/**
 * Provides data about the current game.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class CurrentGameDataStore extends UIDataStore_GameState
	native(inherit)
	implements(UIListElementProvider);


/**
 * Contains the classes which should be used for instancing data providers.
 */
struct native GameDataProviderTypes
{
	/**
	 * the class to use for the game info data provider
	 */
	var	const	class<GameInfoDataProvider>	GameDataProviderClass;

	/**
	 * the class to use for the player data providers
	 */
	var const	class<PlayerDataProvider>	PlayerDataProviderClass;

	/**
	 * the class to use for the team data provider.
	 */
	var	const	class<TeamDataProvider>		TeamDataProviderClass;
};

var	const	GameDataProviderTypes			ProviderTypes;

/**
 * The GameInfoDataProvider that manages access to the current gameinfo's exposed data.
 */
var	protected	GameInfoDataProvider		GameData;

/**
 * The data providers for all players in the current match
 */
var	protected	array<PlayerDataProvider>	PlayerData;

/**
 * The data providers for all teams in the current match.
 */
var	protected	array<TeamDataProvider>		TeamData;

/**
 * Indicates that one or more players have changed or been updated.
 */
var	protected	transient	bool			bRefreshPlayerDataProviders;

/**
 * Indicates that one or more player's teams have changed.
 */
var	protected	transient	bool			bRefreshTeamDataProviders;

