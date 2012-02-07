/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKMapInfo extends MapInfo
	native;

/** modifier to visibility/range calculations for AI (range is 0.0 to 1.0) */
var() float VisibilityModifier;

defaultproperties
{
	VisibilityModifier=1.0
}