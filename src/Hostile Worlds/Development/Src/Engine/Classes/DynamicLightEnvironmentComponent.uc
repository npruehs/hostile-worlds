/**
 * This is used to light components / actors during the game.  Doing something like:
 * LightEnvironment=FooLightEnvironment
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class DynamicLightEnvironmentComponent extends LightEnvironmentComponent
	native(Light);

/** The current state of the light environment. */
var private native transient const pointer State{class FDynamicLightEnvironmentState};

/** The number of seconds between light environment updates for actors which aren't visible. */
var float InvisibleUpdateTime;

/** Minimum amount of time that needs to pass between full environment updates. */
var float MinTimeBetweenFullUpdates;

/** 
 * Speed to interpolate the current shadow to the newly captured shadow.  
 * A value of .01 means the interpolation will be complete after the DLE moves 100 Unreal Units. 
 */
var float ShadowInterpolationSpeed;

/** The number of visibility samples to use within the primitive's bounding volume. */
var() int NumVolumeVisibilitySamples;

/** Scales the bounds used for light environment calculations. */
var() float LightingBoundsScale;

/** The color of the ambient shadow. */
var LinearColor AmbientShadowColor;

/** The direction of the ambient shadow source. */
var vector AmbientShadowSourceDirection;

/** Ambient color added in addition to the level's lighting. */
var LinearColor AmbientGlow;

/** Desaturation percentage of level lighting, which can be used to help team colored characters stand out better under colored lighting. */
var float LightDesaturation;

/** The distance to create the light from the owner's origin, in radius units. */
var float LightDistance;

/** The distance for the shadow to project beyond the owner's origin, in radius units. */
var float ShadowDistance;

/** Whether the light environment should cast shadows */
var() bool bCastShadows;

/** Whether the light environment's shadow includes the effect of dynamic lights. */
var bool bCompositeShadowsFromDynamicLights;

/** Whether to represent all lights with the light environment, including dominant lights which are usually rendered separately. */
var bool bForceCompositeAllLights;

/** 
 * Whether to use cheap on/off shadowing from the environment or allow a dynamic preshadow. 
 */
var() bool bUseBooleanEnvironmentShadowing;

/** Time since the caster was last visible at which the mod shadow will fade out completely.  */
var float ModShadowFadeoutTime;

/** Exponent that controls mod shadow fadeout curve. */
var float ModShadowFadeoutExponent;

/** Brightest ModulatedShadowColor allowed for the shadow.  This can be used to limit the DLE's shadow to a specified darkness. */
var LinearColor MaxModulatedShadowColor;

/** 
 * The distance from the dominant light shadow transition at which to start fading out the DLE's modulated shadow and primary light. 
 * This must be larger than DominantShadowTransitionEndDistance.
 */
var float DominantShadowTransitionStartDistance;

/** 
 * The distance from the dominant light shadow transition at which to end fading out the DLE's modulated shadow and primary light. 
 * This must be smaller than DominantShadowTransitionStartDistance.
 */
var float DominantShadowTransitionEndDistance;

/**
 * Override for min dimensions (in texels) allowed for rendering shadow subject depths.
 * This also controls shadow fading, once the shadow resolution reaches MinShadowResolution it will be faded out completely.
 * A value of 0 defaults to MinShadowResolution in SystemSettings.
 */
var int MinShadowResolution;

/**
 * Override for max square dimensions (in texels) allowed for rendering shadow subject depths.
 * A value of 0 defaults to MaxShadowResolution in SystemSettings.
 */
var int MaxShadowResolution;

/** 
 * Resolution in texels below which shadows begin to be faded out. 
 * Once the shadow resolution reaches MinShadowResolution it will be faded out completely.
 * A value of 0 defaults to ShadowFadeResolution in SystemSettings.
 */
var int ShadowFadeResolution;

/** Quality of shadow buffer filtering to use on the light environment */
var EShadowFilterQuality ShadowFilterQuality;

/** Whether the light environment should be dynamically updated. */
var() bool bDynamic;

/** Whether a directional light should be used to synthesize the dominant lighting in the environment. */
var bool bSynthesizeDirectionalLight;

/**
 * Whether a SH light should be used to synthesize all light not accounted for by the synthesized directional light.
 * If not, a sky light is used instead.  Using an SH light gives higher quality secondary lighting, but at a steeper performance cost.
 */
var() bool bSynthesizeSHLight;

/** 
 * This is to allow individual DLEs to force override and get and SH light.  We need this for levels which have their
 * worldinfo's bAllowLightEnvSphericalHarmonicLights set to FALSE but then have cinematic levels added which were lit needing SH lights
 * to look good.
 **/
var bool bForceAllowLightEnvSphericalHarmonicLights;


/** The type of shadowing to use for the environment's shadow. */
var ELightShadowMode LightShadowMode;

