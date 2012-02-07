/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicle_Manta extends UTVehicle
	abstract;

var(Movement)	float	JumpForceMag;

var(Movement)	float	MaxJumpZVel;

/** How far down to trace to check if we can jump */
var(Movement)   float   JumpCheckTraceDist;

var     float	JumpDelay, LastJumpTime;

var(Movement)   float   DuckForceMag;

var repnotify bool bDoBikeJump;
var repnotify bool bHoldingDuck;
var		bool							bPressingAltFire;

var soundcue JumpSound;
var soundcue DuckSound;

var float BladeBlur, DesiredBladeBlur;
/** if >= 0, index in VehicleEffects array for fan effect that gets its MantaFanSpin parameter set to BladeBlur */
var int FanEffectIndex;
/** parameter name for the fan blur, set to BladeBlur */
var name FanEffectParameterName;

/** Manta flame jet effect name**/
var name FlameJetEffectParameterName;
/** values for setting the FlameJet Particle System **/
var float FlameJetValue, DesiredFlameJetValue;

/** Suspension height when manta is being driven around normally */
var(Movement) protected float FullWheelSuspensionTravel;

/** Suspension height when manta is crouching */
var(Movement) protected float CrouchedWheelSuspensionTravel;

/** controls how fast to interpolate between various suspension heights */
var(Movement) protected float SuspensionTravelAdjustSpeed;

/** Suspension stiffness when manta is being driven around normally */
var(Movement) protected float FullWheelSuspensionStiffness;

/** Suspension stiffness when manta is crouching */
var(Movement) protected float CrouchedWheelSuspensionStiffness;

/** Adjustment for bone offset when changing suspension */
var  protected float BoneOffsetZAdjust;

/** max speed while crouched */
var(Movement) float CrouchedAirSpeed;

/** max speed */
var(Movement) float FullAirSpeed;

replication
{
	if ((!bNetOwner || bDemoRecording) && Role == ROLE_Authority)
		bDoBikeJump, bHoldingDuck;
}

