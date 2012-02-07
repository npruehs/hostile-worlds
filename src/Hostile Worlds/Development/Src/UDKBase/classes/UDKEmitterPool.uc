/**
 * 
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKEmitterPool extends EmitterPool
	native;

/** info about attached explosion lights */
struct native AttachedExplosionLight
{
	var UDKExplosionLight Light;
	var Actor Base;
	var vector RelativeLocation;
};
var array<AttachedExplosionLight> RelativeExplosionLights;

cpptext
{
	virtual void TickSpecial(FLOAT DeltaTime);
}

/**
  * Support for particle emitter LOD based on "drop detail" (when frame rate is low) and distance.
  */
function ParticleSystemComponent SpawnEmitter(ParticleSystem EmitterTemplate, vector SpawnLocation, optional rotator SpawnRotation, optional Actor AttachToActor, optional bool bInheritScaleFromBase)
{
	local PlayerController PC;
	local int LODLevel;
	local ParticleSystemComponent PSC;

	if( EmitterTemplate == none )
	{
		`log( "UDKEmitterPool was passed a none EmitterTemplate" );
		// ScriptTrace();
		return none;
	}

	PSC = Super.SpawnEmitter(EmitterTemplate, SpawnLocation, SpawnRotation, AttachToActor,bInheritScaleFromBase);

	// reduce detail if low framerate
	if (WorldInfo.bDropDetail)
	{
		LODLevel = 1;
	}
	else if (EmitterTemplate.LODDistances.length > 1)
	{
		// also reduce detail if all local players are too far away or effect is behind them
		LODLevel = 1;
		foreach LocalPlayerControllers(class'PlayerController', PC)
		{
			if ( PC.ViewTarget != None && VSize(PC.ViewTarget.Location - SpawnLocation) * PC.LODDistanceFactor < EmitterTemplate.LODDistances[1] &&
				vector(PC.Rotation) dot (SpawnLocation - PC.ViewTarget.Location) >= 0.0 )
			{
				LODLevel = 0;
				break;
			}
		}
	}
	PSC.SetLODLevel(LODLevel);
	PSC.SetDepthPriorityGroup(SDPG_World);
	return PSC;
}

/** hooked up to UDKExplosionLight's OnLightFinished delegate to clean it up */
function OnExplosionLightFinished(UDKExplosionLight Light)
{
	local int i;

	DetachComponent(Light);
	i = RelativeExplosionLights.Find('Light', Light);
	if (i != INDEX_NONE)
	{
		RelativeExplosionLights.Remove(i, 1);
	}
}

/** creates an explosion light (currently not pooled) */
function UDKExplosionLight SpawnExplosionLight(class<UDKExplosionLight> LightClass, vector SpawnLocation, optional Actor AttachToActor)
{
	local UDKExplosionLight Light;
	local int i;

	// AttachToActor is only for movement, so if it can't move, then there is no point in using it
	if (AttachToActor != None && (AttachToActor.bStatic || !AttachToActor.bMovable))
	{
		AttachToActor = None;
	}

	Light = new(self) LightClass;
	Light.SetTranslation(SpawnLocation);
	Light.OnLightFinished = OnExplosionLightFinished;
	AttachComponent(Light);
	if (AttachToActor != None)
	{
		i = RelativeExplosionLights.length;
		RelativeExplosionLights.length = i + 1;
		RelativeExplosionLights[i].Light = Light;
		RelativeExplosionLights[i].Base = AttachToActor;
		RelativeExplosionLights[i].RelativeLocation = SpawnLocation - AttachToActor.Location;
	}

	return Light;
}

defaultproperties
{
	Begin Object Name=ParticleSystemComponent0
		bAcceptsLights=false
		SecondsBeforeInactive=0
		bOverrideLODMethod=true
		LODMethod=PARTICLESYSTEMLODMETHOD_DirectSet
	End Object

	MaxActiveEffects=200
	SMC_MIC_ReductionTime=2.0
	IdealStaticMeshComponents=200
	IdealMaterialInstanceConstants=200
}
