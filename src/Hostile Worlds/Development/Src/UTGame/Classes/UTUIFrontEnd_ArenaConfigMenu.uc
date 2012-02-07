/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTUIFrontEnd_ArenaConfigMenu extends UTUIFrontEnd;

var transient UTUIComboBox WeaponCombo;

event SceneActivated(bool bInitialActivation)
{
	local string StartingValue, FieldValue;
	local array<string> Flags;
	local int NumItems, i;

	Super.SceneActivated(bInitialActivation);

	if (bInitialActivation)
	{
		WeaponCombo = UTUIComboBox(FindChild('cmbWeapon', true));
		StartingValue = class'UTMutator_Arena'.default.ArenaWeaponClassPath;
		WeaponCombo.ComboList.SetIndex(class'UDKUIMenuList'.static.FindCellFieldString(WeaponCombo.ComboList, 'ClassName', StartingValue));
	}
	// remove things we don't want in the list
	NumItems = WeaponCombo.ComboList.GetItemCount();
	for (i = 0; i < NumItems; i++)
	{
		// skip UTGameContent weapons in console builds as we can't load them dynamically
		if ( class'WorldInfo'.static.IsConsoleBuild() &&
			class'UDKUIMenuList'.static.GetCellFieldString(WeaponCombo.ComboList, 'ClassName', i, FieldValue) &&
			Left(FieldValue, 14) ~= "UTGameContent." )
		{
			WeaponCombo.ComboList.RemoveElement(i);
		}
		// skip weapons marked with "NOARENA"
		else if (class'UDKUIMenuList'.static.GetCellFieldString(WeaponCombo.ComboList, 'Flags', i, FieldValue))
		{
			ParseStringIntoArray(FieldValue, Flags, "|", true);
			if (Flags.Find("NOARENA") != INDEX_NONE)
			{
				WeaponCombo.ComboList.RemoveElement(i);
			}
		}
	}
}

/** Sets up the scene's button bar. */
function SetupButtonBar()
{
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);
}

/** Callback for when the user wants to back out of this screen. */
function OnBack()
{
	local string NewValue;

	if (class'UDKUIMenuList'.static.GetCellFieldString(WeaponCombo.ComboList, 'ClassName', WeaponCombo.ComboList.GetCurrentItem(), NewValue))
	{
		class'UTMutator_Arena'.default.ArenaWeaponClassPath = NewValue;
		class'UTMutator_Arena'.static.StaticSaveConfig();
	}

	CloseScene(self);
}

/** Buttonbar Callbacks. */
function bool OnButtonBar_Back(UIScreenObject InButton, int InPlayerIndex)
{
	OnBack();

	return true;
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

	if(EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')
		{
			OnBack();
			bResult=true;
		}
	}

	return bResult;
}