event Tick(Float DeltaSeconds)
{
	local bool bRecentlyRendered, bIsOverJumpableSurface, bAdjustSuspension;
	local vector X,Y, DirZ, HitLocation, HitNormal;
	local actor HitActor;
	local float MaxImpulse, JumpImpulse, DesiredSuspensionTravel, ClampedDeltaSeconds;
	local int i;
	
	super.Tick(DeltaSeconds);

	if ( bDeadVehicle )
	{
		return;
	}
	
	AirSpeed = FullAirSpeed;

	if (Controller != None)
	{
		// trying to jump
		if ( bPressingAltFire || (Rise < 0.0) )
		{
			// Duck!
			AirSpeed = CrouchedAirSpeed;
			if ( !bHoldingDuck )
			{
				bHoldingDuck = true;

				MantaDuckEffect();
				
				if ( UTBot(Controller) != None )
    				Rise = 0.0;
    		}
		}
		else if ( Rise > 0.0 )
		{
			if ( !bHoldingDuck && (WorldInfo.TimeSeconds - JumpDelay >= LastJumpTime) )
			{
				// Calculate Local Up Vector
				GetAxes(Rotation, X, Y, DirZ);

				bIsOverJumpableSurface = false;

				// Don't jump if we are at a steep angle
				if ( DirZ.Z > 0.5 )
				{
					// Otherwise make sure there is ground underneath
					// use an extent trace so what we hit matches up with what the vehicle and physics collision would hit
					HitActor = Trace(HitLocation,HitNormal,Location - (DirZ * JumpCheckTraceDist),Location,true, vect(1,1,1),,TRACEFLAG_Blocking);
					bIsOverJumpableSurface = (HitActor != None);
				}
				if (bIsOverJumpableSurface)
				{
					// If we are on the ground, and press Rise, and we not currently in the middle of a jump, start a new one.
					if (Role == ROLE_Authority)
					{
   						bDoBikeJump = !bDoBikeJump;
					}
					MantaJumpEffect();

					if ( UTBot(Controller) != None )
    					Rise = 0.0;

					 JumpImpulse = JumpForceMag;
					// We limit the impulse, to limit the max vertical velocity achieved
					if( (Mesh != None) && (Mesh.BodyInstance != None) )
					{
						MaxImpulse = (MaxJumpZVel - Velocity.Z) * Mesh.BodyInstance.GetBodyMass();
						if( MaxImpulse > 0.0 )
						{
							JumpImpulse = FMin(MaxImpulse, JumpImpulse);
						}
						else
						{
							JumpImpulse = 0.0;
						}
					}

					AddImpulse( vect(0.0,0.0,1.0)*JumpImpulse );
					LastJumpTime = WorldInfo.TimeSeconds;
				}
			}
			// make sure bot doesn't queue up a jump (it checks frequently enough that this isn't likely to be helpful)
			else if ( UTBot(Controller) != None )
			{
				Rise = 0.0;
			}
			bNoZDamping = (WorldInfo.TimeSeconds - 0.25 < LastJumpTime);
		}
		else if (bHoldingDuck)
		{
			bHoldingDuck = false;
			MantaDuckEffect();
		}
	}

	if ( bDriving )
	{
		DesiredSuspensionTravel = FullWheelSuspensionTravel;
		if ( bHoldingDuck )
		{
			AddForce( vect(0.0,0.0,1.0)*DuckForceMag );
			DesiredSuspensionTravel = CrouchedWheelSuspensionTravel;
		}

		ClampedDeltaSeconds = FMin(DeltaSeconds, 0.1);
		for ( i=0; i<Wheels.Length; i++ )
		{
			bAdjustSuspension = false;

			if ( Wheels[i].SuspensionTravel > DesiredSuspensionTravel )
			{
				// instant crouch
				bAdjustSuspension = true;
				Wheels[i].SuspensionTravel = DesiredSuspensionTravel;
				SimObj.WheelSuspensionStiffness = CrouchedWheelSuspensionStiffness;
			}
			else if ( Wheels[i].SuspensionTravel < DesiredSuspensionTravel )
			{
				// slow rise
				bAdjustSuspension = true;
				Wheels[i].SuspensionTravel = FMin(DesiredSuspensionTravel, Wheels[i].SuspensionTravel + SuspensionTravelAdjustSpeed*ClampedDeltaSeconds);
				SimObj.WheelSuspensionStiffness = FullWheelSuspensionStiffness;
			}
			if ( bAdjustSuspension )
			{
				Wheels[i].BoneOffset.Z = -1.0 * (Wheels[i].SuspensionTravel + Wheels[i].WheelRadius + BoneOffsetZAdjust);
				bUpdateWheelShapes = true; 
			}
		}
	}

	bRecentlyRendered = (LastRenderTime > WorldInfo.TimeSeconds - 1.0f);
	if ( WorldInfo.NetMode != NM_DedicatedServer && bRecentlyRendered )
	{
		// client side only effects
		if ( FanEffectIndex >= 0 && FanEffectIndex < VehicleEffects.Length && VehicleEffects[FanEffectIndex].EffectRef != None )
		{
			if ( bDriving )
			{
				if ( Velocity != vect(0,0,0) )
				{
					DesiredBladeBlur = 1.0 + FClamp( (0.002 * VSize(Velocity)), 0.0, 2.0);
					BladeBlur = DesiredBladeBlur;
					DesiredFlameJetValue = FMin(BladeBlur, 1.0);
					FlameJetValue = DesiredFlameJetValue;
				}
				else
				{
					DesiredBladeBlur = 1.0;
					DesiredFlameJetValue = 0.0;
				}
			}
			else
			{
				DesiredBladeBlur = 0.0;
				DesiredFlameJetValue = 0.0;
			}
		
			if (BladeBlur!=DesiredBladeBlur)
			{
				if (BladeBlur > DesiredBladeBlur)
				{
					BladeBlur = FClamp( (BladeBlur-DeltaSeconds), DesiredBladeBlur, 3.0 );
				}
				else
				{
					BladeBlur = FClamp( (BladeBlur+DeltaSeconds), 0.0, DesiredBladeBlur );
				}
			}

			if (FlameJetValue!=DesiredFlameJetValue)
			{
				if (FlameJetValue > DesiredFlameJetValue)
				{
					FlameJetValue = FClamp( (FlameJetValue-DeltaSeconds), DesiredFlameJetValue, 1.0 );
				}
				else
				{
					FlameJetValue = FClamp( (FlameJetValue+DeltaSeconds), 0.0, DesiredFlameJetValue );
				}
			}

			VehicleEffects[FanEffectIndex].EffectRef.SetFloatParameter(FanEffectParameterName, BladeBlur);
			VehicleEffects[FanEffectIndex].EffectRef.SetFloatParameter(FlameJetEffectParameterName, FlameJetValue);
		}
	}
}

