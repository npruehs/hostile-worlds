/**
 * Presentation component for lists which present their data in standard report format.  This presenter currently supports
 * single or multiple column lists (landscape lists, which are basically multi-column lists turned sideways) do not currently
 * work correctly.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_ListPresenter extends UIComp_ListPresenterBase
	native(inherit)
	DependsOn(UIDataStorePublisher)
	implements(CustomPropertyItemHandler);

/**
 * Corresponds to a single cell in a UIList (intersection of a row and column).  Generally maps directly to a
 * single item in the list, but in the case of multiple columns or rows, a single list item may be associated with
 * multiple UIListElementCells (where each column for that row is represented by a UIListElementCell).
 *
 * The data for a UIListElementCell is accessed using a UIString. Contains one UIListCellRegion per UIStringNode
 * in the UIString, which can be configured to manually controls the extent for each UIStringNode.
 */
struct native UIListElementCell
{
	/** index of the UIListElement that contains this UIListElementCell */
	var	const	native	transient	int					ContainerElementIndex;

	/** pointer to the list that contains this element cell */
	var	const	transient	UIList						OwnerList;

	/**
	 * Allows the designer to specify a different style for each cell in a column/row
	 */
	var						UIStyleReference			CellStyle[EUIListElementState.ELEMENT_MAX];

	/** A UIString which contains data for this cell */
	var	noexport	transient	private	Object			ValueObject;

	structcpptext
	{
		union { class UUIObject* ValueChild; class UUIListString* ValueString; };

		/** Script Constructors */
		FUIListElementCell()
		: ContainerElementIndex(INDEX_NONE), OwnerList(NULL), ValueChild(NULL)
		{}
		FUIListElementCell(EEventParm);

		/**
		 * Called when this cell is created while populating the elements for the owning list. Creates the cell's UIListString.
		 */
		void OnCellCreated( INT ElementIndex, class UUIList* inOwnerList );

		/**
		 * Called when this cell is created while populating the elements for the owning list. Assigns the specified
		 * widget as the value for ValueChild.
		 */
		void OnCellCreated( INT ElementIndex, class UUIList* inOwnerList, class UUIObject* CellWidget );

		/**
		 * Resolves the value of the specified tag from the DataProvider and assigns the result to this cell's ValueString.
		 *
		 * @param	DataSource		the data source to use for populating this cell's data
		 * @param	CellBindingTag	the tag (from the list supported by DataProvider) that should be associated with this
		 *							UIListElementCell.
		 *
		 * @note: even though this method is overridden in FUIListElementCellTemplate, it is intended to be non-virtual!
		 */
		void AssignBinding( struct FUIListItemDataBinding& DataSource, FName CellBindingTag );

		/**
		 * Resolves the CellStyle for the specified element state using the currently active skin.  This function is called
		 * anytime the cached cell style no longer is out of date, such as when the currently active skin has been changed.
		 *
		 * @param	ElementState	the list element state to update the element style for
		 */
		void ResolveCellStyles( EUIListElementState ElementState );

		/**
		 * Propagates the style data for the current menu state and element state to each cell .  This function is called anytime
		 * the style data that is applied to each cell is no longer valid, such as when the cell's CellState changes or when the
		 * owning list's menu state is changed.
		 *
		 * @param	ElementState	the list element state to update the element style for
		 */
		void ApplyCellStyleData( EUIListElementState ElementState );

		/**
		 * @return	the list element (UIListItem) that contains this cell
		 */
		struct FUIListItem* GetContainerElement() const;

		/**
		 * @return	TRUE if this cell displays a UIObject rather than a string.
		 */
		UBOOL IsObjectCell() const;
	}

	structdefaultproperties
	{
		CellStyle(ELEMENT_Normal)=(RequiredStyleClass=class'Engine.UIStyle_Combo')
		CellStyle(ELEMENT_Active)=(RequiredStyleClass=class'Engine.UIStyle_Combo')
		CellStyle(ELEMENT_Selected)=(RequiredStyleClass=class'Engine.UIStyle_Combo')
		CellStyle(ELEMENT_UnderCursor)=(RequiredStyleClass=class'Engine.UIStyle_Combo')
	}
};


