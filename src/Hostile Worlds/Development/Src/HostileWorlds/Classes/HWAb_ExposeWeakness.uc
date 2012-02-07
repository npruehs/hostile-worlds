// ============================================================================
// HWAb_ExposeWeakness
// Ability that applies an ExposeWeakness buff on the target.
//
// Author:  Marcel Koehler, Nick Pruehs
// Date:    2011/04/10
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_ExposeWeakness extends HWChanneledAbility;

/** The particle system emitter that shows the channeling effect. */
var ParticleSystemComponent BeamEmitter;

/** The particle system emitter that shows the beam target effect. */
var ParticleSystemComponent BeamTargetEffects;

/** The particle system template for the channeling effect. */
var ParticleSystem BeamTemplate;

/** The particle system template for the beam target effect. */
var ParticleSystem BeamTargetEffectsTemplate;


/** The color of the channeling effect. */
var Color BeamColor;

var Vector RelativeLocationBeamToMuzzle;

simulated function bool CheckTarget(HWSelectable Target, out string ErrorMessage)
{
	return CheckTargetEnemyUnit(Target, ErrorMessage);
}

function TriggerAbility()
{
	local HWBuff Buff;

	super.TriggerAbility();

	// apply buff
	Buff = Spawn(class'HWBu_ExposeWeakness', self);
	Buff.ApplyBuffTo(HWPawn(TargetUnit));
}

function WrapUp()
{
	super.WrapUp();

	if(TargetUnit != none)
	{
		HWPawn(TargetUnit).RemoveBuffByClass(class'HWBu_ExposeWeakness');
	}
}

/** Shows a nice particle beam effect. */
simulated function ShowAbilityEffects()
{
	// show beam
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

	BeamEmitter.SetVectorParameter('LinkBeamEnd', TargetUnit.Location);
	BeamEmitter.ActivateSystem();
	BeamEmitter.SetHidden(false);

	// show beam target effects
	if (BeamTargetEffectsTemplate != None)
	{
		BeamTargetEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(BeamTargetEffectsTemplate);
		BeamTargetEffects.SetAbsolute(false, false, false);
		BeamTargetEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		BeamTargetEffects.OnSystemFinished = MyOnParticleSystemFinished;
		BeamTargetEffects.bUpdateComponentInTick = true;
		TargetUnit.AttachComponent(BeamTargetEffects);
	}
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (bChanneling)
	{
		BeamEmitter.SetVectorParameter('LinkBeamEnd', TargetUnit.Location);
	}	
}

/** Hides the particle beam leading to the target squad member. */
simulated function HideAbilityEffects()
{
	if (BeamEmitter != none)
	{
		BeamEmitter.SetHidden(true);
		BeamEmitter.DeactivateSystem();
	}

	if (BeamTargetEffects != none)
	{
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(BeamTargetEffects);
	}
}

/**
 * Called as soon as a beam target particle effect has finished. Detaches the
 * particle effect component and returns it to the pool.
 */
simulated function MyOnParticleSystemFinished(ParticleSystemComponent PSC)
{
	if (PSC == BeamTargetEffects)
	{
		// clear component and return to pool
		TargetUnit.DetachComponent(BeamTargetEffects);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(BeamTargetEffects);
		BeamTargetEffects = none;
	}
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(int((class'HWBu_ExposeWeakness'.default.ArmorReductionFactor - 1) * 100)));

	return Result;
}


DefaultProperties
{
	BeamTemplate=ParticleSystem'FX_Abilities.P_Ability_ExposeWeakness_Test'
	BeamColor=(R=255,G=64,B=64,A=255)

	BeamTargetEffectsTemplate=ParticleSystem'FX_Abilities.P_Ability_ExposeWeakness_TargetEffect'

	ChannelingSoundLoop=SoundCue'A_Sounds_Abilities.A_Ability_ExposeWeaknessCue_Test'

	AbilityIcon=Texture2D'UI_HWAbilities.T_UI_Ability_ExposeWeakness_Test'
	AbilityIconColored=Texture2D'UI_HWAbilities.T_UI_Ability_ExposeWeaknessColored_Test'
}
