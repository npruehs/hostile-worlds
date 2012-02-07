/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTAmmo_RocketLauncher extends UTAmmoPickupFactory;

defaultproperties
{
	AmmoAmount=8
	TargetWeapon=class'UTWeap_RocketLauncher'
	PickupSound=SoundCue'A_Pickups.Ammo.Cue.A_Pickup_Ammo_Rocket_Cue'
	MaxDesireability=0.3

    // these are so dark they need all the help they can get to have their leet textures show up instead of being basically black
	Begin Object Name=PickupLightEnvironment
	    AmbientGlow=(R=1.0f,G=1.0f,B=1.0f,A=1.0f)
	End Object

	Begin Object Name=AmmoMeshComp
		StaticMesh=StaticMesh'Pickups.Ammo_Rockets.Mesh.S_Ammo_RocketLauncher'
		Rotation=(Roll=16384)
		Translation=(X=0.0,Y=0.0,Z=1.0)
	End Object
}
