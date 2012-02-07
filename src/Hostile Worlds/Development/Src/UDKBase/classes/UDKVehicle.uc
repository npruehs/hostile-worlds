/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKVehicle extends UDKVehicleBase
	abstract
	native
	nativereplication
	notplaceable;

/** If true, any dead bodies that get ejected when the vehicle is flipped/destroy will be destroyed immediately */
var	bool bEjectKilledBodies;

/** If true, certain weapons/vehicles can lock their weapons on to this vehicle */
var bool	bHomingTarget;

/** Set internally by physics - if the contact force is pressing along vehicle forward direction. */
var const bool	bFrontalCollision;

/** If bFrontalCollision is true, this indicates the collision is with a fixed object (ie not PHYS_RigidBody) */
var const bool	bFrontalCollisionWithFixed;

/** If true, don't damp z component of vehicle velocity while it is in the air */
var bool bNoZDampingInAir;

/** If true, don't damp z component of vehicle velocity even when on the ground */
var bool bNoZDamping;

// when hit with EMP, a Vehicle is Disabled.
var repnotify bool bIsDisabled;

/** How long until it's done burning */
var float RemainingBurn;

/** This vehicle is dead and burning */
var bool bIsBurning;

struct native BurnOutDatum
{
	var MaterialInstanceTimeVarying MITV;

	/**
	 * We need to store the value of the MIC set param on a per material basis as we have some MICs where are
	 * vastly different than the others.
	 **/
	var float CurrValue;

};

/** The material instances and their data used when showing the burning hulk */
var array<BurnOutDatum> BurnOutMaterialInstances;

/** Sound to play from the tires */
var(Sounds) editconst const AudioComponent TireAudioComp;
var(Sounds) array<MaterialSoundEffect> TireSoundList;
var name CurrentTireMaterial;

/** Max dist for wheel sounds and particle effects */
var float MaxWheelEffectDistSq;

/** material specific wheel effects, applied to all attached UDKVehicleWheels with bUseMaterialSpecificEffects set to true */
var array<MaterialParticleEffect> WheelParticleEffects;

/** Used natively to determine if the vehicle has been upside down */
var float LastCheckUpsideDownTime;

/** If true, all passengers (inc. the driver) will be ejected if the vehicle flips over */
var	bool bEjectPassengersWhenFlipped;

/** Used natively to give a little pause before kicking everyone out */
var	float FlippedCount;

/** If true, this vehicle is scraping against something */
var bool bIsScraping;

/** Sound to play when the vehicle is scraping against something */
var(Sounds) AudioComponent ScrapeSound;

/** The health ratio threshold at which the vehicle will catch on fire (and begin to take continuous damage if empty) */
var float FireDamageThreshold;

/** Damage per second if vehicle is on fire */
var float FireDamagePerSec;

/** Accrued Fire Damage */
var float AccruedFireDamage;

/** Damage per second if vehicle is upside down*/
var float UpsideDownDamagePerSec;

/** Damage per second if vehicle is upside down with a driver */
var float OccupiedUpsideDownDamagePerSec;

/*********************************************************************************************
 Water Damage
********************************************************************************************* */

/** How much damage the vehicle will take when submerged in the water */
var float WaterDamage;

/** Whether takes water damage while being driven */
var bool bTakeWaterDamageWhileDriving;

/** Accumulated water damage (only call take damage when > 1 */
var float AccumulatedWaterDamage;

/*********************************************************************************************
 Ground Effects
********************************************************************************************* */

/** indicies into VehicleEffects array of ground effects that have their 'DistToGround' parameter set via C++ */
var array<int> GroundEffectIndices;

/** maximum distance vehicle must be from the ground for ground effects to be displayed */
var float MaxGroundEffectDist;

/** particle parameter for the ground effect, set to the ground distance divided by MaxGroundEffectDist (so 0.0 to 1.0) */
var name GroundEffectDistParameterName;

/** Effect to switch to when over water. */
var ParticleSystem	WaterGroundEffect;

