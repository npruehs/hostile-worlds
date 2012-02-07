//=============================================================================
// PhysicsVolume:  a bounding volume which affects actor physics
// Each Actor is affected at any time by one PhysicsVolume
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class PhysicsVolume extends Volume
	native
	nativereplication
	placeable;

var()		interp vector	ZoneVelocity;
var()		bool		bVelocityAffectsWalking;
var()		float		GroundFriction;
var()		float		TerminalVelocity;
var()		float		DamagePerSec;
var() class<DamageType>	DamageType<AllowAbstract>;
var()		int			Priority;	// determines which PhysicsVolume takes precedence if they overlap
var()		float		FluidFriction;

var()		bool	bPainCausing;			// Zone causes pain.
/** If pain causing, time between damage applications. */
var()		float	PainInterval;
/** if this is TRUE AI should not treat paths inside this volume differently even if the volume causes pain */
var()		bool	bAIShouldIgnorePain;
/** if bPainCausing, cause pain when something enters the volume in addition to damage each second */
var() bool bEntryPain;
var			bool	BACKUP_bPainCausing;
var()		bool	bDestructive;			// Destroys most actors which enter it.
var()		bool	bNoInventory;
var()		bool	bMoveProjectiles;		// this velocity zone should impart velocity to projectiles and effects
var()		bool	bBounceVelocity;		// this velocity zone should bounce actors that land in it
var()		bool	bNeutralZone;			// Players can't take damage in this zone.

/** If TRUE, crowd agents entering this volume play their death animation. */
var()		bool	bCrowdAgentsPlayDeathAnim;

/**
 *	By default, the origin of an Actor must be inside a PhysicsVolume for it to affect it.
 *	If this flag is true though, if this Actor touches the volume at all, it will affect it.
 */
var()		bool	bPhysicsOnContact;

/**
 *	This controls the force that will be applied to PHYS_RigidBody objects in this volume to get them
 *	to match the ZoneVelocity.
 */
var()		float	RigidBodyDamping;

/** Applies a cap on the maximum damping force that is applied to objects. */
var()		float	MaxDampingForce;

var			bool	bWaterVolume;
var	Info PainTimer;

/** Controller that gets credit for any damage caused by this volume */
var Controller DamageInstigator;

var PhysicsVolume NextPhysicsVolume;

struct CheckpointRecord
{
	var bool bPainCausing;
	var bool bActive;
};

cpptext
{
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
	void SetZone( UBOOL bTest, UBOOL bForceRefresh );
	virtual UBOOL ShouldTrace(UPrimitiveComponent* Primitive,AActor *SourceActor, DWORD TraceFlags);
	virtual UBOOL WillHurt(APawn *P);
	virtual void CheckForErrors();

	virtual FLOAT GetVolumeRBGravityZ() { return GetGravityZ(); }
}

native function float GetGravityZ();
native function vector GetZoneVelocityForActor(Actor TheActor);

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	BACKUP_bPainCausing	= bPainCausing;

	if ( Role < ROLE_Authority )
		return;
	if ( bPainCausing )
	{
		PainTimer = Spawn(class'VolumeTimer', self);
	}
}

/* Reset() - reset actor to initial state - used when restarting level without reloading. */
function Reset()
{
	bPainCausing	= BACKUP_bPainCausing;
	bForceNetUpdate = TRUE;
}

/* Called when an actor in this PhysicsVolume changes its physics mode
*/
event PhysicsChangedFor(Actor Other);

event ActorEnteredVolume(Actor Other);
event ActorLeavingVolume(Actor Other);

event PawnEnteredVolume(Pawn Other);
event PawnLeavingVolume(Pawn Other);

simulated function OnToggle( SeqAct_Toggle inAction )
{
	// don't allow this action to modify the collision of static volumes as we won't be able to update the client
	if (!bStatic || RemoteRole > ROLE_None)
	{
		Super.OnToggle(inAction);
	}

	if (inAction.InputLinks[0].bHasImpulse)
	{
		// Turn on pain if that was it's original state
		bPainCausing = BACKUP_bPainCausing;
	}
	else if (inAction.InputLinks[1].bHasImpulse)
	{
		// Turn off pain
		bPainCausing = FALSE;
	}
	else if (inAction.InputLinks[2].bHasImpulse)
	{
		// Toggle pain off, or on if original state caused pain
		bPainCausing = !bPainCausing && BACKUP_bPainCausing;
	}
}

