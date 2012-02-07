// ============================================================================
// HWGFxView
// Base class for any screen or dialog in Hostile Worlds.
//
// Related Flash content: n/a
//
// Author:  Nick Pruehs
// Date:    2011/03/29
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxView extends GFxMoviePlayer;

/** The frontend that manages all transitions to and from this view. */
var HWGFxFrontEnd FrontEnd;

/** The title of this view. */
var localized string ViewTitle;

/** The list of sub-components of this view, e.g. labels or buttons. */
var array<GFxObject> SubComponents;

/** The mouse cursor of this view. */
var GFxObject MouseCursor;


function bool Start(optional bool StartPaused = false)
{
	local bool bLoadErrors;

	bLoadErrors = super.Start(StartPaused);

	// initialize this view without actually advancing the movie
    Advance(0.f);

	// ensure mouse cursor is always on top
	MouseCursor = GetVariableObject("mouseCursor");
	MouseCursor.SetBool("topmostLevel", true);

	`log("§§§ GUI: "$self$" has been started.");

	return bLoadErrors; // (b && true = b)
}

/**
 * Initializes the passed CLIK widget, adding it to the list of sub-components
 * of this view.
 * 
 * @param Widget
 *      the new sub-component of this view
 * @param WidgetName
 *      the name of the new sub-component of this view
 */
function InitSubComponent(GFxObject Widget, name WidgetName)
{
	SubComponents.AddItem(Widget);

	//`log("§§§ GUI: "$self$" has initialized "$WidgetName$" = "$Widget);
}

/** 
 *  Initializes the passed CLIK label, setting its text.
 *  
 *  @param Widget
 *      the new label of this view
 *  @param WidgetName
 *      the name of the new label of this view
 *  @param Text
 *      the initial text of the label
 */
function GFxObject InitLabel(GFxObject Widget, name WidgetName, coerce string Text)
{
	Widget.SetText(Text);

	InitSubComponent(Widget, WidgetName);

	return Widget;
}

/** 
 *  Initializes the passed CLIK button, setting its text and its event
 *  listeners.
 *  
 *  @param Widget
 *      the new button of this view
 *  @param WidgetName
 *      the name of the new button of this view
 *  @param Label
 *      the initial label of the button
 *  @param OnPress
 *      the function to call when the button is pressed
 *  @param OnRollOver
 *      the function to call when the user hovers the button
 */
function GFxClikWidget InitButton(GFxObject Widget, name WidgetName, coerce string Label, delegate<GFxClikWidget.EventListener> OnPress, optional delegate<GFxClikWidget.EventListener> OnRollOver)
{
	local GFxClikWidget Button;

	Button = GFxClikWidget(Widget);

	Button.SetString("label", Label);

	Button.AddEventListener('CLIK_press', OnPress);

	if (OnRollOver != none)
	{
		Button.AddEventListener('CLIK_rollOver', OnRollOver);
		Button.AddEventListener('CLIK_rollOut',  OnRollOut);
	}

	InitSubComponent(Widget, WidgetName);

	return Button;
}

/** 
 *  Initializes the passed CLIK input, setting its text and its event
 *  listeners.
 *  
 *  @param Widget
 *      the new input of this view
 *  @param WidgetName
 *      the name of the new input of this view
 *  @param Text
 *      the initial label of the input
 *  @param OnRollOver
 *      the function to call when the user hovers the input
 */
function GFxClikWidget InitInput(GFxObject Widget, name WidgetName, coerce string Text, optional delegate<GFxClikWidget.EventListener> OnRollOver)
{
	local GFxClikWidget TextInput;

	TextInput = GFxClikWidget(Widget);

	TextInput.SetText(Text);

	if (OnRollOver != none)
	{
		TextInput.AddEventListener('CLIK_rollOver', OnRollOver);
		TextInput.AddEventListener('CLIK_rollOut', OnRollOut);
	}   

	InitSubComponent(Widget, WidgetName);

	return TextInput;
}

/** 
 *  Initializes the passed CLIK checkbox, setting its label, initial state and
 *  event listeners.
 *  
 *  @param Widget
 *      the new checkbox of this view
 *  @param WidgetName
 *      the name of the new checkbox of this view
 *  @param Label
 *      the initial label of the checkbox
  *  @param bChecked
 *      the initial state of the checkbox
 *  @param OnRollOver
 *      the function to call when the user hovers the checkbox
 */
function GFxClikWidget InitCheckBox(GFxObject Widget, name WidgetName, coerce string Label, bool bChecked, optional delegate<GFxClikWidget.EventListener> OnRollOver)
{
	local GFxClikWidget CheckBox;

	CheckBox = GFxClikWidget(Widget);

	CheckBox.SetString("label", Label);
	CheckBox.SetBool("selected", bChecked);

	if (OnRollOver != none)
	{
		CheckBox.AddEventListener('CLIK_rollOver', OnRollOver);
		CheckBox.AddEventListener('CLIK_rollOut',  OnRollOut);
	}

	InitSubComponent(Widget, WidgetName);

	return CheckBox;
}

