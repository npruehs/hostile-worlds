/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTConsolePlayerInput extends UTPlayerInput within UTConsolePlayerController
	config(Input);

/** Multiplier used to scale the sensitivity of the controls. */
var float SensitivityMultiplier;

/** Multiplier used to scale the sensitivity of the turning. */
var float TurningAccelerationMultiplier;

/** Whether to center the player's view when not in a vehicle **/
var config bool bAutoCenterPitch;

/** Whether to center the player's view when in a vehicle **/
var config bool bAutoCenterVehiclePitch;


/** Timer for auto-centering of vehicle turrets */
var float LastTurnTime;

/** Threshold since last turn/fire to auto-center vehicle turrets */
var	globalconfig float AutoCenterDelay;

/** Controls rate at which camera auto-aligns behind vehicle when not being moved */
var	globalconfig float AutoVehicleCenterSpeed;

/** Scaling used when "slow turning" enabled */
var globalconfig float SlowTurnScaling;


/** Whether ViewAcceleration is enabled or not **/
var() config bool bViewAccelerationEnabled;

var config protected bool bDebugViewAcceleration;

/** Threshold above when Yaw Acceleration kicks in*/
var() config float ViewAccel_YawThreshold;
var() config float ViewAccel_DiagonalThreshold;


/** How fast to start accelerating when the stick is slammed to the edge. It goes to a max of 2.0 over time **/
var() config float ViewAccel_BaseMultiplier;
var() private float ViewAccel_CurrMutliplier;

/** How to handle slamming the stick to the edges **/
/** how long you need to hold at edge before the fast acceleration kicks in **/
var() config float ViewAccel_TimeToHoldBeforeFastAcceleration;
var private float ViewAccel_TimeHeld;

/** Amount of twitchy we will handle before just taking the real value of the aTurn.  This basically make the controls feel a lot smoother and not just spastic looking all over the place. **/
var() config float ViewAccel_Twitchy;

/** If user hits A when the thumbstick is above this threshold, they will dodge in the direction of their thumbstick **/
var() config float Dodge_Threshold;


/** Whether TargetFriction is enabled or not **/
var() config bool bTargetFrictionEnabled;

var config protected bool bDebugTargetFriction;

/** Whether or not we actually applied friction.  This is used to make certain we don't then accelerate the view **/
var protected bool bAppliedTargetFriction;


/** Last friction target */
var private Pawn LastFrictionTarget;

/** Last friction target acquire time */
var private float LastFrictionTargetTime;


var private float LastDistToTarget, LastDistMultiplier, LastDistFromAimZ, LastDistFromAimY, LastFrictionMultiplier, LastAdhesionAmtY, LastAdhesionAmtZ;
var private float LastTargetRadius, LastTargetHeight, LastDistFromAimYa, LastDistFromAimZa, LastAdjustY, LastAdjustZ;
var private Vector LastCamLoc;
var private Rotator LastDeltaRot;


/** DeadZone threshold to not count "active" on left thumbstick **/
var config float LeftThumbStickDeadZoneThreshold;

/** DeadZone threshold to not count "active" on right thumbstick **/
var config float RightThumbStickDeadZoneThreshold;


/** magic scaling value for over all sensitivity **/
var config float MagicScaleForSensitivityMiddle;
var config float MagicScaleForSensitivityEdge;

/** How fast you ramp up to the max speed**/
var config float ViewAccel_RampSpeed;
/** Max turn speed **/
var config float ViewAccel_MaxTurnSpeed;


var config float ViewAccel_PitchThreshold;
/** How far to be considered to be looking up and down **/
var config float ViewAccel_LookingUpOrDownBoundary;

/** How far to be considered to be back to center **/
var config float ViewAccel_BackToCenterBoundary;

/** how fast to zip back to center **/
var config float ViewAccel_BackToCenterSpeed;


var config float AutoPitchCenterSpeed;

var config float AutoPitchStopAdjustingValue;

var private bool bIsLookingUp;
var private bool bIsLookingDown;

/**
 * HoverBoards don't have a real turret.  All of the code that exists for modifying the rotation speed is within that set of code
 * So we are going to just modify it here.
 * This is the multiplier we are going to use to make the hoverboard look up and down feel nice.
 **/
var config float HoverBoardPitchMultiplier;


