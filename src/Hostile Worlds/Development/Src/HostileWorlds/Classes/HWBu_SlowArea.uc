// ============================================================================
// HWBu_SlowArea
// Buff that indicates that the target unit is slowed down by the terrain.
//
// Author:  Nick Pruehs
// Date:    2011/02/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBu_SlowArea extends HWBuff
	config(HostileWorlds);

/** The factor that is applied to the movement speed of units passing a Slow Area. */
var config float SlowFactor;


function ApplyBuffTo(HWPawn TargetUnit)
{
	BuffTickTime = 1.0f;

	super.ApplyBuffTo(TargetUnit);

	// reduce movement speed
	TargetUnit.MovementSpeedModifier *= SlowFactor;
}

function TickBuff()
{
	local HWPlayerController OwningPlayer;

	// remember time spent in slow area for score screen
	OwningPlayer = Target.OwningPlayer;

	if (OwningPlayer != none)
	{
		OwningPlayer.TotalTimeSpentInSlowArea++;
	}
}

function WearOff()
{
	// restore movement speed
	Target.MovementSpeedModifier /= SlowFactor;

	super.WearOff();
}

simulated function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(Description, "%1", class'HWHud'.static.HTMLMarkup(int((1 - SlowFactor) * 100)));

	return Result;
}


DefaultProperties
{
	BuffIcon=Texture2D'UI_HWBuffs.T_UI_Buff_SlowArea_Test'
}
