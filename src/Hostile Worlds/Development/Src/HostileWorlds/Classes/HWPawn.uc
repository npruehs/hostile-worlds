// ============================================================================
// HWPawn
// An abstract pawn of Hostile Worlds. Contains combat stastistics, animations
// and sounds.
//
// Author:  Nick Pruehs, Marcel Koehler
// Date:    2010/08/31
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================

class HWPawn extends HWSelectable
	config(HostileWorldsUnitData)
	abstract;

/** The range in which attacks are considered melee attacks. */
const MELEE_RANGE = 100;

/** The range in which nearby allied units respond to calls for help, in UU. */
const CALL_FOR_HELP_RADIUS = 500.f;

/** The maximum amount of structure points of this pawn. */
var config int StructureMax;

/** The value the damage of all attacks is reduces by before being applied. */
var config int Armor;

/** The ground movement speed of this unit, in UU/s. */
var config int MovementSpeed;

/** The damage of the attacks of this pawn. */
var config float AttackDamage;

/** The radius this pawn's projectiles do damage on impact in, in UU. */
var config float SplashDamageRadius;

/** The minimum time between two barrages of this pawn, in seconds. */
var config float Cooldown;

/** The range of the attacks of this pawn, in UU. */
var config float Range;

/** The speed of this pawn's projectiles, in UU/sec. */
var config float ProjectileSpeed;

/** The minimum number of projectiles per barrage fired by this pawn. */
var config int ProjectilesPerBarrageMin;

/** The maximum number of projectiles per barrage fired by this pawn. */
var config int ProjectilesPerBarrageMax;

/** The time between two projectiles belonging to the same barrage fired by this pawn, in seconds. */
var config float TimeBetweenBarrageProjectiles;

/** Whether the melee attacks and projectiles of this unit knock their target back, or not. */
var config bool bAttacksKnockTargetBack;

/** The chase radius of this pawn in each direction, in UU. */
var config int ChaseRadiusUU;

/** The momentum applied to this unit whenever it is knocked back. */
var config float KnockbackMomentum;

/** The player controlling this pawn. */
var repnotify HWPlayerController OwningPlayer;

/** The player replication info of the player who owns this pawn. */
var repnotify PlayerReplicationInfo OwningPlayerRI;

/** The class of this pawn's projectiles. */
var class<Projectile> ProjectileClass;

/** The number of projectiles that are still to be fired in the current barrage. */
var int CurrentBarrageProjectilesRemaining;

/** The target unit of the current projectile barrage. */
var HWPawn CurrentBarrageTarget;

/** Linked list of buffs applied to this pawn. */
var HWBuff Buffs;

/** Slot node used for playing full body animations. */
var AnimNodeSlot FullBodyAnimSlot;

/** The sound component used for playing channeling sounds. */
var AudioComponent ChannelingSoundComponent;

/** The channeling sound currently being played, for replication. */
var repnotify SoundCue ChannelingSoundLoop;

/** Flag to show if the pawn is attacking and shall start or stop any corresponding effects (e.g. attack animation). */
var repnotify bool bIsAttacking;

/** Whether the standard attack of this unit is cooling down, or ready. */
var bool bAttackOnCooldown;

/** The pawn's light environment. */
var DynamicLightEnvironmentComponent LightEnvironment;

/** The decal that is displayed as long as this pawn is selected. */
var HWDe_SelectedCircle DecalSelected;

/** The decal that is displayed when player click to attack this pawn. */
var HWDe_AttackedCircle DecalAttacked;

/** Whether this unit is currently immune to knockback effects, or not. */
var bool bImmuneToKnockbacks;

/** Whether this unit is unable to move, or not. */
var bool bSnared;

/** Whether this unit is unable to use abilities, or not. */
var bool bSilenced;

/** Whether this unit is unable to attack, or not. */
var bool bBlinded;

/** Whether this unit is cloaked or not. */
var repnotify bool bCloaked;

/** (bHiddenForTeam[x] == 1) if and only if this unit is hidden for team x according to the server visibility mask. */
var byte bHiddenForTeam[2];

/** The sound to be played whenever this unit received a move order. */
var SoundCue SoundOrderConfirmed;

/** The sound to be played when this unit engages an enemy. */
var SoundCue SoundBattleCry;

/** The audio component used for playing the dying sound. */
var AudioComponent AudioComponentDied;

/** The sound to be played when this unit dies. */
var SoundCue SoundDied;

/** The name of the death animation of this unit. */
var name AnimNameDeath;

/** The duration of the death animation of this unit. */
var float AnimDurationDeath;

/** The name of the melee attack animation of this unit. */
var name AnimNameMeleeAttack;

/** The material to be shown if the pawn is cloaked. */
var MaterialInterface CloakMaterial;

/** 
 *  The overlay mesh that is attached to this squad member whenever it cloaks.
 */
var SkeletalMeshComponent CloakOverlayMesh;

