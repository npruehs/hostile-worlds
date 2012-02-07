// ============================================================================
// HWBu_Silence
// Buff that indicates that the target unit is silenced.
//
// Author:  Marcel Köhler
// Date:    2011/04/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBu_Silence extends HWBuff;


function ApplyBuffTo(HWPawn TargetUnit)
{
	super.ApplyBuffTo(TargetUnit);
	
	TargetUnit.bSilenced = true;
}

function WearOff()
{
	Target.bSilenced = false;

	super.WearOff();
}

DefaultProperties
{
	BuffIcon=Texture2D'UI_HWBuffs.T_UI_Buff_Silence_Test'
}
