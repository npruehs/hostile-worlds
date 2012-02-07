/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for mapping properties in an OnlineStatsRead
 * class to the UI. It maintains a set of different read objects that are
 * switched between at run time. This allows you to show leaderboards by
 * age (one week, month, year, etc.) from the same UI by having this
 * data store just use different query objects
 *
 * NOTE: Each game needs to derive at least one class from this one in
 * order to expose the game's specific stats class(es)
 */
class UIDataStore_OnlineStats extends UIDataStore_Remote
	native(inherit)
	implements(UIListElementProvider,UIListElementCellProvider)
	abstract
	transient;

/**
 * The OnlineStatsRead derived classes to load and populate the UI with
 */
var array<class<OnlineStatsRead> > StatsReadClasses;

/** Cached FName for faster compares */
var const name StatsReadName;

struct native PlayerNickMetaData
{
	/** Cached FName for faster compares */
	var const name PlayerNickName;
	/** The name displayed in column headings in the UI */
	var localized string PlayerNickColumnName;
};

var const PlayerNickMetaData PlayerNickData;

struct native RankMetaData
{
	/** Cached FName for faster compares */
	var const name RankName;
	/** The name displayed in column headings in the UI */
	var localized string RankColumnName;
};

/** Cached FName for faster compares */
var const RankMetaData RankNameMetaData;

/** Cached FName for faster compares */
var const name TotalRowsName;

/** The set of stats read objects that will be used for display purposes */
var array<OnlineStatsRead> StatsReadObjects;

/**
 * The OnlineStatsRead object that will be exposed to the UI. One of the objects
 * from the array above. The game specific version of this class needs to change
 * the current setting based on its rules
 */
var OnlineStatsRead StatsRead;

/** The types of stats to fetch */
enum EStatsFetchType
{
	/** The player's stats */
	SFT_Player,
	/** The player and people above/below them */
	SFT_CenteredOnPlayer,
	/** The player's frinds list and them */
	SFT_Friends,
	/** The top n ranked players */
	SFT_TopRankings,
};

/** The current type to read */
var EStatsFetchType CurrentReadType;

/** The stats interface to use for reading stats data */
var OnlineStatsInterface StatsInterface;

/** The player interface to use for performing player specific functions */
var OnlinePlayerInterface PlayerInterface;

