/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MaterialInterface extends Surface
	abstract
	forcescriptorder(true)
	native;

enum EMaterialUsage
{
	MATUSAGE_SkeletalMesh,
	MATUSAGE_FracturedMeshes,
	MATUSAGE_ParticleSprites,
	MATUSAGE_BeamTrails,
	MATUSAGE_ParticleSubUV,
	MATUSAGE_Foliage,
	MATUSAGE_SpeedTree,
	MATUSAGE_StaticLighting,
	MATUSAGE_GammaCorrection,
	MATUSAGE_LensFlare,
	MATUSAGE_InstancedMeshParticles,
	MATUSAGE_FluidSurface,
	MATUSAGE_Decals,
	MATUSAGE_MaterialEffect,
	MATUSAGE_MorphTargets,
	MATUSAGE_FogVolumes,
	MATUSAGE_RadialBlur,
	MATUSAGE_InstancedMeshes,
	MATUSAGE_SplineMesh,
	MATUSAGE_ScreenDoorFade,
	MATUSAGE_APEXMesh,
	MATUSAGE_Terrain
};

/** A fence to track when the primitive is no longer used as a parent */
var native const transient RenderCommandFence_Mirror ParentRefFence{FRenderCommandFence};

/** 
 *	Material interface settings for Lightmass
 */
struct native LightmassMaterialInterfaceSettings
{
	/** Scales the emissive contribution of this material to static lighting. */
	var(Material)	float		EmissiveBoost;
	/** Scales the diffuse contribution of this material to static lighting. */
	var(Material)	float		DiffuseBoost;
	/** Scales the specular contribution of this material to static lighting. */
	var				float		SpecularBoost;
	/** 
	 * Scales the resolution that this material's attributes were exported at. 
	 * This is useful for increasing material resolution when details are needed.
	 */
	var(Material)	float		ExportResolutionScale;
	/** Scales the penumbra size of distance field shadows.  This is useful to get softer precomputed shadows on certain material types like foliage. */
	var(Material)	float		DistanceFieldPenumbraScale;
	
	/** Boolean override flags - only used in MaterialInstance* cases. */
	/** If TRUE, override the emissive boost setting of the parent material. */
	var bool bOverrideEmissiveBoost;
	/** If TRUE, override the diffuse boost setting of the parent material. */
	var bool bOverrideDiffuseBoost;
	/** If TRUE, override the specular boost setting of the parent material. */
	var bool bOverrideSpecularBoost;
	/** If TRUE, override the export resolution scale setting of the parent material. */
	var bool bOverrideExportResolutionScale;
	/** If TRUE, override the distance field penumbra scale setting of the parent material. */
	var bool bOverrideDistanceFieldPenumbraScale;

	structdefaultproperties
	{
		EmissiveBoost=1.0
		DiffuseBoost=1.0
		SpecularBoost=1.0
		ExportResolutionScale=1.0
		DistanceFieldPenumbraScale=1.0
	}
};

/** The Lightmass settings for this object. */
var(Lightmass)	protected{protected}	LightmassMaterialInterfaceSettings		LightmassSettings <ScriptOrder=true>;