simulated event PostBeginPlay()
{
	ViewAccel_CurrMutliplier = ViewAccel_BaseMultiplier;
}

/**
 * Overridden to add hooks for view acceleration, target friction, auto centering, controller sensitivity.
 */
function PreProcessInput( float DeltaTime )
{
	local UTWeapon UW;
	local bool bUsingTiltController;

	Super.PreProcessInput(DeltaTime);
	RawJoyLookRight	= aMouseX;
	RawJoyLookUp	= aMouseY;
	//`log( " RawJoyUp: " $ RawJoyUp $ " RawJoyRight: " $ RawJoyRight );

	if( Pawn == none )
	{
		return;
	}

	//`log( "bUsingGamepad: " $ bUsingGamepad );
	// whenever a player uses a non Gamepad for input the input for that frame is set to:  bUsingGamepad=false  so we do not even attempt
	// to do any input help
	if (!bUsingGamepad)
	{
		// if we are playing in a Game that only allows Gamepads and we have received input from a non gamepad
		// we blank all inputs
		if (UTGameReplicationInfo(WorldInfo.GRI) != None && !UTGameReplicationInfo(WorldInfo.GRI).bAllowKeyboardAndMouse)
		{
			RawJoyLookRight = 0.0f;
			RawJoyLookUp = 0.0f;

			aBaseX = 0.0f;
			aBaseY = 0.0f;
			aBaseZ = 0.0f;
			aMouseX = 0.0f;
			aMouseY = 0.0f;
			aForward = 0.0f;
			aTurn = 0.0f;
			aStrafe = 0.0f;
			aUp = 0.0f;
			aLookUp = 0.0f;
		}

		// mouse seems to be slower on PS3 for some reason so give it a boost
		aTurn *= 1.5;
		aLookUp *= 1.5;
		aMouseX *= 1.5;
		aMouseY *= 1.5;

		// let mobile platforms do the return to center, etc, code below
		if (!WorldInfo.IsConsoleBuild(CONSOLE_Mobile))
		{
			return;
		}
	}

	bUsingTiltController = FALSE;

	if( Pawn == none )
	{
		return;
	}

 	bUsingTiltController = UTConsolePlayerController(Pawn.Controller).IsControllerTiltActive();

	UW = UTWeapon(Pawn.Weapon);

	// Accelerate turning rate if we did not apply friction
	// we have a "slowdown" acceleration so we need to do that first
	if( bViewAccelerationEnabled && !bUsingTiltController )
	{
		ApplyViewAcceleration( DeltaTime );
	}

	if( bTargetFrictionEnabled )
	{
		if( UW != none )
		{
			bAppliedTargetFriction = FALSE; // clear the friction flag (we do it here so applyViewAcceleration has a chance to use it from the time before)
			ApplyTargetFriction( DeltaTime, UW );
		}
	}

	// these needs to happen after aForward has been updated.
	// might be out of place here
	if( !bAppliedTargetFriction
		&& (( UW != none ) && ( UW.GetZoomedState() != ZST_Zoomed )) )
	{
		if( bAutoCenterPitch )
		{
			ApplyViewAutoPitchCentering( DeltaTime );
		}

		if( bAutoCenterVehiclePitch )
		{
			ApplyViewAutoVehiclePitchCentering( DeltaTime );
		}
	}

	// See if we should apply the zoomed turn speed scale pct
	if( ( UW != none ) && ( UW.GetZoomedState() == ZST_Zoomed ) )
	{
		aTurn *= UW.ZoomedTurnSpeedScalePct;
		aLookUp *= UW.ZoomedTurnSpeedScalePct;
	}

	aTurn *= TurningAccelerationMultiplier;

	// This will apply the sensitivity scaling to the controller inputs
	// NOTE:  once we have this we may not want to apply if we bAppliedTargetFriction
	aTurn *= SensitivityMultiplier;
	aLookUp *= SensitivityMultiplier;

	// HoverBoards don't have a real turret.  All of the code that exists for modifying the rotation speed is within that set of code
	// So we are going to just modify it here.
	if( UTVehicle_Hoverboard(Pawn) != None )
	{
		aLookUp *= HoverBoardPitchMultiplier;
	}

	//`log( "aTurn: " $ aTurn $ " aLookUp: " $ aLookUp $ " DeltaTime: " $ DeltaTime );
}


