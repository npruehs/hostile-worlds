/**
 * Base class for components which handle list element rendering, formatting, and data management.
 *
 * Resonsible for how the data associated with this list is presented.  Updates the list's operating parameters
 * (CellHeight, CellWidth, etc.) according to the presentation type for the data contained by this list.
 *
 * Routes render messages from the list to the individual elements, adding any additional data necessary for the
 * element to understand how to render itself.  For example, a listdata component might add that the element being
 * rendered is the currently selected element, so that the element can adjust the way it renders itself accordingly.
 * For a tree-type list, the listdata component might add whether the element being drawn is currently open, has
 * children, etc.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_ListPresenterBase extends UIComp_ListComponentBase
	native(inherit)
	abstract
	editinlinenew;

struct native UIListItemDataBinding
{
	/**
	 * The data provider that contains the data for this list element
	 */
	var	UIListElementCellProvider	DataSourceProvider;

	/**
	 * The name of the field from DataSourceProvider that contains the array of data corresponding to this list element
	 */
	var	name						DataSourceTag;

	/**
	 * The index into the array [DataSourceTag] in DataSourceProvider that this list element represents.
	 */
	var	int							DataSourceIndex;

	structcpptext
	{
		/** Constructors */
		FUIListItemDataBinding() {}
		FUIListItemDataBinding(EEventParm)
		{
			appMemzero(this, sizeof(FUIListItemDataBinding));
		}

		FUIListItemDataBinding( TScriptInterface<class IUIListElementCellProvider> InDataSource, FName DataTag, INT InIndex )
		: DataSourceProvider(InDataSource)
		, DataSourceTag(DataTag)
		, DataSourceIndex(InIndex)
		{}
	}

};

/** set to indicate that the cells in this list needs to recalculate their extents */
var			transient										bool				bReapplyFormatting;

