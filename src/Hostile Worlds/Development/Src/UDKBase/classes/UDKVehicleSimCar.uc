/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKVehicleSimCar extends SVehicleSimCar
	native;

/** Torque vs Speed curve: This curve approximates a transmission as opposed to actually simulating one as in SVehicleSimTransmission
    In general you want to have a higher torque at low speed and a lower torque at high speed */
var()	InterpCurveFloat      TorqueVSpeedCurve;

/** Translates forward velocity into an EngineRPM that can be used for effects and sounds */
var()	InterpCurveFloat      EngineRPMCurve;

/** Limited slip differential: 0.60 would mean 60% of the power is routed through the LSD and 40% is divided evenly */
var()   float                 LSDFactor;

/** ThrottleSpeed is the speed at which the vehicle will increase its ActualThrottle to get to the desired Throttle */
var()   float                 ThrottleSpeed;

// Internal
var     float               MinRPM;
var     float               MaxRPM;
var     float               ActualThrottle;

/** flag when throttle was forced up to prevent back slipping */
var		bool				bForceThrottle;

/** flag set when bForceThrottle has been used, and throttle has not been zeroed again */
var		bool				bHasForcedThrottle;

/** flag to prevent braking to a stop with no driver */
var		bool				bDriverlessBraking;

/** steering reduction factor when have wheels in air (to make vehicles easier to control) */
var()	float				SteeringReductionFactor;

/** steering reduction ramp up rate (1/this = time to full steering reduction).  ramps down at half this rate */
var() float					SteeringReductionRampUpRate;

/** current steering reduction value (scales up and down over time */
var float					CurrentSteeringReduction;

/** how many wheels must be on ground in order to avoid steering reduction */
var()	int					NumWheelsForFullSteering;

/** speed at which steering reduction is in full effect */
var()	float				SteeringReductionSpeed;

/** speed at which steering reduction starts */
var()	float				SteeringReductionMinSpeed;

/** minimum speed before torque reduction sets in when turning hard */
var()	float				MinHardTurnSpeed;

/** motor torque applied during hard turns (don't want to accelerate through hard turns */
var()	float				HardTurnMotorTorque;

/** whether should auto-handbrake when wheels on one side are off the ground */
var()	bool				bAutoHandbrake;

/** How quickly the handbrake is turned off (it is turned on immediately) */
var()	float				HandbrakeSpeed;

/** Internal - current amount of handbrake applied. */
var		float				ActualHandbrake;

/** When driving into something, reduce friction on the wheels. */
var()	float				FrontalCollisionGripFactor;

/** When turning hard on console, reduce lateral grip to enhance sliding around. */
var()	float				ConsoleHardTurnGripFactor;

/** Damping on yaw based on vehicle speed. */
var()	float				SpeedBasedTurnDamping;

/** Torque to apply when vehicle is in ato allow some air control. */
var()	float				AirControlTurnTorque;

/** Torque applied when in the air to try and keep vehicle horizontal. */
var()	float				InAirUprightTorqueFactor;

/** Max torque that can be applied to try and */
var()	float				InAirUprightMaxTorque;

cpptext
{
	// SVehicleSimBase interface.
	virtual void UpdateVehicle(ASVehicle* Vehicle, FLOAT DeltaTime);
	virtual FLOAT GetEngineOutput(ASVehicle* Vehicle);
	virtual void ProcessCarInput(ASVehicle* Vehicle);
	virtual void UpdateHandbrake(ASVehicle* Vehicle);
}

defaultproperties
{
	ThrottleSpeed=0.2
	bDriverlessBraking=true
	NumWheelsForFullSteering=0
	SteeringReductionFactor=1.0
	SteeringReductionMinSpeed=2500.0
	SteeringReductionSpeed=2500.0
	CurrentSteeringReduction=1.0
	SteeringReductionRampUpRate=5.0
	MinHardTurnSpeed=250.0
	HardTurnMotorTorque=0.4
	FrontalCollisionGripFactor=1.0
	ConsoleHardTurnGripFactor=1.0
	HandbrakeSpeed=2.0
}
