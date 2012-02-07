// ============================================================================
// HWAb_Cloak
// Ability that causes a cloak buff to be applied to all own units
// in a radius around the commander.
//
// Author:  Marcel Koehler
// Date:    2011/04/01
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_Cloak extends HWAbilityTargetingLocationAOE;

function TriggerAbility()
{
	local HWBuff Buff;
	local HWSquadMember sm;

	super.TriggerAbility();

	// find all own squadmembers in the radius around the target location
	foreach OverlappingActors(class'HWSquadMember', sm, AbilityRadius, TargetLocation)
	{
		// apply the cloak buff if in the same team
		if(sm.TeamIndex == OwningUnit.TeamIndex)
		{
			Buff = Spawn(class'HWBu_Cloak', self);
			Buff.ApplyBuffTo(sm);
		}
	}

	// since the unit triggering this ability isn't included in the overlap check, 
	// extra apply the buff here
	Buff = Spawn(class'HWBu_Cloak', self);
	Buff.ApplyBuffTo(OwningUnit);
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(class'HWBu_Cloak'.default.Duration, 2)));
	Result = Repl(Result, "%2", class'HWHud'.static.HTMLMarkup(int((class'HWBu_Cloak'.default.SpeedFactor - 1) * 100)));
	Result = Repl(Result, "%3", class'HWHud'.static.HTMLMarkup(class'HWBu_Cloak'.default.AbilityCooldown));

	return Result;
}


DefaultProperties
{
	AbilityIconSubmenu=Texture2D'UI_HWSubmenus.T_UI_Submenu_Cloak_Test'

	SoundTriggered=SoundCue'A_Sounds_Abilities.A_Ability_CloakOnCue_Test'
}
