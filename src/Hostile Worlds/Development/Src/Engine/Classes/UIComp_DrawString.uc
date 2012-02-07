/**
 * This component handles rendering UIStrings for widgets.  It is responsible for managing any
 * formatting data that is specific to each widget instance (thus inappropriate for storage in UIStyles).
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_DrawString extends UIComp_DrawComponents
	native(UIPrivate)
	HideCategories(Object)
	editinlinenew
	implements(UIStyleResolver);

/**
 * The subscriber that owns this component.  If set, will be added to the refresh delegates for any data stores
 * resolved in the string contained by this component.
 */
var		transient			UIDataStoreSubscriber		SubscriberOwner;

/**
 * The tag used to fulfill the UIStyleResolver interface's GetStyleResolverTag method.  Value should be set by the owning widget.
 */
var							name						StyleResolverTag;

/**
 * The UIString that will render the text.  Created at runtime when this component is initialized.
 */
var		private	transient	UIString					ValueString;

/** the class to use for creating the ValueString */
var		const transient		class<UIString>				StringClass;

/** true to draw an automatic dropshadow under the text */
var(Appearance)				bool						bDropShadow;

/** Offset to draw the dropshadow */
var(Appearance)				vector2d					DropShadowOffset;

/** Color of the dropshadow */
var(Appearance)				LinearColor					DropShadowColor;

/**
 * Controls whether the owning widget will be automatically resized to display this string's value.
 */
var(Appearance)				AutoSizeData				AutoSizeParameters[EUIOrientation.UIORIENT_MAX]<ToolTip=Controls how this string should be auto-sized>;

/**
 * Specifies how much of the available bounding region should be available for rendering the string in.
 */
var(Appearance) private		UIRenderingSubregion		ClampRegion[EUIOrientation.UIORIENT_MAX];

/**
 * Contains values for customizing and overriding rendering and formatting values designated by this component's style.
 */
var(StyleOverride)			UITextStyleOverride			TextStyleCustomization<ToolTip=Customizes and overrides the style properties for this string instance>;

//@todo ronp - do we also need a UIImageStyleOverride for use by any inline images in the string...?

/**
 * The style to use for rendering this component's string.  If the style is invalid, the component will use the owning
 * widget's PrimaryStyle, if possible.
 */
var	private					UIStyleReference			StringStyle;

/** whether the UIString should process markup */
var(Data)					bool						bIgnoreMarkup<ToolTip=Indicates that this string should not process markup text; useful for labels which must display special characters normally used for markup>;

/**
 * Controls whether docking is taken into account when determining the boundaries of the string, and whether the widget's position and size could potentially be modified by this component.
 * If the widget only has one string component which takes up the entire widget (such as a label
 */
var(Appearance)	private		bool						bAllowBoundsAdjustment<DisplayName=Affects Widget Bounds|ToolTip=Indicates whether this component is allowed to modify the bounds of the widget when autosizing is enabled.>;

/** Used for debugging strings - causes RefreshValue to be called */
var(ZDebug)	transient		bool						bRefreshString<ToolTip=Click this control to force the string to be completely reformatted; useful if your string isn't being formatted correctly>;

/** set to indicate that this label needs to recalculate the extents for its string */
var	transient				bool						bReapplyFormatting;

