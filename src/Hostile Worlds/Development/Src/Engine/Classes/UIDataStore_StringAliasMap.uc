/**
 * This datastore allows games to map aliases to strings that may change based on the current platform or language setting.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 */
class UIDataStore_StringAliasMap extends UIDataStore_StringBase
	native(inherit)
	Config(Game);

/** Struct to store the field values and how they map to localized strings */
struct native UIMenuInputMap
{
	/** the name of the input alias; i.e. Accept, Cancel, Conditional1, etc. */
	var name FieldName;

	/**
	 * Name of the platform type this mapping is associated with.  Valid values are PC, 360, and PS3.
	 */
	var name Set;

	/**
	 * The actual markup string corresponding to this alias's letter in [usually] a button font
	 */
	var string MappedText;
};

/** Array of input string mappings for use in the front end. */
var config array<UIMenuInputMap> MenuInputMapArray;

/** collection of list element provider instances that are associated with each ElementProviderType */
var	const	private	native	transient	Map_Mirror		MenuInputSets{TMap<FName, TMap<FName, INT> >};

/** The index [into the Engine.GamePlayers array] for the player that this data store provides settings for. */
var	const transient int PlayerIndex;

cpptext
{
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
	* Called when this data store is added to the data store manager's list of active data stores.
	*
	* @param	PlayerOwner		the player that will be associated with this DataStore.  Only relevant if this data store is
	*							associated with a particular player; NULL if this is a global data store.
	*/
	virtual void OnRegister( class ULocalPlayer* PlayerOwner );

	/**
	 * For data stores that are responsible for applying inline style modifications (such as the font, style, and attribute data stores),
	 * parses the data store reference and applies the appropriate style changes.
	 *
	 * @param	MarkupString	a markup string representing a style modification that this data store is aware of; i.e. the name of the font,
	 *							style, or attribute.
	 * @param	StyleData		the style data to apply the changes to.
	 *
	 * @return	TRUE if this data store applied a change to StyleData based on the value of MarkupString, FALSE otherwise.
	 */
	virtual UBOOL ParseStringModifier( const FString& MarkupString, struct FUIStringNodeModifier& StyleData ) { return TRUE; }

public:
	/**
	 * Gets the list of data fields exposed by this data provider.
	 *
	 * @param	out_Fields	will be filled in with the list of tags which can be used to access data in this data provider.
	 *						Will call GetScriptDataTags to allow script-only child classes to add to this list.
	 */
	virtual void GetSupportedDataFields( TArray<struct FUIDataProviderField>& out_Fields );

	/* === UIDataStore_MenuStringMap interface === */
public:
	/** Return the string representation of the field being queried */
	virtual FString GetStringFromIndex( INT MapArrayIndex );
}

/**
 * Returns a reference to the ULocalPlayer that this PlayerSettingsProvdier provider settings data for
 */
native final function LocalPlayer GetPlayerOwner() const;

/**
 * Attempts to find a mapping index given a field name.
 *
 * @param FieldName		Fieldname to search for.
 *
 * @return Returns the index of the mapping in the mapping array, otherwise INDEX_NONE if the mapping wasn't found.
 */
native final function int FindMappingWithFieldName( optional String FieldName="", optional String SetName="" );

/**
 * Set MappedString to be the localized string using the FieldName as a key
 * Returns the index into the mapped string array of where it was found.
 */
native virtual function int GetStringWithFieldName( String FieldName, out String MappedString );

DefaultProperties
{
	Tag=StringAliasMap
	WriteAccessType=ACCESS_ReadOnly
	PlayerIndex=INDEX_NONE
}
