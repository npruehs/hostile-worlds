/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// UTPickupInventory:
// This class is used to redirect
// queries normally made to an inventory class to the associated UTItemPickupFactory
//=============================================================================
class UTPickupInventory extends UTInventory;


static function float BotDesireability(Actor PickupHolder, Pawn P, Controller C)
{
	local UTItemPickupFactory F;
	local UTDroppedItemPickup D;

	F = UTItemPickupFactory(PickupHolder);

	if (F != None)
	{
		return F.BotDesireability(P, C);
	}
	else
	{
		D = UTDroppedItemPickup(PickupHolder);
		if (D != None)
		{
			return D.BotDesireability(P, C);
		}
		else
		{
			return 0.0;
		}
	}
}

defaultproperties
{
}