cpptext
{
	/**
	 * Get the material which this is an instance of.
	 * Warning - This is platform dependent!  Do not call GetMaterial(GCurrentMaterialPlatform) and save that reference,
	 * as it will be different depending on the current platform.  Instead call GetMaterial(MSP_BASE) to get the base material and save that.
	 * When getting the material for rendering/checking usage, GetMaterial(GCurrentMaterialPlatform) is fine.
	 *
	 * @param Platform - The platform to get material for.
	 */
	virtual class UMaterial* GetMaterial(EMaterialShaderPlatform Platform = GCurrentMaterialPlatform) PURE_VIRTUAL(UMaterialInterface::GetMaterial,return NULL;);

	/**
	* Tests this material instance for dependency on a given material instance.
	* @param	TestDependency - The material instance to test this instance for dependency upon.
	* @return	True if the material instance is dependent on TestDependency.
	*/
	virtual UBOOL IsDependent(UMaterialInterface* TestDependency) { return FALSE; }

	/**
	* Returns a pointer to the FMaterialRenderProxy used for rendering.
	*
	* @param	Selected	specify TRUE to return an alternate material used for rendering this material when part of a selection
	*						@note: only valid in the editor!
	*
	* @return	The resource to use for rendering this material instance.
	*/
	virtual FMaterialRenderProxy* GetRenderProxy(UBOOL Selected) const PURE_VIRTUAL(UMaterialInterface::GetRenderProxy,return NULL;);

	/**
	* Returns a pointer to the physical material used by this material instance.
	* @return The physical material.
	*/
	virtual UPhysicalMaterial* GetPhysicalMaterial() const PURE_VIRTUAL(UMaterialInterface::GetPhysicalMaterial,return NULL;);

	/** Returns the textures used to render this material for the given platform. */
	virtual void GetUsedTextures(TArray<UTexture*> &OutTextures, EMaterialShaderPlatform Platform = MSP_BASE, UBOOL bAllPlatforms = FALSE) 
		PURE_VIRTUAL(UMaterialInterface::GetUsedTextures,);

	/**
	* Checks whether the specified texture is needed to render the material instance.
	* @param Texture	The texture to check.
	* @return UBOOL - TRUE if the material uses the specified texture.
	*/
	virtual UBOOL UsesTexture(const UTexture* Texture) PURE_VIRTUAL(UMaterialInterface::UsesTexture,return FALSE;);

	/**
	 * Overrides a specific texture (transient)
	 *
	 * @param InTextureToOverride The texture to override
	 * @param OverrideTexture The new texture to use
	 */
	virtual void OverrideTexture( UTexture* InTextureToOverride, UTexture* OverrideTexture ) PURE_VIRTUAL(UMaterialInterface::OverrideTexture,return;);

	/**
	 * Checks if the material can be used with the given usage flag.  
	 * If the flag isn't set in the editor, it will be set and the material will be recompiled with it.
	 * @param Usage - The usage flag to check
	 * @return UBOOL - TRUE if the material can be used for rendering with the given type.
	 */
	virtual UBOOL CheckMaterialUsage(EMaterialUsage Usage) PURE_VIRTUAL(UMaterialInterface::CheckMaterialUsage,return FALSE;);

	/**
	* Allocates a new material resource
	* @return	The allocated resource
	*/
	virtual FMaterialResource* AllocateResource() PURE_VIRTUAL(UMaterialInterface::AllocateResource,return NULL;);

	/**
	 * Gets the static permutation resource if the instance has one
	 * @return - the appropriate FMaterialResource if one exists, otherwise NULL
	 */
	virtual FMaterialResource* GetMaterialResource(EMaterialShaderPlatform Platform = GCurrentMaterialPlatform) { return NULL; }

	/**
	 * @return the flattened texture for the material
	 */
	virtual UTexture* GetMobileTexture(const INT /* EMobileTextureUnit */ MobileTextureUnit);

	/**
	 * Used by various commandlets to purge Editor only data from the object.
	 *
	 * @param TargetPlatform Platform the object will be saved for (ie PC vs console cooking, etc)
	 */
	virtual void StripData(UE3::EPlatformType TargetPlatform);

	/**
	 * Compiles a FMaterialResource on the given platform with the given static parameters
	 *
	 * @param StaticParameters - The set of static parameters to compile for
	 * @param StaticPermutation - The resource to compile
	 * @param Platform - The platform to compile for
	 * @param MaterialPlatform - The material platform to compile for
	 * @param bFlushExistingShaderMaps - Indicates that existing shader maps should be discarded
	 * @return TRUE if compilation was successful or not necessary
	 */
	virtual UBOOL CompileStaticPermutation(
		FStaticParameterSet* StaticParameters, 
		FMaterialResource* StaticPermutation, 
		EShaderPlatform Platform, 
		EMaterialShaderPlatform MaterialPlatform,
		UBOOL bFlushExistingShaderMaps,
		UBOOL bDebugDump)
		PURE_VIRTUAL(UMaterialInterface::CompileStaticPermutation,return FALSE;);

	/**
	* Gets the value of the given static switch parameter
	*
	* @param	ParameterName	The name of the static switch parameter
	* @param	OutValue		Will contain the value of the parameter if successful
	* @return					True if successful
	*/
	virtual UBOOL GetStaticSwitchParameterValue(FName ParameterName,UBOOL &OutValue,FGuid &OutExpressionGuid) 
		PURE_VIRTUAL(UMaterialInterface::GetStaticSwitchParameterValue,return FALSE;);

	/**
	* Gets the value of the given static component mask parameter
	*
	* @param	ParameterName	The name of the parameter
	* @param	R, G, B, A		Will contain the values of the parameter if successful
	* @return					True if successful
	*/
	virtual UBOOL GetStaticComponentMaskParameterValue(FName ParameterName, UBOOL &R, UBOOL &G, UBOOL &B, UBOOL &A, FGuid &OutExpressionGuid) 
		PURE_VIRTUAL(UMaterialInterface::GetStaticComponentMaskParameterValue,return FALSE;);

	/**
	* Gets the compression format of the given normal parameter
	*
	* @param	ParameterName	The name of the parameter
	* @param	CompressionSettings	Will contain the values of the parameter if successful
	* @return					True if successful
	*/
	virtual UBOOL GetNormalParameterValue(FName ParameterName, BYTE& OutCompressionSettings, FGuid &OutExpressionGuid)
		PURE_VIRTUAL(UMaterialInterface::GetNormalParameterValue,return FALSE;);

	virtual UBOOL IsFallbackMaterial() { return FALSE; }

	/** @return The material's view relevance. */
	FMaterialViewRelevance GetViewRelevance();

	INT GetWidth() const;
	INT GetHeight() const;

	// USurface interface
	virtual FLOAT GetSurfaceWidth() const { return GetWidth(); }
	virtual FLOAT GetSurfaceHeight() const { return GetHeight(); }

	// UObject interface
	virtual void BeginDestroy();
	virtual UBOOL IsReadyForFinishDestroy();
	virtual void Serialize(FArchive& Ar);
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/**
	 *	Serialize the given shader map to the given archive
	 *
	 *	@param	InShaderMap				The shader map to serialize; when loading will be NULL.
	 *	@param	Ar						The archvie to serialize it to.
	 *
	 *	@return	FMaterialShaderMap*		The shader map serialized
	 */
	FMaterialShaderMap* SerializeShaderMap(FMaterialShaderMap* InShaderMap, FArchive& Ar);
	
	/**
	 *	Check if the textures have changed since the last time the material was
	 *	serialized for Lightmass... Update the lists while in here.
	 *	NOTE: This will mark the package dirty if they have changed.
	 *
	 *	@return	UBOOL	TRUE if the textures have changed.
	 *					FALSE if they have not.
	 */
	virtual UBOOL UpdateLightmassTextureTracking() { return FALSE; }
	
	/** @return The override emissive boost setting of the material. */
	inline UBOOL GetOverrideEmissiveBoost() const
	{
		return LightmassSettings.bOverrideEmissiveBoost;
	}
	/** @return The override diffuse boost setting of the material. */
	inline UBOOL GetOverrideDiffuseBoost() const
	{
		return LightmassSettings.bOverrideDiffuseBoost;
	}
	/** @return The override specular boost setting of the material. */
	inline UBOOL GetOverrideSpecularBoost() const
	{
		return LightmassSettings.bOverrideSpecularBoost;
	}
	/** @return The override export resolution scale setting of the material. */
	inline UBOOL GetOverrideExportResolutionScale() const
	{
		return LightmassSettings.bOverrideExportResolutionScale;
	}
	inline UBOOL GetOverrideDistanceFieldPenumbraScale() const
	{
		return LightmassSettings.bOverrideDistanceFieldPenumbraScale;
	}
	/** @return	The Emissive boost value for this material. */
	virtual FLOAT GetEmissiveBoost() const
	{
		return LightmassSettings.EmissiveBoost;
	}
	/** @return	The Diffuse boost value for this material. */
	virtual FLOAT GetDiffuseBoost() const
	{
		return LightmassSettings.DiffuseBoost;
	}
	/** @return	The Specular boost value for this material. */
	virtual FLOAT GetSpecularBoost() const
	{
		return LightmassSettings.SpecularBoost;
	}
	/** @return	The ExportResolutionScale value for this material. */
	virtual FLOAT GetExportResolutionScale() const
	{
		return LightmassSettings.ExportResolutionScale;
	}
	virtual FLOAT GetDistanceFieldPenumbraScale() const
	{
		return LightmassSettings.DistanceFieldPenumbraScale;
	}

	/** @param	bInOverrideEmissiveBoost	The override emissive boost setting to set. */
	inline void SetOverrideEmissiveBoost(UBOOL bInOverrideEmissiveBoost)
	{
		LightmassSettings.bOverrideEmissiveBoost = bInOverrideEmissiveBoost;
	}
	/** @param bInOverrideDiffuseBoost		The override diffuse boost setting of the parent material. */
	inline void SetOverrideDiffuseBoost(UBOOL bInOverrideDiffuseBoost)
	{
		LightmassSettings.bOverrideDiffuseBoost = bInOverrideDiffuseBoost;
	}
	/** @param bInOverrideSpecularBoost		The override specular boost setting of the parent material. */
	inline void SetOverrideSpecularBoost(UBOOL bInOverrideSpecularBoost)
	{
		LightmassSettings.bOverrideSpecularBoost = bInOverrideSpecularBoost;
	}
	/** @param bInOverrideExportResolutionScale	The override export resolution scale setting of the parent material. */
	inline void SetOverrideExportResolutionScale(UBOOL bInOverrideExportResolutionScale)
	{
		LightmassSettings.bOverrideExportResolutionScale = bInOverrideExportResolutionScale;
	}
	inline void SetOverrideDistanceFieldPenumbraScale(UBOOL bInOverrideDistanceFieldPenumbraScale)
	{
		LightmassSettings.bOverrideDistanceFieldPenumbraScale = bInOverrideDistanceFieldPenumbraScale;
	}
	/** @param	InEmissiveBoost		The Emissive boost value for this material. */
	inline void SetEmissiveBoost(FLOAT InEmissiveBoost)
	{
		LightmassSettings.EmissiveBoost = InEmissiveBoost;
	}
	/** @param	InDiffuseBoost		The Diffuse boost value for this material. */
	inline void SetDiffuseBoost(FLOAT InDiffuseBoost)
	{
		LightmassSettings.DiffuseBoost = InDiffuseBoost;
	}
	/** @param	InSpecularBoost		The Specular boost value for this material. */
	inline void SetSpecularBoost(FLOAT InSpecularBoost)
	{
		LightmassSettings.SpecularBoost = InSpecularBoost;
	}
	/** @param	InExportResolutionScale		The ExportResolutionScale value for this material. */
	inline void SetExportResolutionScale(FLOAT InExportResolutionScale)
	{
		LightmassSettings.ExportResolutionScale = InExportResolutionScale;
	}
	inline void SetDistanceFieldPenumbraScale(FLOAT InDistanceFieldPenumbraScale)
	{
		LightmassSettings.DistanceFieldPenumbraScale = InDistanceFieldPenumbraScale;
	}

	/**
	 *	Get all of the textures in the expression chain for the given property (ie fill in the given array with all textures in the chain).
	 *
	 *	@param	InProperty				The material property chain to inspect, such as MP_DiffuseColor.
	 *	@param	OutTextures				The array to fill in all of the textures.
	 *	@param	OutTextureParamNames	Optional array to fill in with texture parameter names.
	 *
	 *	@return	UBOOL			TRUE if successful, FALSE if not.
	 */
	virtual UBOOL GetTexturesInPropertyChain(EMaterialProperty InProperty, TArray<UTexture*>& OutTextures,  TArray<FName>* OutTextureParamNames)
		PURE_VIRTUAL(UMaterialInterface::GetTexturesInPropertyChain,return FALSE;);

	/**
	 * Returns the lookup texture to be used in the physical material mask.  Tries to get the parents lookup texture if not overridden here. 
	 */
	virtual UTexture2D* GetPhysicalMaterialMaskTexture() const { return NULL; }

	/**
	 * Returns the black physical material to be used in the physical material mask.  Tries to get the parents black phys mat if not overridden here. 
	 */
	virtual UPhysicalMaterial* GetBlackPhysicalMaterial() const { return NULL; }

	/**
	 * Returns the white physical material to be used in the physical material mask.  Tries to get the parents white phys mat if not overridden here. 
	 */
	virtual UPhysicalMaterial* GetWhitePhysicalMaterial() const { return NULL; }

	/** 
	 * Returns the UV channel that should be used to look up physical material mask information 
	 */
	virtual INT GetPhysMaterialMaskUVChannel() const { return -1; }

	/** 
	 * Returns True if this material has a valid physical material mask setup.
 	 */
	UBOOL HasValidPhysicalMaterialMask() const;

	/**
	 * Determines the texel on the physical material mask that was hit and returns the physical material corresponding to hit texel's color
	 * 
	 * @param HitUV the UV that was hit during collision.
	 */
	UPhysicalMaterial* DetermineMaskedPhysicalMaterialFromUV( const FVector2D& HitUV ) const;
}

