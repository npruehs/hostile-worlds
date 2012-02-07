/**
 * UTEntryPlayerController
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTEntryPlayerController extends UTPlayerController
	config(Game);

var PostProcessChain EntryPostProcessChain;
var array<PostProcessChain> OldPostProcessChain;
var LocalPlayer OldPlayer;

event InitInputSystem()
{
	// Need to bypass the UTPlayerController since it initializes voice and we do not want to do that in the menus.
	Super(GamePlayerController).InitInputSystem();

	AddOnlineDelegates(false);

	// we do this here so that we only bother to create it for local players
	CameraAnimPlayer = new(self) class'CameraAnimInst';

	if (EntryPostProcessChain != None)
	{
		// Store the old post process chains
		if(OldPostProcessChain.length==0)
		{
			OldPostProcessChain = LocalPlayer(Player).PlayerPostProcessChains;
			OldPlayer = LocalPlayer(Player);
		}

		// Remove all post processing chains for the player
		LocalPlayer(Player).RemoveAllPostProcessingChains();
		LocalPlayer(Player).InsertPostProcessingChain(EntryPostProcessChain, -1, FALSE);
	}
}

simulated function RestorePostProcessing()
{
	local int PPIdx;

	// Restore the old post process chain if we removed it
	if( (OldPlayer != None) && (EntryPostProcessChain != none) )
	{
		OldPlayer.RemoveAllPostProcessingChains();

		for(PPIdx=0; PPIdx<OldPostProcessChain.length; PPIdx++)
		{
			OldPlayer.InsertPostProcessingChain(OldPostProcessChain[PPIdx], -1, true);
		}
		OldPostProcessChain.length = 0;
		OldPlayer = None;
	}
}

/** Destroyed event for the PC, resets the post process chain to normal. */
simulated event Destroyed()
{
	RestorePostProcessing();

	Super.Destroyed();
}

/**
 * Attempts to pause/unpause the game when a controller becomes
 * disconnected/connected
 *
 * @param ControllerId the id of the controller that changed
 * @param bIsConnected whether the controller is connected or not
 */
function OnControllerChanged(int ControllerId,bool bIsConnected)
{
	local LocalPlayer LocPlayer;
	// Don't worry about remote players
	LocPlayer = LocalPlayer(Player);
	// If the controller that changed, is attached to the this playercontroller
	if (WorldInfo.IsConsoleBuild() && LocPlayer != None && LocPlayer.ControllerId == ControllerId)
	{
		bIsControllerConnected = bIsConnected;

		//@todo fix this to work again once UI changes are merged back into main
// 		if(bIsConnected)
// 		{
// 			class'UTUIScene'.static.ClearScreenWarningMessage();
// 		}
// 		else
// 		{
// 			class'UTUIScene'.static.ShowScreenWarningMessage(Localize("ToastMessages","ReconnectController","UTGameUI")$" ("$(ControllerId+1)$")");
// 		}
	}
}

/** Callback for when a game invite has been received. */
function OnGameInviteReceived(byte LocalUserNum,string RequestingNick)
{
}


/** Callback for when a friend request has been received. */
function OnFriendInviteReceived(byte LocalUserNum,UniqueNetId RequestingPlayer,string RequestingNick,string Message)
{
}

/**
 * Called when a friend invite arrives for a local player
 *
 * @param LocalUserNum the user that is receiving the invite
 * @param SendingPlayer the player sending the friend request
 * @param SendingNick the nick of the player sending the friend request
 * @param Message the message to display to the recipient
 *
 * @return true if successful, false otherwise
 */
function OnFriendMessageReceived(byte LocalUserNum,UniqueNetId SendingPlayer,string SendingNick,string Message)
{
}

`if(`notdefined(ShippingPC))
`define	debugexec exec
`else
`define debugexec
`endif

/**
 * Called when a system level connection change notification occurs. If we are
 * playing a match through the platform's online service, we may need to notify and
 * go back to the menu. Otherwise silently ignore this.
 *
 * @param ConnectionStatus the new connection status.
 */
