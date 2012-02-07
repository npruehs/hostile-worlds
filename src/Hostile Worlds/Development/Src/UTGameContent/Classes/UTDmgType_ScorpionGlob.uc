/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_ScorpionGlob extends UTDamageType
	abstract;

defaultproperties
{
    VehicleDamageScaling=0.75
    NodeDamageScaling=0.75
	KillStatsName=KILLS_SCORPIONGLOB
	DeathStatsName=DEATHS_SCORPIONGLOB
	SuicideStatsName=SUICIDES_SCORPIONGLOB
	DamageWeaponClass=class'UTVWeap_ScorpionTurret'
	DamageWeaponFireMode=0
	bCausesBlood=false
	VehicleMomentumScaling=1.0
	DamageBodyMatColor=(R=0,G=30,B=50)
}

