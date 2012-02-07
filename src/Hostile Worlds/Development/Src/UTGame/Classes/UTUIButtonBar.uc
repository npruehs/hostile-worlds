/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Container class that holds multiple UTUIButtonBarButton instances.  This class autopositions itself and its buttons at the bottom of the screen.
 */
class UTUIButtonBar extends UDKUI_Widget
	placeable
	dependson(UIButton);

const UTUIBUTTONBAR_MAX_BUTTONS	= 6;
const UTUIBUTTONBAR_BUTTON_SPACING = -20;

/** Array of actual label buttons for the button bar. */
var instanced UTUIButtonBarButton		Buttons[UTUIBUTTONBAR_MAX_BUTTONS];

event PostInitialize()
{
	local int ButtonIdx;

	Super.PostInitialize();

	// Setup button properties.
	for(ButtonIdx=0; ButtonIdx<UTUIBUTTONBAR_MAX_BUTTONS; ButtonIdx++)
	{
		// Hide all buttons by default.
		Buttons[ButtonIdx].SetVisibility(false);
		Buttons[ButtonIdx].TabIndex = UTUIBUTTONBAR_MAX_BUTTONS - 1 - ButtonIdx;
		Buttons[ButtonIdx].DockTargets.bLockWidthWhenDocked = true;

		// Setup docking.
		if(ButtonIdx > 0)
		{
			Buttons[ButtonIdx].SetDockParameters(UIFACE_Right, Buttons[ButtonIdx-1], UIFACE_Left, UTUIBUTTONBAR_BUTTON_SPACING);
		}
		else
		{
			Buttons[ButtonIdx].SetDockParameters(UIFACE_Right, self, UIFACE_Right, 0);
		}

		Buttons[ButtonIdx].StringRenderComponent.EnableAutoSizing(UIORIENT_Horizontal, true);
	}
}

/**
 * Play an animation on this UIObject
 *
 * @Param AnimName			The Name of the Animation to play
 * @Param AnimSeq			Optional, A Sequence Template.  If that's set, we use it instead
 * @Param PlaybackRate  	Optional, How fast to play back the sequence
 * @Param InitialPosition	Optional, Where in the sequence should we start
 *
 */
event PlayUIAnimation(	name AnimName, optional UIAnimationSeq AnimSeqTemplate, optional EUIAnimationLoopMode OverrideLoopMode=UIANIMLOOP_MAX,
						optional float PlaybackRate=1.f, optional float InitialPosition=0.f, optional bool bSetAnimatingFlag=true )
{
	if ( AnimName == 'ButtonBarShow' )
	{
		StopUIAnimation('ButtonBarHide');
	}
	else if ( AnimName == 'ButtonBarHide' )
	{
		StopUIAnimation('ButtonBarShow');
	}

	Super.PlayUIAnimation(AnimName, AnimSeqTemplate, OverrideLoopMode, PlaybackRate, InitialPosition, bSetAnimatingFlag);
}

/**
 * Appends a button to the button bar.
 *
 * @param ButtonTextMarkup	Markup for the button's caption
 * @param ButtonDelegate	Delegate to call when the button is clicked on.
 */
function int AppendButton(string ButtonTextMarkup, delegate<UIObject.OnClicked> ButtonDelegate)
{
	local int ButtonIdx;

	for(ButtonIdx=0; ButtonIdx<UTUIBUTTONBAR_MAX_BUTTONS; ButtonIdx++)
	{
		if ( Buttons[ButtonIdx].IsHidden() )
		{
			SetButton(ButtonIdx, ButtonTextMarkup, ButtonDelegate);
			return ButtonIdx;
		}
	}
	return INDEX_None;
}

event UIButton GetButton(int Index)
{
	return Buttons[Index];
}

/** Sets information for one of the button bar buttons. */
function SetButton(int ButtonIndex, string ButtonTextMarkup, delegate<UIObject.OnClicked> ButtonDelegate)
{
	`assert(ButtonIndex >= 0 && ButtonIndex<UTUIBUTTONBAR_MAX_BUTTONS);

	Buttons[ButtonIndex].SetVisibility(true);
	Buttons[ButtonIndex].SetEnabled(true);
	Buttons[ButtonIndex].SetDatastoreBinding(ButtonTextMarkup);
	Buttons[ButtonIndex].OnClicked=ButtonDelegate;
}

function ClearButton(int ButtonIndex)
{
	`assert(ButtonIndex >= 0 && ButtonIndex<UTUIBUTTONBAR_MAX_BUTTONS);

	Buttons[ButtonIndex].SetVisibility(false);
	Buttons[ButtonIndex].SetDatastoreBinding("");
	Buttons[ButtonIndex].OnClicked=none;
}

/** Clears all set buttons. */
function Clear()
{
	local int ButtonIdx;

	for(ButtonIdx=0; ButtonIdx<UTUIBUTTONBAR_MAX_BUTTONS; ButtonIdx++)
	{
		// Hide all buttons by default.
		Buttons[ButtonIdx].SetVisibility(false);
		Buttons[ButtonIdx].SetDatastoreBinding("");
		Buttons[ButtonIdx].OnClicked=none;
	}
}

