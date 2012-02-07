// ============================================================================
// HWBuff
// An abstract buff of Hostile Worlds. Provides all required applying and
// wearing off logic, including the required timers.
//
// Author:  Nick Pruehs, Marcel Koehler
// Date:    2010/10/21
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBuff extends Actor
	config(HostileWorldsAbilityData)
	abstract;

/** The name of this buff. */
var localized string BuffName;

/** The description of this buff. */
var localized string Description;

/** The target unit this buff has been applied to. */
var HWPawn Target;

/** The previous buff in the target's linked list of buffs. */
var HWBuff PreviousBuff;

/** The next buff in the target's linked list of buffs. */
var HWBuff NextBuff;

/** The optional total duration of the buff, in seconds. If no duration is specified, the buff does not wear off automatically. */
var config float Duration;

/** The time before two ticks of this buff, in seconds. */
var config float BuffTickTime;

/** The sound to be played when this buff wears off. */
var SoundCue SoundOff;

/** If to show an effect corresponding to this buff or not. */
var repnotify bool bShowEffect;

/** The icon of this buff to be shown in the status window of the UI. */
var Texture2D BuffIcon;


/** 
 *  Applies this buff to the specified unit, initializing its duration timer
 *  and activating it.
 *  
 *  @param TargetUnit
 *      the unit this buff should be applied to   
 */
function ApplyBuffTo(HWPawn TargetUnit)
{
	local HWBuff Buff;

	Target = TargetUnit;

	// Remove any buffs from the same class
	Target.RemoveBuffByClass(self.Class);

	if (Target.Buffs == none)
	{
		// buff list is empty
		Target.Buffs = self;
	}
	else
	{
		// add buff to end of buff list
		Buff = Target.Buffs;

		while (Buff.NextBuff != none)
		{
			Buff = Buff.NextBuff;
		}

		Buff.NextBuff = self;
		PreviousBuff = Buff;
	}

	if (Duration > 0)
	{
		SetTimer(Duration, false, 'WearOff');
	}

	if (BuffTickTime > 0)
	{
		// start buff tick timer
		SetTimer(BuffTickTime, true, 'TickBuff');
	}
	
	`log("Buff "$self$" has been applied to "$Target);
}

/** Allows subclasses to specify tick logic for this buff. */
function TickBuff();

/** 
 *  Called when this buff expires normally, i.e. it has not been dispelled.
 *  Removes all effects from the targeted unit.
 */
function WearOff()
{
	`log("Buff "$self$" is wearing off...");

	// play off sound
	if (SoundOff != none)
	{
		Target.PlaySound(SoundOff);
	}

	Remove();
}

/** Removes all effects from the targeted unit and destroys this buff. */
function Remove()
{
	if (PreviousBuff == none && NextBuff == none)
	{
		// buff is the only one in the linked list
		Target.Buffs = none;
	}
	else
	{
		// change pointers of its predecessor and successor
		if (PreviousBuff != none)
		{
			PreviousBuff.NextBuff = NextBuff;
		}
		
		if (NextBuff != none)
		{
			NextBuff.PreviousBuff = PreviousBuff;
		}

		// if this is the first buff in the list, update unit's pointer
		if (Target.Buffs == self)
		{
			Target.Buffs = NextBuff;
		}
	}

	// disable tick timer
	SetTimer(0.f, false, 'TickBuff');

	GotoState('Destroying');
}

/** 
 *  Returns the localized description string of this buff to be displayed in
 *  the HUD whenever this buff is hovered.
 *  
 *  Subclasses may overwrite this method to parse the string and insert values. */
simulated function string GetHTMLDescription()
{
	return Description;
}

simulated function ShowEffect();
simulated function HideEffect();

// State for latent destruction in order to give the instance the opportunity to send all pending updates
State Destroying
{
	Begin:
		if(bPendingNetUpdate)
		{
			Sleep(0.5);
			goto('Begin');
		}
		else
		{
			Destroy();
			GotoState('');
		}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bShowEffect')
	{
		if(bShowEffect)
		{
			ShowEffect();
		}
		else
		{
			HideEffect();
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
		PreviousBuff, NextBuff, Target, bShowEffect;
}

DefaultProperties
{
	RemoteRole = ROLE_SimulatedProxy;

	bAlwaysRelevant=true
}