cpptext
{
	friend class UUIList;

	/**
	 * Called when a new element is added to the list that owns this component.
	 *
	 * @param	InsertIndex			an index in the range of 0 - Items.Num() to use for inserting the element.  If the value is
	 *								not a valid index, the element will be added to the end of the list.
	 * @param	ElementValue		the index [into the data provider's collection] for the element that is being inserted into the list.
	 *
	 * @return	the index where the new element was inserted, or INDEX_NONE if the element wasn't added to the list.
	 */
	virtual INT InsertElement( INT InsertIndex, INT ElementValue ) PURE_VIRTUAL(UUIComp_ListPresenterBase::InsertElement,return INDEX_NONE;);

	/**
	 * Called when an element is removed from the list that owns this component.
	 *
	 * @param	RemovalIndex	the index for the element that should be removed from the list
	 *
	 * @return	the index [into the ElementCells array] for the element that was removed, or INDEX_NONE if RemovalIndex was invalid
	 *			or that element couldn't be removed from this list.
	 */
	virtual INT RemoveElement( INT RemovalIndex ) PURE_VIRTUAL(UUIComp_ListPresenterBase::RemoveElement,return INDEX_NONE;);

	/**
	 * Refreshes the value of all cells for the specified element
	 *
	 * @param	ElementIndex	the index of the element that needs to be refreshed.
	 */
	virtual void RefreshElement( INT ElementIndex ) PURE_VIRTUAL(UUIComp_ListPresenterBase::RefreshElement,);

	/**
	 * Swaps the values at the specified indexes, reversing their positions in the array of items.
	 *
	 * @param	IndexA	the index into the ListItems array for the first element to swap
	 * @param	IndexB	the index into the ListItems array for the second element to swap
	 *
	 * @param	TRUE if the swap was successful
	 */
	virtual UBOOL SwapElements( INT IndexA, INT IndexB ) PURE_VIRTUAL(UUIComp_ListPresenterBase::SwapElements,return FALSE;);

	/**
	 * Returns the text value for the specified element.
	 *
	 * @param	ElementIndex	index [into the Items array] for the value to return.
	 * @param	CellIndex		for lists which have linked columns or rows, indicates which column/row to retrieve.
	 *
	 * @return	the value of the specified element, or an empty string if that element doesn't have a text value.
	 */
	virtual FString GetElementValue( INT ElementIndex, INT CellIndex=INDEX_NONE ) const PURE_VIRTUAL(UUIComp_ListPresenterBase::GetElementValue,return TEXT(""););

	/**
	 * Allows the list presenter to override the menu state that is used for rendering a specific element in the list.  Used for those
	 * lists which need to render some elements using the disabled state, for example.
	 *
	 * @param	ElementIndex		the index into the Elements array for the element to retrieve the menu state for.
	 * @param	out_OverrideState	receives the value of the menu state that should be used for rendering this element. if a specific
	 *								menu state is desired for the specified element, this value should be set to a child of UIState corresponding
	 *								to the menu state that should be used;  only used if the return value for this method is TRUE.
	 *
	 * @return	TRUE if the list presenter assigned a value to out_OverrideState, indicating that the element should be rendered using that menu
	 *			state, regardless of which menu state the list is currently in.  FALSE if the list presenter doesn't want to override the menu
	 *			state for this element.
	 */
	virtual UBOOL GetOverrideMenuState( INT ElementIndex, UClass*& out_OverrideState ) PURE_VIRTUAL(UUIComp_ListPresenterBase::GetOverrideMenuState,return FALSE;);

	/**
	 * Resolves the element schema provider based on the owning list's data source binding, and repopulates the element schema based on
	 * the available data fields in that element schema provider.
	 */
	virtual void RefreshElementSchema() {}

	/**
	 * @return	TRUE if the index is a valid index for this component's schema cell array
	 */
	virtual UBOOL IsValidSchemaIndex( INT SchemaCellIndex ) const PURE_VIRTUAL(UUIComp_ListPresenterBase::IsValidSchemaIndex,return FALSE;);

	/**
	 * @return	TRUE if the index is a valid index for this component's list of elements.
	 */
	virtual UBOOL IsValidElementIndex( INT ElementIndex ) const PURE_VIRTUAL(UUIComp_ListPresenterBase::IsValidElementIndex,return FALSE;);

	/**
	 * Applies the value of bShouldBeDirty to the current style data for all style references in this widget.  Used to force
	 * updating of style data.
	 *
	 * @param	bShouldBeDirty	the value to use for marking the style data for the specified menu state of all style references
	 *							in this widget as dirty.
	 * @param	MenuState		if specified, the style data for that menu state will be modified; otherwise, uses the widget's current
	 *							menu state
	 */
	virtual void ToggleStyleDirtiness( UBOOL bShouldBeDirty, class UUIState* MenuState ) PURE_VIRTUAL(UUIComp_ListPresenterBase::ToggleStyleDirtiness,);

	/**
	 * Determines whether this widget references the specified style.
	 *
	 * @param	CheckStyle		the style to check for referencers
	 */
	virtual UBOOL UsesStyle( class UUIStyle* CheckStyle ) PURE_VIRTUAL(UUIComp_ListPresenterBase::UsesStyle,return FALSE;);

	/**
	 * Retrieves a reference to the custom style currently assigned to the specified cell
	 *
	 * @param	ElementState	the cell state to retrieve the custom style for
	 * @param	CellIndex		the index of the cell (column if linked columns, row if linked rows) to retrieve style for
	 *
	 * @return	a pointer to the UIStyleReference struct from the specified cell, or NULL if the state of cell index are invalid.
	 */
	virtual struct FUIStyleReference* GetCustomCellStyle( EUIListElementState ElementState, INT CellIndex ) { return NULL; }

	/**
	 * Assigns the style for the cell specified and refreshes the cell's resolved style.
	 *
	 * @param	NewStyle		the new style to assign to this widget
	 * @param	ElementState	the list element state to set the element style for
	 * @param	CellIndex		indicates the column (if columns are linked) or row (if rows are linked) to apply the style to
	 *
	 * @return	TRUE if the style was successfully applied to the cell.
	 */
	virtual UBOOL SetCustomCellStyle( class UUIStyle* NewStyle, EUIListElementState ElementState, INT CellIndex ) { return FALSE; };

	/**
	 * Applies the resolved style data for the column header style to the schema cells' strings.  This function is called anytime
	 * the header style data that is applied to the schema cells is no longer valid, such as when the owning list's menu state is changed.
	 *
	 * @param	ResolvedStyle			the style resolved by the style reference
	 */
	virtual void ApplyColumnHeaderStyle( UUIStyle* ResolvedStyle ) {}

	/**
	 * Notification that the list's style has been changed.  Updates the cached cell styles for all elements for the specified
	 * list element state.
	 *
	 * @param	ElementState	the list element state to update the element style for
	 */
	virtual void OnListStyleChanged( EUIListElementState ElementState ) {}

	/**
	 * Notification that the list's menu state has changed.  Reapplies the specified cell style for all elements based on the
	 * new menu state.
	 *
	 * @param	ElementState	the list element state to update the element style for
	 */
	virtual void OnListMenuStateChanged( EUIListElementState ElementState ) {}

	/**
	 * Renders the elements in this list.
	 *
	 * @param	RI					the render interface to use for rendering
	 */
	virtual void Render_List( FCanvas* Canvas ) PURE_VIRTUAL(UUIComp_ListPresenterBase::Render_List,);

	/**
	 * Notifies the owning widget that the formatting and render parameters for the list need to be updated.
	 *
	 * @param	bRequestSceneUpdate		if TRUE, requests the scene to update the positions for all widgets at the beginning of the next frame
	 */
	virtual void ReapplyFormatting( UBOOL bRequestSceneUpdate=TRUE );

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
	virtual void CalculateAutoSizeRowHeight( INT RowIndex, FLOAT& out_RowHeight, FLOAT& out_StylePadding, UBOOL bReturnUnformattedValue=FALSE ) PURE_VIRTUAL(UUIComp_ListPresenterBase::CalculateAutoSizeRowHeight,);

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
	virtual void CalculateAutoSizeColumnWidth( INT ColIndex, FLOAT& out_ColWidth, FLOAT& out_StylePadding, UBOOL bReturnUnformattedValue=FALSE ) PURE_VIRTUAL(UUIComp_ListPresenterBase::CalculateAutoSizeColumnWidth,);

	/**
	 * Wrapper for setting the maximum number of elements that will be displayed by the list at once.
	 *
	 * @param	NewMaxVisibleElements	the maximum number of elements to show at a time. 0 to disable.
	 */
	virtual void SetMaxElementsPerPage( INT NewMaxVisibleElements ) PURE_VIRTUAL(UUIComp_ListPresenterBase::SetMaxElementsPerPage,);

	/**
	 * Wrapper for retrieving the current value of MaxElementsPerPage
	 */
	virtual INT GetMaxElementsPerPage() const PURE_VIRTUAL(UUIComp_ListPresenterBase::GetMaxElementsPerPage,return 0;);

	/**
	 * Evalutes the Position value for the specified face into an actual pixel value.  Adjusts the owning widget's bounds
	 * according to the wrapping mode and autosize behaviors.
	 *
	 * @param	Face	the face that should be resolved
	 */
	void ResolveFacePosition( EUIWidgetFace Face );

	/**
	 * Returns the number of rows the list can dislay
	 */
	INT GetMaxNumVisibleRows() const;

	/**
	 * Returns the number of columns the list can display
	 */
	INT GetMaxNumVisibleColumns() const;

	/**
	 * Returns the total number of rows in this list.
	 */
	INT GetTotalRowCount() const;

	/**
	 * Returns the total number of columns in this list.
	 */
	INT GetTotalColumnCount() const;

	/**
	 * Returns whether element size is determined by the elements themselves.  For lists with linked columns, returns whether
	 * the item height is autosized; for lists with linked rows, returns whether item width is autosized.
	 */
	UBOOL IsElementAutoSizingEnabled() const;

	/**
	 * @return the number of cells in the list's schema
	 */
	virtual INT GetSchemaCellCount() const { return 0; }

	/**
	 * Determine the size of the schema cell at the specified index.
	 *
	 * @param	SchemaCellIndex		the index of the schema cell to get the size for
	 * @param	EvalType			the desired format to return the size in.
	 *
	 * @return	the size of the schema cell at the specified index in the desired format, or -1 if the index is invalid.
	 */
	virtual FLOAT GetSchemaCellSize( INT SchemaCellIndex, EUIExtentEvalType EvalType=UIEXTENTEVAL_Pixels ) const { return -1.f; }

	/**
	 * Change the size of the schema cell at the specified index.
	 *
	 * @param	SchemaCellIndex		the index of the schema cell to set the size for
	 * @param	NewCellSize			the new size for the cell
	 * @param	EvalType			indicates how to evalute the input value
	 *
	 * @return	TRUE if the size was updated successfully; FALSE if the size was not changed or the index was invalid.
	 */
	virtual UBOOL SetSchemaCellSize( INT SchemaCellIndex, FLOAT NewCellSize, EUIExtentEvalType EvalType=UIEXTENTEVAL_Pixels ) { return FALSE; }

	/**
	 * Retrieves the position of the left or top of the cell specified.  For lists with linked columns, SchemaCellIndex would correspond to the column;
	 * for cells with linked rows, it would represent the row index.
	 *
	 * @param	SchemaCellIndex		the index of the schema cell to get the position for
	 *
	 * @return	the position for the specified cell, in screen space absolute pixels relative to 0,0, or -1 if the cell index is invalid.
	 */
	virtual FLOAT GetSchemaCellPosition( INT SchemaCellIndex ) const { return -1.f; }

protected:
	/**
	 * Changes the cell state for the specified element.
	 *
	 * @param	ElementIndex	the index of the element to change states for
	 * @param	NewElementState	the new state to place the element in
	 *
	 * @return	TRUE if the new state was successfully applied to the new element, FALSE otherwise.
	 */
	virtual UBOOL SetElementState( INT ElementIndex, EUIListElementState NewElementState ) PURE_VIRTUAL(UUIComp_ListPresenterBase::SetElementState,return FALSE;);

	/**
	 * @return	the cell state for the specified element, or ELEMENT_MAX if the index is invalid.
	 */
	virtual EUIListElementState GetElementState( INT ElementIndex ) const PURE_VIRTUAL(UUIComp_ListPresenterBase::GetElementState,return ELEMENT_MAX;);

public:
	/**
	 * Determines the appropriate position for the selection hint object based on the size of the list's rows and any padding that must be taken
	 * into account.
	 *
	 * @param	SelectionHintObject		the widget that will display the selection hint (usually a label).
	 * @param	ElementIndex			the index of the element to display the selection hint next to.
	 */
	virtual UBOOL SetSelectionHintPosition( UUIObject* SelectionHintObject, INT ElementIndex ) { return FALSE; }

protected:
	/**
	 * Determines the maximum number of elements which can be rendered given the owning list's bounding region.
	 */
	virtual void CalculateVisibleElements( FRenderParameters& Parameters );

	/**
	 * Initializes the render parameters that will be used for formatting the list elements.
	 *
	 * @param	Face			the face that was being resolved
	 * @param	out_Parameters	[out] the formatting parameters to use when calling ApplyFormatting.
	 *
	 * @return	TRUE if the formatting data is ready to be applied to the list elements, taking into account the autosize settings.
	 */
	virtual UBOOL GetListRenderParameters( EUIWidgetFace Face, FRenderParameters& out_Parameters );

	/**
	 * Wrapper for getting the docking-state of the owning widget's four faces.  No special logic here, but child classes
	 * can use this method to make the formatting code ignore the fact that the widget may be docked (in cases where it is
	 * irrelevant)
	 *
	 * @param	bFaceDocked		[out] an array of bools representing whether the widget is docked on the respective face.
	 */
	virtual void GetOwnerDockingState( UBOOL* bFaceDocked[UIFACE_MAX] ) const;

	/**
	 * Adjusts the owning widget's bounds according to the autosize settings.
	 */
	virtual void UpdateOwnerBounds( FRenderParameters& Parameters );

	/**
	 * Setup the left, top, width, and height values that will be used to render the list.  This will typically be the list's
	 * RenderBounds, unless the elements should be rendered in a subportion of the list.
	 *
	 * @fixme ronp - mmmmm, this is a bit hacky..  we're already doing something similar on the formatting side...seems like
	 * we should be able to leverage that work so that we don't get out of sync.  :\
	 */
	virtual void InitializeRenderingParms( FRenderParameters& Parameters, FCanvas* Canvas=NULL );

	/**
	 * Calculates the maximum number of visible elements and calls ApplyElementFormatting for all elements.
	 *
	 * @param	Parameters		@see UUIString::ApplyFormatting())
	 */
	virtual void ApplyListFormatting( FRenderParameters& Parameters );

	/**
	 * Updates the formatting parameters for all cells of the specified element.
	 *
	 * @param	ElementIndex	the list element to apply formatting for.
	 * @param	Parameters		@see UUIString::ApplyFormatting())
	 */
	virtual void ApplyElementFormatting( INT ElementIndex, FRenderParameters& Parameters ) PURE_VIRTUAL(UUIComp_ListPresenterBase::ApplyElementFormatting,);

	/**
	 * Wrapper for applying formatting to the schema cells.
	 */
	virtual void FormatSchemaCells( FRenderParameters& Parameters ) {};

	/**
	 * Renders the list element specified.
	 *
	 * @param	Canvas			the canvas to use for rendering
	 * @param	ElementIndex	the list element to render
	 * @param	Parameters		Used for various purposes:
	 *							DrawX:		[in]	specifies the pixel location of the start of the horizontal bounding region that should be used for
	 *												rendering this element
	 *										[out]	unused
	 *							DrawY:		[in]	specifies the pixel Y location of the bounding region that should be used for rendering this list element.
	 *										[out]	Will be set to the Y position of the rendering "pen" after rendering this element.  This is the Y position for rendering
	 *												the next element should be rendered
	 *							DrawXL:		[in]	specifies the pixel location of the end of the horizontal bounding region that should be used for rendering this element.
	 *										[out]	unused
	 *							DrawYL:		[in]	specifies the height of the bounding region, in pixels.  If this value is not large enough to render the specified element,
	 *												the element will not be rendered.
	 *										[out]	Will be reduced by the height of the element that was rendered. Thus represents the "remaining" height available for rendering.
	 *							DrawFont:	[in]	specifies the font to use for retrieving the size of the characters in the string
	 *							Scale:		[in]	specifies the amount of scaling to apply when rendering the element
	 */
	virtual void Render_ListElement( FCanvas* Canvas, INT ElementIndex, FRenderParameters& Parameters ) PURE_VIRTUAL(UUIComp_ListPresenterBase::Render_ListElement,);

	/**
	 * Retrieves the list of data stores bound by this subscriber.
	 *
	 * @param	out_BoundDataStores		receives the array of data stores that subscriber is bound to.
	 */
	virtual void GetBoundDataStores(TArray<class UUIDataStore*>& out_BoundDataStores) PURE_VIRTUAL(UUIComp_ListPresenterBase::GetBoundDataStores,);

	/**
	 * Changes the data binding for the specified cell index.
	 *
	 * @param	CellDataBinding		a name corresponding to a tag from the UIListElementProvider currently bound to this list.
	 * @param	ColumnHeader		the string that should be displayed in the column header for this cell.
	 * @param	BindingIndex		the column or row to bind this data field to.  If BindingIndex is greater than the number
	 *								schema cells, empty schema cells will be added to meet the number required to place the data
	 *								at BindingIndex.
	 *								If a value of INDEX_NONE is specified, the cell binding will only occur if there are no other
	 *								schema cells bound to that data field.  In this case, a new schema cell will be appended and
	 *								it will be bound to the data field specified.
	 */
	virtual UBOOL SetCellBinding( FName CellDataBinding, const FString& ColumnHeader, INT BindingIndex ) PURE_VIRTUAL(UUIComp_ListPresenterBase::SetCellBinding,return FALSE;);

	/**
	 * Inserts a new schema cell at the specified index and assigns the data binding.
	 *
	 * @param	InsertIndex			the column/row to insert the schema cell; must be a valid index.
	 * @param	CellDataBinding		a name corresponding to a tag from the UIListElementProvider currently bound to this list.
	 * @param	ColumnHeader	the string that should be displayed in the column header for this cell.
	 *
	 * @return	TRUE if the schema cell was successfully inserted into the list
	 */
	virtual UBOOL InsertSchemaCell( INT InsertIndex, FName CellDataBinding, const FString& ColumnHeader ) PURE_VIRTUAL(UUIComp_ListPresenterBase::InsertSchemaCell,return FALSE;);

	/**
	 * Retrieves the name of the binding for the specified location in the schema.
	 *
	 * @param	BindingIndex	the index for the cell/column to get the binding for
	 *
	 * @return	the value assigned to the schema cell at the specified location, or NAME_None if the binding index is invalid.
	 */
	virtual FName GetCellBinding( INT BindingIndex ) const PURE_VIRTUAL(UUIComp_ListPresenterBase::GetCellBinding,return NAME_None;);

	/**
	 * Removes all schema cells which are bound to the specified data field.
	 *
	 * @return	TRUE if one or more schema cells were successfully removed.
	 */
	virtual UBOOL ClearCellBinding( FName CellDataBinding ) PURE_VIRTUAL(UUIComp_ListPresenterBase::ClearCellBinding,return FALSE;);

	/**
	 * Removes schema cells at the location specified.  If the list's columns are linked, this index should correspond to
	 * the column that should be removed; if the list's rows are linked, this index should correspond to the row that should
	 * be removed.
	 *
	 * @return	TRUE if the schema cell at BindingIndex was successfully removed.
	 */
	virtual UBOOL ClearCellBinding( INT BindingIndex ) PURE_VIRTUAL(UUIComp_ListPresenterBase::ClearCellBinding,return FALSE;);

	/**
	 * Wrapper for changing the surface assigned to a UITexture contained by this component.
	 *
	 * @param	ImageRef	the UITexture that will be created and/or updated
	 * @param	NewImage	the texture or material to apply to the ImageRef.
	 */
	void SetImage( UUITexture** ImageRef, USurface* NewImage );
}