/** Array of GibInfo's. */
var array<GibInfo> Gibs;

/** Track damage accumulated during a tick - used for gibbing determination. */
var float AccumulateDamage;

/** Tick time for which damage is being accumulated - used for gibbing determination. */
var float AccumulationTime;

/** Whether or not we have been gibbed already. */
var bool bGibbed;

/** Wheter or not to gib if torn off. */
var bool bTearOffGibs;

/** Particle effect to play when gibbed. */
var ParticleSystem GibExplosionTemplate;

/** The audio component used for playing the scream gib sound. */
var AudioComponent AudioComponentGibScream;

/** The audio component used for playing the explosion gib sound. */
var AudioComponent AudioComponentGibExplosion;

/** Explosion sound to play when gibbed. */
var SoundCue SoundGibExplosion;

/** Scream sound to play when gibbed. */
var SoundCue SoundGibScream;

/** Whether to play special sounds when this unit is gibbed, or not. */
var bool bPlayGibSounds;


/** 
 *  A struct containing all necessary information to call AnimNodeSlot.PlayCustomAnimation().
 *  Use this struct to replicate animations to clients.
 *  */
struct AnimationInfo
{
	var name Name;
	var bool bStop;
	var float Rate;
	var float BlendInTime;
	var float BlendOutTime;
	var bool bLooping;
	var bool bOverride;
	var float StartTime;
};

/** The name of the currently played animation of this pawn. Replicated in order to trigger animations on clients. */ 
var repnotify AnimationInfo AnimInfo;

/** Whether this unit should focus its target while carrying out orders. */
var bool bShouldFocusTarget;


simulated event PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();

	// call SpawnDefaultController() since pawns spawned during gameplay don't do this in the base implementation
	SpawnDefaultController();

	// create a selection circle that can be kept under this pawn (not on dedicated servers)
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		DecalSelected = Spawn(class'HWDe_SelectedCircle', Owner,, Location, Rotation);
		DecalSelected.SetRadius(CylinderComponent.CollisionRadius * 1.5f);
	}

	// initialize structure and speed values
	HealthMax = StructureMax;
	Health = HealthMax;

	GroundSpeed = MovementSpeed;

	// make the pawn land on ground at the beginning
	Velocity.Z = -10;
	SetPhysics(PHYS_Falling);

	// initialize cloak overlay mesh that is shown every time the unit is cloaked
	if(Mesh != none)
	{
		CloakOverlayMesh.SetSkeletalMesh(Mesh.SkeletalMesh);
		CloakOverlayMesh.SetParentAnimComponent(Mesh);
		for (i = 0; i < CloakOverlayMesh.SkeletalMesh.Materials.Length; i++)
		{
			CloakOverlayMesh.SetMaterial(i, CloakMaterial);
		}
	}

	SetTimer(1.0f, true, 'TriggerEnemyAcquisition');
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
}