/**
 * This will auto center the player's view when they are moving along and not firing
 **/
function ApplyViewAutoPitchCentering( float DeltaTime )
{
	local float AmountToAdjustPitch;
	local float CurrentPitch;

	// so if we are not doing any looking or firing
	if( /*(aTurn != 0) ||*/ ( abs(RawJoyLookUp) > 0 ) || /*( abs(RawJoyLookRight) > 0 ) ||*/ Pawn.IsFiring() || (Pawn.Physics == PHYS_Falling) )
	{
//		`log( "skipping auto-center" $ RawJoyLookUp @ RawJoyLookRight);
		// don't auto-align camera if player is currently moving it
		LastTurnTime = WorldInfo.TimeSeconds;
		return;
	}

	if( ( (WorldInfo.TimeSeconds - LastTurnTime) > AutoCenterDelay ) && ( VSize(Pawn.Velocity) > 10.0f ) )
	{
		CurrentPitch = float(NormalizeRotAxis(Rotation.Pitch));
		AmountToAdjustPitch = FInterpTo( CurrentPitch, 0, DeltaTime, AutoPitchCenterSpeed ) - CurrentPitch;
		//`log( "CurrentPitch: " $ CurrentPitch $ " Abs(RawJoyLookUp): " $ Abs(RawJoyLookUp) );

		if( abs(AmountToAdjustPitch) > AutoPitchStopAdjustingValue )
		{
			if( AmountToAdjustPitch < AutoPitchStopAdjustingValue )
			{
				if( bInvertMouse == FALSE )
				{
					aLookup += FMin( -1*AmountToAdjustPitch, AutoPitchCenterSpeed );
				}
				else
				{
					aLookup -= FMin( -1*AmountToAdjustPitch, AutoPitchCenterSpeed );
				}
				//`log( "aLookup: " $ aLookup $ " AmountToAdjustPitch: " $ AmountToAdjustPitch );
			}
			else if( AmountToAdjustPitch > AutoPitchStopAdjustingValue )
			{
				if( bInvertMouse == FALSE )
				{
					aLookup -= FMin( AmountToAdjustPitch, AutoPitchCenterSpeed );
				}
				else
				{
					aLookup += FMin( AmountToAdjustPitch, AutoPitchCenterSpeed );
				}
				//`log( "aLookup: " $ aLookup $ " AmountToAdjustPitch: " $ AmountToAdjustPitch );
			}
		}
	}
}

/**
 * This will auto center the player's view when they in a vehicle.
 **/
