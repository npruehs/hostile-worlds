/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTWeaponRewardMessage extends UTLocalMessage;

var	localized string 	RewardString[11];
var SoundNodeWave RewardSounds[11];

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
	RewardSounds(0)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_ComboKing'
	RewardSounds(1)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_ShaftMaster'
	RewardSounds(2)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_RocketScientist'

	bIsSpecial=True
	bIsUnique=True
	Lifetime=3
	bBeep=False

	DrawColor=(R=255,G=255,B=128)
	FontSize=2

	MessageArea=3
	AnnouncementPriority=6
}
