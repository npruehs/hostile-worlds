/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/** this is used to replicate out the jump boot feet effects */
class UTJumpBootEffect extends Actor;

/** the particle system to spawn on the feet */
var ParticleSystem JumpingEffect;
/** pawn to spawn effects for */
var repnotify UTPawn OwnerPawn;

replication
{
	if (bNetInitial)
		OwnerPawn;
}

function PostBeginPlay()
{
	OwnerPawn = UTPawn(Owner);
	if (OwnerPawn == None)
	{
		`Warn("Spawned with no Owner");
		Destroy();
	}
	else
	{
		SetBase(Owner); // makes sure net relevancy is the same as Owner
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			AttachToOwner();
		}
	}
}

simulated function AttachToOwner()
{
	local vector SocketLocation;
	local UTEmitter FootEmitter;
	local rotator SocketRotation;

	if (OwnerPawn != None && OwnerPawn.Mesh != None)
	{
		if (OwnerPawn.Mesh.GetSocketWorldLocationAndRotation(OwnerPawn.PawnEffectSockets[0], SocketLocation, SocketRotation))
		{
			FootEmitter = Spawn(class'UTEmitter', OwnerPawn,, SocketLocation, SocketRotation);
			if (OwnerPawn.Mesh.bOwnerNoSee)
			{
				FootEmitter.ParticleSystemComponent.SetOwnerNoSee(true);
			}
			FootEmitter.SetBase(OwnerPawn,, OwnerPawn.Mesh, OwnerPawn.PawnEffectSockets[0]);
			FootEmitter.SetTemplate(JumpingEffect, true);
		}
		if (OwnerPawn.Mesh.GetSocketWorldLocationAndRotation(OwnerPawn.PawnEffectSockets[1], SocketLocation, SocketRotation))
		{
			FootEmitter = Spawn(class'UTEmitter', OwnerPawn,, SocketLocation, SocketRotation);
			if (OwnerPawn.Mesh.bOwnerNoSee)
			{
				FootEmitter.ParticleSystemComponent.SetOwnerNoSee(true);
			}
			FootEmitter.SetBase(OwnerPawn,, OwnerPawn.Mesh, OwnerPawn.PawnEffectSockets[1]);
			FootEmitter.SetTemplate(JumpingEffect, true);
		}
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'OwnerPawn')
	{
		AttachToOwner();
	}
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=true
	LifeSpan=0.2
	bSkipActorPropertyReplication=true
	JumpingEffect=ParticleSystem'Envy_Effects.Particles.P_JumpBoot_Effect'
}