/**
 * Contains the data binding information for a single row or column in a list.  Also used for rendering the list's column
 * headers, if configured to do so.
 */
struct native UIListElementCellTemplate extends UIListElementCell
{
	/**
	 * Contains the data binding for each cell group in the list (row if columns are linked, columns if
	 * rows are linked, individual cells if neither are linked
	 */
	var()	editinline 				name				CellDataField;

	/**
	 * The string that should be rendered in the header for the column which displays the data for this cell.
	 */
	var()							string				ColumnHeaderText;

	/**
	 * The custom size for the linked cell (column/row).  A value of 0 indicates that the row/column's size should be
	 * controlled by the owning list according to its cell auto-size configuration.
	 */
	var()					UIScreenValue_Extent		CellSize;

	/**
	 * The starting position of this cell, in absolute pixels.
	 */
	var								float				CellPosition;

	structcpptext
	{
		/** Script Constructor */
		FUIListElementCellTemplate() {}
		FUIListElementCellTemplate(EEventParm);

		/**
		 * Called when this cell is created while populating the elements for the owning list. Creates the cell's UIListString.
		 */
		void OnCellCreated( class UUIList* inOwnerList );

		/**
		 * Initializes the specified cell based on this cell template.
		 *
		 * @param	DataSource		the information about the data source for this element
		 * @param	TargetCell		the cell to initialize.
		 */
		void InitializeCell( struct FUIListItemDataBinding& DataSource, struct FUIListElementCell& TargetCell );

		/**
		 * Resolves the value of the specified tag from the DataProvider and assigns the result to this cell's ValueString.
		 *
		 * @param	DataProvider	the object which contains the data for this element cell.
		 * @param	CellBindingTag	the tag (from the list supported by DataProvider) that should be associated with this
		 *							UIListElementCell.
		 * @param	ColumnHeader	the string that should be displayed in the column header for this cell.
		 */
		void AssignBinding( TScriptInterface<class IUIListElementCellProvider> DataProvider, FName CellBindingTag, const FString& ColumnHeader );

		/**
		 * Applies the resolved style data for the column header style to the schema cells' strings.  This function is called anytime
		 * the header style data that is applied to the schema cells is no longer valid, such as when the owning list's menu state is changed.
		 *
		 * @param	ResolvedStyle			the style resolved by the style reference
		 */
		void ApplyHeaderStyleData( UUIStyle* ResolvedStyle );
	}
};

/**
 * Corresponds to a single item in a UIList, which may be any type of data structure.
 *
 * Contains a list of UIListElementCells, which correspond to one or more data fields of the underlying data
 * structure associated with the list item represented by this object.  For linked-column lists, each
 * UIListElementCell is typically associated with a different field from the underlying data structure.
 */
struct native UIListItem
{
	/** The list element associated with the cells contained by this UIListItem. */
	var	const						UIListItemDataBinding					DataSource;

	/** the cells associated with this list element */
	var()	editinline editconst editfixedsize	array<UIListElementCell>	Cells;

	/** The current state of this cell (selected, active, etc.) */
	var()	editconst	transient 	noimport EUIListElementState			ElementState;

	/**
	 * Holds the widget associated with this list item for object lists.
	 */
	var()	editinline editconst 	UIObject								ElementWidget;

	structcpptext
	{
		/** Script Constructors */
		FUIListItem() {}
		FUIListItem(EEventParm)
		{
			appMemzero(this, sizeof(FUIListItem));
		}

		/** Standard ctor */
		FUIListItem( const struct FUIListItemDataBinding& InDataSource, UUIObject* inValueChild=NULL );

		/**
		 * Changes the ElementState for this element and refreshes its cell's cached style references based on the new cell state
		 *
		 * @param	NewElementState	the new element state to use.
		 *
		 * @return	TRUE if the element state actually changed.
		 */
		UBOOL SetElementState( EUIListElementState NewElementState );
	}
};

