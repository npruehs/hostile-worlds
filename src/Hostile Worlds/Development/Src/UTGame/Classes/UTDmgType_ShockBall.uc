/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_ShockBall extends UTDamageType
	abstract;



defaultproperties
{
	KillStatsName=KILLS_SHOCKRIFLE
	DeathStatsName=DEATHS_SHOCKRIFLE
	SuicideStatsName=SUICIDES_SHOCKRIFLE
	DamageWeaponClass=class'UTWeap_ShockRifleBase'
	DamageWeaponFireMode=1

	DamageBodyMatColor=(R=40,B=50)
	DamageOverlayTime=0.3
	DeathOverlayTime=0.6
	VehicleDamageScaling=0.8
	VehicleMomentumScaling=2.75
	KDamageImpulse=1500.0
}
