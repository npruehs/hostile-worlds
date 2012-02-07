/**
 * Abstract base class for events which are implemented by UIStates.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIEvent_State extends UIEvent
	native(inherit)
	abstract;

cpptext
{
	/**
	 * Fills in the value of the "State" variable link with the State that the widget is currently in.
	 */
	virtual void InitializeLinkedVariableValues();
}

DefaultProperties
{
	ObjName="State Event"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="State",bWriteable=true)
	bPropagateEvent=false
}
