/**
 * Provides data for a UT3 mutator.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataProvider_Mutator extends UTUIResourceDataProvider
	PerObjectConfig;

/** The mutator class name. */
var config string ClassName;

/** Description for the mutator. */
var config localized string Description;

/** Name of the group(s) the mutator belongs to, separated by pipes | */
var config string GroupNames;

/** Path to a UIScene to use for configuring this mutator. */
var config string UIConfigScene;

/** gametypes this mutator supports - an empty array means it supports any gametype */
var config array<string> SupportedGameTypes;

/** Whether or not the mutator should be allowed in standalone matches only. */
var config bool bStandaloneOnly;

/**
 * Indicates whether this data provider corresponds to an epic mutator class.  Set natively when the data provider
 * is initialized.
 */
var	const private bool bOfficialMutator;

/** Script interface for determining whether or not this provider should be filtered */
event bool ShouldBeFiltered()
{
	return !SupportsCurrentGameMode();
}

/** @return Returns whether or not this mutator supports the currently set gamemode in the frontend. */
event bool SupportsCurrentGameMode()
{
	local string GameMode;
	local class<UTGame> GameModeClass;
	local bool bResult, bGameTypeSupported;
	local string StandaloneMatch;

	bResult = true;

	// Check to see if we should be allowed in stand alone matches only
	if(bStandaloneOnly && GetDataStoreStringValue("<Registry:StandaloneGame>", StandaloneMatch))
	{
		bResult = (StandaloneMatch == "1");
	}

	// Make sure we are compatible with the selected game mode.
	GetDataStoreStringValue("<Registry:SelectedGameMode>", GameMode);

	if ( GameMode != "" )
	{
		if ( SupportedGameTypes.Length > 0 )
		{
			bGameTypeSupported = SupportedGameTypes.Find(GameMode) != INDEX_NONE;
			if ( !bGameTypeSupported )
			{
				// Make sure we use the UTGame version of classes.
				GameMode = Repl(GameMode, "UTGameContent.", "UTGame.");
				GameMode = Repl(GameMode, "_Content", "");

				// try checking the modified GameMode string as well
				if ( SupportedGameTypes.Find(GameMode) == INDEX_NONE)
				{
					bResult = false;
				}
			}
		}

		if ( bResult )
		{
			// Make sure we use the UTGame version of classes.
			GameMode = Repl(GameMode, "UTGameContent.", "UTGame.");
			GameMode = Repl(GameMode, "_Content", "");

			// Find the class and then see if this mutator is allowed.
			GameModeClass = class<UTGame>(FindObject(GameMode, class'class'));
			if(GameModeClass != none)
			{
				bResult = GameModeClass.static.AllowMutator(ClassName);
			}
			else
			{
				`Log("UTUIDataProvider_Mutator::SupportsCurrentGameMode() - Unable to find game class: "$GameMode);
			}
		}
	}

	return bResult;
}


defaultproperties
{
	bSearchAllInis=true
}
