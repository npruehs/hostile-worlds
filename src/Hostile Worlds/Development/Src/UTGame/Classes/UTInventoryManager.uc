/**
 * UTInventoryManager
 * UT inventory definition
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTInventoryManager extends InventoryManager
	config(Game);

/** if true, all weapons use no ammo */
var bool bInfiniteAmmo;

/** This struct defines ammo that is stored in inventory, but for which the pawn doesn't yet have a weapon for. */
struct native AmmoStore
{
	var	int				Amount;
	var class<UTWeapon> WeaponClass;
};

/** Stores the currently stored up ammo */
var array<AmmoStore> AmmoStorage;

/** Holds the last weapon used */
var Weapon PreviousWeapon;

/** weapon server is retrying switch to because the current weapon temporarily denied it (due to currently firing, etc) */
var UTWeapon PendingSwitchWeapon;

/** last time AdjustWeapon() was called */
var float LastAdjustWeaponTime;

replication
{
	if (bNetDirty)
		bInfiniteAmmo;
}


/**
 * Used to inform inventory when owner event occurs (for example jumping or weapon change)
 *
 * @param	EventName	Name of event to forward to inventory items.
 */
simulated function OwnerEvent(name EventName)
{
	local UTInventory	Inv;

	ForEach InventoryActors(class'UTInventory', Inv)
	{
		if( Inv.bReceiveOwnerEvents )
		{
			Inv.OwnerEvent(EventName);
		}
	}
}

/**
 * This function returns a sorted list of weapons, sorted by their InventoryWeight.
 *
 * @Returns the index of the current Weapon
 */
simulated function GetWeaponList(out array<UTWeapon> WeaponList, optional bool bFilter, optional int GroupFilter, optional bool bNoEmpty)
{
	local UTWeapon Weap;
	local int i;

	ForEach InventoryActors( class'UTWeapon', Weap )
	{
		if ( (!bFilter || Weap.InventoryGroup == GroupFilter) && ( !bNoEmpty || Weap.HasAnyAmmo()) )
		{
			if ( WeaponList.Length>0 )
			{
				// Find it's place and put it there.

				for (i=0;i<WeaponList.Length;i++)
				{
					if (WeaponList[i].InventoryWeight > Weap.InventoryWeight)
					{
						WeaponList.Insert(i,1);
						WeaponList[i] = Weap;
						break;
					}
				}
				if (i==WeaponList.Length)
				{
					WeaponList.Length = WeaponList.Length+1;
					WeaponList[i] = Weap;
				}
			}
			else
			{
				WeaponList.Length = 1;
				WeaponList[0] = Weap;
			}
		}
	}
}

/**
 * Handling switching to a weapon group
 */

simulated function SwitchWeapon(byte NewGroup)
{
	local UTWeapon CurrentWeapon;
	local array<UTWeapon> WeaponList;
	local int NewIndex;

	// Get the list of weapons

   	GetWeaponList(WeaponList,true,NewGroup);

	// Exit out if no weapons are in this list.

	if (WeaponList.Length<=0)
		return;

	CurrentWeapon = UTWeapon(PendingWeapon);
	if (CurrentWeapon == None)
	{
		CurrentWeapon = UTWeapon(Instigator.Weapon);
	}

	if (CurrentWeapon == none || CurrentWeapon.InventoryGroup != NewGroup)
	{
		// Changing groups, so activate the first weapon in the array

		NewIndex = 0;
	}
	else
	{
		// Find the current weapon's position in the list and switch to the one above it

		for (NewIndex=0;NewIndex<WeaponList.Length;NewIndex++)
		{
			if (WeaponList[NewIndex] == CurrentWeapon)
				break;
		}
		NewIndex++;
		if (NewIndex>=WeaponList.Length)		// start the beginning if past the end.
			NewIndex = 0;
	}

	// Begin the switch process...

	if ( WeaponList[NewIndex].HasAnyAmmo() )
	{
		SetCurrentWeapon(WeaponList[NewIndex]);
	}
}

