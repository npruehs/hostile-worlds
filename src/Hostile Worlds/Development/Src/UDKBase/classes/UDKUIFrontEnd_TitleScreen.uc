/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Title screen scene for UT3, handles attract mode launching.
 */

class UDKUIFrontEnd_TitleScreen extends UDKUIScene
	native;

cpptext
{
	virtual void Tick( FLOAT DeltaTime );
}

/** Whether or not we are in the attract mode movie. */
var bool	bInMovie;

/** Amount of time elapsed since last user input. */
var float	TimeElapsed;

/** Name of the attract mode movie. */
var() string	MovieName;

/** Amount of time until the attract movie starts. */
var() float TimeTillAttractMovie;

/** Reference to the main menu scene. */
var string MainMenuScene;

/** Flag to update the LP array on the next tick. */
var transient bool bUpdatePlayersOnNextTick;

/** Post initialize event - Sets delegates for the scene. */
event PostInitialize()
{
	local UILabel PressStart;

	Super.PostInitialize();

	// Activate kismet for entering scene
	ActivateLevelEvent('TitleScreenEnter');

	RegisterOnlineDelegates();

	// Update game player's array with players that were logged in before the game was started.
	UpdateGamePlayersArray();

	PressStart = UILabel(FindChild('lblPressStart', true));

	if(!IsConsole())
	{
		PressStart.SetDataStoreBinding("<Strings:UDKGameUI.TitleScreen.PressAnyKey>");
	}
	else
	{
		PressStart.SetDataStoreBinding("<Strings:UDKGameUI.TitleScreen.PressStart>");
	}
}

event SceneActivated(bool bInitialActivation)
{
	Super.SceneActivated(bInitialActivation);

	// Skip title screen if we are exiting a game.
	if(bInitialActivation)
	{
		CheckTitleSkip();
	}
}

event SceneDeactivated()
{
	Super.SceneDeactivated();

	CleanupOnlineDelegates();
}

/** Registers online delegates to catch global events such as login changes. */
function RegisterOnlineDelegates()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			PlayerInterface.AddLoginChangeDelegate(OnLoginChange);
		}
	}

	// Update logged in profile labels
	UpdateProfileLabels();
}

/** Cleans up any registered online delegates. */
function CleanupOnlineDelegates()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			PlayerInterface.ClearLoginChangeDelegate(OnLoginChange);
		}
	}
}

/** @return Returns the number of currently logged in controllers. */
event int GetNumLoggedInPlayers()
{
	local int NumLoggedIn;
	local int ControllerId;

	NumLoggedIn = 0;

	for(ControllerId=0; ControllerId<MAX_SUPPORTED_GAMEPADS; ControllerId++)
	{
		if(IsLoggedIn(ControllerId))
		{
			NumLoggedIn++;
		}
	}

	return NumLoggedIn;
}

/** Creates a local player for every signed in controller. */
native function UpdateGamePlayersArray();

/** Always skip the title screen now. */
function CheckTitleSkip()
{
	// Skip the title every time now
	OpenSceneByName(MainMenuScene, true);
	UpdateProfileLabels();
}

