/**
 * Provides a general purpose global storage area for game or configuration data.
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIDataStore_Registry extends UIDataStore
	native(inherit);

cpptext
{
	/* === UIDataStore interface === */
	/**
	 * Creates the data provider for this registry data store.
	 */
	virtual void InitializeDataStore();

	/* === UIDataProvider interface === */
protected:
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

public:
	/**
	 * Gets the list of data fields exposed by this data provider.
	 *
	 * @param	out_Fields	will be filled in with the list of tags which can be used to access data in this data provider.
	 *						Will call GetScriptDataTags to allow script-only child classes to add to this list.
	 */
	virtual void GetSupportedDataFields( TArray<struct FUIDataProviderField>& out_Fields );

	/**
	 * Returns a pointer to the data provider which provides the tags for this data provider.  Normally, that will be this data provider,
	 * but in this data store, the data fields are pulled from an internal provider but presented as though they are fields of the data store itself.
	 */
	virtual UUIDataProvider* GetDefaultDataProvider();

	/**
	 * Notifies the data store that all values bound to this data store in the current scene have been saved.  Provides data stores which
	 * perform buffered or batched data transactions with a way to determine when the UI system has finished writing data to the data store.
	 */
	virtual void OnCommit();
}

/**
 * The data provider that contains the data fields which have been added to this data store.
 */
var	protected	UIDynamicFieldProvider		RegistryDataProvider;

/**
 * @return	the data provider which stores all registry data.
 */
final function UIDynamicFieldProvider GetDataProvider()
{
	return RegistryDataProvider;
}

DefaultProperties
{
	Tag=Registry
	WriteAccessType=ACCESS_WriteAll
}


