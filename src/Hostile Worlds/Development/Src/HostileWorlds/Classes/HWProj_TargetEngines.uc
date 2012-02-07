// ============================================================================
// HWProj_TargetEngines
// A projectile that snares its target, rendering it unable to move or charge.
//
// Author:  Nick Pruehs
// Date:    2011/03/14
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWProj_TargetEngines extends HWProjectile;

simulated function ProjectileImpact()
{
	local HWBu_TargetEngines Buff;

	if (WorldInfo.NetMode != NM_Client)
	{
		Buff = Spawn(class'HWBu_TargetEngines', Owner);
		Buff.ApplyBuffTo(Target);
	}

	super.Shutdown();
}

DefaultProperties
{
	ProjFlightTemplate=ParticleSystem'FX_Abilities.P_Ability_TargetEngines_Test'
	ProjExplosionTemplate=ParticleSystem'FX_Abilities.P_Ability_TargetEnginesImpact_Test'

	SoundFire=SoundCue'A_Sounds_Abilities.A_Ability_TargetEnginesCue_Test'
}
