// ============================================================================
// HWProjectile
// An abstract standard attack projectile of Hostile Worlds. Will fly to the
// position of a specified target and explode there, dealing damage to it and
// other nearby enemies, showing explosion effects and playing sounds.
//
// Author:  Nick Pruehs
// Date:    2010/10/15
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWProjectile extends Projectile
	abstract;

/** The player who owns the unit that has fired this projectile. */
var HWPlayerController OwningPlayer;

/** The target that will take damage by this projectile. */
var HWPawn Target;

/** Remember if we're shutting down already, so we don't want to spawn new effects. */
var bool bShuttingDown;

/** The particle system that is shown on the flying projectile. */
var ParticleSystemComponent	ProjEffects;

/** The template of the particle system to show on the flying projectile. */
var ParticleSystem ProjFlightTemplate;

/** The template of the particle system to show at this projectile's explosion. */
var ParticleSystem ProjExplosionTemplate;

/** The audio component used for playing the fire sound of this projectile. */
var AudioComponent AudioComponentFire;

/** The audio component used for playing the explosion sound of this projectile. */
var AudioComponent AudioComponentExplosion;

/** The sound that is played when this projectile is fired. */
var SoundCue SoundFire;

/** The sound that is played when this projectile explodes. */
var SoundCue SoundExplosion;

/** The maximum distance the explosion effect of this projectile can be seen from. */
var float MaxEffectDistance;

/** The class of the explosion lights of this projectile. */
var class<UDKExplosionLight> ExplosionLightClass;

/** The maximum distance from a player's viewport explosion lights will be created in. */
var float MaxExplosionLightDistance;

/** Remember if we've already shown the explosion, so we don't do it twice. */
var bool bExplosionShown;

/** Whether this projectile deals damage to units belonging to the same team as the one who fired this projectile, or not. */
var bool bCausesFriendlyFire;

/** The location this projectile is to impact. */
var Vector ImpactLocation;

/** Whether this projectile already has dealt damaage, or not. */
var bool bProcessedImpact;

/** Whether this projectile knocks it target(s) back on exploding, or not. */
var bool bKnocksTargetBack;

/** The momentum to apply to the target unit upon knocking it back. */
var float KnockbackMomentum;

/** The distance from the target location this projectile scores a hit. */
var int ImpactOffset;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SpawnFlightEffects();

	if (!AudioComponentFire.IsPlaying())
	{
		AudioComponentFire.Location = Location;
		AudioComponentFire.SoundCue = SoundFire;
		AudioComponentFire.Play();
	}
}

/**
 * Initialize this projectile's properties from the configuration file.
 * 
 * Server only: Clients don't need to know about the target or the damage;
 * velocity is replicated anyway.
 *
 * @param FiringPawn
 *      the pawn that is firing this projectile
 * @param TargetPawn
 *      the pawn this projectile is intended to hit and hurt
 */
function InitProjectile(HWPawn FiringPawn, HWPawn TargetPawn)
{
	local Vector Direction;

	OwningPlayer = FiringPawn.OwningPlayer;
	Target = TargetPawn;

	Instigator = FiringPawn;
	InstigatorController = FiringPawn.Controller;

	Speed = FiringPawn.ProjectileSpeed;
	MaxSpeed = FiringPawn.ProjectileSpeed;

	Damage = FiringPawn.AttackDamage;
	DamageRadius = FiringPawn.SplashDamageRadius;

	// take high ground into account
	if (TargetPawn.GetHeightLevel() > FiringPawn.GetHeightLevel())
	{
		Damage /= 2.0f;
	}

	bKnocksTargetBack = FiringPawn.bAttacksKnockTargetBack;
	KnockbackMomentum = FiringPawn.KnockbackMomentum;

	Direction = TargetPawn.Location - FiringPawn.GetEffectLocation();
	SetRotation(rotator(Direction));
	Velocity = Speed * Normal(Direction);

	ImpactLocation = TargetPawn.Location;
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (Abs(ImpactLocation.X - Location.X) + Abs(ImpactLocation.Y - Location.Y) < ImpactOffset)
	{
		if (!bProcessedImpact)
		{
			ProjectileImpact();
			bProcessedImpact = true;
		}
	}
}

/** 
 * Processes the impact of this projectle. Defaults to dealing damage on the
 * server and just showing explosion impacts on the client. Subclasses may
 * overwrite this method to specify other behavior instead.
 */
