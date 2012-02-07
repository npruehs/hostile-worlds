/*=============================================================================
	PhysXDestructibleActor.uc: Destructible Vertical Component.
	Copyright 2007-2008 AGEIA Technologies.
=============================================================================*/

class PhysXDestructibleActor extends FracturedStaticMeshActor
	dependson(PhysXDestructible)
	native(Mesh);

struct native SpawnBasis
{
	var	vector	Location;
	var	rotator	Rotation;
	var	float	Scale;
};

/** Contains aggregate collision info for all of the fragments */
var								PhysXDestructibleComponent		DestructibleComponent;

/** In case the destructible becomes dynamic */
var								LightEnvironmentComponent		LightEnvironment;

/** The FracturedStaticMesh and SkeletalMeshes which form the hierarchical decomposition */
var								PhysXDestructible				PhysXDestructible;

/* The DestructibleStructure (island) containing this actor. */
var								PhysXDestructibleStructure		Structure;

/** Where the parts may find their chunks within the Structure.  Appended element [#Fragments] = "stop" value */
var								array<int>						PartFirstChunkIndices;

/** Array of spawned parts (starts off a full array of NULL pointers) */
var								array<PhysXDestructiblePart>	Parts;

/** Array of neighbors in the destructible structure */
var								array<int>						Neighbors;

/** Destructible parameters - damage thresholds, crumble particle systems, etc. */
var(Destructible)	editinline	PhysXDestructibleParameters		DestructibleParameters;

/** Stored off linear size */
var transient	native float									LinearSize;

/** Fracture sound effect flag */
var	transient	native bool										bPlayFractureSound;

/** Fracture effect data - one for each fragment */
var transient	native array<SpawnBasis>						EffectBases;

/** Fluid crumbling data */
var	transient	native pointer									VolumeFill{struct FRBVolumeFill};

/** If this is checked, then only chunks that touch the world are considered for support. */
var(Destructible)		const bool								bSupportChunksTouchWorld;

/** If this is checked, then only chunks that are children of a FracturedStaticMesh support fragment are considered for support. */
var(Destructible)		const bool								bSupportChunksInSupportFragment;

/** Per frame Chunk graph update processing budget, in leaf chunks's quantity*/
var(Destructible)		const int								PerFrameProcessBudget;

/* Depth of the chunk which the Support Graph is base on */
var(Destructible)		const int								SupportDepth;
var						byte									NumPartsRemaining;	// Number of potentially active parts remaining

native function Init();
native function	Term();

simulated event SpawnEffects()
{
	local int i;
	local EmitterSpawnable Effect;
	local FracturedStaticMesh FracMesh;
	local ParticleSystem EffectPSys;

	// These are done individually since they might be positional
	FracMesh = FracturedStaticMesh(FracturedStaticMeshComponent.StaticMesh);
	if( FracMesh.FragmentDestroyEffects.length > 0 && EffectBases.Length > 0 )
	{
		EffectPSys = FracMesh.FragmentDestroyEffects[Rand(FracMesh.FragmentDestroyEffects.length)];
		if(EffectPSys != None)
		{
			for( i = 0; i < EffectBases.Length; i++ )
			{
				Effect = Spawn(class'EmitterSpawnable', self,, EffectBases[i].Location, EffectBases[i].Rotation);
				Effect.SetTemplate(EffectPSys, true);
				Effect.ParticleSystemComponent.SetScale(FracMesh.FragmentDestroyEffectScale*EffectBases[i].Scale);
				Effect.LifeSpan = 1.0;
			}
			EffectBases.Remove( 0, EffectBases.Length );
		}
	}
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	Init();
}

event Destroyed()
{
	super.Destroyed();
	Term();
}

/** Native code for SpawnEffects */
native function NativeSpawnEffects();

/** Native code for TakeDamage. */
native function NativeTakeDamage
(
	int						Damage,
	Controller				EventInstigator,
	vector					HitLocation,
	vector					Momentum,
	class<DamageType>		DamageType,
	optional TraceHitInfo	HitInfo,
	optional Actor			DamageCauser
);

/** TakeDamage will hide/spawn chunks when they get shot. */
simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// call Actor's version to handle any SeqEvent_TakeDamage for scripting
	local int Item;

	// Is there a better way to skip the body of FracturedStaticMeshActor.TakeDamage ?
	Item = HitInfo.Item;
	HitInfo.Item = FracturedStaticMeshComponent.GetCoreFragmentIndex();
	super.TakeDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser );
	HitInfo.Item = Item;

	NativeTakeDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser );
}

simulated native function TakeRadiusDamage
(
	Controller			InstigatedBy,
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	bool				bFullDamage,
	Actor               DamageCauser,
	optional float      DamageFalloffExponent=1.f
);

/**
 *	Break off all pieces in one go.
 */
simulated event Explode()
{
}

cpptext
{
	void			SpawnPart( INT FragmentIndex, UBOOL bFixed );
	void			QueueEffects( struct FPhysXDestructibleChunk & Chunk, INT DepthOffset = 0 );
	virtual void	OnRigidBodyCollision( const FRigidBodyCollisionInfo& MyInfo, const FRigidBodyCollisionInfo& OtherInfo, const FCollisionImpactData& RigidCollisionData );
	virtual void	PostLoad();
}

defaultproperties
{
/*
	Begin Object Class=PhysXDestructibleComponent Name=PhysXDestructibleComponent0
		bAllowApproximateOcclusion=TRUE
		bCastDynamicShadow=FALSE
		bForceDirectLightMap=TRUE
		BlockRigidBody=TRUE
		bAcceptsStaticDecals=FALSE
		bAcceptsDynamicDecals=FALSE
	End Object
	DestructibleComponent=PhysXDestructibleComponent0
	Components.Add(PhysXDestructibleComponent0)
*/
	bNoEncroachCheck=TRUE
	bWorldGeometry=FALSE
	bProjTarget=TRUE

	bSupportChunksTouchWorld=TRUE
	PerFrameProcessBudget=100

	Begin Object Name=FracturedStaticMeshComponent0
		bCastDynamicShadow=TRUE
		bUsePrecomputedShadows=FALSE
	End Object
}
