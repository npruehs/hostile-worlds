/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Abstract base class for a track of interpolated data. Contains the actual data.
 * The Outer of an InterpTrack is the InterpGroup.
 */

class InterpTrack extends Object
	native
	noexport
	collapsecategories
	hidecategories(Object)
	inherits(FInterpEdInputInterface)
	abstract;


/** FCurveEdInterface virtual function table. */
var private native noexport pointer	CurveEdVTable;

/** Subclass of InterpTrackInst that should be created when instancing this track. */
var	class<InterpTrackInst>	TrackInstClass;

/** Required condition for this track to be enabled */
enum ETrackActiveCondition
{
	/** Track is always active */
	ETAC_Always,

	/** Track is active when extreme content (gore) is enabled */
	ETAC_GoreEnabled,

	/** Track is active when extreme content (gore) is disabled */
	ETAC_GoreDisabled
};


/** Sets the condition that must be met for this track to be enabled */
var() ETrackActiveCondition ActiveCondition;

/** Title of track type. */
var		string	TrackTitle;

/** Whether there may only be one of this track in an InterpGroup. */
var		bool	bOnePerGroup; 

/** If this track can only exist inside the Director group. */
var		bool	bDirGroupOnly;

/** Whether or not this track should actually update the target actor. */
var		bool	bDisableTrack;

/** If true, the Actor this track is working on will have BeginAnimControl/FinishAnimControl called on it. */
var		bool	bIsAnimControlTrack;

/** Whether or not this track is visible in the editor. */
var		transient	bool		bVisible;

/** Whether or not this track is selected in the editor. */
var		transient	bool		bIsSelected;

/** Whether or not this track is recording in the editor. */
var		transient	bool		bIsRecording;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInst'

	ActiveCondition=ETAC_Always
	TrackTitle="Track"
	bVisible=true
	bIsSelected=false
	bIsRecording=false
}
