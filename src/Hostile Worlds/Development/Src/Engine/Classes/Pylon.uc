//=============================================================================
// Pylon
//
// Used to determine the start location for exploration/creation of a NavMesh
//
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class Pylon extends NavigationPoint
	hidecategories(Lighting,LightColor,Force)
	implements(EditorLinkSelectionInterface)
	placeable
	native;

enum ENavMeshEdgeType
{
	NAVEDGE_Normal,
	NAVEDGE_Mantle,
	NAVEDGE_Coverslip,
	NAVEDGE_SwatTurn,
	NAVEDGE_DropDown,
	NAVEDGE_PathObject,
	NAVEDGE_BackRefDummy,
	NAVEDGE_Jump,
};

cpptext
{
	typedef TDoubleLinkedList<struct FNavMeshPolyBase*> WSType;
	typedef TDoubleLinkedList<class IInterface_NavMeshPathObject*> PathObjectList;

	// overidden ensure we're not in the pylon octree when we are deleted
	virtual void BeginDestroy();

	// removes this pylon from the global pylon octree
	void RemoveFromPylonOctree();

	FORCEINLINE class UNavigationMeshBase* GetNavMesh()
	{
		return NavMeshPtr;
	}

	UBOOL Explore_SeedWorkingSet( AScout* Scout, FVector& SeedLocation );
	UBOOL Explore_CreateGraph( AScout* Scout, FVector& SeedLocation );
	UBOOL DoesCoverSlotAffectMesh(const struct FCoverInfo& Slot);
	void GatherCoverReferences( AScout* Scout, TArray<struct FCoverInfo>& out_MeshAffectors );
	virtual void CreateExtraMeshData( AScout* Scout );

	void CreateMantleEdges( AScout* Scout );
	void CreateCoverSlipEdges( AScout* Scout );

	void ConvertStaticMeshToNavMesh( UStaticMesh* StaticMesh, FMatrix& ScaledLocalToWorld );
	void AddStaticMeshesToPylon( TArray<class AStaticMeshActor*>& SMActors );

	virtual void Serialize(FArchive& Ar);
	virtual void PostLoad();
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void PostEditMove(UBOOL bFinished);

	virtual UBOOL CanConnectTo(ANavigationPoint* Nav, UBOOL bCheckDistance)
	{
		return FALSE;
	}
	
	// overidden to clear navmesh data
	virtual void ClearPaths(); 

	// clears out navmesh specific pathdata
	virtual void ClearNavMeshPathData();

	// ***** mesh generation functionality follows ****
	
	// structure to store diagonal expansion points for post-expansion
	struct FDiagTest 
	{
		FDiagTest(FVector inParentPos, FVector inPos)
		{
			ParentPos=inParentPos;
			Pos=inPos;
		}
		FVector ParentPos;
		FVector Pos;
	};

	// used when importing a mesh.  vertex color of red indicates obstacle geometry
	virtual UBOOL IsObstacleColor(FColor& VertColor);

	/**
	 * 
	 * will walk out in 8 directions from the passed node trying to add geometry to the mesh from each direction
	 * diags are points that should be tested later for expansion.  This is done to give cardinal directions priority, keeping
	 * non-diagonal and non-subdivided polys a priority
	 * @param ParentPoly - poly we are trying to expand from
	 * @param Scout      - Scout to use for tests/params
	 * @param Diags		 - diagonal expansions to test after cardinal expansions are tried
	 */
	void ExpandCurrentNode(FNavMeshPolyBase* ParentPoly, AScout* Scout, TArray<FDiagTest>& Diags);

	/**
	 * tries to find ground position below passed location and calls AddNewNode if there is nothing in the way of expansion, and the ground isn't too steep/etc..
	 * 
	 * @param NewNodeTestLocation		  - location to try and add a new node 
	 * @param CurrNodePosWithHeightOffset - predecessor node's position (offset from ground with height offset)
	 * @param CUrrNodePos				  - predecessor node's position without height offset
	 * @param Hit						  - output struct indicating values associated with the ground hit
	 * @param Scout						  - Scout to use for tests
	 * @param out_bIvalidSpot			  - out var indicating this spot was invalid due to out of bounds/something else
	 * @param SubdivisionIteration        - the current subdivision iteration
	 * @param bDiag						  - are we checking ground positiopn for a diagonal expansion
	 * @param ParentPoly				  - optional predecessor polygon we're expanding from
	 * @return - the new poly added if any
	 */
	struct FNavMeshPolyBase* ConditionalAddNodeHere(const FVector& NewNodeTestLocation,
		const FVector& CurrNodePosWithHeightOffset,
		const FVector& CurrNodePos,
		FCheckResult& Hit,
		AScout* Scout, 
		UBOOL& out_bInvalidSpot,
		INT SubdivisionIteration=0,
		UBOOL bDiag=FALSE,
		FNavMeshPolyBase* ParentPoly=NULL);

	/**
	 * will add a square poly to the mesh at the passed location unless it's already in the mesh
	 * @param NewLocation - location of new node
	 * @param HitNormal - normal of the hit which we're adding a node for
	 * @param out_bInvalidSpot - OPTIONAL out param indicating whether we couldn't add a node here due to it being out of bounds
	 * @param SubdivisionIteration - OPTIONAL param indicating what subdivision iteration we're adding for
	 * @return - the new poly we just added (NULL if not succesful)
	 */
	struct FNavMeshPolyBase* AddNewNode(const FVector& NewLocation, const FVector& HitNormal, UBOOL* out_bInvalidSpot=NULL, INT SubdivisionIteration=0);

	/**
	 * keeps track of edges which we could drop down but not climb up for later addition to the mesh
	 * 
	 * @param NewLocation - destination location of dropdown 
	 * @param OldLocation - source location of dropdown
	 * @param HitNormal   - normal of the ground hit causing this dropdown
	 * @param ParentPoly  - parent poly we're expending from 
	 * @param SubdivisionIteration - current subdivision iteration 
	 */
	void SavePossibleDropDownEdge(const FVector& NewLocation, const FVector& OldLocation, const FVector& HitNormal, FNavMeshPolyBase* ParentPoly, UBOOL bSkipPullBack);


	/**
	 * when zdelta is greater than step size, but less than the height change due to allowable slopes,
	 * this function is called ot do extra verification (to determine if it is just a slope, or if there is a big step)
	 * 
	 * @param Scout - scout to use for tests/params
	 * @param NewNodePos - new position of node we need to test step for 
	 * @param CurrNodePosWithHeightOffset - predecessor node's current position (with height offset from ground0
	 * @param StepSize - current step size (size of polys being added right now)
	 * @param out_ZDelta - out value of any ZDelta found
	 * @param ParentPoly - the parent (predecessor) Poly we're veryfing a step from
	 * @return - TRUE If step is valid
	 */
	UBOOL VerifySlopeStep(AScout* Scout,
		const FVector& NewNodePos,
		const FVector& CurrNodePosWithHeightOffset,
		FLOAT StepSize,
		FLOAT& out_ZDelta,
		FNavMeshPolyBase* ParentPoly);

	INT SubdivideExpandInternal( struct FNavMeshPolyBase* ParentPoly, 
		const FVector& NewNodeTestLocation,
		const FVector& CurrNodePosWithHeightOffset,
		const FVector& CurrNodePos,
		FCheckResult& Hit,
		AScout* Scout, 
		TArray<FNavMeshPolyBase*>& AddedPolys,
		UBOOL bDiag,
		INT SubdivisionIteration=0);

	struct FNavMeshPolyBase* SubdivideExpand( struct FNavMeshPolyBase* ParentPoly, 
		const FVector& NewNodeTestLocation,
		const FVector& CurrNodePosWithHeightOffset,
		const FVector& CurrNodePos,
		FCheckResult& Hit,
		AScout* Scout,
		UBOOL bDiag);

	// ** mesh generation stage functions **
	
	// intial raycast soup to discover topology of geo
	UBOOL NavMeshPass_InitialExploration();
	
	// second pass raycast soup expansion to expand from auxiliary seedpoints
	UBOOL NavMeshPass_ExpandSeeds();
	
	// fill in stairstep corner with triangles where possible
	UBOOL NavMeshPass_BackfillCorners();
	
	// remove uneccesary polys, by merging together polys that can be merged
	UBOOL NavMeshPass_SimplifyMesh();

	// split generated meshes around boundaries with imported meshes for good edge lineup
	UBOOL NavMeshPass_SplitForImportedMeshes();

	// split mesh around path objects that need splitting
	UBOOL NavMeshPass_SplitMeshAboutPathObjects();

	// convert mesh into serializable structures, and do final cleanup for save
	UBOOL NavMeshPass_FixupForSaving();

	// build edge connections between adjacent polys
	UBOOL NavMeshPass_CreateEdgeConnections();

	// build mesh that describes the boundaries or obstacles of the mesh
	UBOOL NavMeshPass_BuildObstacleMesh();

	// build pylon to pylon reachspecs representing a super graph for quick "is this pylon connected to that one" checks
	UBOOL NavMeshPass_BuildPylonToPylonReachSpecs();


	// returns a bounding box for our expansion bounds (used when adding this pylon to the octree)
	FBox GetExpansionBounds();

	/**
	 * returns bounding box for this pylon's mesh
	 * @param bWorldSpace - ref frame the box should be in
	 */
	FBox GetBounds(UBOOL bWorldSpace);

	/**
	 * returns FALSE if the passed point is not within our expansion constraints
	 * @param Pt - the point to test against expansion bounds
	 * @param Buffer - used only when expansion bounds are spherical.. adds extra size to bounds to account for slight discrepancies 
	 */
	virtual UBOOL   IsPtWithinExpansionBounds(const FVector& Pt,FLOAT Buffer=0.f);

	/**
	 * this function will slide a box downward from a raised position until a position which is non-colliding, then multiple raycasts downward
	 * will be performed to ascertain the topology of the ground underneath the ground check.  This gives us a valid position for the ground at a given 
	 * expansion point, as well as valid normal data for the extent being swept downward
	 * @param TestBasePos - position to start testing from
	 * @param Result      - hit result describing information about the ground position found
	 * @param Scout       - scout instance to be used during this ground check
	 * @param SubdivisionIteration - the number of times to default stepsize has been subdivided for the current callchain
	 * @param out_bNeedsSlopeCheck - if a large gap is found while performing the second stage ground check, this will be turned on
	 *                               indicating a call to 'VerifySlopeStep' is necessary
	 * @return - TRUE if a valid ground posiiton was found
	 */
	virtual UBOOL FindGround(const FVector& TestBasePos, FCheckResult& Result,AScout* Scout, INT SubdivisionIteration=0, UBOOL* out_bNeedsSlopeCheck=NULL);

	// will find a position which is on the stepsize grid to start expanding from (snapped to grid so exploration from multiple pylons lines up)
	FVector SnapSeedLocation( AScout* Scout, FVector& Loc );

	/**
	 * will sweep up from ground position and find the maximum supporting height of a new poly
	 * 
	 * @param TestBasePos - base position of node to test ceiling height for
	 * @param Result	  - resulting hit 
	 * @param Scout		  - scout to use for params/tests
	 * @param Up		  - upward direction for this poly
	 * @param Extent	  - extent to use for linechecks
	 * @return - location of ceiling found
	 */
	virtual FVector FindCeiling(const FVector& TestBasePos, FCheckResult& Result,AScout* Scout, const FVector& Up, const FVector& Extent);

	// returns the 'upward' direction that should be used for this poly
	virtual FVector Up(FNavMeshPolyBase* Poly);

	/**
	 * returns whether or not this pylon should be built right now.. if FALSE this pylon will not rebuilt during this navmesh generation pass
	 * @param bOnlyBuildSelected - the value of 'only build selected' coming from the editor
	 * @return - TRUE if this pylon should be wiped and rebuilt
	 */
	virtual UBOOL ShouldBuildThisPylon(UBOOL bOnlyBuildSelected);
	// *************************** End Mesh Generation shiznaz *************************/


	// add and removal functionality for pylon nav octree
	virtual void AddToNavigationOctree();
	virtual void RemoveFromNavigationOctree();

	/**
	 * Queries the poly octree and fills in the passed array with a list of all the polys that intersect the passed in AABB
	 * @param Loc - center of extent to check
	 * @param Extent - extent of box to check
	 * @param out_Polys - output array of polys 
	 * @param bIgnoreDynamic - whether to ignore dynamically added submeshes or not
	 * @param bReturnBothDynamicAndStatic - if TRUE, BOTH dynamic and static polys will be returned.. using this is *DANGEROUS*! most of the time you should use dynamic polys if they exist
	 *                                      as they are the 'correct' representation of the mesh at that point
	 */
	void GetIntersectingPolys(const FVector& Loc, const FVector& Extent, TArray<FNavMeshPolyBase*>& out_Polys, UBOOL bIgnoreDynamic, UBOOL bReturnBothDynamicAndStatic=FALSE);

	/**
	*	Do anything needed to clear out cross level references; Called from ULevel::PreSave
	*/
	virtual void ClearCrossLevelReferences();

	/**
	* Called when a level is loaded/unloaded, to get a list of all the crosslevel
	* paths that need to be fixed up.
	*/
	virtual void GetActorReferences(TArray<FActorReference*> &ActorRefs, UBOOL bIsRemovingLevel);

	/**
	* Callback used to allow object register its direct object references that are not already covered by
	* the token stream.
	*
	* @param ObjectArray	array to add referenced objects to via AddReferencedObject
	* - this is here to keep the navmesh from being GC'd at runtime
	*/
	virtual void AddReferencedObjects( TArray<UObject*>& ObjectArray );

	/**
	* returns the center of the expansion bounding sphere 
	*/
	FVector GetExpansionSphereCenter() const
	{
		return (bUseExpansionSphereOverride) ? ExpansionSphereCenter : Location;
	}

	void UpdateComponentsInternal(UBOOL bCollisionUpdate);

	/**
	 * Called from UpdateComponentsInternal when a transform update is needed (when this pylon has moved)
	 */
	virtual void PylonMoved();

	/**
	 * indicates whether static cross-pylon edges should be built for this pylon (pylons that move should return false)
	 */
	virtual UBOOL NeedsStaticCrossPylonEdgesBuilt(){ return TRUE; } 

	// indicates whether this pylon is valid to be used
	FORCEINLINE UBOOL IsValid() { return NavMeshPtr != NULL && !bDisabled; }

	////// EditorLinkSelectionInterface
	virtual void LinkSelection(USelection* SelectedActors);

	// overidden to set 'paths need to be rebuilt' warning 
	virtual void PostBeginPlay();
	
	// overidden to throw warnign when pylon is not within its own bounds
	// and throw warnings when pathdata is too out of date
	virtual void CheckForErrors();

	/**
	 * verifies that this pylon is not in conflict with other pylons (e.g. both their start locations are with each other's bounds)
	 * @param out_ConflictingPylons - (optional) list of pylons this pylon is in conflict with (optional)
	 * @return - TRUE if this pylon is not in conflict
	 */
	UBOOL CheckBoundsValidityWithOtherPylons(TArray<APylon*>* out_ConflictingPylons=NULL);


	/**
	 * returns TRUE if this pylon modified the cost of the edge
	 * @param Interface - the interface we're generating a cost for
	 * @param PreviousPoint - the previous point in the path we're pathing from
	 * @param out_PathEdgePoint - the point on the edge we're moving to
	 * @param Edge - the edge we're considering
	 * @param SourcePoly - the poly previous in the current path search
	 * @param out_Cost - the output cost for the edge
	 * @return - TRUE if we modified the cost
	 * NOTE: this function is only called when bNeedsCostCheck is TRUE
	 */ 
	virtual UBOOL CostFor(const struct FNavMeshPathParams& PathParams,
						 const FVector& PreviousPoint,
						 FVector& out_PathEdgePoint,
						 struct FNavMeshEdgeBase* Edge,
						 struct FNavMeshPolyBase* SourcePoly,
						 INT& out_Cost);


	/**
	 * this function returns the local to world matrix transform that should be used for navmeshes associated with this
	 * pylon 
	 */
	virtual FMatrix GetMeshLocalToWorld();

	/**
	 * this function returns the world to local matrix transform that should be used for navmeshes associated with this
	 * pylon 
	 */
	virtual FMatrix GetMeshWorldToLocal();

	// determines if this should be validated and based on objects below it
	UBOOL ShouldBeBased();

	/** Checks to make sure the navigation is at a valid point */
	virtual void Validate();

	virtual void HandleFailedAddNode( AScout* Scout, const FVector& StartPos, const FVector& EndPos ) {}
};

