/**
 * Provides data for a UT3 map.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKUIDataProvider_MapInfo extends UDKUIResourceDataProvider
	native
	PerObjectConfig;

/** Unique ID for maps. */
var config int	  MapId;

/** Actual map name to load */
var config string MapName;

/** String describing how many players the map is good for. */
var config localized string NumPlayers;

/** Localized description of the map */
var config localized string Description;

/** Markup text used to display the preview image for the map. */
var config string PreviewImageMarkup;

defaultproperties
{
	bSearchAllInis=true
}
