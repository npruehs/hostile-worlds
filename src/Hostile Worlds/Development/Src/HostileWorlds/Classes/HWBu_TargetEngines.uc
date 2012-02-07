// ============================================================================
// HWBu_TargetEngines
// Buff that indicates that the target unit is snared and unable to move.
//
// Author:  Nick Pruehs
// Date:    2011/03/14
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBu_TargetEngines extends HWBuff;

function ApplyBuffTo(HWPawn TargetUnit)
{
	super.ApplyBuffTo(TargetUnit);

	TargetUnit.Snare();
}

function WearOff()
{
	Target.UnSnare();

	super.WearOff();
}

DefaultProperties
{
	BuffIcon=Texture2D'UI_HWBuffs.T_UI_Buff_TargetEngines_Test'
}
