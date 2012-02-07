// ============================================================================
// HWAb_EMPGrenade
// Ability that fires a HWProj_EMPGrenade.
//
// Author:  Marcel Koehler
// Date:    2011/04/08
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_EMPGrenade extends HWAbilityTargetingLocationAOE
	config(HostileWorldsAbilityData);

/** The speed of the grenade thrown, in UU/sec. */
var config float GrenadeSpeed;

/** The damage dealt when the grenade explodes. */
var config float GrenadeDamage;

/** How long any hit enemies shall be blinded. */
var config float BlindDuration;


function TriggerAbility()
{
	local HWProj_EMPGrenade Grenade;

	super.TriggerAbility();

	// fire grenade
	Grenade = Spawn(class'HWProj_EMPGrenade', OwningUnit,,OwningUnit.GetEffectLocation());		
	Grenade.Initialize
		(OwningUnit,
		 GrenadeSpeed,
		 GrenadeDamage,
		 AbilityRadius,
		 TargetLocation,
		 BlindDuration);
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static. HTMLMarkup(class'HWHud'.static.FloatToString(default.BlindDuration, 2)));

	return Result;
}


DefaultProperties
{
	AbilityIcon=Texture2D'UI_HWAbilities.T_UI_Ability_EMPGrenade_Test'
	AbilityIconColored=Texture2D'UI_HWAbilities.T_UI_Ability_EMPGrenadeColored_Test'
}
