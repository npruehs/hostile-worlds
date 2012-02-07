/**
 * Provides information about the current game.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class GameInfoDataProvider extends UIDynamicDataProvider
	native(inherit);

var		GameReplicationInfo		GameDataSource;

/* == Events == */
/**
 * Called once BindProviderInstance has successfully verified that DataSourceInstance is of the correct type.  Stores the
 * reference in the GameDataSource variable.
 */
event ProviderInstanceBound( Object DataSourceInstance )
{
	local GameReplicationInfo GRI;

	GRI = GameReplicationInfo(DataSourceInstance);
	if ( GRI != None )
	{
		GameDataSource = GRI;
	}
}

DefaultProperties
{
	DataClass=class'Engine.GameReplicationInfo'
}
