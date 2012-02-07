/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Hoverboard_Content extends UTVehicle_Hoverboard;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Hoverboard.Mesh.SK_VH_Hoverboard'
		PhysicsAsset=PhysicsAsset'VH_Hoverboard.Mesh.SK_VH_Hoverboard_Physics'
		AnimTreeTemplate=VH_Hoverboard.Anims.AT_Hoverboard
		RBDominanceGroup=16
	End Object

	RedDustEffect=ParticleSystem'Envy_Effects.Smoke.P_HoverBoard_Ground_Dust'
	BlueDustEffect=ParticleSystem'Envy_Effects.Smoke.P_HoverBoard_Ground_Dust_Blue'

	Begin Object Class=StaticMeshComponent Name=Handle
		StaticMesh=StaticMesh'VH_Hoverboard.Mesh.S_Hoverboard_Handle'
		Rotation=(Yaw=16384,Roll=-16384)
		Translation=(Z=-1.0)
		CollideActors=false
		Scale=0.5
	End Object
	HandleMesh=Handle

	Begin Object Class=RB_StayUprightSetup Name=MyLeanUprightSetup
		bSwingLimited=false
	End Object
	LeanUprightConstraintSetup=MyLeanUprightSetup

	Begin Object Class=RB_ConstraintInstance Name=MyLeanUprightConstraintInstance
		bSwingPositionDrive=true
		AngularDriveSpring=1000
		AngularDriveDamping=100
	End Object
	LeanUprightConstraintInstance=MyLeanUprightConstraintInstance

	Begin Object Class=RB_ConstraintSetup Name=MyFootBoardConstraintSetup
		bTwistLimited=true
		bSwingLimited=true
	End Object
	FootBoardConstraintSetup=MyFootBoardConstraintSetup

	Begin Object Class=RB_ConstraintInstance Name=MyLeftFootBoardConstraintInstance
	End Object
	LeftFootBoardConstraintInstance=MyLeftFootBoardConstraintInstance

	Begin Object Class=RB_ConstraintInstance Name=MyRightFootBoardConstraintInstance
	End Object
	RightFootBoardConstraintInstance=MyRightFootBoardConstraintInstance

	Begin Object Class=UDKVehicleSimHoverboard Name=SimObject
		WheelSuspensionStiffness=200.0
		WheelSuspensionDamping=20.0
		WheelSuspensionBias=0.0
		WheelLatExtremumValue=0.7

		MaxThrustForce=200.0
		MaxReverseForce=40.0
		MaxReverseVelocity=200.0
		LongDamping=0.3

		MaxStrafeForce=150.0
		LatDamping=0.3

		TurnTorqueFactor=800.0
		SpinTurnTorqueScale=3.5
		MaxTurnTorque=1000.0
		TurnDampingSpeedFunc=(Points=((InVal=0,OutVal=0.05),(InVal=300,OutVal=0.11),(InVal=800,OutVal=0.12)))
		OverWaterSound=SoundCue'A_Vehicle_Hoverboard.Cue.A_Vehicle_HoverBoard_WaterDisruptCue'
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	Begin Object Class=UTHoverWheel Name=HoverWheelFL
		BoneName="Front_Wheel"
		BoneOffset=(X=25.0,Y=0.0,Z=-50.0)
		WheelRadius=10
		SuspensionTravel=50
		bPoweredWheel=true
		LongSlipFactor=0
		LatSlipFactor=100
		HandbrakeLongSlipFactor=0
		HandbrakeLatSlipFactor=150
		SteerFactor=1.0
		Side=SIDE_Left
		bHoverWheel=true
	End Object
	Wheels(0)=HoverWheelFL

	Begin Object Class=UTHoverWheel Name=HoverWheelRL
		BoneName="Rear_Wheel"
		BoneOffset=(X=0.0,Y=0,Z=-50.0)
		WheelRadius=10
		SuspensionTravel=50
		bPoweredWheel=true
		LongSlipFactor=0
		LatSlipFactor=100
		HandbrakeLongSlipFactor=0
		HandbrakeLatSlipFactor=150
		SteerFactor=0.0
		Side=SIDE_Left
		bHoverWheel=true
		SkelControlName="BoardTire"
	End Object
	Wheels(1)=HoverWheelRL

	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=HoverboardEngineSound
		SoundCue=SoundCue'A_Vehicle_Hoverboard.Cue.A_Vehicle_Hoverboard_EngineCue'
	End Object
	EngineSound=HoverboardEngineSound
	Components.Add(HoverboardEngineSound);

	CollisionSound=SoundCue'A_Vehicle_Hoverboard.Cue.A_Vehicle_Hoverboard_CollideCue'
	EnterVehicleSound=SoundCue'A_Vehicle_Hoverboard.Cue.A_Vehicle_Hoverboard_EngineStartCue'
	ExitVehicleSound=SoundCue'A_Vehicle_Hoverboard.Cue.A_Vehicle_Hoverboard_EngineStopCue'

	// Scrape sound.
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	// Carving sound.
	Begin Object Class=AudioComponent Name=CarveSound
		SoundCue=SoundCue'A_Vehicle_Hoverboard.Cue.A_Vehicle_HoverBoard_CurveCue'
	End Object
	CurveSound=CarveSound
	Components.Add(CarveSound);

	EngineThrustSound=SoundCue'A_Vehicle_Hoverboard.Cue.A_Vehicle_HoverBoard_EngineThrustCue'
	TurnSound=SoundCue'A_Vehicle_Hoverboard.Cue.A_Vehicle_HoverBoard_TurnCue'
	JumpSound=SoundCue'A_Vehicle_Hoverboard.Cue.A_Vehicle_Hoverboard_JumpCue'

	BoostPadSound=SoundCue'A_Vehicle_Hoverboard.Cue.A_Vehicle_HoverBoard_JumpBoostCue'

	// Initialize sound parameters.
	EngineStartOffsetSecs=0.3
	EngineStopOffsetSecs=1.0

	RedThrusterEffect=ParticleSystem'VH_Hoverboard.Effects.P_VH_Hoverboard_Jet_Red01'
	BlueThrusterEffect=ParticleSystem'VH_Hoverboard.Effects.P_VH_Hoverboard_Jet_Blue01'

	Begin Object Class=ParticleSystemComponent Name=ThrusterEffect0
		SecondsBeforeInactive=1.0f
	End Object
	ThrusterEffect=ThrusterEffect0
	ThrusterEffectSocket=RearCenterThrusterSocket

	RoosterEffectTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Hoverboard_Water_Towed'
	RoosterSoundCue=SoundCue'VH_Hoverboard.Hoverboard_Water_Sound'
}
