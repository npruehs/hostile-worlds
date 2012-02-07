// ============================================================================
// HWGFxHUD_ChatLog
// The HUD window showing all chat messages received by the local player.
//
// Related Flash content: UDKGame/Flash/HWHud/hwhud_chatlog.fla
//
// Author:  Nick Pruehs
// Date:    2011/05/17
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxHUD_ChatLog extends HWGFxHUDView;

// ----------------------------------------------------------------------------
// Widgets.

var GFxObject LabelTitle;
var GFxClikWidget BtnClose;

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string LabelTextTitle;
var localized string BtnTextClose;


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
		case ('labelTitle'):
			if (LabelTitle == none)
			{
				LabelTitle = Widget;
				LabelTitle.SetText(LabelTextTitle);
				return true;
			}
            break;

		case ('btnClose'):
			if (BtnClose == none)
			{
				BtnClose = GFxClikWidget(Widget);
				BtnClose.SetString("label", BtnTextClose);

				BtnClose.AddEventListener('CLIK_press', OnButtonPressClose);
				return true;
			}
            break;

        default:
            break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

/**
 * Adds the passed text sent by the player with the specified name to this
 * chat log window.
 * 
 * @param SendingPlayerName
 *      the name of the player who sent the message
 * @param Text
 *      the text of the message sent
 */
function Update(string SendingPlayerName, string Text)
{
	ASShowChatMessage(SendingPlayerName, Text);
}

/**
 * Calls the appropriate ActionScript function to show the passed text sent
 * by the player with the specified name to this chat log window.
 * 
 * @param SendingPlayerName
 *      the name of the player who sent the message
 * @param Text
 *      the text of the message sent
 */
function ASShowChatMessage(string SendingPlayerName, string Text)
{
	ActionScriptVoid("showChatMessage");
}

// ----------------------------------------------------------------------------
// Button OnPress events.

function OnButtonPressClose(GFxClikWidget.EventData ev)
{
	Close(false);
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWHud.hwhud_chatlog'

	WidgetBindings.Add((WidgetName="labelTitle",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="btnClose",WidgetClass=class'GFxClikWidget'))
}