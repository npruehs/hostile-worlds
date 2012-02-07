`include(UIDev.uci)
/**
 * A list which has UIObjects as elements.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIObjectList extends UIList
	native(inherit)
	Placeable;

/* == Delegates == */

/* == Natives == */
/**
 * Returns the widget for the specified element.
 *
 * @param	ElementIndex	index [into the Items array] for the value to return.
 * @param	CellIndex		for lists which have linked columns or rows, indicates which column/row to retrieve.
 *
 * @return	the value of the specified element, or an empty string if that element doesn't have a text value.
 */
native final function UIObject GetElementObjectValue( int ElementIndex, optional int CellIndex=INDEX_NONE ) const;

/* == Events == */

/* == UnrealScript == */

/* == SequenceAction handlers == */

/* == Delegate handlers == */


DefaultProperties
{
	Begin Object Class=UIComp_ObjectListPresenter Name=ObjectListPresenter
	End Object
	CellDataComponent=ObjectListPresenter
}
