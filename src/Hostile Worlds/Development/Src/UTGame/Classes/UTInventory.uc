/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTInventory extends Inventory
	abstract;

var bool				bReceiveOwnerEvents;	// If true, receive Owner events. OwnerEvent() is called.

/** adds weapon overlay material this item uses (if any) to the GRI in the correct spot
 *  @see UTPawn.WeaponOverlayFlags, UTWeapon::SetWeaponOverlayFlags
 */
simulated static function AddWeaponOverlay(UTGameReplicationInfo GRI);

/** called on the owning client just before the pickup is dropped or destroyed */
reliable client function ClientLostItem()
{
	if (Role < ROLE_Authority)
	{
		// owner change might not get replicated to client so force it here
		SetOwner(None);
	}
}

simulated event Destroyed()
{
	local Pawn P;

	P = Pawn(Owner);
	if (P != None && (P.IsLocallyControlled() || (P.DrivenVehicle != None && P.DrivenVehicle.IsLocallyControlled())))
	{
		ClientLostItem();
	}

	Super.Destroyed();
}

function DropFrom(vector StartLocation, vector StartVelocity)
{
	ClientLostItem();

	Super.DropFrom(StartLocation, StartVelocity);
}


/* OwnerEvent:
	Used to inform inventory when owner event occurs (for example jumping or weapon change)
	set bReceiveOwnerEvents=true to receive events.
*/
function OwnerEvent(name EventName);

defaultproperties
{
	MessageClass=class'UTPickupMessage'

	DroppedPickupClass=class'UTRotatingDroppedPickup'
}
