/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Scorpion_Content extends UTVehicle_Scorpion;

simulated function TeamChanged()
{
	local color newColor;

	Super.TeamChanged();

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		newColor = (Team == 1) ? MakeColor(96,64,255) : MakeColor(255,64,96);
		RightBoosterLight.SetLightProperties(,newColor);
		LeftBoosterLight.SetLightProperties(,newColor);
	}
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=40.0
		CollisionRadius=100.0
		Translation=(X=-25.0)
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Scorpion.Mesh.SK_VH_Scorpion_001'
		AnimTreeTemplate=AnimTree'VH_Scorpion.Anims.AT_VH_Scorpion_001'
		PhysicsAsset=PhysicsAsset'VH_Scorpion.Mesh.SK_VH_Scorpion_001_Physics'
		MorphSets[0]=MorphTargetSet'VH_Scorpion.Mesh.VH_Scorpion_MorphTargets'
		AnimSets.Add(AnimSet'VH_Scorpion.Anims.K_VH_Scorpion')
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled4=TRUE)
	End Object

	DrawScale=1.2
	IconCoords=(U=831,UL=21,V=39,VL=29)
								     
	BoostToolTipIconCoords=(U=0,UL=101,V=841,VL=49)
	EjectToolTipIconCoords=(U=93,UL=46,V=316,VL=52)

	BrakeLightParameterName=Brake_Light
	ReverseLightParameterName=Reverse_Light
	HeadLightParameterName=Green_Glows_Headlights

	Seats(0)={(	GunClass=class'UTVWeap_ScorpionTurret',
				GunSocket=(TurretFireSocket),
				GunPivotPoints=(gun_rotate),
				TurretVarPrefix="",
				TurretControls=(TurretRotate),
				SeatIconPos=(X=	0.415,Y=0.5),
				CameraTag=GunViewSocket,
				CameraBaseOffset=(X=-50.0),
				CameraOffset=-175,
				WeaponEffects=((SocketName=TurretFireSocket,Offset=(X=-14,Y=5),Scale3D=(X=2.0,Y=3.0,Z=3.0)),(SocketName=TurretFireSocket,Offset=(X=-14,Y=-5),Scale3D=(X=2.0,Y=3.0,Z=3.0)))
				)}

	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=ScorpionEngineSound
		SoundCue=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_EngineLoop'
	End Object
	EngineSound=ScorpionEngineSound
	Components.Add(ScorpionEngineSound);

	Begin Object Class=AudioComponent Name=ScorpionTireSound
		SoundCue=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue'
	End Object
	TireAudioComp=ScorpionTireSound
	Components.Add(ScorpionTireSound);


	TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue')
	TireSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireFoliage01Cue')
	TireSoundList(2)=(MaterialType=Grass,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireGrass01Cue')
	TireSoundList(3)=(MaterialType=Metal,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMetal01Cue')
	TireSoundList(4)=(MaterialType=Mud,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMud01Cue')
	TireSoundList(5)=(MaterialType=Snow,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireSnow01Cue')
	TireSoundList(6)=(MaterialType=Stone,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireStone01Cue')
	TireSoundList(7)=(MaterialType=Wood,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWood01Cue')
	TireSoundList(8)=(MaterialType=Water,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWater01Cue')

	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Scorpion_Wheel_Dust')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'VH_Scorpion.Effects.PS_Wheel_Rocks')
	WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Scorpion_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Scorpion_Wheel_Snow')

	RedBoostCamAnim=CameraAnim'Camera_FX.VH_Scorpion.C_VH_Scorpion_Boost_Red'
	BlueBoostCamAnim=CameraAnim'Camera_FX.VH_Scorpion.C_VH_Scorpion_Boost_Blue'

	// Wheel squealing sound.
	Begin Object Class=AudioComponent Name=ScorpionSquealSound
		SoundCue=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Slide'
	End Object
	SquealSound=ScorpionSquealSound
	Components.Add(ScorpionSquealSound);

	CollisionSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Start'
	ExitVehicleSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Stop'

	// Rocket booster sound.
	Begin Object Class=AudioComponent Name=ScorpionBoosterSound
		SoundCue=SoundCue'A_Vehicle_Raptor.SoundCues.A_Vehicle_Raptor_EngineLoop'
	End Object
	BoosterSound=ScorpionBoosterSound
	Components.Add(ScorpionBoosterSound);

	// Initialize sound parameters.

	SquealThreshold=0.1
	SquealLatThreshold=0.02
	LatAngleVolumeMult = 30.0
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	VehicleEffects(0)=(EffectStartTag=BoostStart,EffectEndTag=BoostStop,EffectTemplate=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Booster_Red',EffectTemplate_Blue=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Booster',EffectSocket=Booster01)
	VehicleEffects(1)=(EffectStartTag=BoostStart,EffectEndTag=BoostStop,EffectTemplate=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Booster_Red',EffectTemplate_Blue=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Booster',EffectSocket=Booster02)
	VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Scorpion',EffectSocket=DamageSmoke01)
	VehicleEffects(3)=(EffectStartTag=MuzzleFlash,EffectTemplate=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Gun_MuzzleFlash_Red',EffectTemplate_Blue=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Gun_MuzzleFlash',EffectSocket=TurretFireSocket)

	RightBladeStartSocket=Blade_R_Start
	RightBladeEndSocket=Blade_R_End
	LeftBladeStartSocket=Blade_L_Start
	LeftBladeEndSocket=Blade_L_End
	BladeDamageType=class'UTDmgType_ScorpionBlade'
	BladeBreakSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_BladeBreakOff'
	BladeExtendSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_BladeExtend'
	BladeRetractSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_BladeRetract'

	SelfDestructDamageType=class'UTDmgType_ScorpionSelfDestruct'

	SelfDestructSoundCue=SoundCue'A_Vehicle_Goliath.SoundCues.A_Vehicle_Goliath_Fire'
	EjectSoundCue=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Eject_Cue'

	Begin Object class=PointLightComponent name=LeftRocketLight
		Brightness=3.0
		LightColor=(R=96,G=64,B=255)
		Radius=100.0
		CastShadows=false
		bEnabled=false
    	Translation=(X=20,Z=0)
	End Object
	LeftBoosterLight=LeftRocketLight

	Begin Object class=PointLightComponent name=RightRocketLight
		Brightness=3.0
		LightColor=(R=96,G=64,B=255)
		Radius=100.0
		CastShadows=false
		bEnabled=false
    	Translation=(X=20,Z=0)
	End Object
	RightBoosterLight=RightRocketLight

	DamageMorphTargets(0)=(InfluenceBone=LtFront_Fender,MorphNodeName=MorphNodeW_LtFrontFender,LinkedMorphNodeName=MorphNodeW_Hood,Health=30,DamagePropNames=(Damage2))
	DamageMorphTargets(1)=(InfluenceBone=RtFront_Fender,MorphNodeName=MorphNodeW_RtFrontFender,LinkedMorphNodeName=MorphNodeW_Hood,Health=30,DamagePropNames=(Damage2))
	DamageMorphTargets(2)=(InfluenceBone=LtRear_Fender,MorphNodeName=MorphNodeW_LtRearFender,LinkedMorphNodeName=MorphNodeW_Hatch,Health=40,DamagePropNames=(Damage1,Damage5))
	DamageMorphTargets(3)=(InfluenceBone=RtRear_Fender,MorphNodeName=MorphNodeW_RtRearFender,LinkedMorphNodeName=MorphNodeW_Hatch,Health=40,DamagePropNames=(Damage1,Damage5))
	DamageMorphTargets(4)=(InfluenceBone=Hood,MorphNodeName=MorphNodeW_Hood,LinkedMorphNodeName=MorphNodeW_Hatch,Health=100,DamagePropNames=(Damage3,Damage1))
	DamageMorphTargets(5)=(InfluenceBone=Hatch_Slide,MorphNodeName=MorphNodeW_Hatch,LinkedMorphNodeName=MorphNodeW_Body,Health=125,DamagePropNames=(Damage1))
	DamageMorphTargets(6)=(InfluenceBone=Main_Root,MorphNodeName=MorphNodeW_Body,Health=175,DamagePropNames=(Damage6,Damage7))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.0)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=1.0)
	DamageParamScaleLevels(3)=(DamageParamName=Damage5,Scale=1.0)
	DamageParamScaleLevels(4)=(DamageParamName=Damage6,Scale=1.0)
	DamageParamScaleLevels(5)=(DamageParamName=Damage7,Scale=1.0)

	ScorpionHood=StaticMesh'VH_Scorpion.Mesh.S_VH_Scorpion_Hood_Damaged'
	BrokenBladeMesh=StaticMesh'VH_Scorpion.Mesh.S_VH_Scorpion_Broken_Blade'

	FlagOffset=(X=-60.0,Y=25,Z=40)

	SelfDestructWarningSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_DestructionWarning_Cue'
	SelfDestructReadyCue=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_EjectReadyBeep_Cue'
	SelfDestructEnabledSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_EngineThrustStart_Cue'
	SelfDestructEnabledLoop=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_EngineThrustLoop_Cue'

	ExplosionSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Explode'

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Scorpion.Materials.MI_VH_Scorpion_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Scorpion.Materials.MI_VH_Scorpion_Spawn_Blue'))

	TeamMaterials[0]=MaterialInstanceConstant'VH_Scorpion.Materials.MI_VH_Scorpion_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_Scorpion.Materials.MI_VH_Scorpion_Blue'

	SuspensionShiftSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleCompressD_Cue'

	DrivingPhysicalMaterial=PhysicalMaterial'vh_scorpion.materials.physmat_scorpiondriving'
	DefaultPhysicalMaterial=PhysicalMaterial'vh_scorpion.materials.physmat_scorpion'

	BurnOutMaterial[0]=MaterialInterface'VH_Scorpion.Materials.MITV_VH_Scorpion_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Scorpion.Materials.MITV_VH_Scorpion_Blue_BO'

	SelfDestructExplosionTemplate=ParticleSystem'VH_Scorpion.Effects.P_VH_Scorpion_SelfDestruct'
	HatchGibClass=class'UTGib_ScorpionHatch'

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Near')
	BigExplosionSocket=VH_Death

   	HudCoords=(U=410,V=112,UL=-86,VL=109)

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_Reaper.BotStatus.A_BotStatus_Reaper_EnemyScorpion'
}
