/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTCTFHUDMessage extends UTLocalMessage;

// CTF Messages
//
// Switch 0: You have the flag message.
// Switch 1: Enemy has the flag message.
// Switch 2: You and enemy have flag message.

var(Message) localized string YouHaveFlagString;
var(Message) localized string EnemyHasFlagString;
var(Message) localized string BothFlagsString;
var(Message) color RedColor, YellowColor;

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (Switch == 0)
		return Default.YellowColor;
	else
		return Default.RedColor;
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Switch == 0 )
	    return Default.YouHaveFlagString;
    else if ( Switch == 1 )
	    return Default.EnemyHasFlagString;
	else
		return Default.BothFlagsString;
}

static function bool AddAnnouncement(UTAnnouncer Announcer, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject) {}

defaultproperties
{
	bIsUnique=true
	bIsConsoleMessage=False
	Lifetime=1

	RedColor=(R=255,G=0,B=0,A=255)
	YellowColor=(R=255,G=255,B=0,A=255)
	DrawColor=(R=0,G=160,B=255,A=255)
	FontSize=1

	MessageArea=0
}
