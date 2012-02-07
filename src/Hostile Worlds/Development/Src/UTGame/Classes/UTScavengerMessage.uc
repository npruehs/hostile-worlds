/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTScavengerMessage extends UTLocalMessage;

var localized array<string>	MessageText;


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

defaultproperties
{
	DrawColor=(R=255,G=255,B=128,A=255)
	FontSize=2
	MessageArea=2
    bIsPartiallyUnique=true
}
