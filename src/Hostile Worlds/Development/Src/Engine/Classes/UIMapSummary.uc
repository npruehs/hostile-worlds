/**
 * Provides information about the static resources available for a particular map.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIMapSummary extends UIResourceDataProvider
	PerObjectConfig
	Config(Game)
	native(UIPrivate);

var	config		string	MapName;
var	config		string	ScreenshotPathName;

var	localized	string	DisplayName;
var	localized	string	Description;

DefaultProperties
{

}
