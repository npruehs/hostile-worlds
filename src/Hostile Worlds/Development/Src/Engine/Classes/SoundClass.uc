/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class SoundClass extends Object
	hidecategories( object )
	dontsortcategories( SoundClass )
	native( AudioDevice );

struct native export SoundClassEditorData
{
	var	native const int NodePosX;
	var native const int NodePosY;
};
	
/**
 * Structure containing configurable properties of a sound class.
 */
struct native SoundClassProperties
{
	/** Volume multiplier. */
	var() float Volume;
	/** Pitch multiplier. */
	var() float Pitch;
	/** The amount of stereo sounds to bleed to the rear speakers */
	var() float StereoBleed;
	/** The amount of a sound to bleed to the LFE channel */
	var() float LFEBleed;
	/** Voice center channel volume - Not a multiplier (no propagation)	*/
	var() float VoiceCenterChannelVolume;
	/** Radio volume multiplier - Not a multiplier (no propagation) */
	var() float VoiceRadioVolume;

	/** Sound mode voice - whether to apply audio effects */
	var() bool bApplyEffects;
	/** Whether to artificially prioritise the component to play */
	var() bool bAlwaysPlay;
	/** Whether or not this sound plays when the game is paused in the UI */
	var() bool bIsUISound;
	/** Whether or not this is music (propagates only if parent is TRUE) */
	var() bool bIsMusic;
	/** Whether or not this sound class has reverb applied */
	var() bool bReverb;

	structdefaultproperties
	{
		Volume=1
		Pitch=1
		StereoBleed=0.25
		LFEBleed=0.5
		VoiceCenterChannelVolume=0
		VoiceRadioVolume=0
		bApplyEffects=FALSE
		bAlwaysPlay=FALSE
		bIsUISound=FALSE
		bIsMusic=FALSE
		bReverb=TRUE
	}
};
	
/** Configurable properties like volume and priority. */
var()				SoundClassProperties			Properties;
/** Array of names of child sound classes. Empty for leaf classes. */
var()				array<name>						ChildClassNames;
/** Whether this class is referenced by another class */
var					bool							bIsChild;
/** ID used in menus in the editor */
var		editoronly	int								MenuID;
/** Editor data for all sound classes; only used in the master sound class */	
var	editoronly	native const 	Map{USoundClass*, FSoundClassEditorData}	EditorData;

defaultproperties
{
}
