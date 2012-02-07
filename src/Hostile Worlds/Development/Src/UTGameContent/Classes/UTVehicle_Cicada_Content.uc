/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Cicada_Content extends UTVehicle_Cicada;

var array<UTDecoy> Decoys;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Mesh != None)
	{
		JetControl = UTSkelControl_JetThruster(Mesh.FindSkelControl('CicadaJet'));
	}
}

function IncomingMissile(Projectile P)
{
	local UTVWeap_CicadaTurret Turret;

	// notify the turret weapon
	if (Seats.length > 1)
	{
		Turret = UTVWeap_CicadaTurret(Seats[1].Gun);
		if (Turret != None)
		{
			Turret.IncomingMissile(P);
		}
	}

	Super.IncomingMissile(P);
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+70.0
		CollisionRadius=+240.0
		Translation=(X=-40.0,Y=0.0,Z=40.0)
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Cicada.Mesh.SK_VH_Cicada'
		AnimTreeTemplate=AnimTree'VH_Cicada.Anims.AT_VH_Cicada'
		PhysicsAsset=PhysicsAsset'VH_Cicada.Mesh.SK_VH_Cicada_Physics'
		AnimSets.Add(AnimSet'VH_Cicada.Anims.VH_Cicada_Anims')
	End Object

	DrawScale=1.3

	Health=500
	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Near')
	BigExplosionSocket=VH_Death

	Seats.Empty
	Seats(0)={(	GunClass=class'UTVWeap_CicadaMissileLauncher',
				GunSocket=(Gun_Socket_02,Gun_Socket_01),
				CameraTag=ViewSocket,
				TurretControls=(LauncherA,LauncherB),
				CameraOffset=-400,
				CameraBaseOffset=(Z=25.0),
				SeatIconPos=(X=0.48,Y=0.25),
				GunPivotPoints=(Main),
				WeaponEffects=((SocketName=Gun_Socket_01,Offset=(X=-80),Scale3D=(X=12.0,Y=15.0,Z=15.0)),(SocketName=Gun_Socket_02,Offset=(X=-80),Scale3D=(X=12.0,Y=15.0,Z=15.0)))
				)}

	Seats(1)={(	GunClass=class'UTVWeap_CicadaTurret',
				GunSocket=(Turret_Gun_Socket_01,Turret_Gun_Socket_02,Turret_Gun_Socket_03,Turret_Gun_Socket_04),
				TurretVarPrefix="Turret",
				TurretControls=(Turret_Rotate),
				CameraTag=Turret_ViewSocket,
				CameraOffset=0,
				GunPivotPoints=(MainTurret_Pitch),
				CameraEyeHeight=0,
				SeatIconPos=(X=0.48,Y=0.56),
				ViewPitchMin=-14000.0,
				ViewPitchMax=1.0,
				WeaponEffects=((SocketName=Turret_Gun_Socket_04,Offset=(X=-80),Scale3D=(X=8.0,Y=10.0,Z=10.0)),(SocketName=Turret_Gun_Socket_03,Offset=(X=-80),Scale3D=(X=8.0,Y=10.0,Z=10.0)))
				)}


	TurretBeamTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_2ndPrim_Beam'

	VehicleEffects.Empty
	
	VehicleEffects(0)=(EffectStartTag=TurretWeapon00,EffectEndTag=STOP_TurretWeapon00,EffectTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_2ndAltFlash',EffectSocket=Turret_Gun_Socket_01)
	VehicleEffects(1)=(EffectStartTag=TurretWeapon01,EffectEndTag=STOP_TurretWeapon01,EffectTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_2ndAltFlash',EffectSocket=Turret_Gun_Socket_02)
	VehicleEffects(2)=(EffectStartTag=TurretWeapon02,EffectEndTag=STOP_TurretWeapon02,EffectTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_2ndAltFlash',EffectSocket=Turret_Gun_Socket_03)
	VehicleEffects(3)=(EffectStartTag=TurretWeapon03,EffectEndTag=STOP_TurretWeapon03,EffectTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_2ndAltFlash',EffectSocket=Turret_Gun_Socket_04)

	VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_GroundEffect',EffectSocket=GroundEffectBase)
	VehicleEffects(5)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_Exhaust',EffectSocket=LeftExhaust)
	VehicleEffects(6)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_Exhaust',EffectSocket=RightExhaust)
	VehicleEffects(7)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Cicada',EffectSocket=DamageSmoke_01)

	VehicleAnims(0)=(AnimTag=Created,AnimSeqs=(InActiveStill),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=CicadaPlayer)
	VehicleAnims(1)=(AnimTag=EngineStart,AnimSeqs=(GetIn),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=CicadaPlayer)
	VehicleAnims(2)=(AnimTag=Idle,AnimSeqs=(Idle),AnimRate=1.0,bAnimLoopLastSeq=true,AnimPlayerName=CicadaPlayer)
	VehicleAnims(3)=(AnimTag=EngineStop,AnimSeqs=(GetOut),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=CicadaPlayer)

	JetEffectIndices=(11,12)
	ContrailEffectIndices=(2,3,4,5,13,14)
	GroundEffectIndices=(10)

	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=RaptorEngineSound
		SoundCue=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_EngineLoop'
	End Object
	EngineSound=RaptorEngineSound
	Components.Add(RaptorEngineSound);

	CollisionSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Start'
	ExitVehicleSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Stop'

	// Scrape sound.
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	// Initialize sound parameters.
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	IconCoords=(U=988,V=0,UL=33,VL=42)

	ExplosionSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Explode'
	JetScalingParam=JetScale

	PassengerTeamBeaconOffset=(X=-125.0f,Y=0.0f,Z=-105.0f);
	ReferenceMovementMesh=StaticMesh'Envy_Effects.Mesh.S_Air_Wind_Ball'

	HudCoords=(U=106,V=125,UL=-106,VL=124)
	TeamMaterials[0]=MaterialInstanceConstant'VH_Cicada.Materials.MI_VH_Cicada_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_Cicada.Materials.MI_VH_Cicada_Blue'

	BurnOutMaterial[0]=MaterialInterface'VH_Cicada.Materials.MITV_VH_Cicada_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Cicada.Materials.MITV_VH_Cicada_Blue_BO'

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Cicada.Materials.MI_VH_Cicada_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Cicada.Materials.MI_VH_Cicada_Spawn_Blue'))

	DamageMorphTargets(0)=(InfluenceBone=Lt_Gun_Yaw,MorphNodeName=none,Health=150,DamagePropNames=(Damage2))
	DamageMorphTargets(1)=(InfluenceBone=Rt_Gun_Yaw,MorphNodeName=none,Health=150,DamagePropNames=(Damage2))
	DamageMorphTargets(2)=(InfluenceBone=FrontGuardDamage,MorphNodeName=none,Health=150,DamagePropNames=(Damage1))
	DamageMorphTargets(3)=(InfluenceBone=MainTurret_Yaw,MorphNodeName=none,Health=150,DamagePropNames=(Damage3))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=3)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.5)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.5)

	DrivingPhysicalMaterial=PhysicalMaterial'VH_Cicada.materials.physmat_Cicada_driving'
	DefaultPhysicalMaterial=PhysicalMaterial'VH_Cicada.materials.physmat_Cicada'

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyCicada'
}
