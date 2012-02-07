/**
 * Version of DominantDirectionalLight that can be rotated in game and doesn't generate precomputed lighting or shadowing.
 * There can only be one dominant directional light in a given level.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class DominantDirectionalLightMovable extends DominantDirectionalLight
	native(Light)
	placeable;

cpptext
{
}

defaultproperties
{
	Begin Object Name=DominantDirectionalLightComponent0
		WholeSceneDynamicShadowRadius=2000
	End Object

	bMovable=TRUE
	Physics=PHYS_Interpolating
}
