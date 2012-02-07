/**
 * The purpose of this class is to act as a base for any non-native UI classes that wish to subscribe to the scene's array of tickable
 * objects.  This  base class implements the UITickableObject interface and routes the call to an event and delegate.  It can be used
 * directly (by subscribing to its OnScriptTick delegate) or subclassed (by overriding the ScriptTick event).
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UITickableObjectProxy extends UIRoot
	native(UIPrivate)
	implements(UITickableObject)
	transient;

cpptext
{
	/**
	 * Called each frame to allow the object to perform work.
	 *
	 * @param	PreviousFrameSeconds	amount of time (in seconds) between the start of this frame and the start of the previous frame.
	 */
	virtual void Tick( FLOAT PreviousFrameSeconds );
}

/**
 * Delegate for allowing others to subscribe to this object's tick.
 */
delegate OnScriptTick( UITickableObjectProxy Sender, float DeltaTime );

/**
 * This event is called by the native code each frame.
 */
event ScriptTick( float DeltaTime );

