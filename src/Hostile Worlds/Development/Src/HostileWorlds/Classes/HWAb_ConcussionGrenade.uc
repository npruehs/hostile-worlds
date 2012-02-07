// ============================================================================
// HWAb_ConcussionGrenade
// Ability that allows firing a grenade that waits a limited amount of time
// before detonating, and deals area of effect damage then.
//
// Author:  Nick Pruehs
// Date:    2011/02/17
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_ConcussionGrenade extends HWAbilityTargetingLocationAOE;

/** The speed of the grenade thrown, in UU/sec. */
var config float GrenadeSpeed;

/** The damage dealt when the grenade explodes. */
var config float GrenadeDamage;

/** The time the grenade lies on the ground before it explodes, in seconds. */
var config float TimeBeforeDetonation;


function TriggerAbility()
{
	local HWProj_ConcussionGrenade Grenade;

	super.TriggerAbility();

	// fire grenade
	Grenade = Spawn(class'HWProj_ConcussionGrenade', OwningUnit,,OwningUnit.GetEffectLocation());		
	Grenade.Initialize
		(OwningUnit,
		 GrenadeSpeed,
		 GrenadeDamage,
		 AbilityRadius,
		 TargetLocation, 
		 TimeBeforeDetonation);
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(default.TimeBeforeDetonation, 2)));
	Result = Repl(Result, "%2", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(default.GrenadeDamage, 2)));

	return Result;
}


DefaultProperties
{
	AbilityIcon=Texture2D'UI_HWAbilities.T_UI_Ability_ConcussionGrenade_Test'
	AbilityIconColored=Texture2D'UI_HWAbilities.T_UI_Ability_ConcussionGrenadeColored_Test'
}
