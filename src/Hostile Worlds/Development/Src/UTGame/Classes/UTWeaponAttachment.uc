/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTWeaponAttachment extends Actor
	abstract
	dependson(UTPawn);

/*********************************************************************************************
 Animations and Sounds
********************************************************************************************* */

var class<Actor> SplashEffect;

/*********************************************************************************************
 Weapon Components
********************************************************************************************* */

/** Weapon SkelMesh */
var SkeletalMeshComponent Mesh;

/*********************************************************************************************
 Overlays
********************************************************************************************* */

/** mesh for overlay - Each weapon will need to add it's own overlay mesh in it's default props */
var protected SkeletalMeshComponent OverlayMesh;

/*********************************************************************************************
 Muzzle Flash
********************************************************************************************* */

/** Holds the name of the socket to attach a muzzle flash too */
var name					MuzzleFlashSocket;

/** Muzzle flash PSC and Templates*/

var ParticleSystemComponent	MuzzleFlashPSC;
var ParticleSystem			MuzzleFlashPSCTemplate, MuzzleFlashAltPSCTemplate;
var color					MuzzleFlashColor;
var bool					bMuzzleFlashPSCLoops;

/** dynamic light */
var class<UDKExplosionLight> MuzzleFlashLightClass;
var	UDKExplosionLight		MuzzleFlashLight;

/** How long the Muzzle Flash should be there */
var float					MuzzleFlashDuration;

/** TEMP for guns with no muzzleflash socket */
var SkeletalMeshComponent OwnerMesh;
var Name AttachmentSocket;

/*********************************************************************************************
 Effects
********************************************************************************************* */

/** impact effects by material type */
var array<MaterialImpactEffect> ImpactEffects, AltImpactEffects;
/** default impact effect to use if a material specific one isn't found */
var MaterialImpactEffect DefaultImpactEffect, DefaultAltImpactEffect;

/** sound that is played when the bullets go whizzing past your head */
var SoundCue BulletWhip;

var float MaxImpactEffectDistance;
var float MaxFireEffectDistance;

var bool bAlignToSurfaceNormal;

var class<UTWeapon> WeaponClass;

var bool bSuppressSounds;

var float MaxDecalRangeSq;

/** When the DistanceFactor for this weapon drops below this, force it into the ref pose (don't do animations etc) */
var float DistFactorForRefPose;

/** If true, make splash effect for local player when hit water */
var bool bMakeSplash;

/*********************************************************************************************
 Anim
********************************************************************************************* */

/** anims to play when firing */
var name FireAnim, AltFireAnim;

var EWeapAnimType WeapAnimType;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(1.0, TRUE, 'CheckToForceRefPose');
}

simulated function CheckToForceRefPose()
{
	if((WorldInfo.TimeSeconds - Mesh.LastRenderTime) > 1.0 || Mesh.MaxDistanceFactor < DistFactorForRefPose)
	{
		if(Mesh.bForceRefpose == 0)
		{
			Mesh.SetForceRefPose(TRUE);
		}
	}
	else
	{
		if(Mesh.bForceRefpose != 0)
		{
			Mesh.SetForceRefPose(FALSE);
		}
	}
}

simulated function CreateOverlayMesh()
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		OverlayMesh = new(self) Mesh.Class;
		OverlayMesh.SetScale(1.00);
		OverlayMesh.SetSkeletalMesh(Mesh.SkeletalMesh);
		OverlayMesh.SetOwnerNoSee(true);
		OverlayMesh.SetOnlyOwnerSee(false);
		OverlayMesh.AnimSets = Mesh.AnimSets;
		OverlayMesh.SetParentAnimComponent(Mesh);
		OverlayMesh.bUpdateSkelWhenNotRendered = false;
		OverlayMesh.bIgnoreControllersWhenNotRendered = true;
		OverlayMesh.bOverrideAttachmentOwnerVisibility = true;

		if (UDKSkeletalMeshComponent(OverlayMesh) != none)
		{
			UDKSkeletalMeshComponent(OverlayMesh).SetFOV(UDKSkeletalMeshComponent(Mesh).FOV);
		}
	}
}


