/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//
// OptionalObject is an Pickup class
//
class UTWeaponSwitchMessage extends UTLocalMessage;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Actor(OptionalObject) != None )
	{
		return Actor(OptionalObject).GetHumanReadableName();
	}
	return "";
}

defaultproperties
{
	bIsUnique=true
	DrawColor=(R=255,G=255,B=255,A=255)
	FontSize=2
	bIsConsoleMessage=false
	MessageArea=4
}
