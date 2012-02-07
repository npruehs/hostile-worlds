/**
 * skeletal controller that locks one or more components of the bone's rotation to a specified value
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSkelControl_LockRotation extends SkelControlBase
	native(Animation);

/** which components of the bone rotation to affect */
var() bool bLockPitch, bLockYaw, bLockRoll;

/** the rotation to lock to */
var() rotator LockRotation;

/** the maximum amount the original rotation can be altered to reach LockRotation */
var() rotator MaxDelta;

/** the space that rotation is in */
var() EBoneControlSpace LockRotationSpace;

/** name of bone used if LockRotationSpace is BCS_OtherBoneSpace */
var() name RotationSpaceBoneName;

cpptext
{
	virtual void GetAffectedBones(INT BoneIndex, USkeletalMeshComponent* SkelComp, TArray<INT>& OutBoneIndices);
	virtual void CalculateNewBoneTransforms(INT BoneIndex, USkeletalMeshComponent* SkelComp, TArray<FBoneAtom>& OutBoneTransforms);
}

defaultproperties
{
	MaxDelta=(Pitch=65535,Yaw=65535,Roll=65535)
}
