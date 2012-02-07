/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Generic Message Box Scene for UDK
 */
class UDKUIScene_MessageBox extends UDKUIScene
	native;

const MESSAGEBOX_MAX_POSSIBLE_OPTIONS = 4;

const CANCEL_BUTTON_MARKUP_STRING = "<Strings:UDKGameUI.Generic.Cancel>";

cpptext
{
	/** Encapsulates logic for determining whether this message box is interpolating opacity */
	UBOOL IsFading() const { return FadeDirection != 0; }
	UBOOL IsFadingIn() const { return FadeDirection > 0; }
	UBOOL IsFadingOut() const { return FadeDirection < 0; }

	/**
	 * Provides scenes with a way to alter the amount of transparency to use when rendering parent scenes.
	 *
	 * @param	AlphaModulationPercent	the value that will be used for modulating the alpha when rendering the scene below this one.
	 *
	 * @return	TRUE if alpha modulation should be applied when rendering the scene below this one.
	 */
	virtual UBOOL ShouldModulateBackgroundAlpha( FLOAT& AlphaModulationPercent );

	/**
	 * Called once per frame to update the scene's state.
	 *
	 * @param	DeltaTime	the time since the last Tick call
	 */
	virtual void Tick( FLOAT DeltaTime );
}

/** Whether you want the message box's dialog and title to position itself to the center of the screen or not. */
var() bool bRepositionMessageToCenter;

/** Message box message. */
var transient UILabel					MessageLabel;

/** Message box title markup. */
var transient UILabel					TitleLabel;

/** Reference to the owning widget that has all of the content of the message box scene. */
var transient UIObject					BackgroundImage;

/** Reference to the scroll window that holds the message label. */
var transient UIObject					ScrollWindow;

/** References to the scene's buttonbar. */
var transient UDKUI_Widget				ButtonBar;

/** Array of potential options markup. */
var transient array<string>				PotentialOptions;

/** Arrays of key's that trigger each potential option. */
struct native PotentialOptionKeys
{
	var array<name>		Keys;
};

var transient array<PotentialOptionKeys>		PotentialOptionKeyMappings;

/** Whether or not the message box is fully visible. */
var transient bool								bFullyVisible;

/** Stores which option the user selected. */
var transient int						PreviouslySelectedOption;

/** Index of the player that selected the option. */
var transient int						SelectingPlayer;

/** Index of the option that is selected by default, valid for PC only. */
var transient int						DefaultOptionIdx;

/** The time the message box was fully displayed. */
var transient float						DisplayTime;

/** The minimum amount of time to display modal message boxes for. */
var transient float						MinimumDisplayTime;

/** How long to take to display/hide the message box. */
var transient float						FadeDuration;

/** Direction we are currently fading, positive is fade in, negative is fade out, 0 is not fading. */
var transient int						FadeDirection;

/** Time fading started. */
var transient float						FadeStartTime;

/** Flag that lets the dialog know it should hide itself. */
var transient bool						bHideOnNextTick;

/** Flag which is used natively to recalculate the dialog button positions */
var bool							bRepositionButtons;

/**
 * The user has made a selection of the choices available to them.
 */
delegate OnSelection(UDKUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex);

/** Delegate called after the message box has been competely closed. */
delegate OnClosed();

/** Delegate to trap any input to the message box. */
delegate bool OnMBInputKey( const out InputEventParameters EventParms );

event Initialized()
{
	Super.Initialized();

	// for some reason the scene's event component serialized the DisabledEventAliases array with 0 elements, so make sure that Closed is in the list
	EventProvider.DisabledEventAliases.AddItem('CloseScene');
}

/** Sets delegates for the scene. */
event PostInitialize()
{
	Super.PostInitialize();

	// Setup a key handling delegate.

	// Store references to key objects.
	MessageLabel = UILabel(FindChild('lblMessage',true));
	TitleLabel = UILabel(FindChild('lblTitle',true));
	ButtonBar = UDKUI_Widget(Findchild('pnlButtonBar', true));
	ScrollWindow = FindChild('pnlScrollFrame', true);
	BackgroundImage = FindChild('imgBackground', true);
}

