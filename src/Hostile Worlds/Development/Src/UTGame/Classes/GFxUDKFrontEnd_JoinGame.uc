/**********************************************************************

Filename    :   GFxUDKFrontEnd_JoinGame.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of a join game/server browser.

                Associated Flash content: udk_instant_action.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_JoinGame extends GFxUDKFrontEnd_Screen;

/** Constants that define the server type of online game being searched for. */
const SERVERBROWSER_SERVERTYPE_LAN		= 0;
const SERVERBROWSER_SERVERTYPE_UNRANKED	= 1;	//	for platforms which do not support ranked matches, represents a normal internet match.
const SERVERBROWSER_SERVERTYPE_RANKED	= 2;	// only valid on platforms which support ranked matches

/** Reference to the search datastore. */
var transient UDKDataStore_GameSearchBase	SearchDataStore;

/** Reference to the string list datastore. */
var transient UTUIDataStore_StringList		StringListDataStore;

/** Reference to the game search datastore. */
var transient UTDataStore_GameSearchDM      SearchDMDataStore;

var transient array<OnlineGameSearchResult> ServerInfoList;

/** Reference to the menu item datastore. */
var transient UTUIDataStore_MenuItems		MenuItemDataStore;

/** Cached online subsystem pointer */
var transient OnlineSubsystem				OnlineSub;

/** Cached game interface pointer */
var transient OnlineGameInterface			GameInterface;

/** Indicates that the current gametype was changed externally - submit a new query when possible */
var	private transient bool					bGametypeOutdated, bSpectate;

var private transient bool                  bIssuedInitialQuery;

var	protected	transient	const	name	SearchDSName;

/** Reference to the "Please enter a password." dialog's MovieClip. */
var private transient GFxUDKFrontEnd_PasswordDialog PasswordDialog;

/** Reference to the Join Server dialog's MovieClip. */
var private transient GFxUDKFrontEnd_JoinDialog     JoinDialogMC; 

/** Is an informative dialog about the server browser currently displayed. */
var private transient bool                  bQueryDialogShowing;

/** Is the join dialog (shown after a server is clicked) currently displayed. */
var private transient bool                  bJoinDialogShowing;

/** Indicates that we're currently processing a join request; prevents user from triggering multiple join requests at once */
var private transient bool bProcessingJoin;

/**
 * Different actions to take when a query completes.
 */
var private transient enum EQueryCompletionAction
{
	/** no query action set */
	QUERYACTION_None,

	/** do nothing when the query completes; default behavior */
	QUERYACTION_Default,

	/**
	 * This is set when the user wants to close the scene but we still have active queries.  When the queries are completed
	 * (either through being cancelled or receiving all results), close the scene.
	 */
	QUERYACTION_CloseScene,

	/**
	 * This is set when the user has chosen a server from the list.  When the queries are completed or cancelled, join the currently selected server.
	 */
	QUERYACTION_JoinServer,

	/**
	 * This is set when the user switches from LAN to Internet or vice versa.  When the queries are completed of cancelled, clear all results and reissue the
	 * current query.
	 */
	QUERYACTION_RefreshAll,

} QueryCompletionAction;

/** stores the password entered by the user when attempting to connect to a server with a password */
var private transient string		ServerPassword;

/** Keeps track of which servers need to have full details read from */
var private int LastServerAdded;

var array<UDKUIDataProvider_SearchResult> ServerListData;

/** Reference to the Menu MovieClip, used for open/clsoe animations. */
var GFxObject MenuMC;

/** Reference to the list. */
var GFxClikWidget ServerListMC;

/** Reference to the Refresh button. */
var GFxClikWidget RefreshBtn;

/** Reference to the header bar at the top of the server list. */
var GFxObject HeaderBarMC;

/** Reference to the flags button of the header  bar which sorts based on the number of flags. */
var GFxClikWidget FlagsHeaderBtn;

/** Reference to the server button of the header bar which sorts the list based on the name of the server. */
var GFxClikWidget ServerHeaderBtn;

/** Reference to the map button of the header bar which sorts the list based on the name of the map. */
var GFxClikWidget MapHeaderBtn;

/** Reference to the players button of the header bar which sorts the list based on the number of players. */
var GFxClikWidget PlayersHeaderBtn;

/** Reference to the ping button of the header bar which sorts the list based on the server's ping. */
var GFxClikWidget PingHeaderBtn; 

/** Reference to the "Match Type" text on the filter button. */
var GFxObject FilterMatchTypeTxt;

/** Reference to the "Game Mode" text on the filter button. */
var GFxObject FilterGameModeTxt;

/** Reference to the "Servers Received:" and "Refreshing.." text field beside the server count. */
var GFxObject StatusTxt;

/** Reference to the loading ticker which is visible and plays when the server browser is refreshing. */
var GFxObject LoadingTickerMC;

/** Reference to the server count text field at the bottom left which displays the number of servers received. */
var GFxObject ServerCountTxt;

/** Reference to the filter button at the top of the view which can be used to bring up the filter dialog. */
var GFxClikWidget FilterBtn;

/** 
 * Global variable to keep track of which item is currently selected in the list. Necessary due to the way mouse
 * rollOver gives focus. Child dialogs will be populated with data based on this index.
 */
var int SelectedIndex;

