/*=============================================================================
	PhysXDestructibleStructure.uc: Destructible Vertical Component.
	Copyright 2007-2008 AGEIA Technologies.
=============================================================================*/

class PhysXDestructibleStructure extends Object
	native(Mesh);

enum EPhysXDestructibleChunkState
{
	DCS_StaticRoot,
	DCS_StaticChild,
	DCS_DynamicRoot,
	DCS_DynamicChild,
	DCS_Hidden,
};

struct native PhysXDestructibleChunk
{
	/* Flag indicating if the world space location is valid. */
	var bool							WorldCentroidValid;

	/* Flag indicating if the world space transformation matrix is valid. */
	var bool							WorldMatrixValid;

	/* Flag which tells fracture algorithm to crumble the chunk */
	var bool							bCrumble;

	/* Whether this chunk is initially fixed in the world environment */
	var bool							IsEnvironmentSupported;

	/* Helper flag for the current route update algorithm*/
	var bool							IsRouting;

	/* flag to indicate whether ShortestRoute is ready or not*/
	var bool							IsRouteValid;

	/* flag to indicate it will not support other chunk in the update route area,
	   before route update, its IsRouteValid is still true even it is a Route Blocker*/
	var bool							IsRouteBlocker;

	/* Index of the owning PhysXDestructibleActor in the Actors array. */
	var int								ActorIndex;

	/* Fragment index within the owning PhysXDestructibleActor. */
	var int								FragmentIndex;

	/* Index of this Chunk in the Chunks array. */
	var int								Index;

	/* Index of the owning mesh in the SkeletalMeshComponents array. */
	var int								MeshIndex;

	/* Index of the bone representing this chunk. */
	var int								BoneIndex;

	/* Name of the bone representing this chunk. */
	var name							BoneName;

	/* Index of the body representing this chunk. */
	var int								BodyIndex;

	/* Parent relative location */
	var vector							RelativeCentroid;

	/* World space location. (Lazy evaluated!) */
	var vector							WorldCentroid;

	/* Parent relative matrix. */
	var matrix							RelativeMatrix;

	/* World space transformation matrix. (Lazy evaluated!) */
	var matrix							WorldMatrix;

	/* Approximate radius of this chunk */
	var	float							Radius;

	/* Index of parent chunk in the Chunks array. INDEX_NONE for root chunk(s). */
	var int								ParentIndex;

	/* Index of the first child Chunks array. INDEX_NONE for leaf chunk(s). */
	var int								FirstChildIndex;

	/* Number of children. */
	var int								NumChildren;

	/* Depth in the chunk hierarchy. Root is at 0 */
	var int								Depth;

	/* Time in seconds the Chunk has been active. */
	var float							Age;

	/* Accumulated damage. */
	var float							Damage;

	/* Measure of the chunk's linear size. */
	var float							Size;

	/* Current state. */
	var EPhysXDestructibleChunkState	CurrentState;

	/* Backpointer */
	var native pointer					Structure{class UPhysXDestructibleStructure};

	/* Linked list entry in FIFO */
	var native int						FIFOIndex;

	/* First Overlap index in the Structure */
	var int								FirstOverlapIndex;

	/* Number of Overlaps */
	var int								NumOverlaps;

	/* the smallest possible( for the amortize algorithm, not optimal) number of chain connected leaf chunks between this and any Environment-Supported chunk.
	   if IsEnvironmentSupported, it is 0*/
	var int								ShortestRoute;

	/* if IsEnvironmentSupported, it is 0.
	   if IsPseudoSupported, it is 0.
	   Otherwise, it is the number of neighbours whose ShortestRoute is one less than this*/
	var int								NumSupporters;

	/* Equal to NumChildren before it helps the algorithm to decide the biggest
	   possible chunk to shed */
	var int								NumChildrenDup;
};

struct native PhysXDestructibleOverlap
{
	var int	ChunkIndex0;
	var int ChunkIndex1;
	var int Adjacent;
};

/** The "parent" manager */
var native pointer										Manager{class FPhysXDestructibleManager};