/** The mesh used by the material editor to preview the material.*/
var() editoronly string PreviewMesh;

/** Unique ID for this material, used for caching during distributed lighting */
var private const Guid LightingGuid;

/** Possible vertex texture coordinate sets that may used to sample textures on mobile platforms */
enum EMobileTexCoordsSource
{
	/** First texture coordinate from mesh vertex */
	MTCS_TexCoords0,

	/** Second texture coordinate from mesh vertex */
	MTCS_TexCoords1,

	/** Third texture coordinate from mesh vertex */
	MTCS_TexCoords2,

	/** Forth texture coordinate from mesh vertex */
	MTCS_TexCoords3,
};

/** The texture that is used to render with on platforms without full material support */
var(Mobile) duplicatetransient texture FlattenedTexture;

/** Texture coordinates from mesh vertex to use when sampling base texture on mobile platforms */
var(Mobile) EMobileTexCoordsSource MobileBaseTextureTexCoordsSource;

/** Mobile platforms only: Detail texture to use */
var(Mobile) texture MobileDetailTexture;

/** Texture coordinates from mesh vertex to use when sampling detail texture on mobile platforms */
var(Mobile) EMobileTexCoordsSource MobileDetailTextureTexCoordsSource;

/** Possible options for blend factor source for blending between textures */
enum EMobileTextureBlendFactorSource
{
	/** From the vertex color's red channel */
	MTBFS_VertexColor,

