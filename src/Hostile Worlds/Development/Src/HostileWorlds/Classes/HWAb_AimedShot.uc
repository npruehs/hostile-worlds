// ============================================================================
// HWAb_AimedShot
// Ability that shoots an AimedShot projectile on the target.
//
// Author:  Marcel Koehler
// Date:    2011/04/08
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_AimedShot extends HWAbilityTargetingUnit;

/** The damage dealt by the AimedShot projectile. */
var config int AimedShotDamage;

simulated function bool CheckTarget(HWSelectable Target, out string ErrorMessage)
{
	return CheckTargetEnemyUnit(Target, ErrorMessage);
}

function TriggerAbility()
{
	local HWProj_AimedShot AbProj;

	super.TriggerAbility();

	AbProj = Spawn(class'HWProj_AimedShot', self,, OwningUnit.GetEffectLocation());
	AbProj.InitProjectile(OwningUnit, HWPawn(TargetUnit));
	AbProj.Damage = AimedShotDamage;
	AbProj.bKnocksTargetBack = true;
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(default.AimedShotDamage));

	return Result;
}


DefaultProperties
{
	AbilityIcon=Texture2D'UI_HWAbilities.T_UI_Ability_AimedShot_Test'
	AbilityIconColored=Texture2D'UI_HWAbilities.T_UI_Ability_AimedShotColored_Test'
}