function SetSkin(Material NewMaterial)
{
	local int i,Cnt;

	if ( NewMaterial == None )	// Clear the materials
	{
		if ( default.Mesh.Materials.Length > 0 )
		{
			Cnt = Default.Mesh.Materials.Length;
			for (i=0;i<Cnt;i++)
			{
				Mesh.SetMaterial( i, Default.Mesh.GetMaterial(i) );
			}
		}
		else if (Mesh.Materials.Length > 0)
		{
			Cnt = Mesh.Materials.Length;
			for ( i=0; i < Cnt; i++ )
			{
				Mesh.SetMaterial(i,none);
			}
		}
	}
	else
	{
		if ( default.Mesh.Materials.Length > 0 || mesh.GetNumElements() > 0 )
		{
			Cnt = default.Mesh.Materials.Length > 0 ? default.Mesh.Materials.Length : mesh.GetNumElements();
			for ( i=0; i < Cnt; i++ )
			{
				Mesh.SetMaterial(i,NewMaterial);
			}
		}
	}
}

/**
 * Allows a child to setup custom parameters on the muzzle flash
 */
simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	PSC.SetColorParameter('MuzzleFlashColor', MuzzleFlashColor);
}

/**
 * Called on a client, this function Attaches the WeaponAttachment
 * to the Mesh.
 */
simulated function AttachTo(UTPawn OwnerPawn)
{
	SetWeaponOverlayFlags(OwnerPawn);

	if (OwnerPawn.Mesh != None)
	{
		// Attach Weapon mesh to player skelmesh
		if ( Mesh != None )
		{
			OwnerMesh = OwnerPawn.Mesh;
			AttachmentSocket = OwnerPawn.WeaponSocket;

			// Weapon Mesh Shadow
			Mesh.SetShadowParent(OwnerPawn.Mesh);
			Mesh.SetLightEnvironment(OwnerPawn.LightEnvironment);

			if (OwnerPawn.ReplicatedBodyMaterial != None)
			{
				SetSkin(OwnerPawn.ReplicatedBodyMaterial);
			}

			OwnerPawn.Mesh.AttachComponentToSocket(Mesh, OwnerPawn.WeaponSocket);
		}

		if (OverlayMesh != none)
		{
			OwnerPawn.Mesh.AttachComponentToSocket(OverlayMesh, OwnerPawn.WeaponSocket);
		}
	}

	if (MuzzleFlashSocket != '')
	{
		if (MuzzleFlashPSCTemplate != None || MuzzleFlashAltPSCTemplate != None)
		{
			MuzzleFlashPSC = new(self) class'UTParticleSystemComponent';
			MuzzleFlashPSC.bAutoActivate = false;
			MuzzleFlashPSC.SetOwnerNoSee(true);
			Mesh.AttachComponentToSocket(MuzzleFlashPSC, MuzzleFlashSocket);
		}
	}

	OwnerPawn.SetWeapAnimType(WeapAnimType);

	GotoState('CurrentlyAttached');
}

/** sets whether the weapon is being put away */
simulated function SetPuttingDownWeapon(bool bNowPuttingDown);

/**
 * Detach weapon from skeletal mesh
 */
simulated function DetachFrom( SkeletalMeshComponent MeshCpnt )
{
	SetSkin(None);

	// Weapon Mesh Shadow
	if ( Mesh != None )
	{
		Mesh.SetShadowParent(None);
		Mesh.SetLightEnvironment(None);
		// muzzle flash effects
		if (MuzzleFlashPSC != None)
		{
			Mesh.DetachComponent(MuzzleFlashPSC);
		}
		if (MuzzleFlashLight != None)
		{
			Mesh.DetachComponent(MuzzleFlashLight);
		}
	}
	if ( MeshCpnt != None )
	{
		// detach weapon mesh from player skelmesh
		if ( Mesh != None )
		{
			MeshCpnt.DetachComponent( mesh );
		}

		if ( OverlayMesh != none )
		{
			MeshCpnt.DetachComponent( OverlayMesh );
		}
	}

	GotoState('');
}

