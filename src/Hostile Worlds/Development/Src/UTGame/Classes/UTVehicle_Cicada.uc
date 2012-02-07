/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicle_Cicada extends UTAirVehicle
	abstract;

var repnotify vector TurretFlashLocation;
var repnotify rotator TurretWeaponRotation;
var	repnotify byte TurretFlashCount;
var repnotify byte TurretFiringMode;

var bool bFreelanceStart;

var array<int> JetEffectIndices;

var ParticleSystem TurretBeamTemplate;

var UTSkelControl_JetThruster JetControl;

var name JetScalingParam;

replication
{
	if (bNetDirty)
		TurretFlashLocation;

	if (!IsSeatControllerReplicationViewer(1) || bDemoRecording)
		TurretFlashCount, TurretFiringMode, TurretWeaponRotation;
}

event Tick(float DeltaTime)
{
	local UTBot Bot;
	local float JetScale;
	local int i, JetIndex;
	local vector HitLocation, HitNormal;
	local actor HitActor;
	
	super.tick(DeltaTime);

	if ( bDriving )
	{
		if ( Controller == None ) 
		{
			if (Seats.Length > 1 && Seats[1].SeatPawn != None && Seats[1].SeatPawn.Controller != None && (Location.Z < WorldInfo.StallZ) )
			{
				// if turret passenger, try to bring vehicle to a halt
				Rise = FClamp((-1.0 * Velocity.Z)/GetMaxRiseForce(), -1.0, 1.0);
			}
		}
		else 
		{
			// AI altitude control
			Bot = UTBot(Controller);
			if ( Bot != None )
			{
				if ( Bot.bScriptedFrozen )
				{
					Rise = FClamp((-1.0 * Velocity.Z) / GetMaxRiseForce(), 0.0, 1.0);
				}
				else if ( !Bot.InLatentExecution(Bot.LATENT_MOVETOWARD) )
				{
					if (Rise < 0.0)
					{
						if (Velocity.Z < 0.0)
						{
							if (Velocity.Z < -1000.0)
							{
								Rise = -0.001;
							}
							HitActor = Trace(HitLocation, HitNormal, Location - vect(0.0, 0.0, 2000.0), Location, FALSE);
							if (HitActor != None)
							{
								if ((Location.Z - HitLocation.Z) / (-1.0 * Velocity.Z) < 0.85)
								{
									Rise = 1.0;
								}
							}
						}
					}
					else if (Rise == 0.0)
					{
						if ( !FastTrace(Location - vect(0.0, 0.0, 500.0), Location) )
						{
							Rise = FClamp((-1.0 * Velocity.Z) / GetMaxRiseForce(), 0.0, 1.0);
						}
					}
				}
			}
		}
	}

	if ( LastRenderTime > WorldInfo.TimeSeconds - 0.2 )
	{
		if ( JetControl != None )
		{
			JetScale = FClamp(1.0-JetControl.ControlStrength, 0.2 , 1.0);
			for ( i=0; i<JetEffectIndices.Length; i++ )
			{
				JetIndex = JetEffectIndices[i];
				if ( JetIndex < VehicleEffects.Length && (VehicleEffects[JetIndex].EffectRef != None) )
				{
					VehicleEffects[JetIndex].EffectRef.SetFloatParameter(JetScalingParam, JetScale);
				}
			}
		}
	}
}


simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
					const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	Super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
	if(!IsTimerActive('ResetTurningSpeed'))
	{
		SetTimer(0.7f,false,'ResetTurningSpeed');
		MaxSpeed = default.MaxSpeed/2.0;
		MaxAngularVelocity = default.MaxAngularVelocity/4.0;
		if( UDKVehicleSimChopper(SimObj) != none)
			UDKVehicleSimChopper(SimObj).bRecentlyHit = true;
	}
}

simulated function ResetTurningSpeed()
{ // this is safe since this only gets called above after checking SimObj is a chopper.
	MaxSpeed = default.MaxSpeed;
	MaxAngularVelocity = default.MaxAngularVelocity;
	if( UDKVehicleSimChopper(SimObj) != none)
		UDKVehicleSimChopper(SimObj).bRecentlyHit = false;
}

// AI hint
function bool ImportantVehicle()
{
	return !bFreelanceStart;
}

function bool DriverEnter(Pawn P)
{
	local UTBot B;

	if ( !Super.DriverEnter(P) )
		return false;

	B = UTBot(Controller);
	bFreelanceStart = (B != None && B.Squad != None && UTSquadAI(B.Squad).bFreelance);
	return true;
}

function DriverLeft()
{
	Super.DriverLeft();

	SetDriving(NumPassengers() > 0);
}

function PassengerLeave(int SeatIndex)
{
	Super.PassengerLeave(SeatIndex);

	SetDriving(NumPassengers() > 0);
}

function bool PassengerEnter(Pawn P, int SeatIndex)
{
	if ( !Super.PassengerEnter(P, SeatIndex) )
		return false;

	SetDriving(true);
	return true;
}

