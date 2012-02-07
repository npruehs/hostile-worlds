/**
 * base class for gibs
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTGib extends Actor
	config(Game)
	notplaceable
	abstract;


/** Our LightEnvironment **/
var DynamicLightEnvironmentComponent GibLightEnvironment;

/** sound played when we hit a wall */
var SoundCue HitSound;

/** the component that will be set to the chosen mesh */
var MeshComponent GibMeshComp;

/** This is the MIC to use for the gib **/
var MaterialInstanceConstant MIC_Gib;

/** This is the MI to use for the decal that this gib may spawn **/
var MaterialInstance MI_Decal;

/** This is the template/parent to use for the decal which will be spawned **/
var protected MaterialInstanceTimeVarying MITV_DecalTemplate;

/** This is the MITV dissolve param for the decal **/
var name DecalDissolveParamName;

/** How long before the Decal should start dissolving **/
var float DecalWaitTimeBeforeDissolve;

/** This is the template/parent to use for the GibMesh which will be spawned **/
var protected MaterialInstanceTimeVarying MITV_GibMeshTemplate;

/** 
 * This is the template/parent to use for the GibMesh which will be spawned.
 * Some of our gibs types have two different materials/packages used so we need to mark which ones need to use the secondary MITV template 
 **/
var protected MaterialInstanceTimeVarying MITV_GibMeshTemplateSecondary;

/** This is the MITV dissolve param for the GibMesh **/
var protected name GibMeshDissolveParamName;

/** How long before the GibMesh should start dissolving **/
var protected float GibMeshWaitTimeBeforeDissolve;

/** PSC for the GibEffect (e.g. for the link gun we play a little lightning) **/
var ParticleSystemComponent PSC_GibEffect;

/** The ParticleSystem or the Custom Gib Effect (if any) **/
var ParticleSystem PS_CustomEffect;

var globalconfig bool bUseUnrealPhysics;

struct StaticMeshDatum
{
	var StaticMesh TheStaticMesh;

	var SkeletalMesh TheSkelMesh;
	var PhysicsAsset ThePhysAsset;

	/** Different gibs can all have different scales based on where the asset came from**/
	var float DrawScale;

	/** Some of our gibs types have two different materials/packages used so we need to mark which ones need to use the secondary MITV template **/
	var bool bUseSecondaryGibMeshMITV;

	structdefaultproperties
	{
		DrawScale=1.0
	}
};

/** list of generic gib meshes from which one will be chosen at random */
var array<StaticMeshDatum> GibMeshesData;

/** Used when is acting as viewtarget */
var vector OldCamLoc;
var rotator OldCamRot;
var bool bStopMovingCamera;


simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	ChooseGib();
}


/**
 * This will force the gib material to stay streamed in and not be affected by distance based streaming
 * which often seems to be causing pops.
 *
 * @paran TimeToBeResident num seconds to be resident
 **/
simulated function SetTexturesToBeResident( float TimeToBeResident )
{
	local int MatIdx;

	for( MatIdx = 0; MatIdx < GibMeshComp.Materials.Length; ++MatIdx )
	{
		GibMeshComp.Materials[MatIdx].SetForceMipLevelsToBeResident( false, false, TimeToBeResident );
	}
}


/**
 * @param	HUD		- HUD with canvas to draw on
 * @input	out_YL		- Height of the current font
 * @input	out_YPos	- Y position on Canvas. out_YPos += out_YL, gives position to draw text for next debug line.
 */
simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	if ( SkeletalMeshComponent(GibMeshComp) != None )
		HUD.Canvas.DrawText("Mesh "$SkeletalMeshComponent(GibMeshComp).SkeletalMesh, false);
	else
		HUD.Canvas.DrawText("Mesh "$StaticMeshComponent(GibMeshComp).StaticMesh, false);
	out_YPos += out_YL;
	HUD.Canvas.SetPos(4,out_YPos);
	super.DisplayDebug(HUD, out_YL, out_YPos);
}

