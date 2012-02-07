/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleVelocity extends ParticleModuleVelocityBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/** 
 *	The velocity to apply to a particle when it is spawned.
 *	Value is retrieved using the EmitterTime of the emitter.
 */
var(Velocity) rawdistributionvector	StartVelocity;
/** 
 *	The velocity to apply to a particle along its radial direction.
 *	Direction is determined by subtracting the location of the emitter from the particle location at spawn.
 *	Value is retrieved using the EmitterTime of the emitter.
 */
var(Velocity) rawdistributionfloat	StartVelocityRadial;

cpptext
{
	virtual void	Spawn(FParticleEmitterInstance* Owner, INT Offset, FLOAT SpawnTime);
}

defaultproperties
{
	bSpawnModule=true

	Begin Object Class=DistributionVectorUniform Name=DistributionStartVelocity
	End Object
	StartVelocity=(Distribution=DistributionStartVelocity)

	Begin Object Class=DistributionFloatUniform Name=DistributionStartVelocityRadial
	End Object
	StartVelocityRadial=(Distribution=DistributionStartVelocityRadial)
}
