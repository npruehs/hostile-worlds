/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class InterpTrackFaceFXHelper extends InterpTrackHelper
	native;

cpptext
{
	virtual	UBOOL PreCreateKeyframe( UInterpTrack *Track, FLOAT KeyTime ) const;
	virtual void  PostCreateKeyframe( UInterpTrack *Track, INT KeyIndex ) const;
}
