/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for mapping properties in an OnlineGameSearch
 * object to something that the UI system can consume. It exposes two things
 * DesiredSettings and SearchResults. DesiredSettings is just publishes the
 * properties/string settings of an online game settings and SearchResults is
 * the set of games found by the search.
 *
 * NOTE: Each game needs to derive at least one class from this one in
 * order to expose the game's specific search class(es)
 */
class UIDataStore_OnlineGameSearch extends UIDataStore_Remote
	native(inherit)
	implements(UIListElementProvider,UIListElementCellProvider)
	abstract
	dependson(OnlineGameSearch)
	transient;

/** Cached FName for faster compares */
var const name SearchResultsName;

/** Cached online subsystem pointer */
var OnlineSubsystem OnlineSub;

/** Cached game interface pointer */
var OnlineGameInterface GameInterface;

/** Holds the items needed for keeping a list of game searches around */
struct native GameSearchCfg
{
	/** The OnlineGameSeach derived class to load and populate the UI with */
	var class<OnlineGameSearch> GameSearchClass;
	/** The OnlineGameSettings derived class to use as the default data */
	var class<OnlineGameSettings> DefaultGameSettingsClass;
	/**
	 * The data provider to use for each search result that is returned. Useful when
	 * a game wishes to create "meta" properties from search results.
	 */
	var class<UIDataProvider_Settings> SearchResultsProviderClass;
	/** Publishes the desired settings from the game search object */
	var UIDataProvider_Settings DesiredSettingsProvider;
	/** Array of providers that handle the search results */
	var array<UIDataProvider_Settings> SearchResults;
	/** OnlineGameSearch object that will be exposed to the UI */
	var OnlineGameSearch Search;
	/** For finding via name */
	var name SearchName;
};

/** The set of game searches and results */
var const array<GameSearchCfg> GameSearchCfgList;

/** The index into the set of providers/searches for the query that the user most recently requested */
var int SelectedIndex;

/** the index into the set of providers/searches for the query that is currently active */
var	int	ActiveSearchIndex;

