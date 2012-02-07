/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTMutator_Arena extends UTMutator
	config(Game);

/** full path to class of weapon to use */
var config string ArenaWeaponClassPath;

function PostBeginPlay()
{
	local UTGame Game;

	Super.PostBeginPlay();

	Game = UTGame(WorldInfo.Game);
	if (Game != None)
	{
		Game.DefaultInventory.Length = 1;
		Game.DefaultInventory[0] = class<Weapon>(DynamicLoadObject(ArenaWeaponClassPath, class'Class'));
		if (Game.DefaultInventory[0] == None)
		{
			`Warn("Failed to load arena weapon, falling back to rocket launcher");
			Game.DefaultInventory[0] = class<Weapon>(DynamicLoadObject("UTGameContent.UTWeap_RocketLauncher_Content", class'Class'));
		}
	}
}

function bool CheckReplacement(Actor Other)
{
	return (!Other.IsA('UTWeaponPickupFactory') && !Other.IsA('UTAmmoPickupFactory') && !Other.IsA('UTWeaponLocker'));
}

function ModifyPlayer(Pawn Other)
{
	local UTInventoryManager UTInvManager;

	UTInvManager = UTInventoryManager(Other.InvManager);
	if (UTInvManager != None)
	{
		UTInvManager.bInfiniteAmmo = true;
	}

	Super.ModifyPlayer(Other);
}

defaultproperties
{
	GroupNames[0]="WEAPONMOD"
	GroupNames[1]="WEAPONRESPAWN"
}
