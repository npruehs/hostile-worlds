/**
 * Base class for all UI entities which can appear onscreen
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIScreenObject extends UIRoot
	native(UIPrivate)
	Config(UI)
	HideCategories(Object)
	AutoCollapseCategories(Animation,Sound,Style)
	abstract
	placeable;

/** The location of this screen object */
var(Appearance)							UIScreenValue_Bounds	Position;

/**
 * Controls how the widget is sorted by the rendering code; higher values push the widget "away" from the screen,
 * while lower values bring the widget "closer" to the screen
 */
var(Appearance)		private{private}	float					ZDepth;

/** Controls whether the screen object is visible */
var(Appearance) 	private{private}	bool					bHidden;

/**
 * Indicates whether this widget has been initialized.  Set from UUIScene/UUIObject::Initialize, immediately after the
 * base version of Initialized has been called, but before Initialize() has been called on the children of the widget.
 */
var transient							bool					bInitialized;

/** list of UIObjects which are owned by this UIObject */
var	protected noimport					array<UIObject>			Children;

/**
 * The states that should exist in this widget's InactiveStates array by default.  When the widget is initialized, the
 * InactiveStates array is iterated through, and if there are no states in the InactiveStates array that have a class
 * matching a DefaultState, a new UIState object of that class is instanced and placed into the InactiveStates array.
 */
var	const								array<class<UIState> >	DefaultStates;

/**
 * Specifies the UIState that this widget will automatically enter when it is initialized.
 */
var										class<UIState>			InitialState;

/** list of states that this screen object can enter */
var(Appearance) const	editconst instanced	array<UIState>		InactiveStates;

/** stack of states this widget is currently using */
var	transient	const					array<UIState>			StateStack;

/**
 * The children of this widget that are in special states (i.e. focused control, last focused control, etc.)
 * Each element of this array corresponds to the player at the same array index in the Engine.GamePlayers array.
 */
var	transient	const			array<PlayerInteractionData>	FocusControls;

/**
 * Determines which children of this widget should receive focus when this widget receives focus.
 * Each element of this array corresponds to the player at the same array index in the Engine.GamePlayers array.
 */
var(Interaction)	transient	array<UIFocusPropagationData>	FocusPropagation;

/**
 * Indicates that this widget should never become the focused control; does not prevent children of this widget from receiving focus (that must be done
 * by calling SetPrivateBehavior(PRIVATE_NotFocusable,true))
 */
var(Interaction)	private{private}	const	bool			bNeverFocus;

/**
 * Controls whether this widget displays a hint when it's the focused control.
 */
var(Interaction)								bool			bSupportsFocusHint;

/** indicates that this control should always have the first chance to process input received by the owning scene */
var					private	const				bool			bOverrideInputOrder;

/** This is the stack of animations currently being applied to this widget */
var					transient	array<UIAnimSequence>			AnimStack;

/** indicates whether this widget (or any of its children) are currently animating */
var	transient		protected					bool			bAnimating;

/** counter used to track how many animations within this widget (including children) are currently active. */
var	transient		protected					int				AnimationCount;

/** globally modifies the rate for all UI animations - for debugging */
var(ZDebug) 		globalconfig				float			AnimationDebugMultiplier;

/** When true the animation does not tick */
var transient		protected{protected}		bool			bAnimationPaused;

/** the opacity of the object */
var(Appearance)									float			Opacity;

/**
 * Indicates whether this widget uses 3D primitives.
 */
var	const				bool						bSupports3DPrimitives;

// ===============================================
// Components
// ===============================================
var	 					UIComp_Event				EventProvider;

// ===============================================
// Sounds
// ===============================================
/** this sound is played when this widget becomes the focused control */
var(Sound)				name						FocusedCue;

/** this sound is played when this widget becomes the active control */
var(Sound)				name						MouseEnterCue;

/** this sound is played when this widget has a navigate up event */
var(Sound)				name						NavigateUpCue;

/** this sound is played when this widget has a navigate down event */
var(Sound)				name						NavigateDownCue;

/** this sound is played when this widget has a navigate left event */
var(Sound)				name						NavigateLeftCue;

/** this sound is played when this widget has a navigate right event */
var(Sound)				name						NavigateRightCue;

/**
 * the list of functions to call when animation tracks and keyframes are completed.
 */
var(Animation)	editconst	transient	private		array<delegate<OnUIAnim_KeyFrameCompleted> >	KeyFrameCompletedDelegates;
var(Animation)	editconst	transient	private		array<delegate<OnUIAnim_TrackCompleted> >		TrackCompletedDelegates;

