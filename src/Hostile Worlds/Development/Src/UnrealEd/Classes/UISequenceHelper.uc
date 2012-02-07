/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UISequenceHelper extends SequenceObjectHelper
	native;

cpptext
{
	/**
	 * Called when the user right clicks on a sequence object, should show a object specific context menu.
	 *
	 * @param InEditor	Pointer to the editor that initiated the callback.
	 */
	virtual void  ShowContextMenu( class WxKismet* InEditor ) const;
}
