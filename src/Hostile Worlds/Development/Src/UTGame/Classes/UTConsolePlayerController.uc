/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTConsolePlayerController extends UTPlayerController
	config(Game);

/** Whether TargetAdhesion is enabled or not **/
var() config bool bTargetAdhesionEnabled;

var config protected bool bDebugTargetAdhesion;

// @todo amitt update this to work with version 2 of the controller UI mapping system
struct native ProfileSettingToUE3BindingDatum
{
	var name ProfileSettingName;
	var name UE3BindingName;

};

var array<ProfileSettingToUE3BindingDatum> ProfileSettingToUE3BindingMapping360;
var array<ProfileSettingToUE3BindingDatum> ProfileSettingToUE3BindingMappingPS3;

/**
 * We need to override this function so we can do our adhesion code.
 *
 * Would be nice to have have a function or something be able to be inserted between the set up
 * and processing.
 **/
function UpdateRotation( float DeltaTime )
{
	local Rotator	DeltaRot, NewRotation, ViewRotation;

	ViewRotation	= Rotation;
	if (Pawn!=none)
	{
		Pawn.SetDesiredRotation(ViewRotation); //save old rotation
	}

	// Calculate Delta to be applied on ViewRotation
	DeltaRot.Yaw	= PlayerInput.aTurn;
	DeltaRot.Pitch	= PlayerInput.aLookUp;


	// NOTE:  we probably only want to ApplyTargetAdhesion when we are moving as it hides the Adhesion a lot better
	if( ( bTargetAdhesionEnabled )
		&& ( Pawn != none )
		&& ( PlayerInput.aForward != 0 )
		)
	{
		UTConsolePlayerInput(PlayerInput).ApplyTargetAdhesion( DeltaTime, UTWeapon(Pawn.Weapon), DeltaRot.Yaw, DeltaRot.Pitch );
	}


	ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );

	SetRotation( ViewRotation );

	ViewShake( DeltaTime );

	NewRotation = ViewRotation;
	NewRotation.Roll = Rotation.Roll;

	if( Pawn != None )
	{
		Pawn.FaceRotation(NewRotation, DeltaTime);
	}
}

function bool AimingHelp(bool bInstantHit)
{
	// bUsingGamepad is updated every time we do an input based on what was used to make that input
	//return PlayerInput.bUsingGamepad;
	// @fixme this needs to eventually use the above line and also have some client to server communication where
	// the client tells the server if they have ever used a keyboard/mouse.  The idea being:  once they have "cheated" then
	// they never will get aiming help again.  Doing it this way reduces the amount of server messages we need to have
	return true;
}

/**
* @returns the distance from the collision box of the target to accept aiming help (for instant hit shots)
*/
function float AimHelpModifier()
{
	return (FOVAngle < DefaultFOV - 8) ? 0.75 : 1.0;
}

simulated function bool PerformedUseAction()
{
	if ( Super.PerformedUseAction() )
	{
		return true;
	}
	else if ( (Role == ROLE_Authority) && !bJustFoundVehicle )
	{
		// console smart use - bring out hoverboard if no other use possible
		ClientSmartUse();
		return true;
	}
	return false;
}

unreliable client function ClientSmartUse()
{
	ToggleTranslocator();
}

reliable client function ClientRestart(Pawn NewPawn)
{
	Super.ClientRestart(NewPawn);

	// we never want the tilt thing on when using UTPawns

	if (UTPawn(NewPawn) != None)
	{
		SetOnlyUseControllerTiltInput(false);
		SetUseTiltForwardAndBack(true);
		SetControllerTiltActive(false);
	}
}

exec function PrevWeapon()
{
	if (Pawn == None || Vehicle(Pawn) != None)
	{
		if ( UDKVehicleBase(Pawn) != None )
		{
			UDKVehicleBase(Pawn).AdjacentSeat(-1, self);
		}
	}
	else if (!Pawn.IsInState('FeigningDeath'))
	{
		Super.PrevWeapon();
	}
}

