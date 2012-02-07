/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/** this plays the "X minutes/seconds remaining" announcements */
class UTTimerMessage extends UTLocalMessage
	abstract;

var array<ObjectiveAnnouncementInfo> Announcements;

static simulated function ClientReceive( PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
					optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local AudioComponent CurrentAnnouncementComponent;
	local UTHUD HUD;
	
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if ( default.Announcements[Switch].AnnouncementSound != None )
	{
		HUD = UTHUD(P.myHUD);
		if ( (HUD != None) && HUD.bIsSplitScreen && !HUD.bIsFirstPlayer )
		{
			return;
		}
		
		if ( Switch < 11 )
		{
			// don't prioritize final countdown with other announcements
			CurrentAnnouncementComponent = P.CreateAudioComponent(SoundCue'A_Announcer_Reward_Cue.SoundCues.AnnouncerCue', false, false);

			// CurrentAnnouncementComponent will be none if -nosound option used
			if ( CurrentAnnouncementComponent != None )
			{
				CurrentAnnouncementComponent.SetWaveParameter('Announcement', default.Announcements[Switch].AnnouncementSound);
				//AnnouncerSoundCue.Duration = default.Announcements[Switch].AnnouncementSound.Duration;
				CurrentAnnouncementComponent.bAutoDestroy = true;
				CurrentAnnouncementComponent.bShouldRemainActiveIfDropped = true;
				CurrentAnnouncementComponent.bAllowSpatialization = false;
				CurrentAnnouncementComponent.bAlwaysPlay = TRUE;
				CurrentAnnouncementComponent.Play();
			}
		}
		else
		{
			UTPlayerController(P).PlayAnnouncement(default.class, Switch);
		}
	}
}

static function string GetString( optional int Switch, optional bool bPRI1HUD, optional PlayerReplicationInfo RelatedPRI_1,
					optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	return default.Announcements[Switch].AnnouncementText;
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return default.Announcements[MessageIndex].AnnouncementSound;
}

static function int GetFontSize( int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer )
{
	if ( Switch == 17 )
	{
		return 4;
	}
	if ( Switch > 10 )
	{
		return default.FontSize;
	}
	return 2;
}

defaultproperties
{
	FontSize=1
	bIsConsoleMessage=false
	bIsUnique=true
	bBeep=false
	DrawColor=(R=255,G=255,B=255)

	Announcements[1]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_Countdown_01')
	Announcements[2]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_Countdown_02')
	Announcements[3]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_Countdown_03')
	Announcements[4]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_Countdown_04')
	Announcements[5]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_Countdown_05')
	Announcements[6]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_Countdown_06')
	Announcements[7]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_Countdown_07')
	Announcements[8]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_Countdown_08')
	Announcements[9]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_Countdown_09')
	Announcements[10]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_Countdown_10')
	Announcements[12]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_30SecondsLeft')
	Announcements[13]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_1MinutesRemain')
	Announcements[14]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_2MinutesRemain')
	Announcements[15]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_3MinutesRemain')
	Announcements[16]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_5MinutesRemain')
	Announcements[17]=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_overtime')
}
