/**
 *	ParticleModuleColorScaleOverLife
 *
 *	The base class for all Beam modules.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class ParticleModuleColorScaleOverLife extends ParticleModuleColorBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/** The scale factor for the color.													*/
var(Color)				rawdistributionvector	ColorScaleOverLife;

/** The scale factor for the alpha.													*/
var(Color)				rawdistributionfloat	AlphaScaleOverLife;

/** Whether it is EmitterTime or ParticleTime related.								*/
var(Color)				bool					bEmitterTime;

cpptext
{
	virtual void	Spawn(FParticleEmitterInstance* Owner, INT Offset, FLOAT SpawnTime);
	virtual void	Update(FParticleEmitterInstance* Owner, INT Offset, FLOAT DeltaTime);
	/**
	 *	Called when the module is created, this function allows for setting values that make
	 *	sense for the type of emitter they are being used in.
	 *
	 *	@param	Owner			The UParticleEmitter that the module is being added to.
	 */
	virtual void SetToSensibleDefaults(UParticleEmitter* Owner);
}

defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true
	bCurvesAsColor=true

	Begin Object Class=DistributionVectorConstantCurve Name=DistributionColorScaleOverLife
	End Object
	ColorScaleOverLife=(Distribution=DistributionColorScaleOverLife)

	Begin Object Class=DistributionFloatConstant Name=DistributionAlphaScaleOverLife
		Constant=1.0f;
	End Object
	AlphaScaleOverLife=(Distribution=DistributionAlphaScaleOverLife)
}