function Initialize(HWMapInfoActor TheMap, optional Actor A)
{
	local HWPlayerController Player;

	super.Initialize(TheMap, A);

	Player = HWPlayerController(A);

	if (Player != none)
	{
		OwningPlayer = Player;
		OwningPlayerRI = Player.PlayerReplicationInfo;
		TeamIndex = Player.PlayerReplicationInfo.Team.TeamIndex;

		Controller.bIsPlayer = true;

		OwningPlayer.ClientPlayVoiceUnit(self, self.SoundSelected);

		`Log(self$" has been spawned for player "$Player.PlayerReplicationInfo.PlayerName$".");
	}
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// accumulate damage taken in a single tick
	if ( AccumulationTime != WorldInfo.TimeSeconds )
	{
		AccumulateDamage = 0;
		AccumulationTime = WorldInfo.TimeSeconds;
	}

	AccumulateDamage += Damage;

	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	// retaliate if possible
	if (Controller != none && DamageCauser != none)
	{
		HWAIController(Controller).NotifyTakeDamage(Damage, DamageCauser, DamageType);
	}
	
	// notify owner that this unit is under attack
	if (OwningPlayer != none)
	{
		OwningPlayer.NotifyTakeDamage(self, DamageType);
	}

	// remember damage dealt and taken for score screen
	if (InstigatedBy != none)
	{
		HWPlayerController(InstigatedBy).TotalDamageDealt += Damage;
	}
	
	if (OwningPlayer != none && DamageType != class'HWDT_Dismiss')
	{
		OwningPlayer.TotalDamageTaken += Damage;
	}
}

event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	local bool bHealed;

	bHealed = super.HealDamage(Amount, Healer, DamageType);

	if (bHealed)
	{
		// remember damage healed for score screen
		HWPlayerController(Healer).TotalDamageHealed += Amount;
	}

	return bHealed;
}

function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
	super.AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);

	// apply armor
	InDamage = Armor > InDamage ? 0 :  InDamage - Armor;
}

/** Overwritten in order to prevent units killing each other when colliding. */
function gibbedBy(actor Other)
{
	`log("WARNING: "$self$" is being gibbed by "$Other$".");
}

/** Overwritten in order to prevent units killing each other when colliding. */
function CrushedBy(Pawn OtherPawn)
{
	`log("WARNING: "$self$" is being crushed by "$OtherPawn$".");
}

/** @return whether or not we should gib due to damage from the passed in damagetype */
simulated function bool ShouldGib(class<HWDamageType> HWDT)
{
	return ((Mesh != None) && (bTearOffGibs || HWDT.Static.ShouldGib(self)));
}

/** spawns gibs and hides the pawn's mesh */
simulated function SpawnGibs(class<HWDamageType> HWDamageType, vector HitLocation)
{
	local int i;
	local bool bSpawnHighDetail;
	local GibInfo MyGibInfo;

	// make sure client gibs me too
	bTearOffGibs = true;

	if ( !bGibbed )
	{
		if (bPlayGibSounds)
		{
			// play sounds
			if (!AudioComponentGibScream.IsPlaying())
			{
				AudioComponentGibScream.Location = Location;
				AudioComponentGibScream.SoundCue = SoundGibScream;
				AudioComponentGibScream.Play();
			}

			if (!AudioComponentGibExplosion.IsPlaying())
			{
				AudioComponentGibExplosion.Location = Location;
				AudioComponentGibExplosion.SoundCue = SoundGibExplosion;
				AudioComponentGibExplosion.Play();
			}
		}

		// gib particles
		if (GibExplosionTemplate != None && EffectIsRelevant(Location, false, 7000))
		{
			WorldInfo.MyEmitterPool.SpawnEmitter(GibExplosionTemplate, Location, Rotation);
			// spawn all other gibs
			bSpawnHighDetail = !WorldInfo.bDropDetail && (Worldinfo.TimeSeconds - LastRenderTime < 1);
			for (i = 0; i < Gibs.length; i++)
			{
				MyGibInfo = Gibs[i];

				if ( bSpawnHighDetail || !MyGibInfo.bHighDetailOnly )
				{
					SpawnGib(MyGibInfo.GibClass, MyGibInfo.BoneName, HWDamageType, HitLocation, true);
				}
			}
		}

		Conceal();

		bGibbed = true;
	}
}

simulated function UTGib SpawnGib(class<UTGib> GibClass, name BoneName, class<HWDamageType> HWDamageType, vector HitLocation, bool bSpinGib)
{
	local UTGib Gib;
	local rotator SpawnRot;
	local int SavedPitch;
	local float GibPerterbation;
	local rotator VelRotation;
	local vector X, Y, Z;

	SpawnRot = QuatToRotator(Mesh.GetBoneQuaternion(BoneName));

	// @todo fixmesteve temp workaround for gib orientation problem
	SavedPitch = SpawnRot.Pitch;
	SpawnRot.Pitch = SpawnRot.Yaw;
	SpawnRot.Yaw = SavedPitch;
	Gib = Spawn(GibClass, self,, Mesh.GetBoneLocation(BoneName), SpawnRot);

	if ( Gib != None )
	{
		// add initial impulse
		GibPerterbation = HWDamageType.default.GibPerterbation * 32768.0;
		VelRotation = rotator(Gib.Location - HitLocation);
		VelRotation.Pitch += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;
		VelRotation.Yaw += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;
		VelRotation.Roll += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;
		GetAxes(VelRotation, X, Y, Z);

		if (Gib.bUseUnrealPhysics)
		{
			Gib.Velocity = Velocity + Z * (FRand() * 200.0 + 50.0);
			Gib.SetPhysics(PHYS_Falling);
		}
		else
		{
			Gib.Velocity = Velocity + Z * (FRand() * 50.0);
			Gib.GibMeshComp.WakeRigidBody();
			Gib.GibMeshComp.SetRBLinearVelocity(Gib.Velocity, false);
			if ( bSpinGib )
			{
				Gib.GibMeshComp.SetRBAngularVelocity(VRand() * 50, false);
			}
		}

		// let damagetype spawn any additional effects
		HWDamageType.static.SpawnGibEffects(Gib);
		Gib.LifeSpan = Gib.LifeSpan + (2.0 * FRand());
	}

	return Gib;
}

/** Disables this pawn's physics, collision and hides all its owned components. */
simulated function Conceal()
{
	local PrimitiveComponent Comp;

	SetPhysics(PHYS_None);
	SetCollision(false, false);

	foreach AllOwnedComponents(class'PrimitiveComponent', Comp)
	{
		Comp.SetHidden(true);
	}
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local bool DyingAllowed;
	local HWPlayerController KillingPlayer;
	local HWPlayerController Player;	
	local STextUpEffect TextUpEffect;

	// stop all channeling abilities
	HWAIController(Controller).InterruptChanneling();

	DyingAllowed = super.Died(Killer, DamageType, HitLocation);

	if (DyingAllowed)
	{
		// award shards to the killer
		if (Killer != none)
		{
			KillingPlayer = HWPlayerController(Killer);

			if (KillingPlayer != none)
			{
				KillingPlayer.Shards += GetShardsAwarded();

				// Show awarded Shards as TextUpEffect
				TextUpEffect.Location = Location;
				TextUpEffect.Text = string(GetShardsAwarded());
				TextUpEffect.Color.B = 255;
				KillingPlayer.ClientShowTextUpEffect(TextUpEffect);
			}

			`log(self$" has been killed by "$Killer$".");
		}

		foreach WorldInfo.AllControllers(class'HWPlayerController', Player)
		{
			// make all players locally deselect this unit
			Player.DeselectUnit(self);

			// hide all map tiles this unit has vision on
			Player.ResetVisionFor(self);
		}

		// update server visibility mask
		if (TeamIndex < 2)
		{
			HWGame(WorldInfo.Game).Teams[TeamIndex].VisibilityMask.HideMapTilesFor(self);
		}
	}

	return DyingAllowed;
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local class<HWDamageType> HWDT;

	super.PlayDying(DamageType, HitLoc);

	HitDamageType = DamageType;
	TakeHitLocation = HitLoc;

	HWDT = class<HWDamageType>(DamageType);
	if (HWDT != None && !class'GameInfo'.static.UseLowGore(WorldInfo) && ShouldGib(HWDT))
	{
		SpawnGibs(HWDT, HitLoc);

		// give the pawn time to replicate bTearOffGibs before destroying it
		LifeSpan = AnimDurationDeath;
	}
	else
	{
		// play dying animation
		if(FullBodyAnimSlot != none && AnimNameDeath != '')
		{
			FullBodyAnimSlot.PlayCustomAnim(AnimNameDeath, 1.0, 0.05, -1.0, false, false);
		}

		// destroy pawn after animation finishes
		LifeSpan = AnimDurationDeath;
	}

	// play Died sound at the location of this unit for all players
	if (!AudioComponentDied.IsPlaying())
	{
		AudioComponentDied.Location = Location;
		AudioComponentDied.SoundCue = SoundDied;
		AudioComponentDied.Play();
	}
}

