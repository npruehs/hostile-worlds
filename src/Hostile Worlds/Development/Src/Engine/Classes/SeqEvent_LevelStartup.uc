/**
 * Event which is activated by GameInfo.StartMatch when the match begins.
 * Originator: current WorldInfo
 * Instigator: None
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqEvent_LevelStartup extends SequenceEvent
	native(Sequence);

cpptext
{
	virtual USequenceObject* ConvertObject();
}

defaultproperties
{
	ObjName="Level Startup"
	VariableLinks.Empty
	bPlayerOnly=false
}
