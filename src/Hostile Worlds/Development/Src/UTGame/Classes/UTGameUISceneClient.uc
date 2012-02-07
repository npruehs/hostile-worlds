/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTGameUISceneClient extends UDKGameUISceneClient
	dependson(UTUIScene_SaveProfile);

var UTUIScene_SaveProfile SaveProfileTemplate;


/**
 * Displays the Saving Profile scene
 *
 * @param PlayerOwner	Player to save profile info for.
 *
 * @return	Returns a ref to the scene if one was shown, otherwise, returns None.
 */
function UTUIScene_SaveProfile ShowSaveProfileScene(UTPlayerController PlayerOwner)
{
	local UIScene Result;
	local UIDataStore_OnlinePlayerData	PlayerDataStore;

	Result = None;

	if(PlayerOwner != None)
	{
		// Only show the scene on consoles.
		if ( class'UIRoot'.static.IsConsole() )
		{
			OpenScene(SaveProfileTemplate,LocalPlayer(PlayerOwner.Player),Result);
		}
		else
		{
			PlayerDataStore = UIDataStore_OnlinePlayerData(DataStoreManager.FindDataStore('OnlinePlayerData', LocalPlayer(PlayerOwner.Player)));

			if(PlayerDataStore != none)
			{
				PlayerDataStore.SaveProfileData();
			}
		}
	}

	return UTUIScene_SaveProfile(Result);
}

defaultproperties
{
	ToastFont=Font'UI_Fonts_Final.Menus.Fonts_Positec'
	SaveProfileTemplate=UTUIScene_SaveProfile'UI_Scenes_Common.SaveProfile'
}
