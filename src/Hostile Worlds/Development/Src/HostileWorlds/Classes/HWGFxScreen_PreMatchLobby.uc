// ============================================================================
// HWGFxScreen_PreMatchLobby
// The Pre-Match Lobby screen of Hostile Worlds. Gives all players an overview
// of the players on the server, as well as information on the map to be
// played, and the possibility of chatting with each other. The host may kick
// any player and start the match. Note that this screen is not managed by the
// frontend.
//
// Related Flash content: UDKGame/Flash/HWScreens/hw_prematchlobby.fla
//
// Author:  Nick Pruehs
// Date:    2011/04/12
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxScreen_PreMatchLobby extends HWGFxView;

// ----------------------------------------------------------------------------
// Widgets.

var GFxObject LabelTeam1;
var GFxObject LabelTeam2;
var GFxObject LabelTeam1Players[4];
var GFxObject LabelTeam2Players[4];
var GFxObject LabelMapName;
var GFxObject LabelSuggestedPlayers;
var GFxObject LabelMapSize;
var GFxObject LabelScoreLimit;
var GFxObject LabelTimeLimit;
var GFxObject LabelSuggestedPlayersValue;
var GFxObject LabelMapSizeValue;
var GFxObject LabelScoreLimitValue;
var GFxObject LabelTimeLimitValue;

var GFxClikWidget BtnKickTeam1Players[4];
var GFxClikWidget BtnKickTeam2Players[4];
var GFxClikWidget TextAreaLobbyChat;
var GFxClikWidget InputLobbyChat;
var GFxClikWidget TextAreaMapDescription;
var GFxClikWidget BtnChangeTeam;
var GFxClikWidget BtnStartMatch;
var GFxClikWidget BtnBackToMainMenu;

var HWGFxDialog DialogPlayerKicked;
var HWGFxDialog DialogServerShutDown;

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string LabelTextTeam1;
var localized string LabelTextTeam2;
var localized string LabelTextSuggestedPlayers;
var localized string LabelTextMapSize;
var localized string LabelTextScoreLimit;
var localized string LabelTextTimeLimit;
var localized string LabelTextTimeLimitMinutes;
var localized string BtnTextKick;
var localized string BtnTextChangeTeam;
var localized string BtnTextStartMatch;
var localized string BtnTextBackToMainMenu;
var localized string TextAreaLobbyChatPlayerJoined;
var localized string TextAreaLobbyChatPlayerLeft;

// ----------------------------------------------------------------------------
// Dialog texts.

var localized string DialogTitleServerShutDown;
var localized string DialogTitlePlayerKicked;
var localized string DialogMessageServerShutDown;
var localized string DialogMessagePlayerKicked;


