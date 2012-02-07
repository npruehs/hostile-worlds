/**
 *
 * @todo:  add ability to use the TempoOverride
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTMusicManager extends Info
	config(Game);

var float	MusicStartTime;			/** Time at which current track started playing */
var	int		LastBeat;				/** Count of beats since MusicStartTime */

/** This is the temp (in Beats Per Minutes) of the track that is currently playing **/
var private float CurrTempo;
var private float CurrFadeFactor;				/** Pre-computed MusicVolume/CrossFadeTime deltatime multiplier for cross-fading */

var UTPlayerController PlayerOwner;	/** Owner of this MusicManager */

var globalconfig float MusicVolume;	/** Maximum volume for music audiocomponents (max value for VolumeMultiplier). */

var float LastActionEventTime;		/** Time at which last "action event" occurred - used to determine when to fade out action track. */
var	bool	bPendingAction;			/** If true, switch to action on next beat */
var config float StingerVolumeMultiplier;

enum EMusicState
{
	MST_Ambient,
	MST_Tension,
	MST_Suspense,
	MST_Action,
	MST_Victory,
};
var EMusicState CurrentState;		/** Current Music state (reflects which track is active). */

var int PendingEvent;				/** Pending music event - will be processed on next beat. */
var float PendingEventPlayTime;
var float PendingEventDelay;

var AudioComponent CurrentTrack;	/** Track being ramped up, rather than faded out */
var AudioComponent  MusicTracks[6]; /** Music Tracks - see ChangeTrack() for definition of slots. */

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// start music on a short timer so we avoid the long initial tick that can make the music skip
	SetTimer(1.0, false, 'StartMusic');
}

/** StartMusic()
* Initialize MusicManager and start intro track.
*/
function StartMusic()
{
	local UTMapInfo UMI;

	UMI = UTMapInfo(WorldInfo.GetMapInfo());
	// means the content folks have not set the map up with music yet
	if (UMI != None && UMI.MapMusicInfo != None)
	{
		MusicTracks[5] = CreateNewTrack(UMI.MapMusicInfo.MapMusic.Intro.TheCue);
		CurrentTrack = MusicTracks[5];
		LastBeat = 0;
		CurrentState = MST_Ambient;
		if ( MusicTracks[5] != None )
		{
			MusicTracks[5].VolumeMultiplier = MusicVolume;
			MusicTracks[5].OnAudioFinished = IntroFinished;
			MusicTracks[5].Play();
		}
		MusicStartTime = WorldInfo.TimeSeconds;
		PlayerOwner = UTPlayerController(Owner);

		CurrTempo = UMI.MapMusicInfo.MapMusic.Tempo;
		CurrFadeFactor = MusicVolume/UMI.MapMusicInfo.MapMusic.Intro.CrossfadeToMeNumMeasuresDuration;
	}
}

/** delegate set to intro music's AudioComponent to detect when the music has completed */
function IntroFinished(AudioComponent AC)
{
	local UTMapInfo UMI;

	// if the intro is still the active track, switch to the looping ambient now
	if (AC == MusicTracks[5] && CurrentTrack == AC && CurrentState == MST_Ambient)
	{
		UMI = UTMapInfo(WorldInfo.GetMapInfo());
		// means the content folks have not set the map up with music yet
		if( UMI == none )
		{
			//`log( GetFuncName() @ "UMI is none" );
			return;
		}

		// why is this not just changing track to ambient?
		MusicTracks[0] = CreateNewTrack(UMI.MapMusicInfo.MapMusic.Ambient.TheCue);
		if (MusicTracks[0] != None)
		{
			//`log( "fading in Ambient music" );
			MusicTracks[0].VolumeMultiplier = MusicVolume;
			MusicTracks[0].Play();
			CurrentTrack = MusicTracks[0];
			MusicStartTime = WorldInfo.TimeSeconds;
			CurrTempo = UMI.MapMusicInfo.MapMusic.Tempo;
			CurrFadeFactor = MusicVolume/UMI.MapMusicInfo.MapMusic.Ambient.CrossfadeToMeNumMeasuresDuration;
			LastBeat = 0;
		}
	}
}

