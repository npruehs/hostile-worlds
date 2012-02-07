// ============================================================================
// HWGFxFrontEnd
// Loads and manages all of the Scaleform GFx movie views. All loaded views
// contain a reference to this class for general menu functionality like screen
// transitions or spawning dialogs. This class acts much like a controller in
// MVC.
//
// Related Flash content: UDKGame/Flash/HWScreens/hw_frontend.fla
//
// Author:  Nick Pruehs
// Date:    2011/03/29
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxFrontEnd extends GFxMoviePlayer
	config(HostileWorlds);

/** The label that shows the title of the current screen. */
var GFxObject LabelScreenTitle;

/** The label that shows information on the object currently hovered by the user. */
var GFxObject LabelInfo;

/** The label that shows the version number of the current build. */
var GFxObject LabelVersion;

/** The screen that is currently active. */
var HWGFxScreen CurrentScreen;

/** The modal dialog that is currently active. */
var HWGFxDialog CurrentDialog;

/** The Main Menu screen. */
var HWGFxScreen_MainMenu ScreenMainMenu;

/** The Host Game screen. */
var HWGFxScreen_HostGame ScreenHostGame;

/** The Join Game screen. */
var HWGFxScreen_JoinGame ScreenJoinGame;

/** The Options screen. */
var HWGFxScreen_Options ScreenOptions;

/** The Credits screen. */
var HWGFxScreen_Credits ScreenCredits;

/** The name of a map associated with its description. */
struct MapEntry
{
	var string MapName;
    var string MapDescription;
};

/** The list of Hostile Worlds maps accessible from the Host Game menu. */
var config array<MapEntry> Maps;

/** The title of the dialog that is shown while trying to connect to a server. */
var localized string DialogConnecting;

/** The message of the dialog that is shown while trying to connect to a remote server. */
var localized string DialogTryingToConnectTo;

/** The caption of the dialog button that is shown while trying to connect to a remote server. */
var localized string DialogCancel;

/** Function signature of dialog event listeners. */
delegate OnDialogClose();


function bool Start(optional bool StartPaused = false)
{
	super.Start(StartPaused);

	// initialize this menu without actually advancing the movie
    Advance(0.f);

	// don't scale menu screens
	SetViewScaleMode(SM_NoScale);

	// clear info label
	ClearInfo();

	// load and show main menu
	ScreenMainMenu = new class'HWGFxScreen_MainMenu';
	ScreenMainMenu.FrontEnd = self;
	
	CurrentScreen = ScreenMainMenu;
	CurrentScreen.ShowView();

	// load other screens
	ScreenHostGame = new class'HWGFxScreen_HostGame';
	ScreenHostGame.FrontEnd = self;

	ScreenJoinGame = new class'HWGFxScreen_JoinGame';
	ScreenJoinGame.FrontEnd = self;

	ScreenOptions = new class'HWGFxScreen_Options';
	ScreenOptions.FrontEnd = self;

	ScreenCredits = new class'HWGFxScreen_Credits';
	ScreenCredits.FrontEnd = self;

	// prepare dialog
	CurrentDialog = new class'HWGFxDialog';
	CurrentDialog.FrontEnd = self;

	// ensure all widgets are initialized before first dialog spawn, and set scale and alignment
	CurrentDialog.Start();
	CurrentDialog.SetViewScaleMode(SM_NoScale);
	CurrentDialog.SetAlignment(Align_Center);
	CurrentDialog.Close(false);

	`log("§§§ GUI: Frontend initialized.");

	return true;
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget) 
{
    switch (WidgetName)
    {
        case ('labelInfo'): 
            if (LabelInfo == none)
            {
				LabelInfo = Widget;

				`log("§§§ GUI: "$self$" has initialized labelInfo = "$LabelInfo);
                return true;
            }
            break;

        case ('labelScreenTitle'): 
            if (LabelScreenTitle == none)
            {
				LabelScreenTitle = Widget;

				`log("§§§ GUI: "$self$" has initialized labelScreenTitle = "$LabelScreenTitle);
                return true;
            }
            break;

        case ('labelVersion'): 
            if (LabelVersion == none)
            {
				LabelVersion = Widget;
				LabelVersion.SetText("Version: "$class'HWGame'.const.VERSION);

				`log("§§§ GUI: "$self$" has initialized labelVersion = "$LabelVersion);
                return true;
            }
            break;

        default:
            break;
    }

    return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