function ApplyViewAutoVehiclePitchCentering( float DeltaTime )
{
	local int VehicleYaw, CameraYaw;
	local float OldaBaseY, ForwardMag;

	local float AmountToAdjustPitch;
	local float CurrentPitch;

	if ( (UTVehicle(Pawn) != None) && !UTVehicle(Pawn).bFollowLookDir && UTVehicle(Pawn).bShouldAutoCenterViewPitch )
	{
		if ( (aTurn != 0) || Pawn.IsFiring() )
		{
			// don't auto-align camera if player is currently moving it
			LastTurnTime = WorldInfo.TimeSeconds;
		}
		else if ( WorldInfo.TimeSeconds - LastTurnTime > AutoCenterDelay )
		{
			ForwardMag = aForward*aForward+aBaseY*aBaseY;

			if ( UTVehicle(Pawn).bStickDeflectionThrottle && !UTVehicle(Pawn).bUsingLookSteer )
			{
				ForwardMag += aStrafe*aStrafe;
				if ( ForwardMag != 0 )
				{
					// auto-align cameras on vehicles
					VehicleYaw = Pawn.Rotation.Yaw & 65535;
					CameraYaw = Rotation.Yaw & 65535;
					if ( CameraYaw ClockwiseFrom VehicleYaw )
					{
						if ( CameraYaw < VehicleYaw )
							CameraYaw += 65536;
						if ( CameraYaw - VehicleYaw > 2048 )
							aTurn = -0.125 - 0.5*(CameraYaw - VehicleYaw)/AutoVehicleCenterSpeed;
					}
					else
					{
						if ( VehicleYaw < CameraYaw )
							VehicleYaw += 65536;
						if ( VehicleYaw - CameraYaw > 2048 )
							aTurn = +0.125 + 0.5*(VehicleYaw - CameraYaw)/AutoVehicleCenterSpeed;
					}
				}
			}
		}

		if ( aStrafe != 0 )
		{
			// aBaseY should be magnitude of deflection, not just in up/down direction
			OldaBaseY = aBaseY;
			aBaseY = FMin(Sqrt(Square(aStrafe) + Square(aBaseY)), 1.f);

			if ( OldaBaseY < 0 )
			{
				aBaseY *= -1;
			}
			RawJoyUp = aBaseY;
		}
	}

	if( ( UTVehicle(Pawn) != None) && ( VSize(Pawn.Velocity) != 0 ) && UTVehicle(Pawn).bShouldAutoCenterViewPitch )
	{
		// so if we are not doing any looking or firing
		if( ( abs(RawJoyLookUp) > 0.2f ) || Pawn.IsFiring() || (Pawn.Physics == PHYS_Falling) )
		{
			// don't auto-align camera if player is currently moving it
			LastTurnTime = WorldInfo.TimeSeconds;
			return;
		}

		if( ( (WorldInfo.TimeSeconds - LastTurnTime) > AutoCenterDelay ) && ( VSize(Pawn.Velocity) > 10.0f ) )
		{
			CurrentPitch = float(NormalizeRotAxis(Rotation.Pitch));
			AmountToAdjustPitch = FInterpTo( CurrentPitch, 0, DeltaTime, AutoPitchCenterSpeed ) - CurrentPitch;
			//`log( "CurrentPitch: " $ CurrentPitch $ " Abs(RawJoyLookUp): " $ Abs(RawJoyLookUp) );

			if( abs(AmountToAdjustPitch) > AutoPitchStopAdjustingValue )
			{
				if( AmountToAdjustPitch < AutoPitchStopAdjustingValue )
				{
					if( bInvertMouse == FALSE )
					{
						aLookup += FMin( -1*AmountToAdjustPitch, AutoPitchCenterSpeed );
					}
					else
					{
						aLookup -= FMin( -1*AmountToAdjustPitch, AutoPitchCenterSpeed );
					}
					//`log( "aLookup: " $ aLookup $ " AmountToAdjustPitch: " $ AmountToAdjustPitch );
				}
				else if( AmountToAdjustPitch > AutoPitchStopAdjustingValue )
				{
					if( bInvertMouse == FALSE )
					{
						aLookup -= FMin( AmountToAdjustPitch, AutoPitchCenterSpeed );
					}
					else
					{
						aLookup += FMin( AmountToAdjustPitch, AutoPitchCenterSpeed );
					}
					//`log( "aLookup: " $ aLookup $ " AmountToAdjustPitch: " $ AmountToAdjustPitch );
				}
			}
		}
	}
}


/**
 * This will scale the player's rotation speed depending on the location of their thumbstick and how
 * long they have held it there.
 **/
