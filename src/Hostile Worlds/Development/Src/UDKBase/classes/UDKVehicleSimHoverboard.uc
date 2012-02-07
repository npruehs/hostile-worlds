/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKVehicleSimHoverboard extends SVehicleSimBase
    native;

var()	float				MaxThrustForce;
var()	float				MaxReverseForce;
var()	float				MaxReverseVelocity;
var()	float				LongDamping;

var()	float				MaxStrafeForce;
var()	float				LatDamping;

var()	float				MaxRiseForce;

var()	float				TurnTorqueFactor;
var()	float				SpinTurnTorqueScale;
var()	float				MaxTurnTorque;
var()	InterpCurveFloat	TurnDampingSpeedFunc;

/** Set to true when hoverboard is over deep water and is not receiving any thrust. */
var		bool				bIsOverDeepWater;

var()	float				StopThreshold;

// WaterCheckLevel is the distance to trace down to determine if water is too deep to travel over
var()   float           WaterCheckLevel;

/** Cue played when over water. */
var SoundCue		OverWaterSound;

var	transient vector GroundNormal;

var		float	TakeoffYaw;
var		float	TrickJumpWarmup;
var		float	SpinHeadingOffset;
var		float	AutoSpin;
var		bool	bInAJump; // True when in-air as the result of a jump
var		bool	bLeftGround;
var()	float	SpinSpeed;
var		float	LandedCountdown;

/** Current offset applied to look direction for board */
var	float CurrentSteerOffset;

/** Using strafe keys adds this offset to current look direction. */
var() float	HoverboardSlalomMaxAngle;

/** How quickly the 'slalom' offset can change (controlled by strafe) */
var() float	SlalomSpeed;

/** The current angle (in radians) between the way the board is pointing and the way the player is looking. */
var transient float	CurrentLookYaw;

cpptext
{
    virtual void ProcessCarInput(ASVehicle* Vehicle);
	virtual void UpdateVehicle(ASVehicle* Vehicle, FLOAT DeltaTime);
	FLOAT GetEngineOutput(ASVehicle* Vehicle);
}

native function InitWheels(UDKVehicle Vehicle);

native function UpdateLeanConstraint( RB_ConstraintInstance LeanUprightConstraintInstance, vector LeanY, vector LeanZ);

defaultproperties
{
	WaterCheckLevel=110.0
	SpinSpeed=11.0
	HoverboardSlalomMaxAngle=45
	SlalomSpeed=5.0
}
