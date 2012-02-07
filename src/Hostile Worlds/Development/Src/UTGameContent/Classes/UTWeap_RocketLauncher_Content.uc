/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTWeap_RocketLauncher_Content extends UTWeap_RocketLauncher;

defaultproperties
{
	WeaponColor=(R=255,G=0,B=0,A=255)
	FireInterval(0)=+1.0
	FireInterval(1)=+1.05
	PlayerViewOffset=(X=0.0,Y=0.0,Z=0.0)

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_1P'
		PhysicsAsset=None
		AnimTreeTemplate=AnimTree'WP_RocketLauncher.Anims.AT_WP_RocketLauncher_1P_Base'
		AnimSets(0)=AnimSet'WP_RocketLauncher.Anims.K_WP_RocketLauncher_1P_Base'
		Translation=(X=0,Y=0,Z=0)
		Rotation=(Yaw=0)
		scale=1.0
		FOV=60.0
		bUpdateSkelWhenNotRendered=true
	End Object
	SkeletonFirstPersonMesh = FirstPersonMesh;
	AttachmentClass=class'UTGameContent.UTAttachment_RocketLauncher'

	// Pickup staticmesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_3P'
	End Object

	WeaponLoadedSnd=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Load_Cue'
	WeaponFireSnd[0]=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Fire_Cue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Fire_Cue'
	WeaponEquipSnd=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Raise_Cue'
	AltFireModeChangeSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_AltModeChange_Cue'
	RocketLoadedSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_RocketLoaded_Cue'
	GrenadeFireSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_GrenadeFire_Cue'

	AltFireSndQue(0)=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_AltFireQueue1_Cue'
	AltFireSndQue(1)=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_AltFireQueue2_Cue'
	AltFireSndQue(2)=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_AltFireQueue3_Cue'

	LockAcquiredSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLock_Cue'
	LockLostSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLost_Cue'

	WeaponProjectiles(0)=class'UTProj_Rocket'
	WeaponProjectiles(1)=class'UTProj_Rocket'
	LoadedRocketClass=class'UTProj_LoadedRocket'

	GrenadeClass=class'UTProj_Grenade'

	FireOffset=(X=20,Y=12,Z=-5)

	MaxDesireability=0.78
	AIRating=+0.78
	CurrentRating=+0.78
	bInstantHit=false
	bSplashJump=true
	bRecommendSplashDamage=true
	bSniping=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=1
	InventoryGroup=8
	GroupWeight=0.5

	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Rocket_Cue'

	AmmoCount=9
	LockerAmmoCount=18
	MaxAmmoCount=30

	SeekingRocketClass=class'UTProj_SeekingRocket'

	AltFireQueueTimes(0)=0.40
	AltFireQueueTimes(1)=0.96
	AltFireQueueTimes(2)=0.96
	AltFireLaunchTimes(0)= 0.51
	AltFireLaunchTimes(1)= 0.51
	AltFireLaunchTimes(2)= 0.51
	AltFireEndTimes(0)=0.44
	AltFireEndTimes(1)=0.44
	AltFireEndTimes(2)=0.44

	MaxLoadCount=3
	SpreadDist=1000
	FiringStatesArray(1)=WeaponLoadAmmo
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile
	WaitToFirePct=0.85
	GracePeriod=0.96

	MuzzleFlashSocket=MuzzleFlashSocketA
	MuzzleFlashSocketList(0)=MuzzleFlashSocketA
	MuzzleFlashSocketList(1)=MuzzleFlashSocketC
	MuzzleFlashSocketList(2)=MuzzleFlashSocketB

	MuzzleFlashPSCTemplate=WP_RocketLauncher.Effects.P_WP_RockerLauncher_Muzzle_Flash
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight'


	ConsoleLockAim=0.992
	LockRange=8000
	LockAim=0.997
	LockChecktime=0.1
	LockAcquireTime=1.1
	LockTolerance=0.2

	IconX=460
	IconY=34
	IconWidth=51
	IconHeight=38

	EquipTime=+0.6

	GrenadeSpreadDist=300

	JumpDamping=0.75

	LockerRotation=(pitch=0,yaw=0,roll=-16384)
	IconCoordinates=(U=131,V=379,UL=129,VL=50)
	CrossHairCoordinates=(U=128,V=64,UL=64,VL=64)
	WeaponPutDownSnd=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Lower_Cue'

	LoadedIconCoords[0]=(U=0,V=384,UL=63,VL=63)
	LoadedIconCoords[1]=(U=63,V=384,UL=63,VL=63)
	LoadedIconCoords[2]=(U=126,V=384,UL=63,VL=63)

	LoadUpAnimList[0]=WeaponAltFireQueue1
	LoadUpAnimList[1]=WeaponAltFireQueue2
	LoadUpAnimList[2]=WeaponAltFireQueue3

	WeaponAltFireLaunch[0]=WeaponAltFireLaunch1
	WeaponAltFireLaunch[1]=WeaponAltFireLaunch2
	WeaponAltFireLaunch[2]=WeaponAltFireLaunch3

	WeaponAltFireLaunchEnd[0]=WeaponAltFireLaunch1End
	WeaponAltFireLaunchEnd[1]=WeaponAltFireLaunch2End
	WeaponAltFireLaunchEnd[2]=WeaponAltFireLaunch3End

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
		Samples(0)=(LeftAmplitude=90,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.200)
	End Object
	WeaponFireWaveForm=ForceFeedbackWaveformShooting1
}