cpptext
{
	/**
	 * Returns the UIScreenObject that owns this widget.
	 */
	virtual UUIScreenObject* GetParent() const { return NULL; }

	/**
	 * Returns the UIObject that owns this widget, or NULL if this screen object
	 * doesn't have an owner (such as UIScenes)
	 */
	virtual UUIObject* GetOwner() const PURE_VIRTUAL(UUIScreenObject::GetOwner,return NULL;);

	/**
	 * Get the scene that owns this widget.  If this is a UIScene, returns a pointer to itself.
	 */
	virtual UUIScene* GetScene() PURE_VIRTUAL(UUIScreenObject::GetScene,return NULL;);

	/**
	 * Get the scene that owns this widget.  If this is a UIScene, returns a pointer to itself.
	 */
	virtual const UUIScene* GetScene() const PURE_VIRTUAL(const UUIScreenObject::GetScene,return NULL;);

	/**
	 * returns the unique tag associated with this screen object
	 */
	virtual FName GetTag() const PURE_VIRTUAL(UUIScreenObject::GetTag,return NAME_None;);

	/**
	 * Returns a string representation of this widget's hierarchy.
	 * i.e. SomeScene.SomeContainer.SomeWidget
	 */
	virtual FString GetWidgetPathName() const PURE_VIRTUAL(UUIScreenObject::GetWidgetPathName,return TEXT(""););

	/**
	 * Returns the default parent to use when placing widgets using the UI editor.  This widget is used when placing
	 * widgets by dragging their outline using the mouse, for example.
	 *
	 * @return	a pointer to the widget that will contain newly placed widgets when a specific parent widget has not been
	 *			selected by the user.
	 */
	virtual UUIScreenObject* GetEditorDefaultParentWidget();

	/**
	 * Returns whether this screen object has been initialized
	 */
	UBOOL IsInitialized() const		{ return bInitialized; }

	/**
	 * Accessor for retrieving the PostProcessSettings struct used for interpolating PP effects.
	 *
	 * @param	CurrentSettings		receives the current PostProcessSettings that should be used for PP effect animation.
	 *
	 * @return	TRUE if this widget supports animation of post-processing and filled in the value of CurrentSettings.
	 */
	virtual UBOOL AnimGetCurrentPPSettings( FPostProcessSettings*& CurrentSettings ) PURE_VIRTUAL(UUIScreenObject::AnimGetCurrentPPSettings,return FALSE;);

	/**
	 * Determines whether to change the Outer of this widget if the widget's Owner doesn't match it's Outer.
	 */
	virtual UBOOL RequiresParentForOuter() const { return TRUE; }

	/**
	 * Determines whether this scene processes axis input events.
	 *
	 * @param	bProcessAxisInput	receives the flags for whether axis input is needed for each player.
	 * @param	NavAliases			list of input aliases that correspond to axis navigation
	 * @param	AxisInputKeys		list of input keys that are associated with axis input.
	 *
	 * @return	TRUE if axis input is supported by all active players (can stop checking children, for example)
	 */
	virtual UBOOL CheckAxisInputSupport( UBOOL* bProcessAxisInput[UCONST_MAX_SUPPORTED_GAMEPADS], const TArray<FName>& NavAliases, const TArray<FName>& AxisInputKeys ) const;

	/**
	 * Tell the scene that it needs to be udpated
	 *
	 * @param	bDockingStackChanged	if TRUE, the scene will rebuild its DockingStack at the beginning
	 *									the next frame
	 * @param	bPositionsChanged		if TRUE, the scene will update the positions for all its widgets
	 *									at the beginning of the next frame
	 * @param	bNavLinksOutdated		if TRUE, the scene will update the navigation links for all widgets
	 *									at the beginning of the next frame
	 * @param	bWidgetStylesChanged			if TRUE, the scene will refresh the widgets reapplying their current styles
	 */
	virtual void RequestSceneUpdate( UBOOL bDockingStackChanged, UBOOL bPositionsChanged, UBOOL bNavLinksOutdated=FALSE, UBOOL bWidgetStylesChanged=FALSE ) {}

	/**
	 * Tells the scene that it should call RefreshFormatting on the next tick.
	 */
	virtual void RequestFormattingUpdate() PURE_VIRTUAL(UUIScreenObject::RequestFormattingUpdate,);

	/**
	 * Flag the scene to recalculate its PlayerInputMask at the beginning of the next tick.
	 */
	virtual void RequestSceneInputMaskUpdate() PURE_VIRTUAL(UUIScreenObject::RequestSceneInputMaskUpdate,);

	/**
	 * Notifies the owning UIScene that the primitive usage in this scene has changed and sets flags in the scene to indicate that
	 * 3D primitives have been added or removed.
	 *
	 * @param	bReinitializePrimitives		specify TRUE to have the scene detach all primitives and reinitialize the primitives for
	 *										the widgets which have them.  Normally TRUE if we have ADDED a new child to the scene which
	 *										supports primitives.
	 * @param	bReviewPrimitiveUsage		specify TRUE to have the scene re-evaluate whether its bUsesPrimitives flag should be set.  Normally
	 *										TRUE if a child which supports primitives has been REMOVED.
	 */
	virtual void RequestPrimitiveReview( UBOOL bReinitializePrimitives, UBOOL bReviewPrimitiveUsage ) PURE_VIRTUAL(UUIScreenObject::RequestPrimitiveReview,);

	/**
	 * Called when this widget is created.
	 */
	virtual void Created( UUIScreenObject* Creator );

	/**
	 * Called immediately after a child has been added to this screen object.
	 *
	 * @param	WidgetOwner		the screen object that the NewChild was added as a child for
	 * @param	NewChild		the widget that was added
	 */
	virtual void NotifyAddedChild( UUIScreenObject* WidgetOwner, UUIObject* NewChild );

	/**
	 * Called immediately after a child has been removed from this screen object.
	 *
	 * @param	WidgetOwner		the screen object that the widget was removed from.
	 * @param	OldChild		the widget that was removed
	 * @param	ExclusionSet	used to indicate that multiple widgets are being removed in one batch; useful for preventing references
	 *							between the widgets being removed from being severed.
	 */
	virtual void NotifyRemovedChild( UUIScreenObject* WidgetOwner, UUIObject* OldChild, TArray<UUIObject*>* ExclusionSet=NULL );

	/**
	 * Called when the currently active skin has been changed.  Reapplies this widget's style and propagates
	 * the notification to all children.
	 */
	virtual void NotifyActiveSkinChanged();

	/**
	 * Generates a array of UI Action keys that this widget supports.
	 *
	 * @param	out_KeyNames	Storage for the list of supported keynames.
	 */
	virtual void GetSupportedUIActionKeyNames(TArray<FName> &out_KeyNames );

	/**
	 * Iterates through the DefaultStates array checking that InactiveStates contains at least one instance of each
	 * DefaultState.  If no instances are found, one is created and added to the InactiveStates array.
	 */
	virtual void CreateDefaultStates();

	/**
	 * Checks that this screen object has an InitialState and contains a UIState_Enabled (or child class) in its
	 * InactiveStates array.  If any of the required states are missing, creates them.
	 */
	virtual void ValidateRequiredStates();

	/**
	 * Returns only those states [from the InactiveStates array] which were instanced from an entry in the DefaultStates array.
	 */
	void GetInstancedStates( TMap<UClass*,UUIState*>& out_Instances );

	/**
	 * Creates a new UIState instance based on the specified template and adds the new state to this widget's list of
	 * InactiveStates.
	 *
	 * @param	StateTemplate	the state to use as the template for the new state
	 *
	 * @return	the state instance that was created
	 */
	class UUIState* AddSupportedState( UUIState* StateTemplate );

	/**
	 * Activates the configured initial state for this widget.
	 *
	 * @param	PlayerIndex			the index [into the Engine.GamePlayers array] for the player to activate this initial state for
	 */
	void ActivateInitialState( INT PlayerIndex );

	/**
	 * Determine whether there are any active states of the specified class
	 *
	 * @param	StateClass	the class to search for
	 * @param	PlayerIndex	the index [into the Engine.GamePlayers array] for the player that generated this call
	 * @param	StateIndex	if specified, will be set to the index of the last state in the list of active states that
	 *						has the class specified
	 *
	 * @return	TRUE if there is at least one active state of the class specified
	 */
	UBOOL HasActiveStateOfClass( UClass* StateClass, INT PlayerIndex, INT* StateIndex=NULL ) const;

	/**
	 * Alternate version of ActivateState that activates the first state in the InactiveStates array with the specified class
	 * that isn't already in the StateStack
	 */
	UBOOL ActivateStateByClass(class UClass* StateToActivate,INT PlayerIndex,class UUIState** StateThatWasAdded=NULL);

	/**
	 * Iterates up the parent chain, calling the NotifyActiveStateChanged delegate for any parent widgets that are handling that delegate.
	 *
	 * @param	PlayerIndex				the index [into the GamePlayers array] for the player that activated this state.
	 * @param	NewlyActiveState		the state that is now active
	 * @param	PreviouslyActiveState	the state that used the be the widget's currently active state.
	 */
	void PropagateStateChangeNotification(INT PlayerIndex, class UUIState* NewlyActiveState, class UUIState* PreviouslyActiveState);

	/**
	 * Returns TRUE if this widget has a UIState_Enabled object in its StateStack and the state has been activated for the specified PlayerIndex.
	 *
	 * @param	PlayerIndex			the index of the player to check
	 * @param	StateIndex			if specified, will be set to the index of the last state in the list of active states that
	 *								has the class specified
	 * @param	bCheckOwnerChain	by default, the owner chain is checked as well; specify FALSE to override this behavior.
	 */
	UBOOL IsEnabled( INT PlayerIndex, INT* StateIndex=NULL, UBOOL bCheckOwnerChain=TRUE ) const;

	/**
	 * Returns TRUE if this widget has a UIState_Disabled object in its StateStack and the state has been activated for the specified PlayerIndex.
	 *
	 * @param	PlayerIndex			the index of the player to check
	 * @param	StateIndex			if specified, will be set to the index of the last state in the list of active states that
	 *								has the class specified
	 * @param	bCheckOwnerChain	by default, the owner chain is checked as well; specify FALSE to override this behavior.
	 */
	UBOOL IsDisabled( INT PlayerIndex, INT* StateIndex=NULL, UBOOL bCheckOwnerChain=TRUE ) const;

	/**
	 * Returns TRUE if this widget has a UIState_Focused object in its StateStack and the state has been activated for the specified PlayerIndex.
	 *
	 * @param	PlayerIndex			the index of the player to check
	 * @param	StateIndex			if specified, will be set to the index of the last state in the list of active states that
	 *								has the class specified
	 */
	UBOOL IsFocused( INT PlayerIndex, INT* StateIndex=NULL ) const;

	/**
	 * Returns TRUE if this widget has a UIState_Active object in its StateStack and the state has been activated for the specified PlayerIndex.
	 *
	 * @param	PlayerIndex			the index of the player to check
	 * @param	StateIndex			if specified, will be set to the index of the last state in the list of active states that
	 *								has the class specified
	 */
	UBOOL IsActive( INT PlayerIndex, INT* StateIndex=NULL ) const;

	/**
	 * Returns TRUE if this widget has a UIState_Pressed object in its StateStack and the state has been activated for the specified PlayerIndex.
	 *
	 * @param	PlayerIndex			the index of the player to check
	 * @param	StateIndex			if specified, will be set to the index of the last state in the list of active states that
	 *								has the class specified
	 */
	UBOOL IsPressed( INT PlayerIndex, INT* StateIndex=NULL ) const;

	/**
	 * Determines whether this widget is contained a scene that has been instanced at runtime.
	 *
	 * @retun	FALSE if this widget is contained in a scene from a content package; TRUE if this widget is contained within a scene
	 *			that has been created from scratch or opened at runtime.
	 */
	UBOOL IsRuntimeInstance() const
	{
		return GetOutermost() == GetTransientPackage();
	}

	/**
	 * Gets the value of this widget's PlayerInputMask.
	 *
	 * @param	bInheritedMaskOnly		specify TRUE to return only the mask that was set by this widget's owner scene.
	 * @param	bOverrideMaskOnly		specify TRUE to return only the mask that was set manually for this widget, in which case whatever
	 *									value was passed for bInheritedMaskOnly is ignored.
	 *
	 * @return	a bitmask representing the indices of the players that this widget accepts input from; If both bInheritedMaskOnly
	 *			and bOverrideMaskOnly are FALSE, returns the override mask if there is one, otherwise the inherited mask.
	 */
	virtual BYTE GetInputMask( UBOOL bInheritedMaskOnly=FALSE, UBOOL bOverrideMaskOnly=FALSE ) const PURE_VIRTUAL(UUIScreenObject::GetInputMask,return (BYTE)INDEX_NONE;)

	/**
	 * Changes the player input mask for this control, which controls which players this control will accept input from.
	 *
	 * @param	NewInputMask	the new mask that should be assigned to this control
	 * @param	bRecurse		if TRUE, calls SetInputMask on all child controls as well.
	 * @param	bForcedOverride	indicates that the specified input mask should override any input mask inherited from the owning scene
	 */
	virtual void SetInputMask( BYTE NewInputMask, UBOOL bRecurse=TRUE, UBOOL bForcedOverride=FALSE );

	/**
	 * Changes the specified preview state on the screen object's StateStack.
	 *
	 * @param	StateToActivate		the new preview state
	 *
	 * @return	TRUE if the state was successfully changed to the new preview state.  FALSE if couldn't change
	 *			to the new state or the specified state already exists in the screen object's list of active states
	 */
	virtual UBOOL ActivatePreviewState(UUIState *StateToActivate);

	/**
	 * Alternate version of DeactivateState that deactivates the last state in the StateStack array that has the specified class.
	 */
	UBOOL DeactivateStateByClass(class UClass* StateToRemove,INT PlayerIndex,class UUIState** StateThatWasRemoved=NULL);

	/**
	 * Activate the event of the specified class.
	 *
	 * @param	PlayerIndex				the index of the player that activated this event
	 * @param	EventClassToActivate	specifies the event class that should be activated.  If there is more than one instance
	 *									of a particular event class in this screen object's list of events, all instances will
	 *									be activated in the order in which they occur in the event provider's list.
	 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents
	 * @param	bActivateImmediately	TRUE to activate the event immediately, causing its output operations to also be processed immediately.
	 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
	 *									will be activated
	 * @param	out_ActivatedEvents		filled with the event instances that were activated.
	 */
	void ActivateEventByClass(INT PlayerIndex,class UClass* EventClassToActivate,class UObject* InEventActivator=NULL,UBOOL bActivateImmediately=0,const TArray<INT>* IndicesToActivate=NULL,TArray<class UUIEvent*>* out_ActivatedEvents=NULL);

private:
	/**
	 * Wrapper for ActivateEventByClass; called when an event is activated by one of our children and is being propagated upwards.  In cases where
	 * there are multiple child classes of the specified class, only those event classes which have TRUE for the value of bPropagateEvents are
	 * activated.
	 *
	 * @param	PlayerIndex				the index of the player that activated this event
	 * @param	EventClassToActivate	specifies the event class that should be activated.  If there is more than one instance
	 *									of a particular event class in this screen object's list of events, all instances will
	 *									be activated in the order in which they occur in the event provider's list.
	 * @param	InEventActivator		the object that the event was originally generated for.
	 * @param	bActivateImmediately	TRUE to activate the event immediately, causing its output operations to also be processed immediately.
	 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
	 *									will be activated
	 * @param	out_ActivatedEvents		filled with the event instances that were activated.
	 */
	void ChildEventActivated( INT PlayerIndex,class UClass* EventClassToActivate,class UObject* InEventActivator,UBOOL bActivateImmediately=0,const TArray<INT>* IndicesToActivate=NULL,TArray<class UUIEvent*>* out_ActivatedEvents=NULL );

public:
	// Wrappers for primary menu states
	/**
	 * @param	bIncludeParents		specify TRUE to check the visibility of parent widgets as well
	 *
	 * @return	TRUE if this widget is visible.
	 */
	UBOOL IsVisible( UBOOL bIncludeParents=FALSE ) const;

	/**
	 * @param	bIncludeParents		specify TRUE to check the visibility of parent widgets as well
	 *
	 * @return	TRUE if this widget is hidden.
	 */
	UBOOL IsHidden( UBOOL bIncludeParents=FALSE ) const;

	/**
	 * Accessor for private variable.
	 *
	 * @return	the current value of ZDepth for this widget.
	 */
	FLOAT GetZDepth() const
	{
		return ZDepth;
	}

	/**
	 * @return Returns TRUE if this widget can be resized, repositioned, or rotated, FALSE otherwise.
	 */
	virtual UBOOL IsTransformable() const
	{
		return TRUE;
	}

	/**
	 * Returns the number of faces this widget has resolved.
	 */
	virtual INT GetNumResolvedFaces() const PURE_VIRTUAL(UUIScreenObject::GetNumResolvedFaces,return 0;);

	/**
	 * Returns whether the specified face has been resolved
	 *
	 * @param	Face	the face to check
	 */
	virtual UBOOL HasPositionBeenResolved( EUIWidgetFace Face ) const PURE_VIRTUAL(UUIScreenObject::HasPositionBeenResolved,return FALSE;);

	/**
	 * Calculates the closest sibling for each child, per face, and assigns that widget as the navigation target for that face.
	 *
	 * @return	TRUE if any navigation links were created.
	 */
	virtual UBOOL GenerateAutoNavigationLinks();

	/**
	 * Calculates the ideal tab index for all children of this widget and assigns the tab index to the child widget, unless
	 * that widget's tab index has been specifically set by the designer.
	 */
	virtual void GenerateAutomaticTabIndexes();

	/**
	 * Assigns values to the links which are used for navigating through this widget using the keyboard.  Sets the first and
	 * last focus targets for this widget as well as the next/prev focus targets for all children of this widget.
	 *
	 * @return	TRUE if any sibling navigation links were created.
	 */
	virtual UBOOL RebuildKeyboardNavigationLinks();

	/**
	 * Called when a property is modified that could potentially affect the widget's position onscreen.
	 */
	virtual void RefreshPosition();

	/**
	 * Called to globally update the formatting of all UIStrings.
	 */
	virtual void RefreshFormatting( UBOOL bRequestSceneUpdate=TRUE ) {}

	/**
	 * Called when the scene receives a notification that the viewport has been resized.  Propagated down to all children.
	 *
	 * @param	OldViewportSize		the previous size of the viewport
	 * @param	NewViewportSize		the new size of the viewport
	 */
	virtual void NotifyResolutionChanged( const FVector2D& OldViewportSize, const FVector2D& NewViewportSize );

	/**
	 * Changes this widget's position to the specified value.
	 *
	 * @param	LeftFace		the value (in pixels or percentage) to set the left face to
	 * @param	TopFace			the value (in pixels or percentage) to set the top face to
	 * @param	RightFace		the value (in pixels or percentage) to set the right face to
	 * @param	BottomFace		the value (in pixels or percentage) to set the bottom face to
	 * @param	InputType		indicates the format of the input value.  All values will be evaluated as this type.
	 *								EVALPOS_None:
	 *									NewValue will be considered to be in whichever format is configured as the ScaleType for the specified face
	 *								EVALPOS_PercentageOwner:
	 *								EVALPOS_PercentageScene:
	 *								EVALPOS_PercentageViewport:
	 *									Indicates that NewValue is a value between 0.0 and 1.0, which represents the percentage of the corresponding
	 *									base's actual size.
	 *								EVALPOS_PixelOwner
	 *								EVALPOS_PixelScene
	 *								EVALPOS_PixelViewport
	 *									Indicates that NewValue is an actual pixel value, relative to the corresponding base.
	 * @param	bIncludesViewportOrigin
	 *							TRUE indicates that the value is relative to the 0,0 on the screen (or absolute position); FALSE to indicate
	 *							the value is relative to the viewport's origin.
	 * @param	bClampValues	if TRUE, clamps the values of RightFace and BottomFace so that they cannot be less than the values for LeftFace and TopFace
	 */
	virtual void SetPosition( const FLOAT LeftFace, const FLOAT TopFace, const FLOAT RightFace, const FLOAT BottomFace, EPositionEvalType InputType=EVALPOS_PixelViewport, UBOOL bIncludesViewportOrigin=FALSE, UBOOL bClampValues=FALSE );

	/**
	 * @param Point	Point to check against the renderbounds of the object.
	 * @return Whether or not this screen object contains the point passed in within its renderbounds.
	 */
	virtual UBOOL ContainsPoint(const FVector2D& Point) const;

	/**
	 * Marks the position for the specified face as out of sync with the corresponding RenderBounds.
	 *
	 * @param	Face	the face to modify; value must be one of the EUIWidgetFace values.
	 */
	void InvalidatePosition( BYTE Face );

	/**
	 * Marks the position for all faces as out of sync with the RenderBounds values
	 *
	 * @param	bIgnoreDockedFaces	indicates whether faces that are docked should be skipped
	 */
	void InvalidateAllPositions( UBOOL bIgnoreDockedFaces=TRUE );

protected:
	/**
	 * Marks the Position for any faces dependent on the specified face, in this widget or its children,
	 * as out of sync with the corresponding RenderBounds.
	 *
	 * @param	Face	the face to modify; value must be one of the EUIWidgetFace values.
	 */
	virtual void InvalidatePositionDependencies( BYTE Face ) PURE_VIRTUAL(UUIScreenObject::InvalidatePositionDependencies,);

public:
	/**
	 * Plays the sound cue associated with the specified name;  simple wrapper method for calling UIInteraction::PlayUISound
	 *
	 * @param	SoundCueName	the name of the UISoundCue to play; should corresond to one of the values of the UISoundCueNames array.
	 * @param	PlayerIndex		allows the caller to indicate which player controller should be used to play the sound cue.  For the most
	 *							part, all sounds can be played by the first player, regardless of who generated the play sound event.
	 *
	 * @return	TRUE if the sound cue specified was found in the currently active skin, even if there was no actual USoundCue associated
	 *			with that UISoundCue.
	 */
	static UBOOL PlayUISound( FName SoundCueName, INT PlayerIndex=0 );

	/**
	 * Routing event for the input we received.  This function first sees if there are any kismet actions that are bound to the
	 * input.  If not, it passes the input to the widget's default input event handler.
	 *
	 * Only called if this widget is in the owning scene's InputSubscribers map for the corresponding key.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	UBOOL HandleInputKeyEvent( const FInputEventParameters& EventParms );

	/**
	 * Remove an existing child widget from this widget's children
	 *
	 * @param	ExistingChild	the widget to remove
	 * @param	ExclusionSet	used to indicate that multiple widgets are being removed in one batch; useful for preventing references
	 *							between the widgets being removed from being severed.
	 *
	 * @return	TRUE if the child was successfully removed from the list, or if the child was not contained by this widget
	 *			FALSE if the child could not be removed from this widget's child list.
	 */
	UBOOL RemoveChild(class UUIObject* ExistingChild, TArray<class UUIObject*>* ExclusionSet=NULL );

	/**
	 * DEPRECATED.  Use PreInitialSceneUpdate instead.
	 */
	virtual void PreRenderCallback();

	/**
	 * Called at the beginning of the first scene update and propagated to all widgets in the scene.  Provides classes with
	 * an opportunity to initialize anything that couldn't be setup earlier due to lack of a viewport.
	 *
	 * Calling functions such as GetViewportSize() or GetPosition() aren't guaranteed to work until this function has been called.
	 */
	virtual void PreInitialSceneUpdate();

	/**
	 * Called at the end of the first scene update and propagated to all widgets in the scene.  Provides classes with
	 * an opportunity to intialize anything that was dependent on child widgets, etc.
	 */
	virtual void PostInitialSceneUpdate();

	/**
	 * Attach and initialize any 3D primitives for this widget and its children.
	 *
	 * @param	CanvasScene		the scene to use for attaching 3D primitives
	 */
	virtual void InitializePrimitives( class FCanvasScene* CanvasScene );

	/**
	 * Routes rendering calls to children of this screen object.
	 *
	 * @param	Canvas	the canvas to use for rendering
	 * @param	UIPostProcessGroup	Group determines current pp pass that is being rendered
	 */
	virtual void Render_Children( FCanvas* Canvas, EUIPostProcessGroup UIPostProcessGroup );

	/**
	 * Routes the call to UpdateWidgetPrimitives to all children of this widget.
	 *
	 * @param	CanvasScene		the scene to use for attaching any 3D primitives
	 */
	virtual void UpdateChildPrimitives( FCanvasScene* Canvas );

	/**
	 * Gets a list of all children contained in this screen object.
	 *
	 * @param	bRecurse		if FALSE, result will only contain widgets from this screen object's Children array
	 *							if TRUE, result will contain all children of this screen object, including their children.
	 * @param	ExclusionSet	if specified, any widgets contained in this array will not be added to the output array.
	 *
	 * @return	an array of widgets contained by this screen object.
	 */
	TArray<class UUIObject*> GetChildren( UBOOL bRecurse=FALSE, TArray<class UUIObject*>* ExclusionSet=NULL ) const;

	/**
	 * Gets a list of all children contained in this screen object.
	 *
	 * @param	out_Children	receives the list of child widgets.
	 * @param	bRecurse		if FALSE, result will only contain widgets from this screen object's Children array
	 *							if TRUE, result will contain all children of this screen object, including their children.
	 * @param	ExclusionSet	if specified, any widgets contained in this array will not be added to the output array.
	 *
	 * @return	an array of widgets contained by this screen object.
	 */
	void GetChildren( TArray<class UUIObject*>& out_Children, UBOOL bRecurse=FALSE, TArray<class UUIObject*>* ExclusionSet=NULL ) const;

	/**
	 * Returns all objects which are docked to this one.
	 *
	 * @param	DockClients					If specified, receives the list of objects docked to this one.  Do not pass a value if you only
	 *										wish to know the number of objects docked to this one.
	 * @param	bDirectDockClientsOnly		by default, only returns widgets that are docked to this widget directly;  Specify FALSE to also
	 *										include widgets which are docked to this widget indirectly (i.e. through more than one docking
	 *										link.  Caution: this can cause a performance hit if there are a large number of widgets in the scene.
	 * @param	TargetFace					if specified, returns only those widgets that are docked to the specified face on this widget.
	 * @param	SourceFace					if specified, returns only those widgets that have the specified face docked to this widget.
	 *
	 * @return	the number of widgets docked to this one.
	 */
	INT GetDockClients( TArray<UUIObject*>* DockClients=NULL, UBOOL bDirectDockClientsOnly=TRUE, /*EUIWidgetFace*/BYTE TargetFace=UIFACE_MAX, /*EUIWidgetFace*/BYTE SourceFace=UIFACE_MAX ) const;

	/**
	 * Generates a list of widgets that have the bEnableSceneUpdateNotifications flag set.
	 */
	void GetSceneUpdateNotificationSubscribers( TArray<UUIObject*>& out_Subscribers ) const;

	/**
	 * Wrapper for AttachFocusHint which first calls into script to allow script the chance to override native handling of the focus hint.
	 */
	void ActivateFocusHint();

	/**
	 * Applies animations to this widget's members, and decrements the animation sequence's counter.
	 *
	 * @param	DeltaTime		the time (in seconds) since the last frame began
	 * @param	AnimSeqRef		the animation sequence to update.
	 *
	 * @return	TRUE if the animation is complete.
	 */
	UBOOL UpdateAnimation( FLOAT DeltaTime, FUIAnimSequence& AnimSeqRef );

protected:
	/**
	 * Activates the focus hint widget for this object; child classes which override this method should set the position of the focus hint
	 * as well as any other properties necessary for correctly displaying the focus hint for this widget.
	 *
	 * @param	FocusHintObject		reference to the widget that supplies the focus hint.
	 *
	 * @return	TRUE if the focus hint object was initialized / repositioned by this widget; FALSE if this widget doesn't support focus hints.
	 */
	virtual UBOOL AttachFocusHint( class UUIObject* FocusHintObject ) { return FALSE; }

	/**
	 * Wrapper for rendering a single child of this widget.
	 *
	 * @param	Canvas	the canvas to use for rendering
	 * @param	Child	the child to render
	 * @param	UIPostProcessGroup	Group determines current pp pass that is being rendered
	 *
	 * @note: this method is non-virtual for speed.  If you need to override this method, feel free to make it virtual.
	 */
	void Render_Child( FCanvas* Canvas, class UUIObject* Child, EUIPostProcessGroup UIPostProcessGroup );

	/**
	 * Sees if there are any kismet actions that are responding to the input we received.  If so, execute the action
	 * that is currently bound to the event we just received.
	 *
	 * Only called if this widget is in the owning scene's InputSubscribers map for the corresponding key.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessActions( const FInputEventParameters& EventParms );

	/**
	 * Determines whether this widget should process the specified input event + state.  If the widget is configured
	 * to respond to this combination of input key/state, any actions associated with this input event are activated.
	 *
	 * Only called if this widget is in the owning scene's InputSubscribers map for the corresponding key.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputKey( const FSubscribedInputEventParameters& EventParms );

	/**
	 * Determines whether this widget should process the specified axis input event (mouse/joystick movement).
	 * If the widget is configured to respond to this axis input event, any actions associated with
	 * this input event are activated.
	 *
	 * Only called if this widget is in the owning scene's InputSubscribers map for the corresponding key.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the axis movement, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputAxis( const FSubscribedInputEventParameters& EventParms );

public:
	/**
	 * Activates any actions assigned to the specified character in this widget's input processor.
	 *
	 * Only called if this widget is in the owning scene's InputSubscriptions map for the KEY_Unicode key.
	 *
	 * @param	PlayerIndex		index [into the Engine.GamePlayers array] of the player that generated this event
	 * @param	Character		the character that was received
	 *
	 * @return	TRUE to consume the character, false to pass it on.
	 */
	virtual UBOOL ProcessInputChar( INT PlayerIndex, TCHAR Character );

	/**
	 * Converts an input key name (e.g. KEY_Enter) to a UI action key name (UIKEY_Clicked)
	 *
	 * @param	EventParms		the parameters for the input event
	 * @param	out_UIKeyName	will be set to the UI action key name that is mapped to the specified input key name.
	 * @param	WidgetClass		allows callers to override the class used for translating the key; if not specified, uses the current class.
	 *
	 * @return	TRUE if InputKeyName was successfully converted into a UI action key name.
	 */
	UBOOL TranslateKey( const FInputEventParameters& EventParms, FName& out_UIKeyName, UClass* WidgetClass=NULL );

	/**
	 * Generates an array of indexes, which correspond to indexes into the Engine.GamePlayers array for the players that
	 * this control accepts input from.
	 */
	void GetInputMaskPlayerIndexes( TArray<INT>& out_Indexes ) const;

	/**
	 * Generates a list of any children of this widget which are of a class that has been deprecated, recursively.
	 */
	void FindDeprecatedWidgets( TArray<UUIScreenObject*>& out_DeprecatedWidgets );

protected:
	/**
	 * Activates the UIState_Focused menu state and updates the pertinent members of FocusControls.
	 *
	 * @param	FocusedChild	the child of this widget that should become the "focused" control for this widget.
	 *							A value of NULL indicates that there is no focused child.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 */
	virtual UBOOL GainFocus( UUIObject* FocusedChild, INT PlayerIndex );

	/**
	 * Deactivates the UIState_Focused menu state and updates the pertinent members of FocusControls.
	 *
	 * @param	FocusedChild	the child of this widget that is currently "focused" control for this widget.
	 *							A value of NULL indicates that there is no focused child.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 */
	virtual UBOOL LoseFocus( UUIObject* FocusedChild, INT PlayerIndex );

public:
	/* === UObject interface === */
	/**
	 * Called after this object has been de-serialized from disk.  This version removes any NULL entries from the Children array.
	 */
	virtual void PostLoad();

	/**
	 * Builds a list of objects which have this object in their archetype chain.
	 *
	 * All archetype propagation for UIScreenObjects is handled by the UIPrefab/UIPrefabInstance code, so this version just
	 * skips the iteration.
	 *
	 * @param	Instances	receives the list of objects which have this one in their archetype chain
	 */
	virtual void GetArchetypeInstances( TArray<UObject*>& Instances );

	/**
	 * Serializes all objects which have this object as their archetype into GMemoryArchive, then recursively calls this function
	 * on each of those objects until the full list has been processed.
	 * Called when a property value is about to be modified in an archetype object.
	 *
	 * Since archetype propagation for UIScreenObjects is handled by the UIPrefab code, this version simply routes the call
	 * to the owning UIPrefab so that it can handle the propagation at the appropriate time.
	 *
	 * @param	AffectedObjects		the array of objects which have this object in their ObjectArchetype chain and will be affected by the change.
	 *								Objects which have this object as their direct ObjectArchetype are removed from the list once they're processed.
	 */
	virtual void SaveInstancesIntoPropagationArchive( TArray<UObject*>& AffectedObjects );

	/**
	 * De-serializes all objects which have this object as their archetype from the GMemoryArchive, then recursively calls this function
	 * on each of those objects until the full list has been processed.
	 *
	 * Since archetype propagation for UIScreenObjects is handled by the UIPrefab code, this version simply routes the call
	 * to the owning UIPrefab so that it can handle the propagation at the appropriate time.
	 *
	 * @param	AffectedObjects		the array of objects which have this object in their ObjectArchetype chain and will be affected by the change.
	 *								Objects which have this object as their direct ObjectArchetype are removed from the list once they're processed.
	 */
	virtual void LoadInstancesFromPropagationArchive( TArray<UObject*>& AffectedObjects );

	/**
	 * Called just after a property in this object's archetype is modified, immediately after this object has been de-serialized
	 * from the archetype propagation archive.
	 *
	 * Allows objects to perform reinitialization specific to being de-serialized from an FArchetypePropagationArc and
	 * reinitialized against an archetype. Only called for instances of archetypes, where the archetype has the RF_ArchetypeObject flag.
	 */
	virtual void PostSerializeFromPropagationArchive();

	/**
	 * Called when a property value has been changed in the editor.
	 */
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/**
	 * Called when a property value has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);

	/**
	 * Called after importing property values for this object (paste, duplicate or .t3d import)
	 * Allow the object to perform any cleanup for properties which shouldn't be duplicated or
	 * are unsupported by the script serialization
	 */
	virtual void PostEditImport();

	/**
	 * Determines whether this object is contained within a UIPrefab.
	 *
	 * @param	OwnerPrefab		if specified, receives a pointer to the owning prefab.
	 *
	 * @return	TRUE if this object is contained within a UIPrefab; FALSE if this object IS a UIPrefab or is not
	 *			contained within a UIPrefab.
	 */
	virtual UBOOL IsAPrefabArchetype( UObject** OwnerPrefab=NULL ) const;

	/**
	 * @return	TRUE if the object is a UIPrefabInstance or a child of a UIPrefabInstance.
	 */
	virtual UBOOL IsInPrefabInstance() const;

	/**
	 * Determines whether this UIScreenObject is contained by a UIPrefab.
	 *
	 * @param	OwningPrefab	if specified, will be filled in with a reference to the UIPrefab which contains this
	 *							widget, if this widget is in fact contained in a UIPrefab
	 */
	UBOOL IsInUIPrefab( class UUIPrefab** OwningPrefab=NULL ) const;
}

