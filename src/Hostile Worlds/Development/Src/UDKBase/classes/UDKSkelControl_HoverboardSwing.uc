/**
 *	Controller used by hoverboard for moving lower part in response to wheel movements.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSkelControl_HoverboardSwing extends SkelControlSingleBone
	hidecategories(Translation,Rotation)
	native(Animation);

cpptext
{
	// SkelControlWheel interface
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
	virtual void CalculateNewBoneTransforms(INT BoneIndex, USkeletalMeshComponent* SkelComp, TArray<FBoneAtom>& OutBoneTransforms);
}

var()	int				SwingHistoryWindow;
var		int				SwingHistorySlot;
var		array<float>	SwingHistory;
var()	float	SwingScale;
var()	float	MaxSwing;
var()	float	MaxUseVel;
var		float	CurrentSwing;

defaultproperties
{
	bApplyRotation=true
	bAddRotation=true
	BoneRotationSpace=BCS_BoneSpace
	SwingHistoryWindow=15
}