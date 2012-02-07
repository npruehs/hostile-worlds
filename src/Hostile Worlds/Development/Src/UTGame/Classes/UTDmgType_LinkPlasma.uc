/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_LinkPlasma extends UTDamageType
	abstract;

defaultproperties
{
	KillStatsName=KILLS_LINKGUN
	DeathStatsName=DEATHS_LINKGUN
	SuicideStatsName=SUICIDES_LINKGUN
	DamageWeaponClass=class'UTWeap_LinkGun'
	DamageWeaponFireMode=0

	DamageBodyMatColor=(R=50,G=50,B=50)
	DamageOverlayTime=0.5
	DeathOverlayTime=1.0
	VehicleDamageScaling=0.6
	NodeDamageScaling=0.8
	VehicleMomentumScaling=0.25
}
