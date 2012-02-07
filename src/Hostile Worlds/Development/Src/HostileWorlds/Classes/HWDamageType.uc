// ============================================================================
// HWDamageType
// Extends DamageType to provide extra gib functionality copied from UTDamageType.
// and sounds.
//
// Author:  Marcel Koehler
// Date:    2010/06/05
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================

class HWDamageType extends DamageType;

/** Somehow controls the random rotation values of spawned gibs, see HWPawn.SpawnGib (values must be between 0.0 and 1.0). */
var	float GibPerterbation;

/** Health threshold at which this damagetype gibs. */
var	int	GibThreshold;

/** Minimum damage in one tick to cause gibbing when health is below gib threshold. */ 
var	int	MinAccumulateDamageThreshold;

/** Minimum damage in one tick to always cause gibbing. */ 
var	int	AlwaysGibDamageThreshold;

/** Particle system trail to attach to gibs caused by this damage type. */
var ParticleSystem GibTrail;


/**
* @param DeadPawn is pawn killed by this damagetype
* @return whether or not we should gib due to damage
*/
static function bool ShouldGib(HWPawn DeadPawn)
{
	return (!Default.bNeverGibs && 
			(Default.bAlwaysGibs 
			|| (DeadPawn.AccumulateDamage > Default.AlwaysGibDamageThreshold) 
			|| ((DeadPawn.Health < Default.GibThreshold) && (DeadPawn.AccumulateDamage > Default.MinAccumulateDamageThreshold))) );
}

/** Allows DamageType to spawn additional effects on gibs (such as flame trails). */
static function SpawnGibEffects(UTGib Gib)
{
	local ParticleSystemComponent Effect;

	if (default.GibTrail != None)
	{
		// we can't use the ParticleSystemComponentPool here as the trails are long lasting/infi so they will not call OnParticleSystemFinished
		Effect = new(Gib) class'UTParticleSystemComponent';
		Effect.SetTemplate(Default.GibTrail);
		Gib.AttachComponent(Effect);
	}
}


DefaultProperties
{
	GibPerterbation=0.06
	GibThreshold=1
	MinAccumulateDamageThreshold=100
	AlwaysGibDamageThreshold=1000
	GibTrail=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1'
}
