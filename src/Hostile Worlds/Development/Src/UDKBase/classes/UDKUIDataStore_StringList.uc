/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKUIDataStore_StringList extends UIDataStore_StringBase
	config(Game)
	native
	transient
	implements(UIListElementProvider)
	implements(UIListElementCellProvider);

const INVALIDFIELD=-1;

struct native EStringListData
{
	/** the tag used for binding this data to a list cell */
	var name Tag;

	/** the string to use as the column header for cells bound to this field */
	var	localized string ColumnHeaderText;

	/** the currently selected value from the Strings array */
	var string CurrentValue;

	/** the index into the Strings array for the element that should be selected by default */
	var int DefaultValueIndex;

	/** the available value choices */
	var localized array<string> Strings;

	/** provider for the list of strings associated with this tag */
	var transient UDKUIDataProvider_StringArray	DataProvider;
};

var config array<EStringListData> StringData;

cpptext
{
/* === UIListElementProvider === */

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

   	virtual TScriptInterface<class IUIListElementProvider> ResolveListElementProvider( const FString& PropertyName );


/* === UIListElementCellProvider === */

	/**
	 * Retrieves the list of tags that can be bound to individual cells in a single list element, along with the human-readable,
	 * localized string that should be used in the header for each cell tag (in lists which have column headers enabled).
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param	out_CellTags	receives the list of tag/column headers that can be bound to element cells for the specified property.
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
	virtual UBOOL GetCellFieldValue( FName FieldName, const FName& CellTag, INT ListIndex, struct FUIProviderFieldValue& out_FieldValue, INT ArrayIndex=INDEX_NONE );



/* === UIDataProvider interface === */

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
	 * Resolves the value of the data field specified and stores the value specified to the appropriate location for that field.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	FieldValue		the value to store for the property specified.
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL SetFieldValue( const FString& FieldName, const struct FUIProviderScriptFieldValue& FieldValue, INT ArrayIndex=INDEX_NONE );

	/**
	 * Adds a new field to the list
	 *
	 * @param	FieldName		the data field to resolve the value for
	 * @param	NewString		The first string to add.
	 * @param bBatchOp		if TRUE, doesn't call RefreshSubscribers()
	 */
	virtual INT AddNewField(FName FieldName, const FString &NewString, UBOOL bBatchOp=FALSE);


}

/**
 * Called when this data store is added to the data store manager's list of active data stores.
 *
 * @param	PlayerOwner		the player that will be associated with this DataStore.  Only relevant if this data store is
 *							associated with a particular player; NULL if this is a global data store.
 */
event Registered( LocalPlayer PlayerOwner )
{
	local int FieldIdx;

	Super.Registered(PlayerOwner);

	// Go through all of the config defined string items and set the default value string.
	for(FieldIdx=0; FieldIdx<StringData.length; FieldIdx++)
	{
		if(StringData[FieldIdx].Strings.length > StringData[FieldIdx].DefaultValueIndex && StringData[FieldIdx].DefaultValueIndex >= 0)
		{
			StringData[FieldIdx].CurrentValue = StringData[FieldIdx].Strings[StringData[FieldIdx].DefaultValueIndex];
		}
	}
}

/**
 * @param FieldName		Name of the String List to find
 * @return the index of a string list
 */
native function INT GetFieldIndex(Name FieldName);

/**
 * Add a string to the list
 *
 * @Param FieldName		The string list to work on
 * @Param NewString		The new string to add
 * @param bBatchOp		if TRUE, doesn't call RefreshSubscribers()
 */
native function AddStr(name FieldName, string NewString, optional bool bBatchOp);

/**
 * Insert a string in to the list at a given index
 *
 * @Param FieldName		The string list to work on
 * @Param NewString		The new string to add
 * @Param InsertIndex	The index where you wish to insert the string
 * @param bBatchOp		if TRUE, doesn't call RefreshSubscribers()
 */
