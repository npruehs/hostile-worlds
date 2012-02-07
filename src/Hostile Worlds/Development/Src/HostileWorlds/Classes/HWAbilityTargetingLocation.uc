// ============================================================================
// HWAbilityTargetingLocation
// An abstract ability of Hostile Worlds targeting a location.
//
// Author:  Nick Pruehs
// Date:    2010/10/25
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAbilityTargetingLocation extends HWAbility
	abstract;

/** The target location the player has chosen for this ability. */
var Vector TargetLocation;


function TriggerAbility()
{
	super.TriggerAbility();

	// Focus the location (needs some time and thus can be off...)
	// TODO Improve this by setting the rotation directly
	HWAIController(OwningUnit.Owner).SetFocalPoint(TargetLocation);
}

/** 
 *  Stub function for checking whether the specified target location is
 *  eligible for this ability. The location can be adjusted, if required.
 *  
 *  Returns false and sets ErrorMessage if not.
 *  
 *  @param LocationToCheck
 *      the location to check
 *  @param ErrorMessage
 *      the error message to set
 */
simulated function bool CheckTargetLocation(out Vector LocationToCheck, out string ErrorMessage)
{
	return true;
}

replication
{
	// Replicate if server
	if(Role == ROLE_Authority && (bNetInitial || bNetDirty))
		TargetLocation;
}

DefaultProperties
{
}
