/**********************************************************************

Filename    :   GFxUDKFrontEnd_HostGame.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of the Host Game view. Logic within this
                class is unique to Host Game and is not shared with 
                Instant Action, which also inherits from LaunchGame.

                Associated Flash content: udk_instant_action.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_HostGame extends GFxUDKFrontEnd_LaunchGame
    config(UI);

const SERVERTYPE_LAN = 0;
const SERVERTYPE_UNRANKED = 1;
const SERVERTYPE_RANKED = 2;

//@todo: This should probably be INI set.
const MAXIMUM_PLAYER_COUNT = 24;

function OnViewActivated()
{        
    Super.OnViewActivated();

    // Whether or not we are starting a standalone game
	class'UIRoot'.static.SetDataStoreStringValue("<Registry:StandaloneGame>", "0");

	// Host game defaults
	class'UIRoot'.static.SetDataStoreStringValue("<UTGameSettings:NumBots>", "0");
   	class'UIRoot'.static.SetDataStoreStringValue("<Registry:ServerMOTD>", class'UTGameReplicationInfo'.default.MessageOfTheDay);
	class'UIRoot'.static.SetDataStoreStringValue("<Registry:ServerPassword>", "");

    ValidateServerType();
}

function OnTopMostView(optional bool bPlayOpenAnimation = false)
{
    super.OnTopMostView(bPlayOpenAnimation);
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
	local name MatchTypeName;

	MatchTypeName = class'UIRoot'.static.IsConsole(CONSOLE_XBox360) ? 'ServerType360' : 'ServerType';

	// find the "MatchType" control (contains the "LAN" and "Internet" options);  if we aren't signed in online,
	// don't have a link connection, or not allowed to play online, don't allow them to select one.
	PlayerIndex = GetPlayerIndex();
	PlayerControllerID = GetPlayerControllerId( PlayerIndex );
	if ( !IsLoggedIn(PlayerControllerId, true) )
	{
		ValueIndex = StringListDataStore.GetCurrentValueIndex(MatchTypeName);
		if ( ValueIndex != class'UTUITabPage_ServerBrowser'.const.SERVERBROWSER_SERVERTYPE_LAN )
		{
			// make sure the "LAN" option is selected
			StringListDataStore.SetCurrentValueIndex(MatchTypeName, 
			                                         class'UTUITabPage_ServerBrowser'.const.SERVERBROWSER_SERVERTYPE_LAN);		
		}
        // Disable the widget so it cannot be changed ?
	}
}

function string GenerateMutatorURLString()
{
	local DataStoreClient DSClient;	
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

/** Setup the GameSettings object using the current options. */
function SetupGameSettings()
{
	local int ValueIndex;
	local UTGameSettingsCommon GameSettings;
    local string SelectedMap, SelectedGameMode;
	local string ServerDescription, MutatorURLString;

	// Setup server options based on server type.
	GameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());
	if(class'UIRoot'.static.IsConsole(CONSOLE_Xbox360))
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

    // @todo sf: Just using SelectedMapName/SelectedGameMode here... Not sure how CustomMaps are handled.
	class'UIRoot'.static.GetDataStoreStringValue("<Registry:SelectedMap>", SelectedMap);
    class'UIRoot'.static.GetDataStoreStringValue("<Registry:SelectedGameMode>", SelectedGameMode);
    
	// Set the map name we are playing on.
	class'UIRoot'.static.SetDataStoreStringValue("<UTGameSettings:CustomMapName>", SelectedMap);
	class'UIRoot'.static.SetDataStoreStringValue("<UTGameSettings:CustomGameMode>", SelectedGameMode);

	// Set server description
	if(class'UIRoot'.static.GetDataStoreStringValue("<OnlinePlayerData:ProfileData.ServerDescription>", ServerDescription,
	                                                none, GetPlayerOwner()))
	{
		class'UIRoot'.static.SetDataStoreStringValue("<UTGameSettings:ServerDescription>", ServerDescription);
	}
	else
	{
		class'UIRoot'.static.SetDataStoreStringValue("<UTGameSettings:ServerDescription>", "");
	}

	// Set server MOTD
	class'UIRoot'.static.GetDataStoreStringValue("<Registry:ServerMOTD>", class'UTGameReplicationInfo'.default.MessageOfTheDay);
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
			// PlayUISound('StartGame');

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
	local OnlineGameSettings LocalGameSettings;
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
				LocalGameSettings = SettingsDataStore.GetCurrentGameSettings();

				LocalGameSettings.bIsDedicated = StringListDataStore.GetCurrentValueIndex('DedicatedServer') == 1;

				// append options from the OnlineGameSettings class
				LocalGameSettings.BuildURL(TravelURL);
				if ( class'UIRoot'.static.IsConsole(CONSOLE_PS3) && LocalGameSettings.bIsDedicated )
				{
					TravelURL $= "?Dedicated";
				}

				if(class'UIRoot'.static.IsConsole(CONSOLE_Ps3))
				{
					if(StringListDataStore.GetCurrentValueIndex('DedicatedServer')==1)
					{
						TravelURL $= "?Dedicated";
					}
				}

				// Append server password if we have one
				if(class'UIRoot'.static.GetDataStoreStringValue("<Registry:ServerPassword>", OutStringValue) && Len(OutStringValue)>0)
				{
					TravelURL $= "?GamePassword=" $ StripInvalidPasswordCharacters(OutStringValue);
					LocalGameSettings.SetStringSettingValue(CONTEXT_LOCKEDSERVER, CONTEXT_LOCKEDSERVER_YES, false);
				}
				else
				{
					LocalGameSettings.SetStringSettingValue(CONTEXT_LOCKEDSERVER, CONTEXT_LOCKEDSERVER_NO, false);
				}

				// Num play needs to be the number of bots + 1 (the player).
				if(LocalGameSettings.GetIntProperty(PROPERTY_NUMBOTS, OutValue))
				{
					TravelURL $= "?NumPlay=" $ (OutValue+1);
				}

				// append the game mode
				TravelURL $= "?game=" $ GetStringFromMarkup("<Registry:SelectedGameMode>");

				// Append any mutators
				Mutators = class'GFxUDKFrontEnd_Mutators'.static.GetEnabledMutators();
				if(Len(Mutators) > 0)
				{
					TravelURL $= "?mutator=" $ Mutators;
				}

				// Append Extra Common Options
				TravelURL $= GetCommonOptionsURL();

				TravelURL = "open " $ GetStringFromMarkup("<Registry:SelectedMap>") $ TravelURL $ "?listen";

				`Log("UTUIFrontEnd_HostGame::OnGameCreated - Game Created, Traveling: " $ TravelURL);

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

/** Actually starts the dedicated server. */
function FinishStartDedicated()
{
	local OnlineGameSettings LocalGameSettings;
	local string TravelURL;
	local string Mutators;
	local int OutValue;
	local string Password;

	// Setup server options based on server type.
	LocalGameSettings = SettingsDataStore.GetCurrentGameSettings();

	// Setup the game settings object with basic settings
	SetupGameSettings();

	// @todo: Is this the correct URL to use?
	LocalGameSettings.BuildURL(TravelURL);

	// Append server password if we have one
	if(class'UIRoot'.static.GetDataStoreStringValue("<Registry:ServerPassword>", Password) && Len(Password)>0)
	{
		TravelURL $= "?GamePassword=" $ StripInvalidPasswordCharacters(Password);
		LocalGameSettings.SetStringSettingValue(CONTEXT_LOCKEDSERVER, CONTEXT_LOCKEDSERVER_YES, false);
	}
	else
	{
		LocalGameSettings.SetStringSettingValue(CONTEXT_LOCKEDSERVER, CONTEXT_LOCKEDSERVER_NO, false);
	}

	// Num play needs to be the number of bots + 1 (the player).
	if(LocalGameSettings.GetIntProperty(PROPERTY_NUMBOTS, OutValue))
	{
		TravelURL $= "?NumPlay=" $ (OutValue+1);
	}

	TravelURL $= "?game=" $ GetStringFromMarkup("<Registry:SelectedGameMode>");

	// Append any mutators
	Mutators = class'UTUIFrontEnd_Mutators'.static.GetEnabledMutators();
	if(Len(Mutators) > 0)
	{
		TravelURL $= "?mutator=" $ Mutators;
	}

	// Append Extra Common Options (i.e. name,
	TravelURL $= GetCommonOptionsURL();

	// Setup dedicated server
    // @todo sf: Starting a dedicated server needs to be added as a native method (GFxUIView / MoviePlayer?)
	//StartDedicatedServer(GetStringFromMarkup("<Registry:SelectedMap>") $ TravelURL);
}


/** Attempts to start an instant action game. */
function OnStartGame_Confirm()
{
	// Make sure the user wants to start the game.
	local OnlineGameSettings LocalGameSettings;

	LocalGameSettings = SettingsDataStore.GetCurrentGameSettings();
	if ( LocalGameSettings.bIsDedicated && !class'UIRoot'.static.IsConsole() )
	{
		FinishStartDedicated();
	}
	else
	{
		CreateOnlineGame( 0 /* None, 0, GetBestPlayerIndex() */ );
	}
}



DefaultProperties
{
	bRequiresNetwork=TRUE
}