/*********************************************************************************************
 Turret controllers / Aim Variables
********************************************************************************************* */
/*
	Vehicles need to handle the replication of all variables required for the firing of a weapon.
	Each vehicle needs to have a set of variables that begin with a common prefix and will be used
	to line up the needed replicated data with that weapon.  The first weapon of the vehicle (ie: that
	which is associated with the driver/seat 0 has no prefix.

	<prefix>WeaponRotation 	- This defines the physical desired rotation of the weapon in the world.
	<prefix>FlashLocation	- This defines the hit location when an instant-hit weapon is fired
	<prefix>FlashCount		- This value is incremented after each shot
	<prefix>FiringMode		- This is assigned the firemode the weapon is currently functioning in

	Additionally, each seat can have any number of SkelControl_TurretConstrained controls associated with
	it.  When a <prefix>WeaponRotation value is set or replicated, those controls will automatically be
	updated.

	FlashLocation, FlashCount and FiringMode (associated with seat 0) are predefined in PAWN.UC.  WeaponRotation
	is defined below.  All "turret" variables must be defined "repnotify".  FlashLocation, FlashCount and FiringMode
	variables should only be replicated to non-owning clients.
*/

/** rotation for the vehicle's main weapon */
var repnotify rotator WeaponRotation;

/** info on locations for weapon bonus effects (UDamage, etc) */
struct native WeaponEffectInfo
{
	/** socket to base on */
	var name SocketName;
	/** offset from the socket to place the effect */
	var vector Offset;
	/** Scaling for the effect */
	var vector Scale3D;
	/** reference to the component */
	var StaticMeshComponent Effect;

	structdefaultproperties
	{
		Scale3D=(X=1.0,Y=1.0,Z=1.0)
	}
};

/**	The VehicleSeat struct defines each available seat in the vehicle. */
struct native VehicleSeat
{
	// ---[ Connections] ------------------------

	/** Who is sitting in this seat. */
	var() editinline  Pawn StoragePawn;

	/** Reference to the WeaponPawn if any */
	var() editinline  Vehicle SeatPawn;

	// ---[ Weapon ] ------------------------

	/** class of weapon for this seat */
	var() class<UDKWeapon> GunClass; 

	/** Reference to the gun */
	var() editinline  UDKWeapon Gun; 

	/** Name of the socket to use for effects/spawning */
	var() array<name> GunSocket;

	/** Where to pivot the weapon */
	var() array<name> GunPivotPoints;

	var	int BarrelIndex;

	/** This is the prefix for the various weapon vars (WeaponRotation, FlashCount, etc)  */
	var() string TurretVarPrefix;

	/** list of locations for weapon bonus effects (UDamage, etc) and the component references if those effects are active */
	var array<WeaponEffectInfo> WeaponEffects;

	/** Cached names for this turret */

	var name	WeaponRotationName;
	var name	FlashLocationName;
	var name	FlashCountName;
	var name	FiringModeName;

	/** Cache pointers to the actual UProperty that is needed */

	var const pointer	WeaponRotationProperty;
	var const pointer	FlashLocationProperty;
	var const pointer	FlashCountProperty;
	var const pointer	FiringModeProperty;

	/** Holds a duplicate of the WeaponRotation value.  It's used to determine if a turret is turning */

	var rotator LastWeaponRotation;

	/** This holds all associated TurretInfos for this seat */
	var() array<name> TurretControls;

	/** Hold the actual controllers */
	var() editinline array<UDKSkelControl_TurretConstrained> TurretControllers;

	/** Cached in ApplyWeaponRotation, this is the vector in the world where the player is currently aiming */
	var vector AimPoint;

	/** Cached in ApplyWeaponRotation, this is the actor the seat is currently aiming at (can be none) */
	var actor AimTarget;

	/** Z distance between weapon pivot and actual firing location - used to correct aiming rotation. */
	var float PivotFireOffsetZ;

	/** Disable adjustment to turret pitch based on PivotFireOffsetZ. */
	var bool bDisableOffsetZAdjust;

	// ---[ Camera ] ----------------------------------

	/** Name of the Bone/Socket to base the camera on */
	var() name CameraTag;

	/** Optional offset to add to the cameratag location, to determine base camera */
	var() vector CameraBaseOffset;

	/** Optional offset to add to the vehicle location, to determine safe trace start point */
	var() vector CameraSafeOffset;

	/** how far camera is pulled back */
	var() float CameraOffset;

