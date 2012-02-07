// ============================================================================
// HWChanneledAbility
// An abstract channeled ability of Hostile Worlds that can be interrupted.
//
// Author:  Nick Pruehs
// Date:    2010/10/25
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWChanneledAbility extends HWAbilityTargetingUnit
	abstract;

/** The channeling duration of this ability, in seconds. 0 = until cancelled. */
var config float ChannelingDuration;

/** Whether this ability is currently being channeled, or not. */
var repnotify bool bChanneling;

/** The sound to be played while channeling this ability. */
var SoundCue ChannelingSoundLoop;


/** Triggers this ability, not starting its cooldown timer. */
function TriggerAbility()
{
	super.TriggerAbility();

	// cooldown of channeled abilities start as soon as channeling finishes
	ClearTimer('Ready');

	bChanneling = true;
	SetTimer(ChannelingDuration, false, 'Finish');

	// start playing the channeling sound
	OwningUnit.PlayChannelingSoundLoop(ChannelingSoundLoop);

	ShowAbilityEffects();

	`log("Ability "$self$" started channeling.");
}

/** Interrupts this channeled ability, starting its cooldown timer. */
function Interrupt()
{
	`log("Ability "$self$" has been interrupted!");

	ClearTimer('Finish');

	WrapUp();
}

/** Finishes this channeled ability, starting its cooldown timer. */
function Finish()
{
	`log("Ability "$self$" has finished channeling.");

	WrapUp();
}

/** 
 *  Notifies the channeling unit's controller that the unit finished channeling,
 *  and starts the cooldown timer of this ability.
 */
function WrapUp()
{
	HWAIController(OwningUnit.Controller).StopChanneling();

	// stop playing the channeling sound
	OwningUnit.PlayChannelingSoundLoop(none);

	bChanneling = false;
	StartCooldownTimer();

	HideAbilityEffects();
}

/** Allows showing client-side effects. */
simulated function ShowAbilityEffects();

/** Allows hiding client-side effects. */
simulated function HideAbilityEffects();

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bChanneling')
	{
		if (bChanneling)
		{
			ShowAbilityEffects();
		}
		else
		{
			HideAbilityEffects();
		}
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

replication
{
	// replicate if server
	if (Role == ROLE_Authority && (bNetInitial || bNetDirty))
		bChanneling;
}

DefaultProperties
{
}
