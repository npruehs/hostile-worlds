// ============================================================================
// HWProj_Engineer
// The projectile of the weapon of an Engineer.
//
// Author:  Nick Pruehs
// Date:    2011/03/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWProj_Engineer extends HWProjectile;

DefaultProperties
{
	ProjFlightTemplate=ParticleSystem'WP_Humans.Effects.P_WP_Engineer_Projectile_Test'
	ProjExplosionTemplate=ParticleSystem'WP_Humans.Effects.P_WP_Engineer_Impact_Test'
	SoundFire=SoundCue'A_Sounds_Weapons.A_Weapon_Engineer_FireCue_Test'
	SoundExplosion=SoundCue'A_Sounds_Weapons.A_Weapon_Engineer_ImpactCue_Test'
}
