/**
 * Provides data about a particular instance of an actor in the game.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIDynamicDataProvider extends UIPropertyDataProvider
	native(inherit)
	implements(UIListElementCellProvider)
	abstract;

cpptext
{
	/* === UUIDynamicDataProvider interface === */
	/**
	 * Determines whether the specified class should be represented by this dynamic data provider.
	 *
	 * @param	PotentialDataSourceClass	a pointer to a UClass that is being considered for binding by this provider.
	 *
	 * @return	TRUE to allow the databinding properties of PotentialDataSourceClass to be displayed in the UI editor's data store browser
	 *			under this data provider.
	 */
	UBOOL IsValidDataSourceClass( UClass* PotentialDataSourceClass );

	/**
	 * Builds an array of classes that are supported by this data provider.  Used in the editor to generate the list of
	 * supported data fields.  Since dynamic data providers are only created during the game, the editor needs a way to
	 * retrieve the list of data field tags that can be bound without requiring instances of this data provider's DataClass to exist.
	 *
	 * @note: only called in the editor!
	 */
	void GetSupportedClasses( TArray<UClass*>& out_Classes );

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
	 * Generates filler data for a given tag.  This is used by the editor to generate a preview that gives the
	 * user an idea as to what a bound datastore will look like in-game.
	 *
 	 * @param		DataTag		the tag corresponding to the data field that we want filler data for
 	 *
	 * @return		a string of made-up data which is indicative of the typical [resolved] value for the specified field.
	 */
	virtual FString GenerateFillerData( const FString& DataTag );

	/**
	 * Resolves the value of the data field specified and stores the value specified to the appropriate location for that field.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	FieldValue		the value to store for the property specified.
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL SetFieldValue(const FString& FieldName,const FUIProviderScriptFieldValue& FieldValue,INT ArrayIndex = INDEX_NONE);

	/* === IUIListElementCellProvider interface === */
	/**
	 * Gets the list of data fields (and their localized friendly name) for the fields exposed this provider.
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param	out_CellTags	receives the name/friendly name pairs for all data fields in this provider.
	 */
	virtual void GetElementCellTags( FName FieldName, TMap<FName,FString>& out_CellTags );

	/**
	 * Retrieves the field type for the specified cell.
	 *
	 * @param	FieldName			the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *								instance provides element cells for multiple collection data fields.
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
}

/**
 * The metaclass for this data provider.  Each instance of this class (including instances of child classes) will have
 * a data provider that tells the UI which properties to provide for this class.  Classes indicate which properties are
 * available for use by dynamic data stores by marking the property with a keyword.
 */
var	const							class	DataClass;

/**
 * The object that this data provider is presenting data for.  Set by calling BindProviderInstance.
 */
var	const	transient	protected	Object	DataSource;


/* == Natives == */
/**
 * Associates this data provider with the specified instance.
 *
 * @param	DataSourceInstance	a pointer to the object instance that this data provider should present data for.  DataSourceInstance
 *								must be of type DataClass.
 *
 * @return	TRUE if the instance specified was successfully associated with this data provider.  FALSE if the object specified
 *			wasn't of the correct type or was otherwise invalid.
 */
native final function bool BindProviderInstance( Object DataSourceInstance );

/**
 * Clears the instance associated with this data provider.
 *
 * @return	TRUE if the instance reference was successfully cleared.
 */
native final function bool UnbindProviderInstance();

/* == Events == */

/**
 * Called once BindProviderInstance has successfully verified that DataSourceInstance is of the correct type.  Child classes
 * can override this function to handle storing the reference, for example.
 */
event ProviderInstanceBound( Object DataSourceInstance );

/**
 * Called immediately after this data provider's DataSource is disassociated from this data provider.
 */
event ProviderInstanceUnbound( Object DataSourceInstance );

/**
 * Script hook for preventing a particular child of DataClass from being represented by this dynamic data provider.
 *
 * @param	PotentialDataSourceClass	a child class of DataClass that is being considered as a candidate for binding by this provider.
 *
 * @return	return FALSE to prevent PotentialDataSourceClass's properties from being added to the UI editor's list of bindable
 *			properties for this data provider; also prevents any instances of PotentialDataSourceClass from binding to this provider
 *			at runtime.
 */
event bool IsValidDataSourceClass( class PotentialDataSourceClass )
{
	return true;
}

/**
 * Returns a reference to the data source associated with this data provider.
 */
final function Object GetDataSource()
{
	return DataSource;
}

/**
 * Allows the data provider to clear any references that would interfere with garbage collection.
 *
 * @return	TRUE if the instance reference was successfully cleared.
 */
function bool CleanupDataProvider()
{
	return UnbindProviderInstance();
}

DefaultProperties
{

}
