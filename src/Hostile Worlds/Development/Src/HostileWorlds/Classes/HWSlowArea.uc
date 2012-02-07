// ============================================================================
// HWSlowArea
// Terrain that slows units down that pass it.
//
// Author:  Nick Pruehs
// Date:    2011/02/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSlowArea extends PhysicsVolume;


event PawnEnteredVolume(Pawn Other)
{
	local HWPawn Unit;
	local HWBu_SlowArea Buff;

	Unit = HWPawn(Other);

	if (Unit != none)
	{
		`log(Unit$" entered "$self);

		// apply buff
		Buff = Spawn(class'HWBu_SlowArea');
		Buff.ApplyBuffTo(Unit);
	}
}

event PawnLeavingVolume(Pawn Other)
{
	local HWPawn Unit;

	Unit = HWPawn(Other);

	if (Unit != none)
	{
		`log(Unit$" left "$self);

		// remove buff
		Unit.RemoveBuffByClass(class'HWBu_SlowArea');
	}
}


DefaultProperties
{
}
