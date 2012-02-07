/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 *
 * BeamWeapons have at least 1 firing state set to WeaponBeamFiring.  This class contains all of the basics
 * needed for that type of weapon
*/

class UTBeamWeapon extends UTWeapon
	abstract;

/** The Particle System Template for the Beam */
var particleSystem BeamTemplate[2];

/** Holds the Emitter for the Beam */
var ParticleSystemComponent BeamEmitter[2];

/** Where to attach the Beam */
var name BeamSockets[2];

/** The name of the EndPoint parameter */
var name EndPointParamName;

/** Animations to play before firing the beam */
var name	BeamPreFireAnim[2];
var name	BeamFireAnim[2];
var name	BeamPostFireAnim[2];

var ForceFeedbackWaveform	BeamWeaponFireWaveForm;

simulated function AddBeamEmitter()
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (BeamEmitter[CurrentFireMode] == None)
		{
			if (BeamTemplate[CurrentFireMode] != None)
			{
				BeamEmitter[CurrentFireMode] = new(Outer) class'UTParticleSystemComponent';
				BeamEmitter[CurrentFireMode].SetDepthPriorityGroup(SDPG_Foreground);
				BeamEmitter[CurrentFireMode].SetTemplate(BeamTemplate[CurrentFireMode]);
				BeamEmitter[CurrentFireMode].SetHidden(true);
				BeamEmitter[CurrentFireMode].SetTickGroup( TG_PostUpdateWork );
				BeamEmitter[CurrentFireMode].bUpdateComponentInTick = true;
				BeamEmitter[CurrentFireMode].SetIgnoreOwnerHidden(TRUE);
				SkeletalMeshComponent(Mesh).AttachComponentToSocket( BeamEmitter[CurrentFireMode],BeamSockets[CurrentFireMode] );
			}
		}
		else
		{
			BeamEmitter[CurrentFireMode].ActivateSystem();
		}
	}
}

simulated function KillBeamEmitter()
{
	if (BeamEmitter[CurrentFireMode] != none)
	{
		BeamEmitter[CurrentFireMode].SetHidden(true);
		BeamEmitter[CurrentFireMode].DeactivateSystem();
	}
}

simulated function SetBeamEmitterHidden(bool bHide)
{
	if (BeamEmitter[CurrentFireMode] != none)
		BeamEmitter[CurrentFireMode].SetHidden(bHide);
}

simulated function UpdateBeamEmitter(vector FlashLocation, vector HitNormal, actor HitActor)
{
	if (BeamEmitter[CurrentFireMode] != none)
	{
		SetBeamEmitterHidden( !UTPawn(Instigator).IsFirstPerson() );
		BeamEmitter[CurrentFireMode].SetVectorParameter(EndPointParamName,FlashLocation);
	}
}


simulated function ProcessBeamHit(vector StartTrace, vector AimDir, out ImpactInfo TestImpact, float DeltaTime);

/**
 * This function looks at who/what the beam is touching and deals with it accordingly.  bInfoOnly
 * is true when this function is called from a Tick.  It causes the link portion to execute, but no
 * damage/health is dealt out.
 */

simulated function UpdateBeam(float DeltaTime)
{
	local Vector		StartTrace, EndTrace, AimDir;
	local ImpactInfo	RealImpact, NearImpact;

	// define range to use for CalcWeaponFire()
	StartTrace	= Instigator.GetWeaponStartTraceLocation();
	AimDir = Vector(GetAdjustedAim( StartTrace ));
	EndTrace	= StartTrace + AimDir * GetTraceRange();

	// Trace a shot
	RealImpact = CalcWeaponFire( StartTrace, EndTrace );
	bUsingAimingHelp = false;

	if ( (RealImpact.HitActor == None) || !RealImpact.HitActor.bProjTarget )
	{
		// console aiming help
		NearImpact = InstantAimHelp(StartTrace, EndTrace, RealImpact);

	}
	if ( NearImpact.HitActor != None )
	{
		bUsingAimingHelp = true;
		ProcessBeamHit(StartTrace, AimDir, NearImpact, DeltaTime);
		UpdateBeamEmitter(NearImpact.HitLocation, NearImpact.HitNormal, NearImpact.HitActor);
	}
	else
	{
		// Allow children to process the hit
		ProcessBeamHit(StartTrace, AimDir, RealImpact, DeltaTime);
		UpdateBeamEmitter(RealImpact.HitLocation, RealImpact.HitNormal, RealImpact.HitActor);
	}
}

/*********************************************************************************************
 * State WeaponFiring
 * See UTWeapon.WeaponFiring
 *********************************************************************************************/

