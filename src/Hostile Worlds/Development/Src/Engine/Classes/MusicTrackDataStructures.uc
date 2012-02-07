/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MusicTrackDataStructures extends Object
	native;

struct native MusicTrackStruct
{
	/** The soundCue to play **/
	var() SoundCue TheSoundCue;

	/** Controls whether or not the track is auto-played when it is attached to the scene. */
	var() bool bAutoPlay;

	/** Controls whether the sound is not stopped on a map change */
	var() bool bPersistentAcrossLevels;

	/** Time taken for sound to fade in when action is activated. */
	var() float FadeInTime;

	/** Volume the sound to should fade in to */
	var() float FadeInVolumeLevel;

	/** Time take for sound to fade out when Stop input is fired. */
	var() float FadeOutTime;

	/** Volume the sound to should fade out to */
	var() float FadeOutVolumeLevel;

	structdefaultproperties
	{
		FadeInTime=5.0f
		FadeInVolumeLevel=1.0f
		FadeOutTime=5.0f
		FadeOutVolumeLevel=0.0f
	}
};

