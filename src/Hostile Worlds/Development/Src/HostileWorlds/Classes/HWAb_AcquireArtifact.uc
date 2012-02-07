// ============================================================================
// HWAb_AcquireArtifact
// Ability that allows harvesting alien artifacts.
//
// Author:  Nick Pruehs
// Date:    2010/10/21
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_AcquireArtifact extends HWChanneledAbility;

/** Error message that is shown when tried to apply to a non-artifact unit. */
var localized string ErrorTargetNeedsToBeAnArtifact;

/** Error message that is shown when tried to apply to an artifact that is not available. */
var localized string ErrorArtifactNotAvailable;

/** The particle system emitter that shows the channeling effect. */
var ParticleSystemComponent BeamEmitter;

/** The particle system template for the channeling effect. */
var ParticleSystem BeamTemplate;

/** The color of the channeling effect. */
var Color BeamColor;


/** 
 *  Checks whether the specified target is an available artifact.
 *  Returns false and sets ErrorMessage if not.
 *  
 *  @param Target
 *      the target to check
 *  @param ErrorMessage
 *      the error message to set
 */
simulated function bool CheckTarget(HWSelectable Target, out string ErrorMessage)
{
	// check if the target is an artifact
	if (Target.IsA('HWArtifact'))
	{
		// check if its available
		if (HWArtifact(Target).bAvailable)
		{
			TargetUnit = Target;
			return true;
		}
		else
		{
			ErrorMessage = ErrorArtifactNotAvailable;
			return false;
		}
	}
	else
	{
		ErrorMessage = ErrorTargetNeedsToBeAnArtifact;
		return false;
	}
}

function bool TargetStillValid()
{
	return HWArtifact(TargetUnit).bAvailable;
}

/** 
 *  Starts the cooldown timer for this ability and acquires the artifact.
 */
function Finish()
{
	super.Finish();

	HWArtifact(TargetUnit).AcquiredBy(OwningUnit);
}

/** Shows a nice particle beam effect. */
simulated function ShowAbilityEffects()
{
	if (BeamEmitter == None)
	{
		BeamEmitter = new(Outer) class'UTParticleSystemComponent';
		BeamEmitter.SetDepthPriorityGroup(SDPG_Foreground);
		BeamEmitter.SetTemplate(BeamTemplate);
		BeamEmitter.SetTickGroup(TG_PostUpdateWork);
		BeamEmitter.bUpdateComponentInTick = true;
		BeamEmitter.SetColorParameter('Link_Beam_Color', BeamColor);
		OwningUnit.WeaponAttachment.Mesh.AttachComponent(BeamEmitter, 'b_gun_muzzleFlash');
	}

	BeamEmitter.SetVectorParameter('LinkBeamEnd',HWArtifact(TargetUnit).Location);
	BeamEmitter.ActivateSystem();
	BeamEmitter.SetHidden(false);
}

/** Hides the particle beam leading to the artifact. */
simulated function HideAbilityEffects()
{
	if (BeamEmitter != none)
	{
		BeamEmitter.SetHidden(true);
		BeamEmitter.DeactivateSystem();
	}
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(default.ChannelingDuration, 2)));

	return Result;
}

DefaultProperties
{
	bDoVisibilityCheck = false;

	BeamTemplate=ParticleSystem'FX_Abilities.P_Ability_AcquireArtifact_Test'
	BeamColor=(R=192,G=192,B=32,A=255)

	ChannelingSoundLoop=SoundCue'A_Sounds_Abilities.A_Ability_AcquireArtifactCue_Test'

	AbilityIcon=Texture2D'UI_HWAbilities.T_UI_Ability_AcquireArtifact_Test'
	AbilityIconColored=Texture2D'UI_HWAbilities.T_UI_Ability_AcquireArtifactColored_Test'
}
