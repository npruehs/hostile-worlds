/*=============================================================================
	ApexDestructibleActor.uc: PhysX APEX integration. Destructible Actor
	Copyright 2008-2009 NVIDIA Corporation.
=============================================================================*/

/*** This class defines a single instance of a destructible asset */
class ApexDestructibleActor extends Actor
	dependson(ApexDestructibleAsset)
	dependson(LightComponent)
	native(Mesh)
	placeable;

/** If set, use this actor's fracture materials instead of the asset's fracture materials. */
var() bool														bFractureMaterialOverride;

/** Fracture effects for each fracture level. Used only if Fracture Material Override is set. */
var() const editfixedsize	array<FractureMaterial>				FractureMaterials;

/** The destructible static component. */
var() const editconst ApexStaticDestructibleComponent			StaticDestructibleComponent;


/** Defines an array that designates which of the destructible chunks are visible */
var init array<byte>								VisibilityFactors;

/** Cached sounds for fractures. */
var transient    array<SoundCue>                FractureSounds;
/** Cached particle effects for fractures. */
var transient    array<ParticleSystem>          FractureParticleEffects;

event SpawnFractureEmitter(ParticleSystem EmitterTemplate, vector SpawnLocation)
{
	local ParticleSystemComponent PSC;
	local LightingChannelContainer Lights;

	PSC = WorldInfo.MyEmitterPool.SpawnEmitter( EmitterTemplate, SpawnLocation );
	Lights = PSC.LightingChannels;
	// TODO: Modify Lights here according to FractureMaterial
	Lights.Dynamic = TRUE;
	Lights.bInitialized = TRUE;
	PSC.SetLightingChannels(Lights);
}

/** Initialize FractureSounds and FractureParticleEffects */
native function CacheFractureEffects();

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	CacheFractureEffects();
}

/** Declares the TakeDamage script function */
simulated native function TakeDamage
(
	int						Damage,				/* The amount of Damage to apply */
	Controller				EventInstigator,    /* The instigator of this event */
	vector					HitLocation,		/* The location where the impact occured */
	vector					Momentum,			/* The momentum of the impact */
	class<DamageType>		DamageType,			/* The type of damage to apply */
	optional TraceHitInfo	HitInfo,			/* The detailed hit information for this damage event */
	optional Actor			DamageCauser		/* The actor which caused the damage */
);

/** Declares the radius damage script function */
simulated native function ApexTakeRadiusDamage
(
	Controller			InstigatedBy,		/* The instigator for this radius damage */
	float				BaseDamage,			/* The base damage amount */
	float				DamageRadius,		/* The radius of the damage */
	class<DamageType>	DamageType,			/* The type of damage to apply */
	float				Momentum,			/* The momentum of the damage */
	vector				HurtOrigin,			/* The origin of the damage */
	bool				bFullDamage,		/* Whether or not to apply full damage or attenuated damage */
	Actor				DamageCauser		/* The actor which caused the damage */
);

cpptext
{
	/** Performs a specialized Tick method on this actor
	*   @param : DeltaSeconds The delta time for this tick.
	*/
	virtual void TickSpecial(FLOAT DeltaSeconds);

	/** Synchronizes this actor to all rigid body components **/
	virtual void SyncActorToRBPhysics();

	/*** Sets the physics on this actor
	* @param NewPhysics : Use PHYS_None for a static destructible, PHYS_RigidBody for a dynamic destructible.
	* @param NewFloor   : Not used.
	* @param NewFloorV  : Not used.
	*/
	virtual void setPhysics(BYTE NewPhysics, AActor *NewFloor, FVector NewFloorV);

	/** Process a property change event.
	*   @param PropertyThatChanged : The property value which changed
	*/
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/** Process an edit move event.
	*
	* @param : bFinished : True if the move is complete.
	*/
	virtual void PostEditMove(UBOOL bFinished);

	/** Notification of the post load event. */
	virtual void PostLoad();

	/** Loads the editor parameters from the asset */
	void LoadEditorParametersFromAsset();

	/** Update old actors. Only has an effect when called from the editor. */
	void FixupActor();

	/** Spawn fracture effects at the given location for the given fracture depth. */
	void SpawnFractureEffects(FVector& Location, INT Depth);
}

defaultproperties
{
	bEdShouldSnap=TRUE
	bCollideActors=TRUE
	bBlockActors=TRUE
	bProjTarget=TRUE
	bGameRelevant=TRUE
	bRouteBeginPlayEvenIfStatic=FALSE
	bCollideWhenPlacing=FALSE
	bStatic=FALSE
	bMovable=FALSE
	bNoDelete=TRUE
	bNoEncroachCheck=TRUE
	bWorldGeometry=FALSE

	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
		bEnabled=FALSE
	End Object
	Components.Add(LightEnvironment0)

	Begin Object Class=ApexStaticDestructibleComponent Name=DestructibleComponent0
		bAllowApproximateOcclusion=TRUE
		bCastDynamicShadow=FALSE
		bForceDirectLightMap=TRUE
		BlockRigidBody=TRUE
		bAcceptsDecals=FALSE
		LightEnvironment=LightEnvironment0
	End Object
	CollisionComponent=DestructibleComponent0
	StaticDestructibleComponent=DestructibleComponent0
	Components.Add(DestructibleComponent0)

//	Begin Object Class=ApexDynamicDestructibleComponent Name=DestructibleComponent1
//		bAllowApproximateOcclusion=TRUE
//		bCastDynamicShadow=FALSE
//		bForceDirectLightMap=TRUE
//		BlockRigidBody=TRUE
//		bAcceptsDecals=FALSE
//		LightEnvironment=LightEnvironment0
//	End Object
//	DynamicDestructibleComponent=DestructibleComponent1
//	Components.Add(DestructibleComponent1)
}
