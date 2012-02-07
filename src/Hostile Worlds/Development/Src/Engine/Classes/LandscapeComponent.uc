/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class LandscapeComponent extends PrimitiveComponent
	native(Terrain);

var const int						SectionBaseX,
									SectionBaseY,

									ComponentSizeQuads,		// Total number of quads for this component
									SubsectionSizeQuads,	// Number of quads for a subsection of the component. SubsectionSizeQuads+1 must be a power of two.
									NumSubsections;			// Number of subsections in X or Y axis

var MaterialInstanceConstant		MaterialInstance;

struct native LandscapeComponentAlphaInfo
{
	// The layer index matching the Landscape actor's LayerNames arrays.
	var private int LayerIndex;	

	// What is the resolution compared to the heightmap
	var private int ResolutionMultiplier;

	// Alpha values
	var private const array<byte> AlphaValues;

	structcpptext
	{
		// tor
		FLandscapeComponentAlphaInfo( ULandscapeComponent* InOwner, INT InLayerIndex, INT InResolutionMultiplier );
		UBOOL IsLayerAllZero() const;
	}
};

struct native WeightmapLayerAllocationInfo
{
	var Name LayerName;
	var byte WeightmapTextureIndex;
	var byte WeightmapTextureChannel;

	structcpptext
	{
		FWeightmapLayerAllocationInfo(FName InLayerName)
		:	LayerName(InLayerName)
		,	WeightmapTextureIndex(0)
		,	WeightmapTextureChannel(0)
		{}
	}
};

/** Alpha info for painting */
var private editoronly const array<LandscapeComponentAlphaInfo> AlphaInfos;

/** List of layers, and the weightmap and channel they are stored */
var private const array<WeightmapLayerAllocationInfo> WeightmapLayerAllocations;

/** Weightmap texture reference */
var private const array<Texture2D> WeightmapTextures;

/** UV offset to component's weightmap data from component local coordinates*/
var Vector4 WeightmapScaleBias;

/** U or V offset into the weightmap for the first subsection, in texture UV space */
var float WeightmapSubsectionOffset;

/** UV offset to Heightmap data from component local coordinates */
var Vector4 HeightmapScaleBias;

/** U or V offset into the heightmap for the first subsection, in texture UV space */
var float HeightmapSubsectionOffset;

/** UV offset for layer texturing to match adjacent components */
var Vector2D LayerUVPan;

/** Heightmap texture reference */
var private const Texture2D HeightmapTexture;

/** Cached bounds, created at heightmap update time */
var const BoxSphereBounds CachedBoxSphereBounds;

/**
 *	The resolution to cache lighting at, in texels/patch.
 *	A separate shadow-map is used for each terrain component, which is
 *	(SectionSizeQuads * StaticLightingResolution + 1) pixels on a side.
 */
var int StaticLightingResolution;

/** Unique ID for this component, used for caching during distributed lighting */
var private const editoronly Guid LightingGuid;

/** Array of shadow maps for this component. */
var private const array<ShadowMap2D> ShadowMaps;

/** Reference to the texture lightmap resource. */
var native private const LightMapRef LightMap;

enum ETerrainComponentNeighbors
{
	TCN_NW,
	TCN_N,
	TCN_NE,
	TCN_W,
	TCN_E,
	TCN_SW,
	TCN_S,
	TCN_SE,
};

/* Eight neigboring TerrainComponents, or NULL if none */
var editoronly const LandscapeComponent Neighbors[8];

cpptext
{
	// UObject interface
	virtual void Serialize(FArchive& Ar);

	// UPrimitiveComponent interface
	virtual FPrimitiveSceneProxy* CreateSceneProxy();
	virtual void GetUsedMaterials( TArray<UMaterialInterface*>& OutMaterials ) const;
	virtual void UpdateBounds();
	void SetParentToWorld(const FMatrix& ParentToWorld);
	void GetStaticLightingInfo(FStaticLightingPrimitiveInfo& OutPrimitiveInfo,const TArray<ULightComponent*>& InRelevantLights,const FLightingBuildOptions& Options);
	UBOOL GetLightMapResolution( INT& Width, INT& Height ) const;

	// UTerrainComponent Interface

	/** Return's the landscape actor associated with this component. */
	class ALandscape* GetLandscapeActor() const
	{
		return CastChecked<ALandscape>(GetOuter());
	}


	/** Initialize the landscape component */
	void Init(INT InBaseX,INT InBaseY,INT InComponentSizeQuads, INT InNumSubsections,INT InSubsectionSizeQuads);

	/**
	 * Update the MaterialInstance parameters to match the layer and weightmaps for this component
	 * Creates the MaterialInstance if it doesn't exist.
	 */
	void UpdateMaterialInstances();

	/**
	 * Recalculate cached bounds using height values.
	 */
	void UpdateCachedBounds();

	/**
	 * Generate mipmaps for height and tangent data.
	 * @param HeightmapTextureMipData array of pointers to the locked mip data.
	 */
	void GenerateHeightmapMips(TArray<FColor*>& HeightmapTextureMipData);

	/**
	 * Generate mipmaps for weightmap
	 * Assumes all weightmaps are unique to this component.
	 * @param WeightmapTextureBaseMipData: array of pointers to each of the weightmaps' base locked mip data.
	 */
	static void GenerateWeightmapMips(INT InNumSubsections, INT InSubsectionSizeQuads, UTexture2D* WeightmapTexture, FColor* BaseMipData);

	/**
	 * Creates a collision component
	 * @param CollisionMipLevel: mip level to use for collision component
	 * @HeightmapTextureMipData: heightmap data
	 */
	void CreateCollisionComponent(INT CollisionMipLevel, FColor* HeightmapTextureMipData);

	friend class FLandscapeComponentSceneProxy;
	friend struct FLandscapeComponentDataInterface;
}

defaultproperties
{
	CollideActors=TRUE
	BlockActors=TRUE
	BlockZeroExtent=TRUE
	BlockNonZeroExtent=TRUE
	BlockRigidBody=TRUE
	CastShadow=TRUE
	bAcceptsLights=TRUE
	bAcceptsDecals=TRUE
	bAcceptsStaticDecals=TRUE
	bUsePrecomputedShadows=TRUE
	bUseAsOccluder=TRUE
	bAllowCullDistanceVolume=FALSE
	StaticLightingResolution=1
}
