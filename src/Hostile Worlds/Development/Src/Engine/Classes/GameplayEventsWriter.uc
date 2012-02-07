/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Streams gameplay events recorded during a session to disk
 */
class GameplayEventsWriter extends GameplayEvents
	dependson(OnlineSubsystem,SoundCue)
	config(Game)
	native;

`define INCLUDE_GAME_STATS(dummy)
`include(Engine\Classes\GameStats.uci);
`undefine(INCLUDE_GAME_STATS)

/** Reference to the game (set by StartLogging/EndLogging) */
var const GameInfo Game;

cpptext
{
	/** Turns a controller into a player index, possibly adding new information to the player array **/
	INT ResolveTeamIndex(class ATeamInfo *TeamInfo);

	/** Turns a weapon class into an index, possibly adding new information to the array **/
	INT ResolveWeaponClassIndex(UClass* WeaponClass);

	/** Turns a damage class into an index, possibly adding new information to the array **/
	INT ResolveDamageClassIndex(UClass* DamageClass);

	/** Turns a projectile class into an index, possibly adding new information to the array **/
	INT ResolveProjectileClassIndex(UClass* ProjectileClass);

	/** Turns a pawn class into an index, possibly adding new information to the array **/
	INT ResolvePawnIndex(UClass* PawnClass);

	/**
	 * Turns an actor into an index
	 *
	 * @param Actor the actor to find in the array
	 *
	 * @return the index in the array for that actor
	 */
	INT ResolveActorIndex(AActor* Actor)
	{
		INT Index = INDEX_NONE;
		if (Actor != NULL)
		{
			Index = ActorArray.FindItemIndex(Actor->GetName());
			if (Index == INDEX_NONE)
			{
				Index = ActorArray.AddItem(Actor->GetName());
			}
		}
		return Index;
	}

	/**
	 * Turns an sound cue into an index
	 *
	 * @param Cue the sound cue to find in the array
	 *
	 * @return the index in the array for that sound cue
	 */
	INT ResolveSoundCueIndex(USoundCue* Cue)
	{
		INT Index = INDEX_NONE;
		if (Cue != NULL)
		{
			Index = SoundCueArray.FindItemIndex(Cue->GetName());
			if (Index == INDEX_NONE)
			{
				Index = SoundCueArray.AddItem(Cue->GetName());
			}
		}
		return Index;
	}
};


/** Turns a controller into a player index, possibly adding new information to the player array **/
function native int ResolvePlayerIndex(Controller Player);

/** 
 * Mark a new session, clear existing events, etc 
 *
 * @param HeartbeatDelta - polling frequency (0 turns it off)
 */
native function StartLogging(optional float HeartbeatDelta);

/** 
 * Resets the session, clearing all event data, but keeps the session ID/Timestamp intact
 * @param HeartbeatDelta - polling frequency (0 turns it off)
 */
native function ResetLogging(optional float HeartbeatDelta);

/** 
 * Mark the end of a logging session
 * closes file, stops polling, etc
 */
native function EndLogging();

/** Returns whether or not a logging session has been started */
function bool IsSessionInProgress()
{
	return CurrentSessionInfo.bGameplaySessionInProgress;
}

/** 
 *   Creates the archive that we are going to write to
 * @param Filename - name of the file that will be open for serialization
 * @return TRUE if successful, else FALSE
 */
native function bool OpenStatsFile(string Filename);

/** 
 * Closes and deletes the archive that was being written to
 * clearing all data stored within
 */
native function CloseStatsFile();

/** Serialize the contents of the file header */
native protected function bool SerializeHeader();

/** Serialize the contents of the file footer */
native protected function bool SerializeFooter();

/** Heartbeat function to record various stats (player location, etc) */
function Poll()
{
	local WorldInfo WI;
	WI = class'WorldInfo'.static.GetWorldInfo();
	if (WI.Pauser == None)
	{
		//Get a sample of where everyone is at the moment
		if (Game != None && !Game.bWaitingToStartMatch)
		{
			LogAllPlayerPositionsEvent(`PlayerStatId(LOCATION_POLL));
		}

		LogSystemPollEvents();
	}
}

/**
* Logs an int base game event
*
* @param EventId the event being logged
* @param Value the value associated with the event
*/
native function LogGameIntEvent(int EventId, int Value);

/**
* Logs a string based game event
*
* @param EventId the event being logged
* @param Value the value associated with the event
*/
native function LogGameStringEvent(int EventId, string Value);

