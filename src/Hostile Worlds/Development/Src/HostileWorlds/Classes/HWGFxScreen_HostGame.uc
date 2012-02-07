// ============================================================================
// HWGFxScreen_HostGame
// The Host Game screen of Hostile Worlds. Allows specifying several game
// options such as the score and time limit or a password.
//
// Related Flash content: UDKGame/Flash/HWScreens/hw_hostgame.fla
//
// Author:  Nick Pruehs
// Date:    2011/03/29
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxScreen_HostGame extends HWGFxScreen;

// ----------------------------------------------------------------------------
// Widgets.

var GFxObject LabelMaps;
var GFxObject LabelPlayerName;
var GFxObject LabelScoreLimit;
var GFxObject LabelTimeLimit;
var GFxClikWidget ListMaps;
var GFxClikWidget TextAreaMapDescription;
var GFxClikWidget InputPlayerName;
var GFxClikWidget InputScoreLimit;
var GFxClikWidget InputTimeLimit;
var GFxClikWidget BtnHostGame;
var GFxClikWidget BtnBackToMainMenu;

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string LabelTextMaps;
var localized string LabelTextPlayerName;
var localized string LabelTextScoreLimit;
var localized string LabelTextTimeLimit;
var localized string BtnTextHostGame;
var localized string BtnTextBackToMainMenu;

// ----------------------------------------------------------------------------
// Description texts.

var localized string DescriptionPlayerName;
var localized string DescriptionScoreLimit;
var localized string DescriptionTimeLimit;
var localized string DescriptionHostGame;
var localized string DescriptionBackToMainMenu;

// ----------------------------------------------------------------------------
// Dialog texts.

var localized string DialogMessageInvalidMap;


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local string PlayerName;
	local int ScoreLimit;
	local int TimeLimit;

    switch (WidgetName)
    {
        case ('labelMaps'): 
            if (LabelMaps == none)
            {
				LabelMaps = InitLabel(Widget, WidgetName, LabelTextMaps);
				return true;
            }
            break;

        case ('labelPlayerName'): 
            if (LabelPlayerName == none)
            {
				LabelPlayerName = InitLabel(Widget, WidgetName, LabelTextPlayerName);
				return true;
            }
            break;

        case ('labelScoreLimit'): 
            if (LabelScoreLimit == none)
            {
				LabelScoreLimit = InitLabel(Widget, WidgetName, LabelTextScoreLimit);
				return true;
            }
            break;

        case ('labelTimeLimit'): 
            if (LabelTimeLimit == none)
            {
				LabelTimeLimit = InitLabel(Widget, WidgetName, LabelTextTimeLimit);
				return true;
            }
            break;

		case ('listMaps'):
			if (ListMaps == none)
			{
				ListMaps = InitList(Widget, WidgetName, FrontEnd.GetMapList(), OnListChangeMaps);
				UpdateMapDescription(0);
				return true;
			}
			break;

		case ('textAreaMapDescription'):
			if (TextAreaMapDescription == none)
			{
				TextAreaMapDescription = GFxClikWidget(Widget);
				UpdateMapDescription(0);
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

		case ('inputScoreLimit'):
			if (InputScoreLimit == none)
			{
				ScoreLimit = GetPC().WorldInfo.Game.GoalScore;

				InputScoreLimit = InitInput(Widget, WidgetName, ScoreLimit, OnInputRollOverScoreLimit);
				return true;
			}
			break;

		case ('inputTimeLimit'):
			if (InputTimeLimit == none)
			{
				TimeLimit = GetPC().WorldInfo.Game.TimeLimit;

				InputTimeLimit = InitInput(Widget, WidgetName, TimeLimit, OnInputRollOverTimeLimit);
				return true;
			}
			break;

		case ('btnHostGame'):
			if (BtnHostGame == none)
			{
				BtnHostGame = InitButton(Widget, WidgetName, BtnTextHostGame, OnButtonPressHostGame, OnButtonRollOverHostGame);
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

function OnButtonPressHostGame(GFxClikWidget.EventData ev)
{
	local int MapIndex;
	local string MapName;
	local string PlayerName;
	local string ScoreLimit;
	local string TimeLimit;

	MapIndex = int(ListMaps.GetFloat("selectedIndex"));

	// check if a valid map has been selected
	if (MapIndex >= FrontEnd.Maps.Length)
	{
		FrontEnd.SpawnDialogError(DialogMessageInvalidMap);
		return;
	}

	MapName = FrontEnd.Maps[MapIndex].MapName;

	PlayerName = InputPlayerName.GetText();
	ScoreLimit = InputScoreLimit.GetText();
	TimeLimit = InputTimeLimit.GetText();

	FrontEnd.StartMatch(MapName, PlayerName, ScoreLimit, TimeLimit);
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

function OnInputRollOverScoreLimit(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionScoreLimit);
}

function OnInputRollOverTimeLimit(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionTimeLimit);
}

function OnButtonRollOverHostGame(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionHostGame);
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

// ----------------------------------------------------------------------------
// OnListChange events.

function OnListChangeMaps(GFxClikWidget.EventData ev)
{
	UpdateMapDescription(ev.index);
}

/**
 * Shows the description of the map with the specified index in the text area.
 * 
 * @param i
 *      the index of the map to show the description of
 */
function UpdateMapDescription(int i)
{
    if (TextAreaMapDescription != none)
    {
		if (i >= 0 && i < FrontEnd.Maps.Length)
		{
			TextAreaMapDescription.SetText(FrontEnd.Maps[i].MapDescription);
		}
		else
		{
			TextAreaMapDescription.SetText("");
		}
    }
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWScreens.hw_hostgame'

	WidgetBindings.Add((WidgetName="labelMaps",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelPlayerName",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelScoreLimit",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTimeLimit",WidgetClass=class'GFxObject'))

	WidgetBindings.Add((WidgetName="listMaps",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="textAreaMapDescription",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="inputPlayerName",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="inputScoreLimit",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="inputTimeLimit",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnHostGame",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBackToMainMenu",WidgetClass=class'GFxClikWidget'))
}
