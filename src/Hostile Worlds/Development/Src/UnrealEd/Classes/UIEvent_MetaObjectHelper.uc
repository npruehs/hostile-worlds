/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UIEvent_MetaObjectHelper extends SequenceObjectHelper
	native;

cpptext
{
	/**
	 * Called when the user right clicks on a sequence object, should show a object specific context menu.
	 *
	 * This version displays a menu allowing the user to add or remove buttons from the process input event.
	 *
	 * @param InEditor	Pointer to the editor that initiated the callback.
	 */
	virtual void  ShowContextMenu( class WxKismet* InEditor ) const;

	/**
	 * Called when the user double clicks on a sequence object, can be used to display object specific
	 * property dialogs.
	 *
	 * @param InEditor	Pointer to the editor that initiated the callback.
	 * @param InObject	Pointer to the object that was clicked on.
	 */
	virtual void  OnDoubleClick( const class WxKismet* InEditor, USequenceObject* InObject ) const;
}
