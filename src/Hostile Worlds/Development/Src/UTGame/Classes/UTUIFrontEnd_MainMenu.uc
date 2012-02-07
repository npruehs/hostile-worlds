/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Main Menu Scene for UT3.
 */

class UTUIFrontEnd_MainMenu extends UTUIFrontEnd_BasicMenu;

const MAINMENU_OPTION_INSTANTACTION = 0;
const MAINMENU_OPTION_MULTIPLAYER = 1;
const MAINMENU_OPTION_EXIT = 2;

/** Reference to the instant action scene. */
var string	InstantActionScene;

/** Reference to the multiplayer scene. */
var string	MultiplayerScene;

/** Callback for when the show animation has completed for this scene. */
function OnMainRegion_Show_UIAnimEnd( UIScreenObject AnimTarget, name AnimName, int TrackTypeMask )
{
	local GameUISceneClient GameSceneClient;

	`log(`location @ `showobj(AnimTarget) @ `showvar(AnimName) @ `showvar(TrackTypeMask),TrackTypeMask==0,'DevUIAnimation');
	Super.OnMainRegion_Show_UIAnimEnd(AnimTarget, AnimName, TrackTypeMask);

	// AnimIndex of 0 corresponds to the 'SceneShowInitial' animation
	if ( AnimName == 'SceneShowInitial' )
	{
		GameSceneClient = GetSceneClient();
		if ( GameSceneClient != None )
		{
			GameSceneClient.ClearMenuProgression();
		}
		CheckForFrontEndError();
	}
}

/** Callback for when the multiplayer screen has opened (only called when returning to the server browser after a disconnect). */
function OnMultiplayerScreenOpened(UIScene OpenedScene, bool bInitialActivation)
{
	local UTUIFrontEnd_Multiplayer MPScene;

	MPScene = UTUIFrontEnd_Multiplayer(OpenedScene);

	if (MPScene != none)
		MPScene.OpenSceneByName(MPScene.JoinScene, True);
}

event SceneActivated(bool bInitialActivation)
{
	Super.SceneActivated(bInitialActivation);

	`log(`location@`showvar(bInitialActivation),,'DevUI');
	if ( !bInitialActivation )
	{
		MenuList.SetFocus(None);
		SetupButtonBar();
	}
}

/** Setup the scene's buttonbar. */
function SetupButtonBar()
{
	ButtonBar.Clear();
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Select>", OnButtonBar_Select);
}

/**
 * Executes a action based on the currently selected menu item.
 */
function OnSelectItem(int PlayerIndex=0)
{
	local int SelectedItem;

	SelectedItem = MenuList.GetCurrentItem();

	switch(SelectedItem)
	{
		case MAINMENU_OPTION_INSTANTACTION:
			OpenSceneByName(InstantActionScene);
			break;

		case MAINMENU_OPTION_MULTIPLAYER:
			if ( CheckLinkConnectionAndError() )
			{
				OpenSceneByName(MultiplayerScene);
			}
			break;

		case MAINMENU_OPTION_EXIT:
			OnMenu_ExitGame();
			break;
	}
}

/** Exit game option selected. */
function OnMenu_ExitGame()
{
	local array<string> MessageBoxOptions;
	local UDKUIScene_MessageBox MessageBoxReference;

	MessageBoxReference = GetMessageBoxScene();
	if(MessageBoxReference != none)
	{
		MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.ExitGame>");
		MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.Cancel>");

		MessageBoxReference.SetPotentialOptions(MessageBoxOptions);
		MessageBoxReference.Display("<Strings:UTGameUI.MessageBox.ExitGame_Message>", "<Strings:UTGameUI.MessageBox.ExitGame_Title>", OnMenu_ExitGame_Confirm, 1);
	}
}

/** Confirmation for the exit game dialog. */
function OnMenu_ExitGame_Confirm(UDKUIScene_MessageBox MessageBox, int SelectedItem, int PlayerIndex)
{
	if( SelectedItem == 0 )
	{
		ConsoleCommand("quit");
	}
}


defaultproperties
{
	bSupportBackButton=false
	InstantActionScene="UI_Scenes_ChrisBLayout.Scenes.InstantAction"
	MultiplayerScene="UI_Scenes_ChrisBLayout.Scenes.Multiplayer""
}
