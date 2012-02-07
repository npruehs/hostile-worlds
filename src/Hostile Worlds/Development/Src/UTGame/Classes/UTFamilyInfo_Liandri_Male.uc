/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTFamilyInfo_Liandri_Male extends UTFamilyInfo_Liandri
	abstract;

defaultproperties
{
	FamilyID="LIAM"

	CharacterMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'

	ArmMeshPackageName="CH_Corrupt_Arms"
	ArmMesh=CH_Corrupt_Arms.Mesh.SK_CH_Corrupt_Arms_MaleA_1P
	ArmSkinPackageName="CH_Corrupt_Arms"
	RedArmMaterial=CH_Corrupt_Arms.Materials.MI_CH_Corrupt_FirstPersonArms_VRed
	BlueArmMaterial=CH_Corrupt_Arms.Materials.MI_CH_Corrupt_FirstPersonArms_VBlue

	CharacterTeamHeadMaterials[0]=MaterialInterface'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MBody01_VRed'
	CharacterTeamBodyMaterials[0]=MaterialInterface'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MHead01_VRed'
	CharacterTeamHeadMaterials[1]=MaterialInterface'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MBody01_VBlue'
	CharacterTeamBodyMaterials[1]=MaterialInterface'CH_Corrupt_Male.Materials.MI_CH_Corrupt_MHead01_VBlue'

	PhysAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
	AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'

	BaseMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_Corrupt_Base'
	BioDeathMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_Corrupt_BioDeath'
}
