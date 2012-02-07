// ============================================================================
// HWAb_CallArtillery
// Ability that allows calling an Artillery reinforcement unit.
//
// Author:  Nick Pruehs
// Date:    2011/03/14
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_CallArtillery extends HWAbilityTargetingLocationAOE;

/** The height the artillery will spawn at. */
const SPAWN_OFFSET_Z = 100;

/** The error message to show if the player chooses an invalid spawn location. */
var localized string ErrorArtilleryCantLandHere;


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
			ErrorMessage = ErrorArtilleryCantLandHere;
			return false;
		}

		// return adjusted location
		LocationToCheck = SpawnLocation;
		return true;
	}

	ErrorMessage = ErrorArtilleryCantLandHere;
	return false;
}

function TriggerAbility()
{
	local HWRe_Artillery Artillery;

	// try and spawn a new artillery
	Artillery = Spawn(class'HWRe_Artillery', OwningUnit.OwningPlayer,, TargetLocation);

	if (Artillery != none)
	{
		Artillery.Initialize(OwningUnit.Map, OwningUnit.OwningPlayer);
		
		// start cooldown timer only if spawn was successful
		super.TriggerAbility();
	}
	else
	{
		OwningUnit.OwningPlayer.ShowErrorMessage(ErrorArtilleryCantLandHere);
	}
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(class'HWRe_Artillery'.default.AmmoCount));

	return Result;
}


DefaultProperties
{
	AbilityIcon=Texture2D'UI_HWAbilities.T_UI_Ability_CallArtillery_Test'
	AbilityIconColored=Texture2D'UI_HWAbilities.T_UI_Ability_CallArtilleryColored_Test'
}
