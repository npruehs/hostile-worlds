// ============================================================================
// HWBu_Charge
// Buff that indicates that the target unit is charging an enemy.
//
// Author:  Nick Pruehs
// Date:    2011/02/16
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBu_Charge extends HWBuff
	config(HostileWorldsAbilityData);

/** The factor that is applied to the movement speed of charging units. */
var config float SpeedFactor;


function ApplyBuffTo(HWPawn TargetUnit)
{
	super.ApplyBuffTo(TargetUnit);

	TargetUnit.bImmuneToKnockbacks = true;

	// increase movement speed
	TargetUnit.MovementSpeedModifier *= SpeedFactor;
}

function WearOff()
{
	Target.bImmuneToKnockbacks = false;

	// restore movement speed
	Target.MovementSpeedModifier /= SpeedFactor;

	super.WearOff();
}

simulated function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(Description, "%1", class'HWHud'.static.HTMLMarkup(int((SpeedFactor - 1) * 100)));

	return Result;
}


DefaultProperties
{
	BuffIcon=Texture2D'UI_HWBuffs.T_UI_Buff_Charge_Test'
}
