// ============================================================================
// HWWeaponAttachment
// An abstract WeaponAttachment of Hostile Worlds. 
// Copied from UTWeaponAttachment.
//
// Author:  Marcel Koehler
// Date:    2010/12/30
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWWeaponAttachment extends Actor
	abstract;

/** The skeletal mesh that represents this weapon. */
var SkeletalMeshComponent Mesh;

/** Holds the name of the socket to attach a muzzle flash to. */
var name MuzzleFlashSocket;

/** The particle system responsible for causing the muzzle flashs of this weapon. */
var ParticleSystemComponent	MuzzleFlashPSC;

/** The template for the particle system responsible for causing the muzzle flashs of this weapon. */
var ParticleSystem MuzzleFlashPSCTemplate;

/** The type of the light that illuminates objects near the muzzle flash. */
var class<UDKExplosionLight> MuzzleFlashLightClass;

/** The light that illuminates objects near the muzzle flash. */
var	UDKExplosionLight MuzzleFlashLight;

/** How long the Muzzle Flash should be there. */
var float MuzzleFlashDuration;

/** When the DistanceFactor for this weapon drops below this, force it into the ref pose (don't do animations etc) */
var float DistFactorForRefPose;


simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(1.0, TRUE, 'CheckToForceRefPose');

	Mesh.SetHidden(false);
}

/** 
 *  Periodically checks whether this weapon is too far away from the camera
 *  and the system can save GPU time by using cheaper vertex shaders and not
 *  showing animations.
 */
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

/**
 * Called on a client, this function attaches the weapon to the squad member
 * and initializes the muzzle flash particle system.
 * 
 * @param OwnerPawn
 *      the unit to attach this weapon to
 */
simulated function AttachTo(HWSquadMember OwnerPawn)
{
	if (OwnerPawn.Mesh != None)
	{
		// Attach Weapon mesh to player skelmesh
		if ( Mesh != None )
		{
			// Weapon Mesh Shadow
			Mesh.SetShadowParent(OwnerPawn.Mesh);
			Mesh.SetLightEnvironment(OwnerPawn.LightEnvironment);

			OwnerPawn.Mesh.AttachComponentToSocket(Mesh, OwnerPawn.WeaponSocket);
		}
	}

	if (MuzzleFlashSocket != '')
	{
		if (MuzzleFlashPSCTemplate != None)
		{
			MuzzleFlashPSC = new(self) class'UDKParticleSystemComponent';
			MuzzleFlashPSC.bAutoActivate = false;
			MuzzleFlashPSC.SetOwnerNoSee(true);
			Mesh.AttachComponentToSocket(MuzzleFlashPSC, MuzzleFlashSocket);
		}
	}
}

/**
 * Turns the MuzzleFlashlight off.
 */
simulated function MuzzleFlashTimer()
{
	if ( MuzzleFlashLight != None )
	{
		MuzzleFlashLight.SetEnabled(FALSE);
	}

	if (MuzzleFlashPSC != none)
	{
		MuzzleFlashPSC.DeactivateSystem();
	}
}

/**
 * Causes the muzzle flash to turn on and sets up a time to turn it back off
 * again.
 */
simulated function CauseMuzzleFlash()
{
	// only enable muzzleflash light if performance is high enough
	if (!WorldInfo.bDropDetail)
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
				else
				{
					`log("WARNING: "$class$" has no MuzzleFlashSocket!");
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
		if (!MuzzleFlashPSC.bIsActive)
		{			
			if (MuzzleFlashPSCTemplate != MuzzleFlashPSC.Template)
			{
				MuzzleFlashPSC.SetTemplate(MuzzleFlashPSCTemplate);
			}
			MuzzleFlashPSC.ActivateSystem();
		}
	}

	// Set when to turn it off.
	SetTimer(MuzzleFlashDuration,false,'MuzzleFlashTimer');
}

/**
 * Stops the muzzle flash.
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
 *  Computes the starting location for muzzle flash effects and projectiles.
 *  
 *  @return
 *      the starting location for muzzle flash effects and projectiles
 */
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
	Begin Object class=UDKAnimNodeSequence Name=MeshSequenceA
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
	MuzzleFlashDuration=0.3
	DistFactorForRefPose=0.14
}
