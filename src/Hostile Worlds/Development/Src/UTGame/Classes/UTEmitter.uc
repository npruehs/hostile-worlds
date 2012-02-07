/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTEmitter extends Emitter
	dependsOn(UTPawn)
	notplaceable;

/** utility function to select the best template from the passed in list
 * the list is assumed to be in order from greatest distance to shortest distance
 */
static final function ParticleSystem GetTemplateForDistance(const out array<DistanceBasedParticleTemplate> TemplateList, vector SpawnLocation, WorldInfo WI)
{
	local PlayerController PC;
	local int i;
	local float Dist;

	if (TemplateList.length == 0 || WI.NetMode == NM_DedicatedServer)
	{
		return None;
	}

	// figure out the distance to use (smallest of all local players)
	Dist = TemplateList[0].MinDistance * 10.0;
	foreach WI.LocalPlayerControllers(class'PlayerController', PC)
	{
		Dist = FMin(Dist, VSize(PC.ViewTarget.Location - SpawnLocation) * PC.LODDistanceFactor);
	}

	for (i = 0; i < TemplateList.length; i++)
	{
		if (Dist >= TemplateList[i].MinDistance)
		{
			return TemplateList[i].Template;
		}
	}

	return None;
}

simulated event SetTemplate(ParticleSystem NewTemplate, optional bool bDestroyOnFinish)
{
	local PlayerController PC;
	local int LODLevel;

	Super.SetTemplate(NewTemplate, bDestroyOnFinish);

	if (NewTemplate != None)
	{
		// reduce detail if low framerate
		if (WorldInfo.bDropDetail)
		{
			LODLevel = 1;
		}
		else if (NewTemplate.LODDistances.length > 1)
		{
			// also reduce detail if all local players are too far away or effect is behind them
			LODLevel = 1;
			foreach LocalPlayerControllers(class'PlayerController', PC)
			{
				if ( PC.ViewTarget != None && VSize(PC.ViewTarget.Location - Location) * PC.LODDistanceFactor < NewTemplate.LODDistances[1] &&
					vector(PC.Rotation) dot (Location - PC.ViewTarget.Location) >= 0.0 )
				{
					LODLevel = 0;
					break;
				}
			}
		}
		ParticleSystemComponent.SetLODLevel(LODLevel);
	}
}

function SetLightEnvironment(LightEnvironmentComponent Light)
{
	if(ParticleSystemComponent != none)
	{
		ParticleSystemComponent.SetLightEnvironment(Light);
	}
}
defaultproperties
{
	Components.Remove(ArrowComponent0)
	Components.Remove(Sprite)

	Begin Object Name=ParticleSystemComponent0
		bAcceptsLights=false
		SecondsBeforeInactive=0
		bOverrideLODMethod=true
		LODMethod=PARTICLESYSTEMLODMETHOD_DirectSet
	End Object

	LifeSpan=7.0
	bDestroyOnSystemFinish=true
	bNoDelete=false
}
