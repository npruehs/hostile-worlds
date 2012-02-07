/**
 * A special button used by the UIScrollbar class for incrementing or decrementing the current position of the scrollbar's
 * marker button.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIScrollbarButton extends UIButton
	within UIScrollbar
	native(inherit)
	notplaceable;


DefaultProperties
{
	//PRIVATE_NotFocusable|PRIVATE_NotDockable|PRIVATE_TreeHidden|PRIVATE_NotEditorSelectable|PRIVATE_ManagedStyle
	PrivateFlags=0x2F
	DockTargets=(bLockHeightWhenDocked=true,bLockWidthWhenDocked=true)

	// the StyleResolverTags must match the name of the property in the owning scrollbar control in order for SetWidgetStyle to work correctly,
	// but since UIScrollbarButton will use either IncrementStyle or DecrementStyle depending on which one this is, it will be set dynamically
	// by the owning scrollbar when this button is created.
}
