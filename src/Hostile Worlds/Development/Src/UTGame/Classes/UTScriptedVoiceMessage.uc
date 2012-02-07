/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTScriptedVoiceMessage extends UTLocalMessage
	abstract;

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return SoundNodeWave(OptionalObject);
}

static simulated function ClientReceive( PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
					optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if (SoundNodeWave(OptionalObject) != None)
	{
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		UTPlayerController(P).PlayAnnouncement(default.class, Switch, RelatedPRI_1, OptionalObject);
	}
}

static function string GetString( optional int Switch, optional bool bPRI1HUD, optional PlayerReplicationInfo RelatedPRI_1,
				optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	return "";
}


static function byte AnnouncementLevel(byte MessageIndex)
{
	return 0;
}

defaultproperties
{
	bShowPortrait=true
	bIsConsoleMessage=false
}
