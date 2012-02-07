/**
 * This datastore provides access to a list of data providers which provide data for any file which is handled by
 * the engine's config cache system, such as .ini and .int files.
 *
 * There is one ConfigFileProvider for each ini/int file, and contains a list of providers for sections in that file.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIConfigFileProvider extends UIConfigProvider
	native(inherit)
	transient;

/** the list of sections in this config file */
var				transient		array<UIConfigSectionProvider>		Sections;

/** the name of the config file associated with this data provider */
var	noexport	transient		string								ConfigFileName;

cpptext
{
	/** the name of the config file associated with this data provider */
	FFilename	ConfigFileName;

	/* === UIConfigFileProvider interface === */
	/**
	 * Initializes this config file provider, creating the section data providers for each of the sections contained
	 * within the ConfigFile specified.
	 *
	 * @param	ConfigFile	the config file to associated with this data provider
	 */
	void InitializeProvider( class FConfigFile* ConfigFile );

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
}

DefaultProperties
{

}