/* == Delegates == */

/* == Natives == */
/**
 * Returns the object that provides the cell schema for this component's owner list (usually the class default object for
 * the class of the owning list's list element provider)
 */
native final function UIListElementCellProvider GetCellSchemaProvider() const;

/**
 * @return the number of cells in the list's schema
 */
native final noexportheader function int GetSchemaCellCount() const;

/**
 * Determine the size of the schema cell at the specified index.
 *
 * @param	SchemaCellIndex		the index of the schema cell to get the size for
 * @param	EvalType			the desired format to return the size in.
 *
 * @return	the size of the schema cell at the specified index in the desired format, or -1 if the index is invalid.
 */
native final noexport function float GetSchemaCellSize( int SchemaCellIndex, optional EUIExtentEvalType EvalType=UIEXTENTEVAL_Pixels ) const;

/**
 * Change the size of the schema cell at the specified index.
 *
 * @param	SchemaCellIndex		the index of the schema cell to set the size for
 * @param	NewCellSize			the new size for the cell
 * @param	EvalType			indicates how to evalute the input value
 *
 * @return	TRUE if the size was updated successfully; FALSE if the size was not changed or the index was invalid.
 */
native final noexport function bool SetSchemaCellSize( int SchemaCellIndex, float NewCellSize, optional EUIExtentEvalType EvalType=UIEXTENTEVAL_Pixels );

