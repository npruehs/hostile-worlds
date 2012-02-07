/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class InterpTrackInstFloatProp extends InterpTrackInstProperty
	native(Interpolation);

cpptext
{
	virtual void SaveActorState(UInterpTrack* Track);
	virtual void RestoreActorState(UInterpTrack* Track);

	virtual void InitTrackInst(UInterpTrack* Track);
}

/** Pointer to float property in TrackObject. */
var	pointer		FloatProp; 

/** Saved value for restoring state when exiting Matinee. */
var	float		ResetFloat;
