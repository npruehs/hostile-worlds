// ============================================================================
// HWGFxScreen_Credits
// The Credits screen of Hostile Worlds.
//
// Related Flash content: UDKGame/Flash/HWScreens/hw_credits.fla
//
// Author:  Nick Pruehs
// Date:    2011/08/25
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxScreen_Credits extends HWGFxScreen;

// ----------------------------------------------------------------------------
// Widgets.

var GFxClikWidget BtnBackToMainMenu;

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string BtnTextBackToMainMenu;

// ----------------------------------------------------------------------------
// Description texts.

var localized string DescriptionBackToMainMenu;


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
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

function OnButtonPressBackToMainMenu(GFxClikWidget.EventData ev)
{
	FrontEnd.SwitchToScreenMainMenu();
}

// ----------------------------------------------------------------------------
// OnRollOver events.

function OnButtonRollOverBackToMainMenu(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionBackToMainMenu);
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWScreens.hw_credits'

	WidgetBindings.Add((WidgetName="btnBackToMainMenu",WidgetClass=class'GFxClikWidget'))
}