cpptext
{
	/**
	 * Initializes this component, creating the UIString needed for rendering text.
	 *
	 * @param	InSubscriberOwner	if this component is owned by a widget that implements the IUIDataStoreSubscriber interface,
	 *								the TScriptInterface containing the interface data for the owner.
	 */
	virtual void InitializeComponent( TScriptInterface<IUIDataStoreSubscriber>* InSubscriberOwner=NULL );

	/**
	 * Adds the specified face to the owning scene's DockingStack for the owning widget.  Takes wrap behavior and
	 * autosizing into account, ensuring that all widget faces are added to the scene's docking stack in the appropriate
	 * order.
	 *
	 * @param	DockingStack	the docking stack to add this docking node to.  Generally the scene's DockingStack.
	 * @param	Face			the face that should be added
	 *
	 * @return	TRUE if a docking node was added to the scene's DockingStack for the specified face, or if a docking node already
	 *			existed in the stack for the specified face of this widget.
	 */
	UBOOL AddDockingNode( TArray<FUIDockingNode>& DockingStack, EUIWidgetFace Face );

	/**
	 * Evalutes the Position value for the specified face into an actual pixel value, and triggers the methods which apply
	 * formatting data to the string.
	 *
	 * @param	Face	the face that should be resolved
	 */
	void ResolveFacePosition( EUIWidgetFace Face );

	/**
	 * Marks the Position for any faces dependent on the specified face, in this component's owning widget or its children,
	 * as out of sync with the corresponding RenderBounds.
	 *
	 * @param	Face	the face to modify; value must be one of the EUIWidgetFace values.
	 */
	virtual void InvalidatePositionDependencies( BYTE Face );

	/**
	 * Calculates the position and size of the bounding region available for rendering this component's string, taking
	 * into account any configured bounding region clamping.
	 *
	 * @param	[out] BoundingRegionStart	receives the location of the upper left corner of the bounding region, in
	 *										pixels relative to the upper left corner of the screen.
	 * @param	[out] BoundingRegionSize	receives the size of the bounding region, in absolute pixels.
	 */
	virtual void CalculateBoundingRegion( FLOAT* BoundingRegionStart[UIORIENT_MAX], FLOAT* BoundingRegionSize[UIORIENT_MAX] ) const;

	/**
	 * Returns TRUE if autosizing is enabled for the specified orientation.
	 *
	 * @param	Orientation		the orientation to check
	 *
	 * @return	TRUE if auto-sizing is enabled for the specified orientation
	 */
	UBOOL IsAutoSizeEnabled( BYTE Orientation ) const
	{
		checkSlow(Orientation<UIORIENT_MAX);
		return AutoSizeParameters[Orientation].bAutoSizeEnabled;
	}

	/**
	 * Changes the style for this UIString.
	 *
	 * @param	NewStringStyle	the new style to use for rendering the string
	 */
	void SetStringStyle( UUIStyle_Combo* NewComboStyle );

	/**
	 * Returns TRUE if this component's UIStyleReference can be resolved into a valid UIStyle.
	 *
	 * @param	CurrentlyActiveSkin		the currently active skin; used for resolving the style reference's default style if it doesn't yet have a valid style id.
	 */
	virtual UBOOL HasValidStyleReference( UUISkin* CurrentlyActiveSkin=NULL );

	/**
	 * Returns the combo style data being used by this string rendering component.  If the component's StringStyle is not set, the style data
	 * will be pulled from the owning widget's PrimaryStyle, if possible.
	 *
	 * @param	DesiredMenuState	the menu state for the style data to retrieve; if not specified, uses the owning widget's current menu state.
	 * @param	SourceSkin			the skin to use for resolving this component's combo style; only relevant when the component's combo style is invalid
	 *								(or if TRUE is passed for bClearExistingValue). If the combo style is invalid and a value is not specified, returned value
	 *								will be NULL.
	 * @param	bClearExistingValue	used to force the component's combo style to be re-resolved from the specified skin; if TRUE, you must supply a valid value for
	 *								SourceSkin.
	 *
	 * @return	the combo style data used to render this component's string for the specified menu state.
	 */
	virtual UUIStyle_Combo* GetAppliedStringStyle( UUIState* DesiredMenuState=NULL, UUISkin* SourceSkin=NULL, UBOOL bClearExistingValue=FALSE );

	/**
	 * Initializes the CustomizedStyleData using the string current style, then applies any per-instance values
	 * which are intended to override values in the style.
	 *
	 * @param	CustomizedStyleData		struct which receives the per-instance style data configured for this component;
	 *									should be initialized using a combo style prior to calling this function.
	 */
	void CustomizeAppliedStyle( FUICombinedStyleData& CustomizedStyleData ) const;

	/**
	 * Applies the current style data (including any style data customization which might be enabled) to the string.
	 */
	void RefreshAppliedStyleData();

	/**
	 * Calculate the rendering bounding region, adjust for alignment, and renders the string.
	 *
	 * @param	Canvas		the FCanvas to use for rendering this string
	 */
	void Render_String( FCanvas* Canvas );

	/**
	 * Flags the component to be reformatted during the next scene update.
	 *
	 * @param	bRequestSceneUpdate		if TRUE, requests the scene to update the positions for all widgets at the beginning of the next frame
	 */
	virtual void ReapplyFormatting( UBOOL bRequestSceneUpdate=TRUE );

	/**
	 * Called when a property value from a member struct or array has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);

	/**
	 * Retrieves a list of all data stores resolved by ValueString.
	 *
	 * @param	StringDataStores	receives the list of data stores that have been resolved by the UIString.  Appends all
	 *								entries to the end of the array and does not clear the array first.
	 */
	virtual void GetResolvedDataStores( TArray<UUIDataStore*>& StringDataStores );

protected:
	/**
	 * Initializes the render parameters that will be used for formatting the string.
	 *
	 * @param	Face			the face that was being resolved
	 * @param	out_Parameters	[out] the formatting parameters to use for formatting the string.
	 *
	 * @return	TRUE if the formatting data is ready to be applied to the string, taking into account the autosize settings.
	 */
	virtual UBOOL GetStringFormatParameters( EUIWidgetFace Face, FRenderParameters& out_Parameters ) const;

	/**
	 * Wrapper for getting the docking-state of the owning widget's four faces.  No special logic here, but child classes
	 * can use this method to make the formatting code ignore the fact that the widget may be docked (in cases where it is
	 * irrelevant)
	 *
	 * @param	bFaceDocked		[out] an array of bools representing whether the widget is docked on the respective face.
	 */
	virtual void GetOwnerDockingState( UBOOL* bFaceDocked[UIFACE_MAX] ) const;

	/**
	 * Adjusts the owning widget's bounds according to the wrapping mode and autosize behaviors.
	 */
	virtual void UpdateOwnerBounds( FRenderParameters& Parameters );

	/**
	 * Wrapper method which applies final formatting to the string and resets the value of bReapplyFormatting.
	 *
	 * @param	Parameters		@see UUIString::ApplyFormatting())
	 * @param	bIgnoreMarkup	@see UUIString::ApplyFormatting())
	 */
	virtual void ApplyStringFormatting( FRenderParameters& Parameters, UBOOL bIgnoreMarkup );

	/**
	 * Renders the string using the parameters specified.  Must have a different name than Render_String, or I can't call
	 * the other version, for some reason.
	 *
	 * @param	Canvas	the canvas to use for rendering this string
	 */
	virtual void InternalRender_String( FCanvas* Canvas, FRenderParameters& Parameters );

	/**
	 * Handles unregistering the "RefreshSubscriberValue" callbacks for the data stores that were previously resolved by this
	 * component's UIString and registering the callbacks for the data stores currently resolved by the UIString.  Requires that
	 * the SubscriberOwner value be set.
	 *
	 * @param	RemovedDataStores	the list of data stores that were previously bound to this component's string.  SubscriberOwner
	 *								will be removed from each data store's "RefreshSubscriberValue" callback list.
	 * @param	AddedDataStores		the list of data stores that are now bound to this component's string.  SubscriberOwner
	 *								will be registered with each data store's "RefreshSubscriberValue" callback list.
	 */
	void UpdateSubscriberCallbacks( TArray<UUIDataStore*> RemovedDataStores, TArray<UUIDataStore*> AddedDataStores );
}

