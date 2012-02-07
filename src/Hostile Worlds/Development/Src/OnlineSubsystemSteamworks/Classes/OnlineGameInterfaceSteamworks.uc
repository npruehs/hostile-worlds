/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Class that implements the Steamworks specific functionality
 */
class OnlineGameInterfaceSteamworks extends OnlineGameInterfaceImpl within OnlineSubsystemCommonImpl
	native
	config(Engine);

cpptext
{
	/** Cleanup stuff that happens outside of uobject's view. */
	virtual void FinishDestroy();

	/** Shut down all Steam HServerQuery handles that might be in-flight. */
	void CancelAllQueries();

	/** Handles updating of any async tasks that need to be performed */
	void Tick(FLOAT DeltaTime);

	/** Bridge from ISteamMatchmakingServerListResponse (glue object that bridges to here is this->ServerListResponse). */
	void ServerResponded(int iServer);
	void ServerFailedToRespond(int iServer);
	void RefreshComplete(EMatchMakingServerResponse Response);

	/** Bridge from ISteamMatchmakingRulesResponse (glue class that bridges to here is SteamRulesResponse). */
	void RulesResponded(SteamRulesResponse *RulesResponse, const char *pchRule, const char *pchValue);
	void RulesFailedToRespond(SteamRulesResponse *RulesResponse);
	void RulesRefreshComplete(SteamRulesResponse *RulesResponse);

	/** Clean up a query mapped in QueryToRulesResponseMap. */
	void CancelSteamRulesQuery(SteamRulesResponse *RulesResponse, const UBOOL bCancel);

	/** Bridge from ISteamMatchmakingPingResponse (glue class that bridges to here is SteamPingResponse). */
	void UpdatePing(SteamPingResponse *PingResponse, const INT Ping);
	void PingServerResponded(SteamPingResponse *PingResponse, const gameserveritem_t &server);
	void PingServerFailedToRespond(SteamPingResponse *PingResponse);

	/** Clean up a query mapped in QueryToPingResponseMap. */
	void CancelSteamPingQuery(SteamPingResponse *PingResponse, const UBOOL bCancel);

	/** Add server to search results. */
	void AddServerToSearchResults(const gameserveritem_t *Server, const INT SteamIndex);

	/** Updates the server details with the new data */
	void UpdateGameSettingsData(UOnlineGameSettings* GameSettings, const SteamRulesMap &Rules);

	/** Marks a server in the server list as unreachable */
	void MarkServerAsUnreachable(const FInternetIpAddr& Addr);

	/** Frees the current server browser query and marks the search as done */
	void CleanupServerBrowserQuery(const UBOOL bCancel);

	/** Returns TRUE if the game wants stats, FALSE if not */
	UBOOL GameWantsStats();

	/** Returns TRUE if Game Server init succeeded, FALSE if not */
	UBOOL PublishSteamServer(const EServerMode ServerMode);

	/** Returns TRUE if we could start the LAN beacon, FALSE if not */
	UBOOL StartSteamLanBeacon();

	/** Clean up a previously started LAN beacon. */
	void StopSteamLanBeacon();

	/** Do some paperwork when Steam tells us the server policy. */
	void OnGSPolicyResponse(const UBOOL bIsVACSecured);

	/** overridden from superclass. */
	UBOOL FindOnlineGames(BYTE SearchingPlayerNum,UOnlineGameSearch* SearchSettings);
	DWORD FindInternetGames();
	DWORD FindLanGames();
	UBOOL CancelFindOnlineGames();
	DWORD CancelFindInternetGames();
	DWORD CancelFindLanGames();
	void RefreshPublishedGameSettings();
	UBOOL CreateOnlineGame(BYTE HostingPlayerNum,FName SessionName,UOnlineGameSettings* NewGameSettings);
	DWORD CreateInternetGame(BYTE HostingPlayerNum);
	DWORD CreateLanGame(BYTE HostingPlayerNum);
	UBOOL JoinOnlineGame(BYTE PlayerNum,FName SessionName,const FOnlineGameSearchResult& DesiredGame);
	DWORD JoinInternetGame(BYTE PlayerNum);
	UBOOL StartOnlineGame(FName SessionName);
	DWORD StartInternetGame();
	UBOOL EndOnlineGame(FName SessionName);
	DWORD EndInternetGame();
	UBOOL DestroyOnlineGame(FName SessionName);
	DWORD DestroyInternetGame();
	DWORD DestroyLanGame();
	void TickLanTasks(FLOAT DeltaTime);
	void TickInternetTasks(FLOAT DeltaTime);
	void SetInviteInfo(const TCHAR* LocationString);
	void RegisterLocalTalkers();
	void UnregisterLocalTalkers();
	DWORD ReadPlatformSpecificInternetSessionInfo(const FOnlineGameSearchResult& DesiredGame,BYTE PlatformSpecificInfo[64]);
	DWORD BindPlatformSpecificSessionToInternetSearch(BYTE SearchingPlayerNum,UOnlineGameSearch* SearchSettings,BYTE* PlatformSpecificInfo);
}

