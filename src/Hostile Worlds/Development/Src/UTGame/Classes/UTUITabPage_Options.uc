/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Options tab page, autocreates a set of options widgets using the datasource provided.
 */

class UTUITabPage_Options extends UTTabPage
	placeable;

/** Option list present on this tab page. */
var transient UTUIOptionList			OptionList;
var transient UTUIDataStore_StringList	StringListDataStore;
var transient UILabel					DescriptionLabel;

/** Target editbox for the onscreen keyboard, if any. */
var transient UIEditBox KeyboardTargetEditBox;

/** Whether or not the keyboard being displayed is a password keyboard. */
var transient bool bIsPasswordKeyboard;

/** Whether or not this option page supports resetting settings to defaults. */
var transient bool bAllowResetToDefaults;

delegate OnAcceptOptions(UIScreenObject InObject, int PlayerIndex);

/** Called when one of our options changes. */
delegate OnOptionChanged(UIScreenObject InObject, name OptionName, int PlayerIndex);

/** Called when one of our options is focused */
delegate OnOptionFocused(UIScreenObject InObject, UIDataProvider OptionProvider);

/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	local UIInteraction UIController;
	local UITabControl OwnerTabControl;

	Super.PostInitialize();

	UIController = GetCurrentUIController();
	if ( UIController != None )
	{
		// Store a reference to the string list datastore.
		StringListDataStore = UTUIDataStore_StringList(StaticResolveDataStore('UTStringList',GetScene(),GetPlayerOwner()));
	}

	/** Store widget references. */
	DescriptionLabel = UILabel(FindChild('lblDescription', true));
	OptionList = UTUIOptionList(FindChild('lstOptions', true));
	OptionList.OnAcceptOptions = OnOptionList_AcceptOptions;
	OptionList.OnOptionChanged = OnOptionList_OptionChanged;
	OptionList.OnOptionFocused = OnOptionList_OptionFocused;

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.FrontEnd.TabCaption_GameSettings>");

	// Update label
	OwnerTabControl = GetOwnerTabControl();
	if((OwnerTabControl == None || OwnerTabControl.ActivePage == Self)
	&&	OptionList != None && OptionList.CurrentIndex >= 0 && OptionList.CurrentIndex<OptionList.GeneratedObjects.length)
	{
		OnOptionList_OptionFocused(OptionList.GeneratedObjects[OptionList.CurrentIndex].OptionObj, OptionList.GeneratedObjects[OptionList.CurrentIndex].OptionProvider);
	}
}

/** Callback allowing the tabpage to setup the button bar for the current scene. */
function SetupButtonBar(UTUIButtonBar ButtonBar)
{
	ConditionallyAppendKeyboardButton(ButtonBar);
	ConditionallyAppendDefaultsButton(ButtonBar);
}


/** Pass through the accept callback. */
function OnOptionList_AcceptOptions(UIScreenObject InObject, int PlayerIndex)
{
	OnAcceptOptions(InObject, PlayerIndex);
}

/** Pass through the option callback. */
function OnOptionList_OptionChanged(UIScreenObject InObject, name OptionName, int PlayerIndex)
{
	OnOptionChanged(InObject, OptionName, PlayerIndex);
}

/** Callback for when an option is focused, by default tries to set the description label for this tab page. */
function OnOptionList_OptionFocused(UIScreenObject InObject, UIDataProvider OptionProvider)
{
	local UTUIDataProvider_MenuOption MenuOptionProvider;

	MenuOptionProvider = UTUIDataProvider_MenuOption(OptionProvider);

	if(DescriptionLabel != None && MenuOptionProvider != None)
	{
		DescriptionLabel.SetDataStoreBinding(MenuOptionProvider.Description);
	}

	OnOptionFocused(InObject, OptionProvider);
}



/** Shows the on screen keyboard. */
function ShowKeyboard(UIEditBox InTargetEditBox, string Title, optional string Message, optional bool bPassword, optional bool bShouldValidate, optional string DefaultText="", optional int MaxLength)
{
	local OnlinePlayerInterface PlayerInt;
	local UTUIScene UTScene;

	UTScene = UTUIScene(GetScene());

	if(UTScene != None)
	{
		KeyboardTargetEditBox = InTargetEditBox;

		bIsPasswordKeyboard=bPassword;
		PlayerInt =UTScene.GetPlayerInterface();
		PlayerInt.AddKeyboardInputDoneDelegate(OnKeyboardInputComplete);
		UTScene.GetUTInteraction().BlockUIInput(true);	// block input
		if(PlayerInt.ShowKeyboardUI(UTScene.GetPlayerIndex(), Title, Message, bPassword, bShouldValidate, DefaultText, MaxLength)==false)
		{
			OnKeyboardInputComplete(false);
		}
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
	local UTUIScene UTScene;

	UTScene = UTUIScene(GetScene());

	if(UTScene != None)
	{
		UTScene.GetUTInteraction().BlockUIInput(false);	// Unblock input
		PlayerInt = UTScene.GetPlayerInterface();

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
						KeyboardResults=UTScene.TrimWhitespace(KeyboardResults);
					}

					KeyboardTargetEditBox.SetValue(KeyboardResults);
				}
			}
		}
	}
}

