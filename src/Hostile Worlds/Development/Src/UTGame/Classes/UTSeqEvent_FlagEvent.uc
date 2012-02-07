/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTSeqEvent_FlagEvent extends SequenceEvent;

/** attempts to activate the event with the appropriate output for the given event type and instigator */
function Trigger(name EventType, Controller EventInstigator)
{
	local array<int> ActivateIndices;
	local int i;
	local SeqVar_Object ObjVar;

	for (i = 0; i < OutputLinks.length; i++)
	{
		if (EventType == name(OutputLinks[i].LinkDesc))
		{
			ActivateIndices[ActivateIndices.length] = i;
		}
	}

	if (ActivateIndices.length == 0)
	{
		ScriptLog("Not activating" @ self @ "for event" @ EventType @ "because there are no matching outputs");
	}
	else if (CheckActivate(Originator, EventInstigator, false, ActivateIndices))
	{
		foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Instigator")
		{
			ObjVar.SetObjectValue(EventInstigator);
		}
	}
}
/**
 * Return the version number for this class.  Child classes should increment this method by calling Super then adding
 * a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
 * link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
 * Super.GetObjClassVersion() should be incremented by 1.
 *
 * @return	the version number for this specific class.
 */
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 1;
}


defaultproperties
{
	ObjName="Flag Event"
	ObjCategory="Objective"
	bPlayerOnly=false
	MaxTriggerCount=0
	OutputLinks[0]=(LinkDesc="Taken")
	OutputLinks[1]=(LinkDesc="Dropped")
	OutputLinks[2]=(LinkDesc="Returned")
	OutputLinks[3]=(LinkDesc="Captured")
}
