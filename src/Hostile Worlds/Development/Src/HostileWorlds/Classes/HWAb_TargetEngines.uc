// ============================================================================
// HWAb_TargetEngines
// Ability that allows snaring an enemy, rendering him unable to move.
//
// Author:  Nick Pruehs
// Date:    2011/03/14
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_TargetEngines extends HWAbilityTargetingUnit;

simulated function bool CheckTarget(HWSelectable Target, out string ErrorMessage)
{
	return CheckTargetEnemyUnit(Target, ErrorMessage);
}

function TriggerAbility()
{
	local HWProj_TargetEngines AbProj;

	super.TriggerAbility();

	// fire a projectile that snares upon impact
	AbProj = Spawn(class'HWProj_TargetEngines', self,, OwningUnit.GetEffectLocation());
	AbProj.InitProjectile(OwningUnit, HWPawn(TargetUnit));
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(class'HWBu_TargetEngines'.default.Duration, 2)));

	return Result;
}


DefaultProperties
{
	AbilityIcon=Texture2D'UI_HWAbilities.T_UI_Ability_TargetEngines_Test'
	AbilityIconColored=Texture2D'UI_HWAbilities.T_UI_Ability_TargetEnginesColored_Test'
}
