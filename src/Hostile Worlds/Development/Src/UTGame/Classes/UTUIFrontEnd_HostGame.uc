/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Host Game scene for UT3.  Contains the host game flow.
 */
class UTUIFrontEnd_HostGame extends UTUIFrontEnd_LaunchGame;

const SERVERTYPE_LAN = 0;
const SERVERTYPE_UNRANKED = 1;
const SERVERTYPE_RANKED = 2;

//@todo: This should probably be INI set.
const MAXIMUM_PLAYER_COUNT = 24;

/** Tab page references for this scene. */
var transient UTUITabPage_Options ServerSettingsTab;

/** PostInitialize event - Sets delegates for the scene. */
event PostInitialize()
{
	Super.PostInitialize();

	// Insert all pages
	ServerSettingsTab = UTUITabPage_Options(FindChild('pnlServerSettings', true));
	ServerSettingsTab.OnAcceptOptions = OnAcceptServerSettings;
	ServerSettingsTab.OnOptionChanged = OnServerOptionChanged;
	ServerSettingsTab.OnOptionFocused = OnServerOptionFocused;
	ServerSettingsTab.SetVisibility(false);
	ServerSettingsTab.SetDataStoreBinding("<Strings:UTGameUI.FrontEnd.TabCaption_ServerSettings>");

	TabControl.InsertPage(GameModeTab, 0, 0, true);
	TabControl.InsertPage(MapTab, 0, 1, false);
	TabControl.InsertPage(ServerSettingsTab, 0, 2, false);
	TabControl.InsertPage(GameSettingsTab, 0, 3, false);

	// Whether or not we are starting a standalone game
	SetDataStoreStringValue("<Registry:StandaloneGame>", "0");

	// Host game defaults
	SetDataStoreStringValue("<UTGameSettings:NumBots>", "0");
	SetDataStoreStringValue("<Registry:ServerMOTD>", class'UTGameReplicationInfo'.default.MessageOfTheDay);
	SetDataStoreStringValue("<Registry:ServerPassword>", "");

	SetupButtonBar();

	bForceRefreshOptionList=true;

	// Force the goal score option to update its subsciber value.
	RefreshGoalScoreOption();
}

/**
 * Handler for the 'show' animation completed.
 */
function OnMainRegion_Show_UIAnimEnd( UIScreenObject AnimTarget, name AnimName, int TrackTypeMask )
{
	Super.OnMainRegion_Show_UIAnimEnd(AnimTarget, AnimName, TrackTypeMask);

	if ( AnimName == 'SceneShowInitial' )
	{
		// make sure we can't choose "internet" if we aren't signed in online
		ValidateServerType();
	}
}

/** Called when one of our options is focused */
function OnServerOptionFocused(UIScreenObject InObject, UIDataProvider OptionProvider)
{
	SetupButtonBar();
}

/**
 * Removes any characters which are not valid to be passed on the URL.
 */
static function string StripInvalidPasswordCharacters( string PasswordString, optional string InvalidChars=" \"/:?,=" )
{
	local int i;

	for ( i = 0; i < Len(InvalidChars); i++ )
	{
		PasswordString = Repl(PasswordString, Mid(InvalidChars, i, 1), "");
	}

	return PasswordString;
}

/**
 * Enables / disables the "server type" control based on whether we are signed in online.
 */
function ValidateServerType()
{
	local int PlayerIndex, ValueIndex, PlayerControllerID;
	local UIObject ServerTypeOption;
	local name MatchTypeName;

	MatchTypeName = IsConsole(CONSOLE_XBox360) ? 'ServerType360' : 'ServerType';

	// find the "MatchType" control (contains the "LAN" and "Internet" options);  if we aren't signed in online,
	// don't have a link connection, or not allowed to play online, don't allow them to select one.
	PlayerIndex = GetPlayerIndex();
	PlayerControllerID = GetPlayerControllerId( PlayerIndex );
	if (!IsLoggedIn(PlayerControllerId, true) )
	{
		ServerTypeOption = FindChild('ServerType', true);
		if ( ServerTypeOption != None )
		{
			ValueIndex = StringListDataStore.GetCurrentValueIndex(MatchTypeName);
			if ( ValueIndex != class'UTUITabPage_ServerBrowser'.const.SERVERBROWSER_SERVERTYPE_LAN )
			{
				// make sure the "LAN" option is selected
				StringListDataStore.SetCurrentValueIndex(MatchTypeName,class'UTUITabPage_ServerBrowser'.const.SERVERBROWSER_SERVERTYPE_LAN);
				UIDataStoreSubscriber(ServerTypeOption).RefreshSubscriberValue();
			}

			// now disable the widget so it can't be changed.
			UTUIOptionList(ServerTypeOption.GetOwner()).EnableItem(PlayerIndex, ServerTypeOption, false);
		}
	}
}