/**
 * Contains the data store bindings for the individual cells of a single element in this list.  This struct is used
 * for looking up the data required to fill the cells of a list element when a new element is added.
 */
struct native UIElementCellSchema
{
	/** contains the data store bindings used for creating new elements in this list */
	var() editinline	array<UIListElementCellTemplate>	Cells;

	structcpptext
	{
		/** Script Constructors */
		FUIElementCellSchema() {}
		FUIElementCellSchema(EEventParm)
		{
			appMemzero(this, sizeof(FUIElementCellSchema));
		}
	}
};


/**
 * Contains the formatting information configured for each individual cell in the UI editor.
 * Private/const because changing the value of this property invalidates all data in this, requiring that all data be refreshed.
 */
var(Data)		const protected								UIElementCellSchema		ElementSchema;

/** the amount of padding between the left side of the list and the left side of the selection hint widget */
var(Appearance)												UIScreenValue_Extent	SelectionHintPadding;

/**
 * Contains the element cells for each list item.  Each item in the ElementCells array is the list of
 * UIListElementCells for the corresponding element in the list.
 */
var(Data)	editconst	editinline	transient noimport	init	array<UIListItem>	ListItems;

/**
 * Optional background image for the column headers; only applicable if bDisplayColumnHeaders is TRUE.
 *
 * @note: if this variable is removed or moved to another class, IsCustomPropertyValueIdentical and EditorSetPropertyValue must be updated as well
 */
var(Style)	instanced	editinlineuse						UITexture				ColumnHeaderBackground[EColumnHeaderState.COLUMNHEADER_MAX]<EditCondition=bDisplayColumnHeaders>;

/**
 * The image to render over each element.
 *
 * @note: if this variable is removed or moved to another class, IsCustomPropertyValueIdentical and EditorSetPropertyValue must be updated as well
 */
var(Style)	instanced	editinlineuse						UITexture				ListItemOverlay[EUIListElementState.ELEMENT_MAX];

/**
 * Texture atlas coordinates for the column header background textures; only applicable if bDisplayColumnHeaders is TRUE.
 * Values of 0 indicate that the texture is not part of an atlas.
 */
var(Style)													TextureCoordinates		ColumnHeaderBackgroundCoordinates[EColumnHeaderState.COLUMNHEADER_MAX]<EditCondition=bDisplayColumnHeaders>;

/**
 * the texture atlas coordinates for the SelectionOverlay. Values of 0 indicate that the texture is not part of an atlas.
 */
var(Style)													TextureCoordinates		ListItemOverlayCoordinates[EUIListElementState.ELEMENT_MAX];

/**
 * The maximum number of items to display at once; only applicable when the list has linked columns and the RowAutoSizeMode is set to
 * adjust list bounds.  Use 0 to disable.
 */
var(Appearance)		private{private}								int				MaxElementsPerPage;

/** Controls whether column headers are rendered for this list */
var(Appearance)		private{private}								bool			bDisplayColumnHeaders;

