/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/** creates a pickup (NOT pickup factory) in the world */
class UTActorFactoryPickup extends ActorFactory;

var() class<Inventory> InventoryClass;

/** 
  * Initialize factory created pickup
  */
simulated event PostCreateActor(Actor NewActor)
{
	local DroppedPickup Pickup;
	local Inventory NewInventory;

	// spawn the inventory actor
	Pickup = UTDroppedPickup(NewActor);
	
	if ( Pickup != None )
	{
		NewInventory = NewActor.Spawn(InventoryClass);
	}
	if (NewInventory != None)
	{
		Pickup.setPhysics(PHYS_Falling);
		Pickup.Inventory = NewInventory;
		Pickup.InventoryClass = InventoryClass;
		Pickup.SetPickupMesh(Pickup.Inventory.DroppedPickupMesh);
	}
	else
	{
		NewActor.Destroy();
	}
}

defaultproperties
{
	NewActorClass=class'UTDroppedPickup'
	bPlaceable=false
}
