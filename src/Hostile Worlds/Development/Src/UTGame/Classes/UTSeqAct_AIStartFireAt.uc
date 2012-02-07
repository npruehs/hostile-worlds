/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTSeqAct_AIStartFireAt extends SequenceAction;

var() byte ForcedFireMode;

defaultproperties
{
	ForcedFireMode=255
	ObjName="Start Firing At"
	ObjCategory="AI"
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Fire At",MinVars=1,MaxVars=1)
}
