/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class TerrainMaterial extends Object
	native(Terrain)
	hidecategories(Object);

var matrix					LocalToMapping;

enum ETerrainMappingType
{
	TMT_Auto,
	TMT_XY,
	TMT_XZ,
	TMT_YZ
};

/** Determines the mapping place to use on the terrain. */
var(Material) ETerrainMappingType	MappingType;
/** Uniform scale to apply to the mapping. */
var(Material) float					MappingScale;
/** Rotation to apply to the mapping. */
var(Material) float					MappingRotation;
/** Offset to apply to the mapping along U. */
var(Material) float					MappingPanU;
/** Offset to apply to the mapping along V. */
var(Material) float					MappingPanV;

/** The Material to apply to the terrain. */
var(Material) MaterialInterface		Material;

/** Grayscale image to move vertices of the terrain along the surface normal. */
var(Displacement) Texture2D			DisplacementMap;
/** The amount to sacle the displacement texture by. */
var(Displacement) float				DisplacementScale;

struct native TerrainFoliageMesh
{
	/** The static mesh to use as the foliage piece. */
	var() StaticMesh		StaticMesh;
	/** The material to apply to the mesh, overriding the one assigned to it (optional). */
	var() MaterialInterface	Material;
	/** The number of meshes per quad. */
	var() int				Density;
	/** The furthest away you will see a mesh. */
	var() float				MaxDrawRadius;
	/** How far away will the mesh cease to blend/scale in. */
	var() float				MinTransitionRadius;
	/** Minimum scale to apply to an instance of the mesh. */
	var() float				MinScale;
	/** Maximum scale to apply to an instance of the mesh. */
	var() float				MaxScale;
	/** Minimum scale to apply to all instances of the mesh. */
	var() float				MinUniformScale;
	/** Maximum scale to apply to all instances of the mesh. */
	var() float				MaxUniformScale;
	/** How far away to start thinning out the meshes. */
	var() float				MinThinningRadius;
	/** Sets the random distribution of the instances. */
	var() int				Seed;
	/** Multiplier for wind resources. */
	var() float				SwayScale;

	/** The weight of the terrain material above which the foliage is spawned. */
	var() float				AlphaMapThreshold;
	
	/**	
	 *	The amount to rotate the mesh to match the slope of the terrain 
	 *	where it is being placed. If 1.0, the mesh will match the slope
	 *	exactly.
	 */
	var() float				SlopeRotationBlend;

	structdefaultproperties
	{
		MaxDrawRadius=1024.0
		MinThinningRadius=1024.0
		MinScale=1.0
		MaxScale=1.0
		MinUniformScale=1.0
		MaxUniformScale=1.0
		SwayScale=1.0
	}
};

/** Foliage meshes to apply (optional). */
var(Foliage) array<TerrainFoliageMesh>	FoliageMeshes;

cpptext
{
	// UpdateMappingTransform

	void UpdateMappingTransform();

	// UObject interface.
	virtual void PreEditChange(UProperty* PropertyAboutToChange);
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void PostLoad();
}

defaultproperties
{
	MappingScale=4.0
	DisplacementScale=0.25
}

