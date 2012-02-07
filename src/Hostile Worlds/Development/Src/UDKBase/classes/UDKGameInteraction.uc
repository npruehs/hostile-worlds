/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKGameInteraction extends UIInteraction
	native;

/** Semaphore for blocking UI input. */
var int		BlockUIInputSemaphore;

cpptext
{
	/**
	 * Check a key event received by the viewport.
	 *
	 * @param	Viewport - The viewport which the key event is from.
	 * @param	ControllerId - The controller which the key event is from.
	 * @param	Key - The name of the key which an event occured for.
	 * @param	Event - The type of event which occured.
	 * @param	AmountDepressed - For analog keys, the depression percent.
	 * @param	bGamepad - input came from gamepad (ie xbox controller)
	 *
	 * @return	True to consume the key event, false to pass it on.
	 */
	virtual UBOOL InputKey(INT ControllerId,FName Key,EInputEvent Event,FLOAT AmountDepressed=1.f,UBOOL bGamepad=FALSE);

	/**
	 * Check an axis movement received by the viewport.
	 *
	 * @param	Viewport - The viewport which the axis movement is from.
	 * @param	ControllerId - The controller which the axis movement is from.
	 * @param	Key - The name of the axis which moved.
	 * @param	Delta - The axis movement delta.
	 * @param	DeltaTime - The time since the last axis update.
	 *
	 * @return	True to consume the axis movement, false to pass it on.
	 */
	virtual UBOOL InputAxis(INT ControllerId,FName Key,FLOAT Delta,FLOAT DeltaTime, UBOOL bGamepad=FALSE);

	/**
	 * Check a character input received by the viewport.
	 *
	 * @param	Viewport - The viewport which the axis movement is from.
	 * @param	ControllerId - The controller which the axis movement is from.
	 * @param	Character - The character.
	 *
	 * @return	True to consume the character, false to pass it on.
	 */
	virtual UBOOL InputChar(INT ControllerId,TCHAR Character);
}

/**
 * @return Whether or not we should process input.
 */
native final function bool ShouldProcessUIInput() const;

/**
 * Calls all of the UI input blocks and sees if we can unblock ui input.
 */
event ClearUIInputBlocks()
{
	BlockUIInputSemaphore = 0;
}

/** Tries to block the input for the UI. */
event BlockUIInput(bool bBlock)
{
	if(bBlock)
	{
		BlockUIInputSemaphore++;
	}
	else if(BlockUIInputSemaphore > 0)
	{
		BlockUIInputSemaphore--;
	}
}

/* === Interaction interface === */

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 */
function NotifyGameSessionEnded()
{
	Super.NotifyGameSessionEnded();

	// if a scene is closed before its opening animation completes, it can result in unmatched calls to BlockUIInput
	// which will prevent the game from processing any input; so if we don't have any scenes open, make sure the
	// semaphore is reset to 0
	if ( !SceneClient.IsUIActive() )
	{
		ClearUIInputBlocks();
	}
}