function string GenerateMutatorURLString()
{
	local DataStoreClient DSClient;
	local UTUIDataStore_MenuItems MenuDataStore;
	local int Idx, MutatorIdx;
	local string MutatorClassName, GameModeString, MutatorURLString;

	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		MenuDataStore = UTUIDataStore_MenuItems(DSClient.FindDataStore('UTMenuItems'));
		if ( MenuDataStore != None )
		{
			// Some mutators are filtered out based on the currently selected gametype, so in order to guarantee
			// that our bitmasks always match up (i.e. between a client and server), clear the setting that mutators
			// use for filtering so that we always get the complete list.  We'll restore it once we're done.
			class'UIRoot'.static.GetDataStoreStringValue("<Registry:SelectedGameMode>", GameModeString);
			class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedGameMode>", "");

			// EnabledMutators should have already been set by UTUITabPage_Mutators
			for ( Idx=0; Idx < MenuDataStore.EnabledMutators.Length; Idx++ )
			{
				MutatorIdx = MenuDataStore.EnabledMutators[Idx];

				// get the class name for the UTUIDataProvider_Mutator instance at Idx in the
				// UTUIDataStore_MenuItems's list of mutator data providers.
				if ( MenuDataStore.GetValueFromProviderSet('Mutators', 'ClassName', MutatorIdx, MutatorClassName)
				&&	MutatorClassName != "" )
				{
					if ( MutatorURLString != "" )
					{
						MutatorURLString $= ",";
					}

					MutatorURLString $= MutatorClassName;
				}
			}

			class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedGameMode>", GameModeString);
		}
	}

	if ( MutatorURLString != "" )
	{
		MutatorURLString = "?Mutator=" $ MutatorURLString;
	}

	return MutatorURLString;
}

/** Called when one of our options changes. */
function OnServerOptionChanged(UIScreenObject InObject, name OptionName, int PlayerIndex)
{
	local UTGameSettingsCommon GameSettings;
	local array<UIDataStore> OutDataStores;
	local int ItemIdx;

	// Setup server options based on server type.
	GameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());

	if(OptionName=='MaxPlayers_PC' || OptionName=='MaxPlayers_Console' || OptionName=='PrivateSlots' || OptionName=='MinNumPlayers_PC' || OptionName=='MinNumPlayers_Console')
	{
		UIDataStorePublisher(InObject).SaveSubscriberValue(OutDataStores);

		if(GameSettings.MaxPlayers < GameSettings.NumPrivateConnections)
		{
			GameSettings.NumPrivateConnections=GameSettings.MaxPlayers;
		}

		if(GameSettings.MinNetPlayers > GameSettings.MaxPlayers)
		{
			GameSettings.MinNetPlayers=GameSettings.MaxPlayers;
		}

		ItemIdx = ServerSettingsTab.OptionList.GetObjectInfoIndexFromName('PrivateSlots');
		if ( ItemIdx != INDEX_NONE )
		{
			UTUISlider(ServerSettingsTab.OptionList.GeneratedObjects[ItemIdx].OptionObj).SliderValue.MaxValue=GameSettings.MaxPlayers;
			UTUISlider(ServerSettingsTab.OptionList.GeneratedObjects[ItemIdx].OptionObj).RefreshSubscriberValue();
		}

		ItemIdx = ServerSettingsTab.OptionList.GetObjectInfoIndexFromName('MinNumPlayers_PC');
		if(ItemIdx != INDEX_NONE)
		{
			UTUISlider(ServerSettingsTab.OptionList.GeneratedObjects[ItemIdx].OptionObj).SliderValue.MaxValue=GameSettings.MaxPlayers;
			UTUISlider(ServerSettingsTab.OptionList.GeneratedObjects[ItemIdx].OptionObj).RefreshSubscriberValue();
		}

		ItemIdx = ServerSettingsTab.OptionList.GetObjectInfoIndexFromName('MinNumPlayers_Console');
		if(ItemIdx != INDEX_NONE)
		{
			UTUISlider(ServerSettingsTab.OptionList.GeneratedObjects[ItemIdx].OptionObj).SliderValue.MaxValue=GameSettings.MaxPlayers;
			UTUISlider(ServerSettingsTab.OptionList.GeneratedObjects[ItemIdx].OptionObj).RefreshSubscriberValue();
		}
	}
	else if ( OptionName == 'DedicatedServer' || OptionName == 'DedicatedServerPS3' )
	{
		UIDataStorePublisher(InObject).SaveSubscriberValue(OutDataStores);
	}

	SetupButtonBar();
}