cpptext
{
	/**
	 * Parses the markup string for a reference to a specific element of the TeamData collection.
	 *
	 * @param	FieldName	a markup string possibly containing markup referencing a specific element of the TeamData array.
	 *						If a reference is found (i.e. TeamData;0), will be set to the remainder of the string.
	 *
	 * @return	a pointer to the element of the TeamData array if the markup contains a reference to one; otherwise NULL.
	 */
	virtual UTeamDataProvider* ParseTeamProviderCollectionReference( FString& FieldName ) const;

	/* === UUIDataProvider interface === */
	/**
	 * Gets the list of data fields exposed by this data provider.
	 *
	 * @param	out_Fields	will be filled in with the list of tags which can be used to access data in this data provider.
	 *						Will call GetScriptDataTags to allow script-only child classes to add to this list.
	 */
	virtual void GetSupportedDataFields( TArray<struct FUIDataProviderField>& out_Fields );

	/**
	 * Resolves the value of the data field specified and stores it in the output parameter.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	out_FieldValue	receives the resolved value for the property specified.
	 *							@see GetDataStoreValue for additional notes
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL GetFieldValue( const FString& FieldName, struct FUIProviderFieldValue& out_FieldValue, INT ArrayIndex=INDEX_NONE );

	/**
	 * Returns a pointer to the data provider which provides the tags for this data provider.  Normally, that will be this data provider,
	 * but for some data stores such as the Scene data store, data is pulled from an internal provider but the data fields are presented as
	 * though they are fields of the data store itself.
	 */
	virtual UUIDataProvider* GetDefaultDataProvider();
	/**
	 * Resolves PropertyName into a list element provider that provides list elements for the property specified.
	 *
	 * @param	PropertyName	the name of the property that corresponds to a list element provider supported by this data store
	 *
	 * @return	a pointer to an interface for retrieving list elements associated with the data specified, or NULL if
	 *			there is no list element provider associated with the specified property.
	 */
	virtual TScriptInterface<class IUIListElementProvider> ResolveListElementProvider( const FString& PropertyName );

	/* === IUIListElementProvider interface === */
	/**
	 * Retrieves the list of all data tags contained by this element provider which correspond to list element data.
	 *
	 * @return	the list of tags supported by this element provider which correspond to list element data.
	 */
	virtual TArray<FName> GetElementProviderTags();

	/**
	 * Returns the number of list elements associated with the data tag specified.
	 *
	 * @param	FieldName	the name of the property to get the element count for.  guaranteed to be one of the values returned
	 *						from GetElementProviderTags.
	 *
	 * @return	the total number of elements that are required to fully represent the data specified.
	 */
	virtual INT GetElementCount( FName FieldName );

	/**
	 * Retrieves the list elements associated with the data tag specified.
	 *
	 * @param	FieldName		the name of the property to get the element count for.  guaranteed to be one of the values returned
	 *							from GetElementProviderTags.
	 * @param	out_Elements	will be filled with the elements associated with the data specified by DataTag.
	 *
	 * @return	TRUE if this data store contains a list element data provider matching the tag specified.
	 */
	virtual UBOOL GetListElements( FName FieldName, TArray<INT>& out_Elements );

	/**
	 * Allows list element providers the chance to perform custom sorting of a collection of list elements.  Implementors should implement this
	 * method if they desire to perform complex sorting behavior, such as considering additional data when evaluting the order to sort the elements into.
	 *
	 * @param	CollectionDataFieldName		the name of a collection data field inside this UIListElementProvider associated with the
	 *										list items provided.  Guaranteed to one of the values returned from GetElementProviderTags.
	 * @param	ListItems					the array of list items that need sorting.
	 * @param	SortParameters				the parameters to use for sorting
	 *										PrimaryIndex:
	 *											the index [into the ListItems' Cells array] for the cell which the user desires to perform primary sorting with.
	 *										SecondaryIndex:
	 *											the index [into the ListItems' Cells array] for the cell which the user desires to perform secondary sorting with.  Not guaranteed
	 *											to be a valid value; Comparison should be performed using the value of the field indicated by PrimarySortIndex, then when these
	 *											values are identical, the value of the cell field indicated by SecondarySortIndex should be used.
	 *
	 * @return	TRUE to indicate that custom sorting was performed by this UIListElementProvider.  Custom sorting is not required - if this method returns FALSE,
	 *			the list bound to this UIListElementProvider will perform its default sorting behavior (alphabetical sorting of the desired cell values)
	 */
	virtual UBOOL SortListElements( FName CollectionDataFieldName, TArray<const struct FUIListItem>& ListItems, const struct FUIListSortingParameters& SortParameters );

	/**
	 * Determines whether a member of a collection should be considered "enabled" by subscribed lists.  Disabled elements will still be displayed in the list
	 * but will be drawn using the disabled state.
	 *
	 * @param	FieldName			the name of the collection data field that CollectionIndex indexes into.
	 * @param	CollectionIndex		the index into the data field collection indicated by FieldName to check
	 *
	 * @return	TRUE if FieldName doesn't correspond to a valid collection data field, CollectionIndex is an invalid index for that collection,
	 *			or the item is actually enabled; FALSE only if the item was successfully resolved into a data field value, but should be considered disabled.
	 */
	virtual UBOOL IsElementEnabled( FName FieldName, INT CollectionIndex );

	/**
	 * Retrieves a UIListElementCellProvider for the specified data tag that can provide the list with the available cells for this list element.
	 * Used by the UI editor to know which cells are available for binding to individual list cells.
	 *
	 * @param	FieldName		the tag of the list element data field that we want the schema for.
	 *
	 * @return	a pointer to some instance of the data provider for the tag specified.  only used for enumerating the available
	 *			cell bindings, so doesn't need to actually contain any data (i.e. can be the CDO for the data provider class, for example)
	 */
	virtual TScriptInterface<class IUIListElementCellProvider> GetElementCellSchemaProvider( FName FieldName );

	/**
	 * Retrieves a UIListElementCellProvider for the specified data tag that can provide the list with the values for the cells
	 * of the list element indicated by CellValueProvider.DataSourceIndex
	 *
	 * @param	FieldName		the tag of the list element data field that we want the values for
	 * @param	ListIndex		the list index for the element to get values for
	 *
	 * @return	a pointer to an instance of the data provider that contains the value for the data field and list index specified
	 */
	virtual TScriptInterface<class IUIListElementCellProvider> GetElementCellValueProvider( FName FieldName, INT ListIndex );
}

/**
 * Creates the GameInfoDataProvider that will track all game info state data
 */
