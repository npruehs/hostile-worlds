// ============================================================================
// HWBu_FocusFire
// Buff that increases the attack damage of the target.
//
// Author:  Marcel Koehler
// Date:    2011/04/14
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBu_FocusFire extends HWBuff
	config(HostileWorldsAbilityData);

/** The attack damage factor in percent (0 to 1). */
var config float AttackDamageFactor;

/** The amount of additional damage this used does while buffed. */
var float AttackDamageIncrement;

/** The overlay mesh that is attached to this squad member whenever it has this buff applied. */
var SkeletalMeshComponent BuffOverlayMesh;

/** The material to be shown whenever the this buff is applied. */
var MaterialInterface BuffMaterial;


function ApplyBuffTo(HWPawn TargetUnit)
{
	super.ApplyBuffTo(TargetUnit);

	AttackDamageIncrement = TargetUnit.AttackDamage * AttackDamageFactor;
	TargetUnit.AttackDamage += AttackDamageIncrement;

	ShowEffect();
}

function WearOff()
{
	super.WearOff();

	Target.AttackDamage -= AttackDamageIncrement;

	HideEffect();

	bForceNetUpdate = true;
}

simulated function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(Description, "%1", class'HWHud'.static.HTMLMarkup(int((1 - AttackDamageFactor) * 100)));

	return Result;
}

simulated function ShowEffect()
{
	local int i;

	bShowEffect = true;

	BuffOverlayMesh.SetSkeletalMesh(Target.Mesh.SkeletalMesh);
	BuffOverlayMesh.SetParentAnimComponent(Target.Mesh);

	for (i = 0; i < BuffOverlayMesh.SkeletalMesh.Materials.Length; i++)
	{
		BuffOverlayMesh.SetMaterial(i, BuffMaterial);
	}

	Target.AttachComponent(BuffOverlayMesh);
}

simulated function HideEffect()
{
	bShowEffect = false;

	Target.DetachComponent(BuffOverlayMesh);
}

DefaultProperties
{
	BuffMaterial=Material'FX_Abilities.M_Ability_FocusFire_Test'
	SoundOff=SoundCue'A_Sounds_Abilities.A_Ability_FocusFireOffCue_Test'

	BuffIcon=Texture2D'UI_HWBuffs.T_UI_Buff_FocusFire_Test'

	Begin Object Name=OverlayMeshComponent Class=SkeletalMeshComponent
		Scale=1.015
		bAcceptsDynamicDecals=FALSE
		CastShadow=false
		bOwnerNoSee=true
		bUpdateSkelWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=true
		TickGroup=TG_PostAsyncWork
		bAllowAmbientOcclusion=false
	End Object
	BuffOverlayMesh=OverlayMeshComponent
}
