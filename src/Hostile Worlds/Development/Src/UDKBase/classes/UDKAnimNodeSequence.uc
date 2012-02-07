/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKAnimNodeSequence extends AnimNodeSequence
	native(Animation);

/** If true, this node will automatically start playing */
var() bool bAutoStart;

/** When a given sequence is finished, it will continue to select new sequences from this list */
var array<name> SeqStack;

/** If true, when the last sequence in the stack is reached, it will be looped */
var bool bLoopLastSequence;

cpptext
{
	virtual void OnAnimEnd(FLOAT PlayedTime, FLOAT ExcessTime);
}

native function PlayAnimation(name Sequence, float SeqRate, bool bSeqLoop);
native function PlayAnimationSet(array<name> Sequences, float SeqRate, bool bLoopLast);

event OnInit()
{
	Super.OnInit();

	if (bAutoStart)
	{
		PlayAnim(bLooping, Rate);
	}
}

defaultproperties
{
	bCallScriptEventOnInit=TRUE
}