/* == Delegates == */
/**
 * Called when the currently active skin has been changed.  Reapplies this widget's style and propagates
 * the notification to all children.
 *
 * @note: this delegate is only called if it is actually assigned to a member function.
 */
delegate NotifyActiveSkinChanged();

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
delegate bool OnRawInputKey( const out InputEventParameters EventParms );

/**
 * Provides a hook for unrealscript to respond to input using UI input aliases (i.e. Left, Tab, etc.)
 *
 * Called when an input axis event is received which this widget responds to and is in the correct state to process.  The
 * axis and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
delegate bool OnRawInputAxis( const out InputEventParameters EventParms );

/**
 * Provides a hook for unrealscript to respond to input using UI input aliases (i.e. Clicked, NextControl, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called AFTER kismet is given a chance to process the input, but BEFORE any native code processes the input.
 *
 * @param	EventParms	information about the input event, including the name of the input alias associated with the
 *						current key name (Tab, Space, etc.), event type (Pressed, Released, etc.) and modifier keys (Ctrl, Alt)
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
delegate bool OnProcessInputKey( const out SubscribedInputEventParameters EventParms );

/**
 * Provides a hook for unrealscript to respond to input using UI input aliases (i.e. Clicked, NextControl, etc.)
 *
 * Called when an input axis event is received which this widget responds to and is in the correct state to process.  The
 * axis and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called AFTER kismet is given a chance to process the input, but BEFORE any native code processes the input.
 *
 * @param	EventParms	information about the input event, including the name of the input alias associated with the
 *						current key name (Tab, Space, etc.), event type (Pressed, Released, etc.) and modifier keys (Ctrl, Alt)
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
delegate bool OnProcessInputAxis( const out SubscribedInputEventParameters EventParms );

/**
 * Called whenever this object changes its position
 */
delegate NotifyPositionChanged( UIScreenObject Sender );

/**
 * Called when the viewport rendering this widget's scene is resized.
 *
 * @param	OldViewportSize		the previous size of the viewport
 * @param	NewViewportSize		the new size of the viewport
 */
delegate NotifyResolutionChanged( const out Vector2D OldViewportsize, const out Vector2D NewViewportSize );

/**
 * Called when a new UIState becomes the widget's currently active state, after all activation logic has occurred.
 *
 * @param	Sender					the widget that changed states.
 * @param	PlayerIndex				the index [into the GamePlayers array] for the player that activated this state.
 * @param	NewlyActiveState		the state that is now active
 * @param	PreviouslyActiveState	the state that used the be the widget's currently active state.
 */