/** 
 *  Initializes the passed CLIK slider, setting its value range and
 *  event listeners.
 *  
 *  @param Widget
 *      the new slider of this view
 *  @param WidgetName
 *      the name of the new slider of this view
 *  @param MinValue
 *      the minimum value of the new slider
 *  @param MaxValue
 *      the maximum value of the new slider
 *  @param InitialValue
 *      the initial value of the new slider
 *  @param OnChange
 *      the function to call when the value of the slider changes
 *  @param SnapInterval
 *      the interval between two steps of the new slider
 */
function GFxClikWidget InitSlider(GFxObject Widget, name WidgetName, float MinValue, float MaxValue, float InitialValue, delegate<GFxClikWidget.EventListener> OnChange, optional float SnapInterval)
{
	local GFxClikWidget Slider;

	Slider = GFxClikWidget(Widget);

	// initialize value range
	Slider.SetFloat("minimum", MinValue);
	Slider.SetFloat("maximum", MaxValue);
	Slider.SetFloat("value", InitialValue);

	// set up event listener
	Slider.SetBool("liveDragging", true);
	Slider.AddEventListener('CLIK_change', OnChange);

	// enable snapping
	if (SnapInterval != 0)
	{
		Slider.SetBool("snapping", true);
		Slider.SetFloat("snapInterval", SnapInterval);
	}
	else
	{
		Slider.SetBool("snapping", false);
	}

	InitSubComponent(Widget, WidgetName);

	return Slider;
}

/**
 * Initializes the passed list, filling it with the specified list items and
 * setting up its event listeners.
 * 
 * @param Widget
 *      the new list of this view
 * @param WidgetName
 *      the name of the new list of this view
 * @param ListItems
 *      the items to add to the list
 * @param OnChange
 *      the function to call whenever a new list item has been selected
 */
function GFxClikWidget InitList(GFxObject Widget, name WidgetName, array<string> ListItems, delegate<GFxClikWidget.EventListener> OnChange)
{
	local GFxClikWidget List;
	local GFxObject DataProvider;
	local int i;

	List = GFxClikWidget(Widget);

	// fill list
    DataProvider = CreateArray();

    for (i = 0; i < ListItems.Length; i++)
    {        
        DataProvider.SetElementString(i, ListItems[i]);
    }

    List.SetObject("dataProvider", DataProvider);  

	// add event listener
	List.AddEventListener('CLIK_change', OnChange);

	// initially select first item
	List.SetFloat("selectedIndex", 0);

	InitSubComponent(Widget, WidgetName);

	return List;
}

/**
 * Initializes the passed CLIK dropdown menu, filling it with the specified
 * menu items and setting up its event listeners.
 * 
 * @param Widget
 *      the new dropdown menu of this view
 * @param WidgetName
 *      the name of the new dropdown menu of this view
 * @param MenuItems
 *      the items to add to the dropdown menu
 * @param OnSelect
 *      the function to call whenever a new menu item has been selected
 *  @param OnRollOver
 *      the function to call when the user hovers the checkbox
 */
function GFxClikWidget InitDropdown(GFxObject Widget, name WidgetName, array<string> MenuItems, delegate<GFxClikWidget.EventListener> OnSelect,  optional delegate<GFxClikWidget.EventListener> OnRollOver)
{
	local GFxClikWidget DropDown;
	local GFxObject DataProvider;
	local int i;

	DropDown = GFxClikWidget(Widget);

	// fill dropdown menu
    DataProvider = CreateArray();

    for (i = 0; i < MenuItems.Length; i++)
    {        
        DataProvider.SetElementString(i, MenuItems[i]);
    }

    DropDown.SetObject("dataProvider", DataProvider);  
	DropDown.SetFloat("rowCount", MenuItems.Length);

	// add event listeners
	DropDown.AddEventListener('CLIK_select', OnSelect);

	if (OnRollOver != none)
	{
		DropDown.AddEventListener('CLIK_rollOver', OnRollOver);
		DropDown.AddEventListener('CLIK_rollOut',  OnRollOut);
	}

	// initially select first item
	DropDown.SetFloat("selectedIndex", 0);

	InitSubComponent(Widget, WidgetName);

	return DropDown;
}

/** Starts the Flash movie associated with this view and activates all of its components. */
function ShowView()
{
	Start();
	SetStateOfSubComponents(true);

	`log("§§§ GUI: Showing "$self);
}

/** Closes the Flash movie associated with this view (without unloading it) and de-activates all of its components. */
function HideView()
{
	Close(false);
	SetStateOfSubComponents(false);

	`log("§§§ GUI: Hiding "$self);
}

/** 
 *  Allows subclasses to enable or disable their sub-components.
 *  
 *  @param bEnabled
 *      whether to enable the sub-components
 */
function SetStateOfSubComponents(bool bEnabled)
{
	local GFxObject Widget;

	foreach SubComponents(Widget)
	{
		Widget.SetBool("disabled", !bEnabled);
	}
}

/** Clears the info label of the frontend. */
function OnRollOut(GFxClikWidget.EventData ev)
{
	if (FrontEnd != none)
	{
		FrontEnd.ClearInfo();
	}
}


DefaultProperties
{
	bDisplayWithHudOff=true    
    TimingMode=TM_Real
	bPauseGameWhileActive=false
	bCaptureInput=true
	bIgnoreMouseInput=false
}
