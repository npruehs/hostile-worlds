/**
 * Base class for message box scene types.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIMessageBoxBase extends UIScene
	abstract;

/** References to the widgets in the scene */
var transient UILabel lblTitle;
var	transient UILabel lblMessage;
var transient UILabel lblQuestion;
var transient UIImage imgQuestion;
var	transient UICalloutButtonPanel	btnbarChoices;

/** Names of the above widgets */
var() name TitleWidgetName;
var() name MessageWidgetName;
var() name QuestionWidgetName;
var() name ChoicesWidgetName;
var() name QuestionWidgetImageName;

/** Name of the style to use for the image of the buttonbar buttons */
var() name ButtonBarButtonBGStyleName;
/** Name of the style to use for the string of the buttonbar buttons */
var() name ButtonBarButtonTextStyleName;

/** Whether or not you want the message box to handle the layout and docking automatically or not */
var() bool bPerformAutomaticLayout;

/* == Delegates == */
/**
 * Called when the user selects an option.
 *
 * @param	Sender				the message box that generated this call
 * @param	SelectedInputAlias	the alias of the button that the user selected.  Should match one of the aliases passed into
 *								this message box.
 * @param	PlayerIndex			the index of the player that selected the option.
 *
 * @return	TRUE to indicate that the message box should close itself.
 */
delegate bool OnOptionSelected( UIMessageBoxBase Sender, name SelectedInputAlias, int PlayerIndex )
{
	return true;
}

/* == Natives == */

/* == Events == */

/* == UnrealScript == */
/**
 * Sets the values for the message box controls.
 *
 * @param	Title				the string or datastore markup to use as the message box title
 * @param	Message				the string or datastore markup to use for the message box text
 * @param	Question			the string or datastore markup to use for the question text
 * @param	ButtonAliases		the list of aliases to use in the message box's button bar; this determines which options are available as well
 *								as which input keys the message box responds to.  Aliases must be registered in the Engine.UIDataStore_InputAlias
 *								section of the input .ini file.
 * @param	SelectionCallback	specifies the function to call when the user makes a selection.
 */
function SetupMessageBox( string Title, string Message, string Question, array<name> ButtonAliases, optional delegate<OnOptionSelected> SelectionCallback )
{
	local int ButtonIdx;

	SetTitle(Title);
	SetMessage(Message);
	SetQuestion(Question);

	if ( btnbarChoices != None )
	{
		btnbarChoices.RemoveAllButtons();

		// add a button for each alias specified
		for ( ButtonIdx = 0; ButtonIdx < ButtonAliases.Length; ButtonIdx++ )
		{
			AddButton(ButtonAliases[ButtonIdx]);
		}

		if ( SelectionCallback != None )
		{
			OnOptionSelected = SelectionCallback;
		}
	}
}

/**
 * Sets the title for the message box.
 *
 * @param	NewTitleString	the string or datastore markup to use as the message box's title
 */
function SetTitle( string NewTitleString )
{
	if ( lblTitle != None )
	{
		lblTitle.SetDataStoreBinding(NewTitleString);
	}
}

/**
 * Sets the text for the message box.
 *
 * @param	NewMessageString	the string or datastore markup to use for the message box text
 */
function SetMessage( string NewMessageString )
{
	if ( lblMessage != None )
	{
		lblMessage.SetDataStoreBinding(NewMessageString);
	}
}

/**
 * Sets the text for the question.  Will hide the widget if the string is empty
 *
 * @param	NewMessageString	the string or datastore markup to use for the question text
 */
function SetQuestion( string NewMessageString )
{
	if ( lblMessage != None )
	{
		if ( NewMessageString == "" )
		{
			lblQuestion.SetVisibility( FALSE );
			imgQuestion.SetVisibility( FALSE );
		}
		else
		{
			lblQuestion.SetVisibility( TRUE );
			imgQuestion.SetVisibility( TRUE );
			lblQuestion.SetDataStoreBinding(NewMessageString);
		}
	}
}

/**
 * Assign the button's OnClick delegate to a function in this scene, and
 * set the styles for both the background and the text
 *
 * @param	TargetButton	the button to set the callback for.
 */
function protected SetButtonCallback( UICalloutButton TargetButton )
{
	TargetButton.SetWidgetStyleByName(TargetButton.BackgroundImageComponent.StyleResolverTag, ButtonBarButtonBGStyleName );
	TargetButton.SetWidgetStyleByName(TargetButton.StringRenderComponent.StyleResolverTag, ButtonBarButtonTextStyleName );

	btnbarChoices.SetButtonCallback(TargetButton.InputAliasTag, OptionChosen);
}

/**
 * Adds a button to the button bar, enabling the message box to respond to the input key
 * associated with the button alias.
 *
 * @param	ButtonAlias		the buttonbar alias of the button that should be added to the buttonbar. This determines which
 *							options are available as well as which input keys the message box responds to.  Aliases must be
 *							registered in the Engine.UIDataStore_InputAlias section of the input .ini file.
 *
 * @return	TRUE if the button was successfully added to the buttonbar.  FALSE if the alias wasn't registered or
 *			the button already existed in the buttonbar.
 */
function bool AddButton( name ButtonAlias )
{
	local bool bResult;
	local UICalloutButton AddedButton;

	if ( !HasButton(ButtonAlias) && btnbarChoices != None )
	{
		AddedButton = btnbarChoices.CreateCalloutButton(ButtonAlias, name("btn" $ ButtonAlias));
		if ( AddedButton != None )
		{
			SetButtonCallback(AddedButton);
			bResult = true;
		}
	}

	return bResult;
}

