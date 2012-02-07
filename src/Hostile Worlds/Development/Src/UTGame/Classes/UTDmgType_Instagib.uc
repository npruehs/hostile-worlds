/**
 * UTDmgType_Instagib
 *
 *
 *
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_Instagib extends UTDamageType
	abstract;

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	Super.SpawnHitEffect(P,Damage,Momentum,BoneName,HitLocation);
	if(UTPawn(P) != none)
	{
		UTPawn(P).SoundGroupClass.Static.PlayInstagibSound(P);
	}
}

defaultproperties
{
	KillStatsName=KILLS_INSTAGIB
	DeathStatsName=DEATHS_INSTAGIB
	SuicideStatsName=SUICIDES_INSTAGIB
	DamageWeaponClass=class'UTWeap_ShockRifleBase'
	DamageWeaponFireMode=2
    bAlwaysGibs=true
	GibPerterbation=0.5
}
