/**
 * Inherited version of the game resource datastore that has UT specific dataproviders.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKUIDataStore_MenuItems extends UIDataStore_GameResource
	native
	implements(UIListElementCellProvider)
	Config(Game);
	
var class<UDKUIDataProvider_MapInfo> MapInfoDataProviderClass;

cpptext
{
	/**
	 * Finds or creates the UIResourceDataProvider instances referenced by ElementProviderTypes, and stores the result
	 * into the ListElementProvider map.
	 */
	virtual void InitializeListElementProviders();

protected:
	/**
	 * Sorts the list of map and mutator data providers according to whether they're official or not, then alphabetically.
	 */
	void SortRelevantProviders();

public:

	/**
	 * Gets the list of element providers for a fieldname with filtered elements removed.
	 *
	 * @param FieldName				Fieldname to use to search for providers.
	 * @param OutElementProviders	Array to store providers in.
	 */
	void GetFilteredElementProviders(FName FieldName, TArray<class UUDKUIResourceDataProvider*> &OutElementProviders);

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

	/* === UIDataProvider interface === */
	/**
	 * Resolves the value of the data field specified and stores it in the output parameter.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	out_FieldValue	receives the resolved value for the property specified.
	 *							@see GetDataStoreValue for additional notes
	 * @param	ArrayIndex		optional array index for use with data collections
	 *
	 * @todo - not yet implemented
	 */
	virtual UBOOL GetFieldValue( const FString& FieldName, struct FUIProviderFieldValue& out_FieldValue, INT ArrayIndex=INDEX_NONE );

	/**
	 * Gets the list of data fields exposed by this data provider.
	 *
	 * @param	out_Fields	will be filled in with the list of tags which can be used to access data in this data provider.
	 *						Will call GetScriptDataTags to allow script-only child classes to add to this list.
	 */
	virtual void GetSupportedDataFields( TArray<struct FUIDataProviderField>& out_Fields );

	/**
	 * Retrieves a list element for the specified data tag that can provide the list with the available cells for this list element.
	 * Used by the UI editor to know which cells are available for binding to individual list cells.
	 *
	 * @param	FieldName		the tag of the list element data provider that we want the schema for.
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

	/**
	 * Resolves the value of the data field specified and stores the value specified to the appropriate location for that field.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	FieldValue		the value to store for the property specified.
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL SetFieldValue( const FString& FieldName, const struct FUIProviderScriptFieldValue& FieldValue, INT ArrayIndex=INDEX_NONE );

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
	 * Attempts to find a simple menu with the field name provided.
	 *
	 * @param FieldName		Field name of the simple menu.  Defined in UUTUIDataProvider_SimpleMenu::FieldName
	 */
	virtual class UUDKUIDataProvider_SimpleMenu* FindSimpleMenu(FName FieldName);


// IUIListElement interface

	/**
	 * Returns the names of the exposed members in the first entry in the array
	 * of search results
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param OutCellTags the columns supported by this row
	 */
	virtual void GetElementCellTags( FName FieldName, TMap<FName,FString>& out_CellTags );

	/**
	 * Retrieves the field type for the specified cell.
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param	CellTag				the tag for the element cell to get the field type for
	 * @param	out_CellFieldType	receives the field type for the specified cell; should be a EUIDataProviderFieldType value.
	 *
	 * @return	TRUE if this element cell provider contains a cell with the specified tag, and out_CellFieldType was changed.
	 */
	virtual UBOOL GetCellFieldType( FName FieldName, const FName& CellTag, BYTE& out_CellFieldType );

	/**
	 * Resolves the value of the cell specified by CellTag and stores it in the output parameter.
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param	CellTag			the tag for the element cell to resolve the value for
	 * @param	ListIndex		the UIList's item index for the element that contains this cell.  Useful for data providers which
	 *							do not provide unique UIListElement objects for each element.
	 * @param	out_FieldValue	receives the resolved value for the property specified.
	 *							@see GetDataStoreValue for additional notes
	 * @param	ArrayIndex		optional array index for use with cell tags that represent data collections.  Corresponds to the
	 *							ArrayIndex of the collection that this cell is bound to, or INDEX_NONE if CellTag does not correspond
	 *							to a data collection.
	 */
	virtual UBOOL GetCellFieldValue( FName FieldName, const FName& CellTag, INT ListIndex, FUIProviderFieldValue& out_FieldValue, INT ArrayIndex=INDEX_NONE );

}

/** Array of enabled mutators, the available mutators list will not contain any of these mutators. */
var array<int> EnabledMutators;

/** Array of maps, the available maps list will not contain any of these maps. */
var array<int> MapCycle;

/** Priority listing of the weapons, index 0 being highest priority. */
var array<int> WeaponPriority;

/** Current game mode to filter by. */
var int GameModeFilter;

/** @return Returns the number of providers for a given field name. */
native function int GetProviderCount(name FieldName) const;

/** @return Whether or not the specified provider is filtered or not. */
native function bool IsProviderFiltered(name FieldName, int ProviderIdx);

/** finds all UIResourceDataProvider objects defined in all .ini files in the game's config directory
 * static and script exposed to allow access to map/mutator/gametype/weapon lists outside of the menus
 */
native static final function GetAllResourceDataProviders(class<UDKUIResourceDataProvider> ProviderClass, out array<UDKUIResourceDataProvider> Providers);

/**
 * Attempts to find the index of a provider given a provider field name, a search tag, and a value to match.
 *
 * @return	Returns the index of the provider or INDEX_NONE if the provider wasn't found.
 */
native function int FindValueInProviderSet(name ProviderFieldName, name SearchTag, string SearchValue);

/**
 * Attempts to find the value of a provider given a provider cell field.
 *
 * @return	Returns true if the value was found, false otherwise.
 */
native function bool GetValueFromProviderSet(name ProviderFieldName, name SearchTag, int ListIndex, out string OutValue);

/** 
 * Attempts to retrieve all providers with the specified provider field name.
 *
 * @param ProviderFieldName		Name of the provider set to search for
 * @param OutProviders			A set of providers with the given name
 * 
 * @return	TRUE if the set was found, FALSE otherwise.
 */
native function bool GetProviderSet(name ProviderFieldName, out array<UDKUIResourceDataProvider> OutProviders);

/**
 * Finds or creates the UIResourceDataProvider instances referenced by ElementProviderTypes, and stores the result
 * into the ListElementProvider map.
 * Script event called after C++ version has created base map
 */
event InitializeListElementProviders()
{
	local array<UDKUIResourceDataProvider> WeaponProviders;
	local UDKUIResourceDataProvider Provider;
	local int WeaponIdx;

	// Generate DropDownWeapons provider set
	GetProviderSet('Weapons', WeaponProviders);
	RemoveListElementProvidersKey('DropDownWeapons');

	for( WeaponIdx=0; WeaponIdx<WeaponProviders.Length; WeaponIdx++ )
	{
		Provider = WeaponProviders[WeaponIdx];

		if( Provider != None )
		{
			AddListElementProvidersKey('DropDownWeapons', Provider);
		}
	}
}

/**
  * Remove key from ListElementProviders multimap
  */
native function RemoveListElementProvidersKey(Name KeyName);

/**
  * Add to ListElementProviders multimap
  */
native function AddListElementProvidersKey(Name KeyName, UDKUIResourceDataProvider Provider);

DefaultProperties
{
	Tag=UDKMenuItems
	WriteAccessType=ACCESS_WriteAll
	MapInfoDataProviderClass=class'UDKUIDataProvider_MapInfo'
}