function SetSubFocus(int Index, UIObject NewFocus)
{
	Buttons[Index].SetFocus(NewFocus);
}


/**
 * Used to toggle a button on/off
 */
function ToggleButton(int ButtonIdx, bool bActive)
{
	`assert(ButtonIdx >= 0 && ButtonIdx<UTUIBUTTONBAR_MAX_BUTTONS);

	Buttons[ButtonIdx].SetVisibility(bActive);
}

defaultproperties
{
	bCanAcceptFocusOnConsole=false

	DefaultStates.Add(class'Engine.UIState_Focused')

	Position={( Value[UIFACE_Left]=0,
				ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
				Value[UIFACE_Top]=0.95,
				ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
				Value[UIFACE_Right]=1,
				ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,
				Value[UIFACE_Bottom]=0.05,
				ScaleType[UIFACE_Bottom]=EVALPOS_PercentageOwner)}

	// Button 0
	Begin Object Class=UTUIButtonBarButton Name=ButtonTemplate0
		TabIndex=0
		WidgetTag=butButtonBarButton0
		CaptionDataSource=(MarkupString="Button 0",RequiredFieldType=DATATYPE_Property)

		Position={( Value[UIFACE_Left]=0.9,
				ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
				Value[UIFACE_Top]=0,
				ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
				Value[UIFACE_Right]=0.1,
				ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,
				Value[UIFACE_Bottom]=0.70,
				ScaleType[UIFACE_Bottom]=EVALPOS_PercentageOwner)}
	End Object
	Buttons[0]=ButtonTemplate0

	// Button 1
	Begin Object Class=UTUIButtonBarButton Name=ButtonTemplate1
		TabIndex=1
		WidgetTag=butButtonBarButton1
		CaptionDataSource=(MarkupString="Button 1",RequiredFieldType=DATATYPE_Property)

		Position={( Value[UIFACE_Left]=0.9,
				ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
				Value[UIFACE_Top]=0,
				ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
				Value[UIFACE_Right]=0.1,
				ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,
				Value[UIFACE_Bottom]=0.70,
				ScaleType[UIFACE_Bottom]=EVALPOS_PercentageOwner)}
	End Object
	Buttons[1]=ButtonTemplate1

	// Button 2
	Begin Object Class=UTUIButtonBarButton Name=ButtonTemplate2
		TabIndex=2
		WidgetTag=butButtonBarButton2
		CaptionDataSource=(MarkupString="Button 2",RequiredFieldType=DATATYPE_Property)

		Position={( Value[UIFACE_Left]=0.9,
				ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
				Value[UIFACE_Top]=0,
				ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
				Value[UIFACE_Right]=0.1,
				ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,
				Value[UIFACE_Bottom]=0.70,
				ScaleType[UIFACE_Bottom]=EVALPOS_PercentageOwner)}
	End Object
	Buttons[2]=ButtonTemplate2

	// Button 3
	Begin Object Class=UTUIButtonBarButton Name=ButtonTemplate3
		TabIndex=3
		WidgetTag=butButtonBarButton3
		CaptionDataSource=(MarkupString="Button 3",RequiredFieldType=DATATYPE_Property)

		Position={( Value[UIFACE_Left]=0.9,
				ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
				Value[UIFACE_Top]=0,
				ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
				Value[UIFACE_Right]=0.1,
				ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,
				Value[UIFACE_Bottom]=0.70,
				ScaleType[UIFACE_Bottom]=EVALPOS_PercentageOwner)}
	End Object
	Buttons[3]=ButtonTemplate3

	// Button 4
	Begin Object Class=UTUIButtonBarButton Name=ButtonTemplate4
		TabIndex=4
		WidgetTag=butButtonBarButton4
		CaptionDataSource=(MarkupString="Button 4",RequiredFieldType=DATATYPE_Property)

		Position={( Value[UIFACE_Left]=0.9,
				ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
				Value[UIFACE_Top]=0,
				ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
				Value[UIFACE_Right]=0.1,
				ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,
				Value[UIFACE_Bottom]=0.70,
				ScaleType[UIFACE_Bottom]=EVALPOS_PercentageOwner)}
	End Object
	Buttons[4]=ButtonTemplate4

	// Button 5
	Begin Object Class=UTUIButtonBarButton Name=ButtonTemplate5
		TabIndex=5
		WidgetTag=butButtonBarButton5
		CaptionDataSource=(MarkupString="Button 5",RequiredFieldType=DATATYPE_Property)

		Position={( Value[UIFACE_Left]=0.9,
				ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
				Value[UIFACE_Top]=0,
				ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
				Value[UIFACE_Right]=0.1,
				ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,
				Value[UIFACE_Bottom]=0.70,
				ScaleType[UIFACE_Bottom]=EVALPOS_PercentageOwner)}
	End Object
	Buttons[5]=ButtonTemplate5
}
