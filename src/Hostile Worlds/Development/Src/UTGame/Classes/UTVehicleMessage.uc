/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleMessage extends UTLocalMessage;

var localized array<string> MessageText;

var array<Color> DrawColors;

var array<SoundNodeWave> MessageAnnouncements;

var array<int> CustomMessageArea;



static simulated function ClientReceive(
										PlayerController P,
										optional int Switch,
										optional PlayerReplicationInfo RelatedPRI_1,
										optional PlayerReplicationInfo RelatedPRI_2,
										optional Object OptionalObject
										)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (default.MessageAnnouncements[Switch] != None)
	{
		UTPlayerController(P).PlayAnnouncement(default.class, Switch);
	}
}


static function byte AnnouncementLevel(byte MessageIndex)
{
	return 2;
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.MessageText[Switch];
}


static function color GetColor(
							   optional int Switch,
							   optional PlayerReplicationInfo RelatedPRI_1,
							   optional PlayerReplicationInfo RelatedPRI_2,
								optional Object OptionalObject
							   )
{
	return Default.DrawColors[Switch];
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return default.MessageAnnouncements[MessageIndex];
}

defaultproperties
{
	DrawColors(0)=(R=255,G=255,B=128,A=255)
	DrawColors(1)=(R=0,G=160,B=255,A=255)
	DrawColors(2)=(R=255,G=0,B=0,A=255)
	DrawColors(3)=(R=255,G=0,B=0,A=255)
	DrawColors(4)=(R=255,G=255,B=255,A=255)
	DrawColors(5)=(R=255,G=255,B=255,A=255)

	FontSize=2
	MessageArea=2
	bIsConsoleMessage=false

	bIsUnique=false
	bIsPartiallyUnique=true

	MessageAnnouncements[4]=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_Hijacked'
	MessageAnnouncements[5]=SoundNodeWave'A_Announcer_Reward.Rewards.A_RewardAnnouncer_CarJacked'
	AnnouncementPriority=5
}
