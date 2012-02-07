/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//
// CTF Messages
//
// Switch 0: Capture Message
//	RelatedPRI_1 is the scorer.
//	OptionalObject is the flag.
//
// Switch 1: Return Message
//	RelatedPRI_1 is the scorer.
//	OptionalObject is the flag.
//
// Switch 2: Dropped Message
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 3: Was Returned Message
//	OptionalObject is the flag's team teaminfo.
//
// Switch 4: Has the flag.
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 5: Auto Send Home.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 6: Pickup stray.
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.

class UTCTFMessage extends UTCarriedObjectMessage;

/**
* Kill pending flag messages when a score happens
*/
static function bool ShouldBeRemoved(UTQueuedAnnouncement MyAnnouncement, class<UTLocalMessage> NewAnnouncementClass, int NewMessageIndex)
{
	if ( NewAnnouncementClass == class'UTTeamScoreMessage' )
	{
		return true;
	}
	
	return super.ShouldBeRemoved(MyAnnouncement, NewAnnouncementClass, NewMessageIndex);
}

defaultproperties
{
	ReturnSounds(0)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedFlagReturned'
	ReturnSounds(1)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueFlagReturned'
	DroppedSounds(0)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedFlagDropped'
	DroppedSounds(1)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueFlagDropped'
	TakenSounds(0)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_RedFlagTaken'
	TakenSounds(1)=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_BlueFlagTaken'

	bIsUnique=True
	FontSize=2
	MessageArea=1
	bBeep=false
	DrawColor=(R=0,G=160,B=255,A=255)
}
