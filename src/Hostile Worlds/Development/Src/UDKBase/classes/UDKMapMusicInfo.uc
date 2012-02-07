/** 
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKMapMusicInfo extends Object
	native
	hidecategories(Object)
	editinlinenew;

enum ECrossfadeType
{
	CFT_BeginningOfMeasure,
	CFT_EndOfMeasure
};

struct native MusicSegment
{
	/** Tempo in Beats per Minute. This allows for the specific segement to have a different BPM **/
	var() float TempoOverride;

	/** crossfading always begins at the beginning of the measure **/
	var ECrossfadeType CrossfadeRule;

	/**
	* How many measures it takes to crossfade to this MusicSegment
	* (e.g. No matter which MusicSegement we are currently in when we crossfade to this one we will
	* fade over this many measures.
	**/
	var() int CrossfadeToMeNumMeasuresDuration;

	var() SoundCue TheCue;

	structdefaultproperties
	{
		CrossfadeRule=CFT_BeginningOfMeasure;
		CrossfadeToMeNumMeasuresDuration=1
	}

};

struct native StingersForAMap
{
	var() SoundCue Died;
	var() SoundCue DoubleKill;
	var() SoundCue EnemyGrabFlag;
	var() SoundCue FirstKillingSpree;
	var() SoundCue FlagReturned;
	var() SoundCue GrabFlag;
	var() SoundCue Kill;
	var() SoundCue LongKillingSpree;
	var() SoundCue MajorKill;
	var() SoundCue MonsterKill;
	var() SoundCue MultiKill;
	var() SoundCue ReturnFlag;
	var() SoundCue ScoreLosing;
	var() SoundCue ScoreTie;
	var() SoundCue ScoreWinning;

};


struct native MusicForAMap
{
	/** Default Tempo in Beats per Minute. **/
	var() float Tempo;

	var() MusicSegment Action;
	var() MusicSegment Ambient;
	var() MusicSegment Intro;
	var() MusicSegment Suspense;
	var() MusicSegment Tension;
	var() MusicSegment Victory;
};

/** 
 * This is the music for the map.  Content folk will pick from the various sets of music that exist
 * and then specify the music the map should have.
 **/
var() MusicForAMap MapMusic;

/** These are the stingers for the map **/
var() StingersForAMap MapStingers;

defaultproperties
{
}