/**
 * This will set the StaticMeshComponent's StaticMesh.  Useful for spawning a UTGib and then setting the value (e.g. the vehicle gibs)
 **/
simulated function SetGibStaticMesh( StaticMesh NewStaticMesh )
{
	local StaticMeshComponent SMC;

	GibMeshComp = new(self) class'UTGibStaticMeshComponent';
	CollisionComponent = GibMeshComp;

	SMC = StaticMeshComponent(GibMeshComp);
	AttachComponent(GibMeshComp);
	// Need to attach before calling SetStaticMesh, so component is in right place before creating physics
	SMC.SetStaticMesh( NewStaticMesh );

	SMC.SetLightEnvironment( GibLightEnvironment );
}


/** This will choose between the two types of gib meshes that we can have. **/
simulated function ChooseGib()
{
	local StaticMeshDatum SMD;
	local StaticMeshComponent SMC;
	local SkeletalMeshComponent SKMC;
	local int StartIndex, Index;
	local MaterialInstanceTimeVarying GibMaterialInstance;
	local CylinderComponent MyCylinder;

	if (GibMeshesData.length > 0)
	{
		Index = Rand(GibMeshesData.length);
		// don't allow skeletal gibs if low detail
		if ( bUseUnrealPhysics || WorldInfo.bDropDetail || WorldInfo.GetDetailMode() == DM_Low || class'Engine'.static.IsSplitScreen() )
		{
			StartIndex = Index;
			while (GibMeshesData[Index].ThePhysAsset != None)
			{
				Index++;
				if (Index >= GibMeshesData.length)
				{
					Index = 0;
				}
				if (Index == StartIndex)
				{
					Destroy();
					return;
				}
			}
		}
		SMD = GibMeshesData[Index];

		// do the static mesh version of the gib
		if( SMD.ThePhysAsset == NONE )
		{
			GibMeshComp = new(self) class'UTGibStaticMeshComponent';

			if ( bUseUnrealPhysics )
			{
				MyCylinder = new(self) class'CylinderComponent';
				CollisionComponent = MyCylinder;
				MyCylinder.SetCylinderSize(5.0, 5.0);
				MyCylinder.SetTraceBlocking(true, false);
				MyCylinder.SetActorCollision(true, false, false);
				SetPhysics(PHYS_Falling);
				bCollideWorld = true;
				bBounce = true;
				AttachComponent(MyCylinder);
			}
			else
			{
				CollisionComponent = GibMeshComp;
			}

			SMC = StaticMeshComponent(GibMeshComp);
			SMC.SetScale(SMD.DrawScale);
			AttachComponent(GibMeshComp);
			// Need to attach before calling SetStaticMesh, so component is in right place before creating physics
			SMC.SetStaticMesh( SMD.TheStaticMesh );
		}
		// do the skeletal mesh version of the gib
		else
		{
			GibMeshComp = new(self) class'UTGibSkeletalMeshComponent';
			CollisionComponent = GibMeshComp;

			SKMC = SkeletalMeshComponent(GibMeshComp);
			SKMC.SetSkeletalMesh( SMD.TheSkelMesh );
			SKMC.SetPhysicsAsset( SMD.ThePhysAsset );
			SKMC.SetScale(SMD.DrawScale);
			AttachComponent(GibMeshComp);
			SKMC.SetHasPhysicsAssetInstance( TRUE ); // this need to comes after the AttachComponent so component is in right place.
		}

		GibMeshComp.SetLightEnvironment( GibLightEnvironment );

		DoCustomGibEffects();

		if (!WorldInfo.IsConsoleBuild(CONSOLE_Mobile))
		{
			// this is going to set up the MITV so we can have the gibs burn out nicely
			GibMaterialInstance = new(self) class'MaterialInstanceTimeVarying';
			if( SMD.bUseSecondaryGibMeshMITV == FALSE )
			{
				GibMaterialInstance.SetParent( MITV_GibMeshTemplate );
			}
			else
			{
				GibMaterialInstance.SetParent( MITV_GibMeshTemplateSecondary );
			}

			GibMeshComp.SetMaterial( 0, GibMaterialInstance );

			GibMaterialInstance.SetScalarStartTime( GibMeshDissolveParamName, (GibMeshWaitTimeBeforeDissolve-(FRand()*1.0f)));
		}
	}
	else
	{
		//`warn( "Unable to find mesh for: " $ self );
		//ScriptTrace();
		Destroy();
	}
}


