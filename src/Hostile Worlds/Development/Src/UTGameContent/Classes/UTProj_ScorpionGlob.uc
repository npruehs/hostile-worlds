/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_ScorpionGlob extends UTProj_ScorpionGlob_Base;

defaultproperties
{
	MyDamageType=class'UTDmgType_ScorpionGlob'

	ProjFlightTemplate=ParticleSystem'VH_Scorpion.Effects.P_Scorpion_Bounce_Projectile'
	ProjExplosionTemplate=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Gun_Impact'

	Explosionsound=SoundCue'A_Weapon_BioRifle.Weapon.A_BioRifle_FireImpactExplode_Cue'
	ImpactSound=SoundCue'A_Weapon_BioRifle.Weapon.A_BioRifle_FireImpactFizzle_Cue'
}