cpptext
{
	friend class UUIList;

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

	/**
	 * Called when an element is removed from the list that owns this component.  Removes the UIElementCellList located at the
	 * specified index.
	 *
	 * @param	RemovalIndex	the index for the element that should be removed from the list
	 *
	 * @return	the index [into the ElementCells array] for the element that was removed, or INDEX_NONE if RemovalIndex was invalid
	 *			or that element couldn't be removed from this list.
	 */
	virtual INT RemoveElement( INT RemovalIndex );

	/**
	 * Refreshes the value of all cells for the specified element
	 *
	 * @param	ElementIndex	the index of the element that needs to be refreshed.
	 */
	virtual void RefreshElement( INT ElementIndex );

	/**
	 * Swaps the values at the specified indexes, reversing their positions in the ListItems array.
	 *
	 * @param	IndexA	the index into the ListItems array for the first element to swap
	 * @param	IndexB	the index into the ListItems array for the second element to swap
	 *
	 * @param	TRUE if the swap was successful
	 */
	virtual UBOOL SwapElements( INT IndexA, INT IndexB );

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
	virtual FString GetElementValue( INT ElementIndex, INT CellIndex=INDEX_NONE ) const;

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
	 *
	 * @note: noexport because it is pure virtual natively
	 */
	virtual void CalculateAutoSizeColumnWidth( INT ColIndex, FLOAT& out_ColWidth, FLOAT& out_StylePadding, UBOOL bReturnUnformattedValue=FALSE );

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
	virtual UBOOL GetOverrideMenuState( INT ElementIndex, UClass*& out_OverrideState );

	/**
	 * Resolves the element schema provider based on the owning list's data source binding, and repopulates the element schema based on
	 * the available data fields in that element schema provider.
	 */
	virtual void RefreshElementSchema();

	/**
	 * Applies the value of bShouldBeDirty to the current style data for all style references in this widget.  Used to force
	 * updating of style data.
	 *
	 * @param	bShouldBeDirty	the value to use for marking the style data for the specified menu state of all style references
	 *							in this widget as dirty.
	 * @param	MenuState		if specified, the style data for that menu state will be modified; otherwise, uses the widget's current
	 *							menu state
	 */
	virtual void ToggleStyleDirtiness( UBOOL bShouldBeDirty, class UUIState* MenuState );

	/**
	 * Determines whether this widget references the specified style.
	 *
	 * @param	CheckStyle		the style to check for referencers
	 */
	virtual UBOOL UsesStyle( class UUIStyle* CheckStyle );

	/**
	 * Retrieves a reference to the custom style currently assigned to the specified cell
	 *
	 * @param	ElementState	the cell state to retrieve the custom style for
	 * @param	CellIndex		the index of the cell (column if linked columns, row if linked rows) to retrieve style for
	 *
	 * @return	a pointer to the UIStyleReference struct from the specified cell, or NULL if the state of cell index are invalid.
	 */
	virtual FUIStyleReference* GetCustomCellStyle( EUIListElementState ElementState, INT CellIndex );

	/**
	 * Assigns the style for the cell specified and refreshes the cell's resolved style.
	 *
	 * @param	NewStyle		the new style to assign to this widget
	 * @param	ElementState	the list element state to set the element style for
	 * @param	CellIndex		indicates the column (if columns are linked) or row (if rows are linked) to apply the style to
	 *
	 * @return	TRUE if the style was successfully applied to the cell.
	 */
	virtual UBOOL SetCustomCellStyle( class UUIStyle* NewStyle, EUIListElementState ElementState, INT CellIndex );

	/**
	 * Applies the resolved style data for the column header style to the schema cells' strings.  This function is called anytime
	 * the header style data that is applied to the schema cells is no longer valid, such as when the owning list's menu state is changed.
	 *
	 * @param	ResolvedStyle			the style resolved by the style reference
	 */
	virtual void ApplyColumnHeaderStyle( UUIStyle* ResolvedStyle );

	/**
	 * Notification that the list's style has been changed.  Updates the cached cell styles for all elements for the specified
	 * list element state.
	 *
	 * @param	ElementState	the list element state to update the element style for
	 */
	virtual void OnListStyleChanged( EUIListElementState ElementState );

	/**
	 * Notification that the list's menu state has changed.  Reapplies the specified cell style for all elements based on the
	 * new menu state.
	 *
	 * @param	ElementState	the list element state to update the element style for
	 */
	virtual void OnListMenuStateChanged( EUIListElementState ElementState );

	/**
	 * Renders the elements in this list.
	 *
	 * @param	RI					the render interface to use for rendering
	 */
	virtual void Render_List( FCanvas* Canvas );

protected:
	/**
	 * Changes the cell state for the specified element.
	 *
	 * @param	ElementIndex	the index of the element to change states for
	 * @param	NewElementState	the new state to place the element in
	 *
	 * @return	TRUE if the new state was successfully applied to the new element, FALSE otherwise.
	 */
	virtual UBOOL SetElementState( INT ElementIndex, EUIListElementState NewElementState );

	/**
	 * @return	the cell state for the specified element, or ELEMENT_MAX if the index is invalid.
	 */
	virtual EUIListElementState GetElementState( INT ElementIndex ) const;

public:
	/**
	 * @return	TRUE if the index is a valid index for this component's schema cell array
	 */
	virtual UBOOL IsValidSchemaIndex( INT SchemaCellIndex ) const;

	/**
	 * @return	TRUE if the index is a valid index for this component's list of elements.
	 */
	virtual UBOOL IsValidElementIndex( INT ElementIndex ) const;

	/**
	 * Determines the appropriate position for the selection hint object based on the size of the list's rows and any padding that must be taken
	 * into account.
	 *
	 * @param	SelectionHintObject		the widget that will display the selection hint (usually a label).
	 * @param	ElementIndex			the index of the element to display the selection hint next to.
	 */
	virtual UBOOL SetSelectionHintPosition( UUIObject* SelectionHintObject, INT ElementIndex );

	/**
	 * Determine the size of the schema cell at the specified index.
	 *
	 * @param	SchemaCellIndex		the index of the schema cell to get the size for
	 * @param	EvalType			the desired format to return the size in.
	 *
	 * @return	the size of the schema cell at the specified index in the desired format, or -1 if the index is invalid.
	 */
	virtual FLOAT GetSchemaCellSize( INT SchemaCellIndex, EUIExtentEvalType EvalType=UIEXTENTEVAL_Pixels ) const;

	/**
	 * Change the size of the schema cell at the specified index.
	 *
	 * @param	SchemaCellIndex		the index of the schema cell to set the size for
	 * @param	NewCellSize			the new size for the cell
	 * @param	EvalType			indicates how to evalute the input value
	 *
	 * @return	TRUE if the size was updated successfully; FALSE if the size was not changed or the index was invalid.
	 */
	virtual UBOOL SetSchemaCellSize( INT SchemaCellIndex, FLOAT NewCellSize, EUIExtentEvalType EvalType=UIEXTENTEVAL_Pixels );

	/**
	 * Retrieves the position of the left or top of the cell specified.  For lists with linked columns, SchemaCellIndex would correspond to the column;
	 * for cells with linked rows, it would represent the row index.
	 *
	 * @param	SchemaCellIndex		the index of the schema cell to get the position for
	 *
	 * @return	the position for the specified cell, in screen space absolute pixels relative to 0,0, or -1 if the cell index is invalid.
	 */
	virtual FLOAT GetSchemaCellPosition( INT SchemaCellIndex ) const;

	/**
	 * @return the number of cells in the list's schema
	 */
	virtual INT GetSchemaCellCount() const;

	/**
	 * Returns whether this list should render column headers
	 */
	virtual UBOOL ShouldRenderColumnHeaders() const;

	/**
	 * Changes whether this list renders colum headers or not.  Only applicable if the owning list's CellLinkType is LINKED_Columns
	 */
	virtual void EnableColumnHeaderRendering( UBOOL bShouldRenderColHeaders=TRUE );

	/**
	 * Wrapper for setting the maximum number of elements that will be displayed by the list at once.
	 *
	 * @param	NewMaxVisibleElements	the maximum number of elements to show at a time. 0 to disable.
	 */
	virtual void SetMaxElementsPerPage( INT NewMaxVisibleElements );

	/**
	 * Wrapper for retrieving the current value of MaxElementsPerPage
	 */
	virtual INT GetMaxElementsPerPage() const;

protected:
	/**
	 * Updates the formatting parameters for all cells of the specified element.
	 *
	 * @param	ElementIndex	the list element to apply formatting for.
	 * @param	Parameters		@see UUIString::ApplyFormatting())
	 */
	virtual void ApplyElementFormatting( INT ElementIndex, FRenderParameters& Parameters );

	/**
	 * Wrapper for applying formatting to the schema cells.
	 */
	virtual void FormatSchemaCells( FRenderParameters& Parameters );

	/**
	 * Updates the formatting parameters for all cells of the specified element.
	 *
	 * @param	Cells			the list of cells to render
	 * @param	Parameters		@see UUIString::ApplyFormatting())
	 */
	virtual void ApplyCellFormatting( TArray<FUIListElementCell*> Cells, FRenderParameters& Parameters );

	/**
	 * Renders the overlay image for a single list element.  Moved into a separate function to allow child classes to easily override
	 * and modify the way that the overlay is rendered.
	 *
	 * @param	same as Render_ListElement, except that no values are passed back to the caller.
	 */
	virtual void Render_ElementOverlay( FCanvas* Canvas, INT ElementIndex, const FRenderParameters& Parameters, const FVector2D& DefaultCellSize );

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
	virtual void Render_ListElement( FCanvas* Canvas, INT ElementIndex, FRenderParameters& Parameters );

	/**
	 * Renders the list element cells specified.
	 *
	 * @param	Canvas			the canvas to use for rendering
	 * @param	ElementIndex	the index of the element being rendered; INDEX_NONE if rendering header cells.
	 * @param	Cells			the list of cells to render
	 * @param	CellParameters	Used for various purposes:
	 *							DrawX:		[in]	specifies the location of the start of the horizontal bounding region that should be used for
	 *												rendering the cells, in absolute screen pixels
	 *										[out]	unused
	 *							DrawY:		[in]	specifies the location of the start of the vertical bounding region that should be used for rendering
	 *												the cells, in absolute screen pixels
	 *										[out]	Will be set to the Y position of the rendering "pen" after rendering all cells.
	 *							DrawXL:		[in]	specifies the location of the end of the horizontal bounding region that should be used for rendering this element, in absolute screen pixels
	 *										[out]	unused
	 *							DrawYL:		[in]	specifies the height of the bounding region, in absolute screen pixels.  If this value is not large enough to render the cells, they will not be
	 *												rendered
	 *										[out]	Will be reduced by the height of the cells that were rendered. Thus represents the "remaining" height available for rendering.
	 *							DrawFont:	[in]	specifies the font to use for retrieving the size of the characters in the string
	 *							Scale:		[in]	specifies the amount of scaling to apply when rendering the cells
	 */
	virtual void Render_Cells( FCanvas* Canvas, INT ElementIndex, const TArray<FUIListElementCell*> Cells, FRenderParameters& CellParameters );

	/**
	 * Renders the background texture for a column header.
	 *
	 * @param	Canvas			the canvas to use for rendering
	 * @param	CellParameters	see Render_Cells
	 * @param	CellIndex		which column is being rendered; used for determining whether one of the "sort" styles should be used.
	 */
	virtual void Render_ColumnBackground( FCanvas* Canvas, const FRenderParameters& CellParameters, INT CellIndex );

	/**
	 * Retrieves the list of data stores bound by this subscriber.
	 *
	 * @param	out_BoundDataStores		receives the array of data stores that subscriber is bound to.
	 */
	virtual void GetBoundDataStores(TArray<class UUIDataStore*>& out_BoundDataStores);

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
	virtual UBOOL SetCellBinding( FName CellDataBinding, const FString& ColumnHeader, INT BindingIndex );

	/**
	 * Inserts a new schema cell at the specified index and assigns the data binding.
	 *
	 * @param	InsertIndex			the column/row to insert the schema cell; must be a valid index.
	 * @param	CellDataBinding		a name corresponding to a tag from the UIListElementProvider currently bound to this list.
	 * @param	ColumnHeader	the string that should be displayed in the column header for this cell.
	 *
	 * @return	TRUE if the schema cell was successfully inserted into the list
	 */
	virtual UBOOL InsertSchemaCell( INT InsertIndex, FName CellDataBinding, const FString& ColumnHeader );

	/**
	 * Retrieves the name of the binding for the specified location in the schema.
	 *
	 * @param	BindingIndex	the index for the cell/column to get the binding for
	 *
	 * @return	the value assigned to the schema cell at the specified location, or NAME_None if the binding index is invalid.
	 */
	virtual FName GetCellBinding( INT BindingIndex ) const;

	/**
	 * Removes all schema cells which are bound to the specified data field.
	 *
	 * @return	TRUE if one or more schema cells were successfully removed.
	 */
	virtual UBOOL ClearCellBinding( FName CellDataBinding );

	/**
	 * Removes schema cells at the location specified.  If the list's columns are linked, this index should correspond to
	 * the column that should be removed; if the list's rows are linked, this index should correspond to the row that should
	 * be removed.
	 *
	 * @return	TRUE if the schema cell at BindingIndex was successfully removed.
	 */
	virtual UBOOL ClearCellBinding( INT BindingIndex );

public:

	/* === UObject interface === */
	/**
	 * Called when a property value has been changed in the editor.  When the data source for the cell schema is changed,
	 * refreshes the list's data.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);

	/**
	 * Called when a member property value has been changed in the editor.
	 */
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/**
	 * Copies the value of the deprecated SelectionOverlay/Coordinates into the appropriate element of the ItemOverlay array.
	 */
	virtual void PostLoad();

	/* === CustomPropertyItemHandler interface === */
	/**
	 * Determines whether the specified property value matches the current value of the property.  Called after the user
	 * has changed the value of a property handled by a custom property window item.  Is used to determine whether Pre/PostEditChange
	 * should be called for the selected objects.
	 *
	 * @param	InProperty			the property whose value is being checked.
	 * @param	NewPropertyValue	the value to compare against the current value of the property.
	 * @param	ArrayIndex			the array index for the element being compared; only relevant for array properties
	 *
	 * @return	TRUE if NewPropertyValue matches the current value of the property specified, indicating that no effective changes
	 *			were actually made.
	 */
	virtual UBOOL IsCustomPropertyValueIdentical( UProperty* InProperty, const union UPropertyValue& NewPropertyValue, INT ArrayIndex=INDEX_NONE );

	/**
	 * Method for overriding the default behavior of applying property values received from a custom editor property window item.
	 *
	 * @param	InProperty		the property that is being edited
	 * @param	PropertyValue	the value to assign to the property
	 * @param	ArrayIndex		the array index for the element being changed; only relevant for array properties
	 *
	 * @return	TRUE if the property was handled by this object and the property value was successfully applied to the
	 *			object's data.
	 */
	virtual UBOOL EditorSetPropertyValue( UProperty* InProperty, const UPropertyValue& PropertyValue, INT ArrayIndex=INDEX_NONE );
}

