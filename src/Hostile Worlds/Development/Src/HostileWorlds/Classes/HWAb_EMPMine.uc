// ============================================================================
// HWAb_EMPMine
// Ability that fires a HWProj_EMPMine.
//
// Author:  Marcel Koehler
// Date:    2011/04/28
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_EMPMine extends HWAbilityTargetingLocationAOE
	config(HostileWorldsAbilityData);

/** The flight speed of the mine, in UU/sec. */
var config float FlightSpeed;

/** The damage dealt when the mine explodes. */
var config float ExplosionDamage;

/** The time hit enemies are blinded. */
var config float BlindDuration;


function TriggerAbility()
{
	local HWProj_EMPMine Mine;

	super.TriggerAbility();

	Mine = Spawn(class'HWProj_EMPMine', OwningUnit,,OwningUnit.GetEffectLocation());		
	Mine.Initialize
		(OwningUnit,
		 FlightSpeed,
		 ExplosionDamage,
		 AbilityRadius,
		 TargetLocation,
		 BlindDuration);
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(default.ExplosionDamage, 2)));
	Result = Repl(Result, "%2", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(default.BlindDuration, 2)));

	return Result;
}


DefaultProperties
{
	AbilityIcon=Texture2D'UI_HWAbilities.T_UI_Ability_EMPMine_Test'
	AbilityIconColored=Texture2D'UI_HWAbilities.T_UI_Ability_EMPMineColored_Test'
}
