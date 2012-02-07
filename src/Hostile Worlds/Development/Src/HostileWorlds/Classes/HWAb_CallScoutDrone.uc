// ============================================================================
// HWAb_CallScoutDrone
// Ability that allows calling a scout drone reinforcement unit.
//
// Author:  Marcel Koehler
// Date:    2011/04/15
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_CallScoutDrone extends HWAbilityTargetingLocationAOE;

/** The height the artillery will spawn at. */
const SPAWN_OFFSET_Z = 100;

/** The error message to show if the player chooses an invalid spawn location. */
var localized string ErrorScoutDroneCantLandHere;


simulated function bool CheckTargetLocation(out Vector LocationToCheck, out string ErrorMessage)
{
	local Actor a;
	local Vector SpawnLocation;
	local Vector CollisionBoxExtent;
	
	// compute the probable spawn location
	SpawnLocation.X = LocationToCheck.X;
	SpawnLocation.Y = LocationToCheck.Y;
	SpawnLocation.Z = LocationToCheck.Z + SPAWN_OFFSET_Z;

	// use the ability radius as collision check radius
	CollisionBoxExtent.X = AbilityRadius;
	CollisionBoxExtent.Y = AbilityRadius;

	// check SpawnLocation for collision with the world geometry
	if (FindSpot(CollisionBoxExtent, SpawnLocation))
	{
		// check for encroaching actors
		foreach CollidingActors(class'Actor', a, AbilityRadius, SpawnLocation)
		{
			ErrorMessage = ErrorScoutDroneCantLandHere;
			return false;
		}

		// return adjusted location
		LocationToCheck = SpawnLocation;
		return true;
	}

	ErrorMessage = ErrorScoutDroneCantLandHere;
	return false;
}

function TriggerAbility()
{
	local HWRe_ScoutDrone ScoutDrone;

	// try and spawn a new artillery
	ScoutDrone = Spawn(class'HWRe_ScoutDrone', OwningUnit.OwningPlayer,, TargetLocation);

	if (ScoutDrone != none)
	{
		ScoutDrone.Initialize(OwningUnit.Map, OwningUnit.OwningPlayer);
		
		// start cooldown timer only if spawn was successful
		super.TriggerAbility();
	}
	else
	{
		OwningUnit.OwningPlayer.ShowErrorMessage(ErrorScoutDroneCantLandHere);
	}
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(class'HWRe_ScoutDrone'.default.ReinforcementLifeTime, 2)));

	return Result;
}


DefaultProperties
{
	AbilityIcon=Texture2D'UI_HWAbilities.T_UI_Ability_CallScoutDrone_Test'
	AbilityIconColored=Texture2D'UI_HWAbilities.T_UI_Ability_CallScoutDroneColored_Test'
}
