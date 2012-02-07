// ============================================================================
// HWGFxHUD_CommandWindow
// The HUD window providing access to all standard orders.
//
// Related Flash content: UDKGame/Flash/HWHud/hwhud_commandwindow.fla
//
// Author:  Nick Pruehs
// Date:    2011/05/04
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxHUD_CommandWindow extends HWGFxHUDView;

// ----------------------------------------------------------------------------
// Widgets.

var GFxClikWidget BtnCommandMove;
var GFxClikWidget BtnCommandStop;
var GFxClikWidget BtnCommandHoldPosition;
var GFxClikWidget BtnCommandAttack;
var GFxClikWidget BtnFocusCommander;
var GFxClikWidget BtnRespawnCommander;
var GFxClikWidget BtnSelectAll;
var GFxClikWidget TextAreaTooltip;

// ----------------------------------------------------------------------------
// Description texts.

var localized string TooltipCommandMove;
var localized string TooltipCommandStop;
var localized string TooltipCommandHoldPosition;
var localized string TooltipCommandAttack;
var localized string TooltipFocusCommander;
var localized string TooltipRespawnCommander;
var localized string TooltipSelectAll;

var localized string TooltipCommandMoveDescription;
var localized string TooltipCommandStopDescription;
var localized string TooltipCommandHoldPositionDescription;
var localized string TooltipCommandAttackDescription;
var localized string TooltipFocusCommanderDescription;
var localized string TooltipRespawnCommanderDescription;
var localized string TooltipSelectAllDescription;


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
		case ('btnCommandMove'):
			if (BtnCommandMove == none)
			{
				BtnCommandMove = GFxClikWidget(Widget);
				BtnCommandMove.AddEventListener('CLIK_press', OnButtonPressCommandMove);
				BtnCommandMove.AddEventListener('CLIK_rollOver', OnButtonRollOverCommandMove);
				BtnCommandMove.AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnCommandStop'):
			if (BtnCommandStop == none)
			{
				BtnCommandStop = GFxClikWidget(Widget);
				BtnCommandStop.AddEventListener('CLIK_press', OnButtonPressCommandStop);
				BtnCommandStop.AddEventListener('CLIK_rollOver', OnButtonRollOverCommandStop);
				BtnCommandStop.AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnCommandHoldPosition'):
			if (BtnCommandHoldPosition == none)
			{
				BtnCommandHoldPosition = GFxClikWidget(Widget);
				BtnCommandHoldPosition.AddEventListener('CLIK_press', OnButtonPressCommandHoldPosition);
				BtnCommandHoldPosition.AddEventListener('CLIK_rollOver', OnButtonRollOverCommandHoldPosition);
				BtnCommandHoldPosition.AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnCommandAttack'):
			if (BtnCommandAttack == none)
			{
				BtnCommandAttack = GFxClikWidget(Widget);
				BtnCommandAttack.AddEventListener('CLIK_press', OnButtonPressCommandAttack);
				BtnCommandAttack.AddEventListener('CLIK_rollOver', OnButtonRollOverCommandAttack);
				BtnCommandAttack.AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnFocusCommander'):
			if (BtnFocusCommander == none)
			{
				BtnFocusCommander = GFxClikWidget(Widget);
				BtnFocusCommander.AddEventListener('CLIK_press', OnButtonPressFocusCommander);
				BtnFocusCommander.AddEventListener('CLIK_rollOver', OnButtonRollOverFocusCommander);
				BtnFocusCommander.AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnRespawnCommander'):
			if (BtnRespawnCommander == none)
			{
				BtnRespawnCommander = GFxClikWidget(Widget);
				BtnRespawnCommander.AddEventListener('CLIK_press', OnButtonPressRespawnCommander);
				BtnRespawnCommander.AddEventListener('CLIK_rollOver', OnButtonRollOverRespawnCommander);
				BtnRespawnCommander.AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnSelectAll'):
			if (BtnSelectAll == none)
			{
				BtnSelectAll = GFxClikWidget(Widget);
				BtnSelectAll.AddEventListener('CLIK_press', OnButtonPressSelectAll);
				BtnSelectAll.AddEventListener('CLIK_rollOver', OnButtonRollOverSelectAll);
				BtnSelectAll.AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('textAreaTooltip'):
			if (TextAreaTooltip == none)
			{
				TextAreaTooltip = GFxClikWidget(Widget);
				TextAreaTooltip.SetText("");
				return true;
			}
			break;

        default:
            break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

/** Updates this command window based on the current selection of the local player. */
function Update()
{
	local HWPlayerController ThePlayer;
	local HWSelectable s;
	local HWPawn SelectedUnit;

	ThePlayer = HWPlayerController(myHUD.PlayerOwner);

	// if the player selected any own unit, show the command buttons...
	if (ThePlayer.SelectedUnits.Length > 0)
    {
		foreach ThePlayer.SelectedUnits(s)
		{
			SelectedUnit = HWPawn(s);

			if (SelectedUnit != none && SelectedUnit.OwningPlayer == ThePlayer)
			{
				
				ShowCommandButtons();
				return;
			}
		}
    }
	
	// ...and hide them if not
	HideCommandButtons();
}

/** Shows the Move, Stop, Hold Position and Attack command buttons. */
function ShowCommandButtons()
{
	BtnCommandMove.SetVisible(true);
	BtnCommandStop.SetVisible(true);
	BtnCommandHoldPosition.SetVisible(true);
	BtnCommandAttack.SetVisible(true);
}

/** Hides the Move, Stop, Hold Position and Attack command buttons. */
function HideCommandButtons()
{
	BtnCommandMove.SetVisible(false);
	BtnCommandStop.SetVisible(false);
	BtnCommandHoldPosition.SetVisible(false);
	BtnCommandAttack.SetVisible(false);
}

/**
 * Shows and hides the Focus Commander and Respawn Commander buttons according
 * to whether the commander of the local player is currently alive or not.
 * 
 * @param bAlive
 *      whether the commander of the local player is currently alive or not
 */
function NotifyCommanderAlive(bool bAlive)
{
	BtnFocusCommander.SetVisible(bAlive);
	BtnRespawnCommander.SetVisible(!bAlive);
}

/**
 * Changes the tooltip shown next to the command window. Supports basic HTML.
 * 
 * @param Tooltip
 *      the new tooltip to show
 */
function ShowTooltip(string Tooltip)
{
	TextAreaTooltip.SetString("htmlText", Tooltip);
}

/** Clears the tooltip shown next to the command window. */
function ClearTooltip()
{
	TextAreaTooltip.SetString("htmlText", "");
}

// ----------------------------------------------------------------------------
// Button OnPress events.

function OnButtonPressCommandMove(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).TriggerMoveOrder();
}

function OnButtonPressCommandStop(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).TriggerStopOrder();
}

function OnButtonPressCommandHoldPosition(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).TriggerHoldPositionOrder();
}

function OnButtonPressCommandAttack(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).TriggerAttackOrder();
}

function OnButtonPressFocusCommander(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).SelectCommander();
}

function OnButtonPressRespawnCommander(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).RespawnCommander();
}

function OnButtonPressSelectAll(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).SelectAllSquadMembers();
}

