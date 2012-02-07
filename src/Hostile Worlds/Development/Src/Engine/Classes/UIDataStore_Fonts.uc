/**
 * This data store class is responsible for parsing and applying inline font changes.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIDataStore_Fonts extends UIDataStore
	native(inherit);

cpptext
{
	/* === UIDataProvider interface === */
	/**
	 * Gets the list of font names available through this data store.
	 *
	 * @param	out_Fields	will be filled in with the list of tags which can be used to access data in this data provider.
	 *						Will call GetScriptDataTags to allow script-only child classes to add to this list.
	 */
	virtual void GetSupportedDataFields( TArray<struct FUIDataProviderField>& out_Fields );

	/**
	 * This data store cannot generate string nodes.
	 */
	virtual UBOOL GetDataStoreValue( const FString& MarkupString, struct FUIProviderFieldValue& out_FieldValue ) { return FALSE; }

	/**
	 * Attempst to load the font specified and if successful changes the style data's DrawFont.
	 *
	 * @param	MarkupString	a string corresponding to the name of a font.
	 * @param	StyleData		the style data to apply the changes to.
	 *
	 * @return	TRUE if a font was found matching the specified FontName, FALSE otherwise.
	 */
	virtual UBOOL ParseStringModifier( const FString& FontName, struct FUIStringNodeModifier& StyleData );
}

DefaultProperties
{
	Tag=Fonts
}
