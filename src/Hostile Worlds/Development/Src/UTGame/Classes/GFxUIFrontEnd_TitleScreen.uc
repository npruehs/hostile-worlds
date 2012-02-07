/**********************************************************************

Copyright   :   (c) 2006-2007 Scaleform Corp. All Rights Reserved.

Portions of the integration code is from Epic Games as identified by Perforce annotations.
Copyright (c) 2010 Epic Games, Inc. All rights reserved.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/

/**
 * Main menu implementation.
 * Related Flash content:   ut3_menu.fla
 * 
 * The 3D tweens and transformation take place largely with the ActionScript
 * for this file. Event listeners are added to the buttons within UnrealScript
 * removing unnecessary communication back and forth between AS and US.
 */

class GFxUIFrontEnd_TitleScreen extends GFxMoviePlayer;

var GFxObject TitleScreenMC;
var GFxObject MainMenuMC;
var GFxObject MenuButtonsMC, BlackMC;

var GFxClikWidget    MenuBtn1MC, MenuBtn2MC, MenuBtn3MC, MenuBtn4MC, MenuBtn5MC, MenuBtn6MC;

var string  InstantActionMap, CampaignMap;

Enum MenuButtonsType
{
	MENU_BTN_CAMPAIGN,
	MENU_BTN_INSTANTACTION,
	MENU_BTN_MULTIPLAYER,
	MENU_BTN_COMMUNITY,
	MENU_BTN_SETTINGS,
	MENU_BTN_EXIT,

	MENU_BTN_LOGOUT,
	MENU_BTN_SELECT,
};

var byte Selection;

/*
 * Start / configuration for Title Screen.  Called from Kismet.
 */
function bool Start(optional bool StartPaused = false)
{
    super.Start();
    Advance(0);

	// Cache references to important MovieClips for reuse.
    TitleScreenMC = GetVariableObject("_root");
    MainMenuMC = TitleScreenMC.GetObject("mainMenu");
    BlackMC = TitleScreenMC.GetObject("black");
    MenuButtonsMC = MainMenuMC.GetObject("menu");

	// Configure buttons with their index and EventListeners.
    MenuBtn1MC = GFxClikWidget(MenuButtonsMC.GetObject("menubtn1").GetObject("menuBtn1", class'GFxClikWidget'));
	MenuBtn1MC.SetFloat("data", MenuButtonsType.MENU_BTN_CAMPAIGN);

    MenuBtn2MC = GFxClikWidget(MenuButtonsMC.GetObject("menubtn2").GetObject("menuBtn2", class'GFxClikWidget'));
	MenuBtn2MC.SetFloat("data", MenuButtonsType.MENU_BTN_INSTANTACTION);

    MenuBtn3MC = GFxClikWidget(MenuButtonsMC.GetObject("menubtn3").GetObject("menuBtn3", class'GFxClikWidget'));
	MenuBtn3MC.SetFloat("data", MenuButtonsType.MENU_BTN_MULTIPLAYER);

    MenuBtn4MC = GFxClikWidget(MenuButtonsMC.GetObject("menubtn4").GetObject("menuBtn4", class'GFxClikWidget'));
	MenuBtn4MC.SetFloat("data", MenuButtonsType.MENU_BTN_COMMUNITY);

    MenuBtn5MC = GFxClikWidget(MenuButtonsMC.GetObject("menubtn5").GetObject("menuBtn5", class'GFxClikWidget'));
	MenuBtn5MC.SetFloat("data", MenuButtonsType.MENU_BTN_SETTINGS);

    MenuBtn6MC = GFxClikWidget(MenuButtonsMC.GetObject("menubtn6").GetObject("menuBtn6", class'GFxClikWidget'));
	MenuBtn6MC.SetFloat("data", MenuButtonsType.MENU_BTN_EXIT);

    MenuBtn1MC.AddEventListener('CLIK_press', OnMenuButtonPress);
    MenuBtn2MC.AddEventListener('CLIK_press', OnMenuButtonPress);
    MenuBtn6MC.AddEventListener('CLIK_press', OnMenuButtonPress);

    return TRUE;
}

/** Can be overridden to filter input to this movie.  Return TRUE to trap the input, FALSE to let it pass through to Flash */
event bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	//if ( ButtonName == 'XboxTypeS_A' )
	//{
	//	`log("woot");
	//	//PlaySound( SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_BodyFall_Cue' );
	//	return true;
	//}
	//else
	//{
	//	`log(ButtonName);
	//}

	return false;
}


/*
 * Handler for Menu Button "press" events.  Stores the selection and
 * starts the CloseAnimation. OnCloseAnimationComplete will be triggered
 * from the Flash file when the animations has finished.
 */
function OnMenuButtonPress(GFxClikWidget.EventData ev)
{
    Selection = byte(ev.target.GetFloat("data"));
	PlayCloseAnimation();	
}

function PlayCloseAnimation()
{
	// "Open" is a mislabeled close animation.
    BlackMC.GotoAndPlay("open");
}

function OnCloseAnimationComplete()
{
    switch (Selection)
    {
        case(MENU_BTN_CAMPAIGN):
            UT_ConsoleCommand("open "$CampaignMap$"?game=UTGameContent.UTVehicleCTFGame_Content", true);
            break;
        case(MENU_BTN_INSTANTACTION):
            UT_ConsoleCommand("open "$InstantActionMap $ "?game=UTGame.UTTeamGame", true);
            break;
        case(MENU_BTN_EXIT):
            UT_ConsoleCommand("quit", true);
            break;
        default:
            break;
    }
}

/*
    Launch a console command using the PlayerOwner.
    Will fail if PlayerOwner is undefined.
*/
final function UT_ConsoleCommand(string Cmd, optional bool bWriteToLog)
{
    GetPC().Player.Actor.ConsoleCommand(Cmd, bWriteToLog);
}

defaultproperties
{
	 CampaignMap   = "VCTF-Sandstorm.udk"
     InstantActionMap        = "DM-Deck.udk"

     bDisplayWithHudOff = TRUE
     bEnableGammaCorrection   = FALSE
}