	/** The Eye Height for Weapon Pawns */
	var() float CameraEyeHeight;

	// ---[ View Limits ] ----------------------------------
	// - NOTE!! If ViewPitchMin/Max are set to 0.0f, the values associated with the host vehicle will be used

	/** Used for setting the ViewPitchMin on the Weapon pawn */
	var() float ViewPitchMin;

	/** Used for setting the ViewPitchMax on the Weapon pawn */
	var() float ViewPitchMax;

	// ---[  Pawn Visibility ] ----------------------------------

	/** Is this a visible Seat */
	var() bool bSeatVisible;

	/** Name of the Bone to use as an anchor for the pawn */
	var() name SeatBone;

	/** Offset from the origin to place the based pawn */
	var() vector SeatOffset;

	/** Any additional rotation needed when placing the based pawn */
	var() rotator SeatRotation;

	/** Name of the Socket to attach to */
	var() name SeatSocket;

	// ---[ Muzzle Flashes ] ----------------------------------
	var class<UDKExplosionLight> MuzzleFlashLightClass;

	var	UDKExplosionLight		MuzzleFlashLight;

	// ---[ Impact Flashes (for instant hit only) ] ----------------------------------
	var class<UDKExplosionLight> ImpactFlashLightClass;

	// ---[ Misc ] ----------------------------------

	/** damage to the driver is multiplied by this value */
	var() float DriverDamageMult;

	// ---[ Sounds ] ----------------------------------

	/** The sound to play when this seat is in motion (ie: turning) */
	var AudioComponent SeatMotionAudio;

	var UDKVehicleMovementEffect SeatMovementEffect;

	// ---[ HUD ] ----------------------------------

	var vector2D SeatIconPOS;

};

/** information for each seat a player may occupy
 * @note: this array is on clients as well, but SeatPawn and Gun will only be valid for the client in that seat
 */
var(Seats)	array<VehicleSeat> 	Seats;

/** This replicated property holds a mask of which seats are occupied.  */
var int SeatMask;

struct native VehicleAnim
{
	/** Used to look up the animation */
	var() name AnimTag;

	/** Animation Sequence sets to play */
	var() array<name> AnimSeqs;

	/** Rate to play it at */
	var() float AnimRate;

	/** Does it loop */
	var() bool bAnimLoopLastSeq;

	/**  The name of the UTAnimNodeSequence to use */
	var() name AnimPlayerName;
};

/** Holds a list of vehicle animations */
var(Effects) array<VehicleAnim>	VehicleAnims;

struct native VehicleSound
{
	var() name SoundStartTag;
	var() name SoundEndTag;
	var() SoundCue SoundTemplate;
	var AudioComponent SoundRef;
};

var(Effects) array<VehicleSound> VehicleSounds;

/** Anim to play when a visible driver is driving */
var	name	DrivingAnim;

/*********************************************************************************************
 Penetration destruction
********************************************************************************************* */

/** If a physics penetration of greater than this is detected, destroy vehicle. */
var() float DestroyOnPenetrationThreshold;

/** If we are over DestroyOnPenetrationThreshold for more than this (seconds), call RBPenetrationDestroy. */
var() float DestroyOnPenetrationDuration;

/** TRUE indicates vehicle is currently in penetration greater than DestroyOnPenetrationThreshold. */
var bool bIsInDestroyablePenetration;

/** How long the vehicle has been in penetration greater than DestroyOnPenetrationThreshold. */
var float TimeInDestroyablePenetration;

/** stores the time of the last death impact to stop spamming them from occurring*/
var float LastDeathImpactTime;

/** The sounds this vehicle will play based on impact force */
var SoundCue LargeChunkImpactSound, MediumChunkImpactSound, SmallChunkImpactSound;

/** Is this vehicle dead */
var repnotify bool bDeadVehicle;

/** If true, jostle vehicle with driver (used for air vehicles to provide natural hovering motion) */
var bool bJostleWhileDriving;

/** Set true for flying vehicles */
var bool bFloatWhenDriven;

/** scaling factor for this vehicle's gravity - used in GetGravityZ() */
var(Movement) float CustomGravityScaling;

/*********************************************************************************************
 Damage Morphing
********************************************************************************************* */