delegate transient NotifyActiveStateChanged( UIScreenObject Sender, int PlayerIndex, UIState NewlyActiveState, optional UIState PreviouslyActiveState );

/**
 * Allows others to receive a notification when this widget's visibility status changes.
 *
 * @param	SourceWidget	the widget that changed visibility status
 * @param	bIsVisible		whether this widget is now visible.
 */
delegate NotifyVisibilityChanged( UIScreenObject SourceWidget, bool bIsVisible );

/**
 * Called just before the scene perform its first update.  This is first time it's guaranteed to be safe to call functions
 * which require a valid viewport, such as SetPosition/GetPosition
 */
delegate transient OnInitialSceneUpdate();

/* == Natives == */

/**
 * Returns whether this screen object has been initialized.
 */
native final noexport function bool IsInitialized();

/**
 * Accessor for private variable
 *
 * @param	bIncludeParents		specify TRUE to check the visibility of parent widgets as well
 *
 * @returns true if this object is visible
 */
native final noexportheader function bool IsVisible( optional bool bIncludeParents );

/**
 * Accessor for private variable
 *
 * @param	bIncludeParents		specify TRUE to check the visibility of parent widgets as well
 *
 * @returns true if this object is hidden
 */
native final noexportheader function bool IsHidden( optional bool bIncludeParents );

/**
 * Accessor for private variable.
 *
 * @return	the current value of ZDepth for this widget.
 */
native final noexportheader function float GetZDepth() const;

/**
 * Accessor for changing the value of ZDepth.
 *
 * @param	NewZDepth				the ZDepth value to use.
 * @param	bPropagateToChildren	specify TRUE to set ZDepth on all child widgets to this value as well.
 */
native final function SetZDepth( float NewZDepth, optional bool bPropagateToChildren );

/**
 * Called when a new player has been added to the list of active players (i.e. split-screen join) after the scene
 * has been activated.
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was inserted
 * @param	AddedPlayer		the player that was added
 */
native final virtual function CreatePlayerData( int PlayerIndex, LocalPlayer AddedPlayer );

/**
 * Called when a player has been removed from the list of active players (i.e. split-screen players)
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was located
 * @param	RemovedPlayer	the player that was removed
 */
native final virtual function RemovePlayerData( int PlayerIndex, LocalPlayer RemovedPlayer );

/**
 * Sets up the focus, input, and any other arrays which contain data that tracked uniquely for each active player.
 * Ensures that the arrays responsible for managing focus chains are synched up with the Engine.GamePlayers array.
 */
native final virtual function InitializePlayerTracking();

/**
 * Retrieves a reference to a LocalPlayer.
 *
 * @param	PlayerIndex		if specified, returns the player at this index in the GamePlayers array.  Otherwise, returns
 *							the player associated with the owner scene.
 *
 * @return	the player that owns this scene or is located in the specified index of the GamePlayers array.
 */
native final function LocalPlayer GetPlayerOwner( optional int PlayerIndex=INDEX_NONE );

/**
 * Plays the sound cue associated with the specified name; simple wrapper for UIInteraction.PlayUISound
 *
 * @param	SoundCueName	the name of the UISoundCue to play; should corresond to one of the values of the UISoundCueNames array.
 * @param	PlayerIndex		allows the caller to indicate which player controller should be used to play the sound cue.  For the most
 *							part, all sounds can be played by the first player, regardless of who generated the play sound event.
 *
 * @return	TRUE if the sound cue specified was found in the currently active skin, even if there was no actual USoundCue associated
 *			with that UISoundCue.
 *
 * @note: noexport because the native version is a static method of UUIScreenObject
 */
native static final noexport function bool PlayUISound( name SoundCueName, optional int PlayerIndex=0 );

/**
 * Utility function for encapsulating constructing a widget
 *
 * @param	Owner			the container for the widget.  Cannot be none
 * @param	WidgetClass		the class of the widget to create.  Cannot be none.
 * @param	WidgetArchetype	the template to use for creating the widget
 * @param	WidgetName		the name to use for the new widget
 */
native final function UIObject CreateWidget( UIScreenObject Owner, class<UIObject> WidgetClass, optional Object WidgetArchetype, optional name WidgetName );

/**
 * Creates an instance of a UIPrefab and inserts it into this widget's Children array.
 *
 * @param	SourcePrefab		the prefab to instance
 * @param	PrefabInstanceName	the name to use for the new prefab instance
 * @param	PlacementLocation	the screen location [in pixels, relative to 0,0 in canvas space] to place the UIPrefabInstance.
 * @param	InsertIndex			the position to insert the widget.  If not specified, the widget is insert at the end of the list
 * @param	bRenameExisting		controls what happens if there is another widget in this widget's Children list with the same name as the
 *								new prefab (only relevant when specifying a value for PrefabInstanceName).
 *								if TRUE, renames the existing widget giving a unique transient name.
 *								if FALSE, does not add NewChild to the list and returns None.
 *
 * @return	a UIPrefabInstance created from the specified UIPrefab.
 */
native final function UIPrefabInstance InstanceUIPrefab( UIPrefab SourcePrefab, optional name PrefabInstanceName, optional const out Vector2D PlacementLocation, optional int InsertIndex=INDEX_NONE, optional bool bRenameExisting=true );

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
native final function virtual Initialize( UIScene inOwnerScene, optional UIObject InOwner );

/**
 * Insert a widget at the specified location
 *
 * @param	NewChild		the widget to insert
 * @param	InsertIndex		the position to insert the widget.  If not specified, the widget is insert at the end of
 *							the list
 * @param	bRenameExisting	controls what happens if there is another widget in this widget's Children list with the same tag as NewChild.
 *							if TRUE, renames the existing widget giving a unique transient name.
 *							if FALSE, does not add NewChild to the list and returns FALSE.
 *
 * @return	the position that that the child was inserted in, or INDEX_NONE if the widget was not inserted
 */
native function int InsertChild( UIObject NewChild, optional int InsertIndex = INDEX_NONE, optional bool bRenameExisting=true );

/**
 * Remove an existing child widget from this widget's children
 *
 * @param	ExistingChild	the widget to remove
 * @param	ExclusionSet	used to indicate that multiple widgets are being removed in one batch; useful for preventing references
 *							between the widgets being removed from being severed.
 *
 * @return	TRUE if the child was successfully removed from the list, or if the child was not contained by this widget
 *			FALSE if the child could not be removed from this widget's child list.
 *
 * @note: noexport because non-const optional arrays aren't exported correctly by the script compiler.
 */
native final noexport function bool RemoveChild( UIObject ExistingChild, optional array<UIObject> ExclusionSet );

/**
 * Removes a group of children from this widget's Children array.  All removal notifications are delayed until all children
 * have been removed; useful for removing a group of child widgets without destroying the references between them.
 *
 * @param	ChildrenToRemove	the list of child widgets to remove
 *
 * @return	a list of children that could not be removed; if the return array is emtpy, all children were successfully removed.
 */
native final function array<UIObject> RemoveChildren( array<UIObject> ChildrenToRemove );

/**
 * Wrapper for removing a child from this widget in order to add it as a child of another widget in this scene
 *
 * @param	CurrentChild	the widget that is being reparented
 * @param	NewParent		the widget that will be the new parent of the child
 * @param	InsertIndex		the position to insert the widget.  If not specified, the widget is insert at the end of
 *							the list
 *
 * @return	TRUE if reparented successfully.  FALSE if any input parameters were invalid, or if the new parent wasn't in the same scene.
 */
native final function bool ReparentChild( UIObject CurrentChild, UIScreenObject NewParent, optional int InsertIndex=INDEX_NONE );

/**
 * Wrapper for removing a collection of children from this widget in order to add to another widget's children in this scene
 *
 * @param	ChildrenToReparent	the widgets that are being reparented
 * @param	NewParent			the widget that will be the new parent of the child
 * @param	InsertIndex			the position to insert the widget.  If not specified, the widget is insert at the end of
 *								the list
 *
 * @return	TRUE if reparented successfully.  FALSE if any input parameters were invalid, or if the new parent wasn't in the same scene.
 */
native final function bool ReparentChildren( array<UIObject> ChildrenToReparent, UIScreenObject NewParent, optional int InsertIndex=INDEX_NONE );

/**
 * Replace an existing child widget with the specified widget.
 *
 * @param	ExistingChild	the widget to remove
 * @param	NewChild		the widget to replace ExistingChild with
 *
 * @return	TRUE if the ExistingChild was successfully replaced with the specified NewChild; FALSE otherwise.
 */
native final function bool ReplaceChild( UIObject ExistingChild, UIObject NewChild );

/**
 * Find a child widget with the specified name
 *
 * @param	WidgetName	the name of the child to find
 * @param	bRecurse	if TRUE, searches all children of this object recursively
 *
 * @return	a pointer to a widget contained by this object that has the specified name, or
 *			NULL if no widgets with that name were found
 */
native final function UIObject FindChild( name WidgetName, optional bool bRecurse ) const;

/**
 * Find a child widget with the specified GUID
 *
 * @param	WidgetID	the ID(GUID) of the child to find
 * @param	bRecurse	if TRUE, searches all children of this object recursively
 *
 * @return	a pointer to a widget contained by this object that has the specified GUID, or
 *			NULL if no widgets with that name were found
 */
native final function UIObject FindChildUsingID( WIDGET_ID WidgetID, optional bool bRecurse ) const;

/**
 * Find the index for the child widget with the specified name
 *
 * @param	WidgetName	the name of the child to find
 *
 * @return	the index into the array of children for the widget that has the specified name, or
 *			-1 if there aren't any widgets with that name.
 */
native final function int FindChildIndex( name WidgetName ) const;

/**
 * Returns whether this screen object contains the specified child in its list of children.
 *
 * @param	Child		the child to look for
 * @param	bRecurse	whether to search child widgets for the specified child.  if this value is FALSE,
 *						only the Children array of this screen object will be searched for Child.
 *
 * @return	TRUE if Child is contained by this screen object
 */
native final function bool ContainsChild( UIObject Child, optional bool bRecurse=true ) const;

/**
 * Returns whether this screen object contains a child of the specified class.
 *
 * @param	SearchClass	the class to search for.
 * @param	bRecurse	indicates whether to search child widgets.  if this value is FALSE,
 *						only the Children array of this screen object will be searched for instances of SearchClass.
 *
 * @return	TRUE if Child is contained by this screen object
 */
native final function bool ContainsChildOfClass( class<UIObject> SearchClass, optional bool bRecurse=true ) const;

/**
 * Gets a list of all children contained in this screen object.
 *
 * @param	bRecurse		if FALSE, result will only contain widgets from this screen object's Children array
 *							if TRUE, result will contain all children of this screen object, including their children.
 * @param	ExclusionSet	if specified, any widgets contained in this array will not be added to the output array.
 *
 * @return	an array of widgets contained by this screen object.
 *
 * @note: noexport because non-const optional arrays aren't exported correctly by the script compiler.
 */
native final noexport function array<UIObject> GetChildren( optional bool bRecurse, optional array<UIObject> ExclusionSet ) const;

/**
 * Returns the number of UIObjects owned by this UIScreenObject, recursively
 *
 * @return	the number of widgets (including this one) contained by this widget, including all
 *			child widgets
 */
native final function int GetObjectCount() const;

/**
 * Returns all objects which are docked to this one.
 *
 * @param	DockClients					If specified, receives the list of objects docked to this one.  Do not pass a value if you only
 *										wish to know the number of objects docked to this one.
 * @param	bDirectDockClientsOnly		by default, only returns widgets that are docked to this widget directly;  Specify FALSE to also
 *										include widgets which are docked to this widget indirectly (i.e. through more than one docking
 *										link.  Caution: this can cause a performance hit if there are a large number of widgets in the scene.
 * @param	TargetFace					if specified, returns only those widgets that are docked to the specified face on this widget.
 * @param	SourceFace					if specified, returns only those widgets that have the specified face docked to this widget.
 *
 * @return	the number of widgets docked to this one.
 *
 * @note: noexport so that the script thunk can handle the optional array parm correctly
 */
native final noexport function int GetDockClients( optional out array<UIObject> DockClients, optional bool bDirectDockClientsOnly=true, optional EUIWidgetFace TargetFace=UIFACE_MAX, optional EUIWidgetFace SourceFace=UIFACE_MAX ) const;

/**
 * Tell the scene that it needs to be udpated
 *
 * @param	bDockingStackChanged	if TRUE, the scene will rebuild its DockingStack at the beginning
 *									the next frame
 * @param	bPositionsChanged		if TRUE, the scene will update the positions for all its widgets
 *									at the beginning of the next frame
 * @param	bNavLinksOutdated		if TRUE, the scene will update the navigation links for all widgets
 *									at the beginning of the next frame
 * @param	bWidgetStylesChanged	if TRUE, the scene will refresh the widgets reapplying their current styles
 */
native final noexport function RequestSceneUpdate( bool bDockingStackChanged, bool bPositionsChanged, bool bNavLinksOutdated=FALSE, bool bWidgetStylesChanged=FALSE );

/**
 * Flag the scene to refresh all string formatting at the beginning of the next tick.
 */
native final noexport function RequestFormattingUpdate();

/**
 * Flag the scene to recalculate its PlayerInputMask at the beginning of the next tick.
 */
native final noexportheader function RequestSceneInputMaskUpdate();

/**
 * Notifies the owning UIScene that the primitive usage in this scene has changed and sets flags in the scene to indicate that
 * 3D primitives have been added or removed.
 *
 * @param	bReinitializePrimitives		specify TRUE to have the scene detach all primitives and reinitialize the primitives for
 *										the widgets which have them.  Normally TRUE if we have ADDED a new child to the scene which
 *										supports primitives.
 * @param	bReviewPrimitiveUsage		specify TRUE to have the scene re-evaluate whether its bUsesPrimitives flag should be set.  Normally
 *										TRUE if a child which supports primitives has been REMOVED.
 */
native final noexport function RequestPrimitiveReview( bool bReinitializePrimitives, bool bReviewPrimitiveUsage );

/**
 * Immediately rebuilds the navigation links between the children of this screen object and recalculates the child that should
 * be the first & last focused control.
 *
 * @return	TRUE if navigation links were created between any children of this widget.
 */
