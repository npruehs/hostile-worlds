/**
 * Provides information about the static resources associated with a single weapon class.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIWeaponSummary extends UIResourceDataProvider
	PerObjectConfig
	Config(Game);

var	config				string				ClassPathName;

var	config	localized	string				FriendlyName;
var	config	localized	string				WeaponDescription;

var	config				bool				bIsDisabled;

/**
 * Allows a resource data provider instance to indicate that it should be unselectable in subscribed lists
 *
 * @return	FALSE to indicate that list elements which represent this data provider should be considered unselectable
 *			or otherwise disabled (though it will still appear in the list).
 */
event bool IsProviderDisabled()
{
	return bIsDisabled;
}

DefaultProperties
{

}
