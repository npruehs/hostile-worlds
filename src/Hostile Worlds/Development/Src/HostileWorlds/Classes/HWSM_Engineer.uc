// ============================================================================
// HWSM_Engineer
// An Engineer of Hostile Worlds.
//
// Author:  Nick Pruehs
// Date:    2011/03/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSM_Engineer extends HWSquadMember;

function AddAbilities()
{
	Abilities[0] = Spawn(class'HWAb_Recharge', self);
	Abilities[0].OwningUnit = self;

	Abilities[1] = Spawn(class'HWAb_AcquireArtifact', self);
	Abilities[1].OwningUnit = self;

	Abilities[2] = Spawn(class'HWAb_CallArtillery', self);
	Abilities[2].OwningUnit = self;

	Abilities[3] = Spawn(class'HWAb_EMPMine', self);
	Abilities[3].OwningUnit = self;

	AutoCastAbility = HWAbilityTargetingUnit(Abilities[0]);
}


DefaultProperties
{
	WeaponAttachmentClass = class'HWWA_Engineer';
	ProjectileClass = class'HWProj_Engineer';

	Race=class'HWRace_Humans'

	SoundSelected=SoundCue'A_Test_Voice_Units.EngineerSelected_Cue'
	SoundOrderConfirmed=SoundCue'A_Test_Voice_Units.EngineerOrderConfirmed_Cue'
	SoundDied=SoundCue'A_Test_Voice_Units.EngineerDied_Cue'

	UnitPortraitNotSelected=Texture2D'UI_HWPortraits.T_UI_Portrait_Engineer_Test'
	UnitPortrait=Texture2D'UI_HWPortraits.T_UI_Portrait_EngineerColored_Test'
	UnitPortraitSubmenu=Texture2D'UI_HWSubmenus.T_UI_Submenu_CallEngineer_Test'

	TeamMaterialNames(0)=M_commander
	TeamMaterialNames(1)=m_engineer

	// Workaround to show the pawn's visual assets
	Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		LightShadowMode=LightShadow_ModulateBetter
		ShadowFilterQuality=SFQ_High
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
		AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimTreeTemplate=AnimTree'CH_human_engineer.AT_CH_Human_Engineer'
		SkeletalMesh=SkeletalMesh'CH_human_engineer.ENGINEER'
	End Object

	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

	// Floating fix
	CollisionType=COLLIDE_BlockAll
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0048.000000
	End Object
	CylinderComponent=CollisionCylinder
}