cpptext
{
protected:
// UIDataStore interface

	/**
	 * Loads and creates an instance of the registered provider objects for each
	 * registered OnlineGameSettings class
	 */
	virtual void InitializeDataStore(void);

	/**
	 * Builds a list of available fields from the array of properties in the
	 * game settings object
	 *
	 * @param OutFields	out value that receives the list of exposed properties
	 */
	virtual void GetSupportedDataFields(TArray<FUIDataProviderField>& OutFields);

	/**
	 * Resolves the value of the data field specified and stores it in the output parameter.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	OutFieldValue	receives the resolved value for the property specified.
	 *							@see GetDataStoreValue for additional notes
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL GetFieldValue(const FString& FieldName,FUIProviderFieldValue& OutFieldValue,INT ArrayIndex);

	/**
	 * Resolves the value of the data field specified and stores the value specified to the appropriate location for that field.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	FieldValue		the value to store for the property specified.
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL SetFieldValue(const FString& FieldName,const FUIProviderScriptFieldValue& FieldValue,INT ArrayIndex = INDEX_NONE);

	/**
	 * Resolves PropertyName into a list element provider that provides list elements for the property specified.
	 *
	 * @param	PropertyName	the name of the property that corresponds to a list element provider supported by this data store
	 *
	 * @return	a pointer to an interface for retrieving list elements associated with the data specified, or NULL if
	 *			there is no list element provider associated with the specified property.
	 */
	virtual TScriptInterface<IUIListElementProvider> ResolveListElementProvider(const FString& PropertyName);

// IUIListElement interface

	/**
	 * Returns the names of the exposed members in the first entry in the array
	 * of search results
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
	 * @param	CellTag				the tag for the element cell to get the field type for
	 * @param	out_CellFieldType	receives the field type for the specified cell; should be a EUIDataProviderFieldType value.
	 *
	 * @return	TRUE if this element cell provider contains a cell with the specified tag, and out_CellFieldType was changed.
	 */
	virtual UBOOL GetCellFieldType( FName FieldName, const FName& CellTag, BYTE& out_CellFieldType );

	/**
	 * Resolves the value of the cell specified by CellTag and stores it in the output parameter.
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param	CellTag			the tag for the element cell to resolve the value for
	 * @param	ListIndex		the UIList's item index for the element that contains this cell.  Useful for data providers which
	 *							do not provide unique UIListElement objects for each element.
	 * @param	out_FieldValue	receives the resolved value for the property specified.
	 *							@see GetDataStoreValue for additional notes
	 * @param	ArrayIndex		optional array index for use with cell tags that represent data collections.  Corresponds to the
	 *							ArrayIndex of the collection that this cell is bound to, or INDEX_NONE if CellTag does not correspond
	 *							to a data collection.
	 */
	virtual UBOOL GetCellFieldValue( FName FieldName, const FName& CellTag, INT ListIndex, FUIProviderFieldValue& out_FieldValue, INT ArrayIndex=INDEX_NONE );

// IUIListElementProvider interface

	/**
	 * Retrieves the list of all data tags contained by this element provider which correspond to list element data.
	 *
	 * @return	the list of tags supported by this element provider which correspond to list element data.
	 */
	virtual TArray<FName> GetElementProviderTags(void);

	/**
	 * Returns the number of list elements associated with the data tag specified.
	 *
	 * @param	DataTag		a tag corresponding to tag of a data provider in this list element provider
	 *						that can be represented by a list
	 *
	 * @return	the total number of elements that are required to fully represent the data specified.
	 */
	virtual INT GetElementCount(FName DataTag);

	/**
	 * Retrieves the list elements associated with the data tag specified.
	 *
	 * @param	FieldName		the name of the property to get the element count for.  guaranteed to be one of the values returned
	 *							from GetElementProviderTags.
	 * @param	OutElements		will be filled with the elements associated with the data specified by DataTag.
	 *
	 * @return	TRUE if this data store contains a list element data provider matching the tag specified.
	 */
	virtual UBOOL GetListElements(FName FieldName,TArray<INT>& OutElements);

	/**
	 * Retrieves a list element for the specified data tag that can provide the list with the available cells for this list element.
	 * Used by the UI editor to know which cells are available for binding to individual list cells.
	 *
	 * @param	DataTag			the tag of the list element data provider that we want the schema for.
	 *
	 * @return	a pointer to some instance of the data provider for the tag specified.  only used for enumerating the available
	 *			cell bindings, so doesn't need to actually contain any data (i.e. can be the CDO for the data provider class, for example)
	 */
	virtual TScriptInterface<IUIListElementCellProvider> GetElementCellSchemaProvider(FName FieldName);

	/**
	 * Retrieves a UIListElementCellProvider for the specified data tag that can provide the list with the values for the cells
	 * of the list element indicated by CellValueProvider.DataSourceIndex
	 *
	 * @param	FieldName		the tag of the list element data field that we want the values for
	 * @param	ListIndex		the list index for the element to get values for
	 *
	 * @return	a pointer to an instance of the data provider that contains the value for the data field and list index specified
	 */
	virtual TScriptInterface<IUIListElementCellProvider> GetElementCellValueProvider(FName FieldName,INT ListIndex);
}

/**
 * Registers the delegate with the online subsystem
 */
event Init()
{
	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the game interface to verify the subsystem supports it
		GameInterface = OnlineSub.GameInterface;
		if (GameInterface != None)
		{
			// Set the function to call when the search is done
			GameInterface.AddFindOnlineGamesCompleteDelegate(OnSearchComplete);
		}
	}
}

/**
 * Attempts to free the results from the last search that was submitted.
 */
function bool InvalidateCurrentSearchResults()
{
	local OnlineGameSearch ActiveSearch;
	local bool bResult;

	ActiveSearch = GetActiveGameSearch();
	if ( ActiveSearch != None )
	{
		// Free any previous results and tell the list to refresh
		if ( GameInterface.FreeSearchResults(ActiveSearch) )
		{
			// BuildSearchResults will clear the list of SearchResults providers for the active search
			BuildSearchResults();

			// notify subscribers that the value has been invalidated.
			RefreshSubscribers(SearchResultsName, true, GameSearchCfgList[SelectedIndex].DesiredSettingsProvider);
			bResult = true;
		}
	}
	return bResult;
}

/**
 * Called to kick off an online game search and set up all of the delegates needed
 *
 * @param ControllerIndex the ControllerId for the player to perform the search for
 * @param bInvalidateExistingSearchResults	specify FALSE to keep previous searches (i.e. for other gametypes) in memory; default
 *											behavior is to clear all search results when switching to a different item in the game search list
 *
 * @return TRUE if the search call works, FALSE otherwise
 */
