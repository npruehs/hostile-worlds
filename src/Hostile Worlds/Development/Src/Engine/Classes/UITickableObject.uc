/**
 * Provides an interface for widgets that need to receive a callback each frame.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
interface UITickableObject
	native(UIPrivate);

cpptext
{
	/**
	 * Called each frame to allow the object to perform work.
	 *
	 * @param	PreviousFrameSeconds	amount of time (in seconds) between the start of this frame and the start of the previous frame.
	 */
	virtual void Tick( FLOAT PreviousFrameSeconds )=0;
}

