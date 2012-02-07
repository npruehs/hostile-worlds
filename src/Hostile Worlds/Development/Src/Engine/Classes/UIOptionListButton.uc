/**
* A special button used by the UIOptionListBase class for incrementing or decrementing the current position of the list's label
*
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*/
class UIOptionListButton extends UIButton
	within UIOptionListBase
	native(inherit)
	notplaceable;

/**
 * Determines which states this button should be in based on the state of the owner UIOptionListBase and synchronizes to those states.
 *
 * @param	PlayerIndex		the index of the player that generated the update; if not specified, states will be activated for all
 *							players that are eligible to generate input for this button.
 */
native final function UpdateButtonState( optional int PlayerIndex=INDEX_NONE );

DefaultProperties
{
	//PRIVATE_NotFocusable|PRIVATE_NotDockable|PRIVATE_TreeHiddenRecursive|PRIVATE_NotEditorSelectable|PRIVATE_ManagedStyle
	PrivateFlags=0x6F

	// the StyleResolverTags must match the name of the property in the owning option list in order for SetWidgetStyle to work correctly,
	// but since UIOptionListButton will use either IncrementStyle or DecrementStyle depending on which one this is, it will be set dynamically
	// by the owning option list when this button is created.
}