function ApplyViewAcceleration( float DeltaTime )
{
	local float CurrentPitch;
	local UTWeapon UW;

	UW = UTWeapon(Pawn.Weapon);
	CurrentPitch = NormalizeRotAxis(Rotation.Pitch);

	//`log( "ahh: " $ square(Abs(RawJoyLookRight)) + square(Abs(RawJoyLookUp/0.75)) $ " RawJoyLookRight: " $ RawJoyLookRight $ " RawJoyLookUp: " $ RawJoyLookUp );

	if( CurrentPitch < -1*ViewAccel_LookingUpOrDownBoundary )
	{
		//`log( "looking down: " $ CurrentPitch $ " aLookUp: " $ aLookUp );
		bIsLookingDown = TRUE;
	}
	else if( CurrentPitch > ViewAccel_LookingUpOrDownBoundary )
	{
		//`log( "looking up: " $ CurrentPitch $ " aLookUp: " $ aLookUp );
		bIsLookingUp = TRUE;
	}

	// need to check for sniper here
	// check to see if we are trying to get back to center from looking up or down
	if( ( ( bIsLookingDown == TRUE ) && ( RawJoyLookUp < -1*ViewAccel_PitchThreshold ) )
		|| ( ( bIsLookingUp == TRUE ) && ( RawJoyLookUp > ViewAccel_PitchThreshold ) )
		)
	{
		//aLookUp = ( aLookUp < 0 ) ? (aLookUp*ViewAccel_BackToCenterSpeed) : (aLookUp*ViewAccel_BackToCenterSpeed);
		aLookUp *= ViewAccel_BackToCenterSpeed;
	}
	// non-linear scale for turn magnitude
	// If above threshold, accelerate Yaw turning rate (e.g. when you slam the thumbstick to the farthest position)
	else if( ( Abs(aTurn) > ViewAccel_YawThreshold ) ||  ( ( square(Abs(RawJoyLookRight) + square(Abs(RawJoyLookUp/0.75))) ) > ViewAccel_DiagonalThreshold )
		)
	{
		 // if we are not targeting someone.  (i.e. in the heat of battle of circle straffing you want to be JAMMED to the edge as you are spazzing out.  but are targeting and fighting so you don't want to flip around all speedy )
		if( ( ViewAccel_TimeHeld > ViewAccel_TimeToHoldBeforeFastAcceleration )
			&& ( !bAppliedTargetFriction )
			&& ( ( !Pawn.IsFiring() ) || ( ( UW != None ) && ( UW.CanViewAccelerationWhenFiring() ) ) ) // if we are shooting then don't do super speed up (e.g. we are prob circle straffing))
			)
		{
			ViewAccel_CurrMutliplier += ( ViewAccel_RampSpeed ) ;
			aTurn *= FMin( FMax(ViewAccel_CurrMutliplier, ViewAccel_BaseMultiplier), ViewAccel_MaxTurnSpeed );  // we need to always be at least a 1.0f here or we will go slower and hitch
		}
		else
		{
			aTurn = ( aTurn < 0 ) ? -1*Square(aTurn) : Square(aTurn);
			aTurn /= MagicScaleForSensitivityEdge;
			ViewAccel_CurrMutliplier = aTurn;
			ViewAccel_TimeHeld += DeltaTime;
		}
	}
	// we are doing a non slam to the edge movement
	else
	{

		aTurn = ( aTurn < 0 ) ? -1*Square(aTurn) : Square(aTurn);
		aTurn /= MagicScaleForSensitivityMiddle;

		// reset
		ViewAccel_CurrMutliplier = ViewAccel_BaseMultiplier;
		ViewAccel_TimeHeld = 0;
	}

	// check to write out these vars if they were true before and if we are in the middle section of being "centered"
	if( ( bIsLookingDown || bIsLookingUp )
		&& ( CurrentPitch < ViewAccel_BackToCenterBoundary )
		&& ( CurrentPitch > -1*ViewAccel_BackToCenterBoundary )
		)
	{
		//`log( "resetting look up down" );
		bIsLookingDown = FALSE;
		bIsLookingUp = FALSE;
	}

}

/**
 * This will attempt to keep the player aiming at the target.  It will forcibly aim the player at the target.
 *
 * TODO:  move this to c++
 **/
