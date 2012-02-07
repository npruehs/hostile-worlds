/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UISequenceObjectHelper extends SequenceObjectHelper
	native;

cpptext
{
	/**
	 * Called when the user right clicks on a sequence object, should show a object specific context menu.
	 *
     * This version shows a context menu specific to UI Kismet objects.
     *
	 * @param InEditor	Pointer to the editor that initiated the callback.
	 */
	virtual void  ShowContextMenu( class WxKismet* InEditor ) const;
}