struct native FDamageMorphTargets
{
	/** These are used to reference the MorphNode that is represented by this struct */
	var	name MorphNodeName;

	/** Link to the actual node */
	var	MorphNodeWeight	MorphNode;

	/** These are used to reference the next node if this is at 0 health.  It can be none */
	var name LinkedMorphNodeName;

	/** Actual Node pointed to by LinkMorphNodeName*/
	var	int LinkedMorphNodeIndex;

	/** This holds the bone that influences this node */
	var Name InfluenceBone;

	/** This is the current health of the node.  If it reaches 0, then we should pass damage to the linked node */
	var	int Health;

	/** Holds the name of the Damage Material Scalar property to adjust when it takes damage */
	var array<name> DamagePropNames;

	structdefaultproperties
	{
		Health=1.0f;
	}
};

struct native DamageParamScales
{
	var name DamageParamName;
	var float Scale;
};

var array<DamageParamScales> DamageParamScaleLevels;

/** Holds the damage skel controls */
var array<UDKSkelControl_Damage> DamageSkelControls;

/** Holds the Damage Morph Targets */
var	array<FDamageMorphTargets> DamageMorphTargets;

/* This allows access to the Damage Material parameters */
var MaterialInstanceConstant	DamageMaterialInstance[2];

/*********************************************************************************************
 Vehicle Effects
********************************************************************************************* */

/** replicated information on a hit we've taken */
var UDKPawn.UTTakeHitInfo LastTakeHitInfo;

/** stop considering LastTakeHitInfo for replication when world time passes this (so we don't replicate out-of-date hits when pawns become relevant) */
var float LastTakeHitTimeout;

/** Holds the needed data to create various effects that respond to different actions on the vehicle */
struct native VehicleEffect
{
	/** Tag used to trigger the effect */
	var() name EffectStartTag;

	/** Tag used to kill the effect */
	var() name EffectEndTag;

	/** If true should restart running effects, if false will just keep running */
	var() bool bRestartRunning;

	var() bool bHighDetailOnly;

	/** Template to use */
	var() ParticleSystem EffectTemplate;

	/** Template to use for the blue team (may or may not be one)*/
	var() ParticleSystem EffectTemplate_Blue;

	/** Socket to attach to */
	var() name EffectSocket;

	/** The Actual PSC */
	var ParticleSystemComponent EffectRef;

	structdefaultproperties
	{
		bRestartRunning=true;
	}
};
/** Holds the Vehicle Effects data */
var(Effects) array<VehicleEffect>	VehicleEffects;

/** player that killed the vehicle (replicated, but only to that player) */
var Controller KillerController;

/** Natively used in determining when a bot should just out of the vehicle */
var float LastJumpOutCheck;

/** Water effect type name */
var name WaterEffectType;

/*****************************************************************************************************
 Contrails for flying vehicles
******************************************************************************************************/

/** indices into VehicleEffects array of contrail effects that have their 'ContrailColor' parameter set via C++ */
var array<int> ContrailEffectIndices;

/** parameter name for contrail color (determined by speed) */
var name ContrailColorParameterName;

/** Whether the driver is allowed to exit the vehicle */
var		bool				bAllowedExit;

/** if AI controlled and bot needs to trigger an objective not triggerable by vehicles, it will try to get out this far away */
var float ObjectiveGetOutDist;

var array<UDKBot> Trackers;

/** whether AI should consider using its squad's alternate path to objectives while in this vehicle
 * (set false for vehicles where detours are painful and/or the vehicle is so strong the AI just shouldn't care)
 */
var bool bUseAlternatePaths;

/** Holds the team designation for this vehicle */
var	repnotify byte Team;

/** additional downward threshold for AI reach tests (for high hover vehicles) */
var float ExtraReachDownThreshold;

/** if vehicle has no driver, CheckReset() will be called at this time */
var	float	ResetTime;

/** speed must be greater than this for running into someone to do damage */
var float MinRunOverSpeed;

/** last time checked for pawns in front of vehicle and warned them of their impending doom. */
var	float LastRunOverWarningTime;

/** last time checked for pawns in front of vehicle and warned them of their impending doom. */
var	float MinRunOverWarningAim;

/*********************************************************************************************
 Team beacons
********************************************************************************************* */