/**
 * Removes a button from the buttonbar.  The messagebox will no longer respond to the
 * input key associated with the button alias.
 *
 * @param	ButtonAlias		the buttonbar alias associated with the button that should be removed.
 *
 * @return	TRUE if the button was successfully removed.
 */
function bool RemoveButton( name ButtonAlias )
{
	local bool bResult;

	if ( btnbarChoices != None )
	{
		bResult = btnbarChoices.RemoveButtonByAlias(ButtonAlias);
	}

	return bResult;
}

/**
 * @return	TRUE if the button bar contains a button which has the specified alias.
 */
function bool HasButton( name ButtonAlias )
{
	return FindButtonIndex(ButtonAlias) != INDEX_NONE;
}

/**
 * Find the location of a button in the buttonbar's list of buttons.
 *
 * @param	ButtonAlias		the buttonbar alias associated with the button to search for.
 *
 * @return	the index into the buttonbar's list of buttons, or INDEX_NONE if it isn't found.
 */
function int FindButtonIndex( name ButtonAlias )
{
	if ( btnbarChoices != None )
	{
		return btnbarChoices.FindButtonIndex(ButtonAlias);
	}

	return INDEX_NONE;
}

/**
 * @return	the label that displays the message box's title string
 */
function UILabel GetTitleLabel()
{
	return lblTitle;
}

/**
 * @return	the label that displays the message box's message
 */
function UILabel GetMessageLabel()
{
	return lblMessage;
}

/**
 * @return	the buttonbar for the message box
 */
function UICalloutButtonPanel GetButtonBar()
{
	return btnbarChoices;
}

/**
 * Applies any special formatting to the message box's internal controls.
 */
function LayoutControls()
{
	if ( bPerformAutomaticLayout )
	{
		// setup the docking
		SetupDockingRelationships();

		// turn on auto-sizing
		lblTitle.StringRenderComponent.EnableAutoSizing(UIORIENT_Vertical, true);
		lblMessage.StringRenderComponent.EnableAutoSizing(UIORIENT_Vertical, true);

		// setup alignment
		lblTitle.StringRenderComponent.SetAlignment(UIORIENT_Horizontal, UIALIGN_Center);
		lblTitle.StringRenderComponent.SetAlignment(UIORIENT_Vertical, UIALIGN_Left);
		lblMessage.StringRenderComponent.SetAlignment(UIORIENT_Horizontal, UIALIGN_Center);
		lblMessage.StringRenderComponent.SetAlignment(UIORIENT_Vertical, UIALIGN_Left);

		// enable wrapping
		lblTitle.StringRenderComponent.SetWrapMode(CLIP_Wrap);
		lblMessage.StringRenderComponent.SetWrapMode(CLIP_Wrap);
	}
}

/**
 * Sets up the docking links for the message box's controls
 */
function SetupDockingRelationships();

/* == SequenceAction handlers == */

/* == Delegate handlers == */
/**
 * Handler for the buttonbar buttons' OnClicked delegate.  Routes the notification to the scene's OnOptionSelected
 * delegate.
 *
 * @param EventObject	Object that issued the event.
 * @param PlayerIndex	Player that performed the action that issued the event.
 *
 * @return	return TRUE to prevent the kismet OnClick event from firing.
 */
function bool OptionChosen( UIScreenObject EventObject, int PlayerIndex )
{
	local UICalloutButton SelectedButton;
	local GameUISceneClient GameSceneClient;

	SelectedButton = UICalloutButton(EventObject);
	if ( SelectedButton != None && SelectedButton.InputAliasTag != '' )
	{
		GameSceneClient = GetSceneClient();

		PlayUISound('Clicked');

		//@todo ronp - should we provide a way for clients to control whether we use a closing animation?
		if ( OnOptionSelected(Self, SelectedButton.InputAliasTag, PlayerIndex) )
		{
			OnOptionSelected = None;

			// we might have been closed by the handler of our OnOptionSelected delegate - they should return false in this case, but
			// doesn't hurt to double-check
			if ( GameSceneClient != None && GameSceneClient.FindSceneIndex(Self) != INDEX_NONE )
			{
				CloseScene();
			}
		}
	}

	return true;
}

/* === UIScreenObject interface === */
/**
 * Handler for scene's OnSceneActivated delegate.
 *
 * @param	ActivatedScene			the scene that was activated
 * @param	bInitialActivation		TRUE if this is the first time this scene is being activated; FALSE if this scene has become active
 *									as a result of closing another scene or manually moving this scene in the stack.
 */
function HandleSceneActivated( UIScene ActivatedScene, bool bInitialActivation )
{
	if ( bInitialActivation )
	{
		lblTitle = UILabel(FindChild(TitleWidgetName, true));
		lblMessage = UILabel(FindChild(MessageWidgetName, true));
		lblQuestion = UILabel(FindChild(QuestionWidgetName, true));
		imgQuestion = UIImage(FindChild(QuestionWidgetImageName, true));
		btnbarChoices = UICalloutButtonPanel(FindChild(ChoicesWidgetName, true));

		LayoutControls();
	}
}

DefaultProperties
{
	/* == UIScene defaults == */
	bPauseGameWhileActive=false
	bRenderParentScenes=true
	OnSceneActivated=HandleSceneActivated
	SceneRenderMode=SPLITRENDER_Fullscreen

	// override the scene's event provider to remove the CloseScene alias.
	Begin Object Name=SceneEventComponent
		DisabledEventAliases.Add(CloseScene)
	End Object

	/* == UIScreenObject defaults == */
	Position={(
			Value[UIFACE_Left]=0.25,	ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
			Value[UIFACE_Top]=0.25,		ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
			Value[UIFACE_Right]=0.75,	ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,
			Value[UIFACE_Bottom]=0.75,	ScaleType[UIFACE_Bottom]=EVALPOS_PercentageOwner
			)}
}

