/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSkelControl_DamageHinge extends UDKSkelControl_Damage
	hidecategories(Translation, Rotation, Adjustments)
	native(Animation);

/** The Maximum size of the angle this hinge can open to in Degrees */
var(Hinge) float MaxAngle;

/** Which axis this hinge opens around */
var(Hinge) EAxis PivotAxis;

/** The angular velocity that is used to calculate the angle of the hinge will be multipled by this value.  
  * NOTE: This should be negative
  */
var(Hinge) float AVModifier;

/** The current angle of the hinge */
var transient float CurrentAngle;

/** How stiff is the spring */
var float SpringStiffness;


cpptext
{
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
}

defaultproperties
{
	MaxAngle=45.0
	AVModifier=-1.5
	PivotAxis=AXIS_Y
	SpringStiffness=-0.035
	bApplyRotation=true
	BoneRotationSpace=BCS_ActorSpace
}