/** Navigation mesh created for this pylon */
var const native pointer NavMeshPtr{class UNavigationMeshBase};
/** Obstacle mesh used for "can-go" raycasts */
var const native pointer ObstacleMesh{class UNavigationMeshBase};
/** Obstacle mesh used for "can-go" raycasts - built from dynamic obstacles! */
var const native pointer DynamicObstacleMesh{class UNavigationMeshBase};

/** Working set ptr - used internally for building nav mesh */
var const native transient pointer WorkingSetPtr{TDoubleLinkedList<struct FNavMeshPolyBase*>};
/** internally used list of pathobjects which affect this pylon's mesh.  Used only at navmesh generation time*/
var const native transient private pointer PathObjectsThatAffectThisPylon { TDoubleLinkedList<class IInterface_NavMeshPathObject*> };
/** Seed points created by last round of cover info */
var const transient array<Vector>	NextPassSeedList;

/** ID member var for octree functionality */
var	const native OctreeElementId	OctreeId{FOctreeElementId};

/** pointer to the octree this pylon was added to (so we can tell when the octree changes */
var const native Pointer OctreeIWasAddedTo{void};

/** Next pylon in the linked list */
var const Pylon NextPylon;

/** A list of volumes within which is valid to explore Note this trumps expansion radius */
var(MeshGeneration) array<Volume> ExpansionVolumes;