native final virtual function bool RebuildNavigationLinks();

/**
 * Retrieves the virtual viewport offset for the viewport which renders this widget's scene.  Only relevant in the UI editor;
 * non-zero if the user has panned or zoomed the viewport.
 *
 * @param	out_ViewportOffset	[out] will be filled in with the delta between the viewport's actual origin and virtual origin.
 *
 * @return	TRUE if the viewport origin was successfully retrieved
 */
native final function bool GetViewportOffset( out Vector2D out_ViewportOffset ) const;

/**
 * Retrieves the scale factor for the viewport which renders this widget's scene.  Only relevant in the UI editor.
 */
native final function float GetViewportScale() const;

/**
 * Retrieves the virtual origin of the viewport that this widget is rendered within.  See additional comments in UISceneClient
 *
 * In the game, this will be non-zero if Scene is for split-screen and isn't for the first player.
 * In the editor, this will be equal to the value of the gutter region around the viewport.
 *
 * @param	out_ViewportOrigin	[out] will be filled in with the origin point for the viewport that
 *								owns this screen object
 *
 * @return	TRUE if the viewport origin was successfully retrieved
 */
native final function bool GetViewportOrigin( out Vector2D out_ViewportOrigin ) const;

/**
 * Retrieves the viewport size, accounting for split-screen.
 *
 * @param	out_ViewportSize	[out] will be filled in with the width & height of the viewport that
 *								owns this screen object
 *
 * @return	TRUE if the viewport size was successfully retrieved
 */
native final function bool GetViewportSize( out Vector2D out_ViewportSize ) const;

/**
 * Retrieves the width of the viewport this widget uses for rendering.
 */
native final function float GetViewportWidth() const;

/**
 * Retrieves the height of the viewport this widget uses for rendering.
 */
native final function float GetViewportHeight() const;

/**
 * Retrieves the ratio of the viewport's width to its height.
 */
native final function float GetAspectRatio() const;

/**
 * Activate the event of the specified class.
 *
 * @param	PlayerIndex				the index of the player that activated this event
 * @param	EventClassToActivate	specifies the event class that should be activated.  If there is more than one instance
 *									of a particular event class in this screen object's list of events, all instances will
 *									be activated in the order in which they occur in the event provider's list.
 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents
 * @param	bActivateImmediately	TRUE to activate the event immediately, causing its output operations to also be processed immediately.
 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
 *									will be activated
 * @param	out_ActivatedEvents		filled with the event instances that were activated.
 *
 * @note: noexport because non-const optional arrays aren't exported correctly by the script compiler.
 */
native final noexport function ActivateEventByClass( int PlayerIndex, class<UIEvent> EventClassToActivate, optional Object InEventActivator, optional bool bActivateImmediately, optional array<int> IndicesToActivate, optional out array<UIEvent> out_ActivatedEvents );

/**
 * Finds UIEvent instances of the specified class.
 *
 * @param	EventClassToFind		specifies the event class to search for.
 * @param	out_EventInstances		an array that will contain the list of event instances of the specified class.
 * @param	LimitScope				if specified, only events contained by the specified state's sequence will be returned.
 * @param	bExactClass				if TRUE, only events that have the class specified will be found.  Otherwise, events of that class
 *									or any of its child classes will be found.
 */
native final function FindEventsOfClass( class<UIEvent> EventClassToFind, out array<UIEvent> out_EventInstances, optional UIState LimitScope, optional bool bExactClass );

/** State functions */

/**
 * Attempts to set the object to the enabled/disabled state specified.
 *
 * @param bEnabled		Whether to enable or disable the widget.
 * @param PlayerIndex	Player index to set the state for.
 *
 * @return TRUE if the operation was successful, FALSE otherwise.
 */
native function bool SetEnabled( bool bEnabled, int PlayerIndex=GetBestPlayerIndex() );

/**
 * Gets the current UIState of this screen object
 *
 * @param	PlayerIndex	the index [into the Engine.GamePlayers array] for the player that generated this call
 */
native final function UIState GetCurrentState( INT PlayerIndex=INDEX_NONE );

/**
 * Determine whether there are any active states of the specified class
 *
 * @param	StateClass	the class to search for
 * @param	PlayerIndex	the index [into the Engine.GamePlayers array] for the player that generated this call
 * @param	StateIndex	if specified, will be set to the index of the last state in the list of active states that
 *						has the class specified
 *
 * @return	TRUE if there is at least one active state of the class specified
 */
native final noexport function bool HasActiveStateOfClass( class<UIState> StateClass, int PlayerIndex, optional out int StateIndex );

/**
 * Adds the specified state to the screen object's StateStack.
 *
 * @param	StateToActivate		the new state for the widget
 * @param	PlayerIndex			the index [into the Engine.GamePlayers array] for the player that generated this call
 *
 * @return	TRUE if the widget's state was successfully changed to the new state.  FALSE if the widget couldn't change
 *			to the new state or the specified state already exists in the widget's list of active states
 */
native final virtual function bool ActivateState( UIState StateToActivate, int PlayerIndex );
/**
 * Alternate version of ActivateState that activates the first state in the InactiveStates array with the specified class
 * that isn't already in the StateStack
 */
native final noexport function bool ActivateStateByClass( class<UIState> StateToActivate, int PlayerIndex, optional out UIState StateThatWasAdded );

/**
 * Removes the specified state from the screen object's state stack.
 *
 * @param	StateToRemove	the state to be removed
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
 *
 * @return	TRUE if the state was successfully removed, or if the state didn't exist in the widget's list of states;
 *			false if the state overrode the request to be removed
 */
native final virtual function bool DeactivateState( UIState StateToRemove, int PlayerIndex );
/**
 * Alternate version of DeactivateState that deactivates the last state in the StateStack array that has the specified class.
 */
native final noexport function bool DeactivateStateByClass( class<UIState> StateToRemove, int PlayerIndex, optional out UIState StateThatWasRemoved );

/**
 * Propagates the enabled state of this widget to its child widgets, if the widget has the PRIVATE_PropageteState flag set.
 *
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
 * @param	bForce			specify TRUE to propagate the enabled state even if this widget doesn't have the PropagateState flag set.
 *
 * @return	TRUE if child widget states were set successfully.
 */
native final virtual function bool ConditionalPropagateEnabledState( int PlayerIndex, optional bool bForce );

/**
* Returns TRUE if the player associated with the specified ControllerId is holding the Ctrl key
*
* @fixme - doesn't currently respect the value of ControllerId
*/
native final virtual function bool IsHoldingCtrl( int ControllerId );

/**
* Returns TRUE if the player associated with the specified ControllerId is holding the Alt key
*
* @fixme - doesn't currently respect the value of ControllerId
*/
native final virtual function bool IsHoldingAlt( int ControllerId );

/**
* Returns TRUE if the player associated with the specified ControllerId is holding the Shift key
*
* @fixme - doesn't currently respect the value of ControllerId
*/
native final virtual function bool IsHoldingShift( int ControllerId );

/** === Navigation === */
/**
 * Sets focus to the first focus target within this container.
 *
 * @param	Sender	the widget that generated the focus change.  if NULL, this widget generated the focus change.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
 *
 * @return	TRUE if focus was successfully propagated to the first focus target within this container.
 */
native function bool FocusFirstControl( UIScreenObject Sender, optional int PlayerIndex=GetBestPlayerIndex() );

/**
 * Sets focus to the last focus target within this container.
 *
 * @param	Sender			the widget that generated the focus change.  if NULL, this widget generated the focus change.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
 *
 * @return	TRUE if focus was successfully propagated to the last focus target within this container.
 */
native function bool FocusLastControl( UIScreenObject Sender, optional int PlayerIndex=GetBestPlayerIndex() );

/**
 * Sets focus to the next control in the tab order (relative to Sender) for widget.  If Sender is the last control in
 * the tab order, propagates the call upwards to this widget's parent widget.
 *
 * @param	Sender			the widget to use as the base for determining which control to focus next
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
 *
 * @return	TRUE if we successfully set focus to the next control in tab order.  FALSE if Sender was the last eligible
 *			child of this widget or we couldn't otherwise set focus to another control.
 */
native function bool NextControl( UIScreenObject Sender, optional int PlayerIndex=GetBestPlayerIndex() );

/**
 * Sets focus to the previous control in the tab order (relative to Sender) for widget.  If Sender is the first control in
 * the tab order, propagates the call upwards to this widget's parent widget.
 *
 * @param	Sender			the widget to use as the base for determining which control to focus next
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
 *
 * @return	TRUE if we successfully set focus to the previous control in tab order.  FALSE if Sender was the first eligible
 *			child of this widget or we couldn't otherwise set focus to another control.
 */
native function bool PrevControl( UIScreenObject Sender, optional int PlayerIndex=GetBestPlayerIndex() );

/**
 * Sets focus to the widget bound to the navigation link for specified direction of the Sender.  This function
 * is used for navigation between controls in scenes that support unbound (i.e. any direction) navigation.
 *
 * @param	Sender			Control that called NavigateFocus.  Possible values are:
 *							-	if NULL is specified, it indicates that this is the first step in a focus change.  The widget will
 *								attempt to set focus to its most eligible child widget.  If there are no eligible child widgets, this
 *								widget will enter the focused state and start propagating the focus chain back up through the Owner chain
 *								by calling SetFocus on its Owner widget.
 *							-	if Sender is the widget's owner, it indicates that we are in the middle of a focus change.  Everything else
 *								proceeds the same as if the value for Sender was NULL.
 *							-	if Sender is a child of this widget, it indicates that focus has been successfully changed, and the focus is now being
 *								propagated upwards.  This widget will now enter the focused state and continue propagating the focus chain upwards through
 *								the owner chain.
 * @param	Direction 			the direction to navigate focus.
 * @param	PlayerIndex			the index [into the Engine.GamePlayers array] for the player that generated the focus change.
 * @param	bFocusChanged		will be set to true if we should play a sound as a result of this navigation; false otherwise.
 *
 * @return	TRUE if the navigation event was handled successfully.
 */
native function bool NavigateFocus( UIScreenObject Sender, EUIWidgetFace Direction, optional int PlayerIndex=GetBestPlayerIndex(), optional out byte bFocusChanged );

/** === Focus Handling === */

/**
 * Getter for bNeverFocus
 */
native final function bool IsNeverFocused() const;

/**
 * Determines whether this widget can become the focused control.
 *
 * @param	PlayerIndex					the index [into the Engine.GamePlayers array] for the player to check focus availability
 * @param	bIncludeParentVisibility	indicates whether the widget should consider the visibility of its parent widgets when determining
 *										whether it is eligible to receive focus.  Only needed when building navigation networks, where the
 *										widget might start out hidden (such as UITabPanel).
 *
 * @return	TRUE if this widget (or any of its children) is capable of becoming the focused control.
 */
native function bool CanAcceptFocus( optional int PlayerIndex=GetBestPlayerIndex(), optional bool bIncludeParentVisibility=true ) const;

/**
 * Determines whether this widget is allowed to propagate focus chains to and from the specified widget.
 *
 * @param	TestChild	the widget to check
 *
 * @return	TRUE if the this widget is allowed to route the focus chain through TestChild.
 */
native final function bool CanPropagateFocusFor( UIObject TestChild ) const;

/**
 * Activates the focused state for this widget and sets it to be the focused control of its parent (if applicable)
 *
 * @param	Sender		Control that called SetFocus.  Possible values are:
 *						-	if NULL is specified, it indicates that this is the first step in a focus change.  The widget will
 *							attempt to set focus to its most eligible child widget.  If there are no eligible child widgets, this
 *							widget will enter the focused state and start propagating the focus chain back up through the Owner chain
 *							by calling SetFocus on its Owner widget.
 *						-	if Sender is the widget's owner, it indicates that we are in the middle of a focus change.  Everything else
 *							proceeds the same as if the value for Sender was NULL.
 *						-	if Sender is a child of this widget, it indicates that focus has been successfully changed, and the focus is now being
 *							propagated upwards.  This widget will now enter the focused state and continue propagating the focus chain upwards through
 *							the owner chain.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
 */
native function bool SetFocus( UIScreenObject Sender, optional int PlayerIndex=GetBestPlayerIndex() );

/**
 * Sets focus to the specified child of this widget.
 *
 * @param	ChildToFocus	the child to set focus to.  If not specified, attempts to set focus to the most elibible child,
 *							as determined by navigation links and FocusPropagation values.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
 */
native function bool SetFocusToChild( optional UIObject ChildToFocus, optional int PlayerIndex=GetBestPlayerIndex() );

/**
 * Deactivates the focused state for this widget.
 *
 * @param	Sender			the control that called KillFocus.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
 */
native function bool KillFocus( UIScreenObject Sender, optional int PlayerIndex=GetBestPlayerIndex() );

/**
 * Retrieves the child of this widget which is current focused.
 *
 * @param	bRecurse		if TRUE, returns the inner-most focused widget; i.e. the widget at the end of the focus chain
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
 *
 * @return	a pointer to the child (either direct or indirect) widget which is in the focused state and is the focused control
 *			for its parent widget, or NULL if this widget doesn't have a focused control.
 */
native final function UIObject GetFocusedControl( optional bool bRecurse, optional int PlayerIndex=GetBestPlayerIndex() ) const;

/**
 * Retrieves the child of this widget which last had focus.
 *
 * @param	bRecurse		if TRUE, returns the inner-most previously focused widget; i.e. the widget at the end of the focus chain
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
 *
 * @return	a pointer to the child (either direct or indirect) widget which was previously the focused control for its parent,
 *			or NULL if this widget doesn't have a LastFocusedControl
 */
native final function UIObject GetLastFocusedControl( optional bool bRecurse, optional int PlayerIndex=GetBestPlayerIndex() ) const;

/**
 * Manually sets the last focused control for this widget; only necessary in cases where a particular child should be given focus
 * but this widget (me) doesn't currently have focus.  Setting the last focused control to the ChildToFocus will make it so that
 * ChildToFocus is given focus the next time this widget does.
 */
native final function OverrideLastFocusedControl( int PlayerIndex, UIObject ChildToFocus );

