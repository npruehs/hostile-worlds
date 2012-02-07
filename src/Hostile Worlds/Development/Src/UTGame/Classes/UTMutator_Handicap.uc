// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
class UTMutator_Handicap extends UTMutator;

/* called by GameInfo.RestartPlayer()
	change the players jumpz, etc. here
*/
function ModifyPlayer(Pawn P)
{
	local int HandicapNeed;
	local UTPawn PlayerPawn;
	local UTWeap_LinkGun PlayerGun;
	
	PlayerPawn = UTPawn(P);
	if ( PlayerPawn == None )
	{
		return;
	}

	HandicapNeed = UTGame(WorldInfo.Game).GetHandicapNeed(PlayerPawn);

	if ( HandicapNeed > 2 )
	{
		// give a shieldbelt as well
		PlayerPawn.ShieldBeltArmor = Max(100, PlayerPawn.ShieldBeltArmor);
	}

	if ( HandicapNeed >= 1 )
	{
		PlayerPawn.VestArmor = Max(50, PlayerPawn.VestArmor);
	}
	if ( HandicapNeed >= 2 )
	{
		PlayerGun = UTWeap_LinkGun(PlayerPawn.FindInventoryType(class'UTWeap_LinkGun'));
		if ( PlayerGun != None )
		{
			PlayerGun.BoostPower();
		}
	}

	Super.ModifyPlayer(PlayerPawn);
}

defaultproperties
{
	GroupNames[0]="HANDICAP"
}


