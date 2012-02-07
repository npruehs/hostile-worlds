/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKVehicleSimHover extends UDKVehicleSimChopper
	native;

/** set wheel collision (repulsors) based on whether have a driver */
var		bool	bDisableWheelsWhenOff;

/** Whether repulsors are currently turned on */
var		bool	bRepulsorCollisionEnabled;

/** if bCanClimbSlopes and on ground, "forward" depends on the slope */
var		bool	bCanClimbSlopes;

/** If true, vehicle has a driver but is unpowered (no engine acceleration) */
var		bool	bUnPoweredDriving;

cpptext
{
	virtual void UpdateVehicle(ASVehicle* Vehicle, FLOAT DeltaTime);
	FLOAT GetEngineOutput(ASVehicle* Vehicle);
	virtual void GetRotationAxes(ASVehicle* Vehicle, FVector &DirX, FVector &DirY, FVector &DirZ);
}

defaultproperties
{
	bDisableWheelsWhenOff=true
	bRepulsorCollisionEnabled=true
}
