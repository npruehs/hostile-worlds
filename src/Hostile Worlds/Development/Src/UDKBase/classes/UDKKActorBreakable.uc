/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKKActorBreakable extends KActor
	native;

/** If true, this vehicle has health */
var() bool bHasHealth;

/** If true, this will cause Damage on Encroachment (DOE) */
var() bool bDamageOnEncroachment;

/** If true bDamageOnEncroachment will reset when this actor sleeps or falls below a threshold */
var() bool bResetDOEWhenAsleep;

/** Should this KActor take damage when it encroaches*/
var() bool bTakeDamageOnEncroachment;

/** If true, this KActor will break when it causes damage */
var() bool bBreakWhenCausingDamage;

/** How much health this actor has before it's destroyed */
var() int Health;

/** How much damage this actor does upon contact */
var() int EncroachDamage_Other;

/** How much should it take */
var() int EncroachDamage_Self;

/** When causing damage, use this damage type */
var() class<DamageType> DmgTypeClass;

/** This is the velocity threshhold at which the DOE will reset.  If set to 0, it will only reset on sleep */
var() int DOEResetThreshold;

/** Emitter template to use when this object breaks */
var() ParticleSystem BrokenTemplate;

/** Allows things to pass along a damage instigator */
var controller InstigatorController;

/** If true, this actor is broken and no longer functional */
var repnotify bool bBroken;

cpptext
{
	// AActor interface
	virtual void physRigidBody(FLOAT DeltaTime);
}

/**
 * This delegate is called when this UDKKActorBreakable breaks
 */
delegate OnBreakApart();

/**
 * This delegate is called when this UDKKActorBreakable encroaches on another actor
 */
delegate bool OnEncroach(actor Other);

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	if ( bHasHealth  )
	{
		Health -= Damage;
		if ( Health < 0 )
		{
			BreakApart();
		}
	}
}


function bool EncroachingOn(Actor Other)
{
	if ( OnEncroach(Other) )
		return Super.EncroachingOn(Other);

	if ( bDamageOnEncroachment && Other != InstigatorController && Other != InstigatorController.Pawn )
	{
		Other.TakeDamage(EncroachDamage_Other, InstigatorController, Location, Velocity, DmgTypeClass);
	}

	if ( bTakeDamageOnEncroachment && bHasHealth)
	{
		TakeDamage(EncroachDamage_Self, none ,Location, vect(0,0,0), DmgTypeClass);
	}
	return Super.EncroachingOn(Other);
}

function BreakApart()
{
	SetPhysics(PHYS_None);
	SetCollision(false,false,false);
	StaticMeshComponent.SetHidden(true);
	OnBreakApart();

	if (WorldInfo.NetMode != NM_DedicatedServer && BrokenTemplate != none)
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(BrokenTemplate, Location, Rotation);
	}
	bBroken = true;
	bNetDirty = true;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bBroken')
	{
		BreakApart();
	}
}

defaultproperties
{
	DmgTypeClass=class'DmgType_Crushed'
	DOEResetThreshold=40
}