/**
 * Changes the value of the text at runtime.
 *
 * @param	NewText		the new text that should be displayed
 */
native final virtual function SetValue( string NewText );

/**
 * Retrieve the value of the string.
 *
 * @param	bReturnProcessedText	Determines whether the processed or raw version of the value string is returned.
 *									The raw value will contain any markup; the processed string will be text only.
 *									Any image tokens are converted to their text counterpart.
 *
 * @return	the complete text value contained by the UIString, in either the processed or unprocessed state.
 */
native final virtual function string GetValue( optional bool bReturnProcessedText=true ) const;

/**
 * Clears and regenerates all nodes in the string by reparsing the source string.
 */
native final function RefreshValue();

/**
 * Returns TRUE if a subregion clamp is enabled for the specified orientation.
 *
 * @param	Orientation		the orientation to check
 *
 * @return	TRUE if a subregion is enabled for the specified orientation
 */
native final function bool IsSubregionEnabled( EUIOrientation Orientation ) const;

/**
 * Returns the size of the clamped subregion for a single orientation.
 *
 * @param	Orientation		the orientation to retrieve the subregion size for
 * @param	OutputType		indicates how the result should be formatted.
 *
 * @return	the size of the clamp subregion for the specified orientation, formatted according to the value of OutputType.
 */
