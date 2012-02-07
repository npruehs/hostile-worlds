/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTIdleKickWarningMessage extends UTLocalMessage;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	UTPlayerController(OptionalObject).LastKickWarningTime = UTPlayerController(OptionalObject).WorldInfo.TimeSeconds;
    return class'GameMessage'.Default.KickWarning;
}

defaultproperties
{
	bIsUnique=true
	bIsConsoleMessage=False
	Lifetime=1

	DrawColor=(R=255,G=255,B=64,A=255)
	FontSize=2

   	MessageArea=2
}