/** The maximum distance out that the Team Beacon will be displayed */
var	float TeamBeaconMaxDist;

/** Last time trace test check for drawing postrender hud icons was performed */
var float LastPostRenderTraceTime;

var bool bShowLocked;

/** Team defines which players are allowed to enter the vehicle */
var	bool bTeamLocked;

var float ShowLockedMaxDist;

var vector HUDLocation;

/** disable repulsors if the vehicle has negative Z velocity exceeds the Driver's MaxFallSpeed */
var bool bDisableRepulsorsAtMaxFallSpeed;

/** Emitter under the board making dust. */
var ParticleSystemComponent HoverboardDust;

/*********************************************************************************************
 Hoverboard native support (HACK)
 These properties need to be here because need replication (so must be in actor) and are accessed by native code.
********************************************************************************************* */
var		bool	bTrickJumping;
var		bool	bGrab1;
var		bool	bGrab2;
var		bool	bForceSpinWarmup;

cpptext
{
	virtual void OnRigidBodyCollision(const FRigidBodyCollisionInfo& MyInfo, const FRigidBodyCollisionInfo& OtherInfo, const FCollisionImpactData& RigidCollisionData);
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void TickSpecial(FLOAT DeltaTime);
	virtual void ApplyWeaponRotation(INT SeatIndex, FRotator NewRotation);
	void RequestTrackingFor(AUDKBot *Bot);
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
	virtual void PreNetReceive();
	virtual void PostNetReceive();
	virtual FVector GetDampingForce(const FVector& InForce);
	virtual UBOOL JumpOutCheck(AActor *GoalActor, FLOAT Distance, FLOAT ZDiff);
	virtual UBOOL ReachThresholdTest(const FVector& TestPosition, const FVector& Dest, AActor* GoalActor, FLOAT UpThresholdAdjust, FLOAT DownThresholdAdjust, FLOAT ThresholdAdjust);
	virtual void VehicleUnpackRBState();

#if WITH_NOVODEX
	virtual void PostInitRigidBody(NxActor* nActor, NxActorDesc& ActorDesc, UPrimitiveComponent* PrimComp);
#endif // WITH_NOVODEX
}

replication
{
	if (bNetDirty)
		bDeadVehicle, Team, CustomGravityScaling, SeatMask, bIsDisabled, bTeamLocked, bGrab1, bGrab2;
	if (bNetDirty && (!bNetOwner || bDemoRecording))
		WeaponRotation, bTrickJumping, bForceSpinWarmup;
	if (bNetDirty && WorldInfo.TimeSeconds < LastTakeHitTimeout)
		LastTakeHitInfo;
	if (bNetDirty && WorldInfo.ReplicationViewers.Find('InViewer', PlayerController(KillerController)) != INDEX_NONE)
		KillerController;
}

/*********************************************************************************************
  Native Accessors for the WeaponRotation, FlashLocation, FlashCount and FiringMode
********************************************************************************************* */
native simulated function rotator 	SeatWeaponRotation	(int SeatIndex, optional rotator NewRot,	optional bool bReadValue);
native simulated function vector  	SeatFlashLocation	(int SeatIndex, optional vector  NewLoc,	optional bool bReadValue);
native simulated function byte		SeatFlashCount		(int SeatIndex, optional byte NewCount, 	optional bool bReadValue);
native simulated function byte		SeatFiringMode		(int SeatIndex, optional byte NewFireMode,	optional bool bReadValue);

native simulated function ForceWeaponRotation(int SeatIndex, Rotator NewRotation);
native simulated function vector GetSeatPivotPoint(int SeatIndex);
native simulated function int GetBarrelIndex(int SeatIndex);

/** @return whether we are currently replicating to the Controller of the given seat
 * this would be equivalent to checking bNetOwner on that seat,
 * but bNetOwner is only valid during that Actor's replication, not during the base vehicle's
 * not complex logic, but since it's for use in vehicle replication statements, the faster the better
 */
native(999) noexport final function bool IsSeatControllerReplicationViewer(int SeatIndex);

/**
  * Returns damagetype to use for deaths caused by being run over by this vehicle
  */
function class<DamageType> GetRanOverDamageType()
{
	return class'DmgType_Crushed';
}