/** Maps a Steam HServerQuery to a Steam server rules callback object. */
struct native ServerQueryToRulesResponseMapping
{
	/** The Steam query handle */
	var int Query;
	/** The Steam callback object */
	var native pointer Response{SteamRulesResponse};
};

/** Stores in-progress Steam query handles. */
var array<ServerQueryToRulesResponseMapping> QueryToRulesResponseMap;

/** Maps a Steam HServerQuery to a Steam server rules callback object. */
struct native ServerQueryToPingResponseMapping
{
	/** The Steam query handle */
	var int Query;
	/** The Steam callback object */
	var native pointer Response{SteamPingResponse};
};

/** Stores in-progress Steam query handles. */
var array<ServerQueryToPingResponseMapping> QueryToPingResponseMap;

/** Provides callbacks when there are master server results. */
var const native transient pointer ServerListResponse{SteamServerListResponse};

/** The type of server search we're doing at the moment. */
enum ESteamMatchmakingType
{
	SMT_Invalid,
	SMT_LAN,
	SMT_Internet
};

/** The kind of server search in progress */
var ESteamMatchmakingType CurrentMatchmakingType;

/** Handle to in-progress Steam server query. */
var const native transient pointer CurrentMatchmakingQuery{void};

/** The list of delegates to notify when a game invite is accepted */
var array<delegate<OnGameInviteAccepted> > GameInviteAcceptedDelegates;

/** Game game settings associated with this invite */
var const private OnlineGameSearch InviteGameSearch;

/** The last invite's URL information */
var const private string InviteLocationUrl;

/** This is the list of requested delegates to fire when complete */
var array<delegate<OnRegisterPlayerComplete> > RegisterPlayerCompleteDelegates;

/** This is the list of requested delegates to fire when complete */
var array<delegate<OnUnregisterPlayerComplete> > UnregisterPlayerCompleteDelegates;

/**
 * Updates the localized settings/properties for the game in question
 *
 * @param SessionName the name of the session to update
 * @param UpdatedGameSettings the object to update the game settings with
 * @param bShouldRefreshOnlineData whether to submit the data to the backend or not
 *
 * @return true if successful creating the session, false otherwsie
 */
native function bool UpdateOnlineGame(name SessionName,OnlineGameSettings UpdatedGameSettings,optional bool bShouldRefreshOnlineData = false);

/**
 * Sets the delegate used to notify the gameplay code when a game invite has been accepted
 *
 * @param LocalUserNum the user to request notification for
 * @param GameInviteAcceptedDelegate the delegate to use for notifications
 */
function AddGameInviteAcceptedDelegate(byte LocalUserNum,delegate<OnGameInviteAccepted> GameInviteAcceptedDelegate)
{
	if (GameInviteAcceptedDelegates.Find(GameInviteAcceptedDelegate) == INDEX_NONE)
	{
		GameInviteAcceptedDelegates[GameInviteAcceptedDelegates.Length] = GameInviteAcceptedDelegate;
	}
}

/**
 * Removes the specified delegate from the notification list
 *
 * @param LocalUserNum the user to request notification for
 * @param GameInviteAcceptedDelegate the delegate to use for notifications
 */