/** The intensity of the simulated bounced light, as a fraction of the LightComponent's bounced lighting settings. */
var float BouncedLightingFactor;

/**
 * The minimum angle to allow between the shadow direction and horizontal.  An angle > 0 constrains the shadow to never be cast from a light
 * below horizontal.
 */
var float MinShadowAngle;

/** Whether this is an actor that can't tolerate latency in lighting updates; a full lighting update is done every frame. */
var bool bRequiresNonLatentUpdates;

/* 
 * Whether to do visibility traces from the closest point on the bounds to the light, or just from the center of the bounds. 
 * This is useful when using a DLE on an object that is likely embedded in shadow casting objects (ie fractured meshes).
 */
var bool bTraceFromClosestBoundsPoint;

/** 
 * Whether this light environment is being applied to a character 
 * And should be affected by character specific lighting like WorldInfo's CharacterLightingContrastFactor. 
 */
var bool bIsCharacterLightEnvironment;

/** 
 * Methods used to calculate the bounds that this light environment will use as a representation of what it is lighting.
 * The default settings will trace one ray from the center of the calculated bounds to each relevant light.
 */
enum EDynamicLightEnvironmentBoundsMethod
{
	/** The default DLE bounds method, starts with a small sphere at the Owner's origin and adds each component of Owner using this DLE. */
	DLEB_OwnerComponents,
	/** Uses OverriddenBounds, doesn't depend on Owner at all. */
	DLEB_ManualOverride,
	/** 
	 * Accumulates the bounds of attached components on any actor using this DLE.  
	 * This is useful when the DLE is lighting something whose Owner is placed in the world, like a pool actor.
	 * This method only works when the components using this DLE are attached before the DLE is updated.
	 */
	DLEB_ActiveComponents
};

var EDynamicLightEnvironmentBoundsMethod BoundsMethod;

/* The bounds to use for visibility calculations if BoundsMethod==DLEB_ManualOverride. */
var BoxSphereBounds OverriddenBounds;

/* Whether to override the lighting channels of the owner with OverriddenLightingChannels. */
var bool bOverrideOwnerLightingChannels;

/* The lighting channels to use if bOverrideOwnerLightingChannels is enabled. */
var LightingChannelContainer OverriddenLightingChannels;

/** Light components which override lights in GWorld, useful for rendering light environments in preview scenes. */
var const array<LightComponent> OverriddenLightComponents;

cpptext
{
	// UObject interface.
	virtual void FinishDestroy();
	virtual void AddReferencedObjects( TArray<UObject*>& ObjectArray );
	virtual void Serialize(FArchive& Ar);
	virtual void PostLoad();
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	// UActorComponent interface.
	virtual void Tick(FLOAT DeltaTime);
	virtual void Attach();
	virtual void UpdateTransform();
	virtual void Detach( UBOOL bWillReattach = FALSE );
	virtual void BeginPlay();
	virtual void CheckForErrors();

	// ULightEnvironmentComponent interface.
	virtual void UpdateLight(const ULightComponent* Light);

	friend class FDynamicLightEnvironmentState;
}

/* Forces a full update the of the dynamic and static environments on the next Tick. */
native final function ResetEnvironment();

defaultproperties
{
	InvisibleUpdateTime=5.0
`if(`notdefined(MOBILE))
	MinTimeBetweenFullUpdates=1.0
`else
	MinTimeBetweenFullUpdates=0.25
`endif
	NumVolumeVisibilitySamples=1
	LightingBoundsScale=1
	// Using a relatively slow speed so that the shadow is mostly interpolating which hides the low update frequency
	ShadowInterpolationSpeed=.004
	AmbientShadowColor=(R=0.001,G=0.001,B=0.001)
	AmbientShadowSourceDirection=(X=0.01,Y=0,Z=0.99)
	LightDistance=10.0
	ShadowDistance=5.0
	// bRequiresNonLatentUpdates sets it to TG_PostUpdateWork in BeginPlay()
	TickGroup=TG_DuringAsyncWork
	bCastShadows=TRUE
	bCompositeShadowsFromDynamicLights=TRUE
	// Cheap default
	bUseBooleanEnvironmentShadowing=TRUE
	ModShadowFadeoutExponent=3.0
    MaxModulatedShadowColor=(R=0.5,G=0.5,B=0.5)
    DominantShadowTransitionStartDistance=100
    DominantShadowTransitionEndDistance=10
	MinShadowResolution=0
	MaxShadowResolution=0
	ShadowFadeResolution=0
	ShadowFilterQuality=SFQ_Low
	bDynamic=TRUE
	LightShadowMode=LightShadow_Modulate
	bSynthesizeDirectionalLight=TRUE
	bSynthesizeSHLight=FALSE
	BouncedLightingFactor=1.0
	MinShadowAngle=25.0
	BoundsMethod=DLEB_OwnerComponents
}