/**
 * Turns the MuzzleFlashlight off
 */
simulated function MuzzleFlashTimer()
{
	if ( MuzzleFlashLight != None )
	{
		MuzzleFlashLight.SetEnabled(FALSE);
	}

	if (MuzzleFlashPSC != none && (!bMuzzleFlashPSCLoops) )
	{
		MuzzleFlashPSC.DeactivateSystem();
	}
}

/**
 * Causes the muzzle flash to turn on and setup a time to
 * turn it back off again.
 */
simulated function CauseMuzzleFlash()
{
	local ParticleSystem MuzzleTemplate;

	// only enable muzzleflash light if performance is high enough
	// enable muzzleflash on mobile since its one of the few ways to show dynamic lighting on skelmeshes
	if ((!WorldInfo.bDropDetail && !class'Engine'.static.IsSplitScreen()) || WorldInfo.IsConsoleBuild(CONSOLE_Mobile) )
	{
		if ( MuzzleFlashLight == None )
		{
			if ( MuzzleFlashLightClass != None )
			{
				MuzzleFlashLight = new(Outer) MuzzleFlashLightClass;
				if (Mesh != None && Mesh.GetSocketByName(MuzzleFlashSocket) != None)
				{
					Mesh.AttachComponentToSocket(MuzzleFlashLight, MuzzleFlashSocket);
				}
				else if ( OwnerMesh != None )
				{
					OwnerMesh.AttachComponentToSocket(MuzzleFlashLight, AttachmentSocket);
				}
			}
		}
		else
		{
			MuzzleFlashLight.ResetLight();
		}
	}

	if (MuzzleFlashPSC != none)
	{
		if ( !bMuzzleFlashPSCLoops || !MuzzleFlashPSC.bIsActive)
		{
			if (Instigator != None && Instigator.FiringMode == 1 && MuzzleFlashAltPSCTemplate != None)
			{
				MuzzleTemplate = MuzzleFlashAltPSCTemplate;
			}
			else
			{
				MuzzleTemplate = MuzzleFlashPSCTemplate;
			}
			if (MuzzleTemplate != MuzzleFlashPSC.Template)
			{
				MuzzleFlashPSC.SetTemplate(MuzzleTemplate);
			}
			SetMuzzleFlashParams(MuzzleFlashPSC);
			MuzzleFlashPSC.ActivateSystem();
		}
	}

	// Set when to turn it off.
	SetTimer(MuzzleFlashDuration,false,'MuzzleFlashTimer');

}

/**
 * Stops the muzzle flash
 */
simulated function StopMuzzleFlash()
{
	ClearTimer('MuzzleFlashTimer');
	MuzzleFlashTimer();

	if ( MuzzleFlashPSC != none )
	{
		MuzzleFlashPSC.DeactivateSystem();
	}
}

/**
 * The Weapon attachment, though hidden, is also responsible for controlling
 * the first person effects for a weapon.
 */

simulated function FirstPersonFireEffects(Weapon PawnWeapon, vector HitLocation)	// Should be subclassed
{
	if (PawnWeapon!=None)
	{
		// Tell the weapon to cause the muzzle flash, etc.
		PawnWeapon.PlayFireEffects( Pawn(Owner).FiringMode, HitLocation );
	}
}

simulated function StopFirstPersonFireEffects(Weapon PawnWeapon)	// Should be subclassed
{
	if (PawnWeapon!=None)
	{
		// Tell the weapon to cause the muzzle flash, etc.
		PawnWeapon.StopFireEffects( Pawn(Owner).FiringMode );
	}
}

