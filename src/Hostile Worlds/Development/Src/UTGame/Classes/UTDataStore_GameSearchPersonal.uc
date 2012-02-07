/**
 * This specialized online game search data store provides the UI access to the search query and results for specific
 * servers that the player wishes to query.  It is aware of the main game search data store, and ensures that the main
 * search data store is not busy before allowing any action to take place.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDataStore_GameSearchPersonal extends UDKDataStore_GameSearchBase
	config(Game)
	abstract;

/**
 * reference to the main game search data store
 */
var	transient	UTDataStore_GameSearchDM	PrimaryGameSearchDataStore;

/** the maximum number of most recently visited servers that will be retained */
const MAX_PERSONALSERVERS=15;

/** the list of servers stored in this data store */
var	config	string		ServerUniqueId[MAX_PERSONALSERVERS];

/**
 * @param	bRestrictCheckToSelf	if TRUE, will not check related game search data stores for outstanding queries.
 *
 * @return	TRUE if a server list query was started but has not completed yet.
 */
function bool HasOutstandingQueries( optional bool bRestrictCheckToSelf )
{
	local bool bResult;

	bResult = Super.HasOutstandingQueries(bRestrictCheckToSelf);
	if ( !bResult && !bRestrictCheckToSelf && PrimaryGameSearchDataStore != None )
	{
		bResult = PrimaryGameSearchDataStore.HasOutstandingQueries(true);
	}

	return bResult;
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
	local int i;
	local string QueryString;
	local UTGameSearchPersonal HistorySearch;
	local array<string> HistoryList;

	HistorySearch = UTGameSearchPersonal(Search);
	if ( HistorySearch != None )
	{
		GetServerStringList(HistoryList);

		// alter the query - remove all filters then add the list of the recently visited servers.
		for ( i = 0; i < HistoryList.Length; i++ )
		{
			if ( QueryString != "" )
			{
				QueryString $= "OR";
			}

			QueryString $= "(OwningPlayerId=" $ HistoryList[i] $ ")";
		}

		Search.AdditionalSearchCriteria = QueryString;
	}

	if ( QueryString == "" )
	{
		// if we don't have any servers in our history yet, just submit a query which is guaranteed to fail.
		Search.AdditionalSearchCriteria = "(OwningPlayerId=1)";
	}

	return false;
}

/**
 * Retrieve the name of the currently logged in profile.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 *
 * @return	the name of the currently logged in player.
 */
function string GetPlayerName( optional int ControllerId=0 )
{
	local string Result;
	local OnlinePlayerInterface PlayerInt;

	PlayerInt = OnlineSub.PlayerInterface;
	if ( PlayerInt != None )
	{
		Result = PlayerInt.GetPlayerNickname(ControllerId);
	}

	return Result;
}

/**
 * Retrieve the UniqueNetId for the currently logged in player.
 *
 * @param	out_PlayerId	receives the value of the logged in player's UniqueNetId
 * @param	ControllerId	the index of the controller associated with the logged in player.
 *
 * @return	TRUE if the logged in player's UniqueNetId was successfully retrieved.
 */
function bool GetPlayerNetId( out UniqueNetId out_PlayerId, optional int ControllerId=0  )
{
	local bool bResult;
	local OnlinePlayerInterface PlayerInt;

	PlayerInt = OnlineSub.PlayerInterface;
	if ( PlayerInt != None )
	{
		bResult = PlayerInt.GetUniquePlayerId(ControllerId, out_PlayerId);
	}

	return bResult;
}

/**
 * Find the index [into the server history list] of the specified server.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 * @param	IdToFind		the UniqueNetId for the server to find
 *
 * @return	the index [into the server history list] for the specified server
 */
function int FindServerIndexByString( int ControllerId, string IdToFind )
{
	local int i, Result;

	Result = INDEX_NONE;
	for ( i = 0; i < MAX_PERSONALSERVERS; i++ )
	{
		if ( ServerUniqueId[i] == IdToFind )
		{
			Result = i;
			break;
		}
	}

	return Result;
}

