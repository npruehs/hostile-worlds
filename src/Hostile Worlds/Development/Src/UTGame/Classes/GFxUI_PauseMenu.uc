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
 * Pause menu implementation.
 * Related Flash content:   ut3_pausemenu.fla
 * 
 * 
 */
class GFxUI_PauseMenu extends UTGFxTweenableMoviePlayer;

var GFxObject RootMC, PauseMC, OverlayMC, Btn_Resume_Wrapper, Btn_Exit_Wrapper;
var GFxClikWidget Btn_ResumeMC, Btn_ExitMC;

// Localized strings to use as button labels
var localized string ResumeString, ExitString;

function bool Start(optional bool StartPaused = false)
{
    super.Start();
    Advance(0);

	RootMC = GetVariableObject("_root");
    PauseMC = RootMC.GetObject("pausemenu");    

	Btn_Resume_Wrapper = PauseMC.GetObject("resume");
	Btn_Exit_Wrapper = PauseMC.GetObject("exit");

    Btn_ResumeMC = GFxClikWidget(Btn_Resume_Wrapper.GetObject("btn", class'GFxClikWidget'));
    Btn_ExitMC = GFxClikWidget(Btn_Exit_Wrapper.GetObject("btn", class'GFxClikWidget'));

	Btn_ExitMC.SetString("label", ExitString);
	Btn_ResumeMC.SetString("label", ResumeString);

	Btn_ExitMC.AddEventListener('CLIK_press', OnPressExitButton);
	Btn_ResumeMC.AddEventListener('CLIK_press', OnPressResumeButton);

	AddCaptureKey('XboxTypeS_A');
	AddCaptureKey('XboxTypeS_Start');
	AddCaptureKey('Enter');

    return TRUE;
}

function OnPressResumeButton(GFxClikWidget.EventData ev)
{
    PlayCloseAnimation();
}

function OnPressExitButton(GFxClikWidget.EventData ev)
{
	UTPlayerController(GetPC()).QuitToMainMenu();	
}

function PlayOpenAnimation()
{
    PauseMC.GotoAndPlay("open");
}

function PlayCloseAnimation()
{
    PauseMC.GotoAndPlay("close");
}

function OnPlayAnimationComplete()
{
    //
}

function OnCloseAnimationComplete()
{
    UTGFxHudWrapper(GetPC().MyHUD).CompletePauseMenuClose();
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
    bEnableGammaCorrection=FALSE
	bPauseGameWhileActive=TRUE
	bCaptureInput=true
}