function ClearGameInviteAcceptedDelegate(byte LocalUserNum,delegate<OnGameInviteAccepted> GameInviteAcceptedDelegate)
{
	local int RemoveIndex;

	RemoveIndex = GameInviteAcceptedDelegates.Find(GameInviteAcceptedDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		GameInviteAcceptedDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Called when a user accepts a game invitation. Allows the gameplay code a chance
 * to clean up any existing state before accepting the invite. The invite must be
 * accepted by calling AcceptGameInvite() on the OnlineGameInterface after clean up
 * has completed
 *
 * @param InviteResult the search/settings for the game we're joining via invite
 */
delegate OnGameInviteAccepted(const out OnlineGameSearchResult InviteResult);

/**
 * Tells the online subsystem to accept the game invite that is currently pending
 *
 * @param LocalUserNum the local user accepting the invite
 * @param SessionName the name of the session this invite is to be known as
 *
 * @return true if the game invite was able to be accepted, false otherwise
 */
native function bool AcceptGameInvite(byte LocalUserNum,name SessionName);

/**
 * Registers a player with the online service as being part of the online game
 *
 * @param SessionName the name of the session the player is joining
 * @param UniquePlayerId the player to register with the online service
 * @param bWasInvited whether the player was invited to the game or searched for it
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool RegisterPlayer(name SessionName,UniqueNetId PlayerId,bool bWasInvited);

/**
 * Delegate fired when the registration process has completed
 *
 * @param SessionName the name of the session the player joined or not
 * @param PlayerId the player that was unregistered from the online service
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnRegisterPlayerComplete(name SessionName,UniqueNetId PlayerId,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the player
 * registration request they submitted has completed
 *
 * @param RegisterPlayerCompleteDelegate the delegate to use for notifications
 */
function AddRegisterPlayerCompleteDelegate(delegate<OnRegisterPlayerComplete> RegisterPlayerCompleteDelegate)
{
	if (RegisterPlayerCompleteDelegates.Find(RegisterPlayerCompleteDelegate) == INDEX_NONE)
	{
		RegisterPlayerCompleteDelegates[RegisterPlayerCompleteDelegates.Length] = RegisterPlayerCompleteDelegate;
	}
}

/**
 * Removes the specified delegate from the notification list
 *
 * @param RegisterPlayerCompleteDelegate the delegate to use for notifications
 */
function ClearRegisterPlayerCompleteDelegate(delegate<OnRegisterPlayerComplete> RegisterPlayerCompleteDelegate)
{
	local int RemoveIndex;

	RemoveIndex = RegisterPlayerCompleteDelegates.Find(RegisterPlayerCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		RegisterPlayerCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Unregisters a player with the online service as being part of the online game
 *
 * @param SessionName the name of the session the player is leaving
 * @param PlayerId the player to unregister with the online service
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool UnregisterPlayer(name SessionName,UniqueNetId PlayerId);

/**
 * Delegate fired when the unregistration process has completed
 *
 * @param SessionName the name of the session the player left
 * @param PlayerId the player that was unregistered from the online service
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnUnregisterPlayerComplete(name SessionName,UniqueNetId PlayerId,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the player
 * Unregistration request they submitted has completed
 *
 * @param UnregisterPlayerCompleteDelegate the delegate to use for notifications
 */
function AddUnregisterPlayerCompleteDelegate(delegate<OnUnregisterPlayerComplete> UnregisterPlayerCompleteDelegate)
{
	if (UnregisterPlayerCompleteDelegates.Find(UnregisterPlayerCompleteDelegate) == INDEX_NONE)
	{
		UnregisterPlayerCompleteDelegates[UnregisterPlayerCompleteDelegates.Length] = UnregisterPlayerCompleteDelegate;
	}
}

/**
 * Removes the specified delegate from the notification list
 *
 * @param UnregisterPlayerCompleteDelegate the delegate to use for notifications
 */
function ClearUnregisterPlayerCompleteDelegate(delegate<OnUnregisterPlayerComplete> UnregisterPlayerCompleteDelegate)
{
	local int RemoveIndex;

	RemoveIndex = UnregisterPlayerCompleteDelegates.Find(UnregisterPlayerCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		UnregisterPlayerCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Fetches the additional data a session exposes outside of the online service.
 * NOTE: notifications will come from the OnFindOnlineGamesComplete delegate
 *
 * @param StartAt the search result index to start gathering the extra information for
 * @param NumberToQuery the number of additional search results to get the data for
 *
 * @return true if the query was started, false otherwise
 */
function bool QueryNonAdvertisedData(int StartAt,int NumberToQuery)
{
	`Log("Ignored on Steamworks");  // ignored on Live, too.
	return false;
}

