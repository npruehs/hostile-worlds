/**
 * UIString is the core renderable entity for all data that is presented by the UI.  UIStrings are divided into one
 * or more UIStringNodes, where each node corresponds to either normal text or markup data.  Markup data is defined
 * as text that will be replaced by some data retrieved from a data store, referenced by DataStoreName:PropertyName.
 * Markup can change the current style: <Styles:NormalText>, can enable or disable a style attribute:
 * <Attributes:B> <Attributes:/B>, or it can indicate that the markup should be replaced by the value of the property
 * from the data store specified in the markup: <SomeDataStoreName:PropertyName>.
 * UIStrings dynamically generate UIStringNodes by parsing the input text. For example, passing the following string
 * to a UIString generates 7 tokens:
 * "The name specified '<SceneData:EnteredName>' is not available.  Press <ButtonImages:IMG_A> to continue or <ButtonImages:IMG_B> to cancel."
 * The tokens generated correspond to:
 *	(0)="The name specified '"
 *	(1)=" <SceneData:EnteredName>"
 *	(2)="' is not available.  Press "
 *	(3)="<ButtonImages:IMG_A>"
 *	(4)=" to continue or "
 *	(5)="<ButtonImages:IMG_B>"
 *	(6)=" to cancel."
 *
 * The source text for a UIString must be specified outside of the UIString itself.  There is no such thing as a
 * stand-alone UIString.  When used in a label, for example, the property which contains the text which will be used
 * in the label is specified by the UILabel.  This value may contain references to other data sources using markup, but
 * UIStrings cannot be bound to a data store by themselves.  When used in a list, the element cell will be responsible
 * for giving the UIString its source text.
 *
 * @todo UIString is supposed to support persistence, so that designers can override the extents for individual nodes
 *	in the string, so it should not be marked transient
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIString extends UIRoot
	within UIScreenObject
	native(inherit)
	transient;

cpptext
{
	/* === UIString Interface === */
	/**
	 * Calculates the size of the specified string.
	 *
	 * @param	Parameters	Used for various purposes
	 *							DrawXL:		[out] will be set to the width of the string
	 *							DrawYL:		[out] will be set to the height of the string
	 *							DrawFont:	[in] specifies the font to use for retrieving the size of the characters in the string
	 *							Scale:		[out] specifies the amount of scaling to apply to the string
	 * @param	pText		the string to calculate the size for
	 * @param	EOL			a pointer to a single character that is used as the end-of-line marker in this string
	 * @param	bStripTrailingCharSpace
	 *						whether the inter-character spacing following the last character should be included in the calculated width of the result string
	 */
	static void StringSize( FRenderParameters& Parameters, const TCHAR* pText, const TCHAR* EOL=NULL, UBOOL bStripTrailingCharSpace=TRUE );

	/**
	 * Clips text to the bounding region specified.
	 *
	 * @param	Parameters			Various:
	 *									DrawX:		[in] specifies the pixel location of the start of the bounding region that should be used for clipping
	 *									DrawXL:		[in] specifies the pixel location of the end of the bounding region that should be used for clipping
	 *												[out] set to the width of out_ResultString, in pixels
	 *									DrawY:		unused
	 *									DrawYL:		[out] set to the height of the string
	 *									Scaling:	specifies the amount of scaling to apply to the string
	 * @param	pText				the text that should be clipped
	 * @param	out_ResultString	[out] a string containing all characters from the source string that fit into the bounding region
	 * @param	ClipAlignment		controls which part of the input string is preserved (remains after clipping).
	 * @param	bStripTrailingCharSpace
	 *								whether the inter-character spacing following the last character should be included in the calculated width of the result string
	 * @param	bClipToNearestEdge	indicates whether the last character should be included in the result string if its midpoint is inside the bounding region.
	 */
	static void ClipString( FRenderParameters& Parameters, const TCHAR* pText, FString& out_ResultString, EUIAlignment ClipAlignment=UIALIGN_Left, UBOOL bStripTrailingCharSpace=TRUE, UBOOL bClipToNearestEdge=FALSE );

	/**
	 * Parses a single string into an array of strings that will fit inside the specified bounding region.
	 *
	 * @param	Parameters		Used for various purposes:
	 *							DrawX:		[in] specifies the pixel location of the start of the horizontal bounding region that should be used for wrapping.
	 *							DrawY:		[in] specifies the Y origin of the bounding region.  This should normally be set to 0, as this will be
	 *										     used as the base value for DrawYL.
	 *										[out] Will be set to the Y position (+YL) of the last line, i.e. the total height of all wrapped lines relative to the start of the bounding region
	 *							DrawXL:		[in] specifies the pixel location of the end of the horizontal bounding region that should be used for wrapping
	 *							DrawYL:		[in] specifies the height of the bounding region, in pixels.  A input value of 0 indicates that
	 *										     the bounding region height should not be considered.  Once the total height of lines reaches this
	 *										     value, the function returns and no further processing occurs.
	 *							DrawFont:	[in] specifies the font to use for retrieving the size of the characters in the string
	 *							Scale:		[in] specifies the amount of scaling to apply to the string
	 * @param	CurX			specifies the pixel location to begin the wrapping; usually equal to the X pos of the bounding region, unless wrapping is initiated
	 *								in the middle of the bounding region (i.e. indentation)
	 * @param	pText			the text that should be wrapped
	 * @param	out_Lines		[out] will contain an array of strings which fit inside the bounding region specified.  Does
	 *							not clear the array first.
	 * @param	EOL				a pointer to a single character that is used as the end-of-line marker in this string
	 * @param	MaxLines		the maximum number of lines that can be created.
	 */
	static void WrapString( FRenderParameters& Parameters, FLOAT CurX, const TCHAR* pText, TArray<struct FWrappedStringElement>& out_Lines, const TCHAR* EOL = NULL, INT MaxLines = MAXINT);

	/**
	 * Changes the style data for this UIString.
	 *
	 * @return	TRUE if the string needs to be reformatted, indicating that the new style data was successfully applied
	 *			to the string.  FALSE if the new style data was identical to the current style data or the new style data
	 *			was invalid.
	 */
	UBOOL SetStringStyle( const struct FUICombinedStyleData& NewStringStyle );

	/**
	 * Changes the complete style for this UIString.
	 *
	 * @return	TRUE if the string needs to be reformatted, indicating that the new style data was successfully applied
	 *			to the string.  FALSE if the new style data was identical to the current style data or the new style data
	 *			was invalid.
	 */
	UBOOL SetStringStyle( class UUIStyle_Combo* NewStringStyle );

	/**
	 * Changes the text style for this UIString.
	 *
	 * @param	NewTextStyle	the new text style data to use
	 *
	 * @return	TRUE if the string needs to be reformatted, indicating that the new style data was successfully applied
	 *			to the string.  FALSE if the new style data was identical to the current style data or the new style data
	 *			was invalid.
	 */
	UBOOL SetStringTextStyle( const struct FStyleDataReference& NewTextStyle );

	/**
	 * Changes the text style for this UIString.
	 *
	 * @param	NewSourceStyle	the UIStyle object to retrieve the new text style data from
	 * @param	NewSourceState	the menu state corresponding to the style data to apply to the string
	 *
	 * @return	TRUE if the string needs to be reformatted, indicating that the new style data was successfully applied
	 *			to the string.  FALSE if the new style data was identical to the current style data or the new style data
	 *			was invalid.
	 */
	UBOOL SetStringTextStyle( UUIStyle* NewSourceStyle, UUIState* NewSourceState );

	/**
	 * Changes the image style for this UIString.
	 *
	 * @param	NewTextStyle	the new image style data to use
	 *
	 * @return	TRUE if the string needs to be reformatted, indicating that the new style data was successfully applied
	 *			to the string.  FALSE if the new style data was identical to the current style data or the new style data
	 *			was invalid.
	 */
	UBOOL SetStringImageStyle( const struct FStyleDataReference& NewImageStyle );

	/**
	 * Changes the image style for this UIString.
	 *
	 * @param	NewSourceStyle	the UIStyle object to retrieve the new image style data from
	 * @param	NewSourceState	the menu state corresponding to the style data to apply to the string
	 *
	 * @return	TRUE if the string needs to be reformatted, indicating that the new style data was successfully applied
	 *			to the string.  FALSE if the new style data was identical to the current style data or the new style data
	 *			was invalid.
	 */
	UBOOL SetStringImageStyle( UUIStyle* NewSourceStyle, UUIState* NewSourceState );

	/**
	 * Retrieves the UIState that should be used for applying style data.
	 */
	virtual class UUIState* GetCurrentMenuState() const;

	/**
	 * Propagates the string's text and image styles to all existing string nodes.
	 */
	void RefreshNodeStyles();

	/**
	 * Removes all slave nodes which were created as a result of wrapping or other string formatting, appending their RenderedText
	 * to the parent node.
	 */
	void UnrollWrappedNodes();

	/**
	 * Reformats this UIString's nodes to fit within the bounding region specified.
	 *
	 * @param	Parameters		Used for various purposes:
	 *							DrawX:		[in] specifies the X position of the bounding region, in pixels
	 *										[out] Will be set to the X position of the end of the last node in the string.
	 *							DrawY:		[out] Will be set to the Y position of the last node in the string
	 *							DrawXL:		[in] specifies the width of the bounding region, in pixels.
	 *							DrawYL:		[in] specifies the height of the bounding region, in pixels.
	 *							DrawFont:	unused
	 *							Scale:		unused
	 * @param	bIgnoreMarkup	if TRUE, does not attempt to process any markup and only one UITextNode is created
	 */
	void ApplyFormatting( FRenderParameters& Parameters, UBOOL bIgnoreMarkup );

	/**
	 * Converts the raw source text containing optional markup (such as tokens and inline images)
	 * into renderable data structures.
	 *
	 * @param	InputString			A string containing optional markup.
	 * @param	bSystemMarkupOnly	if TRUE, only system generated markup will be processed (such as markup for rendering carets, etc.)
	 * @param	out_Nodes			[out] A collection of UITextNodes which will contain the parsed nodes.
	 * @param	StringNodeModifier	the style data to use as the starting point for string node modifications.  If not specified, uses the
	 *								string's DefaultStringStyle as the starting point.  Generally only specified when recursively calling
	 *								ParseString.
	 *
	 * @return	TRUE if InputString was successfully parsed into out_Nodes
	 */
	UBOOL ParseString( const FString& InputString, UBOOL bSystemMarkupOnly, TArray<FUIStringNode*>& out_Nodes, struct FUIStringNodeModifier* StringNodeModifier=NULL ) const;

	/**
	 * Render this UIString using the parameters specified.
	 *
	 * @param	Canvas		the FCanvas to use for rendering this string
	 * @param	Parameters	the bounds for the region that this string can render to.
	 */
	void Render_String( FCanvas* Canvas, const FRenderParameters& Parameters );

	/**
	 * Calculates the height of a single line of text using the string's default text style for sizing.
	 *
	 * @return	the average height a single line in this string, in pixels, using the string's current text style.
	 */
	FLOAT GetDefaultLineHeight( FLOAT ViewportHeight ) const;

	/**
	 * Retrieves a list of all data stores resolved by this UIString.
	 *
	 * @param	StringDataStores	receives the list of data stores that have been resolved by this string.  Appends all
	 *								entries to the end of the array and does not clear the array first.
	 */
	void GetResolvedDataStores( TArray<class UUIDataStore*>& StringDataStores );

	/**
	 * Gets the size of the viewport.
	 *
	 * @param	out_ViewportSize	receives the viewport size.
	 *
	 * @return	TRUE if the viewport size was retrieved successfully.
	 */
	virtual UBOOL GetViewportSize( FVector2D& out_ViewportSize ) const;

