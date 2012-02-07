/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Interface for processing events as they are read out of the game stats stream
 */
class GameplayEventsHandler extends Object
	abstract
	config(Game)
	native;

cpptext
{
	/** The function that does the actual handling of data (override with particular implementation) */
	virtual void HandleEvent(struct FGameEventHeader& GameEvent, class IGameEvent* GameEventData) {}

	/** Access the current session info */
	const FGameSessionInformation& GetSessionInfo() const
	{
		check(Reader);
		return Reader->CurrentSessionInfo;
	}

	/** Returns the metadata associated with the given index */
	virtual const FGameplayEventMetaData& GetEventMetaData(INT EventID)
	{
		check(Reader);
		return Reader->GetEventMetaData(EventID);
	}

	/** Returns the metadata associated with the given index */
	const FTeamInformation& GetTeamMetaData(INT TeamIndex)
	{
		check(Reader);
		return Reader->GetTeamMetaData(TeamIndex);
	}

	/** Returns the metadata associated with the given index */
	const FPlayerInformationNew& GetPlayerMetaData(INT PlayerIndex)
	{
		check(Reader);
		return Reader->GetPlayerMetaData(PlayerIndex);
	}

	/** Returns the metadata associated with the given index */
	const FPawnClassEventData& GetPawnMetaData(INT PawnClassIndex)
	{
		check(Reader);
		return Reader->GetPawnMetaData(PawnClassIndex);
	}

	/** Returns the metadata associated with the given index */
	const FWeaponClassEventData& GetWeaponMetaData(INT WeaponClassIndex)
	{
		check(Reader);
		return Reader->GetWeaponMetaData(WeaponClassIndex);
	}

	/** Returns the metadata associated with the given index */
	const FDamageClassEventData& GetDamageMetaData(INT DamageClassIndex)
	{
		check(Reader);
		return Reader->GetDamageMetaData(DamageClassIndex);
	}

	/** Returns the metadata associated with the given index */
	const FProjectileClassEventData& GetProjectileMetaData(INT ProjectileClassIndex)
	{
		check(Reader);
		return Reader->GetProjectileMetaData(ProjectileClassIndex);
	}

	/**
	 * Returns the metadata associated with the given index
	 * @param ActorIndex the index of the actor being looked up
	 * @return the name of the actor at that index
	 */
	const FString& GetActorMetaData(INT ActorIndex)
	{
		check(Reader);
		return Reader->GetActorMetaData(ActorIndex);
	}
}

/** Array of event types that will be ignored */
var config array<int> EventIDFilter;

/** Array of groups to filter, expands out into EventIDFilter above */
var config array<GameStatGroup> GroupFilter;

/** Reference to the reader for access to metadata, etc */
var transient private{protected} GameplayEventsReader Reader;

/** Set the reader on this handler */
function SetReader(GameplayEventsReader NewReader)
{
	Reader = NewReader;
}

/** A chance to do something before the stream starts */
event PreProcessStream()
{
	// Setup specified filters 
	ResolveGroupFilters();
}

/** A chance to do something after the stream ends */
event PostProcessStream();

/** Iterate over all events, checking to see if they should be filtered out by their group */
event ResolveGroupFilters()
{
	local int EventIdx, FilterIdx;

	for (EventIdx=0; EventIdx<Reader.SupportedEvents.length; EventIdx++)
	{
		// Are we filtering this stats group at all?
		FilterIdx = GroupFilter.Find('Group', Reader.SupportedEvents[EventIdx].StatGroup.Group);
		if (FilterIdx != INDEX_NONE)
		{
			// Stats filter at or above the indicated level
			if (GroupFilter[FilterIdx].Level <= Reader.SupportedEvents[EventIdx].StatGroup.Level)
			{
				AddFilter(Reader.SupportedEvents[EventIdx].EventID);
			}
		}
	}
}

/** Add an event id to ignore while processing */
function AddFilter(int EventID)
{
	if (EventIDFilter.Find(EventID) == INDEX_NONE)
	{
		EventIDFilter.AddItem(EventID);
	}
}

/** Remove an event id to ignore while processing */
function RemoveFilter(int EventID)
{
	EventIDFilter.RemoveItem(EventID);
}

/** Returns whether or not this processor handles this event */
event bool IsEventFiltered(int EventID)
{
	return (EventIDFilter.Find(EventID) != INDEX_NONE);
}