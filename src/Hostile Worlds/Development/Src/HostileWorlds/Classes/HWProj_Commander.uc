// ============================================================================
// HWProj_Commander
// The projectile of the weapon of a commander.
//
// Author:  Nick Pruehs
// Date:    2010/10/15
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWProj_Commander extends HWProjectile;

DefaultProperties
{
	ProjFlightTemplate=ParticleSystem'WP_Humans.Effects.P_WP_Commander_Projectile'
	ProjExplosionTemplate=ParticleSystem'WP_Humans.Effects.P_WP_Commander_Impact'
	SoundFire=SoundCue'A_Sounds_Weapons.A_Weapon_Commander_FireCue_Test'
	SoundExplosion=SoundCue'A_Sounds_Weapons.A_Weapon_Commander_ImpactCue_Test'
}
