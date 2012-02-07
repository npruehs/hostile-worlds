/**
 * when this node becomes relevant, it selects an animation from its list based on the rotation of 
 * the given bone relative to the rotation of the owning actor
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKAnimNodeSequenceByBoneRotation extends AnimNodeSequence;

/** bone whose direction should be tested */
var() name BoneName;
/** axis of that bone to check */
var() EAxis BoneAxis;

/** list of animations to choose from */
struct AnimByRotation
{
	/** desired rotation of the bone to play this animation */
	var() rotator DesiredRotation;
	/** the animation to play */
	var() name AnimName;
};
var() array<AnimByRotation> AnimList;

event OnBecomeRelevant()
{
	local vector BoneDirection;
	local int i;
	local float Diff, BestDiff;
	local name BestAnim;

	if (SkelComponent.Owner == None)
	{
		`warn("SkeletalMeshComponent has no Owner");
	}
	else if (BoneAxis == AXIS_NONE || BoneAxis == AXIS_BLANK)
	{
		`warn("Invalid Axis specified");
	}
	else
	{
		// get the bone's rotation relative to the owning actor
		BoneDirection = SkelComponent.GetBoneAxis(BoneName, BoneAxis) >> SkelComponent.Owner.Rotation;

		// find the animation in the list whose rotation is closest to the bone's
		BestDiff = -1.0;
		for (i = 0; i < AnimList.length; i++)
		{
			Diff = BoneDirection Dot vector(AnimList[i].DesiredRotation);
			if (Diff > BestDiff)
			{
				BestAnim = AnimList[i].AnimName;
				BestDiff = Diff;
			}
		}

		// set to the best animation and make sure it starts from the beginning
		SetAnim(BestAnim);
		SetPosition(0.0f, false);
	}
}

defaultproperties
{
	BoneAxis=AXIS_X
	bCallScriptEventOnBecomeRelevant=TRUE
}
