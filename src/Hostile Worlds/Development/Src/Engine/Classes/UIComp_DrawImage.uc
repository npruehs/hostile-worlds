/**
 * This component encapsulates rendering a UITexture for widgets.  It is responsible for managing any
 * image formatting data that is required for a particular widget (thus inappropriate for storage in UIStyles).
 *
 * The style used for rendering the ImageRef is defined by whichever widget owns this component.  It is the widget's
 * responsibility to call ApplyImageStyle when the widget receives a call to OnStyleResolved for the UIStyleReference
 * which is intended to be used as the style for this image.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_DrawImage extends UIComp_DrawComponents
	native(UIPrivate)
	HideCategories(Object)
	implements(UIStyleResolver,CustomPropertyItemHandler)
	editinlinenew;

/**
 * The tag used to fulfill the UIStyleResolver interface's GetStyleResolverTag method.  Value should be set by the owning widget.
 */
var													name					StyleResolverTag;

/**
 * The utility wrapper for the image that this component should render.  Automatically created by the component when
 * given an material/texture to render.
 */
var(StyleOverride)	instanced	editinlineuse		UITexture				ImageRef;

/**
 * Contains values for customizing and overriding rendering and formatting values designated by this component's style.
 */
var(StyleOverride)									UIImageStyleOverride	StyleCustomization;

/**
 * The style to use for rendering this component's image.  If the style is invalid, the component will use the owning
 * widget's PrimaryStyle, if possible.
 */
var	private											UIStyleReference		ImageStyle;


cpptext
{
	/* === UIComp_DrawImage interface === */
	/**
	 * Renders the image.  The owning widget is responsible for applying any transformations to the canvas
	 * prior to rendering this component.
	 *
	 * @param	Canvas		the canvas to render the image to
	 * @param	Parameters	the bounds for the region that this texture can render to.
	 */
	virtual void RenderComponent( class FCanvas* Canvas, FRenderParameters Parameters );

	/**
	 * Returns TRUE if this component's UIStyleReference can be resolved into a valid UIStyle.
	 *
	 * @param	CurrentlyActiveSkin		the currently active skin; used for resolving the style reference's default style if it doesn't yet have a valid style id.
	 */
	virtual UBOOL HasValidStyleReference( class UUISkin* CurrentlyActiveSkin=NULL );

	/**
	 * Returns the image style data being used by this image rendering component.  If the component's ImageStyle is not set, the style data
	 * will be pulled from the owning widget's primary style.
	 *
	 * @param	DesiredMenuState	the menu state for the style data to retrieve; if not speicified, uses the owning widget's current menu state.
	 * @param	SourceSkin			the skin to use for resolving this component's image style; only relevant when the component's image style is invalid
	 *								(or if TRUE is passed for bClearExistingValue). If the image style is invalid and a value is not specified, returned value
	 *								will be NULL.
	 * @param	bClearExistingValue	used to force the component's image style to be re-resolved from the specified skin; if TRUE, you must supply a valid value for
	 *								SourceSkin.
	 *
	 * @return	the image style data used to render this component's image for the specified menu state.
	 */
	virtual class UUIStyle_Image* GetAppliedImageStyle( class UUIState* DesiredMenuState=NULL, class UUISkin* SourceSkin=NULL, UBOOL bClearExistingValue=FALSE );

	/**
	 * Initializes the combinedstyledata using the component's current image sytle, then applies any per-instance values
	 * which are intended to override values in the style.
	 *
	 * @param	CustomizedStyleData		struct which receives the per-instance style data configured for this component;
	 *									should be initialized using an image style prior to calling this function.
	 */
	void CustomizeAppliedStyle( FUICombinedStyleData& CustomizedStyleData ) const;

	/**
	 * Applies the current style data (including any style data customization which might be enabled) to the component's image.
	 */
	void RefreshAppliedStyleData();

	/* === UObject interface === */
	/**
	 * Called when a property value has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);

	/**
	 * Called after this object has been completely de-serialized.
	 *
	 * This version migrates the ImageCoordinates value over to the StyleCustomization member.
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


/* === Natives === */
/**
 * Returns the image style data being used by this image rendering component.  If the component's ImageStyle is not set, the style data
 * will be pulled from the owning widget's primary style.
 *
 * @param	DesiredMenuState	the menu state for the style data to retrieve; if not speicified, uses the owning widget's current menu state.
 *
 * @return	the image style data used to render this component's image for the specified menu state.
 *
 * @note: noexport because we the native version is also handles optionally resolving the image style data from the active skin, so it
 * takes a few more parameters.
 */
native final noexport function UIStyle_Image GetAppliedImageStyle( optional UIState DesiredMenuState );

/**
 * Changes the image for this component, creating the wrapper UITexture if necessary.
 *
 * @param	NewImage		the new texture or material to use in this component
 */
native final function SetImage( Surface NewImage );

/**
 * Enables image coordinate customization and changes the component's override coordinates to the value specified.
 *
 * @param	NewCoordinates	the UV coordinates to use for rendering this component's image
 */
native final function SetCoordinates( TextureCoordinates NewCoordinates );

/**
 * Enables image color customization and changes the component's override color to the value specified.
 *
 * @param	NewColor	the color to use for rendering this component's image
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
 * Enables image formatting customization and changes the component's formatting override data to the value specified.
 *
 * @param	Orientation			indicates which orientation to modify
 * @param	NewFormattingData	the new value to use for rendering this component's image.
 */
native final function SetFormatting( EUIOrientation Orientation, UIImageAdjustmentData NewFormattingData );

/**
 * Disables image coordinate customization allowing the image to use the values from the applied style.
 */
native final function DisableCustomCoordinates();

/**
 * Disables image color customization allowing the image to use the values from the applied style.
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
 * Disables image formatting customization allowing the image to use the values from the applied style.
 */
native final function DisableCustomFormatting();

/**
 * Returns the texture or material assigned to this component.
 */
native final function Surface GetImage() const;

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
 * Resolves the image style for this image rendering component.
 *
 * @param	ActiveSkin			the skin the use for resolving the style reference.
 * @param	bClearExistingValue	if TRUE, style references will be invalidated first.
 * @param	CurrentMenuState	the menu state to use for resolving the style data; if not specified, uses the current
 *								menu state of the owning widget.
 * @param	StyleProperty		if specified, only the style reference corresponding to the specified property
 *								will be resolved; otherwise, all style references will be resolved.
 */
native final virtual function bool NotifyResolveStyle( UISkin ActiveSkin, bool bClearExistingValue, optional UIState CurrentMenuState, const optional name StylePropertyName );

DefaultProperties
{
	ImageStyle=(DefaultStyleTag="DefaultImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	StyleResolverTag="Image Style"
}