function bool Start(optional bool StartPaused = false)
{
	local bool bLoadErrors;

	bLoadErrors = super.Start(StartPaused);

	if (IsHost())
	{
		// pause the game running in the background
		ConsoleCommand("pause");
	}
	
	return bLoadErrors;
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
        case ('labelTeam1'): 
            if (LabelTeam1 == none)
            {
				LabelTeam1 = InitLabel(Widget, WidgetName, LabelTextTeam1);
				return true;
            }
            break;

        case ('labelTeam2'): 
            if (LabelTeam2 == none)
            {
				LabelTeam2 = InitLabel(Widget, WidgetName, LabelTextTeam2);
				return true;
            }
            break;

        case ('labelTeam1Player1'): 
            if (LabelTeam1Players[0] == none)
            {
				LabelTeam1Players[0] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam1Player2'): 
            if (LabelTeam1Players[1] == none)
            {
				LabelTeam1Players[1] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam1Player3'): 
            if (LabelTeam1Players[2] == none)
            {
				LabelTeam1Players[2] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam1Player4'): 
            if (LabelTeam1Players[3] == none)
            {
				LabelTeam1Players[3] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

       case ('labelTeam2Player1'): 
            if (LabelTeam2Players[0] == none)
            {
				LabelTeam2Players[0] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam2Player2'): 
            if (LabelTeam2Players[1] == none)
            {
				LabelTeam2Players[1] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam2Player3'): 
            if (LabelTeam2Players[2] == none)
            {
				LabelTeam2Players[2] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam2Player4'): 
            if (LabelTeam2Players[3] == none)
            {
				LabelTeam2Players[3] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelMapName'): 
            if (LabelMapName == none)
            {
				LabelMapName = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelSuggestedPlayers'): 
            if (LabelSuggestedPlayers == none)
            {
				LabelSuggestedPlayers = InitLabel(Widget, WidgetName, LabelTextSuggestedPlayers);
				return true;
            }
            break;

        case ('labelMapSize'): 
            if (LabelMapSize == none)
            {
				LabelMapSize = InitLabel(Widget, WidgetName, LabelTextMapSize);
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

        case ('labelSuggestedPlayersValue'): 
            if (LabelSuggestedPlayersValue == none)
            {
				LabelSuggestedPlayersValue = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelMapSizeValue'): 
            if (LabelMapSizeValue == none)
            {
				LabelMapSizeValue = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelScoreLimitValue'): 
            if (LabelScoreLimitValue == none)
            {
				LabelScoreLimitValue = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTimeLimitValue'): 
            if (LabelTimeLimitValue == none)
            {
				LabelTimeLimitValue = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

		case ('btnKickTeam1Player1'):
			if (BtnKickTeam1Players[0] == none)
			{
				BtnKickTeam1Players[0] = InitButton(Widget, WidgetName, BtnTextKick, OnButtonPressKickTeam1Player1);
				return true;
			}
            break;

		case ('btnKickTeam1Player2'):
			if (BtnKickTeam1Players[1] == none)
			{
				BtnKickTeam1Players[1] = InitButton(Widget, WidgetName, BtnTextKick, OnButtonPressKickTeam1Player2);
				return true;
			}
            break;

		case ('btnKickTeam1Player3'):
			if (BtnKickTeam1Players[2] == none)
			{
				BtnKickTeam1Players[2] = InitButton(Widget, WidgetName, BtnTextKick, OnButtonPressKickTeam1Player3);
				return true;
			}
            break;

		case ('btnKickTeam1Player4'):
			if (BtnKickTeam1Players[3] == none)
			{
				BtnKickTeam1Players[3] = InitButton(Widget, WidgetName, BtnTextKick, OnButtonPressKickTeam1Player4);
				return true;
			}
            break;

		case ('btnKickTeam2Player1'):
			if (BtnKickTeam2Players[0] == none)
			{
				BtnKickTeam2Players[0] = InitButton(Widget, WidgetName, BtnTextKick, OnButtonPressKickTeam2Player1);
				return true;
			}
            break;

		case ('btnKickTeam2Player2'):
			if (BtnKickTeam2Players[1] == none)
			{
				BtnKickTeam2Players[1] = InitButton(Widget, WidgetName, BtnTextKick, OnButtonPressKickTeam2Player2);
				return true;
			}
            break;

		case ('btnKickTeam2Player3'):
			if (BtnKickTeam2Players[2] == none)
			{
				BtnKickTeam2Players[2] = InitButton(Widget, WidgetName, BtnTextKick, OnButtonPressKickTeam2Player3);
				return true;
			}
            break;

		case ('btnKickTeam2Player4'):
			if (BtnKickTeam2Players[3] == none)
			{
				BtnKickTeam2Players[3] = InitButton(Widget, WidgetName, BtnTextKick, OnButtonPressKickTeam2Player4);
				return true;
			}
            break;

		case ('textAreaLobbyChat'):
			if (TextAreaLobbyChat == none)
			{
				TextAreaLobbyChat = GFxClikWidget(Widget);
				return true;
			}
			break;

		case ('inputLobbyChat'):
			if (InputLobbyChat == none)
			{
				InputLobbyChat = InitInput(Widget, WidgetName, "");
				return true;
			}
			break;

		case ('textAreaMapDescription'):
			if (TextAreaMapDescription == none)
			{
				TextAreaMapDescription = GFxClikWidget(Widget);
				return true;
			}
			break;

		case ('btnChangeTeam'):
			if (BtnChangeTeam == none)
			{
				BtnChangeTeam = InitButton(Widget, WidgetName, BtnTextChangeTeam, OnButtonPressChangeTeam);
				return true;
			}
            break;

		case ('btnStartMatch'):
			if (BtnStartMatch == none)
			{
				BtnStartMatch = InitButton(Widget, WidgetName, BtnTextStartMatch, OnButtonPressStartMatch);
				return true;
			}
            break;

		case ('btnBackToMainMenu'):
			if (BtnBackToMainMenu == none)
			{
				BtnBackToMainMenu = InitButton(Widget, WidgetName, BtnTextBackToMainMenu, OnButtonPressBackToMainMenu);
				return true;
			}
            break;

        default:
            break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

function ShowView()
{
	local int i;
	local HWPlayerController ThePlayer;
	local string MapName;
	local string SuggestedPlayers;

	super.ShowView();

	ThePlayer = HWPlayerController(GetPC());

	// hide kick buttons
	for (i = 0; i < 4; i++)
	{
		BtnKickTeam1Players[i].SetBool("visible", false);
	}

	for (i = 0; i < 4; i++)
	{
		BtnKickTeam2Players[i].SetBool("visible", false);
	}

	// show map name
	MapName = ThePlayer.WorldInfo.GetMapName(true);
	LabelMapName.SetText(MapName);

	// show map image
	SetExternalTexture("MapImage", ThePlayer.Map.MinimapTexture);

	// show map description (hack - maybe there's a better way later)
	FrontEnd = new class'HWGFxFrontEnd';
	TextAreaMapDescription.SetText(FrontEnd.GetMapDescriptionByName(MapName));

	// show suggested players
	SuggestedPlayers = string(ThePlayer.Map.SuggestedPlayersPerTeam[0]);
	SuggestedPlayers $= "v";
	SuggestedPlayers $= string(ThePlayer.Map.SuggestedPlayersPerTeam[1]);

	LabelSuggestedPlayersValue.SetText(SuggestedPlayers);

	// show map size
	LabelMapSizeValue.SetText(ThePlayer.Map.GetHumanReadableMapSize());

	// hide start match button on clients
	if (!IsHost())
	{
		BtnStartMatch.SetBool("visible", false);
	}

	// setup ActionScript callback for hitting the ENTER key in the chat textfield
	SetupASDelegateBroadcastChatMessage(BroadcastChatMessage);
}

/** The signature of the function to call whenever the player hits the ENTER key in the chat textfield. */
delegate BroadcastChatMessageSignature();

/**
 * Sets up the ActionScript callback for hitting the ENTER key in the chat
 * textfield.
 * 
 * @param d
 *      the delegate to call when the ENTER key is hit
 */
function SetupASDelegateBroadcastChatMessage(delegate<BroadcastChatMessageSignature> d)
{
     local GFxObject RootObj;

     RootObj = GetVariableObject("_root");
     ActionScriptSetFunction(RootObj, "SubmitChatMessage");
}

/**
 * Shows the specified score and time limit.
 * 
 * @param ScoreLimit
 *      the score limit to show
 * @param TimeLimit
 *      the time limit to show
 */
function SetScoreAndTimeLimit(int ScoreLimit, int TimeLimit)
{
	LabelScoreLimitValue.SetText(ScoreLimit);
	LabelTimeLimitValue.SetText(TimeLimit@LabelTextTimeLimitMinutes);
}

/**
 * Notifies this lobby that a new player has joined. Shows the player name,
 * the appropriate buttons and dropdown menus, and a system message in the
 * chat textbox.
 * 
 * @param PlayerName
 *      the name of the joining player
 * @param TeamIndex
 *      the index of the team of the joining player
 * @param Slot
 *      the team slot of the joining player
 */
function PlayerJoined(string PlayerName, int TeamIndex, int Slot)
{
	if (TeamIndex == 0)
	{
		LabelTeam1Players[Slot].SetText(PlayerName);

		// show kick button only on server and not for host player
		if (IsHost() && LocalPlayer(HWGame(GetPC().WorldInfo.Game).Teams[TeamIndex].Players[Slot].Player) == none)
		{
			BtnKickTeam1Players[Slot].SetBool("visible", true);
		}
	}
	else
	{
		LabelTeam2Players[Slot].SetText(PlayerName);

		// show kick button only on server and not for host player
		if (IsHost() && LocalPlayer(HWGame(GetPC().WorldInfo.Game).Teams[TeamIndex].Players[Slot].Player) == none)
		{
			BtnKickTeam2Players[Slot].SetBool("visible", true);
		}
	}

	ASShowSystemMessage(PlayerName@TextAreaLobbyChatPlayerJoined);
}

/**
 * Notifies this lobby that a player has left. Hides the player name,
 * the appropriate buttons and dropdown menus, and shows a system message in
 * the chat textbox.
 * 
 * @param PlayerName
 *      the name of the leaving player
 * @param TeamIndex
 *      the index of the team of the leaving player
 * @param Slot
 *      the team slot of the leaving player
 */
function PlayerLeft(string PlayerName, int TeamIndex, int Slot)
{
	if (TeamIndex == 0)
	{
		LabelTeam1Players[Slot].SetText("");
		BtnKickTeam1Players[Slot].SetBool("visible", false);
	}
	else
	{
		LabelTeam2Players[Slot].SetText("");
		BtnKickTeam2Players[Slot].SetBool("visible", false);
	}

	ASShowSystemMessage(PlayerName@TextAreaLobbyChatPlayerLeft);
}

/**
 * Notifies this lobby that a player has changed its team. Moves the player
 * name and the appropriate buttons and dropdown menus to the new team.
 * 
 * @param PlayerName
 *      the name of the player that changed its team
 * @param OldTeamIndex
 *      the previous index of the team of the player
 * @param OldSlot
 *      the previous team slot of the player
 * @param NewTeamIndex
 *      the new index of the team of the player
 * @param NewSlot
 *      the new team slot of the player
 */
function PlayerChangedTeam(string PlayerName, int OldTeamIndex, int OldSlot,  int NewTeamIndex, int NewSlot)
{
	// remove player from old team
	if (OldTeamIndex == 0)
	{
		LabelTeam1Players[OldSlot].SetText("");
		BtnKickTeam1Players[OldSlot].SetBool("visible", false);
	}
	else
	{
		LabelTeam2Players[OldSlot].SetText("");
		BtnKickTeam2Players[OldSlot].SetBool("visible", false);
	}

	// add to new team
	if (NewTeamIndex == 0)
	{
		LabelTeam1Players[NewSlot].SetText(PlayerName);

		// show kick button only on server and not for host player
		if (IsHost() && LocalPlayer(HWGame(GetPC().WorldInfo.Game).Teams[NewTeamIndex].Players[NewSlot].Player) == none)
		{
			BtnKickTeam1Players[NewSlot].SetBool("visible", true);
		}
	}
	else
	{
		LabelTeam2Players[NewSlot].SetText(PlayerName);

		// show kick button only on server and not for host player
		if (IsHost() && LocalPlayer(HWGame(GetPC().WorldInfo.Game).Teams[NewTeamIndex].Players[NewSlot].Player) == none)
		{
			BtnKickTeam2Players[NewSlot].SetBool("visible", true);
		}
	}
}

/** ActionScript callback called whenever the user hits ENTER on the chatbtextfield. Clears it and broadcasts the entered message to all players. */
function BroadcastChatMessage()
{
	local string Message;

	Message = InputLobbyChat.GetText();
	InputLobbyChat.SetText("");

	HWPlayerController(GetPC()).ClientBroadcastChatMessage(Message);
}

/**
 * Notifies this lobby that the local player has received a chat message,
 * showing that message.
 * 
 * @param Sender
 *      the name of the sending player
 * @param Msg
 *      the chat message the local player has received
 */
function ChatMessageReceived(string Sender, string Msg)
{
	ASShowChatMessage(Sender, Msg);
}

/**
 * Kicks the player in the passed slot of the team with the specified index
 * if this is the server.
 * 
 * @param TeamIndex
 *      the index of the team the player to kick is in
 * @param Slot
 *      the index of the slot the player to kick is in
 */
function TryKickPlayer(int TeamIndex, int Slot)
{
	local HWGame Game;

	if (IsHost())
	{
		Game = HWGame(GetPC().WorldInfo.Game);
		Game.AccessControl.KickPlayer(Game.Teams[TeamIndex].Players[Slot], DialogMessagePlayerKicked);
	}
}

/** Notifies this lobby that the local player has been kicked. Disables all components and shows an information dialog. */
function PlayerKicked()
{
	SetStateOfSubComponents(false);

	DialogPlayerKicked = new class'HWGFxDialog';
	DialogPlayerKicked.ShowView();
	DialogPlayerKicked.InitDialogInformation(DialogTitlePlayerKicked, DialogMessagePlayerKicked, OnDialogOK);
}

/** Notifies this lobby that the server shut down. Disables all components and shows an information dialog. */
function ServerShutDown()
{
	SetStateOfSubComponents(false);

	DialogServerShutDown = new class'HWGFxDialog';
	DialogServerShutDown.ShowView();
	DialogServerShutDown.InitDialogInformation(DialogTitleServerShutDown, DialogMessageServerShutDown, OnDialogOK);
}

/**
 * Calls the appropriate ActionScript function to show a system message in the
 * chat textarea.
 * 
 * @param Msg
 *      the system message to show
 */
function ASShowSystemMessage(string Msg)
{
	ActionScriptVoid("showSystemMessage");
}

/**
 * Calls the appropriate ActionScript function to show a chat message in the
 * chat textarea.
 * 
 * @param Msg
 *      the chat message to show
 */
function ASShowChatMessage(string Sender, string Msg)
{
	ActionScriptVoid("showChatMessage");
}

/** Returns true if the local player is the game host, and false otherwise. */
function bool IsHost()
{
	// no GameInfo on client machines ;)
	return (GetPC().WorldInfo.Game != none);
}

function HideView()
{
	if (DialogPlayerKicked != none)
	{
		DialogPlayerKicked.Close(true);
	}

	if (DialogServerShutDown != none)
	{
		DialogServerShutDown.Close(true);
	}

	Close(true);

	`log("§§§ GUI: Closing pre-match lobby.");
}

// ----------------------------------------------------------------------------
// Button OnPress events.

function OnButtonPressKickTeam1Player1(GFxClikWidget.EventData ev)
{
	TryKickPlayer(0, 0);
}

function OnButtonPressKickTeam1Player2(GFxClikWidget.EventData ev)
{
	TryKickPlayer(0, 1);
}

function OnButtonPressKickTeam1Player3(GFxClikWidget.EventData ev)
{
	TryKickPlayer(0, 2);
}

function OnButtonPressKickTeam1Player4(GFxClikWidget.EventData ev)
{
	TryKickPlayer(0, 3);
}

function OnButtonPressKickTeam2Player1(GFxClikWidget.EventData ev)
{
	TryKickPlayer(1, 0);
}

function OnButtonPressKickTeam2Player2(GFxClikWidget.EventData ev)
{
	TryKickPlayer(1, 1);
}

function OnButtonPressKickTeam2Player3(GFxClikWidget.EventData ev)
{
	TryKickPlayer(1, 2);
}

function OnButtonPressKickTeam2Player4(GFxClikWidget.EventData ev)
{
	TryKickPlayer(1, 3);
}

function OnButtonPressChangeTeam(GFxClikWidget.EventData ev)
{
	HWPlayerController(GetPC()).ServerSwitchTeam();
}

function OnButtonPressStartMatch(GFxClikWidget.EventData ev)
{
	if (IsHost())
	{
		// unpause the game again
		ConsoleCommand("pause");
	}

	GetPC().WorldInfo.Game.StartMatch();
}

function OnButtonPressBackToMainMenu(GFxClikWidget.EventData ev)
{
	if (IsHost())
	{
		// notify all other players we're shutting down before they're kicked by the engine
		 HWGame(GetPC().WorldInfo.Game).NotifyServerShuttingDown();
	}

	HideView();

	ConsoleCommand("open "$class'HWGame'.const.FRONTEND_MAP_NAME);
}

// ----------------------------------------------------------------------------
// Dialog events.

function OnDialogOK()
{
	HideView();

	ConsoleCommand("open "$class'HWGame'.const.FRONTEND_MAP_NAME);
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWScreens.hw_prematchlobby'

	WidgetBindings.Add((WidgetName="labelTeam1",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam1Player1",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam1Player2",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam1Player3",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam1Player4",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2Player1",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2Player2",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2Player3",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2Player4",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelMapName",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelSuggestedPlayers",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelMapSize",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelScoreLimit",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTimeLimit",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelSuggestedPlayersValue",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelMapSizeValue",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelScoreLimitValue",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTimeLimitValue",WidgetClass=class'GFxObject'))

	WidgetBindings.Add((WidgetName="btnKickTeam1Player1",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnKickTeam1Player2",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnKickTeam1Player3",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnKickTeam1Player4",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnKickTeam2Player1",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnKickTeam2Player2",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnKickTeam2Player3",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnKickTeam2Player4",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="textAreaLobbyChat",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="inputLobbyChat",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="textAreaMapDescription",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnChangeTeam",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnStartMatch",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBackToMainMenu",WidgetClass=class'GFxClikWidget'))
}
