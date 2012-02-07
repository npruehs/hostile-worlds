// ============================================================================
// HWGFxScreen_JoinGame
// The Join Game screen of Hostile Worlds. Allows specifying a player name and
// the public IP address of the server to connect to.
//
// Related Flash content: UDKGame/Flash/HWScreens/hw_joingame.fla
//
// Author:  Nick Pruehs
// Date:    2011/04/07
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxScreen_JoinGame extends HWGFxScreen
	config(HostileWorlds);

// ----------------------------------------------------------------------------
// Widgets.

var GFxObject LabelPlayerName;
var GFxObject LabelHostIP;
var GFxClikWidget InputPlayerName;
var GFxClikWidget InputHostIP;
var GFxClikWidget BtnJoinGame;
var GFxClikWidget BtnBackToMainMenu;

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string LabelTextPlayerName;
var localized string LabelTextHostIP;
var localized string BtnTextJoinGame;
var localized string BtnTextBackToMainMenu;

var config string HostIP;

// ----------------------------------------------------------------------------
// Description texts.

var localized string DescriptionPlayerName;
var localized string DescriptionHostIP;
var localized string DescriptionJoinGame;
var localized string DescriptionBackToMainMenu;


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local string PlayerName;

    switch (WidgetName)
    {
        case ('labelPlayerName'): 
            if (LabelPlayerName == none)
            {
				LabelPlayerName = InitLabel(Widget, WidgetName, LabelTextPlayerName);
				return true;
            }
            break;

        case ('labelHostIP'): 
            if (LabelHostIP == none)
            {
				LabelHostIP = InitLabel(Widget, WidgetName, LabelTextHostIP);
				return true;
            }
            break;

		case ('inputPlayerName'):
			if (InputPlayerName == none)
			{
				PlayerName = HWPlayerController(GetPC()).GetPlayerSettings().PlayerName;

				InputPlayerName = InitInput(Widget, WidgetName, PlayerName, OnInputRollOverPlayerName);
				InputPlayerName.AddEventListener('CLIK_textChange', OnInputTextChangePlayerName);
				return true;
			}
			break;

		case ('inputHostIP'):
			if (InputHostIP == none)
			{
				InputHostIP = InitInput(Widget, WidgetName, HostIP, OnInputRollOverHostIP);
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

		case ('btnBackToMainMenu'):
			if (BtnBackToMainMenu == none)
			{
				BtnBackToMainMenu = InitButton(Widget, WidgetName, BtnTextBackToMainMenu, OnButtonPressBackToMainMenu, OnButtonRollOverBackToMainMenu);
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

function OnButtonPressJoinGame(GFxClikWidget.EventData ev)
{
	local string PlayerName;

	PlayerName = InputPlayerName.GetText();
	HostIP = InputHostIP.GetText();

	SaveConfig();

	FrontEnd.ConnectToServer(PlayerName, HostIP);
}

function OnButtonPressBackToMainMenu(GFxClikWidget.EventData ev)
{
	FrontEnd.SwitchToScreenMainMenu();
}

// ----------------------------------------------------------------------------
// OnRollOver events.

function OnInputRollOverPlayerName(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionPlayerName);
}

function OnInputRollOverHostIP(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionHostIP);
}

function OnButtonRollOverJoinGame(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionJoinGame);
}

function OnButtonRollOverBackToMainMenu(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionBackToMainMenu);
}

// ----------------------------------------------------------------------------
// OnTextChange events.

function OnInputTextChangePlayerName(GFxClikWidget.EventData ev)
{
	local string EnteredText;

	EnteredText = InputPlayerName.GetText();
	EnteredText = FrontEnd.ValidatePlayerName(EnteredText);
	InputPlayerName.SetText(EnteredText);
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWScreens.hw_joingame'

	WidgetBindings.Add((WidgetName="labelPlayerName",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelHostIP",WidgetClass=class'GFxObject'))

	WidgetBindings.Add((WidgetName="inputPlayerName",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="inputHostIP",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnJoinGame",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBackToMainMenu",WidgetClass=class'GFxClikWidget'))
}
