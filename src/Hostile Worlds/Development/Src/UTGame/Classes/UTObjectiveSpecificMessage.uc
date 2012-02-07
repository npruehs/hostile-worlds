/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/** base class for messages that get their text/sound from the objective actor passed to them */
class UTObjectiveSpecificMessage extends UTLocalMessage
	abstract;

/** should be implemented to return the announcement to use based on the given objective and index */
static function ObjectiveAnnouncementInfo GetObjectiveAnnouncement(byte MessageIndex, Object Objective, PlayerController PC);

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	local ObjectiveAnnouncementInfo Announcement;

	Announcement = GetObjectiveAnnouncement(MessageIndex, OptionalObject, PC);
	return Announcement.AnnouncementSound;
}

static simulated function ClientReceive( PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
						optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local UTPlayerController UTP;
	local ObjectiveAnnouncementInfo Announcement;
	
	UTP = UTPlayerController(P);
	if (UTP != None)
	{
		Announcement = GetObjectiveAnnouncement(Switch, OptionalObject, P);

		if (Announcement.AnnouncementSound != None)
		{
			UTP.PlayAnnouncement(default.Class, Switch,, OptionalObject);
		}

		if (P.myHud != None)
		{
			SetHUDDisplay(P, Switch, Announcement.AnnouncementText, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		}
		if (Announcement.AnnouncementText != "")
		{
			if (IsConsoleMessage(Switch) && LocalPlayer(P.Player).ViewportClient != None)
			{
				LocalPlayer(P.Player).ViewportClient.ViewportConsole.OutputText(Announcement.AnnouncementText);
			}
		}
	}
}


static function string GetString(
								 optional int Switch,
								 optional bool bPRI1HUD,
								 optional PlayerReplicationInfo RelatedPRI_1,
								 optional PlayerReplicationInfo RelatedPRI_2,
								 optional Object OptionalObject
								 )
{
	local ObjectiveAnnouncementInfo Announcement;

	if ( IsConsoleMessage(Switch) )
	{
		Announcement = GetObjectiveAnnouncement(Switch, OptionalObject, None);
		return Announcement.AnnouncementText;
	}
	return "";
}

/** sets up whatever this message displays on the HUD */
static simulated function SetHUDDisplay( PlayerController P, int Switch, string Text, PlayerReplicationInfo RelatedPRI_1,
					PlayerReplicationInfo RelatedPRI_2, Object OptionalObject )
{
	if (Text != "")
	{
		P.myHUD.LocalizedMessage( default.Class, RelatedPRI_1, RelatedPRI_2, Text, Switch,
				static.GetPos(Switch, P.MyHUD), static.GetLifeTime(Switch),
				static.GetFontSize(Switch, RelatedPRI_1, RelatedPRI_2, P.PlayerReplicationInfo),
				static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2), OptionalObject );
	}
}

defaultproperties
{
	MessageArea=6
}
