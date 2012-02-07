// ============================================================================
// HWAb_FocusFire
// Ability that causes a FocusFire buff to be applied to all own units
// in a radius around the triggering unit.
//
// Author:  Marcel Koehler
// Date:    2011/04/14
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_FocusFire extends HWAbilityTargetingLocationAOE;

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
			Buff = Spawn(class'HWBu_FocusFire', self);
			Buff.ApplyBuffTo(sm);
		}
	}

	// since the unit triggering this ability isn't included in the overlap check, 
	// extra apply the buff here	
	Buff = Spawn(class'HWBu_FocusFire', self);
	Buff.ApplyBuffTo(OwningUnit);
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(int((1 - class'HWBu_FocusFire'.default.AttackDamageFactor) * 100)));
	Result = Repl(Result, "%2", class'HWHud'.static. HTMLMarkup(class'HWHud'.static.FloatToString(class'HWBu_FocusFire'.default.Duration, 2)));

	return Result;
}


DefaultProperties
{
	SoundTriggered=SoundCue'A_Sounds_Abilities.A_Ability_FocusFireOnCue_Test'

	AbilityIcon=Texture2D'UI_HWAbilities.T_UI_Ability_FocusFire_Test'
	AbilityIconColored=Texture2D'UI_HWAbilities.T_UI_Ability_FocusFireColored_Test'
}