/**
 * Handles information about a collection of list elements are sorted.  Responsible for invoking the
 * UISortableItem on each element to allow the element to perform the comparison.
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_ListElementSorter extends UIComp_ListComponentBase
	native(inherit)
	editinlinenew;

/**
 * Contains parameters for a list sorting operation.
 */
struct native transient UIListSortingParameters
{
	/** the index of the column/row that should be used for first-pass sorting */
	var		int		PrimaryIndex;
	/** the index of the column/row that should be used when first pass sorting encounters two identical elements */
	var		int		SecondaryIndex;

	/** indicates that the elements should be sorted in reverse for first-pass */
	var		bool	bReversePrimarySorting;
	/** indicates that the elements should be sorted in reverse for second-pass */
	var		bool	bReverseSecondarySorting;
	/** indicates that sorting should be case sensitive */
	var		bool	bCaseSensitive;

	/** indicates that the strings should be converted into integers for sorting purposes */
	var		bool	bIntSortPrimary;
	var		bool	bIntSortSecondary;

	/** indicates that the strings should be converted into floats for sorting purposes */
	var		bool	bFloatSortPrimary;
	var		bool	bFloatSortSecondary;

structcpptext
{
	/** Constructors */
	FUIListSortingParameters()
	: PrimaryIndex(INDEX_NONE), SecondaryIndex(INDEX_NONE)
	, bReversePrimarySorting(FALSE), bReverseSecondarySorting(FALSE), bCaseSensitive(FALSE)
	, bIntSortPrimary(FALSE), bIntSortSecondary(FALSE), bFloatSortPrimary(FALSE), bFloatSortSecondary(FALSE)
	{
	}
	FUIListSortingParameters( INT InPrimaryIndex, INT InSecondaryIndex, UBOOL bReversePrimary, UBOOL bReverseSecondary, UBOOL bInCaseSensitive, UBOOL bIntSort[2], UBOOL bFloatSort[2] )
	: PrimaryIndex(InPrimaryIndex), SecondaryIndex(InSecondaryIndex)
	, bReversePrimarySorting(bReversePrimary), bReverseSecondarySorting(bReverseSecondary), bCaseSensitive(bInCaseSensitive)
	, bIntSortPrimary(bIntSort[0]), bIntSortSecondary(bIntSort[1]), bFloatSortPrimary(bFloatSort[0]), bFloatSortSecondary(bFloatSort[1])
	{
	}
}
};

/** Indicates whether sorting by multiple columns is allowed in this list */
var(Interaction)										bool	bAllowCompoundSorting<Tooltip=Enables sorting by multiple columns>;

/** the index of the column (or row) to use for sorting the list's elements when SortColumn is INDEX_NONE */
var(Interaction)										int		InitialSortColumn;

/** the index of the column (or row) to use for performing the initial secondary sorting of the list's elements when SecondarySortColumn is INDEX_NONE */
var(Interaction)										int		InitialSecondarySortColumn;

/** the index of the column (or row) being used for sorting the list's items */
var(Interaction)		editconst	transient	const	int		PrimarySortColumn;

/** the index of the column (or row) of the previous SortColumn */
var(Interaction)		editconst	transient	const	int		SecondarySortColumn;

/** indicates that the primary sort column should be sorted in reverse order */
var(Interaction)										bool	bReversePrimarySorting;

/** indicates that the secondary sort column should be sorted in reverse order */
var(Interaction)										bool	bReverseSecondarySorting;


cpptext
{
	/**
	 * Determines whether the element values should be converted to int/floats for the purposes of sorting.
	 *
	 * @param	bShouldIntSortPrimary		receives the value for whether the primary sort column should be converted to int for sorting
	 * @param	bShouldIntSortSecondary		receives the value for whether the secondary sort column should be converted to int for sorting
	 * @param	bShouldFloatSortPrimary		receives the value for whether the primary sort column should be converted to float for sorting
	 * @param	bShouldFloatSortSecondary	receives the value for whether the secondary sort column should be converted to float for sorting
	 */
	void SetNumericSortFlags( UBOOL& bShouldIntSortPrimary, UBOOL& bShouldIntSortSecondary, UBOOL& bShouldFloatSortPrimary, UBOOL& bShouldFloatSortSecondary );
}

/**
 * Provides a hook for unrealscript to manage the sorting for this list.
 *
 * @param	Sender						the list that contains this sort component.
 * @param	CollectionDataFieldName		the name of the collection data field corresponding to the list data being sorted.
 * @param	SortParameters				the parameters to use for sorting
 *										PrimaryIndex:
 *											the index [into the list schema's array of cells] for the cell which the user desires to perform primary sorting with.
 *										SecondaryIndex:
 *											the index [into the list schema's array of cells] for the cell which the user desires to perform secondary sorting with.  Not guaranteed
 *											to be a valid value; Comparison should be performed using the value of the field indicated by PrimarySortIndex, then when these
 *											values are identical, the value of the cell field indicated by SecondarySortIndex should be used.
 * @param	OrderedIndices				receives the sorted list of indices for the owning list's Items array.
 *
 * @return	TRUE to indicate that custom sorting was performed (or to prevent sorting).  Custom sorting is not required; return FALSE to have the list use
 *			its default sorting method.
 */
delegate bool OverrideListSort( UIList Sender, name CollectionFieldName, const out UIListSortingParameters SortParameters, out array<int> OrderedIndices );

/**
 * Resets the PrimarySortColumn and SecondarySortColumn to the Initial* values.
 *
 * @param	bResort	specify TRUE to re-sort the list's elements after resetting the sort columns.
 */
native final function ResetSortColumns( optional bool bResort=true );

/**
 * Sorts the owning list's items using the parameters specified.
 *
 * @param	ColumnIndex		the column (when CellLinkType is LINKED_Columns) or row (when CellLinkType is LINKED_Rows) to
 *							use for sorting.  Specify INDEX_NONE to clear sorting.
 * @param	bSecondarySort	specify TRUE to set ColumnIndex as the SecondarySortColumn.  If FALSE, resets the value of SecondarySortColumn
 * @param	bCaseSensitive	specify TRUE to perform case-sensitive comparison
 *
 * @return	TRUE if the items were sorted successfully.
 */
native final function bool SortItems( int ColumnIndex, optional bool bSecondarySort, optional bool bCaseSensitive );

/**
 * Sorts the owning list's items without modifying any sorting parameters.
 *
 * @param	bCaseSensitive	specify TRUE to perform case-sensitive comparison
 *
 * @return	TRUE if the items were sorted successfully.
 */
native final function bool ResortItems( optional bool bCaseSensitive );

DefaultProperties
{
	bAllowCompoundSorting=true

	InitialSortColumn=INDEX_NONE
	InitialSecondarySortColumn=INDEX_NONE

	PrimarySortColumn=INDEX_NONE
	SecondarySortColumn=INDEX_NONE
}
