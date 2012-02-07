// ============================================================================
// HWProj_EMPGrenade
// A grenade that blinds all targets in a radius and canceling their channeled abilities.
//
// Author:  Marcel Koehler
// Date:    2011/04/08
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWProj_EMPGrenade extends HWProjectile;

/** The velocity vector of this grenade before it hit the ground. */
var Vector InitialVelocity;

/** How long any hit enemies shall be blinded. */
var float BlindDuration;

/**
 * Initializes this grenade with the passed parameters.
 * 
 * @param FiringPawn
 *      the unit that has fired this grenade
 * @param GrenadeSpeed
 *      the speed of this grenade, in UU/sec
 * @param GrenadeDamage
 *      the damage dealt when this grenade explodes
 * @param SplashDamageRadius
 *      the radius of the area of effect this grenade deals damage in
 * @param TargetLocation
 *      the location on the ground this grenade should land
 * @param NewBlindDuration
 *      the time hit units are blinded long any hit enemies shall be blinded
 */
function Initialize(HWPawn FiringPawn, float GrenadeSpeed, float GrenadeDamage, float SplashDamageRadius, Vector TargetLocation, float NewBlindDuration)
{
	local Vector Direction;
	
	OwningPlayer = FiringPawn.OwningPlayer;

	Instigator = FiringPawn;
	InstigatorController = FiringPawn.Controller;

	Speed = GrenadeSpeed;
	MaxSpeed = GrenadeSpeed;

	Damage = GrenadeDamage;
	DamageRadius = SplashDamageRadius;

	Direction = TargetLocation - FiringPawn.GetEffectLocation();
	SetRotation(rotator(Direction));
	Velocity = Speed * Normal(Direction);

	ImpactLocation = TargetLocation;

	BlindDuration = NewBlindDuration;
}

simulated function ProjectileImpact()
{
	local HWBu_Blind Buff;
	local HWPawn CurrentPawn;

	super.ProjectileImpact();

	// find all enemies in the radius around the target location
	foreach OverlappingActors(class'HWPawn', CurrentPawn, DamageRadius, ImpactLocation)
	{
		if(CurrentPawn.TeamIndex != HWPawn(Instigator).TeamIndex)
		{
			// blind
			Buff = Spawn(class'HWBu_Blind', self);
			Buff.Duration = BlindDuration;
			Buff.ApplyBuffTo(CurrentPawn);

			// cancel all channeled abilities
			HWAIController(CurrentPawn.Controller).InterruptChanneling();
		}
	}
}

DefaultProperties
{
	bCausesFriendlyFire=false

	ProjFlightTemplate=ParticleSystem'FX_Abilities.P_Ability_EMPGrenade_Test'
	ProjExplosionTemplate=ParticleSystem'FX_Abilities.P_Ability_EMPGrenadeExplosion_Test'

	SoundFire=SoundCue'A_Sounds_Abilities.A_Ability_EMPGrenadeCue_Test'
	SoundExplosion=SoundCue'A_Sounds_Abilities.A_Ability_EMPGrenadeExplosionCue_Test'
}
