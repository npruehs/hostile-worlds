// ============================================================================
// HWAbility
// An abstract ability of Hostile Worlds. Provides stub functions for checking
// targets for eligibility, and contains all required cooldown logic.
//
// Author:  Nick Pruehs
// Date:    2010/10/21
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAbility extends Actor
	config(HostileWorldsAbilityData)
	abstract;

/** The name of this ability. */
var localized string AbilityName;

/** The description of this ability. */
var localized string Description;

/** The minimum time between two uses of this ability, in seconds. */
var config float Cooldown;

/** The range of this ability, in UU. */
var config float Range;

/** The number of shards required for using this ability. */
var config int ShardsRequired;

/** Whether this ability is ready or on cooldown. */
var bool bReady;

/** Whether this ability has already been unlocked, or not. */
var bool bLearned;

/** Whether the owning unit is currently on its way to trigger this ability. */
var bool bBeingActivated;

/** The unit this ability belongs to. */
var HWSquadMember OwningUnit;

/** The error message to show when the player tries to use an ability that is still on cooldown. */
var localized string ErrorAbilityNotReadyYet;

/** Error message that is shown when tried to trigger an ability while being snared that can't be triggered while being snared. */
var localized string ErrorCantDoThatWhileSnared;

/** The message to show when the player tries to trigger abilities for silenced units. */
var localized string ErrorCantDoThatWhileSilenced;

/** The sound to play whenever this ability is triggered. */
var SoundCue SoundTriggered;

/** Whether this ability was triggered or not. Used to call OnAbilityTriggered on clients if replicated. */
var repnotify bool bTriggered;

/** Whether to show the ability radius or not. */
var bool bShowAbilityRadius;

/** The icon of this ability to be shown in the UI, as long as this ability has not been learned. */
var Texture2D AbilityIcon;

/** The icon of this ability to be shown in the UI, as soon as this ability has been learned. */
var Texture2D AbilityIconColored;

/** The icon of this ability to be shown in the Tactical Abilities submenu of the UI. */
var Texture2D AbilityIconSubmenu;


/**
 * Stub function for checking whether this ability may be triggered
 * right now. Returns false and sets ErrorMessage if not.
 * 
 * @param ErrorMessage
 *      the error message to set
 */
simulated function bool CheckPreconditions(out string ErrorMessage)
{
	// check if the ability is on cooldown
	if (!bReady)
	{
		ErrorMessage = ErrorAbilityNotReadyYet;
		return false;
	}
	else if(OwningUnit.bSilenced)
	{
		ErrorMessage = ErrorCantDoThatWhileSilenced;
		return false;
	}
	else
	{
		return true;
	}
}

/**
 * Checks whether the unit owning this ability is snared. Returns
 * false and sets ErrorMessage if that's the case.
 * 
 * @param ErrorMessage
 *      the error message to set
 */
simulated function bool CheckSnared(out string ErrorMessage)
{
	if (OwningUnit.bSnared)
	{
		ErrorMessage = ErrorCantDoThatWhileSnared;
		return false;
	}
	else
	{
		return true;
	}
}

/** Triggers this ability, paying shards and starting its cooldown timer. */
function TriggerAbility()
{
	`log("Ability "$self$" has been triggered.");

	// make the player pay ;)
	OwningUnit.OwningPlayer.Shards -= ShardsRequired;

	// start cooldown timer
	StartCooldownTimer();

	// play sound
	if (SoundTriggered != none)
	{
		OwningUnit.PlaySound(SoundTriggered);
	}

	bTriggered = true;
	OnAbilityTriggered();

	// remember triggered ability for score screen
	OwningUnit.OwningPlayer.TotalAbilitiesTriggered++;

	if (ShardsRequired > 0)
	{
		OwningUnit.OwningPlayer.TotalTacticalAbilitiesTriggered++;
	}

	// write log output for analyzing tool
	`log("SERVER: Ability \""$AbilityName$"\" used by "$OwningUnit.OwningPlayer.PlayerReplicationInfo.PlayerName);
}

/** Starts the cooldown timer of this ability. */
function StartCooldownTimer()
{
	bReady = false;
	SetTimer(Cooldown, false, 'Ready');
}

/**
 * Forces this ability to be on cooldown for the given time.
 * Abilities that are already on cooldown maintain their original cooldown if bigger,
 * otherwise use the given time as new cooldown.
 */
function ForceCooldown(int time)
{
	local float remainingTime;

	// if not on cooldown just set the given time as cooldown
	if(bReady)
	{
		bReady = false;
		SetTimer(time, false, 'Ready');
	}
	// if already on cooldown only use the given time if bigger than the remaining time
	else
	{
		remainingTime = GetRemainingTimeForTimer('Ready');

		if(remainingTime < time)
		{
			SetTimer(time, false, 'Ready');
		}
	}	
}

/** Turns this ability ready again after its cooldown has expired. */
function Ready()
{
	bReady = true;
	bTriggered = false;

	`log("Ability "$self$" has finished cooling down.");
}

/** 
 *  Function that is called if the ability was triggered.
 *  Use this to initialize effects on the clients.
 */
simulated function OnAbilityTriggered()
{
}

/** 
 *  Returns the localized description string of this ability to be displayed in
 *  the HUD whenever this ability is hovered.
 *  
 *  Subclasses may overwrite this method to parse the string and insert values. */
simulated static function string GetHTMLDescription()
{
	return default.Description;
}

/** Returns the shards required to trigger this ability. */
simulated static function int GetShardsRequired()
{
	return default.ShardsRequired;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bTriggered')
	{
		if(bTriggered)
		{
			OnAbilityTriggered();
		}
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

replication
{
	// Replicate if server
	if(Role == ROLE_Authority && (bNetInitial || bNetDirty))
		bLearned, OwningUnit, bReady, bBeingActivated, bTriggered;
}

DefaultProperties
{
	RemoteRole=ROLE_SimulatedProxy
	
	bReady=true
	bAlwaysRelevant=true
	bShowAbilityRadius=true
}
