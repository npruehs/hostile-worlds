/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTReplicatedEmitter extends UTEmitter
	notplaceable
	abstract;

/** The Template to use for this emitter */
var ParticleSystem EmitterTemplate;

/** How long this actor lives on a dedicated server */
var float ServerLifeSpan;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		LifeSpan = ServerLifeSpan;
	}
	else
	{
		SetTemplate(EmitterTemplate,true);
	}
}

defaultproperties
{
	ServerLifeSpan=0.2
	bNetInitialRotation=true
	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=true
}
