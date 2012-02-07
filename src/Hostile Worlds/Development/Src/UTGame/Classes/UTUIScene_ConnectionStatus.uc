/**
 * This scene is displayed while the user is waiting for a connection to finish.  It has code for handling connection
 * error notifications and routing those errors back to its parent scenes.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTUIScene_ConnectionStatus extends UTUIScene_MessageBox;

/**
 * Called when a user has chosen one of the possible options available to them.
 * Begins hiding the dialog and calls the On
 *
 * @param OptionIdx		Index of the selection option.
 * @param PlayerIndex	Index of the player that selected the option.
 */
function OptionSelected(int OptionIdx, int PlayerIndex)
{
	local OnlineSubsystem OnlineSub;

	Super.OptionSelected(OptionIdx, PlayerIndex);

	// Store a reference to the game interface
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if ( OnlineSub != None && OnlineSub.GameInterface != None )
	{
		// kill the pending connection
		OnlineSub.GameInterface.DestroyOnlineGame('Game');
	}
	ConsoleCommand("CANCEL");
}

DefaultProperties
{
	bExemptFromAutoClose=true
}