/** radius within which expansion will be allowed.  Note if this pylon has an expansion volume linked to it, this parameter has no effect*/
var(MeshGeneration) float ExpansionRadius;
/** Used to prevent exploration from wrapping past the 65536 available indices in a WORD */
var	  const float MaxExpansionRadius;

var DrawPylonRadiusComponent PylonRadiusPreview;

/** Indicates if this pylon is associated with an imported mesh */
var bool bImportedMesh;

/** when TRUE, center of sphere used for expansion bounds will be ExpansionSphereCenter rather than this.location*/
var bool bUseExpansionSphereOverride;
var vector ExpansionSphereCenter;

/** indicates that this pylon's CostFor function needs to be called when considering edges owned by it
    False by default in order to avoid unnecessary vfunc calls*/
var bool bNeedsCostCheck;

/** pointer to this pylon's rendering component */
var NavMeshRenderingComponent RenderingComp;

/** sprite comp to be used when this pylon is broken somehow */
var const transient SpriteComponent BrokenSprite;


//debug
var(Debug) int DebugEdgeCount;
var(Debug) bool bDrawEdgePolys;
var(Debug) bool bDrawPolyBounds;
var(Display) bool bRenderInShowPaths;
var(Display) bool bDrawWalkableSurface;
var(Display) bool bDrawObstacleSurface;