/* CreateNewTrack()
* Create a new AudioComponent to play MusicCue.
* @param MusicCue:  the sound cue to play
* @returns the new audio component
*/
function AudioComponent CreateNewTrack(SoundCue MusicCue)
{
	local AudioComponent AC;

	AC = CreateAudioComponent( MusicCue, false, true );

	// AC will be none if -nosound option used
	if ( AC != None )
	{
		AC.bAllowSpatialization = false;
		AC.bShouldRemainActiveIfDropped = true;
	}
	return AC;
}

/* MusicEvent()
Music Manager interface for musical events.
@param NewEventIndex:  see list below
0 - enemy action (shooting at you, you shooting at them)
1 - kill
2 - died
3 - returned flag
4 - enemy took flag (from base)
5 - enemy returned flag NOT IMPLEMENTED, CHANGE?
6 - major kill (first blood, killed flag carrier, or took lead in DM)
7 - took flag
8 - killing spree
9 - double kill
10 - long spree
11 - ultrakill
12 - monster kill
13- score behind
14 - score increase lead
15 - score take lead
*/
function MusicEvent(int NewEventIndex)
{
	// set pendingevent - will be processed on the next beat
	if ( PendingEvent > 0 )
	{
		if ( PendingEvent > NewEventIndex )
		{
			return;
		}
		ProcessMusicEvent();
	}

	PendingEvent = NewEventIndex;
	PendingEventPlayTime = WorldInfo.TimeSeconds + PendingEventDelay;

	//`log( "new MusicEvent: " $ NewEventIndex );

	// request change to action track if appropriate
    if ( (PendingEvent != 2)
		&& (PendingEvent != 3)
		&& (PendingEvent != 4)
		&& (PendingEvent != 5)
		&& (PendingEvent != 7)
		&& (PendingEvent < 13) )
	{
		if ( CurrentState != MST_Action )
		{
			bPendingAction = true;
		}

		LastActionEventTime = WorldInfo.TimeSeconds;
	}
}

function bool AlreadyInActionMusic()
{
	return CurrentState == MST_Action;
}

/** ProcessMusicEvent()
process PendingEvent.  Called from Tick() on a beat.
*/
function ProcessMusicEvent()
{
	local UTMapInfo UMI;
	local SoundCue EventCue;
	local AudioComponent EventTrack;

	// change to action track if appropriate
    if ( bPendingAction )
	{
		if ( CurrentState != MST_Action )
			ChangeTrack(MST_Action);
		bPendingAction = false;
	}

	UMI = UTMapInfo(WorldInfo.GetMapInfo());
	// means the content folks have not set the map up with music yet
	if( UMI == none )
	{
		//`log( GetFuncName() @ "UMI is none" );
		return;
	}

	// play appropriate stinger
	Switch ( PendingEvent )
	{
		case 1:		EventCue = UMI.MapMusicInfo.MapStingers.Kill; break;
		case 2:		EventCue = UMI.MapMusicInfo.MapStingers.Died; break;
		case 3:		EventCue = UMI.MapMusicInfo.MapStingers.ReturnFlag; break;
		case 4:		EventCue = UMI.MapMusicInfo.MapStingers.EnemyGrabFlag; break;
		case 5:		EventCue = UMI.MapMusicInfo.MapStingers.FlagReturned; break;
		case 6:		EventCue = UMI.MapMusicInfo.MapStingers.MajorKill; break;
		case 7:		EventCue = UMI.MapMusicInfo.MapStingers.GrabFlag; break;
		case 8:		EventCue = UMI.MapMusicInfo.MapStingers.FirstKillingSpree; break;
		case 9:		EventCue = UMI.MapMusicInfo.MapStingers.DoubleKill; break;
		case 10:	EventCue = UMI.MapMusicInfo.MapStingers.LongKillingSpree; break;
		case 11:	EventCue = UMI.MapMusicInfo.MapStingers.MultiKill; break;
		case 12:	EventCue = UMI.MapMusicInfo.MapStingers.MonsterKill; break;
		case 13:	EventCue = UMI.MapMusicInfo.MapStingers.ScoreLosing; break;
		case 14:	EventCue = UMI.MapMusicInfo.MapStingers.ScoreTie; break;
		case 15:	EventCue = UMI.MapMusicInfo.MapStingers.ScoreWinning; break;
	}

	EventTrack = CreateNewTrack(EventCue);
	if (EventTrack != None)
	{
		EventTrack.bAutoDestroy = true;
		EventTrack.VolumeMultiplier = StingerVolumeMultiplier;
		EventTrack.Play();
	}
}