/** This will do any custom gib effects for this gib.  (e.g. robots have a sparkie that plays!) **/
simulated function DoCustomGibEffects();


function Timer()
{
	local PlayerController PC;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if( PC.ViewTarget == self )
		{
			SetTimer( 4.0, FALSE );
			return;
		}
	}

	Destroy();
}

event BecomeViewTarget( PlayerController PC )
{
	SetHidden( TRUE );
	LifeSpan = 0;
	SetTimer( 4.0, FALSE );
}


/**
 *	Calculate camera view point, when viewing this actor.
 *
 * @param	fDeltaTime	delta time seconds since last update
 * @param	out_CamLoc	Camera Location
 * @param	out_CamRot	Camera Rotation
 * @param	out_FOV		Field of View
 *
 * @return	true if Actor should provide the camera point of view.
 */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	local int InYaw;

	if( Physics != PHYS_None )
	{
		if ( bStopMovingCamera )
		{
			OldCamRot.Roll = OldCamRot.Roll & 65535;
			if ( (OldCamRot.Roll < 8192) || (OldCamRot.Roll > 57343) )
			{
				out_CamRot = Rotation;
				out_CamRot.Pitch = 0;
				OldCamRot = out_CamRot;
			}
			else
			{
				InYaw = out_CamRot.Yaw;
				out_CamRot = OldCamRot;
				out_CamRot.Yaw = InYaw;
			}
		}
		else
		{
			out_CamRot = Rotation;
			out_CamRot.Pitch = 0;
			OldCamRot = out_CamRot;
		}
	}

	out_CamLoc = Location;

	if ( OldCamLoc != vect(0,0,0) )
	{
		HitActor = trace(HitLocation, HitNormal, Location, OldCamLoc, false, vect(14,14,14));
		if ( HitActor != None )
		{
			out_CamLoc = HitLocation;
			bStopMovingCamera = (HitNormal.Z > 0.7);
		}
	}
	OldCamLoc = out_CamLoc;
	return false;
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
					const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	// don't spawn a decal unless we have more than likely hit something other than the orig pawn or other Gibs
	if( (WorldInfo.TimeSeconds - CreationTime ) > 0.4 )
	{
		// once we hit one thing don't fire off anymore hits
		if( GibMeshComp != none )
		{
			GibMeshComp.SetNotifyRigidBodyCollision( FALSE );
		}

		if ( EffectIsRelevant(Location, false, 4000.0) )
		{
			PlaySound( HitSound, TRUE );
			LeaveADecal( Location, Normal(Velocity) );
		}
	}
}

/** Data provided by the derived classes to do their specific form of decal leaving (e.g. blood for bodies, green goop for aliens, etc.) **/
simulated function LeaveADecal( vector HitLoc, vector HitNorm )
{
	local Actor TraceActor;
	local vector out_HitLocation;
	local vector out_HitNormal;
	local vector TraceDest;
	local vector TraceStart;
	local vector TraceExtent;
	local TraceHitInfo HitInfo;

	// this code is mostly duplicated in:  UTGib, UTProjectile, UTVehicle, UTWeaponAttachment be aware when updating
	// see if our child class provided a template to spawn
	if( MITV_DecalTemplate != none )
	{
		// these should be randomized
		TraceStart = HitLoc + ( -HitNorm * 15 );
		TraceDest = HitLoc + ( HitNorm * 15 );
		//DrawDebugLine( TraceStart, TraceDest, 255,255,255, TRUE );

		TraceActor = Trace( out_HitLocation, out_HitNormal, TraceDest, TraceStart, false, TraceExtent, HitInfo, TRACEFLAG_PhysicsVolumes );

		if( TraceActor != None )
		{
			MI_Decal = new(self) class'MaterialInstanceTimeVarying';
			MI_Decal.SetParent( MITV_DecalTemplate );

			WorldInfo.MyDecalManager.SpawnDecal(MI_Decal, out_HitLocation, rotator(-out_HitNormal), 200, 200, 10, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex);

			MaterialInstanceTimeVarying(MI_Decal).SetScalarStartTime( DecalDissolveParamName, DecalWaitTimeBeforeDissolve );
		}
	}
}