/**
 * Retrieves the position of the left or top of the cell specified.  For lists with linked columns, SchemaCellIndex would correspond to the column;
 * for cells with linked rows, it would represent the row index.
 *
 * @param	SchemaCellIndex		the index of the schema cell to get the position for
 *
 * @return	the position for the specified cell, in screen space absolute pixels relative to 0,0, or -1 if the cell index is invalid.
 */
native final noexportheader function float GetSchemaCellPosition( int SchemaCellIndex ) const;

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
 *
 * @note: noexport because it is pure virtual natively
 */
native final noexportheader function CalculateAutoSizeRowHeight( int RowIndex, out float out_RowHeight, out float out_StylePadding, optional bool bReturnUnformattedValue );

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
 *
 * @note: noexport because it is pure virtual natively
 */
native final noexportheader function CalculateAutoSizeColumnWidth( int ColIndex, out float out_ColWidth, out float out_StylePadding, optional bool bReturnUnformattedValue );

/**
 * Returns whether the list's bounds will be adjusted for the specified orientation considering the list's configured
 * autosize and cell link type values.
 *
 * @param	Orientation		the orientation to check auto-sizing for
 */
native final function bool ShouldAdjustListBounds( EUIOrientation Orientation ) const;

/**
 * Returns whether this list should render column headers
 */
