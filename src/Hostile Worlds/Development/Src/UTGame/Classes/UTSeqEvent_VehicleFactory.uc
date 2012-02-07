/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTSeqEvent_VehicleFactory extends SequenceEvent;

/** reference to the vehicle spawned by the factory */
var UTVehicle SpawnedVehicle;

event Activated()
{
	if (UTVehicleFactory(Originator) != None)
	{
		SpawnedVehicle = UTVehicle(UTVehicleFactory(Originator).ChildVehicle);
	}
}

defaultproperties
{
	ObjName="Vehicle Factory Event"
	OutputLinks[0]=(LinkDesc="Spawned")
	OutputLinks[1]=(LinkDesc="Taken")
	OutputLinks[2]=(LinkDesc="Destroyed")
	OutputLinks[3]=(LinkDesc="VehicleEntered")
	OutputLinks[4]=(LinkDesc="VehicleLeft")
	bPlayerOnly=false
	MaxTriggerCount=0
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawned Vehicle",bWriteable=true,PropertyName=SpawnedVehicle)
}
