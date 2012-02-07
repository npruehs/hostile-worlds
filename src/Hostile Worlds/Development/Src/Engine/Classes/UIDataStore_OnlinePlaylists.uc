/**
 * Data store provides access to available playlist resources
 * The data for each playlist is provided through a data provider and is specified in the .ini file for that
 * data provider class type using the PerObjectConfig paradigm.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIDataStore_OnlinePlaylists extends UIDataStore
	native(inherit)
	implements(UIListElementProvider)
	Config(Game);

/** Constants used for accessing the data providers */
const RANKEDPROVIDERTAG		= "PlaylistsRanked";
const UNRANKEDPROVIDERTAG	= "PlaylistsUnranked";

/** Name of provider class associated with this data store (uses them and all child classes) */
var config string ProviderClassName;

/** Class reference for the above provider class name */
var	transient	class<UIResourceDataProvider>	ProviderClass;

/** Cached array of perobjectconfig data providers for playlists determined to be "ranked" */
var const private array<UIResourceDataProvider> RankedDataProviders;

/** Cached array of perobjectconfig data providers for playlists determined to be "unranked" */
var const private array<UIResourceDataProvider> UnRankedDataProviders;

cpptext
{
	/* === UUIDataStore_GameResource interface === */
	/**
	 * Finds or creates the UIResourceDataProvider instances used by online playlists, and stores the result by ranked or unranked provider types
	 */
	virtual void InitializeListElementProviders();

	/**
	 * Finds the data provider associated with the tag specified.
	 *
	 * @param	ProviderTag		The tag of the provider to find.  Must match the ProviderTag value for one of elements
	 *							in the ElementProviderTypes array, though it can contain an array index (in which case
	 *							the array index will be removed from the ProviderTag value passed in).
	 * @param	InstanceIndex	If ProviderTag contains an array index, this will be set to the array index value that was parsed.
	 *
	 * @return	a data provider instance (or CDO if no array index was included in ProviderTag) for the element provider
	 *			type associated with ProviderTag.
	 */
	class UUIResourceDataProvider* ResolveProviderReference( FName& ProviderTag, INT* InstanceIndex=NULL ) const;

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

	/* === UIDataStore interface === */
	/**
	 * Loads the classes referenced by the ElementProviderTypes array.
	 */
	virtual void LoadDependentClasses();

	/**
	 * Called when this data store is added to the data store manager's list of active data stores.
	 *
	 * @param	PlayerOwner		the player that will be associated with this DataStore.  Only relevant if this data store is
	 *							associated with a particular player; NULL if this is a global data store.
	 */
	virtual void OnRegister( ULocalPlayer* PlayerOwner );

	/**
	 * Resolves PropertyName into a list element provider that provides list elements for the property specified.
	 *
	 * @param	PropertyName	the name of the property that corresponds to a list element provider supported by this data store
	 *
	 * @return	a pointer to an interface for retrieving list elements associated with the data specified, or NULL if
	 *			there is no list element provider associated with the specified property.
	 */
	virtual TScriptInterface<class IUIListElementProvider> ResolveListElementProvider( const FString& PropertyName );

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
	virtual UBOOL GetFieldValue( const FString& FieldName, FUIProviderFieldValue& out_FieldValue, INT ArrayIndex=INDEX_NONE );

	/**
	 * Generates filler data for a given tag.  This is used by the editor to generate a preview that gives the
	 * user an idea as to what a bound datastore will look like in-game.
	 *
 	 * @param		DataTag		the tag corresponding to the data field that we want filler data for
 	 *
	 * @return		a string of made-up data which is indicative of the typical [resolved] value for the specified field.
	 */
	virtual FString GenerateFillerData( const FString& DataTag );

	/**
	 * Gets the list of data fields exposed by this data provider.
	 *
	 * @param	out_Fields	will be filled in with the list of tags which can be used to access data in this data provider.
	 *						Will call GetScriptDataTags to allow script-only child classes to add to this list.
	 */
	virtual void GetSupportedDataFields( TArray<FUIDataProviderField>& out_Fields );

	/* === UObject interface === */
	/** Required since maps are not yet supported by script serialization */
	virtual void AddReferencedObjects( TArray<UObject*>& ObjectArray );
	virtual void Serialize( FArchive& Ar );

	/**
	 * Called from ReloadConfig after the object has reloaded its configuration data.  Reinitializes the collection of list element providers.
	 */
	virtual void PostReloadConfig( UProperty* PropertyThatWasLoaded );

	/**
	 * Callback for retrieving a textual representation of natively serialized properties.  Child classes should implement this method if they wish
	 * to have natively serialized property values included in things like diffcommandlet output.
	 *
	 * @param	out_PropertyValues	receives the property names and values which should be reported for this object.  The map's key should be the name of
	 *								the property and the map's value should be the textual representation of the property's value.  The property value should
	 *								be formatted the same way that UProperty::ExportText formats property values (i.e. for arrays, wrap in quotes and use a comma
	 *								as the delimiter between elements, etc.)
	 * @param	ExportFlags			bitmask of EPropertyPortFlags used for modifying the format of the property values
	 *
	 * @return	return TRUE if property values were added to the map.
	 */
	virtual UBOOL GetNativePropertyValues( TMap<FString,FString>& out_PropertyValues, DWORD ExportFlags=0 ) const;
}

