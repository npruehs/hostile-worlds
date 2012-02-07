/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTEmit_TransLocateOut extends UTReplicatedEmitter;

var float	TLTrailKillWindow;
var ParticleSystem FirstPersonTemplate;

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (Owner != none)
	{
		Owner.TakeDamage(Damage, EventInstigator, Owner.Location - (Location - HitLocation), Momentum * 0.25, DamageType, HitInfo, DamageCauser);
	}
	return;
}

simulated function PostBeginPlay()
{
	// Set Notification Delegate
	if (ParticleSystemComponent != None)
	{
		ParticleSystemComponent.OnSystemFinished = OnParticleSystemFinished;
	}

	SetTimer(TLTrailKillWindow, false);
}

simulated function Timer()
{
	CollisionComponent.SetActorCollision(false, false);
	RemoteRole = ROLE_None;
	if (WorldInfo.NetMode == NM_DedicatedServer)
	{
		Destroy();
	}
}

/** we set the template on the first tick instead of in PostBeginPlay() so the client has a chance to get Owner */
auto state FirstTick
{
	simulated function Tick(float DeltaTime)
	{
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			if (Pawn(Owner) != none && Pawn(Owner).IsFirstPerson())
			{
				SetTemplate(FirstPersonTemplate,true);
			}
			else
			{
				SetTemplate(EmitterTemplate,true);
			}
		}

		GotoState('');
	}
}

defaultproperties
{
	TickGroup=TG_PostAsyncWork

	EmitterTemplate=WP_Translocator.Particles.P_WP_Translocator_Teleport
	FirstPersonTemplate=Envy_Effects.Particles.P_Player_Spawn_Blue

	bCollideActors=true
	bCollideWorld=true
	bBlockActors=true
	bProjTarget=true


	Begin Object Name=ParticleSystemComponent0
		bAcceptsLights=false
		SecondsBeforeInactive=0
		bOverrideLODMethod=true
		LODMethod=PARTICLESYSTEMLODMETHOD_DirectSet
		//bOwnerNoSee=true
	End Object

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0044.000000
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	TLTrailKillWindow=0.1
}
