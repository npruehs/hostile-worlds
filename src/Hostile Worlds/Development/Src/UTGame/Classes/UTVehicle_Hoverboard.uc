/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Hoverboard extends UTVehicle
	abstract;

/** Hoverboard mesh visible attachment */
var     UDKSkeletalMeshComponent HoverboardMesh;
var()   vector                  MeshLocationOffset;
var()   rotator                 MeshRotationOffset;

var()	float	JumpForceMag;

/** Sideways force when dodging (added to JumpForceMag * 0.8) */
var()	float	DodgeForceMag;

var()	float	TrickJumpWarmupMax;
var()   float   JumpCheckTraceDist;
var		float	TrickSpinWarmup;
var     float	JumpDelay, LastJumpTime;

var repnotify bool bDoHoverboardJump;

/** True when requesting dodge */
var bool bIsDodging;

/** Dodge force to apply (has direction) */
var vector DodgeForce;

var		bool	bGrabbingBoard;

var editinline export	    RB_StayUprightSetup     LeanUprightConstraintSetup;
var editinline export	    RB_ConstraintInstance   LeanUprightConstraintInstance;

var editinline export		RB_ConstraintSetup		FootBoardConstraintSetup;
var editinline export		RB_ConstraintInstance	LeftFootBoardConstraintInstance;
var editinline export		RB_ConstraintInstance	RightFootBoardConstraintInstance;

/** Controller used to turn the spine. */
var SkelControlSingleBone	SpineTurnControl;

/** Max yaw applied to have head/spine track looking direction. */
var(HeadTracking)	float	MaxTrackYaw;

/** Used internally for limiting how quickly the head tracks. */
var	transient float	CurrentHeadYaw;

// TurnLeanFactor adjusts how much the hoverboard leans when turning
// MaxTurnLean is the maximum amount the hoverboard can lean in unreal angular units
// StrafeLean is the amount the hoverboard will lean when strafing in unreal angular units

var()   float   TurnLeanFactor;
var()	float	MaxLeanPitchSpeed;
var		transient float TargetPitch;

var editinline export	    RB_DistanceJointSetup   DistanceJointSetup;
var editinline export	    RB_ConstraintInstance   DistanceJointInstance;

var ParticleSystem			RedDustEffect;
var ParticleSystem			BlueDustEffect;

var name					DustVelMagParamName;
var name					DustBoardHeightParamName;
var name					DustVelParamName;

var	ParticleSystemComponent	ThrusterEffect;
var name					ThrusterEffectSocket;
var ParticleSystem			RedThrusterEffect;
var ParticleSystem			BlueThrusterEffect;

/** Effect when moving quickly over water. */
var ParticleSystemComponent	RoosterEffect;
var ParticleSystem RoosterEffectTemplate;
/** How much to turn effect to side based on steering. */
var float					RoosterTurnScale;
/** Noise to play when rooster tail is active. */
var	AudioComponent			RoosterNoise;
var SoundCue RoosterSoundCue;

/** Sounds */
var AudioComponent  CurveSound;
var SoundCue        EngineThrustSound;
var SoundCue        TurnSound;
var SoundCue        JumpSound;

/** camera smooth out */
var float CameraInitialOut;

var(HoverboardCam)	vector	HoverCamOffset;
var(HoverboardCam)	rotator	HoverCamRotOffset;
var(HoverboardCam)	vector	VelLookAtOffset;
var(HoverboardCam)	vector	VelBasedCamOffset;
var(HoverboardCam)	float	VelRollFactor;
var(HoverboardCam)	float	HoverCamMaxVelUsed;
var(HoverboardCam)	float	ViewRollRate;
var					int		CurrentViewRoll;

var float	TargetPhysicsWeight;
var float	PhysWeightBlendTimeToGo;

var() float	PhysWeightBlendTime;

/** Save Doubleclick move from player */
var eDoubleClickDir	DoubleClickMove;

/** hoverboard handle mesh, attached separately to driver */
var StaticMeshComponent HandleMesh;

/** How much falling damage player can take on hoverboard without ragdolling */
var int FallingDamageRagdollThreshold;

/** set when ragdolling, so DriverLeave() doesn't try to stick driver in another vehicle */
var bool bNoVehicleEntry;

/** If we hit the ground harder than this, reset the physics of the rider to the animated pose, to avoid weird psoes. */
var() float	ImpactGroundResetPhysRiderThresh;

/** If we do hit the ground harder than ImpactGroundResetPhysRiderThresh - set the rider Z vel to be this instead. */
var() float BigImpactPhysRiderZVel;

/** If bot's speed is less than this for a while, it leaves the hoverboard to go on foot fot a bit instead */
var float DesiredSpeedSquared;

/** last time bot's speed was at or above DesiredSpeedSquared */
var float LastDesiredSpeedTime;

replication
{
	if (!bNetOwner)
		bDoHoverboardJump;
}

/**
  * Give script a chance to do some rigid body post initialization
  */
event PostInitRigidBody(PrimitiveComponent PrimComp)
{
	local bool bOldDriving;

	LeanUprightConstraintSetup.PriAxis1 = vect(0,0,1);
	LeanUprightConstraintSetup.SecAxis1 = vect(0,1,0);

	LeanUprightConstraintSetup.PriAxis2 = vect(0,0,1);
	LeanUprightConstraintSetup.SecAxis2 = vect(0,1,0);

	LeanUprightConstraintInstance.InitConstraint(None, CollisionComponent, LeanUprightConstraintSetup, 1.0, self, None, true);

	// Hack to init all the wheels with 'driving' params (ie not parked ones), to avoid updating each frame.
	bOldDriving=bDriving;
	bDriving = TRUE;
	UDKVehicleSimHoverboard(SimObj).InitWheels(self);
	bDriving = bOldDriving;
}

/** Used by PlayerController.FindGoodView() in RoundEnded State */
simulated function FindGoodEndView(PlayerController InPC, out Rotator GoodRotation)
{
	if ( UTPawn(Driver) != None )
	{
		Driver.FindGoodEndView(InPC, GoodRotation);
	}
	else
	{
		super.FindGoodEndView(InPC, GoodRotation);
	}
}

simulated function bool CoversScreenSpace(vector ScreenLoc, Canvas Canvas)
{
	return ( (ScreenLoc.X > 0.5*Canvas.ClipX) &&  (ScreenLoc.X < 0.7*Canvas.ClipX)
		&& (ScreenLoc.Y > 0.5*Canvas.ClipY) );
}

function PlayHorn() {}

simulated function float GetDisplayedHealth()
{
	return (Driver != None) ? Driver.Health : Health;
}

simulated function DisplayHud(UTHud Hud, Canvas Canvas, vector2D HudPOS, optional int SeatIndex)
{
}

/**
  * returns the camera focus position (without camera lag)
  */
simulated function vector GetCameraFocus(int SeatIndex)
{
	return (Driver != None) ? Driver.Mesh.GetBoneLocation(Seats[SeatIndex].CameraTag) : Location;
}

function bool AnySeatAvailable()
{
	return (Driver != none) ? false : super.AnySeatAvailable();
}

/**
  * returns TRUE if vehicle is useable (can be entered)
  */
simulated function bool ShouldShowUseable(PlayerController PC, float Dist)
{
	return false;
}

