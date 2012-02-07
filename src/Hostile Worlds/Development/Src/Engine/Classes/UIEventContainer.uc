/**
 * Provides an interface for objects which can contain collections of UIEvents.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
interface UIEventContainer
	native(UserInterface);

/**
 * Retrieves the UIEvents contained by this container.
 *
 * @param	out_Events	will be filled with the UIEvent instances stored in by this container
 * @param	LimitClass	if specified, only events of the specified class (or child class) will be added to the array
 */
native function GetUIEvents( out array<UIEvent> out_Events, optional class<UIEvent> LimitClass );

/**
 * Adds a new SequenceObject to this containers's list of ops
 *
 * @param	NewObj		the sequence object to add.
 * @param	bRecurse	if TRUE, recursively add any sequence objects attached to this one
 *
 * @return	TRUE if the object was successfully added to the sequence.
 */
native function bool AddSequenceObject( SequenceObject NewObj, optional bool bRecurse );

/**
 * Removes the specified SequenceObject from this container's list of ops.
 *
 * @param	ObjectToRemove	the sequence object to remove
 */
native function RemoveSequenceObject( SequenceObject ObjectToRemove );

/**
 * Removes the specified SequenceObjects from this container's list of ops.
 *
 * @param	ObjectsToRemove		the objects to remove from this sequence
 */
native function RemoveSequenceObjects( array<SequenceObject> ObjectsToRemove );

DefaultProperties
{

}