/**
 * Spawn all of the effects that will be seen in behindview/remote clients.  This
 * function is called from the pawn, and should only be called when on a remote client or
 * if the local client is in a 3rd person mode.
*/
simulated function ThirdPersonFireEffects(vector HitLocation)
{
	local UTPawn P;
	if ( EffectIsRelevant(Location,false,MaxFireEffectDistance) )
	{
		// Light it up
		CauseMuzzleFlash();
	}

	// Have pawn play firing anim
	P = UTPawn(Instigator);
	if (P != None && P.GunRecoilNode != None)
	{
		// Use recoil node to move arms when we fire
		P.GunRecoilNode.bPlayRecoil = true;
	}

	if (Instigator.FiringMode == 1 && AltFireAnim != 'None')
	{
		Mesh.PlayAnim(AltFireAnim,,, false);
	}
	else if (FireAnim != 'None')
	{
		Mesh.PlayAnim(FireAnim,,, false);
	}
}

simulated event StopThirdPersonFireEffects()
{
	StopMuzzleFlash();
}

/** returns the impact sound that should be used for hits on the given physical material */
simulated function MaterialImpactEffect GetImpactEffect(PhysicalMaterial HitMaterial)
{
	local int i;
	local UTPhysicalMaterialProperty PhysicalProperty;

	if (HitMaterial != None)
	{
		PhysicalProperty = UTPhysicalMaterialProperty(HitMaterial.GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty'));
	}
	if (UTPawn(Owner).FiringMode > 0)
	{
		if (PhysicalProperty != None && PhysicalProperty.MaterialType != 'None')
		{
			i = AltImpactEffects.Find('MaterialType', PhysicalProperty.MaterialType);
			if (i != -1)
			{
				return AltImpactEffects[i];
			}
		}
		return DefaultAltImpactEffect;
	}
	else
	{
		if (PhysicalProperty != None && PhysicalProperty.MaterialType != 'None')
		{
			i = ImpactEffects.Find('MaterialType', PhysicalProperty.MaterialType);
			if (i != -1)
			{
				return ImpactEffects[i];
			}
		}
		return DefaultImpactEffect;
	}
}

simulated function bool AllowImpactEffects(Actor HitActor, vector HitLocation, vector HitNormal)
{
	return (PortalTeleporter(HitActor) == None);
}

simulated function SetImpactedActor(Actor HitActor, vector HitLocation, vector HitNormal, TraceHitInfo HitInfo);

/**
 * Spawn any effects that occur at the impact point.  It's called from the pawn.
 */
simulated function PlayImpactEffects(vector HitLocation)
{
	local vector NewHitLoc, HitNormal, FireDir, WaterHitNormal;
	local Actor HitActor;
	local TraceHitInfo HitInfo;
	local MaterialImpactEffect ImpactEffect;
	local MaterialInterface MI;
	local MaterialInstanceTimeVarying MITV_Decal;
	local int DecalMaterialsLength;
	local Vehicle V;
	local UTPawn P;

	P = UTPawn(Owner);
	HitNormal = Normal(Owner.Location - HitLocation);
	FireDir = -1 * HitNormal;
	if ( (P != None) && EffectIsRelevant(HitLocation, false, MaxImpactEffectDistance) )
	{
		if ( bMakeSplash && !WorldInfo.bDropDetail && P.IsPlayerPawn() && P.IsLocallyControlled() )
		{
			HitActor = Trace(NewHitLoc, WaterHitNormal, HitLocation, P.Location+P.eyeheight*vect(0,0,1), true,, HitInfo, TRACEFLAG_PhysicsVolumes | TRACEFLAG_Bullet);
			if ( UTWaterVolume(HitActor) != None )
			{
				WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'Envy_Effects.Particles.P_WP_Water_Splash_Small', NewHitLoc, rotator(vect(0,0,1)));
			}
		}
		HitActor = Trace(NewHitLoc, HitNormal, (HitLocation - (HitNormal * 32)), HitLocation + (HitNormal * 32), true,, HitInfo, TRACEFLAG_Bullet);
		if(Pawn(HitActor) != none)
		{
			CheckHitInfo(HitInfo, Pawn(HitActor).Mesh, -HitNormal, NewHitLoc);
		}
		SetImpactedActor(HitActor, HitLocation, HitNormal, HitInfo);
		// figure out the impact sound to use
		ImpactEffect = GetImpactEffect(HitInfo.PhysMaterial);
		V = Vehicle(HitActor);
		if (ImpactEffect.Sound != None && !bSuppressSounds)
		{
			// if hit a vehicle controlled by the local player, always play it full volume
			if (V != None && V.IsLocallyControlled() && V.IsHumanControlled())
			{
				PlayerController(V.Controller).ClientPlaySound(ImpactEffect.Sound);
			}
			else
			{
				if ( BulletWhip != None )
				{
					CheckBulletWhip(FireDir, HitLocation);
				}
				PlaySound(ImpactEffect.Sound, true,,, HitLocation);
			}
		}
		if ( UTVehicle(V) != none && Role < ROLE_Authority && !WorldInfo.GRI.OnSameTeam(Owner,V) )
		{
			UTVehicle(V).ApplyMorphDamage(HitLocation, WeaponClass.Default.InstantHitDamage[UTPawn(Owner).FiringMode], WeaponClass.Default.InstantHitMomentum[UTPawn(Owner).FiringMode]*FireDir);
		}

		// Pawns handle their own hit effects
		if ( HitActor != None &&
			 (Pawn(HitActor) == None || Vehicle(HitActor) != None) &&
			 AllowImpactEffects(HitActor, HitLocation, HitNormal) )
		{
			// this code is mostly duplicated in:  UTGib, UTProjectile, UTVehicle, UTWeaponAttachment be aware when updating
			if ( !WorldInfo.bDropDetail
				&& (Pawn(HitActor) == None)
				&& (VSizeSQ(Owner.Location - HitLocation) < MaxDecalRangeSq)
				&& (((WorldInfo.GetDetailMode() != DM_Low) && !class'Engine'.static.IsSplitScreen()) || (P.IsLocallyControlled() && P.IsHumanControlled())) )
			{
				// if we have a decal to spawn on impact
				DecalMaterialsLength = ImpactEffect.DecalMaterials.length;
				if( DecalMaterialsLength > 0 )
				{
					MI = ImpactEffect.DecalMaterials[Rand(DecalMaterialsLength)];
					if( MI != None )
					{
						if( MaterialInstanceTimeVarying(MI) != none )
						{
							// hack, since they don't show up on terrain anyway
							if ( Terrain(HitActor) == None )
							{
							MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
							MITV_Decal.SetParent( MI );

							WorldInfo.MyDecalManager.SpawnDecal( MITV_Decal, HitLocation, rotator(-HitNormal), ImpactEffect.DecalWidth,
								ImpactEffect.DecalHeight, 10.0, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex );
							//here we need to see if we are an MITV and then set the burn out times to occur
							MITV_Decal.SetScalarStartTime( ImpactEffect.DecalDissolveParamName, ImpactEffect.DurationOfDecal );
						}
						}
						else
						{
							WorldInfo.MyDecalManager.SpawnDecal( MI, HitLocation, rotator(-HitNormal), ImpactEffect.DecalWidth,
								ImpactEffect.DecalHeight, 10.0, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex );
						}
					}
				}
			}

			if (ImpactEffect.ParticleTemplate != None)
			{
				if (!bAlignToSurfaceNormal)
				{
					HitNormal = normal(FireDir - ( 2 *  HitNormal * (FireDir dot HitNormal) ) ) ;
				}
				WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffect.ParticleTemplate, HitLocation, rotator(HitNormal), HitActor);
			}
		}
	}
	else if ( BulletWhip != None )
	{
		CheckBulletWhip(FireDir, HitLocation);
	}
}

