// ============================================================================
// HWGameViewportClient
// Custom viewport for showing custom transition and progress messages.
//
// Author:  Nick Pruehs
// Date:    2011/04/10
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGameViewportClient extends GameViewportClient;

/** Font used for displaying the map name on the loading screen. */
var Font LoadingScreenMapNameFont;

/** Font used for displaying the hint on the loading screen. */
var Font LoadingScreenHintFont;

/** The message to show while loading the main menu. */
var localized string ReturningToMainMenu;


function DrawTransition(Canvas Canvas)
{
	local HWGame Game;
	local string MapName;
	local string HintMessage;

	if (Outer.TransitionType == TT_Loading)
	{
		// clear previous overlays
		class'Engine'.static.RemoveAllOverlays();

		// show map
		MapName = Outer.TransitionDescription;

		class'Engine'.static.AddOverlay(LoadingScreenMapNameFont, MapName, 0.2, 0.5, 2.0, 2.0, false);

		// show loading description or random hint
		if (MapName ~= class'HWGame'.const.FRONTEND_MAP_NAME)
		{
			class'Engine'.static.AddOverlayWrapped(LoadingScreenHintFont, ReturningToMainMenu, 0.25, 0.6, 1.0, 1.0, 0.65);
		}
		else
		{
			Game = HWGame(Outer.GetCurrentWorldInfo().Game);
			HintMessage = Game.GetRandomHint();

			class'Engine'.static.AddOverlayWrapped(LoadingScreenHintFont, HintMessage, 0.25, 0.6, 1.0, 1.0, 0.65);
		}
	}

	// change content of this method if we want to display transition related
	// messages like TT_Paused, TT_Connecting or TT_Precaching in a different way
}

function DisplayProgressMessage(Canvas Canvas)
{
	// change content of this method if we want to display network connection
	// related messages like PMT_DownloadProgress, PMT_ConnectionFailure or
	// PMT_SocketFailure in a different way
	super.DisplayProgressMessage(Canvas);
}

event SetProgressMessage(EProgressMessageType MessageType, string Message, optional string Title, optional bool bIgnoreFutureNetworkMessages)
{
	switch (MessageType)
	{
		case PMT_ConnectionFailure:
		case PMT_SocketFailure:
			HWPlayerController(GetPlayerOwner(0).Actor).NotifyConnectionError(Message);
			break;

		default:
			break;
	}
}

function NotifyConnectionError(optional string Message=Localize("Errors", "ConnectionFailed", "Engine"), optional string Title=Localize("Errors", "ConnectionFailed_Title", "Engine"))
{
	// change content of this method if we want to display network connection
	// related messages like PMT_DownloadProgress, PMT_ConnectionFailure or
	// PMT_SocketFailure in a different way
}


DefaultProperties
{
	// use UT fonts
	LoadingScreenMapNameFont=MultiFont'UI_Fonts_Final.Menus.Fonts_AmbexHeavyOblique'
	LoadingScreenHintFont=MultiFont'UI_Fonts_Final.HUD.MF_Medium'
}
