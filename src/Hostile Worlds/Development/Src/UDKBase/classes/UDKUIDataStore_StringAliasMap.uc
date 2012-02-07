/**
 * This datastore allows games to map aliases to strings that may change based on the current platform or language setting.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 */
class UDKUIDataStore_StringAliasMap extends UIDataStore_StringAliasMap
	native
	Config(Game);

/** Debug variable to fake a platform: -1 = Normal, 0 = PC, 1 = XBox360, 2 = PS3 */
var config int FakePlatform;

/**
 * Set MappedString to be the localized string using the FieldName as a key
 * Returns the index into the mapped string array of where it was found.
 */
native virtual function int GetStringWithFieldName( String FieldName, out String MappedString );

