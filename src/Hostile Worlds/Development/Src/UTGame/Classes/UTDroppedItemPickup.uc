/**
 *  base class of dropped pickups for items that don't actually have an Inventory class (e.g. armor)
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTDroppedItemPickup extends UTDroppedPickup;

var float MaxDesireability;
var SoundCue PickupSound;

function float BotDesireability(Pawn Bot, Controller C);

simulated event SetPickupMesh(PrimitiveComponent NewPickupMesh);

event PostBeginPlay()
{
	// spawn an instance of the fake item for AI queries
	Inventory = Spawn(InventoryClass);

	Super.PostBeginPlay();
}

event Destroyed()
{
	Super.Destroyed();

	if (Inventory != None)
	{
		Inventory.Destroy();
	}
}

/** initialize pickup from Pawn that dropped it */
function DroppedFrom(Pawn P);

function PickedUpBy(Pawn P)
{
	PlaySound(PickupSound);

	Super.PickedUpBy(P);
}

defaultproperties
{
	InventoryClass=class'UTPickupInventory'
}
