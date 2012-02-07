// ============================================================================
// HWGFxHUD_Mouse
// The movie clip providing a mouse cursor that is drawn on-top of the HUD.
//
// Related Flash content: UDKGame/Flash/HWHud/hwhud_mouse.fla
//
// Author:  Nick Pruehs
// Date:    2011/05/04
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxHUD_Mouse extends GFxMoviePlayer;

/** The mouse cursor of the HUD. */
var GFxObject MouseCursor;

function bool Start(optional bool StartPaused = false)
{
	local bool bLoadErrors;

	bLoadErrors = super.Start(StartPaused);

	// initialize this movie clip without actually advancing the movie
    Advance(0.f);

	// don't scale mouse cursor
	SetViewScaleMode(SM_NoScale);

	// ensure mouse cursor is always on top
	MouseCursor = GetVariableObject("mouseCursor");
	MouseCursor.SetBool("topmostLevel", true);

	`log("§§§ GUI: "$self$" has been started.");

	return bLoadErrors; // (b && true = b)
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWHud.hwhud_mouse'

	bDisplayWithHudOff=false    
    TimingMode=TM_Real
	bPauseGameWhileActive=false
	bIgnoreMouseInput=false
}
