//=============================================================================
// ParticleModuleLocationPrimitiveCylinder
// Location primitive spawning within a cylinder.
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class ParticleModuleLocationPrimitiveCylinder extends ParticleModuleLocationPrimitiveBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/** If TRUE, get the particle velocity form the radial distance inside the primitive. */
var(Location) bool					RadialVelocity;
/** The radius of the cylinder. */
var(Location) rawdistributionfloat	StartRadius;
/** The height of the cylinder, centered about the location. */
var(Location) rawdistributionfloat	StartHeight;

enum CylinderHeightAxis
{
	PMLPC_HEIGHTAXIS_X,
	PMLPC_HEIGHTAXIS_Y,
	PMLPC_HEIGHTAXIS_Z
};

/** Determines particle particle system axis that should represent the height of the cylinder.
 *	Can be one of the following:
 *		PMLPC_HEIGHTAXIS_X		Orient the height along the particle system X-axis.
 *		PMLPC_HEIGHTAXIS_Y		Orient the height along the particle system Y-axis.
 *		PMLPC_HEIGHTAXIS_Z		Orient the height along the particle system Z-axis.
 */
var(Location) CylinderHeightAxis	HeightAxis;

cpptext
{
	virtual void	Spawn(FParticleEmitterInstance* Owner, INT Offset, FLOAT SpawnTime);
	virtual void	Render3DPreview(FParticleEmitterInstance* Owner, const FSceneView* View,FPrimitiveDrawInterface* PDI);
}

defaultproperties
{
	RadialVelocity=true

	Begin Object Class=DistributionFloatConstant Name=DistributionStartRadius
		Constant=50.0
	End Object
	StartRadius=(Distribution=DistributionStartRadius)

	Begin Object Class=DistributionFloatConstant Name=DistributionStartHeight
		Constant=50.0
	End Object
	StartHeight=(Distribution=DistributionStartHeight)

	bSupported3DDrawMode=true

	HeightAxis=PMLPC_HEIGHTAXIS_Z
}