/**
 * Get the number of UIResourceDataProvider instances associated with the specified tag.
 *
 * @param	ProviderTag		the tag to find instances for; should match the ProviderTag value of an element in the ElementProviderTypes array.
 *
 * @return	the number of instances registered for ProviderTag.
 */
native function int GetProviderCount( name ProviderTag ) const;

/**
 * Get the UIResourceDataProvider instances associated with the tag.
 *
 * @param	ProviderTag		the tag to find instances for; should match the ProviderTag value of an element in the ElementProviderTypes array.
 * @param	out_Providers	receives the list of provider instances. this array is always emptied first.
 *
 * @return	the list of UIResourceDataProvider instances registered for ProviderTag.
 */
native final function bool GetResourceProviders( name ProviderTag, out array<UIResourceDataProvider> out_Providers ) const;

/**
 * Get the list of fields supported by the provider type specified.
 *
 * @param	ProviderTag			the name of the provider type to get fields for; should match the ProviderTag value of an element in the ElementProviderTypes array.
 *								If the provider type is expanded (bExpandProviders=true), this tag should also contain the array index of the provider instance
 *								to use for retrieving the fields (this can usually be automated by calling GenerateProviderAccessTag)
 * @param	ProviderFieldTags	receives the list of tags supported by the provider specified.
 *
 * @return	TRUE if the tag was resolved successfully and the list of tags was retrieved (doesn't guarantee that the provider
 *			array will contain any elements, though).  FALSE if the data store couldn't resolve the ProviderTag.
 */
native final function bool GetResourceProviderFields( name ProviderTag, out array<name> ProviderFieldTags ) const;

/**
 * Get the value of a single field in a specific resource provider instance. Example: GetProviderFieldValue('PlaylistsRanked', 'PlaylistId', 2, FieldValue)
 *
 * @param	ProviderTag		the name of the provider type; should match the ProviderTag value of an element in the ElementProviderTypes array.
 * @param	SearchField		the name of the field within the provider type to get the value for; should be one of the elements retrieved from a call
 *							to GetResourceProviderFields.
 * @param	ProviderIndex	the index [into the array of providers associated with the specified tag] of the instance to get the value from;
 *							should be one of the elements retrieved by calling GetResourceProviders().
 * @param	out_FieldValue	receives the value of the field
 *
 * @return	TRUE if the field value was successfully retrieved from the provider.  FALSE if the provider tag couldn't be resolved,
 *			the index was not a valid index for the list of providers, or the search field didn't exist in that provider.
 */
native final function bool GetProviderFieldValue( name ProviderTag, name SearchField, int ProviderIndex, out UIProviderScriptFieldValue out_FieldValue ) const;

/**
 * Searches for resource provider instance that has a field with a value that matches the value specified.
 *
 * @param	ProviderTag			the name of the provider type; should match the ProviderTag value of an element in the ElementProviderTypes array.
 * @param	SearchField			the name of the field within the provider type to compare the value to; should be one of the elements retrieved from a call
 *								to GetResourceProviderFields.
 * @param	ValueToSearchFor	the field value to search for.
 *
 * @return	the index of the resource provider instance that has the same value for SearchField as the value specified, or INDEX_NONE if the
 *			provider tag couldn't be resolved,  none of the provider instances had a field with that name, or none of them had a field
 *			of that name with the value specified.
 */
native final function int FindProviderIndexByFieldValue( name ProviderTag, name SearchField, out const UIProviderScriptFieldValue ValueToSearchFor ) const;

/**
 * Searches for resource provider instance given its associated provider tag and an index within that subset
 *
 * @param	ProviderTag			the name of the provider type; should match the ranked or unranked provider tag
 * @param	SearchField			the index of the provider within the provider subset specified by the ProviderTag
 * @param	out_Provider		the resource provider instance found
 *
 * @return	true if the out_Provider has been found, false otherwise
 */
native final function bool GetPlaylistProvider( name ProviderTag, int ProviderIndex, out UIResourceDataProvider out_Provider);


/** Returns the OnlinePlaylistProvider with the corresponding PlaylistId */
static function OnlinePlaylistProvider GetOnlinePlaylistProvider( name ProviderTag, int PlaylistId, optional out int ProviderIndex )
{
	local UIDataStore_OnlinePlaylists PlaylistDS;
	local UIProviderScriptFieldValue Value;
	local UIResourceDataProvider PlaylistProvider;

	ProviderIndex = INDEX_NONE;
	PlaylistDS = UIDataStore_OnlinePlaylists(class'UIRoot'.static.StaticResolveDataStore(class'UIDataStore_OnlinePlaylists'.default.Tag));
	if ( PlaylistDS != None )
	{
		Value.PropertyTag = 'PlaylistId';
		Value.PropertyType = DATATYPE_Property;
		Value.StringValue = string(PlaylistId);

		// Find the index to the provider with the playerlistid
		ProviderIndex = PlaylistDS.FindProviderIndexByFieldValue(ProviderTag, 'PlaylistId', Value);
		if ( ProviderIndex != INDEX_NONE )
		{
			PlaylistDS.GetPlaylistProvider(ProviderTag, ProviderIndex, PlaylistProvider);
		}
	}

	return OnlinePlaylistProvider(PlaylistProvider);
}

DefaultProperties
{
	Tag=OnlinePlaylists
}
