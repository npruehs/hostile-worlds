/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSkelControl_SpinControl extends SkelControlSingleBone
	native(Animation)
	hidecategories(Adjustments,Translation,Rotation);

/** How fast is the core to spin at max health */

var(Spin)	float 	DegreesPerSecond;
var(Spin)	vector	Axis;

cpptext
{
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
}

defaultproperties
{
	bApplyTranslation=false
	bAddTranslation=false
	bApplyRotation=true
	bAddRotation=true
	BoneRotationSpace=BCS_ActorSpace
	DegreesPerSecond=180
}