/** Appends a keyboard button to the buttonbar if we are on PS3 and a editbox option is selected. */
function ConditionallyAppendKeyboardButton(UTUIButtonBar ButtonBar)
{
	local UTUIDataProvider_MenuOption OptionInfo;
	local UTUIScene UTScene;

	UTScene = UTUIScene(GetScene());

	if(UTScene != None)
	{
		if(IsConsole(CONSOLE_PS3) && OptionList != None && OptionList.CurrentIndex >= 0 && OptionList.GeneratedObjects.length > OptionList.CurrentIndex)
		{
			OptionInfo = UTUIDataProvider_MenuOption(OptionList.GeneratedObjects[OptionList.CurrentIndex].OptionProvider);

			if(OptionInfo.OptionType==UTOT_EditBox)
			{
				ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Keyboard>", OnButtonBar_ShowKeyboard);
			}
		}
	}
}

/** Shows the onscreen keyboard using the currently selected option as a target. */
function OnShowKeyboard()
{
	local UTUIDataProvider_MenuOption OptionInfo;
	local UIEditBox EditboxObject;

	OptionInfo = UTUIDataProvider_MenuOption(OptionList.GeneratedObjects[OptionList.CurrentIndex].OptionProvider);

	if(OptionInfo.OptionType==UTOT_EditBox)
	{
		EditboxObject = UIEditBox(OptionList.GeneratedObjects[OptionList.CurrentIndex].OptionObj);
		ShowKeyboard(EditboxObject, OptionInfo.FriendlyName, OptionInfo.FriendlyName, false, false, EditboxObject.GetValue(), EditboxObject.MaxCharacters);
	}
}

/** Buttonbar callback for showing the keyboard. */
function bool OnButtonBar_ShowKeyboard(UIScreenObject InButton, int InPlayerIndex)
{
	OnShowKeyboard();

	return true;
}

/** Buttonbar callback for resetting to defaults. */
function bool OnButtonBar_ResetToDefaults(UIScreenObject InButton, int InPlayerIndex)
{
	OnResetToDefaults();

	return true;
}


/** Condtionally appends reset to defaults button if the tab page supports it. */
function ConditionallyAppendDefaultsButton(UTUIButtonBar ButtonBar)
{
	if(bAllowResetToDefaults)
	{
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ResetToDefaults>", OnButtonBar_ResetToDefaults);
	}
}

/** Reset to defaults callback, resets all of the profile options in this widget to their default values. */
function OnResetToDefaults()
{
	local UDKUIScene_MessageBox MessageBoxReference;
	local array<string> MessageBoxOptions;

	MessageBoxReference = UTUIScene(GetScene()).GetMessageBoxScene();

	if(MessageBoxReference != none)
	{
		MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.ResetToDefaultAccept>");
		MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.Cancel>");

		MessageBoxReference.SetPotentialOptions(MessageBoxOptions);
		MessageBoxReference.Display("<Strings:UTGameUI.MessageBox.ResetToDefaults_Message>", "<Strings:UTGameUI.MessageBox.ResetToDefaults_Title>", OnResetToDefaults_Confirm, 1);
	}
}

/**
 * Callback for the reset to defaults confirmation dialog box.
 *
 * @param SelectionIdx	Selected item
 * @param PlayerIndex	Index of player that performed the action.
 */
function OnResetToDefaults_Confirm(UDKUIScene_MessageBox MessageBox, int SelectionIdx, int PlayerIndex)
{
	local int OptionIdx;
	local int DataPosition;
	local string ProfileOptionName;
	local UTUIDataProvider_MenuOption MenuProvider;
	local UTProfileSettings Profile;
	local UTUIScene UTScene;
	local int ProfileId;

	if(SelectionIdx==0)
	{
		UTScene = UTUIScene(GetScene());
		if(UTScene != None)
		{
			Profile = UTProfileSettings(UTScene.GetPlayerInterface().GetProfileSettings(GetPlayerOwner().ControllerId));

			if(Profile != None)
			{
				for(OptionIdx=0; OptionIdx<OptionList.GeneratedObjects.length; OptionIdx++)
				{
					MenuProvider = UTUIDataProvider_MenuOption(OptionList.GeneratedObjects[OptionIdx].OptionProvider);

					if(MenuProvider != None)
					{
						DataPosition = InStr(MenuProvider.DataStoreMarkup, "<OnlinePlayerData:ProfileData.");
						if(DataPosition != INDEX_NONE)
						{
							DataPosition += Len("<OnlinePlayerData:ProfileData.");
							ProfileOptionName=Mid(MenuProvider.DataStoreMarkup, DataPosition, Len(MenuProvider.DataStoreMarkup)-DataPosition-1);
							if(Profile.GetProfileSettingId(name(ProfileOptionName), ProfileId))
							{
								Profile.ResetToDefault(ProfileId);
								UIDataStoreSubscriber(OptionList.GeneratedObjects[OptionIdx].OptionObj).RefreshSubscriberValue();
							}
						}
					}
				}
			}

			UTScene.ConsoleCommand("RetrieveSettingsFromProfile");
		}
	}
}
