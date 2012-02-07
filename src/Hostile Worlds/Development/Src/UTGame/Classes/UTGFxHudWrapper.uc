/**********************************************************************

Copyright   :   Copyright 2006-2007 Scaleform Corp. All Rights Reserved.

Portions of the integration code is from Epic Games as identified by Perforce annotations.
Copyright 2010 Epic Games, Inc. All rights reserved.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
/**
 * HUDWrapper to workaround lack of multiple inheritance.
 * Related Flash content:   ut3_hud.fla
 *                          ut3_minimap.fla
 *                          ut3_scoreboard.fla
 * 
 */
class UTGFxHudWrapper extends UTHUDBase;

var GFxMinimapHud   HudMovie;

var GFxUIScoreboard     ScoreboardMovie;

var GFxUI_PauseMenu		PauseMenuMovie;

var GFxProjectedUI      InventoryMovie;

/** Class of HUD Movie object */
var class<GFxMinimapHUD> MinimapHUDClass;

/** Whether to let actor overlays get drawn this tick */
var bool	bEnableActorOverlays;

/** Cache viewport size to determine if it has changed */
var int ViewX, ViewY;

exec function MinimapZoomIn()
{
	HudMovie.MinimapZoomIn();
}

exec function MinimapZoomOut()
{
	HudMovie.MinimapZoomOut();
}

exec function ShowMenu()
{
	// if using GFx HUD, use GFx pause menu
	TogglePauseMenu();
}

singular event Destroyed()
{
	RemoveMovies();

	Super.Destroy();
}

/** 
  * Destroy existing Movies
  */
function RemoveMovies()
{
	if ( HUDMovie != None )
	{
		HUDMovie.Close(true);
		HUDMovie = None;
	}
	if (PauseMenuMovie != None)
	{
		PauseMenuMovie.Close(true);
		PauseMenuMovie = None;
	}
	if ( ScoreboardMovie != None )
	{
		ScoreboardMovie.Close(true);
		ScoreboardMovie = None;
	}
	if (InventoryMovie != None)
	{
		InventoryMovie.Close(true);
		InventoryMovie = None;
	}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	CreateHUDMovie();
}

/** 
  * Create and initialize the HUDMovie.
  */
function CreateHUDMovie()
{
	HudMovie = new MinimapHUDClass;
	HudMovie.SetTimingMode(TM_Real);
	HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
	HudMovie.ToggleCrosshair(true);
}


/** 
 *  Toggles visibility of normal in-game HUD
 */
function SetVisible(bool bNewVisible)
{
	HudMovie.ToggleCrosshair(bNewVisible);
	HudMovie.Minimap.SetVisible(bNewVisible);
	bEnableActorOverlays = bNewVisible;
	bShowHUD = bNewVisible;
}

function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
	HudMovie.DisplayHit(HitDir, Damage, DamageType);
}

/*
 * Toggle the Pause Menu on or off.
 * 
 */
function TogglePauseMenu()
{
    if ( PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen )
        PauseMenuMovie.PlayCloseAnimation();
	else
    {
		if ( InventoryMovie != none && InventoryMovie.bMovieIsOpen )
		{
			InventoryMovie.StartCloseAnimation();
			return;
		}

        PlayerOwner.SetPause(True);

        if (PauseMenuMovie == None)
        {
	        PauseMenuMovie = new class'GFxUI_PauseMenu';
            PauseMenuMovie.MovieInfo = SwfMovie'UDKHud.udk_pausemenu';
            PauseMenuMovie.bEnableGammaCorrection = FALSE;
			PauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
            PauseMenuMovie.SetTimingMode(TM_Real);
        }

        SetVisible(false);
        PauseMenuMovie.Start();
        PauseMenuMovie.PlayOpenAnimation();
        PauseMenuMovie.AddFocusIgnoreKey('Escape');
    }
}

/*
 * Complete necessary actions for OnPauseMenuClose.
 * Fired from Flash.
 */
function CompletePauseMenuClose()
{
    PlayerOwner.SetPause(False);
    PauseMenuMovie.Close(false);  // Keep the Pause Menu loaded in memory for reuse.
    SetVisible(true);
}

