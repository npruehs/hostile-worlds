/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Holds the base game search for a TDM match.
 */
class UTGameSearchTDM extends UTGameSearchCommon;

defaultproperties
{
	GameSettingsClass=class'UTGame.UTGameSettingsTDM'

	// Which server side query to execute
	Query=(ValueIndex=QUERY_TDM)

	// Set the specific game mode that we are searching for
	LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_TDM,AdvertisementType=ODAT_OnlineService)
}