/*=============================================================================
	InputHelper.as : Script on top of scaleform to allow top level movie input to behave as a first class citizen with CLIK input
	Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
	
	Will translate into "ProcessKeyDown", "ProcessKeyUp", and "ProcessKeyHold" events defined in the global scope
=============================================================================*/

import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;

/**
 * derived handleInput call that will be sent from CLIK and intercepted by top level movies where this is included.
 */
function handleInput(details:InputDetails, pathToFocus:Array):Boolean 
{
	//try recursing first.  if it successfully dealt with the input, then bail.
	if (pathToFocus != null && pathToFocus.length > 0) {
		var handled:Boolean = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		if (handled) 
		{
			return handled; 
		}
	}

	//event has NOT been successfully dealt with.  Try to send the appropriate event to the top level movie
	if ((details.value == "keyDown") && (ProcessKeyDown))
	{
		return ProcessKeyDown(details, pathToFocus);
	}
	else if ((details.value == "keyUp") && (ProcessKeyUp))
	{
		return ProcessKeyUp(details, pathToFocus);
	}
	else if ((details.value == "keyHold") && (ProcessKeyHold))
	{
		return ProcessKeyHold(details, pathToFocus);
	}
	//Since this is the top level, the return value isn't relevant.  Just say we didn't handle it.
	return FALSE;
}

//clears the definitions in case flash has left stale definitions when jumping through the timeline
this.ProcessKeyDown = undefined
this.ProcessKeyUp = undefined
this.ProcessKeyHold = undefined

