/**
 * Keyframe reduction algorithm that simply removes keys which are linear interpolations of surrounding keys.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class AnimationCompressionAlgorithm_RemoveLinearKeys extends AnimationCompressionAlgorithm
	native(Anim);

/** Maximum position difference to use when testing if an animation key may be removed. Lower values retain more keys, but yield less compression. */
var()	float	MaxPosDiff;

/** Maximum angle difference to use when testing if an animation key may be removed. Lower values retain more keys, but yield less compression. */
var()	float	MaxAngleDiff;

/** 
 * As keys are tested for removal, we monitor the effects all the way down to the end effectors. 
 * If their position changes by more than this amount as a result of removing a key, the key will be retained.
 * This value is used for all bones except the end-effectors parent.
 */
var()	float	MaxEffectorDiff;

/** 
 * As keys are tested for removal, we monitor the effects all the way down to the end effectors. 
 * If their position changes by more than this amount as a result of removing a key, the key will be retained.
 * This value is used for the end-effectors parent, allowing tighter restrictions near the end of a skeletal chain.
 */
var()	float	MinEffectorDiff;

/** 
 * A scale value which increases the likelihood that a bone will retain a key if it’s parent also had a key at the same time position. 
 * Higher values can remove shaking artifacts from the animation, at the cost of compression.
 */
var()	float	ParentKeyScale;

/** 
 * TRUE = As the animation is compressed, adjust animated nodes to compensate for compression error.
 * FALSE= Do not adjust animated nodes.
 */
var()	bool	bRetarget;

cpptext
{
protected:
	/**
	 * Keyframe reduction algorithm that simply removes every second key.
	 *
	 * @return		TRUE if the keyframe reduction was successful.
	 */
	virtual void DoReduction(class UAnimSequence* AnimSeq, class USkeletalMesh* SkelMesh, const TArray<class FBoneData>& BoneData);

	/**
	 * Locates spans of keys within the position and rotation tracks provided which can be estimated
	 * through linear interpolation of the surrounding keys. The remaining key values are bit packed into
	 * the animation sequence provided
	 *
	 * @param	AnimSeq		The animation sequence being compressed
	 * @param	SkelMesh	The skeletal mesh to use to guide the compressor
	 * @param	BoneData	BoneData array describing the hierarchy of the animated skeleton
	 * @param	TranslationCompressionFormat	The format to use when encoding translation keys.
	 * @param	RotationCompressionFormat		The format to use when encoding rotation keys.
	 * @param	TranslationData		Translation Tracks to compress and bit-pack into the Animation Sequence.
	 * @param	RotationData		Rotation Tracks to compress and bit-pack into the Animation Sequence.
	 * @return				None.
	 */
	void ProcessAnimationTracks(
		UAnimSequence* AnimSeq, 
		USkeletalMesh* SkelMesh, 
		const TArray<FBoneData>& BoneData, 
		AnimationCompressionFormat TranslationCompressionFormat,
		AnimationCompressionFormat RotationCompressionFormat,
		TArray<FTranslationTrack>& PositionTracks,
		TArray<FRotationTrack>& RotationTracks);
}

defaultproperties
{
	bNeedsSkeleton = TRUE
	Description="Remove Linear Keys"
	MaxPosDiff = 0.1
	MaxAngleDiff = 0.025
	MaxEffectorDiff = 0.01	// used to be 0.2
	MinEffectorDiff = 0.02	// used to be 0.1
	ParentKeyScale = 2.0
	bRetarget=TRUE
}