event bool SubmitGameSearch(byte ControllerIndex, optional bool bInvalidateExistingSearchResults=true)
{
	if (OnlineSub != None)
	{
		if (GameInterface != None)
		{
			if ( bInvalidateExistingSearchResults || ActiveSearchIndex == SelectedIndex )
			{
				InvalidateCurrentSearchResults();
			}

			// Do not change the value of ActiveSearchIndex as long as we have a search in progress.
			if ( ActiveSearchIndex == INDEX_NONE || !GameSearchCfgList[ActiveSearchIndex].Search.bIsSearchInProgress )
			{
				ActiveSearchIndex = SelectedIndex;
			}

			if ( OverrideQuerySubmission(ControllerIndex, GameSearchCfgList[ActiveSearchIndex].Search) )
			{
				return true;
			}

			// invalidate the results for this search
			InvalidateCurrentSearchResults();
			return GameInterface.FindOnlineGames(ControllerIndex,GameSearchCfgList[ActiveSearchIndex].Search);
		}
		else
		{
			`warn("OnlineSubsystem does not support the game interface. Can't search for games");
		}
	}
	else
	{
		`warn("No OnlineSubsystem present. Can't search for games");
	}
	return false;
}

/**
 * Worker for SubmitGameSeach; allows child classes to perform additional work before the query is submitted.
 *
 * @param	ControllerId	the index of the controller for the player to perform the search for.
 * @param	Search			the search object that will be used to generate the query.
 *
 * @return	TRUE to prevent SubmitGameSeach from submitting the search (such as when you do this step yourself).
 */
protected function bool OverrideQuerySubmission( byte ControllerId, OnlineGameSearch Search )
{
	return false;
}

/**
 * Called by the online subsystem when the game search has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnSearchComplete(bool bWasSuccessful)
{
	if (bWasSuccessful == true)
	{
		// Build the array data from the search results
		BuildSearchResults();

		// Notify any providers or other data stores that we have new data
		NotifyPropertyChanged(SearchResultsName);

		// notify any subscribers that we have new data
		RefreshSubscribers(SearchResultsName, false, GameSearchCfgList[ActiveSearchIndex].DesiredSettingsProvider);

		// now we leave ActiveSearchIndex at its current value so that we know which search we performed last - this way
		// when SetCurrentByName, SubmitGameSearch, etc. is called with bInvalidateSearchResults=TRUE, we know which one
		// to invalidate.
	}
	else
	{
		`Log("Failed to search for online games");
	}
}

/**
 * Returns the search result for the list index specified
 *
 * @param ListIndex the index to find the result for
 *
 * @return the search results (empty if out of bounds)
 */
event bool GetSearchResultFromIndex(int ListIndex,out OnlineGameSearchResult Result)
{
	if (ListIndex >= 0 && ListIndex < GameSearchCfgList[SelectedIndex].Search.Results.Length)
	{
		Result = GameSearchCfgList[SelectedIndex].Search.Results[ListIndex];
		return true;
	}
	return false;
}

/**
 * Displays the gamercard for the specified host
 *
 * @param ControllerIndex	the ControllerId for the player displaying the gamercard
 * @param ListIndex			the item in the list to display the gamercard for
 */
event bool ShowHostGamercard(byte ControllerIndex,int ListIndex)
{
	local OnlinePlayerInterfaceEx PlayerExt;
	local OnlineGameSettings Game;

	// Validate the specified index is within the search results
	if (ListIndex >= 0 && ListIndex < GameSearchCfgList[SelectedIndex].Search.Results.Length)
	{
		if (OnlineSub != None)
		{
			PlayerExt = OnlineSub.PlayerInterfaceEx;
			if (PlayerExt != None)
			{
				Game = GameSearchCfgList[SelectedIndex].Search.Results[ListIndex].GameSettings;
				return PlayerExt.ShowGamerCardUI(ControllerIndex,Game.OwningPlayerId);
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

/** Tells this provider to rebuild it's array data */
native function BuildSearchResults();

/** Returns the game search object that is currently selected */
event OnlineGameSearch GetCurrentGameSearch()
{
	if ( SelectedIndex >= 0 && SelectedIndex < GameSearchCfgList.Length )
	{
		return GameSearchCfgList[SelectedIndex].Search;
	}

	return None;
}

/** returns the game search object that last submitted a server query */
event OnlineGameSearch GetActiveGameSearch()
{
	if ( ActiveSearchIndex >= 0 && ActiveSearchIndex < GameSearchCfgList.Length )
	{
		return GameSearchCfgList[ActiveSearchIndex].Search;
	}

	return None;
}

/**
 * Find the index of the search configuration element which has the specified tag.
 *
 * @param	SearchTag	the name of the search configuration to find
 *
 * @return	the index of the search configuration with a tag matching the input value or INDEX_NONE if none were found.
 */
function int FindSearchConfigurationIndex( name SearchTag )
{
	local int Index;

	for (Index = 0; Index < GameSearchCfgList.Length; Index++)
	{
		if (GameSearchCfgList[Index].SearchName == SearchTag)
		{
			return Index;
		}
	}

	return INDEX_NONE;
}


/**
 * Sets the index into the list of game search to use
 *
 * @param NewIndex the new index to use
 * @param bInvalidateExistingSearchResults	specify FALSE to keep previous searches (i.e. for other gametypes) in memory; default
 *											behavior is to clear all search results when switching to a different item in the game search list
 */
event SetCurrentByIndex(int NewIndex, optional bool bInvalidateExistingSearchResults=true)
{
	// Range check to prevent accessed nones
	if (NewIndex >= 0 && NewIndex < GameSearchCfgList.Length)
	{
		SelectedIndex = NewIndex;

		if ( !bInvalidateExistingSearchResults
		|| !InvalidateCurrentSearchResults() )
		{
			RefreshSubscribers(SearchResultsName, true, GameSearchCfgList[SelectedIndex].DesiredSettingsProvider);
		}
	}
	else
	{
		`Log("Invalid index ("$NewIndex$") specified to SetCurrentByIndex() on "$Self);
	}
}

/**
 * Sets the index into the list of game settings to use
 *
 * @param SearchName the name of the search to find
 * @param bInvalidateExistingSearchResults	specify FALSE to keep previous searches (i.e. for other gametypes) in memory; default
 *											behavior is to clear all search results when switching to a different item in the game search list
 */
event SetCurrentByName(name SearchName, optional bool bInvalidateExistingSearchResults=true)
{
	local int Index;

	Index = FindSearchConfigurationIndex(SearchName);
	if ( Index != INDEX_NONE )
	{
		// If this is the one we want, set it and refresh
		SelectedIndex = Index;

		if ( !bInvalidateExistingSearchResults
		|| !InvalidateCurrentSearchResults() )
		{
			RefreshSubscribers(SearchResultsName, true, GameSearchCfgList[SelectedIndex].DesiredSettingsProvider);
		}
	}
	else
	{
		`Log("Invalid name ("$SearchName$") specified to SetCurrentByName() on "$Self);
	}
}

/**
 * Moves to the next item in the list
 *
 * @param bInvalidateExistingSearchResults	specify FALSE to keep previous searches (i.e. for other gametypes) in memory; default
 *											behavior is to clear all search results when switching to a different item in the game search list
 */
event MoveToNext(optional bool bInvalidateExistingSearchResults=true)
{
	SelectedIndex = Min(SelectedIndex + 1,GameSearchCfgList.Length - 1);

	if ( !bInvalidateExistingSearchResults
	|| !InvalidateCurrentSearchResults() )
	{
		RefreshSubscribers(SearchResultsName, true, GameSearchCfgList[SelectedIndex].DesiredSettingsProvider);
	}
}

/**
 * Moves to the previous item in the list
 *
 * @param bInvalidateExistingSearchResults	specify FALSE to keep previous searches (i.e. for other gametypes) in memory; default
 *											behavior is to clear all search results when switching to a different item in the game search list
 */
event MoveToPrevious(optional bool bInvalidateExistingSearchResults=true)
{
	SelectedIndex = Max(SelectedIndex - 1,0);

	if ( !bInvalidateExistingSearchResults
	|| !InvalidateCurrentSearchResults() )
	{
		RefreshSubscribers(SearchResultsName, true, GameSearchCfgList[SelectedIndex].DesiredSettingsProvider);
	}
}

/**
 * Attempts to clear the server query results for all gametypes
 */
function ClearAllSearchResults()
{
	local int OriginalActiveIndex, GameTypeIndex;

	OriginalActiveIndex = ActiveSearchIndex;
	if ( GameInterface != None )
	{
		for ( GameTypeIndex = 0; GameTypeIndex < GameSearchCfgList.Length; GameTypeIndex++ )
		{
			ActiveSearchIndex = GameTypeIndex;
			if ( GameInterface.FreeSearchResults(GameSearchCfgList[GameTypeIndex].Search) )
			{
				// this is const - can't clear it...call BuildSearchResults to clear the SearchResults array for this game search element
				BuildSearchResults();
			}
			else
			{
				`warn(Name $ ".ClearAllSearchResults: Failed to free search results for" @ GameSearchCfgList[GameTypeIndex].SearchName @ "(" $ GameTypeIndex $ ") - search is still in progress");
			}
		}
	}

	ActiveSearchIndex = OriginalActiveIndex;
}

defaultproperties
{
	// Change this value in the derived class
	Tag=OnlineGameSearch
	SearchResultsName=SearchResults
	WriteAccessType=ACCESS_WriteAll

	ActiveSearchIndex=INDEX_NONE
}
