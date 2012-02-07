/**
 * Reverts any animation compression, restoring the animation to the raw data.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class AnimationCompressionAlgorithm_RevertToRaw extends AnimationCompressionAlgorithm
	native(Anim);

cpptext
{
protected:
	/**
	 * Reverts any animation compression, restoring the animation to the raw data.
	 */
	virtual void DoReduction(class UAnimSequence* AnimSeq, class USkeletalMesh* SkelMesh, const TArray<class FBoneData>& BoneData);
}

defaultproperties
{
	Description="Revert To Raw"
	TranslationCompressionFormat=ACF_None
	RotationCompressionFormat=ACF_None
}
