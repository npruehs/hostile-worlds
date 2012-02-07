/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTLocalMessage extends LocalMessage
	abstract;

/** Message area on HUD (index into UTHUD.MessageOffset[]) */
var int MessageArea;

/** Used for ordering messages in announcement queue */
var int AnnouncementPriority;

/** Show PRI's HUD portrait when this message is played */
var bool bShowPortrait;

/** Volume multiplier for announcements */
var float AnnouncementVolume;

/** Delay before playing announcement */
var	float AnnouncementDelay;

static function byte AnnouncementLevel(byte MessageIndex)
{
	return 1;
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC);

/**
 * Allow messages to remove themselves if they are superfluous because of newly added message
 */
static function bool ShouldBeRemoved(UTQueuedAnnouncement MyAnnouncement, class<UTLocalMessage> NewAnnouncementClass, int NewMessageIndex)
{
	return false;
}

static function bool AddAnnouncement(UTAnnouncer Announcer, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
	local UTQueuedAnnouncement NewAnnouncement, A, RemovedAnnouncement;
	local bool bPlacedAnnouncement;

	NewAnnouncement = Announcer.Spawn(class'UTQueuedAnnouncement');
	NewAnnouncement.AnnouncementClass = Default.Class;
	NewAnnouncement.MessageIndex = MessageIndex;
	NewAnnouncement.PRI = PRI;
	NewAnnouncement.OptionalObject = OptionalObject;

	if (Announcer.Queue != None && Announcer.Queue.AnnouncementClass.static.ShouldBeRemoved(Announcer.Queue, Default.Class, MessageIndex))
	{
		RemovedAnnouncement = Announcer.Queue;
		Announcer.Queue = Announcer.Queue.nextAnnouncement;
		RemovedAnnouncement.Destroy();
	}

	// default implementation is to insert based on AnnouncementPriority
	if ( Announcer.Queue == None )
	{
		NewAnnouncement.nextAnnouncement = Announcer.Queue;
		Announcer.Queue = NewAnnouncement;
	}
	else
	{
		if ( default.AnnouncementPriority > Announcer.Queue.AnnouncementClass.default.AnnouncementPriority )
		{
			NewAnnouncement.nextAnnouncement = Announcer.Queue;
			Announcer.Queue = NewAnnouncement;
			bPlacedAnnouncement = true;
		}
		for ( A=Announcer.Queue; A!=None; A=A.nextAnnouncement )
		{
			if ( A.nextAnnouncement == None )
			{
				if ( !bPlacedAnnouncement )
				{
					A.nextAnnouncement = NewAnnouncement;
				}
				break;
			}
			if ( !bPlacedAnnouncement && default.AnnouncementPriority > A.NextAnnouncement.AnnouncementClass.default.AnnouncementPriority )
			{
				bPlacedAnnouncement = true;
				NewAnnouncement.NextAnnouncement = A.nextAnnouncement;
				A.NextAnnouncement = NewAnnouncement;
			}
			else if ( A.nextAnnouncement.AnnouncementClass.static.ShouldBeRemoved(A.nextAnnouncement, Default.Class, MessageIndex) )
			{
				RemovedAnnouncement = A.nextAnnouncement;
				A.nextAnnouncement = A.nextAnnouncement.nextAnnouncement;
				if ( A.nextAnnouncement == None )
				{
					if ( !bPlacedAnnouncement )
					{
						A.nextAnnouncement = NewAnnouncement;
					}
					break;
				}
				RemovedAnnouncement.Destroy();
			}
		}
	}
	return false;
}

static function float GetPos( int Switch, HUD myHUD )
{
	return (UTHUD(myHUD) != None) ? UTHUD(myHUD).MessageOffset[Default.MessageArea] : 0.5;
}

static function bool KilledByVictoryMessage(int AnnouncementIndex)
{
	return (default.AnnouncementPriority < 6);
}

defaultproperties
{
	MessageArea=1
	AnnouncementVolume=2.0
}