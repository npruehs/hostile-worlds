/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Aggregates data from a game session stored on disk
 */
class GameStatsAggregator extends GameplayEventsHandler
	native(GameStats)
	config(Game);

`include(Engine\Classes\GameStats.uci);

/* Aggregate data starts here */
const GAMEEVENT_AGGREGATED_DATA = 10000;

/** Total time player is recorded as alive (Player Spawn -> Player Death) */
const GAMEEVENT_AGGREGATED_PLAYER_TIMEALIVE = 10001;

/** Game specific starts here */
const GAMEEVENT_AGGREGATED_GAME_SPECIFIC = 11000;

/** Current game state as the game stream is parsed */
var GameStateObject GameState;

/** Basic ID pair for storing events in the aggregate mapping */
struct native EventPair
{
	var int EventPair[2];

	structcpptext
	{
		FEventPair()
		{}
		FEventPair(EEventParm)
		{
			appMemzero(this, sizeof(FEventPair));
		}
		FEventPair(INT EventID, INT SubEventID) 
		{
			EventPair[0] = EventID;
			EventPair[1] = SubEventID;
		}
		FEventPair(const FEventPair& Src)
		{
			EventPair[0] = Src.EventPair[0];
			EventPair[1] = Src.EventPair[1];
		}
		// Assignment operators.
		FEventPair& operator=(const FEventPair& Other)
		{
			EventPair[0] = Other.EventPair[0];
			EventPair[1] = Other.EventPair[1];
			return *this;
		}

		UBOOL operator==(const FEventPair& Src) const
		{
			return (EventPair[0] == Src.EventPair[0]) && (EventPair[1] == Src.EventPair[1]);
		}

		/** TMap interface */
		friend FORCEINLINE DWORD GetTypeHash( const FEventPair& EventPair )
		{
			return appMemCrc(&EventPair, sizeof(FEventPair));
		}

		/**
		 * Serialize to Archive
		 */
		friend FArchive& operator<<( FArchive& Ar, FEventPair& W )
		{
			return Ar << W.EventPair[0] << W.EventPair[1];
		}
	}
};

/** Events to post in the special "highlights" sections of the report */
var array<int> HighlightEvents;
/** Array of all unique EventIDs found in the stream or added by the aggregator */
var const private array<int> EventsFound;
/** Mapping of aggregate dimensions to a mapping of event IDs stored there and their accumulated values */
var const private native transient  Map_Mirror  GameAggregateEventMap{TMap<INT, TMap<INT, FLOAT> >};
/** Mapping of aggregate dimensions to a mapping of sub dimensions, their event IDs stored there and their accumulated values */
var const private native transient  Map_Mirror  GameAggregateEventPairMap{TMap<INT, TMap<FEventPair, FLOAT> >};
/** The additional set of aggregate events that the aggregator supports */
var array<GameplayEventMetaData> AggregateEvents;

cpptext
{
	/** 
	 * The function that does the actual handling of data
	 * Makes sure that the game state object gets a chance to handle data before the aggregator does
	 * @param GameEvent - header of the current game event from disk
	 * @param GameEventData - payload immediately following the header
	 */
	virtual void HandleEvent(struct FGameEventHeader& GameEvent, class IGameEvent* GameEventData);

	/*
	 *   GameStatsFileReader Interface (handles parsing of the data stream)
	 */
	virtual void HandleGameStringEvent(struct FGameEventHeader& GameEvent, struct FGameStringEvent* GameEventData);
	virtual void HandleGameIntEvent(struct FGameEventHeader& GameEvent, struct FGameIntEvent* GameEventData);
	
	virtual void HandleTeamIntEvent(struct FGameEventHeader& GameEvent, struct FTeamIntEvent* GameEventData);
	
	virtual void HandlePlayerIntEvent(struct FGameEventHeader& GameEvent, struct FPlayerIntEvent* GameEventData);
	virtual void HandlePlayerFloatEvent(struct FGameEventHeader& GameEvent, struct FPlayerFloatEvent* GameEventData);
	virtual void HandlePlayerStringEvent(struct FGameEventHeader& GameEvent, struct FPlayerStringEvent* GameEventData);
	virtual void HandlePlayerSpawnEvent(struct FGameEventHeader& GameEvent, struct FPlayerSpawnEvent* GameEventData);
	virtual void HandlePlayerLoginEvent(struct FGameEventHeader& GameEvent, struct FPlayerLoginEvent* GameEventData);
	virtual void HandlePlayerKillDeathEvent(struct FGameEventHeader& GameEvent, struct FPlayerKillDeathEvent* GameEventData);
	virtual void HandlePlayerPlayerEvent(struct FGameEventHeader& GameEvent, struct FPlayerPlayerEvent* GameEventData);
	virtual void HandlePlayerLocationsEvent(struct FGameEventHeader& GameEvent, struct FPlayerLocationsEvent* GameEventData);
	
	virtual void HandleWeaponIntEvent(struct FGameEventHeader& GameEvent, struct FWeaponIntEvent* GameEventData);
	virtual void HandleDamageIntEvent(struct FGameEventHeader& GameEvent, struct FDamageIntEvent* GameEventData);
	virtual void HandleProjectileIntEvent(struct FGameEventHeader& GameEvent, struct FProjectileIntEvent* GameEventData);

	/** Triggered by the end of round event, adds any additional aggregate stats required */
	virtual void AddEndOfRoundStats();
	/** Triggered by the end of match event, adds any additional aggregate stats required */
	virtual void AddEndOfMatchStats();

	/** Returns the metadata associated with the given index, overloaded to access aggregate events not found in the stream directly */
	virtual const FGameplayEventMetaData& GetEventMetaData(INT EventID);
};

/** A chance to do something before the stream starts */
native event PreProcessStream();

/** A chance to do something after the stream ends */
native event PostProcessStream();

/** 
 *	Add an entry to the aggregator for the given event
 *	@param Dimension - the dimension to add to
 *	@param EventID - the key value in the given dimension
 *	@param EventValue - the value for this event
 */
native function AddEntryToDimension(int Dimension, int EventID, float EventValue);

/** 
 *	Add an entry pair to the aggregator for the given event
 *	@param Dimension - the dimension to add to
 *	@param SubDimension - the key value in the given dimension
 *	@param EventID - the subkey value in the given dimension
 *	@param EventValue - the value for this event
 */
native function AddEntryPairToDimension(int Dimension, int SubDimension, int EventID, float EventValue);

defaultproperties
{
	// Additional aggregate events added to the output as the game stats stream is parsed
	AggregateEvents.Add((EventID=GAMEEVENT_AGGREGATED_PLAYER_TIMEALIVE,EventName="Player Time Alive",StatGroup=(Group=GSG_Player,Level=1),EventDataType=`GET_PlayerFloat))

	HighlightEvents.Add(GAMEEVENT_PLAYER_KILL);
	HighlightEvents.Add(GAMEEVENT_PLAYER_DEATH);
	HighlightEvents.Add(GAMEEVENT_PLAYER_SPAWN);
	HighlightEvents.Add(GAMEEVENT_PLAYER_MATCH_WON);
}

