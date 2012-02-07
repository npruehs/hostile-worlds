// ============================================================================
// HWSM_Commander
// A Human commander of Hostile Worlds.
//
// Author:  Nick Pruehs
// Date:    2010/10/13
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSM_Commander extends HWCommander;

function AddAbilities()
{
	// tactical abilities need to be the first ones among all Commander abilities
	Abilities[0] = Spawn(Race.default.TacticalAbilities[0], self);
	Abilities[0].bLearned = true;
	Abilities[0].OwningUnit = self;

	Abilities[1] = Spawn(Race.default.TacticalAbilities[1], self);
	Abilities[1].bLearned = true;
	Abilities[1].OwningUnit = self;
	
	Abilities[2] = Spawn(Race.default.TacticalAbilities[2], self);
	Abilities[2].bLearned = true;
	Abilities[2].OwningUnit = self;

	Abilities[3] = Spawn(class'HWAb_AcquireArtifact', self);
	Abilities[3].bLearned = true;
	Abilities[3].OwningUnit = self;

	Abilities[4] = Spawn(class'HWAb_Repair', self);
	Abilities[4].bLearned = true;
	Abilities[4].OwningUnit = self;

	AutoCastAbility = HWAbilityTargetingUnit(Abilities[4]);
}


DefaultProperties
{
	WeaponAttachmentClass = class'HWWA_Commander';
	ProjectileClass = class'HWProj_Commander';

	Race=class'HWRace_Humans'

	SoundSelected=SoundCue'A_Test_Voice_Units.CommanderSelected_Cue'
	SoundOrderConfirmed=SoundCue'A_Test_Voice_Units.CommanderOrderConfirmed_Cue'
	SoundDied=SoundCue'A_Test_Voice_Units.CommanderDied_Cue'

	UnitPortrait=Texture2D'UI_HWPortraits.T_UI_Portrait_Commander_Test'

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
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		SkeletalMesh=SkeletalMesh'CH_human_commander.Commander'
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
