/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 *  Our UIScenes provide PreRender and tick passes to our Widgets
 */

class UTUIScene extends UDKUIScene
	abstract
	dependson(OnlinePlayerInterface,UTGameInteraction);

`include(UTOnlineConstants.uci)

/**
 *  Returns the Player Profile for a given player index.
 *
 * @param	PlayerIndex		The player who's profile you require
 * @returns the profile precast to UTProfileSettings
 */
function UTProfileSettings GetPlayerProfile(optional int PlayerIndex=GetBestPlayerIndex() )
{
	local LocalPlayer LP;
	local UTProfileSettings Profile;

	LP = GetPlayerOwner(PlayerIndex);
	if ( LP != none && LP.Actor != none )
	{
		Profile = UTProfileSettings( LP.Actor.OnlinePlayerData.ProfileProvider.Profile);
	}
	return Profile;
}

/**
 *  Returns the Player Profile for a given player index.
 *
 * @param	PC	The PlayerContorller of the profile you require.
 * @returns the profile precast to UTProfileSettings
 */
function UTProfileSettings GetPlayerProfileFromPC(PlayerController PC )
{
	local UTProfileSettings Profile;
	Profile = UTProfileSettings( PC.OnlinePlayerData.ProfileProvider.Profile);
	return Profile;
}

/** @return Checks to see if the platform is currently connected to a network. */
function bool CheckLinkConnectionAndError( optional string AlternateTitle, optional string AlternateMessage )
{
	if( HasLinkConnection() )
	{
		return true;
	}
	else
	{
		if ( AlternateTitle == "" )
		{
			AlternateTitle = "<Strings:UTGameUI.Errors.Error_Title>";
		}
		if ( AlternateMessage == "" )
		{
			AlternateMessage = "<Strings:UTGameUI.Errors.LinkDisconnected_Message>";
		}

		DisplayMessageBox(AlternateMessage,AlternateTitle);
		return false;
	}
}

/**
 * Displays a screen warning message.  This message will be displayed prominently centered in the viewport and
 * will persist until you call ClearScreenWarningMessage().  It's useful for important modal warnings, such
 * as when the controller is disconnected on a console platform.
 *
 * @param Message Message to display
 */
static function ShowScreenWarningMessage( string Message )
{
	// NOTE: Currently we don't bother drawing these on Xbox since they automatically display things like
	//   'please reconnect controller', etc.
	if( !IsConsole( CONSOLE_Xbox360 ) )
	{
		UTGameUISceneClient( GetSceneClient() ).ShowScreenWarningMessage( Message );
	}
}


/**
 * Clears the screen warning message if one was set.  It will no longer be rendered.
 */
static function ClearScreenWarningMessage()
{
	if( !IsConsole( CONSOLE_Xbox360 ) )
	{
		UTGameUISceneClient( GetSceneClient() ).ClearScreenWarningMessage();
	}
}

defaultproperties
{
	MessageBoxScene=UIScene'UI_Scenes_Common.MessageBox'
	InputBoxScene=UIScene'UI_Scenes_Common.InputBox'
`if(`notdefined(MOBILE))
	SceneSkin=UISkin'UI_Skin_Derived.UTDerivedSkin'
`endif
	PendingPlayerOwnerIndex=INDEX_NONE
}
