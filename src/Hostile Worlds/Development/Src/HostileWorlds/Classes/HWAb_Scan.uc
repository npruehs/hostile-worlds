// ============================================================================
// HWAb_Scan
// Ability that allows to call an air strike onto a target location.
//
// Author:  Marcel Koehler
// Date:    2011/04/20
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_Scan extends HWAbilityTargetingLocationAOE;

/** The error message to show if the player chooses an invalid spawn location. */
var localized string ErrorScannerCantLandHere;


function TriggerAbility()
{
	local HWRe_Scanner Scanner;

	Scanner = Spawn(class'HWRe_Scanner', self, , TargetLocation);

	if (Scanner != none)
	{
		Scanner.Initialize(OwningUnit.Map, OwningUnit.OwningPlayer);
		
		// start cooldown timer only if spawn was successful
		super.TriggerAbility();
	}
	else
	{
		OwningUnit.OwningPlayer.ShowErrorMessage(ErrorScannerCantLandHere);
	}	
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(class'HWRe_Scanner'.default.ReinforcementLifeTime, 2)));

	return Result;
}


DefaultProperties
{
	AbilityIconSubmenu=Texture2D'UI_HWSubmenus.T_UI_Submenu_Scan_Test'

	SoundTriggered=SoundCue'A_Sounds_Abilities.A_Ability_ScanCue_Test'

	bShowAbilityRadius=false
}
