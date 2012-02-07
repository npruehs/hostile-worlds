/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTCarriedObjectMessage extends UTLocalMessage
	abstract;


var(Message) localized string ReturnBlue, ReturnRed;
var(Message) localized string ReturnedBlue, ReturnedRed;
var(Message) localized string CaptureBlue, CaptureRed;
var(Message) localized string DroppedBlue, DroppedRed;
var(Message) localized string HasBlue, HasRed;
var(Message) localized string KilledBlue, KilledRed;

var SoundNodeWave ReturnSounds[2];
var SoundNodeWave DroppedSounds[2];
var SoundNodeWave TakenSounds[2];

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

	if ( RelatedPRI_1 == P.PlayerReplicationInfo )
	{
		if ( (Switch == 1) || (Switch == 8) )
		{
			UTPlayerController(P).ClientMusicEvent(3);
		}
		else if ( (Switch == 4) || (Switch == 6) || (Switch == 11) || (Switch == 13) )
		{
			UTPlayerController(P).ClientMusicEvent(7);
		}
	}
	else if ( (Switch == 4) || (Switch == 11) )
	{
		if ( (RelatedPRI_1 != None) && !P.WorldInfo.GRI.OnSameTeam(P,RelatedPRI_1) )
		{
			UTPlayerController(P).ClientMusicEvent(4);
		}
	}

	HUD = UTHUD(P.myHUD);
	if ( (HUD != None) && HUD.bIsSplitScreen && !HUD.bIsFirstPlayer )
	{
		return;
	}

	UTPlayerController(P).PlayAnnouncement(default.class, Switch);
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	switch (MessageIndex)
	{
		// red team
		// Returned the flag.
	case 0:
	case 1:
	case 3: // because it fell out of the world
	case 5:
		return default.ReturnSounds[0];
		break;

		// Dropped the flag.
	case 2:
		return default.DroppedSounds[0];
		break;

		// taken the flag
	case 4: // taken from dropped position
	case 6: // taken from base
		return default.TakenSounds[0];
		break;

		// blue team
		// Returned the flag.
	case 7:
	case 8:
	case 10: // because it fell out of the world
	case 12:
		return default.ReturnSounds[1];
		break;

		// Dropped the flag.
	case 9:
		return default.DroppedSounds[1];
		break;

		// taken the flag
	case 11: // taken from dropped position
	case 13: // taken from base
		return default.TakenSounds[1];
		break;

	}
}

static function byte AnnouncementLevel(byte MessageIndex)
{
	return 2;
}

static function string GetString(
								 optional int Switch,
								 optional bool bPRI1HUD,
								 optional PlayerReplicationInfo RelatedPRI_1,
								 optional PlayerReplicationInfo RelatedPRI_2,
								 optional Object OptionalObject
								 )
{
	switch (Switch)
	{
		// RED TEAM
		// Captured the flag.
	case 0:
		if (RelatedPRI_1 == None)
			return "";

		return RelatedPRI_1.PlayerName@Default.CaptureRed;
		break;

		// Returned the flag.
	case 1:
		if (RelatedPRI_1 == None)
		{
			return Default.ReturnedRed;
		}
		return RelatedPRI_1.PlayerName@Default.ReturnRed;
		break;

		// Dropped the flag.
	case 2:
		if (RelatedPRI_1 == None)
			return "";
		if ( (RelatedPRI_2 != None) && (RelatedPRI_2 != RelatedPRI_1) )
			return RelatedPRI_2.PlayerName@Default.KilledRed;
		else
			return RelatedPRI_1.PlayerName@Default.DroppedRed;
		break;

		// Was returned.
	case 3:
		return Default.ReturnedRed;
		break;

		// Has the flag.
	case 4:
		if (RelatedPRI_1 == None)
			return "";
		return RelatedPRI_1.PlayerName@Default.HasRed;
		break;

		// Auto send home.
	case 5:
		return Default.ReturnedRed;
		break;

		// Pickup
	case 6:
		if (RelatedPRI_1 == None)
			return "";
		return RelatedPRI_1.PlayerName@Default.HasRed;
		break;

		// BLUE TEAM
		// Captured the flag.
	case 7:
		if (RelatedPRI_1 == None)
			return "";

		return RelatedPRI_1.PlayerName@Default.CaptureBlue;
		break;

		// Returned the flag.
	case 8:
		if (RelatedPRI_1 == None)
		{
			return Default.ReturnedBlue;
		}
		return RelatedPRI_1.PlayerName@Default.ReturnBlue;
		break;

		// Dropped the flag.
	case 9:
		if (RelatedPRI_1 == None)
			return "";

		if ( (RelatedPRI_2 != None) && (RelatedPRI_2 != RelatedPRI_1) )
			return RelatedPRI_2.PlayerName@Default.KilledBlue;
		else
			return RelatedPRI_1.PlayerName@Default.DroppedBlue;
		break;

		// Was returned.
	case 10:
		return Default.ReturnedBlue;
		break;

		// Has the flag.
	case 11:
		if (RelatedPRI_1 == None)
			return "";
		return RelatedPRI_1.PlayerName@Default.HasBlue;
		break;

		// Auto send home.
	case 12:
		return Default.ReturnedBlue;
		break;

		// Pickup
	case 13:
		if (RelatedPRI_1 == None)
			return "";
		return RelatedPRI_1.PlayerName@Default.HasBlue;
		break;
	}
	return "";
}

