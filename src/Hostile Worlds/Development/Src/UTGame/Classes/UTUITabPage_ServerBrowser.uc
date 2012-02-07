/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Tab page for a server browser.
 */

class UTUITabPage_ServerBrowser extends UTTabPage
	placeable;

const SERVERBROWSER_SERVERTYPE_LAN		= 0;
const SERVERBROWSER_SERVERTYPE_UNRANKED	= 1;	//	for platforms which do not support ranked matches, represents a normal internet match.
const SERVERBROWSER_SERVERTYPE_RANKED	= 2;	// only valid on platforms which support ranked matches

/** Reference to the list of servers */
var transient UIList						ServerList;
/** Reference to the list of rules for the selected server */
var transient UIList						DetailsList;
/** reference to the list of mutators for the selected server */
var transient UIList						MutatorList;

/** Reference to a label to display when refreshing. */
var transient UIObject						RefreshingLabel;

/** Reference to the label which displays the number of servers currently loaded in the list */
var	transient UILabel						ServerCountLabel;

/** Reference to the combobox containing the gametypes */
var	transient UTUIComboBox					GameTypeCombo;

/** Reference to the search datastore. */
var transient UDKDataStore_GameSearchBase	SearchDataStore;

/** Reference to the string list datastore. */
var transient UTUIDataStore_StringList		StringListDataStore;

/** Reference to the menu item datastore. */
var transient UTUIDataStore_MenuItems		MenuItemDataStore;

/** Cached online subsystem pointer */
var transient OnlineSubsystem				OnlineSub;

/** Cached game interface pointer */
var transient OnlineGameInterface			GameInterface;

/** Indices for the button bar buttons */
var	transient int							BackButtonIdx, JoinButtonIdx, RefreshButtonIdx, CancelButtonIdx, SpectateButtonIdx, DetailsButtonIdx;

/** Indicates that the current gametype was changed externally - submit a new query when possible */
var	private transient bool					bGametypeOutdated, bSpectate;

var	protected	transient	const	name	SearchDSName;

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


/** Go back delegate for this page. */
delegate transient OnBack();

/** Called when the user changes the game type using the combo box */
delegate transient OnSwitchedGameType();

/**
 * Called when we're about the submit a server query.  Usual thing to do is make sure the GameSearch object is up to date
 */
delegate transient OnPrepareToSubmitQuery( UTUITabPage_ServerBrowser Sender );

/** PostInitialize event - Sets delegates for the page. */
event PostInitialize( )
{
	local DataStoreClient DSClient;
	local UTUIList UTComboList;

	Super.PostInitialize();

	// Find the server list.
	ServerList = UIList(FindChild('lstServers', true));
	if(ServerList != none)
	{
		ServerList.OnSubmitSelection = OnServerList_SubmitSelection;
		ServerList.OnValueChanged = OnServerList_ValueChanged;
		ServerList.OnListElementsSorted = ServerListResorted;

		// the server list's initial sort column
		if ( ServerList.SortComponent != None )
		{
			ServerList.SortComponent.bReversePrimarySorting = true;
		}
	}

	DetailsList = UIList(FindChild('lstDetails', true));
	MutatorList = UIList(FindChild('lstMutators', true));

	// Get reference to the refreshing/searching label.
	RefreshingLabel = FindChild('lblRefreshing', true);
	if ( RefreshingLabel != None )
	{
		RefreshingLabel.SetVisibility(false);
	}

	// get a reference to the server count label
	ServerCountLabel = UILabel(FindChild('lblServerCount', true));

	// get a reference to the combo holding the list of gametypes.
	GameTypeCombo = UTUIComboBox(FindChild('cmbGameType', true));
	if ( GameTypeCombo != None )
	{
		UTComboList = UTUIList(GameTypeCombo.ComboList);

		// UTUIComboBox sets this flag on its internal list for some reason - unset it so that the combobox works like
		// it's supposed to.
		if ( UTComboList != None )
		{
			UTComboList.bAllowSaving = true;
		}
	}

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

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.JoinGame.Servers>");

	AdjustLayout();

	UpdateServerCount();
}

