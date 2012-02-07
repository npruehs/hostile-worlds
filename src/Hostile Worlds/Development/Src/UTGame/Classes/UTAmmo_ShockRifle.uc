/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTAmmo_ShockRifle extends UTAmmoPickupFactory;

defaultproperties
{
	AmmoAmount=10
	TargetWeapon=class'UTWeap_ShockRifleBase'
	PickupSound=SoundCue'A_Pickups.Ammo.Cue.A_Pickup_Ammo_Shock_Cue'
	MaxDesireability=0.28

	Begin Object Name=AmmoMeshComp
		StaticMesh=StaticMesh'Pickups.Ammo_Shock.Mesh.S_Ammo_ShockRifle'
		Translation=(X=0.0,Y=0.0,Z=-15.0)
	End Object

	Begin Object Name=CollisionCylinder
		CollisionHeight=14.4
	End Object
}