`{debugexec} function OnConnectionStatusChange(EOnlineServerConnectionStatus ConnectionStatus)
{
	local GameUISceneClient SceneClient;
	local bool bInvalidConnectionStatus;
	local string OutValue;

	// Only handle the error if we arent currently creating a profile.
	if(class'UIRoot'.static.GetDataStoreStringValue("<Registry:CreatingProfile>",OutValue)==false || OutValue!="1")
	{
		// Determine whether the connection status change requires us to drop and go to the menu
		switch (ConnectionStatus)
		{
		case OSCS_DuplicateLoginDetected:
			// Two people can't play or badness will happen
			`Log("Detected another user logging-in with this profile.");

			// now set an error message to be displayed to the user
			SetFrontEndErrorMessage("<Strings:UTGameUI.Errors.DuplicateLogin_Title>",
				"<Strings:UTGameUI.Errors.DuplicateLogin_Message>");

			bInvalidConnectionStatus = true;
			break;

		case OSCS_ConnectionDropped:
		case OSCS_NoNetworkConnection:
		case OSCS_UpdateRequired:
		case OSCS_ServersTooBusy:
			// set an error message to be displayed to the user
			SetFrontEndErrorMessage("<Strings:UTGameUI.Errors.ConnectionLost_Title>",
				"<Strings:UTGameUI.Errors.ConnectionLost_Message>");

			bInvalidConnectionStatus = true;
			break;

		case OSCS_ServiceUnavailable:
			SetFrontEndErrorMessage("<Strings:UTGameUI.Errors.ServiceUnavailable_Title>", "<Strings:UTGameUI.Errors.ServiceUnavailable_Message>");
			bInvalidConnectionStatus = true;
			break;
		}

		// notify the UI scene client, which will propagate the notification to all scenes.  Any scenes
		// which require a valid online service will close themselves.
		SceneClient = class'UIRoot'.static.GetSceneClient();
		if ( SceneClient != None )
		{
			SceneClient.NotifyOnlineServiceStatusChanged(ConnectionStatus);
		}

		`log(`location@`showenum(EOnlineServerConnectionStatus,ConnectionStatus)@`showvar(bInvalidConnectionStatus),,'DevOnline');
		if ( bInvalidConnectionStatus )
		{
			// finalize
			QuitToMainMenu();
		}
	}
}

/**
 * Called when the platform's network link status changes.  If we are playing a match on a remote server, we need to go back
 * to the front end menus and notify the player.
 */
`{debugexec} function OnLinkStatusChanged( bool bConnected )
{
	local GameUISceneClient SceneClient;
	local string ErrorDisplay;

	`log(`location@`showvar(bConnected),,'DevNet');

	// notify the UI scene client, which will propagate the notification to all scenes.  Any scenes
	// which require a valid network connection will close themselves.
	SceneClient = class'UIRoot'.static.GetSceneClient();
	if ( SceneClient != None )
	{
		SceneClient.NotifyLinkStatusChanged(bConnected);
	}

	if ( !bConnected )
	{
		// if we're no longer connected to the network, check to see if another error message has been set
		// only display our message if none are currently set.
		if (!class'UIRoot'.static.GetDataStoreStringValue("<Registry:FrontEndError_Display>", ErrorDisplay)
		||	int(ErrorDisplay) == 0 )
		{
			SetFrontEndErrorMessage("<Strings:UTGameUI.Errors.Error_Title>", "<Strings:UTGameUI.Errors.NetworkLinkLost_Message>");
			QuitToMainMenu();
		}
	}
}

/** Called when returning to the main menu. */
function QuitToMainMenu()
{
	local GameUISceneClient SceneClient;
	local UTUIFrontEnd Scene;

	`Log("UTEntryPlayerController::QuitToMainMenu() - Quitting to main menu.");

	if(GetURLMap()=="UTFrontEnd" || GetURLMap()=="UDKFrontEndMap")
	{
		OnlineSub.GameInterface.DestroyOnlineGame('Game');

		SceneClient = class'UIRoot'.static.GetSceneClient();
		if ( SceneClient != None && SceneClient.IsUIActive() )
		{
			foreach SceneClient.AllActiveScenes(class'UTUIFrontEnd', Scene, true)
			{
				Scene.SetupButtonBar();
				Scene.CheckForFrontEndError();
				break;
			}
		}
	}
	else
	{
		Super.QuitToMainMenu();
	}
}

function LoadCharacterFromProfile(UTProfileSettings Profile);	// Do nothing
function SetPawnConstructionScene(bool bShow);	// Do nothing
function UTUIScene_MidGameMenu ShowMidGameMenu(optional name TabTag,optional bool bEnableInput);
function ShowScoreboard();

exec function UnlockChapter(int ChapterIndex)
{
	local UTProfileSettings Profile;
	Profile = UTProfileSettings(OnlinePlayerData.ProfileProvider.Profile);
	if (Profile != none)
	{
		Profile.UnlockChapter(ChapterIndex);
	}
}

defaultproperties
{
	EntryPostProcessChain=PostProcessChain'FX_HitEffects.UTMenuPostProcess'
}
