/**
 * Acts as the raw interface for providing a texture or material to the UI.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UITexture extends UIRoot
	native(UIPrivate)
	editinlinenew;

cpptext
{
	/**
	 * Fills in the extent with the size of this texture's material
	 *
	 * @param	Extent	[out] set to the width/height of this texture's material
	 */
	virtual void CalculateExtent( FVector2D& Extent ) const;

	/**
	 * Fills in the extent with the size of this texture's material
	 *
	 * @param	SizeX	[out] filled in with the width this texture's material
	 * @param	SizeY	[out] filled in with the height of this texture's material
	 */
	virtual void CalculateExtent( FLOAT& out_SizeX, FLOAT& out_SizeY ) const;

	/**
	 * Render this UITexture using the parameters specified.
	 *
	 * @param	Canvas		the FCanvas to use for rendering this texture
	 * @param	Parameters	the bounds for the region that this texture can render to.
	 */
	virtual void Render_Texture( FCanvas* Canvas, const FRenderParameters& Parameters );

	/**
	 * Returns the surface associated with this UITexture.
	 */
	USurface* GetSurface() const { return ImageTexture; }

	/**
	 * Copies the style data specified to this UITexture's ImageStyleData.
	 */
	void SetImageStyle( const struct FUICombinedStyleData& NewStyleData );

	/**
	 * Provides read-only access to the style data assigned to this UITexture
	 */
	const struct FUICombinedStyleData& GetImageStyle() const { return ImageStyleData; }

	/**
	 * Utility function for rendering a texture to the screen using DrawTile.  Determines the appropriate overload of DrawTile
	 * to call, depending on the type of surface being rendered, and translates the UV values into percentages as this is what
	 * Canvas expects.
	 *
	 * @param	Canvas			the FCanvas to use for rendering this texture
	 * @param	Surface			the texture to be rendered
	 * @param	StyleData		this is [currently] only used when rendering UTexture surfaces to get the color to use for rendering
	 * @param	X				the horizontal screen location (in pixels) where the image should be rendered
	 * @param	Y				the vertical screen location (in pixels) where the image should be rendered
	 * @param	XL				the width of the region (in pixels) where this image will be rendered
	 * @param	YL				the height of the region (in pixels) where this image will be rendered
	 * @param	U				the horizontal location (in pixels) to begin sampling the texture data
	 * @param	V				the vertical location (in pixels) to begin sampling the texture data
	 * @param	UL				the width (in pixels) of the texture data sampling region
	 * @param	VL				the height (in pixels) of the texture data sampling region
	 */
	static void DrawTile( FCanvas* Canvas, USurface* Surface, const struct FUICombinedStyleData& StyleData,
						 FLOAT X, FLOAT Y, FLOAT XL, FLOAT YL, FLOAT U, FLOAT V, FLOAT UL, FLOAT VL );

	static void DrawTileZ( FCanvas* Canvas, USurface* Surface, const struct FUICombinedStyleData& StyleData,
						  FLOAT X, FLOAT Y, FLOAT Z, FLOAT XL, FLOAT YL, FLOAT U, FLOAT V, FLOAT UL, FLOAT VL );

	/**
	 * Render the specified image.  If the target region is larger than the image being rendered, the image is stretched by duplicating the pixels at the
	 * images midpoint to fill the additional space.  If the target region is smaller than the image being rendered, the image will be scaled to fit the region.
	 *
	 * @param	Canvas			the FCanvas to use for rendering this texture
	 * @param	Surface			the texture to be rendered
	 * @param	StyleData		used to determine which orientations can be stretched in the image
	 * @param	Parameters		describes the bounds and sample locations for rendering this tile.  See the documentation for DrawTile
	 *							for more details about each individual member.
	 */
	static void DrawTileStretched( FCanvas* Canvas, USurface* Surface, const struct FUICombinedStyleData& StyleData, const FRenderParameters& Parameters );

	/**
	 * Render the specified image.  The protected regions of the image will not be scaled in the directions of their respective dimensions,
	 * i.e. the left protected region will not be scaled in the horizontal dimension with the rest of the image.  The protected regions are
	 * defined by a value that indicates the distance from their respective face to the opposite edge of the region.  The perpendicular
	 * faces of a given protected region extend to the edges of the full image.
	 *
	 * @param	RI				the render interface to use for rendering the image
	 * @param	Surface			the texture to be rendered
	 * @param	StyleData		used to determine which orientations can be stretched in the image
	 * @param	Parameters		describes the bounds and sample locations for rendering this tile.  See the documentation for DrawTile
	 *							for more details about each individual member.
	 */
	static void DrawTileProtectedRegions( FCanvas* Canvas, USurface* Surface, const struct FUICombinedStyleData& StyleData, const FRenderParameters& Parameters );

	/* === UObject interface === */
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
 * Contains data for controlling or modifying how this image is displayed.  Set by the object which owns this texture/material.
 */
var private{private}	transient	UICombinedStyleData		ImageStyleData;

/**
 * The texture or material that will be rendered by this UITexture.  If not specified, will render the FallbackImage set
 * in the ImageStyleData instead.
 */
var									Surface					ImageTexture;

/**
 * Wrapper for retrieving the widget that owns this UITexture, if it's owned by a widget.
 */
native final function UIScreenObject GetOwnerWidget( optional out UIComponent OwnerComponent ) const;

/**
 * Initializes ImageStyleData using the specified image style.
 *
 * @param	NewImageStyle	the image style to copy values from
 */
native final function SetImageStyle( UIStyle_Image NewImageStyle );

/**
 * Determines whether this UITexture has been assigned style data.
 *
 * @return	TRUE if ImageStyleData has been initialized; FALSE otherwise
 */
native final function bool HasValidStyleData() const;

/**
 * Returns the surface associated with this UITexture.
 */
final function Surface GetSurface()
{
	return ImageTexture;
}

DefaultProperties
{

}