/**
 * Are we allowing this Pawn to be based on us?
 */
simulated function bool CanBeBaseForPawn(Pawn APawn)
{
	return bCanBeBaseForPawns && !bDriving;
}

/** DriverEnter()
Make Pawn P the new driver of this vehicle
*/
function bool DriverEnter(Pawn P)
{
	local Pawn BasedPawn;

	if ( super.DriverEnter(P) )
	{
		ForEach BasedActors(class'Pawn', BasedPawn)
		{
			if(BasedPawn != Driver)
			{
				BasedPawn.JumpOffPawn();
			}
		}
		return true;
	}
	return false;
}

simulated function bool OverrideBeginFire(byte FireModeNum)
{
	if (FireModeNum == 1)
	{
		bPressingAltFire = true;
		return true;
	}

	return false;
}

simulated function bool OverrideEndFire(byte FireModeNum)
{
	if (FireModeNum == 1)
	{
		bPressingAltFire = false;
		return true;
	}

	return false;
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
	super.PossessedBy(C, bVehicleTransition);

	// reset jump/duck properties
	bHoldingDuck = false;
	LastJumpTime = 0;
	bDoBikeJump = false;
	bPressingAltFire = false;
}

simulated function MantaJumpEffect();

simulated function MantaDuckEffect();

//========================================
// AI Interface

function byte ChooseFireMode()
{
	local UTBot B;

	B = UTBot(Controller);
	if ( B != None
		&& (B.Skill > 1.7 + FRand())
		&& Pawn(Controller.Focus) != None
		&& Vehicle(Controller.Focus) == None
		&& Controller.MoveTarget == Controller.Focus
		&& Controller.InLatentExecution(Controller.LATENT_MOVETOWARD)
		&& VSize(Controller.GetFocalPoint() - Location) < 800
		&& Controller.LineOfSightTo(Controller.Focus) )
	{
		return 1;
	}

	return 0;
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	Rise = 1;
	return true;
}

function IncomingMissile(Projectile P)
{
	local UTBot B;

	B = UTBot(Controller);
	if (B != None && B.Skill > 4.0 + 4.0 * FRand() && VSize(P.Location - Location) < VSize(P.Velocity))
	{
		DriverLeave(false);
	}
	else
	{
		Super.IncomingMissile(P);
	}
}

