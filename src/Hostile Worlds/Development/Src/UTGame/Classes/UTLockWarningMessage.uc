/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTLockWarningMessage extends UTLocalMessage;

var(Message) localized string MissileLockOnString;
var(Message) localized string RadarLockString;

var color RedColor;
var color YellowColor;

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
	switch (Switch)
	{
		case 1:
			return Default.MissileLockOnString;
			break;
		case 4:
			return default.RadarLockString;
			break;
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
	return Default.RedColor;
}

DefaultProperties
{
	RedColor=(R=255,G=0,B=0,A=255)
	YellowColor=(R=255,G=255,B=0,A=255)
	Lifetime=2.5
	bIsUnique=false
	bIsPartiallyUnique=true
	bBeep=false
	DrawColor=(R=0,G=160,B=255,A=255)
	FontSize=1
	MessageArea=3
}
