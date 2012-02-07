/**
 * This data provider class allows adding and removing data fields at runtime.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIDynamicFieldProvider extends UIDataProvider
	native(inherit)
	config(UI)
	PerObjectConfig
	nontransient;

cpptext
{
	/* === UIDynamicFieldProvider interface === */
	/**
	 * Adds a new data field to the list of supported fields.
	 *
	 * @param	FieldName			the name to give the new field
	 * @param	FieldType			the type of data field being added
	 * @param	bPersistent			specify TRUE to add the field to the PersistentDataFields array as well.
	 * @param	out_InsertPosition	allows the caller to find out where the element was inserted
	 *
	 * @return	TRUE if the field was successfully added to the list; FALSE if the a field with that name already existed
	 *			or the specified name was invalid.
	 */
	virtual UBOOL AddField( FName FieldName, BYTE FieldType=0, UBOOL bPersistent=FALSE, INT* out_InsertPosition=NULL );

	/* === UUIDataProvider interface === */
	/**
	 * Resolves the value of the data field specified and stores it in the output parameter.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	out_FieldValue	receives the resolved value for the property specified.
	 *							@see ParseDataStoreReference for additional notes
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
	 * Gets the list of data fields exposed by this data provider.
	 *
	 * @param	out_Fields	will be filled in with the list of tags which can be used to access data in this data provider.
	 *						Will call GetScriptDataTags to allow script-only child classes to add to this list.
	 */
	virtual void GetSupportedDataFields( TArray<struct FUIDataProviderField>& out_Fields );

	/* === UObject interface === */
	/**
	 * Serializes the value of the PersistentCollectionData and RuntimeCollectionData members, since they are not supported
	 * by script serialization.
	 */
	virtual void Serialize( FArchive& Ar );
}

/**
 * The list of data fields and values which were added to this data provider in the UI editor.  These fields are copied into
 * the RuntimeDataFields array when the provider is initialized.
 */
var()	protected{protected}	config		array<UIProviderScriptFieldValue>	PersistentDataFields;

/**
 * The list of data fields currently supported by this data provider.  When fields are added and removed during the game,
 * those operations always occur using this array.  Is never modified in the editor.
 */
var()	protected{protected}	transient	array<UIProviderScriptFieldValue>	RuntimeDataFields;

/**
 * Contains the source data for all DATATYPE_Collection data fields which have their values stored in the PersistentDataFields array.
 */
var		protected{protected}	native	const				Map_Mirror			PersistentCollectionData{TMap< FName, TMap<FName,TArray<FString> > >};

/**
 * Contains the source data for all DATATYPE_Collection data fields which have their values stored in the PersistentDataFields array.
 */
var		protected{protected}	native	const	transient	Map_Mirror			RuntimeCollectionData{TMap< FName, TMap<FName,TArray<FString> > >};

/**
 * Copies the elements from the PersistentDataFields array into the RuntimeDataFields array.  Should only be called once when the provider
 * is initialized.
 */
native function InitializeRuntimeFields();

/**
 * Adds a new data field to the list of supported fields.
 *
 * @param	FieldName			the name to give the new field
 * @param	FieldType			the type of data field being added
 * @param	bPersistent			specify TRUE to add the field to the PersistentDataFields array as well.
 * @param	out_InsertPosition	allows the caller to find out where the element was inserted
 *
 * @return	TRUE if the field was successfully added to the list; FALSE if the a field with that name already existed
 *			or the specified name was invalid.
 */
native virtual final noexport function bool AddField( name FieldName, EUIDataProviderFieldType FieldType=DATATYPE_Property, optional bool bPersistent, optional out int out_InsertPosition );

/**
 * Removes the data field that has the specified tag.
 *
 * @param	FieldName	the name of the data field to remove from this data provider.
 *
 * @return	TRUE if the field was successfully removed from the list of supported fields or the field name wasn't in the list
 *			to begin with; FALSE if the name specified was invalid or the field couldn't be removed for some reason
 */
native virtual final function bool RemoveField( name FieldName );