final function CreateGameDataProvider( GameReplicationInfo GRI )
{
	if ( GRI != None )
	{
		GameData = new ProviderTypes.GameDataProviderClass;
		if ( !GameData.BindProviderInstance(GRI) )
		{
			`log(`location@"Failed to bind GameReplicationInfo to game data store:"@`showobj(GRI),,'DevDataStore');
		}
	}
	else
	{
		`log(`location@"NULL GRI specified!"@ `showobj(GameData),,'DevDataStore');
	}
}

/**
 * Creates a PlayerDataProvider for the specified PlayerReplicationInfo, and adds it to the PlayerData array.
 *
 * @param	PRI		the PlayerReplicationInfo to create the PlayerDataProvider for.
 */
final function AddPlayerDataProvider( PlayerReplicationInfo PRI )
{
	local int ExistingIndex;
	local PlayerDataProvider DataProvider;

`if(`notdefined(FINAL_RELEASE))
	local string PlayerName;

	PlayerName = PRI != None ? PRI.PlayerName : "None";
`endif

	`log(">> CurrentGameDataStore::AddPlayerDataProvider -" @ PRI @ "(" $ PlayerName $ ")",,'DevDataStore');
	if ( PRI != None )
	{
		if ( GameData != None )
		{
			ExistingIndex = FindPlayerDataProviderIndex(PRI);
			if ( ExistingIndex == INDEX_NONE )
			{
				DataProvider = new ProviderTypes.PlayerDataProviderClass;
				if ( !DataProvider.BindProviderInstance(PRI) )
				{
					`log("Failed to bind PRI to PlayerDataProvider:"@ DataProvider @ "for player" @ PlayerName,,'DevDataStore');
				}
				else
				{
					DataProvider.AddPropertyNotificationChangeRequest(PlayerDataProviderPropertyChange);
					PlayerData[PlayerData.Length] = DataProvider;

					RefreshSubscribers('Players', true, Self);
					NotifyTeamChange();
				}
			}
			else
			{
				`log("PlayerDataProvider already registered in 'CurrentGame' data store for" @ PlayerName @ `showobj(PlayerData[ExistingIndex]),,'DevDataStore');
			}
		}
		else
		{
			`log("CurrentGame data provider not yet created!",,'DevDataStore');
		}
	}
	else
	{
		`log("NULL PRI specified - current number of player data provider:"@ PlayerData.Length,,'DevDataStore');
	}
	`log("<< CurrentGameDataStore::AddPlayerDataProvider -" @ PRI @ "(" $ PlayerName $ ")",,'DevDataStore');
}

/**
 * Removes the PlayerDataProvider associated with the specified PlayerReplicationInfo.
 *
 * @param	PRI		the PlayerReplicationInfo to remove the data provider for.
 */
final function RemovePlayerDataProvider( PlayerReplicationInfo PRI )
{
	local int ExistingIndex;

	if ( PRI != None )
	{
		ExistingIndex = FindPlayerDataProviderIndex(PRI);
		if ( ExistingIndex != INDEX_NONE )
		{
			if ( PlayerData[ExistingIndex].CleanupDataProvider() )
			{
				PlayerData[ExistingIndex].RemovePropertyNotificationChangeRequest(PlayerDataProviderPropertyChange);
				PlayerData.Remove(ExistingIndex,1);

				RefreshSubscribers('Players', true, Self);
				NotifyTeamChange();
			}
		}
	}
	else
	{
		`log(`location@"NULL PRI specified!"@ `showvar(PlayerData.Length),,'DevDataStore');
	}
}

/**
 * Creates a TeamDataProvider for the specified TeamInfo, and adds it to the TeamData array.
 *
 * @param	TI		the TeamInfo to create the TeamDataProvider for.
 */
final function AddTeamDataProvider( TeamInfo TI )
{
	local int ExistingIndex;
	local TeamDataProvider DataProvider;

`if(`notdefined(FINAL_RELEASE))
	local string TeamName;

	TeamName = TI != None ? TI.TeamName : "None";
`endif

	`log(">> CurrentGameDataStore::AddTeamDataProvider -" @ TI @ "(" $ TeamName $ ")",,'DevDataStore');
	if ( TI != None )
	{
		if ( GameData != None )
		{
			ExistingIndex = FindTeamDataProviderIndex(TI);
			if ( ExistingIndex == INDEX_NONE )
			{
				DataProvider = new ProviderTypes.TeamDataProviderClass;

				if ( !DataProvider.BindProviderInstance(TI) )
				{
					`log("Failed to bind TeamInfo to TeamDataProvider in 'CurrentGame' data store:" @ DataProvider @ "for team" @ TeamName,,'DevDataStore');
				}
				else
				{
					TeamData[TI.TeamIndex] = DataProvider;
					DataProvider.AddPropertyNotificationChangeRequest(TeamDataProviderPropertyChange);
					NotifyTeamChange();
					OnAddTeamProvider(DataProvider);
				}
			}
			else
			{
				`log("TeamDataProvider already registered in 'CurrentGame' data store for" @ TeamName @ `showobj(TeamData[ExistingIndex]),,'DevDataStore');
			}
		}
	}
	else
	{
		`log("NULL TeamInfo specified - current number of team data providers:"@ TeamData.Length,,'DevDataStore');
	}
}

/**
 * Removes the TeamDataProvider associated with the specified TeamInfo.
 *
 * @param	TI		the TeamInfo to remove the data provider for.
 */
final function RemoveTeamDataProvider( TeamInfo TI )
{
	local int ExistingIndex;

	if ( TI != None )
	{
		ExistingIndex = FindTeamDataProviderIndex(TI);
		if ( ExistingIndex != INDEX_NONE )
		{
			if ( TeamData[ExistingIndex].CleanupDataProvider() )
			{
				TeamData[ExistingIndex].RemovePropertyNotificationChangeRequest(TeamDataProviderPropertyChange);
				TeamData.Remove(ExistingIndex,1);
			}
		}
	}
	else
	{
		`log(`location@"NULL TeamInfo specified!"@ `showvar(TeamData.Length,TeamCount),,'DevDataStore');
	}
}

/**
 * Returns the index into the PlayerData array for the PlayerDataProvider associated with the specified PlayerReplicationInfo.
 *
 * @param	PRI		the PlayerReplicationInfo to search for
 *
 * @return	an index into the PlayerData array for the PlayerDataProvider associated with the specified PlayerReplicationInfo,
 * or INDEX_NONE if no associated PlayerDataProvider was found
 */
final function int FindPlayerDataProviderIndex( PlayerReplicationInfo PRI )
{
	local int i, Result;

	Result = INDEX_NONE;

	for ( i = 0; i < PlayerData.Length; i++ )
	{
		if ( PlayerData[i].GetDataSource() == PRI )
		{
			Result = i;
			break;
		}
	}

	return Result;
}

/**
 * Returns the index into the TeamData array for the TeamDataProvider associated with the specified TeamInfo.
 *
 * @param	TI		the TeamInfo to search for
 *
 * @return	an index into the TeamData array for the TeamDataProvider associated with the specified TeamInfo, or INDEX_NONE
 *			if no associated TeamDataProvider was found
 */
final function int FindTeamDataProviderIndex( TeamInfo TI )
{
	local int i, Result;

	Result = INDEX_NONE;

	for ( i = 0; i < TeamData.Length; i++ )
	{
		if ( TeamData[i] != None && TeamData[i].GetDataSource() == TI )
		{
			Result = i;
			break;
		}
	}

	return Result;
}

/**
 * Returns a reference to the PlayerDataProvider associated with the PRI specified.
 *
 * @param	PRI		the PlayerReplicationInfo to search for
 *
 * @return	the PlayerDataProvider associated with the PRI specified, or None if there was no PlayerDataProvider for the
 *			PRI specified.
 */
final function PlayerDataProvider GetPlayerDataProvider( PlayerReplicationInfo PRI )
{
	local int Index;
	local PlayerDataProvider Provider;

	Index = FindPlayerDataProviderIndex(PRI);
	if ( Index != INDEX_NONE )
	{
		Provider = PlayerData[Index];
	}


	return Provider;
}

/**
 * Returns a reference to the TeamDataProvider associated with the TI specified.
 *
 * @param	TI		the TeamInfo to search for
 *
 * @return	the TeamDataProvider associated with the TeamInfo specified, or None if there was no TeamDataProvider for the
 *			TeamInfo specified.
 */
final function TeamDataProvider GetTeamDataProvider( TeamInfo TI )
{
	local int Index;
	local TeamDataProvider Provider;

	Index = FindTeamDataProviderIndex(TI);
	if ( Index != INDEX_NONE )
	{
		Provider = TeamData[Index];
	}


	return Provider;
}

/**
 * Clears all data provider references.
 */
final function ClearDataProviders()
{
	local int i;

	`log(">>" @ `location,,'DevDataStore');
	if ( GameData != None )
	{
		GameData.CleanupDataProvider();
	}

	for ( i = 0; i < PlayerData.Length; i++ )
	{
		PlayerData[i].CleanupDataProvider();
	}

	for ( i = 0; i < TeamData.Length; i++ )
	{
		if (TeamData[i] != None)
		{
			TeamData[i].CleanupDataProvider();
		}
	}

	GameData = None;
	PlayerData.Length = 0;
	TeamData.Length = 0;

	`log("<<" @ `location,,'DevDataStore');
}

