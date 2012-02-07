/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVictoryMessage extends UTLocalMessage;

var SoundNodeWave VictorySounds[6];

static function byte AnnouncementLevel(byte MessageIndex)
{
	return 1;
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return Default.VictorySounds[MessageIndex];
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local UTHUD HUD;

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	
	HUD = UTHUD(P.myHUD);
	if ( (HUD != None) && HUD.bIsSplitScreen )
	{
		return;
	}

	UTPlayerController(P).PlayAnnouncement(default.class,Switch );
}

/**
  * kill all queued messages and play immediately
  */
static function bool AddAnnouncement(UTAnnouncer Announcer, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
	local UTQueuedAnnouncement RemovedAnnouncement;

	while ( Announcer.Queue != None )
	{
		RemovedAnnouncement = Announcer.Queue;
		Announcer.Queue = Announcer.Queue.nextAnnouncement;
		RemovedAnnouncement.Destroy();
	}
	super.AddAnnouncement(Announcer, MessageIndex, PRI, OptionalObject);
	return Announcer.PlayingAnnouncementClass.static.KilledByVictoryMessage(Announcer.PlayingAnnouncementIndex);
}

defaultproperties
{
	bIsConsoleMessage=true
	VictorySounds(0)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_FlawlessVictory'
	VictorySounds(1)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_HumiliatingDefeat'
	VictorySounds(2)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_YouHaveWonTheMatch'
	VictorySounds(3)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_YouHaveLostTheMatch'
	VictorySounds(4)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedTeamWinsTheMatch'
	VictorySounds(5)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueTeamWinsTheMatch'
	MessageArea=2
}