/**
  * Can't kick out bots from their hoverboard
  */
function bool KickOutBot()
{
	return false;
}

/**
  * Called from TickSpecial().  Doubleclick detected, so pick dodge direction
  */
event RequestDodge()
{
	if (DoubleClickMove == DCLICK_Right)
	{
		Rise = 1.0;
		bIsDodging = TRUE;
		ServerRequestDodge(false);
	}
	else if (DoubleClickMove == DCLICK_Left)
	{
		Rise = 1.0;
		bIsDodging = TRUE;
		ServerRequestDodge(true);
	}
}

/**
  * Server adds dodge force
  * @PARAM bDodgeLeft is true if dodging left, false if dodging right
  */
unreliable server function ServerRequestDodge(bool bDodgeLeft)
{
	local vector X,Y,Z;

	bIsDodging = true;

	GetAxes(Rotation, X, Y, Z);
	Y.Z = 0.0;
	Rise = 1.0;
	DodgeForce = DodgeForceMag * Normal(Y);
	if ( bDodgeLeft )
	{
		DodgeForce *= -1;
	}
	if ( Velocity dot X > 0 )
	{
		DodgeForce -= 0.5 * DodgeForceMag * X;
	}
	DodgeForce.Z = -0.3f * JumpForceMag;
}

event UpdateHoverboardDustEffect(float DustHeight)
{
	HoverboardDust.SetFloatParameter(DustVelMagParamName, VSize(Velocity));
	HoverboardDust.SetFloatParameter(DustBoardHeightParamName, DustHeight);
	HoverboardDust.SetVectorParameter(DustVelParamName, Velocity);

}


/**
  * Get double click status from playercontroller
  */
