// ============================================================================
// HWBeamProjectile
// An abstract standard beam projectile of Hostile Worlds which extends HWProjectile. 
// A beam particle system is shown on impact from the origin to the hit location.
//
// Author:  Marcel Koehler
// Date:    2011/04/07
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBeamProjectile extends HWProjectile
	abstract;

/** The template of the beam particle system to show on impact. */
var ParticleSystem ProjBeamTemplate;


/**
 * Beam projectiles don't spawn flight effects.
 */
simulated function SpawnFlightEffects()
{
	// do nothing
}

/**
 * Checks if the explosion can be seen or heard by anyone, and if yes,
 * spawns the appropriate particle system and lights, and plays the
 * explosion sound.
 */
simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	// Setting the LastRenderTime to now is necessary in order for the EffectIsRelevant()
	// check in the super.SpawnExplosionEffects() call to return true and thus render the explosion effect
	// (otherwise a beam projectile wouldn't be considered relevant, because it's LastRendertime is too long ago
	// since it isn't actually rendered).
	LastRenderTime = WorldInfo.TimeSeconds;
	super.SpawnExplosionEffects(HitLocation, HitNormal);
}

simulated function ProjectileImpact()
{
	local ParticleSystemComponent E;

	E = WorldInfo.MyEmitterPool.SpawnEmitter(ProjBeamTemplate, HWSquadMember(Instigator).GetEffectLocation());
	E.SetVectorParameter('ShockBeamEnd', ImpactLocation);

	super.ProjectileImpact();
}

DefaultProperties
{	
}