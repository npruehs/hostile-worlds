class DebugManager extends Object
	transient
	native;
/**
 * This class stores temporary state and debug date used during development which is easily
 * accessible via the "set" command from the console and "GEngine->DebugManager" from C++.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/** Index of first miplevel which is colored instead of using the texture data */
var	int	FirstColoredMip;

defaultproperties
{
	// Class properties.
	FirstColoredMip=1000
}