simulated event CollisionChanged()
{
	// disable Volume behaviour of toggling rigid body collision...
}

/*
TimerPop
damage touched actors if pain causing.
since PhysicsVolume is static, this function is actually called by a volumetimer
*/
function TimerPop(VolumeTimer T)
{
	local Actor A;

	if ( T == PainTimer )
	{
		if ( !bPainCausing )
			return;

		ForEach TouchingActors(class'Actor', A)
		{
			if ( A.bCanBeDamaged && !A.bStatic )
			{
				CausePainTo(A);
			}
		}
	}
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	Super.Touch(Other, OtherComp, HitLocation, HitNormal);
	if ( (Other == None) || Other.bStatic )
		return;
	if ( bNoInventory && (DroppedPickup(Other) != None) && (Other.Owner == None) )
	{
		Other.LifeSpan = 1.5;
		return;
	}
	if ( bMoveProjectiles && (ZoneVelocity != vect(0,0,0)) )
	{
		if ( Other.Physics == PHYS_Projectile )
			Other.Velocity += ZoneVelocity;
			else if ( (Other.Base == None) && Other.IsA('Emitter') && (Other.Physics == PHYS_None) )
		{
			Other.SetPhysics(PHYS_Projectile);
			Other.Velocity += ZoneVelocity;
		}
	}
	if ( bPainCausing )
	{
		if ( Other.bDestroyInPainVolume )
		{
			Other.VolumeBasedDestroy(self);
			return;
		}
		if (bEntryPain && Other.bCanBeDamaged)
		{
			CausePainTo(Other);
		}
	}
}

function CausePainTo(Actor Other)
{
	if (DamagePerSec > 0)
	{
		if ( WorldInfo.bSoftKillZ && (Other.Physics != PHYS_Walking) )
			return;
		if ( (DamageType == None) || (DamageType == class'DamageType') )
			`log("No valid damagetype ("$DamageType$") specified for "$PathName(self));
		Other.TakeDamage(DamagePerSec*PainInterval, DamageInstigator, Location, vect(0,0,0), DamageType,, self);
	}
	else
	{
		Other.HealDamage(-DamagePerSec * PainInterval, DamageInstigator, DamageType);
	}
}

/** called from GameInfo::SetPlayerDefaults() on the Pawn's PhysicsVolume after the its default movement properties have been restored
 * allows the volume to reapply any movement modifiers on the Pawn
 */
function ModifyPlayer(Pawn PlayerPawn);

/** notification when a Pawn inside this volume becomes the ViewTarget for a PlayerController */
function NotifyPawnBecameViewTarget(Pawn P, PlayerController PC);

/** Kismet hook to set DamageInstigator */
function OnSetDamageInstigator(SeqAct_SetDamageInstigator Action)
{
	DamageInstigator = Action.GetController(Action.DamageInstigator);
}

function bool ShouldSaveForCheckpoint()
{
	return (bPainCausing != BACKUP_bPainCausing);
}

function CreateCheckpointRecord(out CheckpointRecord Record)
{
	Record.bPainCausing = bPainCausing;
}

function ApplyCheckpointRecord(const out CheckpointRecord Record)
{
	bPainCausing = Record.bPainCausing;
}

defaultproperties
{
	Begin Object Name=BrushComponent0
		CollideActors=true
		BlockActors=false
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=false
	End Object

	MaxDampingForce=1000000.0
	FluidFriction=+0.3
	bVelocityAffectsWalking=true
	TerminalVelocity=4000.0
	bAlwaysRelevant=true
	bOnlyDirtyReplication=true
	GroundFriction=+00008.000000
	NetUpdateFrequency=0.1
	bSkipActorPropertyReplication=true
	DamageType=class'Engine.DamageType'
	bEntryPain=true
	PainInterval=1.f

	// LDs might just want to toggle pain, which is server only
	// we prevent the collision toggle from working in cases where that wouldn't replicate
	bForceAllowKismetModification=true
}
