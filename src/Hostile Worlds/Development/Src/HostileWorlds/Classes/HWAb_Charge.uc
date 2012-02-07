// ============================================================================
// HWAb_Charge
// Ability that allows charging an enemy, greatly increasing movement speed,
// becoming immune to knockback effects and knocking back the target.
//
// Author:  Nick Pruehs
// Date:    2011/02/16
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_Charge extends HWAbilityTargetingUnit;

/** The name of the animation to play when this ability is triggered. */
var name AnimNameStartUp;

/** The name of the animation to play while charging. */
var name AnimNameSprint;

/** The name of the animation to play when finished charging. */
var name AnimNameKick;

/** The momentum applied to the target unit upon knocking it back. */
var config float KnockbackMomentum;

/** The damage dealt upon knocking the target back. */
var config float KnockbackDamage;

/** The sound to play when the charging unit hits its target. */
var SoundCue SoundKnockback;

simulated function bool CheckPreconditions(out string ErrorMessage)
{
	return (super.CheckPreconditions(ErrorMessage) && CheckSnared(ErrorMessage));
}

simulated function bool CheckTarget(HWSelectable Target, out string ErrorMessage)
{
	return CheckTargetEnemyUnit(Target, ErrorMessage);
}

function TriggerAbility()
{
	local HWBuff Buff;

	super.TriggerAbility();

	// apply buff
	Buff = Spawn(class'HWBu_Charge', self);
	Buff.ApplyBuffTo(OwningUnit);

	// charge!
	HWAIController(OwningUnit.Controller).StartCharging();
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(int((class'HWBu_Charge'.default.SpeedFactor - 1) * 100)));

	return Result;
}


DefaultProperties
{
	SoundTriggered=SoundCue'A_Sounds_Abilities.A_Ability_ChargeCue_Test'
	SoundKnockback=SoundCue'A_Sounds_Abilities.A_Ability_ConcussionGrenadeExplosionCue_Test'

	AnimNameStartUp = anlauf
	AnimNameSprint = sprint
	AnimNameKick = kicknomove

	AbilityIcon=Texture2D'UI_HWAbilities.T_UI_Ability_Charge_Test'
	AbilityIconColored=Texture2D'UI_HWAbilities.T_UI_Ability_ChargeColored_Test'
}