//Switching seats during altfire doesn't replicate because
//bDriving is the same at the end of the tick as the beginning.  Tell the client
//to stop firing the weapon it left behind
simulated function SitDriver( UTPawn UTP, int SeatIndex)
{
	if (Role<ROLE_Authority && SeatIndex == 1)
	{
		Seats[0].Gun.ForceEndFire();
	}

	Super.SitDriver(UTP, SeatIndex);
}


/* FIXME:
function Vehicle FindEntryVehicle(Pawn P)
{
	local Bot B, S;

	B = Bot(P.Controller);
	if ( (B == None) || !IsVehicleEmpty() || (WeaponPawns[0].Driver != None) )
		return Super.FindEntryVehicle(P);

	for ( S=B.Squad.SquadMembers; S!=None; S=S.NextSquadMember )
	{
		if ( (S != B) && (S.RouteGoal == self) && S.InLatentExecution(S.LATENT_MOVETOWARD)
			&& ((S.MoveTarget == self) || (Pawn(S.MoveTarget) == None)) )
			return WeaponPawns[0];
	}
	return Super.FindEntryVehicle(P);
}
*/

function bool RecommendLongRangedAttack()
{
	return true;
}

/* FIXME:
function float RangedAttackTime()
{
	local ONSDualACSideGun G;

	G = ONSDualACSideGun(Weapons[0]);
	if ( G.LoadedShotCount > 0 )
		return (0.05 + (G.MaxShotCount - G.LoadedShotCount) * G.FireInterval);
	return 1;
}
*/

simulated function VehicleWeaponImpactEffects(vector HitLocation, int SeatIndex)
{
	local ParticleSystemComponent E;

	Super.VehicleWeaponImpactEffects(HitLocation, SeatIndex);

	if (SeatIndex == 1 && !IsZero(HitLocation))
	{
		E = WorldInfo.MyEmitterPool.SpawnEmitter(TurretBeamTemplate, GetEffectLocation(SeatIndex));
		E.SetVectorParameter('ShockBeamEnd', HitLocation);
	}
}

/**
 * We override GetCameraStart for the Belly Turret so that it just uses the Socket Location
 */
simulated function vector GetCameraStart(int SeatIndex)
{
	local vector CamStart;

	if (SeatIndex == 1 && Seats[SeatIndex].CameraTag != '')
	{
		if (Mesh.GetSocketWorldLocationAndRotation(Seats[SeatIndex].CameraTag, CamStart) )
		{
			return CamStart;
		}
	}

	return Super.GetCameraStart(SeatIndex);
}

/**
 * We override VehicleCalcCamera for the Belly Turret so that it just uses the Socket Location
 */
simulated function VehicleCalcCamera(float DeltaTime, int SeatIndex, out vector out_CamLoc, out rotator out_CamRot, out vector CamStart, optional bool bPivotOnly)
{
	if (SeatIndex == 1)
	{
		out_CamLoc = GetCameraStart(SeatIndex);
		out_CamRot = Seats[SeatIndex].SeatPawn.GetViewRotation();
	CamStart = out_CamLoc;
	}
	else
	{
		Super.VehicleCalcCamera(DeltaTime, SeatIndex, out_CamLoc, out_CamRot, CamStart, bPivotOnly);
	}
}

simulated function bool ShouldClamp()
{
	return false;
}

defaultproperties
{
	Begin Object Class=UDKVehicleSimChopper Name=SimObject
		MaxThrustForce=700.0
		MaxReverseForce=700.0
		LongDamping=0.6
		MaxStrafeForce=680.0
		LatDamping=0.7
		MaxRiseForce=1000.0
		UpDamping=0.7
		TurnTorqueFactor=7000.0
		TurnTorqueMax=10000.0
		TurnDamping=1.2
		MaxYawRate=1.8
		PitchTorqueFactor=450.0
		PitchTorqueMax=60.0
		PitchDamping=0.3
		RollTorqueTurnFactor=700.0
		RollTorqueStrafeFactor=100.0
		RollTorqueMax=300.0
		RollDamping=0.1
		MaxRandForce=30.0
		RandForceInterval=0.5
		StopThreshold=100
		bShouldCutThrustMaxOnImpact=true
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	COMOffset=(X=-40,Z=-50.0)

	BaseEyeheight=30
	Eyeheight=30
	bRotateCameraUnderVehicle=false
	CameraLag=0.05
	LookForwardDist=290.0
	bLimitCameraZLookingUp=true

	AirSpeed=2000.0
	GroundSpeed=1600.0

	UprightLiftStrength=30.0
	UprightTorqueStrength=30.0

	bStayUpright=true
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=1200
	StayUprightDamping=20

	SpawnRadius=180.0
	RespawnTime=45.0

	bOverrideAVRiLLocks=true

	PushForce=50000.0
	HUDExtent=140.0

	HornIndex=0
}
