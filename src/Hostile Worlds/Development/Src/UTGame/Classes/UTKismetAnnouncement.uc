/** message class for announcements played through "Play Announcement" Kismet action
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTKismetAnnouncement extends UTObjectiveSpecificMessage;

static function ObjectiveAnnouncementInfo GetObjectiveAnnouncement(byte MessageIndex, Object Objective, PlayerController PC)
{
	local UTSeqAct_PlayAnnouncement Action;
	local ObjectiveAnnouncementInfo EmptyAnnouncement;

	Action = UTSeqAct_PlayAnnouncement(Objective);
	return (Action != None) ? Action.Announcement : EmptyAnnouncement;
}

static function byte AnnouncementLevel(byte MessageIndex)
{
	return 1;
}

defaultproperties
{
	DrawColor=(R=0,G=160,B=255,A=255)
	FontSize=2
	Lifetime=2.5
	bIsConsoleMessage=true
	MessageArea=6
}
