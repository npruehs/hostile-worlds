/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleRotation extends ParticleModuleRotationBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/**
 *	Initial rotation of the particle (1 = 360 degrees).
 *	The value is retrieved using the EmitterTime.
 */
var(Rotation) rawdistributionfloat	StartRotation;

cpptext
{
	virtual void	Spawn(FParticleEmitterInstance* Owner, INT Offset, FLOAT SpawnTime);
}

defaultproperties
{
	bSpawnModule=true

	Begin Object Class=DistributionFloatUniform Name=DistributionStartRotation
		Min=0.0
		Max=1.0
	End Object
	StartRotation=(Distribution=DistributionStartRotation)
}