/**
 * Handler for the PlayerDataProvider's OnDataProviderPropertyChange delegate.  Forwards the notification to the data
 * store's notification delegates.
 *
 * @param	SourceProvider		the data provider that generated the notification
 * @param	PropTag				the property that changed
 */
function PlayerDataProviderPropertyChange( UIDataProvider SourceProvider, optional name PropTag )
{
	local int PlayerArrayIndex, CollectionIndex;
	local EUIDataProviderFieldType ProviderFieldType;
	local bool bInvalidateListItems;

	`log(">>" @ `location @ `showvar(PropTag) @ `showvar(SourceProvider),,'DevDataStore');

	for ( PlayerArrayIndex = PlayerData.Length - 1; PlayerArrayIndex >= 0; PlayerArrayIndex-- )
	{
		if ( SourceProvider == PlayerData[PlayerArrayIndex] )
		{
			break;
		}
	}

	CollectionIndex = PlayerArrayIndex;
	if ( PlayerArrayIndex != INDEX_NONE )
	{
		if ( PropTag != 'None' )
		{
			// if the provider's internal field is a collection, the field we'll pass to
			// our subscribers should be formatted to allow referencing the internal collection
			if (SourceProvider.GetProviderFieldType(PropTag, ProviderFieldType)
			&&	SourceProvider.IsCollectionDataType(ProviderFieldType) )
			{
				CollectionIndex = SourceProvider.ParseTagArrayDelimiter(PropTag);
				if ( CollectionIndex == INDEX_NONE )
				{
					// if no collection index was specified, then the entire collection was updated/invalidated
					bInvalidateListItems = true;
				}

				PropTag = name( "Players;" $ PlayerArrayIndex $ "." $ PropTag );
			}
			else
			{
				PropTag = name( "Players." $ PropTag );
			}
		}
		else
		{
			// assume that everything was invalidated in this provider.
			bInvalidateListItems = true;
		}
	}
	else
	{
		//@todo - not one of our providers?
		`log(`location @ "CALLED BUT NO MATCHING PLAYERDATAPROVIDER FOUND!  " $ `showobj(SourceProvider) @ `showvar(PropTag),,'ERROR_DataStore');
	}

	RefreshSubscribers(PropTag, bInvalidateListItems, SourceProvider, CollectionIndex);
	`log("<<" @ `showvar(PropTag)@`showvar(bInvalidateListItems)@`showvar(CollectionIndex)@`showvar(PlayerArrayIndex)@`showobj(SourceProvider),,'DevDataStore');
}