cpptext
{
protected:
// UIDataStore interface

	/**
	 * Loads and creates an instance of the registered stats read object
	 */
	virtual void InitializeDataStore(void);

	/**
	 * Returns the stats read results as a collection
	 *
	 * @param OutFields	out value that receives the list of exposed properties
	 */
	virtual void GetSupportedDataFields(TArray<FUIDataProviderField>& OutFields)
	{
		OutFields.Empty();
		new(OutFields)FUIDataProviderField(StatsReadName,DATATYPE_Collection);
		new(OutFields)FUIDataProviderField(TotalRowsName);
	}

	/**
	 * Gets the value for the specified field
	 *
	 * @param	FieldName		the field to look up the value for
	 * @param	OutFieldValue	out param getting the value
	 * @param	ArrayIndex		ignored
	 */
	virtual UBOOL GetFieldValue(const FString& FieldName,FUIProviderFieldValue& OutFieldValue,INT ArrayIndex=INDEX_NONE)
	{
		if (FName(*FieldName) == TotalRowsName)
		{
			OutFieldValue.PropertyType = DATATYPE_Property;
			OutFieldValue.StringValue = FString::Printf(TEXT("%d"),StatsRead ? StatsRead->TotalRowsInView : 0);
			return TRUE;
		}
		return FALSE;
	}

	/**
	 * Returns the list element provider for the specified proprety name
	 *
	 * @param PropertyName the name of the property to look up
	 *
	 * @return pointer to the interface or null if the property name is invalid
	 */
	virtual TScriptInterface<IUIListElementProvider> ResolveListElementProvider(const FString& PropertyName)
	{
		if (FName(*PropertyName) == StatsReadName)
		{
			return this;
		}
		return TScriptInterface<IUIListElementProvider>();
	}

// IUIListElement interface

	/**
	 * Returns the names of the columns that can be bound to
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param OutCellTags the columns supported by this row
	 */
	virtual void GetElementCellTags( FName FieldName, TMap<FName,FString>& out_CellTags );

	/**
	 * Retrieves the field type for the specified cell.
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param CellTag the tag for the element cell to get the field type for
	 * @param OutCellFieldType receives the field type for the specified cell (property)
	 *
	 * @return TRUE if the cell tag is valid, FALSE otherwise
	 */
	virtual UBOOL GetCellFieldType(FName FieldName, const FName& CellTag,BYTE& OutCellFieldType);

	/**
	 * Finds the value for the specified column in a row (if valid)
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param CellTag the tag for the element cell to resolve the value for
	 * @param ListIndex the index into the stats read results array
	 * @param OutFieldValue the out value that holds the cell's value
	 * @param ArrayIndex ignored
	 *
	 * @return TRUE if the cell value was found, FALSE otherwise
	 */
	virtual UBOOL GetCellFieldValue(FName FieldName, const FName& CellTag,INT ListIndex,FUIProviderFieldValue& OutFieldValue,INT ArrayIndex = INDEX_NONE);

// IUIListElementProvider interface

	/**
	 * Fetches the column names that can be bound
	 *
	 * @return the list of tags supported
	 */
	virtual TArray<FName> GetElementProviderTags(void);

	/**
	 * Returns the number of rows in the data set
	 *
	 * @param DataTag the name of the collection that is being queried
	 *
	 * @return the number of items in the list
	 */
	virtual INT GetElementCount(FName DataTag)
	{
		check(StatsRead);
		return StatsRead->Rows.Num();
	}

	/**
	 * Returns the list of indices for the list items
	 *
	 * @param	FieldName		the name of the property to get the indices for
	 * @param	OutElements		will be filled with the indices into the list
	 *
	 * @return	TRUE if the field name is valid, FALSE otherwise
	 */
	virtual UBOOL GetListElements(FName FieldName,TArray<INT>& OutElements);

	/**
	 * Fetches the interface that allows the UI to query for column names
	 *
	 * @param DataTag the tag of the list needed
	 *
	 * @return a pointer to the interface or null if invalid
	 */
	virtual TScriptInterface<IUIListElementCellProvider> GetElementCellSchemaProvider(FName FieldName)
	{
		if (FieldName == StatsReadName)
		{
			return this;
		}
		return TScriptInterface<IUIListElementCellProvider>();
	}

	/**
	 * Fetches the interface that allows the UI to query for column values
	 *
	 * @param FieldName the tag of the list that needs the interface
	 * @param ListIndex ignored
	 *
	 * @return a pointer to the interface or null if invalid
	 */
	virtual TScriptInterface<IUIListElementCellProvider> GetElementCellValueProvider(FName FieldName,INT)
	{
		if (FieldName == StatsReadName)
		{
			return this;
		}
		return TScriptInterface<IUIListElementCellProvider>();
	}
}

/**
 * Grabs the interface pointers and sets the read delegate
 */
event Init()
{
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if ( OnlineSub != None )
	{
		// Grab the stats and player interfaces
		StatsInterface = OnlineSub.StatsInterface;
		PlayerInterface = OnlineSub.PlayerInterface;

		// Set the delegate that tells the UI to refresh
		StatsInterface.AddReadOnlineStatsCompleteDelegate(OnReadComplete);
	}
}

/**
 * This function should be overloaded with a game specific version. It is used
 * to determine which search class to use and in which mode
 */
function SetStatsReadInfo()
{
	StatsRead = StatsReadObjects[0];
	CurrentReadType = SFT_Player;
}

