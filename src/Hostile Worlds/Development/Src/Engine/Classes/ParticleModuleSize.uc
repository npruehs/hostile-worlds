/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleSize extends ParticleModuleSizeBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/**
 *	The initial size that should be used for a particle.
 *	The value is retrieved using the EmitterTime during the spawn of a particle.
 *	It is added to the Size and BaseSize fields of the spawning particle.
 */
var(Size) rawdistributionvector	StartSize;

cpptext
{
	virtual void	Spawn(FParticleEmitterInstance* Owner, INT Offset, FLOAT SpawnTime);
}

defaultproperties
{
	bSpawnModule=true
	bUpdateModule=false

	Begin Object Class=DistributionVectorUniform Name=DistributionStartSize
		Min=(X=1,Y=1,Z=1)
		Max=(X=1,Y=1,Z=1)
	End Object
	StartSize=(Distribution=DistributionStartSize)
}