simulated function AdjustWeapon(int NewOffset)
{
	local Weapon CurrentWeapon;
	local array<UTWeapon> WeaponList;
	local int i, Index;

	// don't allow multiple weapon switches very close to one another (seems to happen with some mouse wheels)
	if (WorldInfo.TimeSeconds - LastAdjustWeaponTime < 0.05)
	{
		return;
	}
	LastAdjustWeaponTime = WorldInfo.TimeSeconds;

	CurrentWeapon = UTWeapon(PendingWeapon);
	if (CurrentWeapon == None)
	{
		CurrentWeapon = UTWeapon(Instigator.Weapon);
	}

   	GetWeaponList(WeaponList,,, true);
   	if (WeaponList.length == 0)
   	{
   		return;
   	}

	for (i = 0; i < WeaponList.Length; i++)
	{
		if (WeaponList[i] == CurrentWeapon)
		{
			Index = i;
			break;
		}
	}

	Index += NewOffset;
	if (Index < 0)
	{
		Index = WeaponList.Length - 1;
	}
	else if (Index >= WeaponList.Length)
	{
		Index = 0;
	}

	if (Index >= 0)
	{
		SetCurrentWeapon(WeaponList[Index]);
	}
}

/**
 * Switches to Previous weapon
 * Network: Client
 */
simulated function PrevWeapon()
{
	if ( UTWeapon(Pawn(Owner).Weapon) != None && UTWeapon(Pawn(Owner).Weapon).DoOverridePrevWeapon() )
		return;

	AdjustWeapon(-1);
}

/**
 *	Switches to Next weapon
 *	Network: Client
 */
simulated function NextWeapon()
{
	if ( UTWeapon(Pawn(Owner).Weapon) != None && UTWeapon(Pawn(Owner).Weapon).DoOverrideNextWeapon() )
		return;

	AdjustWeapon(+1);
}

/** AllAmmo()
All weapons currently in inventory have ammo increased to max allowed value.  Super weapons will only have their ammo amount changed if
bAmmoForSuperWeapons is true.
*/
function AllAmmo(optional bool bAmmoForSuperWeapons)
{
	local Inventory Inv;

	for( Inv=InventoryChain; Inv!=None; Inv=Inv.Inventory )
		if ( (UTWeapon(Inv)!=None) && (bAmmoForSuperWeapons || !UTWeapon(Inv).bSuperWeapon) )
			UTWeapon(Inv).Loaded(true);
}

/**
 * SetCurrentWeapon starts a weapon change.  It calls SetPendingWeapon and then if it's called
 * on a remote client, tells the server to begin the process.
 *
 * @param	DesiredWeapon		The Weapon to switch to
 */

reliable client function SetCurrentWeapon( Weapon DesiredWeapon )
{
	SetPendingWeapon(DesiredWeapon);

	// If we are a remote client, make sure the Server Set's its pending weapon

	if( Role < Role_Authority )
	{
		ServerSetCurrentWeapon(DesiredWeapon);
	}

}

/**
 * Accessor for the server to begin a weapon switch on the client.
 *
 * @param	DesiredWeapon		The Weapon to switch to
 */

reliable client function ClientSetCurrentWeapon(Weapon DesiredWeapon)
{
	SetPendingWeapon(DesiredWeapon);
}

/**
 * When a client-switch begins on a remote-client, the server needs to be told to
 * start the process as well.  SetCurrentWeapon() makes that call.
 *
 * NETWORK - This function should *ONLY* be called from a remote client's SetCurrentWeapon()
 * function.
 *
 * @param	DesiredWeapon		The Weapon to switch to
 */

reliable server function ServerSetCurrentWeapon(Weapon DesiredWeapon)
{
	SetPendingWeapon(DesiredWeapon);
}

/**
 * This is the work-horse of the weapon switch.  It will set a new pending weapon
 * and tell the weapon to begin the switch.  If the call to Weapon.TryPutdown() returns
 * false, it means that the weapon can't switch at the moment and has deferred it until later
 *
 * @param	DesiredWeapon		The Weapon to switch to
 */

