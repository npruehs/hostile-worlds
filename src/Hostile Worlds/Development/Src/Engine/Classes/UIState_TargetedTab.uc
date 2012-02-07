/**
 * A state very similar to focused, but only supports the UITabButton class.  Used by the tab control when previewing
 * other tab pages to indicate which tab button's page is currently visible.
 *
 * @note: native only because UITabButton references this class in native code.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIState_TargetedTab extends UIState
	native(UIPrivate);

/**
 * Determines whether this state can be used by the widget class specified.  Only used in the UI editor to remove
 * unsupported states from the various controls and menus.
 *
 * @param	WidgetClass	the widget class to check.
 *
 * @return	TRUE if this state can appear in the state-related controls and menus for WidgetClass.
 */
event bool IsWidgetClassSupported( class<UIScreenObject> WidgetClass )
{
	return WidgetClass.ClassIsChildOf(WidgetClass, class'Engine.UITabButton');
}


defaultproperties
{
	// one above UIState_Focused's priority.
	StackPriority=11
}