simulated function CheckBulletWhip(vector FireDir, vector HitLocation)
{
	local UTPlayerController PC;

	ForEach LocalPlayerControllers(class'UTPlayerController', PC)
	{
		if ( !WorldInfo.GRI.OnSameTeam(Owner,PC) )
			PC.CheckBulletWhip(BulletWhip, Owner.Location, FireDir, HitLocation);
	}
}

/** When an attachment is attached to a pawn, it enters the CurrentlyAttached state.  */
state CurrentlyAttached
{
}

/* FIXMESTEVE
simulated function CheckForSplash()
{
	local Actor HitActor;
	local vector HitNormal, HitLocation;

	if ( !WorldInfo.bDropDetail && (WorldInfo.DetailMode != DM_Low) && (SplashEffect != None) && !Instigator.PhysicsVolume.bWaterVolume )
	{
		// check for splash
		HitActor = Trace(HitLocation,HitNormal,mHitLocation,Instigator.Location,true,,true);
		if ( (PhysicsVolume(HitActor) != None) && PhysicsVolume(HitActor).bWaterVolume )
			Spawn(SplashEffect,,,HitLocation,rot(16384,0,0));
	}
}
*/

simulated function SetWeaponOverlayFlags(UTPawn OwnerPawn)
{
	local MaterialInterface InstanceToUse;
	local byte Flags;
	local int i;
	local UTGameReplicationInfo GRI;

	GRI = UTGameReplicationInfo(WorldInfo.GRI);
	if (GRI != None)
	{
		Flags = OwnerPawn.WeaponOverlayFlags;
		for (i = 0; i < GRI.WeaponOverlays.length; i++)
		{
			if (GRI.WeaponOverlays[i] != None && bool(Flags & (1 << i)))
			{
				InstanceToUse = GRI.WeaponOverlays[i];
				break;
			}
		}
	}
	if (InstanceToUse != none)
	{
		if (OverlayMesh == None)
		{
			CreateOverlayMesh();
		}
		if ( OverlayMesh != none )
		{
			for (i=0;i<OverlayMesh.GetNumElements(); i++)
			{
				OverlayMesh.SetMaterial(i, InstanceToUse);
			}

			OverlayMesh.SetHidden(false);
			if (!OverlayMesh.bAttached)
			{
				OwnerPawn.Mesh.AttachComponentToSocket(OverlayMesh, OwnerPawn.WeaponSocket);
			}
		}
	}
	else if ( OverlayMesh != none )
	{
		OverlayMesh.SetHidden(true);
		OwnerPawn.Mesh.DetachComponent(OverlayMesh);
	}
}