/** Space for updating and configuring the screen. Currently unused. */
function OnViewLoaded()
{
   	local DataStoreClient DSClient;

    Super.OnViewLoaded();

	// Get a reference to the datastore we are working with.
	// @todo: This should probably come from the list.
	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		SearchDataStore = UDKDataStore_GameSearchBase(DSClient.FindDataStore(SearchDSName));
		StringListDataStore = UTUIDataStore_StringList(DSClient.FindDataStore('UTStringList'));
		MenuItemDataStore = UTUIDataStore_MenuItems(DSClient.FindDataStore('UTMenuItems'));
	}

    // Store a reference to the game interface
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		GameInterface = OnlineSub.GameInterface;
	}   
}

function OnViewActivated()
{        
	// Default to LAN.
    class'UIRoot'.static.SetDataStoreStringValue("<Registry:LanClient>", "1");

	FlagsHeaderBtn.SetString("label", "FLAGS");
	ServerHeaderBtn.SetString("label", "SERVER NAME");
	MapHeaderBtn.SetString("label", "MAP");
	PlayersHeaderBtn.SetString("label", "PLAYERS");
	PingHeaderBtn.SetString("label", "PING");

	// Sorting by header is unimplemented, so disable these buttons for now.
	FlagsHeaderBtn.SetBool("disabled", TRUE);
	ServerHeaderBtn.SetBool("disabled", TRUE);
	MapHeaderBtn.SetBool("disabled", TRUE);
	PlayersHeaderBtn.SetBool("disabled", TRUE);
	PingHeaderBtn.SetBool("disabled", TRUE);

    // Decide whether we're playing LAN or Online and set MatchType appropriately.
    ValidateServerType();     
    UseLANMode();

    // Check whether the gametype is outdated / hasn't been set.
	if ( bGametypeOutdated )
	{
		NotifyGameTypeChanged();
		bGametypeOutdated = FALSE;
	}

    // Push an initial query when the page is first activated.
    if ( !bIssuedInitialQuery )
	{
		bIssuedInitialQuery = TRUE;
		RefreshServerList(FakePlayerIndex);
	}    

	// FilterBtn.SetBool("disabled", TRUE);

    // Update the list's data provider.
	UpdateFilterButton();
    UpdateListDataProvider();    
    UpdateServerCount();
}

/** 
 *  Update the view.  
 *  This method is called whenever the view is pushed or popped from the view stakc.
 */
function OnTopMostView(optional bool bPlayOpenAnimation = false)
{
    Super.OnTopMostView(bPlayOpenAnimation);     

    MenuManager.SetSelectionFocus(RefreshBtn);
    UpdateFilterButton();
}

/** Cleanup method called by the MenuManager when the view is closed. */
function OnViewClosed()
{
    Cleanup();
}

/** Enable/disable sub-components of the view. */
function DisableSubComponents(bool bDisableComponents)
{
    ServerListMC.SetBool("disabled", bDisableComponents);    
    BackBtn.SetBool("disabled", bDisableComponents);
    RefreshBtn.SetBool("disabled", bDisableComponents);
	// @todo sf: If the filters functionality still works, enable this button.
	// FilterBtn.SetBool("disabled", bDisableComponents);
}

/**
 * Enables / disables the "match type" control based on whether we are signed in online.
 */
function ValidateServerType()
{
	local int PlayerIndex, PlayerControllerID;
	
	// find the "MatchType" control (contains the "LAN" and "Internet" options);  if we aren't signed in online,
	// don't have a link connection, or not allowed to play online, don't allow them to select one.	    
	PlayerIndex = GetPlayerIndex();
	PlayerControllerID = GetPlayerControllerId( PlayerIndex );
    if ( !IsLoggedIn(PlayerControllerID, true) )
	{
		ForceLANOption(PlayerIndex);
	}
}

/** Forces "LAN" to be selected in the case that the user is not online. Updates buttons/textFields appropriately. */
final function ForceLANOption( int PlayerIndex )
{
	local int ValueIndex;
	local name MatchTypeName;	
	
	MatchTypeName = class'UIRoot'.static.IsConsole(CONSOLE_XBox360) ? 'MatchType360' : 'MatchType';
	ValueIndex = StringListDataStore.GetCurrentValueIndex(MatchTypeName);
	if ( ValueIndex != SERVERBROWSER_SERVERTYPE_LAN )
	{
		// make sure the "LAN" option is selected
		StringListDataStore.SetCurrentValueIndex(MatchTypeName, SERVERBROWSER_SERVERTYPE_LAN);
		UpdateFilterButton();
	}

	// LAN queries show all gametypes, so switch to "DeathMatch" so that search results are always in the same place
	ValueIndex = MenuItemDataStore.FindValueInProviderSet('GameModeFilter', 'GameSearchClass', "UTGameSearchDM");
	if ( ValueIndex != INDEX_NONE && MenuItemDataStore.GameModeFilter != ValueIndex )
	{
		MenuItemDataStore.GameModeFilter = ValueIndex;		
		SearchDataStore.SetCurrentByName('UTGameSearchDM', true);
	}

	// use the accessor so that if the match or server type options are selected, we select the next possible one
	//GameTypeOption = FindChild('GameModeFilter', true);
		
	//OptionList.EnableItem(PlayerIndex, ServerTypeOption, false);
	//OptionList.EnableItem(PlayerIndex, GameTypeOption, false);
}