simulated function Tick(float DeltaSeconds)
{
	local UDKVehicleSimHoverboard SimHoverboard;
	local float BlendDelta, TurnAngVel, Speed, Steer, PitchAngle, NewTargetPitch, MaxPitchChange, DeltaPitch, DesiredYaw, MaxDeltaYaw;
	local bool bWindingUp, bJumpNow;
	local vector DirX, DirY, LocalUp, AngVel, ForwardInZPlane, LeanX, LeanY, LeanZ, HitLocation, HitNormal;
	local rotator LeanRot;
	local PlayerController PC;
	local Actor HitActor;

	if ( (Driver == None) || (Controller == None) )
	{
		// Hack - make extra sure we have no hoverboards without riders.
		if ( Role == ROLE_Authority )
		{
			`log("Uncontrolled hoverboard left around - destroying...");
			Destroy();
		}
		return;
	}
	Super.Tick(DeltaSeconds);

	if ( (PlayerController(Controller) != None) && (PlayerController(Controller).PlayerInput != None) )
	{
		DoubleClickMove = PlayerController(Controller).PlayerInput.CheckForDoubleClickMove(DeltaSeconds);
	}

	SimHoverboard = UDKVehicleSimHoverboard(SimObj);

	// Blend PhysicsWeight smoothly over time.
	if( PhysWeightBlendTimeToGo != 0.0 )
	{
		// Amount we want to change PhysicsWeight by.
		BlendDelta = TargetPhysicsWeight - Driver.Mesh.PhysicsWeight; 

		if( Abs(BlendDelta) > 0.0001 && PhysWeightBlendTimeToGo > DeltaSeconds )
		{
			Driver.Mesh.PhysicsWeight += (BlendDelta / PhysWeightBlendTimeToGo) * DeltaSeconds;
			PhysWeightBlendTimeToGo	-= DeltaSeconds;
		}
		else
		{
			Driver.Mesh.PhysicsWeight = TargetPhysicsWeight;
			PhysWeightBlendTimeToGo	= 0.0;
		}
	}

	SimHoverboard.LandedCountdown -= DeltaSeconds;

	// Handle landing and taking off.
	if ( SimHoverboard.bInAJump || bTrickJumping )
	{
		// Note when we first leave the ground.
		if( !SimHoverboard.bLeftGround && !bVehicleOnGround )
		{
			SimHoverboard.bLeftGround = true;
		}

		// If we were off the ground, and have landed (or we never left the ground) for a second.
		if( bVehicleOnGround && (SimHoverboard.bLeftGround || (WorldInfo.TimeSeconds > LastJumpTime + 1.0)) )
		{
			SimHoverboard.bInAJump = false;
			HoverboardLanded();
			SimHoverboard.CurrentSteerOffset = 0.0;

			// This is done on the server and replicated to clients.
			if(Role == ROLE_Authority)
			{
				bTrickJumping = false;
			}

			SimHoverboard.bLeftGround = false;
			if(bGrabbingBoard)
			{
				ToggleAnimBoard(false, 0.0);
			}
			SimHoverboard.LandedCountdown = 1.0;	
			SimHoverboard.AutoSpin = 0.0;
		}
		else if( bTrickJumping )
		{
			if((bGrab1 || bGrab2) && !bGrabbingBoard)
			{
				ToggleAnimBoard(true, 0.f);
			}
			else if(!(bGrab1 || bGrab2) && bGrabbingBoard)
			{
				if( IsLocallyControlled() && IsHumanControlled() )
				{
					TargetPhysicsWeight = 1.0;
					PhysWeightBlendTimeToGo = 0.1;
				}

				ToggleAnimBoard(false, 0.1);
			}
		}
	}

	// See if we are winding up for a jump
	bWindingUp = (OutputRise < 0.0);

	// Don't allow you to wind up for a jump while in the air
	if( bWindingUp && !SimHoverboard.bInAJump )
	{
		SimHoverboard.TrickJumpWarmup = FMin(SimHoverboard.TrickJumpWarmup + DeltaSeconds, TrickJumpWarmupMax);

		if( Abs(Steering) > 0.2 )
		{
			TrickSpinWarmup += DeltaSeconds;
			if(Steering > 0.0)
			{
				SimHoverboard.AutoSpin = 1.0;
			}
			else
			{
				SimHoverboard.AutoSpin = -1.0;
			}
		}
		else
		{
			TrickSpinWarmup = 0.0;
			SimHoverboard.AutoSpin = 0.0;
		}
	}

	// Calculate Local Up Vector
	GetAxes(Rotation, DirX, DirY, LocalUp);

	AngVel = CollisionComponent.BodyInstance.GetUnrealWorldAngularVelocity();
	TurnAngVel = AngVel dot vect(0,0,0);

	// When over water - enable 'rooster tail'
	if( bVehicleOnWater )
	{
		if ( RoosterEffect == None )
		{
			SpawnRoosterEffect();
		}
		if ( RoosterEffect !=  None )
		{
			if (RoosterEffect.bSuppressSpawning || !RoosterEffect.bIsActive)
			{
				RoosterEffect.ActivateSystem();
				RoosterNoise.Play();
			}

			Speed = FClamp((VSize(Velocity)/MaxSpeed), 0.0, 1.0);
			RoosterEffect.SetFloatParameter('WaterAmount', Speed);
			if ( RoosterNoise != None )
			{
				RoosterNoise.SetFloatParameter('WaterSpeed', Speed);
			}

			Steer = 0.5 + FClamp(TurnAngVel*RoosterTurnScale, -0.5, 0.5);
			RoosterEffect.SetVectorParameter('WaterDirection', vect(1,1,1)*Steer);
		}
	}
	else
	{
		if(RoosterEffect != None && !RoosterEffect.bSuppressSpawning)
		{
			RoosterEffect.DeactivateSystem();
			if (RoosterNoise != None)
			{
				RoosterNoise.Stop();
			}
		}
	}

	// Constrain the hoverboard pitch and roll to a dynamically generated orientation
	// YAW
	LeanRot.Yaw = Rotation.Yaw;

	// PITCH
	// Project forward vector into Z plane and normalize.
	ForwardInZPlane = DirX;
	ForwardInZPlane.Z = 0.0;
	ForwardInZPlane = Normal(ForwardInZPlane);

	PitchAngle = -1.0 * Asin(SimHoverboard.GroundNormal dot ForwardInZPlane);
	NewTargetPitch = 10430.2192 * PitchAngle; // 10430.2192 = Rad2U
	MaxPitchChange = MaxLeanPitchSpeed * DeltaSeconds;
	DeltaPitch = FClamp(NewTargetPitch - TargetPitch, -MaxPitchChange, MaxPitchChange);
	TargetPitch += DeltaPitch;
	LeanRot.Pitch = int(TargetPitch);

	// Add torque to lean as we turn.
	if( !SimHoverboard.bInAJump)
	{
		AddTorque( -1.0 * DirX * ForwardVel * TurnAngVel * TurnLeanFactor );
	}

	GetAxes(LeanRot, LeanX, LeanY, LeanZ);

	SimHoverboard.UpdateLeanConstraint(LeanUprightConstraintInstance, LeanY, LeanZ);

	// Carving sound
	if ( !CurveSound.bWasPlaying )
		CurveSound.Play();	
	CurveSound.VolumeMultiplier = Abs(TurnAngVel)/8192.0;

	PC = PlayerController(Controller);
	if ( PC != None )
	{
		if ( HasWheelsOnGround() && (DoubleClickMove != DCLICK_None) )
		{
			RequestDodge();
			DoubleClickMove = DCLICK_None;
		}
	}
	else if ( HasWheelsOnGround() )
	{
		if ( (LocalUp.Z < WalkableFloorZ) && (VSizeSq(Velocity) < Square(Driver.GroundSpeed)) ) 
		{
			// AI bails if moving slowly and ground is too steep
			BelowSpeedThreshold();
			if (bDeleteMe)
			{
				return;
			}
		}
		else if (LastDesiredSpeedTime == 0.0 || !Controller.InLatentExecution(Controller.LATENT_MOVETOWARD) || (VSizeSq2D(Velocity) > DesiredSpeedSquared) )
		{
			LastDesiredSpeedTime = WorldInfo.TimeSeconds;
		}
		else if (WorldInfo.TimeSeconds - LastDesiredSpeedTime > 1.0)
		{
			// bail because moving too slowly
			BelowSpeedThreshold();
			if (bDeleteMe)
			{
				return;
			}
		}
	}

	// First see if we want to try and jump
	bJumpNow = (OutputRise > 0.0 || (OutputRise == 0.0 && SimHoverboard.TrickJumpWarmup > 0.0) || bIsDodging);

	// Disallow if already doing one
	if(bJumpNow && SimHoverboard.bInAJump)
	{
		bJumpNow = false;
	}

	// Disallow if it hasn't been long enough since last jump
	if( bJumpNow && (WorldInfo.TimeSeconds < LastJumpTime + JumpDelay) )
	{
		bJumpNow = false;
		// make sure bot doesn't queue up a jump (it checks frequently enough that this isn't likely to be helpful)
		if ( UDKBot(Controller) != None )
		{
			Rise = 0.0;
		}
	}

	// Disallow if not over suitable surface
	if( bJumpNow )
	{
		// Don't jump if we are at a steep angle
		if ( LocalUp.Z < 0.5 )
		{
			bJumpNow = false;
		}
		else
		{
			HitActor = Trace(HitLocation, HitNormal, Location - (LocalUp * JumpCheckTraceDist), Location, true);
			bJumpNow = (HitActor != None);
		}
	}

	// Ok - jumping now!
	if ( bJumpNow )
	{	
		BoardJumpEffect();

		if ( UDKBot(Controller) != None )
		{
			Rise = 0.0;
		}

		SimHoverboard.bInAJump = TRUE;
		SimHoverboard.bLeftGround = FALSE;

		// Remember the yaw we have when we take off.
		SimHoverboard.TakeoffYaw = DriverViewYaw;

		// If trick jumping
		if ( SimHoverboard.TrickJumpWarmup > 0.0 && !bIsDodging)
		{
			bTrickJumping = TRUE;
			SimHoverboard.SpinHeadingOffset = 0.f;
		}

		AddImpulse( JumpForceMag*vect(0,0,1) + DodgeForce );
		DodgeForce = vect(0,0,0);
		LastJumpTime = WorldInfo.TimeSeconds;
	}

	bIsDodging = false;
	bNoZDamping = (WorldInfo.TimeSeconds - 0.25 < LastJumpTime);

	if(OutputRise == 0.0)
	{
		SimHoverboard.TrickJumpWarmup = 0.0;
		TrickSpinWarmup = 0.0;
	}

	// If we have control for turning body to match look direction, update them here.
	if( SpineTurnControl != None )
	{
		DesiredYaw = FClamp(SimHoverboard.CurrentLookYaw, -MaxTrackYaw, MaxTrackYaw);
		MaxDeltaYaw = DeltaSeconds * 3.0;
		CurrentHeadYaw += FClamp(DesiredYaw - CurrentHeadYaw, -MaxDeltaYaw, MaxDeltaYaw);

		SpineTurnControl.BoneRotation.Yaw = int(CurrentHeadYaw * 10430.2192);  // 10430.2192 = Rad2U
	}
}

simulated function WeaponRotationChanged(int SeatIndex)
{
	return;
}

function DriverDied(class<DamageType> DamageType)
{
	// to get more dual enforcer opportunities, throw out enforcer when kill player on hoverboard
	if ( Driver != None )
	{
		Driver.Weapon = None;
		Driver.ThrowActiveWeapon();
	}
	Super.DriverDied(DamageType);
}

simulated function InitializeEffects()
{
	local ParticleSystem TeamThrusterEffect;
	local ParticleSystem TeamDustEffect;

	if (WorldInfo.NetMode != NM_DedicatedServer && !bInitializedVehicleEffects)
	{
		if(Team == 1)
		{
			TeamThrusterEffect = BlueThrusterEffect;
			TeamDustEffect = BlueDustEffect;
		}
		else
		{
			TeamThrusterEffect = RedThrusterEffect;
			TeamDustEffect = RedDustEffect;
		}

		ThrusterEffect.SetTemplate(TeamThrusterEffect);
		HoverboardDust.SetTemplate(TeamDustEffect);

		AttachHoverboardEffects();
	}

	Super.InitializeEffects();
}

simulated function AttachHoverboardEffects()
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (bGrabbingBoard)
		{
			if(HoverboardMesh != None)
			{
				HoverboardMesh.AttachComponentToSocket(ThrusterEffect, ThrusterEffectSocket);
			}
		}
		else
		{
			Mesh.AttachComponentToSocket(ThrusterEffect, ThrusterEffectSocket);
		}
	}
}

/**
 * Called when a pawn enters the vehicle
 *
 * @Param P		The Pawn entering the vehicle
 */
function bool DriverEnter(Pawn P)
{
	local int i;
	local RB_BodyInstance BodyInstance;
	local vehicle OldDrivenVehicle;

	// set AI desired speed based on speed of driver
	DesiredSpeedSquared = P.GroundSpeed * 0.25;
	DesiredSpeedSquared *= DesiredSpeedSquared;

	// keep player from getting super jump while getting onto hoverboard
	if ( P.Velocity.Z > 0 )
	{
		LastJumpTime = WorldInfo.TimeSeconds - 0.75;
	}

	// give impulse to physics to match velocity player had before
	Mesh.AddImpulse(P.Velocity,,, true);
	// immediately set BodyInstance velocity properties so if we're already colliding with something RigidBodyCollision() has the correct values
	BodyInstance = Mesh.GetRootBodyInstance();

	// if we fail to spawn the bodyInstance, physics failed here, so just disallow the player to get on hoverboard
	// zero out the pawn's velocity in case his velocity is what caused the physics object to fail
	if (BodyInstance == None)
	{
		P.Velocity = vect(0, 0, 0);
		return false;
	}

	BodyInstance.Velocity = P.Velocity;
	BodyInstance.PreviousVelocity = P.Velocity;

	if (bDisableRepulsorsAtMaxFallSpeed && P.Velocity.Z <= -P.MaxFallSpeed)
	{
		for (i = 0; i < Wheels.length; i++)
		{
			SetWheelCollision(i, false);
		}
	}

	CameraInitialOut = 0.1/SeatCameraScale;

	// temporarily set drivenvehicle so any loaded weapon fires don't hit me.
	OldDrivenVehicle = P.DrivenVehicle;
	P.DrivenVehicle = self;

	if ( BodyInstance == none || !super.DriverEnter(P) )
	{
		P.DrivenVehicle = OldDrivenVehicle;
		return false;
	}

	SetOnlyControllableByTilt( TRUE );

	return true;
}

simulated function vector GetCameraStart(int SeatIndex)
{
	local vector NewStart, UseVel;

	UseVel = ClampLength(Velocity, HoverCamMaxVelUsed);
	NewStart = super.GetCameraStart(SeatIndex);
	return NewStart + (UseVel * VelLookAtOffset);
}

simulated function VehicleCalcCamera(float DeltaTime, int SeatIndex, out vector out_CamLoc, out rotator out_CamRot, out vector CamStart, optional bool bPivotOnly)
{
	local float RealCameraScale;
	local float VelSize;
	local vector AngVel, NewPos, HitLocation, HitNormal;
	local int TargetRoll, DeltaRoll;
	local actor HitActor;

	RealCameraScale = SeatCameraScale;
	if ( CameraInitialOut < 1.0 )
	{
		CameraInitialOut = FMin(1.0, CameraInitialOut + 3*DeltaTime);
		SeatCameraScale *= CameraInitialOut;
	}
	Super.VehicleCalcCamera(DeltaTime, SeatIndex, out_CamLoc, out_CamRot, CamStart, bPivotOnly);
	SeatCameraScale = RealCameraScale;

	VelSize = FMin(VSize(Velocity), HoverCamMaxVelUsed);

	out_CamRot += HoverCamRotOffset;
	out_CamRot = Normalize(out_CamRot);

	// Apply extra translation
	NewPos = out_CamLoc + ((HoverCamOffset + (VelSize * VelBasedCamOffset)) >> out_CamRot);

	// Line check to see we can do that.
	HitActor = Trace(HitLocation, HitNormal, NewPos, out_CamLoc, FALSE, vect(12,12,12));
	if( HitActor != None )
	{
		out_CamLoc = HitLocation;
	}
	else
	{
		out_CamLoc = NewPos;
	}

	TargetRoll = 0;
	if(!UDKVehicleSimHoverboard(SimObj).bInAJump && Mesh.BodyInstance != None)
	{
		AngVel = Mesh.BodyInstance.GetUnrealWorldAngularVelocity();
		TargetRoll = VelRollFactor * AngVel.Z * VelSize;
	}

	DeltaRoll = Clamp(TargetRoll - CurrentViewRoll, -ViewRollRate*DeltaTime, ViewRollRate*DeltaTime);
	CurrentViewRoll += DeltaRoll;
	out_CamRot.Roll = CurrentViewRoll;
}

simulated function AttachDriver( Pawn P )
{
	local UTPawn UTP;

	UTP = UTPawn(P);
	if (UTP != None)
	{
        //Disable foot placement controls
		UTP.bEnableFootPlacement = FALSE;
		if ( UTP.LeftLegControl != None )
		{
		UTP.LeftLegControl.SetSkelControlActive(false);
		UTP.LeftLegControl.SetSkelControlStrength(0.0, 0.0);
		}
		if ( UTP.RightLegControl != None )
		{
		UTP.RightLegControl.SetSkelControlActive(false);
		UTP.RightLegControl.SetSkelControlStrength(0.0, 0.0);
	}
	}

	Super.AttachDriver(P);

	if (UTP != None && UTP.Mesh.SkeletalMesh != None)
	{
		HandleMesh.SetShadowParent(UTP.Mesh);
		HandleMesh.SetLightEnvironment( UTP.LightEnvironment );
		UTP.Mesh.AttachComponentToSocket(HandleMesh, UTP.WeaponSocket);

		// Disable possible blending-out of hit reactions.
		UTP.bBlendOutTakeHitPhysics = FALSE;

		UTP.Mesh.PhysicsWeight = 0.0;
		UTP.Mesh.MinDistFactorForKinematicUpdate = 0.0;
		UTP.Mesh.bUpdateKinematicBonesFromAnimation = TRUE;

		UTP.RootRotControl.BoneRotation.Yaw = 0;
		UTP.DrivingNode.UpdateDrivingState();
		UTP.VehicleNode.UpdateVehicleState();
		UTP.HoverboardingNode.SetActiveChild(0, 0.0);

		UTP.FullBodyAnimSlot.StopCustomAnim(0.0);
		UTP.TopHalfAnimSlot.StopCustomAnim(0.0);

		UTP.Mesh.ForceSkelUpdate();
		UTP.Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
		InitPhysicsAnimPawn();
	}
}

simulated function SitDriver(UTPawn UTP, int SeatIndex)
{
	UTP.SetLocation(Location + vect(0,0,100));

	Super.SitDriver(UTP, SeatIndex);

	// Force the driver skelmeshcomp to be in the right place before trying to
	//UTP.ForceUpdateComponents(FALSE,TRUE);
	UTP.Mesh.ForceUpdate(true);

	// don't reduce pawn culldistance as it's the most visible part of the hoverboard
	UTP.Mesh.SetCullDistance(UTP.default.Mesh.CachedMaxDrawDistance);
}

/** Set whether the flag is attached directly to kinematic bodies on the rider. */
simulated static function SetFlagAttachToBody(UTPawn UTP, bool bAttached)
{
	local int i;
	local UTCTFFlag Flag;

	for (i = 0; i < UTP.Attached.length; i++)
	{
		Flag = UTCTFFlag(UTP.Attached[i]);
		if(Flag != None)
		{
			Flag.SetBase(UTP,,UTP.Mesh,Flag.GameObjBone3P);
			Flag.SetRelativeRotation(Flag.GameObjRot3P);
			Flag.SetRelativeLocation(Flag.GameObjOffset3P);
			Flag.SkelMesh.ResetClothVertsToRefPose();
			if (Flag.BaseSkelComponent != None)
			{
				Flag.SkelMesh.SetAttachClothVertsToBaseBody(FALSE);
				if(bAttached)
				{
					Flag.SkelMesh.SetAttachClothVertsToBaseBody(TRUE);
				}
			}
		}
	}
}

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	local UTPawn UTP;
	local Canvas	Canvas;

	super.DisplayDebug(HUD, out_YL, out_YPos);

	UTP = UTPawn(Driver);
	Canvas = HUD.Canvas;

	Canvas.SetDrawColor(128,128,255);
	Canvas.DrawText("UTP PhysicsWeight "$UTP.Mesh.PhysicsWeight);
	out_YPos += out_YL;
	Canvas.SetPos(4,out_YPos);
}

/** Set up the rider with physics for riding. */
simulated function SetHoverboardRiderPhysics(UTPawn UTP)
{
	local array<name> SpringBodies;
	local int i;
	local vector WorldConPos, LocalConPos;
	local rotator WorldConRot, LocalConRot;

	// Turn off driver's collision with rigid bodies so it doesn't collide with hoverboard
	UTP.SetPawnRBChannels(FALSE);

	// Use kinematic actor method for bone springs. Makes damping relative to animated pose rather than 'world',
	// so we don't tend to lag behind the hoverboard when moving quickly.
	for( i=0; i<UTP.Mesh.PhysicsAssetInstance.Bodies.Length; i++)
	{
		UTP.Mesh.PhysicsAssetInstance.Bodies[i].bMakeSpringToBaseCollisionComponent = TRUE;
	}

	// Set rider state based on kinematic update state.
	UTP.Mesh.PhysicsWeight = 1.f;
	UTP.Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);

	// Make physics interaction with hoverboard one-way
	UTP.Mesh.SetRBDominanceGroup(Mesh.RBDominanceGroup+1);

	SetFlagAttachToBody(UTP, TRUE);

	WorldConPos = UTP.Mesh.GetBoneLocation(UTP.LeftFootBone, 0);
	WorldConRot = QuatToRotator( UTP.Mesh.GetBoneQuaternion(UTP.LeftFootBone, 0) );
	Mesh.TransformToBoneSpace('UpperBody', WorldConPos, WorldConRot, LocalConPos, LocalConRot);
	FootBoardConstraintSetup.ConstraintBone1 = UTP.LeftFootBone;
	FootBoardConstraintSetup.ConstraintBone2 = 'UpperBody';
	FootBoardConstraintSetup.Pos2 = 0.02f * LocalConPos;
	FootBoardConstraintSetup.PriAxis2 = vect(1,0,0) >> LocalConRot;
	FootBoardConstraintSetup.SecAxis2 = vect(0,1,0) >> LocalConRot;
	LeftFootBoardConstraintInstance.InitConstraint(UTP.Mesh, Mesh, FootBoardConstraintSetup, 1.f, self, None, false);

	WorldConPos = UTP.Mesh.GetBoneLocation(UTP.RightFootBone, 0);
	WorldConRot = QuatToRotator( UTP.Mesh.GetBoneQuaternion(UTP.RightFootBone, 0) );
	Mesh.TransformToBoneSpace('UpperBody', WorldConPos, WorldConRot, LocalConPos, LocalConRot);
	FootBoardConstraintSetup.ConstraintBone1 = UTP.RightFootBone;
	FootBoardConstraintSetup.ConstraintBone2 = 'UpperBody';
	FootBoardConstraintSetup.Pos2 = 0.02f * LocalConPos;
	FootBoardConstraintSetup.PriAxis2 = vect(1,0,0) >> LocalConRot;
	FootBoardConstraintSetup.SecAxis2 = vect(0,1,0) >> LocalConRot;
	RightFootBoardConstraintInstance.InitConstraint(UTP.Mesh, Mesh, FootBoardConstraintSetup, 1.f, self, None, false);

	SpringBodies.AddItem('b_Spine2');
	SpringBodies.AddItem('b_RightHand');
	SpringBodies.AddItem('b_LeftHand');
	UTP.Mesh.PhysicsAssetInstance.SetNamedRBBoneSprings(TRUE, SpringBodies, 10.f, 0.5f, UTP.Mesh);

	UTP.Mesh.bUpdateJointsFromAnimation = TRUE;
	// Set the global linear and angular drive scale that is applied to all bones to be 1.0f so it uses the values setup in UnrealEd
	UTP.Mesh.PhysicsAssetInstance.SetNamedMotorsAngularPositionDrive(false, false, UTP.NoDriveBodies, UTP.Mesh, true);
	UTP.Mesh.PhysicsAssetInstance.SetAngularDriveScale(1.0f, 4.0f, 0.0f);

	UTP.BackSpring(10.0);
	UTP.BackDamp(0.25);
	UTP.HandSpring(2.0);
	UTP.HandDamp(0.005);

	UTP.bIsHoverboardAnimPawn=TRUE;
}

exec function BackSpring(float LinSpring)
{
	local UTPawn UTP;
	UTP = UTPawn(Driver);
	UTP.BackSpring(LinSpring);
}

exec function BackDamp(float LinDamp)
{
	local UTPawn UTP;
	UTP = UTPawn(Driver);
	UTP.BackDamp(LinDamp);
}

exec function HandSpring(float LinSpring)
{
	local UTPawn UTP;
	UTP = UTPawn(Driver);
	UTP.HandSpring(LinSpring);
}

exec function HandDamp(float LinDamp)
{
	local UTPawn UTP;
	UTP = UTPawn(Driver);
	UTP.HandDamp(LinDamp);
}

simulated exec function TestResetPhys()
{
	`log("Reset Char Phys");
	UTPawn(Driver).ResetCharPhysState();
}

static function bool IsHumanDriver(UTVehicle_Hoverboard HB, Pawn P)
{
	if(HB.IsLocallyControlled() && HB.IsHumanControlled())
	{
		return TRUE;
	}

	if(P != None && P.IsLocallyControlled() && P.IsHumanControlled())
	{
		return TRUE;
	}

	return FALSE;
}

simulated function OnDriverPhysicsAssetChanged(UTPawn UTP)
{
	if(IsHumanDriver(self, UTP))
	{
		if(!UTP.bIsHoverboardAnimPawn)
		{
			SetHoverboardRiderPhysics(UTP);
		}
	}
	else
	{
		UTP.Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
		UTP.Mesh.bUpdateKinematicBonesFromAnimation = FALSE;
	}

	UTP.SetHandIKEnabled(FALSE);
}

simulated function InitPhysicsAnimPawn()
{
	local UTPawn UTP;

	UTP = UTPawn(Driver);
	if (UTP != None && UTP.Mesh != None && UTP.Mesh.PhysicsAssetInstance != None)
	{
		// Switch over to physics representation of pawn
		Driver.CollisionComponent = Driver.Mesh;

		// If its us, or another player who is close enough to have kinematics updated, blend from animated to physics.
		if(IsHumanDriver(self, UTP))
		{
			if(!UTP.bIsHoverboardAnimPawn)
			{
				SetHoverboardRiderPhysics(UTP);
			}

			// Animation should be entirely physics driven
			UTP.Mesh.PhysicsWeight = 0.0;
			TargetPhysicsWeight = 1.0;
			PhysWeightBlendTimeToGo = PhysWeightBlendTime;
		}
		else
		{
			UTP.Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
			UTP.Mesh.bUpdateKinematicBonesFromAnimation = FALSE;
			UTP.Mesh.PhysicsWeight = 0.0;
			PhysWeightBlendTimeToGo = 0.0;
		}

		SpineTurnControl = SkelControlSingleBone(UTP.Mesh.FindSkelControl('SpineTurn'));
		if(SpineTurnControl != None)
		{
			SpineTurnControl.BoneRotation = rot(0,0,0);
			SpineTurnControl.SetSkelControlStrength(1.0, 0.5);
		}
	}
}


simulated function DetachDriver( Pawn P )
{
	local array<name> SpringBodies;
	local UTPawn UTP;

	if(SpineTurnControl != None)
	{
		SpineTurnControl.SetSkelControlStrength(0.0, 0.0);
		SpineTurnControl = None;
	}

	// Make sure bones are in correct position when falling off board.
	P.Mesh.UpdateRBBonesFromSpaceBases(TRUE,TRUE);

	if(HoverboardMesh != None)
	{
		P.Mesh.DetachComponent(HoverboardMesh);
	}
	P.Mesh.DetachComponent(HandleMesh);
	HandleMesh.SetShadowParent(None);
	HandleMesh.SetLightEnvironment( None );

	if (P.Mesh != None && P.Mesh.PhysicsAssetInstance != None)
	{
		P.CollisionComponent = P.CylinderComponent;
		P.Mesh.PhysicsWeight = 0.0;
		P.Mesh.bUpdateJointsFromAnimation = FALSE;

		P.Mesh.SetRBDominanceGroup(P.default.Mesh.RBDominanceGroup);

		// Turn off bone springs and drive
		SpringBodies.AddItem('b_Spine2');
		SpringBodies.AddItem('b_RightHand');
		SpringBodies.AddItem('b_LeftHand');
		P.Mesh.PhysicsAssetInstance.SetNamedRBBoneSprings(FALSE, SpringBodies, 10.f, 0.5f, P.Mesh);
		P.Mesh.PhysicsAssetInstance.SetAllMotorsAngularPositionDrive(false, false);

		P.Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
		P.Mesh.PhysicsAssetInstance.SetFullAnimWeightBonesFixed(FALSE, P.Mesh);

		P.Mesh.MinDistFactorForKinematicUpdate = P.default.Mesh.MinDistFactorForKinematicUpdate;
		P.Mesh.bUpdateKinematicBonesFromAnimation = P.default.Mesh.bUpdateKinematicBonesFromAnimation;
	}
	P.SetTickGroup(P.default.TickGroup);
	P.Mesh.SetTickGroup(P.default.Mesh.TickGroup);

	UTP = UTPawn(Driver);
	if(UTP != None)
	{
		UTP.bIsHoverboardAnimPawn = false;
		//Enable foot placement controls
        UTP.bEnableFootPlacement = true;
		UTP.LeftLegControl.SetSkelControlActive(true);
		UTP.RightLegControl.SetSkelControlActive(true);
	}

	Super.DetachDriver(P);
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
	super.PossessedBy(C, bVehicleTransition);

	// reset jump/duck properties
	bDoHoverboardJump = false;
	bIsDodging = false;
	bGrab1 = false;
	bGrab2 = false;
}

reliable server function ServerChangeSeat(int RequestedSeat)
{
	// if pressed hoverboard weapon key again, leave hoverboard
	if ( RequestedSeat == -1 )
	{
		bNoVehicleEntry = true;
		DriverLeave(false);
	}
}

simulated event BoardJumpEffect()
{
	if ( Role == ROLE_Authority )
	{
		bDoHoverboardJump = !bDoHoverboardJump;
	}
	PlaySound(JumpSound, true);
	VehicleEvent('BoostStart');
}

simulated function SetInputs(float InForward, float InStrafe, float InUp)
{
	Super.SetInputs(InForward, InStrafe, InUp);
}

// Force a spin jump
function ForceSpinJump()
{
	bForceSpinWarmup = false;
	UDKVehicleSimHoverboard(SimObj).TrickJumpWarmup = TrickJumpWarmupMax;
}

reliable server function ServerSpin(float Direction)
{

}

reliable client function ClientForceSpinWarmup()
{
	bForceSpinWarmup = true;
}

function OnHoverboardSpinJump(UTSeqAct_HoverboardSpinJump Action)
{
	bForceSpinWarmup = true;
	ClientForceSpinWarmup();
	SetTimer(Action.WarmupTime, false, 'ForceSpinJump');
}

simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if ( Role < ROLE_Authority )
		return;

	bForceNetUpdate = TRUE; // force quick net update

	// pass damage to driver
	if (Driver != None)
	{
		Driver.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}

	// if the driver wasn't killed from the hit, keep going
	if (Driver != None && Driver.Health > 0 && !bDeleteMe)
	{
		// take momentum from hit, but not damage
		Super.TakeDamage(0, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	if (Driver != None && !Driver.Died(Killer, DamageType, HitLocation))
	{
		RagdollDriver();
	}

	Destroy();

	return true;
}

// DriverRadiusDamage() ignored, since our TakeDamage() already passes damage to driver
function DriverRadiusDamage(float DamageAmount, float DamageRadius, Controller EventInstigator, class<DamageType> DamageType, float Momentum, vector HitLocation, Actor DamageCauser, optional float DamageFalloffExp);

function NotifyDriverTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> DamageType, vector Momentum)
{
	local class<UTDamageType> UTDmgType;

	// if we take enemy weapons fire, toss driver into ragdoll
	if (Damage > 0 && InstigatedBy != None && !WorldInfo.GRI.OnSameTeam(InstigatedBy, self))
	{
		UTDmgType = class<UTDamageType>(DamageType);
		if (UTDmgType != None && UTDmgType.default.DamageWeaponClass != None)
		{
			// might be in physics tick and can't send things to ragdoll during that, so delay one tick
			SetTimer(0.01, false, 'RagdollDriver');
		}
	}
}

simulated function float GetChargePower()
{
	return FClamp( (WorldInfo.TimeSeconds - LastJumpTime), 0, JumpDelay)/JumpDelay;
}

//========================================
// AI Interface

function byte ChooseFireMode()
{
	return 0;
}

function bool Dodge(eDoubleClickDir InDoubleClickMove)
{
	Rise = 1;
	return true;
}

function IncomingMissile(Projectile P)
{
	local UTBot B;

	B = UTBot(Controller);
	if (B != None && B.Skill > 2.0 + 2.0 * FRand())
	{
		DriverLeave(false);
	}
}

event bool DriverLeave(bool bForceLeave)
{
	local Pawn SavedDriver;

	SavedDriver = Driver;

	// turn off collision so that we can place the driver exactly where it is on the hoverboard
	SetCollision(false, false);
	ExitPositions[0] = Driver.Location - Location;
	SetOnlyControllableByTilt( FALSE );

	if (Super.DriverLeave(bForceLeave))
	{
		if (!bNoVehicleEntry)
		{
			// Get into towing vehicle if close enough
			if ( PlayerController(SavedDriver.Controller) != None )
			{
				// try to get into any vehicle if close enough and looking at it
				PlayerController(SavedDriver.Controller).FindVehicleToDrive();
			}
		}
		return true;
	}
	else
	{
		// failed to exit, turn collision back on
		SetCollision(default.bCollideActors, default.bBlockActors);
		return false;
	}
}

function DriverLeft()
{
	Driver.Velocity = Velocity;
	if ( UTPawn(Driver) != None )
	{
		UTPawn(Driver).LastHoverboardTime = WorldInfo.TimeSeconds;
	}

	SetOnlyControllableByTilt(false);

	Super.DriverLeft();
	Destroy();
}

simulated function DrivingStatusChanged()
{
	bGrab1 = false;
	bGrab2 = false;

	Super.DrivingStatusChanged();
}

/** Used to turn on or off the functionality of the controller only accepting input from the tilt aspect (if it has it) **/
reliable client function SetOnlyControllableByTilt( bool bActive )
{
	local PlayerController PC;

	PC = PlayerController(Controller);

	if( (PC == none) && (Driver != None) )
	{
		PC = PlayerController(Driver.Controller);
	}

	if( PC != none )
	{
		PC.SetOnlyUseControllerTiltInput( bActive );
		PC.SetUseTiltForwardAndBack( !bActive );  // we do not want to have the tilt forward/back be on
		PC.SetControllerTiltActive( bActive );
	}
}

simulated function ReplicatedEvent(name VarName)
{
	if (VarName == 'bDoHoverboardJump')
	{
		BoardJumpEffect();
	}
	else
	{
		if (VarName == 'Driver')
		{
			if ( (Driver != None) && (UTPlayerController(Controller) != None) && (Driver.DrivenVehicle == None) )
			{
				Driver.DrivenVehicle = self;
				Driver.StartDriving(self);
			}
		}
		Super.ReplicatedEvent(VarName);
	}
}

simulated function bool DisableVehicle()
{
	RagdollDriver();
	return true;
}

/** kick the driver out and throw him into ragdoll because we ran into something */
function RagdollDriver()
{
	local UTPawn OldDriver;

	bNoVehicleEntry = true;
	OldDriver = UTPawn(Driver);
	if (OldDriver != None)
	{
		DriverLeave(true);
		OldDriver.SoundGroupClass.static.PlayFallingDamageLandSound(OldDriver);
		OldDriver.Velocity = Velocity;
		OldDriver.ForceRagdoll();
		if (OldDriver.Physics == PHYS_RigidBody)
		{
			// apply a small impulse towards the top of the player so the body pitches forward a bit
			OldDriver.Mesh.AddImpulse(Normal(Velocity) * 100.0, OldDriver.Location + vect(0,0,0.75) * OldDriver.GetCollisionHeight());
		}
	}
}

event bool EncroachingOn(Actor Other)
{
	RanInto(Other);
	return bDeleteMe; // return true if we were destroyed (driver kicked out) so the other thing doesn't think it got run over
}

event RanInto(Actor Other)
{
	if (Role == ROLE_Authority && Pawn(Other) != None && !WorldInfo.GRI.OnSameTeam(self, Other))
	{
		if (Driver == None)
		{
			if (Controller == None)
			{
				// encroached while spawning, driver isn't in yet
				Destroy();
			}
		}
		else
		{
			RagdollDriver();
		}
	}
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
					const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	local RB_BodyInstance BodyInstance;
	local Vehicle OtherVehicle;
	local int OldHealth;

	if (Role == ROLE_Authority)
	{
		BodyInstance = Mesh.GetRootBodyInstance();
		OtherVehicle = (OtherComponent != None) ? Vehicle(OtherComponent.Owner) : None;

		if ( (OtherVehicle != None) && !WorldInfo.GRI.OnSameTeam(self, OtherVehicle)
			&& OtherVehicle.bDriving )
		{
			if ( UTVehicle_Hoverboard(OtherVehicle) != None )
			{
				RagdollDriver();
				Super(SVehicle).RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
				return;
			}
			else
			{
				OtherVehicle.RanInto(self);
			}
		}
		if ( !IsTimerActive('RagdollDriver') && Driver != None )
		{
			if (BodyInstance.PreviousVelocity.Z < -Driver.MaxFallSpeed)
			{
				// only check fall damage for Z axis collisions
				if (Abs(RigidCollisionData.ContactInfos[0].ContactNormal.Z) > 0.5f)
				{
					Driver.Velocity = BodyInstance.PreviousVelocity;
					OldHealth = Driver.Health;
					Driver.TakeFallingDamage();
					// zero our velocity so that the ragdoll'ed driver won't take falling damage again
					// unless it gets into another long fall
					Velocity.Z = 0.0;
					if ( (Driver.Health < 0) || (OldHealth - Driver.Health > FallingDamageRagdollThreshold) )
					{
						RagdollDriver();
					}
					Super(SVehicle).RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
					return;
				}
			}
			else if (OtherComponent != None && bTrickJumping && (bGrab1 || bGrab2))
			{
				RagdollDriver();
				Super(SVehicle).RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
				return;
			}
		}

		Super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
	}
}

// ignore penetration for hoverboard
event RBPenetrationDestroy();

simulated function StopVehicleSounds()
{
	super.StopVehicleSounds();
	CurveSound.Stop();
}

simulated event ToggleAnimBoard(bool bAnimBoard, float Delay)
{
	local UTPawn UTP;

	UTP = UTPawn(Driver);

	if (bAnimBoard)
	{
		bGrabbingBoard = TRUE;

		// Create trick board mesh now
		if(HoverboardMesh == None)
		{
			HoverboardMesh = new(self) class'UDKSkeletalMeshComponent';
			HoverboardMesh.SetSkeletalMesh(Mesh.SkeletalMesh);
			HoverboardMesh.SetLightEnvironment(Mesh.LightEnvironment);
			HoverboardMesh.CastShadow = TRUE;
		}

		Mesh.SetHidden(TRUE);

		if(UTP != None)
		{
			UTP.Mesh.AttachComponent(HoverboardMesh, UTP.LeftFootBone, MeshLocationOffset, MeshRotationOffset);
			HoverboardMesh.SetShadowParent(UTP.Mesh);
		}

		AttachHoverboardEffects();

		if(IsHumanDriver(self, Driver))
		{
			TargetPhysicsWeight = 0.0;
			PhysWeightBlendTimeToGo = 0.1;
		}
    }
    else
    {
		bGrabbingBoard = FALSE;
		if(Delay > 0.0)
		{
			SetTimer(Delay, false, 'HideBoard');
		}
		else
		{
			HideBoard();
		}

		if(IsHumanDriver(self, Driver))
		{
			TargetPhysicsWeight = 1.0;
			PhysWeightBlendTimeToGo = 0.1;
		}
	}
}

simulated event HideBoard()
{
	AttachHoverboardEffects();

	Mesh.SetHidden(FALSE);

	if(Driver != None)
	{
		Driver.Mesh.SetShadowParent(Mesh);

		if(HoverboardMesh != None)
		{
			HoverboardMesh.SetShadowParent(None);
			Driver.Mesh.DetachComponent(HoverboardMesh);
		}
	}
}

simulated event HoverboardLanded()
{
	local vector NewVel;

	if((-1.0 * Velocity.Z) > ImpactGroundResetPhysRiderThresh)
	{
		Driver.Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);

		NewVel.X = Velocity.X;
		NewVel.Y = Velocity.Y;
		NewVel.Z = BigImpactPhysRiderZVel;
		Driver.Mesh.SetRBLinearVelocity(NewVel, FALSE);
	}

	if(bTrickJumping && (bGrab1 || bGrab2) && Role == ROLE_Authority)
	{
		SetTimer(0.01, false, 'RagdollDriver');
	}
}

/** Check the bIgnoreHoverboards flag. */
function bool OnTouchForcedDirVolume(UDKForcedDirectionVolume Vol)
{
	if(Vol.bIgnoreHoverboards)
	{
		return FALSE;
	}
	else
	{
		return TRUE;
	}
}

/** spawn and attach effects for moving over water - called from C++ if RoosterEffect is None when over water */
simulated event SpawnRoosterEffect()
{
	local Vector RoosterEffectOffset;

	// Offset the RoosterEffect to be at the base of the collision cylinder, so it appears at the water's surface
	RoosterEffectOffset.Z = (-CylinderComponent.Translation.Z - CylinderComponent.CollisionHeight*0.5f);

	RoosterEffect = new(self) class'ParticleSystemComponent';
	RoosterEffect.bAutoActivate = false;
	RoosterEffect.SetTemplate(RoosterEffectTemplate);
	RoosterEffect.SetTranslation(RoosterEffectOffset);
	Mesh.AttachComponentToSocket(RoosterEffect, 'RearCenterThrusterSocket');

	RoosterNoise = new(self) class'AudioComponent';
	RoosterNoise.SoundCue = RoosterSoundCue;
	RoosterNoise.VolumeMultiplier = 5.0;
}

function bool TooCloseToAttack(Actor Other)
{
	return false;
}

/** called when AI controlled and the hoverboard is moving too slow so the AI wants to bail */
event BelowSpeedThreshold()
{
	local UTBot B;

	B = UTBot(Instigator.Controller);
	if (B != None)
	{
		B.LeaveVehicle(false);
	}
	else
	{
		DriverLeave(false);
	}
}

event bool ContinueOnFoot()
{
	local UTBot B;

	if (Super.ContinueOnFoot())
	{
		// make sure bot doesn't immediately get back on
		B = UTBot(Controller);
		if (B != None)
		{
			B.LastTryHoverboardTime = WorldInfo.TimeSeconds + 4.0;
		}
		return true;
	}
	else
	{
		return false;
	}
}

defaultproperties
{
	MaxGroundEffectDist=256.0
	GroundEffectDistParameterName=DistToGround

	Begin Object Name=CollisionCylinder
		CollisionHeight=+44.0
		CollisionRadius=+40.0
		Translation=(Z=25.0)
	End Object

	MeshLocationOffset=(X=5,Y=5,Z=15)
	MeshRotationOffset=(Pitch=10012,Roll=16382,Yaw=18204)

	MeleeRange=-100.0
	bDrawHealthOnHUD=false

	COMOffset=(x=10.0,y=0.0,z=-35.0)

	JumpForceMag=5000.0
	DodgeForceMag=5000.0
	JumpCheckTraceDist=90.0
	TrickJumpWarmupMax=0.5
	JumpDelay=1.0
	WaterDamage=0.0

	MaxAngularVelocity=110000.0

	AirSpeed=900
	GroundSpeed=900.0
	MaxSpeed=3500.0
	MomentumMult=2.0
	bDisableRepulsorsAtMaxFallSpeed=true

	bCanCarryFlag=true
	bFollowLookDir=true
	bTurnInPlace=true
	bScriptedRise=True
	bCanStrafe=false
	ObjectiveGetOutDist=750.0
	MaxDesireability=0.6
	SpawnRadius=125.0
	CollisionDamageMult=0.0013
	bValidLinkTarget=false

	bStayUpright=false

	TurnLeanFactor=0.0013
	MaxLeanPitchSpeed=10000.0

	MaxTrackYaw=1.0

	bUseSuspensionAxis=true

	Seats(0)={(GunClass=class'UTVWeap_TowCable',
				GunSocket=(FireSocket),
				CameraTag=b_Hips,
				CameraOffset=-200,
				DriverDamageMult=1.0,
				bSeatVisible=true,
				SeatBone=UpperBody,
				SeatOffset=(X=0,Y=0,Z=51))}

	InertiaTensorMultiplier=(x=1.0,y=1.0,z=1.0)

	GroundEffectIndices=(0)

	RoosterTurnScale=1.0

	bTeamLocked=false
	Team=255
	bAttachDriver=true
	bDriverIsVisible=true
	Eyeheight=35
	BaseEyeheight=35
	bShouldLeaveForCombat=true

	BurnOutTime=2.0

	//@TEXTURECHANGEFIXME - Needs actual UV's
	IconCoords=(U=0,V=0,UL=0,VL=0)

	// Tow Cable
	Begin Object Class=RB_DistanceJointSetup Name=MyDistanceJointSetup
	End Object
	DistanceJointSetup=MyDistanceJointSetup
	Begin Object Class=RB_ConstraintInstance Name=MyDistanceJointInstance
	End Object
	DistanceJointInstance=MyDistanceJointInstance

	Begin Object Class=UTParticleSystemComponent Name=HoverboardDust0
		AbsoluteTranslation=true
		AbsoluteRotation=true
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
	End Object
	Components.Add(HoverboardDust0);
	HoverboardDust=HoverboardDust0

	DustVelMagParamName=BoardVelMag
	DustBoardHeightParamName=BoardHeight
	DustVelParamName=BoardVel

	SeatCameraScale=0.8
	bRotateCameraUnderVehicle=true
	bNoZSmoothing=false
	bNoFollowJumpZ=true

	DefaultFOV=90
	CameraLag=0.0
	bDriverCastsShadow=true
	bDriverHoldsFlag=true

	MinCameraDistSq=144.0
	bStickDeflectionThrottle=true

	ExplosionSound=None

	PhysWeightBlendTime=1.0

	FallingDamageRagdollThreshold=10

	bAlwaysRelevant=false
	bDoExtraNetRelevancyTraces=false

	HoverCamOffset=(X=60,Y=-20,Z=-15)
	HoverCamRotOffset=(Pitch=728)
	VelLookAtOffset=(X=-0.07,Y=-0.07,Z=-0.03)
	VelBasedCamOffset=(Z=-0.02)
	VelRollFactor=0.4
	HoverCamMaxVelUsed=800
	ViewRollRate=100

	ImpactGroundResetPhysRiderThresh=400.0
	BigImpactPhysRiderZVel=-400.0

	AIPurpose=AIP_Any
	bPathfindsAsVehicle=false

	bEjectKilledBodies=true
}