/**
 * Sets the potential options for a message box.
 *
 * @param InPotentialOptions				Potential options the user has to choose from.
 * @param InPotentialOptionsKeyMappings		Button keys that map to the options specified, usually this can be left to defaults.
 */
function SetPotentialOptions(array<string> InPotentialOptions, optional array<PotentialOptionKeys> InPotentialOptionKeyMappings)
{
	PotentialOptions = InPotentialOptions;
}

/**
 * Sets the potential option key mappings for a message box, usually this can be left to defaults.
 *
 * @param InPotentialOptions				Potential options the user has to choose from.
 * @param InPotentialOptionsKeyMappings		Button keys that map to the options specified, usually this can be left to defaults.
 */
function SetPotentialOptionKeyMappings(array<PotentialOptionKeys> InPotentialOptionKeyMappings)
{
	PotentialOptionKeyMappings=InPotentialOptionKeyMappings;
}

/**
 * Changes the title for this messagebox.
 *
 * @param	NewTitle	the new title for the message box
 */
function SetTitle(string NewTitle)
{
	TitleLabel.SetDatastoreBinding(NewTitle);
}

/**
 * Sets the current message for this messagebox.
 *
 * @param NewMessage	New message for the messagebox.
 */
function SetMessage(string NewMessage)
{
	local int i;

	// NOTE: GetValue should return the processed string, i.e. without markups
	i = Len(MessageLabel.GetValue());

	MessageLabel.SetDatastoreBinding(NewMessage);

	// If the new label is bigger than the last, recalculate button positions (otherwise buttons may overlap text)
	if (Len(MessageLabel.GetValue()) > i)
		bRepositionButtons = True;
}

/**
 * Wrapper for setting the OnSelection delegate.
 */
function SetSelectionDelegate( delegate<OnSelection> InSelectionDelegate )
{
	OnSelection = InSelectionDelegate;
}

/**
 * Closes the message box, used for modal message boxes.
 *
 * @param	bSimulateCancel		specify TRUE to generate a cancel button press event; otherwise, whichever button is in
 *								the last slot (e.g. PotentialOptions[0]) will appear to have been pressed).
 * @param	PlayerIndex			the index of the player that generated the close event.
 */
function Close( optional bool bSimulateCancel, optional int PlayerIndex=GetBestPlayerIndex() )
{
	local int CancelButtonIndex;

	if ( bSimulateCancel )
	{
		CancelButtonIndex = Max(0, FindCancelButtonIndex());
		OptionSelected(CancelButtonIndex, PlayerIndex);
	}
	else
	{
		bHideOnNextTick = true;
	}
}

/**
 * Displays a message box that has the default button layout; useful when you may be reusing the same scene instance
 *
 * @param Message				Message for the message box.  Should be datastore markup.
 * @param Title					Title for the message box.  Should be datastore markup.
 * @param InSelectionDelegate	Delegate to call when the user dismisses the message box.
 */
function DisplayAcceptBox(string Message, optional string Title="", optional delegate<OnSelection> InSelectionDelegate)
{
	PotentialOptions = default.PotentialOptions;
	PotentialOptionKeyMappings = default.PotentialOptionKeyMappings;

	Display(Message,Title,InSelectionDelegate);
}

/**
 * Displays a message box that has a cancel button only.
 *
 * @param Message				Message for the message box.  Should be datastore markup.
 * @param Title					Title for the message box.  Should be datastore markup.
 * @param InSelectionDelegate	Delegate to call when the user dismisses the message box.
 */
function DisplayCancelBox(string Message, optional string Title="", optional delegate<OnSelection> InSelectionDelegate)
{
	if ( !bFullyVisible )
	{
		PotentialOptions.length = 1;
		PotentialOptions[0]=CANCEL_BUTTON_MARKUP_STRING;

		PotentialOptionKeyMappings.length = 1;
		PotentialOptionKeyMappings[0].Keys.length=2;
		PotentialOptionKeyMappings[0].Keys[0]='XboxTypeS_B';
		PotentialOptionKeyMappings[0].Keys[1]='Escape';

		Display(Message,Title,InSelectionDelegate);
	}
	else
	{
		if ( PotentialOptions.Length != 1
		||	PotentialOptions[0] != CANCEL_BUTTON_MARKUP_STRING )
		{
			PotentialOptions.length = 1;
			PotentialOptions[0]=CANCEL_BUTTON_MARKUP_STRING;

			PotentialOptionKeyMappings.length = 1;
			PotentialOptionKeyMappings[0].Keys.length=2;
			PotentialOptionKeyMappings[0].Keys[0]='XboxTypeS_B';
			PotentialOptionKeyMappings[0].Keys[1]='Escape';
			SetupButtonBar();
		}

		SetTitle(Title);
		SetMessage(Message);
		SetSelectionDelegate(InSelectionDelegate);
	}
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

	Display(Message, Title, InSelectionDelegate);
}


