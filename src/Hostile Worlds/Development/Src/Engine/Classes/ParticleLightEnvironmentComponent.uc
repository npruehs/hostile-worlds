/**
 * Light environment class used by particle systems.
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class ParticleLightEnvironmentComponent extends DynamicLightEnvironmentComponent
	native(Light);

/** Reference count used to know when this light environment can be detached and cleaned up since it may be shared by multiple particle system components. */
var transient protected{protected} const int ReferenceCount;

/** 
 * Whether this DLE can be used with components of the same actor.
 * This should be set to FALSE when attaching a UParticleSystemComponent on a pool actor.
 */
var bool bAllowDLESharing;

cpptext
{
	inline void AddRef() { ReferenceCount++; }
	inline void RemoveRef() 
	{ 
		check(ReferenceCount > 0);
		ReferenceCount--; 
	}
	inline INT GetRefCount() const { return ReferenceCount; }

	virtual void UpdateLight(const ULightComponent* Light);

	// UActorComponent interface.
	virtual void Tick(FLOAT DeltaTime);
}

defaultproperties
{
	ReferenceCount=1
	// Never allow sharing for now to ensure pooling works
	bAllowDLESharing=false
	// Cheap defaults, can be set to dynamic if needed
	bDynamic=false
	// Particles are most likely translucent, translucency needs line-check shadowing from dominant lights.
	bForceCompositeAllLights=true
	InvisibleUpdateTime=10.0
	MinTimeBetweenFullUpdates=3.0
	// Using DLEB_ActiveComponents instead of DLEB_OwnerComponents to prevent the Owner's position from affecting the bounds, which is necessary for pooled particle components.
	BoundsMethod=DLEB_ActiveComponents
}
