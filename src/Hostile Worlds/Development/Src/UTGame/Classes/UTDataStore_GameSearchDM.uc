/**
 * This game search data store handles generating and receiving results for internet queries of all gametypes.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDataStore_GameSearchDM extends UDKDataStore_GameSearchBase
	config(UI);

var			class<UTDataStore_GameSearchHistory>	HistoryGameSearchDataStoreClass;

/** Reference to the search data store that handles the player's list of most recently visited servers */
var	transient	UTDataStore_GameSearchHistory		HistoryGameSearchDataStore;

/**
 * A simple mapping of localized setting ID to a localized setting value ID.
 */
struct PersistentLocalizedSettingValue
{
	/** the ID of the setting */
	var	config	int		SettingId;

	/** the id of the value */
	var	config	int		ValueId;
};

/**
 * Stores a list of values ids for a single game search configuration.
 */
struct GameSearchSettingsStorage
{
	/** the name of the game search configuration */
	var	config	name									GameSearchName;

	/** the list of stored values */
	var	config	array<PersistentLocalizedSettingValue>	StoredValues;
};

/** the list of search parameter values per game search configuration */
var	config	array<GameSearchSettingsStorage>	StoredGameSearchValues;


event Registered( LocalPlayer PlayerOwner )
{
	local DataStoreClient DSClient;

	Super.Registered(PlayerOwner);

	DSClient = GetDataStoreClient();
	if ( DSClient != None )
	{
		// now create the game history data store
		if ( HistoryGameSearchDataStoreClass == None )
		{
			HistoryGameSearchDataStoreClass = class'UTGame.UTDataStore_GameSearchHistory';
		}

		HistoryGameSearchDataStore = DSClient.CreateDataStore(HistoryGameSearchDataStoreClass);
		HistoryGameSearchDataStore.PrimaryGameSearchDataStore = Self;

		// and register it
		DSClient.RegisterDataStore(HistoryGameSearchDataStore, PlayerOwner);
	}

	LoadGameSearchParameters();
}

/**
 * Called to kick off an online game search and set up all of the delegates needed; this version saved the search parameters
 * to persistent storage.
 *
 * @param ControllerIndex the ControllerId for the player to perform the search for
 * @param bInvalidateExistingSearchResults	specify FALSE to keep previous searches (i.e. for other gametypes) in memory; default
 *											behavior is to clear all search results when switching to a different item in the game search list
 *
 * @return TRUE if the search call works, FALSE otherwise
 */
event bool SubmitGameSearch(byte ControllerIndex, optional bool bInvalidateExistingSearchResults=true)
{
	if ( bInvalidateExistingSearchResults || !HasExistingSearchResults() )
	{
		SaveGameSearchParameters();
	}

	return Super.SubmitGameSearch(ControllerIndex, bInvalidateExistingSearchResults);
}

/**
 * @param	bRestrictCheckToSelf	if TRUE, will not check related game search data stores for outstanding queries.
 *
 * @return	TRUE if a server list query was started but has not completed yet.
 */
function bool HasOutstandingQueries( optional bool bRestrictCheckToSelf )
{
	local bool bResult;

	bResult = Super.HasOutstandingQueries(bRestrictCheckToSelf);
	if ( !bResult && !bRestrictCheckToSelf && HistoryGameSearchDataStore != None )
	{
		bResult = HistoryGameSearchDataStore.HasOutstandingQueries(true);
		if ( !bResult && HistoryGameSearchDataStore.FavoritesGameSearchDataStore != None )
		{
			bResult = HistoryGameSearchDataStore.FavoritesGameSearchDataStore.HasOutstandingQueries(true);
		}
	}

	return bResult;
}

/**
 * Finds the index of the saved parameters for the specified game search.
 *
 * @param	GameSearchName	the name of the game search to find saved parameters for
 *
 * @return	the index for the saved parameters associated with the specified gametype, or INDEX_NONE if not found.
 */
function int FindStoredSearchIndex( name GameSearchName )
{
	local int i, Result;

	Result = INDEX_NONE;
	for ( i = 0; i < StoredGameSearchValues.Length; i++ )
	{
		if ( StoredGameSearchValues[i].GameSearchName == GameSearchName )
		{
			Result = i;
			break;
		}
	}

	return Result;
}

/**
 * Find the index for the specified setting in a game search configuration's saved parameters.
 *
 * @param	StoredGameSearchIndex	the index of the game search configuration to lookup
 * @param	LocalizedSettingId		the id of the setting to find the value for
 * @param	bAddIfNecessary			if the specified setting Id is not found in the saved parameters for the game search config,
 *									automatically creates an entry for that setting if this value is TRUE
 *
 * @return	the index of the setting in the game search configuration's saved parameters list of settings, or INDEX_NONE if
 *			it doesn't exist.
 */
