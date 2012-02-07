// ============================================================================
// HWCommander
// A commander of Hostile Worlds.
//
// Author:  Nick Pruehs
// Date:    2011/04/27
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWCommander extends HWSquadMember;

/** The time a commander has to be dead before he can be resurrected, in seconds. */
const RESURRECTION_TIME = 15;


function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local bool DyingAllowed;

	DyingAllowed = super.Died(Killer, DamageType, HitLocation);

	if (DyingAllowed)
	{
		OwningPlayer.NotifyCommanderDied();
	}

	return DyingAllowed;
}


DefaultProperties
{
}
