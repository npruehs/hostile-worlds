// ============================================================================
// HWProj_Artillery
// The projectile of the artillery.
//
// Author:  Nick Pruehs
// Date:    2011/07/28
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWProj_Artillery extends HWProjectile;

DefaultProperties
{
	ProjFlightTemplate=ParticleSystem'WP_Humans.Effects.P_WP_Artillery_Projectile_Test'
	ProjExplosionTemplate=ParticleSystem'WP_Humans.Effects.P_WP_Artillery_Impact_Test'
	SoundFire=SoundCue'A_Sounds_Weapons.A_Weapon_Artillery_FireCue_Test'
	SoundExplosion=SoundCue'A_Sounds_Weapons.A_Weapon_Artillery_ImpactCue_Test'
}
