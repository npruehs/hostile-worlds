// ============================================================================
// HWSpawnPoint
// A point where players can respawn their commanders.
//
// Author:  Nick Pruehs
// Date:    2011/06/07
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSpawnPoint extends Actor
	placeable;

/** The decal highlighting this spawn point. */
var HWDe_SpawnArea SpawnArea;


simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	SpawnArea = Spawn(class'HWDe_SpawnArea');
}


DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.Corpse'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	bNoDelete=true
	bStatic=true
}
