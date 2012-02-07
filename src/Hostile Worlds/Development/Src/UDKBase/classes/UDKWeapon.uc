/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKWeapon extends Weapon
	native
	nativereplication
	abstract;

/** mesh for overlay - Each weapon will need to add its own overlay mesh in its default props */
var protected MeshComponent OverlayMesh;

/** Lead targets with this weapon (true by default, ignored for instant hit - set false for special cases like targeting with AVRiL */
var		bool	bLeadTarget;

/** Whether should consider projectile acceleration when leading targets */
var		bool	bConsiderProjectileAcceleration;

/** Current ammo count */
var repnotify int AmmoCount;

/** Replicated flag set when hitscan hits enemy */
var repnotify byte HitEnemy;

/** cached max range of the weapon used for aiming traces */
var float AimTraceRange;

/** actors that the aiming trace should ignore (used by vehicle weapons) */
var array<Actor> AimingTraceIgnoredActors;

replication
{
	// Server->Client properties
	if ( bNetOwner )
		AmmoCount, HitEnemy;
}

cpptext
{
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
	UBOOL Tick( FLOAT DeltaSeconds, ELevelTick TickType );
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	AimTraceRange = MaxRange();
}

/**
 * IsAimCorrect - Returns true if the turret associated with a given seat is aiming correctly
 * Used by vehicle weapons with limited rotation speeds
 * @return TRUE if we can hit where the controller is aiming
 */
simulated event bool IsAimCorrect();

/**
 * BestMode()
 * choose between regular or alt-fire
 */
function byte BestMode();

/** Util that makes sure the overlay component is last in the AllComponents/Components array. */
native function EnsureWeaponOverlayComponentLast();

/**
 * This function aligns the gun model in the world
 */
simulated event SetPosition(UDKPawn Holder);

defaultproperties
{
	bLeadTarget=true
	bConsiderProjectileAcceleration=true
}