/**
 * Called when the owning scene is being closed - provides a hook for the tab page to ensure it's cleaned up all external
 * references (i.e. delegates, etc.)
 * @todo sf: This is called OnViewClosed, but the view isn't truly closed when the user jumps into a game. Tried adding
 *			 just before the ProcessJoin() is called, but doesn't seem to prevent the "Failed to cleanup online subsystem error".
 */
function Cleanup()
{
	`assert(QueryCompletionAction == QUERYACTION_None);
	if ( GameInterface != None )
	{	
		GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
	}

	// if we're leaving the server browser area - clear all stored server query searches
	if ( SearchDataStore != None )
	{
		SearchDataStore.ClearAllSearchResults();
	}
}

final function UpdateFilterButton()
{
    local int DesiredMatchType;
    local string FilterMatchType;
    local string FilterGameMode;    
	
    DesiredMatchType = GetDesiredMatchType();	
    switch (DesiredMatchType)
    {
        case (SERVERBROWSER_SERVERTYPE_LAN):
            FilterMatchType = "LAN";
            break;
        case (SERVERBROWSER_SERVERTYPE_UNRANKED):
            FilterMatchType = "Internet";
            break;
        case (SERVERBROWSER_SERVERTYPE_RANKED):
            FilterMatchType = "Ranked";
            break;
        default:
            // This should never be reached, but just in case.
            FilterMatchType = "Unknown";
            break;
    }

    class'UIRoot'.static.GetDataStoreStringValue("<UTMenuItems:GameModeFilterClass>", FilterGameMode);
	FilterMatchTypeTxt.SetText(FilterMatchType);

	if (FilterGameMode == "")
	{
		class'UIRoot'.static.GetDataStoreStringValue("<UTGameSettings:CustomGameMode>", FilterGameMode);
		FilterGameMode = class'GFxUDKFrontEnd_LaunchGame'.static.GetGameModeFriendlyString(FilterGameMode);
	}

	FilterGameModeTxt.SetText(FilterGameMode);
}

/**
 * Retrieve the index in the game search data store's list of search results for the specified gametype class
 *
 * @param	GameClassName	the path name of the gametype to find; if not specified, uses the currently selected gametype
 *
 * @return	the index into the UIDataStore_OnlineGameSearch's GameSearchCfgList array for the gametype specified.
 */
function int GetGameTypeSearchProviderIndex( optional string GameClassName )
{
	local int ProviderIdx;
	local string SearchTag;

	ProviderIdx = INDEX_NONE;
	if ( GameClassName == "" )
	{
		// if no gametype was specified, use the currently selected gametype
		class'UIRoot'.static.GetDataStoreStringValue("<UTGameSettings:CustomGameMode>", GameClassName);
	}

	if ( GameClassName != "" && MenuItemDataStore != None && SearchDataStore != None )
	{		
		// in order to find the search datastore index for the gametype, we need to get its search tag.  This comes from
		// the menu items data store (for some reason)
		// first, find the location of this gametype in the UTMenuItems data store's list of gametypes
		ProviderIdx = MenuItemDataStore.FindValueInProviderSet('GameModeFilter', 'GameMode', GameClassName);

		// now that we know the index into the UTMenuItems data store, we can retrieve the tag that is used to identify the corresponding
		// game search configuration in the Game Search data store.
		if (ProviderIdx != INDEX_NONE
		&&	MenuItemDataStore.GetValueFromProviderSet('GameModeFilter', 'GameSearchClass', ProviderIdx, SearchTag)
		&&	SearchTag != "")
		{
			ProviderIdx = SearchDataStore.FindSearchConfigurationIndex(name(SearchTag));
		}
		else
		{
			ProviderIdx = INDEX_NONE;
		}
	}

	return ProviderIdx;
}

/**
 * Called when the user changes the currently selected gametype via the gametype combo.
 * 
 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
function OnGameTypeChanged( optional int PlayerIndex )
{
	local int ProviderIdx;	
	local string GameTypeClassName;
	
	// Retrieve said value.
	class'UIRoot'.static.GetDataStoreStringValue("<UTGameSettings:CustomGameMode>", GameTypeClassName);

	if (GameTypeClassName != "")
	{
		// Find the index into the UTMenuItems data store for the gametype with the specified class name
		ProviderIdx = GetGameTypeSearchProviderIndex(GameTypeClassName);
		`Log(`location@"- Game mode filter class set to" @ GameTypeClassName @ "(" $ ProviderIdx $ ")");

		if ( ProviderIdx != INDEX_NONE )
		{
			MenuItemDataStore.GameModeFilter = ProviderIdx;

			// Update the online game search data store's current gametype
			SearchDataStore.SetCurrentByIndex(ProviderIdx, false);
			ConditionalRefreshServerList(PlayerIndex);
		}
	}
}

/**
 * Refreshes the server list by submitting a new query if certain conditions are met.
 */
function ConditionalRefreshServerList( int PlayerIndex )
{
	local bool bHasExistingResults, bHasOutstandingQueries;

	bHasExistingResults = SearchDataStore.HasExistingSearchResults();
	bHasOutstandingQueries = SearchDataStore.HasOutstandingQueries();

	// if we don't have any results for this gametype yet (either this is our first time switching to it or
	// we didn't find any servers last time) and we don't have an existing search pending, start a search using the new gametype.
	if ( !bHasExistingResults && !bHasOutstandingQueries )
	{
		// fire the query!
		RefreshServerList(PlayerIndex);
	}
	else
	{
		if ( bHasExistingResults )
		{
			// refresh the list with the items from the currently selected gametype's cached query
			UpdateListDataProvider();
		}

		// update the server count label with the number of servers received so far for this gametype
		UpdateServerCount();
	}
}


/**
 * Setup the server filter/browser for LAN mode
 */
function UseLANMode()
{
	MenuItemDataStore.FindValueInProviderSet('GameModeFilter', 'GameSearchClass', "UTGameSearchDM");
}

/**
 * Updates the enabled state of certain button bar buttons depending on whether a server is selected or not.
 */
function UpdateButtonStates()
{
	local bool bHasPendingSearches;

	bHasPendingSearches = SearchDataStore.HasOutstandingQueries();	
	
	RefreshBtn.SetBool("toggled", bHasPendingSearches);
	RefreshBtn.SetBool("disabled", bHasPendingSearches); // QueryCompletionAction==QUERYACTION_None?
	
    /*
	if ( GameTypeCombo != None )
	{
		GameTypeCombo.SetEnabled(!bHasPendingSearches && GetDesiredMatchType() != SERVERBROWSER_SERVERTYPE_LAN, PlayerIndex);
	}
    */	
}

/**
 * Displays a dialog to the user which allows him to enter the password for the currently selected server.
 */
private final function PromptForServerPassword()
{    
    if (MenuManager != none)
	{				
        PasswordDialog = GFxUDKFrontEnd_PasswordDialog(MenuManager.SpawnDialog('PasswordDialog'));    
        if (PasswordDialog != none)
        {
            PasswordDialog.SetOKButtonListener(OnPasswordDialog_OK);
        }
	}  
}

/**
 * The user has made a selection of the choices available to them.
 */
private final function OnPasswordDialog_OK(GFxClikWidget.EventData ev)
{
    local String Password; 
   
    Password = PasswordDialog.GetPassword();    		
	if ( Password != "" )
	{
		// strip out all
		ServerPassword = class'UTUIFrontEnd_HostGame'.static.StripInvalidPasswordCharacters(Password);
		ProcessJoin();
	}
	else
	{
		ServerPassword = "";
	}

    // MenuManager.PopDialogView();    
}

/**
 * Updates the server count label with the number of servers received so far for the currently selected gametype.
 */
function UpdateServerCount()
{    
	local int ServerCount;
	local OnlineGameSearch CurrentSearch;    

	if ( SearchDataStore != None )
	{
		CurrentSearch = SearchDataStore.GetCurrentGameSearch();
		if ( CurrentSearch != None )
		{
			ServerCount = CurrentSearch.Results.Length;
		}
	}

	class'UIRoot'.static.SetDataStoreStringValue("<SceneData:NumServersReceived>", string(ServerCount));	
    StatusTxt.SetText("SERVERS RECEIVED:");
    ServerCountTxt.SetText(string(ServerCount));
}


/**
 * Builds the string needed to join a game from the resolved connection:
 *		"open 172.168.0.1"
 *
 * NOTE: Overload this method to modify the URL before exec-ing it
 *
 * @param ResolvedConnectionURL the platform specific URL information
 *
 * @return the final URL to use to open the map
 */
function string BuildJoinURL(string ResolvedConnectionURL)
{
	local string ConnectURL;

	ConnectURL = "open " $ ResolvedConnectionURL;
	if ( ServerPassword != "" )
	{
		ConnectURL $= "?Password=" $ ServerPassword;
	}

	if ( bSpectate )
	{
		ConnectURL $= "?SpectatorOnly=1";
	}

	return ConnectURL;
}

/** Refreshes the server list. */
function RefreshServerList(int InPlayerIndex, optional int MaxResults=1000)
{
	local OnlineGameSearch GameSearch;
	local int ValueIndex;

    `log("GFx: RefreshServerList("@InPlayerIndex$", " $MaxResults @")");
	if ( !SearchDataStore.HasOutstandingQueries() )
	{
		// Play the refresh sound
		//PlayUISound('RefreshServers');

		// Get current filter from the string list datastore
		GameSearch = SearchDataStore.GetCurrentGameSearch();

		// Set max results
		GameSearch.MaxSearchResults = MaxResults;

		// Get the match type based on the platform.
		ValueIndex = GetDesiredMatchType();        
		switch(ValueIndex)
		{
		case SERVERBROWSER_SERVERTYPE_LAN:
			`Log(`location @ "- Searching for a LAN match.",,'DevOnline');
			GameSearch.bIsLanQuery=TRUE;
			GameSearch.bUsesArbitration=FALSE;
			break;

		case SERVERBROWSER_SERVERTYPE_RANKED:
			if ( class'UIRoot'.static.IsConsole(CONSOLE_XBox360) )
			{
				`Log(`location @ "- Searching for a ranked match.",,'DevOnline');
				GameSearch.bIsLanQuery=FALSE;
				GameSearch.bUsesArbitration=TRUE;
				break;
			}

			// falls through - platform doesn't support ranked matches.

		case SERVERBROWSER_SERVERTYPE_UNRANKED:
			`Log(`location @ "- Searching for an unranked match.",,'DevOnline');
			GameSearch.bIsLanQuery=FALSE;
			GameSearch.bUsesArbitration=FALSE;
			break;
		}

		SubmitServerListQuery(InPlayerIndex);
	}
}

