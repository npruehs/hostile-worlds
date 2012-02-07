/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Manta_Content extends UTVehicle_Manta;

simulated function InitializeEffects()
{
	Super.InitializeEffects();

	// we need to do this here as we have a bunch of code that correctly spawns on demand but these are a special case
	// of needing to exist when ever there is a manta
	if( VehicleEffects[FanEffectIndex].EffectRef == None )
	{
		CreateVehicleEffect( FanEffectIndex );
	}

	// immediately start and stop the fan effect, causing the blade particle to be left there unmoving so it's not missing
	//@note: requires a nonzero WarmupTime in the particle system itself
	if (FanEffectIndex >= 0 && FanEffectIndex < VehicleEffects.Length && VehicleEffects[FanEffectIndex].EffectRef != None)
	{
		VehicleEffects[FanEffectIndex].EffectRef.ActivateSystem();
		VehicleEffects[FanEffectIndex].EffectRef.DeactivateSystem();
	}
}

simulated event MantaJumpEffect()
{
	PlaySound(JumpSound, true);
	VehicleEvent('BoostStart');
}

simulated event MantaDuckEffect()
{
	if (bHoldingDuck)
	{
		PlaySound(DuckSound, true);
		VehicleEvent('CrushStart');
	}
	else
	{
		VehicleEvent('CrushStop');
	}
}

simulated function SetVehicleEffectParms(name TriggerName, ParticleSystemComponent PSC)
{
	if (TriggerName == 'MantaOnFire')
	{
		PSC.SetFloatParameter('smokeamount', 0.95);
		PSC.SetFloatParameter('fireamount', 0.95);
	}
	else
	{
		Super.SetVehicleEffectParms(TriggerName, PSC);
	}
}

simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	VehicleEvent('MantaNormal');
	return Super.Died(Killer,DamageType,HitLocation);
}

simulated function DrivingStatusChanged()
{
	if ( !bDriving )
	{
		VehicleEvent('CrushStop');
	}
	Super.DrivingStatusChanged();
}