/** Returns the value of shards that are awarded for killing this pawn. */     
function int GetShardsAwarded();

/** Calls MakeNoise() in order to make enemies aware of this unit. */
function TriggerEnemyAcquisition()
{
	MakeNoise(1.0f, 'TriggerEnemyAcquisition');
}

/**
 * Starts playing the passed channeling sound loop, or just stops playing
 * the current one if passed None.
 * 
 * @param NewChannelingSoundLoop
 *      the loop to play
 */
simulated function PlayChannelingSoundLoop(SoundCue NewChannelingSoundLoop)
{
	// if the component is already playing this sound, don't restart it
	if (NewChannelingSoundLoop != ChannelingSoundComponent.SoundCue)
	{
		ChannelingSoundLoop = NewChannelingSoundLoop;
		ChannelingSoundComponent.Stop();
		ChannelingSoundComponent.SoundCue = NewChannelingSoundLoop;

		if (NewChannelingSoundLoop != None)
		{
			ChannelingSoundComponent.Play();
		}
	}
}

/**
 * Wraps the FullBodyAnimSlot.PlayCustomAnim() and FullBodyAnimSlot.StopCustomAnim() calls.
 * Sets this pawns AnimInfo if bNotReplicated == false (default) in order to allow replication of animations.
 */
function PlayCustomAnimation(
	name AnimName, 
	optional bool bNotReplicated, 
	optional bool bStop, 
	optional float Rate = 1.0f,
	optional float BlendInTime,
	optional float BlendOutTime = -1.0f,
	optional bool bLooping,
	optional bool bOverride,
	optional float StartTime)
{
	local AnimationInfo NewAnimInfo;

	if(!bNotReplicated)
	{
		NewAnimInfo.Name = AnimName;
		NewAnimInfo.bStop = bStop;
		NewAnimInfo.Rate = Rate;
		NewAnimInfo.BlendInTime = BlendInTime;
		NewAnimInfo.BlendOutTime = BlendOutTime;
		NewAnimInfo.bLooping = bLooping;
		NewAnimInfo.bOverride = bOverride;
		NewAnimInfo.StartTime = StartTime;

		AnimInfo = NewAnimInfo;
	}

	// Only stop the animation if it's the one currently played
	if(bStop && FullBodyAnimSlot.GetPlayedAnimation() == AnimName)
	{
		FullBodyAnimSlot.StopCustomAnim(0);
	}
	else
	{
		FullBodyAnimSlot.PlayCustomAnim(AnimName, Rate, BlendInTime, BlendOutTime, bLooping, bOverride, StartTime);
	}
}

