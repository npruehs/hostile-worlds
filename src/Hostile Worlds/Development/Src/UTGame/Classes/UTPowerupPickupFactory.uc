/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTPowerupPickupFactory extends UTPickupFactory
	abstract;

/** adds weapon overlay material this powerup uses (if any) to the GRI in the correct spot
 *  @see UTPawn.WeaponOverlayFlags, UTWeapon::SetWeaponOverlayFlags
 */
simulated function AddWeaponOverlay(UTGameReplicationInfo GRI)
{
	local class<UTInventory> UTInvClass;

	UTInvClass = class<UTInventory>(InventoryType);
	if (UTInvClass != None)
	{
		UTInvClass.static.AddWeaponOverlay(GRI);
	}
}

function SpawnCopyFor( Pawn Recipient )
{
	if ( UTPlayerReplicationInfo(Recipient.PlayerReplicationInfo) != None )
	{
		UTPlayerReplicationInfo(Recipient.PlayerReplicationInfo).IncrementPickupStat(GetPickupStatName());
	}
	Recipient.MakeNoise(0.5);

	super.SpawnCopyFor(Recipient);
}

defaultproperties
{
	// setting bMovable=FALSE will break pickups and powerups that are on movers.
	// I guess once we get the LightEnvironment brightness issues worked out and if this is needed maybe turn this on?
	// will need to look at all maps and change the defaults for the pickups that move tho.
	bMovable=TRUE
    bStatic=FALSE

	bRotatingPickup=true
	YawRotationRate=32768

	bIsSuperItem=true
}