/**
 * Returns TRUE if this widget has a UIState_Enabled object in its StateStack and the state has been activated for the specified PlayerIndex.
 *
 * @param	PlayerIndex			the index of the player to check
 * @param	bCheckOwnerChain	by default, the owner chain is checked as well; specify FALSE to override this behavior.
 */
native final noexport function bool IsEnabled( optional int PlayerIndex=GetBestPlayerIndex(), optional bool bCheckOwnerChain=true ) const;

/**
 * Returns TRUE if this widget has a UIState_Disabled object in its StateStack and the state has been activated for the specified PlayerIndex.
 *
 * @param	PlayerIndex			the index of the player to check
 * @param	bCheckOwnerChain	by default, the owner chain is checked as well; specify FALSE to override this behavior.
 */
native final noexport function bool IsDisabled( optional int PlayerIndex=GetBestPlayerIndex(), optional bool bCheckOwnerChain=true ) const;

/**
 * Returns TRUE if this widget has a UIState_Focused object in its StateStack and the state has been activated for the specified PlayerIndex.
 *
 * @param	PlayerIndex		the index of the player to check
 */
native final noexport function bool IsFocused( optional int PlayerIndex=GetBestPlayerIndex() ) const;

/**
 * Returns TRUE if this widget has a UIState_Active object in its StateStack and the state has been activated for the specified PlayerIndex.
 *
 * @param	PlayerIndex		the index of the player to check
 */
native final noexport function bool IsActive( optional int  PlayerIndex=GetBestPlayerIndex() ) const;

/**
 * Returns TRUE if this widget has a UIState_Pressed object in its StateStack and the state has been activated for the specified PlayerIndex.
 *
 * @param	PlayerIndex		the index of the player to check
 */
native final noexport function bool IsPressed( optional int PlayerIndex=GetBestPlayerIndex() ) const;

/**
 * Determines whether this widget is contained a scene that has been instanced at runtime.
 *
 * @retun	FALSE if this widget is contained in a scene from a content package; TRUE if this widget is contained within a scene
 *			that has been created from scratch or opened at runtime.
 */
native final noexportheader function bool IsRuntimeInstance() const;

/**
 * Determines whether this widget can accept input from the player specified
 *
 * @param	PlayerIndex		the index of the player to check
 *
 * @return	TRUE if this widget's PlayerInputMask allows it to process input from the specified player.
 */
native final function bool AcceptsPlayerInput( int PlayerIndex ) const;

/**
 * Gets the value of this widget's PlayerInputMask.
 *
 * @param	bInheritedMaskOnly		specify TRUE to return only the mask that was set by this widget's owner scene.
 * @param	bOverrideMaskOnly		specify TRUE to return only the mask that was set manually for this widget.
 */
native final noexportheader function byte GetInputMask( optional bool bInheritedMaskOnly, optional bool bOverrideMaskOnly ) const;

/**
 * Changes the player input mask for this control, which controls which players this control will accept input from.
 *
 * @param	NewInputMask	the new mask that should be assigned to this control
 * @param	bRecurse		if TRUE, calls SetInputMask on all child controls as well.
 * @param	bForcedOverride	indicates that the specified input mask should override any input mask inherited from the owning scene
 */
native final noexportheader function SetInputMask( byte NewInputMask, optional bool bRecurse=true, optional bool bForcedOverride );

/**
 * Returns the number of active split-screen players.
 */
native static final noexport function int GetActivePlayerCount();

/**
 * Returns the maximum number of players that could potentially generate input for this scene.  If the owning scene's input mode
 * is INPUTMODE_Free, will correspond to the maximum number of simultaneous gamepads supported by this platform; otherwise, the
 * number of active players.
 */
native final function int GetSupportedPlayerCount();

/**
 * @return	the index [into the Engine.GamePlayers array] for the player that this widget's owner scene last received
 *			input from, or INDEX_NONE if the scene is NULL or hasn't received any input from players yet.
 */
native final function int GetBestPlayerIndex() const;

/**
 * @return	the ControllerId for this widget's owner scene's PlayerOwner, or the player that the owning scene last received
 *			input from.  If the owning scene is NULL, the PlayerOwner is NULL, and no input has been received, returns INDEX_NONE.
 */
native final function int GetBestControllerId() const;

/**
 * Get the index [into the Engine's GamePlayers array] for the player that owns this scene.  Different from GetBestPlayerIndex() in that
 * the index will always be that of the scene's owning player, and never the player that the scene last received input from.
 *
 * @param	if the scene doesn't have a player owner, specifying TRUE for this parameter will return the result of GetBestPlayerIndex().
 *
 * @return	the index for the scene's owning player, or INDEX_NONE if the scene has no PlayerOwner and bRequireValidIndex is FALSE.
 */
native final function int GetPlayerOwnerIndex( optional bool bRequireValidIndex=true ) const;

/**
 * Marks the position for the specified face as out of sync with the corresponding RenderBounds, as well as any faces in this or other
 * widgets which are dependent on this face.
 *
 * @param	Face	the face to modify; value must be one of the EUIWidgetFace values.
 */
native final noexportheader function InvalidatePosition( EUIWidgetFace Face );

/**
 * Marks the position for all faces as out of sync with the RenderBounds values
 *
 * @param	bIgnoreDockedFaces	indicates whether faces that are docked should be skipped
 */
native final noexportheader function InvalidateAllPositions( optional bool bIgnoreDockedFaces=true );

/**
 * Changes this widget's position to the specified value for the specified face.
 *
 * @param	NewValue		the new value (in pixels or percentage) to use
 * @param	Face			indicates which face to change the position for
 * @param	InputType		indicates the format of the input value
 *							EVALPOS_None:
 *								NewValue will be considered to be in whichever format is configured as the ScaleType for the specified face
 *							EVALPOS_PercentageOwner:
 *							EVALPOS_PercentageScene:
 *							EVALPOS_PercentageViewport:
 *								Indicates that NewValue is a value between 0.0 and 1.0, which represents the percentage of the corresponding
 *								base's actual size.
 *							EVALPOS_PixelOwner
 *							EVALPOS_PixelScene
 *							EVALPOS_PixelViewport
 *								Indicates that NewValue is an actual pixel value, relative to the corresponding base.
 * @param	bIncludesViewportOrigin
 *							TRUE indicates that the value is relative to the 0,0 on the screen (or absolute position); FALSE to indicate
 *							the value is relative to the viewport's origin.
 * @param	bResolveChange	indicates whether a scene update should be requested if NewValue does not match the current value.
 */
native final function SetPosition( float NewValue, EUIWidgetFace Face, EPositionEvalType InputType=EVALPOS_PixelOwner, optional bool bIncludesViewportOrigin, optional bool bResolveChange=true );

/**
 * @Returns the Position of a given face for this widget
 * @param	Face			indicates which face to change the position for
 * @param	OutputType		indicates the format of the returnedvalue
 *							EVALPOS_None:
 *								NewValue will be considered to be in whichever format is configured as the ScaleType for the specified face
 *							EVALPOS_PercentageOwner:
 *							EVALPOS_PercentageScene:
 *							EVALPOS_PercentageViewport:
 *								Indicates that return value is between 0.0 and 1.0, which represents the percentage of the corresponding
 *								base's actual size.
 *							EVALPOS_PixelOwner
 *							EVALPOS_PixelScene
 *							EVALPOS_PixelViewport
 *								Indicates that return value is an actual pixel value, relative to the corresponding base.
 * @param	bIncludeOrigin	specify TRUE to indicate that the viewport's origin should be included in the result (for retrieving absolute screen locations)
 *	@param	bIgnoreDockPadding
 *							used to prevent recursion when evaluting docking links
 */
native final function float GetPosition(EUIWidgetFace Face, EPositionEvalType OutputType=EVALPOS_None, optional bool bIncludeOrigin, optional bool bIgnoreDockPadding ) const;

/**
 * Returns the width or height for this widget
 *
 * @param	Dimension			UIORIENT_Horizontal to get the width, UIORIENT_Vertical to get the height
 * @param	OutputType			indicates the format of the returnedvalue
 * @param	bIgnoreDockPadding	used to prevent recursion when evaluting docking links
 */
native final function float GetBounds(EUIOrientation Dimension, EPositionEvalType OutputType=EVALPOS_None, optional bool bIgnoreDockPadding) const;

/**
 * Returns this widget's absolute normalized screen position as a vector.
 *
 * @param	bIncludeParentPosition	if TRUE, coordinates returned will be absolute (relative to the viewport origin); if FALSE
 *									returned coordinates will be relative to the owning widget's upper left corner, if applicable.
 */
native final function vector GetPositionVector( optional bool bIncludeParentPosition=true ) const;

/**
 * Resolves a UIScreenValue_Extent into a pixel value.
 *
 * @param	ExtentToResolve		the extent that needs to be resolved into pixels.
 * @param	OwnerWidget			the widget that contains this extent value
 * @param	OutputType			indicates the desired format for the result
 *								UIEXTENTEVAL_Pixels:
 *									Result should be the actual number of pixels
 *								UIEXTENTEVAL_PercentOwner:
 *									result should be formatted as a percentage of the widget's parent
 *								UIEXTENTEVAL_PercentScene:
 *									result should be formatted as a percentage of the scene
 *								UIEXTENTEVAL_PercentViewport:
 *									result should be formatted as a percentage of the viewport
 *
 * @return	the value [in pixels] for the specified extent
 */
static native final function float ResolveUIExtent( out const UIScreenValue_Extent ExtentToResolve, UIScreenObject OwnerWidget, EUIExtentEvalType OutputType=UIEXTENTEVAL_Pixels ) const;

/**
 * Generates a list of all widgets which are docked to this one.
 *
 * @param	out_DockedWidgets	receives the list of widgets which are docked to this one
 * @param	SourceFace			if specified, only widgets which are docked to this one through the specified face will be considered
 * @param	TargetFace			if specified, only widgets which are docked to the specified face on this widget will be considered
 */
native final function GetDockedWidgets( out array<UIObject> out_DockedWidgets, optional EUIWidgetFace SourceFace=UIFACE_MAX, optional EUIWidgetFace TargetFace=UIFACE_MAX ) const;

/* === Conversion between coordinate systems === */
/*
There are two coordinate systems that are used by the UI system:

	Canvas (widget local space)
		- X/Y axis are aligned with the widget's top/left face
		- Range is 0,0 to SizeX,SizeY
		- Origin at 0,0 (transformed using the widget's transform matrix)

	Pixel (actual viewport pixel location)
		- X/Y axis are aligned with the screen's top/left edge
		- Range is 0,0 to SizeX,SizeY
		- Origin at 0,0 (top-left of screen)

	the intermediate coordinate systems are not used directly by the UI system, but are important when convertin between them:
	Screen (D3D device coordinates) / Camera (normalized device coordinates)
		- X/Y axis are aligned to the screen's left/top
		- Range is -1,1 to 1,-1 (normalized) or -SizeX/2,SizeY/2 to SizeX/2,-SizeY/2
		- Origin is at 0,0 (center of screen)

*/
/**
 * Converts a coordinate from this widget's local space (that is, tranformed by the widget's rotation) into a 2D viewport
 * location, in pixels.
 *
 * @param	CanvasPosition	a vector representing a location in widget local space.
 *
 * @return	a coordinate representing a point on the screen in pixel space
 */
native final function Vector Project( const out Vector CanvasPosition ) const;

/**
 * Converts an absolute pixel position into 3D screen coordinates.
 *
 * @param	PixelPosition	the position of the 2D point, in pixels
 *
 * @return	a position tranformed using this widget's rotation and the scene client's projection matrix.
 */
native final function Vector DeProject( const out Vector PixelPosition ) const;

/**
 * Transforms a vector from canvas (widget local) space into screen (D3D device) space
 *
 * @param	CanvasPosition	a vector representing a location in widget local space.
 *
 * @return	a vector representing that location in screen space.
 */
native final function Vector4 CanvasToScreen( const out Vector CanvasPosition ) const;

/**
 * Transforms a vector from screen (D3D device space) into pixel (viewport pixels) space.
 *
 * @param	ScreenPosition	a vector representing a location in device space
 *
 * @return	a vector representing that location in pixel space.
 */
native final function Vector2D ScreenToPixel( const out Vector4 ScreenPosition ) const;

/**
 * Transforms a vector from pixel (viewport pixels) space into screen (D3D device) space
 *
 * @param	PixelPosition	a vector representing a location in viewport pixel space
 *
 * @return	a vector representing that location in screen space.
 */
native final function Vector4 PixelToScreen( const out Vector2D PixelPosition ) const;

/**
 * Transforms a vector from screen (D3D device space) space into canvas (widget local) space
 *
 * @param	ScreenPosition	a vector representing a location in screen space.
 *
 * @return	a vector representing that location in screen space.
 */
native final function Vector ScreenToCanvas( const out Vector4 ScreenPosition ) const;

/**
 * Transforms a 2D screen coordinate into this widget's local space in canvas coordinates.  In other words, converts a screen point into
 * what that point would be on this widget if this widget wasn't rotated.
 *
 * @param	PixelPosition	the position of the 2D point; a value from 0 - size of the viewport.
 *
 * @return	a 2D screen coordinate corresponding to where PixelPosition would be if this widget was not rotated.
 */
native final function Vector PixelToCanvas( const out Vector2D PixelPosition ) const;

// Same thing as Project
//native final function Vector2D CanvasToPixel( const out Vector CanvasPosition ) const;

/**
 * Returns a matrix which includes the scene client's CanvasToScreen matrix and this widget's tranform matrix.
 */
native final function matrix GetCanvasToScreen() const;

/**
 * Returns the inverse of the canvas to screen matrix.
 */
native final function Matrix GetInverseCanvasToScreen() const;

/**
 * Calculate the correct scaling factor to use for preserving aspect ratios in e.g. string and image formatting.
 *
 * @param	BaseFont	if specified, a font which can provide a "base" resolution for the scale; otherwise, uses the
 *						values of the DFEAULT_SIZE_X/Y consts as the base resolution.
 *
 * @param	a float representing the aspect ratio percentage to use for scaling fonts and images.
 */
native final function float GetAspectRatioAutoScaleFactor( optional Font BaseFont ) const;

