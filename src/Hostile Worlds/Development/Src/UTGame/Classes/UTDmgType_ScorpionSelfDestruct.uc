/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_ScorpionSelfDestruct extends UTDmgType_Burning;

/** Amount of damage to given when hitting a vehicle **/
var int DamageGivenForSelfDestruct;

static function int IncrementKills(UTPlayerReplicationInfo KillerPRI)
{
	if ( UTPlayerController(KillerPRI.Owner) != None )
	{
		UTPlayerController(KillerPRI.Owner).BullseyeMessage();
	}
	return super.IncrementKills(KillerPRI);
}

defaultproperties
{
	KillStatsName=KILLS_SCORPIONSELFDESTRUCT
	DeathStatsName=DEATHS_SCORPIONSELFDESTRUCT
	SuicideStatsName=SUICIDES_SCORPIONSELFDESTRUCT
	KDamageImpulse=12000
	bDontHurtInstigator=true
	bSelfDestructDamage=true

	DamageGivenForSelfDestruct=610
}