simulated function ProjectileImpact()
{
	if (WorldInfo.NetMode != NM_Client)
	{
		DealDamage();
	}
	else
	{
		Shutdown();
	}
}

/** 
 *  Makes this projectile explode and deal damage at once.
 *  
 *  Server only: Health is replicated to all clients.
 */
function DealDamage()
{
	local vector HitNormal;

	// taken from UTProjectile::Shutdown()
	HitNormal = Normal(Velocity * -1);

	// let's just assume we really hit out target ;)
	ImpactedActor = Target;

	Explode(Location,  HitNormal);
}

// override Projectile's Touch in order to avoid collision with any pawns
simulated singular event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal);

/**
 * Makes all targets within the splash damage radius take damage, spawns all
 * explosion effects and shuts down this projectile.
 * 
 * Server only: Health is replicated to all clients. Explosion effects are
 * spawned on the appropriate clients as this actor gets destroyed.
 * 
 * "simulated" is set only to avoid compile warnings. This function is never
 * called on any client actually.
 */
simulated function Explode(vector HitLocation, vector HitNormal)
{
	// check if there is any damage to be dealt
	if (Damage > 0 && !bShuttingDown)
	{
		if (DamageRadius == 0) 
		{
			DealDamageTo(Target);
		}
		else
		{
			DealAOEDamage();
		}
	}

	SpawnExplosionEffects(HitLocation, HitNormal);

	ShutDown();
}

/**
 * Deals full damage to all units within DamageRadius around this projectile.
 */
function DealAOEDamage()
{
	local HWPawn Victim;

	foreach CollidingActors(class'HWPawn', Victim, DamageRadius)
	{
		if ((Victim.TeamIndex != HWPawn(Instigator).TeamIndex) || bCausesFriendlyFire)
		{
			DealDamageTo(Victim);
		}
	}
}

/**
 * Deals basic damage to the specified victim, knocking it back if enabled.
 * 
 * @param Victim
 *      the unit to take damage
 */
function DealDamageTo(HWPawn Victim)
{
	Victim.TakeDamage(Damage, OwningPlayer, Victim.Location, vect(0,0,0), MyDamageType,, Instigator);
	
	if (bKnocksTargetBack)
	{
		Victim.KnockedBackBy(self, KnockbackMomentum, 0.f);
	}
}

/**
 * Spawns any effects needed for the flight of this projectile.
 * 
 * (Taken from UTProjectile::SpawnFlightEffects().)
 */
simulated function SpawnFlightEffects()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && ProjFlightTemplate != None)
	{
		ProjEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjFlightTemplate);
		ProjEffects.SetAbsolute(false, false, false);
		ProjEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		ProjEffects.OnSystemFinished = MyOnParticleSystemFinished;
		ProjEffects.bUpdateComponentInTick = true;
		AttachComponent(ProjEffects);
	}
}

/**
 * Stub function that allows specific projectiles to initialize any particle
 * system parameters they require for their explosions.
 */
simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion);

/**
 * Checks if the explosion can be seen or heard by anyone, and if yes,
 * spawns the appropriate particle system and lights, and plays the
 * explosion sound.
 */
simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local vector LightLoc;
	local vector LightHitLocation;
	local vector LightHitNormal;
	local ParticleSystemComponent ProjExplosion;

	// nothing to see or hear on dedicated servers ;)
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (ProjExplosionTemplate != None && EffectIsRelevant(Location, false, MaxEffectDistance))
		{
			// spawn the particle emitter for the explosion effect
			ProjExplosion = WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, HitLocation, rotator(HitNormal), ImpactedActor);

			// allows subclass to initialize any required parameters
			SetExplosionEffectParameters(ProjExplosion);

			if (ShouldSpawnExplosionLight(HitLocation, HitNormal))
			{
				// taken from UTProjectile::SpawnExplosionEffects
				if (Trace(LightHitLocation, LightHitNormal, HitLocation + (0.25 * ExplosionLightClass.default.TimeShift[0].Radius * HitNormal), HitLocation, false) == None)
				{
					LightLoc = HitLocation + (0.25 * ExplosionLightClass.default.TimeShift[0].Radius * (vect(1,0,0) >> ProjExplosion.Rotation));
				}
				else
				{
					LightLoc = HitLocation + (0.5 * VSize(HitLocation - LightHitLocation) * (vect(1,0,0) >> ProjExplosion.Rotation));
				}

				UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight(ExplosionLightClass, LightLoc, ImpactedActor);
			}
		}

		// play explosion sound
		if (SoundExplosion != none && !AudioComponentExplosion.IsPlaying())
		{
			AudioComponentExplosion.Location = Location;
			AudioComponentExplosion.SoundCue = SoundExplosion;
			AudioComponentExplosion.Play();
		}

		// don't show explosion again
		bExplosionShown = true;
	}
}

