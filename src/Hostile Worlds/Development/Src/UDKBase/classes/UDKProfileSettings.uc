/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * List of profile settings for UT
 */
class UDKProfileSettings extends OnlineProfileSettings
	native;
	

/**
 * Sets the specified profile id back to its default value.
 *
 * @param ProfileId	Profile setting to reset to default.
 */
native function ResetToDefault(int ProfileId);


/**
 * Resets the current keybindings for the specified playerowner to the defaults specified in the INI.
 *
 * @param InPlayerOwner	Player to get the default keybindings for.
 */
native static function ResetKeysToDefault(optional LocalPlayer InPlayerOwner);