struct immutablewhencooked native PolyReference
{
	var ActorReference OwningPylon;
	// Poly ID that indexes into the navmesh poly array
	// NOTE: this has two WORDs shoved into it, lowest 2 bytes are Top level poly ID, highest 2 bytes are sub-poly ID
	var private {private} INT PolyId;


	structcpptext
	{
		FPolyReference()
		{
			SetPolyId(MAXWORD,MAXWORD);
		}
		FPolyReference(EEventParm)
		{
			appMemzero(this, sizeof(FPolyReference));
		}

		explicit FPolyReference(AActor* Pylon, INT InPolyId)
		{
			OwningPylon = FActorReference(Pylon,*Pylon->GetGuid());
			SetPolyId(InPolyId,MAXWORD);
		}

		explicit FPolyReference(struct FNavMeshPolyBase* InPoly);

		// overload various operators to make the reference struct as transparent as possible
		struct FNavMeshPolyBase* operator*();

		/**
		 * this will dereference the poly and return a pointer to it
		 * @param bEvenIfPylonDisabled - pass TRUE to this if you want the poly even if its pylon is bDisabled
		 * @return the poly assoicated with this poly ref
		 */
		struct FNavMeshPolyBase* GetPoly(UBOOL bEvenIfPylonDisabled=FALSE);

		FORCEINLINE struct FNavMeshPolyBase* operator->()
		{
			return *(*this);
		}
		FPolyReference* operator=(FNavMeshPolyBase* Poly);
		FORCEINLINE UBOOL operator==(const FPolyReference &Ref) const
		{
			return ((Ref.OwningPylon == OwningPylon) && Ref.GetTopLevelPolyId() == GetTopLevelPolyId() && Ref.GetSubPolyId() == GetSubPolyId());
		}
		FORCEINLINE UBOOL operator!=(const FPolyReference &Ref) const
		{
			return ((Ref.OwningPylon != OwningPylon) || Ref.GetTopLevelPolyId() != GetTopLevelPolyId() || Ref.GetSubPolyId() != GetSubPolyId());
		}

		operator UBOOL();
		UBOOL operator!();

		FORCEINLINE void Clear()
		{
			OwningPylon.Actor = NULL;
			OwningPylon.Guid  = FGuid(0,0,0,0);
			SetPolyId(MAXWORD,MAXWORD);
		}

		class APylon* Pylon();

		friend FArchive& operator<<( FArchive& Ar, FPolyReference& T );

		FORCEINLINE WORD GetTopLevelPolyId() const { return PolyId&65535; }
		FORCEINLINE WORD GetSubPolyId() const { return PolyId>>16; }
		FORCEINLINE void SetPolyId(WORD NewTopLevelPolyId, WORD NewSubPolyId) 
		{
			PolyId = NewTopLevelPolyId | (NewSubPolyId<<16); 
		}


	}
};

