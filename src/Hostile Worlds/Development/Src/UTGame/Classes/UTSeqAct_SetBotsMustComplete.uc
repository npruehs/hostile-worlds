/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


/** this action sets the flag that tells bots whether or not they must complete a given objective to proceed */
class UTSeqAct_SetBotsMustComplete extends SequenceAction;

defaultproperties
{
	ObjCategory="Objective"
	ObjName="Set Bots Must Complete"
	InputLinks[0]=(LinkDesc="Turn On")
	InputLinks[1]=(LinkDesc="Turn Off")
}
