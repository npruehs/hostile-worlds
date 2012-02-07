// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
class UTMutator_SuperBerserk extends UTMutator;


/* called by GameInfo.RestartPlayer()
	change the players jumpz, etc. here
*/
function ModifyPlayer(Pawn Other)
{
	local UTPawn P;

	//@todo: we used to just give the Berserk powerup here, so then it would be limited time unless you killed people,
	//	plus there were lots of powerups falling everywhere, which was cool
	//	but we can't afford the Berserk being in memory all the time on console
	//	maybe still do it on PC though?
	//P.CreateInventory(class'UTGame.UTBerserk');

	P = UTPawn(Other);
	if (P != None)
	{
		P.FireRateMultiplier *= 0.5;
	}
	Super.ModifyPlayer(Other);
}

/**
 * Max out UTWeapon ammo
 */
function bool CheckReplacement(Actor Other)
{
	local UTWeapon W;

	W = UTWeapon(Other);
	if ( (W != None) && !W.bSuperWeapon )
	{
		W.Loaded(true);
	}
	return true;
}

defaultproperties
{
	GroupNames[0]="FIRINGSPEED"
}