/** Callback for when the gamemode changes on the game mode selection tab. */
function OnGameModeSelected(string InGameMode, string InDefaultMap, string GameSettingsClass, bool bSelectionSubmitted)
{
	Super.OnGameModeSelected(InGameMode, InDefaultMap, GameSettingsClass, bSelectionSubmitted);

	// Reset bot count to 0
	SetDataStoreStringValue("<UTGameSettings:NumBots>", "0");
}

/** Goal score needs to be refreshed because it has different settings depending on game type. */
function RefreshGoalScoreOption()
{
	local UIObject GoalScoreOption;

	GoalScoreOption = FindChild('GoalScore', true);
	if ( GoalScoreOption != None )
	{
		UIDataStoreSubscriber(GoalScoreOption).RefreshSubscriberValue();
	}
}

/** Sets up the game settings object using the current options. */
function SetupGameSettings()
{
	local int ValueIndex;
	local UTGameSettingsCommon GameSettings;
	local string ServerDescription, MutatorURLString;

	// Setup server options based on server type.
	GameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());

	if(IsConsole(CONSOLE_Xbox360))
	{
		ValueIndex = StringListDataStore.GetCurrentValueIndex('ServerType360');
	}
	else
	{
		ValueIndex = StringListDataStore.GetCurrentValueIndex('ServerType');
	}

	switch(ValueIndex)
	{
	case SERVERTYPE_LAN:
		`Log("UTUIFrontEnd_HostGame::CreateOnlineGame - Setting up a LAN match.",,'DevUI');
		GameSettings.bIsLanMatch=TRUE;
		GameSettings.bUsesArbitration=FALSE;
		break;
	case SERVERTYPE_UNRANKED:
		`Log("UTUIFrontEnd_HostGame::CreateOnlineGame - Setting up an unranked match.",,'DevUI');
		GameSettings.bIsLanMatch=FALSE;
		GameSettings.bUsesArbitration=FALSE;
		break;
	case SERVERTYPE_RANKED:
		`Log("UTUIFrontEnd_HostGame::CreateOnlineGame - Setting up a ranked match.",,'DevUI');
		GameSettings.bIsLanMatch=FALSE;
		GameSettings.bUsesArbitration=TRUE;
		GameSettings.NumPrivateConnections = 0;
		break;
	}

	GameSettings.NumPrivateConnections = Clamp(GameSettings.NumPrivateConnections, 0, GameSettings.MaxPlayers-1);
	GameSettings.NumPublicConnections = GameSettings.MaxPlayers - GameSettings.NumPrivateConnections;

	// initialize the number of open connections to the number of total connections....this will be updated once the match
	// starts as players login
	GameSettings.NumOpenPublicConnections = GameSettings.NumPublicConnections;
	GameSettings.NumOpenPrivateConnections = GameSettings.NumPrivateConnections;

	// apply the selected mutators to the game settings object
	MutatorURLString = GenerateMutatorURLString();
	GameSettings.SetMutators(MutatorURLString);

	// Set the map name we are playing on.
	SetDataStoreStringValue("<UTGameSettings:CustomMapName>", MapTab.GetFirstMap());
	SetDataStoreStringValue("<UTGameSettings:CustomGameMode>", GameMode);

	// Set server description
	if(GetDataStoreStringValue("<OnlinePlayerData:ProfileData.ServerDescription>",ServerDescription,self,GetPlayerOwner()))
	{
		SetDataStoreStringValue("<UTGameSettings:ServerDescription>", ServerDescription);
	}
	else
	{
		SetDataStoreStringValue("<UTGameSettings:ServerDescription>", "");
	}

	// Set server MOTD
	GetDataStoreStringValue("<Registry:ServerMOTD>", class'UTGameReplicationInfo'.default.MessageOfTheDay);

}

/** Creates the online game and travels to the map we are hosting a server on. */
function CreateOnlineGame(int PlayerIndex)
{
	local OnlineSubsystem OnlineSub;
	local OnlineGameInterface GameInterface;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the game interface to verify the subsystem supports it
		GameInterface = OnlineSub.GameInterface;
		if (GameInterface != None)
		{
			// Play the startgame sound
			PlayUISound('StartGame');

			// Sets up the game settings object
			SetupGameSettings();

			// Create the online game
			GameInterface.AddCreateOnlineGameCompleteDelegate(OnGameCreated);

			if(SettingsDataStore.CreateGame(GetPlayerControllerId(PlayerIndex))==FALSE )
			{
				GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);
				`Log("UTUIFrontEnd_HostGame::CreateOnlineGame - Failed to create online game.");
			}
		}
		else
		{
			`Log("UTUIFrontEnd_HostGame::CreateOnlineGame - No GameInterface found.");
		}
	}
	else
	{
		`Log("UTUIFrontEnd_HostGame::CreateOnlineGame - No OnlineSubSystem found.");
	}
}

