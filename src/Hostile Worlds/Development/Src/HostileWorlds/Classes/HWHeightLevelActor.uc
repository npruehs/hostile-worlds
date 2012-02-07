// ============================================================================
// HWHeightLevelActor
// Marks the beginning of a new height level.
//
// Author:  Nick Pruehs
// Date:    2011/02/23
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWHeightLevelActor extends Actor
	placeable;

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.Flag1'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	bNoDelete=true
	bStatic=true
}