	/** From the mask texture's alpha */
	MTBFS_MaskTexture,
};

/** Where the blend factor comes from, for the blending the base texture with the detail texture */
var(Mobile) EMobileTextureBlendFactorSource MobileTextureBlendFactorSource;

/** Mobile platforms only: Normal map texture */
var(Mobile) texture MobileNormalTexture;

/** Mobile platforms only: Environment map texture */
var(Mobile) texture MobileEnvironmentTexture;

/** Mask texture used for bump offset amount, texture blending, etc. */
var(Mobile) texture MobileMaskTexture;

/** Texture coordinates from mesh vertex to use when sampling mask texture on mobile platforms */
var(Mobile) EMobileTexCoordsSource MobileMaskTextureTexCoordsSource;

/** Whether or not to use the bump offset code path on platforms without full material support */
var(Mobile) bool bUseMobileBumpOffset;

/** When using bump offset on platforms without full material support, the bump reference plane */
var(Mobile) float MobileBumpOffsetReferencePlane <EditCondition=bUseMobileBumpOffset>;

/** When using bump offset on platforms without full material support, the bump height ratio */
var(Mobile) float MobileBumpOffsetHeightRatio <EditCondition=bUseMobileBumpOffset>;

/**Whether or not to use the "texture transform" code path in the emulation shaders on platforms without full material support*/
var(Mobile) bool bUseMobileTextureTransform;

