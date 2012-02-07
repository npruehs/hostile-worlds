/**
 * Base class for emitters which should be attached to the camera (for example blood effects across the screen)
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKEmitCameraEffect extends Emitter
	abstract
	native;

/** How far in front of the camera this emitter should live. */
var() protected float DistFromCamera;

/** Camera this emitter is attached to, will be notified when emitter is destroyed */
var protected UDKPlayerController Cam;

simulated event PostBeginPlay()
{
	// render in front of all in world objects
	ParticleSystemComponent.SetDepthPriorityGroup(SDPG_Foreground);

	super.PostBeginPlay();
}

/**
  * Tell camera to remove this effect when destroyed
  */
function Destroyed()
{
	Cam.RemoveCameraEffect(self);
	super.Destroyed();
}

/** Tell the emitter what camera it is attached to. */
function RegisterCamera( UDKPlayerController inCam )
{
	Cam = inCam;
}

/** Given updated camera information, adjust this effect to display appropriately. */
native function UpdateLocation( const out vector CamLoc, const out rotator CamRot, float CamFOVDeg );

defaultproperties
{
	Begin Object Name=ParticleSystemComponent0
	End Object

	// makes sure I tick after the camera
	TickGroup=TG_DuringAsyncWork

	DistFromCamera=90

	LifeSpan=10.0f

	bDestroyOnSystemFinish=true
	bNetInitialRotation=true
	bNoDelete=false

}



