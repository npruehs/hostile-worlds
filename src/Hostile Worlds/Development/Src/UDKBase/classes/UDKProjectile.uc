/**
 * This is our base projectile class.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKProjectile extends Projectile
	abstract
	native
	nativereplication;

/** for console games (wider collision w/ enemy players) */
var bool bWideCheck;

var float CheckRadius;

/** Acceleration magnitude. By default, acceleration is in the same direction as velocity */
var float AccelRate;

/** if true, the shutdown function has been called and 'new' effects shouldn't happen */
var bool bShuttingDown;

//=======================================================
// Seeking Projectile Support

/** Currently tracked target - if set, projectile will seek it */
var actor SeekTarget;

/** Tracking strength for normal targets.*/
var float BaseTrackingStrength;

/** Tracking strength for vehicle targets with bHomingTarget=true */
var float HomingTrackingStrength;

/** Initial direction of seeking projectile */
var vector InitialDir;

/** The last time a lock message was sent (to vehicle with bHomingTarget=true) */
var float	LastLockWarningTime;

/** How long before re-sending the next Lock On message update */
var float	LockWarningInterval;

/** TerminalVelocity for this projectile when falling */
var float TerminalVelocity;

/** Water buoyancy. A ratio (1.0 = neutral buoyancy, 0.0 = no buoyancy) */
var float Buoyancy;

/** custom gravity multiplier */
var float CustomGravityScaling;

/** if this projectile is fired by a vehicle passenger gun, this is the base vehicle
 * considered the same as Instigator for purposes of bBlockedByInstigator
 */
var Vehicle InstigatorBaseVehicle;

/** Make true if want to spawn ProjectileLight.  Set false in TickSpecial() once it's been determined whether Instigator is local player.  Done there to make sure instigator has been replicated */
var bool bCheckProjectileLight;

/** if true, not blocked by vehicle shields with bIgnoreFlaggedProjectiles*/
var bool bNotBlockedByShield;

cpptext
{
	virtual void TickSpecial( FLOAT DeltaSeconds );
	virtual void GetNetBuoyancy(FLOAT &NetBuoyancy, FLOAT &NetFluidFriction);
	virtual FLOAT GetGravityZ();
	virtual UBOOL IgnoreBlockingBy(const AActor* Other) const;
	virtual INT* GetOptimizedRepList(BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel);
}

replication
{
	if (bNetInitial)
		bWideCheck, SeekTarget, InitialDir;
	if (bNetDirty && bReplicateInstigator)
		InstigatorBaseVehicle;
}

/** returns terminal velocity (max speed while falling) for this actor.  Unless overridden, it returns the TerminalVelocity of the PhysicsVolume in which this actor is located.
*/
native function float GetTerminalVelocity();

/** CreateProjectileLight() called from TickSpecial() once if Instigator is local player
*/
simulated event CreateProjectileLight();
