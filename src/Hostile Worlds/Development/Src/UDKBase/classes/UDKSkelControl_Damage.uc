/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSkelControl_Damage extends SkelControlSingleBone
	native(Animation);

/** Is this control initialized */
var bool bInitialized;

/** Quick link to the owning UDKVehicle */
var UDKVehicle OwnerVehicle;

/** Which morph Target to use for health.  If none, use the main vehicle health */
var float HealthPerc;

/** Whether the OnDamage functionality is active **/
var(Damage) bool bOnDamageActive;

/** Value to scale this bone to on death **/
var(Damage) float DamageBoneScale;

/** How much damage the control can take */
var(Damage) int DamageMax;

/** If the health target is above this threshold, this control will be inactive */
var(Damage) float ActivationThreshold;

/** Once activated, does we generate the control strength as a product of the health remaining, or is it always full */
var(Damage) bool bControlStrFollowsHealth;

/** The Static Mesh component to display when it breaks off */
var(Damage) StaticMesh	BreakMesh;

/** The threshold at which the spring will begin looking to break */
var(Damage) float BreakThreshold;

/** This is the amount of time to go from breaking to broken */
var(Damage) float BreakTime;

/** When breaking off, use this to build the vector */
var(Damage) vector DefaultBreakDir;

/**
 * The scale to use for the spawned piece.  (i.e. we have one static mesh asset but it is being spawned from different locations on a vehicle
 * which is mirrored down the center.
 **/
var(Damage) vector DamageScale;

/** ParticleSystem to spawn when this piece breaks */
var(Damage) ParticleSystem PS_DamageOnBreak;

/** ParticleSystem to attach when this piece flies off (i.e. a dark acrid trailing smoke trail!) */
var(Damage) ParticleSystem PS_DamageTrail;


/** Is this control broken */
var transient bool bIsBroken;

/** This is set to true when Break() is called.  It signals the control is breaking but not yet broken */
var transient bool bIsBreaking;

/** This holds the name of the bone that was broken */
var transient name BrokenBone;

/** This holds the real-time at which this should break */
var transient float BreakTimer;

/** cached MaxDamage for a vehicle */
var transient float OwnerVehicleMaxHealth;

/** force that pushes the part up when the part is broken off to clear the vehicle. */
var() vector BreakSpeed;

/** Whether the OnDeath functionality is active **/
var(OnDeath) bool bOnDeathActive;

/** Whether the OnDeath functionality is active for the secondary explosion **/
var(OnDeath) bool bOnDeathUseForSecondaryExplosion;

/** This is the percent that this piece will actually spawn if OnDeath is active **/
var(OnDeath) float DeathPercentToActuallySpawn;

/** Value to scale this bone to on death **/
var(OnDeath) float DeathBoneScale;

/** The static mesh to spawn on death **/
var(OnDeath) StaticMesh DeathStaticMesh;

/** This is the direction which the spawned vehicle piece will fly **/
var(OnDeath) vector DeathImpulseDir;

/**
 * The scale to use for the spawned piece.  (i.e. we have one static mesh asset but it is being spawned from different locations on a vehicle
 * which is mirrored down the center.
 **/
var(OnDeath) vector DeathScale;

/** ParticleSystem to spawn when this piece breaks */
var(OnDeath) ParticleSystem PS_DeathOnBreak;

/** ParticleSystem to attach when this piece flies off (i.e. a dark acrid trailing smoke trail!) */
var(OnDeath) ParticleSystem PS_DeathTrail;


cpptext
{
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
	virtual void CalculateNewBoneTransforms(INT BoneIndex, USkeletalMeshComponent* SkelComp, TArray<FBoneAtom>& OutBoneTransforms);
	virtual FLOAT GetBoneScale(INT BoneIndex, USkeletalMeshComponent* SkelComp);
	virtual UBOOL InitializeControl(USkeletalMeshComponent* SkelComp);
}

/**
 * This event is triggered when the spring has decided to break.
 *
 * Network - Called everywhere except on a dedicated server.
 */
simulated event BreakApart(vector PartLocation, bool bIsVisible)
{
	BoneScale = DamageBoneScale;
	bIsBreaking = FALSE;
	bIsBroken = TRUE;
}

simulated event BreakApartOnDeath(vector PartLocation, bool bIsVisible)
{
	BoneScale = DeathBoneScale;
	bIsBroken = TRUE;
}

simulated event float RestorePart()
{
	BoneScale = 1.0f;
	HealthPerc = 1.0f;

	return HealthPerc;
}

defaultproperties
{
	bOnDamageActive=TRUE

	bControlStrFollowsHealth=FALSE
	BreakThreshold=1.1
	BreakTime=0.0
	HealthPerc=1.f
	DamageMax=25
	bIgnoreWhenNotRendered=TRUE

	DamageScale=(X=1.0f,Y=1.0f,Z=1.0f)
	DeathScale=(X=1.0f,Y=1.0f,Z=1.0f)
	DeathPercentToActuallySpawn=1.0f
}

