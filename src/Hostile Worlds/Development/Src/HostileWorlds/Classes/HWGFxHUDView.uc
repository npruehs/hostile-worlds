// ============================================================================
// HWGFxHUDView
// Base class for any part of the ingame HUD in Hostile Worlds.
//
// Related Flash content: n/a
//
// Author:  Nick Pruehs
// Date:    2011/04/20
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxHUDView extends GFxMoviePlayer;

/** The HUD this window belongs to. */
var HWHud myHUD;


function bool Start(optional bool StartPaused = false)
{
	local bool bLoadErrors;

	bLoadErrors = super.Start(StartPaused);

	// initialize this view without actually advancing the movie
    Advance(0.f);

	// don't scale HUD views
	SetViewScaleMode(SM_NoScale);

	`log("§§§ GUI: "$self$" has been started.");

	return bLoadErrors; // (b && true = b)
}

/**
 * Constructs and shows a formatted HTML tooltip with the specified title
 * and description.
 * 
 * @param Title
 *      the title to show
 * @param Description
 *      the description to show
 *      
 *  @param HotKey
 *      the HotKey to show
 *      
 * @param Shards
 *      the Shards to show
 */
function ShowTooltipWithTitle(string Title, string Description, optional string HotKey = "", optional string Shards = "")
{
	local string Tooltip;

	if(HotKey != "")
	{
		Tooltip $= "<b><font color=\"#FFFF00\">[" $ HotKey $ "] </font></b> ";
	}

	Tooltip $= "<b><font color=\"#FFFF00\">"$Title$"</font></b>";

	if(Shards != "")
	{
		Tooltip $= " <b><font color=\"#0000FF\">Shards: " $ Shards $" </font></b>";
	}

	Tooltip $= "<br />";
	Tooltip $= "<br />";
	Tooltip $= Description;

	myHUD.ShowTooltip(Tooltip);
}

DefaultProperties
{
	bDisplayWithHudOff=false    
    TimingMode=TM_Real
	bPauseGameWhileActive=false
	bIgnoreMouseInput=false
}
