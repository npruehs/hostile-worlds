/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTKillerMessage extends UTWeaponKillMessage;

var(Message) localized string YouKilled, YouKilledTrailer, YouTeamKilled, YouTeamKilledTrailer;
var(Message) localized string OtherKilledPrefix, OtherKilled, OtherKilledTrailer;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_1 == None || RelatedPRI_2.PlayerName == "")
	{
		return "";
	}
	else if (bPRI1HUD)
	{
		return ((RelatedPRI_1.Team == None) || (RelatedPRI_1.Team != RelatedPRI_2.Team))
				? (default.YouKilled @ RelatedPRI_2.PlayerName @ default.YouKilledTrailer)
				: (default.YouTeamKilled @ RelatedPRI_2.PlayerName @ default.YouTeamKilledTrailer);
	}
	else
	{
		return (default.OtherKilledPrefix @ RelatedPRI_1.PlayerName @ default.OtherKilled @ RelatedPRI_2.PlayerName @ default.OtherKilledTrailer);
	}
}

defaultproperties
{
	bIsSpecial=True
	bIsUnique=True
	DrawColor=(R=255,G=255,B=255,A=255)
	FontSize=2
	MessageArea=1
}