/** Displays a message box that has no buttons and must be closed by the scene that opened it. */
function DisplayModalBox(string Message, optional string Title="", optional float InMinDisplayTime=2.0f)
{
	// If we're not shown yet, do the fade in animation, otherwise just update the text.
	if ( !bFullyVisible )
	{
		// This is a ship requirement, we need to display modal dialogs for a minimum amount of time.
		MinimumDisplayTime = InMinDisplayTime;
		PotentialOptions.length = 0;
		PotentialOptionKeyMappings.length = 0;
		ButtonBar.SetVisibility(false);

		Display(Message,Title);
	}
	else
	{
		DefaultOptionIdx = INDEX_NONE;
		SetSelectionDelegate(None);

		SetTitle(Title);
		SetMessage(Message);

		if ( PotentialOptions.Length > 0 )
		{
			PotentialOptions.Length = 0;
			PotentialOptionKeyMappings.Length = 0;
			ButtonBar.SetVisibility(false);
			SetupButtonBar();
		}
	}
}


/**
 * Displays the message box.
 *
 * @param Message				Message for the message box.  Should be datastore markup.
 * @param Title					Title for the message box.  Should be datastore markup.
 * @param InSelectionDelegate	Delegate to call when the user dismisses the message box.
 */
function Display(string Message, optional string Title="", optional delegate<OnSelection> InSelectionDelegate, optional int InDefaultOptionIdx=INDEX_NONE)
{
	local int OptionIdx;

	`log(`location@`showvar(Message)@`showvar(Title)@`showvar(InSelectionDelegate!=None,DelegateValid)@`showvar(InDefaultOptionIdx),,'DevUI');

	SetTitle(Title);
	SetMessage(Message);
	SetSelectionDelegate(InSelectionDelegate);
	DefaultOptionIdx = InDefaultOptionIdx;

	SetupButtonBar();

	// Set focus to the default option
	if(PotentialOptions.length > 0)
	{
		OptionIdx = PotentialOptions.Length - 1 - Max(0, DefaultOptionIdx);
		ButtonBar.SetSubFocus(OptionIdx, None);
	}

	// Start showing the scene.

	// only call BlockUIInput if we aren't already performing a fade animation; otherwise, the number of calls to BeginShow
	// won't match the number of calls to OnShowComplete, so we end up blocking more than we unblock
	if ( FadeDirection == 0 )
	{
		GetUTInteraction().BlockUIInput(true);
	}

	BeginShow();
}

/**
 * Sets up the buttons that should be visible in the bar across the bottom of the scene.
 */
