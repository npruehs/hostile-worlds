/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVWeap_MantaGun extends UTVehicleWeapon
	HideDropDown;

function float SuggestAttackStyle()
{
	local UTBot B;
	
	B = UTBot(Instigator.Controller);
	if ( (Pawn(Instigator.Controller.Focus) == None) || (B == None) || (B.Skill < 3) )
	{
		return -0.2;
	}
	
	return 0.2;
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'UTProj_MantaBolt'
	WeaponFireTypes(1)=EWFT_None

	WeaponFireSnd[0]=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Fire'

	FireInterval(0)=+0.2
	bFastRepeater=true
	ShotCost(0)=0
	ShotCost(1)=0
	FireTriggerTags=(MantaWeapon01,MantaWeapon02)
	VehicleClass=class'UTVehicle_Manta_Content'
	AimError=750
}