/** 
 *  Shows visual feedback at the current position of this actor and adds
 *  this unit to the collection of selected units of the selecting player.
 *  Returns true if the unit could be selected, false otherwise.
 *  
 *  @param SelectingPlayer
 *      the player that selected this unit
 *  @param bAddToList
 *      whether to add this unit to the collection of selected units of the
 *      selecting player; defaults to true
 */
simulated function bool Select(HWPlayerController SelectingPlayer, optional bool bAddToList = true) 
{
	// prevent selection of cloaked enemy units
	if(OwningPlayer != SelectingPlayer && bCloaked)
	{
		return false;
	}

	if (super.Select(SelectingPlayer, bAddToList))
	{
		if (DecalSelected != none)
		{
			DecalSelected.SetHidden(false);
		}
		
		// don't show target destinations for aliens ;)
		if (OwningPlayer != none)
		{
			OwningPlayer.ShowOrderTargetDestination();
		}

		return true;
	}
	
	return false;
}

/** 
 *  Hides the Selected decal associated with this unit and 
 *  removes this unit from the collection of selected units of the local
 *  player. The latter is optional; if the list is to be cleared anyway,
 *  pass false to save CPU time.
 *  
 *  @param bRemoveFromList
 *      whether to remove this unit from the collection of selected units of
 *      the local player; defaults to true
 */
simulated function Deselect(optional bool bRemoveFromList = true) 
{
	/*
	 * This if-statement is the only reason we need the variable SelectedBy
	 * for. For some reason hiding the effect when it has never be shown (for
	 * example on map initialization) breaks the effect.
	 */
	if (SelectedBy != none && DecalSelected != none)
	{
		DecalSelected.SetHidden(true);
	}

	super.Deselect(bRemoveFromList);
}

simulated function bool ShowOnMiniMap()
{	
	// Always show own pawns 
	if(OwningPlayer != none && OwningPlayer.IsLocalPlayerController())
	{
		return true;
	}

	// Only show enemy pawns (Aliens and enemy SquadMembers) if not cloaked
	return !bCloaked;
}

/** 
 *  Main entry point for Controllers to start the attack process of pawns. 
 *  
 *  @param Target 
 *      The target to be attacked.
 */
function Attack(HWPawn Target)
{
	if(Range <= MELEE_RANGE)
	{
		bIsAttacking = true;

		MeleeDamage(Target);

		OnAttackStart();
	}
	else	
	{
		FireProjectileBarrage(Target);
	}

	// set the attack on cooldown
	bAttackOnCooldown = true;
	SetTimer(Cooldown, false, 'ReadyAttack');

	// trigger Kismet events
	if (OwningPlayer != none)
	{
		OwningPlayer.EnterCombat();
	}
}

/** Main entry point for Controllers to stop the attack process of pawns. */
function StopAttack()
{
	if(Range <= MELEE_RANGE)
	{
		bIsAttacking = false;

		OnAttackStop();
	}
}

/** Starts any attack effects (e.g. attack animation loop). */
simulated function OnAttackStart()
{
	if(Range <= MELEE_RANGE)
	{
		// PlayCustomAnimByDuration() is used to ensure that the animation's duration matches the attack's cooldown
		FullBodyAnimSlot.PlayCustomAnimByDuration(AnimNameMeleeAttack, Cooldown, 0.05, -1.0, true, false);
	}
}

/** Stops any attack effects (e.g. attack animation loop). */
simulated function OnAttackStop()
{
	if(Range <= MELEE_RANGE)
	{
		FullBodyAnimSlot.StopCustomAnim(0);
	}
}

/**
 * Starts firing a barrage of a random number of projectiles at the
 * specified target.
 * 
 * @param Target
 *      the target to be attacked
 */
function FireProjectileBarrage(HWPawn Target)
{
	CurrentBarrageTarget = Target;
	CurrentBarrageProjectilesRemaining = ProjectilesPerBarrageMin + Rand(ProjectilesPerBarrageMax - ProjectilesPerBarrageMin + 1);
	FireProjectile();
}

/** 
 *  Spawns and fires a new projectile with the statistics of this pawn
 *  in direction of the current projectile barrage's target.
 */
function FireProjectile()
{
	local HWProjectile p;
	
	p = HWProjectile(Spawn(ProjectileClass, self,, GetEffectLocation()));		
	p.InitProjectile(self, CurrentBarrageTarget);

	// Trigger weapon fired effects
	IncrementFlashCount(none, 0);

	// keep on firing the barrage, if any projectiles remain
	CurrentBarrageProjectilesRemaining--;

	if (CurrentBarrageProjectilesRemaining > 0)
	{
		SetTimer(TimeBetweenBarrageProjectiles, false, 'FireProjectile');
	}
}

/**
 * Immediately deals damage to all enemy units within a SplashDamageRadius
 * around the specified target.
 * 
 * @param Target
 *      the target to attack
 */
