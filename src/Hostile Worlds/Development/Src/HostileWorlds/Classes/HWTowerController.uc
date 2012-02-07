// ============================================================================
// HWTowerController
// The controller responsible for chaning the ownership of HWTowers.
//
// Author:  Nick Pruehs
// Date:    2011/01/07
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWTowerController extends AIController;

/** The tower controlled by this controller. */
var HWTower Tower;


event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	Tower = HWTower(inPawn);
}

event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	// HWTowers use noises heard within their AcquisitionRange to change teams

	local HWSquadMember SquadMember;

	SquadMember = HWSquadMember(NoiseMaker);

	// check team index
	if (SquadMember != none && SquadMember.TeamIndex != Tower.TeamIndex)
	{
		// change owner
		Tower.ChangeOwner(SquadMember.TeamIndex);

		// remember captured tower for score screen
		SquadMember.OwningPlayer.TotalTowersCaptured++;
	}
}

DefaultProperties
{
}
