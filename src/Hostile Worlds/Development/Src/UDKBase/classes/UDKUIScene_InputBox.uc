/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Generic Message Box Scene for UDK
 */
class UDKUIScene_InputBox extends UDKUIScene_MessageBox
	native;

cpptext
{
	/**
	 * Called once per frame to update the scene's state.
	 *
	 * @param	DeltaTime	the time since the last Tick call
	 */
	virtual void Tick( FLOAT DeltaTime );
}


/** Reference to the editbox for the inputbox. */
var transient UIEditbox InputEditbox;

/** Whether or not this is a password input box. */
var transient bool bIsPasswordKeyboard;

/** Sets delegates for the scene. */
event PostInitialize()
{
	Super.PostInitialize();

	InputEditbox = UIEditbox(FindChild('txtValue', true));
	InputEditbox.SetDataStoreBinding("");
	InputEditbox.SetValue("");
	InputEditbox.OnSubmitText=OnSubmitText;
}

/**
 * Called when the user presses enter (or any other action bound to UIKey_SubmitText) while this editbox has focus.
 *
 * @param	Sender	the editbox that is submitting text
 * @param	PlayerIndex		the index of the player that generated the call to SetValue; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 *
 * @return	if TRUE, the editbox will clear the existing value of its textbox.
 */
function bool OnSubmitText( UIEditBox Sender, int PlayerIndex )
{
	OptionSelected(0, PlayerIndex);
	return false;
}

/** @return string	Returns the value of the input box. */
function string GetValue()
{
	return InputEditbox.GetValue();
}

/**
 * Sets the flag indicating whether this input box is for a password.
 */
function SetPasswordMode( bool bIsPasswordInput )
{
	bIsPasswordKeyboard = bIsPasswordInput;
	InputEditbox.bPasswordMode = bIsPasswordInput;
}


/**
 * Displays a message box that has an accept and cancel button.
 *
 * @param Message				Message for the message box.  Should be datastore markup.
 * @param Title					Title for the message box.  Should be datastore markup.
 * @param InSelectionDelegate	Delegate to call when the user dismisses the message box.
 */
function DisplayAcceptCancelBox(string Message, optional string Title="", optional delegate<OnSelection> InSelectionDelegate)
{
	PotentialOptions.length = 2;
	PotentialOptions[0]="<strings:UDKGameUI.Generic.OK>";
	PotentialOptions[1]=CANCEL_BUTTON_MARKUP_STRING;


	PotentialOptionKeyMappings.length = 2;
	PotentialOptionKeyMappings[0].Keys.length=1;
	PotentialOptionKeyMappings[0].Keys[0]='XboxTypeS_A';
	PotentialOptionKeyMappings[1].Keys.length=2;
	PotentialOptionKeyMappings[1].Keys[0]='XboxTypeS_B';
	PotentialOptionKeyMappings[1].Keys[1]='Escape';

	if(IsConsole())
	{
		PotentialOptions.length = 3;
		PotentialOptions[2]="<strings:UDKGameUI.ButtonCallouts.Keyboard>";
		PotentialOptionKeyMappings.length = 3;
		PotentialOptionKeyMappings[2].Keys.length=1;
		PotentialOptionKeyMappings[2].Keys[0]='XboxTypeS_X';
	}

	Display(Message, Title, InSelectionDelegate);

	InputEditbox.SetFocus(none);
}


/**
 * Called when a user has chosen one of the possible options available to them.
 * Begins hiding the dialog and calls the On
 *
 * @param OptionIdx		Index of the selection option.
 * @param PlayerIndex	Index of the player that selected the option.
 */
function OptionSelected(int OptionIdx, int PlayerIndex)
{
	if(OptionIdx==2)	// Option 2 is the keyboard option.
	{
		ShowKeyboard();
	}
	else
	{
		Super.OptionSelected(OptionIdx, PlayerIndex);
	}
}

/** Shows the on screen keyboard. */
function ShowKeyboard()
{
	local OnlinePlayerInterface PlayerInt;

	PlayerInt = GetPlayerInterface();
	PlayerInt.AddKeyboardInputDoneDelegate(OnKeyboardInputComplete);

	//@hack: on ps3, we use the description as the title for the ps3's keyboard ui, but the description is a little too long to fit so we'll use the
	// title in this case.
	if ( IsConsole(CONSOLE_PS3) && bIsPasswordKeyboard )
	{
		PlayerInt.ShowKeyboardUI(GetPlayerIndex(), "", TitleLabel.GetValue(), InputEditbox.bPasswordMode, false,
			InputEditbox.GetValue(), InputEditbox.MaxCharacters);
	}
	else
	{
		PlayerInt.ShowKeyboardUI(GetPlayerIndex(), TitleLabel.GetValue(), MessageLabel.GetValue(), InputEditbox.bPasswordMode, false,
			InputEditbox.GetValue(), InputEditbox.MaxCharacters);
	}
}

/**
 * Delegate used when the keyboard input request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnKeyboardInputComplete(bool bWasSuccessful)
{
	local OnlinePlayerInterface PlayerInt;
	local byte bWasCancelled;
	local string KeyboardResults;

	PlayerInt = GetPlayerInterface();

	if(PlayerInt != None)
	{
		PlayerInt.ClearKeyboardInputDoneDelegate(OnKeyboardInputComplete);

		if(bWasSuccessful)
		{
			KeyboardResults = PlayerInt.GetKeyboardInputResults(bWasCancelled);

			if(bool(bWasCancelled)==false)
			{
				if(!bIsPasswordKeyboard)
				{
					KeyboardResults=TrimWhitespace(KeyboardResults);
				}

				InputEditbox.SetValue(KeyboardResults);
			}
		}
	}
}