function ApplyTargetAdhesion( float DeltaTime, UTWeapon W, out int out_YawRot, out int out_PitchRot )
{
	local Vector	RealTargetLoc, TargetLoc, CamToTarget, AimLoc, CamLoc, ClosestY, ClosestZ;
	local Vector	X, Y, Z;
	local Rotator	CamRot, DeltaRot;
	local float		DistToTarget, DistFromAimZ, DistFromAimY, AdhesionAmtY, AdhesionAmtZ, TargetRadius, TargetHeight, Pct;
	local int		AdjustY, AdjustZ;
	local Pawn	AdhesionTarget;

	if( W == None
		|| !W.bTargetAdhesionEnabled
		)
	{
		return;
	}

	// Setup some initial data
	CamLoc = CalcViewLocation;
	CamRot = CalcViewRotation;
	// using this at this point here causes mega hitches to occur.  As the correct values have not been updated yet this early
	//GetPlayerViewPoint( CamLoc, CamRot );
	GetAxes( CamRot, X, Y, Z );

	// attempt to use the friction target if available
	AdhesionTarget = LastFrictionTarget;
	if (AdhesionTarget == None || `TimeSince(LastFrictionTargetTime) > W.TargetAdhesionTimeMax)
	{
		// otherwise look for a new target
		AdhesionTarget = GetTargetAdhesionFrictionTarget( W.TargetAdhesionDistanceMax, CamLoc, CamRot );
	}

	// If still within adhesion time constraints, and the target is still alive
	if( AdhesionTarget != None )
	{
		// Grab collision info from target
		AdhesionTarget.GetBoundingCylinder( TargetRadius, TargetHeight );
		// reduce the size a bit to allow adhesion to move the crosshair onto the character
		TargetRadius *= 0.65f;
		TargetHeight *= 0.65f;
		RealTargetLoc = AdhesionTarget.Location + (W.TargetFrictionOffset >> CamRot);

		// Make sure the target has some velocity
		if( (W.TargetAdhesionTargetVelocityMin == 0.f || VSize(AdhesionTarget.Velocity) > W.TargetAdhesionTargetVelocityMin)
			&& (W.TargetAdhesionPlayerVelocityMin == 0.f || VSize(Pawn.Velocity) > W.TargetAdhesionPlayerVelocityMin)
			&& ((RealTargetLoc - CamLoc) DOT Vector(CamRot) > 0.f) )
		{
			// Figure out the distance from aim to target
			CamToTarget = (RealTargetLoc - CamLoc);
			DistToTarget = VSize(CamToTarget);
			AimLoc = CamLoc + (X * DistToTarget);

			// Calculate the aim friction multiplier
			// Y component
			TargetLoc	 = RealTargetLoc;
			TargetLoc.Z  = AimLoc.Z;
			DistFromAimY = PointDistToLine(AimLoc,(TargetLoc - CamLoc),CamLoc, ClosestY );
			ClosestY = TargetLoc + Normal(ClosestY - TargetLoc) * TargetRadius;

			// Z component
			TargetLoc	 = RealTargetLoc;
			TargetLoc.X  = AimLoc.X;
			TargetLoc.Y  = AimLoc.Y;
			DistFromAimZ = PointDistToLine(AimLoc,(TargetLoc - CamLoc),CamLoc, ClosestZ);
			ClosestZ	 = TargetLoc + Normal(ClosestZ - TargetLoc) * TargetRadius;

			DeltaRot.Yaw	= Rotator(ClosestY - CamLoc).Yaw	- CamRot.Yaw;
			DeltaRot.Pitch	= Rotator(ClosestZ - CamLoc).Pitch	- CamRot.Pitch;
			DeltaRot = Normalize( DeltaRot );

			// Make sure it is still within valid distance AND
			// outside the cylinder in at least one direction AND
			// target can be seen
			if( ( DistToTarget <= W.TargetAdhesionDistanceMax )
				&& (DistFromAimY > TargetRadius || DistFromAimZ > TargetHeight)
				&& LineOfSightTo( AdhesionTarget, CamLoc ) // find a way no do this line check
				)
			{
				// Lateral adhesion
				if(	DistFromAimY > TargetRadius )
				{
					Pct = 1.f - (DistFromAimY-TargetRadius)/W.TargetAdhesionAimDistY;
					if (Pct > 0.f)
					{
						// boost based on other gameplay things (distance or something)
						// boost slightly when targeting
						Pct = FMin(Pct, 0.8f);

						AdhesionAmtY = GetRangeValueByPct(W.TargetAdhesionScaleRange, Pct);

						// Apply the adhesion
						AdjustY = DeltaRot.Yaw * (AdhesionAmtY * DeltaTime);
						out_YawRot += AdjustY;
					}
				}

				// Vertical adhesion
				if( DistFromAimZ > TargetHeight )
				{
					Pct = 1.f - (DistFromAimZ-TargetHeight)/W.TargetAdhesionAimDistZ;
					if (Pct > 0.f)
					{
						// boost based on other gameplay things (distance or something)
						// boost slightly when targeting
						Pct = FMin(Pct, 0.8f);

						AdhesionAmtZ = GetRangeValueByPct(W.TargetAdhesionScaleRange, Pct);

						//`log( "AdhesionAmtZ: " $ AdhesionAmtZ );

						// Apply the adhesion
						AdjustZ = DeltaRot.Pitch * (AdhesionAmtZ * DeltaTime);
						out_PitchRot += AdjustZ;
					}
				}
			}
		}
	}

`if(`notdefined(FINAL_RELEASE))
	//debug
	LastAdhesionAmtY = AdhesionAmtY;
	LastAdhesionAmtZ = AdhesionAmtZ;
	LastDistFromAimZa = DistFromAimZ;
	LastDistFromAimYa = DistFromAimY;
	LastDeltaRot = DeltaRot;
	LastAdjustY = AdjustY;
	LastAdjustZ = AdjustZ;
