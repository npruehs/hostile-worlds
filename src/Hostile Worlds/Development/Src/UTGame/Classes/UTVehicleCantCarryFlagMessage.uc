/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleCantCarryFlagMessage extends UTLocalMessage;

var localized string FlagMessage;
var SoundNodeWave FlagAnnouncement;

static simulated function ClientReceive( PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
						optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	UTPlayerController(P).PlayAnnouncement(default.class, Switch);
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return default.FlagAnnouncement;
}

static function byte AnnouncementLevel(byte MessageIndex)
{
	return 2;
}

static function string GetString( optional int Switch, optional bool bPRI1HUD, optional PlayerReplicationInfo RelatedPRI_1,
					optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	return default.FlagMessage;
}

defaultproperties
{
	FlagAnnouncement=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_YouCannotCarryTheFlagInThisVehicle'

	bIsUnique=false
	FontSize=1
	MessageArea=2
	bBeep=false
	DrawColor=(R=0,G=160,B=255,A=255)
}
