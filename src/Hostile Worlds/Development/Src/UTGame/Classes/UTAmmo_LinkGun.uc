/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTAmmo_LinkGun extends UTAmmoPickupFactory;

defaultproperties
{
	AmmoAmount=50
	TargetWeapon=class'UTWeap_LinkGun'
	PickupSound=SoundCue'A_Pickups.Ammo.Cue.A_Pickup_Ammo_Link_Cue'
	MaxDesireability=0.24

	Begin Object Name=AmmoMeshComp
		StaticMesh=StaticMesh'Pickups.Ammo_Link.Mesh.S_Ammo_LinkGun'
		Translation=(X=0.0,Y=0.0,Z=-16.0)
	End Object

	Begin Object Name=CollisionCylinder
		CollisionHeight=14.4
	End Object
}
