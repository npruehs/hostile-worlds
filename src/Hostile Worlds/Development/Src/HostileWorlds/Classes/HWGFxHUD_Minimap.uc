// ============================================================================
// HWGFxHUD_Minimap
// The HUD window showing the minimap, including the map's texture, fog
// of war, all visible units and the view frustum.
//
// Related Flash content: UDKGame/Flash/HWHud/hwhud_minimap.fla
//
// Author:  Nick Pruehs
// Date:    2011/05/11
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxHUD_Minimap extends HWGFxHUDView;

// ----------------------------------------------------------------------------
// Widgets.

var GFxClikWidget BtnToggleFogOfWar;
var GFxClikWidget BtnToggleTerrain;
var GFxClikWidget BtnToggleUnits;
var GFxClikWidget BtnToggleTeamColors;

// ----------------------------------------------------------------------------
// Description texts.

var localized string TooltipToggleFogOfWar;
var localized string TooltipToggleTerrain;
var localized string TooltipToggleUnits;
var localized string TooltipToggleTeamColors;

var localized string TooltipToggleFogOfWarDescription;
var localized string TooltipToggleTerrainDescription;
var localized string TooltipToggleUnitsDescription;
var localized string TooltipToggleTeamColorsDescription;


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
		case ('btnToggleFogOfWar'):
			if (BtnToggleFogOfWar == none)
			{
				BtnToggleFogOfWar = GFxClikWidget(Widget);
				BtnToggleFogOfWar.AddEventListener('CLIK_press', OnButtonPressToggleFogOfWar);
				BtnToggleFogOfWar.AddEventListener('CLIK_rollOver', OnButtonRollOverToggleFogOfWar);
				BtnToggleFogOfWar.AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnToggleTerrain'):
			if (BtnToggleTerrain == none)
			{
				BtnToggleTerrain = GFxClikWidget(Widget);
				BtnToggleTerrain.AddEventListener('CLIK_press', OnButtonPressToggleTerrain);
				BtnToggleTerrain.AddEventListener('CLIK_rollOver', OnButtonRollOverToggleTerrain);
				BtnToggleTerrain.AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnToggleUnits'):
			if (BtnToggleUnits == none)
			{
				BtnToggleUnits = GFxClikWidget(Widget);
				BtnToggleUnits.AddEventListener('CLIK_press', OnButtonPressToggleUnits);
				BtnToggleUnits.AddEventListener('CLIK_rollOver', OnButtonRollOverToggleUnits);
				BtnToggleUnits.AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnToggleTeamColors'):
			if (BtnToggleTeamColors == none)
			{
				BtnToggleTeamColors = GFxClikWidget(Widget);
				BtnToggleTeamColors.AddEventListener('CLIK_press', OnButtonPressToggleTeamColors);
				BtnToggleTeamColors.AddEventListener('CLIK_rollOver', OnButtonRollOverToggleTeamColors);
				BtnToggleTeamColors.AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

        default:
            break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

/** Updates the fog-of-war, all unit positions and the view frustum of this minimap. */
function Update()
{
	myHUD.Minimap.MinimapTexture.bNeedsUpdate = true;

	SetExternalTexture("Minimap", myHUD.Minimap.MinimapTexture);
}

/**
 * Callback function called in Flash to notify this minimap that the player has
 * clicked the left mouse button at the passed minimap coordinates.
 * 
 * @param x
 *      the x-coordinate in tile space the player clicked at
 * @param y
 *      the y-coordinate in tile space the player clicked at
 */
function MinimapLeftMouseDown(float x, float y)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).MinimapScroll(Round(x), Round(y));
}

/**
 * Callback function called in Flash to notify this minimap that the player has
 * clicked the right mouse button at the passed minimap coordinates.
 * 
 * @param x
 *      the x-coordinate in tile space the player clicked at
 * @param y
 *      the y-coordinate in tile space the player clicked at
 */
function MinimapRightMouseDown(float x, float y)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
}

/**
 * Callback function called in Flash to notify this minimap that the player has
 * moved the mouse to the passed minimap coordinates.
 * 
 * @param x
 *      the x-coordinate in tile space the player moved the mouse to
 * @param y
 *      the y-coordinate in tile space the player moved the mouse to
 */
function MinimapMouseMove(float x, float y)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).MinimapScroll(Round(x), Round(y));
}

/**
 * Callback function called in Flash to notify this minimap that the player has
 * released the left mouse button at the passed minimap coordinates.
 * 
 * @param x
 *      the x-coordinate in tile space the player released the mouse button at
 * @param y
 *      the y-coordinate in tile space the player released the mouse button at
 */
function MinimapLeftMouseUp(float x, float y)
{
	HWPlayerController(myHUD.PlayerOwner).MinimapClick(Round(x), Round(y));
}

/**
 * Callback function called in Flash to notify this minimap that the player has
 * released the right mouse button at the passed minimap coordinates.
 * 
 * @param x
 *      the x-coordinate in tile space the player released the mouse button at
 * @param y
 *      the y-coordinate in tile space the player released the mouse button at
 */
function MinimapRightMouseUp(float x, float y)
{
	HWPlayerController(myHUD.PlayerOwner).MinimapRightClick(Round(x), Round(y));
}

// ----------------------------------------------------------------------------
// Button OnPress events.

function OnButtonPressToggleFogOfWar(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).ToggleMinimapFogOfWar();
}

function OnButtonPressToggleTerrain(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).ToggleMinimapTerrain();
}

function OnButtonPressToggleUnits(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).ToggleMinimapUnits();
}

function OnButtonPressToggleTeamColors(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).ToggleMinimapTeamColors();
}

// ----------------------------------------------------------------------------
// Button OnRollOver events.

function OnButtonRollOverToggleFogOfWar(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipToggleFogOfWar, TooltipToggleFogOfWarDescription);
}

function OnButtonRollOverToggleTerrain(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipToggleTerrain, TooltipToggleTerrainDescription);
}

function OnButtonRollOverToggleUnits(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipToggleUnits, TooltipToggleUnitsDescription);
}

function OnButtonRollOverToggleTeamColors(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipToggleTeamColors, TooltipToggleTeamColorsDescription);
}

// ----------------------------------------------------------------------------
// Button OnRollOver events.

function OnButtonRollOut(GFxClikWidget.EventData ev)
{
	myHUD.ClearTooltip();
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWHud.hwhud_minimap'

	WidgetBindings.Add((WidgetName="btnToggleFogOfWar",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnToggleTerrain",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnToggleUnits",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnToggleTeamColors",WidgetClass=class'GFxClikWidget'))
}
