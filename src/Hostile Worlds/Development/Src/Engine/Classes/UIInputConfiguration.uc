/**
 * Simple container class for storing the UI system's input mappings.  An instance of this class is never actually created, since
 * it is only used as a storage location for UI input mappings.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIInputConfiguration extends UIRoot
	config(Input)
	native(inherit);

/**
 * Default UI action key mappings for each widget class.
 */
var	const	config	public{private}			array<UIInputAliasClassMap>				WidgetInputAliases;

/**
 * Default button press emulation definitions for gamepad and joystick axis input keys.
 */
var	const	config							array<UIAxisEmulationDefinition>		AxisEmulationDefinitions;

cpptext
{
	friend class WxDlgUIEventKeyBindings;

	/**
	 * Returns the list of widget class input aliases.
	 */
	TArray<struct FUIInputAliasClassMap>& GetInputAliasList();
}

/**
 * Loads all widget classes in the WidgetInputAliases array.
 */
native final function LoadInputAliasClasses();

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 */
native function NotifyGameSessionEnded();

DefaultProperties
{

}
