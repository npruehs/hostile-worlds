/**
 * This button is identical to UIButton, with the exception that pressing this button toggles its pressed state, rather
 * than only remaining in the pressed state while the mouse/key is depressed.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIToggleButton extends UILabelButton
	native(inherit);

/** the data store that this togglebutton retrieves its checked/unchecked value from */
var(Data)	private					UIDataStoreBinding		ValueDataSource;

/**
 * Controls whether this button is considered checked.  When bIsChecked is TRUE, CheckedImage will be rendered over
 * the button background image, using the current style.
 */
var(Data)	private					bool					bIsChecked;

/** Renders the caption for this button when it is checked */
var(Components)	editinline	const noclear	UIComp_DrawString	CheckedStringRenderComponent;

/** Component for rendering the button background image when checked */
var(Components)	editinline	const	noclear	UIComp_DrawImage	CheckedBackgroundImageComponent;

cpptext
{
	/**
	 * Perform all initialization for this widget. Called on all widgets when a scene is opened,
	 * once the scene has been completely initialized.
	 * For widgets added at runtime, called after the widget has been inserted into its parent's
	 * list of children.
	 *
	 * @param	inOwnerScene	the scene to add this widget to.
	 * @param	inOwner			the container widget that will contain this widget.  Will be NULL if the widget
	 *							is being added to the scene's list of children.
	 */
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );

	/* === UUIObject interface === */
	/**
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the LabelBackground (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

/**
	 * Adds the specified face to the DockingStack for the specified widget
	 *
	 * @param	DockingStack	the docking stack to add this docking node to.  Generally the scene's DockingStack.
	 * @param	Face			the face that should be added
	 *
	 * @return	TRUE if a docking node was added to the scene's DockingStack for the specified face, or if a docking node already
	 *			existed in the stack for the specified face of this widget.
	 */
	virtual UBOOL AddDockingNode( TArray<FUIDockingNode>& DockingStack, EUIWidgetFace Face );

	/**
	 * Evalutes the Position value for the specified face into an actual pixel value.  Should only be
	 * called from UIScene::ResolvePositions.  Any special-case positioning should be done in this function.
	 *
	 * @param	Face	the face that should be resolved
	 */
	virtual void ResolveFacePosition( EUIWidgetFace Face );

protected:
	/**
	 * Marks the Position for any faces dependent on the specified face, in this widget or its children,
	 * as out of sync with the corresponding RenderBounds.
	 *
	 * @param	Face	the face to modify; value must be one of the EUIWidgetFace values.
	 */
	virtual void InvalidatePositionDependencies( BYTE Face );

public:
	/**
	 * Render this widget.
	 *
	 * @param	Canvas	the FCanvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas );

	/**
	 * Called to globally update the formatting of all UIStrings.
	 */
	virtual void RefreshFormatting( UBOOL bRequestSceneUpdate=TRUE );

	/**
	 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
	 *
	 * @param	BindingIndex		indicates which data store binding should be modified.
	 *
	 * @return	TRUE if this subscriber successfully resolved and applied the updated value.
	 */
	virtual UBOOL RefreshSubscriberValue(INT BindingIndex=INDEX_NONE);
	/**
	 * Retrieves the list of data stores bound by this subscriber.
	 *
	 * @param	out_BoundDataStores		receives the array of data stores that subscriber is bound to.
	 */
	virtual void GetBoundDataStores(TArray<class UUIDataStore*>& out_BoundDataStores);
	/**
	 * Notifies this subscriber to unbind itself from all bound data stores
	 */
	virtual void ClearBoundDataStores();
	/** Saves the value for this subscriber. */
	virtual UBOOL SaveSubscriberValue(TArray<class UUIDataStore*>& out_BoundDataStores,INT BindingIndex=INDEX_NONE);

protected:

	/**
	 * Handles input events for this checkbox.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputKey( const struct FSubscribedInputEventParameters& EventParms );

public:
	/* === UObject interface === */
	/**
	 * Called when a property value from a member struct or array has been changed in the editor, but before the value has actually been modified.
	 */
	virtual void PreEditChange( FEditPropertyChain& PropertyThatChanged );

	/**
	 * Called when a property value from a member struct or array has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);
}

/* === Natives === */

/**
 * Sets the caption for this button.
 *
 * @param	NewText			the new caption for the button
 */
native function SetCaption( string NewText );

/* === Unrealscript === */
/**
 * Returns TRUE if this button is in the checked state, FALSE if in the
 */
final function bool IsChecked()
{
	return bIsChecked;
}

/**
 * Changed the checked state of this checkbox and activates a checked event.
 *
 * @param	bShouldBeChecked	TRUE to turn the checkbox on, FALSE to turn it off
 * @param	PlayerIndex			the index of the player that generated the call to SetValue; used as the PlayerIndex when activating
 *								UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
native final function SetValue( bool bShouldBeChecked, optional int PlayerIndex=INDEX_NONE );

/**
 * Default handler for the toggle button's OnClick
 */
function bool ButtonClicked( UIScreenObject Sender, int PlayerIndex )
{
	SetValue( !IsChecked() );
	return false;
}

DefaultProperties
{
	OnClicked=ButtonClicked

	Begin Object Class=UIComp_DrawString Name=CheckedLabelStringRenderer
		StringStyle=(DefaultStyleTag="DefaultToggleButtonStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
		StyleResolverTag="Caption Style (Checked)"
	End Object
	CheckedStringRenderComponent=CheckedLabelStringRenderer

	Begin Object class=UIComp_DrawImage Name=CheckedBackgroundImageTemplate
		ImageStyle=(DefaultStyleTag="DefaultToggleButtonBackgroundStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Background Image Style (Checked)"
	End Object
	CheckedBackgroundImageComponent=CheckedBackgroundImageTemplate

	ValueDataSource=(RequiredFieldType=DATATYPE_Property)
}
