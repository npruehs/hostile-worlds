/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 */
class ParticleModuleParameterDynamic extends ParticleModuleParameterBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/**
 *	EmitterDynamicParameterValue
 *	Enumeration indicating the way a dynamic parameter should be set.
 */
enum EEmitterDynamicParameterValue
{
	/** UserSet - use the user set values in the distribution (the default) */
	EDPV_UserSet,
	/** VelocityX - pass the particle velocity along the X-axis thru */
	EDPV_VelocityX,
	/** VelocityY - pass the particle velocity along the Y-axis thru */
	EDPV_VelocityY,
	/** VelocityZ - pass the particle velocity along the Z-axis thru */
	EDPV_VelocityZ,
	/** VelocityMag - pass the particle velocity magnitude thru */
	EDPV_VelocityMag
};

/** Helper structure for displaying the parameter. */
struct native EmitterDynamicParameter
{
	/** The parameter name - from the material DynamicParameter expression. READ-ONLY */
	var() editconst name					ParamName;
	/** If TRUE, use the EmitterTime to retrieve the value, otherwise use Particle RelativeTime. */
	var() bool								bUseEmitterTime;
	/** If TRUE, only set the value at spawn time of the particle, otherwise update each frame. */
	var() bool								bSpawnTimeOnly;
	/** Where to get the parameter value from. */
	var() EEmitterDynamicParameterValue		ValueMethod;
	/** If TRUE, scale the velocity value selected in ValueMethod by the evaluated ParamValue. */
	var() bool								bScaleVelocityByParamValue;
	/** The distriubtion for the parameter value. */
	var() rawdistributionfloat				ParamValue;
};

/** The dynamic parameters this module uses. */
var() editfixedsize array<EmitterDynamicParameter>	DynamicParams;

