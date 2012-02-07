// ============================================================================
// HWWA_Hunter
// The WeaponAttachment for the Hunter.
//
// Author:  Nick Pruehs
// Date:    2011/07/11
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWWA_Hunter extends HWWeaponAttachment;

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_Humans.Mesh.SK_WP_Commander'
	End Object

	MuzzleFlashSocket=MuzzleFlashSocket	
	MuzzleFlashPSCTemplate=ParticleSystem'WP_Humans.Effects.P_FX_Hunter_MF'
	MuzzleFlashDuration=.2f;
	MuzzleFlashLightClass=class'HWMuzzleFlashLight_Commander'
}
