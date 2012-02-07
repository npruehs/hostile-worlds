/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKPlayerController extends GamePlayerController
	native;

/** plays camera animations (mostly used for viewshakes) */
var CameraAnimInst CameraAnimPlayer;

/** The effect to play on the camera **/
var UDKEmitCameraEffect CameraEffect;

/** indicates whether this player is a dedicated server spectator (so disable rendering and don't allow it to participate at all) */
var bool bDedicatedServerSpectator;

/** makes playercontroller hear much better (used to magnify hit sounds caused by player) */
var					bool	bAcuteHearing;			

/** current offsets applied to the camera due to camera anims, etc */
var vector ShakeOffset; // current magnitude to offset camera position from shake
var rotator ShakeRot; // current magnitude to offset camera rotation from shake

/** stores post processing settings applied by the camera animation
 * applied additively to the default post processing whenever a camera anim is playing
 */
var PostProcessSettings CamOverridePostProcess;

/** additional post processing settings modifier that can be applied
 * @note: defaultproperties for this are hardcoded to zeroes in C++
 */
var PostProcessSettings PostProcessModifier;

/** Actors which may be hidden dynamically when rendering (by adding to PlayerController.HiddenActors array) */
var array<Actor> PotentiallyHiddenActors;

/** If true, player is on a console (used by C++) */
var bool bConsolePlayer;

/** Custom scaling for vehicle check radius.  Used by UTConsolePlayerController for example */
var	float	VehicleCheckRadiusScaling;

var float PulseTimer;
var bool bPulseTeamColor;

/** if true, rotate smoothly to desiredrotation */
var bool bUsePhysicsRotation;

struct native ObjectiveAnnouncementInfo
{
	/** the default announcement sound to play (can be None) */
	var() SoundNodeWave AnnouncementSound;
	/** text displayed onscreen for this announcement */
	var() localized string AnnouncementText;
};

cpptext
{
	virtual UBOOL Tick( FLOAT DeltaSeconds, ELevelTick TickType );
	virtual UBOOL HearSound(USoundCue* InSoundCue, AActor* SoundPlayer, const FVector& SoundLocation, UBOOL bStopWhenOwnerDestroyed);
	virtual UBOOL MoveWithInterpMoveTrack(UInterpTrackMove* MoveTrack, UInterpTrackInstMove* MoveInst, FLOAT CurTime, FLOAT DeltaTime);
	virtual void ModifyPostProcessSettings(FPostProcessSettings& PPSettings) const;
	virtual void UpdateHiddenActors(const FVector& ViewLocation);
	virtual void PreSave();

	/**
	 * This will score both Adhesion and Friction targets.  We want the same scoring function as we
	 * don't want the two different systems fighting over targets that are close.
	 **/
	virtual FLOAT ScoreTargetAdhesionFrictionTarget( const APawn* P, FLOAT MaxDistance, const FVector& CamLoc, const FRotator& CamRot ) const;

	/** Determines whether this Pawn can be used for TargetAdhesion **/
	virtual UBOOL IsValidTargetAdhesionFrictionTarget( APawn* P, FLOAT MaxDistance );
}

/**
 * Sets the current gamma value.
 *
 * @param New Gamma Value, must be between 0.0 and 1.0
 */
native function SetGamma(float GammaValue);

/**
 * Sets whether or not hardware physics are enabled.
 *
 * @param bEnabled	Whether to enable the physics or not.
 */
native function SetHardwarePhysicsEnabled(bool bEnabled);

/** @return Whether or not the user has a keyboard plugged-in. */
native simulated function bool IsKeyboardAvailable() const;

/** @return Whether or not the user has a mouse plugged-in. */
native simulated function bool IsMouseAvailable() const;

/** @param CamEmitter Clear the CameraEffect if it is the one passed in */
function RemoveCameraEffect( UDKEmitCameraEffect CamEmitter )
{
	if (CameraEffect == CamEmitter)
	{
		CameraEffect = None;
	}
}

/** Spawn ClientSide Camera Effects **/
unreliable client function ClientSpawnCameraEffect(class<UDKEmitCameraEffect> CameraEffectClass)
{
	local vector CamLoc;
	local rotator CamRot;

	if (CameraEffectClass != None && CameraEffect == None)
	{
		CameraEffect = Spawn(CameraEffectClass, self);
		if (CameraEffect != None)
		{
			GetPlayerViewPoint(CamLoc, CamRot);
			CameraEffect.RegisterCamera(self);
			CameraEffect.UpdateLocation(CamLoc, CamRot, FOVAngle);
		}
	}
}

function ClearCameraEffect()
{
	if( CameraEffect != None )
	{
		CameraEffect.Destroy();
		CameraEffect = none;
	}
}

/**
 * This will find the best AdhesionFriction target based on the params passed in.
 **/
native function Pawn GetTargetAdhesionFrictionTarget( FLOAT MaxDistance, const out vector CamLoc, const out Rotator CamRot );

/** @returns whether the controller is active **/
native simulated function bool IsControllerTiltActive() const;

native simulated function SetControllerTiltDesiredIfAvailable( bool bActive );

native simulated function SetControllerTiltActive( bool bActive );

native simulated function SetOnlyUseControllerTiltInput( bool bActive );

native simulated function SetUseTiltForwardAndBack( bool bActive );