/**
 *  LockOnWarning() called by seeking missiles to warn vehicle they are incoming
 */
simulated event LockOnWarning(UDKProjectile IncomingMissile);

event OnPropertyChange(name PropName);

native function float GetGravityZ();

/** Notification that this vehicle has hit a ForcedDirVolume. If it returns FALSE, volume will not affect it. */
function bool OnTouchForcedDirVolume(UDKForcedDirectionVolume Vol)
{
	return TRUE;
}

/** plays take hit effects; called from PlayHit() on server and whenever LastTakeHitInfo is received on the client */
simulated event PlayTakeHitEffects();

/** called when the client receives a change to Health
 * if LastTakeHitInfo changed in the same received bunch, always called *after* PlayTakeHitEffects()
 * (this is so we can use the damage info first for more accurate modelling and only use the direct health change for corrections)
 */
simulated event ReceivedHealthChange();

/**
 * JumpOutCheck()
 * Check if bot wants to jump out of vehicle, which is currently descending towards its destination
 */
event JumpOutCheck();

/**
  * @RETURNS max rise force for this vehicle (used by AI)
  */
native function float GetMaxRiseForce();

/**
  * Check if close enough to something to auto destruct.
  * SelfDestruct() event called if tests pass.
  */
native simulated function bool CheckAutoDestruct(TeamInfo InstigatorTeam, float CheckRadius);

event SelfDestruct(Actor ImpactedActor);

/**
 * @Returns the TeamIndex of this vehicle
 */
simulated native function byte GetTeamNum();


simulated native function NativePostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir);

simulated native function bool InUseableRange(UDKPlayerController PC, float Dist);

/**
 * function used to update where icon for this actor should be rendered on the HUD
 *  @param 	NewHUDLocation 		is a vector whose X and Y components are the X and Y components of this actor's icon's 2D position on the HUD
 */
simulated native function SetHUDLocation(vector NewHUDLocation);

native simulated function InitDamageSkel();

/**
 * Whenever the morph system adjusts a health, it should call UpdateDamageMaterial() so that
 * any associated skins can be adjusted.  This is also native
 */
native simulated function UpdateDamageMaterial();

/**
 * When damage occur, we need to apply it to any MorphTargets.  We do this natively for speed
 *
 * @param	HitLocation		Where did the hit occured
 * @param	Damage			How much damage occured
 */
native function ApplyMorphDamage(vector HitLocation, int Damage, vector Momentum);

/**
 * The event is called from the native function ApplyMorphDamage when a node is destroyed (health <= 0).
 *
 * @param	MorphNodeIndex 		The Index of the node that was destroyed
 */
simulated event MorphTargetDestroyed(int MorphNodeIndex);

/** Called when a contact with a large penetration occurs. */
event RBPenetrationDestroy()
{
	if (Health > 0)
	{
		//`log("Penetration Death:"@self@Penetration);
		TakeDamage(10000, GetCollisionDamageInstigator(), Location, vect(0,0,0), class'DmgType_Crushed');
	}
}

/**
 * TakeWaterDamage() called every tick when AccumulatedWaterDamage>0 and PhysicsVolume.bWaterVolume=true
 *
 * @param	DeltaTime		The amount of time passed since it was last called
 */
event TakeWaterDamage();

/**
 *  Vehicle has been in the middle of nowhere with no driver for a while, so consider resetting it.
 *  Called when un attended for more than ResetTime
 */
event CheckReset()
{
	// base implementation doesn't reset
	ResetTime = WorldInfo.TimeSeconds + 10000000.0;
}
/**
 * This event occurs when the physics determines the vehicle is upside down or empty and on fire, and AccruedFireDamage exceeds 1. 
 */
event TakeFireDamage();

/**
  * Give script a chance to do some rigid body post initialization
  */
event PostInitRigidBody(PrimitiveComponent PrimComp);

event UpdateHoverboardDustEffect(float DustHeight);

defaultproperties
{
	MaxWheelEffectDistSq=16000000.0
	CustomGravityScaling=1.0
	bNoZDampingInAir=true
	bAllowedExit=true
	ObjectiveGetOutDist=1000.0
	TeamBeaconMaxDist=5000.0
	ShowLockedMaxDist=3000.0

	bUseAlternatePaths=true
}
