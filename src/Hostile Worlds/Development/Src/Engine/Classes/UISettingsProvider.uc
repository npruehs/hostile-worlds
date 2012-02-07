/**
 * Base class for data providers which provide settings data.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UISettingsProvider extends UIPropertyDataProvider
	native(inherit)
	abstract;

/**
 * The tag to use for this provider.  This is the name that will appear in the data store browser for this data provider's tree item.
 */
var			const		name			ProviderTag;

/**
 * Stores the options related to creating or connecting to game sessions that have been selected thus far.
 */
//var		const		transient		SessionOptionsManager		CurrentSession;

// initializes the value of the widget, sets up any additional parameters such as maxvalue, minvalue, etc.
function LoadPropertyValue( name PropertyName, UIObject Widget );

//  - saves the current value of the widget to the appropriate location
function SavePropertyValue( name PropertyName, UIObject Widget );

// - called when the user changes the value of a widget that is bound to a property in this datastore
// return true to indicate that the scene should reload the property values for all bound widgets.
function bool OnModifiedProperty( name PropertyName, UIObject Widget );

/**
 * Allows the data provider to clear any references that would interfere with garbage collection.
 *
 * @return	TRUE if the instance reference was successfully cleared.
 */
function bool CleanupDataProvider()
{
	return true;
}

DefaultProperties
{
	ProviderTag=SettingsProvider
}
