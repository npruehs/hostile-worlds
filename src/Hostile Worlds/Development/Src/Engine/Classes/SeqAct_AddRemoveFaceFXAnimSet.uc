/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class SeqAct_AddRemoveFaceFXAnimSet extends SequenceAction;

/** List of FaceFXAnimSets to add to Pawn Target */
var() deprecated Array<FaceFXAnimSet> FaceFXAnimSets;

defaultproperties
{
	ObjName="Add Remove FaceFXAnimSet"
	ObjCategory="Pawn"

	InputLinks(0)=(LinkDesc="Add FaceFXAnimSets")
	InputLinks(1)=(LinkDesc="Remove FaceFXAnimSets")

	// define the base output link that this action generates (always assumed to generate at least a single output)
	OutputLinks(0)=(LinkDesc="Out")
}
