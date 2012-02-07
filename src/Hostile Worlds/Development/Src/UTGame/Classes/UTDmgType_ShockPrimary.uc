/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_ShockPrimary extends UTDamageType
	abstract;

defaultproperties
{
	KillStatsName=KILLS_SHOCKRIFLE
	DeathStatsName=DEATHS_SHOCKRIFLE
	SuicideStatsName=SUICIDES_SHOCKRIFLE
	DamageWeaponClass=class'UTWeap_ShockRifleBase'
	DamageWeaponFireMode=0

	DamageBodyMatColor=(R=40,B=50)
	DamageOverlayTime=0.3
	DeathOverlayTime=0.6
	GibPerterbation=0.75
	VehicleMomentumScaling=2.0
	VehicleDamageScaling=0.7
	NodeDamageScaling=0.8
	KDamageImpulse=1500.0

	DamageCameraAnim=CameraAnim'Camera_FX.ShockRifle.C_WP_ShockRifle_Hit_Shake'
	CustomTauntIndex=4
}
