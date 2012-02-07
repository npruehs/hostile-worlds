/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTSeqCond_DoTutorial extends SequenceCondition;

event Activated()
{
	local bool bTutorialOK;
	local WorldInfo WI;

	WI = GetWorldInfo();

	bTutorialOK = false;
	if ( WI != none && WI.GRI != none && UTGameReplicationInfo(WI.GRI) != none )
	{

		// If we are in story mode the tutorial is ok.

		bTutorialOK = UTGameReplicationInfo(WI.GRI).bStoryMode;

		if (WI.Game.NumPlayers + WI.Game.NumTravellingPlayers > 1)
		{
			bTutorialOK = false;
		}
	}


	OutputLinks[ bTutorialOK ? 0 : 1].bHasImpulse = true;
}


defaultproperties
{
	ObjName="Do Tutorial"
	OutputLinks(0)=(LinkDesc="Play Tutorial")
	OutputLinks(1)=(LinkDesc="Abort Tutorial")
}