simulated function DrivingStatusChanged()
{
	bPressingAltFire = false;

	Super.DrivingStatusChanged();
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bDoBikeJump')
	{
		MantaJumpEffect();
	}
	else if (VarName == 'bHoldingDuck')
	{
		MantaDuckEffect();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function float GetChargePower()
{
	return FClamp( (WorldInfo.TimeSeconds - LastJumpTime), 0, JumpDelay)/JumpDelay;
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
				const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	// only process rigid body collision if not hitting ground
	if ( Abs(RigidCollisionData.ContactInfos[0].ContactNormal.Z) < WalkableFloorZ )
	{
		super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
	}
}

simulated function bool ShouldClamp()
{
	return false;
}

function bool TooCloseToAttack(Actor Other)
{
	local float OtherRadius, OtherHeight;

	if (Pawn(Other) != None && Vehicle(Other) == None)
	{
		return false;
	}
	else if (Super.TooCloseToAttack(Other))
	{
		return true;
	}
	else
	{
		Other.GetBoundingCylinder(OtherRadius, OtherHeight);
		return (VSize2D(Other.Location - Location) < OtherRadius + CylinderComponent.CollisionRadius + 150.0);
	}
}

function bool RecommendCharge(UTBot B, Pawn Enemy)
{
	if ( B.Skill < 1 + FRand() )
	{
		return false;
	}
	if ( Vehicle(Enemy) == None )
	{
		return (VSize(Location - Enemy.Location) < 1000.0 + 3000.0*FRand());
	}
	return false;
}	

defaultproperties
{
	MaxGroundEffectDist=256.0
	GroundEffectDistParameterName=DistToGround
	bNoZSmoothing=false
	CollisionDamageMult=0.0008

	Health=200
	MeleeRange=-100.0
	ExitRadius=160.0
	bTakeWaterDamageWhileDriving=false

	COMOffset=(x=0.0,y=0.0,z=0.0)
	UprightLiftStrength=30.0
	UprightTorqueStrength=30.0
	bCanFlip=true
	JumpForceMag=7000.0
	JumpDelay=3.0
	MaxJumpZVel=900.0
	DuckForceMag=-350.0
	JumpCheckTraceDist=175.0
	FullWheelSuspensionTravel=145
	CrouchedWheelSuspensionTravel=100
	FullWheelSuspensionStiffness=20.0
	CrouchedWheelSuspensionStiffness=40.0
	SuspensionTravelAdjustSpeed=100
	BoneOffsetZAdjust=45.0
	CustomGravityScaling=0.8

	AirSpeed=1800.0
	GroundSpeed=1500.0
	CrouchedAirSpeed=1200.0
	FullAirSpeed=1800.0
	bCanCarryFlag=false
	bFollowLookDir=True
	bTurnInPlace=True
	bScriptedRise=True
	bCanStrafe=True
	ObjectiveGetOutDist=750.0
	MaxDesireability=0.6
	SpawnRadius=125.0
	MomentumMult=3.2

	bStayUpright=true
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=450
	StayUprightDamping=20

	bRagdollDriverOnDarkwalkerHorn=true

	Begin Object Class=UDKVehicleSimHover Name=SimObject
		WheelSuspensionStiffness=20.0
		WheelSuspensionDamping=1.0
		WheelSuspensionBias=0.0
		MaxThrustForce=325.0
		MaxReverseForce=250.0
		LongDamping=0.3
		MaxStrafeForce=260.0
		DirectionChangeForce=375.0
		LatDamping=0.3
		MaxRiseForce=0.0
		UpDamping=0.0
		TurnTorqueFactor=2500.0
		TurnTorqueMax=1000.0
		TurnDamping=0.25
		MaxYawRate=100000.0
		PitchTorqueFactor=200.0
		PitchTorqueMax=18.0
		PitchDamping=0.1
		RollTorqueTurnFactor=1000.0
		RollTorqueStrafeFactor=110.0
		RollTorqueMax=500.0
		RollDamping=0.2
		MaxRandForce=20.0
		RandForceInterval=0.4
		bAllowZThrust=false
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	Begin Object Class=UTHoverWheel Name=RThruster
		BoneName="Engine"
		BoneOffset=(X=-50.0,Y=100.0,Z=-200.0)
		WheelRadius=10
		SuspensionTravel=145
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(0)=RThruster

	Begin Object Class=UTHoverWheel Name=LThruster
		BoneName="Engine"
		BoneOffset=(X=-50.0,Y=-100.0,Z=-200.0)
		WheelRadius=10
		SuspensionTravel=145
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(1)=LThruster

	Begin Object Class=UTHoverWheel Name=FThruster
		BoneName="Engine"
		BoneOffset=(X=80.0,Y=0.0,Z=-200.0)
		WheelRadius=10
		SuspensionTravel=145
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(2)=FThruster

	bAttachDriver=true
	bDriverIsVisible=true

	bHomingTarget=true

	BaseEyeheight=110
	Eyeheight=110

	DefaultFOV=90
	CameraLag=0.02
	bCanBeBaseForPawns=true
	bEjectKilledBodies=true

	HornIndex=0
}