/** == Debug == */

/**
 * Returns a string representation of this widget's hierarchy.
 * i.e. SomeScene.SomeContainer.SomeWidget
 */
native final noexport function string GetWidgetPathName();

/* == Events == */

/**
 * Called once this screen object has been completely initialized, before it has activated its InitialState or called
 * Initialize on its children.  This event is only called the first time a widget is initialized.  If reparented, for
 * example, the widget would already be initialized so the Initialized event would not be called.
 */
event Initialized();

/**
 * Called after this screen object's children have been initialized.  While the Initialized event is only called when
 * a widget is initialized for the first time, PostInitialize() will be called every time this widget receives a call
 * to Initialize(), even if the widget was already initialized.  Examples would be reparenting a widget.
 */
event PostInitialize();

/**
 * Called immediately after a child has been added to this screen object.
 *
 * @param	WidgetOwner		the screen object that the NewChild was added as a child for
 * @param	NewChild		the widget that was added
 */
event AddedChild( UIScreenObject WidgetOwner, UIObject NewChild );

/**
 * Called immediately after a child has been removed from this screen object.
 *
 * @param	WidgetOwner		the screen object that the widget was removed from.
 * @param	OldChild		the widget that was removed
 * @param	ExclusionSet	used to indicate that multiple widgets are being removed in one batch; useful for preventing references
 *							between the widgets being removed from being severed.
 *							NOTE: If a value is specified, OldChild will ALWAYS be part of the ExclusionSet, since it is being removed.
 */
event RemovedChild( UIScreenObject WidgetOwner, UIObject OldChild, optional array<UIObject> ExclusionSet );

/**
 * Notification that this widget has been added to the Children array of another widget.  Called immediately before the
 * parent receives the call to AddedChild.
 *
 * @param	NewOwner	the widget
 */
//not yet: event NotifyAddedToParent( UIScreenObject NewOwner );

/**
 * Notification that this widget's parent is about to remove this widget from its children array.  Allows the widget
 * to clean up any references to the old parent.
 *
 * @param	WidgetOwner		the screen object that this widget was removed from.
 */
event RemovedFromParent( UIScreenObject WidgetOwner )
{
	local int AnimationIndex;

	for ( AnimationIndex = AnimStack.Length - 1; AnimationIndex >= 0; AnimationIndex-- )
	{
		StopUIAnimation(AnimStack[AnimationIndex].SequenceRef.SeqName, AnimStack[AnimationIndex].SequenceRef, false);
	}
}

/** @return Returns whether or not the player with the specified controller id is logged in */
event bool IsLoggedIn( optional int ControllerId=255, optional bool bRequireOnlineLogin )
{
	if ( ControllerId == 255 )
	{
		ControllerId = GetBestControllerId();
	}

	return class'UIInteraction'.static.IsLoggedIn(ControllerId, bRequireOnlineLogin);
}

/**
 * Wrapper for determining whether a controller is connected.  Not affected by whether a player is active on that gamepad.
 *
 * @param	ControllerId	the id of the gamepad to check connectivity for.  If not specified, uses the gamepad id of the player
 *							that owns this menu.
 *
 * @return	TRUE if the gamepad is currently connected and turned on.
 */
event final bool IsGamepadConnected( int ControllerId=255 )
{
	if ( ControllerId == 255 )
	{
		ControllerId = GetBestControllerId();
	}

	return class'UIInteraction'.static.IsGamepadConnected(ControllerId);
}

/**
 * Changes this widget's visibility.  Do not change this method to be public - if you need to bypass overrides of SetVisibility,
 * use the Super/Super(UIScreenObject) syntax.
 *
 * @param	bVisible	specify FALSE to hide the widget.
 */
final private function PrivateSetVisibility( bool bVisible )
{
	local bool bCouldAcceptFocus;

	if ( bHidden == bVisible )
	{
		bCouldAcceptFocus = CanAcceptFocus(GetBestPlayerIndex());

		bHidden = !bVisible;
		NotifyVisibilityChanged(Self, bVisible);

		if ( IsFocused() )
		{
			KillFocus(None);
		}

		if ( bCouldAcceptFocus != CanAcceptFocus(GetBestPlayerIndex()) )
		{
			RequestSceneUpdate( false, false, true );
		}
	}
}

/**
 * Changes whether this widget is visible or not.  Should be overridden in child classes to perform additional logic or
 * abort the visibility change.
 *
 * @param	bIsVisible	TRUE if the widget should be visible; false if not.
 */
event SetVisibility( bool bIsVisible )
{
	PrivateSetVisibility(bIsVisible);
}

/**
 * Enables input processing in this widget for the player located at the specified index of the Engine.GamePlayers array.
 * If this control is not currently masking input (i.e. its PlayerInputMask is 0xF), the input mask will be set to only
 * allow input from the player index specified.
 *
 * @param	PlayerIndex		the index of the player that this control should now respond to input for.
 * @param	bRecurse		propagate the new input mask to all children of this control.
 */
final event EnablePlayerInput( byte PlayerIndex, optional bool bRecurse=true )
{
	local byte CurrentPlayerInputMask, NewPlayerInputMask;

	if ( PlayerIndex >= 0 && PlayerIndex < MAX_SUPPORTED_GAMEPADS )
	{
		// a value of 0xF allows this control to process input from all gamepads, so if the current value
		// is 0xF, we need to reset it first so that we now only respond to the gamepad index specified.
		CurrentPlayerInputMask = GetInputMask(false,true);
//		if ( CurrentPlayerInputMask == 0xF )
//		{
//			CurrentPlayerInputMask = 0;
//		}
//
		NewPlayerInputMask = CurrentPlayerInputMask | (1 << PlayerIndex);
		SetInputMask(NewPlayerInputMask, bRecurse, true);
	}
}

/**
 * Disables input processing in this widget for the player located at the specified index of the Engine.GamePlayers array.
 * If this control is no longer masking any players (i.e. the new PlayerInputMask would be 0), the input mask will be reset
 * to allow input from any player.
 *
 * @param	GamepadIndex	the gamepad that this control should no longer respond to input for.
 * @param	bRecurse		propagate the new input mask to all children of this control.
 */
final event DisablePlayerInput( byte PlayerIndex, optional bool bRecurse=true )
{
	local byte NewPlayerInputMask;

	if ( PlayerIndex >= 0 && PlayerIndex < MAX_SUPPORTED_GAMEPADS )
	{
		NewPlayerInputMask = GetInputMask(false,true) & ~(1 << PlayerIndex);

		// if we disabled input for all gamepads, it means that we don't want to mask out
		// any gamepads, so reset this control's input mask so that it will accept input
		// from any gamepad
//		if ( NewPlayerInputMask == 0 )
//		{
//			NewPlayerInputMask = 0xF;
//		}

		SetInputMask(NewPlayerInputMask, bRecurse, true);
	}
}

/**
 * Allow Script to add UI Actions
 */
event GetSupportedUIActionKeyNames(out array<Name> out_KeyNames );

/**
 * Provides script-only child classes with a hook for manipulating the focus hint widget.  Only called if this widget has a value of TRUE
 * for bSupportsFocusHint.
 *
 * @param	FocusHintObject		reference to the widget that supplies the focus hint.
 *
 * @return	TRUE if the initialization/repositioning of the focus hint object was handled in script.
 */
event bool ActivateFocusHint( UIObject FocusHintObject )
{
	return false;
}

/* == Unrealscript == */
/**
 * Returns the scene or widget that contains this widget in its Children array.
 */
function UIScreenObject GetParent();

/** wrapper for enabling/disabling widgets */
final function bool EnableWidget( int PlayerIndex )
{
	return SetEnabled(true, PlayerIndex);
}
final function bool DisableWidget( int PlayerIndex )
{
	return SetEnabled(false, PlayerIndex);
}

function OnConsoleCommand( UIAction_ConsoleCommand Action )
{
	local LocalPlayer PlayerOwner;

	PlayerOwner = GetPlayerOwner();
	if ( PlayerOwner != None && PlayerOwner.Actor != None )
	{
		PlayerOwner.Actor.ConsoleCommand(Action.Command);
	}
	else
	{
		`log(`location@"Couldn't execute console command '" $ Action.Command $ "':" @ `showobj(PlayerOwner) @ (PlayerOwner != None ? `showobj(PlayerOwner.Actor) : ""));
	}
}

/** @return Returns the current login status for the specified controller id. */
final function ELoginStatus GetLoginStatus(int ControllerId=GetBestControllerId())
{
	return class'UIInteraction'.static.GetLoginStatus(ControllerId);
}

/** @return Returns the current status of the platform's network connection. */
static final function bool HasLinkConnection()
{
	return class'UIInteraction'.static.HasLinkConnection();
}

/** @return Returns whether or not the specified player can play online. */
final function bool CanPlayOnline(int ControllerId=GetBestControllerId())
{
	return class'UIInteraction'.static.CanPlayOnline(ControllerId);
}

/** Wrapper for getting the number of signed in players */
static final function int GetLoggedInPlayerCount( optional bool bRequireOnlineLogin, optional int MaxPlayersToCheck=MAX_SUPPORTED_GAMEPADS )
{
	local array<int> IDs;
	GetLoggedInControllerIds(Ids, bRequireOnlineLogin, MaxPlayersToCheck);
	return Ids.Length;
}
static final function GetLoggedInControllerIds( out array<int> ControllerIds, optional bool bRequireOnlineLogin, optional int MaxPlayersToCheck=MAX_SUPPORTED_GAMEPADS )
{
	local int ControllerId;

	// Don't check beyond the platforms limits
	MaxPlayersToCheck = Min(class'OnlineSubsystem'.static.GetNumSupportedLogins(),MaxPlayersToCheck);

	ControllerIds.Length = 0;
	for ( ControllerId = 0; ControllerId < MaxPlayersToCheck; ControllerId++ )
	{
		if ( class'UIInteraction'.static.IsLoggedIn(ControllerId, bRequireOnlineLogin) )
		{
			ControllerIds.AddItem(ControllerId);
		}
	}
}

/**
 * Wrapper for getting the NAT type
 */
function ENATType GetNATType()
{
	return class'UIInteraction'.static.GetNatType();
}

/**
 * Makes a player the primary player
 * @param PlayerIndex - The index of the player to be made into the primary player
 */
function BecomePrimaryPlayer( int PlayerIndex )
{
	local array<LocalPlayer> OtherPlayers;
	local LocalPlayer PlayerOwner, NextPlayer, OriginalPrimaryPlayer;
	local UIInteraction UIController;
	local UIScene OwnerScene;
	local UIObject Widget;

	UIController = GetCurrentUIController();
	if ( UIController != None && PlayerIndex > 0 && PlayerIndex < UIController.GetPlayerCount() )
	{
		OriginalPrimaryPlayer = GetPlayerOwner(0);

		// get the player that owns this scene
		PlayerOwner = GetPlayerOwner(PlayerIndex);
		if ( PlayerOwner == None )
		{
			PlayerOwner = GetPlayerOwner();
		}

		if ( PlayerOwner != None )
		{
			NextPlayer = OriginalPrimaryPlayer;
			while ( NextPlayer != None && NextPlayer != PlayerOwner )
			{
				// the easiest way to ensure that everything is updated properly is to simulate the player being removed;
				// do it manually so that their PlayerController and stuff aren't destroyed.
				UIController.NotifyPlayerRemoved(0, NextPlayer);
				UIController.Outer.Outer.GamePlayers.Remove(0, 1);

				// we need to re-add the player so keep them in a temporary list
				OtherPlayers.AddItem(NextPlayer);

				NextPlayer = GetPlayerOwner(0);
			}

			// now re-add the previous players to the GamePlayers array.
			while ( OtherPlayers.Length > 0 )
			{
				NextPlayer = OtherPlayers[0];

				UIController.Outer.Outer.GamePlayers.InsertItem(1, NextPlayer);
				UIController.NotifyPlayerAdded(1, NextPlayer);

				OtherPlayers.Remove(0, 1);
			}

			Widget = UIObject(Self);
			if ( Widget == None )
			{
				OwnerScene = UIScene(Self);
			}
			else
			{
				OwnerScene = Widget.GetScene();
			}

			if ( OwnerScene != None )
			{
				OwnerScene.LastPlayerIndex = 0;
			}

			// update the PlayerIndex so that it still corresponds to the correct player
			PlayerIndex = 0;
		}

		// if we have a new primary player, reload their profile so that their settings will be applied
		NextPlayer = GetPlayerOwner(0);
		if ( OriginalPrimaryPlayer != NextPlayer )
		{
			NextPlayer.Actor.ReloadProfileSettings();
		}
	}
}

// ===============================================
// ANIMATIONS
// ===============================================
/**
 * Callback which is triggered when a single key-frame of an active UI animation sequence is finished running.  You must call
 * Add_UIAnim_KeyFrameCompletedHandler to subscribe to this delegate.
 *
 * @param	Sender		the widget that owns the animation sequence
 * @param	AnimName	the name of the sequence containing the key-frame that finished.
 * @param	TrackType	the identifier for the track containing the key-frame that completed.
 */
delegate private OnUIAnim_KeyFrameCompleted( UIScreenObject Sender, name AnimName, EUIAnimType TrackType );

/**
 * Callback which is triggered when all key-frames in a single track of an active UI animation sequence have completed.  You must call
 * Add_UIAnimTrackCompletedHandler to subscribe to this delegate.
 *
 * @param	Sender			the widget executing the animation containing the track that just completed
 * @param	AnimName		the name of the animation sequence containing the track that completed.
 * @param	TrackTypeMask	a bitmask of EUIAnimType values indicating which animation tracks completed.  The value is generated by
 *							left shifting 1 by the value of the track type.  A value of 0 indicates that all tracks have completed (in
 *							other words, that the entire animation sequence is completed).
 */
delegate private OnUIAnim_TrackCompleted( UIScreenObject Sender, name AnimName, int TrackTypeMask );

/**
 * Retrieves the current value for some data currently being interpolated by this widget.
 *
 * @param	AnimationType		the type of animation data to retrieve
 * @param	out_CurrentValue	receives the current data value; animation type determines which of the fields holds the actual data value.
 *
 * @return	TRUE if the widget supports the animation type specified.
 */