/**
 * Causes this page to become (or no longer be) the tab control's currently active page.
 *
 * @param	PlayerIndex	the index [into the Engine.GamePlayers array] for the player that wishes to activate this page.
 * @param	bActivate	TRUE if this page should become the tab control's active page; FALSE if it is losing the active status.
 * @param	bTakeFocus	specify TRUE to give this panel focus once it's active (only relevant if bActivate = true)
 *
 * @return	TRUE if this page successfully changed its active state; FALSE otherwise.
 */
event bool ActivatePage( int PlayerIndex, bool bActivate, optional bool bTakeFocus=true )
{
	local bool bResult;

	bResult = Super.ActivatePage(PlayerIndex, bActivate, bTakeFocus);

	if ( bResult && bActivate )
	{
		if ( GameTypeCombo != None )
		{
			GameTypeCombo.OnValueChanged = OnGameTypeChanged;
		}

		if ( bGametypeOutdated )
		{
			NotifyGameTypeChanged();
			bGametypeOutdated = false;
		}
	}

	return bResult;
}

/**
 * Called when the owning scene is being closed - provides a hook for the tab page to ensure it's cleaned up all external
 * references (i.e. delegates, etc.)
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

/**
 * Adjusts the layout of the scene based on the current platform
 */
function AdjustLayout()
{
	local UTUIScene UTOwnerScene;
	local UIObject DetailsContainer, BackgroundContainer;

	UTOwnerScene = UTUIScene(GetScene());
	if ( UTOwnerScene != None
	&&	IsConsole() )
	{
		// if we're on a console, a few things need to change in the scene

		// we need to hide the gametype combo
		if ( GameTypeCombo != None )
		{
			GameTypeCombo.SetVisibility(false);
		}

		// hide the details panels
		DetailsContainer = FindChild('pnlDetailsContainer',true);
		if ( DetailsContainer != None )
		{
			DetailsContainer.SetVisibility(false);
		}

		// redock the server count label to the bottom of the background panel
		BackgroundContainer = FindChild('pnlBackgroundContainer', true);
		if ( BackgroundContainer != None )
		{
			ServerCountLabel.SetDockTarget(UIFACE_Bottom, BackgroundContainer, UIFACE_Bottom);
		}
	}
}

/**
 * Wrapper for grabbing a reference to a button bar button.
 */
final function UTUIButtonBarButton GetButtonBarButton( int ButtonIndex )
{
	local UTUIButtonBar ButtonBar;
	local UTUIButtonBarButton Result;

	ButtonBar = GetButtonBar();
	if ( ButtonBar != None )
	{
		if ( ButtonIndex >= 0 && ButtonIndex < ArrayCount(ButtonBar.Buttons) )
		{
			Result = ButtonBar.Buttons[ButtonIndex];
		}
	}

	return Result;
}

/** Sets buttons for the scene. */
function SetupButtonBar(UTUIButtonBar ButtonBar)
{
	ButtonBar.Clear();

	if ( SearchDataStore != None && SearchDataStore.HasOutstandingQueries() )
	{
		BackButtonIdx = INDEX_NONE;
		CancelButtonIdx = ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.CancelSearch>", OnButtonBar_CancelQuery);
	}
	else
	{
		CancelButtonIdx = INDEX_NONE;
		BackButtonIdx = ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);
	}

	JoinButtonIdx = ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.JoinServer>", OnButtonBar_JoinServer);
	SpectateButtonIdx = ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.SpectateServer>", OnButtonBar_SpectateServer);
	RefreshButtonIdx = ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Refresh>", OnButtonBar_Refresh);

	if ( IsConsole() )
	{
		DetailsButtonIdx = ButtonBar.AppendButton( "<Strings:UTGameUI.ButtonCallouts.ServerDetails>", OnButtonBar_ServerDetails );
	}

	SetupExtraButtons(ButtonBar);

	UpdateButtonStates();
}

/**
 * Provides an easy way for child classes to add additional buttons before the ButtonBar's button states are updated
 */
function SetupExtraButtons( UTUIButtonBar ButtonBar );

/**
 * Updates the enabled state of certain button bar buttons depending on whether a server is selected or not.
 */
