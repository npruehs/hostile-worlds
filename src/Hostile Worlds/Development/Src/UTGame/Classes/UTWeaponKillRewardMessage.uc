/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTWeaponKillRewardMessage extends UTLocalMessage;

var	localized string 	RewardString[2];
var SoundNodeWave RewardSounds[2];

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.RewardString[Switch];
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
	UTPlayerController(P).PlayAnnouncement(default.class, Switch);
	UTPlayerController(P).ClientMusicEvent(6);
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return Default.RewardSounds[MessageIndex];
}

defaultproperties
{
	RewardSounds(0)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_HeadShot'
	RewardSounds(1)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_Bullseye'

	bIsSpecial=True
	bIsUnique=True
	Lifetime=3
	bBeep=False
	AnnouncementPriority=10

	DrawColor=(R=255,G=255,B=128)
	FontSize=2

	MessageArea=3
}
