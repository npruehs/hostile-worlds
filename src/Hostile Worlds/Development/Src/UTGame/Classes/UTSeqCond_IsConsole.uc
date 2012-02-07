/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTSeqCond_IsConsole extends SequenceCondition;

event Activated()
{
	OutputLinks[ (Class'WorldInfo'.Static.IsConsoleBuild()) ? 0 : 1].bHasImpulse = true;
}


defaultproperties
{
	ObjName="UTIsConsole"
	OutputLinks(0)=(LinkDesc="Console Game")
	OutputLinks(1)=(LinkDesc="PC Game")
}
