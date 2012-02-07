/**
 * This specialized version of UIString is used by preview panels in style editors.  Since those strings are created using
 * CDOs as their Outer, the menu state used to apply style data must be set manually.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIPreviewString extends UIString
	native(Private)
	transient;

var		private{private}	UIState			CurrentMenuState;

/**
 * The size of the preview window's viewport - set by the WxTextPreviewPanel that handles this string.
 */
var		const	private		Vector2D		PreviewViewportSize;

cpptext
{
	/* === UIPreviewString interface === */
	/**
	 * Changes the current menu state for this UIPreviewString.
	 */
	void SetCurrentMenuState( class UUIState* NewMenuState );

	/* === UIString interface === */
	/**
	 * Retrieves the UIState that should be used for applying style data.
	 */
	virtual class UUIState* GetCurrentMenuState() const;

	/**
	 * Gets the size of the viewport.
	 *
	 * @param	out_ViewportSize	receives the viewport size.
	 *
	 * @return	TRUE if the viewport size was retrieved successfully.
	 */
	virtual UBOOL GetViewportSize( FVector2D& out_ViewportSize ) const;
}

DefaultProperties
{

}