simulated function SetPendingWeapon( Weapon DesiredWeapon )
{
	local UTWeapon PrevWeapon, CurrentPending;
	local UTPawn UTP;

	if (Instigator == None)
	{
		return;
	}

	PrevWeapon = UTWeapon( Instigator.Weapon );
	CurrentPending = UTWeapon(PendingWeapon);

	if ( (PrevWeapon == None || PrevWeapon.AllowSwitchTo(DesiredWeapon)) &&
		(CurrentPending == None || CurrentPending.AllowSwitchTo(DesiredWeapon)) )
	{
		// We only work with UTWeapons
		// Detect that a weapon is being reselected.  If so, notify that weapon.
		if ( DesiredWeapon != None && DesiredWeapon == Instigator.Weapon )
		{
			if (PendingWeapon != None)
			{
				PendingWeapon = None;
			}
			else
			{
				PrevWeapon.ServerReselectWeapon();
			}

			// If this weapon is ready to fire, there is no reason to perform the whole switch logic.
			if (!PrevWeapon.bReadyToFire())
			{
				PrevWeapon.Activate();
			}
			else
			{
				PrevWeapon.bWeaponPutDown = false;
			}
		}
		else
		{
			if ( Instigator.IsHumanControlled() && Instigator.IsLocallyControlled() )
			{
				// preload pending weapon textures, clear any other preloads
				if ( UTWeapon(Instigator.Weapon) != None )
				{
					UTWeapon(Instigator.Weapon).PreloadTextures(false);
				}
				if ( PendingWeapon != None )
				{
					UTWeapon(PendingWeapon).PreloadTextures(false);
				}
	 			UTWeapon(DesiredWeapon).PreloadTextures(true);
			}
			PendingWeapon = DesiredWeapon;

			// if there is an old weapon handle it first.
			if( PrevWeapon != None && !PrevWeapon.bDeleteMe && !PrevWeapon.IsInState('Inactive') )
			{
				PrevWeapon.TryPutDown();
			}
			else
			{
				// We don't have a weapon, force the call to ChangedWeapon
				ChangedWeapon();
			}
		}
	}

	UTP = UTPawn(Instigator);
	if (UTP != None)
	{
		UTP.SetPuttingDownWeapon((PendingWeapon != None));
	}
}

/**
 * Weapon just given to a player, check if player should switch to this weapon
 * Network: LocalPlayer
 * Called from Weapon.ClientWeaponSet()
 */
simulated function ClientWeaponSet(Weapon NewWeapon, bool bOptionalSet, optional bool bDoNotActivate)
{
	local Weapon OldWeapon;

	OldWeapon = Instigator.Weapon;

		// If no current weapon, then set this one
		if ( OldWeapon == None || OldWeapon.bDeleteMe || OldWeapon.IsInState('Inactive') )
		{
			SetCurrentWeapon(NewWeapon);
			return;
		}

		if ( OldWeapon == NewWeapon )
		{
			return;
		}

		if (!bOptionalSet)
		{
			SetCurrentWeapon(NewWeapon);
			return;
		}

		if (Instigator.IsHumanControlled() && PlayerController(Instigator.Controller).bNeverSwitchOnPickup)
		{
		NewWeapon.GotoState('Inactive');
		return;
	}
	
	if ( OldWeapon.IsFiring() || OldWeapon.DenyClientWeaponSet() && (UTWeapon(NewWeapon) != None) )
	{
		NewWeapon.GotoState('Inactive');
		RetrySwitchTo(UTWeapon(NewWeapon));
			return;
		}

		// Compare switch priority and decide if we should switch to new weapon
		if ( (PendingWeapon == None || !PendingWeapon.HasAnyAmmo() || PendingWeapon.GetWeaponRating() < NewWeapon.GetWeaponRating()) &&
			(!Instigator.Weapon.HasAnyAmmo() || Instigator.Weapon.GetWeaponRating() < NewWeapon.GetWeaponRating()) )
		{
			SetCurrentWeapon(NewWeapon);
			return;
		}

	NewWeapon.GotoState('Inactive');
}