`endif
}


function AdjustMouseSensitivity(float FOVScale)
{
	// Apply mouse sensitivity.
	// @TODO FIXME HACK - shouldn't need to do this at all
	aMouseX			*= 60 * FOVScale;
	aMouseY			*= 60 * FOVScale;
}

/**
 * This will slow down the player's aiming when they are on "top" of a valid Target.  So when you whip around
 * there will be a slight slow down when you are directly aiming at a target.
 *
 * TODO:  move this to c++
 **/
function ApplyTargetFriction( float DeltaTime, UTWeapon W )
{
	local Pawn FrictionTarget;
	local Vector CamLoc, X, Y, Z, CamToTarget, AimLoc, TargetLoc, RealTargetLoc;
 	local Rotator CamRot;
 	local float DistToTarget, DistMultiplier, DistFromAimZ, DistFromAimY;
 	local float TargetRadius, TargetHeight;
 	local float FrictionMultiplier;

	//	local float Time;
	//	CLOCK_CYCLES(time);

	if( Pawn == None || !W.bTargetFrictionEnabled )
	{
		//`log( "ApplyTargetFriction returning: W.bTargetFrictionEnabled: " $ W.bTargetFrictionEnabled $ " Pawn: " $ Pawn $ " W: " $ W );
		return;
	}

	// Setup some initial data
	CamLoc = CalcViewLocation;
	CamRot = CalcViewRotation;
	// using this at this point here causes mega hitches to occur.  As the correct values have not been updated yet this early
	//GetPlayerViewPoint( CamLoc, CamRot );
	GetAxes( CamRot, X, Y, Z );

	// Look for a friction target
	FrictionTarget = GetTargetAdhesionFrictionTarget( W.TargetFrictionDistanceMax, CamLoc, CamRot );

	// If we have a valid friction target
	if( FrictionTarget != None )
	{
		//`log( "Friction Target: " $ FrictionTarget );
		RealTargetLoc = FrictionTarget.Location + ( W.TargetFrictionOffset >> CamRot );
		CamToTarget = ( RealTargetLoc - CamLoc );
		DistToTarget = VSize(CamToTarget);
		AimLoc = CamLoc + ( X * DistToTarget );

		// Grab collision info from target
		FrictionTarget.GetBoundingCylinder( TargetRadius, TargetHeight );
		if( bDebugTargetFriction )
		{
			DrawDebugCylinder(FrictionTarget.Location+vect(0,0,1)*TargetHeight, FrictionTarget.Location-vect(0,0,1)*TargetHeight, TargetRadius, 12, 255, 0, 0);
		}

		// Calculate the aim friction multiplier
		// Y component
		TargetLoc	 = RealTargetLoc;
		TargetLoc.Z  = AimLoc.Z;
		DistFromAimY = PointDistToLine(AimLoc,(TargetLoc - CamLoc),CamLoc);

		// Z component
		TargetLoc	 = RealTargetLoc;
		TargetLoc.X  = AimLoc.X;
		TargetLoc.Y  = AimLoc.Y;
		DistFromAimZ = PointDistToLine(AimLoc,(TargetLoc - CamLoc),CamLoc);

		// Calculate the distance multiplier
		DistMultiplier = 0.f;
		//`log( " TargetFrictionDistanceMin: " $ W.TargetFrictionDistanceMin  $ " TargetFrictionDistanceMax: " $ W.TargetFrictionDistanceMax $ " DistToTarget: " $ DistToTarget );

		if( DistToTarget >= W.TargetFrictionDistanceMin
			&& DistToTarget <= W.TargetFrictionDistanceMax
			)
		{
			if( DistToTarget <= W.TargetFrictionDistancePeak )
			{
				// Ramp up to peak
				DistMultiplier = FClamp((DistToTarget - W.TargetFrictionDistanceMin)/(W.TargetFrictionDistancePeak - W.TargetFrictionDistanceMin),0.f,1.f);
			}
			else
			{
				// Ramp down from peak
				DistMultiplier = FClamp(1.f - (DistToTarget - W.TargetFrictionDistancePeak)/(W.TargetFrictionDistanceMax - W.TargetFrictionDistancePeak),0.f,1.f);
			}

			//`log( "DistMultiplier: " $ DistMultiplier );

			// Scale target radius by distance
			TargetRadius *= 1.f + (W.TargetFrictionPeakRadiusScale * DistMultiplier);
			TargetHeight *= 1.f + (W.TargetFrictionPeakHeightScale * DistMultiplier);
		}

		// this is used to reduce the target radius so that moving pawns have a smaller radius so that when we are tracking
		// them the reticle doesn't stop outside of their body mass making it either impossible to hit them or making it look bad when
		// shots do actually hit them
		if( ( VSize(FrictionTarget.Velocity) > 200 )
			&& ( W.GetZoomedState() == ZST_Zoomed )
			)
		{
			TargetRadius *= 0.05f;
		}

		// If we should apply friction - must be within friction collision box
		if( DistFromAimY < TargetRadius
			&& DistFromAimZ < TargetHeight
			)
		{
			// Calculate the final multiplier (only based on horizontal turn)
			FrictionMultiplier = GetRangeValueByPct( W.TargetFrictionMultiplierRange, 1.f - (DistFromAimY/TargetRadius) );

			if( FrictionMultiplier > 0.0f )
			{
				bAppliedTargetFriction = TRUE;

				// Apply the friction
				aTurn *= (1.f - FrictionMultiplier);
				aLookUp *= (1.f - FrictionMultiplier);

				// Keep the friction target for possible use with adhesion
				LastFrictionTargetTime	= WorldInfo.TimeSeconds;
				LastFrictionTarget		= FrictionTarget;
			}
		}
	}