function SetupButtonBar()
{
	local int OptionIdx;

	// Setup buttons.  We only show enough buttons to cover each of the options the user specified.
	ButtonBar.Clear();
	for(OptionIdx=0;  OptionIdx<MESSAGEBOX_MAX_POSSIBLE_OPTIONS && OptionIdx<PotentialOptions.length; OptionIdx++)
	{
		// Reverse the index when displaying buttons so cancel is always shown to the far left.
		ButtonBar.AppendButton(PotentialOptions[PotentialOptions.length-OptionIdx-1], OnOptionButton_Clicked);
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
	local int OptionIdx;
	local int ButtonIdx;
	local array<name> KeyMappings;

	bResult=false;

	if(bFullyVisible)
	{
		// Give the mb delegate first chance at input
		bResult = OnMBInputKey(EventParms);

		if( !bResult )
		{
			if(EventParms.EventType==IE_Released)
			{
				// See if the key pressed is mapped to any of the potential options.
				for(OptionIdx=0; OptionIdx<PotentialOptions.length && OptionIdx<MESSAGEBOX_MAX_POSSIBLE_OPTIONS && OptionIdx<PotentialOptionKeyMappings.length && bResult==false; OptionIdx++)
				{
					KeyMappings=PotentialOptionKeyMappings[OptionIdx].Keys;

					for(ButtonIdx=0; ButtonIdx<KeyMappings.length; ButtonIdx++)
					{
						if(EventParms.InputKeyName==KeyMappings[ButtonIdx])
						{
							OptionSelected(OptionIdx, EventParms.PlayerIndex);
							bResult = true;
							break;
						}
					}
				}
			}
		}
	}

	return bResult;
}

/** Starts showing the message box. */
native function BeginShow();

/** Called when the dialog has finished showing itself. */
event OnShowComplete()
{
	//`Log("UTUIMessageBox::OnShowComplete() - Finished showing messagebox");

	GetUTInteraction().BlockUIInput(false);
	bFullyVisible = true;
	FadeDirection = 0;
}

/** Starts hiding the message box. */
native function BeginHide();

/** Called when the dialog is finished hiding itself. */
event OnHideComplete()
{
	//`Log("UTUIMessageBox::OnHideComplete() - Finished hiding messagebox");

	FadeDirection = 0;

	// Close ourselves.
	CloseScene(self, ,true);

	// Fire the OnClosed delegate
	OnClosed();

	// and clear it
	OnClosed = None;
}

/**
 * Callback for the OnClicked event.
 *
 * @param EventObject	Object that issued the event.
 * @param PlayerIndex	Player that performed the action that issued the event.
 *
 * @return	return TRUE to prevent the kismet OnClick event from firing.
 */
function bool OnOptionButton_Clicked(UIScreenObject EventObject, int PlayerIndex)
{
	local int OptionIdx;

	if(bFullyVisible)
	{
		for(OptionIdx=0; OptionIdx<MESSAGEBOX_MAX_POSSIBLE_OPTIONS; OptionIdx++)
		{
			if(EventObject==ButtonBar.GetButton(OptionIdx))
			{
				// Need to reverse the index
				OptionSelected(PotentialOptions.length-OptionIdx-1, PlayerIndex);
				break;
			}
		}
	}

	return false;
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
	PreviouslySelectedOption=OptionIdx;
	SelectingPlayer=PlayerIndex;
	bHideOnNextTick = true;

	// Fire the OnSelection delegate
	OnSelection(Self, PreviouslySelectedOption, SelectingPlayer);
}

/**
 * Determines the index of the button corresponding to the cancel button.
 *
 * @param	CancelButtonMarkupString	if a custom markup string was used for the cancel button, it can be specified here;
 *										otherwise the default markup string for the cancel button is used.
 *
 * @return	the index of the button used to cancel this dialog, or INDEX_NONE if a cancel button wasn't found.
 */
function int FindCancelButtonIndex( optional string CancelButtonMarkupString )
{
	if ( CancelButtonMarkupString == "" )
	{
		CancelButtonMarkupString = CANCEL_BUTTON_MARKUP_STRING;
	}

	return PotentialOptions.Find(CancelButtonMarkupString);
}

// Reposition buttons upon resolution change
function OnResolutionChanged(const out Vector2D OldViewportsize, const out Vector2D NewViewportSize)
{
	bRepositionButtons = True;
}

defaultproperties
{
	OnInterceptRawInputKey=HandleInputKey
	bPauseGameWhileActive=false
	bRenderParentScenes=true
	PotentialOptions=("<strings:UDKGameUI.Generic.OK>")
	PotentialOptionKeyMappings=((Keys=("XboxTypeS_A","Enter")), (Keys=("XboxTypeS_B","Escape")), (Keys=("XboxTypeS_X")), (Keys=("XboxTypeS_Y"))  )
	DefaultOptionIdx=INDEX_NONE
	FadeDuration=0.25f

	Begin Object Class=UIComp_Event Name=WidgetEventComponent
		DisabledEventAliases.Add(CloseScene)
	End Object
	EventProvider=WidgetEventComponent
	SceneRenderMode=SPLITRENDER_Fullscreen

	bRepositionMessageToCenter=true
	SceneSkin=None

	NotifyResolutionChanged=OnResolutionChanged
}
