//=============================================================================
// PathNode.
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class PathNode extends NavigationPoint
	placeable
	native;

cpptext
{
	virtual INT AddMyMarker(AActor *S);
}

simulated event string GetDebugAbbrev()
{
	return "PN";
}

defaultproperties
{
	Begin Object NAME=Sprite
		Sprite=Texture2D'EditorResources.S_Pickup'
	End Object
}
