/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_ScorpionGlob_Red extends UTProj_ScorpionGlob_Base;

defaultproperties
{
	ProjFlightTemplate = ParticleSystem'VH_Scorpion.Effects.P_Scorpion_Bounce_Projectile_Red'
	ProjExplosionTemplate= ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Gun_Impact_Red'
	MyDamageType=class'UTDmgType_ScorpionGlobRed'

	Explosionsound=SoundCue'A_Weapon_BioRifle.Weapon.A_BioRifle_FireImpactExplode_Cue'
	ImpactSound=SoundCue'A_Weapon_BioRifle.Weapon.A_BioRifle_FireImpactFizzle_Cue'
}