simulated function Inventory CreateInventory(class<Inventory> NewInventoryItemClass, optional bool bDoNotActivate)
{
	if (Role==ROLE_Authority)
	{
		return Super.CreateInventory(NewInventoryItemClass, bDoNotActivate);
	}
	return none;
}

/** timer function set by RetrySwitchTo() to actually retry the switch */
simulated function ProcessRetrySwitch()
{
	local UTWeapon NewWeapon;

	NewWeapon = PendingSwitchWeapon;
	PendingSwitchWeapon = None;
	if (NewWeapon != None)
	{
		CheckSwitchTo(NewWeapon);
	}
}

/** called to retry switching to the passed in weapon a little later */
simulated function RetrySwitchTo(UTWeapon NewWeapon)
{
	PendingSwitchWeapon = NewWeapon;
	SetTimer(0.1, false, 'ProcessRetrySwitch');
}

/** checks if we should autoswitch to this weapon (server) */
simulated function CheckSwitchTo(UTWeapon NewWeapon)
{
	if ( UTWeapon(Instigator.Weapon) == None ||
			( Instigator != None && PlayerController(Instigator.Controller) != None &&
				UTWeapon(Instigator.Weapon).ShouldSwitchTo(NewWeapon) ) )
	{
		NewWeapon.ClientWeaponSet(true);
	}
}

/**
 * Handle AutoSwitching to a weapon
 */
simulated function bool AddInventory( Inventory NewItem, optional bool bDoNotActivate )
{
	local bool bResult;
	local int i;

	if (Role == ROLE_Authority)
	{
		bResult = super.AddInventory(NewItem, bDoNotActivate);

		if (bResult && UTWeapon(NewItem) != None)
		{
			// Check to see if we need to give it any extra ammo the pawn has picked up

			for (i=0;i<AmmoStorage.Length;i++)
			{
				if (AmmoStorage[i].WeaponClass == NewItem.Class)
				{
					UTWeapon(NewItem).AddAmmo(AmmoStorage[i].Amount);
					AmmoStorage.Remove(i,1);
					break;
				}
			}

			if (!bDoNotActivate)
			{
				CheckSwitchTo(UTWeapon(NewItem));
			}
		}
	}

	return bResult;
}

simulated function DiscardInventory()
{
	local Vehicle V;

	if (Role == ROLE_Authority)
	{
		Super.DiscardInventory();

		V = Vehicle(Owner);
		if (V != None && V.Driver != None && V.Driver.InvManager != None)
		{
			V.Driver.InvManager.DiscardInventory();
		}
	}
}

simulated function RemoveFromInventory(Inventory ItemToRemove)
{
	if (Role==ROLE_Authority)
	{
		Super.RemoveFromInventory(ItemToRemove);
		if (PendingSwitchWeapon == ItemToRemove)
		{
			PendingSwitchWeapon = None;
			ClearTimer('ProcessRetrySwitch');
		}
	}
}

function bool NeedsAmmo(class<UTWeapon> TestWeapon)
{
	local array<UTWeapon> WeaponList;
	local int i;

	// Check the list of weapons
	GetWeaponList(WeaponList);
	for (i=0;i<WeaponList.Length;i++)
	{
		if ( ClassIsChildOf(WeaponList[i].Class, TestWeapon) )	// The Pawn has this weapon
		{
			if ( WeaponList[i].AmmoCount < WeaponList[i].MaxAmmoCount )
				return true;
			else
				return false;
		}
	}

	// Check our stores.
	for (i=0;i<AmmoStorage.Length;i++)
	{
		if ( ClassIsChildOf(WeaponList[i].Class, TestWeapon) )
		{
			if ( AmmoStorage[i].Amount < TestWeapon.default.MaxAmmoCount )
				return true;
			else
				return false;
		}
	}

	return true;

}

/**
 * Called by the UTAmmoPickup classes, this function attempts to add ammo to a weapon.  If that
 * weapon exists, it adds it otherwise it tracks the ammo in an array for later.
 */

