/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKAnimNodeFramePlayer extends AnimNodeSequence
	native(Animation);

native function SetAnimation(name Sequence, float RateScale);
native function SetAnimPosition(float Perc);

defaultproperties
{
}
