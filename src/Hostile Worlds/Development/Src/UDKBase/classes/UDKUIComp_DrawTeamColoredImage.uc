/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Automatically apply a team color to an image
 */

class UDKUIComp_DrawTeamColoredImage extends UIComp_DrawImage
	native;

/** Holds the colors to use.  The last color in the array will be used for non-team games as well as team indexes that
    are out of range. */
var(Team) array<LinearColor> TeamColors;

/** For Testing - If we are in the editor, but not in the game, this value will be used */
var(Team) int EditorTeamIndex;

cpptext
{
	virtual void RenderComponent( class FCanvas* Canvas, FRenderParameters Parameters );
}

defaultproperties
{
	TeamColors[0]=(R=3.0,G=0.0,B=0.05,A=1.0)
	TeamColors[1]=(R=0.5,G=0.8,B=10.0,A=1.0)
	TeamColors[2]=(R=4.0,G=2.0,B=0.5,A=1.0)
}
