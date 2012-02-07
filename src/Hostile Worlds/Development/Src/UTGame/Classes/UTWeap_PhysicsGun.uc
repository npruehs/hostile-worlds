/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTWeap_Physicsgun extends UTWeapon
	HideDropDown;

var()				float			WeaponImpulse;
var()				float			HoldDistanceMin;
var()				float			HoldDistanceMax;
var()				float			ThrowImpulse;
var()				float			ChangeHoldDistanceIncrement;

var					RB_Handle		PhysicsGrabber;
var					float			HoldDistance;
var					Quat			HoldOrientation;


simulated function PostBeginPlay()
{
	Super.PostbeginPlay();
}

/**
 * This function is called from the pawn when the visibility of the weapon changes
 */
simulated function ChangeVisibility(bool bIsVisible)
{
	Super.ChangeVisibility(bIsVisible);
}

simulated function StartFire(byte FireModeNum)
{
	local vector					StartShot, EndShot, PokeDir;
	local vector					HitLocation, HitNormal, Extent;
	local actor						HitActor;
	local float						HitDistance;
	local Quat						PawnQuat, InvPawnQuat, ActorQuat;
	local TraceHitInfo				HitInfo;
	local SkeletalMeshComponent		SkelComp;
	local Rotator					Aim;
	local PhysAnimTestActor			PATActor;
	local StaticMeshComponent HitComponent;
	local KActorFromStatic NewKActor;

	if ( Role < ROLE_Authority )
		return;

	// Do ray check and grab actor
	StartShot	= Instigator.GetWeaponStartTraceLocation();
	Aim			= GetAdjustedAim( StartShot );
	EndShot		= StartShot + (10000.0 * Vector(Aim));
	Extent		= vect(0,0,0);
	HitActor	= Trace(HitLocation, HitNormal, EndShot, StartShot, True, Extent, HitInfo, TRACEFLAG_Bullet);
	HitDistance = VSize(HitLocation - StartShot);

	HitComponent = StaticMeshComponent(HitInfo.HitComponent);
	if ( (HitComponent != None) ) 
	{
		if(HitInfo.PhysMaterial != none)
		{
			if(HitInfo.PhysMaterial.ImpactSound != none)
			{
				PlaySound(HitInfo.PhysMaterial.ImpactSound,,,,HitLocation);
			}

			if(HitInfo.PhysMaterial.ImpactEffect != none)
			{
				WorldInfo.MyEmitterPool.SpawnEmitter(HitInfo.PhysMaterial.ImpactEffect, HitLocation, rotator(HitNormal), none);
			}
		}

		if( HitComponent.CanBecomeDynamic() )
		{
			NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitComponent);
			if ( NewKActor != None )
			{
				HitActor = NewKActor;
			}
		}
	}

	// POKE
	if(FireModeNum == 0)
	{
		PokeDir = Vector(Aim);

		if ( PhysicsGrabber.GrabbedComponent == None )
		{
			// `log("HitActor:"@HitActor@"Hit Bone:"@HitInfo.BoneName);
			if( HitActor != None &&
				HitActor != WorldInfo &&
				HitInfo.HitComponent != None )
			{
				PATActor = PhysAnimTestActor(HitActor);
				if(PATActor != None)
				{
					if( !PATActor.PrePokeActor(PokeDir) )
					{
						return;
					}
				}

				HitInfo.HitComponent.AddImpulse(PokeDir * WeaponImpulse, HitLocation, HitInfo.BoneName);
			}
		}
		else
		{
			PhysicsGrabber.GrabbedComponent.AddImpulse(PokeDir * ThrowImpulse, , PhysicsGrabber.GrabbedBoneName);
			PhysicsGrabber.ReleaseComponent();
		}
	}
	// GRAB
	else
	{
		if( HitActor != None &&
			HitActor != WorldInfo &&
			HitInfo.HitComponent != None &&
			HitDistance > HoldDistanceMin &&
			HitDistance < HoldDistanceMax )
		{
			PATActor = PhysAnimTestActor(HitActor);
			if(PATActor != None)
			{
				if( !PATActor.PreGrab() )
				{
					return;
				}
			}

			// If grabbing a bone of a skeletal mesh, dont constrain orientation.
			SkelComp = SkeletalMeshComponent(HitInfo.HitComponent);
			PhysicsGrabber.GrabComponent(HitInfo.HitComponent, HitInfo.BoneName, HitLocation, (SkelComp == None) && (PlayerController(Instigator.Controller).bRun==0));

			// If we succesfully grabbed something, store some details.
			if (PhysicsGrabber.GrabbedComponent != None)
			{
				HoldDistance	= HitDistance;
				PawnQuat		= QuatFromRotator( Rotation );
				InvPawnQuat		= QuatInvert( PawnQuat );

				if ( HitInfo.BoneName != '' )
				{
					ActorQuat = SkelComp.GetBoneQuaternion(HitInfo.BoneName);
				}
				else
				{
					ActorQuat = QuatFromRotator( PhysicsGrabber.GrabbedComponent.Owner.Rotation );
				}

				HoldOrientation = QuatProduct(InvPawnQuat, ActorQuat);
			}
		}
	}

	Super.StartFire( FireModeNum );
}

