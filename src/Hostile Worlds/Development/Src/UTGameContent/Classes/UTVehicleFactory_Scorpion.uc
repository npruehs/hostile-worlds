/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleFactory_Scorpion extends UTVehicleFactory;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Scorpion.Mesh.SK_VH_Scorpion_001'
		Translation=(X=0.0,Y=0.0,Z=-70.0) // -60 seems about perfect for exact alignment, -70 for some 'lee way'
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=+80.0
		CollisionRadius=+120.0
		Translation=(X=-45.0,Y=0.0,Z=-10.0)
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_Scorpion_Content"
	DrawScale=1.2
}