event PostRender()
{
	local bool bNeedScoreboardMovie, bNeedInventoryMovie, bNeedPauseMenuMovie;

    RenderDelta = WorldInfo.TimeSeconds - LastHUDRenderTime;

	bIsSplitscreen = class'Engine'.static.IsSplitScreen();
	ResolutionScaleX = Canvas.ClipX/1024;
	ResolutionScale = Canvas.ClipY/768;
	if ( bIsSplitScreen )
		ResolutionScale *= 2.0;

	// re-create the HUD movie initially and whenever resolution changes
	if ( (ViewX != Canvas.ClipX) || (ViewY != Canvas.ClipY) )
	{
		bNeedScoreboardMovie =  ScoreboardMovie != None && ScoreboardMovie.bMovieIsOpen;
		bNeedInventoryMovie = InventoryMovie != none && InventoryMovie.bMovieIsOpen;
		bNeedPauseMenuMovie = PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen;
		RemoveMovies();
		CreateHUDMovie();
		if ( bNeedScoreboardMovie )
		{
			SetShowScores(true);
		}
		if ( bNeedInventoryMovie )
		{
			ToggleInventory();
		}
		if ( bNeedPauseMenuMovie )
		{
			TogglePauseMenu();
		}
		ViewX = Canvas.ClipX;
		ViewY = Canvas.ClipY;
	}
	UTGRI = UTGameReplicationInfo(WorldInfo.GRI);

	if (HudMovie != none)
		HudMovie.TickHud(0);

	if ( ScoreboardMovie != None && ScoreboardMovie.bMovieIsOpen )
	{
	   ScoreboardMovie.Tick(RenderDelta);
	}

	if ( InventoryMovie != none && InventoryMovie.bMovieIsOpen )
	{
		InventoryMovie.Tick(RenderDelta);
		InventoryMovie.UpdatePos();
	}

	if ( bShowHud && bEnableActorOverlays )
	{
		DrawHud();
	}

	LastHUDRenderTime = WorldInfo.TimeSeconds;
}

/*
 * Complete close of Scoreboard.  Fired from Flash
 * when the "close" animation is finished.
 */
function OnCloseAnimComplete()
{
	// Close the scoreboard but keep it in memory.
    ScoreboardMovie.Close(false);
}

/*
 * Complete open of Scoreboard.  Fired from Flash
 * when the "open" animation is finished.
 */
function OnOpenAnimComplete()
{
}

/*
 * SetShowScores() override to display GFx Scoreboard.
 * If the scoreboard has been loaded, this will play the appropriate
 * Flash animation.
 */
exec function SetShowScores(bool bEnableShowScores)
{
    if(bEnableShowScores)
    {
        if ( ScoreboardMovie == None )
        {
            ScoreboardMovie = new class'GFxUIScoreboard';
			ScoreboardMovie.LocalPlayerOwnerIndex = HudMovie.LocalPlayerOwnerIndex;
			ScoreboardMovie.SetTimingMode(TM_Real);
			ScoreboardMovie.ExternalInterface = self;
		}

        if ( !ScoreboardMovie.bMovieIsOpen )
        {
            ScoreboardMovie.Start();
            ScoreboardMovie.PlayOpenAnimation();
        }
		SetVisible(false);
    }
    else if ( (ScoreboardMovie != None) && ScoreboardMovie.bMovieIsOpen )
	{
		ScoreboardMovie.PlayCloseAnimation();
		SetVisible(true);
	}
}

/**
  * Call PostRenderFor() on actors that want it.
  */
