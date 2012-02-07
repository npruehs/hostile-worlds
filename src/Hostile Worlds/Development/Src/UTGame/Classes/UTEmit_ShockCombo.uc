/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTEmit_ShockCombo extends UTReplicatedEmitter;

var class<UDKExplosionLight> ExplosionLightClass;

/** increase in vortex force per second */
var float VortexForcePerSecond;
/** radius in which ragdolls have the force applied */
var float VortexRadius;
/** duration in seconds of the physics effect, or zero for it to be the same as the emitter */
var float VortexDuration;
/** damage type passed to SpawnGibs() when blowing up a ragdoll */
var class<UTDamageType> VortexDamageType;

simulated event SetInitialState()
{
	local PlayerController P;
	local float Dist;
	local bool bSpawnLight, bDoPhysicsVortex;

	Super.SetInitialState();

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		// decide whether to enable explosion light and/or vortex effect
		ForEach LocalPlayerControllers(class'PlayerController', P)
		{
			if (!WorldInfo.bDropDetail && !bSpawnLight)
			{
				Dist = VSize(P.ViewTarget.Location - Location);
				if ( (P.Pawn == Instigator) || (Dist < ExplosionLightClass.Default.Radius) || ((Dist < 6000) && ((vector(P.Rotation) dot (Location - P.ViewTarget.Location)) > 0)) )
				{
					bSpawnLight = true;
				}
			}
			if (!bDoPhysicsVortex && (Instigator == P.ViewTarget || FastTrace(Location, P.ViewTarget.Location)))
			{
				bDoPhysicsVortex = true;
			}
		}
		if (bSpawnLight)
		{
			AttachComponent(new(self) ExplosionLightClass);
		}
		if ( bDoPhysicsVortex && !class'GameInfo'.Static.UseLowGore(WorldInfo) )
		{
			GotoState('PhysicsVortex');
		}
	}
}

/** this state does the cool physics vortex effect */
state PhysicsVortex
{
	simulated event BeginState(name PreviousStateName)
	{
		if (VortexDuration > 0.0)
		{
			SetTimer(VortexDuration, false, 'EndVortex');
		}
	}

	simulated function EndVortex()
	{
		GotoState('');
	}

	simulated event Tick(float DeltaTime)
	{
		local float CurrentForce;
		local UTPawn P;
		local vector OtherLocation, Dir;

		CurrentForce = VortexForcePerSecond * (WorldInfo.TimeSeconds - CreationTime);

		foreach CollidingActors(class'UTPawn', P, VortexRadius,, true)
		{
			if (P.Physics == PHYS_RigidBody && P.Health < 0 && P.IsInState('Dying'))
			{
				OtherLocation = P.Mesh.GetPosition();
				if (FastTrace(Location, OtherLocation))
				{
					// if it has reached the center, gib it
					Dir = Location - OtherLocation;
					if (VSize(Dir) < P.Mesh.Bounds.SphereRadius && Normal(P.Velocity) dot Dir > 0.0 && !class'GameInfo'.static.UseLowGore(WorldInfo) )
					{
						P.SpawnGibs(VortexDamageType, Location);
					}
					else
					{
						P.Mesh.AddForce(Normal(Dir) * CurrentForce);
					}
				}
			}
		}
	}
}

defaultproperties
{
	EmitterTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Explo'
	ExplosionLightClass=class'UTShockComboExplosionLight'

	TickGroup=TG_PreAsyncWork

	VortexRadius=400.0
	VortexForcePerSecond=150.0
	VortexDuration=2.75
	VortexDamageType=class'UTDmgType_ShockCombo'
}