/**
 * Finds the index into the DataFields array for the data field specified.
 *
 * @param	FieldName	the name of the data field to search for
 * @param	bSearchPersistentFields		if TRUE, searches the PersistentDataFields array for the specified field; otherwise,
 *										searches the RuntimeDataFields array
 *
 * @param	the index into the DataFields array for the data field specified, or INDEX_NONE if it isn't in the array.
 */
native virtual final function int FindFieldIndex( name FieldName, optional bool bSearchPersistentFields ) const;

/**
 * Removes all data fields from this data provider.
 *
 * @param	bReinitializeRuntimeFields	specify TRUE to reset the elements of the RuntimeDataFields array to match the elements
 *										in the PersistentDataFields array.  Ignored in the editor.
 *
 * @return	TRUE indicates that all fields were removed successfully; FALSE otherwise.
 */
native virtual final function bool ClearFields( optional bool bReinitializeRuntimeFields=true );

/**
 * Gets the value of the data field specified.
 *
 * @param	FieldName	the name of the data field to retrieve the value for
 * @param	out_Field	receives the value of the data field specified
 *
 * @return	TRUE if out_Field was successfully filled in with the value of the specified data field; FALSE if the data field
 *			doesn't exist in this data provider.
 */
native virtual final noexport function bool GetField( name FieldName, out UIProviderScriptFieldValue out_Field );

/**
 * Sets the value for the data field specified.
 *
 * @param	FieldName	the name of the data field to retrieve the value for
 * @param	FieldValue	the value to assign to the specified data field
 * @param	bChangeExistingOnly		controls what happens if there is no data field with the specified name in this data provider's list
 *									of fields;  TRUE indicates that we should only set the value if the field already exists in the list;
 *									FALSE indicates that we should add a new element to the list if there are no existing fields with this name.
 *
 * @return	TRUE if the value was successfully applied to the field specified; FALSE otherwise.
 */
native virtual final noexport function bool SetField( name FieldName, const out UIProviderScriptFieldValue FieldValue, optional bool bChangeExistingOnly=true );

/**
 * Copies the values of all fields which exist in the PersistentDataFields array from the RuntimeDataFields array into the PersistentDataFields array and
 * saves everything to the .ini.
 */
native virtual final function SavePersistentProviderData();

/** === source data for collection data fields === */
/**
 * Gets the list of schema tags set for the data value source array stored for FieldName
 *
 * @param	FieldName			the name of the data field the source data should be associated with.
 * @param	out_CellTagArray	the list of unique tags stored in the source array data for the specified data field name.
 * @param	bPersistent			specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *								wouldn't be.
 *
 * @return	TRUE if the array containing possible values for the FieldName data field was successfully located and copied
 *			into the out_CellTagArray variable.
 */
native virtual final function bool GetCollectionValueSchema( name FieldName, out array<name> out_CellTagArray, optional bool bPersistent );

/**
 * Gets the data value source array for the specified data field.
 *
 * @param	FieldName			the name of the data field the source data should be associated with.
 * @param	out_DataValueArray	receives the array of data values available for FieldName.
 * @param	bPersistent			specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *								wouldn't be.
 * @param	CellTag				optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the array containing possible values for the FieldName data field was successfully located and copied
 *			into the out_DataValueArray variable.
 */
native virtual final function bool GetCollectionValueArray( name FieldName, out array<string> out_DataValueArray, optional bool bPersistent, optional name CellTag );

/**
 * Sets the source data for a collection data field to the values specified.  It is not necessary to add the field first
 * (via AddField) in order to set the collection values.
 *
 * @param	FieldName			the name of the data field the source data should be associated with.
 * @param	CollectionValues	the actual values that will be associated with FieldName.
 * @param	bClearExisting		specify TRUE to clear the existing collection data before adding the new values
 * @param	InsertIndex			the position to insert the new values (only relevant if bClearExisting is FALSE)
 * @param	bPersistent			specify TRUE to ensure that the values will be added to PersistentCollectionData, even
 *								if they otherwise wouldn't be.
 * @param	CellTag				optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the collection data was applied successfully; FALSE if there was also already data for this collection
 *			data field [and bOverwriteExisting was FALSE] or the data couldn't otherwise
 */