/** Callback for when the game is finish being created. */
function OnGameCreated(name SessionName,bool bWasSuccessful)
{
	local OnlineGameSettings GameSettings;
	local string TravelURL;
	local OnlineSubsystem OnlineSub;
	local OnlineGameInterface GameInterface;
	local string Mutators;
	local int OutValue;
	local string OutStringValue;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the game interface to verify the subsystem supports it
		GameInterface = OnlineSub.GameInterface;
		if (GameInterface != None)
		{
			// Clear the delegate we set.
			GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);

			// If we were successful, then travel.
			if(bWasSuccessful)
			{
				// Setup server options based on server type.
				GameSettings = SettingsDataStore.GetCurrentGameSettings();

				GameSettings.bIsDedicated = StringListDataStore.GetCurrentValueIndex('DedicatedServer') == 1;

				// append options from the OnlineGameSettings class
				GameSettings.BuildURL(TravelURL);
				if ( IsConsole(CONSOLE_PS3) && GameSettings.bIsDedicated )
				{
					TravelURL $= "?Dedicated";
				}

				if(IsConsole(CONSOLE_Ps3))
				{
					if(StringListDataStore.GetCurrentValueIndex('DedicatedServer')==1)
					{
						TravelURL $= "?Dedicated";
					}
				}

				// Append server password if we have one
				if(GetDataStoreStringValue("<Registry:ServerPassword>", OutStringValue) && Len(OutStringValue)>0)
				{
					TravelURL $= "?GamePassword=" $ StripInvalidPasswordCharacters(OutStringValue);
					GameSettings.SetStringSettingValue(CONTEXT_LOCKEDSERVER, CONTEXT_LOCKEDSERVER_YES, false);
				}
				else
				{
					GameSettings.SetStringSettingValue(CONTEXT_LOCKEDSERVER, CONTEXT_LOCKEDSERVER_NO, false);
				}

				// Num play needs to be the number of bots + 1 (the player).
				if(GameSettings.GetIntProperty(PROPERTY_NUMBOTS, OutValue))
				{
					TravelURL $= "?NumPlay=" $ (OutValue+1);
				}

				// append the game mode
				TravelURL $= "?game=" $ GameMode;

				// Append any mutators
				Mutators = class'UTUIFrontEnd_Mutators'.static.GetEnabledMutators();
				if(Len(Mutators) > 0)
				{
					TravelURL $= "?mutator=" $ Mutators;
				}

				// Append Extra Common Options
				TravelURL $= GetCommonOptionsURL();

				TravelURL = "open " $ MapTab.GetFirstMap() $ TravelURL $ "?listen";

				//`Log("UTUIFrontEnd_HostGame::OnGameCreated - Game Created, Traveling: " $ TravelURL);

				// Do the server travel.
				ConsoleCommand(TravelURL);
			}
			else
			{
				`Log("UTUIFrontEnd_HostGame::OnGameCreated - Game Creation Failed.");
			}
		}
		else
		{
			`Log("UTUIFrontEnd_HostGame::OnGameCreated - No GameInterface found.");
		}
	}
	else
	{
		`Log("UTUIFrontEnd_HostGame::OnGameCreated - No OnlineSubSystem found.");
	}
}

/** Callback for when the user has accepted server settings. */
function OnAcceptServerSettings(UIScreenObject InObject, int PlayerIndex)
{
	ShowNextTab();
}


/** Attempts to start a dedicated server. */
function OnStartDedicated()
{
	// Make sure the user wants to start the game.
	local UDKUIScene_MessageBox MessageBoxReference;
	local array<string> MessageBoxOptions;

	if(MapTab.CanBeginMatch())
	{
		MessageBoxReference = GetMessageBoxScene();

		if(MessageBoxReference != none)
		{
			MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.StartDedicated>");
			MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.Cancel>");

			MessageBoxReference.SetPotentialOptions(MessageBoxOptions);
			MessageBoxReference.Display("<Strings:UTGameUI.MessageBox.StartDedicated_Message>", "<Strings:UTGameUI.MessageBox.StartDedicated_Title>", OnStartDedicated_Confirm);
		}
	}
}

/** Callback for the start game message box. */
function OnStartDedicated_Confirm(UDKUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	// If they want to start the game, then create the online game.
	if(SelectedOption==0)
	{
		FinishStartDedicated();
	}
}

/** Actually starts the dedicated server. */
function FinishStartDedicated()
{
	local OnlineGameSettings GameSettings;
	local string TravelURL;
	local string Mutators;
	local int OutValue;
	local string Password;

	// Setup server options based on server type.
	GameSettings = SettingsDataStore.GetCurrentGameSettings();

	// Saves out the widget's values to the datastore.
	SaveSceneDataValues(FALSE);

	// Setup the game settings object with basic settings
	SetupGameSettings();

	// @todo: Is this the correct URL to use?
	GameSettings.BuildURL(TravelURL);

	// Append server password if we have one
	if(GetDataStoreStringValue("<Registry:ServerPassword>", Password) && Len(Password)>0)
	{
		TravelURL $= "?GamePassword=" $ StripInvalidPasswordCharacters(Password);
		GameSettings.SetStringSettingValue(CONTEXT_LOCKEDSERVER, CONTEXT_LOCKEDSERVER_YES, false);
	}
	else
	{
		GameSettings.SetStringSettingValue(CONTEXT_LOCKEDSERVER, CONTEXT_LOCKEDSERVER_NO, false);
	}

	// Num play needs to be the number of bots + 1 (the player).
	if(GameSettings.GetIntProperty(PROPERTY_NUMBOTS, OutValue))
	{
		TravelURL $= "?NumPlay=" $ (OutValue+1);
	}

	TravelURL $= "?game=" $ GameMode;

	// Append any mutators
	Mutators = class'UTUIFrontEnd_Mutators'.static.GetEnabledMutators();
	if(Len(Mutators) > 0)
	{
		TravelURL $= "?mutator=" $ Mutators;
	}

	// Append Extra Common Options (i.e. name,
	TravelURL $= GetCommonOptionsURL();

	// Setup dedicated server
	StartDedicatedServer(MapTab.GetFirstMap() $ TravelURL);
}

/** Attempts to start an instant action game. */
function OnStartGame()
{
	// Make sure the user wants to start the game.
	local OnlineGameSettings GameSettings;

	if(MapTab.CanBeginMatch())
	{
		// Force widgets to save out their values to their respective datastores.
		SaveSceneDataValues(FALSE);

		GameSettings = SettingsDataStore.GetCurrentGameSettings();
		if ( GameSettings.bIsDedicated && !IsConsole() )
		{
			OnStartDedicated();
		}
		else
		{
			OnStartGame_Confirm(None, 0, GetBestPlayerIndex());
		}
	}
}

/** Callback for the start game message box. */
function OnStartGame_Confirm(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	// If they want to start the game, then create the online game.
	if(SelectedOption==0)
	{
		CreateOnlineGame(PlayerIndex);
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
	local UTUITabPage_Options CurrentPage;
	bResult = Super.HandleInputKey(EventParms);

	CurrentPage=UTUITabPage_Options(TabControl.ActivePage);
	if(bResult == false)
	{
		if(CurrentPage!=None && EventParms.InputKeyName=='XboxTypeS_X')
		{
			CurrentPage.OnShowKeyboard();
			bResult=true;
		}
	}

	return bResult;
}

defaultproperties
{
	bRequiresNetwork=true
}