native final function float GetSubregionSize( EUIOrientation Orientation, EUIExtentEvalType OutputType=UIEXTENTEVAL_Pixels ) const;

/**
 * Returns the offset of the clamped subregion for a single orientation.
 *
 * @param	Orientation		the orientation to retrieve the subregion offset for
 * @param	OutputType		indicates how the result should be formatted.
 *
 * @return	the offset of the clamp subregion for the specified orientation, relative to the widget's bounding region and
 *			formatted according to the value of OutputType.
 */
native final function float GetSubregionOffset( EUIOrientation Orientation, EUIExtentEvalType OutputType=UIEXTENTEVAL_Pixels ) const;

/**
 * Returns the alignment of the clamped subregion for a single orientation.
 *
 * @param	Orientation		the orientation to retrieve the subregion alignment for
 *
 * @return	the alignment of the clamp subregion for the specified orientation.
 */
native final function EUIAlignment GetSubregionAlignment( EUIOrientation Orientation ) const;

/**
 * Changes the value of bSubregionEnabled for the specified orientation.
 *
 * @param	Orientation		the orientation to enable/disable
 * @param	bShouldEnable	whether specifying a subregion should be allowed
 */
native final function EnableSubregion( EUIOrientation Orientation, optional bool bShouldEnable = true );

/**
 * Changes the size of the clamped subregion for the specified orientation.
 *
 * @param	Orientation		the orientation to update
 * @param	NewValue		the new size for the subregion.
 * @param	EvalType		indicates how NewValue should be intepreted
 */
native final function SetSubregionSize( EUIOrientation Orientation, float NewValue, EUIExtentEvalType EvalType );

/**
 * Changes the offset of the clamped subregion for the specified orientation.
 *
 * @param	Orientation		the orientation to update
 * @param	NewValue		the new offset to use
 * @param	EvalType		indicates how NewValue should be intepreted
 */
native final function SetSubregionOffset( EUIOrientation Orientation, float NewValue, EUIExtentEvalType EvalType );

/**
 * Changes the alignment of the clamped subregion for the specified orientation.
 *
 * @param	Orientation		the orientation to update
 * @param	NewValue		the new alignment to use
 */
native final function SetSubregionAlignment( EUIOrientation Orientation, EUIAlignment NewValue );

/**
 * Enables font color customization and changes the component's override color to the value specified.
 *
 * @param	NewColor	the color to use for rendering this component's string
 */
native final function SetColor( LinearColor NewColor );

/**
 * Enables a custom opacity and changes the component's override opacity to the value specified.
 *
 * @param	NewOpacity	the alpha to use for rendering this component's string
 */
native final function SetOpacity(float NewOpacity);

/**
 * Enables custom padding and changes the component's override padding to the value specified.
 *
 * @param	HorizontalPadding	new horizontal padding value to use (assuming a screen height of DEFAULT_SIZE_Y);
 *								will be scaled based on actual resolution.  Specify -1 to indicate that HorizontalPadding
 *								should not be changed (useful when changing only the vertical padding)
 * @param	HorizontalPadding	new vertical padding value to use (assuming a screen height of DEFAULT_SIZE_Y);
 *								will be scaled based on actual resolution.  Specify -1 to indicate that VerticalPadding
 *								should not be changed (useful when changing only the horizontal padding)
 */
native final function SetPadding( float HorizontalPadding, float VerticalPadding );

/**
 * Enables font customization and changes the component's override font to the value specified.
 *
 * @param	NewFont	the font to use for rendering this component's text
 */
native final function SetFont( Font NewFont );

/**
 * Enables text attribute customization and changes the component's override attributes to the value specified.
 *
 * @param	NewAttributes	the attributes to use for rendering this component's text
 */
native final function SetAttributes( UITextAttributes NewAttributes );

/**
 * Enables text alignment customization and sets the component's custom alignment value to the value specified.
 *
 * @param	Orientation		indicates which orientation to modify
 * @param	NewAlignment	the new alignment to use for rendering this component's text
 */
native final function SetAlignment( EUIOrientation Orientation, EUIAlignment NewAlignment );

/**
 * Enables clip mode customization and sets the component's custom clip mode value to the value specified.
 *
 * @param	NewClipMode	the new wrapping mode for this string.
 */