/**
 * Find the index [into the server history list] of the specified server.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 * @param	IdToFind		the UniqueNetId for the server to find
 *
 * @return	the index [into the server history list] for the specified server
 */
function int FindServerIndexById( int ControllerId, const out UniqueNetId IdToFind )
{
	return FindServerIndexByString(ControllerId, class'Engine.OnlineSubsystem'.static.UniqueNetIdToString(IdToFind));
}

/**
 * Add a server to the server history list.  Places the server at position 0; if the server already exists in the list
 * elsewhere, it is moved to position 0.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 * @param	IdToFind		the UniqueNetId for the server to add
 */
function bool AddServer( int ControllerId, UniqueNetId IdToAdd )
{
	local int i, CurrentIndex;
	local string UniqueIdString;
	local bool bResult;

	// first, determine whether the server is already in our list
	UniqueIdString = class'Engine.OnlineSubsystem'.static.UniqueNetIdToString(IdToAdd);
	CurrentIndex = FindServerIndexByString(ControllerId, UniqueIdString);
	if ( CurrentIndex == INDEX_NONE )
	{
		CurrentIndex = MAX_PERSONALSERVERS - 1;
	}

	// if this server is already at position 0, leave it there
	if ( CurrentIndex != 0 )
	{
		for ( i = CurrentIndex; i > 0; i-- )
		{
			ServerUniqueId[i] = ServerUniqueId[i - 1];
		}

		ServerUniqueId[0] = UniqueIdString;
		SaveConfig();
		bResult = true;

		InvalidateCurrentSearchResults();
	}

	return bResult;
}

/**
 * Removes the specified server from the server history list.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 * @param	IdToRemove		the UniqueNetId for the server to remove
 */
function bool RemoveServer( int ControllerId, UniqueNetId IdToRemove )
{
	local int i, CurrentIndex;
	local bool bResult;

	// first, determine whether the server is already in our list
	CurrentIndex = FindServerIndexById(ControllerId, IdToRemove);
	if ( CurrentIndex != INDEX_NONE )
	{
		for ( i = CurrentIndex + 1; i < MAX_PERSONALSERVERS; i++ )
		{
			ServerUniqueId[i - 1] = ServerUniqueId[i];
		}

		// now clear the last element
		ServerUniqueId[MAX_PERSONALSERVERS-1] = "";
		SaveConfig();
		bResult = true;

		InvalidateCurrentSearchResults();
	}

	return bResult;
}

/**
 * Retrieve the list of most recently visited servers.
 *
 * @param	out_ServerList	receives the list of UniqueNetIds for the most recently visited servers.
 */
function GetServerIdList( out array<UniqueNetId> out_ServerList )
{
	local int i;
	local UniqueNetId ServerNetId;

	out_ServerList.Length = MAX_PERSONALSERVERS;
	for ( i = 0; i < MAX_PERSONALSERVERS; i++ )
	{
		if ( ServerUniqueId[i] == ""
		||	!class'Engine.OnlineSubsystem'.static.StringToUniqueNetId(ServerUniqueId[i], ServerNetId) )
		{
			out_ServerList.Length = i;
			break;
		}

		out_ServerList[i] = ServerNetId;
	}
}
function GetServerStringList( out array<string> out_ServerList )
{
	local int i;

	out_ServerList.Length = MAX_PERSONALSERVERS;
	for ( i = 0; i < MAX_PERSONALSERVERS; i++ )
	{
		if ( ServerUniqueId[i] == "" )
		{
			out_ServerList.Length = i;
			break;
		}

		out_ServerList[i] = ServerUniqueId[i];
	}
}


DefaultProperties
{
	Tag=UTGameSearchPersonal

	GameSearchCfgList.Empty
}