function AddAmmoToWeapon(int AmountToAdd, class<UTWeapon> WeaponClassToAddTo)
{
	local array<UTWeapon> WeaponList;
	local int i;

	// Get the list of weapons

	GetWeaponList(WeaponList);
	for (i=0;i<WeaponList.Length;i++)
	{
		if ( ClassIsChildOf(WeaponList[i].Class, WeaponClassToAddTo) )	// The Pawn has this weapon
		{
			WeaponList[i].AddAmmo(AmountToAdd);
			return;
		}
	}

	// Add to to our stores for later.

	for (i=0;i<AmmoStorage.Length;i++)
	{

		// We are already tracking this type of ammo, so just increment the ammount

		if (AmmoStorage[i].WeaponClass == WeaponClassToAddTo)
		{
			AmmoStorage[i].Amount += AmountToAdd;
			return;
		}
	}

	// Track a new type of ammo

	i = AmmoStorage.Length;
	AmmoStorage.Length = AmmoStorage.Length + 1;
	AmmoStorage[i].Amount = AmountToAdd;
	AmmoStorage[i].WeaponClass = WeaponClassToAddTo;

}

/**
 * Scans the inventory looking for any of type InvClass.  If it finds it it returns it, other
 * it returns none.
 */

function Inventory HasInventoryOfClass(class<Inventory> InvClass)
{
	local inventory inv;

	inv = InventoryChain;
	while(inv!=none)
	{
		if (Inv.Class==InvClass)
			return Inv;

		Inv = Inv.Inventory;
	}

	return none;
}

/**
 * Store the last used weapon for later
 */

simulated function ChangedWeapon()
{
	local UTWeapon Wep;
	local UTPawn UTP;

	PreviousWeapon = Instigator.Weapon;
	Super.ChangedWeapon();

	Wep = UTWeapon(Instigator.Weapon);

	// Clear out Pending fires if the weapon doesn't allow them

	if ( Wep!=none && Wep.bNeverForwardPendingFire )
	{
		ClearAllPendingFire(Wep);
	}

	UTP = UTPawn(Instigator);
	if (UTP != None)
	{
		UTP.SetPuttingDownWeapon((PendingWeapon != None));
	}
}

simulated function SwitchToPreviousWeapon()
{
	if ( PreviousWeapon!=none && PreviousWeapon != Pawn(Owner).Weapon )
	{
		PreviousWeapon.ClientWeaponSet(false);
	}
}


/**
 * Hook called from HUD actor. Gives access to HUD and Canvas
 *
 * @param	H	HUD
 */
simulated function DrawHud(HUD H)
{
	scripttrace();

	// Send ActiveRenderOverlays event to active weapon
	if( UTWeapon(Instigator.Weapon) != None )
	{
		UTWeapon(Instigator.Weapon).ActiveRenderOverlays(H);
	}
}

/**
 * Cut and pasted here except call ClientWeaponSet on the weapon instead of forcing it.
 * This causes all of the "should I put down" logic to occur
 */

simulated function SwitchToBestWeapon( optional bool bForceADifferentWeapon )
{
	local Weapon BestWeapon;

	if (Instigator.IsLocallyControlled())
	{
		// if we don't already have a pending weapon,
		if( bForceADifferentWeapon ||
			PendingWeapon == None ||
			(AIController(Instigator.Controller) != None) )
		{
			// figure out the new weapon to bring up
			BestWeapon = GetBestWeapon( bForceADifferentWeapon );

			// if it matches our current weapon then don't bother switching
			if( BestWeapon == Instigator.Weapon )
			{
				BestWeapon = None;
				PendingWeapon = None;
				if (Instigator.Weapon != None)
				{
					Instigator.Weapon.Activate();
				}
			}
		}

		if (BestWeapon != None)
		{
			SetCurrentWeapon(BestWeapon);
		}
	}
}

defaultproperties
{
	bMustHoldWeapon=true
	PendingFire(0)=0
	PendingFire(1)=0
}