/**
 * Find the index of the list item which corresponds to the data element specified.
 *
 * @param	DataSourceIndex		the index into the list element provider's data source collection for the element to find.
 *
 * @return	the index [into the ListItems array] for the element which corresponds to the data element specified, or INDEX_NONE
 * if none where found or DataSourceIndex is invalid.
 */
native final function int FindElementIndex( int DataSourceIndex ) const;

DefaultProperties
{
	bDisplayColumnHeaders=true
	SelectionHintPadding=(Orientation=UIORIENT_Horizontal,ScaleType=UIEXTENTEVAL_Pixels)

	// We create these in default properties so that the user is not required to
	Begin Object Class=UITexture Name=NormalOverlayTemplate
	End Object
	Begin Object Class=UITexture Name=ActiveOverlayTemplate
	End Object
	Begin Object Class=UITexture Name=SelectionOverlayTemplate
	End Object
	Begin Object Class=UITexture Name=HoverOverlayTemplate
	End Object
	ListItemOverlay(ELEMENT_Normal)=NormalOverlayTemplate
	ListItemOverlay(ELEMENT_Active)=ActiveOverlayTemplate
	ListItemOverlay(ELEMENT_Selected)=SelectionOverlayTemplate
	ListItemOverlay(ELEMENT_UnderCursor)=HoverOverlayTemplate
}
