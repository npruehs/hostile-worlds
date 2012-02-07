/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTTeamScoreMessage extends UTLocalMessage;

var SoundNodeWave TeamScoreSounds[8];
var localized string PreScoreRed, ScoreRed, PreScoreBlue, ScoreBlue, PreScoreNone, ScoreNone;

static function byte AnnouncementLevel(byte MessageIndex)
{
	return 1;
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local UTHUD HUD;

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	HUD = UTHUD(P.myHUD);
	if ( (HUD != None) && HUD.bIsSplitScreen && !HUD.bIsFirstPlayer )
	{
		return;
	}
	UTPlayerController(P).PlayAnnouncement(default.class,Switch );

	if ( Switch < 2 )
		UTPlayerController(P).ClientMusicEvent(13);
	else if ( Switch < 4 )
		UTPlayerController(P).ClientMusicEvent(14);
	else if ( Switch < 6 )
		UTPlayerController(P).ClientMusicEvent(15);
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return Default.TeamScoreSounds[MessageIndex];
}

static function string GetString(
								 optional int Switch,
								 optional bool bPRI1HUD,
								 optional PlayerReplicationInfo RelatedPRI_1,
								 optional PlayerReplicationInfo RelatedPRI_2,
								 optional Object OptionalObject
								 )
{
	if ( (Switch > 5) && (RelatedPRI_1 != None) )
	{
		if ( RelatedPRI_1.Team == None )
		{
			return default.PreScoreNone@RelatedPRI_1.PlayerName@default.ScoreNone;
		}
		if ( RelatedPRI_1.Team.TeamIndex == 0 )
		{
			return default.PreScoreRed@RelatedPRI_1.PlayerName@default.ScoreRed;
		}
		return default.PreScoreBlue@RelatedPRI_1.PlayerName@default.ScoreBlue;
	}
	return "";
}

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( (Switch > 5) && (RelatedPRI_1 != None) && (RelatedPRI_1.Team != None) )
	{
		return (RelatedPRI_1.Team.TeamIndex == 0) ? class'UTTeamGameMessage'.default.RedDrawColor : class'UTTeamGameMessage'.default.BlueDrawColor;
	}
	return Default.DrawColor;
}

defaultproperties
{
	TeamScoreSounds(0)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedTeamScores'
	TeamScoreSounds(1)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueTeamScores'
	TeamScoreSounds(2)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedTeamIncreasesTheirLead'
	TeamScoreSounds(3)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueTeamIncreasesTheirLead'
	TeamScoreSounds(4)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedTeamTakesTheLead'
	TeamScoreSounds(5)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueTeamTakesTheLead'
	TeamScoreSounds(6)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_HatTrick'
	TeamScoreSounds(7)=None
	FontSize=2
	DrawColor=(R=255,G=255,B=255,A=255)
	AnnouncementPriority=11
}
