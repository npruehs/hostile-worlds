/**
 * Custom list presenter class for the UIContextMenu.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_ContextMenuListPresenter extends UIComp_ListPresenterCascade
	within UIContextMenu
	native(inherit);

cpptext
{
	/**
	 * Resolves the element schema provider based on the owning list's data source binding, and repopulates the element schema based on
	 * the available data fields in that element schema provider.
	 */
	virtual void RefreshElementSchema();
}

DefaultProperties
{
	bDisplayColumnHeaders=false
}
