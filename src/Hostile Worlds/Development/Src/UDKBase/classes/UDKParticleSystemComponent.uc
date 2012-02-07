/**
 * Special Particle system component that can handle rendering at a different FOV than the the world.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKParticleSystemComponent extends ParticleSystemComponent
	native;

/** Used when a custom FOV is set to make sure the particles render properly using the custom FOV */
var public{private} const float FOV;
var public{private} const bool bHasSavedScale3D;
var public{private} const vector SavedScale3D;


cpptext
{
private:
	/** Override LocalToWorld with custom FOV changes */
	virtual void SetTransformedToWorld();
	virtual void InitParticles();
}


/** This changes the FOV used for rendering the particle system component. A value of 0 means to use the default. */
native final function SetFOV(float NewFOV);

defaultproperties
{
	bAcceptsLights=false
	bOverrideLODMethod=true
	LODMethod=PARTICLESYSTEMLODMETHOD_DirectSet
	SecondsBeforeInactive=1.0f
}
