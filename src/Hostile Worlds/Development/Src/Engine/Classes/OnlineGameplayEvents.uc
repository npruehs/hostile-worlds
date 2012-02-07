/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Holds the gameplay events that were captured in a session
 */
class OnlineGameplayEvents extends Object
	native;

/** List of player information cached in case the player logs out and GC collects the objects */
struct native PlayerInformation
{
	/** Controller.Name */
	// has to be a string unfortunately since the names are shared, number appended
	var string ControllerName;
	/** Controller.PlayerReplicationInfo.PlayerName */
	var string PlayerName;
	/** The unique id that identifies a player on the backend */
	var UniqueNetId UniqueId;
	/** Whether the player is a bot or not */
	var bool bIsBot;
    /** Last entry into PlayerEvent associated with this player */
    var int LastPlayerEventIdx;
};
var const array<PlayerInformation> PlayerList;

/** Table of event descriptions, since they are often duplicated (only events encountered are in the list) */
var const array<string> EventDescList;

/** Table of gameplay events to remove redundant data */
var const array<name> EventNames;

/** Basic information describing a gameplay event, refered to only by a PlayerEvent */
struct native GameplayEvent
{
	/** 
	*	PlayerEvent index and TargetPlayer index packed into a single 32bit integer.
	*	high 16 bits= index to PlayerEvent array designating the parent PlayerEvent for this entry.
	*	low 16 bits = Index to PlayerList to record the target player associated with this event
	*/
	var int PlayerEventAndTarget;
	
	/** 
	*	Event Name index and Event Description index packed into a single 32bit integer.
	*	high 16 bits= Index to the gameplay event name.
	*	low 16 bits = Additional string attached to this event (extra description).
	*/
	var int EventNameAndDesc;
};
var const array<GameplayEvent> GameplayEvents;

/** List of events associated with a player within a specific time section */
struct native PlayerEvent
{
	/** Time this event occured */
	var float EventTime;
	
	/** Location of this event */
	var vector EventLocation;

	/** 
	*	Player index and Yaw Rotation packed into a 32 bit integer.
	*	high 16 bits= Index to PlayerList to record the player associated with this eventy.
	*	low 16 bits = FRotation Yaw component of the orientation for the player
	*/
	var int PlayerIndexAndYaw;
	
	/** 
	*	Player Pitch and Yaw Rotation packed into a 32 bit integer.
	*	low 16 bits = FRotation Pitch component of the orientation for the player
	*	low 16 bits = FRotation Roll component of the orientation for the player
	*/
	var int PlayerPitchAndRoll;
};
var const array<PlayerEvent> PlayerEvents;

/** Time this session was begun */
var const string GameplaySessionStartTime;
/** Is a session currently in progress */
var const bool bGameplaySessionInProgress;
/** Unique session ID */
var const GUID GameplaySessionID;
