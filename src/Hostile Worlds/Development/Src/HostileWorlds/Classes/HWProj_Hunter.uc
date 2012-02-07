// ============================================================================
// HWProj_Hunter
// The projectile of the weapon of a hunter.
//
// Author:  Nick Pruehs, Marcel Koehler
// Date:    2011/04/07
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWProj_Hunter extends HWBeamProjectile;

DefaultProperties
{
	ProjBeamTemplate=ParticleSystem'WP_Humans.Effects.P_WP_Hunter_Beam_Test'
	ProjExplosionTemplate=ParticleSystem'WP_Humans.Effects.P_WP_Hunter_Impact_Test'
	SoundFire=SoundCue'A_Sounds_Weapons.A_Weapon_Hunter_FireCue_Test'
}
