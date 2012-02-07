/**
 * This virtual data store is used to resolve references to materials or textures.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIDataStore_Images extends UIDataStore
	native(UIPrivate)
	transient;

cpptext
{
	/* === UIDataStore interface === */
	/**
	 * Retrieves the tag used for referencing this data store.  Loc data store is always referenced using the special tag "Strings"
	 */
	virtual FName GetDataStoreID() const { return NAME_Images; }

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
}

DefaultProperties
{
	Tag=Images
}