simulated function ChangeVisibility(bool bIsVisible)
{
	if (Mesh != None)
	{
		Mesh.SetHidden(!bIsVisible);
	}

	if (OverlayMesh != none)
	{
		OverlayMesh.SetHidden(!bIsVisible);
	}
}

simulated function FireModeUpdated(byte FiringMode, bool bViaReplication);

/** @return the starting location for effects (generally tracers) */
simulated function vector GetEffectLocation()
{
	local vector SocketLocation;

	if (MuzzleFlashSocket != 'None')
	{
		Mesh.GetSocketWorldLocationAndRotation(MuzzleFlashSocket, SocketLocation);
		return SocketLocation;
	}
	else
	{
		return Mesh.Bounds.Origin + (vect(45,0,0) >> Instigator.Rotation);
	}
}

defaultproperties
{
	Begin Object class=UTAnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		bOwnerNoSee=true
		bOnlyOwnerSee=false
		CollideActors=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000
		bForceRefPose=1
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		Animations=MeshSequenceA
		CastShadow=true
		bCastDynamicShadow=true
		MotionBlurScale=0.0
		bAllowAmbientOcclusion=false
	End Object
	Mesh=SkeletalMeshComponent0

	TickGroup=TG_DuringAsyncWork
	NetUpdateFrequency=10
	RemoteRole=ROLE_None
	bReplicateInstigator=true
	MaxImpactEffectDistance=4000.0
	MaxFireEffectDistance=5000.0
	bAlignToSurfaceNormal=true
	MuzzleFlashDuration=0.3
	MuzzleFlashColor=(R=255,G=255,B=255,A=255)
	MaxDecalRangeSQ=16000000.0
	DistFactorForRefPose=0.14
}