function Tick(float DeltaTime)
{
	local float NumBeats;
	local int i;
	local EMusicState NewState;

	// Cross-fade
	if ( CurrentTrack != None && CurrentTrack.VolumeMultiplier < MusicVolume )
	{
		// ramp up current track
		CurrentTrack.VolumeMultiplier = FMin(MusicVolume, CurrentTrack.VolumeMultiplier + CurrFadeFactor*DeltaTime);
	}

	for ( i=0; i<6; i++ )
	{
		// ramp down other tracks
		if ( (MusicTracks[i] != None) && (MusicTracks[i] != CurrentTrack) && (MusicTracks[i].VolumeMultiplier > 0.f) )
		{
			MusicTracks[i].VolumeMultiplier = MusicTracks[i].VolumeMultiplier - CurrFadeFactor*DeltaTime;
			if ( MusicTracks[i].VolumeMultiplier <= 0.f )
			{
				//`log( "fading out in tick" );
				MusicTracks[i].VolumeMultiplier = 0.f;
				MusicTracks[i].Stop();
			}
		}
	}

	NumBeats = (WorldInfo.TimeSeconds - MusicStartTime) * CurrTempo/60;
	if ( NumBeats - LastBeat < 1 )
	{
		return;
	}

	LastBeat = int(NumBeats);
	if ( LastBeat % 2 != 0 )
	{
		return;
	}

	// process any outstanding pending events
	if ( (PendingEvent > 0) && (WorldInfo.TimeSeconds > PendingEventPlayTime) )
	{
		ProcessMusicEvent();
		PendingEvent = 0;
		return;
	}

	// check if there is current game action (to keep the action track going)
	if ( PlayerOwner.Pawn != None )
	{
		if ( (PlayerOwner.Pawn.Weapon != None) && PlayerOwner.Pawn.Weapon.IsFiring() )
		{
			LastActionEventTime = WorldInfo.TimeSeconds;
		}
		else if ( UTPawn(PlayerOwner.Pawn) != None && UTPawn(PlayerOwner.Pawn).InCombat() )
		{
			LastActionEventTime = WorldInfo.TimeSeconds;
			if ( CurrentState != MST_Action )
				ChangeTrack(MST_Action);
		}
	}

	if ( (CurrentState != MST_Action) || (WorldInfo.TimeSeconds - LastActionEventTime > 8) )
	{
		// determine if music state needs to change
		if ( (UTPawn(PlayerOwner.Pawn) != None) && UTPawn(PlayerOwner.Pawn).PoweredUp() )
		{
			NewState = MST_Victory;
		}
		else if ( !UTGameReplicationInfo(WorldInfo.GRI).FlagsAreHome() )
		{
			if ( UTPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bHasFlag )
				NewState = MST_Victory;
			else
			{
				if ( (PlayerOwner.PlayerReplicationInfo.Team != None) && UTGameReplicationInfo(WorldInfo.GRI).FlagIsHome(PlayerOwner.PlayerReplicationInfo.Team.TeamIndex) )
					NewState = MST_Suspense;
				else
					NewState = MST_Tension;
			}
		}
		else
		{
			NewState = MST_Ambient;
		}

		if ( NewState != CurrentState )
			ChangeTrack(NewState);
	}
}

