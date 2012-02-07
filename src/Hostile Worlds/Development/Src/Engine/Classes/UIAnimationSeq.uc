/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UIAnimationSeq extends UIAnimation
	native(UIPrivate);

/** The name of this sequence */
var		name					SeqName;

/** Holds a list of Animation Tracks in this sequence */
var		array<UIAnimTrack>		Tracks;

/** Controls how this animation sequence loops */
var		EUIAnimationLoopMode	LoopMode;

/**
 * Wrapper for verifying whether the index is a valid index for the track's keyframes array.
 *
 * @param	TrackIndex	the index [into the Tracks array] for the track to check
 * @param	FrameIndex	the index [into the KeyFrames array of the track] for the keyframe to check
 *
 * @return	TRUE if the specified track contains a keyframe at the specified index.
 */
native final function bool IsValidFrameIndex( int TrackIndex, int FrameIndex ) const;

/**
 * Wrapper for getting the length of a specific frame in one of this animation sequence's tracks.
 *
 * @param	TrackIndex			the index [into the Tracks array] for the track to check
 * @param	FrameIndex			the index [into the KeyFrames array of the track] for the keyframe to check
 * @param	out_FrameLength		receives the remaining seconds for the frame specified
 *
 * @return	TRUE if the call succeeded; FALSE if an invalid track or frame index was specified.
 */
native final function bool GetFrameLength( int TrackIndex, int FrameIndex, out float out_FrameLength ) const;

/**
 * Wrapper for getting the length of a specific track in this animation sequence.
 *
 * @param	TrackIndex	the index [into the Tracks array] for the track to check
 * @param	out_TrackLength		receives the remaining number of seconds for the track specified.
 *
 * @return	TRUE if the call succeeded; FALSE if an invalid track index was specified.
 */
native final function bool GetTrackLength( int TrackIndex, out float out_TrackLength ) const;

/**
 * Wrapper for getting the length of this animation sequence.
 *
 * @return	the total number of seconds in this animation sequence.
 */
native final function float GetSequenceLength() const;

defaultproperties
{
}
