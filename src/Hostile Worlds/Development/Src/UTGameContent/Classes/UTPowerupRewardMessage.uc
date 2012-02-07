/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTPowerupRewardMessage extends UTLocalMessage;

var localized string JuggernautString;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.JuggernautString;
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	UTPlayerController(P).PlayAnnouncement(default.class, 0);
	UTPlayerController(P).ClientMusicEvent(6);
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_Juggernaut';
}

defaultproperties
{
	MessageArea=3
	Fontsize=2
	bBeep=False
	DrawColor=(R=255,G=0,B=0)
	AnnouncementPriority=5
}
