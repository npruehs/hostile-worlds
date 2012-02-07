// ============================================================================
// HWProj_EMPMine
// A mine that lies on the ground and explodes if touched,
// blinding all targets in a radius and canceling their channeled abilities.
//
// Author:  Marcel Koehler
// Date:    2011/04/28
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWProj_EMPMine extends HWProjectile;

/** The audio component used for playing a sound when this mine touches the ground. */
var AudioComponent AudioComponentHitsGround;

/** The sound the be played when the grenade hits the ground. */
var SoundCue SoundGrenadeHitsGround;

/** The velocity vector of this grenade before it hit the ground. */
var Vector InitialVelocity;

/** The time hit enemies are blinded. */
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

	Direction = TargetLocation - Location;
	SetRotation(rotator(Direction));
	Velocity = Speed * Normal(Direction);

	ImpactLocation = TargetLocation;

	BlindDuration = NewBlindDuration;
}

simulated singular event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal);

auto state Unarmed
{
	ignores Touch;

	simulated function ProjectileImpact()
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

		GotoState('Armed');
	}
}

state Armed
{
	simulated singular event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		local HWBu_Blind Buff;
		local HWPawn CurrentPawn;

		if(HWPawn(Other).TeamIndex != HWPawn(Instigator).TeamIndex)
		{
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
	}
}

DefaultProperties
{
	bCausesFriendlyFire=false

	ProjFlightTemplate=ParticleSystem'FX_Abilities.P_Ability_EMPGrenade_Test'
	ProjExplosionTemplate=ParticleSystem'FX_Abilities.P_Ability_EMPGrenadeExplosion_Test'

	SoundFire=SoundCue'A_Sounds_Abilities.A_Ability_EMPGrenadeCue_Test'
	SoundGrenadeHitsGround=SoundCue'A_Sounds_Abilities.A_Ability_ConcussionGrenadeHitGroundCue_Test'
	SoundExplosion=SoundCue'A_Sounds_Abilities.A_Ability_EMPGrenadeExplosionCue_Test'

	Begin Object Name=CollisionCylinder
		CollisionRadius=100
		CollisionHeight=100
		AlwaysLoadOnServer=True
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	LifeSpan=1000.0
	CollisionType=COLLIDE_TouchAll
	bBlockedByInstigator=false

	Begin Object Class=AudioComponent name=NewAudioComponentHitsGround
	End Object
	AudioComponentHitsGround=NewAudioComponentHitsGround
	Components.Add(NewAudioComponentHitsGround)
}