native virtual final function bool SetCollectionValueArray( name FieldName, out const array<string> CollectionValues, optional bool bClearExisting=true,
	optional int InsertIndex=INDEX_NONE, optional bool bPersistent, optional name CellTag );

/**
 * Inserts a new string into the list of values for the specified collection data field.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	NewValue		the value to insert
 * @param	InsertIndex		the index [into the array of values for FieldName] to insert the new value, or INDEX_NONE to
 *							append the value to the end of the list.
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	bAllowDuplicateValues
 *							controls whether multiple elements containing the same value should be allowed in the data source
 *							collection.  If FALSE is specified, and NewValue already exists in the collection source array, method
 *							return TRUE but it does not modify the array.  If TRUE is specified, NewValue will be added anyway,
 *							resulting in multiple copies of NewValue existing in the array.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the new value was successfully inserted into the collection data source for the specified field.
 */
native virtual final function bool InsertCollectionValue( name FieldName, out const string NewValue, optional int InsertIndex=INDEX_NONE,
	optional bool bPersistent, optional bool bAllowDuplicateValues, optional name CellTag );

/**
 * Removes a value from the collection data source specified by FieldName.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	ValueToRemove	the value that should be removed
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the value was successfully removed or didn't exist in the first place.
 */
native virtual final function bool RemoveCollectionValue( name FieldName, out const string ValueToRemove, optional bool bPersistent, optional name CellTag );

/**
 * Removes the value from the collection data source specified by FieldName located at ValueIndex.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	ValueIndex		the index [into the array of values for FieldName] of the value that should be removed.
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the value was successfully removed; FALSE if ValueIndex wasn't valid or the value couldn't be removed.
 */
native virtual final function bool RemoveCollectionValueByIndex( name FieldName, int ValueIndex, optional bool bPersistent, optional name CellTag );

/**
 * Replaces the value in a collection data source with a different value.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	CurrentValue	the value that will be replaced.
 * @param	NewValue		the value that will replace CurrentValue
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the old value was successfully replaced with the new value.
 */
native virtual final function bool ReplaceCollectionValue( name FieldName, out const string CurrentValue, out const string NewValue, optional bool bPersistent, optional name CellTag );

/**
 * Replaces the value located at ValueIndex in a collection data source with a different value
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	ValueIndex		the index [into the array of values for FieldName] of the value that should be replaced.
 * @param	NewValue		the value that should replace the old value.
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the value was successfully replaced; FALSE if ValueIndex wasn't valid or the value couldn't be removed.
 */
native virtual final function bool ReplaceCollectionValueByIndex( name FieldName, int ValueIndex, out const string NewValue, optional bool bPersistent, optional name CellTag );

/**
 * Removes all data values for a single collection data field.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the data values were successfully cleared or didn't exist in the first place; FALSE if they couldn't be removed.
 */
native virtual final function bool ClearCollectionValueArray( name FieldName, optional bool bPersistent, optional name CellTag );

/**
 * Retrieves the value of an element in a collection data source array.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	ValueIndex		the index [into the array of values for FieldName] of the value that should be retrieved.
 * @param	out_Value		receives the value of the collection data source element
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise
 *							wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	TRUE if the value was successfully retrieved and copied to out_Value.
 */
native virtual final function bool GetCollectionValue( name FieldName, int ValueIndex, out string out_Value, optional bool bPersistent, optional name CellTag ) const;

/**
 * Finds the index [into the array of values for FieldName] for a specific value.
 *
 * @param	FieldName		the name of the data field associated with the data source collection being manipulated.
 * @param	ValueToFind		the value that should be found.
 * @param	bPersistent		specify TRUE to ensure that the PersistentCollectionData is used, even if it otherwise wouldn't be.
 * @param	CellTag			optional name of a subfield within the list of values for FieldName. if not specified, FieldName is used.
 *
 * @return	the index for the specified value, or INDEX_NONE if it couldn't be found.
 */
native virtual final function int FindCollectionValueIndex( name FieldName, out const string ValueToFind, optional bool bPersistent, optional name CellTag ) const;

DefaultProperties
{
	WriteAccessType=ACCESS_WriteAll
}
