/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * UT specific search result that exposes some extra fields to the server browser.
 */
class UDKUIDataProvider_SearchResult extends UIDataProvider_Settings
	native;

/** data field tags - cached for faster lookup */
var	const	name	PlayerRatioTag;
var	const	name	GameModeFriendlyNameTag;
var	const	name	ServerFlagsTag;
var	const	name	MapNameTag;

/** the path name to the font containing the icons used to display the server flags */
var	const	string	IconFontPathName;

cpptext
{
	/**
	 * @return	TRUE if server corresponding to this search result allows players to use keyboard & mouse.
	 */
	UBOOL AllowsKeyboardMouse();

	/**
	 * Resolves the value of the data field specified and stores it in the output parameter.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	out_FieldValue	receives the resolved value for the property specified.
	 *							@see GetDataStoreValue for additional notes
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL GetFieldValue(const FString& FieldName,FUIProviderFieldValue& out_FieldValue,INT ArrayIndex = INDEX_NONE);

	/**
	 * Builds a list of available fields from the array of properties in the
	 * game settings object
	 *
	 * @param OutFields	out value that receives the list of exposed properties
	 */
	virtual void GetSupportedDataFields(TArray<FUIDataProviderField>& OutFields);

	/**
	 * Gets the list of data fields (and their localized friendly name) for the fields exposed this provider.
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param	out_CellTags	receives the name/friendly name pairs for all data fields in this provider.
	 */
	virtual void GetElementCellTags( FName FieldName, TMap<FName,FString>& out_CellTags );
}

	/**
	 * @return	TRUE if server corresponding to this search result is password protected.
	 */
native function bool IsPrivateServer();

defaultproperties
{
	PlayerRatioTag="PlayerRatio"
	GameModeFriendlyNameTag="GameModeFriendlyName"
	ServerFlagsTag="ServerFlags"
	MapNameTag="CustomMapName"
}
