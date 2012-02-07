//=============================================================================
// VehicleMovementEffect
//  Is the visual effect that is spawned by someone on a vehicle
//  
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class VehicleMovementEffect extends UDKVehicleMovementEffect;

defaultproperties
{
	Begin Object Name=AerialMesh
		StaticMesh=StaticMesh'Envy_Effects.Mesh.S_Air_Wind_Ball'//StaticMesh'Envy_Effects.Mesh.S_FX_Vehicle_Holocube_01'
		Scale3D=(X=80.0,Y=60.0,Z=60.0)
		Translation=(Z=-100.0)
	End Object
}