/** ChangeTrack()
* @param NewState  New music state (track to ramp up).
*/
function ChangeTrack(EMusicState NewState)
{
	local UTMapInfo UMI;
	local AudioComponent NewTrack;

	//`log( "MusicManager:  ChangeTrack: " $ NewState );

	if ( CurrentState == NewState )
	{
		//`log( "MusicManager:  ChangeTrack:  new and current state are the same" );
		return;
	}

	CurrentState = NewState;

	UMI = UTMapInfo(WorldInfo.GetMapInfo());
	// means the content folks have not set the map up with music yet
	if( UMI == none )
	{
		//`log( GetFuncName() @ "UMI is none" );
		return;
	}

	// select appropriate track
	Switch( NewState )
	{
		case MST_Ambient:
			if ( MusicTracks[0] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == UMI.MapMusicInfo.MapMusic.Ambient.TheCue) )
				{
					MusicTracks[0] = CurrentTrack;
				}
				else
				{
					MusicTracks[0] = CreateNewTrack(UMI.MapMusicInfo.MapMusic.Ambient.TheCue);
				}
			}
			NewTrack = MusicTracks[0];
			CurrTempo = UMI.MapMusicInfo.MapMusic.Tempo;
			CurrFadeFactor = MusicVolume/UMI.MapMusicInfo.MapMusic.Ambient.CrossfadeToMeNumMeasuresDuration;
			break;
		case MST_Tension:
			if ( MusicTracks[1] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == UMI.MapMusicInfo.MapMusic.Tension.TheCue) )
				{
					MusicTracks[1] = CurrentTrack;
				}
				else
				{
					MusicTracks[1] = CreateNewTrack(UMI.MapMusicInfo.MapMusic.Tension.TheCue);
				}
			}
			NewTrack = MusicTracks[1];
			CurrTempo = UMI.MapMusicInfo.MapMusic.Tempo;
			CurrFadeFactor = MusicVolume/UMI.MapMusicInfo.MapMusic.Tension.CrossfadeToMeNumMeasuresDuration;
			break;
		case MST_Suspense:
			if ( MusicTracks[2] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == UMI.MapMusicInfo.MapMusic.Suspense.TheCue) )
				{
					MusicTracks[2] = CurrentTrack;
				}
				else
				{
					MusicTracks[2] = CreateNewTrack(UMI.MapMusicInfo.MapMusic.Suspense.TheCue);
				}
			}
			NewTrack = MusicTracks[2];
			CurrTempo = UMI.MapMusicInfo.MapMusic.Tempo;
			CurrFadeFactor = MusicVolume/UMI.MapMusicInfo.MapMusic.Suspense.CrossfadeToMeNumMeasuresDuration;
			break;
		case MST_Action:
			if ( MusicTracks[3] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == UMI.MapMusicInfo.MapMusic.Action.TheCue) )
				{
					MusicTracks[3] = CurrentTrack;
				}
				else
				{
					MusicTracks[3] = CreateNewTrack(UMI.MapMusicInfo.MapMusic.Action.TheCue);
				}
			}
			NewTrack = MusicTracks[3];
			CurrTempo = UMI.MapMusicInfo.MapMusic.Tempo;
			CurrFadeFactor = MusicVolume/UMI.MapMusicInfo.MapMusic.Action.CrossfadeToMeNumMeasuresDuration;
			break;
		case MST_Victory:
			if ( MusicTracks[4] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == UMI.MapMusicInfo.MapMusic.Victory.TheCue) )
				{
					MusicTracks[4] = CurrentTrack;
				}
				else
				{
					MusicTracks[4] = CreateNewTrack(UMI.MapMusicInfo.MapMusic.Victory.TheCue);
				}
			}
			NewTrack = MusicTracks[4];
			CurrTempo = UMI.MapMusicInfo.MapMusic.Tempo;
			CurrFadeFactor = MusicVolume/UMI.MapMusicInfo.MapMusic.Victory.CrossfadeToMeNumMeasuresDuration;
			break;
	}

	if ( (CurrentTrack == NewTrack) && (CurrentTrack != None) && CurrentTrack.bWasPlaying )
		return;

	// play selected track
	CurrentTrack = NewTrack;
	MusicStartTime = WorldInfo.TimeSeconds;
	LastBeat = 0;
	if ( CurrentTrack != None )
	{
		CurrentTrack.VolumeMultiplier = 0.0;
		CurrentTrack.Play();
	}
}

defaultproperties
{
	LastActionEventTime=-1000.0
	PendingEventDelay=0.125
}


