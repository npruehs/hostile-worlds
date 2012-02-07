/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class InterpTrackInstDirector extends InterpTrackInst
	native(Interpolation);


var	Actor	OldViewTarget;

cpptext
{
	/** Initialise this Track instance. Called in-game before doing any interpolation. */
	virtual void InitTrackInst(UInterpTrack* Track);
	/** Called when interpolation is done. Should not do anything else with this TrackInst after this. */
	virtual void TermTrackInst(UInterpTrack* Track);
}

defaultproperties
{
}
