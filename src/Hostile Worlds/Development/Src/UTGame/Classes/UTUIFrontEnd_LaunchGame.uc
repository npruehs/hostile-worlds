/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Launch game scene for UT3, contains functionality common to instant action and host game flows.
 */
class UTUIFrontEnd_LaunchGame extends UTUIFrontEnd
	abstract;

/** Reference to the settings datastore that we will use to create the game. */
var transient UIDataStore_OnlineGameSettings	SettingsDataStore;

/** Reference to the stringlist datastore that we will use to create the game. */
var transient UTUIDataStore_StringList	StringListDataStore;

/** References to the tab control and pages. */
var transient UTUITabPage_GameModeSelection		GameModeTab;
var transient UTUITabPage_MapSelection			MapTab;
var transient UTUITabPage_Options				GameSettingsTab;

/** Current match settings, used to launch the game. .*/
var transient string  MapName;
var transient string  GameMode;

/** Whether or not we're fully initialized yet. */
var transient bool bFullyInitialized;

/** Whether or not the option list should be refreshed. */
var transient bool bForceRefreshOptionList;

/** PostInitialize event - Sets delegates for the scene. */
event PostInitialize()
{
	Super.PostInitialize();

	// Get a reference to the settings datastore.
	SettingsDataStore = UIDataStore_OnlineGameSettings(FindDataStore('UTGameSettings'));
	StringListDataStore = UTUIDataStore_StringList(FindDataStore('UTStringList'));

	// Game mode
	GameModeTab = UTUITabPage_GameModeSelection(FindChild('pnlGameModeSelection', true));
	if(GameModeTab != none)
	{
		GameModeTab.OnGameModeSelected = OnGameModeSelected;
	}

	// Map
	MapTab = UTUITabPage_MapSelection(FindChild('pnlMapSelection', true));
	if(MapTab != none)
	{
		MapTab.OnMapSelected = OnMapSelected;
	}

	// Game Settings
	GameSettingsTab = UTUITabPage_Options(FindChild('pnlGameSettings', true));
	if(GameSettingsTab != none)
	{
		GameSettingsTab.OnAcceptOptions = OnAcceptGameSettings;
	}

	// Set defaults
	SetDataStoreStringValue("<Registry:SelectedGameMode>", GameMode);
	MapTab.OnGameModeChanged();

	bFullyInitialized=true;
	bForceRefreshOptionList=true;
}


/** Scene activation event, always sets focus to current tab page if activating the page for a second time. */
event SceneActivated(bool bInitialActivation)
{
	Super.SceneActivated(bInitialActivation);

	if(bInitialActivation==false)
	{
		if(TabControl.ActivePage != None)
		{
			TabControl.ActivePage.SetFocus(none);
		}
	}
}

/** Sets up the button bar for the scene. */
function SetupButtonBar()
{
	if(ButtonBar != None)
	{
		ButtonBar.Clear();

		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Next>", OnButtonBar_Next);

		if( TabControl != None && UTTabPage(TabControl.ActivePage) != None && GameModeTab != None )
		{
			if(TabControl.ActivePage != GameModeTab)
			{
				ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.QuickStartGame>", OnButtonBar_StartGame);
			}

			// Let the current tab page try to setup the button bar
			UTTabPage(TabControl.ActivePage).SetupButtonBar(ButtonBar);
		}
	}
}

/** Starts the game. */
function OnStartGame();

/** Callback for when the gamemode changes on the game mode selection tab. */
function OnGameModeSelected(string InGameMode, string InDefaultMap, string GameSettingsClass, bool bSelectionSubmitted)
{
	GameMode = InGameMode;
	MapName = InDefaultMap;

	// Set the game settings object to use
	SettingsDataStore.SetCurrentByName(name(GameSettingsClass));

	// Refresh map list.
	SetDataStoreStringValue("<Registry:SelectedGameMode>", InGameMode);

	// Setup the map list on the map tab.
	MapTab.OnGameModeChanged();
	class'UTUIFrontEnd_Mutators'.static.ApplyGameModeFilter();

	if(bSelectionSubmitted)
	{
		ShowNextTab();
	}
}

/**
 * Called when a new page is activated.
 *
 * @param	Sender			the tab control that activated the page
 * @param	NewlyActivePage	the page that was just activated
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this event.
 */
function OnPageActivated( UITabControl Sender, UITabPage NewlyActivePage, int PlayerIndex )
{
	local string OptionSetMarkup;

	Super.OnPageActivated(Sender, NewlyActivePage, PlayerIndex);

	if(NewlyActivePage==GameSettingsTab)
	{
		// Set the option set to use.
		if(bFullyInitialized)
		{
			OptionSetMarkup = "<UTOptions:"$GameModeTab.GetOptionSet()$">";

			if(OptionSetMarkup != GameSettingsTab.OptionList.GetDataStoreBinding() || bForceRefreshOptionList==true)
			{
				if(bForceRefreshOptionList)
				{
					GameSettingsTab.OptionList.SetDataStoreBinding("");
				}

				bForceRefreshOptionList=false;
				GameSettingsTab.OptionList.SetDataStoreBinding(OptionSetMarkup);
				GameSettingsTab.OptionList.InitializeComboboxWidgets();	// needs to be called manually since prepre
			}

			GameSettingsTab.OptionList.RefreshAllOptions();
		}
	}
}

/** Callback for when the user has selected the map. */
function OnMapSelected()
{
	ShowNextTab();
}

/** Callback for when the user has accepted the game settings. */
function OnAcceptGameSettings(UIScreenObject InObject, int PlayerIndex)
{
	ShowNextTab();
}

/** Shows the previous tab page, if we are at the first tab, then we close the scene. */
function ShowPrevTab()
{
	if(TabControl.ActivatePreviousPage(0,false,false)==false)
	{
		CloseScene(self);
	}
}

/** Shows the next tab page, if we are at the last tab, then we start the game. */
function ShowNextTab()
{
	if(TabControl.ActivateNextPage(0,false,false)==false)
	{
		OnStartGame();
	}
}

/** Buttonbar Callbacks. */
function bool OnButtonBar_StartGame(UIScreenObject InButton, int PlayerIndex)
{
	OnStartGame();

	return true;
}

function bool OnButtonBar_Next(UIScreenObject InButton, int PlayerIndex)
{
	ShowNextTab();

	return true;
}


function bool OnButtonBar_Back(UIScreenObject InButton, int PlayerIndex)
{
	ShowPrevTab();

	return true;
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
	local UTTabPage CurrentTabPage;

	// Let the tab page's get first chance at the input
	CurrentTabPage = UTTabPage(TabControl.ActivePage);
	bResult=CurrentTabPage.HandleInputKey(EventParms);

	if(bResult==false)
	{
		if(EventParms.EventType==IE_Released)
		{
			if(EventParms.InputKeyName=='XboxTypeS_Start')
			{
				// Only allow the 'Start' button to start a game if we're not currently on the 'Game Mode' tab.
				// This is consistent with how the buttons on the bottom bar are configured.
				if( CurrentTabPage != None && CurrentTabPage != GameModeTab)
				{
					OnStartGame();
					bResult=true;
				}
			}
			else if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')
			{
				ShowPrevTab();
				bResult=true;
			}
		}
	}

	return bResult;
}

DefaultProperties
{
	MapName="DM-Deck"
	GameMode="UTGame.UTDeathmatch"
	bMenuLevelRestoresScene=true
}
