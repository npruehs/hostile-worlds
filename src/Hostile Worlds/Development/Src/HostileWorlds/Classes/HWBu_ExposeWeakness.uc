// ============================================================================
// HWBu_ExposeWeakness
// Buff that reduces the armor of the target.
//
// Author:  Marcel Koehler
// Date:    2011/04/10
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBu_ExposeWeakness extends HWBuff
	config(HostileWorldsAbilityData);

/** The armor reduction in percent (0 to 1). */
var config float ArmorReductionFactor;


function ApplyBuffTo(HWPawn TargetUnit)
{
	super.ApplyBuffTo(TargetUnit);

	// reduce armor
	TargetUnit.Armor *= ArmorReductionFactor;
}

function WearOff()
{
	super.WearOff();

	// restore armor
	Target.Armor /= ArmorReductionFactor;
}

simulated function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(Description, "%1", class'HWHud'.static.HTMLMarkup(int((ArmorReductionFactor - 1) * 100)));

	return Result;
}


DefaultProperties
{
	BuffIcon=Texture2D'UI_HWBuffs.T_UI_Buff_ExposeWeakness_Test'
}
