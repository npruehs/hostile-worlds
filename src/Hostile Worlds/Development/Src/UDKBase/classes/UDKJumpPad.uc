/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//=============================
// UDKJumppad - bounces players/bots up
//
//=============================
class UDKJumpPad extends NavigationPoint
	native
	hidecategories(VehicleUsage);

/** Pre-calculated initial jumping velocity to reach JumpTarget */
var		vector				JumpVelocity;

/** Target of jumppad - jumppad bounces you to this */
var()	PathNode			JumpTarget;

/** Sound that plays when jumppad is triggered */
var()	SoundCue			JumpSound;

/** How long the jump should take.  Altering this value changes the JumpVelocity. */
var()	float				JumpTime;

/** How much air control the player should have while in the air off this pad.  Less air control (even 0.0) is desireable for tight landings, since players will often accidentally air control themselves away from the target destination. */
var()	float				JumpAirControl;

/** Ambient sound associated with this jumppad. */
var AudioComponent			JumpAmbientSound;

cpptext
{
	virtual void addReachSpecs(AScout *Scout, UBOOL bOnlyChanged=0);
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void PostEditMove(UBOOL bFinished);
	UBOOL CalculateJumpVelocity(AScout *Scout);
}

/** 
  * Touch called during move - Set PendingTouch so PostTouch() will be called after physics completes
  */
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if ( (UDKPawn(Other) == None) || (Other.Physics == PHYS_None) )
		return;

	PendingTouch = Other.PendingTouch;
	Other.PendingTouch = self;
}

/**
  * Update velocity after movement has completed, so it doesn't get stomped by physics update in progress.
  */
event PostTouch(Actor Other)
{
	local UDKPawn P;

	P = UDKPawn(Other);
	if (P == None || P.Physics == PHYS_None || P.DrivenVehicle != None)
	{
		return;
	}
	if ( P.bNotifyStopFalling )
	{
		P.StoppedFalling();
	}

	// adjust facing direction and movetarget of bots
	if ( UDKBot(P.Controller) != None )
	{
		if ( Other.GetGravityZ() > WorldInfo.DefaultGravityZ )
			UDKBot(P.Controller).Focus = UDKBot(P.Controller).FaceActor(2);
		else
			P.Controller.Focus = JumpTarget;
		P.Controller.Movetarget = JumpTarget;
		if ( P.Physics != PHYS_Flying )
			P.Controller.MoveTimer = 2.0;
		P.DestinationOffset = 50;
	}
	if ( P.Physics == PHYS_Walking )
	{
		P.SetPhysics(PHYS_Falling);
		P.bReadyToDoubleJump = true;
	}
	P.Velocity = JumpVelocity;

	// adjust jumpvelocity if gravity is altered
	if ( (WorldInfo.WorldGravityZ != WorldInfo.DefaultGravityZ) && (Other.GetGravityZ() == WorldInfo.WorldGravityZ) )
	{
		P.Velocity *= sqrt(Other.GetGravityZ()/WorldInfo.DefaultGravityZ);
	}

	P.AirControl = JumpAirControl;
	P.Acceleration = vect(0,0,0);
	if ( JumpSound != None )
		P.PlaySound(JumpSound);
}

/**
  *  Hint for bots which want to use this jumppad
  */
event bool SuggestMovePreparation(Pawn Other)
{
	local Vehicle V;

	// can't use jumppad while in a vehicle
	V = Vehicle(Other);
	if (V != None)
	{
		V.DriverLeave(false);
	}

	return false;
}

defaultproperties
{
	bDestinationOnly=true
	bCollideActors=true
	JumpTime=2.0
	JumpAirControl=0.05
	bHidden=false
	bBlockedForVehicles=true
	bMovable=false
	bNoDelete=true
	bStatic=false
	bSpecialMove=true
	Components.Remove(Sprite)
	Components.Remove(Sprite2)
	GoodSprite=None
	BadSprite=None

	Begin Object Name=CollisionCylinder
		CollideActors=true
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=JumpPadLightEnvironment
	    bDynamic=FALSE
		bCastShadows=FALSE
	End Object
	Components.Add(JumpPadLightEnvironment)
}
