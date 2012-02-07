/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Instant Action scene for UT3.
 */
class UTUIFrontEnd_InstantAction extends UTUIFrontEnd_LaunchGame;

/** PostInitialize event - Sets delegates for the scene. */
event PostInitialize()
{
	Super.PostInitialize();

	// Insert tab pages
	TabControl.InsertPage(GameModeTab, 0, 0, true);
	TabControl.InsertPage(MapTab, 0, 1, false);
	TabControl.InsertPage(GameSettingsTab, 0, 2, false);

	// Whether or not we are starting a standalone game
	SetDataStoreStringValue("<Registry:StandaloneGame>", "1");

	// Setup the default button bar.
	SetupButtonBar();
}

/** Attempts to start an instant action game. */
function OnStartGame()
{
	// Make sure the user wants to start the game.
	local UDKUIScene_MessageBox MessageBoxReference;

	if( MapTab.CanBeginMatch() )
	{
		MessageBoxReference = GetMessageBoxScene();
		OnStartGame_Confirm(MessageBoxReference, 0, 0);
	}
}

/** Callback for the start game message box. */
function OnStartGame_Confirm(UDKUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	local Settings GameSettings;
	local string URL;
	local string GameExec;
	local string Mutators;
	local int OutValue;

	if(SelectedOption==0)
	{
		// Play the startgame sound
		PlayUISound('StartGame');

		// Save scene settings values
		SaveSceneDataValues(FALSE);

		// Generate settings URL
		GameSettings = SettingsDataStore.GetCurrentGameSettings();
		GameSettings.SetStringSettingValue(CONTEXT_VSBOTS,CONTEXT_VSBOTS_NONE,FALSE);
		GameSettings.BuildURL(URL);

		// Num play needs to be the number of bots + 1 (the player).
		if(GameSettings.GetIntProperty(PROPERTY_NUMBOTS, OutValue))
		{
			URL $= "?NumPlay=" $(OutValue+1);
		}

		// Append any mutators
		Mutators = class'UTUIFrontEnd_Mutators'.static.GetEnabledMutators();
		if(Len(Mutators) > 0)
		{
			URL = URL $ "?mutator=" $ Mutators;
		}

		URL = URL $ GetCommonOptionsURL();

		// Start the game.
		GameExec = "open " $ MapTab.GetFirstMap() $ "?game=" $ GameMode $ URL;
		`Log("UTUIFrontEnd: Starting Game..." $ GameExec);
		ConsoleCommand(GameExec);
	}
}