`if(`notdefined(FINAL_RELEASE))
	// debug
	LastDistToTarget = DistToTarget;
	LastDistMultiplier = DistMultiplier;
	LastDistFromAimZ = DistFromAimZ;
	LastDistFromAimY = DistFromAimY;
	LastFrictionMultiplier = FrictionMultiplier;
	LastTargetRadius = TargetRadius;
	LastTargetHeight = TargetHeight;
	LastCamLoc = CamLoc;
`endif
}

/** Toggle debug display for view acceleration **/
exec function DebugViewAcceleration()
{
	if ( WorldInfo.NetMode == NM_StandAlone )
	{
		bDebugViewAcceleration = !bDebugViewAcceleration;
		ClientMessage( "bDebugViewAcceleration is now: " $ bDebugViewAcceleration );
	}
}

/** Toggle debug display for target adhesion **/
exec function DebugTargetAdhesion()
{
	if ( WorldInfo.NetMode == NM_StandAlone )
	{
		bDebugTargetAdhesion = !bDebugTargetAdhesion;
		ClientMessage( "bDebugTargetAdhesion is now: " $ bDebugTargetAdhesion );
	}
}

/** Toggle debug display for target friction **/
exec function DebugTargetFriction()
{
	if ( WorldInfo.NetMode == NM_StandAlone )
	{
		bDebugTargetFriction = !bDebugTargetFriction;
		ClientMessage( "bDebugTargetFriction is now: " $ bDebugTargetFriction );
	}
}

exec function SmartJump()
{
	local UTPawn P;

	// jump cancels feign death
	P = UTPawn(Pawn);
	if (P != None && P.bFeigningDeath)
	{
		P.FeignDeath();
	}
	else
	{
		// determine is dodging or jumping backwards or just doing a normal jump
		if( RawJoyRight < -Dodge_Threshold )
		{
			ForcedDoubleClick = DCLICK_Left;
		}
		else if( RawJoyRight > Dodge_Threshold )
		{
			ForcedDoubleClick = DCLICK_Right;
		}
  		else
  		{
			super.jump();
  		}
	}
}

exec function Jump()
{
	SmartJump();
}

// check for double click move
function Actor.EDoubleClickDir CheckForDoubleClickMove(float DeltaTime)
{
	if (DoubleClickDir != DCLICK_None)
	{
		ForcedDoubleClick = DCLICK_None;
		return Super.CheckForDoubleClickMove(DeltaTime);
	}
	else
	{
		DoubleClickDir = ForcedDoubleClick;
		ForcedDoubleClick = DCLICK_None;
		return DoubleClickDir;
	}
}


defaultproperties
{
	SensitivityMultiplier=1.0f
	TurningAccelerationMultiplier=1.0f
	bUsingGamepad=TRUE
}