static function bool ShouldBeRemoved(UTQueuedAnnouncement MyAnnouncement, class<UTLocalMessage> NewAnnouncementClass, int NewMessageIndex)
{
	return ShouldRemoveFlagAnnouncement( MyAnnouncement.MessageIndex, NewAnnouncementClass, NewMessageIndex);
}

/**
* Don't let multiple messages for same flag stack up
*/
static function bool ShouldRemoveFlagAnnouncement(int MyMessageIndex, class<UTLocalMessage> NewAnnouncementClass, int NewMessageIndex)
{
	// check if message is not a flag status announcement
	if (default.Class != NewAnnouncementClass)
	{
		return false;
	}

	// check if messages are for same flag
	if ( ((MyMessageIndex < 7) != (NewMessageIndex < 7)) || (MyMessageIndex == 0) )
	{
		return false;
	}

	if ( MyMessageIndex > 6 )
		MyMessageIndex -= 7;
	if ( NewMessageIndex > 6 )
		NewMessageIndex -= 7;

	if ( MyMessageIndex == 6 )
		return false;
	if ( (NewMessageIndex == 1) || (NewMessageIndex == 3) || (NewMessageIndex == 5) || (NewMessageIndex == 12) || (NewMessageIndex == 0) )
		return true;

	return ( (MyMessageIndex == 2) || (MyMessageIndex == 4) );
}

/**
  * move ahead of all queued messages (except for UTVehicleKillMessage or UTWeaponKillRewardMessage)
  * play immediately if already playing multikill message
  * returns true if announcement at head of queue should be played immediately
  */
static function bool AddAnnouncement(UTAnnouncer Announcer, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
	super.AddAnnouncement(Announcer, MessageIndex, PRI, OptionalObject);

	return (Announcer.PlayingAnnouncementClass == None)
		|| (Announcer.PlayingAnnouncementClass == default.Class) && ShouldRemoveFlagAnnouncement(Announcer.PlayingAnnouncementIndex, default.Class, MessageIndex);
}

/**
  * RETURNS true if messages are similar enough to trigger "partially unique" check for HUD display
  */
static function bool PartiallyDuplicates(INT Switch1, INT Switch2, object OptionalObject1, object OptionalObject2 )
{
	return ShouldRemoveFlagAnnouncement(Switch1, default.Class, Switch2);
}

defaultproperties
{
	bIsUnique=True
	FontSize=1
	MessageArea=1
	bBeep=false
	DrawColor=(R=0,G=160,B=255,A=255)
	AnnouncementPriority=4
}
