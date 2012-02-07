/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSkelControl_TurretConstrained extends SkelControlSingleBone
	native(Animation);

var(Constraint)	bool bConstrainPitch;
var(Constraint)	bool bConstrainYaw;
var(Constraint)	bool bConstrainRoll;

var(Constraint)	bool bInvertPitch;
var(Constraint)	bool bInvertYaw;
var(Constraint)	bool bInvertRoll;


struct native TurretConstraintData
{
	var() int	PitchConstraint;
	var() int	YawConstraint;
	var() int	RollConstraint;
};

var(Constraint)	TurretConstraintData MaxAngle;    // Max. angle in Degrees
var(Constraint) TurretConstraintData MinAngle;    // Min. angle in Degrees

/**
 * Allow each turret to have various steps in which to contrain the data.
 */

struct native TurretStepData
{
	var() int StepStartAngle;
	var() int StepEndAngle;
	var() TurretConstraintData MaxAngle;
	var() TurretConstraintData MinAngle;
};

var(Constraints) array<TurretStepData> Steps;

var(Turret)	float 	LagDegreesPerSecond;
var(Turret) float	PitchSpeedScale;
var(Turret) rotator	DesiredBoneRotation;

/** If true, this turret won't update if the seat it is associated with is firing */
var(Turret) bool bFixedWhenFiring;

/** The Seat Index this control is associated with */
var(Turret) int AssociatedSeatIndex;

/** If true, this turret will reset to 0,0,0 when there isn't a driver */
var(Turret) bool bResetWhenUnattended;

var bool bIsInMotion;

/** This is the world space rotation after constraints have been applied
 * We set Bone rotation to this value by default in GetAffectedBones
 */
var transient Rotator ConstrainedBoneRotation;

cpptext
{
	/** handles constraining the passed in local space rotator based on the turret's parameters */
	FRotator GetClampedLocalDesiredRotation(const FRotator& UnclampedLocalDesired);
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
}

delegate OnTurretStatusChange(bool bIsMoving);

/** Initialises turret, so its current direction is the way it wants to point. */
native final function InitTurret(Rotator InitRot, SkeletalMeshComponent SkelComp);

/** @return if the given pitch would be limited by this controller */
native final function bool WouldConstrainPitch(int TestPitch, SkeletalMeshComponent SkelComp);

defaultproperties
{
	bConstrainPitch=false;
	bConstrainYaw=false;
	bConstrainRoll=false;

	LagDegreesPerSecond=360
	PitchSpeedScale=1.0
	bApplyRotation=true
	BoneRotationSpace=BCS_ActorSpace
	bIsInMotion=false

}

