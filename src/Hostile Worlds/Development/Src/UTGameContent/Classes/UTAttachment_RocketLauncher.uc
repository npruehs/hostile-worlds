/**
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*/
class UTAttachment_RocketLauncher extends UTWeaponAttachment;

simulated function AttachTo(UTPawn OwnerPawn)
{
	Super.AttachTo(OwnerPawn);
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	if (IsZero(HitLocation))
	{
		// fired rocket
		Mesh.PlayAnim('WeaponReload', (WeaponClass != None) ? WeaponClass.default.FireInterval[0] : 0.0);
		Super.ThirdPersonFireEffects(HitLocation);
	}
}

simulated function StopThirdPersonFireEffects()
{
	Super.StopThirdPersonFireEffects();
}

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_3P'		
		MaxDrawDistance=5000
		AnimSets(0)=AnimSet'WP_RocketLauncher.Anims.K_WP_RocketLauncher_3P'
		Translation=(Y=1,Z=1)
		Rotation=(Roll=-599)
		Scale=1.1
		End Object

		MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight'
		WeaponClass=class'UTWeap_RocketLauncher'

		WeapAnimType=EWAT_Stinger
}
