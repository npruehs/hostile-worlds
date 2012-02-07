/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/** Holds the settings that are common to all match types */
class UDKGameSettingsCommon extends OnlineGameSettings
	native;

/**
 * Converts a string to a hexified blob.
 *
 * @param InString	String to convert.
 * @param OutBlob	Resulting blob
 *
 * @return	Returns whether or not the string was converted.
 */
native static function bool StringToBlob(const out string InString, out string OutBlob);

/**
 * Converts a hexified blob to a normal string.
 *
 * @param InBlob	String to convert back.
 *
 * @return	Returns whether or not the string was converted.
 */
native static function string BlobToString(const out string InBlob);