/**
 * Tells the online subsystem to re-read the stats data using the current read
 * mode and the current object to add the results to
 */
event bool RefreshStats(byte ControllerIndex)
{
	local array<UniqueNetId> Players;
	local UniqueNetId PlayerId;

	SetStatsReadInfo();
	// Clear the previous results and tell the UI to update
	StatsInterface.FreeStats(StatsRead);
	OnReadComplete(true);

	// Figure out what type of stats read we are doing
	switch (CurrentReadType)
	{
		case SFT_Player:
			// Get the player id of the local player and then read the stats
			PlayerInterface.GetUniquePlayerId(ControllerIndex,PlayerId);
			Players[0] = PlayerId;
			if (StatsInterface.ReadOnlineStats(Players, StatsRead) == false)
			{
				// Clear the delegate that tells the UI to refresh
				`warn("Querying Player failed.");
				return false;
			}
			return true;

		case SFT_CenteredOnPlayer:
			if (StatsInterface.ReadOnlineStatsByRankAroundPlayer(ControllerIndex, StatsRead, 10) == false)
			{
				// Clear the delegate that tells the UI to refresh
				`warn("Querying CenteredOnPlayer failed.");
				return false;
			}
			return true;

		case SFT_Friends:
			if (StatsInterface.ReadOnlineStatsForFriends(ControllerIndex, StatsRead) == false)
			{
				// Clear the delegate that tells the UI to refresh
				`warn("Querying Friends failed.");
				return false;
			}
			return true;

		case SFT_TopRankings:
//@todo joeg -- expose a way to do virtual paging...different Kismet object?
			if (StatsInterface.ReadOnlineStatsByRank(StatsRead) == false)
			{
				// Clear the delegate that tells the UI to refresh
				`log("Querying Top Rankings failed.");
				return false;
			}
			return true;
	}
}

/**
 * Displays the gamercard for the specified list index
 *
 * @param ConrollerIndex	the ControllerId for the player displaying the gamercard
 * @param ListIndex			the item in the list to display the gamercard for
 */
event bool ShowGamercard(byte ConrollerIndex,int ListIndex)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterfaceEx PlayerExt;
	local UniqueNetId PlayerId;

	// Validate the specified index is within the stats results
	if (ListIndex >= 0 && ListIndex < StatsRead.Rows.Length)
	{
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			PlayerExt = OnlineSub.PlayerInterfaceEx;
			if (PlayerExt != None)
			{
				// Get the player id of the player we are going to show the gamer card of
				PlayerId = StatsRead.Rows[ListIndex].PlayerId;
				// Show the gamer card
				return PlayerExt.ShowGamerCardUI(ConrollerIndex,PlayerId);
			}
			else
			{
				`warn("OnlineSubsystem does not support the extended player interface. Can't show gamercard");
			}
		}
		else
		{
			`warn("No OnlineSubsystem present. Can't show gamercard");
		}
	}
	else
	{
		`warn("Invalid index ("$ListIndex$") specified for online game to show the gamercard of");
	}
}

/**
 * Called by the online subsystem when the stats read has completed
 *
 * @param bWasSuccessful whether the stats read was successful or not
 */
function OnReadComplete(bool bWasSuccessful)
{
	// If the call worked, sort the items before telling the list to refresh
	if (bWasSuccessful)
	{
		SortResultsByRank();
	}
//@todo - display a message box upon error?
	// Notify any subscribers that we have new data
	NotifyPropertyChanged();
	RefreshSubscribers();
}

/**
 * Sorts the returned results by their rank (lowest to highest)
 */
native function SortResultsByRank();

defaultproperties
{
	// Change this value in the derived class
	Tag=OnlineStats
	StatsReadName=StatsReadResults
	PlayerNickData=(PlayerNickName="Player Nick")
	RankNameMetaData=(RankName="Rank")
	TotalRowsName="TotalRows"
}
