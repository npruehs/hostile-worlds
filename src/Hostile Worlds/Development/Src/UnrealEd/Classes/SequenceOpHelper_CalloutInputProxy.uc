/**
 * This class is used to provide the editor with a way to apply specialized logic specific to the UIEvent_CalloutButtonProxy
 * class without requiring the editor to know anything about that class.  It is invoked by the kismet editor when the user
 * double-clicks or right-clicks on a UIEvent_CalloutButtonInputProxy object.  It instantiates a customized version of the
 * respective context menus which has additional logic for dealing with UIEvent_CalloutButtonInputProxy objects.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SequenceOpHelper_CalloutInputProxy extends SequenceObjectHelper
	native(Private);

cpptext
{
	/**
	 * Called when the user double clicks on a sequence object, can be used to display object specific
	 * property dialogs.
	 *
	 * @param InEditor	Pointer to the editor that initiated the callback.
	 * @param InObject	Pointer to the object that was clicked on.
	 */
	virtual void OnDoubleClick( const class WxKismet* InEditor, USequenceObject* InObject ) const;

	/**
	 * Called when the user right clicks on a sequence object, should show a object specific context menu.
	 *
	 * @param InEditor	Pointer to the editor that initiated the callback.
	 */
	virtual void  ShowContextMenu( class WxKismet* InEditor ) const;
//
//	not yet implemented - not actually referenced by any of the tree controls, but could be useful
//	/**
//	 * Called when the Kismet editor wants the object to add itself to a tree control.
//	 *
//	 * @param InEditor		Pointer to the editor that initiated the callback.
//	 * @param InTreeCtrl	Pointer to the tree control we will be adding an item to.
//	 * @param ParentItem	The parent of the item that will be added.
//	 * @return				The tree item we created.
//	 */
//	virtual wxTreeItemId AddToTreeControl(  class WxKismet* InEditor, class wxTreeCtrl* InTreeCtrl, class wxTreeItemId& ParentItem ) const;
}

