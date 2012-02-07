/**
 *  skeletal controller that tries to keep a bone within a certain distance of the ground within its constraints
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSkelControl_HugGround extends SkelControlSingleBone
	native(Animation)
	hidecategories(Translation, Rotation, Adjustment);

/** desired distance from bone to ground */
var() float DesiredGroundDist;
/** maximum distance the bone may be moved from its normal location */
var() float MaxDist;
/** optional name of a bone that the controlled bone will always be rotated towards */
var() name ParentBone;
/** if true, rotate the bone in the opposite direction of the parent instead of in the same direction */
var() bool bOppositeFromParent;
/** if ParentBone is specified and this is greater than zero always keep the controlled bone exactly this many units from it */
var() float XYDistFromParentBone;
var() float ZDistFromParentBone;
/** maximum amount the BoneTranslation may change per second */
var() float MaxTranslationPerSec;
/** time bone transforms were last updated */
var transient float LastUpdateTime;

cpptext
{
	virtual void CalculateNewBoneTransforms(INT BoneIndex, USkeletalMeshComponent* SkelComp, TArray<FBoneAtom>& OutBoneTransforms);
}

defaultproperties
{
	DesiredGroundDist=60.0
	MaxDist=60.0
	bApplyTranslation=true
	bAddTranslation=true
	// bApplyRotation = (ParentBone != 'None')
	BoneRotationSpace=BCS_BoneSpace
	BoneTranslationSpace=BCS_ActorSpace
	bIgnoreWhenNotRendered=true
	MaxTranslationPerSec=150.0
}