/** 
 *  Retruns true, if there has been a light class specified at all, the
 *  game is not dropping the detail level, and any player is able to see
 *  the explosion, and false otherwise.
*/
simulated function bool ShouldSpawnExplosionLight(vector HitLocation, vector HitNormal)
{
	local PlayerController LocalPlayer;
	local float Dist;

	if (ExplosionLightClass == None)
	{
		return false;
	}

	if (WorldInfo.bDropDetail)
	{
		return false;
	}

	// if any player can see the explosion, we should spawn a light
	foreach LocalPlayerControllers(class'PlayerController', LocalPlayer)
	{
		Dist = VSize(LocalPlayer.ViewTarget.Location - Location);

		// taken from UTProjectile::ShouldSpawnExplosionLight
		if ((LocalPlayer.Pawn == Instigator) ||
			(Dist < ExplosionLightClass.Default.Radius) ||
			((Dist < MaxExplosionLightDistance) && ((vector(LocalPlayer.Rotation) dot (Location - LocalPlayer.ViewTarget.Location)) > 0)))
		{
			return true;
		}
	}

	return false;
}

/**
 * Shuts down this projectile, disabling physics, particle effects and
 * replication, turning it invisible and destroying it.
 */
simulated function Shutdown()
{
	local vector HitNormal;

	// hey, we're shutting down now - don't spawn any new effects!
	bShuttingDown = true;

	SetPhysics(PHYS_None);

	if (ProjEffects != None)
	{
		ProjEffects.DeactivateSystem();
	}

	// if the explosion effect has not been shown yet, do it now
	if (WorldInfo.NetMode != NM_DedicatedServer && !bExplosionShown)
	{
		// taken from UTProjectile::Shutdown()
		HitNormal = Normal(Velocity * -1);

		SpawnExplosionEffects(Location, HitNormal);
	}

	HideProjectile();
	SetCollision(false, false);

	Destroy();
}

event TornOff()
{
	ShutDown();

	Super.TornOff();
}

/** Hides all mesh components of this projectile and stops it. */
simulated function HideProjectile()
{
	local MeshComponent ComponentIt;

	foreach ComponentList(class'MeshComponent', ComponentIt)
	{
		ComponentIt.SetHidden(true);
	}

	Velocity = vect(0, 0, 0);
}

simulated function Destroyed()
{
	/*
	 * taken from UTProjectile::Destroyed() - they'll have their reasons why we
	 * need to do this third check ;)
	 */

	// final failsafe check for explosion effect
	if (WorldInfo.NetMode != NM_DedicatedServer && !bExplosionShown)
	{
		SpawnExplosionEffects(Location, vector(Rotation) * -1);
	}

	if (ProjEffects != None)
	{
		DetachComponent(ProjEffects);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(ProjEffects);
		ProjEffects = None;
	}

	super.Destroyed();
}

/**
 * Called as soon as a flight particle effect has finished. Detaches the
 * particle effect component and returns it to the pool.
 */
simulated function MyOnParticleSystemFinished(ParticleSystemComponent PSC)
{
	if (PSC == ProjEffects)
	{
		// clear component and return to pool
		DetachComponent(ProjEffects);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(ProjEffects);
		ProjEffects = None;
	}
}


replication
{
	// Replicate if server
	if(Role == ROLE_Authority && (bNetInitial || bNetDirty))
		ImpactLocation;
}

DefaultProperties
{
	bCollideWorld=false
	MaxEffectDistance=7000.0
	ImpactOffset = 100;

	RemoteRole = ROLE_SimulatedProxy;

	// all clients have to be able to see projectiles
	bAlwaysRelevant=true

	Begin Object Class=AudioComponent name=NewAudioComponentFire
	End Object
	AudioComponentFire=NewAudioComponentFire
	Components.Add(NewAudioComponentFire)

	Begin Object Class=AudioComponent name=NewAudioComponentExplosion
	End Object
	AudioComponentExplosion=NewAudioComponentExplosion
	Components.Add(NewAudioComponentExplosion)
}