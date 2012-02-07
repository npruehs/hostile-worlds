/**
 * This data store class provides query and search results for the "Favorites" page.  In functionality, it's essentially
 * the same as the history data store - just stores a different list of servers.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDataStore_GameSearchFavorites extends UTDataStore_GameSearchPersonal;

var	transient	UTDataStore_GameSearchHistory	HistoryGameSearchDataStore;

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
	}

	return bResult;
}

DefaultProperties
{
	Tag=UTGameFavorites
	GameSearchCfgList.Add((GameSearchClass=class'UTGame.UTGameSearchPersonal',DefaultGameSettingsClass=class'UTGame.UTGameSettingsPersonal',SearchResultsProviderClass=class'UTGame.UTUIDataProvider_SearchResult',SearchName="UTGameSearchFavorites"))
}