/** when FALSE this pylon's navmesh will not be cleared, nor built during 'build paths' -- useful for building subsets of the map at once*/
var transient bool bBuildThisPylon;

// when TRUE, this pylon and its mesh are considered invalid (same as unloaded)
var bool bDisabled;

// when TRUE, obstacle mesh polys will collide even if they have Cross Pylon edges which are loaded
var bool bForceObstacleMeshCollision;

event SetEnabled(bool bEnabled)
{
	bDisabled = !bEnabled;
	bForceObstacleMeshCollision = bDisabled;
}

event bool IsEnabled()
{
	return !bDisabled;
}

function OnToggle(SeqAct_Toggle action)
{
	if (action.InputLinks[0].bHasImpulse)
	{
		// turn on
		SetEnabled(true);
	}
	else if (action.InputLinks[1].bHasImpulse)
	{
		// turn off
		SetEnabled(false);
	}
	else if (action.InputLinks[2].bHasImpulse)
	{
		// toggle
		SetEnabled(!IsEnabled());
	}

}

native function bool CanReachPylon( Pylon DestPylon, Controller C );

defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'EditorResources.Pylon'
		HiddenGame=TRUE
		HiddenEditor=FALSE
		AlwaysLoadOnClient=FALSE
		AlwaysLoadOnServer=FALSE
	End Object

	bStatic=TRUE
	bNoDelete=TRUE
	bHidden=FALSE
	bCollideActors=FALSE

	Begin Object Class=NavMeshRenderingComponent Name=NavMeshRenderer
	End Object
	Components.Add(NavMeshRenderer)
	RenderingComp=NavMeshRenderer

	Begin Object Class=DrawPylonRadiusComponent Name=DrawPylonRadius0
	End Object
	Components.Add(DrawPylonRadius0)
	PylonRadiusPreview=DrawPylonRadius0

	//debug
	DebugEdgeCount=-1

	ExpansionRadius=2048
	MaxExpansionRadius=7168

	bDestinationOnly=TRUE
	bRenderInShowPaths=TRUE
	bDrawWalkableSurface=TRUE
	bDrawObstacleSurface=TRUE


	Begin Object Class=SpriteComponent Name=Sprite3
		Sprite=Texture2D'EditorResources.BadPylon'
		HiddenGame=true
		HiddenEditor=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		//Scale=0.25
	End Object
	Components.Add(Sprite3)
	BrokenSprite=Sprite3
}
