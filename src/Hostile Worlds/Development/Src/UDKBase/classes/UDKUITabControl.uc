/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * UDK extended version of the UITabControl
 */
class UDKUITabControl extends UITabControl
	native;

cpptext
{
protected:
	/**
	 * Set up the docking links between the tab control, buttons, and pages, based on the TabDockFace.
	 */
	virtual void SetupDockingRelationships();

public:
	/**
	 * Sets focus to the child widget that is next in the specified direction in the navigation network within this widget.
	 *
	 * This version doesn't let forced navigation start targetting mode.
	 *
	 * @param	Sender		Control that called NavigateFocus.  Possible values are:
	 *						-	if NULL is specified, it indicates that this is the first step in a focus change.  The widget will
	 *							attempt to set focus to its most eligible child widget.  If there are no eligible child widgets, this
	 *							widget will enter the focused state and start propagating the focus chain back up through the Owner chain
	 *							by calling SetFocus on its Owner widget.
	 *						-	if Sender is the widget's owner, it indicates that we are in the middle of a focus change.  Everything else
	 *							proceeds the same as if the value for Sender was NULL.
	 *						-	if Sender is a child of this widget, it indicates that focus has been successfully changed, and the focus is now being
	 *							propagated upwards.  This widget will now enter the focused state and continue propagating the focus chain upwards through
	 *							the owner chain.
	 * @param	Direction 		the direction to navigate focus.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player to set focus for.
	 * @param	bFocusChanged	TRUE if the focus was changed
	 *
	 * @return	TRUE if the navigation event was handled successfully.
	 */
	UBOOL NavigateFocus( UUIScreenObject* Sender, BYTE Direction, INT PlayerIndex=0, BYTE* bFocusChanged=NULL );
};

var()		name	DefaultTabWidgetTag;

var(Style)	name	CalloutLabelStyleName;

/** these labels will contain button callouts for activating the PrevPage / NextPage input aliases, on consoles */
var	transient	UILabel		PrevPageCalloutLabel;
var	transient	UILabel		NextPageCalloutLabel;

/**
 * Hide all the pages.  This allows us to not care what page was left on in the editor
 */
event PostInitialize()
{
	local int i;

	// Hide all of the pages

	for (i=0; i < Pages.Length; i++)
	{
		Pages[i].SetVisibility(false);
	}

	// Disable page previews on PS3/360
	if(IsConsole())
	{
		bAllowPagePreviews=FALSE;
	}

	Super.PostInitialize();
}

/**
 * Attempt to activate the default tab
 */
function bool ActivateBestTab( int PlayerIndex, optional bool bFocusPage=true, optional int StartIndex=0 )
{
	if ( DefaultTabWidgetTag != '' && ActivateTabByTag( DefaultTabWidgetTag ) )
	{
		return true;
	}
	
	// We either couldn't find it or it couldn't be activated.  Use the default code.
	return Super.ActivateBestTab( PlayerIndex, bFocusPage, StartIndex);

}


function int FindPageIndexByTag(name TabTag)
{
	local int i;
	for (i=0; i<Pages.Length;i++)
	{
		if ( Pages[i].WidgetTag == TabTag )
		{
        	return i;
        }
    }
    return INDEX_None;
}

// HACK FOR GETTING SCOREBOARD ACTIVE
function ForceTabPageReady(name TabTag)
{
	local int TIndex;

	TIndex = FindPageIndexByTag(TabTag);
	Pages[TIndex].SetVisibility(true); 
	Pages[TIndex].PlayerInputMask = 15;
}

/**
 * Activate a page by it's widget tag
 */
function bool ActivateTabByTag(name TabTag, optional int PlayerIndex, optional bool bFocusPage=true)
{
	local int TIndex;

	TIndex = FindPageIndexByTag(TabTag);
	if ( TIndex != INDEX_None )
	{
		if ( ActivatePage(Pages[TIndex], PlayerIndex, bFocusPage) )
		{
			return true;
		}
	}
	return false;
}

/**
 * Removes a page by it's widget tag
 */

function RemoveTabByTag(name TabTag, optional int PlayerIndex)
{
	local int TIndex;
	TIndex = FindPageIndexByTag(TabTag);
	if ( TIndex != INDEX_None )
	{
		RemovePage(Pages[TIndex],PlayerIndex);
	}
}

function bool ProcessInputKey( const out InputEventParameters EventParms )
{
	//@TODO: This is currently a hack, need to figure out what we want to support in UT and what we dont.
	return false;
}

defaultproperties
{
	TabButtonSize=(Value=0.033566,ScaleType=UIEXTENTEVAL_PercentOwner,Orientation=UIORIENT_Vertical)
	CalloutLabelStyleName=CycleTabs
}
