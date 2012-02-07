// ============================================================================
// HWSeqAct_NextArtifactRound
// A Hostile Worlds sequence action that triggers the next artifact round.
//
// Author:  Nick Pruehs
// Date:    2011/03/20
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSeqAct_NextArtifactRound extends HWSequenceAction;

event Activated()
{
	HWGame(GetWorldInfo().Game).ArtifactManager.NextArtifactRound();

	super.Activated();
}


DefaultProperties
{
	ObjName="Artifact Controller - Next Artifact Round"
}
