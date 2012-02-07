// ============================================================================
// HWGFxDialog
// A modal dialog of Hostile Worlds. Shows a message and provides different
// button setups.
//
// Related Flash content: UDKGame/Flash/HWScreens/hw_dialog.fla
//
// Author:  Nick Pruehs
// Date:    2011/04/08
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxDialog extends HWGFxView;

// ----------------------------------------------------------------------------
// Widgets.

var GFxObject LabelDialogTitle;
var GFxClikWidget TextAreaMessage;
var GFxClikWidget BtnYes;
var GFxClikWidget BtnOK;
var GFxClikWidget BtnNo;

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string DialogTitleWarning;
var localized string DialogTitleError;
var localized string BtnTextYes;
var localized string BtnTextOK;
var localized string BtnTextNo;

// ----------------------------------------------------------------------------
// Button delegates.

delegate OnDialogYes();
delegate OnDialogOK();
delegate OnDialogNo();


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
        case ('labelDialogTitle'): 
            if (LabelDialogTitle == none)
            {
				LabelDialogTitle = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

		case ('textAreaMessage'):
			if (TextAreaMessage == none)
			{
				TextAreaMessage = GFxClikWidget(Widget);
				return true;
			}
			break;

		case ('btnYes'):
			if (BtnYes == none)
			{
				BtnYes = InitButton(Widget, WidgetName, BtnTextYes, OnButtonPressYes, OnRollOut);
				return true;
			}
            break;

		case ('btnOK'):
			if (BtnOK == none)
			{
				BtnOK = InitButton(Widget, WidgetName, BtnTextOK, OnButtonPressOK, OnRollOut);
				return true;
			}
            break;

		case ('btnNo'):
			if (BtnNo == none)
			{
				BtnNo = InitButton(Widget, WidgetName, BtnTextNo, OnButtonPressNo, OnRollOut);
				return true;
			}
            break;

        default:
            break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

/**
 * Initializes this dialog as question dialog with the specified title. Shows
 * the passed question and 'Yes' and 'No' buttons, setting up their event
 * listeners to call the passed function delegates.
 * 
 * @param DialogTitle
 *      the new title of this dialog
 * @param DialogQuestion
 *      the question to show
 * @param inOnDialogYes
 *     the function to call when the user hits 'Yes'
 * @param inOnDialogNo
 *      the function to call when the user hits 'No'
 */
function InitDialogQuestion(coerce string DialogTitle, coerce string DialogQuestion, delegate<OnDialogYes> inOnDialogYes, optional delegate<OnDialogNo> inOnDialogNo)
{
	LabelDialogTitle.SetText(DialogTitle);
	TextAreaMessage.SetText(DialogQuestion);

	OnDialogYes = inOnDialogYes;
	OnDialogNo = inOnDialogNo;

	BtnYes.SetBool("visible", true);
	BtnOK.SetBool("visible", false);
	BtnNo.SetBool("visible", true);
}

/**
 * Initializes this dialog as warning dialog. Shows the passed warning and
 * 'Yes' and 'No' buttons, setting up their event listeners to call the passed
 * function delegates.
 * 
 * @param DialogWarning
 *      the warning to show
 * @param inOnDialogYes
 *     the function to call when the user hits 'Yes'
 * @param inOnDialogNo
 *      the function to call when the user hits 'No'
 */
function InitDialogWarning(coerce string DialogWarning, delegate<OnDialogYes> inOnDialogYes, optional delegate<OnDialogNo> inOnDialogNo)
{
	InitDialogQuestion(DialogTitleWarning, DialogWarning, inOnDialogYes, inOnDialogNo);
}

/**
 * Initializes this dialog as info dialog with the specified title. Shows the
 * passed message and an 'OK' button, setting up its event listener to call the
 * passed function delegate.
 * 
 * @param DialogTitle
 *      the new title of this dialog
 * @param DialogMessage
 *      the message to show
 * @param inOnDialogOK
 *     the function to call when the user hits 'OK'
 */
function InitDialogInformation(coerce string DialogTitle, coerce string DialogMessage, optional delegate<OnDialogYes> inOnDialogOK)
{
	LabelDialogTitle.SetText(DialogTitle);
	TextAreaMessage.SetText(DialogMessage);
	OnDialogOK = inOnDialogOK;

	BtnYes.SetBool("visible", false);
	BtnOK.SetBool("visible", true);
	BtnNo.SetBool("visible", false);
}

/**
 * Initializes this dialog as error dialog. Shows the passed error message and
 * an 'OK' button, setting up its event listener to call the passed function
 * delegate.
 * 
 * @param DialogErrorMessage
 *      the error message to show
 * @param inOnDialogOK
 *      the function to call when the user hits 'OK'
 */
function InitDialogError(coerce string DialogErrorMessage, optional delegate<OnDialogYes> inOnDialogOK)
{
	InitDialogInformation(DialogTitleError, DialogErrorMessage, inOnDialogOK);
}

function ShowView()
{
	super.ShowView();

	SetViewScaleMode(SM_NoScale);
	SetAlignment(Align_Center);
}

// ----------------------------------------------------------------------------
// Button OnPress events.

function OnButtonPressYes(GFxClikWidget.EventData ev)
{
	OnDialogYes();

	if (FrontEnd != none)
	{
		FrontEnd.HideDialog();
	}	
}

function OnButtonPressOK(GFxClikWidget.EventData ev)
{
	OnDialogOK();

	if (FrontEnd != none)
	{
		FrontEnd.HideDialog();
	}	
}

function OnButtonPressNo(GFxClikWidget.EventData ev)
{
	OnDialogNo();

	if (FrontEnd != none)
	{
		FrontEnd.HideDialog();
	}	
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWScreens.hw_dialog'

	bPauseGameWhileActive=false
	bCaptureInput=false

	WidgetBindings.Add((WidgetName="labelDialogTitle",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="textAreaMessage",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnYes",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnOK",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnNo",WidgetClass=class'GFxClikWidget'))
}
