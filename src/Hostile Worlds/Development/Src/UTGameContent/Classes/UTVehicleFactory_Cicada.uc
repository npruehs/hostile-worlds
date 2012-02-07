/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleFactory_Cicada extends UTVehicleFactory;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Cicada.Mesh.SK_VH_Cicada'
		Translation=(X=-40.0,Y=0.0,Z=-70.0) // -60 seems about perfect for exact alignment, -70 for some 'lee way'
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=+120.0
		CollisionRadius=+200.0
		Translation=(X=0.0,Y=0.0,Z=-40.0)
	End Object

	VehicleClassPath="UTGameContent.UTVehicle_Cicada_Content"
	DrawScale=1.3
}
