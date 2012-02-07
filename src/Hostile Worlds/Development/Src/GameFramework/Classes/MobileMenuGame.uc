/**
* MobileMenuGame
* A replacement game type that pops up a menu
*
*
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*/

class MobileMenuGame extends GameInfo;

var class<MobileMenuScene> InitialSceneToDisplayClass;

/**
 * We override PostLogin and display the scene directly after the login process is finished.                                                                     
 */
event PostLogin( PlayerController NewPlayer )
{
	local MobileMenuPlayerController MPC;
	local MobilePlayerInput MI;
	
	Super.PostLogin(NewPlayer);

	`log("" $ Class $"::PostLogin" @ InitialSceneToDisplayClass);

	if (InitialSceneToDisplayClass != none)
	{
		MPC = MobileMenuPlayerController(NewPlayer);
		if (MPC != none)
		{
			MI = MobilePlayerInput(MPC.PlayerInput);
			if (MI != none)
			{
				MI.OpenMenuScene(InitialSceneToDisplayClass);
			}
			else
			{
				`Log("MobileMenuGame.Login - Could not find a MobilePlayerInput to open the scene!");
			}
		}
		else
		{
			`Log("MobileMenuGame.Login - Could not find a MobileMenuPlayerController");
		}
	}
	else
	{
		`Log("MobileMenuGame.Login - No scene to open");
	}

}

/**
 * Never start a match in the menus
 */
function StartMatch()
{
}

/**
 * Never restart a player in the menus                                                                     
 */
function RestartPlayer(Controller NewPlayer)
{
}


defaultproperties
{
	PlayerControllerClass=class'MobileMenuPlayerController'
	HUDType=class'MobileHud'
}

