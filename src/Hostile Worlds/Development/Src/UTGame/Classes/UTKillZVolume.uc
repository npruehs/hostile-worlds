/**
 * UTKillZVolume
 * Kills pawns using KillZ interface
 *
 *
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTKillZVolume extends PhysicsVolume
    placeable;

var() class<DamageType> KillZDamageType;

event ActorEnteredVolume(Actor Other)
{
	if (!Other.bStatic)
	{
		KillActor(Other);
	}
}

event PawnEnteredVolume(Pawn Other)
{
	KillActor(Other);
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if (!Other.bStatic)
	{
		KillActor(Other);
	}
}

simulated event KillActor(Actor Other)
{
	if ( !Other.bScriptInitialized )
	{
		// warn if actor was spawned in killz volume (bad)
		`Log(Other @ "destroyed in" @ self @ "while being spawned!",, 'DevSpawn');
	}
	Other.FellOutOfWorld(KillZDamageType);
	if ( UTPawn(Other) != None )
	{
		UTPawn(Other).bStopDeathCamera = true;
	}
	else if ( UTVehicle(Other) != None )
	{
		UTVehicle(Other).bStopDeathCamera = true;
	}
}

defaultproperties
{
	KillZDamageType=class'KillZDamageType'
}
