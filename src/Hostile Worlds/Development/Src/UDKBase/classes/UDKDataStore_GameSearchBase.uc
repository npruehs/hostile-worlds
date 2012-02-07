/**
 * UDK specific data store base class for online game searches.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKDataStore_GameSearchBase extends UIDataStore_OnlineGameSearch
	native
	abstract;

cpptext
{
	/**
	 * Initializes the dataproviders for all of the various character parts.
	 */
	virtual void InitializeDataStore();

	/**
	 * Builds a list of available fields from the array of properties in the
	 * game settings object
	 *
	 * @param OutFields	out value that receives the list of exposed properties
	 */
	virtual void GetSupportedDataFields(TArray<FUIDataProviderField>& OutFields);

	/* === UIListElementProvider === */

	/**
	 * Retrieves the list of all data tags contained by this element provider which correspond to list element data.
	 *
	 * @return	the list of tags supported by this element provider which correspond to list element data.
	 */
	virtual TArray<FName> GetElementProviderTags();

	/**
	 * Returns the number of list elements associated with the data tag specified.
	 *
	 * @param	FieldName	the name of the property to get the element count for.  guaranteed to be one of the values returned
	 *						from GetElementProviderTags.
	 *
	 * @return	the total number of elements that are required to fully represent the data specified.
	 */
	virtual INT GetElementCount( FName FieldName );

	/**
	 * Retrieves the list elements associated with the data tag specified.
	 *
	 * @param	FieldName		the name of the property to get the element count for.  guaranteed to be one of the values returned
	 *							from GetElementProviderTags.
	 * @param	out_Elements	will be filled with the elements associated with the data specified by DataTag.
	 *
	 * @return	TRUE if this data store contains a list element data provider matching the tag specified.
	 */
	virtual UBOOL GetListElements( FName FieldName, TArray<INT>& out_Elements );

	/**
	 * Retrieves a UIListElementCellProvider for the specified data tag that can provide the list with the available cells for this list element.
	 * Used by the UI editor to know which cells are available for binding to individual list cells.
	 *
	 * @param	FieldName		the tag of the list element data field that we want the schema for.
	 *
	 * @return	a pointer to some instance of the data provider for the tag specified.  only used for enumerating the available
	 *			cell bindings, so doesn't need to actually contain any data (i.e. can be the CDO for the data provider class, for example)
	 */
	virtual TScriptInterface<class IUIListElementCellProvider> GetElementCellSchemaProvider( FName FieldName );

	/**
	 * Retrieves a UIListElementCellProvider for the specified data tag that can provide the list with the values for the cells
	 * of the list element indicated by CellValueProvider.DataSourceIndex
	 *
	 * @param	FieldName		the tag of the list element data field that we want the values for
	 * @param	ListIndex		the list index for the element to get values for
	 *
	 * @return	a pointer to an instance of the data provider that contains the value for the data field and list index specified
	 */
	virtual TScriptInterface<class IUIListElementCellProvider> GetElementCellValueProvider( FName FieldName, INT ListIndex );

   	virtual TScriptInterface<class IUIListElementProvider> ResolveListElementProvider( const FString& PropertyName );
}

/** Reference to the dataprovider that will provide details for a specific search result. */
var transient	UDKUIDataProvider_ServerDetails	ServerDetailsProvider;

/**
 * Retrieves the list of currently enabled mutators.
 *
 * @param	MutatorIndices	indices are from the list of UTUIDataProvider_Mutator data providers in the
 *							UTUIDataStore_MenuItems data store which are currently enabled.
 *
 * @return	TRUE if the list of enabled mutators was successfully retrieved.
 */
native function bool GetEnabledMutators( out array<int> MutatorIndices );

/**
 * Registers the delegate with the online subsystem
 */
event Init()
{
	Super.Init();

	// since we have two game search data stores active at the same time, we'll need to register this delegate only when
	// we're actively performing a search..
	if ( GameInterface != None )
	{
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnSearchComplete);
	}
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
	local bool bResult;

	// Set the function to call when the search is done
	GameInterface.AddFindOnlineGamesCompleteDelegate(OnSearchComplete);

	bResult = Super.SubmitGameSearch(ControllerIndex, bInvalidateExistingSearchResults);
	if ( !bResult )
	{
		// should never return false, but just to be safe
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnSearchComplete);
	}

	return bResult;
}

/**
 * Called by the online subsystem when the game search has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnSearchComplete(bool bWasSuccessful)
{
	// regardless of whether the query was successful, if we don't have any queries pending, unregister the delegate
	// so that we don't receive callbacks when the other game search data store is performing a query
	if ( !HasOutstandingQueries(true) )
	{
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnSearchComplete);
	}

	Super.OnSearchComplete(bWasSuccessful);
}

/**
 * @param	bRestrictCheckToSelf	if TRUE, will not check related game search data stores for outstanding queries.
 *
 * @return	TRUE if a server list query was started but has not completed yet.
 */
function bool HasOutstandingQueries( optional bool bRestrictCheckToSelf )
{
	local bool bResult;
	local int i;

	for ( i = 0; i < GameSearchCfgList.Length; i++ )
	{
		if ( GameSearchCfgList[i].Search != None && GameSearchCfgList[i].Search.bIsSearchInProgress )
		{
			bResult = true;
			break;
		}
	}

	return bResult;
}

/**
 * @return	TRUE if the current game search has completed a query.
 */
function bool HasExistingSearchResults()
{
	local bool bQueryCompleted;

	// ok, this is imprecise - we may have already issued a query, but no servers were found...
	// could add a bool
	if ( SelectedIndex >=0 && SelectedIndex < GameSearchCfgList.Length )
	{
		bQueryCompleted = GameSearchCfgList[SelectedIndex].Search.Results.Length > 0;
	}

	return bQueryCompleted;
}

defaultproperties
{
}
