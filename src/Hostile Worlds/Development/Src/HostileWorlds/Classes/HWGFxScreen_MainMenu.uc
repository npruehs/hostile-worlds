// ============================================================================
// HWGFxScreen_MainMenu
// The main menu of Hostile Worlds.
//
// Related Flash content: UDKGame/Flash/HWScreens/hw_mainmenu.fla
//
// Author:  Nick Pruehs
// Date:    2011/03/29
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxScreen_MainMenu extends HWGFxScreen;

// ----------------------------------------------------------------------------
// Widgets.

var GFxClikWidget BtnHostGame;
var GFxClikWidget BtnJoinGame;
var GFxClikWidget BtnOptions;
var GFxClikWidget BtnCredits;
var GFxClikWidget BtnQuitGame;

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string BtnTextHostGame;
var localized string BtnTextJoinGame;
var localized string BtnTextOptions;
var localized string BtnTextCredits;
var localized string BtnTextQuitGame;

// ----------------------------------------------------------------------------
// Description texts.

var localized string DescriptionHostGame;
var localized string DescriptionJoinGame;
var localized string DescriptionOptions;
var localized string DescriptionCredits;
var localized string DescriptionQuitGame;

// ----------------------------------------------------------------------------
// Dialog texts.

var localized string DialogTitleQuitGame;
var localized string DialogMessageQuitGame;


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
		case ('btnHostGame'):
			if (BtnHostGame == none)
			{
				BtnHostGame = InitButton(Widget, WidgetName, BtnTextHostGame, OnButtonPressHostGame, OnButtonRollOverHostGame);
				return true;
			}
            break;

		case ('btnJoinGame'):
			if (BtnJoinGame == none)
			{
				BtnJoinGame = InitButton(Widget, WidgetName, BtnTextJoinGame, OnButtonPressJoinGame, OnButtonRollOverJoinGame);
				return true;
			}
            break;

		case ('btnOptions'):
			if (BtnOptions == none)
			{
				BtnOptions = InitButton(Widget, WidgetName, BtnTextOptions, OnButtonPressOptions, OnButtonRollOverOptions);
				return true;
			}
            break;

		case ('btnCredits'):
			if (BtnCredits == none)
			{
				BtnCredits = InitButton(Widget, WidgetName, BtnTextCredits, OnButtonPressCredits, OnButtonRollOverCredits);
				return true;
			}
            break;

		case ('btnQuitGame'):
			if (BtnQuitGame == none)
			{
				BtnQuitGame = InitButton(Widget, WidgetName, BtnTextQuitGame, OnButtonPressQuitGame, OnButtonRollOverQuitGame);
				return true;
			}
            break;

        default:
			break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

// ----------------------------------------------------------------------------
// Button OnPress events.

function OnButtonPressHostGame(GFxClikWidget.EventData ev)
{
	FrontEnd.SwitchToScreenHostGame();
}

function OnButtonPressJoinGame(GFxClikWidget.EventData ev)
{
	FrontEnd.SwitchToScreenJoinGame();
}

function OnButtonPressOptions(GFxClikWidget.EventData ev)
{
	FrontEnd.SwitchToScreenOptions();
}

function OnButtonPressCredits(GFxClikWidget.EventData ev)
{
	FrontEnd.SwitchToScreenCredits();
}

function OnButtonPressQuitGame(GFxClikWidget.EventData ev)
{
	 FrontEnd.SpawnDialogQuestion(DialogTitleQuitGame, DialogMessageQuitGame,  OnDialogYesQuitGame);
}

// ----------------------------------------------------------------------------
// OnRollOver events.

function OnButtonRollOverHostGame(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionHostGame);
}

function OnButtonRollOverJoinGame(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionJoinGame);
}

function OnButtonRollOverOptions(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionOptions);
}

function OnButtonRollOverCredits(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionCredits);
}

function OnButtonRollOverQuitGame(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionQuitGame);
}

// ----------------------------------------------------------------------------
// Dialog events.

function OnDialogYesQuitGame()
{
	 ConsoleCommand("quit");
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWScreens.hw_mainmenu'

	WidgetBindings.Add((WidgetName="btnHostGame",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnJoinGame",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnOptions",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCredits",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnQuitGame",WidgetClass=class'GFxClikWidget'))
}
