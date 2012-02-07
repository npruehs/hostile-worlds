/**
 * Base class for events which are activated when some widget that contains data changes the value of that data
 * (checkboxes, editboxes, lists, etc.)
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * @note: native because C++ code activates this event
 */
class UIEvent_ValueChanged extends UIEvent
	native(inherit)
	abstract
	;

DefaultProperties
{
	ObjName="Value Changed"
	ObjCategory="Value Changed"
}
