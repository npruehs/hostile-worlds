// ============================================================================
// HWProj_ConcussionGrenade
// A grenade that lies on the ground for a limited time before it explodes,
// and deals area of effect damage then.
//
// Author:  Nick Pruehs
// Date:    2011/02/17
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWProj_ConcussionGrenade extends HWProjectile;

/** The time this grenade lies on the ground before it explodes, in seconds. */
var float TimeBeforeGrenadeDetonates;

/** The audio component used for playing a sound when this grenade touches the ground. */
var AudioComponent AudioComponentHitsGround;

/** The sound the be played when the grenade hits the ground. */
var SoundCue SoundGrenadeHitsGround;

/** The velocity vector of this grenade before it hit the ground. */
var Vector InitialVelocity;


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
 *      the location on the ground this greande should land
 * @param TimeBeforeDetonation
 *      the time this grenade lies on the ground before it explodes, in seconds
 */
function Initialize(HWPawn FiringPawn, float GrenadeSpeed, float GrenadeDamage, float SplashDamageRadius, Vector TargetLocation, float TimeBeforeDetonation)
{
	local Vector Direction;
	
	OwningPlayer = FiringPawn.OwningPlayer;

	Instigator = FiringPawn;
	InstigatorController = FiringPawn.Controller;

	Speed = GrenadeSpeed;
	MaxSpeed = GrenadeSpeed;

	Damage = GrenadeDamage;
	DamageRadius = SplashDamageRadius;

	Direction = TargetLocation - Location;
	SetRotation(rotator(Direction));
	Velocity = Speed * Normal(Direction);

	TimeBeforeGrenadeDetonates = TimeBeforeDetonation;

	ImpactLocation = TargetLocation;
}

simulated function ProjectileImpact()
{
	// don't deal damage immediately
	HitGround();
}

/** Stops this grenade and starts its detonation timer. */
simulated function HitGround()
{
	// zero movement variables
	InitialVelocity = Velocity;

	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);

	// play sound
	if (SoundGrenadeHitsGround != none && !AudioComponentHitsGround.IsPlaying())
	{
		AudioComponentHitsGround.Location = Location;
		AudioComponentHitsGround.SoundCue = SoundGrenadeHitsGround;
		AudioComponentHitsGround.Play();
	}

	// start detonation timer
	if (WorldInfo.NetMode != NM_Client)
	{
		SetTimer(TimeBeforeGrenadeDetonates, false, 'DealDamage');
	}
	else
	{
		SetTimer(TimeBeforeGrenadeDetonates, false, 'Shutdown');
	}
}

function DealDamage()
{
	// restore velocity vector prior to normal vector computation
	Velocity = InitialVelocity;

	super.DealDamage();
}

simulated function Shutdown()
{
	// restore velocity vector prior to normal vector computation
	Velocity = InitialVelocity;

	super.Shutdown();
}

replication
{
	// Replicate if server
	if(Role == ROLE_Authority && (bNetInitial || bNetDirty))
		TimeBeforeGrenadeDetonates;
}

DefaultProperties
{
	bCausesFriendlyFire=true

	SoundFire=SoundCue'A_Sounds_Abilities.A_Ability_ConcussionGrenadeCue_Test'
	SoundGrenadeHitsGround=SoundCue'A_Sounds_Abilities.A_Ability_ConcussionGrenadeHitGroundCue_Test'
	SoundExplosion=SoundCue'A_Sounds_Abilities.A_Ability_ConcussionGrenadeExplosionCue_Test'

	ProjFlightTemplate=ParticleSystem'FX_Abilities.P_Ability_ConcussionGrenade_Test'
	ProjExplosionTemplate=ParticleSystem'P_general.Particles.P_GrenadeExplosion'

	MyDamageType=class'HWDT_Explosion'

	Begin Object Class=AudioComponent name=NewAudioComponentHitsGround
	End Object
	AudioComponentHitsGround=NewAudioComponentHitsGround
	Components.Add(NewAudioComponentHitsGround)
}
