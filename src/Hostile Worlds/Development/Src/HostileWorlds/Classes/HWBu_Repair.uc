// ============================================================================
// HWBu_Repair
// Buff that indicates that the target unit is being repaired.
//
// Author:  Nick Pruehs
// Date:    2011/03/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBu_Repair extends HWBuff
	config(HostileWorldsAbilityData);

/** The number of structure points restored per second. */
var config float StructurePerSecond;

/** The number of structure points restored per repair tick. */
var float StructurePerTick;


function ApplyBuffTo(HWPawn TargetUnit)
{
	super.ApplyBuffTo(TargetUnit);

	StructurePerTick = StructurePerSecond * BuffTickTime;
}

/** Restores a certain amount of structure points of the target. */
function TickBuff()
{
	Target.HealDamage(StructurePerTick, HWAb_Repair(Owner).OwningUnit.OwningPlayer, class'DamageType');

	if (Target.Health >= Target.HealthMax)
	{
		WearOff();
	}
}

simulated function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(Description, "%1", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(StructurePerSecond, 2)));

	return Result;
}


DefaultProperties
{
	BuffIcon=Texture2D'UI_HWBuffs.T_UI_Buff_Repair_Test'
}
