/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
/** action that causes the AI to do absolutely nothing and deactivates any automatic responses it might have
	note that even while frozen future Kismet AI actions will still work, just no default behavior */
class UTSeqAct_AIFreeze extends SequenceAction;

/** whether to allow the AI's target selection and weapon firing logic to continue to execute */
var() bool bAllowWeaponFiring;

defaultproperties
{
	ObjName="Freeze"
	ObjCategory="AI"
	InputLinks[0]=(LinkDesc="Freeze")
	InputLinks[1]=(LinkDesc="Unfreeze")
}