/** Closes the current screen and shows the Main Menu screen instead. */
function SwitchToScreenMainMenu()
{
	SwitchToScreen(ScreenMainMenu);
}

/** Closes the current screen and shows the Host Game screen instead. */
function SwitchToScreenHostGame()
{
	SwitchToScreen(ScreenHostGame);
}

/** Closes the current screen and shows the Join Game screen instead. */
function SwitchToScreenJoinGame()
{
	SwitchToScreen(ScreenJoinGame);
}

/** Closes the current screen and shows the Options screen instead. */
function SwitchToScreenOptions()
{
	SwitchToScreen(ScreenOptions);
}

/** Closes the current screen and shows the Credits screen instead. */
function SwitchToScreenCredits()
{
	SwitchToScreen(ScreenCredits);
}

/**
 * Closes the current screen and shows the specified screen instead.
 * 
 * @param NewScreen
 *      the screen to show
 */
function SwitchToScreen(HWGFxScreen NewScreen)
{
	CurrentScreen.HideView();
	CurrentScreen = NewScreen;
	CurrentScreen.ShowView();

	ClearInfo();
}

/**
 * Spawns a dialog that asks the specified question. Sets up the dialog's
 * delegates to call one of the specified functions when the user closes the
 * dialog.
 * 
 * @param DialogTitle
 *      the title of the dialog
 * @param DialogQuestion
 *      the question to ask
 * @param inOnDialogYes
 *      the function to call when the user hits 'Yes'
 * @param inOnDialogNo
 *      the function to call when the user hits 'No'
 */
function SpawnDialogQuestion(coerce string DialogTitle, coerce string DialogQuestion, delegate<OnDialogClose> inOnDialogYes, optional delegate<OnDialogClose> inOnDialogNo)
{
	CurrentDialog.InitDialogQuestion(DialogTitle, DialogQuestion, inOnDialogYes, inOnDialogNo);
	ShowDialog();
}

/**
 * Spawns a dialog that shows the specified warning. Sets up the dialog's
 * delegates to call one of the specified functions when the user closes the
 * dialog.
 * 
 * @param DialogWarning
 *      the warning to show
 * @param inOnDialogYes
 *      the function to call when the user hits 'Yes'
 * @param inOnDialogNo
 *      the function to call when the user hits 'No'
 */
function SpawnDialogWarning(coerce string DialogWarning, delegate<OnDialogClose> inOnDialogYes, optional delegate<OnDialogClose> inOnDialogNo)
{
	CurrentDialog.InitDialogWarning(DialogWarning, inOnDialogYes, inOnDialogNo);
	ShowDialog();
}

/**
 * Spawns a dialog that shows the specified message. Sets up the dialog's
 * delegate to call the specified function when the user closes the dialog.
 * 
 * @param DialogTitle
 *      the title of the dialog
 * @param DialogMessage
 *      the message to show
 * @param inOnDialogOK
 *      the function to call when the user hits 'OK'
 */
function SpawnDialogInformation(coerce string DialogTitle, coerce string DialogMessage, optional delegate<OnDialogClose> inOnDialogOK)
{
	CurrentDialog.InitDialogInformation(DialogTitle, DialogMessage, inOnDialogOK);
	ShowDialog();
}

/**
 * Spawns a dialog that shows the specified error message. Sets up the dialog's
 * deleaget to call the specified function when the user closes the dialog.
 * 
 * @param DialogErrorMessage
 *      the error message to show
 * @param inOnDialogOK
 *      the function to call when the user hits 'OK'
 */
function SpawnDialogError(coerce string DialogErrorMessage, optional delegate<OnDialogClose> inOnDialogOK)
{
	CurrentDialog.InitDialogError(DialogErrorMessage, inOnDialogOK);
	ShowDialog();
}

/** Disables all subcomponents of the current screen and shows the current modal dialog. */
function ShowDialog()
{
	CurrentScreen.SetStateOfSubComponents(false);
	CurrentDialog.ShowView();
}

/** Enables all subcomponents of the current screen and hides the current modal dialog. */
function HideDialog()
{
	CurrentDialog.HideView();
	CurrentScreen.SetStateOfSubComponents(true);
}

/**
 * Unloads all Flash movies and starts a new Hostile Worlds match with the
 * specified game options.
 * 
 * @param MapName
 *      the name of the map to host
 * @param PlayerName
 *      the name of player hosting the game
 * @param ScoreLimit
 *      the score limit of the match
 * @param TimeLimit
 *      the time limit of the match, in minutes
 */