simulated function StopFire(byte FireModeNum)
{
	local PhysAnimTestActor	PATActor;

	if ( PhysicsGrabber.GrabbedComponent != None )
	{
		PATActor = PhysAnimTestActor(PhysicsGrabber.GrabbedComponent.Owner);
		if(PATActor != None)
		{
			PATActor.EndGrab();
		}

		PhysicsGrabber.ReleaseComponent();
	}

	Super.StopFire( FireModeNum );
}

simulated function bool DoOverridePrevWeapon()
{
	HoldDistance += ChangeHoldDistanceIncrement;
	HoldDistance = FMin(HoldDistance, HoldDistanceMax);
	return false;
}

simulated function bool DoOverrideNextWeapon()
{
	HoldDistance -= ChangeHoldDistanceIncrement;
	HoldDistance = FMax(HoldDistance, HoldDistanceMin);
	return false;
}

simulated function Tick( float DeltaTime )
{
	local vector	NewHandlePos, StartLoc;
	local Quat		PawnQuat, NewHandleOrientation;
	local Rotator	Aim;

 	if ( PhysicsGrabber.GrabbedComponent == None )
 	{
 		return;
 	}

	PhysicsGrabber.GrabbedComponent.WakeRigidBody( PhysicsGrabber.GrabbedBoneName );

	// Update handle position on grabbed actor.
	if( Instigator != None )
	{
		StartLoc		= Instigator.GetWeaponStartTraceLocation();
		Aim				= GetAdjustedAim( StartLoc );
		NewHandlePos	= StartLoc + (HoldDistance * Vector(Aim));
		PhysicsGrabber.SetLocation( NewHandlePos );

		// Update handle orientation on grabbed actor.
		PawnQuat				= QuatFromRotator( Rotation );
		NewHandleOrientation	= QuatProduct(PawnQuat, HoldOrientation);
		PhysicsGrabber.SetOrientation( NewHandleOrientation );
	}
}

/**
 * Consumes some of the ammo
 */
function ConsumeAmmo( byte FireModeNum )
{
	// dont consume ammo
}

defaultproperties
{
	HoldDistanceMin=0.0
	HoldDistanceMax=750.0
	WeaponImpulse=2000.0
	ThrowImpulse=100.0
	ChangeHoldDistanceIncrement=50.0

	Begin Object Class=RB_Handle Name=RB_Handle0
		LinearDamping=1.0
		LinearStiffness=50.0
		AngularDamping=1.0
		AngularStiffness=50.0
	End Object
	Components.Add(RB_Handle0)
	PhysicsGrabber=RB_Handle0

	WeaponColor=(R=255,G=255,B=128,A=255)
	FireInterval(0)=+1.0
	FireInterval(1)=+1.0
	PlayerViewOffset=(X=0.0,Y=7.0,Z=-9.0)

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Projectile

	FireOffset=(X=16,Y=10)

	AIRating=+0.75
	CurrentRating=+0.75
	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0
	bCanThrow=false

	InventoryGroup=666
	GroupWeight=0.5

	AmmoCount=99
	LockerAmmoCount=99
	MaxAmmoCount=99

	bExportMenuData=false
}
