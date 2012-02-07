/**
 * This class tracks and stores the currently configured settings for a single ui editor window.  When a UI editor window is created,
 * a UIEditorOptions object is created for that window using the name of the window as the name of the UIEditorOptions object.  As the
 * user changes options in the ui editor, those values are stored here.  When the editor window is destroyed, the values are saved
 * to the ini using standard PerObjectConfig naming rules.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIEditorOptions extends UIRoot
	config(EditorUserSettings)
	PerObjectConfig
	native(Private);

/** represents the layout for an editor window */
struct {WxRect} ViewportDimension
{
	var config	int	X, Y, Width, Height;
};

/** the position of this editor window */
var	config	ViewportDimension	WindowPosition;

/** the position of the datastore splitter sash */
var	config	int					DataStoreBrowserSashPosition;

/** the number of pixels to use for a "gutter" around the scene being rendered. */
var	config	int					ViewportGutterSize;

/** the virtual size of the viewport - this size is used when the scene requests the viewport size */
const AUTOEXPAND_VALUE=0;
var	config	int					VirtualSizeX, VirtualSizeY;

/** whether the various outline indicators should be rendered */
var	config	bool				bRenderViewportOutline,
								bRenderContainerOutline,
								bRenderSelectionOutline,
								bRenderSelectionHandles,
								bRenderPerWidgetSelectionOutline,
								bRenderTitleSafeRegionOutline;

var	config	bool				mViewDrawBkgnd;
var	config	bool				mViewDrawGrid;
/** if TRUE then primitive scene is rendered in wireframe mode */
var config	bool				bViewShowWireframe;

var	config	int					ToolMode;

var config  int					GridSize;
var config  bool				bSnapToGrid;
var config  bool				bShowDockHandles;

/**
 * the name of the platform (PC, Xbox, etc.) being used as the current preview platform.
 */
var	config	string				CurrentPreviewPlatform;

/**
 * the current mode for previewing split-screen
 */
var	config	ESplitScreenType	CurrentSSPreviewMode;

cpptext
{
	/**
	 * Retrieves the size that the UI should use as the size of the viewport when resolving positions.
	 *
	 * @param	RenderViewport	if the VirtualSize is 'Auto', the output values are filled using the size of this viewport.
	 * @param	out_SizeX		receives the horizontal size of the viewport
	 * @param	out_SizeY		receives the vertical size of the viewport
	 * @param	bIgnoreSSLayout	specify TRUE to ignore the current split-screen layout preview mode and assume fullscreen
	 * @param	bIgnoreGutter	specify TRUE to ignore any gutter value being applied.
	 *
	 * @return	TRUE if a virtual viewport size has been set, FALSE if the virtual viewport size is "Auto"
	 */
	UBOOL GetVirtualViewportSize( FViewport* RenderViewport, FLOAT& out_SizeX, FLOAT& out_SizeY, UBOOL bIgnoreSSLayout=FALSE, UBOOL bIgnoreGutter=FALSE ) const;

	/**
	 * Returns a string representation of the virtual viewport size, in the format:
	 * 640x480
	 * (assuming VirtualSizeX is 640 and VirtualSizeY is 480)
	 *
	 * @return	a string representing the configured viewport size, or an empty string to indicate that the viewport
	 *			should take up the entire window (auto-expand)
	 */
	FString	GetViewportSizeString() const;

	/**
	 * Sets the values for VirtualSizeX and VirtualSizeY from a string in the format:
	 * 640x480
	 * (assuming you wanted to set VirtualSizeX to 640 and VirtualSizeY to 480).  To indicate
	 * that the viewport should take up the entire window (auto-expand), pass in an empty string.
	 *
	 * @return	TRUE if the input string was successfully parsed into a SizeX and SizeY value.
	 */
	UBOOL SetViewportSize( const FString& ViewportSizeString );
}

DefaultProperties
{

}
