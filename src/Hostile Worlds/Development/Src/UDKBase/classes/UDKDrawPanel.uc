/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKDrawPanel extends UDKUI_Widget
	placeable
	native;

/** If false, the cavas will be preset to the bounds of the panel.  If it's true, canvas will the full viewport */
var() bool bUseFullViewport;

/** Holds a reference to the canvas.  This is only valid during the DrawPanel() event */
var Canvas Canvas;

/** Holds the Coords of this panel in PixelViewport and it's only valid during rendering */
var float pLeft, pTop, pWidth, pHeight;

/** Viewport.Y / 768 - The scaling factor for this widget */
var float ResolutionScale;

cpptext
{
	void PostRender_Widget(FCanvas* Canvas);
}

/** Draws a 2D Line */
native final function Draw2DLine(int X1, int Y1, int X2, int Y2, color LineColor);


/**
 * In both functions below, Canvas will to the bounds of the widget.  You should
 * use DrawTile() with bClipTile=TRUE in order to make sure left/top clipping occurs if not
 * against the left/top edges
 */

/**
 * If this delegate is set, native code will call here first for rendering.
 *
 * @Return true to stop native code from calling the event
 */

delegate bool DrawDelegate(Canvas C);


/**
 * Handle drawing in script
 */

event DrawPanel();


defaultproperties
{
	// States
	DefaultStates.Add(class'Engine.UIState_Focused')

	bUseFullViewport=false
}

