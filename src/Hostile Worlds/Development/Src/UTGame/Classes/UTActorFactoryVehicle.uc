/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTActorFactoryVehicle extends ActorFactoryVehicle;

/** whether the vehicle starts out locked and can only be used by the owning team */
var() bool bTeamLocked;
/** the number of the team that may use this vehicle */
var() byte TeamNum;
/** if set, force vehicle to be a key vehicle (displayed on map and considered more important by AI) */
var() bool bKeyVehicle;


/** 
  * Initialize factory created vehicle
  */
simulated event PostCreateActor(Actor NewActor)
{
	local UTVehicle NewVehicle;
	
	NewVehicle = UTVehicle(NewActor);
	if ( NewVehicle != None )
	{
		NewVehicle.SetTeamNum(TeamNum);
		NewVehicle.bTeamLocked = bTeamLocked;
		if (bKeyVehicle)
		{
			NewVehicle.SetKeyVehicle();
		}
		// actor factories could spawn the vehicle anywhere, so make sure it's awake so it doesn't end up floating or something
		if ( NewVehicle.Mesh != None)
		{
			NewVehicle.Mesh.WakeRigidBody();
		}
	}
}

defaultproperties
{
	VehicleClass=class'UTVehicle'
	bTeamLocked=true
}
