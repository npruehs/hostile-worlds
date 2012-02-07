/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UIDataStore_Color extends UIDataStore
	native(inherit);

cpptext
{
	/* === UIDataProvider interface === */

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
	virtual UBOOL ParseStringModifier( const FString& ColorParams, struct FUIStringNodeModifier& StyleData );
}

DefaultProperties
{
	Tag=Color
}
