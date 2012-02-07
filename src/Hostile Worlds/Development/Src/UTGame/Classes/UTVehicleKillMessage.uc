/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleKillMessage extends UTLocalMessage;

var localized string KillString[8];
var SoundNodeWave KillSounds[8];

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.KillString[Min(Switch,7)];
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
	UTPlayerController(P).PlayAnnouncement(default.class, Min(Switch,7));
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return Default.KillSounds[MessageIndex];
}

defaultproperties
{
	KillSounds(0)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_RoadKill'
	KillSounds(1)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_Hitandrun'
	KillSounds(2)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_RoadRage'
	KillSounds(3)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_Vehicularmanslaughter'
	KillSounds(4)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_Pancake'
	KillSounds(5)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_EagleEye'
	KillSounds(6)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_topgun'
	KillSounds(7)=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_RoadRampage'

	bIsSpecial=True
	bIsUnique=True
	Lifetime=3
	bBeep=False
	AnnouncementPriority=10

	DrawColor=(R=255,G=0,B=0)
	FontSize=2

	MessageArea=3
}
