/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class Material extends MaterialInterface
	native
	hidecategories(object);

/** Note: This is mirrored in Lightmass, be sure to update the blend mode structure and logic there if this changes. */
enum EBlendMode
{
	BLEND_Opaque,
	BLEND_Masked,
	BLEND_Translucent,
	BLEND_Additive,
	BLEND_Modulate,
	BLEND_SoftMasked,
	BLEND_AlphaComposite
};

enum EMaterialLightingModel
{
	MLM_Phong,
	MLM_NonDirectional,
	MLM_Unlit,
	MLM_SHPRT,
	MLM_Custom,
	MLM_Anisotropic
};

// Material input structs.

struct MaterialInput
{
	var MaterialExpression	Expression;
	var int					Mask,
							MaskR,
							MaskG,
							MaskB,
							MaskA;
	var int					GCC64_Padding; // @todo 64: if the C++ didn't mismirror this structure (with ExpressionInput), we might not need this
};

struct ColorMaterialInput extends MaterialInput
{
	var bool	UseConstant;
	var color	Constant;
};

struct ScalarMaterialInput extends MaterialInput
{
	var bool	UseConstant;
	var float	Constant;
};

struct VectorMaterialInput extends MaterialInput
{
	var bool	UseConstant;
	var vector	Constant;
};

struct Vector2MaterialInput extends MaterialInput
{
	var bool	UseConstant;
	var float	ConstantX,
				ConstantY;
};

// Physics.

/** Physical material to use for this graphics material. Used for sounds, effects etc.*/
var() PhysicalMaterial		PhysMaterial;

/** For backwards compatibility only. */
var class<PhysicalMaterial>	PhysicalMaterial;

/** A 1 bit monochrome texture that represents a mask for what physical material should be used if the collided texel is black or white. */
var(PhysicalMaterialMask)	Texture2D	PhysMaterialMask;				
/** The UV channel to use for the PhysMaterialMask. */
var(PhysicalMaterialMask)	INT	PhysMaterialMaskUVChannel;
/** The physical material to use when a black pixel in the PhysMaterialMask texture is hit. */
var(PhysicalMaterialMask)	PhysicalMaterial BlackPhysicalMaterial;
/** The physical material to use when a white pixel in the PhysMaterialMask texture is hit. */
var(PhysicalMaterialMask)	PhysicalMaterial WhitePhysicalMaterial;

// Reflection.

//NOTE: If any additional inputs are added/removed WxMaterialEditor::GetVisibleMaterialParameters() must be updated
var ColorMaterialInput		DiffuseColor;
var ScalarMaterialInput		DiffusePower;
var ColorMaterialInput		SpecularColor;
var ScalarMaterialInput		SpecularPower;
var VectorMaterialInput		Normal;

// Emission.

var ColorMaterialInput		EmissiveColor;

// Transmission.

var ScalarMaterialInput		Opacity;
var ScalarMaterialInput		OpacityMask;

/** If BlendMode is BLEND_Masked or BLEND_SoftMasked, the surface is not rendered where OpacityMask < OpacityMaskClipValue. */
var() float OpacityMaskClipValue;

/** Allows the material to distort background color by offsetting each background pixel by the amount of the distortion input for that pixel. */
var Vector2MaterialInput	Distortion;

/** Determines how the material's color is blended with background colors. */
var() EBlendMode BlendMode;

/** Determines how inputs are combined to create the material's final color. */
var() EMaterialLightingModel LightingModel;

/** 
 * Use a custom light transfer equation to be factored with light color, attenuation and shadowing. 
 * This is currently only used for Movable, Toggleable and Dominant light contribution.
 * LightVector can be used in this material input and will be set to the tangent space light direction of the current light being rendered.
 */
var ColorMaterialInput		CustomLighting;

/** 
 * Use a custom diffuse factor for attenuation with lights that only support a diffuse term. 
 * This should only be the diffuse color coefficient, and must not depend on LightVector.
 * This is currently used with skylights, SH lights, materials exported to lightmass and directional lightmap contribution.
 */