function int FindStoredSettingValueIndex( int StoredGameSearchIndex, int LocalizedSettingId, optional bool bAddIfNecessary )
{
	local int i, Result;

	Result = INDEX_NONE;
	if ( StoredGameSearchIndex >= 0 && StoredGameSearchIndex < StoredGameSearchValues.Length )
	{
		for ( i = 0; i < StoredGameSearchValues[StoredGameSearchIndex].StoredValues.Length; i++ )
		{
			if ( StoredGameSearchValues[StoredGameSearchIndex].StoredValues[i].SettingId == LocalizedSettingId )
			{
				Result = i;
				break;
			}
		}

		if ( Result == INDEX_NONE && bAddIfNecessary )
		{
			Result = StoredGameSearchValues[StoredGameSearchIndex].StoredValues.Length;

			StoredGameSearchValues[StoredGameSearchIndex].StoredValues.Length = Result + 1;
			StoredGameSearchValues[StoredGameSearchIndex].StoredValues[Result].SettingId = LocalizedSettingId;
		}
	}

	return Result;
}

/**
 * Loads the saved game search parameters from disk and initializes the game search objects with the previously
 * selected values.
 */
function LoadGameSearchParameters()
{
	local OnlineGameSearch Search;
	local int GameIndex, SettingIndex, SettingId,
		StoredSearchIndex, SettingValueIndex, SettingValueId;

	// for each game configuration
	for ( GameIndex = 0; GameIndex < GameSearchCfgList.Length; GameIndex++ )
	{
		Search = GameSearchCfgList[GameIndex].Search;
		if ( Search != None )
		{
			// find the index of the persistent settings for this gametype
			StoredSearchIndex = FindStoredSearchIndex(GameSearchCfgList[GameIndex].SearchName);
			if ( StoredSearchIndex != INDEX_NONE )
			{
				// for each localized setting in this game search object, copy the stored value into the search object for this game search configuration.
				for ( SettingIndex = 0; SettingIndex < Search.LocalizedSettings.Length; SettingIndex++ )
				{
					SettingId = Search.LocalizedSettings[SettingIndex].Id;

					// skip the gametype property
					if ( SettingId != class'UTGameSearchCommon'.const.CONTEXT_GAME_MODE )
					{
						SettingValueIndex = FindStoredSettingValueIndex(StoredSearchIndex, SettingId);
						if (SettingValueIndex >= 0
						&&	SettingValueIndex < StoredGameSearchValues[StoredSearchIndex].StoredValues.Length)
						{
							SettingValueId = StoredGameSearchValues[StoredSearchIndex].StoredValues[SettingValueIndex].ValueId;

							// apply it to the settings object
							Search.SetStringSettingValue(SettingId, SettingValueId, false);
						}
					}
				}
			}
		}
	}
}

/**
 * Saves the user selected game search options to disk.
 */
function SaveGameSearchParameters()
{
	local OnlineGameSearch Search;
	local int GameIndex, SettingIndex, SettingId,
		StoredSearchIndex, SettingValueIndex;
	local bool bDirty;

	// for each game configuration
	for ( GameIndex = 0; GameIndex < GameSearchCfgList.Length; GameIndex++ )
	{
		Search = GameSearchCfgList[GameIndex].Search;
		if ( Search != None )
		{
			// find the index of the persistent settings for this gametype
			StoredSearchIndex = FindStoredSearchIndex(GameSearchCfgList[GameIndex].SearchName);
			if ( StoredSearchIndex == INDEX_NONE )
			{
				// if not found, add a new entry to hold this game configuration's search params
				StoredSearchIndex = StoredGameSearchValues.Length;
				StoredGameSearchValues.Length = StoredSearchIndex + 1;
				StoredGameSearchvalues[StoredSearchIndex].GameSearchName = GameSearchCfgList[GameIndex].SearchName;
				bDirty = true;
			}

			// for each localized setting in this game search object, copy the current value into our persistent storage
			for ( SettingIndex = 0; SettingIndex < Search.LocalizedSettings.Length; SettingIndex++ )
			{
				SettingId = Search.LocalizedSettings[SettingIndex].Id;

				// skip the gametype property
				if ( SettingId != class'UTGameSearchCommon'.const.CONTEXT_GAME_MODE )
				{
					SettingValueIndex = FindStoredSettingValueIndex(StoredSearchIndex, SettingId, true);
					bDirty = bDirty || StoredGameSearchValues[StoredSearchIndex].StoredValues[SettingValueIndex].ValueId != Search.LocalizedSettings[SettingIndex].ValueIndex;
					StoredGameSearchValues[StoredSearchIndex].StoredValues[SettingValueIndex].ValueId = Search.LocalizedSettings[SettingIndex].ValueIndex;
				}
			}
		}
	}

	if ( bDirty )
	{
		SaveConfig();
	}
}

DefaultProperties
{
	Tag=UTGameSearch
	HistoryGameSearchDataStoreClass=class'UTGame.UTDataStore_GameSearchHistory'

	GameSearchCfgList.Empty
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchDM',DefaultGameSettingsClass=class'UTGame.UTGameSettingsDM',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchDM"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchTDM',DefaultGameSettingsClass=class'UTGame.UTGameSettingsTDM',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchTDM"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchCTF',DefaultGameSettingsClass=class'UTGame.UTGameSettingsCTF',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchCTF"))
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchVCTF',DefaultGameSettingsClass=class'UTGame.UTGameSettingsVCTF',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchVCTF"))	
}