function MeleeDamage(HWPawn Target)
{
	local HWPawn Victim;

	if (SplashDamageRadius == 0) 
	{
		// deal damage to single target
		DealDamageTo(Target);
	}
	else
	{
		// deal damage to all enemy units within SplashDamageRadius around the target's location (no friendly fire here)
		foreach CollidingActors(class'HWPawn', Victim, SplashDamageRadius, Target.Location)
		{
			if (Victim.TeamIndex != TeamIndex)
			{
				DealDamageTo(Victim);
			}
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
	Victim.TakeDamage(AttackDamage, OwningPlayer, Victim.Location, vect(0,0,0), class'DamageType',, self);
	
	if (bAttacksKnockTargetBack)
	{
		Victim.KnockedBackBy(self, KnockbackMomentum, 0.f);
	}
}

/** Turns the standard attack of this unit ready again after its cooldown has expired. */
function ReadyAttack()
{
	bAttackOnCooldown = false;
}

/** Returns the time before the standard attack of this unit can be used again, in seconds. */
function float GetRemainingAttackCooldown()
{
	return GetTimerRate('ReadyAttack') - GetTimerCount('ReadyAttack');
}

/** 
 *  Returns the location for any attack effects (e.g. muzzle flash). 
 *  Should be overridden by subclasses which use a different effect location as the default. 
 *  Default is the pawns location. */
function vector GetEffectLocation()
{
	return Location;
}

/**
 * Removes the first buff of the specified class from this unit.
 * 
 * @param BuffClass
 *      the class of the buff to remove
 */
function RemoveBuffByClass(class<HWBuff> BuffClass)
{
	local HWBuff Buff;

	if (Buffs != none)
	{
		// iterate buff list
		Buff = Buffs;

		while (Buff != none)
		{
			if (ClassIsChildOf(Buff.Class, BuffClass))
			{
				// found buff to remove; destroy buff and return
				Buff.WearOff();

				return;
			}
			else
			{
				Buff = Buff.NextBuff;
			}
		}
	}
}

/**
 * Returns the given buff if the pawn has it applied, returns none if not.
 */
function HWBuff GetBuff(class<HWBuff> BuffClass)
{
	local HWBuff Buff;

	if (Buffs != none)
	{
		Buff = Buffs;

		while (Buff != none)
		{
			if (ClassIsChildOf(Buff.Class, BuffClass))
			{
				return Buff;
			}
			else
			{
				Buff = Buff.NextBuff;
			}
		}
	}

	return none;
}

/**
 * Called by the possessing controller to notify this unit that is has engaged
 * an enemy without having received a specific order to do so, for example
 * because it was attacked or heard an enemy.
 * 
 * Plays the Battle Cry sound of this unit, if possbile, and calls nearby
 * allied units for help.
 */
function NotifyEnemyEngaged()
{
	local HWPlayerController PC;

	//`log(self$" has engaged an enemy, calling for help.");

	// call for help
	MakeNoise(1.0f, 'CallForHelp');

	// play Battle Cry sound at the location of this unit for all players
	if (SoundBattleCry != none)
	{
		foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
		{
			PC.ClientPlaySoundBattleCry(Location, SoundBattleCry);
		}
	}
}

/**
 * Knocks this unit back, if it is not immune at the moment.
 * 
 * @param A
 *      the actor knocking this unit back
 * @param inKnockbackMomentum
 *      the knockback momentum applied to this unit
 * @param inKnockbackDamage
 *      the damage the knockback deals
 */
function KnockedBackBy(Actor A, float inKnockbackMomentum, int inKnockbackDamage)
{
	local Vector Momentum;
	local HWPawn KnockingUnit;
	local HWProjectile KnockingProjectile;
	local HWPlayerController KnockingPlayer;
	local HWBuff Buff;

	if (!bImmuneToKnockbacks)
	{
		// stop all channeling abilities (controller might have been already destroyed if pawn was killed)
		if(Controller != none)
		{
			HWAIController(Controller).InterruptChanneling();
		}

		// remember knockback caused for score screen
		KnockingUnit = HWPawn(A);

		if (KnockingUnit != none)
		{
			KnockingPlayer = KnockingUnit.OwningPlayer;
		}
		else
		{
			KnockingProjectile = HWProjectile(A);

			if (KnockingProjectile != none)
			{
				KnockingPlayer = KnockingProjectile.OwningPlayer;
			}
		}

		if (KnockingPlayer != none)
		{
			KnockingPlayer.TotalKnockbacksCaused++;
		}

		// remember knockback taken for score screen
		if (OwningPlayer != none)
		{
			OwningPlayer.TotalKnockbacksTaken++;
		}

		// do knockback
		Momentum = Normal(Location - A.Location) * inKnockbackMomentum;
		TakeDamage(inKnockbackDamage, KnockingPlayer, Location, Momentum, class'DamageType', , self);

		// blind and silence for a short duration
		Buff = Spawn(class'HWBu_Blind', A);
		Buff.Duration = 0.5f;
		Buff.ApplyBuffTo(self);

		Buff = Spawn(class'HWBu_Silence', A);
		Buff.Duration = 0.5f;
		Buff.ApplyBuffTo(self);

		`log(self$" has been knocked back by "$A$", applying momentum "$Momentum);
	}
	else
	{
		`log(self$" would have been knocked back by "$A$", but is immune.");
	}
}

/** Snares this unit, rendering it unable to move. */
function Snare()
{
	GroundSpeed = 0;
	bSnared = true;
}

/** Frees this unit, making it able to move again. */
function UnSnare()
{
	GroundSpeed = MovementSpeed;
	bSnared = false;
}

/** Cloaks this unit:
 *  increases its movement speed and hides it,
 *  but renders it unable to attack or use abilities. */
simulated function Cloak()
{
	local MeshComponent MeshComp;

	bCloaked = true;

	// hide all mesh components for enemy pawns
	if(!IsLocalControlled())
	{
		Deselect(true);

		foreach AllOwnedComponents(class'MeshComponent', MeshComp)
		{
			MeshComp.SetHidden(true);
		}

		// schedule the cloak effect deactivation
		SetTimer(1.5, , 'HideCloakEffect');
	}
	
	// activate the cloak effect for own and enemy pawn
	CloakOverlayMesh.SetHidden(false);

	// stop all orders targeting this unit on the server (for both teams)
	if(WorldInfo.NetMode < NM_Client)
	{
		HWGame(WorldInfo.Game).StopOrders(self, 0); 
		HWGame(WorldInfo.Game).StopOrders(self, 1); 
	}
}

simulated function HideCloakEffect()
{
	CloakOverlayMesh.SetHidden(true);
}

/** Uncloaks this unit: all cloak effects are removed. */
simulated function UnCloak()
{
	local MeshComponent MeshComp;

	bCloaked = false;

	// unhide all mesh components for enemy pawns
	if(!IsLocalControlled())
	{
		// this also activates the cloak effect
		foreach AllOwnedComponents(class'MeshComponent', MeshComp)
		{
			MeshComp.SetHidden(false);
		}

		// show the cloak effect for some time after uncloakings
		SetTimer(1.5, , 'HideCloakEffect');
	}
	// deactivate the cloak effect immediately for own pawns
	else
	{
		CloakOverlayMesh.SetHidden(true);
	}
}

/**
 * Kills this pawn, triggering all death effects and animations.
 * 
 * @param inDamageType
 *      the type of damage that killed this pawn
 */
function Kill(class<DamageType> inDamageType)
{
	TakeDamage(10000, none, Location, vect(0,0,0), inDamageType);
}

/** 
 *  Overrides the base implementation in order to destroy this HWPawn and its variables on a Reset() call.
 *  (the base implementation only destroys pawns controlled by a PlayerController with bIsPlayer == true. HWPawns have HWAIControllers with bIsPlayer == false).
 */
function Reset()
{
	super.Reset();

	// Destroy() implicitly destroys the Controller
	Destroy();
}

simulated function Destroyed()
{
	local HWBuff CurrentBuff;
	local HWBuff NextBuff;

	super.Destroyed();

	// destroy all buffs
	CurrentBuff = Buffs;

	while (CurrentBuff != none)
	{
		NextBuff = CurrentBuff.NextBuff;
		CurrentBuff.Destroy();
		CurrentBuff = NextBuff;
	}

	// destroy the Selected decal if this actor is destroyed
	if (DecalSelected != none)
	{
		DecalSelected.Destroy();
	}

	// destroy the Attacked decal if this actor is destroyed
	if (DecalAttacked != none)
	{
		DecalAttacked.Destroy();
	}
}

/** 
 *  Calling this function freezes the pawn.
 *  Additionally to the base implementation, a StopOrder is issued on the server on this HWPawn's HWAIController and its RoundEnded state is entered.
 */
simulated function TurnOff()
{
	super.TurnOff();

	// server only
	if(Role == ROLE_Authority)
	{
		HWAIController(Controller).IssueStopOrder();
		HWAIController(Controller).GoToState('RoundEnded');
	}
}

/**
 * Does nothing, it's just implemented to prevent Kismet warnings (Warning: Obj HWSM_Commander_0 has no handler for SeqAct_ToggleCinematicMode_0).
 * This is because a SeqAct_ToggleCinematicMode uses a SeqVar_Player in order to find all existing Controllers (PlayerController & AIController).
 * If the Controller has a pawn (in case of AIController), OnToggleCinematicMode is called on it, which leads to the warning.
 */
function OnToggleCinematicMode(SeqAct_ToggleCinematicMode Action)
{
	// do nothing
}

/** Returns true if this pawn is owned by the local PlayerController, false otherwise. */
simulated function bool IsLocalControlled()
{
	local PlayerController localPC;

	localPC = GetALocalPlayerController();

	return localPC == none ? false : OwningPlayer == none ? false : OwningPlayer == localPC;
}

/** Called if the OwningPlayer variable was changed by replication on a client. */
simulated function OnOwningPlayerChanged()
{
}

/** Called if the OwningPlayerRI variable was changed by replication on a client. */
simulated function OnOwningPlayerRIChanged()
{
}

/** Called from PC when this pawn will be selected for attack. */
simulated function ShowAttackedCircle(bool bShow)
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (bShow)
		{
			DecalAttacked = Spawn(class'HWDe_AttackedCircle', self, , Location, Rotation);
			if (DecalAttacked != none)
			{
				DecalAttacked.SetRadius(self.GetCollisionRadius() * 1.5f);
				DecalAttacked.SetHidden(false);
				SetTimer(1.0, false, 'AttackedCircleTimer');
			}
		}
		else
		{
			if (DecalAttacked != none)
			{
				DecalAttacked.SetHidden(true);
				DecalAttacked.Destroy();
			}
		}
	}
}

