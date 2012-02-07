/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class FoliageFactory extends Volume
	native(Foliage)
	dependson(LightmassPrimitiveSettingsObject)
	placeable;

struct native FoliageMesh
{
	var() StaticMesh InstanceStaticMesh;
	var() MaterialInterface Material;
	
	var() float MaxDrawRadius;
	var() float MinTransitionRadius;
	var() float MinThinningRadius;

	var() vector MinScale;
	var() vector MaxScale;
	var() float MinUniformScale;
	var() float MaxUniformScale;

	var() float SwayScale;

	var() int Seed;

	var() float SurfaceAreaPerInstance;

	var() bool bCreateInstancesOnBSP;
	var() bool bCreateInstancesOnStaticMeshes;
	var() bool bCreateInstancesOnTerrain;
	
	var(Lightmass) LightmassPrimitiveSettings LightmassSettings <ScriptOrder=true>;

	var FoliageComponent Component;

	structdefaultproperties
	{
		MaxDrawRadius=2000
		MinThinningRadius=2000

		MinScale=(X=1,Y=1,Z=1)
		MaxScale=(X=1,Y=1,Z=1)
		MinUniformScale=1.0
		MaxUniformScale=1.0

		SwayScale=1.0

		SurfaceAreaPerInstance=1000

		bCreateInstancesOnBSP=TRUE
		bCreateInstancesOnStaticMeshes=TRUE
		bCreateInstancesOnTerrain=TRUE
		
		LightmassSettings=(EmissiveLightFalloffExponent=2.0f,EmissiveBoost=1.0,DiffuseBoost=1.0,SpecularBoost=1.0)
	}
};

var(Foliage) const array<FoliageMesh> Meshes;

/** The radius inside/outside the volume that the foliage density falls off over. */
var(Foliage) const float VolumeFalloffRadius;

/** The exponent of the density falloff. */
var(Foliage) const float VolumeFalloffExponent;

/** The density of foliage instances on upward facing surfaces. */
var(Foliage) const float SurfaceDensityUpFacing;

/** The density of foliage instances on downward facing surfaces. */
var(Foliage) const float SurfaceDensityDownFacing;

/** The density of foliage instances on sideways facing surfaces. */
var(Foliage) const float SurfaceDensitySideFacing;

/** The falloff exponent for facing dependent density. */
var(Foliage) const float FacingFalloffExponent;

/** The maximum number of foliage instances to create from this factory. */
var(Foliage) const int MaxInstanceCount;

cpptext
{
	/**
	 * Checks whether an instance should be spawned at a particular point on a surface for this foliage factory.
	 * @param Point - The world-space point on the surface.
	 * @param Normal - The surface normal at the point.
	 * @return TRUE if the instance should be created.
	 */
	virtual UBOOL ShouldCreateInstance(const FVector& Point,const FVector& Normal) const;
	
	/**
	 * Determines whether the foliage factory may spawn foliage on a specific primitive.
	 * @param Primitive - The primitive being considered.
	 * @return TRUE if the foliage factory may spawn foliage on the primitive.
	 */
	virtual UBOOL IsPrimitiveRelevant(const UPrimitiveComponent* Primitive) const;

	/** Regenerates the foliage instances for the actor. */
	void RegenerateFoliageInstances();

	// AActor interface.
	virtual void PostEditMove(UBOOL bFinished);

	// UObject interface.
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void PostLoad();
}

defaultproperties
{
	bStatic=TRUE
	bMovable=FALSE
	bHidden=FALSE

	VolumeFalloffExponent=1.0
	
	Begin Object Name=BrushComponent0
		CollideActors=False
		BlockActors=False
		BlockZeroExtent=False
		BlockNonZeroExtent=False
		BlockRigidBody=False
	End Object
	
	SurfaceDensityUpFacing=1.0
	SurfaceDensityDownFacing=1.0
	SurfaceDensitySideFacing=1.0
	FacingFalloffExponent=2.0
	
	MaxInstanceCount=10000
}