function StartMatch(string MapName, string PlayerName, string ScoreLimit, string TimeLimit)
{
	local string GameURL;

	UnloadAllViews();

	GameURL = MapName;
	GameURL $= "?listen=true";
	GameURL $= "?Name="$PlayerName;
	GameURL $= "?ScoreLimit="$ScoreLimit;
	GameURL $= "?TimeLimit="$TimeLimit;

	ConsoleCommand("open "$GameURL);
}

/**
 * Unloads all Flash movies and connects to the specified Hostile Worlds server.
 * 
 * @param PlayerName
 *      the name of the player that wants to join
 * @param IP
 *      the public IP address of the server to connect to
 */
function ConnectToServer(string PlayerName, string IP)
{
	UnloadAllViews();

	// show cancel dialog
	CurrentDialog = new class'HWGFxDialog';
	CurrentDialog.FrontEnd = self;
	CurrentDialog.Start();
	CurrentDialog.SetViewScaleMode(SM_NoScale);
	CurrentDialog.SetAlignment(Align_Center);
	CurrentDialog.InitDialogInformation(DialogConnecting, DialogTryingToConnectTo@IP$"...", Disconnect);
	CurrentDialog.BtnOK.SetString("label", DialogCancel);
	ShowDialog();

	ConsoleCommand("open "$IP$"?Name="$PlayerName);
}

/** Hides the cancel dialog and cancels the connection attempt. */
function Disconnect()
{
	CurrentDialog.Close(true);

	ConsoleCommand("disconnect");
}

/** Closes and unloads all views. */
function UnloadAllViews()
{
	ScreenMainMenu.Close(true);
	ScreenHostGame.Close(true);
	ScreenJoinGame.Close(true);
	ScreenOptions.Close(true);
	ScreenCredits.Close(true);
	CurrentDialog.Close(true);
}

/**
 * Changes the text of the screen title label to the passed one.
 * 
 * @param NewTitle
 *      the new screen title to show
 */
function SetScreenTitle(string NewTitle)
{
	LabelScreenTitle.SetText(NewTitle);
}

/**
 * Changes the text of the info label to the passed one.
 * 
 * @param NewInfo
 *      the new info to show
 */
function SetInfo(string NewInfo)
{
	LabelInfo.SetText(NewInfo);
}

/** Clears the text of the info label. */
function ClearInfo()
{
	LabelInfo.SetText("");
}

/**
 * Validates the passed player name by removing any occurences of URL-sensitive
 * characters.
 * 
 * @param PlayerName
 *      the nickname to validate
 */
function string ValidatePlayerName(string PlayerName)
{
	// remove all URL-sensitive characters
	PlayerName = ValidateString(PlayerName, "?");
	PlayerName = ValidateString(PlayerName, "=");
	PlayerName = ValidateString(PlayerName, " ");

	return PlayerName;
}

/**
 * Validates the passed string by removing any occurences of the specified
 * illegal string.
 * 
 * @param Str
 *      the string to validate
 * @param Illegal
 *      the string to remove
 */
function string ValidateString(string Str, string Illegal)
{
	local bool bValid;
	local int i;

	while (!bValid)
	{
		i = InStr(Str, Illegal);

		if (i >= 0)
		{
			Str = Repl(Str, Illegal, "");
		}
		else
		{
			bValid = true;
		}
	}

	return Str;
}

/** Returns a list of all maps that can be hosted from the Host Game menu. */
function array<string> GetMapList()
{
	local array<string> MapList;
    local int i;

    for (i = 0; i < Maps.Length; i++)
    {        
        MapList.AddItem(Maps[i].MapName);
    }

    return MapList;    
}

/**
 * Returns the description of the map with the given full name (including
 * map prefix), if the map could be found, and an empty string otherwise.
 * 
 * @param MapName
 *      the map to look up the description of
 */
function string GetMapDescriptionByName(string MapName)
{
	local MapEntry CurrentMap;

	// find the specified map
	foreach Maps(CurrentMap)
	{
		if (CurrentMap.MapName ~= MapName)
		{
			// return its description
			return CurrentMap.MapDescription;
		}
	}

	return "";
}

DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWScreens.hw_frontend'

	WidgetBindings.Add((WidgetName="labelInfo",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelScreenTitle",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelVersion",WidgetClass=class'GFxObject'))

	bDisplayWithHudOff=true    
    TimingMode=TM_Real
	bPauseGameWhileActive=false
	bCaptureInput=true
	bIgnoreMouseInput=false
}
