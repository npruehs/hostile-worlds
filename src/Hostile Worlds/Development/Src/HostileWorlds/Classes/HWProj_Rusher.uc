// ============================================================================
// HWProj_Rusher
// The projectile of the weapon of a rusher.
//
// Author:  Nick Pruehs
// Date:    2010/10/20
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWProj_Rusher extends HWProjectile;

DefaultProperties
{
	ProjFlightTemplate=ParticleSystem'WP_Humans.Effects.P_WP_Rusher_Projectile_Test'
	ProjExplosionTemplate=ParticleSystem'WP_Humans.Effects.P_WP_Rusher_Impact_Test'
	SoundFire=SoundCue'A_Sounds_Weapons.A_Weapon_Rusher_FireCue_Test'
}
