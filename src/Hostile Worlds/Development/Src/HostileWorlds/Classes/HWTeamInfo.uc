// ============================================================================
// HWTeamInfo
// Provides a visibility mask for every team.
//
// Author:  Nick Pruehs
// Date:    2011/01/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWTeamInfo extends TeamInfo;

/** The visibility mask that tells where this team has vision. */
var HWVisibilityMask VisibilityMask;

/** The players belonging to this team. */
var HWPlayerController Players[4];


function bool AddToTeam(Controller Other)
{
	local bool bAdded;
	local int Slot;

	// check team size
	if (Size < 4)
	{
		// let the engine perform team change logic
		bAdded = super.AddToTeam(Other);

		if (bAdded)
		{
			// put player in first empty slot
			Slot = FindEmptySlot();
			Players[Slot] = HWPlayerController(Other);
		}
	}

	`log(Other$" has joined team "$TeamIndex);

	return bAdded;
}

function RemoveFromTeam(Controller Other)
{
	local int Slot;

	super.RemoveFromTeam(Other);

	Slot = GetPlayerSlot(HWPlayerController(Other));
	Players[Slot] = none;

	`log(Other$" has left team "$TeamIndex);
}

/** Returns the index of the first empty slot of this team. */
function int FindEmptySlot()
{
	local int i;

	for (i = 0; i < 4; i++)
	{
		if (Players[i] == none)
		{
			return i;
		}
	}

	return -1;
}

/**
 * Returns the index of the slot of the specified player within this team.
 * 
 * @param inPlayer
 *      the player to get the slot index of
 */
function int GetPlayerSlot(HWPlayerController inPlayer)
{
	local int i;

	for (i = 0; i < 4; i++)
	{
		if (Players[i] == inPlayer)
		{
			return i;
		}
	}

	return -1;
}


DefaultProperties
{
}