/**
* Logs a team event
*
* @param EventId - the event being logged
* @param TeamIndex - the team associated with this event
* @param Value - the value associated with the event
*/
native function LogTeamIntEvent(int EventId, TeamInfo Team, int Value);

/**
* Logs an event with an integer value associated with it
*
* @param EventId the event being logged
* @param Player the player that triggered the event
* @param Value the value for this event
*/
native function LogPlayerIntEvent(int EventId, Controller Player, int Value);

/**
* Logs an event with an float value associated with it
*
* @param EventId the event being logged
* @param Player the player that triggered the event
* @param Value the value for this event
*/
native function LogPlayerFloatEvent(int EventId, Controller Player, float Value);

/**
* Logs an event with an string value associated with it
*
* @param EventId the event being logged
* @param Player the player that triggered the event
* @param EventString the value for this event
*/
native function LogPlayerStringEvent(int EventId, Controller Player, string EventString);

/**
* Logs a spawn event for a player (team, class, etc)
*
* @param EventId the event being logged
* @param Player the player that triggered the event
* @param PawnClass the pawn this player spawned with
* @param Team the team the player is on
*/
native function LogPlayerSpawnEvent(int EventId, Controller Player, class<Pawn> PawnClass, int TeamID);

/**
* Logs when a player leaves/joins a session
*
* @param EventId the login/logout event for the player
* @param Player the player that joined/left
* @param PlayerName the name of the player in question
* @param PlayerId the net id of the player in question
* @param bSplitScreen whether the player is on splitscreen
*/
native function LogPlayerLoginChange(int EventId, Controller Player, string PlayerName, UniqueNetId PlayerId, bool bSplitScreen);

/**
* Logs the location of all players when this event occurred 
*
* @param EventId the event being logged
*/
native function LogAllPlayerPositionsEvent(int EventId);

/**
* Logs a player killing and a player being killed
*
* @param EventId the event that should be written
* @param KillType the additional information about a kill
* @param Killer the player that did the killing
* @param DmgType the damage type that was done
* @param Dead the player that was killed
*/
native function LogPlayerKillDeath(int EventId, int KillType, Controller Killer, class<DamageType> DmgType, Controller Dead);

/**
* Logs a player to player event
*
* @param EventId the event that should be written
* @param Player the player that triggered the event
* @param Target the player that was the recipient
*/
native function LogPlayerPlayerEvent(int EventId, Controller Player, Controller Target);

/**
* Logs a weapon event with an integer value associated with it
*
* @param EventId the event being logged
* @param Player the player that triggered the event
* @param WeaponClass the weapon class associated with the event
* @param Value the value for this event
*/
native function LogWeaponIntEvent(int EventId, Controller Player, class<Weapon> WeaponClass, int Value);

/**
* Logs damage with the amount that was done and to whom it was done
*
* @param EventId the event being logged
* @param Player the player that triggered the event
* @param DmgType the damage type that was done
* @param Target the player being damaged
* @param Amount the amount of damage done
*/
native function LogDamageEvent(int EventId, Controller Player, class<DamageType> DmgType, Controller Target, int Amount);

/**
* Logs a projectile event with an integer value associated with it
*
* @param EventId the event being logged
* @param Player the player that triggered the event
* @param Proj the projectile class associated with the event
* @param Value the value for this event
*/
native function LogProjectileIntEvent(int EventId, Controller Player, class<Projectile> Proj, int Value);


/** Log various system properties like memory usage, network usage, etc. */
native function LogSystemPollEvents();

/** will return a generic param list entry that can then have params set on it before commiting to disk */
native function GenericParamListStatEntry GetGenericParamListEntry();

function RecordAIPathFail(Controller AI, coerce string reason, vector dest)
{
`if(`notdefined(FINAL_RELEASE))
	local GenericParamListStatEntry  PLE;
	
	PLE = GetGenericParamListEntry();
	PLE.AddInt('EventID',`GAMEEVENT_AI_PATH_FAILURE);
	PLE.AddString('Name',AI.Name);
	PLE.AddVector('BaseLocation',AI.Pawn.Location);
	PLE.AddString('Sprite',"Texture2D'EditorResources.BadPylon'");
	PLE.AddString('Text',reason);
	PLE.AddVector('LineStart',AI.Pawn.Location);
	PLE.AddVector('LineEnd',dest);
	PLE.AddVector('BoxLoc',dest);
	PLE.AddVector('BoxExtent',vect(5,5,5));
	PLE.AddInt('PlayerIndex',ResolvePlayerIndex(AI));
	PLE.CommitToDisk();
`endif
}

defaultproperties
{
}