/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSkelControl_VehicleFlap extends SkelControlSingleBone
	hidecategories(Translation, Rotation, Adjustment)
	native(Animation);

var(Manta)	float	MaxPitch;
var			float	OldZPitch;

/** 1/MaxPitchTime is minimum time to go from 0 to max pitch */
var			float	MaxPitchTime;

/** Max pitch change per second */
var			float	MaxPitchChange;

var name RightFlapControl;
var name LeftFlapControl;

cpptext
{
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
}


defaultproperties
{
	MaxPitch=30
	MaxPitchTime=4.0
	MaxPitchChange=10000.0
	bApplyRotation=true
	BoneRotationSpace=BCS_ActorSpace

	ControlStrength=1.0
	bIgnoreWhenNotRendered=true
	RightFlapControl=right_flap
	LeftFlapControl=left_flap
}
