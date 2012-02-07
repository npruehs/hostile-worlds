// ============================================================================
// HWAbilityTargetingUnit
// An abstract ability of Hostile Worlds targeting a unit.
//
// Author:  Nick Pruehs
// Date:    2010/10/25
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAbilityTargetingUnit extends HWAbility
	abstract;

/** The target unit the player has chosen for this ability. */
var HWSelectable TargetUnit;

/** Whether this ability requires a visibility check if issued on a target unit. */
var bool bDoVisibilityCheck;

/** Error message that is shown when tried to target a friendly unit. */
var localized string ErrorMustTargetAnEnemyUnit;

/** Error message that is shown when tried to target an enemy unit. */
var localized string ErrorMustTargetAnAlliedUnit;

/** Error message that is shown when tried to apply to a non-squad member unit. */
var localized string ErrorTargetNeedsToBeASquadMember;


/** 
 *  Stub function for checking whether the specified target is eligible
 *  for this ability. Returns false and sets ErrorMessage if not.
 *  
 *  @param Target
 *      the target to check
 *  @param ErrorMessage
 *      the error message to set
 */
simulated function bool CheckTarget(HWSelectable Target, out string ErrorMessage);

/** 
 * Checks whether the specified target is an enemy unit.
 * Returns false and sets ErrorMessage if not.
 *  
 *  @param Target
 *      the target to check
 *  @param ErrorMessage
 *      the error message to set
 */
simulated function bool CheckTargetEnemyUnit(HWSelectable Target, out string ErrorMessage)
{
	if (Target.IsA('HWPawn') && HWPawn(Target).TeamIndex != OwningUnit.TeamIndex)
	{
		TargetUnit = Target;
		return true;
	}
	else
	{
		ErrorMessage = ErrorMustTargetAnEnemyUnit;
		return false;
	}
}

/** 
 * Checks whether the specified target is an allied unit.
 * Returns false and sets ErrorMessage if not.
 *  
 *  @param Target
 *      the target to check
 *  @param ErrorMessage
 *      the error message to set
 */
simulated function bool CheckTargetAlliedUnit(HWSelectable Target, out string ErrorMessage)
{
	if (Target.IsA('HWPawn') && HWPawn(Target).TeamIndex == OwningUnit.TeamIndex)
	{
		TargetUnit = Target;
		return true;
	}
	else
	{
		ErrorMessage = ErrorMustTargetAnAlliedUnit;
		return false;
	}
}

/** 
 *  Checks whether the target of this ability is still valid (e.g. alive, available).
 *  The default implementation returns false if the target is a cloaked HWPawn.
 */
function bool TargetStillValid()
{
	return  HWPawn(TargetUnit) != none 
			&& TargetUnit.Health > 0
			&& !HWPawn(TargetUnit).bCloaked
			// if the ability was triggered check if the TargetUnit is still in range
			&& (!bTriggered || class'HWAIController'.static.CheckDistance2D(OwningUnit.Location, TargetUnit.Location, Range));
}

replication
{
	// replicate if server
	if (Role == ROLE_Authority && (bNetInitial || bNetDirty))
		TargetUnit;
}

DefaultProperties
{
	bDoVisibilityCheck = true;
}