exec function NextWeapon()
{
	if (Pawn == None || Vehicle(Pawn) != None)
	{
		if ( UDKVehicleBase(Pawn) != None )
		{
			UDKVehicleBase(Pawn).AdjacentSeat(1, self);
		}
	}
	else if (!Pawn.IsInState('FeigningDeath'))
	{
		Super.NextWeapon();
	}
}

function ResetPlayerMovementInput()
{
	local UTConsolePlayerInput ConsoleInput;

	Super.ResetPlayerMovementInput();

	ConsoleInput = UTConsolePlayerInput(PlayerInput);
	if (ConsoleInput != None)
	{
		ConsoleInput.ForcedDoubleClick = DCLICK_None;
	}
}

/** Gathers player settings from the client's profile. */
function LoadSettingsFromProfile(bool bLoadCharacter)
{
	local int OutIntValue;
	local UTProfileSettings Profile;
	local UTConsolePlayerInput ConsolePlayerInput;
	local int BindingIdx;

	// If we are NOT epic internal, then do not set any settings.
	if( !bShouldLoadSettingsFromProfile )
	{
		`Log("UTConsolePlayerController::LoadSettingsFromProfile() - Not an Epic internal build, skipping setting profile settings.");
		return;
	}

	Profile = UTProfileSettings(OnlinePlayerData.ProfileProvider.Profile);
	ConsolePlayerInput = UTConsolePlayerInput(PlayerInput);

	// AutoCenterPitch
	if(Profile.GetProfileSettingValueIdByName('AutoCenterPitch', OutIntValue))
	{
		ConsolePlayerInput.bAutoCenterPitch = (OutIntValue == UTPID_VALUE_YES);
	}

	// AutoCenterVehiclePitch
	if(Profile.GetProfileSettingValueIdByName('AutoCenterVehiclePitch', OutIntValue))
	{
		ConsolePlayerInput.bAutoCenterVehiclePitch = (OutIntValue == UTPID_VALUE_YES);
	}

	// TiltSensing
	if(Profile.GetProfileSettingValueIdByName('TiltSensing', OutIntValue))
	{
		SetControllerTiltDesiredIfAvailable(OutIntValue == UTPID_VALUE_YES);
	}


	// ControllerSensitivityMultiplier
	if(Profile.GetProfileSettingValueIntByName('ControllerSensitivityMultiplier', OutIntValue))
	{
		ConsolePlayerInput.SensitivityMultiplier = float(OutIntValue) / 10.0f;
	}

	// TurningAccelerationFactor
	if(Profile.GetProfileSettingValueIntByName('TurningAccelerationFactor', OutIntValue))
	{
		// 1 is .25  ....
		// 2 is .5  ????
		// 4 is our default value for speed so we want it to be a 1.0 multiplier
		// 8 is 2.0
		// 10 is 2.5!!!
		//`log( "OutIntValue: " $ OutIntValue );
		ConsolePlayerInput.TurningAccelerationMultiplier = float(OutIntValue) / 5.333f;    // .75
		//`log( "ConsolePlayerInput.TurningAccelerationMultiplier: " $ ConsolePlayerInput.TurningAccelerationMultiplier );
	}

	if ( class'UIRoot'.static.IsConsole(CONSOLE_PS3) )
	{
		// @todo amitt update this to work with version 2 of the controller UI mapping system
		for( BindingIdx = ProfileSettingToUE3BindingMappingPS3.length-1; BindingIdx >= 0; BindingIdx-- )
		{
			//`log( "RetrieveSettingsFromProfile: " $ ProfileSettingToUE3BindingMappingPS3[BindingIdx].ProfileSettingName );

			if( Profile.GetProfileSettingValueIdByName( ProfileSettingToUE3BindingMappingPS3[BindingIdx].ProfileSettingName, OutIntValue) )
			{
				//`log( "  RetrieveSettingsFromProfile: FOUND: " $ ProfileSettingToUE3BindingMappingPS3[BindingIdx].ProfileSettingName );
				UpdateControllerSettings_Worker( ProfileSettingToUE3BindingMappingPS3[BindingIdx].UE3BindingName, class'UTProfileSettings'.default.DigitalButtonActionsToCommandMapping[OutIntValue] );
			}
		}
	}
	// default to 360
	else
	{
		// @todo amitt update this to work with version 2 of the controller UI mapping system
		for( BindingIdx = ProfileSettingToUE3BindingMapping360.length-1; BindingIdx >= 0; BindingIdx-- )
		{
			//`log( "RetrieveSettingsFromProfile: " $ ProfileSettingToUE3BindingMapping360[BindingIdx].ProfileSettingName );

			if( Profile.GetProfileSettingValueIdByName( ProfileSettingToUE3BindingMapping360[BindingIdx].ProfileSettingName, OutIntValue) )
			{
				//`log( "  RetrieveSettingsFromProfile: FOUND: " $ ProfileSettingToUE3BindingMapping360[BindingIdx].ProfileSettingName );
				UpdateControllerSettings_Worker( ProfileSettingToUE3BindingMapping360[BindingIdx].UE3BindingName, class'UTProfileSettings'.default.DigitalButtonActionsToCommandMapping[OutIntValue] );
			}
		}
	}



	// Handle stick mappings.
	if(Profile.GetProfileSettingValueId(class'UTProfileSettings'.const.UTPID_GamepadBinding_AnalogStickPreset, OutIntValue))
	{
		`Log("Setting Stick configuration: "$EAnalogStickActions(OutIntValue));

		switch(EAnalogStickActions(OutIntValue))
		{
		case ESA_Legacy:

			UpdateControllerSettings_Worker( 'GBA_TurnLeft_Gamepad', "Axis aTurn Speed=1.0 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_MoveForward_Gamepad', "Axis aBaseY Speed=1.0 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_StrafeLeft_Gamepad', "Axis aStrafe Speed=1.0 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_Look_Gamepad', "Axis aLookup Speed=0.65 DeadZone=0.2" );

			UpdateControllerSettings_Worker( 'XboxTypeS_LeftX', "GBA_TurnLeft_Gamepad" );
			UpdateControllerSettings_Worker( 'XboxTypeS_LeftY', "GBA_MoveForward_Gamepad" );
			UpdateControllerSettings_Worker( 'XboxTypeS_RightX', "GBA_StrafeLeft_Gamepad" );
			UpdateControllerSettings_Worker( 'XboxTypeS_RightY', "GBA_Look_Gamepad" );
			break;
		case ESA_SouthPaw:
			UpdateControllerSettings_Worker( 'GBA_TurnLeft_Gamepad', "Axis aTurn Speed=1.0 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_Look_Gamepad', "Axis aLookup Speed=-0.65 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_StrafeLeft_Gamepad', "Axis aStrafe Speed=1.0 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_MoveForward_Gamepad', "Axis aBaseY Speed=-1.0 DeadZone=0.2" );

			UpdateControllerSettings_Worker( 'XboxTypeS_LeftX', "GBA_TurnLeft_Gamepad" );
			UpdateControllerSettings_Worker( 'XboxTypeS_LeftY', "GBA_Look_Gamepad" );
			UpdateControllerSettings_Worker( 'XboxTypeS_RightX', "GBA_StrafeLeft_Gamepad" );
			UpdateControllerSettings_Worker( 'XboxTypeS_RightY', "GBA_MoveForward_Gamepad" );
			break;
		case ESA_LegacySouthPaw:
			UpdateControllerSettings_Worker( 'GBA_StrafeLeft_Gamepad', "Axis aStrafe Speed=1.0 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_Look_Gamepad', "Axis aLookup Speed=-0.65 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_TurnLeft_Gamepad', "Axis aTurn Speed=1.0 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_MoveForward_Gamepad', "Axis aBaseY Speed=-1.0 DeadZone=0.2" );

			UpdateControllerSettings_Worker( 'XboxTypeS_LeftX', "GBA_StrafeLeft_Gamepad" );
			UpdateControllerSettings_Worker( 'XboxTypeS_LeftY', "GBA_Look_Gamepad" );
			UpdateControllerSettings_Worker( 'XboxTypeS_RightX', "GBA_TurnLeft_Gamepad" );
			UpdateControllerSettings_Worker( 'XboxTypeS_RightY', "GBA_MoveForward_Gamepad" );
			break;
		case ESA_Normal: default:
			UpdateControllerSettings_Worker( 'GBA_StrafeLeft_Gamepad', "Axis aStrafe Speed=1.0 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_MoveForward_Gamepad', "Axis aBaseY Speed=1.0 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_TurnLeft_Gamepad', "Axis aTurn Speed=1.0 DeadZone=0.2" );
			UpdateControllerSettings_Worker( 'GBA_Look_Gamepad', "Axis aLookup Speed=0.65 DeadZone=0.2" );

			UpdateControllerSettings_Worker( 'XboxTypeS_LeftX', "GBA_StrafeLeft_Gamepad" ); // Axis aStrafe Speed=1.0 DeadZone=0.2
			UpdateControllerSettings_Worker( 'XboxTypeS_LeftY', "GBA_MoveForward_Gamepad" ); //  Axis aBaseY Speed=1.0 DeadZone=0.2
			UpdateControllerSettings_Worker( 'XboxTypeS_RightX', "GBA_TurnLeft_Gamepad" ); // Axis aTurn Speed=1.0 DeadZone=0.2
			UpdateControllerSettings_Worker( 'XboxTypeS_RightY', "GBA_Look_Gamepad" ); //  Axis aLookup Speed=0.65 DeadZone=0.2
			break;
		}
	}

	// make sure to call the super version after, since it updates the current pawn as well.
	Super.LoadSettingsFromProfile(bLoadCharacter);

	// Bind menu button
	UpdateControllerSettings_Worker( 'XboxTypeS_Start', class'UTProfileSettings'.default.DigitalButtonActionsToCommandMapping[DBA_ShowMenu] );
}


private function UpdateControllerSettings_Worker( name TheName, string TheCommand )
{
	PlayerInput.SetBind(TheName, TheCommand);
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
	ignores SeePlayer, HearNoise, Bump;

	/**
	  * needs to support switching from wall dodge attempt to double jump with air control
	  */
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
			DoubleClickDir = DCLICK_Active;
		else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
		{
			if ( UTPawn(Pawn).Dodge(DoubleClickMove) )
			{
				DoubleClickDir = DCLICK_Active;
			}
			else if ( Pawn.Physics == PHYS_Falling )
			{
				// allow double jump while air controlling
				bPressedJump = true;
			}
		}

		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
	}
}

defaultproperties
{
	InputClass=class'UTGame.UTConsolePlayerInput'
	VehicleCheckRadiusScaling=1.5

	// @todo amitt update this to work with version 2 of the controller UI mapping system
	ProfileSettingToUE3BindingMapping360(0)=(ProfileSettingName="GamepadBinding_ButtonA",UE3BindingName="XboxTypeS_A")
	ProfileSettingToUE3BindingMapping360(1)=(ProfileSettingName="GamepadBinding_ButtonB",UE3BindingName="XboxTypeS_B")
	ProfileSettingToUE3BindingMapping360(2)=(ProfileSettingName="GamepadBinding_ButtonX",UE3BindingName="XboxTypeS_X")
	ProfileSettingToUE3BindingMapping360(3)=(ProfileSettingName="GamepadBinding_ButtonY",UE3BindingName="XboxTypeS_Y")
	ProfileSettingToUE3BindingMapping360(4)=(ProfileSettingName="GamepadBinding_Back",UE3BindingName="XboxTypeS_Back")
	ProfileSettingToUE3BindingMapping360(5)=(ProfileSettingName="GamepadBinding_Start",UE3BindingName="XboxTypeS_Start")

	ProfileSettingToUE3BindingMapping360(6)=(ProfileSettingName="GamepadBinding_RightBumper",UE3BindingName="XboxTypeS_RightTrigger")
	ProfileSettingToUE3BindingMapping360(7)=(ProfileSettingName="GamepadBinding_LeftBumper",UE3BindingName="XboxTypeS_LeftTrigger")

	ProfileSettingToUE3BindingMapping360(8)=(ProfileSettingName="GamepadBinding_RightTrigger",UE3BindingName="XboxTypeS_RightShoulder")
	ProfileSettingToUE3BindingMapping360(9)=(ProfileSettingName="GamepadBinding_LeftTrigger",UE3BindingName="XboxTypeS_LeftShoulder")

	ProfileSettingToUE3BindingMapping360(10)=(ProfileSettingName="GamepadBinding_RightThumbstickPressed",UE3BindingName="XboxTypeS_RightThumbstick")
	ProfileSettingToUE3BindingMapping360(11)=(ProfileSettingName="GamepadBinding_LeftThumbstickPressed",UE3BindingName="XboxTypeS_LeftThumbstick")
	ProfileSettingToUE3BindingMapping360(12)=(ProfileSettingName="GamepadBinding_DPadUp",UE3BindingName="XboxTypeS_DPad_Up")
	ProfileSettingToUE3BindingMapping360(13)=(ProfileSettingName="GamepadBinding_DPadDown",UE3BindingName="XboxTypeS_DPad_Down")
	ProfileSettingToUE3BindingMapping360(14)=(ProfileSettingName="GamepadBinding_DPadLeft",UE3BindingName="XboxTypeS_DPad_Left")
	ProfileSettingToUE3BindingMapping360(15)=(ProfileSettingName="GamepadBinding_DPadRight",UE3BindingName="XboxTypeS_DPad_Right")


	ProfileSettingToUE3BindingMappingPS3(0)=(ProfileSettingName="GamepadBinding_ButtonA",UE3BindingName="XboxTypeS_A")
	ProfileSettingToUE3BindingMappingPS3(1)=(ProfileSettingName="GamepadBinding_ButtonB",UE3BindingName="XboxTypeS_B")
	ProfileSettingToUE3BindingMappingPS3(2)=(ProfileSettingName="GamepadBinding_ButtonX",UE3BindingName="XboxTypeS_X")
	ProfileSettingToUE3BindingMappingPS3(3)=(ProfileSettingName="GamepadBinding_ButtonY",UE3BindingName="XboxTypeS_Y")
	ProfileSettingToUE3BindingMappingPS3(4)=(ProfileSettingName="GamepadBinding_Back",UE3BindingName="XboxTypeS_Back")
	ProfileSettingToUE3BindingMappingPS3(5)=(ProfileSettingName="GamepadBinding_Start",UE3BindingName="XboxTypeS_Start")


	ProfileSettingToUE3BindingMappingPS3(6)=(ProfileSettingName="GamepadBinding_RightBumper",UE3BindingName="XboxTypeS_RightShoulder")
	ProfileSettingToUE3BindingMappingPS3(7)=(ProfileSettingName="GamepadBinding_LeftBumper",UE3BindingName="XboxTypeS_LeftShoulder")
	ProfileSettingToUE3BindingMappingPS3(8)=(ProfileSettingName="GamepadBinding_RightTrigger",UE3BindingName="XboxTypeS_RightTrigger")
	ProfileSettingToUE3BindingMappingPS3(9)=(ProfileSettingName="GamepadBinding_LeftTrigger",UE3BindingName="XboxTypeS_LeftTrigger")

	ProfileSettingToUE3BindingMappingPS3(10)=(ProfileSettingName="GamepadBinding_RightThumbstickPressed",UE3BindingName="XboxTypeS_RightThumbstick")
	ProfileSettingToUE3BindingMappingPS3(11)=(ProfileSettingName="GamepadBinding_LeftThumbstickPressed",UE3BindingName="XboxTypeS_LeftThumbstick")
	ProfileSettingToUE3BindingMappingPS3(12)=(ProfileSettingName="GamepadBinding_DPadUp",UE3BindingName="XboxTypeS_DPad_Up")
	ProfileSettingToUE3BindingMappingPS3(13)=(ProfileSettingName="GamepadBinding_DPadDown",UE3BindingName="XboxTypeS_DPad_Down")
	ProfileSettingToUE3BindingMappingPS3(14)=(ProfileSettingName="GamepadBinding_DPadLeft",UE3BindingName="XboxTypeS_DPad_Left")
	ProfileSettingToUE3BindingMappingPS3(15)=(ProfileSettingName="GamepadBinding_DPadRight",UE3BindingName="XboxTypeS_DPad_Right")
	
	bConsolePlayer=true
}