cpptext
{
	/**
	 *	Called on a particle that is freshly spawned by the emitter.
	 *	
	 *	@param	Owner		The FParticleEmitterInstance that spawned the particle.
	 *	@param	Offset		The modules offset into the data payload of the particle.
	 *	@param	SpawnTime	The time of the spawn.
	 */
	virtual void	Spawn(FParticleEmitterInstance* Owner, INT Offset, FLOAT SpawnTime);
	/**
	 *	Called on a particle that is being updated by its emitter.
	 *	
	 *	@param	Owner		The FParticleEmitterInstance that 'owns' the particle.
	 *	@param	Offset		The modules offset into the data payload of the particle.
	 *	@param	DeltaTime	The time since the last update.
	 */
	virtual void	Update(FParticleEmitterInstance* Owner, INT Offset, FLOAT DeltaTime);

	/**
	 *	Returns the number of bytes that the module requires in the particle payload block.
	 *
	 *	@param	Owner		The FParticleEmitterInstance that 'owns' the particle.
	 *
	 *	@return	UINT		The number of bytes the module needs per particle.
	 */
	virtual UINT	RequiredBytes(FParticleEmitterInstance* Owner = NULL);

	// For Cascade
	/**
	 *	Called when the module is created, this function allows for setting values that make
	 *	sense for the type of emitter they are being used in.
	 *
	 *	@param	Owner			The UParticleEmitter that the module is being added to.
	 */
	virtual void SetToSensibleDefaults(UParticleEmitter* Owner);

	/** 
	 *	PostEditChange...
	 */
	virtual void	PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/** 
	 *	Fill an array with each Object property that fulfills the FCurveEdInterface interface.
	 *
	 *	@param	OutCurve	The array that should be filled in.
	 */
	virtual void	GetCurveObjects(TArray<FParticleCurvePair>& OutCurves);

	/**
	 *	Returns TRUE if the results of LOD generation for the given percentage will result in a 
	 *	duplicate of the module.
	 *
	 *	@param	SourceLODLevel		The source LODLevel
	 *	@param	DestLODLevel		The destination LODLevel
	 *	@param	Percentage			The percentage value that should be used when setting values
	 *
	 *	@return	UBOOL				TRUE if the generated module will be a duplicate.
	 *								FALSE if not.
	 */
	virtual UBOOL WillGeneratedModuleBeIdentical(UParticleLODLevel* SourceLODLevel, UParticleLODLevel* DestLODLevel, FLOAT Percentage)
	{
		// The assumption is that at 100%, ANY module will be identical...
		// (Although this is virtual to allow over-riding that assumption on a case-by-case basis!)
		return TRUE;
	}

	/**
	 *	Retrieve the ParticleSysParams associated with this module.
	 *
	 *	@param	ParticleSysParamList	The list of FParticleSysParams to add to
	 */
	virtual void GetParticleSysParamsUtilized(TArray<FString>& ParticleSysParamList);

	/**
	 *	Retrieve the distributions that use ParticleParameters in this module.
	 *
	 *	@param	ParticleParameterList	The list of ParticleParameter distributions to add to
	 */
	virtual void GetParticleParametersUtilized(TArray<FString>& ParticleParameterList);
	
	/**
	 *	Update the parameter names with the given material...
	 *
	 *	@param	InMaterialInterface	Pointer to the material interface
	 *	@param	bIsMeshEmitter		TRUE if the emitter is a mesh emitter...
	 *
	 */
	virtual void UpdateParameterNames(UMaterialInterface* InMaterialInterface, UBOOL bIsMeshEmitter);

	/**
	 *	Refresh the module...
	 */
	virtual void RefreshModule(UInterpCurveEdSetup* EdSetup, UParticleEmitter* InEmitter, INT InLODLevel);
	
	/**
	 *	Retrieve the value for the parameter at the given index.
	 *
	 *	@param	ParamIndex		The index of the parameter we are interested on.
	 *	@param	Particle		The particle we are getting the value for.
	 *	@param	Owner			The FParticleEmitterInstance owner of the particle.
	 *
	 *	@return	FLOAT			The value for the parameter.
	 */
	inline FLOAT GetParameterValue(INT ParamIndex, FBaseParticle& Particle, FParticleEmitterInstance* Owner)
	{
		FEmitterDynamicParameter& DynParams = DynamicParams(ParamIndex);
		FLOAT DistributionValue = 1.0f;
		if ((DynParams.bScaleVelocityByParamValue == TRUE) || (DynParams.ValueMethod == EDPV_UserSet))
		{
			DistributionValue = (DynParams.bUseEmitterTime ? 
				DynParams.ParamValue.GetValue(Owner->EmitterTime, Owner->Component) :
				DynParams.ParamValue.GetValue(Particle.RelativeTime, Owner->Component));
		}
		
		switch (DynParams.ValueMethod)
		{
		case EDPV_VelocityX:
			return Particle.Velocity.X * DistributionValue;
		case EDPV_VelocityY:
			return Particle.Velocity.Y * DistributionValue;
		case EDPV_VelocityZ:
			return Particle.Velocity.Z * DistributionValue;
		case EDPV_VelocityMag:
			return Particle.Velocity.Size() * DistributionValue;
		}
		//case EDPV_UserSet:
		return DistributionValue;
	}
}

defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true

	Begin Object Class=DistributionFloatConstant Name=DistributionParam1
	End Object
	DynamicParams(0)=(ParamName="",bUseEmitterTime=false,ValueMethod=EDPV_UserSet,ParamValue=(Distribution=DistributionParam1))
	Begin Object Class=DistributionFloatConstant Name=DistributionParam2
	End Object
	DynamicParams(1)=(ParamName="",bUseEmitterTime=false,ValueMethod=EDPV_UserSet,ParamValue=(Distribution=DistributionParam2))
	Begin Object Class=DistributionFloatConstant Name=DistributionParam3
	End Object
	DynamicParams(2)=(ParamName="",bUseEmitterTime=false,ValueMethod=EDPV_UserSet,ParamValue=(Distribution=DistributionParam3))
	Begin Object Class=DistributionFloatConstant Name=DistributionParam4
	End Object
	DynamicParams(3)=(ParamName="",bUseEmitterTime=false,ValueMethod=EDPV_UserSet,ParamValue=(Distribution=DistributionParam4))
}
