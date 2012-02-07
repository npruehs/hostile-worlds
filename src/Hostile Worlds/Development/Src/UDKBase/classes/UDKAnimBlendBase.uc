/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKAnimBlendBase extends AnimNodeBlendList
	native(Animation);

/** How fast show a given child blend in. */
var(Animation) float BlendTime;

/** Also allow for Blend Overrides */
var(Animation) array<float> ChildBlendTimes;

/** Whether this AnimBlend wants a script TickAnim event called (for script extensibility) */
var bool bTickAnimInScript;

cpptext
{
	virtual	void TickAnim(FLOAT DeltaSeconds);

	// AnimTree editor interface
	virtual void HandleSliderMove(INT SliderIndex, INT ValueIndex, FLOAT NewSliderValue);
}

native final function float GetBlendTime(int ChildIndex, optional bool bGetDefault);

/** If child is an AnimNodeSequence, find its duration at current play rate. */
native final function float GetAnimDuration(int ChildIndex);

/** Use to implement custom anim blend functionality in script */
event TickAnim(FLOAT DeltaSeconds);

defaultproperties
{
	BlendTime=0.25
}
