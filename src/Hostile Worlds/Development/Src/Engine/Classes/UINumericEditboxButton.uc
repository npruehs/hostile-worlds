/**
 * This  widget is a simple extension of the UIButton class with minor changes made specificly for its application
 * in the UINumericEditBox class.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 */
class UINumericEditBoxButton extends UIButton
	native(inherit)
	notplaceable;

defaultproperties
{
	//PRIVATE_NotFocusable|PRIVATE_NotDockable|PRIVATE_TreeHidden|PRIVATE_NotEditorSelectable|PRIVATE_ManagedStyle
	PrivateFlags=0x2F

	// the StyleResolverTags must match the name of the property in the owning scrollbar control in order for SetWidgetStyle to work correctly,
	// but since UIScrollbarButton will use either IncrementStyle or DecrementStyle depending on which one this is, it will be set dynamically
	// by the owning scrollbar when this button is created.
}
