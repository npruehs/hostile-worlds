/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSkelControl_DamageSpring extends UDKSkelControl_Damage
	native(Animation);

/** The Maximum size of the angle this spring can open to in Degrees */
var(Spring) rotator MaxAngle;

/** The Minmum size of the angle this spring can open to in Degrees */
var(Spring) rotator MinAngle;

/** How fast does it return to normal */
var(Spring) float Falloff;

/** How stiff is the spring */
var(Spring) float SpringStiffness;

var(Spring) float AVModifier;

/** The current angle of the hinge */
var transient rotator CurrentAngle;

/** % of movement decided randomly */
var float RandomPortion;

// to add momentum from breaking due to a damage hit
var vector LastHitMomentum;
var float LastHitTime;
var float MomentumPortion;


cpptext
{
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
	virtual INT CalcAxis(INT &InAngle, FLOAT CurVelocity, FLOAT MinAngle, FLOAT MaxAngle);
	virtual UBOOL InitializeControl(USkeletalMeshComponent* SkelComp);
}


defaultproperties
{
	BreakTime=0.0
	SpringStiffness=-0.035
	bApplyRotation=TRUE
	BoneRotationSpace=BCS_ActorSpace
	Falloff=0.975
	AVModifier=1.0
	bControlStrFollowsHealth=TRUE
	ActivationThreshold=1.0
	RandomPortion=0.2f
	MomentumPortion=0.75f
}
