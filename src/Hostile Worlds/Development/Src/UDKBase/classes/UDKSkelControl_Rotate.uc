/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSkelControl_Rotate extends SkelControlSingleBone
	native(Animation);

/** Where we wish to get to */
var(Desired) rotator	DesiredBoneRotation;

/** The Rate we wish to rotate */
var(Desired) rotator	DesiredBoneRotationRate;

cpptext
{
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
}

defaultproperties
{
	bApplyTranslation=false
	bApplyRotation=true
	bAddRotation=true
	BoneRotationSpace=BCS_BoneSpace
}

