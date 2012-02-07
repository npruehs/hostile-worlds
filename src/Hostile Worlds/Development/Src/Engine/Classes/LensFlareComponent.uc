/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class LensFlareComponent extends PrimitiveComponent
	native(LensFlare)
	hidecategories(Object)
	hidecategories(Physics)
	hidecategories(Collision)
	editinlinenew
	dependson(LensFlare);

var()	const			LensFlare							Template;
var		const			DrawLightConeComponent				PreviewInnerCone;
var		const			DrawLightConeComponent				PreviewOuterCone;
var		const			DrawLightRadiusComponent			PreviewRadius;

struct LensFlareElementInstance
{
	// No UObject reference
};

/** If TRUE, automatically enable this flare when it is attached */
var()								bool					bAutoActivate;

/** Internal variables */
var transient						bool					bIsActive;
var	transient						bool					bHasTranslucency;
var	transient						bool					bHasUnlitTranslucency;
var	transient						bool					bHasUnlitDistortion;
var	transient						bool					bUsesSceneColor;

/** Viewing cone angles. */
var transient						float					OuterCone;
var transient						float					InnerCone;
var transient						float					ConeFudgeFactor;
var transient						float					Radius;

/** The color of the source	*/
var(Rendering)						linearcolor				SourceColor;

/** Storage for mobile as to whether this lens flare was visible based on a line check on previous check*/
var bool bVisibleForMobile;

struct native LensFlareElementMaterials
{
	var() array<MaterialInterface>	ElementMaterials;
};

/** Per-element material overrides.  These must NOT be set directly or a race condition can occur between GC and the rendering thread. */
var transient array<LensFlareElementMaterials>				Materials;

/** Command fence used to shut down properly */
var		native				const	pointer					ReleaseResourcesFence{class FRenderCommandFence};

native final function SetTemplate(LensFlare NewTemplate, bool bForceSet=FALSE);
native		 function SetSourceColor(linearcolor InSourceColor);
native		 function SetIsActive(bool bInIsActive);

cpptext
{
	// UObject interface
	virtual void BeginDestroy();
	virtual UBOOL IsReadyForFinishDestroy();
	virtual void FinishDestroy();
	virtual void PreEditChange(UProperty* PropertyThatWillChange);
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void PostLoad();

	// UActorComponent interface.
	virtual void Attach();

public:
	// UPrimitiveComponent interface
	virtual void UpdateBounds();
	virtual void Tick(FLOAT DeltaTime);

	/** 
	 *	Setup the Materials array for the lens flare component.
	 *	
	 *	@param	bForceReset		If TRUE, reset the array and refill it from the template.
	 */
	void SetupMaterialsArray(UBOOL bForceReset);

	virtual INT GetNumElements() const;
	virtual UMaterialInterface* GetElementMaterial(INT MaterialIndex) const;
	virtual void SetElementMaterial(INT ElementIndex, UMaterialInterface* InMaterial);

	/**
	 * Retrieves the materials used in this component
	 *
	 * @param OutMaterials	The list of used materials.
	 */
	virtual void GetUsedMaterials( TArray<UMaterialInterface*>& OutMaterials ) const;

	/** Returns true if the prim is using a material with unlit distortion */
	virtual UBOOL HasUnlitDistortion() const;
	/** Returns true if the prim is using a material with unlit translucency */
	virtual UBOOL HasUnlitTranslucency() const;
	/** Returns true if the prim is using a material with lit translucency */
	virtual UBOOL HasLitTranslucency() const;

	/**
	* Returns true if the prim is using a material that samples the scene color texture.
	* If true then these primitives are drawn after all other translucency
	*/
	virtual UBOOL UsesSceneColor() const;

	virtual FPrimitiveSceneProxy* CreateSceneProxy();

	// InstanceParameters interface
	void	AutoPopulateInstanceProperties();
}

defaultproperties
{
	bAutoActivate=true
	bTickInEditor=true
	TickGroup=TG_PostAsyncWork
	bAllowApproximateOcclusion=false
	bFirstFrameOcclusion=true
	bIgnoreNearPlaneIntersection=true

	SourceColor=(R=1.0,G=1.0,B=1.0,A=1.0)

	bVisibleForMobile=false;
}