/** This material should never have a flatted mobile texture generated for it. Set for system-generated material such as Landscape MICs */
var bool bNeverFlattenMaterial;

enum EMobileTextureTransformTarget
{
	/** Transform diffuse texture (and bump offset texture) UVs */
	MTTT_BaseTexture,

	/** Transform detail texture UVs */
	MTTT_DetailTexture
};

/** Which texture UVs to transform */
var(Mobile) EMobileTextureTransformTarget MobileTextureTransformTarget <EditCondition=bUseMobileTextureTransform>;

/**X-Center of the texture for rotation/scale on platforms without full material support*/
var(Mobile) float TransformCenterX <EditCondition=bUseMobileTextureTransform>;
/**Y-Center of the texture for rotation/scale on platforms without full material support*/
var(Mobile) float TransformCenterY <EditCondition=bUseMobileTextureTransform>;

/**X-Axis Speed for panning textures on platforms without full material support*/
var(Mobile) float PannerSpeedX <EditCondition=bUseMobileTextureTransform>;
/**Y-Axis Speed for panning textures on platforms without full material support*/
var(Mobile) float PannerSpeedY <EditCondition=bUseMobileTextureTransform>;

/**Rotation speed on platforms without full material support*/
var(Mobile) float RotateSpeed <EditCondition=bUseMobileTextureTransform>;

