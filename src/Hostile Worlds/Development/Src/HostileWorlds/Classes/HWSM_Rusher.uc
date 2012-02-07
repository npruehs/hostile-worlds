// ============================================================================
// HWSM_Rusher
// A rusher of Hostile Worlds.
//
// Author:  Nick Pruehs
// Date:    2010/10/13
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSM_Rusher extends HWSquadMember;

function AddAbilities()
{
	Abilities[0] = Spawn(class'HWAb_Charge', self);
	Abilities[0].OwningUnit = self;

	Abilities[1] = Spawn(class'HWAb_ConcussionGrenade', self);
	Abilities[1].OwningUnit = self;

	Abilities[2] = Spawn(class'HWAb_TargetEngines', self);
	Abilities[2].OwningUnit = self;
	
	Abilities[3] = Spawn(class'HWAb_FocusFire', self);
	Abilities[3].OwningUnit = self;
}


DefaultProperties
{
	WeaponAttachmentClass = class'HWWA_Rusher';
	ProjectileClass = class'HWProj_Rusher';

	Race=class'HWRace_Humans'

	SoundSelected=SoundCue'A_Test_Voice_Units.RusherSelected_Cue'
	SoundOrderConfirmed=SoundCue'A_Test_Voice_Units.RusherOrderConfirmed_Cue'
	SoundDied=SoundCue'A_Test_Voice_Units.RusherDied_Cue'

	UnitPortraitNotSelected=Texture2D'UI_HWPortraits.T_UI_Portrait_Rusher_Test'
	UnitPortrait=Texture2D'UI_HWPortraits.T_UI_Portrait_RusherColored_Test'
	UnitPortraitSubmenu=Texture2D'UI_HWSubmenus.T_UI_Submenu_CallRusher_Test'

	TeamMaterialNames(0)=M_Rusher

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
		SkeletalMesh=SkeletalMesh'CH_human_rusher.SM_human_rusher'
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
