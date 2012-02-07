/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_CicadaRocket extends UTProjectile;

var float SpiralForceMag;
var float InwardForceMag;
var float ForwardForceMag;
var float DesiredDistanceToAxis;
var float DesiredDistanceDecayRate;
var float InwardForceMagGrowthRate;

var float CurSpiralForceMag;
var float CurInwardForceMag;
var float CurForwardForceMag;

var float DT;

var vector AxisOrigin;
var vector AxisDir;

var vector Target, SecondTarget;
var float KillRange;
var bool bFinalTarget;
var float SwitchTargetTime;

var SoundCue IgniteSound;

var float IgniteTime;
var repnotify vector InitialAcceleration;


replication
{
	if ( bNetInitial && Role == ROLE_Authority )
		IgniteTime, InitialAcceleration, Target, SecondTarget, SwitchTargetTime, bFinalTarget;
}


simulated function ReplicatedEvent(name VarName)
{
	if ( VarName == 'InitialAcceleration' )
	{
		SetTimer(IgniteTime , false, 'Ignite');
		Acceleration = InitialAcceleration;
	}
}

function Init(vector Direction);

function ArmMissile(vector InitAccel, vector InitVelocity)
{
	local float Dist;

	Velocity = InitVelocity;
	InitialAcceleration = InitAccel;

	Dist = VSize(Target - Location);
	if ( Dist < KillRange )
	{
		IgniteTime = 0.2 - 0.2 * ((KillRange - Dist)/KillRange);
	}
	else
	{
		IgniteTime = (FRand() * 0.2) + 0.2;
	}

	// Seed the acceleration/timer on a server
	ReplicatedEvent('InitialAcceleration');
}

simulated function ChangeTarget()
{
	Target = SecondTarget;
	bFinalTarget = true;
	SwitchTargetTime = 0;
}

simulated function Ignite()
{
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		PlaySound(IgniteSound, true);
	}

	SetCollision(true, true);

	if ( VSize(Target - Location) <= KillRange )
	{
		if (!bFinalTarget)
		{
			ChangeTarget();
		}
		GotoState('Homing');
	}
	else
	{
		GotoState('Spiraling');
	}
}


state Spiraling
{
	simulated function BeginState(name PreviousStateName)
	{
		CurSpiralForceMag = SpiralForceMag;
		CurInwardForceMag = InwardForceMag;
		CurForwardForceMag = ForwardForceMag;

		AxisOrigin = Location;
		AxisDir =  Normal(Target - AxisOrigin);
		SetTimer(DT, true);
	}

	// @TODO FIXMESTEVE move to C++, and do every tick (with less accel change)
	simulated function Timer()
	{
		local vector ParallelComponent, PerpendicularComponent, NormalizedPerpendicularComponent;
		local vector SpiralForce, InwardForce, ForwardForce;
		local float InwardForceScale;

		// Add code to switch directions

		// Update the inward force magnitude.
		CurInwardForceMag += InwardForceMagGrowthRate * DT;

		ParallelComponent = ((Location - AxisOrigin) dot AxisDir) * AxisDir;
		PerpendicularComponent = (Location - AxisOrigin) - ParallelComponent;
		NormalizedPerpendicularComponent = Normal(PerpendicularComponent);

		InwardForceScale = VSize(PerpendicularComponent) - DesiredDistanceToAxis;

		SpiralForce = CurSpiralForceMag * Normal(AxisDir cross NormalizedPerpendicularComponent);
		InwardForce = -CurInwardForceMag * InwardForceScale * NormalizedPerpendicularComponent;
		ForwardForce = CurForwardForceMag * AxisDir;

		Acceleration = SpiralForce + InwardForce + ForwardForce;

		DesiredDistanceToAxis -= DesiredDistanceDecayRate * DT;
		DesiredDistanceToAxis = FMax(DesiredDistanceToAxis, 0.0);

		// Check to see if we should switch to Home in Mode
		if (!bFinalTarget)
		{
			SwitchTargetTime -= DT;
			if (SwitchTargetTime <= 0)
			{
				ChangeTarget();
				GotoState('Homing');
				return;
			}
		}

		if (VSize(Location - Target) <= KillRange)
		{
			if ( !bFinalTarget )
			{
				ChangeTarget();
			}
			GotoState('Homing');
		}
	}
}

state Homing
{
	simulated function Timer()
	{
		// do normal guidance to target.
		Acceleration = 16.0 * AccelRate * Normal(Target - Location);

		if ( ((Acceleration dot Velocity) < 0.f) && (VSizeSq(Target - Location) < Square(0.5*KillRange)) )
		{
			Explode(Location, vect(0,0,1));
		}
	}

	simulated function BeginState(name PreviousStateName)
	{
		Timer();
		SetTimer(0.1, true);
	}
}


simulated function Landed(vector HitNormal, Actor FloorActor)
{
	Explode(Location, HitNormal);
}

simulated function ProcessTouch(Actor Other, vector HitLocation, vector HitNormal)
{
	if (Other != Instigator && (!Other.IsA('Projectile') || Other.bProjTarget))
	{
		Explode(HitLocation, vect(0,0,1));
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	ClearTimer('Ignite');
	Super.Explode(HitLocation, HitNormal);
	SetTimer(0.0,false);
}

defaultproperties
{
	Speed=1000.0
	AccelRate=750
	MaxSpeed=4000.0
	SpiralForceMag=800.0
	InwardForceMag=25.0
	ForwardForceMag=15000.0
	DesiredDistanceToAxis=250.0
	DesiredDistanceDecayRate=500.0
	InwardForceMagGrowthRate=0.0
	DT=0.1
	MomentumTransfer=40000
	Damage=50
	DamageRadius=220.0
	MyDamageType=class'UTDmgType_CicadaRocket'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=7.0
	RotationRate=(Roll=50000)
	DrawScale=0.5
	bCollideWorld=True
	bCollideActors=false
	bNetTemporary=False
	KillRange=2000
	IgniteSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_MissileIgnite'

	ExplosionLightClass=class'UTGame.UTCicadaRocketExplosionLight'
	ProjFlightTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketTrail'
	ProjExplosionTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
	
	ExplosionSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Impact_Cue'
	bWaitForEffects=true
	bRotationFollowsVelocity=true
	IgniteTime=0.2
}
