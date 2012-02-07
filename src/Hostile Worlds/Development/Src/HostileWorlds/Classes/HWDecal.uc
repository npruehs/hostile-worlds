// ============================================================================
// HWDecal
// A decal used for indicating areas or radiuses.
//
// Author:  Nick Pruehs
// Date:    2011/03/07
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWDecal extends DecalActorMovable
	config(HostileWorlds);

/** Half the initial width and height of the texture of this decal. */
var config float InitialRadius;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	// Rotation is set wrong by Spawn in most cases...
	SetRotation(default.Rotation);

	// most decals are shown in special situations only
	SetHidden(true);

	SetRadius(InitialRadius);
}

/**
 * Sets the width and height of the texture of this decal to twice the
 * passed value.
 * 
 * @param Radius
 *      the new radius indicated by this decal
 */
simulated function SetRadius(float Radius)
{
	Decal.Height = Radius * 2;
	Decal.Width = Radius * 2;
}

DefaultProperties
{
	bNoDelete=false

	Rotation=(Pitch=-16384,Yaw=0,Roll=0) // -90°

	Begin Object Name=NewDecalComponent
		NearPlane=-300.0f
	End Object	
}