native final function SetWrapMode( ETextClipMode NewClipMode );

/**
 * Enables clip alignment customization and sets the component's custom clip alignment value to the value specified.
 *
 * @param	NewClipAlignment	the new clip alignment to use mode for this string.
 */
native final function SetClipAlignment( EUIAlignment NewClipAlignment );

/**
 * Enables autoscale customization and changes the component's override autoscalemode to the value specified.
 *
 * @param	NewAutoScaleMode	the autoscale mode to use for formatting this component's text
 * @param	NewMinScaleValue	the minimum scaling value to apply to the text.  if not specified (or a negative value
 *								is specified), the min scaling value will not be changed.
 */
native final function SetAutoScaling( ETextAutoScaleMode NewAutoScaleMode, optional float NewMinScaleValue=-1.f );

/**
 * Enables text scale customization and sets the component's custom scale value to the value specified.
 *
 * @param	Orientation		indicates which orientation to modify
 * @param	NewScale		the new scale to use for rendering this component's text
 */
native final function SetScale( EUIOrientation Orientation, float NewScale );

/**
 * Enables customization of the spacing adjustment between characters and lines of text
 *
 * @param	Orientation		indicates which orientation to modify
 * @param	NewSpacingAdjust		the new spacing adjust (in pixels) for rendering this component's text
 */
native final function SetSpacingAdjust( EUIOrientation Orientation, float NewSpacingAdjust );

/**
 * Disables font color customization allowing the string to use the values from the applied style.
 */
native final function DisableCustomColor();

/**
 * Disables the custom opacity level for this comp
 */
native final function DisableCustomOpacity();

/**
 * Disables the custom padding for this component.
 */
native final function DisableCustomPadding();

/**
 * Disables font customization allowing the string to use the values from the applied style.
 */
native final function DisableCustomFont();

/**
 * Disables text attribute customization allowing the string to use the values from the applied style.
 */
native final function DisableCustomAttributes();

/**
 * Disables text alignment customization allowing the string to use the values from the applied style.
 */
native final function DisableCustomAlignment();

/**
 * Disables text clip mode customization allowing the string to use the values from the applied style.
 */
native final function DisableCustomClipMode();

/**
 * Disables clip alignment customization allowing the string to use the values from the applied style.
 */
native final function DisableCustomClipAlignment();

/**
 * Disables text autoscale mode customization, allowing the string to use the values from the applied style.
 */
native final function DisableCustomAutoScaling();

/**
 * Disables text scale customization allowing the string to use the values from the applied style.
 */
native final function DisableCustomScale();

/**
 * Disables customization of spacing adjustment between characters and lines of text from the applied style.
 */
native final function DisableCustomSpacingAdjust();

/**
 * Wrapper for quickly grabbing the current wrap mode for this component.
 */
native final function ETextClipMode GetWrapMode() const;

/**
 * Returns the combo style data being used by this string rendering component.  If the component's StringStyle is not set, the style data
 * will be pulled from the owning widget's PrimaryStyle, if possible.
 *
 * @param	DesiredMenuState	the menu state for the style data to retrieve; if not specified, uses the owning widget's current menu state.
 *
 * @return	the combo style data used to render this component's string for the specified menu state.
 *
 * @note: noexport because we the native version is also handles optionally resolving the string style data from the active skin, so it
 * takes a few more parameters.
 */
native final noexport function UIStyle_Combo GetAppliedStringStyle( optional UIState DesiredMenuState );

/**
 * Gets the style data that will be used when rendering this component's string, including all style overrides or customizations enabled for this instance.
 *
 * @param	FinalStyleData	will be filled in with the style and formatting values that will be applied to this component's string
 *
 * @return	TRUE if the input value was filled in; FALSE if the component's style is still invalid or couldn't set the output value for any reason.
 */
native final function bool GetFinalStringStyle( out UICombinedStyleData FinalStyleData );

/* === UIStyleResolver interface === */
/**
 * Returns the tag assigned to this UIStyleResolver by the owning widget
 */
native final virtual function name GetStyleResolverTag();

/**
 * Changes the tag assigned to the UIStyleResolver to the specified value.
 *
 * @return	TRUE if the name was changed successfully; FALSE otherwise.
 */
