/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Extended version of console that only allows the quick console to be open if there are no UI scenes open, this is to allow UI scenes to process the TAB key.
 */
class UTConsole extends Console;

var int TextCount;

/**
 * Process an input key event routed through unrealscript from another object. This method is assigned as the value for the
 * OnRecievedNativeInputKey delegate so that native input events are routed to this unrealscript function.
 *
 * @param	ControllerId	the controller that generated this input key event
 * @param	Key				the name of the key which an event occured for (KEY_Up, KEY_Down, etc.)
 * @param	EventType		the type of event which occured (pressed, released, etc.)
 * @param	AmountDepressed	for analog keys, the depression percent.
 *
 * @return	true to consume the key event, false to pass it on.
 */
function bool InputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE )
{
	local UTGameUISceneClient UTSceneClient;

	// Don't allow console commands when in seamless travel.

    UTSceneClient = UTGameUISceneClient(class'UIRoot'.static.GetSceneClient());
	if ( UTSceneClient != none && UTSceneClient.IsInSeamlessTravel() )
	{
		return false;
	}

	if ( Event == IE_Pressed )
	{
		bCaptureKeyInput = false;

		if ( Key == ConsoleKey )
		{
			GotoState('Open');

			// this already gets set in Open.BeginState, but no harm in being explicit
			bCaptureKeyInput = true;
		}
		else if ( Key == TypeKey )
		{
			// Only show the quick console if there are no UI scenes open that are accepting input.
			if( UTSceneClient==None || UTSceneClient.IsUIAcceptingInput() ==false )
			{
				GotoState('Typing');
				// this already gets set in Typing.BeginState, but no harm in being explicit
				bCaptureKeyInput = true;
			}
		}
	}

	return bCaptureKeyInput;
}

state Typing
{
	function bool InputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE )
	{
		if( Key == 'Escape' && Event == IE_Released )
		{
			GotoState( '' );
			return true;
		}

		return Super.InputKey( ControllerId, Key, Event, AmountDepressed, bGamepad);
	}
}

function OutputTextLine(coerce string Text)
{
	TextCount++;
	Super.OutputTextLine(text);
}
