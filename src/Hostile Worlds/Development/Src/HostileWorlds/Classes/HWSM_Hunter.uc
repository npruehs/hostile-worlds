// ============================================================================
// HWSM_Hunter
// A hunter of Hostile Worlds.
//
// Author:  Nick Pruehs, Marcel Köhler
// Date:    2011/04/07
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSM_Hunter extends HWSquadMember;

function AddAbilities()
{
	Abilities[0] = Spawn(class'HWAb_AimedShot', self);
	Abilities[0].OwningUnit = self;

	Abilities[1] = Spawn(class'HWAb_EMPGrenade', self);
	Abilities[1].OwningUnit = self;

	Abilities[2] = Spawn(class'HWAb_ExposeWeakness', self);
	Abilities[2].OwningUnit = self;

	Abilities[3] = Spawn(class'HWAb_CallScoutDrone', self);
	Abilities[3].OwningUnit = self;
}


DefaultProperties
{
	WeaponAttachmentClass = class'HWWA_Hunter';
	ProjectileClass = class'HWProj_Hunter';

	Race=class'HWRace_Humans'

	SoundSelected=SoundCue'A_Test_Voice_Units.HunterSelected_Cue'
	SoundOrderConfirmed=SoundCue'A_Test_Voice_Units.HunterOrderConfirmed_Cue'
	SoundDied=SoundCue'A_Test_Voice_Units.HunterDied_Cue'

	UnitPortraitNotSelected=Texture2D'UI_HWPortraits.T_UI_Portrait_Hunter_Test'
	UnitPortrait=Texture2D'UI_HWPortraits.T_UI_Portrait_HunterColored_Test'
	UnitPortraitSubmenu=Texture2D'UI_HWSubmenus.T_UI_Submenu_CallHunter_Test'

	TeamMaterialNames(0)=m_hunter
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
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		SkeletalMesh=SkeletalMesh'CH_human_hunter.hunter'
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