function UpdateButtonStates()
{
	local UTUIFrontEnd UTOwnerScene;
	local UTUIButtonBar ButtonBar;
	local UITabControl TabControlOwner;
	local bool bValidServerSelected, bHasPendingSearches;
	local int PlayerIndex;

	TabControlOwner = GetOwnerTabControl();
	if ( TabControlOwner != None )
	{
		if ( TabControlOwner.ActivePage == Self )
		{
			UTOwnerScene = UTUIFrontEnd(GetScene());
			ButtonBar = GetButtonBar();
			if ( ButtonBar != None )
			{
				PlayerIndex = UTOwnerScene.GetPlayerIndex();
				bHasPendingSearches = SearchDataStore.HasOutstandingQueries();
				bValidServerSelected = ServerList != None && ServerList.GetCurrentItem() != INDEX_NONE;

				if ( CancelButtonIdx != INDEX_NONE )
				{
					if ( bHasPendingSearches )
					{
						ButtonBar.Buttons[CancelButtonIdx].SetEnabled(QueryCompletionAction==QUERYACTION_None, PlayerIndex);
					}
					else
					{
						ButtonBar.SetButton(CancelButtonIdx, "<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);
						BackButtonIdx = CancelButtonIdx;
						CancelButtonIdx = INDEX_NONE;
					}
				}
				else if ( BackButtonIdx != INDEX_NONE )
				{
					if ( bHasPendingSearches )
					{
						ButtonBar.SetButton(BackButtonIdx, "<Strings:UTGameUI.ButtonCallouts.CancelSearch>", OnButtonBar_CancelQuery);
						CancelButtonIdx = BackButtonIdx;
						BackButtonIdx = INDEX_NONE;

						ButtonBar.Buttons[CancelButtonIdx].SetEnabled(QueryCompletionAction==QUERYACTION_None, PlayerIndex);
					}
					else
					{
						ButtonBar.Buttons[BackButtonIdx].SetEnabled(true, PlayerIndex);
					}
				}

				// we must have a valid server selected in order to activate the Join Server button
				if ( JoinButtonIdx != INDEX_NONE )
				{
					ButtonBar.Buttons[JoinButtonIdx].SetEnabled(bValidServerSelected, PlayerIndex);
				}
				if ( SpectateButtonIdx != INDEX_NONE )
				{
					ButtonBar.Buttons[SpectateButtonIdx].SetEnabled(bValidServerSelected, PlayerIndex);
				}

				// the refresh button and gametype combo can only be enabled if there are no searches currently working
				if ( RefreshButtonIdx != INDEX_NONE && UTOwnerScene.ButtonBar.Buttons[RefreshButtonIdx] != None )
				{
					ButtonBar.Buttons[RefreshButtonIdx].SetEnabled(!bHasPendingSearches, PlayerIndex);
				}

				if ( GameTypeCombo != None )
				{
					GameTypeCombo.SetEnabled(!bHasPendingSearches && GetDesiredMatchType() != SERVERBROWSER_SERVERTYPE_LAN, PlayerIndex);
				}

				// we must have a valid server selected in order to activate the Server Details button.
				if (IsConsole()
				&&	DetailsButtonIdx != INDEX_NONE
				&&	ButtonBar.Buttons[DetailsButtonIdx] != None)
				{
					ButtonBar.Buttons[DetailsButtonIdx].SetEnabled(bValidServerSelected, PlayerIndex);
				}
			}
		}
		else if ( UTUITabPage_ServerBrowser(TabControlOwner.ActivePage) != None )
		{
			UTUITabPage_ServerBrowser(TabControlOwner.ActivePage).UpdateButtonStates();
		}
	}
}

/**
 * Displays a dialog to the user which allows him to enter the password for the currently selected server.
 */
private final function PromptForServerPassword()
{
	local UTUIScene UTSceneOwner;
	local UDKUIScene_InputBox PasswordInputScene;

	ServerPassword = "";
	UTSceneOwner = UTUIScene(GetScene());
	if ( UTSceneOwner != None )
	{
		PasswordInputScene = UTSceneOwner.GetInputBoxScene();
		if ( PasswordInputScene != None )
		{
			PasswordInputScene.SetPasswordMode(true);
			PasswordInputScene.DisplayAcceptCancelBox(
				"<Strings:UTGameUI.MessageBox.EnterServerPassword_Message>",
				"<Strings:UTGameUI.MessageBox.EnterServerPassword_Title>",
				OnPasswordDialog_Closed
				);
		}
		else
		{
			`log("Failed to open the input box scene (" $ UTSceneOwner.InputBoxScene $ ")");
		}
	}
}

/**
 * The user has made a selection of the choices available to them.
 */
private final function OnPasswordDialog_Closed(UDKUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	local UDKUIScene_InputBox PasswordInputScene;

	PasswordInputScene = UDKUIScene_InputBox(MessageBox);
	if ( PasswordInputScene != None && SelectedOption == 0 )
	{
		// strip out all
		ServerPassword = class'UTUIFrontEnd_HostGame'.static.StripInvalidPasswordCharacters(PasswordInputScene.GetValue());
		ProcessJoin();
	}
	else
	{
		ServerPassword = "";
	}
}

/** Joins the currently selected server. */
function JoinServer()
{
	local UTUIScene UTScene;
	local int CurrentSelection;
	local UTUIDataProvider_SearchResult CurrentSearchResult;

	if ( AllowJoinServer() )
	{
		UTScene = UTUIScene(GetScene());
		if(UTScene != None)
		{
			CurrentSelection = ServerList.GetCurrentItem();
			if ( CurrentSelection >= 0 )
			{
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
}

private function ProcessJoin()
{
	local OnlineGameSearchResult GameToJoin;
	local int ControllerId, CurrentSelection;

	if ( GameInterface != None )
	{
		CurrentSelection = ServerList.GetCurrentItem();
		if(SearchDataStore.GetSearchResultFromIndex(CurrentSelection, GameToJoin))
		{
			`Log(`location @"- Joining Search Result " $ CurrentSelection,,'DevUI');

			// Play the startgame sound
			PlayUISound('StartGame');

			if (GameToJoin.GameSettings != None)
			{
				bProcessingJoin = true;

				// Set the delegate for notification
				GameInterface.AddJoinOnlineGameCompleteDelegate(OnJoinGameComplete);

				// Start the async task
				ControllerId = GetBestControllerId();
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

	UpdateButtonStates();
}

/** Callback for when the join completes. */
function OnJoinGameComplete(name SessionName,bool bSuccessful)
{
	local string URL;
	local UTUIScene UTOwnerScene;

	bProcessingJoin = false;

	// Figure out if we have an online subsystem registered
	if (GameInterface != None)
	{
		if (bSuccessful)
		{
			// Get the platform specific information
			if (GameInterface.GetResolvedConnectString('Game',URL))
			{
				UTOwnerScene = UTUIScene(GetScene());

				// Call the game specific function to appending/changing the URL
				URL = BuildJoinURL(URL);

				// @TODO: This is only temporary
				URL $= "?name=" $ UTOwnerScene.GetPlayerName();

				`Log(`location @"- Join Game Successful, Traveling: "$URL$"",,'DevUI');

				// Get the resolved URL and build the part to start it
				UTOwnerScene.ConsoleCommand(URL);
			}
		}
		else
		{
			GameInterface.DestroyOnlineGame('Game');
			// Display error message
			UTOwnerScene = UTUIScene(GetScene());
			if (UTOwnerScene != None)
			{
				UTOwnerScene.DisplayMessageBox("<Strings:UTGameUI.Errors.ConnectionLost_Message>","<Strings:UTGameUI.Errors.ConnectionLost_Title>");
			}
		}

		// Remove the delegate from the list
		GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
	}

	bSpectate = false;
	ServerPassword = "";
	UpdateButtonStates();
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
			ServerList.RefreshSubscriberValue();
		}

		// update the server count label with the number of servers received so far for this gametype
		UpdateServerCount();
	}
}

function int GetDesiredMatchType()
{
	local int Result;

	// Get the match type based on the platform.
	if( IsConsole(CONSOLE_XBox360) )
	{
		Result = StringListDataStore.GetCurrentValueIndex('MatchType360');
	}
	else
	{
		Result = StringListDataStore.GetCurrentValueIndex('MatchType');
	}
	return Result;
}

/** called when the list is resorted (can be triggered by manual resort from user input or automatic resort from new elements added */
function ServerListResorted( UIList Sender )
{
	RefreshDetailsList();
}

/** Refreshes the server list. */
function RefreshServerList(int InPlayerIndex, optional int MaxResults=1000)
{
	local OnlineGameSearch GameSearch;
	local int ValueIndex;

	if ( !SearchDataStore.HasOutstandingQueries() )
	{
		// Play the refresh sound
		PlayUISound('RefreshServers');

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
			if ( IsConsole(CONSOLE_XBox360) )
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

	OnPrepareToSubmitQuery( Self );

	// show the "refreshing" label
	if(RefreshingLabel != None)
	{
		RefreshingLabel.SetVisibility(true);
	}

	// Add a delegate for when the search completes.  We will use this callback to do any post searching work.
	GameInterface.AddFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);

	// Start a search
	if ( !SearchDataStore.SubmitGameSearch(class'UIInteraction'.static.GetPlayerControllerId(PlayerIndex), false) )
	{
		RefreshingLabel.SetVisibility(false);
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

	// Hide refreshing label.
	if ( RefreshingLabel != None )
	{
		RefreshingLabel.SetVisibility(false);
	}

	// update the server count label
	UpdateServerCount();

	if ( bSearchCompleted )
	{
		// Clear delegate
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);

		OnFindOnlineGamesComplete(bWasSuccessful);
	}

	// update the enabled state of the button bar buttons
	UpdateButtonStates();
}

/**
 * Delegate fired when the search for an online game has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnFindOnlineGamesComplete(bool bWasSuccessful)
{
	local UTUIScene UTOwnerScene;
	local UTUIScene_MessageBox MessageBoxScene;

	UTOwnerScene = UTUIScene(GetScene());
	if ( QueryCompletionAction != QUERYACTION_None )
	{
		MessageBoxScene = UTUIScene_MessageBox(UTOwnerScene.MessageBoxScene);

		if ( MessageBoxScene != None && MessageBoxScene.IsSceneActive(true) )
		{
			MessageBoxScene.OnClosed = MessageBoxClosed;
			MessageBoxScene.Close();
		}
		else
		{
			OnCancelSearchComplete(true);
		}
	}
	// refresh the list with the items from the currently selected gametype's cached query
	ServerList.RefreshSubscriberValue();
}

/**
 * Handler for the message box scene's OnClose delegate when we're displaying a modal dialog while waiting for the active
 * query to complete.
 */
function MessageBoxClosed()
{
	// simulate the cancel succeeding - this function does everything we need to do
	OnCancelSearchComplete(true);
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
 * Determine if we're in the right state to close the "Join Game" scene (cancels any pending queries, etc.)
 *
 * @return	TRUE if closing the scene should be allowed; FALSE if there a query is still active - will close the scene
 *			when it's safe to do so.
 */
function bool AllowCloseScene()
{
	local bool bResult;

	bResult = true;
	if ( GameInterface != None )
	{
		// see if we still have searches pending
		if ( SearchDataStore != None && SearchDataStore.HasOutstandingQueries() )
		{
			// don't allow the scene to close
			bResult = false;

			// we will close the scene when the query is complete
			CancelQuery(QUERYACTION_CloseScene);
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

/**
 * Handler for the 'cancel query' asynchronous task completion.  Performs the actions dictated by the current QueryCompletionAction, as
 * set when CancelQuery was called.
 */
function OnCancelSearchComplete( bool bWasSuccessful )
{
	local EQueryCompletionAction CurrentAction;
	local UTUIScene UTOwnerScene;
	local UDKUIScene_MessageBox MessageBoxScene;

	if ( bWasSuccessful )
	{
		CurrentAction = QueryCompletionAction;
		QueryCompletionAction = QUERYACTION_None;

		switch ( CurrentAction )
		{
		case QUERYACTION_CloseScene:
			UTOwnerScene = UTUIScene(GetScene());
			UTOwnerScene.CloseScene(UTOwnerScene);
			break;

		case QUERYACTION_JoinServer:
			JoinServer();

			UpdateButtonStates();

			// Hide refreshing label.
			if ( RefreshingLabel != None )
			{
				RefreshingLabel.SetVisibility(false);
			}
			break;

		case QUERYACTION_RefreshAll:
			// if we're leaving the server browser area - clear all stored server query searches
			if ( SearchDataStore != None )
			{
				SearchDataStore.ClearAllSearchResults();
			}
			UpdateButtonStates();

			// Hide refreshing label.
			if ( RefreshingLabel != None )
			{
				RefreshingLabel.SetVisibility(false);
			}
			break;

		default:
			// don't do anything - just update the enabled state of the button bar buttons
			UpdateButtonStates();

			// Hide refreshing label.
			if ( RefreshingLabel != None )
			{
				RefreshingLabel.SetVisibility(false);
			}
			break;
		}
	}
	else if ( QueryCompletionAction != QUERYACTION_None )
	{
		// looks like we'll have to wait until the query completes on its own; since we're going to take some action
		// when the query completes, we'll need to display a dialog to the user so that they know what the holdup is
		UTOwnerScene = UTUIScene(GetScene());
		MessageBoxScene = UTOwnerScene.GetMessageBoxScene();

		// show the messagebox scene - when we receive the call to OnFindOnlineGamesCompleteDelegate with HasOutstandingQueries() == false,
		// the message box will be closed and this method will be called again.
		MessageBoxScene.DisplayModalBox("<Strings:UTGameUI.MessageBox.QueryPending_Message>");
	}
}

/**
 * Updates the server count label with the number of servers received so far for the currently selected gametype.
 */
function UpdateServerCount()
{
	local int ServerCount;
	local OnlineGameSearch CurrentSearch;

	if ( ServerCountLabel != None && SearchDataStore != None )
	{
		CurrentSearch = SearchDataStore.GetCurrentGameSearch();
		if ( CurrentSearch != None )
		{
			ServerCount = CurrentSearch.Results.Length;
		}
	}

	SetDataStoreStringValue("<SceneData:NumServersReceived>", string(ServerCount), GetScene(), GetPlayerOwner(GetBestPlayerIndex()));
	if ( ServerCountLabel != None )
	{
		ServerCountLabel.RefreshSubscriberValue();
	}
}

/** Refreshes the game details list using the currently selected item in the server list. */
function RefreshDetailsList()
{
	if ( SearchDataStore != None )
	{
		SearchDataStore.ServerDetailsProvider.SearchResultsRow = ServerList.GetCurrentItem();
	}

	if ( DetailsList != None )
	{
		DetailsList.RefreshSubscriberValue();
	}

	if ( MutatorList != None )
	{
		MutatorList.RefreshSubscriberValue();
	}
}

/**
 * Opens a custom UIScene which displays more verbose details about the server currently selected in the server browser.
 * Console only.
 */
function ShowServerDetails()
{
	local int ServerIndex;
	local UTUIFrontEnd ServerDetailScene;
	local UILabel DetailTitleLabel;

	if ( SearchDataStore != None )
	{
		ServerIndex = SearchDataStore.ServerDetailsProvider.SearchResultsRow;
		if ( ServerIndex != INDEX_NONE )
		{
			ServerDetailScene = UTUIFrontEnd(UTUIScene(GetScene()).OpenSceneByName("UI_Scenes_FrontEnd.Popups.ServerDetails"));
			if ( ServerDetailScene != None )
			{
				// don't show the title label on this popup.
				DetailTitleLabel = ServerDetailScene.GetTitleLabel();
				if ( DetailTitleLabel != None )
				{
					DetailTitleLabel.SetVisibility(false);
				}
			}
		}
		else
		{
			//@todo - play error sound?  this shouldn't happen because we disable the button in this case.
		}
	}
}

/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool HandleInputKey( const out InputEventParameters EventParms )
{
	local bool bResult;
	local UTUIButtonBarButton Button;

	bResult=false;

	if(EventParms.EventType==IE_Released)
	{
		if ( EventParms.InputKeyName=='XboxTypeS_X' )
		{
			Button = GetButtonBarButton(RefreshButtonIdx);
			if ( Button == None || Button.OnClicked == None
			||	!Button.OnClicked(Button, EventParms.PlayerIndex) )
			{
				OnButtonBar_Refresh(Button, EventParms.PlayerIndex);
			}
			bResult=true;
		}
		else if( EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape' )
		{
			Button = GetButtonBarButton(BackButtonIdx);
			if ( Button == None )
			{
				Button = GetButtonBarButton(CancelButtonIdx);
			}

			if ( Button == None || Button.OnClicked == None
			||	!Button.OnClicked(Button, EventParms.PlayerIndex) )
			{
				OnButtonBar_Back(Button, EventParms.PlayerIndex);
			}
			bResult=true;
		}
		else if ( EventParms.InputKeyName == 'XboxTypeS_Y' && IsConsole() )
		{
			Button = GetButtonBarButton(DetailsButtonIdx);
			if ( Button == None || Button.OnClicked == None
			||	!Button.OnClicked(Button, EventParms.PlayerIndex) )
			{
				OnButtonBar_ServerDetails(Button, EventParms.PlayerIndex);
			}
			bResult = true;
		}
		else if ( EventParms.InputKeyName == 'XboxTypeS_LeftTrigger' )
		{
			Button = GetButtonBarButton(SpectateButtonIdx);
			if ( Button == None || Button.OnClicked == None
			||	!Button.OnClicked(Button, EventParms.PlayerIndex) )
			{
				OnButtonBar_SpectateServer(Button, EventParms.PlayerIndex);
			}
			bResult = true;
		}
	}

	return bResult;
}

/** ButtonBar - JoinServer */
function bool OnButtonBar_JoinServer(UIScreenObject InButton, int InPlayerIndex)
{
	if ( InButton != None && InButton.IsEnabled(InPlayerIndex) )
	{
		// we must have a valid server selected in order to activate the Join Server button
		JoinServer();
	}
	return true;
}

function bool OnButtonBar_SpectateServer(UIScreenObject InButton, int InPlayerIndex)
{
	if ( InButton != None && InButton.IsEnabled(InPlayerIndex) )
	{
		bSpectate = true;

		// we must have a valid server selected in order to activate the Spectate Server button
		JoinServer();
	}
	return true;
}

/** ButtonBar - Back */
function bool OnButtonBar_Back(UIScreenObject InButton, int InPlayerIndex)
{
	if ( InButton != None && InButton.IsEnabled(InPlayerIndex) )
	{
		OnBack();
	}
	return true;
}

/** ButtonBar - Refresh */
function bool OnButtonBar_Refresh(UIScreenObject InButton, int InPlayerIndex)
{
	if ( InButton != None && InButton.IsEnabled(InPlayerIndex) )
	{
		RefreshServerList(InPlayerIndex);
		if (ServerList.CanAcceptFocus())
		{
			ServerList.SetFocus(none);
		}
	}
	return true;
}

function bool OnButtonBar_CancelQuery( UIScreenObject InButton, int inPlayerIndex )
{
	if ( InButton != None && InButton.IsEnabled(InPlayerIndex) )
	{
		CancelQuery();
		if (ServerList.CanAcceptFocus())
		{
			ServerList.SetFocus(none);
		}
	}
	return true;
}

/** ButtonBar - ServerDetails (console only) */
function bool OnButtonBar_ServerDetails( UIScreenObject InButton, int InPlayerIndex )
{
	if ( InButton != None && InButton.IsEnabled(InPlayerIndex) )
	{
		ShowServerDetails();
	}
	return true;
}

/** Server List - Submit Selection. */
function OnServerList_SubmitSelection( UIList Sender, int PlayerIndex )
{
	OnButtonBar_JoinServer(GetButtonBarButton(JoinButtonIdx), PlayerIndex);
}

/** Server List - Value Changed. */
function OnServerList_ValueChanged( UIObject Sender, int PlayerIndex )
{
	RefreshDetailsList();
	if ( IsVisible() )
	{
		UpdateButtonStates();
	}
	else
	{
		bGametypeOutdated = true;
	}
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
		GetDataStoreStringValue("<UTGameSettings:CustomGameMode>", GameClassName);
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
 * @param	Sender			the UIObject whose value changed
 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
function OnGameTypeChanged( UIObject Sender, int PlayerIndex )
{
	local int ProviderIdx;
	local array<UIDataStore> BoundDataStores;
	local string GameTypeClassName;

	if (IsVisible()
	&&	GameTypeCombo != None && GameTypeCombo.ComboList != None

	// calling SaveSubscriberValue on the combobox list will set the currently selected gametype as the value for the UTMenuItems:GameModeFilter field
	&&	GameTypeCombo.ComboList.SaveSubscriberValue(BoundDataStores)

	// so now we just retrieve this field
	&&	GetDataStoreStringValue("<UTMenuItems:GameModeFilterClass>", GameTypeClassName))
	{
		// make sure to update the GameSettings value - this is used to build the join URL
		SetDataStoreStringValue("<UTGameSettings:CustomGameMode>", GameTypeClassName);

		// find the index into the UTMenuItems data store for the gametype with the specified class name
		ProviderIdx = GetGameTypeSearchProviderIndex(GameTypeClassName);
		`Log(`location@"- Game mode filter class set to" @ GameTypeClassName @ "(" $ ProviderIdx $ ")");

		if ( ProviderIdx != INDEX_NONE )
		{
			MenuItemDataStore.GameModeFilter = ProviderIdx;

			// update the online game search data store's current gametype
			SearchDataStore.SetCurrentByIndex(ProviderIdx, false);
			OnSwitchedGameType();

			ConditionalRefreshServerList(PlayerIndex);
		}
	}
}

/**
 * Notification that the currently selected gametype was changed externally.  Update this tab page to reflect the new
 * gametype.
 */
function NotifyGameTypeChanged()
{
	if ( IsVisible() )
	{
		// update the gametype combo to reflect the currently selected gametype.  This will cause OnGameTypeChanged
		// to be called
		GameTypeCombo.ComboList.RefreshSubscriberValue();
	}
	else
	{
		// set a bool to indicate that a new query should be submitted when this tab page is shown
		bGametypeOutdated = true;
	}
}

/**
 * Wrapper for getting a reference to the favorites data store.  Stub for child classes.
 */
function UTDataStore_GameSearchFavorites GetFavoritesDataStore();

/**
 * Determines whether the server with the specified Id is in the list of favorites.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 * @param	IdToFind		the UniqueNetId for the server to find
 *
 * @return	TRUE if the specified server is in the list of server favorites.
 */
function bool HasServerInFavorites( int ControllerId, const out UniqueNetId IdToFind )
{
	local bool bResult;
	local UTDataStore_GameSearchFavorites FavsDataStore;

	FavsDataStore = GetFavoritesDataStore();
	if ( FavsDataStore != None && ServerList != None )
	{
		bResult = FavsDataStore.FindServerIndexById(ControllerId, IdToFind) != INDEX_NONE;
	}

	return bResult;
}

/**
 * Wrapper for HasServerInFavorites which encapsulates finding the UniqueNetId for the currently selected server.
 *
 * @param	ControllerId	the index of the controller associated with the logged in player.
 *
 * @return	TRUE if the currently selected server is in the list of server favorites.
 */
function bool HasSelectedServerInFavorites( int ControllerId )
{
	local OnlineGameSearchResult SelectedGame;
	local int CurrentSelection;
	local bool bResult;

	if ( SearchDataStore != None && ServerList != None )
	{
		CurrentSelection = ServerList.GetCurrentItem();
		if ( SearchDataStore.GetSearchResultFromIndex(CurrentSelection, SelectedGame) )
		{
			bResult = HasServerInFavorites(ControllerId, SelectedGame.GameSettings.OwningPlayerId);
		}
	}

	return bResult;
}

defaultproperties
{
	SearchDSName=UTGameSearch

	JoinButtonIdx=INDEX_NONE
	RefreshButtonIdx=INDEX_NONE
	DetailsButtonIdx=INDEX_NONE
	SpectateButtonIdx=INDEX_NONE
}