protected:

	/**
	 * Find the data store that has the specified tag.
	 *
	 * @param	DataStoreTag	A name corresponding to the 'Tag' property of a data store
	 *
	 * @return	a pointer to the data store that has a Tag corresponding to DataStoreTag, or NULL if no data
	 *			were found with that tag.
	 */
	UUIDataStore* ResolveDataStore( FName DataStoreTag ) const;

	/**
	 * Deletes all nodes allocated by this UIString and empties the Nodes array
	 */
	void ClearNodes();

	/**
	 * Hook for adjusting the extents and render text of any nodes prior to applyig formatting data.
	 *
	 * @param	FormatData	contains the precalculated formatting data (available bounding region size, etc.)
	 *
	 * @return	TRUE to indicate that the string has been preclipping (forces UUIString::ApplyFormatting to use UIALIGN_Left
	 *			instead of the configured text clip mode, if the string must be clipped further).
	 */
	virtual UBOOL AdjustNodeExtents( struct FNodeFormattingData& FormatData ) { return FALSE; }

public:
	/* === UObject interface. === */
	virtual void AddReferencedObjects( TArray<UObject*>& ObjectArray );
	virtual void Serialize( FArchive& Ar );
	virtual void FinishDestroy();

	/**
	 * Determines whether this object is contained within a UIPrefab.
	 *
	 * @param	OwnerPrefab		if specified, receives a pointer to the owning prefab.
	 *
	 * @return	TRUE if this object is contained within a UIPrefab; FALSE if this object IS a UIPrefab or is not
	 *			contained within a UIPrefab.
	 */
	virtual UBOOL IsAPrefabArchetype( UObject** OwnerPrefab=NULL ) const;

	/**
	 * @return	TRUE if the object is contained within a UIPrefabInstance.
	 */
	virtual UBOOL IsInPrefabInstance() const;
}