var ColorMaterialInput		CustomSkylightDiffuse;

/** Specify a vector to use as anisotropic direction */
var VectorMaterialInput		AnisotropicDirection;

/** Lerps between lighting color (diffuse * attenuation * Lambertian) and lighting without the Lambertian term color (diffuse * attenuation * TwoSidedLightingColor). */
var ScalarMaterialInput		TwoSidedLightingMask;

/** Modulates the lighting without the Lambertian term in two sided lighting. */
var ColorMaterialInput		TwoSidedLightingColor;

/** Adds to world position in the vertex shader. */
var VectorMaterialInput		WorldPositionOffset;

/** Indicates that the material should be rendered without backface culling and the normal should be flipped for backfaces. */
var() bool TwoSided;

/** Indicates that the material should be rendered in its own pass. Used for hair renderering */
var(Translucency) bool TwoSidedSeparatePass;

/**
 * Allows the material to disable depth tests, which is only meaningful with translucent blend modes.
 * Disabling depth tests will make rendering significantly slower since no occluded pixels can get zculled.
 */
var(Translucency) bool bDisableDepthTest;

/** Whether the material should allow fog or be unaffected by fog.  This only has meaning for materials with translucent blend modes. */
var(Translucency) bool bAllowFog;

/** 
 * Whether the material should receive dynamic dominant light shadows from static objects when the material is being lit by a light environment. 
 * This is useful for character hair.
 */
var(Translucency) bool bTranslucencyReceiveDominantShadowsFromStatic;

/** 
 * Whether the material should inherit the dynamic shadows that dominant lights are casting on opaque and masked materials behind this material.
 * This is useful for ground meshes using a translucent blend mode and depth biased alpha to hide seams.
 */
var(Translucency) bool bTranslucencyInheritDominantShadowsFromOpaque;

/** Whether the material should allow Depth of Field or be unaffected by DoF.  This only has meaning for materials with translucent blend modes. */
var(Translucency) bool bAllowTranslucencyDoF;

/**
 * Whether the material should use one-layer distortion, which can be cheaper than normal distortion for some primitive types (mainly fluid surfaces).
 * One layer distortion won't handle overlapping one layer distortion primitives correctly.
 * This causes an extra scene color resolve for the first primitive that uses one layer distortion and so should only be used in very specific circumstances.
 */
var(Translucency) bool bUseOneLayerDistortion;

/** If this is set, a depth-only pass for will be rendered for solid (A=255) areas of dynamic lit translucency primitives. This improves hair sorting at the extra render cost. */
var(Translucency) bool bUseLitTranslucencyDepthPass;

/** If this is set, a depth-only pass for will be rendered for any visible (A>0) areas of dynamic lit translucency primitives. This is necessary for correct fog and DoF of hair */
var(Translucency) bool bUseLitTranslucencyPostRenderDepthPass;

/** If this is set, lit translucent objects will cast shadow as if they were masked */
var(Translucency) bool bCastLitTranslucencyShadowAsMasked;

var(MutuallyExclusiveUsage) const bool bUsedAsLightFunction;
/** Indicates that the material is used on fog volumes.  This usage flag is mutually exclusive with all other mesh type usage flags! */
var(MutuallyExclusiveUsage) const bool bUsedWithFogVolumes;

/** 
 * This is a special usage flag that allows a material to be assignable to any primitive type.
 * This is useful for materials used by code to implement certain viewmodes, for example the default material or lighting only material.
 * The cost is that nearly 20x more shaders will be compiled for the material than the average material, which will greatly increase shader compile time and memory usage.
 * This flag should only be set when absolutely necessary, and is purposefully not exposed to the UI to prevent abuse.
 */
var duplicatetransient const bool bUsedAsSpecialEngineMaterial;
/** 
 * Indicates that the material and its instances can be assigned to skeletal meshes.  
 * This will result in the shaders required to support skeletal meshes being compiled which will increase shader compile time and memory usage.
 */
