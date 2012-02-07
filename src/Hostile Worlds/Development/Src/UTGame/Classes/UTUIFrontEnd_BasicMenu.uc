/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Basic Menu Scene for UT3, contains a menu list and a description label.
 */
class UTUIFrontEnd_BasicMenu extends UTUIFrontEnd;

/** Reference to the menu list for this scene. */
var transient UDKUIMenuList	MenuList;

/** Reference to the description label for this scene. */
var transient UILabel		DescriptionLabel;

/** Whether or not to support a back button for this scene. */
var bool bSupportBackButton;

event PostInitialize()
{
	Super.PostInitialize();

	// Get Widget References
	DescriptionLabel = UILabel(FindChild('lblDescription', true));
	MenuList = UDKUIMenuList(FindChild('lstMenu', true));
	if(MenuList != none)
	{
		MenuList.OnSubmitSelection = OnMenu_SubmitSelection;
		MenuList.OnValueChanged = OnMenu_ValueChanged;
	}
}

/** Setup the scene's buttonbar. */
function SetupButtonBar()
{
	ButtonBar.Clear();

	if(bSupportBackButton)
	{
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);
	}

	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Select>", OnButtonBar_Select);
}

/**
 * Executes a action based on the currently selected menu item.
 */
function OnSelectItem(int PlayerIndex=0)
{
	// Must be implemented in subclass
}


/** Callback for when the user wants to back out of this screen. */
function OnBack()
{
	CloseScene(self);
}

/** Buttonbar Callbacks. */
function bool OnButtonBar_Select(UIScreenObject InButton, int InPlayerIndex)
{
	OnSelectItem();

	return true;
}

/** Buttonbar Callbacks. */
function bool OnButtonBar_Back(UIScreenObject InButton, int InPlayerIndex)
{
	OnBack();

	return true;
}

/**
 * Called when the user presses Enter (or any other action bound to UIKey_SubmitListSelection) while this list has focus.
 *
 * @param	Sender	the list that is submitting the selection
 */
function OnMenu_SubmitSelection( UIObject Sender, optional int PlayerIndex=0 )
{
	OnSelectItem(PlayerIndex);
}


/**
 * Called when the user changes the currently selected list item.
 */
function OnMenu_ValueChanged( UIObject Sender, optional int PlayerIndex=0 )
{
	local int SelectedItem;
	local string StringValue;

	SelectedItem = MenuList.GetCurrentItem();

	if(MenuList.GetCellFieldString(MenuList, 'Description', SelectedItem, StringValue))
	{
		DescriptionLabel.SetDatastoreBinding(StringValue);
	}
}


/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool HandleInputKey( const out InputEventParameters EventParms )
{
	local bool bResult;

	bResult=false;

	if(bSupportBackButton && EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')
		{
			OnBack();
			bResult=true;
		}
	}

	return bResult;
}

defaultproperties
{
	bSupportBackButton=true
}