native final virtual function bool Anim_GetValue( EUIAnimType AnimationType, out UIAnimationRawData out_CurrentValue ) const;
/**
 * Updates the current value for some data currently being interpolated by this widget.
 *
 * @param	AnimationType		the type of animation data to set
 * @param	out_CurrentValue	contains the updated data value; animation type determines which of the fields holds the actual data value.
 *
 * @return	TRUE if the widget supports the animation type specified.
 */
native final virtual function bool Anim_SetValue( EUIAnimType AnimationType, const out UIAnimationRawData NewValue );

/**
 * Accessor for retrieving the PostProcessSettings struct used for interpolating PP effects.
 *
 * @param	CurrentSettings		receives the current PostProcessSettings that should be used for PP effect animation.
 *
 * @return	TRUE if this widget supports animation of post-processing and filled in the value of CurrentSettings.
 */
native final noexport function bool AnimGetCurrentPPSettings( out PostProcessSettings CurrentSettings );

/**
 * Iterate over the AnimStack and tick each active sequence
 *
 * @Param DeltaTime			How much time since the last call
 */
native function TickAnimations(FLOAT DeltaTime);

/**
 * Find the index [into this widget's AnimStack array] for the animation sequence that has the specified name.
 *
 * @param	SequenceName	the name of the sequence to find.
 *
 * @return	the index of the sequence, or INDEX_NONE if it's not currently active.
 */
native final function int FindAnimationSequenceIndex( name SequenceName ) const;

/**
 * Play an animation on this UIObject
 *
 * @param	AnimName			name of the animation sequence to activate; only necessary if no value is provided for AnimSeq
 * @param	AnimSeq				the animation sequence to activate for this widget; if specified, overrides the value of AnimName.
 * @param	OverrideLoopMode	if specified, overrides the animation sequence's default looping behavior
 * @param	PlaybackRate		if specified, affects how fast the animation will be executed.  1.0 is 100% speed.
 * @param	InitialPosition		if specified, indicates an alternate starting position (in seconds) for the animation sequence
 * @param	bSetAnimatingFlag	specify FALSE to prevent this function from marking this widget (and its parents) as bAnimating.
 */
native event PlayUIAnimation(	name AnimName, optional UIAnimationSeq AnimSeqTemplate, optional EUIAnimationLoopMode OverrideLoopMode=UIANIMLOOP_MAX,
								optional float PlaybackRate=1.f, optional float InitialPosition=0.f, optional bool bSetAnimatingFlag=true );

/**
 * Stop an animation that is playing.
 *
 * @param	AnimName	name of the animation sequence to stop; only necessary if no value is provided for AnimSeq
 * @param	AnimSeq		the animation sequence to deactivate for this widget; if specified, overrides the value of AnimName.
 * @param	bFinalize	indicates whether the widget should apply the final frame of the animation (i.e. simulate the animation completing)
 * @param	TypeMask	a bitmask representing the type of animation tracks to stop.  The bitmask should be generated by left shifting
 *						1 by the values of the EUIAnimType enum.
 */
native event StopUIAnimation(name AnimName, optional UIAnimationSeq AnimSeq, optional bool bFinalize=true, optional int TrackTypeMask);

/**
 * Disables the looping for an animation, without affecting the animation itself.
 *
 * @param	SequenceIndex	the index of the sequence to clear the looping for; can be retrieved using FindAnimationSequenceIndex().
 * @param	TypeMask		a bitmask representing the type of animation tracks to affect.  The bitmask should be generated by left shifting
 *							1 by the values of the EUIAnimType enum.
 */
native event ClearUIAnimationLoop( int SequenceIndex, optional int TrackTypeMask );

/**
 * Accessor for checking whether this widget is currently animating.
 *
 * @param	AnimationSequenceName	if specified, checks whether an animation sequence with this name is currently active.
 *
 * @return	TRUE if this widget is animating and if the named animation sequence is active.
 */
native event bool IsAnimating( optional name AnimationSequenceName );

/**
 * Changes the value of bAnimationPaused
 *
 * @param	bPauseAnimation		the new value for
 */
native final function PauseAnimations( bool bPauseAnimation );

/**
 * Accessor for checking whether animations are currently paused.
 *
 * @return	TRUE if animations are paused for this widget.
 */
native final function bool IsAnimationPaused() const;

/**
 * Notification that an animation sequence has been activated.
 *
 * @param	Sender				the widget that owns the animation sequence that was activated
 * @param	AnimName			the name of the animation sequence that was activated.
 * @param	TypeMask			a bitmask indicating which animation tracks were activated.  It is generated by left shifting 1 by the
 *								values of the EUIAnimType enum.  A value of 0 indicates that all tracks in the animation sequence are being
 *								activated.
 * @param	bSetAnimatingFlag	indicates whether this widget should mark itself as animating.
 */
event UIAnimationStarted( UIScreenObject Sender, name AnimName, int TrackTypeMask, optional bool bSetAnimatingFlag=true )
{
	local UIScreenObject Parent;

	if ( Sender != None )
	{
		AnimationCount++;
		if ( !bAnimating && bSetAnimatingFlag )
		{
			bAnimating = true;
		}

		Parent = GetParent();
		if ( Parent != None )
		{
			Parent.UIAnimationStarted(Sender, AnimName, TrackTypeMask, bSetAnimatingFlag);
		}
	}
}

/**
 * Notification that one or more tracks in an animation sequence have completed.
 *
 * @param	Sender				the widget that completed animating.
 * @param	AnimName			the name of the animation sequence that completed.
 * @param	TypeMask			a bitmask indicating which animation tracks completed.  It is generated by left shifting 1 by the
 *								values of the EUIAnimType enum.
 *								A value of 0 indicates that all tracks in the animation sequence have finished.
 */
event UIAnimationEnded( UIScreenObject Sender, name AnimName, int TrackTypeMask )
{
	local UIScreenObject Parent;

	if ( Sender != None )
	{
		AnimationCount--;
		if ( AnimationCount <= 0 )
		{
			AnimationCount = 0;
			bAnimating = false;
		}

		if ( Sender == Self )
		{
			ActivateTrackCompletedDelegates(Sender, AnimName, TrackTypeMask);
		}

		Parent = GetParent();
		if ( Parent != None )
		{
			Parent.UIAnimationEnded(Sender, AnimName, TrackTypeMask);
		}
	}
}

/**
 * Calls each function in the list of delegates subscribed for key-frame completions.
 *
 * @param	Sender		the widget that owns the animation sequence
 * @param	AnimName	the name of the sequence containing the key-frame that finished.
 * @param	TrackType	the identifier for the track containing the key-frame that completed.
 */
event ActivateKeyFrameCompletedDelegates( UIScreenObject Sender, name AnimName, EUIAnimType TrackType )
{
	local int FuncIndex;
	local array<delegate<OnUIAnim_KeyFrameCompleted> > TempDelegates;
	local delegate<OnUIAnim_KeyFrameCompleted> HandlerFunction;

	// make a copy in case the handler removes itself from the list of delegates.
	TempDelegates = KeyFrameCompletedDelegates;
	for ( FuncIndex = 0; FuncIndex < TempDelegates.Length; FuncIndex++ )
	{
		HandlerFunction = TempDelegates[FuncIndex];
		HandlerFunction(Sender, AnimName, TrackType);
	}
}

/**
 * Calls each function in the list of delegates subscribed for animation track completions.
 *
 * @param	Sender			the widget executing the animation containing the track that just completed
 * @param	AnimName		the name of the animation sequence containing the track that completed.
 * @param	TrackTypeMask	a bitmask of EUIAnimType values indicating which animation tracks completed.  The value is generated by
 *							left shifting 1 by the value of the track type.  A value of 0 indicates that all tracks have completed (in
 *							other words, that the entire animation sequence is completed).
 */
event ActivateTrackCompletedDelegates( UIScreenObject Sender, name AnimName, int TrackTypeMask )
{
	local int FuncIndex;
	local array<delegate<OnUIAnim_TrackCompleted> > TempDelegates;
	local delegate<OnUIAnim_TrackCompleted> HandlerFunction;

	// make a copy in case the handler removes itself from the list of delegates.
	TempDelegates = TrackCompletedDelegates;
	for ( FuncIndex = 0; FuncIndex < TempDelegates.Length; FuncIndex++ )
	{
		HandlerFunction = TempDelegates[FuncIndex];
		HandlerFunction(Sender, AnimName, TrackTypeMask);
	}
}

/**
 * Adds a function to the list of callbacks that receive notification that a UI animation key-frame has completed.
 *
 * for now, these just assign...encapsulated like this to make it easy to change the delegate assignment into a list, for example
 * eventually, these will add the passed in value to an array of delegates (once animation is being handled by a component)
 */
final function Add_UIAnimKeyFrameCompletedHandler( delegate<OnUIAnim_KeyFrameCompleted> KeyFrameCompletedDelegate )
{
	if ( KeyFrameCompletedDelegate != None )
	{
		if ( KeyFrameCompletedDelegates.Find(KeyFrameCompletedDelegate) == INDEX_NONE )
		{
			KeyFrameCompletedDelegates.AddItem(KeyFrameCompletedDelegate);
		}
	}
	else
	{
		`warn("NULL value specified for delegate to add.");
	}
//	if ( KeyFrameCompletedDelegate != None )
//	{
//		OnUIAnim_KeyFrameCompleted = KeyFrameCompletedDelegate;
//	}
}

/**
 * Adds a function to the list of callbacks that receive notification that a UI animation tracks has completed.
 *
 * for now, these just assign...encapsulated like this to make it easy to change the delegate assignment into a list, for example
 * eventually, these will add the passed in value to an array of delegates (once animation is being handled by a component)
 */
final function Add_UIAnimTrackCompletedHandler( delegate<OnUIAnim_TrackCompleted> TrackCompletedDelegate )
{
	if ( TrackCompletedDelegate != None )
	{
		if ( TrackCompletedDelegates.Find(TrackCompletedDelegate) == INDEX_NONE )
		{
			TrackCompletedDelegates.AddItem(TrackCompletedDelegate);
		}
	}
	else
	{
		`warn("NULL value specified for delegate to add.");
	}
//	if ( TrackCompletedDelegate != None )
//	{
//		OnUIAnim_TrackCompleted = TrackCompletedDelegate;
//	}
}

/**
 * Removes a function from the list of callbacks that are fired when UI animation keyframes are completed.
 */
final function Remove_UIAnimKeyFrameCompletedHandler( delegate<OnUIAnim_KeyFrameCompleted> KeyFrameCompletedDelegate )
{
	local int RemoveIndex;

	if ( KeyFrameCompletedDelegate != None )
	{
		RemoveIndex = KeyFrameCompletedDelegates.Find(KeyFrameCompletedDelegate);
		if ( RemoveIndex != INDEX_NONE )
		{
			KeyFrameCompletedDelegates.Remove(RemoveIndex, 1);
		}
		else
		{
			`warn(KeyFrameCompletedDelegate @ "was not found in the list of delegates.");
		}
	}
	else
	{
		`warn("NULL value specified for delegate to remove.");
	}
//	if ( OnUIAnim_KeyFrameCompleted == KeyFrameCompletedDelegate )
//	{
//		OnUIAnim_KeyFrameCompleted = None;
//	}
//	else
//	{
//		`warn(`location $ ":" @ KeyFrameCompletedDelegate @ "is not the current value of the OnUIAnim_KeyFrameCompleted delegate (" $ __OnUIAnim_KeyFrameCompleted__Delegate $ ")");
//	}
}

/**
 * Removes a function from the list of callbacks that are fired when UI animation tracks are completed.
 */
final function Remove_UIAnimTrackCompletedHandler( delegate<OnUIAnim_TrackCompleted> TrackCompletedDelegate )
{
	local int RemoveIndex;

	if ( TrackCompletedDelegate != None )
	{
		RemoveIndex = TrackCompletedDelegates.Find(TrackCompletedDelegate);
		if ( RemoveIndex != INDEX_NONE )
		{
			TrackCompletedDelegates.Remove(RemoveIndex, 1);
		}
		else
		{
			`warn(TrackCompletedDelegate @ "was not found in the list of delegates.");
		}
	}
	else
	{
		`warn("NULL value specified for delegate to remove.");
	}
//	if ( OnUIAnim_TrackCompleted == TrackCompletedDelegate )
//	{
//		OnUIAnim_TrackCompleted = None;
//	}
//	else
//	{
//		`warn(`location $ ":" @ TrackCompletedDelegate @ "is not the current value of the OnUIAnim_KeyFrameCompleted delegate (" $ __OnUIAnim_TrackCompleted__Delegate $ ")");
//	}
}

/**
 * Finds the location of a function in the list of callbacks for key-frame completion.
 */
final function int Find_UIAnimKeyFrameCompletedHandler( delegate<OnUIAnim_KeyFrameCompleted> KeyFrameCompletedDelegate )
{
	return KeyFrameCompletedDelegates.Find(KeyFrameCompletedDelegate);
}

/**
 * Finds the location of a function in the list of callbacks for key-frame completion.
 */
final function int Find_UIAnimTrackCompletedHandler( delegate<OnUIAnim_TrackCompleted> TrackCompletedDelegate )
{
	return TrackCompletedDelegates.Find(TrackCompletedDelegate);
}

//Debug
function LogCurrentState( int Indent )
{
`if(`notdefined(FINAL_RELEASE))
	local int i;
	local string IndentString;
	local UIState CurrentState;

	for ( i = 0; i < Indent; i++ )
	{
		IndentString $= " ";
	}

	CurrentState = GetCurrentState();
	`log(IndentString $ "'" $ Name $ "':" @ CurrentState.Name);;
	for ( i = 0; i < Children.Length; i++ )
	{
		Children[i].LogCurrentState(Indent + 3);
	}
`endif
}

defaultproperties
{
	DefaultStates(0)=class'UIState_Enabled'
	DefaultStates(1)=class'UIState_Disabled'

	InitialState=class'UIState_Enabled'

	FocusedCue=Focused
	NavigateUpCue=NavigateUp
	NavigateDownCue=NavigateDown
	NavigateLeftCue=NavigateLeft
	NavigateRightCue=NavigateRight

	Opacity=1.0
}

