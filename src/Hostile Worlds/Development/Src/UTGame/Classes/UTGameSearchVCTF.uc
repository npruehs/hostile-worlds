/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Holds the base game search for a VCTF match.
 */
class UTGameSearchVCTF extends UTGameSearchCommon;

defaultproperties
{
	GameSettingsClass=class'UTGame.UTGameSettingsVCTF'

	// Which server side query to execute
	Query=(ValueIndex=QUERY_VCTF)

	// Set the specific game mode that we are searching for
	LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_VCTF,AdvertisementType=ODAT_OnlineService)
}