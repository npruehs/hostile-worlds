/**
 * Vehicle spawner.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKVehicleFactory extends NavigationPoint
	abstract
	native
	nativereplication
	placeable;

/** full package.class for the vehicle class. You should set this in the default properties, NOT VehicleClass.
 * this indirection is needed for the cooker, so it can fully clear references to vehicles that won't be spawned on the target platform
 * if the direct class reference were in the default properties, this wouldn't be possible without deleting the factory outright,
 * which we can't do without breaking paths
 */
var string VehicleClassPath;

/** Whether vehicles spawned at this factory are initially team locked */
var		bool			bHasLockedVehicle;

/** actual vehicle class to spawn. DO NOT SET THIS IN DEFAULT PROPERTIES - set VehicleClassPath instead */
var		class<UDKVehicle>	VehicleClass;
var		UDKVehicle			ChildVehicle;

/** if set, replicate ChildVehicle reference */
var bool bReplicateChildVehicle;

/** Timer for determining when to spawn vehicles */
var		float			RespawnProgress;		

/** HUD Rendering (for minimap) - updated in SetHUDLocation() */
var		vector			HUDLocation;

var     int             TeamNum;

cpptext
{
	virtual void TickSpecial( FLOAT DeltaSeconds );
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
	virtual void Spawned();
}

replication
{
	if (bNetDirty && Role == ROLE_Authority)
		bHasLockedVehicle;
	if (bNetDirty && Role == ROLE_Authority && bReplicateChildVehicle)
		ChildVehicle;
}

event SpawnVehicle();

/** function used to update where icon for this actor should be rendered on the HUD minimap
 *  @param NewHUDLocation is a vector whose X and Y components are the X and Y components of this actor's icon's 2D position on the HUD minimap
 */
simulated native function SetHUDLocation(vector NewHUDLocation);

simulated native function byte GetTeamNum();
