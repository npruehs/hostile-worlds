/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class FoliageComponent extends PrimitiveComponent
	dependson(LightmassPrimitiveSettingsObject)
	native(Foliage);

/** Information about an instance of the component's foliage mesh that is common to all foliage instance types. */
struct native FoliageInstanceBase
{
	/** The instance's world-space location. */
	var Vector Location;
	
	/** The instance's X Axis. */
	var Vector XAxis;
	
	/** The instance's Y Axis. */
	var Vector YAxis;
	
	/** The instance's Z Axis. */
	var Vector ZAxis;

	/** The instance's distance factor, squared. */
	var float DistanceFactorSquared;
};

/** The information for each instance that is gathered during lighting and saved. */
struct native StoredFoliageInstance extends FoliageInstanceBase
{
	/** 
	* The static lighting received by the instance. The number of coefficients corresponds to NUM_STORED_LIGHTMAP_COEF in native.
	*/
	var Color StaticLighting[3];
};

/** The component's foliage instances. */
var const array<StoredFoliageInstance> LitInstances;

/** The lights included in the foliage's static lighting. */
var const array<guid> StaticallyRelevantLights;

/** The statically irrelevant lights for all the component's foliage instances. */
var const array<guid> StaticallyIrrelevantLights;

/** The scale factors applied to the directional static lighting. */
var const float DirectionalStaticLightingScale[3];

/** The scale factors applied to the simple static lighting. */
var const float SimpleStaticLightingScale[3];

/** The mesh which is drawn for each foliage instance. */
var const StaticMesh InstanceStaticMesh;

/** The material applied to the foliage instance mesh. */
var const MaterialInterface Material;

/** The maximum distance to draw foliage instances at. */
var float MaxDrawRadius;

/** The minimum distance to start scaling foliage instances away at. */
var float MinTransitionRadius;

/** The minimum distance to start thinning foliage instances at. */
var float MinThinningRadius;

/** The minimum scale to draw foliage instances at. */
var vector MinScale;

/** The minimum scale to draw foliage instances at. */
var vector MaxScale;

/** A scale for the effect of wind on the foliage mesh. */
var float SwayScale;

/** The Lightmass settings for this object. */
var LightmassPrimitiveSettings	LightmassSettings <ScriptOrder=true>;

cpptext
{
	// UPrimitiveComponent interface.
	virtual void UpdateBounds();
	virtual FPrimitiveSceneProxy* CreateSceneProxy();
	virtual void GetStaticLightingInfo(FStaticLightingPrimitiveInfo& OutPrimitiveInfo,const TArray<ULightComponent*>& InRelevantLights,const FLightingBuildOptions& Options);

	/** 
	 * Retrieves the materials used in this component 
	 * 
	 * @param OutMaterials	The list of used materials.
	 */
	virtual void GetUsedMaterials( TArray<UMaterialInterface*>& OutMaterials ) const;

	/**
	 *	Requests whether the component will use texture, vertex or no lightmaps.
	 *
	 *	@return	ELightMapInteractionType		The type of lightmap interaction the component will use.
	 */
	virtual ELightMapInteractionType GetStaticLightingType() const	{ return LMIT_Vertex;	}
	/** Gets the emissive boost for the primitive component. */
	virtual FLOAT GetEmissiveBoost(INT ElementIndex) const;
	/** Gets the diffuse boost for the primitive component. */
	virtual FLOAT GetDiffuseBoost(INT ElementIndex) const;
	/** Gets the specular boost for the primitive component. */
	virtual FLOAT GetSpecularBoost(INT ElementIndex) const;
	virtual void InvalidateLightingCache();
	
	virtual UMaterialInterface* GetMaterial() const;
}

defaultproperties
{
	bAcceptsLights=TRUE
	bUsePrecomputedShadows=TRUE
	bForceDirectLightMap=TRUE
}
