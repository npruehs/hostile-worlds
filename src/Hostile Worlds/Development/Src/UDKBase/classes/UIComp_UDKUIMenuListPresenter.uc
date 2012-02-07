/**
 * Responsible for how the data associated with this list is presented.  Updates the list's operating parameters
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
class UIComp_UDKUIMenuListPresenter extends UIComp_ListPresenter
	within UIList
	native
	DependsOn(UIDataStorePublisher);

cpptext
{
	friend class UUIList;

	/**
	 * Initializes the component's prefabs.
	 */
	virtual void InitializePrefabs();

	/**
	 * Renders the elements in this list.
	 *
	 * @param	RI					the render interface to use for rendering
	 */
	virtual void Render_List( FCanvas* Canvas );

	/**
	 * Renders the list element specified.
	 *
	 * @param	Canvas			the canvas to use for rendering
	 * @param	ElementIndex	the index for the list element to render
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
	void Render_ListElement( FCanvas* Canvas, INT ElementIndex, FRenderParameters& Parameters );

	/**
	 * Called when a member property value has been changed in the editor.
	 */
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/**
	 * Updates the prefab widgets we are dynamically changing the markup of to use a new list row for their datasource.
	 *
	 * @param NewIndex	New list row index to rebind the widgets with.
	 */
	virtual void UpdatePrefabMarkup();

	/** Updates the position of the selected item prefab. */
	virtual void UpdatePrefabPosition();
}

/** Size of the selected prefab item. */
var() int		SelectedItemHeight;

/** The prefab to use for the selected item. */
var() UIPrefab	SelectedItemPrefab;

/** The prefab to use for normal items. */
var() UIPrefab	NormalItemPrefab;

/** List of prefab widgets to replace with current selected item values. */
struct native PrefabMarkupReplace
{
	var() name	WidgetTag;	/** Tag of the widget we are going to replace the markup of. */
	var() name	CellTag;	/** Cell tag to use get the new value of the widget. */
};

var() array<PrefabMarkupReplace> PrefabMarkupReplaceList;

/** Struct to store info/references about the instanced prefab. */
struct native InstancedPrefabInfo
{
	var UIPrefabInstance PrefabInstance;
	var array<UIObject> ResolvedObjects;
};

/** Instances of prefabs for each of the items in the list. */
var transient array<InstancedPrefabInfo> InstancedPrefabs;

defaultproperties
{
	bDisplayColumnHeaders = false
	SelectedItemHeight = 50
}