native final virtual function bool SetStyleResolverTag( name NewResolverTag );

/**
 * Resolves the combo style for this string rendering component.
 *
 * @param	ActiveSkin			the skin the use for resolving the style reference.
 * @param	bClearExistingValue	if TRUE, style references will be invalidated first.
 * @param	CurrentMenuState	the menu state to use for resolving the style data; if not specified, uses the current
 *								menu state of the owning widget.
 * @param	StyleProperty		if specified, only the style reference corresponding to the specified property
 *								will be resolved; otherwise, all style references will be resolved.
 */
native final function virtual bool NotifyResolveStyle( UISkin ActiveSkin, bool bClearExistingValue, optional UIState CurrentMenuState, const optional name StylePropertyName );


/* === Unrealscript === */
/**
 * Changes the minimum and maximum auto-size values for this string.
 *
 * @param	Orientation		the orientation to enable/disable
 * @param	MinValue		the minimum size that auto-sizing should resize to (specify 0 to disable)
 * @param	MaxValue		the maximum size that auto-sizing should resize to (specify 0 to disable)
 * @param	MinScaleType	the scale type for the minimum value
 * @param	MaxScaleType	the scale type for the maximum value
 */
native final function SetAutoSizeExtent( EUIOrientation Orientation, float MinValue, float MaxValue, EUIExtentEvalType MinScaleType, EUIExtentEvalType MaxScaleType );

/**
 * Returns TRUE if autosizing is enabled for the specified orientation.
 *
 * @param	Orientation		the orientation to check
 *
 * @return	TRUE if auto-sizing is enabled for the specified orientation
 */
final function bool IsAutoSizeEnabled( EUIOrientation Orientation )
{
	return AutoSizeParameters[Orientation].bAutoSizeEnabled;
}

/**
 * Changes the value of bAutoSizeEnabled for the specified orientation.
 *
 * @param	Orientation	the orientation to enable/disable
 * @param	bShouldEnable	whether autosizing should be enabled
 */
final event EnableAutoSizing( EUIOrientation Orientation, bool bShouldEnable=true )
{
	local bool bNeedsReformatting;

	bNeedsReformatting = IsAutoSizeEnabled(Orientation) != bShouldEnable;
	AutoSizeParameters[Orientation].bAutoSizeEnabled = bShouldEnable;

	bReapplyFormatting = bReapplyFormatting || bNeedsReformatting;
	if ( bReapplyFormatting )
	{
		RequestSceneUpdate(true, true);
	}
}

final event SetAutoSizePadding( EUIOrientation Orientation, float NearValue, float FarValue, EUIExtentEvalType NearScaleType, EUIExtentEvalType FarScaleType )
{
	local bool bNeedsReformatting;

	bNeedsReformatting = AutoSizeParameters[Orientation].Padding.Value[0] != NearValue
		|| AutoSizeParameters[Orientation].Padding.Value[1] != FarValue
		|| AutoSizeParameters[Orientation].Padding.EvalType[0] != NearScaleType
		|| AutoSizeParameters[Orientation].Padding.EvalType[1] != FarScaleType;

	AutoSizeParameters[Orientation].Padding.Value[0] = NearValue;
	AutoSizeParameters[Orientation].Padding.Value[1] = FarValue;
	AutoSizeParameters[Orientation].Padding.EvalType[0] = NearScaleType;
	AutoSizeParameters[Orientation].Padding.EvalType[1] = FarScaleType;

	bReapplyFormatting = bReapplyFormatting || bNeedsReformatting;
	if ( bReapplyFormatting )
	{
		RequestSceneUpdate(false, true);
	}
}

DefaultProperties
{
	StringClass=class'Engine.UIString'
	StringStyle=(DefaultStyleTag="DefaultComboStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
	StyleResolverTag="String Style"
	bAllowBoundsAdjustment=true
	DropShadowOffset=(X=2,Y=2)

	ClampRegion(UIORIENT_Horizontal)=(ClampRegionSize=(Orientation=UIORIENT_Horizontal),ClampRegionOffset=(Orientation=UIORIENT_Horizontal))
	ClampRegion(UIORIENT_Vertical)=(ClampRegionSize=(Orientation=UIORIENT_Vertical),ClampRegionOffset=(Orientation=UIORIENT_Vertical))
}
