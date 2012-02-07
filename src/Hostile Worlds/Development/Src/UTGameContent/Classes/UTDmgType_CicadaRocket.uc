/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_CicadaRocket extends UTDmgType_Burning
	abstract;

static function ScoreKill(UTPlayerReplicationInfo KillerPRI, UTPlayerReplicationInfo KilledPRI, Pawn KilledPawn)
{
	super.ScoreKill(KillerPRI, KilledPRI, KilledPawn);
	if (KilledPRI != None && KillerPRI != KilledPRI && Vehicle(KilledPawn) != None && Vehicle(KilledPawn).bCanFly)
	{
		KillerPRI.IncrementEventStat('EVENT_TOPGUN');
		if (UTPlayerController(KillerPRI.Owner) != None)
			UTPlayerController(KillerPRI.Owner).ReceiveLocalizedMessage(class'UTVehicleKillMessage', 6);
	}
}

defaultproperties
{
	KillStatsName=KILLS_CICADAROCKET
	DeathStatsName=DEATHS_CICADAROCKET
	SuicideStatsName=SUICIDES_CICADAROCKET
	DamageWeaponClass=class'UTVWeap_CicadaMissileLauncher'
	VehicleMomentumScaling=2.5
	NodeDamageScaling=0.8
}
