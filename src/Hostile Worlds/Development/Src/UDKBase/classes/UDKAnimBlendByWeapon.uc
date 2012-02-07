/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKAnimBlendByWeapon extends AnimNodeBlendPerBone
	native(Animation);

/** Is this weapon playing a looped anim */
var(Animation) bool bLooping;
/** If set, after the fire anim completes this anim is looped instead of looping the fire anim */
var(Animation) name LoopingAnim;
/** Blend Times */
var(Animation) float BlendTime;

cpptext
{
	virtual void OnChildAnimEnd(UAnimNodeSequence* Child, FLOAT PlayedTime, FLOAT ExcessTime);
}

/** Call to trigger the fire sequence. It will blend to the fire animation.
	If bAutoFire is specified, if LoopSequence is 'None' or unspecified, FireSequence will be looped, otherwise FireSequence
	will be played once and LoopSequence will be looped after that */
function AnimFire(name FireSequence, bool bAutoFire, optional float AnimRate, optional float SpecialBlendTime, optional name LoopSequence = LoopingAnim)
{
	local AnimNodeSequence FireNode;

	// Fix the rate
	if (AnimRate == 0)
	{
		AnimRate = 1.0;
	}

	if (SpecialBlendTime == 0.0f)
	{
		SpecialBlendtime = BlendTime;
	}

	// Activate the child node
	SetBlendTarget(1, SpecialBlendtime);

	// Restart the sequence
	FireNode = AnimNodeSequence(Children[1].Anim);
	if (FireNode != None)
	{
		FireNode.SetAnim(FireSequence);
		FireNode.PlayAnim(bAutoFire && LoopSequence == 'None', AnimRate);
	}

	bLooping = bAutoFire;
	LoopingAnim = LoopSequence;
}

/** Blends out the fire animation
	This event is called automatically for non-looping fire animations; otherwise it must be called manually */
event AnimStopFire(optional float SpecialBlendTime)
{
	local AnimNodeSequence FireNode;

	if (SpecialBlendTime == 0.0f)
	{
		SpecialBlendTime = BlendTime;
	}

	SetBlendTarget(0, SpecialBlendTime);

	FireNode = AnimNodeSequence(Children[1].Anim);
	if (FireNode != None)
	{
		FireNode.StopAnim();
	}

	bLooping = false;
}

defaultproperties
{
	BlendTime=0.15

	Children(0)=(Name="Not-Firing",Weight=1.0)
	Children(1)=(Name="Firing")
	bFixNumChildren=true
}