simulated state WeaponBeamFiring
{
	/** view shaking for the beam mode is handled in RefireCheckTimer() */
	simulated function ShakeView();

	/**
	 * In this weapon, RefireCheckTimer consumes ammo and deals out health/damage.  It's not
	 * concerned with the effects.  They are handled in the tick()
	 */
	simulated function RefireCheckTimer()
	{
		local UTPlayerController PC;

		// If weapon should keep on firing, then do not leave state and fire again.
		if( ShouldRefire() )
		{
			// trigger a view shake for the local player here, because effects are called every tick
			// but we don't want to shake that often
			PC = UTPlayerController(Instigator.Controller);
			if (PC != None && LocalPlayer(PC.Player) != None && CurrentFireMode < FireCameraAnim.length && FireCameraAnim[CurrentFireMode] != None)
			{
				PC.PlayCameraAnim(FireCameraAnim[CurrentFireMode], (GetZoomedState() > ZST_ZoomingOut) ? PC.FOVAngle / PC.DefaultFOV : 1.0);
			}
			return;
		}

		// Otherwise we're done firing, so go back to active state.
		GotoState('Active');

		// if out of ammo, then call weapon empty notification
		if( !HasAnyAmmo() )
		{
			WeaponEmpty();
		}
	}


	/**
	 * When done firing, we have to make sure we unlink the weapon.
	 */
	simulated function EndFire(byte FireModeNum)
	{
		Global.EndFire(FireModeNum);

		if ( bWeaponPutDown )
		{
			// if switched to another weapon, put down right away
			GotoState('WeaponPuttingDown');
			return;
		}
		else
		{
			GotoState('Active');
		}
	}

	/**
	 * Update the beam and handle the effects
	 */
	simulated function Tick(float DeltaTime)
	{
		// Retrace everything and see if there is a new LinkedTo or if something has changed.
		UpdateBeam(DeltaTime);
	}

	simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
	{
		local UTPlayerController PC;

		// Start muzzle flash effect
		CauseMuzzleFlash();

	    // Play controller vibration
		PC = UTPlayerController(Instigator.Controller);
	    if( PC != None && LocalPlayer(PC.Player) != None )
	    {
		    // only do rumble if we are a player controller
		    PC.ClientPlayForceFeedbackWaveform( BeamWeaponFireWaveForm );
	    }

		ShakeView();
	}

	event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		if ((SeqNode == None || SeqNode.AnimSeqName != BeamFireAnim[CurrentFireMode]) && BeamFireAnim[CurrentFireMode] != '')
		{
			PlayWeaponAnimation(BeamFireAnim[CurrentFireMode],1.0,true);
		}
	}

	simulated function BeginState( Name PreviousStateName )
	{
		local UTPawn POwner;

		// Fire the first shot right away
		RefireCheckTimer();
		TimeWeaponFiring( CurrentFireMode );

		if (BeamPreFireAnim[CurrentFireMode] != '')
		{
			PlayWeaponAnimation( BeamPreFireAnim[CurrentFireMode], 1.0);
		}
		else if (BeamFireAnim[CurrentFireMode] != '')
		{
			PlayWeaponAnimation( BeamFireAnim[CurrentFireMode], 1.0);
		}

		POwner = UTPawn(Instigator);
		if (POwner != None)
		{
			AddBeamEmitter();
			POwner.SetWeaponAmbientSound(WeaponFireSnd[CurrentFireMode]);
		}
	}


	/**
	 * When leaving the state, shut everything down
	 */
	simulated function EndState(Name NextStateName)
	{
		local UTPawn POwner;
		local UTPlayerController PC;

		POwner = UTPawn(Instigator);
		if (POwner != None)
		{
			POwner.SetWeaponAmbientSound(None);
		}

		ClearTimer('RefireCheckTimer');
		ClearFlashLocation();

		if (BeamPostFireAnim[CurrentFireMode] != '')
		{
			PlayWeaponAnimation( BeamPostFireAnim[CurrentFireMode], 1.0);
		}

	    // Stop controller vibration
		PC = UTPlayerController(Instigator.Controller);
	    if( PC != None && LocalPlayer(PC.Player) != None )
	    {
		    // only do rumble if we are a player controller
		    PC.ClientStopForceFeedbackWaveform( BeamWeaponFireWaveForm );
	    }

		super.EndState(NextStateName);

		KillBeamEmitter();
	}

	simulated function bool IsFiring()
	{
		return true;
	}

	simulated function bool TryPutDown()
	{
		bWeaponPutDown = true;
		return false;
	}

}

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	super.DisplayDebug(Hud, out_YL, out_YPos);

	if (BeamEmitter[CurrentFireMode] != none)
	{
	    HUD.Canvas.SetPos(4,out_YPos);
	    HUD.Canvas.DrawText("Beam:"@BeamEmitter[CurrentFireMode]@BeamEmitter[CurrentFireMode].HiddenGame);
	    out_YPos+= out_YL;
	}
}

defaultproperties
{
}
