class InterpGroupAI extends InterpGroup
	native(Interpolation)
	collapsecategories
	hidecategories(Object);

/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Group for controlling properties of a 'player' in the game. This includes switching the player view between different cameras etc.
 */

cpptext
{
	/**
	 * Create Preview Pawn/Destroy Preview Pawn
	 */ 
	void CreatePreviewPawn();
	void DestroyPreviewPawn();

	/**
	 * Get Stage Mark Actor ground position & rotation
	 */
	FVector     GetStageMarkPosition(FRotator* Rotation = NULL);
	
	/** 
	 *  Update Stage Mark Group Actor
	 */ 
	void UpdateStageMarkGroupActor(USeqAct_Interp * Seq);

	// Post edit
	// Need to refresh skelmesh if that changes
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	// UInterpGroup interface
	virtual void UpdateGroup(FLOAT NewPosition, class UInterpGroupInst* GrInst, UBOOL bPreview, UBOOL bJump);
}

/** 
 *	Preview Pawn class for this track 
 */
var()   editoronly class<Pawn>                      PreviewPawnClass;

/**
 * Name of Stage Mark Group - used for locator
 */
var()   Name                            StageMarkGroup;

/** Preview Pawn for only editor - in game it should be AI **/
var   editoronly transient Pawn PreviewPawn;

/** Stage Mark Actor - from StageMark Group **/
var Actor   StageMarkActor;

/** Snap AI to root bone location when finished **/
var() bool    SnapToRootBoneLocationWhenFinished;

defaultproperties
{
	GroupName="AIGroup"
}
