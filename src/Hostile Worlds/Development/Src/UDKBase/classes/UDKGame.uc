/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKGame extends FrameworkGame
	native;

cpptext
{
	/**
	  *  Initializes the supported game types for a level (its GameTypesSupportedOnThisMap) based on the level filename
	  * and the DefaultMapPrefixes array.  Avoids LDs having to set supported game types up manually (needed for knowing what to cook).
	  */
	virtual void AddSupportedGameTypes(AWorldInfo* Info, const TCHAR* WorldFilename) const;
}
