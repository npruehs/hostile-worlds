// ============================================================================
// HWDamageArea
// Terrain that periodically deals damage to units that pass it.
//
// Author:  Nick Pruehs
// Date:    2011/02/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWDamageArea extends PhysicsVolume
	config(HostileWorlds);

/** The damage per second this terrain deals to units passing it. */
var config float DamagePerSecond;


simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	DamagePerSec = DamagePerSecond;
}

event PawnEnteredVolume(Pawn Other)
{
	local HWPawn Unit;
	local HWBu_DamageArea Buff;

	Unit = HWPawn(Other);

	if (Unit != none)
	{
		`log(Unit$" entered "$self);

		Buff = Spawn(class'HWBu_DamageArea');
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

		Unit.RemoveBuffByClass(class'HWBu_DamageArea');
	}
}


DefaultProperties
{
	bPainCausing=true
	bEntryPain=false

	DamageType=class'HWDT_DamageArea'
}
