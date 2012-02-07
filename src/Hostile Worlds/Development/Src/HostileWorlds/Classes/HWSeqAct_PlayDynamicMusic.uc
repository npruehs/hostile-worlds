// ============================================================================
// HWSeqAct_PlayDynamicMusic
// A Hostile Worlds sequence action that switches the dynamic music played.
//
// Author:  Nick Pruehs
// Date:    2011/07/02
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSeqAct_PlayDynamicMusic extends HWSequenceAction;

/** The music to play. */
var() SoundCue MusicToPlay;

/** Time taken for the music to fade in when action is activated. */
var() float	FadeInTime;

/** Time taken for the other music to fade out. */
var() float	FadeOutTime;

/** Whether the new music to play is intense, or calm. */
var() bool bIsIntense;

event Activated()
{
	local HWPlayerController PC;

	PC = HWPlayerController(GetWorldInfo().GetALocalPlayerController());
	PC.ClientPlayDynamicMusic(MusicToPlay, FadeInTime, FadeOutTime, bIsIntense);

	super.Activated();
}


DefaultProperties
{
	ObjName="Sound - Play Dynamic Music"
}