/** Sets PlayerIndex 0's controller id to be the specified controller id, this makes it so that the specified controller can control all of the menus. */
function SetMainControllerId(int ControllerId)
{
	local LocalPlayer LP;

	`Log("UDKUIFrontEnd_TitleScreen::SetMainControllerId - Setting main controller ID to "$ControllerId);

	LP = GetPlayerOwner(0);
	LP.SetControllerId(ControllerId);

	UpdateProfileLabels();
}

function OnReadOnlineAvatarCompleted(const UniqueNetId PlayerNetId, Texture2D Avatar)
{
	local OnlinePlayerInterface PlayerInt;
	local UIImage PlayerAvatar;
	local UIScene BackgroundScene;
	local LocalPlayer LP;
	local UniqueNetId NetId;

	BackgroundScene = GetSceneClient().FindSceneByTag('MainMenu');
	if (BackgroundScene == None)
	{
		return;   // oh well.
	}

	LP = GetPlayerOwner(0);
	PlayerInt = GetPlayerInterface();
		
	if(!IsConsole(CONSOLE_Xbox360))
	{
		if (PlayerAvatar == None)
		{
			LP = GetPlayerOwner(0);
			if ( ( LP != None ) && ( PlayerInt.GetUniquePlayerId(LP.ControllerId, NetId) ) && ( NetId == PlayerNetId ) )
			{
				PlayerAvatar = UIImage(BackgroundScene.FindChild('imgPlayerAvatarPC', true));
			}
		}
	}
	else
	{
		if (PlayerAvatar == None)
		{
			LP = GetPlayerOwner(0);
			if ( ( LP != None ) && ( PlayerInt.GetUniquePlayerId(LP.ControllerId, NetId) ) && ( NetId == PlayerNetId ) )
			{
				PlayerAvatar = UIImage(BackgroundScene.FindChild('imgPlayerAvatar1', true));
			}
		}
		
		if (PlayerAvatar == None)
		{
			LP = GetPlayerOwner(1);
			if ( ( LP != None ) && ( PlayerInt.GetUniquePlayerId(LP.ControllerId, NetId) ) && ( NetId == PlayerNetId ) )
			{
				PlayerAvatar = UIImage(BackgroundScene.FindChild('imgPlayerAvatar2', true));
			}
		}
	}

	if (PlayerAvatar != None)
	{
		PlayerAvatar.SetVisibility(false);
		if ( IsLoggedIn(LP.ControllerId) && (Avatar != None) )
		{
			PlayerAvatar.SetValue(Avatar);
			PlayerAvatar.SetVisibility(true);
		}
	}
}

function ReadPlayerAvatar(byte LocalUserNum)
{
//Disabled the steamworks specific calls until it can be done in a clean crossplatform way
/*	local OnlinePlayerInterface PlayerInt;
	local OnlinePlayerInterfaceEx PlayerIntEx;
	local UniqueNetId ZeroId;
	local UniqueNetId NetId;

	PlayerInt = GetPlayerInterface();
	PlayerIntEx = GetPlayerInterfaceEx();
	if ( ( PlayerInt == None ) || ( PlayerIntEx == None) || ( !PlayerInt.GetUniquePlayerId(LocalUserNum, NetId) ) || ( NetId == ZeroId ) )
	{
		return;
	}

	PlayerIntEx.ReadOnlineAvatar(NetId, OnReadOnlineAvatarCompleted);*/
}


/** Updates the profile labels. */
event UpdateProfileLabels()
{
	local UIScene BackgroundScene;
	local LocalPlayer LP;
	local OnlinePlayerInterface PlayerInt;
	local UIObject PanelPC;
	local UIObject PanelConsole;
	local UILabel PlayerLabel1;
	local UILabel PlayerLabel2;
	local UIImage PlayerAvatar1;
	local UIImage PlayerAvatar2;

	PlayerInt=GetPlayerInterface();
	BackgroundScene = GetSceneClient().FindSceneByTag('MainMenu');

	if(BackgroundScene != None)
	{
		PanelPC = BackgroundScene.FindChild('imgNameBGPC',true);
		PanelConsole = BackgroundScene.FindChild('imgNameBGConsole',true);

		if(!IsConsole(CONSOLE_Xbox360))
		{
			PlayerLabel1 = UILabel(BackgroundScene.FindChild('lblPlayerNamePC', true));
			PlayerAvatar1 = UIImage(BackgroundScene.FindChild('imgPlayerAvatarPC', true));
			if ( PlayerAvatar1 != None )
			{
				PlayerAvatar1.SetVisibility(false);   // delegate will change this, later.
			}
			PanelPC.SetVisibility(true);
			PanelConsole.SetVisibility(false);
		}
		else
		{
			PlayerLabel1 = UILabel(BackgroundScene.FindChild('lblPlayerName1', true));
			PlayerLabel2 = UILabel(BackgroundScene.FindChild('lblPlayerName2', true));
			PlayerAvatar1 = UIImage(BackgroundScene.FindChild('imgPlayerAvatar1', true));
			PlayerAvatar2 = UIImage(BackgroundScene.FindChild('imgPlayerAvatar2', true));
			if ( PlayerAvatar1 != None )
			{
				PlayerAvatar1.SetVisibility(false);   // delegate will change this, later.
			}
			if ( PlayerAvatar2 != None )
			{
				PlayerAvatar2.SetVisibility(false);   // delegate will change this, later.
			}
			PanelPC.SetVisibility(false);
			PanelConsole.SetVisibility(true);
		}

		// Player 1
		if ( PlayerLabel1 != None )
		{
			LP = GetPlayerOwner(0);
			if(LP != None && IsLoggedIn(LP.ControllerId))
			{
				if(IsLoggedIn(LP.ControllerId, true))
				{
					PlayerLabel1.SetDataStoreBinding(PlayerInt.GetPlayerNickname(LP.ControllerId));
					ReadPlayerAvatar(LP.ControllerId);
				}
				else
				{
					PlayerLabel1.SetDataStoreBinding("<OnlinePlayerData:PlayerNickName> <Strings:UDKGameUI.Generic.OfflineProfile>");
				}
			}
			else
			{
				PlayerLabel1.SetDataStoreBinding("");
				PanelPC.SetVisibility(false);
			}
		}

		// Player 2
		if(PlayerLabel2 != None)
		{
			LP = GetPlayerOwner(1);
			if(LP != None && IsLoggedIn(LP.ControllerId))
			{
				if(IsLoggedIn(LP.ControllerId, true))
				{
					PlayerLabel2.SetDataStoreBinding(PlayerInt.GetPlayerNickname(LP.ControllerId));
					ReadPlayerAvatar(LP.ControllerId);
				}
				else
				{
					PlayerLabel2.SetDataStoreBinding("<OnlinePlayerData:PlayerNickName> <Strings:UDKGameUI.Generic.OfflineProfile>");
				}
			}
			else
			{
				PlayerLabel2.SetDataStoreBinding("");
			}
		}
	}
}

/** Called when the profile read has completed for any player. */
function OnProfileReadComplete()
{
	UpdateProfileLabels();
}

/** Called any time any player changes their current login status. */
function OnLoginChange(byte ControllerId)
{
	if (ControllerId == GetPlayerOwner().ControllerId)
	{
		// Update the game player's array
		bUpdatePlayersOnNextTick = true;
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

	bResult=false;

	if(EventParms.EventType==IE_Released && (IsConsole(CONSOLE_Xbox360) || EventParms.ControllerId==0))
	{
		if(bInMovie)
		{
			if(!IsConsole()
			|| EventParms.InputKeyName=='XboxTypeS_A'
			|| EventParms.InputKeyName=='XboxTypeS_B'
			|| EventParms.InputKeyName=='XboxTypeS_X'
			|| EventParms.InputKeyName=='XboxTypeS_Y'
			|| EventParms.InputKeyName=='XboxTypeS_Start'
			|| EventParms.InputKeyName=='Enter'
			|| EventParms.InputKeyName=='LeftMouseButton')
			{
				StopMovie();
			}
		}
		else
		{
			if(!IsConsole()
			|| EventParms.InputKeyName=='XboxTypeS_A'
			|| EventParms.InputKeyName=='XboxTypeS_Start'
			|| EventParms.InputKeyName=='Enter'
			|| EventParms.InputKeyName=='LeftMouseButton')
			{
				// Set main controller id.
				if(IsConsole(CONSOLE_Xbox360))
				{
					SetMainControllerId(EventParms.ControllerId);
					bResult=true;
				}
				else
				{
					SetMainControllerId(0);
					bResult=true;
				}

				if(bResult)
				{
					// Activate kismet for exiting scene
					ActivateLevelEvent('TitleScreenExit');

					OpenSceneByName(MainMenuScene);
					UpdateProfileLabels();
				}

			}
			else
			{
				TimeElapsed=0.0;
			}
		}
	}

	return bResult;
}

/** Starts the attract mode movie. */
native function StartMovie();

/** Stops the currently playing movie. */
native function StopMovie();

/** Checks to see if a movie is done playing. */
native function UpdateMovieStatus();

defaultproperties
{
	OnInterceptRawInputKey=HandleInputKey
	TimeTillAttractMovie=90.0
}