simulated function AttackedCircleTimer()
{
	ShowAttackedCircle(false);
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'ChannelingSoundLoop')
	{
		PlayChannelingSoundLoop(ChannelingSoundLoop);
	}
	else if( VarName == 'bIsAttacking' )	
	{
		if(bIsAttacking)
		{
			OnAttackStart();
		}
		else
		{
			OnAttackStop();
		}
	}
	else if (VarName == 'AnimInfo')
	{
		if(AnimInfo.bStop && FullBodyAnimSlot.GetPlayedAnimation() == AnimInfo.Name)
		{
			FullBodyAnimSlot.StopCustomAnim(0);
			
		}
		else
		{
			FullBodyAnimSlot.PlayCustomAnim(AnimInfo.Name, AnimInfo.Rate, AnimInfo.BlendInTime, AnimInfo.BlendOutTime, AnimInfo.bLooping,  AnimInfo.bOverride, AnimInfo.StartTime);
		}
	}
	else if (VarName == 'bCloaked')
	{
		if(bCloaked)
		{
			Cloak();
		}
		else
		{
			UnCloak();
		}
	}
	else if (VarName == 'OwningPlayer')
	{
		OnOwningPlayerChanged();
	}
	else if (VarName == 'OwningPlayerRI')
	{	
		OnOwningPlayerRIChanged();
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

replication
{
	// Replicate if server
	if (Role == ROLE_Authority && (bNetInitial || bNetDirty))
		OwningPlayer, OwningPlayerRI, bAttackOnCooldown, Buffs, bSnared, bCloaked, bSilenced, bBlinded,

		// required for playing sounds on the client
		ChannelingSoundLoop,
		
		// required for learning the rusher ultimate ability
		Armor,
		
		// required for learning the hunter ultimate ability
		Range,

		// required for level-ups
		AttackDamage,

		// required to trigger local effects (animations) on attack start or stop
		bIsAttacking,
			
		AnimInfo;
}

DefaultProperties
{
	ControllerClass=class'HWAIController'

	// TODO Set to HWScout values used for NavMesh generation
	//WalkableFloorZ=0.85

	RotationRate=(Pitch=100000,Yaw=100000,Roll=100000)

	bCanJump=true
	bReplicateHealthToAll=true

	bShouldFocusTarget=true

	Begin Object Class=AudioComponent name=NewChannelingSoundComponent
	End Object
	ChannelingSoundComponent=NewChannelingSoundComponent
	Components.Add(NewChannelingSoundComponent)

	Begin Object Class=AudioComponent name=NewAudioComponentDied
	End Object
	AudioComponentDied=NewAudioComponentDied
	Components.Add(NewAudioComponentDied)

	Begin Object Class=AudioComponent name=NewAudioComponentGibScream
	End Object
	AudioComponentGibScream=NewAudioComponentGibScream
	Components.Add(NewAudioComponentGibScream)

	Begin Object Class=AudioComponent name=NewAudioComponentGibExplosion
	End Object
	AudioComponentGibExplosion=NewAudioComponentGibExplosion
	Components.Add(NewAudioComponentGibExplosion)

	CloakMaterial=Material'FX_Abilities.M_Ability_Cloak_Test'

	Begin Object Name=OverlayMeshComponentCloak Class=SkeletalMeshComponent
		Scale=1.015
		bAcceptsDynamicDecals=FALSE
		CastShadow=false
		bOwnerNoSee=true
		bUpdateSkelWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=true
		TickGroup=TG_PostAsyncWork
		bAllowAmbientOcclusion=false
		HiddenGame=true
	End Object
	CloakOverlayMesh=OverlayMeshComponentCloak
	Components.Add(OverlayMeshComponentCloak)

	SoundGibExplosion=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_BodyExplosion_Cue'
	SoundGibScream=SoundCue'A_Character_CorruptEnigma_Cue.Mean_Efforts.A_Effort_EnigmaMean_DeathInstant_Cue'

	bPlayGibSounds=true
}