/**
 * Submits a query for the list of servers which match the current configuration.
 */
function SubmitServerListQuery( int PlayerIndex )
{
	`log(`location@`showvar(SearchDataStore.HasOutstandingQueries(),QueryActive)@`showvar(SearchDataStore.HasExistingSearchResults(),ExistingResults),,'DevOnline');    

    // @todo sf: Not sure if this is necessary. Doesn't seem to have an effect if removed from UTUITabPanel_ServerBrowser.
    // I believe that this calls SaveSceneDataValues(false). See UTUIFrontEnd_JoinGame::PreSubmitQuery;
	//OnPrepareToSubmitQuery( Self );

	// Show the "refreshing" label   	
	SetRefreshing(true);

	// Add a delegate for when the search completes.  We will use this callback to do any post searching work.
	GameInterface.AddFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);

	// Start a search
	if ( !SearchDataStore.SubmitGameSearch(class'UIInteraction'.static.GetPlayerControllerId(PlayerIndex), false) )
	{
		SetRefreshing(false);
	}

	// update the server count label and button states while we're waiting for the query results
	UpdateServerCount();
	UpdateButtonStates();
}

/**
 * Delegate fired each time a new server is received, or when the action completes (if there was an error)
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnFindOnlineGamesCompleteDelegate(bool bWasSuccessful)
{
	local bool bSearchCompleted;    

	bSearchCompleted = !SearchDataStore.HasOutstandingQueries();
	`Log(`location @ `showvar(bWasSuccessful) @ `showvar(bSearchCompleted),,'DevOnline');

	SetRefreshing(false);

	// Update the server count label
	UpdateServerCount();        
	if ( bSearchCompleted )
	{
		// Clear delegate
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
		OnFindOnlineGamesComplete(bWasSuccessful);
	}

	// update the enabled state of the button bar buttons
	UpdateButtonStates();
    UpdateListDataProvider();
}

/**
 * Delegate fired when the search for an online game has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnFindOnlineGamesComplete(bool bWasSuccessful)
{	
	if ( QueryCompletionAction != QUERYACTION_None )
	{
		if ( bQueryDialogShowing )
		{
			MenuManager.PopView();
            bQueryDialogShowing = false;
		}
		else
		{
			OnCancelSearchComplete(true);
		}
	}    
	
    // refresh the list with the items from the currently selected gametype's cached query
    UpdateListDataProvider();
}

function int GetDesiredMatchType()
{
	// Get the match type based on the platform.
	return class'UIRoot'.static.IsConsole(CONSOLE_XBox360) 
			? StringListDataStore.GetCurrentValueIndex('MatchType360') 
			: StringListDataStore.GetCurrentValueIndex('MatchType');
}

function OnRefreshButtonPress(GFxClikWidget.EventData ev)
{    
    RefreshServerList(FakePlayerIndex);
    UpdateListDataProvider();
}

function OnFilterButtonPress(GFxClikWidget.EventData ev)
{
    local GFxUDKFrontEnd_FilterDialog FilterDialog;    
    FilterDialog = GFxUDKFrontEnd_FilterDialog(MenuManager.SpawnDialog('FilterDialog', self));
    FilterDialog.SetBackButtonListener(OnRefreshButtonPress);
    FilterDialog.OnSwitchedGameType = ServerFilterChangedGameType;
}

function ServerFilterChangedGameType()
{
	OnGameTypeChanged();
    NotifyGameTypeChanged();
}

function UpdateListDataProvider()
{   
    local byte i;
    local GFxObject DataProvider;
    local GFxObject TempObj;
    local OnlineGameSearch LatestGameSearch;
    local array<ASValue> args;
    local ASValue ASVal;
           
    ServerInfoList.Length = 0;    
    LatestGameSearch = SearchDataStore.GetActiveGameSearch();

	if (LatestGameSearch != none)
	{

		if (LatestGameSearch.Results.Length == 0)
		{                
			HeaderBarMC.SetBool("focusable", false);
			ServerListMC.SetBool("focusable", false);
			MenuManager.SetSelectionFocus(BackBtn);        
		}
		else 
		{
			HeaderBarMC.SetBool("focusable", true);
			ServerListMC.SetBool("focusable", true);
		}
	        
		DataProvider = Outer.CreateArray();
		for (i = 0; i < LatestGameSearch.Results.Length; i++)
		{	        
			TempObj = CreateObject("Object");
			TempObj.SetString("ServerName",     LatestGameSearch.Results[i].GameSettings.OwningPlayerName);        
			TempObj.SetFloat("Players",        (LatestGameSearch.Results[i].GameSettings.NumPublicConnections-LatestGameSearch.Results[i].GameSettings.NumOpenPublicConnections));
			TempObj.SetFloat("MaxPlayers",     LatestGameSearch.Results[i].GameSettings.NumPublicConnections);

			// Flags can be used to set "locked", "official server", "anti-cheat enabled" icons via htmlText.
			// TempObj.SetString("Flags", "<img src='flags_lock_png'> <img src='flags_ue_png'>");
			DataProvider.SetElementObject(i, TempObj);  
		}    
		ServerListMC.SetObject("dataProvider", DataProvider);  

		// Create an empty ActionScript argument to invoke validateNow().
		ASVal.Type = AS_String;
		ASVal.s = "";
		Args[0] = ASVal;
		ServerListMC.Invoke("validateNow", args);
	}
}

function OnServerHeaderPress(GFxClikWidget.EventData ev)
{
    //  
}

function OnMapHeaderPress(GFxClikWidget.EventData ev)
{
    //
}

function OnPlayersHeaderPress(GFxClikWidget.EventData ev)
{
    //
}

function OnPingHeaderPress(GFxClikWidget.EventData ev)
{
    //
}

function OnServerListItemPress(GFxClikWidget.EventData ev)
{
    local OnlineGameSearch LatestGameSearch;    
    local OnlineGameSettings SelectedGameSettings;    
        
    SelectedIndex = ev.index;
    JoinDialogMC = GFxUDKFrontEnd_JoinDialog(MenuManager.SpawnDialog('JoinDialog')); 
        
    LatestGameSearch = SearchDataStore.GetActiveGameSearch();
    SelectedGameSettings = LatestGameSearch.Results[ev.index].GameSettings;
    JoinDialogMC.PopulateServerInfo(SelectedGameSettings);
    JoinDialogMC.SetJoinButtonPress(JoinServerClikListener);
    JoinDialogMC.SetSpectateButtonPress(SpectateServer);
    bJoinDialogShowing = true;
}

function SpectateServer(GFxClikWidget.EventData ev)
{
    bSpectate = true;
    JoinServer();
}


function JoinServerClikListener(GFxClikWidget.EventData ev)
{
    if ( SearchDataStore != None )
	{
		SearchDataStore.ServerDetailsProvider.SearchResultsRow = SelectedIndex;
	}

    JoinServer();
}

function JoinServer()
{	
	local int CurrentSelection;
	local UTUIDataProvider_SearchResult CurrentSearchResult;    
	if ( AllowJoinServer() )
	{        
		CurrentSelection = SelectedIndex;
		if ( CurrentSelection >= 0 )
		{
            // @todo sf: This bit doesn't work since we don't have a provider/subscriber relationship?
            //           The code here is a workaround for that situation.
			CurrentSearchResult = ((SearchDataStore != None) && (SearchDataStore.ServerDetailsProvider != None))
									? UTUIDataProvider_SearchResult(SearchDataStore.ServerDetailsProvider.GetSearchResultsProvider())
									: None;
			if ( (CurrentSearchResult != None)
				&& CurrentSearchResult.IsPrivateServer() 
				&& ServerPassword == "" )
			{
				PromptForServerPassword();
			}
			else
			{             
				ProcessJoin();
			}
		}	
	}
}


private function ProcessJoin()
{
	local OnlineGameSearchResult GameToJoin;
	local int ControllerId, CurrentSelection;

    `log("ProcessJoin()");
	if ( GameInterface != None )
	{        
		CurrentSelection = SelectedIndex;        
		if(SearchDataStore.GetSearchResultFromIndex(CurrentSelection, GameToJoin))
		{
			`Log(`location @"- Joining Search Result " $ CurrentSelection, ,'DevGFxUI');

			// Play the startgame sound
            // PlayUISound('StartGame');

			if (GameToJoin.GameSettings != None)
			{
				bProcessingJoin = true;

				// Set the delegate for notification
				GameInterface.AddJoinOnlineGameCompleteDelegate(OnJoinGameComplete);

				// Start the async task
                // @todo sf: GetBestControllerID() implementation for GFxMovie?
				ControllerId = 0;//GetBestControllerId();
				if (!GameInterface.JoinOnlineGame(ControllerId,'Game',GameToJoin))
				{
					//@todo - should we do anything here?  OnJoinGameComplete will be called even if the call to JoinOnlineGame returns FALSE.
					bProcessingJoin = false;
				}
			}
			else
			{
				`Log(`location @"- Failed to join game because of a NULL GameSettings object in the search result.");
				OnJoinGameComplete('Game',false);
			}
		}
		else
		{
			bSpectate = false;
			ServerPassword = "";
			`Log(`location @"- Unable to get search result for index "$CurrentSelection);
		}
	}
	else
	{
		bSpectate = false;
		ServerPassword = "";
		`Log(`location @"- Unable to join game, GameInterface is NULL!");
	}
}

/** Callback for when the join completes. */
function OnJoinGameComplete(name SessionName,bool bSuccessful)
{
	local string URL;	
    local GFxUDKFrontEnd_ErrorDialog DialogMC;

	bProcessingJoin = false;
    `log("OnJoinGameComplete("@String(SessionName)@","@bSuccessful);
	
	// Figure out if we have an online subsystem registered
	if (GameInterface != None)
	{
		if (bSuccessful)
		{
            Cleanup();
			// Get the platform specific information
			if (GameInterface.GetResolvedConnectString('Game',URL))
			{				
				// Call the game specific function to appending/changing the URL
				URL = BuildJoinURL(URL);				
				URL $= "?name=" $ GetPlayerName();

				`Log(`location @"- Join Game Successful, Traveling: "$URL$"",,'DevUI');                                
				
                // Get the resolved URL and build the part to start it
				ConsoleCommand(URL);                
			}
		}
		else
		{
			GameInterface.DestroyOnlineGame('Game');
			if (MenuManager != none)
			{				
                DialogMC = GFxUDKFrontEnd_ErrorDialog(MenuManager.SpawnDialog('ErrorDialog'));
                DialogMC.SetTitle("<Strings:UTGameUI.Errors.ConnectionLost_Title>");
                DialogMC.SetInfo("<Strings:UTGameUI.Errors.ConnectionLost_Message>");		        
                DialogMC.SetButtonLabel("BACK");
                DialogMC.SetBackButton_OnPress(Select_Back);
			}            
		}

		// Remove the delegate from the list
		GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
	}
    
	bSpectate = false;
	ServerPassword = "";	
}

/**
 * Determine if we're in the right state to join a server (cancels any pending queries, etc.)
 *
 * @return	TRUE if joining a server should be allowed; FALSE if there a query is still active - will join the server
 *			when it's safe to do so.
 */
function bool AllowJoinServer()
{
	local bool bResult;

	if ( !bProcessingJoin )
	{
		bResult = true;
		if ( GameInterface != None )
		{
			// see if we still have searches pending
			if ( SearchDataStore != None && SearchDataStore.HasOutstandingQueries() )
			{
                `log("Searches are still pending");
				// don't allow the scene to close
				bResult = false;

				// we will join the selected server when the query is complete
				CancelQuery(QUERYACTION_JoinServer);
			}
		}
	}

	return bResult;
}

