/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class SeqCond_IsConsole extends SequenceCondition
	native(Sequence);

cpptext
{
	virtual void Activated()
	{
		AWorldInfo* WorldInfo = GWorld->GetWorldInfo();

		// Trigger the output based upon meeting the num logged in criteria
		if( WorldInfo && WorldInfo->IsConsoleBuild() )
		{
			OutputLinks(0).bHasImpulse = TRUE;
		}
		else
		{
			OutputLinks(1).bHasImpulse = TRUE;
		}
	}
}

defaultproperties
{
	ObjName="Is Console"

	OutputLinks(0)=(LinkDesc="True")
	OutputLinks(1)=(LinkDesc="False")
}