native function InsertStr(name FieldName, string NewString, int InsertIndex, optional bool bBatchOp);

/**
 * Remove a string from the list
 *
 * @Param FieldName		The string list to work on
 * @Param StringToRemove 	The string to remove
 * @param bBatchOp		if TRUE, doesn't call RefreshSubscribers()
 */
native function RemoveStr(name FieldName, string StringToRemove, optional bool bBatchOp);

/**
 * Remove a string (or multiple strings) by the index.
 *
 * @Param FieldName		The string list to work on
 * @Param Index			The index to remove
 * @Param Count			<Optional> # of strings to remove
 * @param bBatchOp		if TRUE, doesn't call RefreshSubscribers()
 */
native function RemoveStrByIndex(name FieldName, int Index, optional int Count=1, optional bool bBatchOp);

/**
 * Empty a string List
 *
 * @Param FieldName		The string list to work on
 * @param bBatchOp		if TRUE, doesn't call RefreshSubscribers()
 */
native function Empty(name FieldName, optional bool bBatchOp);

/**
 * Finds a string in the list
 *
 * @Param FieldName		The string list to add the new string to
 * @Param SearchStr		The string to find
 *
 * @returns the index in the list or INVALIDFIELD
 */
native function INT FindStr(name FieldName, string SearchString);

/**
 * Returns the a string by the index
 *
 * @Param FieldName		The string list to add the new string to
 * @Param StrIndex		The index of the string to get
 *
 * @returns the string.
 */
native function string GetStr(name FieldName, int StrIndex);

/**
 * Get a list
 *
 * @Param FieldName		The string list to add the new string to
 * @returns a copy of the list
 */
native function array<string> GetList(name FieldName);


/**
 * Returns the current value of a field.
 *
 * @param FieldName		Field to search.
 * @param out_Value		Variable to store the result string in.
 *
 * @return TRUE if the field was found, FLASE otherwise.
 */
event bool GetCurrentValue(name FieldName, out string out_Value)
{
	local bool Result;
	local int FieldIndex;

	Result = FALSE;

	FieldIndex = GetFieldIndex(FieldName);

	if(FieldIndex!=INDEX_NONE)
	{
		Result = TRUE;
		out_Value = StringData[FieldIndex].CurrentValue;
	}

	return Result;
}

/**
 * Returns the current value index of a given field.
 *
 * @param FieldName		Field to search.
 */
event int GetCurrentValueIndex(name FieldName)
{
	local int Result;
	local int FieldIndex;

	Result = INDEX_NONE;

	FieldIndex = GetFieldIndex(FieldName);

	if(FieldIndex!=INDEX_NONE)
	{
		Result = FindStr(FieldName, StringData[FieldIndex].CurrentValue);
	}

	return Result;
}

/**
 * Sets the current value index of a given field.
 *
 * @param FieldName		Field to change.
 * @param int			NewValueIndex
 */
event int SetCurrentValueIndex(name FieldName, int NewValueIndex)
{
	local int Result;
	local int FieldIndex;

	Result = INDEX_NONE;

	FieldIndex = GetFieldIndex(FieldName);

	if(FieldIndex!=INDEX_NONE && StringData[FieldIndex].Strings.length > NewValueIndex)
	{
		StringData[FieldIndex].CurrentValue = StringData[FieldIndex].Strings[NewValueIndex];
	}

	//@fixme - should we call refresh subscribers here?
	return Result;
}

/**
 * Get the number of strings in a given list
 *
 * @Param FieldName		The string list to work on
 * @returns the # of strings or -1 if the list does not exist
 */
event int Num(name FieldName)
{
	local int FieldIndex;
	FieldIndex = GetFieldIndex(FieldName);
	if ( FieldIndex > INDEX_NONE )  // Found it, add the string
	{
		return StringData[FieldIndex].Strings.Length;
	}

	return -1;
}

defaultproperties
{
	Tag=UTStringList
	WriteAccessType=ACCESS_WriteAll
}