// ----------------------------------------------------------------------------
// Button OnRollOver events.

function OnButtonRollOverCommandMove(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipCommandMove, TooltipCommandMoveDescription);
}

function OnButtonRollOverCommandStop(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipCommandStop, TooltipCommandStopDescription);
}

function OnButtonRollOverCommandHoldPosition(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipCommandHoldPosition, TooltipCommandHoldPositionDescription);
}

function OnButtonRollOverCommandAttack(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipCommandAttack, TooltipCommandAttackDescription);
}

function OnButtonRollOverFocusCommander(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipFocusCommander, TooltipFocusCommanderDescription);
}

function OnButtonRollOverRespawnCommander(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipRespawnCommander, TooltipRespawnCommanderDescription);
}

function OnButtonRollOverSelectAll(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipSelectAll, TooltipSelectAllDescription);
}

// ----------------------------------------------------------------------------
// Button OnRollOver events.

function OnButtonRollOut(GFxClikWidget.EventData ev)
{
	ClearTooltip();
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWHud.hwhud_commandwindow'

	WidgetBindings.Add((WidgetName="btnCommandMove",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCommandStop",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCommandHoldPosition",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCommandAttack",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnFocusCommander",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnRespawnCommander",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnSelectAll",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="textAreaTooltip",WidgetClass=class'GFxClikWidget'))
}