/** NOTE - Scale is done around the rotation center x,y */
/**Scale in X for platforms without full material support*/
var(Mobile) float FixedScaleX <EditCondition=bUseMobileTextureTransform>;
/**Scale in Y for platforms without full material support*/
var(Mobile) float FixedScaleY <EditCondition=bUseMobileTextureTransform>;

/**Scale applied to a sine wave in X for platforms without full material support*/
var(Mobile) float SineScaleX <EditCondition=bUseMobileTextureTransform>;
/*Scale applied to a sine wave in Y for platforms without full material support*/
var(Mobile) float SineScaleY <EditCondition=bUseMobileTextureTransform>;
/**Multiplier for frequency used with SineScaleX & SineScaleY for platforms without full material support*/
var(Mobile) float SineScaleFrequencyMultipler <EditCondition=bUseMobileTextureTransform>;

/** Mobile platforms only: Enables per-vertex specular for this material */
/** @todo: This should be renamed to bUseMobileSpecular or changed to an enum */
var(Mobile) bool bUseMobileVertexSpecular;

/** Mobile platforms only: Enables per-pixel specular for this material (requires normal map) */
var(Mobile) bool bUseMobilePixelSpecular<EditCondition=bUseMobileVertexSpecular>;

/** Mobile platforms only: Material specular color */
var(Mobile) LinearColor MobileSpecularColor<EditCondition=bUseMobileVertexSpecular>;

/** Mobile platforms only: Enables per-vertex specular for this material */
var(Mobile) float MobileSpecularPower<EditCondition=bUseMobileVertexSpecular>;

enum EMobileSpecularMask
{
	MSM_Constant,
	MSM_Luminance,
	MSM_DiffuseRed,
	MSM_DiffuseGreen,
	MSM_DiffuseBlue,
	MSM_DiffuseAlpha,
};

/** Mobile platforms only: Determines how specular values are masked.  Constant: Mask is disabled.  Luminance: Diffuse RGB luminance used as mask.  Diffuse Red/Green/Blue: Use a specific channel of the diffuse texture as the specular mask */
var(Mobile) EMobileSpecularMask MobileSpecularMask<EditCondition=bUseMobileVertexSpecular>;