var(Usage) const bool bUsedWithSkeletalMesh;
var(Usage) const bool bUsedWithTerrain;
var(Usage) const bool bUsedWithFracturedMeshes;
var		   const bool bUsedWithParticleSystem;
var(Usage) const bool bUsedWithParticleSprites;
var(Usage) const bool bUsedWithBeamTrails;
var(Usage) const bool bUsedWithParticleSubUV;
var(Usage) const bool bUsedWithFoliage;
var(Usage) const bool bUsedWithSpeedTree;
var(Usage) const bool bUsedWithStaticLighting;
var(Usage) const bool bUsedWithLensFlare;
/** 
 * Gamma corrects the output of the base pass using the current render target's gamma value. 
 * This must be set on materials used with UIScenes to get correct results.
 */
var(Usage) const bool bUsedWithGammaCorrection;
/** Enables instancing for mesh particles.  Use the "Vertex Color" node when enabled, not "MeshEmit VertColor." */
var(Usage) const bool bUsedWithInstancedMeshParticles;
var(Usage) const bool bUsedWithFluidSurfaces;
/** WARNING: bUsedWithDecals is mutually exclusive with all other mesh type usage flags!  A material with bUsedWithDecals=true will not work on any other mesh type. */
var(MutuallyExclusiveUsage) const bool bUsedWithDecals;
var(Usage) const bool bUsedWithMaterialEffect;
var(Usage) const bool bUsedWithMorphTargets;
var(Usage) const bool bUsedWithRadialBlur;
var(Usage) const bool bUsedWithInstancedMeshes;
var(Usage) const bool bUsedWithSplineMeshes;
var(Usage) const bool bUsedWithAPEXMeshes;

/** Enables support for screen door fading for primitives rendering with this material.  This adds an extra texture lookup and a few extra instructions. */
var(Usage) const bool bUsedWithScreenDoorFade;

var() bool Wireframe;

/** When enabled, the camera vector will be computed in the pixel shader instead of the vertex shader which may improve the quality of the reflection.  Enabling this setting also allows VertexColor expressions to be used alongside Transform expressions. */
var() bool bPerPixelCameraVector;

/** Controls whether lightmap specular will be rendered or not.  Can be disabled to reduce instruction count. */
var() bool bAllowLightmapSpecular;

/** Indicates that the material will be used as a fallback on sm2 platforms */
var deprecated bool bIsFallbackMaterial;

// indexed by EMaterialShaderPlatform
// Only the first entry is ever used now that SM2 is no longer supported, 
// But the member is kept as an array to make adding future material platforms easier.  
// The second entry is to work around the script compile error from having an array with one element.
var const native duplicatetransient pointer MaterialResources[2]{FMaterialResource};

// second is used when selected
var const native duplicatetransient pointer DefaultMaterialInstances[2]{class FDefaultMaterialInstance};

var int		EditorX,
			EditorY,
			EditorPitch,
			EditorYaw;

/** Array of material expressions, excluding Comments and Compounds.  Used by the material editor. */
var array<MaterialExpression>			Expressions;

/** Array of comments associated with this material; viewed in the material editor. */
var editoronly array<MaterialExpressionComment>	EditorComments;

/** Array of material expression compounds associated with this material; viewed in the material editor. */
var editoronly array<MaterialExpressionCompound> EditorCompounds;

var native map{FName, TArray<UMaterialExpression*>} EditorParameters;

/** TRUE if Material uses distortion */
var private bool						bUsesDistortion;

/** TRUE if Material is masked and uses custom opacity */
var private bool						bIsMasked;

/** TRUE if Material is the preview material used in the material editor. */
var transient duplicatetransient private bool bIsPreviewMaterial;

/** Legacy texture references, now handled by FMaterial. */
var deprecated private const array<texture> ReferencedTextures;

