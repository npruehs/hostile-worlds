// ============================================================================
// HWRe_Artillery
// An Artillery reinforcements unit of Hostile Worlds.
//
// Author:  Nick Pruehs
// Date:    2011/03/14
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWRe_Artillery extends HWReinforcement;

/** The controller modifying the rotation of this artillery's turret. */
var SkelControlSingleBone SkelControlArtillery;

/** The name of the controller modifying the rotation of this artillery's turret. */
var name SkelControlArtilleryName;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);

	if (SkelComp == Mesh)
	{
		SkelControlArtillery = SkelControlSingleBone(Mesh.FindSkelControl(SkelControlArtilleryName));
	}
}

function Attack(HWPawn Target)
{
	local Rotator Rot;

	// rotate turret towards target
	Rot = Rotator(Target.Location - Location);
	SkelControlArtillery.BoneRotation.Yaw = Rot.Yaw;

	// fire projectile
	super.Attack(Target);
}

simulated event Destroyed()
{
	super.Destroyed();

	SkelControlArtillery = none;
}


DefaultProperties
{
	bImmuneToKnockbacks=true

	ProjectileClass = class'HWProj_Artillery';

	SoundSelected=SoundCue'A_Test_Voice_Units.ArtillerySelected_Cue'
	SoundOrderConfirmed=SoundCue'A_Test_Voice_Units.ArtilleryOrderConfirmed_Cue'
	SoundDied=SoundCue'A_Test_Voice_Units.ArtilleryDied_Cue'

	UnitPortrait=Texture2D'UI_HWPortraits.T_UI_Portrait_Artillery_Test'

	TeamMaterialNames(0)=m_arti

	bShouldFocusTarget=false

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
		SkeletalMesh=SkeletalMesh'Artillery.sm_arti'
		AnimTreeTemplate=AnimTree'Artillery.AT_VH_Artillery'
	End Object

	SkelControlArtilleryName=SkelControlArtillery

	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

	DrawScale=.5f

	// Floating fix
	CollisionType=COLLIDE_BlockAll
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0050.000000
		CollisionHeight=+0048.000000
	End Object
	CylinderComponent=CollisionCylinder

	bPlayGibSounds=false
}