simulated function BlowupVehicle()
{
	if(WorldInfo.Netmode != NM_DEDICATEDSERVER && VehicleEffects[11].EffectRef != none)
	{
		VehicleEffects[11].EffectRef.SetHidden(true); // special case to get rid of the blades
	}
	super.BlowUpVehicle();
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=40.0
		CollisionRadius=100.0
		Translation=(X=-40.0,Y=0.0,Z=40.0)
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Manta.Mesh.SK_VH_Manta'
		AnimTreeTemplate=AnimTree'VH_Manta.Anims.AT_Manta'
		PhysicsAsset=PhysicsAsset'VH_Manta.Mesh.SK_VH_Manta_Physics'
		MorphSets[0]=MorphTargetSet'VH_Manta.Mesh.VH_Manta_MorphTargets'
	End Object

	Seats(0)={( GunClass=class'UTVWeap_MantaGun',
				GunSocket=(Gun_Socket_01,Gun_Socket_02),
				TurretControls=(gun_rotate_lt,gun_rotate_rt),
				CameraTag=ViewSocket,
				CameraOffset=-180,
				SeatIconPos=(X=0.46,Y=0.45),
				DriverDamageMult=0.75,
				bSeatVisible=true,
				CameraBaseOffset=(X=-20,Y=0,Z=10),
				SeatOffset=(X=-30,Y=0,Z=-5),
				WeaponEffects=((SocketName=Gun_Socket_01,Offset=(X=-35,Y=-3),Scale3D=(X=3.0,Y=6.0,Z=6.0)),(SocketName=Gun_Socket_02,Offset=(X=-35,Y=-3),Scale3D=(X=3.0,Y=6.0,Z=6.0)))
				)}


	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=MantaEngineSound
		SoundCue=SoundCue'A_Vehicle_Manta_UT3g.SoundCues.A_Vehicle_Manta_EngineLoop'
	End Object
	EngineSound=MantaEngineSound
	Components.Add(MantaEngineSound);

	CollisionSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Start'
	ExitVehicleSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Stop'

	// Scrape sound.
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	JumpSound=SoundCue'A_Vehicle_Manta.Sounds.A_Vehicle_Manta_JumpCue'
	DuckSound=SoundCue'A_Vehicle_Manta.Sounds.A_Vehicle_Manta_CrouchCue'

	// Initialize sound parameters.
	EngineStartOffsetSecs=0.5
	EngineStopOffsetSecs=1.0

//	VehicleEffects(0)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Exhaust_Smoke',EffectSocket=Tailpipe_1)
//	VehicleEffects(1)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Exhaust_Smoke',EffectSocket=Tailpipe_2)

	VehicleEffects(2)=(EffectStartTag=BoostStart,EffectEndTag=BoostStop,EffectTemplate=ParticleSystem'VH_Manta.EffectS.PS_Manta_Up_Boost_Jump',EffectSocket=Wing_Lft_Socket)
	VehicleEffects(3)=(EffectStartTag=BoostStart,EffectEndTag=BoostStop,EffectTemplate=ParticleSystem'VH_Manta.EffectS.PS_Manta_Up_Boost_Jump',EffectSocket=Wing_Rt_Socket)

	VehicleEffects(4)=(EffectStartTag=CrushStart,EffectEndTag=CrushStop,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Down_Boost',EffectSocket=Wing_Lft_Socket)
	VehicleEffects(5)=(EffectStartTag=CrushStart,EffectEndTag=CrushStop,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Down_Boost',EffectSocket=Wing_Rt_Socket)

	VehicleEffects(6)=(EffectStartTag=MantaWeapon01,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Gun_MuzzleFlash',EffectSocket=Gun_Socket_02)
	VehicleEffects(7)=(EffectStartTag=MantaWeapon02,EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Gun_MuzzleFlash',EffectSocket=Gun_Socket_01)

	VehicleEffects(8)=(EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Up_Boost',EffectSocket=Wing_Lft_Socket)
	VehicleEffects(9)=(EffectTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Up_Boost',EffectSocket=Wing_Rt_Socket)

	VehicleEffects(10)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Manta',EffectSocket=DamageSmoke01)

	VehicleEffects(11)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.EffectS.P_FX_Manta_Blades_Blurred',EffectSocket=BladeSocket)

	VehicleEffects(12)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.EffectS.PS_Manta_Ground_FX',EffectSocket=Wing_Lft_Socket)
	VehicleEffects(13)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.EffectS.PS_Manta_Ground_FX',EffectSocket=Wing_rt_socket)

//	VehicleEffects(14)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Manta.Effects.P_VH_Manta_Exhaust',EffectSocket=ExhaustPort)

	VehicleEffects(14)=(EffectStartTag=MantaOnFire,EffectEndTag=MantaNormal,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=Wing_Lft_Socket)
	VehicleEffects(15)=(EffectStartTag=MantaOnFire,EffectEndTag=MantaNormal,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=Wing_Rt_Socket)
	VehicleEffects(16)=(EffectStartTag=MantaOnFire,EffectEndTag=MantaNormal,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=Gun_Socket_01)
	VehicleEffects(17)=(EffectStartTag=MantaOnFire,EffectEndTag=MantaNormal,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=Gun_Socket_02)
	VehicleEffects(18)=(EffectStartTag=MantaOnFire,EffectEndTag=MantaNormal,EffectTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1',EffectSocket=ExhaustPort)

	//Viper..(Special Case)........................................VH_NecrisManta.Effects.PS_Viper_Ground_FX............(this effect is in but needs a param set.  This will be the same effect for all surfaces except water which will use the same Param just swap PS to ...( Envy_Level_Effects_2.Vehicle_Water_Effects.PS_Viper_Water_Ground_FX )   (Param Name: Direction,  MinINPUT: -5  MaxINPUT: 5)  0 is when the Vh is still, positive X=forward movemet 5 being max forward movement.  -X is backwards.  Y is same thing but side to side

	// guess we can just have a water effect name here and then check for water and then then add and && to use only this named VehicleEffects index data


	FanEffectIndex=11

	GroundEffectIndices=(12,13)
	WaterGroundEffect=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.PS_Manta_Water_Effects'

	FanEffectParameterName=MantaFanSpin
	FlameJetEffectParameterName=Jet

	IconCoords=(U=859,UL=36,V=0,VL=27)

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Near')
	BigExplosionSocket=VH_Death
	ExplosionSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Explode'

	TeamMaterials[0]=MaterialInstanceConstant'VH_Manta.Materials.MI_VH_Manta_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_Manta.Materials.MI_VH_Manta_Blue'

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Manta.Materials.MI_VH_Manta_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Manta.Materials.MI_VH_Manta_Spawn_Blue'))

	DrivingPhysicalMaterial=PhysicalMaterial'VH_Manta.physmat_mantadriving'
	DefaultPhysicalMaterial=PhysicalMaterial'VH_Manta.physmat_manta'

	BurnOutMaterial[0]=MaterialInterface'VH_Manta.Materials.MITV_VH_Manta_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Manta.Materials.MITV_VH_Manta_Blue_BO'

	DamageMorphTargets(0)=(InfluenceBone=Damage_LtCanard,MorphNodeName=MorphNodeW_Front,LinkedMorphNodeName=none,Health=70,DamagePropNames=(Damage2))
	DamageMorphTargets(1)=(InfluenceBone=Damage_RtRotor,MorphNodeName=MorphNodeW_Right,LinkedMorphNodeName=none,Health=70,DamagePropNames=(Damage3))
	DamageMorphTargets(2)=(InfluenceBone=Damage_LtRotor,MorphNodeName=MorphNodeW_Left,LinkedMorphNodeName=none,Health=70,DamagePropNames=(Damage3))
	DamageMorphTargets(3)=(InfluenceBone=Hatch,MorphNodeName=MorphNodeW_Rear,LinkedMorphNodeName=none,Health=70,DamagePropNames=(Damage1))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.5)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=1.5)

	HudCoords=(U=228,V=143,UL=-119,VL=106)

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_Reaper.BotStatus.A_BotStatus_Reaper_EnemyManta'
}
