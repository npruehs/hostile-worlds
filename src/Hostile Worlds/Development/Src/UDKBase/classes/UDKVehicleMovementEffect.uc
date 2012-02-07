//=============================================================================
// VehicleMovementEffect
//  Is the visual effect that is spawned by someone on a vehicle
//  
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class UDKVehicleMovementEffect extends Actor
	native;

/** The static mesh that can be used as a speed effect*/
var staticmeshcomponent AirEffect;

/** slower than this will disable the effect*/
var float MinVelocityForAirEffect;

/** At this speed the air effect is at full level */
var float MaxVelocityForAirEffect;

/** the param in the material(0) of the AirEffect to scale from 0-1*/
var name AirEffectScalar;

/** Max change per second of AirCurrentLevel */
var float AirMaxDelta;

/** Current level of the air effect */
var float AirCurrentLevel;

cpptext
{
	virtual void TickSpecial(FLOAT DeltaTime);
}
defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=AerialMesh
		CollideActors=false
		CastShadow=false
		bAcceptsLights=false
		bOnlyOwnerSee=true
		MaxDrawDistance=7500
		BlockRigidBody=false
		BlockActors=false
		AbsoluteRotation=true
	End Object
	Components.Add(AerialMesh)
	AirEffect=AerialMesh

	MinVelocityForAirEffect=15000.0f
	MaxVelocityForAirEffect=850000.0f
	AirMaxDelta=0.05f;
	AirEffectScalar=Wind_Opacity
}