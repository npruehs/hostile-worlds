// ============================================================================
// HWBu_Cloak
// Buff that indicates that the target unit is cloaked.
//
// Author:  Marcel Köhler
// Date:    2011/07/04
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBu_Cloak extends HWBuff
	config(HostileWorldsAbilityData);

/** The factor that is applied to the movement speed of cloaked units. */
var config float SpeedFactor;

/** The cooldown all the target unit abilities have after uncloaking. */
var config int AbilityCooldown;

function ApplyBuffTo(HWPawn TargetUnit)
{
	local HWBu_Silence BuSilence;
	local HWBu_Blind BuBlind;

	super.ApplyBuffTo(TargetUnit);

	// increase movement speed
	TargetUnit.MovementSpeedModifier *= SpeedFactor;

	TargetUnit.Cloak();

	// apply a blind buff for the duration of the cloak
	BuBlind = Spawn(class'HWBu_Blind', self);
	BuBlind.Duration = Duration;
	BuBlind.ApplyBuffTo(Target);

	// apply a silence buff for the duration of the cloak plus the AbilityCooldown duration
	BuSilence = Spawn(class'HWBu_Silence', self);
	BuSilence.Duration = Duration + AbilityCooldown;
	BuSilence.ApplyBuffTo(Target);
}

function WearOff()
{
	// restore movement speed
	Target.MovementSpeedModifier /= SpeedFactor;

	Target.UnCloak();

	super.WearOff();
}

simulated function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(Description, "%1", class'HWHud'.static.HTMLMarkup(int((SpeedFactor - 1) * 100)));

	return Result;
}


DefaultProperties
{
	SoundOff=SoundCue'A_Sounds_Abilities.A_Ability_CloakOffCue_Test'

	BuffIcon=Texture2D'UI_HWBuffs.T_UI_Buff_Cloak_Test'
}
