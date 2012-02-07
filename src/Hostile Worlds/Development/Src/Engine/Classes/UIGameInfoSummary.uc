/**
 * Provides information about the static resources available for a particular gametype.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIGameInfoSummary extends UIResourceDataProvider
	PerObjectConfig
	Config(Game);

var	config		string	ClassName;
var	config		string	GameAcronym;
var	config		string	MapPrefix;
var	config		bool	bIsTeamGame;

/** the pathname for the OnlineGameSettings subclass associated with this gametype */
var	config		string	GameSettingsClassName;

// may want to expose other props here, like MaxPlayers, GoalScore, etc.

var	config localized	string	GameName;
var	config localized	string	Description;

var	config		bool	bIsDisabled;

/**
 * Allows a resource data provider instance to indicate that it should be unselectable in subscribed lists
 *
 * @return	FALSE to indicate that list elements which represent this data provider should be considered unselectable
 *			or otherwise disabled (though it will still appear in the list).
 */
event bool IsProviderDisabled()
{
	return bIsDisabled;
}

DefaultProperties
{

}
