`include(UIDev.uci)

/**
 * Base class for all widget types which act as buttons.  Buttons trigger events when
 * they are clicked on or activated using the keyboard.
 * This basic button contains only a background image.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIButton extends UIObject
	native(UIPrivate);

/** Component for rendering the button background image */
var(Components)	editinline	const	noclear	UIComp_DrawImage		BackgroundImageComponent;

/** this sound is played when this widget is clicked */
var(Sound)				name						ClickedCue;

cpptext
{
	/* === UIButton interface === */
	/**
	 * Changes the background image for this button, creating the wrapper UITexture if necessary.
	 *
	 * @param	NewImage		the new surface to use for this UIImage
	 */
	virtual void SetImage( class USurface* NewImage );

	/* === UIObject interface === */
	/**
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the BackgroundImageComponent (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

	/* === UUIScreenObject interface === */
	/**
	 * Generates a array of UI Action keys that this widget supports.
	 *
	 * @param	out_KeyNames	Storage for the list of supported keynames.
	 */
	virtual void GetSupportedUIActionKeyNames(TArray<FName> &out_KeyNames );

	/**
	 * Render this button.
	 *
	 * @param	Canvas	the FCanvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas );

protected:
	/**
	 * Handles input events for this button.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputKey( const struct FSubscribedInputEventParameters& EventParms );

public:
	/**
	 * Called when a property value from a member struct or array has been changed in the editor, but before the value has actually been modified.
	 */
	virtual void PreEditChange( FEditPropertyChain& PropertyThatChanged );

	/**
	 * Called when a property value from a member struct or array has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);
}

/* === Unrealscript === */
/**
 * Changes the background image for this button, creating the wrapper UITexture if necessary.
 *
 * @param	NewImage		the new surface to use for this UIImage
 */
final function SetImage( Surface NewImage )
{
	if ( BackgroundImageComponent != None )
	{
		BackgroundImageComponent.SetImage(NewImage);
	}
}

`if(`isdefined(dev_build))
function bool InitContextMenu( UIObject Sender, int PlayerIndex, out UIContextMenu CustomContextMenu )
{
	local array<string> InitialItems;
	local string Item;
	local int ItemIndex;

	CustomContextMenu = GetScene().GetDefaultContextMenu();
	if ( CustomContextMenu != None )
	{
		InitialItems[0] = "first item";
		InitialItems[1] = "second item";
		InitialItems[2] = "third item";
		InitialItems[3] = "-";

		if ( !CustomContextMenu.SetMenuItems(Self, InitialItems) )
		{
			`log("SetMenuItems failed!");
		}

		if ( !CustomContextMenu.InsertMenuItem(Self, "first appended item") )
		{
			`log("InsertMenuItem failed!");
		}

		if ( CustomContextMenu.GetMenuItem(Self, 2, Item) )
		{
			`log("GetMenuItem(2) returned:" @ Item);
		}
		else
		{
			`log("GetMenuItem failed!");
		}

		if ( !CustomContextMenu.RemoveMenuItem(Self, InitialItems[1]) )
		{
			`log("RemoveMenuItem failed!");
		}
		else if ( !CustomContextMenu.InsertMenuItem(Self, InitialItems[2], 2) )
		{
			`log("InsertMenuItem with custom index failed!");
		}

		ItemIndex = CustomContextMenu.FindMenuItemIndex(Self, InitialItems[3]);
		`log("FindMenuItemIndex '-' returned:" @ ItemIndex);
	}
	return true;
}

/**
 * Called when the user selects a choice from a context menu.
 *
 * @param	ContextMenu		the context menu that called this delegate.
 * @param	PlayerIndex		the index of the player that generated the event.
 * @param	ItemIndex		the index [into the context menu's MenuItems array] for the item that was selected.
 */
function LogSelectedItem( UIContextMenu ContextMenu, int PlayerIndex, int ItemIndex )
{
	`log("Context menu item selected:" @ `showobj(ContextMenu) @ `showvar(ItemIndex));
}

DefaultProperties
{
	OnOpenContextMenu=InitContextMenu
	OnContextMenuItemSelected=LogSelectedItem
`else
DefaultProperties
{
`endif

	PrimaryStyle=(DefaultStyleTag="ButtonBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
	bSupportsPrimaryStyle=false

	// States
	DefaultStates.Add(class'Engine.UIState_Focused')
	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Pressed')

	Begin Object class=UIComp_DrawImage Name=BackgroundImageTemplate
		ImageStyle=(DefaultStyleTag="ButtonBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Background Image Style"
	End Object
	BackgroundImageComponent=BackgroundImageTemplate

	// Events
	Begin Object Class=UIEvent_OnClick Name=ButtonClickHandler
	End Object

	Begin Object Name=WidgetEventComponent
		DefaultEvents.Add((EventTemplate=ButtonClickHandler,EventState=class'UIState_Focused'))
	End Object

	ClickedCue=Clicked
}
