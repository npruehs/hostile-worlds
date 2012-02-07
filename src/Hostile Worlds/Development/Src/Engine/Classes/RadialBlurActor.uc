/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class RadialBlurActor extends Actor
	placeable;

/**
 *	Actor used to spawn radial screen blur 
 */

/** Blur component created for the actor */
var() RadialBlurComponent	RadialBlur;

defaultproperties
{
	Begin Object Class=RadialBlurComponent Name=RadialBlurComp 		
  	End Object
 	RadialBlur=RadialBlurComp
 	Components.Add(RadialBlurComp)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=FALSE		
	End Object
	Components.Add(Sprite)
}
