/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleLifetime extends ParticleModuleLifetimeBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/** The lifetime of the particle, in seconds. Retrieved using the EmitterTime at the spawn of the particle. */
var(Lifetime) rawdistributionfloat	Lifetime;

cpptext
{
	virtual void	Spawn(FParticleEmitterInstance* Owner, INT Offset, FLOAT SpawnTime);

	/**
	 *	Called when the module is created, this function allows for setting values that make
	 *	sense for the type of emitter they are being used in.
	 *
	 *	@param	Owner			The UParticleEmitter that the module is being added to.
	 */
	virtual void SetToSensibleDefaults(UParticleEmitter* Owner);

	virtual FLOAT	GetMaxLifetime();
}

defaultproperties
{
	bSpawnModule=true

	Begin Object Class=DistributionFloatUniform Name=DistributionLifetime
	End Object
	Lifetime=(Distribution=DistributionLifetime)
}
