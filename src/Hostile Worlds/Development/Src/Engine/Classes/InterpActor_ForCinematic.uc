/** 
 *  This actor is meant to be used by Matinee for all of the usage scenerios where you have an invisible
 * InterpActor moving around some track that the camera is eventually attached to.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class InterpActor_ForCinematic extends InterpActor
	placeable;



defaultproperties
{
	// since these InterpActors are usually invisible and not on screen we need to make certain they are getting full ticking
	TickFrequencyAtEndDistance=0
}