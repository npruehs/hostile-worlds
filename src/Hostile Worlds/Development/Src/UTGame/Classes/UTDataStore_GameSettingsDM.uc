/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Warfare specific datastore for TDM game creation
 */
class UTDataStore_GameSettingsDM extends UIDataStore_OnlineGameSettings;

defaultproperties
{
	GameSettingsCfgList.Add((GameSettingsClass=class'UTGame.UTGameSettingsDM',SettingsName="UTGameSettingsDM"))
	GameSettingsCfgList.Add((GameSettingsClass=class'UTGame.UTGameSettingsTDM',SettingsName="UTGameSettingsTDM"))
	GameSettingsCfgList.Add((GameSettingsClass=class'UTGame.UTGameSettingsCTF',SettingsName="UTGameSettingsCTF"))
	GameSettingsCfgList.Add((GameSettingsClass=class'UTGame.UTGameSettingsVCTF',SettingsName="UTGameSettingsVCTF"))
	Tag=UTGameSettings
}
