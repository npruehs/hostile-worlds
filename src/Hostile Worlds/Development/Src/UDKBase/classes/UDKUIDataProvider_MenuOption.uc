/**
 * Provides an option for a UI menu item.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKUIDataProvider_MenuOption extends UDKUIResourceDataProvider
	native
	PerObjectConfig;

enum EUTOptionType
{
	UTOT_ComboReadOnly,
	UTOT_ComboNumeric,
	UTOT_CheckBox,
	UTOT_Slider,
	UTOT_Spinner,
	UTOT_EditBox,
	UTOT_CollectionCheckBox
};

var config EUTOptionType OptionType;

/** Name of the option set that this option belongs to. */
var config array<name> OptionSet;

/** Markup for the option */
var config string DataStoreMarkup;

/** Game mode required for this option to appear. */
var config name RequiredGameMode;

/** Script settable friendly name. */
var string CustomFriendlyName;

/** Localized description of the option */
var config localized string Description;

/** Whether or not the options presented to the user are the only options they can choose from, used on PC only for setting whether combobox edit boxes are read only or not. */
var config bool bEditableCombo;

/** Whether or not the combobox is numeric. */
var config bool	bNumericCombo;

/** Maximum length of the editbox property. */
var config int EditBoxMaxLength;

/** the allowed character set for editboxes */
var	config EEditBoxCharacterSet EditboxAllowedChars;

/** Range data for the option, only used if its a slider type. */
var config UIRangeData	RangeData;

/** Whether the option is a keyboard or mouse option. */
var config bool	bKeyboardOrMouseOption;

/** Whether the option is a online only option or not. */
var config bool bOnlineOnly;

/** Whether the option is a offline only option or not. */
var config bool bOfflineOnly;

cpptext
{
	/** @return 	TRUE if this menu option's configuration isn't compatible with the desired game settings  */
	virtual UBOOL IsFiltered();
}

