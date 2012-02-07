/**
 * This specialized online game search data store provides the UI access to the search query and results for the player's
 * most recently visited servers.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDataStore_GameSearchHistory extends UTDataStore_GameSearchPersonal;

var			class<UTDataStore_GameSearchFavorites>	FavoritesGameSearchDataStoreClass;

/** Reference to the search data store that handles the player's list of favorite servers */
var	transient	UTDataStore_GameSearchFavorites		FavoritesGameSearchDataStore;

event Registered( LocalPlayer PlayerOwner )
{
	local DataStoreClient DSClient;

	Super.Registered(PlayerOwner);

	DSClient = GetDataStoreClient();
	if ( DSClient != None )
	{
		// now create the game history data store
		if ( FavoritesGameSearchDataStoreClass == None )
		{
			FavoritesGameSearchDataStoreClass = class'UTGame.UTDataStore_GameSearchFavorites';
		}

		FavoritesGameSearchDataStore = DSClient.CreateDataStore(FavoritesGameSearchDataStoreClass);
		if ( FavoritesGameSearchDataStore != None )
		{
			FavoritesGameSearchDataStore.HistoryGameSearchDataStore = Self;
			FavoritesGameSearchDataStore.PrimaryGameSearchDataStore = PrimaryGameSearchDataStore;

			// and register it
			DSClient.RegisterDataStore(FavoritesGameSearchDataStore, PlayerOwner);
		}
	}
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
	if ( !bResult && !bRestrictCheckToSelf && FavoritesGameSearchDataStore != None )
	{
		bResult = FavoritesGameSearchDataStore.HasOutstandingQueries(true);
	}

	return bResult;
}


DefaultProperties
{
	Tag=UTGameHistory
	FavoritesGameSearchDataStoreClass=class'UTGame.UTDataStore_GameSearchFavorites'
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchPersonal',DefaultGameSettingsClass=class'UTGame.UTGameSettingsPersonal',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchHistory"))
}