event DrawHUD()
{
	local vector ViewPoint;
	local rotator ViewRotation;
	local float XL, YL, YPos;

	if (UTGRI != None && !UTGRI.bMatchIsOver  )
	{
		Canvas.Font = GetFontSizeIndex(0);
		PlayerOwner.GetPlayerViewPoint(ViewPoint, ViewRotation);
		DrawActorOverlays(Viewpoint, ViewRotation);
	}

	if ( bCrosshairOnFriendly )
	{
		// verify that crosshair trace might hit friendly
		bGreenCrosshair = CheckCrosshairOnFriendly();
		bCrosshairOnFriendly = false;
	}
	else
	{
		bGreenCrosshair = false;
	}

	if ( HudMovie.bDrawWeaponCrosshairs )
	{
		PlayerOwner.DrawHud(self);
	}

	if ( bShowDebugInfo )
	{
		Canvas.Font = GetFontSizeIndex(0);
		Canvas.DrawColor = ConsoleColor;
		Canvas.StrLen("X", XL, YL);
		YPos = 0;
		PlayerOwner.ViewTarget.DisplayDebug(self, YL, YPos);

		if (ShouldDisplayDebug('AI') && (Pawn(PlayerOwner.ViewTarget) != None))
		{
			DrawRoute(Pawn(PlayerOwner.ViewTarget));
		}
		return;
	}
}

function LocalizedMessage
(
	class<LocalMessage>		InMessageClass,
	PlayerReplicationInfo	RelatedPRI_1,
	PlayerReplicationInfo	RelatedPRI_2,
	string					CriticalString,
	int						Switch,
	float					Position,
	float					LifeTime,
	int						FontSize,
	color					DrawColor,
	optional object			OptionalObject
)
{
	local class<UTLocalMessage> UTMessageClass;

	UTMessageClass = class<UTLocalMessage>(InMessageClass);

	if (InMessageClass == class'UTMultiKillMessage')
		HudMovie.ShowMultiKill(Switch, "Kill Streak!");
	else if (ClassIsChildOf (InMessageClass, class'UTDeathMessage'))
		HudMovie.AddDeathMessage (RelatedPRI_1, RelatedPRI_2, class<UTDamageType>(OptionalObject));
	else  if ( (UTMessageClass == None) || UTMessageClass.default.MessageArea > 6 )
	{
		HudMovie.AddMessage("text", InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
	}
	else if ( (UTMessageClass.default.MessageArea < 4) || (UTMessageClass.default.MessageArea == 6) )
	{
		HudMovie.SetCenterText(InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
	}	

	// Skip message area 4,5 for now (pickup and weapon switch messages)
}

/**
 * Add a new console message to display.
 */
function AddConsoleMessage(string M, class<LocalMessage> InMessageClass, PlayerReplicationInfo PRI, optional float LifeTime)
{
	// check for beep on message receipt
	if( bMessageBeep && InMessageClass.default.bBeep )
	{
		PlayerOwner.PlayBeepSound();
	}

	HudMovie.AddMessage("text", M);
}

/*
 * Toggle for  3D Inventory menu.
 */
exec function ToggleInventory()
{
    if ( InventoryMovie != None && InventoryMovie.bMovieIsOpen )
    {
        InventoryMovie.StartCloseAnimation();
    }
    else if ( PlayerOwner.Pawn != None )
    {
		if (InventoryMovie == None)
			InventoryMovie = new class'GFxProjectedUI';

		InventoryMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
		InventoryMovie.SetTimingMode(TM_Real);
		InventoryMovie.Start();

		if (!WorldInfo.bPlayersOnly)
		   PlayerOwner.ConsoleCommand("playersonly");

		// Hide the HUD.
		SetVisible(false);
    }
}

function CompleteCloseInventory()
{
	if (WorldInfo.bPlayersOnly)
	{
		PlayerOwner.ConsoleCommand("playersonly");
	}

	SetTimer(0.1, false, 'CompleteCloseTimer');
}

/*
 * Used to manage the timing of events on Inventory close.
 *
 */
function CompleteCloseTimer()
{
    //If InventoryMovie exists, destroy it.
    if ( InventoryMovie != none && InventoryMovie.bMovieIsOpen )
    {
        InventoryMovie.Close(false); // Keep the Pause Menu loaded in memory for reuse.
    }

	SetVisible(true);
}

defaultproperties
{
	bEnableActorOverlays=true
	MinimapHUDClass=class'GFxMinimapHUD'
}