virtual native final function bool ShouldRenderColumnHeaders() const;

/**
 * Changes whether this list renders colum headers or not.  Only applicable if the owning list's CellLinkType is LINKED_Columns
 */
virtual native final function EnableColumnHeaderRendering( bool bShouldRenderColHeaders=true );

/**
 * Returns the text value for the specified element.
 *
 * @param	ElementIndex	index [into the Items array] for the value to return.
 * @param	CellIndex		for lists which have linked columns or rows, indicates which column/row to retrieve.
 *
 * @return	the value of the specified element, or an empty string if that element doesn't have a text value.
 *
 * @note: noexport because it is pure virtual natively
 */
native final noexportheader function string GetElementValue( int ElementIndex, optional int CellIndex=INDEX_NONE ) const;

/**
 * Wrapper for setting the maximum number of elements that will be displayed by the list at once.
 *
 * @param	NewMaxVisibleElements	the maximum number of elements to show at a time. 0 to disable.
 */
native final noexportheader function SetMaxElementsPerPage( int NewMaxVisibleElements );

/**
 * Wrapper for retrieving the current value of MaxElementsPerPage
 */
native final noexportheader function int GetMaxElementsPerPage() const;

/* == Events == */

/* == UnrealScript == */

/* == SequenceAction handlers == */



DefaultProperties
{
	bReapplyFormatting=true
}
