// ============================================================================
// HWBu_DamageArea
// Buff that indicates that the target unit is periodically dealt damage by
// the terrain.
//
// Author:  Nick Pruehs
// Date:    2011/02/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBu_DamageArea extends HWBuff;

function ApplyBuffTo(HWPawn TargetUnit)
{
	BuffTickTime = 1.0f;
	super.ApplyBuffTo(TargetUnit);
}

function TickBuff()
{
	local HWPlayerController OwningPlayer;

	// remember time spent in damage area for score screen
	OwningPlayer = Target.OwningPlayer;

	if (OwningPlayer != none)
	{
		OwningPlayer.TotalTimeSpentInDamageArea++;
	}
}

DefaultProperties
{
	BuffIcon=Texture2D'UI_HWBuffs.T_UI_Buff_DamageArea_Test'
}
