/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// UTAvoidMarker.
// Bots avoid these spots when moving - used for very short term stationary hazards like bio goo or sticky grenades
//=============================================================================
class UTAvoidMarker extends Actor
	notPlaceable;

var CylinderComponent CollisionCylinder;

event Touch( actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if ( (Pawn(Other) != None) && (UTBot(Pawn(Other).Controller) != None) && !WorldInfo.GRI.OnSameTeam(self,Other) )
		UTBot(Pawn(Other).Controller).FearThisSpot(self);
}

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	Begin Object Class=CylinderComponent Name=Cylinder
		CollisionRadius=+0100.000000
		CollisionHeight=+0040.000000
		CollideActors=true
	End Object
	Components.Add(Cylinder)
	CollisionComponent=Cylinder
	CollisionCylinder=Cylinder

	bCollideActors=true
}
