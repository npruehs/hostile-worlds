// ============================================================================
// HWBu_Recharge
// Buff that indicates that the target squad member is having its shields
// restored.
//
// Author:  Nick Pruehs
// Date:    2011/03/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBu_Recharge extends HWBuff
	config(HostileWorldsAbilityData);

/** The number of shield points restored per second. */
var config float ShieldsPerSecond;

/** The number of shield points restored per recharge tick. */
var float ShieldsPerTick;


function ApplyBuffTo(HWPawn TargetUnit)
{
	super.ApplyBuffTo(TargetUnit);

	ShieldsPerTick = ShieldsPerSecond * BuffTickTime;
}

/** Restores a certain amount of shield points of the target. */
function TickBuff()
{
	local HWSquadMember SquadMember;

	SquadMember = HWSquadMember(Target);

	SquadMember.ShieldsCurrent = Min(SquadMember.ShieldsCurrent + ShieldsPerTick, SquadMember.ShieldsMax);

	if (SquadMember.ShieldsCurrent >= SquadMember.ShieldsMax)
	{
		WearOff();
	}
}

simulated function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(Description, "%1", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(ShieldsPerSecond, 2)));

	return Result;
}


DefaultProperties
{
	BuffIcon=Texture2D'UI_HWBuffs.T_UI_Buff_Recharge_Test'
}