/**
 * The text nodes contained by this UIString.  Each text node corresponds to a single atomically renderable
 * element, such as a string of text, an inline image (like a button icon), etc.
 */
var	native transient	array<pointer>				Nodes{FUIStringNode};

/**
 * The default style that will be used for initializing the styles for all nodes contained by this string.
 * Initialized using the owning widget's style, then modified by any per-widget style customizations enabled for the widget.
 */
var transient			UICombinedStyleData			StringStyleData;

/** the width and height of the entire string */
var transient			Vector2D					StringExtent;

/**
 * Parses a string containing optional markup (such as tokens and inline images) and stores the result in Nodes.
 *
 * @param	InputString		A string containing optional markup.
 * @param	bIgnoreMarkup	if TRUE, does not attempt to process any markup and only one UITextNode is created
 *
 * @return	TRUE if the string was successfully parsed into the Nodes array.
 */
native final virtual function bool SetValue( string InputString, bool bIgnoreMarkup );

/**
 * Returns the complete text value contained by this UIString, in either the processed or unprocessed state.
 *
 * @param	bReturnProcessedText	Determines whether the processed or raw version of the value string is returned.
 *									The raw value will contain any markup; the processed string will be text only.
 *									Any image tokens are converted to their text counterpart.
 *
 * @return	the complete text value contained by this UIString, in either the processed or unprocessed state.
 */
native final function string GetValue( optional bool bReturnProcessedText=true ) const;

/**
 * Retrieves the configured auto-scale percentage.
 *
 * @param	BoundingRegionSize		the bounding region to use for determining autoscale factor (only relevant for certain
 *									auto-scale modes).
 * @param	StringSize				the size of the string, unwrapped and non-scaled; (only relevant for certain
 *									auto-scale modes).
 * @param	out_AutoScalePercent	receives the autoscale percent value.
 */
native final function GetAutoScaleValue( Vector2D BoundingRegionSize, Vector2D StringSize, out Vector2D out_AutoScalePercent ) const;

/**
 * @return	TRUE if this string's value contains markup text
 */
native final function bool ContainsMarkup() const;

DefaultProperties
{
	StringStyleData=(TextClipMode=CLIP_Normal)
}
