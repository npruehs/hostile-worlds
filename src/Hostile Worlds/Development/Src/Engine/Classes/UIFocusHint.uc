/**
 * Special kind of label used to display a indicator next to the currently focused interactive widget.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIFocusHint extends UILabel
	notplaceable;

/* === UIScreenObject interface === */
/**
 * Notification that this widget's parent is about to remove this widget from its children array.  Allows the widget
 * to clean up any references to the old parent.
 *
 * @param	WidgetOwner		the screen object that this widget was removed from.
 */
event RemovedFromParent( UIScreenObject WidgetOwner )
{
	Super.RemovedFromParent(WidgetOwner);

	ClearDockTargets();
}

DefaultProperties
{
	DockTargets=(bLockWidthWhenDocked=true)
	Begin Object Name=LabelStringRenderer
		AutoSizeParameters(UIORIENT_Horizontal)=(bAutoSizeEnabled=true)
		AutoSizeParameters(UIORIENT_Vertical)=(bAutoSizeEnabled=true)
	End Object
}
