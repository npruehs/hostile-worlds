/**
 * SeqAct_WaitForLevelsVisible
 *
 * Kismet action exposing associating/ dissociating of levels.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_WaitForLevelsVisible extends SeqAct_Latent
	native(Sequence);

/** Names of levels to wait for visibility. */
var() array<Name> LevelNames;

/** If TRUE engine will request blocking load if level is in process of being loaded. */
var() bool bShouldBlockOnLoad;

cpptext
{
	UBOOL UpdateOp(FLOAT DeltaTime);
};

defaultproperties
{
	bShouldBlockOnLoad=TRUE

	ObjName="Wait for Levels to be visible"
	ObjCategory="Level"
	VariableLinks.Empty
	OutputLinks.Empty
	InputLinks(0)=(LinkDesc="Wait")
	OutputLinks(0)=(LinkDesc="Finished")
}
