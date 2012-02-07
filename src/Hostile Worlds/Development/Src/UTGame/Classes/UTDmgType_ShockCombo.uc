/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_ShockCombo extends UTDamageType
	abstract;

defaultproperties
{
	RewardCount=15
	RewardEvent=REWARD_COMBOKING
	RewardAnnouncementSwitch=0
	KillStatsName=KILLS_SHOCKCOMBO
	DeathStatsName=DEATHS_SHOCKCOMBO
	SuicideStatsName=SUICIDES_SHOCKCOMBO
	DamageWeaponClass=class'UTWeap_ShockRifleBase'
	DamageWeaponFireMode=2

	DamageBodyMatColor=(R=40,B=50)
	DamageOverlayTime=0.3
	DeathOverlayTime=0.9
	bThrowRagdoll=true

	KDamageImpulse=6500
	VehicleDamageScaling=0.8
	VehicleMomentumScaling=2.25

	bNeverGibs=true //@note: physics vortex will force gib if it sucks pawn in, ignoring this flag
	bHeadGibCamera=false

	DamageCameraAnim=CameraAnim'Camera_FX.ShockRifle.C_WP_ShockRifle_Combo_Shake'
}