simulated function TurnOnCollision()
{
	//`log( "COLLIDING ON: " $ self );
	//GibMeshComp.SetActorCollision( TRUE, FALSE );

	GibMeshComp.SetBlockRigidBody( TRUE );

	GibMeshComp.SetRBCollidesWithChannel( RBCC_Default, TRUE );
	GibMeshComp.SetRBCollidesWithChannel( RBCC_Pawn, TRUE );
	GibMeshComp.SetRBCollidesWithChannel( RBCC_Vehicle, TRUE );
	GibMeshComp.SetRBCollidesWithChannel( RBCC_GameplayPhysics, TRUE );
	GibMeshComp.SetRBCollidesWithChannel( RBCC_EffectPhysics, TRUE );

	DetachComponent(GibMeshComp);
	AttachComponent(GibMeshComp);

	GibMeshComp.WakeRigidBody();
}

//===================================================
// SUPPORT FOR GIBS USING UNREAL PHYSICS

event Landed(vector HitNormal, Actor FloorActor)
{
	HitWall(HitNormal, FloorActor, None);
}

event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	local float Speed;

	Velocity = Velocity - 2 * (Velocity dot HitNormal) * HitNormal;
	if ( LifeSpan < Default.LifeSpan - 0.3 )
	{
		Velocity *= 0.5;
	}

	Speed = VSize(Velocity);

	if( (WorldInfo.TimeSeconds - CreationTime ) > 0.4 )
	{
		if ( EffectIsRelevant(Location, false, 4000.0) )
		{
			PlaySound( HitSound, TRUE );
			LeaveADecal( Location, Normal(Velocity) );
		}
	}

	if ( (HitNormal.Z > 0.7) && (Speed < 20) )
	{
		bBounce = false;
		SetPhysics(PHYS_None);
	}
}

defaultproperties
{
	// each gib has their own LightEnvironment as they can travel pretty far through disparate lighting variations
 	Begin Object Class=DynamicLightEnvironmentComponent Name=GibLightEnvironmentComp
 		bCastShadows=FALSE
		bDynamic=TRUE // we might want to change this to FALSE as it should be good to grab the light where the spawning occurs
		AmbientGlow=(R=0.5,G=0.5,B=0.5)
		AmbientShadowColor=(R=0.3,G=0.3,B=0.3)
 	End Object
 	GibLightEnvironment=GibLightEnvironmentComp
 	Components.Add(GibLightEnvironmentComp)

	TickGroup=TG_PostAsyncWork
	RemoteRole=ROLE_None
	Physics=PHYS_RigidBody

	bNoEncroachCheck=true
	bDestroyedByInterpActor=TRUE
	bCollideActors=true
	bBlockActors=false
	bWorldGeometry=false
	bCollideWorld=FALSE  // we want the gib to use the rigidbody collision.  Setting this to TRUE means that unreal physics will try to control
	bProjTarget=true
	LifeSpan=10.0
	bGameRelevant=true

	DecalDissolveParamName="DissolveAmount"
	DecalWaitTimeBeforeDissolve=20.0f

	//Which ramps from 0 (fully opaque) to 9.9 (fully burnt out) over the time we want the gib to fade out.
	GibMeshDissolveParamName="BurnTime"
	GibMeshWaitTimeBeforeDissolve=8.0f
}