/**
 * Handler for the TeamDataProvider's OnDataProviderPropertyChange delegate.  Forwards the notification to the data
 * store's notification delegates.
 *
 * @param	SourceProvider	the data provider that generated the notification
 * @param	PropTag			the property that changed
 */
function TeamDataProviderPropertyChange( UIDataProvider SourceProvider, optional name PropTag )
{
	local int TeamArrayIndex, CollectionIndex;
	local EUIDataProviderFieldType ProviderFieldType;
	local bool bInvalidateListItems;

	`log(">>" @ `location @ `showvar(PropTag)@`showvar(SourceProvider),,'DevDataStore');

	for ( TeamArrayIndex = TeamData.Length - 1; TeamArrayIndex >= 0; TeamArrayIndex-- )
	{
		if ( SourceProvider == TeamData[TeamArrayIndex] )
		{
			break;
		}
	}

	CollectionIndex = TeamArrayIndex;
	if ( TeamArrayIndex != INDEX_NONE )
	{
		if ( PropTag != 'None' )
		{
			// if the provider's internal field is a collection, the field we'll pass to
			// our subscribers should be formatted to allow referencing the internal collection
			if (SourceProvider.GetProviderFieldType(PropTag, ProviderFieldType)
			&&	SourceProvider.IsCollectionDataType(ProviderFieldType) )
			{
				CollectionIndex = SourceProvider.ParseTagArrayDelimiter(PropTag);
				if ( CollectionIndex == INDEX_NONE )
				{
					// if no collection index was specified, then the entire collection was updated/invalidated
					bInvalidateListItems = true;
				}

				PropTag = name( "Teams;" $ TeamArrayIndex $ "." $ PropTag );
			}
			else
			{
				PropTag = name( "Teams." $ PropTag );
			}
		}
		else
		{
			// assume that everything was invalidated in this provider.
			bInvalidateListItems = true;
		}
	}
	else
	{
		//@todo - not one of our providers?
		`log(`location @ "CALLED BUT NO MATCHING TEAMDATAPROVIDER FOUND!  " $ `showobj(SourceProvider) @ `showvar(PropTag),,'ERROR_DataStore');
	}

	RefreshSubscribers(PropTag, bInvalidateListItems, SourceProvider, CollectionIndex);
	`log("<<" @ `location @ `showvar(PropTag)@`showvar(bInvalidateListItems)@`showvar(CollectionIndex)@`showvar(TeamArrayIndex)@`showobj(SourceProvider),,'DevDataStore');
}

/**
 * Called by the GameReplicationInfo each time it receives a call to Timer()
 */
function Timer()
{
	if ( bRefreshPlayerDataProviders )
	{
		RefreshPlayerDataProviders();
	}

	if ( bRefreshTeamDataProviders )
	{
		RefreshTeamDataProviders();
	}
}

/**
 * Sets a flag indicating that the array of PlayerDataProviders has changed and subscribers should be notified
 * @note: not yet implemented
 */
function NotifyPlayersChanged()
{
	bRefreshPlayerDataProviders = true;
}

/**
 * Called whenever a player changes team or something affecting the team.  Issues a request for the TeamDataProviders to update
 * their cached lists of players.
 */
function NotifyTeamChange()
{
	bRefreshTeamDataProviders = true;
}

/**
 * Refreshes any subscribers bound to the array of PlayerDataProviders.
 * @note: not yet implemented.
 */
function RefreshPlayerDataProviders()
{
	RefreshSubscribers('Players', true, Self);
//
//	for ( i = 0; i < TeamData.Length; i++ )
//	{
//		PlayerData[i].RegeneratePlayerLists(PlayerData);
//	}

	bRefreshPlayerDataProviders = false;
}

/**
 * Instructs the team data providers to update their cached lists of players.
 */
function RefreshTeamDataProviders()
{
	local int i;

	for ( i = 0; i < TeamData.Length; i++ )
	{
		if (TeamData[i] != None)
		{
			TeamData[i].RegeneratePlayerLists(PlayerData);
		}
	}

	bRefreshTeamDataProviders = false;
}

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 *
 * @return	TRUE indicates that this data store should be automatically unregistered when this game session ends.
 */
function bool NotifyGameSessionEnded()
{
	ClearDataProviders();

	// this game state data store should not be unregistered when the match is over.
	return false;
}

delegate OnAddTeamProvider(TeamDataProvider Provider);


DefaultProperties
{
	Tag=CurrentGame

	ProviderTypes={(
		GameDataProviderClass=class'Engine.GameInfoDataProvider',
		PlayerDataProviderClass=class'Engine.PlayerDataProvider',
		TeamDataProviderClass=class'Engine.TeamDataProvider'
	)}
}
