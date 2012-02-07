/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTKillsRemainingMessage extends UTLocalMessage;

var SoundNodeWave KillsRemainSounds[3];
var localized string KillsRemainStrings[3];

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.KillsRemainStrings[Switch];
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
	UTPlayerController(P).PlayAnnouncement(default.class, Switch);
}
static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return Default.KillsRemainSounds[MessageIndex];
}

defaultproperties
{
	KillsRemainSounds(0)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_TenKillsRemain'
	KillsRemainSounds(1)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_FiveKillsRemain'
	KillsRemainSounds(2)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_OneKillRemains'

	bIsSpecial=True
	bIsUnique=True
	Lifetime=3
	bBeep=False

	DrawColor=(R=255,G=0,B=0)
	FontSize=3
	AnnouncementPriority=8

	MessageArea=2
}
