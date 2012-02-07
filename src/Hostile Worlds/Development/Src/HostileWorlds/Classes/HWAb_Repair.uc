// ============================================================================
// HWAb_Repair
// Ability that allows repairing damaged squad members.
//
// Author:  Nick Pruehs
// Date:    2011/03/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_Repair extends HWChanneledAbility;

/** Error message that is shown when tried to apply to a squad member that is not damaged. */
var localized string ErrorSquadMemberNotDamaged;

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


/** 
 *  Checks whether the specified target is a damaged squad member.
 *  Returns false and sets ErrorMessage if not.
 *  
 *  @param Target
 *      the target to check
 *  @param ErrorMessage
 *      the error message to set
 */
simulated function bool CheckTarget(HWSelectable Target, out string ErrorMessage)
{
	// check if the target is a squad member
	if (Target.IsA('HWSquadMember'))
	{
		// check if its damaged
		if (Target.Health < Target.HealthMax)
		{
			return CheckTargetAlliedUnit(Target, ErrorMessage);
		}
		else
		{
			ErrorMessage = ErrorSquadMemberNotDamaged;
			return false;
		}
	}
	else
	{
		ErrorMessage = ErrorTargetNeedsToBeASquadMember;
		return false;
	}
}

function TriggerAbility()
{
	local HWBuff Buff;

	super.TriggerAbility();

	// apply buff
	Buff = Spawn(class'HWBu_Repair', self);
	Buff.ApplyBuffTo(HWPawn(TargetUnit));
}

function bool TargetStillValid()
{
	return super.TargetStillValid() && TargetUnit.Health < TargetUnit.HealthMax;
}

function WrapUp()
{
	super.WrapUp();

	if(TargetUnit != none)
	{
		HWPawn(TargetUnit).RemoveBuffByClass(class'HWBu_Repair');
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

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(class'HWBu_Repair'.default.StructurePerSecond, 2)));

	return Result;
}


DefaultProperties
{
	BeamTemplate=ParticleSystem'FX_Abilities.P_Ability_Repair_Test'
	BeamColor=(R=128,G=220,B=120,A=255)

	BeamTargetEffectsTemplate=ParticleSystem'FX_Abilities.P_Ability_Repair_TargetEffect'

	ChannelingSoundLoop=SoundCue'A_Sounds_Abilities.A_Ability_RepairCue_Test'
}