/** The actors within this structure.  They form an island. */
var	native transient	array<PhysXDestructibleActor>	Actors;

/** For delayed killing */
var	native transient	array<PhysXDestructibleActor>	ActorKillList;

/** The chunks from all of the actors in this structure. */
var	native transient	array<PhysXDestructibleChunk>	Chunks;

/** Neighbor info for chunks at SupportDepth. */
var	native transient	array<PhysXDestructibleOverlap>	Overlaps;

/** List of active chunks */
var native transient	array<int>						Active;

/** Support algorithm */
var	native transient	array<int>						PseudoSupporterFifo;
var native transient	int								PseudoSupporterFifoStart;
var native transient	array<int>						FractureOriginFifo;//No chunk will be user fractured twice, so the maximum length is Chunks.Num()
var native transient	int								FractureOriginFifoStart;
var native transient	array<int>						FractureOriginChunks;
var native transient	array<int>						RouteUpdateArea;
var native transient	const int						PerFrameProcessBudget;
var native transient	array<int>						PassiveFractureChunks;
var native transient	array<int>						RouteUpdateFifo;
var native transient	int								RouteUpdateFifoStart;
var native transient	int								SupportDepth;

cpptext
{
	/** Update actors within structure, and state of "active" (dynamic) chunks */
	void TickStructure( FLOAT DeltaTime );
	
	/** Apply damage directly to a chunk.  Damage is propagated to other nearby chunks within the structure */
	UBOOL ApplyDamage( INT FirstChunkIndex, INT NumChunks, FLOAT BaseDamage, FLOAT DamageRadius, FLOAT Momentum, FVector HurtOrigin, UBOOL bInheritRootVel, UBOOL bFullDamage, FLOAT DamageFalloffExponent );
	
#if WITH_NOVODEX
	/** Return the physical actor for a chunk */
	NxActor* GetChunkNxActor( INT ChunkIndex );
#endif

	/** Return the skeletal mesh component that a chunk lies in */
	USkeletalMeshComponent* GetChunkMesh( int ChunkIndex );
	
	/** Shows the mesh and initializes the RB associated with a chunk.  If InitTM != NULL, uses InitTM for the mesh */
	void ShowChunk( INT ChunkIndex, UBOOL bFixed, FMatrix * InitTM = NULL );
	
	/** Hides the mesh and destroys the RB associated with a chunk.  If bRecurse is true, hides all child chunks as well */
	void HideChunk( INT ChunkIndex, UBOOL bRecurse = TRUE );
	
	/** Mark dirty state of chunk */
	void MarkMoved( int ChunkIndex );
	
	/** Changes state of chunk and all children to dynamic */
	void SwitchToDynamic( INT ChunkIndex );
	
	/** Support algorithm */
	void PropagateFracture();
	void AppendFractureOriginFifo(INT ChunkIndex);
	void ExtendRerouteAreaFromPseudoSupporter(TArray<INT>& Area, INT Limit);
	void ExtendRerouteAreaFromFractureOrigin(TArray<INT>& Area, INT Limit);
	void RerouteArea(TArray<INT>& Area);
	void SupportDepthPassiveFracture(INT ChunkIndex);
	
	/** Remove actor from this structure.  Call this instead of destroying the actor directly. */
	UBOOL RemoveActor( APhysXDestructibleActor * Actor );
}

/** Propagate damage calculation to chunk and all children.  Returns an array of chunks that should be broken free */
native function	bool	DamageChunk					( int ChunkIndex, vector Point, float BaseDamage, float Radius, bool bFullDamage, float DamageFalloffExp, out array<int> Output );

/** Break chunk free, and make it dynamic */
native function			FractureChunk				( int ChunkIndex, vector point, vector impulse, bool bInheritRootVel );

/** Destroy chunk and initiate fluid emitter volume filling */
native function			CrumbleChunk				( int ChunkIndex );

/** Return world matrix associated with chunk */
native function matrix	GetChunkMatrix				( int ChunkIndex );

/** Return world centroid of chunk */
native function vector	GetChunkCentroid			( int ChunkIndex );

defaultproperties
{
}
