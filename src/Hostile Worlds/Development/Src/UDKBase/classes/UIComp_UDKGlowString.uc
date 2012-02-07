/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UIComp_UDKGlowString extends UIComp_DrawString
	native;

/** Specifies the glowing style data to use for this widget */
var(Style) UIStyleReference GlowStyle;

cpptext
{
	/* === UUIComp_DrawString interface === */
	/**
	 * Returns the combo style data being used by this string rendering component.  If the component's StringStyle is not set, the style data
	 * will be pulled from the owning widget's PrimaryStyle, if possible.
	 *
	 * This version resolves the additional style reference property declared by the UTGlowString component.
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
	virtual class UUIStyle_Combo* GetAppliedStringStyle( class UUIState* DesiredMenuState=NULL, class UUISkin* SourceSkin=NULL, UBOOL bClearExistingValue=FALSE );

	/**
	 * Resolves the glow style for this string rendering component.
	 *
	 * @param	ActiveSkin			the skin the use for resolving the style reference.
	 * @param	bClearExistingValue	if TRUE, style references will be invalidated first.
	 * @param	CurrentMenuState	the menu state to use for resolving the style data; if not specified, uses the current
	 *								menu state of the owning widget.
	 * @param	StyleProperty		if specified, only the style reference corresponding to the specified property
	 *								will be resolved; otherwise, all style references will be resolved.
	 */
	virtual UBOOL NotifyResolveStyle(class UUISkin* ActiveSkin,UBOOL bClearExistingValue,class UUIState* CurrentMenuState=NULL,const FName StylePropertyName=NAME_None);

protected:
	/**
	 * We override InternalRender_String so that we can render twice.  Once with the glow style, once with the normal
	 * style
	 *
	 * @param	Canvas	the canvas to use for rendering this string
	 */
	virtual void InternalRender_String( FCanvas* Canvas, FRenderParameters& Parameters );
}

defaultproperties
{
	GlowStyle=(DefaultStyleTag="DefaultGlowStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
}
