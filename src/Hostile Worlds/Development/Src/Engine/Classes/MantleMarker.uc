/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MantleMarker extends NavigationPoint
	native;

cpptext
{
	virtual UBOOL	CanConnectTo( ANavigationPoint* Nav, UBOOL bCheckDistance );
}

var() editconst CoverInfo OwningSlot;

defaultproperties
{
	bCollideWhenPlacing=FALSE
	bSpecialMove=TRUE

//	Components.Remove(Sprite)
//	Components.Remove(Sprite2)
	Components.Remove(Arrow)

	Begin Object Name=CollisionCylinder
		CollisionRadius=40.f
		CollisionHeight=40.f
	End Object
}