/**
 * Fires an asynchronous task to cancels all active queries.
 *
 * @param	DesiredCancelAction		specifies what should happen when the asynchronous task completes.
 */
function CancelQuery( optional EQueryCompletionAction DesiredCancelAction=QUERYACTION_Default )
{
	if ( QueryCompletionAction == QUERYACTION_None )
	{
		QueryCompletionAction = DesiredCancelAction;
		if ( SearchDataStore == None || SearchDataStore.HasOutstandingQueries() )
		{
			// we don't check for none so that we get warning in the log if GameInterface is none (this would be bad)
			GameInterface.AddCancelFindOnlineGamesCompleteDelegate(OnCancelSearchComplete);
			GameInterface.CancelFindOnlineGames();
		}
		else if ( SearchDataStore.HasExistingSearchResults() )
		{
			OnCancelSearchComplete(true);
		}
	}
	else
	{
		`log("Could not cancel query because query cancel already in progress:" @ GetEnum(enum'EQueryCompletionAction', QueryCompletionAction));
	}
}

function SetRefreshing(bool IsRefreshing)
{
    if (IsRefreshing)
    {
        StatusTxt.SetText("<Strings:UTGameUI.Generic.Refreshing>");        
        LoadingTickerMC.SetVisible(true);
        LoadingTickerMC.GotoAndStopI(1);
    }
    else 
    {        
        LoadingTickerMC.SetVisible(false);
        LoadingTickerMC.GotoAndStopI(1);
    }
}

/**
 * Handler for the 'cancel query' asynchronous task completion.  Performs the actions dictated by the current QueryCompletionAction, as
 * set when CancelQuery was called.
 */
function OnCancelSearchComplete( bool bWasSuccessful )
{
	local EQueryCompletionAction CurrentAction;	
    local GFxUDKFrontEnd_ErrorDialog Dialog;

	if ( bWasSuccessful )
	{
		CurrentAction = QueryCompletionAction;
		QueryCompletionAction = QUERYACTION_None;

		switch ( CurrentAction )
		{
		case QUERYACTION_CloseScene:
            MenuManager.PopView();
			break;

		case QUERYACTION_JoinServer:
			JoinServer();            
			UpdateButtonStates();
			SetRefreshing(false);		            
            break;

		case QUERYACTION_RefreshAll:
			// if we're leaving the server browser area - clear all stored server query searches
			if ( SearchDataStore != None )
			{
				SearchDataStore.ClearAllSearchResults();
			}
			UpdateButtonStates();
			SetRefreshing(false);
			break;

		default:
			// don't do anything - just update the enabled state of the button bar buttons
			UpdateButtonStates();
			SetRefreshing(false);
			break;
		}
	}
	else if ( QueryCompletionAction != QUERYACTION_None )
	{
		// looks like we'll have to wait until the query completes on its own; since we're going to take some action
		// when the query completes, we'll need to display a dialog to the user so that they know what the holdup is		
	    /*
	    UTOwnerScene = UTUIScene(GetScene());
		MessageBoxScene = UTOwnerScene.GetMessageBoxScene();

		// show the messagebox scene - when we receive the call to OnFindOnlineGamesCompleteDelegate with HasOutstandingQueries() == false,
		// the message box will be closed and this method will be called again.
		MessageBoxScene.DisplayModalBox("<Strings:UTGameUI.MessageBox.QueryPending_Message>");        
        */

        if (MenuManager != none)
		{				
            Dialog = GFxUDKFrontEnd_ErrorDialog(MenuManager.SpawnDialog('ErrorDialog'));
            Dialog.SetTitle("<Strings:UTGameUI.Errors.Error_Title>");
            Dialog.SetInfo("<Strings:UTGameUI.MessageBox.QueryPending_Message>");
            bQueryDialogShowing = true;
		}    

        UpdateButtonStates();
	}
}

/**
 * Notification that the currently selected gametype was changed externally.  Update this tab page to reflect the new
 * gametype.
 */
function NotifyGameTypeChanged()
{	
	UpdateFilterButton();    			
	bGametypeOutdated = true;	
}
           
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    local bool bWasHandled;
    bWasHandled = false;

    // `log("GFxUDKFrontEnd_JoinGame: WidgetInit - WidgetName: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
    switch(WidgetName)
    {
        case ('list'): 
            if (ServerListMC == none)
            {
                ServerListMC = GFxClikWidget(Widget); 
                UpdateListDataProvider();
                ServerListMC.AddEventListener('CLIK_itemPress', OnServerListItemPress);
                bWasHandled = true;
            }
            break;
        case ('menu'):
            if (MenuMC == none)
            {
                MenuMC = Widget;
                bWasHandled = true;
            }
            break;
        case ('headerbar'):
            if (HeaderBarMC == none)
            {
                HeaderBarMC = Widget;
                FlagsHeaderBtn = GFxClikWidget(Widget.GetObject("header1", class'GFxClikWidget'));
                
                ServerHeaderBtn = GFxClikWidget(Widget.GetObject("header2", class'GFxClikWidget'));
                ServerHeaderBtn.AddEventListener('CLIK_press', OnServerHeaderPress);

                MapHeaderBtn = GFxClikWidget(Widget.GetObject("header3", class'GFxClikWidget'));
                MapHeaderBtn.AddEventListener('CLIK_press', OnMapHeaderPress);

                PlayersHeaderBtn = GFxClikWidget(Widget.GetObject("header4", class'GFxClikWidget'));
                PlayersHeaderBtn.AddEventListener('CLIK_press', OnPlayersHeaderPress);

                PingHeaderBtn = GFxClikWidget(Widget.GetObject("header5", class'GFxClikWidget'));
                PingHeaderBtn.AddEventListener('CLIK_press', OnPingHeaderPress);
                bWasHandled = true;
            }
            break;
        case ('browsertext'):                
            FilterMatchTypeTxt = Widget.GetObject("matchtype");
            FilterGameModeTxt = Widget.GetObject("gamemode");
            bWasHandled = true;
            break;        
        case ('browserbtn_fliter'):
            if (FilterBtn == none)
            {
                FilterBtn = GFxClikWidget(Widget);
                FilterBtn.AddEventListener('CLIK_press', OnFilterButtonPress);
                bWasHandled = true;
            }
            break;
        case ('browserbtn_refresh'):
            RefreshBtn = GFxClikWidget(Widget);
            RefreshBtn.RemoveAllEventListeners("CLIK_press");
            RefreshBtn.AddEventListener('CLIK_press', OnRefreshButtonPress);
            bWasHandled = true;            
            break;
        case ('btn_back'):
            if (BackBtn == none)
            {
                BackBtn = GFxClikWidget(Widget.GetObject("btn", class'GFxClikWidget'));
                BackBtn.AddEventListener('CLIK_press', Select_Back);                
                BackBtn.SetString("label", "BACK");
                bWasHandled = true;
            }
            break;   
        case ('servers_received'):
			//if (LoadingTickerMC == none)
			//{
			LoadingTickerMC = Widget.GetObject("loading_ticker");
			StatusTxt = Widget.GetObject("label");
			ServerCountTxt = Widget.GetObject("textField");
			bWasHandled = true;
			//}                      
            break;
        default:
            break;
    }
	
	if (!bWasHandled)
	{
		bWasHandled = Super.WidgetInitialized(WidgetName, WidgetPath, Widget);    
	}
    return bWasHandled;
}


DefaultProperties
{
    SelectedIndex=0
    ServerPassword=""
	SearchDSName=UTGameSearch
    bIssuedInitialQuery=FALSE
    bQueryDialogShowing=FALSE
}

/*
			//class'OnlineSubsystem'.static.DumpGameSettings( LatestGameSearch.Results[i].GameSettings );
			//`log("Results["$i$"]: bIsDedicated: " @ LatestGameSearch.Results[i].GameSettings.bIsDedicated);
			//`log("Results["$i$"]: Ping: " @ LatestGameSearch.Results[i].GameSettings.PingInMs);
			//`log("LatestGameSearchCfg: SearchName: " @ LatestGameSearchCfg.Name);     
			//`log("LatestGameSearchCfg: GameSearchClass: " @ LatestGameSearchCfg.GameSearchClass);
			//`log("LatestGameSearchCfg: DefaultGameSettingsClass: " @ LatestGameSearchCfg.DefaultGameSettingsClass);
			//`log("LatestGameSearchCfg: SearchResultsProviderClass: " @ LatestGameSearchCfg.SearchResultsProviderClass);
			//`log("LatestGameSearchCfg: Search: " @ LatestGameSearchCfg.Search);
			//`log("LatestGameSearchCfg: SearchResults[0]: " @ LatestGameSearchCfg.SearchResults[0]); 
*/