/**
 * Handles formatting, rendering, and data management for UIObjectList.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_ObjectListPresenter extends UIComp_ListPresenter
	within UIObjectList
	native(inherit);

cpptext
{
	/* === UUIComp_ListPresenter interface === */
	/**
	 * Wrapper for determining the optimal size of a single row in the list.  Only relevant for lists which have a CellLinkType of LINKED_None
	 * or LINKED_Columns.
	 *
	 * @param	RowIndex			the index for the row to get the height for.  If the index is invalid, returns the height of the list's
	 *								schema cells instead, which do not necessarily use the same font.
	 * @param	out_RowHeight		receives the height of the row
	 * @param	out_StylePadding	receives the value for an optional padding amount applied by the cell's style.
	 * @param	bReturnUnformattedValue
	 *							specify TRUE to return a value determined by the size of a typical character from the font applied to the cell; otherwise,
	 *							uses the cell string's calculated StringExtent, which will include any scaling that has been applied.
	 */
	virtual void CalculateAutoSizeRowHeight( INT RowIndex, FLOAT& out_RowHeight, FLOAT& out_StylePadding, UBOOL bReturnUnformattedValue=FALSE );

	/**
	 * Wrapper for determining the optimal size of a single column in the list.  Only relevant for lists which have a CellLinkType of LINKED_None
	 * or LINKED_Rows.
	 *
	 * @param	ColIndex			the index for the column to get the width for.  If the index is invalid, returns the width of the list's
	 *								schema cells instead, which do not necessarily use the same font.
	 * @param	out_ColWidth		receives the width of the column
	 * @param	out_StylePadding	receives the value for an optional padding amount applied by the cell's style.
	 * @param	bReturnUnformattedValue
	 *							specify TRUE to return a value determined by the size of a typical character from the font applied to the cell; otherwise,
	 *							uses the cell string's calculated StringExtent, which will include any scaling that has been applied.
	 */
	virtual void CalculateAutoSizeColumnWidth( INT ColIndex, FLOAT& out_ColWidth, FLOAT& out_StylePadding, UBOOL bReturnUnformattedValue=FALSE );

	/**
	 * Called when a new element is added to the list that owns this component.  Creates a UIElementCellList for the specified element.
	 *
	 * @param	InsertIndex			an index in the range of 0 - Items.Num() to use for inserting the element.  If the value is
	 *								not a valid index, the element will be added to the end of the list.
	 * @param	ElementValue		the index [into the data provider's collection] for the element that is being inserted into the list.
	 *
	 * @return	the index where the new element was inserted, or INDEX_NONE if the element wasn't added to the list.
	 */
	virtual INT InsertElement( INT InsertIndex, INT ElementValue );
}

DefaultProperties
{
	bDisplayColumnHeaders=false
}