/** Mobile platforms only: Enables per-vertex movement on a wave (for use in trees) */
var(Mobile) bool bUseMobileWaveVertexMovement;
/** Mobile platforms only: Frequency adjustment for wave on vertex positions */
var(Mobile) float MobileTangentVertexFrequencyMultiplier<EditCondition=bUseMobileWaveVertexMovement>;
/** Mobile platforms only: Frequency adjustment for wave on vertex positions */
var(Mobile) float MobileVerticalFrequencyMultiplier<EditCondition=bUseMobileWaveVertexMovement>;
/** Mobile platforms only: Amplitude of adjustments for wave on vertex positions*/
var(Mobile) float MobileMaxVertexMovementAmplitude<EditCondition=bUseMobileWaveVertexMovement>;
/**Mobile platforms only: Frequency of entire object sway */
var(Mobile) float MobileSwayFrequencyMultiplier<EditCondition=bUseMobileWaveVertexMovement>;
/**Mobile platforms only: Frequency of entire object sway */
var(Mobile) float MobileSwayMaxAngle<EditCondition=bUseMobileWaveVertexMovement>;

/** Mobile platforms only: Allows custom enabling/disabling of fog */
var (Mobile) bool bMobileAllowFog;


native final noexport function Material GetMaterial();

/**
* Returns a pointer to the physical material used by this material instance.
* @return The physical material.
*/
native final noexport function PhysicalMaterial GetPhysicalMaterial() const;

// Get*ParameterValue - Gets the entry from the ParameterValues for the named parameter.
// Returns false is parameter is not found.


native function bool GetFontParameterValue(name ParameterName,out font OutFontValue, out int OutFontPage);
native function bool GetScalarParameterValue(name ParameterName, out float OutValue);
native function bool GetScalarCurveParameterValue(name ParameterName, out InterpCurveFloat OutValue);
native function bool GetTextureParameterValue(name ParameterName, out Texture OutValue);
native function bool GetVectorParameterValue(name ParameterName, out LinearColor OutValue);
native function bool GetVectorCurveParameterValue(name ParameterName, out InterpCurveVector OutValue);

/**
 * Forces the streaming system to disregard the normal logic for the specified duration and
 * instead always load all mip-levels for all textures used by this material.
 *
 * @param ForceDuration	- Number of seconds to keep all mip-levels in memory, disregarding the normal priority logic.
 * @param CinematicTextureGroups	- Bitfield indicating which texture groups that use extra high-resolution mips
 */
native function SetForceMipLevelsToBeResident( bool OverrideForceMiplevelsToBeResident, bool bForceMiplevelsToBeResidentValue, float ForceDuration, optional int CinematicTextureGroups = 0 );

defaultproperties
{
	bUseMobileTextureTransform=FALSE
	MobileTextureTransformTarget=MTTT_BaseTexture

	//default to the center of the texture for scaling and rotating
	TransformCenterX=0.5
	TransformCenterY=0.5

	PannerSpeedX=0.0
	PannerSpeedY=0.0

	RotateSpeed=0.0

	FixedScaleX=1.0
	FixedScaleY=1.0

	SineScaleX=0.0
	SineScaleY=0.0
	SineScaleFrequencyMultipler=1.0

	bUseMobileVertexSpecular=FALSE
	bUseMobilePixelSpecular=FALSE
	MobileSpecularColor=(R=1.0,G=1.0,B=1.0,A=1.0)
	MobileSpecularPower=16.0
	MobileSpecularMask=MSM_Constant

	MobileTextureBlendFactorSource=MTBFS_VertexColor
	MobileBaseTextureTexCoordsSource=MTCS_TexCoords0
	MobileDetailTextureTexCoordsSource=MTCS_TexCoords1
	MobileMaskTextureTexCoordsSource=MTCS_TexCoords0

	bUseMobileBumpOffset=FALSE;
	MobileBumpOffsetReferencePlane = 0.5;
	MobileBumpOffsetHeightRatio = 0.05;

	bUseMobileWaveVertexMovement = FALSE;
	MobileTangentVertexFrequencyMultiplier = .125;
	MobileVerticalFrequencyMultiplier = .1;
	MobileMaxVertexMovementAmplitude = 5.0;
	MobileSwayFrequencyMultiplier=.07;
	MobileSwayMaxAngle=2.0;


	bMobileAllowFog = TRUE;
}
