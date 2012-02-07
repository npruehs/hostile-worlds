/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class PhysXEmitterSpawnable extends Emitter
	native(Particle)
	notplaceable;

struct native IndexedRBState
{
    var	vector	CenterOfMass;
    var	vector	LinearVelocity;
    var	vector	AngularVelocity;
    var	int		Index;
};

struct native RBVolumeFill
{
	var init	array<IndexedRBState>	RBStates;
	var	init	array<vector>			Positions;
};

var	native pointer	VolumeFill{FRBVolumeFill};

var repnotify ParticleSystem ParticleTemplate;

replication
{
	if (bNetInitial)
		ParticleTemplate;
}

native function Term();

event Destroyed()
{
	Super.Destroyed();
	Term();
}

simulated event SetTemplate(ParticleSystem NewTemplate, optional bool bDestroyOnFinish)
{
	Super.SetTemplate(NewTemplate, bDestroyOnFinish);

	ParticleTemplate = NewTemplate;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'ParticleTemplate')
	{
		SetTemplate(ParticleTemplate, bDestroyOnSystemFinish);
		ParticleSystemComponent.ActivateSystem();
		if (ParticleTemplate == None && bDestroyOnSystemFinish)
		{
			// prevent emitter from hanging around forever with no template
			Destroy();
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

defaultproperties
{
	Begin Object Name=ParticleSystemComponent0
		SecondsBeforeInactive=0
	End Object

	bNoDelete=false
	bDestroyOnSystemFinish=true
	bNetTemporary=true
}
