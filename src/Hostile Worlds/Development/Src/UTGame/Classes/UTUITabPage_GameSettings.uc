/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Tab page for a user's Game settings.
 */

class UTUITabPage_GameSettings extends UTUITabPage_Options
	placeable;

/** String reference to the mutator scene. */
var transient string MutatorScene;

/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	Super.PostInitialize();

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.FrontEnd.TabCaption_GameSettings>");

	// Anytime an option is changed, save its value immediately
	OptionList.OnOptionChanged=OnOptionChanged;
}

/** Callback for when an option has changed. */
function OnOptionChanged(UIScreenObject InObject, name OptionName, int PlayerIndex)
{
	local UTUIScene_MidGameMenu UTSceneOwner;
	local UIDataStorePublisher Publisher;
	local array<UIDataStore> OutDataStores;

	Publisher = UIDataStorePublisher(InObject);
	if ( Publisher != None )
	{
		Publisher.SaveSubscriberValue(OutDataStores);

		UTSceneOwner = UTUIScene_MidGameMenu(GetScene());
		if ( UTSceneOwner != None )
		{
			UTSceneOwner.bNeedsProfileSave = true;
		}
	}
}

/** Sets up the button bar for the parent scene. */
function SetupButtonBar(UTUIButtonBar ButtonBar)
{
	if(UTUIScene(GetScene()).GetWorldInfo().IsDemoBuild()==false)
	{
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.SelectMutators>", OnButtonBar_Mutators);
	}
}

/** Shows the mutator scene. */
function OnShowMutators()
{
	UTUIScene(GetScene()).OpenSceneByName(MutatorScene, false);
}

function bool OnButtonBar_Mutators(UIScreenObject InButton, int PlayerIndex)
{
	OnShowMutators();

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
		if(EventParms.InputKeyName=='XboxTypeS_X')		// Show mutator screen
		{
			if(UTUIScene(GetScene()).GetWorldInfo().IsDemoBuild()==false)
			{
				OnShowMutators();
			}

			bResult=true;
		}
	}

	return bResult;
}

defaultproperties
{
	MutatorScene="UI_Scenes_ChrisBLayout.Scenes.Mutators"
}
