// ============================================================================
// HWBu_Blind
// Buff that indicates that the target unit is blinded.
//
// Author:  Marcel Köhler
// Date:    2011/04/10
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWBu_Blind extends HWBuff;


function ApplyBuffTo(HWPawn TargetUnit)
{
	super.ApplyBuffTo(TargetUnit);
	
	TargetUnit.bBlinded = true;
}

function WearOff()
{
	Target.bBlinded = false;

	super.WearOff();
}

DefaultProperties
{
	BuffIcon=Texture2D'UI_HWBuffs.T_UI_Buff_Blind_Test'
}