var private const editoronly array<guid> ReferencedTextureGuids;

cpptext
{
	// Constructor.
	UMaterial();

	/** @return TRUE if the material uses distortion */
	UBOOL HasDistortion() const;
	/** @return TRUE if the material uses the scene color texture */
	UBOOL UsesSceneColor() const;

	/**
	 * Allocates a material resource off the heap to be stored in MaterialResource.
	 */
	virtual FMaterialResource* AllocateResource();

	/** Returns the textures used to render this material for the given platform. */
	virtual void GetUsedTextures(TArray<UTexture*> &OutTextures, EMaterialShaderPlatform Platform = MSP_BASE, UBOOL bAllPlatforms = FALSE);

	/**
	* Checks whether the specified texture is needed to render the material instance.
	* @param Texture	The texture to check.
	* @return UBOOL - TRUE if the material uses the specified texture.
	*/
	virtual UBOOL UsesTexture(const UTexture* Texture);

	/**
	 * Overrides a specific texture (transient)
	 *
	 * @param InTextureToOverride The texture to override
	 * @param OverrideTexture The new texture to use
	 */
	virtual void OverrideTexture( UTexture* InTextureToOverride, UTexture* OverrideTexture );

private:

	/** Sets the value associated with the given usage flag. */
	void SetUsageByFlag(EMaterialUsage Usage, UBOOL NewValue);

public:

	/** Gets the name of the given usage flag. */
	FString GetUsageName(EMaterialUsage Usage) const;

	/** Gets the value associated with the given usage flag. */
	UBOOL GetUsageByFlag(EMaterialUsage Usage) const;

	/**
	 * Checks if the material can be used with the given usage flag.
	 * If the flag isn't set in the editor, it will be set and the material will be recompiled with it.
	 * @param Usage - The usage flag to check
	 * @return UBOOL - TRUE if the material can be used for rendering with the given type.
	 */
	virtual UBOOL CheckMaterialUsage(EMaterialUsage Usage);

	/**
	 * Sets the given usage flag.
	 * @param bNeedsRecompile - TRUE if the material was recompiled for the usage change
	 * @param Usage - The usage flag to set
	 * @return UBOOL - TRUE if the material can be used for rendering with the given type.
	 */
	UBOOL SetMaterialUsage(UBOOL &bNeedsRecompile, EMaterialUsage Usage);

	/**
	 * @param	OutParameterNames		Storage array for the parameter names we are returning.
	 * @param	OutParameterIds			Storage array for the parameter id's we are returning.
	 *
	 * @return	Returns a array of parameter names used in this material for the specified expression type.
	 */
	template<typename ExpressionType>
	void GetAllParameterNames(TArray<FName> &OutParameterNames, TArray<FGuid> &OutParameterIds);
	
	void GetAllVectorParameterNames(TArray<FName> &OutParameterNames, TArray<FGuid> &OutParameterIds);
	void GetAllScalarParameterNames(TArray<FName> &OutParameterNames, TArray<FGuid> &OutParameterIds);
	void GetAllTextureParameterNames(TArray<FName> &OutParameterNames, TArray<FGuid> &OutParameterIds);
	void GetAllFontParameterNames(TArray<FName> &OutParameterNames, TArray<FGuid> &OutParameterIds);
	void GetAllStaticSwitchParameterNames(TArray<FName> &OutParameterNames, TArray<FGuid> &OutParameterIds);
	void GetAllStaticComponentMaskParameterNames(TArray<FName> &OutParameterNames, TArray<FGuid> &OutParameterIds);
	void GetAllNormalParameterNames(TArray<FName> &OutParameterNames, TArray<FGuid> &OutParameterIds);
	void GetAllTerrainLayerWeightParameterNames(TArray<FName> &OutParameterNames, TArray<FGuid> &OutParameterIds);

	/**
	 * Attempts to find a expression by its GUID.
	 *
	 * @param InGUID GUID to search for.
	 *
	 * @return Returns a expression object pointer if one is found, otherwise NULL if nothing is found.
	 */
	template<typename ExpressionType>
	ExpressionType* FindExpressionByGUID(const FGuid &InGUID)
	{
		ExpressionType* Result = NULL;

		for(INT ExpressionIndex = 0;ExpressionIndex < Expressions.Num();ExpressionIndex++)
		{
			ExpressionType* ExpressionPtr =
				Cast<ExpressionType>(Expressions(ExpressionIndex));

			if(ExpressionPtr && ExpressionPtr->ExpressionGUID.IsValid() && ExpressionPtr->ExpressionGUID==InGUID)
			{
				Result = ExpressionPtr;
				break;
			}
		}

		return Result;
	}

	// UMaterialInterface interface.

	/**
	 * Get the material which this is an instance of.
	 * Warning - This is platform dependent!  Do not call GetMaterial(GCurrentMaterialPlatform) and save that reference,
	 * as it will be different depending on the current platform.  Instead call GetMaterial(MSP_BASE) to get the base material and save that.
	 * When getting the material for rendering/checking usage, GetMaterial(GCurrentMaterialPlatform) is fine.
	 *
	 * @param Platform - The platform to get material for.
	 */
	virtual UMaterial* GetMaterial(EMaterialShaderPlatform Platform = GCurrentMaterialPlatform);
    virtual UBOOL GetVectorParameterValue(FName ParameterName,FLinearColor& OutValue);
    virtual UBOOL GetScalarParameterValue(FName ParameterName,FLOAT& OutValue);
    virtual UBOOL GetTextureParameterValue(FName ParameterName,class UTexture*& OutValue);
	virtual UBOOL GetFontParameterValue(FName ParameterName,class UFont*& OutFontValue,INT& OutFontPage);

	/**
	 * Gets the value of the given static switch parameter
	 *
	 * @param	ParameterName	The name of the static switch parameter
	 * @param	OutValue		Will contain the value of the parameter if successful
	 * @return					True if successful
	 */
	virtual UBOOL GetStaticSwitchParameterValue(FName ParameterName,UBOOL &OutValue,FGuid &OutExpressionGuid);

	/**
	 * Gets the value of the given static component mask parameter
	 *
	 * @param	ParameterName	The name of the parameter
	 * @param	R, G, B, A		Will contain the values of the parameter if successful
	 * @return					True if successful
	 */
	virtual UBOOL GetStaticComponentMaskParameterValue(FName ParameterName, UBOOL &R, UBOOL &G, UBOOL &B, UBOOL &A, FGuid &OutExpressionGuid);

	/**
	* Gets the compression format of the given normal parameter
	*
	* @param	ParameterName	The name of the parameter
	* @param	CompressionSettings	Will contain the values of the parameter if successful
	* @return					True if successful
	*/
	virtual UBOOL GetNormalParameterValue(FName ParameterName, BYTE& OutCompressionSettings, FGuid &OutExpressionGuid);

	virtual FMaterialRenderProxy* GetRenderProxy(UBOOL Selected) const;
	virtual UPhysicalMaterial* GetPhysicalMaterial() const;

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
	UBOOL CompileStaticPermutation(
		FStaticParameterSet* StaticParameters,
		FMaterialResource* StaticPermutation,
		EShaderPlatform Platform,
		EMaterialShaderPlatform MaterialPlatform,
		UBOOL bFlushExistingShaderMaps,
		UBOOL bDebugDump);

	/**
	 * Compiles material resources for the current platform if the shader map for that resource didn't already exist.
	 *
	 * @param ShaderPlatform - platform to compile for
	 * @param bFlushExistingShaderMaps - forces a compile, removes existing shader maps from shader cache.
	 * @param bForceAllPlatforms - compile for all platforms, not just the current.
	 */
	void CacheResourceShaders(EShaderPlatform Platform, UBOOL bFlushExistingShaderMaps=FALSE, UBOOL bForceAllPlatforms=FALSE);

private:
	/**
	 * Flushes existing resource shader maps and resets the material resource's Ids.
	 */
	virtual void FlushResourceShaderMaps();

public:
	/**
	 * Gets the material resource based on the input platform
	 * @return - the appropriate FMaterialResource if one exists, otherwise NULL
	 */
	virtual FMaterialResource* GetMaterialResource(EMaterialShaderPlatform Platform = GCurrentMaterialPlatform);

	/** === USurface interface === */
	/**
	 * Method for retrieving the width of this surface.
	 *
	 * This implementation returns the maximum width of all textures applied to this material - not exactly accurate, but best approximation.
	 *
	 * @return	the width of this surface, in pixels.
	 */
	virtual FLOAT GetSurfaceWidth() const;
	/**
	 * Method for retrieving the height of this surface.
	 *
	 * This implementation returns the maximum height of all textures applied to this material - not exactly accurate, but best approximation.
	 *
	 * @return	the height of this surface, in pixels.
	 */
	virtual FLOAT GetSurfaceHeight() const;

	// UObject interface.
	/**
	 * Called before serialization on save to propagate referenced textures. This is not done
	 * during content cooking as the material expressions used to retrieve this information will
	 * already have been dissociated via RemoveExpressions
	 */
	void PreSave();

	virtual void AddReferencedObjects(TArray<UObject*>& ObjectArray);
	virtual void Serialize(FArchive& Ar);
	virtual void PostDuplicate();
	virtual void PostLoad();
	virtual void PreEditChange(UProperty* PropertyAboutToChange);
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void BeginDestroy();
	virtual UBOOL IsReadyForFinishDestroy();
	virtual void FinishDestroy();

	/**
	 * @return		Sum of the size of textures referenced by this material.
	 */
	virtual INT GetResourceSize();

	/**
	 * Null any material expression references for this material
	 *
	 * @param bRemoveAllExpressions If TRUE, the function will remove every expression and uniform expression from the material and its material resources
	 */
	void RemoveExpressions(UBOOL bRemoveAllExpressions=FALSE);

	UBOOL IsFallbackMaterial() { return bIsFallbackMaterial_DEPRECATED; }

	/**
	 * Goes through every material, flushes the specified types and re-initializes the material's shader maps.
	 */
	static void UpdateMaterialShaders(TArray<FShaderType*>& ShaderTypesToFlush, TArray<FVertexFactoryType*>& VFTypesToFlush);

	/**
	 * Adds an expression node that represents a parameter to the list of material parameters.
	 *
	 * @param	Expression	Pointer to the node that is going to be inserted if it's a parameter type.
	 */
	virtual UBOOL AddExpressionParameter(UMaterialExpression* Expression);

	/**
	 * Removes an expression node that represents a parameter from the list of material parameters.
	 *
	 * @param	Expression	Pointer to the node that is going to be removed if it's a parameter type.
	 */
	virtual UBOOL RemoveExpressionParameter(UMaterialExpression* Expression);

	/**
	 * A parameter with duplicates has to update its peers so that they all have the same value. If this step isn't performed then
	 * the expression nodes will not accurately display the final compiled material.
	 *
	 * @param	Parameter	Pointer to the expression node whose state needs to be propagated.
	 */
	virtual void PropagateExpressionParameterChanges(UMaterialExpression* Parameter);

	/**
	 * This function removes the expression from the editor parameters list (if it exists) and then re-adds it.
	 *
	 * @param	Expression	The expression node that represents a parameter that needs updating.
	 */
	virtual void UpdateExpressionParameterName(UMaterialExpression* Expression);

	/**
	 * Iterates through all of the expression nodes in the material and finds any parameters to put in EditorParameters.
	 */
	virtual void BuildEditorParameterList();

	/**
	 * Returns TRUE if the provided expression parameter has duplicates.
	 *
	 * @param	Expression	The expression parameter to check for duplicates.
	 */
	virtual UBOOL HasDuplicateParameters(UMaterialExpression* Expression);

	/**
	 * Returns TRUE if the provided expression dynamic parameter has duplicates.
	 *
	 * @param	Expression	The expression dynamic parameter to check for duplicates.
	 */
	virtual UBOOL HasDuplicateDynamicParameters(UMaterialExpression* Expression);

	/**
	 * Iterates through all of the expression nodes and fixes up changed names on
	 * matching dynamic parameters when a name change occurs.
	 *
	 * @param	Expression	The expression dynamic parameter.
	 */
	virtual void UpdateExpressionDynamicParameterNames(UMaterialExpression* Expression);

	/**
	 * Gets the name of a parameter.
	 *
	 * @param	Expression	The expression to retrieve the name from.
	 * @param	OutName		The variable that will hold the parameter name.
	 * @return	TRUE if the expression is a parameter with a name.
	 */
	static UBOOL GetExpressionParameterName(UMaterialExpression* Expression, FName& OutName);

	/**
	 * Copies the values of an expression parameter to another expression parameter of the same class.
	 *
	 * @param	Source			The source parameter.
	 * @param	Destination		The destination parameter that will receive Source's values.
	 */
	static UBOOL CopyExpressionParameters(UMaterialExpression* Source, UMaterialExpression* Destination);

	/**
	 * Returns TRUE if the provided expression node is a parameter.
	 *
	 * @param	Expression	The expression node to inspect.
	 */
	static UBOOL IsParameter(UMaterialExpression* Expression);

	/**
	 * Returns TRUE if the provided expression node is a dynamic parameter.
	 *
	 * @param	Expression	The expression node to inspect.
	 */
	static UBOOL IsDynamicParameter(UMaterialExpression* Expression);

	/**
	 * Returns the number of parameter groups. NOTE: The number returned can be innaccurate if you have parameters of different types with the same name.
	 */
	inline INT GetNumEditorParameters() const
	{
		return EditorParameters.Num();
	}

	/**
	 * Empties the editor parameters for the material.
	 */
	inline void EmptyEditorParameters()
	{
		EditorParameters.Empty();
	}

	/**
	 * Returns the lookup texture to be used in the physical material mask.  Tries to get the parents lookup texture if not overridden here. 
	 */
	virtual UTexture2D* GetPhysicalMaterialMaskTexture() const { return PhysMaterialMask; }

	/**
	 * Returns the black physical material to be used in the physical material mask.  Tries to get the parents black phys mat if not overridden here
	 */
	virtual UPhysicalMaterial* GetBlackPhysicalMaterial() const { return BlackPhysicalMaterial; }

	/**
	 * Returns the white physical material to be used in the physical material mask.  Tries to get the parents white phys mat if not overridden here. 
	 */
	virtual UPhysicalMaterial* GetWhitePhysicalMaterial() const { return WhitePhysicalMaterial; }

	/** 
	 * Returns the UV channel that should be used to look up physical material mask information 
	 */
	virtual INT GetPhysMaterialMaskUVChannel() const { return PhysMaterialMaskUVChannel; }

protected:
	/**
	 * Sets overrides in the material's static parameters
	 *
	 * @param	Permutation		The set of static parameters to override and their values
	 */
	void SetStaticParameterOverrides(const FStaticParameterSet* Permutation);

	/**
	 * Clears static parameter overrides so that static parameter expression defaults will be used
	 *	for subsequent compiles.
	 */
	void ClearStaticParameterOverrides();

public:
	/** Helper functions for text output of properties... */
	static const TCHAR* GetMaterialLightingModelString(EMaterialLightingModel InMaterialLightingModel);
	static EMaterialLightingModel GetMaterialLightingModelFromString(const TCHAR* InMaterialLightingModelStr);
	static const TCHAR* GetBlendModeString(EBlendMode InBlendMode);
	static EBlendMode GetBlendModeFromString(const TCHAR* InBlendModeStr);

	/**
	 *	Check if the textures have changed since the last time the material was
	 *	serialized for Lightmass... Update the lists while in here.
	 *	NOTE: This will mark the package dirty if they have changed.
	 *
	 *	@return	UBOOL	TRUE if the textures have changed.
	 *					FALSE if they have not.
	 */
	virtual UBOOL UpdateLightmassTextureTracking();

	/**
	*	Get the expression input for the given property
	*
	*	@param	InProperty				The material property chain to inspect, such as MP_DiffuseColor.
	*
	*	@return	FExpressionInput*		A pointer to the expression input of the property specified, 
	*									or NULL if an invalid property was requested.
	*/
	FExpressionInput* GetExpressionInputForProperty(EMaterialProperty InProperty);

	/**
	 *	Get the expression chain for the given property (ie fill in the given array with all expressions in the chain).
	 *
	 *	@param	InProperty				The material property chain to inspect, such as MP_DiffuseColor.
	 *	@param	OutExpressions			The array to fill in all of the expressions.
	 *
	 *	@return	UBOOL					TRUE if successful, FALSE if not.
	 */
	virtual UBOOL GetExpressionsInPropertyChain(EMaterialProperty InProperty, TArray<UMaterialExpression*>& OutExpressions);

	/**
	 *	Get all of the textures in the expression chain for the given property (ie fill in the given array with all textures in the chain).
	 *
	 *	@param	InProperty				The material property chain to inspect, such as MP_DiffuseColor.
	 *	@param	OutTextures				The array to fill in all of the textures.
	 *	@param	OutTextureParamNames	Optional array to fill in with texture parameter names.
	 *
	 *	@return	UBOOL			TRUE if successful, FALSE if not.
	 */
	virtual UBOOL GetTexturesInPropertyChain(EMaterialProperty InProperty, TArray<UTexture*>& OutTextures,  TArray<FName>* OutTextureParamNames);

protected:
	/**
	 *	Recursively retrieve the expressions contained in the chain of the given expression.
	 *
	 *	@param	InExpression			The expression to start at.
	 *	@param	InOutProcessedInputs	An array of processed expression inputs. (To avoid circular loops causing infinite recursion)
	 *	@param	OutExpressions			The array to fill in all of the expressions.
	 *
	 *	@return	UBOOL					TRUE if successful, FALSE if not.
	 */
	virtual UBOOL RecursiveGetExpressionChain(UMaterialExpression* InExpression, TArray<FExpressionInput*>& InOutProcessedInputs, TArray<UMaterialExpression*>& OutExpressions);

	/**
	*	Recursively update the bRealtimePreview for each expression based on whether it is connected to something that is time-varying.
	*	This is determined based on the result of UMaterialExpression::NeedsRealtimePreview();
	*
	*	@param	InExpression				The expression to start at.
	*	@param	InOutExpressionsToProcess	Array of expressions we still need to process.
	*
	*/
	void RecursiveUpdateRealtimePreview(UMaterialExpression* InExpression, TArray<UMaterialExpression*>& InOutExpressionsToProcess);


	friend class FLightmassMaterialProxy;
};

defaultproperties
{
	BlendMode=BLEND_Opaque
	DiffuseColor=(Constant=(R=128,G=128,B=128))
	DiffusePower=(Constant=1.0)
	SpecularColor=(Constant=(R=128,G=128,B=128))
	SpecularPower=(Constant=15.0)
	Distortion=(ConstantX=0,ConstantY=0)
	Opacity=(Constant=1)
	OpacityMask=(Constant=1)
	OpacityMaskClipValue=0.3333
	TwoSidedLightingColor=(Constant=(R=255,G=255,B=255))
	bAllowFog=TRUE
	bUsedWithStaticLighting=FALSE
	bAllowLightmapSpecular=TRUE
	PhysMaterialMaskUVChannel=-1
}
