// ============================================================================
// HWProj_AimedShot
// A projectile that hits the target with high damage and knocks it back.
//
// Author:  Marcel Koehler
// Date:    2011/04/08
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWProj_AimedShot extends HWBeamProjectile;

DefaultProperties
{
	ProjBeamTemplate=ParticleSystem'FX_Abilities.P_Ability_AimedShot_Test'
	ProjExplosionTemplate=ParticleSystem'FX_Abilities.P_Ability_AimedShotImpact_Test'
	SoundFire=SoundCue'A_Sounds_Abilities.A_Ability_AimedShotCue_Test'
}
