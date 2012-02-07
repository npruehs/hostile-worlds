/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Multiplayer Scene for UT3.
 */

class UTUIFrontEnd_Multiplayer extends UTUIFrontEnd_BasicMenu
	dependson(UTUIScene_MessageBox);

const MULTIPLAYER_OPTION_JOINGAME = 0;
const MULTIPLAYER_OPTION_HOSTGAME = 1;

/** Reference to the host game scene. */
var string	HostScene;

/** Reference to the join game scene. */
var string	JoinScene;

/* PlayerInterfaceEx reference. */
var transient OnlinePlayerInterfaceEx PlayerInterfaceEx;	

/** Reference to the label which displays the number of people playing this game, globally */
var	transient UILabel NumberOfCurrentPlayersLabel;

/**
 * Executes a action based on the currently selected menu item.
 */
function OnSelectItem(int PlayerIndex=GetPlayerIndex())
{
	local int SelectedItem;

	if ( ButtonBar.Buttons[1].IsEnabled(PlayerIndex) )
	{
		SelectedItem = MenuList.GetCurrentItem();
		switch(SelectedItem)
		{
		case MULTIPLAYER_OPTION_HOSTGAME:
			if ( CheckLinkConnectionAndError() )
			{
				OpenSceneByName(HostScene);
			}
			break;

		case MULTIPLAYER_OPTION_JOINGAME:
			if ( CheckLinkConnectionAndError() )
			{
				OpenSceneByName(Joinscene, false, OnJoinLanScene_Opened);
			}
			break;
		}
	}
}

/** Callback for when the join scene has opened for LAN. */
function OnJoinLanScene_Opened(UIScene OpenedScene, bool bInitialActivation)
{
	local UTUIFrontEnd_JoinGame JoinSceneInst;

	// Set a string value to indicate that this is a LAN client, so the
	// UI is aware of this after we disconnect from the server
	SetDataStoreStringValue("<Registry:LanClient>", "1");

	JoinSceneInst = UTUIFrontEnd_JoinGame(OpenedScene);
	if ( JoinSceneInst != none && bInitialActivation )
	{
		JoinSceneInst.UseLANMode();
	}
}

/** Callback for when the user wants to back out of this screen. */
function OnBack()
{
	if ( ButtonBar.Buttons[0].IsEnabled(GetPlayerIndex()) )
	{
		Super.OnBack();
	}
}

/** Called when the OnlineSubsystem figures out (or can't figure out) how many global players there are. */
function OnGetNumberOfCurrentPlayersComplete(int TotalPlayers)
{
	if (NumberOfCurrentPlayersLabel != None)
	{
		// may be -1 if we don't/can't know.
		if (TotalPlayers == -1)
		{
			NumberOfCurrentPlayersLabel.SetVisibility(false);  // just don't show the information.
		}
		else
		{
			// !!! FIXME: this should use localization and the data store!
			NumberOfCurrentPlayersLabel.SetValue(TotalPlayers$" global players");
			NumberOfCurrentPlayersLabel.SetVisibility(true);
		}
	}
}

event SceneActivated( bool bInitialActivation )
{
//	local OnlineSubsystem OnlineSub;

	Super.SceneActivated(bInitialActivation);

	NumberOfCurrentPlayersLabel = UILabel(FindChild('lblNumberPlayers', true));
	if (NumberOfCurrentPlayersLabel != None)
	{
		NumberOfCurrentPlayersLabel.SetVisibility(false);   // hide until we have an answer.

// Disabled the steamworks specific calls until it can be done in a clean crossplatform way
/*		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			PlayerInterfaceEx = OnlineSub.PlayerInterfaceEx;
			if (PlayerInterfaceEx != None)
			{
				PlayerInterfaceEx.AddGetNumberOfCurrentPlayersCompleteDelegate(OnGetNumberOfCurrentPlayersComplete);
				PlayerInterfaceEx.GetNumberOfCurrentPlayers();  // trigger an async query.
			}
		}*/
	}
}

event SceneDeactivated()
{
	Super.SceneDeactivated();
// Disabled the steamworks specific calls until it can be done in a clean crossplatform way
/*	if ( PlayerInterfaceEx != None )
	{
		PlayerInterfaceEx.ClearGetNumberOfCurrentPlayersCompleteDelegate(OnGetNumberOfCurrentPlayersComplete);
	}*/

	UTGameUISceneClient(GetSceneClient()).bDimScreen=false;
}

defaultproperties
{
	JoinScene="UI_Scenes_FrontEnd.Scenes.JoinGame"
	HostScene="UI_Scenes_ChrisBLayout.Scenes.HostGame"
	bMenuLevelRestoresScene=true
	bRequiresNetwork=true
}
