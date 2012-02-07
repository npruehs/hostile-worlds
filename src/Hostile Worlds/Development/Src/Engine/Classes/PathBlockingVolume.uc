/**
 * this volume only blocks the path builder - it has no gameplay collision
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class PathBlockingVolume extends Volume
	native
	placeable;

cpptext
{
	virtual void SetCollisionForPathBuilding(UBOOL bNowPathBuilding);
}

defaultproperties
{
	Begin Object Name=BrushComponent0
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
		AlwaysLoadOnClient=false
		AlwaysLoadOnServer=false
	End Object

	bWorldGeometry=true
	bCollideActors=false
	bBlockActors=true
}
