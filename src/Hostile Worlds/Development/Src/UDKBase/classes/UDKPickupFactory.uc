/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKPickupFactory extends PickupFactory
	abstract
	native
	nativereplication
	hidecategories(Display,Collision,PickupFactory);

var repnotify bool bIsRespawning;

/** When set to true, this base will begin pulsing its emissive */
var repnotify bool bPulseBase;

/** In disabled state */
var repnotify bool bIsDisabled;

/**  pickup base mesh */
var transient StaticMeshComponent BaseMesh;

/** Used to pulse the emissive on the base */
var MaterialInstanceConstant BaseMaterialInstance;

/** The baseline material colors */
var LinearColor BaseBrightEmissive;		// When the pickup is on the base
var LinearColor	BaseDimEmissive;		// When the pickup isn't on the base

/** How fast does the base pulse */
var float BasePulseRate;

/** How much time left in the current pulse */
var float BasePulseTime;

/** This pickup base will begin pulsing when there are PulseThreshold seconds left before respawn. */
var float PulseThreshold;

/** The TargetEmissive Color */
var LinearColor BaseTargetEmissive;
var LinearColor BaseEmissive;

/** This material instance parameter for adjusting the emissive */
var name BaseMaterialParamName;

var	bool	bFloatingPickup;	// if true, the pickup mesh floats (bobs) slightly
var	bool	bRandomStart;		// if true, this pickup will start at a random height
var				float 	BobTimer;			// Tracks the bob time.  Used to create the position
var				float 	BobOffset;			// How far to bob.  It will go from +/- this number
var				float 	BobSpeed;			// How fast should it bob
var				float	BobBaseOffset;		// The base offset (Translation.Y) cached

var		bool			bRotatingPickup;	// if true, the pickup mesh rotates
var		float			YawRotationRate;


/** whether this pickup is updating */
var bool bUpdatingPickup;

/** Translation of pivot point */
var vector PivotTranslation;

/** Determines whether this pickup fades in or not when respawning. */
var bool bDoVisibilityFadeIn;
var name VisibilityParamName;

/** holds the pickups material so parameters can be set **/
var MaterialInstanceConstant MIC_Visibility;

/** holds the pickups 2nd material so parameters can be set **/
var MaterialInstanceConstant MIC_VisibilitySecondMaterial;

/** the glowing effect that comes from the base on spawn. */
var ParticleSystemComponent Glow; 
var name GlowEmissiveParam;

/** extra spinning component (rotated in C++ when visible) */
var PrimitiveComponent Spinner;

/** spinning particles (rotated in C++ when visible) */
var UDKParticleSystemComponent SpinningParticleEffects;
	
cpptext
{
	virtual void TickSpecial( FLOAT DeltaSeconds );
	virtual void PostEditMove(UBOOL bFinished);
	virtual void Spawned();
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
}

replication
{
	if ( bNetDirty && (Role == Role_Authority) )
		bPulseBase,bIsRespawning;
	if (bNetInitial && ROLE==ROLE_Authority )
		bIsDisabled;
}

/** 
  * Make pickup mesh and associated effects visible.
  */
simulated function SetPickupVisible()
{
	if(SpinningParticleEffects != none)
	{
		SpinningParticleEffects.SetActive(true);
	}
	super.SetPickupVisible();
}

/** 
  * Make pickup mesh and associated effects hidden.
  */
simulated function SetPickupHidden()
{
	if(SpinningParticleEffects != none)
		SpinningParticleEffects.DeactivateSystem();
		
	super.SetPickupHidden();
}

