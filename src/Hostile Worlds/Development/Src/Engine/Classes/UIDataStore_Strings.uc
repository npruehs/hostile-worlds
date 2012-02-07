/**
 * This datastore provides the UI with access to localized strings.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIDataStore_Strings extends UIDataStore_StringBase
	native(inherit)
	transient;

/** list of data providers for each loc file */
var		transient		array<UIConfigFileProvider>		LocFileProviders;

cpptext
{
protected:
	/* === UUIDataStore_Strings interface === */
	/**
	 * Creates an UIConfigFileProvider instance for the loc file specified by FilePathName.
	 *
	 * @return	a pointer to a newly allocated UUIConfigFileProvider instance that contains the data for the specified
	 *			loc file.
	 */
	class UUIConfigFileProvider* CreateLocProvider( const FFilename& FilePathName );

public:
	/* === UIDataStore interface === */
	/**
	 * Loads all .int files and creates UIConfigProviders for each loc file that was loaded.
	 */
	virtual void InitializeDataStore();

	/* === UIDataProvider interface === */
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
	 * Parses the data store reference and resolves it into a value that can be used by the UI.
	 *
	 * @param	MarkupString	a markup string that can be resolved to a data field contained by this data provider, or one of its
	 *							internal data providers.
	 * @param	out_FieldValue	receives the value of the data field resolved from MarkupString.  If the specified property corresponds
	 *							to a value that can be rendered as a string, the field value should be assigned to the StringValue member;
	 *							if the specified property corresponds to a value that can only be rendered as an image, such as an object
	 *							or image reference, the field value should be assigned to the ImageValue member.
	 *							Data stores can optionally manually create a UIStringNode_Text or UIStringNode_Image containing the appropriate
	 *							value, in order to have greater control over how the string node is initialized.  Generally, this is not necessary.
	 *
	 * @return	TRUE if this data store (or one of its internal data providers) successfully resolved the string specified into a data field
	 *			and assigned the value to the out_FieldValue parameter; false if this data store could not resolve the markup string specified.
	 */
	virtual UBOOL GetDataStoreValue( const FString& MarkupString, struct FUIProviderFieldValue& out_FieldValue )
	{
		return GetFieldValue(MarkupString, out_FieldValue);
	}

	/**
	 * Parses the data store reference and resolves the data provider and field that is referenced by the markup.
	 *
	 * @param	MarkupString	a markup string that can be resolved to a data field contained by this data provider, or one of its
	 *							internal data providers.
	 * @param	out_FieldOwner	receives the value of the data provider that owns the field referenced by the markup string.
	 * @param	out_FieldTag	receives the value of the property or field referenced by the markup string.
	 * @param	out_ArrayIndex	receives the optional array index for the data field referenced by the markup string.  If there is no array index embedded in the markup string,
	 *							value will be INDEX_NONE.
	 *
	 * @return	TRUE if this data store was able to successfully resolve the string specified.
	 */
	virtual UBOOL ParseDataStoreReference( const FString& MarkupString, class UUIDataProvider*& out_FieldOwner, FString& out_FieldTag, INT& out_ArrayIndex )
	{
		out_FieldOwner = this;
		out_FieldTag = MarkupString;
		return TRUE;
	}

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
	virtual void GetSupportedDataFields( TArray<struct FUIDataProviderField>& out_Fields );
}

DefaultProperties
{
	Tag=Strings
}
