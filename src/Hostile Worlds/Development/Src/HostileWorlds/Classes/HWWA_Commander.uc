// ============================================================================
// HWWA_Commander
// The WeaponAttachment for the Commander. 
// Copied from UTAttachment_ShockRifle.
//
// Author:  Marcel Koehler
// Date:    2010/12/30
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWWA_Commander extends HWWeaponAttachment;

defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_Humans.Mesh.SK_WP_Commander'
	End Object

	MuzzleFlashSocket=MuzzleFlashSocket	
	MuzzleFlashPSCTemplate=ParticleSystem'WP_Humans.Effects.P_FX_Commander_MF'
	MuzzleFlashDuration=.175f
	MuzzleFlashLightClass=class'HWMuzzleFlashLight_Commander'
}
