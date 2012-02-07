/**
 * Outermost container for a group of widgets.  The relationship between UIScenes and widgets is very similar to the
 * relationship between maps and the actors placed in a map, in that all UIObjects must be contained by a UIScene.
 * Widgets cannot be rendered directly.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIScene extends UIScreenObject
	native(UIPrivate)
	AutoCollapseCategories(Controls,Scene);

/**
 * Semi-unique non-localized name for this scene which is used to reference the scene from unrealscript.
 * For scenes which are gametype specific, each scene may wish to use the same SceneName (for example, if each game
 * had a single scene which represented the HUD for that gametype, all of the HUD scenes might use "HUDScene" as their
 * SceneName, so that the current game's HUD scene can be referenced using "HUDScene" regardless of which type of hud it is)
 */
var()			editconst			name					SceneTag<ToolTip=Human-friendly name for this scene>;

/** the client for this scene - provides all global state information the scene requires for operation */
var const transient					UISceneClient			SceneClient;

/**
 * The data store that provides access to this scene's temporary data
 */
var	const 	instanced				SceneDataStore			SceneData;

/**
 * The LocalPlayer which owns this scene.  NULL if this scene is global (i.e. not owned by a player)
 */
var const transient 				LocalPlayer				PlayerOwner;

/**
 * The context menu currently being displayed or pending display.
 */
var	const transient private			 UIContextMenu			ActiveContextMenu;

/**
 * This context menu will be used as the context menu for widgets which do not provide their own
 */
var	const transient	private{private} UIContextMenu			StandardContextMenu;

/**
 * The UIContextMenu class to use for the StandardContextMenu
 */
var(Controls)	const				class<UIContextMenu>	DefaultContextMenuClass<ToolTip=The class that should be used for displaying context menus in this scene>;

/**
 * Provides a way to force this scene to use a specific skin.  Useful for transitions between front-end and HUD scenes, for example.
 */
var(Style)	const	editinlineuse	UISkin					SceneSkin;

/**
 * Optional safe region panel that should be considered the scene's primary one; if set, the scene will always resolve its position values first
 */
var	const transient	private			UISafeRegionPanel		PrimarySafeRegionPanel;

/**
 * Tracks the docking relationships between widgets owned by this scene.  Determines the order in which the
 * UIObject.Position values for each widget in the sceen are evaluated into UIObject.RenderBounds
 *
 * @note: this variable is not serialized (even by GC) as the widget stored in this array will be
 * serialized through the Children array.
 */
var const transient	native private array<UIDockingNode> DockingStack;

/**
 * Tracks the order in which widgets were rendered, for purposes of hit detection.
 */
var	const	transient	private		array<UIObject>			RenderStack;

/**
 * List of widgets in this scene that implement the UITickableObject interface.
 */
var	const	transient	private		array<UITickableObject>	TickableObjects;

/**
 * List of widgets in this scene that are currently animating.
 */
var			transient	private		array<UIScreenObject>	AnimatingObjects;

/**
 * Tracks the widgets owned by this scene which are currently eligible to process input.
 * Maps the input keyname to the list of widgets that can process that event.
 *
 * @note: this variable is not serialized (even by GC) as the widgets stored in this map will be
 * serialized through the Children array
 */
var	const	transient	native		Map_Mirror				InputSubscriptions[MAX_SUPPORTED_GAMEPADS]{TMap<FName,FInputEventSubscription>};

/**
 * The index for the player that this scene last received input from.
 */
var			transient				int						LastPlayerIndex;

/**
 * Indicates that the docking stack should be rebuilt on the next Tick()
 */
var	transient const					bool 					bUpdateDockingStack;

/**
 * Indicates that the widgets owned by this scene should re-evaluate their screen positions
 * into absolute pixels on the next Tick().
 */
var transient const					bool					bUpdateScenePositions;

/**
 * Indicates that the navigation links between the widgets owned by this scene are no longer up to date.  Once this is set to
 * true, RebuildNavigationLinks() will be called on the next Tick()
 */
var	transient const					bool					bUpdateNavigationLinks;

/**
 * Indicates that the value of bUsesPrimitives is potentially out of date.  Normally set when a child is added or removed from the scene.
 * When TRUE, UpdatePrimitiveUsage will be called during the next tick.
 */
var	transient const					bool					bUpdatePrimitiveUsage;

/**
 * Indicates that the Widgets displayed need to be redrawn. Once this is set to
 * true, RefreshWidgets() will be called on the next Tick()
 */
var	transient const					bool					bRefreshWidgetStyles;

/**
 * Indicates that all strings contained in this scene should be reformatted.
 */
var	transient const					bool					bRefreshStringFormatting;

/**
 * Indicates that the scene should recalculate its PlayerInputMask on the next tick.
 */
var	transient const					bool					bRecalculateInputMask;

/**
 * This flag is used to detect whether or not we are updating the scene for the first time, if it is FALSE and update scene is called,
 * then we issue the PreInitialSceneUpdate for the scene so widgets have a chance to 'initialize' their positions if desired.
 */
var transient const	bool									bPerformedInitialUpdate;

/**
 * Indicates that the scene is currently resolving positions for widgets in this scene
 */
var	transient const bool									bResolvingScenePositions;

/**
 * Number of consecutive frames that bUpdateScenePositions has been set while already in the process of
 * updating widget positions in ResolveScenePositions().  Used by tools to generate warning messages. */
var transient int											UpdateSceneFeedbackLoopCount;

/**
 * Indicates that one or more widgets in this scene are using 3D primitives.  Set to TRUE in Activate() if any children
 * of this scene have true for UIScreenObject.bSupports3DPrimitives
 */
var	transient const bool									bUsesPrimitives;

/**
 * Indicates whether this scene contains multiple controls that the user can navigate between;  set natively, and used to determine whether
 * the UI should process navigation input keys.
 */
var	transient	const				bool					bSupportsNavigation;

/**
 * Indicates that the scene should recalculate the value of bSupportsRotation on the next tick.
 */
var	transient	const				bool					bReevaluateRotationSupport;

/**
 * Indicates whether this scene contains any widgets that have a non-zero rotation.
 */
var	transient	const				bool					bSupportsRotation;

/**
 * Sorting priority; when scenes are opened, they are placed in the stack at the location where
 * all scenes have a SceneStackPriority less than or equal to this one.  By default, the
 * scene is placed at the top of the scene stack.
 */
var()								int						SceneStackPriority;

/**
 * Controls whether the cursor is shown while this scene is active.  Interactive scenes such as menus will generally want
 * this enabled, while non-interactive scenes, such as the HUD generally want it disabled.
 *
 * @todo - this bool may be unnecessary, since we can establish whether a scene should process mouse input by looking
 * at the input events for the widgets of this scene; if any process any of the mouse keys (MouseX, MouseY, RMB, LMB, MMB, etc.)
 * or if the scene can be a drop target, then this scene needs to process mouse input, and should probably display a cursor....
 * hmmm need to think about this assumption a bit more before implementing this
 */
var(Flags) 							bool					bDisplayCursor<ToolTip=Controls whether the game renders a mouse cursor while this scene is active>;

/**
 * Controls whether the scenes underneath this scene are rendered.
 */
var(Flags)							bool					bRenderParentScenes<ToolTip=Controls whether previously open scenes are rendered while this scene is active>;

/**
 * Overrides the setting of bRenderParentScenes for any scenes higher in the stack
 */
var(Flags)							bool					bAlwaysRenderScene<ToolTip=Overrides the value of bRenderScenes for any scenes which were opened after this one>;

/**
 * Indicates whether the game should be paused while this scene is active.
 */
var(Flags)							bool					bPauseGameWhileActive<ToolTip=Controls whether the game is automatically paused while this scene is active>;

/**
 * If true this scene is exempted from Auto closuer when a scene above it closes
 */
var(Flags)							bool					bExemptFromAutoClose<ToolTip=Controls whether this scene is automatically closed when one of its parent scenes is closed>;

/**
 * Indicates whether the the scene should close itself when the level changes.  This is useful for
 * when you have a main menu and want to make certain it is closed when ever you switch to a new level.
 */
var(Flags)							bool					bCloseOnLevelChange<ToolTip=Controls whether this scene is automatically closed when the level changes (recommended if this scene contains references to Actors)>;

/**
 * Indicates whether the scene should have its widgets save their values to the datastore on close.
 */
var(Flags)							bool					bSaveSceneValuesOnClose<ToolTip=Controls whether widgets automatically save their values to their data stores when the scene is closed (turn off if you handle saving manually, such as only when the scene is closed with a certain keypress)>;

/**
 * Controls whether post-processing is enabled for this scene.
 */
var(PostProcess)					bool					bEnableScenePostProcessing<ToolTip=Controls whether post-processing effects are enabled for this scene>;

/**
 * Controls whether depth testing is enabled for this scene.  If TRUE then the 2d ui items are depth tested against the 3d ui scene
 */
var(Flags)							bool					bEnableSceneDepthTesting<ToolTip=Controls whether depth testing with 3D ui primitives is enabled for this scene>;

/**
 * TRUE to indicate that this scene requires a valid network connection in order to be opened.  If no network connection is
 * available, the scene will be closed.
 */
var(Flags)							bool					bRequiresNetwork;

/**
 * Set to TRUE to indicate that the user must be signed into an online service (for example, Windows live) in order to
 * view this scene.  If the user is not signed into an online service, the scene will be closed.
 */
var(Flags)							bool					bRequiresOnlineService;

/**
 * TRUE indicates that this scene can be automatically reopened when the user returns to the main front-end menu.
 */
var(Flags)							bool					bMenuLevelRestoresScene;

/**
 * TRUE to flush all player input when this scene is opened.
 */
var(Flags)							bool					bFlushPlayerInput<DisplayName=Flush Input|ToolTip=Controls whether keys being held down (such as when the player is firing) should be cleared when this scene is opened>;

/**
 * Indicates whether this scene should capture all input which wasn't processed by the scene.  Only relevant for scenes with an input mode
 * of INPUTMODE_MatchingOnly (all other input modes capture all input anyway).
 */
var(Flags)							bool					bCaptureMatchedInput;

/**
 * TRUE to disable world rendering while this scene is active
 */
var(Flags) 							bool 					bDisableWorldRendering<DisplayName=Disable World Rendering|ToolTip=If true, the world rendering will be disabled when this scene is active>;

/**
 * Preview thumbnail for the generic browser.
 */
var	editoronly						Texture2D				ScenePreview;

/**
 * A bitmask representing the player indexes that this control will process input for, where the value is generated by
 * left bitshifting by the index of the player.
 * A value of 0xF indicates that this control will process input from all players.
 * A value of 1 << 1 indicate that only input from player at index 1 will be acccepted, etc.  So value of 3 means that this control
 * processes input from players at indexes 0 and 1.  Input from player indexes that do not match the mask will be ignored.
 *
 * Calculated at runtime.
 */
var	transient						byte					PlayerInputMask;

/**
 * Controls how this scene responds to input from multiple players.
 */
var(Interaction) private{private}	EScreenInputMode		SceneInputMode<ToolTip=Controls how this scene responds to input from multiple players>;

/**
 * Controls how this scene will be rendered when split-screen is active.
 */
var(Interaction) protected{protected} ESplitscreenRenderMode	SceneRenderMode<ToolTip=Controls whether this scene should be rendered when in split-screen>;

/**
 * Post process applied after rendering the UI.
 */
var(PostProcess)					PostProcessChain		UIPostProcessForeground;

/**
 * Post process applied to background before rendering the UI.
 */
var(PostProcess)					PostProcessChain		UIPostProcessBackground;

/**
 * Ordering of post process effects applied.
 * UIPostProcess_None - No post process pass for the UI Scene
 * UIPostProcess_Background - Only UIPostProcessBackground renders before the UI Scene
 * UIPostProcess_Foreground - Only UIPostProcessForeground renders after the UI Scene
 * UIPostProcess_BackgroundAndForeground - Both UIPostProcessBackground/UIPostProcessForeground render for the UI Scene
 */
var(PostProcess)					EUIPostProcessGroup		ScenePostProcessGroup;
var	transient	const				PostProcessSettings		CurrentBackgroundSettings, CurrentForegroundSettings;

/**
 * The current aspect ratio for this scene's viewport.  For scenes modified in the UI editor, this will be set according
 * to the value of the resolution drop-down control.  In game, this will be updated anytime the resolution is changed.
 */
var									Vector2D				CurrentViewportSize;

// ===============================================
// Animations
// ===============================================

//@note: eventually, all animation data will be moved into a component
/** the name of the animation sequence to play when the scene is opened */
var(Animation)						name	SceneAnimation_Open;

/** the name of the animation sequence to play when the scene is closed */
var(Animation)						name	SceneAnimation_Close;

/**
 * the name of the animation sequence to play when this scene opens another scene (and thus, becomes the background for the new scene, in
 * at least in cases where the new scene has bRenderParentScenes set
 */
var(Animation)						name	SceneAnimation_LoseFocus;

/**
 * the name of the animation sequence to play when the topmost scene has just begun its closing animation, and this scene will
 * become the next topmost scene
 */
var(Animation)						name	SceneAnimation_RegainingFocus;

/** the name of the animation sequence to play when the scene is about to become the active scene due to another scene closing */
var(Animation)						name	SceneAnimation_RegainedFocus;

/**
 * Indicates that an animation is playing which should block input.
 */
var			transient	private		bool	bAnimationBlockingInput;

// ===============================================
// Sounds
// ===============================================
/** this sound is played when this scene is activated */
var(Sound)				name						SceneOpenedCue;
/** this sound is played when this scene is deactivated */
var(Sound)				name						SceneClosedCue;


// ===============================================
// Editor
// ===============================================
/**
 * The root of the layer hierarchy for this scene;  only loaded in the editor.
 *
 * @todo ronp - temporarily marked this transient until I can address the bugs in layer browser which are holding references to deleted objects
 * (also commented out the creation of the layer browser).
 */
var	editoronly const	private	transient	UILayerBase		SceneLayerRoot;


cpptext
{
	// UUIScreenObject interface.

	/**
	 * Returns the UIObject that owns this widget, or NULL if this screen object
	 * doesn't have an owner (such as UIScenes)
	 */
	virtual UUIObject* GetOwner() const			{ return NULL; }

	/**
	 * Returns a pointer to this scene.
	 */
	virtual UUIScene* GetScene() 				{ return this; }

	/**
	 * Returns a const pointer to this scene.
	 */
	virtual const UUIScene* GetScene() const	{ return this; }

	/**
	 * returns the unique tag associated with this screen object
	 */
	virtual FName GetTag() const				{ return SceneTag; }

	/**
	 * Returns a string representation of this widget's hierarchy.
	 * i.e. SomeScene.SomeContainer.SomeWidget
	 */
	virtual FString GetWidgetPathName() const	{ return SceneTag.ToString(); }

	/** gets the currently active skin */
	class UUISkin* GetActiveSkin() const;

	/**
	 *	Iterates over all widgets in the scene and forces them to update their style
	 */
	void RefreshWidgetStyles();

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

	/**
	 * Sets up the focus, input, and any other arrays which contain data that tracked uniquely for each active player.
	 * Ensures that the arrays responsible for managing focus chains are synched up with the Engine.GamePlayers array.
	 *
	 * This version also calls CalculateInputMask to initialize the scene's PlayerInputMask for use by the activation
	 * and initialization events that will be called as the scene is activated.
	 */
	virtual void InitializePlayerTracking();

	/**
	 * Called when a new player has been added to the list of active players (i.e. split-screen join) after the scene
	 * has been activated.
	 *
	 * This version updates the scene's PlayerInputMask to reflect the newly added player.
	 *
	 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was inserted
	 * @param	AddedPlayer		the player that was added
	 */
	virtual void CreatePlayerData( INT PlayerIndex, class ULocalPlayer* AddedPlayer );

	/**
	 * Called when a player has been removed from the list of active players (i.e. split-screen players)
	 *
	 * This version updates the scene's PlayerInputMask to reflect the removed player.
	 *
	 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was located
	 * @param	RemovedPlayer	the player that was removed
	 */
	virtual void RemovePlayerData( INT PlayerIndex, class ULocalPlayer* RemovedPlayer );

	/**
	 * Generates a array of UI Action keys that this widget supports.
	 *
	 * @param	out_KeyNames	Storage for the list of supported keynames.
	 */
	virtual void GetSupportedUIActionKeyNames(TArray<FName> &out_KeyNames );

	/**
	 * Creates and initializes this scene's data store.
	 */
	void CreateSceneDataStore();

	/** Called when this scene is about to be added to the active scenes array */
	void Activate();

	/** Called just after this scene is removed from the active scenes array */
	virtual void Deactivate();

	/**
	 * Notification that this scene becomes the active scene.  Called after other activation methods have been called
	 * and after focus has been set on the scene.
	 *
	 * @param	bInitialActivation		TRUE if this is the first time this scene is being activated; FALSE if this scene has become active
	 *									as a result of closing another scene or manually moving this scene in the stack.
	 */
	virtual void OnSceneActivated( UBOOL bInitialActivation );

	/**
	 * This notification is sent to the topmost scene when a different scene is about to become the topmost scene.
	 * Provides scenes with a single location to perform any cleanup for its children.
	 *
	 * @param	NewTopScene		the scene that is about to become the topmost scene.
	 */
	virtual void NotifyTopSceneChanged( UUIScene* NewTopScene );

	/**
	 * Returns the number of faces this widget has resolved.
	 */
	virtual INT GetNumResolvedFaces() const
	{
		return bUpdateScenePositions == TRUE ? 0 : UIFACE_MAX;
	}

	/**
	 * Returns whether the specified face has been resolved
	 *
	 * @param	Face	the face to check
	 */
	virtual UBOOL HasPositionBeenResolved( EUIWidgetFace Face ) const
	{
		return bUpdateScenePositions == FALSE;
	}

	/**
	 * Called when the scene receives a notification that the viewport has been resized.  Propagated down to all children.
	 *
	 * @param	OldViewportSize		the previous size of the viewport
	 * @param	NewViewportSize		the new size of the viewport
	 */
	virtual void NotifyResolutionChanged( const FVector2D& OldViewportSize, const FVector2D& NewViewportSize );

	/**
	 * Immediately rebuilds the navigation links between the children of this screen object and recalculates the child that should
	 * be the first & last focused control.
	 *
	 * @return	TRUE if navigation links were created between any children of this widget.
	 */
	virtual UBOOL RebuildNavigationLinks();

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
	 * Gets the value of this widget's PlayerInputMask.
	 *
	 * @param	bInheritedMaskOnly		ignored
	 * @param	bOverrideMaskOnly		ignored
	 *
	 * @return	a bitmask representing the indices of the players that this scene accepts input from.
	 */
	virtual BYTE GetInputMask( UBOOL bInheritedMaskOnly=FALSE, UBOOL bOverrideMaskOnly=FALSE ) const
	{
		return PlayerInputMask;
	}

	/**
	 * Changes the player input mask for this control, which controls which players this control will accept input from.
	 *
	 * @param	NewInputMask	the new mask that should be assigned to this control
	 * @param	bRecurse		if TRUE, calls SetInputMask on all child controls as well.
	 * @param	bForcedOverride	by default, the widget's PlayerInputMask is only changed if it still matches the default value.
	 */
	virtual void SetInputMask( BYTE NewInputMask, UBOOL bRecurse=TRUE, UBOOL bForcedOverride=FALSE );

	/**
	 * Accessor for retrieving the scene's configured post-process group.
	 *
	 * @return	the post-process group that this scene is configured to use.
	 */
	virtual EUIPostProcessGroup GetScenePostProcessGroup() const;

	/**
	 * Retrieve the post process chain that should be rendered for the UIScene given the post process group
	 *
	 * @param	InUIPostProcessGroup	the type of post processing currently being applied; only scenes with a compatible ScenePostProcessGroup
	 *									will return a valid value.
	 * @param	PPSettings				receives the value of the scene's current post-process settings.
	 *
	 * @return	the post-process chain associated with this scene, if the scene's ScenePostProcessGroup matches the value specified.
	 */
	virtual const class UPostProcessChain* GetPostProcessChain( EUIPostProcessGroup InUIPostProcessGroup/*, FPostProcessSettings** PPSettings=NULL*/ ) const;

	/**
	 * Accessor for retrieving the PostProcessSettings struct used for interpolating PP effects.
	 *
	 * @param	CurrentSettings		receives the current PostProcessSettings that should be used for PP effect animation.
	 *
	 * @return	TRUE if this widget supports animation of post-processing and filled in the value of CurrentSettings.
	 */
	virtual UBOOL AnimGetCurrentPPSettings( FPostProcessSettings*& CurrentSettings );
protected:
	/**
	 * Marks the Position for any faces dependent on the specified face, in this widget or its children,
	 * as out of sync with the corresponding RenderBounds.
	 *
	 * @param	Face	the face to modify; value must be one of the EUIWidgetFace values.
	 */
	virtual void InvalidatePositionDependencies( BYTE Face );

public:
	/* == UUIScene interface == */

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
	virtual void RequestSceneUpdate( UBOOL bDockingStackChanged, UBOOL bPositionsChanged, UBOOL bNavLinksOutdated=FALSE, UBOOL bWidgetStylesChanged=FALSE )
	{
		bUpdateDockingStack = bUpdateDockingStack || bDockingStackChanged;
		bUpdateScenePositions = bUpdateScenePositions || bPositionsChanged;
		bUpdateNavigationLinks = bUpdateNavigationLinks || bNavLinksOutdated;
		bRefreshWidgetStyles = bRefreshWidgetStyles || bWidgetStylesChanged;
	}

	/**
	 * Tells the scene that it should call RefreshFormatting on the next tick.
	 */
	virtual void RequestFormattingUpdate()
	{
		bRefreshStringFormatting = TRUE;
	}

	/**
	 * Flag the scene to recalculate its PlayerInputMask at the beginning of the next tick.
	 */
	virtual void RequestSceneInputMaskUpdate()
	{
		bRecalculateInputMask = TRUE;
	}

	/**
	 * Flag the scene to recalculate the value of bSupportsRotation during the next tick.
	 */
	void RequestRotationSupportUpdate()
	{
		bReevaluateRotationSupport = TRUE;
	}

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
	virtual void RequestPrimitiveReview( UBOOL bReinitializePrimitives, UBOOL bReviewPrimitiveUsage );

	/**
	 * Accessor for retrieving the scene's input mode.
	 *
	 * @param	bMemberValueOnly	specify TRUE to skip calling the delegate and immediately return the value of SceneInputMode
	 *
	 * @return	if the scene's GetSceneInputModeOverride delegate is set, returns the result from that.  Otherwise, the value of this scene's
	 *			SceneInputMode.
	 */
	EScreenInputMode GetSceneInputMode( UBOOL bMemberValueOnly=FALSE );

	/**
	 * Accessor for retrieving the scene's render mode.  Forces render mode to be SPLITRENDER_FullScreen
	 *
	 * @param	bMemberValueOnly	specify TRUE to return the value of SceneRenderMode, ignoring any logic that could potentially alter
	 *								the return value (like being in a cinematic or something)
	 *
	 * @return	the value of this scene's SceneRenderMode member.
	 */
	ESplitscreenRenderMode GetSceneRenderMode( UBOOL bMemberValueOnly=FALSE ) const;

	/**
	 * Accessor for changing the value of this scene's SceneRenderMode var.
	 */
	void SetSceneRenderMode( /*ESplitscreenRenderMode*/BYTE NewRenderMode )
	{
		check(NewRenderMode<SPLITRENDER_MAX);
		SceneRenderMode = NewRenderMode;
	}

	/**
     *	Actually update the scene by rebuilding docking and resolving positions.
     */
	void UpdateScene();

	/**
	 * @return	TRUE if the scene will perform any updates.
	 */
	UBOOL RequiresUpdate() const;

	/**
	 * Updates the value of bUsesPrimitives.
	 */
	virtual void UpdatePrimitiveUsage();

	/**
	 * Called at the beginning of the first scene update and propagated to all widgets in the scene.  Provides classes with
	 * an opportunity to initialize anything that couldn't be setup earlier due to lack of a viewport.
	 *
	 * Calling functions such as GetViewportSize() or GetPosition() aren't guaranteed to work until this function has been called.
	 */
	virtual void PreInitialSceneUpdate();

	/**
	 * Called to globally update the formatting of all UIStrings.
	 */
	virtual void RefreshFormatting( UBOOL bRequestSceneUpdate=TRUE );

	/**
	 * Iterates over all widgets in the scene to determine whether any have a non-zero value for Rotation.  Child classes could override
	 * this method to e.g. force rotation support to be always on or off.
	 */
	virtual void RecalculateRotationSupport();

	/**
	 * Called once per frame to update the scene's state.
	 *
	 * @param	DeltaTime	the time since the last Tick call
	 */
	virtual void Tick( FLOAT DeltaTime );

	/**
	 * Updates the sequences for this scene and its child widgets.
	 *
	 * @param	DeltaTime	the time since the last call to TickSequence.
	 */
	void TickSequence( FLOAT DeltaTime );

	/**
	 * Provides scenes with a way to alter the amount of transparency to use when rendering parent scenes.
	 *
	 * @param	AlphaModulationPercent	the value that will be used for modulating the alpha when rendering the scene below this one.
	 *
	 * @return	TRUE if alpha modulation should be applied when rendering the scene below this one.
	 */
	virtual UBOOL ShouldModulateBackgroundAlpha( FLOAT& AlphaModulationPercent );

	/**
	 * Renders this scene.
	 *
	 * @param	Canvas	the canvas to use for rendering the scene
	 * @param	UIPostProcessGroup	Group determines current pp pass that is being rendered
	 */
	virtual void Render_Scene( FCanvas* Canvas, EUIPostProcessGroup UIPostProcessGroup );

	/**
	 * Renders all special overlays for this scene, such as context menus or tooltips.
	 *
	 * @param	Canvas	the canvas to use for rendering the overlays
	 * @param	UIPostProcessGroup	Group determines current pp pass that is being rendered
	 */
	virtual void RenderSceneOverlays( FCanvas* Canvas, EUIPostProcessGroup UIPostProcessGroup  );

	/**
	 * Updates all 3D primitives in this scene.
	 *
	 * @param	CanvasScene		the scene to use for attaching any 3D primitives
	 */
	virtual void UpdateScenePrimitives( FCanvasScene* CanvasScene );

	/**
	 * Adds the specified widget to the list of subscribers for the specified input key
	 *
	 * @param	InputKey	the key that the widget wants to subscribe to
	 * @param	Handler		the widget to add to the list of subscribers
	 * @param	PlayerIndex	the index of the player to register the input events for
	 *
	 * @return	TRUE if the widget was successfully added to the subscribers list
	 */
	UBOOL SubscribeInputEvent( FName InputKey, UUIScreenObject* Handler, INT PlayerIndex );

	/**
	 * Removes the specified widget from the list of subscribers for the specified input key
	 *
	 * @param	InputKey		the key that the widget wants to unsubscribe for
	 * @param	Handler			the widget to remove from the list of subscribers
	 * @param	PlayerIndex		the index of the player to unregister the input events for
	 * @param	bForcedRemoval	specify TRUE to ignore whether the specified player index is in the list of indices that this scene
	 *							supports input for.  Necessary to remove stale input subscriptions for players that have been
	 *							removed.
	 *
	 * @return	TRUE if the widget was successfully removed from the subscribers list
	 */
	UBOOL UnsubscribeInputEvent( FName InputKey, UUIScreenObject* Handler, INT PlayerIndex, UBOOL bForcedRemoval=FALSE );

	/**
	 * Retrieve the list of input event subscribers for the specified input key and player index.
	 *
	 * @param	InputKey				the input key name to retrieve subscribers for
	 * @param	PlayerIndex				the index for the player to retrieve subscribed controls for
	 * @param	out_SubscribersList		filled with the controls that respond to the specified input key for the specified player
	 *
	 * @return	TRUE if an input subscription was found for the specified input key and player index, FALSE otherwise.
	 */
	UBOOL GetInputEventSubscribers( FName InputKey, INT PlayerIndex, FInputEventSubscription** out_SubscriberList );

protected:
	/**
	 * Wrapper function for converting the controller Id specified into a PlayerIndex and grabbing the scene's input mode.
	 *
	 * @param	ControllerId			the gamepad id of the player that generated the input event
	 * @param	out_ScreenInputMode		set to this scene's input mode
	 * @param	out_PlayerIndex			the Engine.GamePlayers index for the player with the gamepad id specified.
	 *
	 * @return	TRUE if this scene can process input for the gamepad id specified, or FALSE if this scene should ignore
	 *			and swallow this input
	 */
	UBOOL PreprocessInput( INT ControllerId, EScreenInputMode& out_ScreenInputMode, INT& out_PlayerIndex );

	/**
	 * Processes key events for the scene itself.
	 *
	 * Only called if this scene is in the InputSubscribers map for the corresponding key.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputKey( const FSubscribedInputEventParameters& EventParms );

public:
	/**
	 * Allow this scene the chance to respond to an input event.
	 *
	 * @param	ControllerId	controllerId corresponding to the viewport that generated this event
	 * @param	Key				name of the key which an event occured for.
	 * @param	Event			the type of event which occured.
	 * @param	AmountDepressed	(analog keys only) the depression percent.
	 * @param	bGamepad - input came from gamepad (ie xbox controller)
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	UBOOL InputKey(INT ControllerId,FName Key,EInputEvent Event,FLOAT AmountDepressed=1.f,UBOOL bGamepad=FALSE);

	/**
	 * Allow this scene the chance to respond to an input axis event (mouse movement)
	 *
	 * @param	ControllerId	controllerId corresponding to the viewport that generated this event
	 * @param	Key				name of the key which an event occured for.
	 * @param	Delta 			the axis movement delta.
	 * @param	DeltaTime		seconds since the last axis update.
	 *
	 * @return	TRUE to consume the axis movement, FALSE to pass it on.
	 */
	UBOOL InputAxis(INT ControllerId,FName Key,FLOAT Delta,FLOAT DeltaTime,UBOOL bGamepad=FALSE);

	/**
	 * Allow this scene to respond to an input char event.
	 *
	 * @param	ControllerId	controllerId corresponding to the viewport that generated this event
	 * @param	Character		the character that was received
	 *
	 * @return	TRUE to consume the character, false to pass it on.
	 */
	UBOOL InputChar(INT ControllerId,TCHAR Character);

	/**
	 * Determines whether the current docking relationships between the widgets in this scene are valid.
	 *
	 * @return	TRUE if all docking nodes were added to the list.  FALSE if any recursive docking relationships were detected.
	 */
	UBOOL ValidateDockingStack() const;

	/* === UObject interface === */
	/**
	 * Called after importing property values for this object (paste, duplicate or .t3d import)
	 * Allow the object to perform any cleanup for properties which shouldn't be duplicated or
	 * are unsupported by the script serialization
	 *
	 * Updates the scene's SceneTag to match the name of the scene.
	 */
	virtual void PostEditImport();

	/**
	 * Called after this scene is renamed.
	 *
	 * Updates the scene's SceneTag to match the name of the scene.
	 */
	virtual void PostRename();

	/**
	 * Called after duplication & serialization and before PostLoad.
	 *
	 * Updates the scene's SceneTag to match the name of the scene.
	 */
	virtual void PostDuplicate();

	/**
	 * Presave function. Gets called once before an object gets serialized for saving. This function is necessary
	 * for save time computation as Serialize gets called three times per object from within UObject::SavePackage.
	 *
	 * @warning: Objects created from within PreSave will NOT have PreSave called on them!!!
	 *
	 * This version determines determines which sequences in this scene contains sequence ops that are capable of executing logic,
	 * and marks sequence objects with the RF_NotForClient|RF_NotForServer if the op isn't linked to anything.
	 */
	virtual void PreSave();

	/**
	 * Callback for retrieving a textual representation of natively serialized properties.  Child classes should implement this method if they wish
	 * to have natively serialized property values included in things like diffcommandlet output.
	 *
	 * @param	out_PropertyValues	receives the property names and values which should be reported for this object.  The map's key should be the name of
	 *								the property and the map's value should be the textual representation of the property's value.  The property value should
	 *								be formatted the same way that UProperty::ExportText formats property values (i.e. for arrays, wrap in quotes and use a comma
	 *								as the delimiter between elements, etc.)
	 * @param	ExportFlags			bitmask of EPropertyPortFlags used for modifying the format of the property values
	 *
	 * @return	return TRUE if property values were added to the map.
	 */
	virtual UBOOL GetNativePropertyValues( TMap<FString,FString>& out_PropertyValues, DWORD ExportFlags=0 ) const;
}

/* ==========================================================================================================
	UIScene interface.
========================================================================================================== */
/* == Delegates == */
/**
 * Allows users to override the input mode reported for this scene.  If this delegate is not assigned, the scene's will
 * SceneInputMode value will be used.
 *
 * @note: callers should not call this delegate directly to get the scene's input mode; call GetSceneInputMode() instead.
 */
delegate EScreenInputMode GetSceneInputModeOverride();

/**
 * Provides a hook for scenes to have the first chance to process input key events; can be used in cases where the scene needs to override
 * receive a chance to process any input it receives, prior to it being passed around via the normal input processing rules.
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * @param	EventParms	information about the input event, including the name of the input key that was pressed (Tab, Space, etc.),
 *			event type (Pressed, Released, etc.) and modifier keys (Ctrl, Alt)
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
delegate bool OnInterceptRawInputKey( const out InputEventParameters EventParms );

/**
 * Allows others to be notified when this scene becomes the active scene.  Called after other activation methods have been called
 * and after focus has been set on the scene
 *
 * @param	ActivatedScene			the scene that was activated
 * @param	bInitialActivation		TRUE if this is the first time this scene is being activated; FALSE if this scene has become active
 *									as a result of closing another scene or manually moving this scene in the stack.
 */
delegate OnSceneActivated( UIScene ActivatedScene, bool bInitialActivation );

/**
 * Allows others to be notified when this scene is closed.  Called after the SceneDeactivated event, after the scene has published
 * its data to the data stores bound by the widgets of this scene.
 *
 * @param	DeactivatedScene	the scene that was deactivated
 */
delegate OnSceneDeactivated( UIScene DeactivatedScene );

/**
 * Callback which provides a way to prevent the scene client from closing this scene (e.g. for performing a closing animation).
 *
 * @param	SceneToDeactivate	the scene that will be deactivated.
 * @param	bCloseChildScenes	indicates whether the caller wishes to close scenes opened after this one.
 * @param	bForcedClose		indicates whether the caller wished to force the scene to close.  Generally, if this parameter is false you
 *								should allow the scene to be closed so as not to interfere with garbage collection.
 *
 * @return	TRUE to allow the scene to be closed immediately.  FALSE to prevent the scene client from closing the scene.
 */
delegate bool OnQueryCloseSceneAllowed( UIScene SceneToDeactivate, bool bCloseChildScenes, bool bForcedClose );

/**
 * This notification is sent to the topmost scene when a different scene is about to become the topmost scene.
 * Provides scenes with a single location to perform any cleanup for its children.
 *
 * @note: this delegate is called while this scene is still the top-most scene.
 *
 * @param	NewTopScene		the scene that is about to become the topmost scene.
 */
delegate OnTopSceneChanged( UIScene NewTopScene );

/**
 * Provides scenes with a way to alter the amount of transparency to use when rendering parent scenes.
 *
 * @param	AlphaModulationPercent	the value that will be used for modulating the alpha when rendering the scene below this one.
 *
 * @return	TRUE if alpha modulation should be applied when rendering the scene below this one.
 */
delegate bool ShouldModulateBackgroundAlpha( out float AlphaModulationPercent );

/**
 * Called when an animation sequence is activated.  Determines whether the scene should start ignoring and capturing all input.
 *
 * @param	AnimationSequenceName	the name of the animation sequence to activate; should match the 'SeqName' of one of the UIAnimationSeq
 *									objects defined in the game scene client class.
 * @param	TypeMask				a bitmask indicating which animation tracks were activated.  It is generated by left shifting 1 by the
 *									values of the EUIAnimType enum.  A value of 0 indicates that all tracks in the animation sequence are being
 *									activated.
 *
 * @return	TRUE to turn off input processing in this scene - all input will be captured by the scene but not processed.
 */
delegate bool OnQueryBeginAnimation_DisableInput( name AnimationSequenceName, int TrackTypeMask )
{
	local bool bResult;

	if ( TrackTypeMask == 0 )
	{
		bResult = bAnimating && AnimationSequenceName != '';
	}

	return bResult;
}

/**
 * Called when an animation sequence is completed.  Determines whether the scene should start processing input again.
 *
 * @param	AnimationSequenceName	the name of the animation sequence that completed; should match the 'SeqName' of one of
 *									the UIAnimationSeq objects defined in the game scene client class.
 * @param	TrackTypeMask			a bitmask indicating which animation tracks completed.  It is generated by left shifting 1 by the
 *									values of the EUIAnimType enum.
 *									A value of 0 indicates that all tracks in the animation sequence have finished.
 *
 * @return	TRUE to indicate that the scene should re-enable input processing.
 */
delegate bool OnQueryEndAnimation_EnableInput( name AnimationSequenceName, int TrackTypeMask )
{
	local bool bResult;

	if ( TrackTypeMask == 0 )
	{
		bResult = !bAnimating && AnimationSequenceName != '';
	}

	return bResult;
}

/* == Natives == */
/**
 * Triggers an immediate full scene update (rebuilds docking stacks if necessary, resolves scene positions if necessary, etc.); scene
 * updates normally occur at the beginning of each scene's Tick() so this function should only be called if you must change the positions
 * and/or formatting of a widget in the scene after the scene has been ticked, but before it's been rendered.
 *
 * @note: noexport because this simply calls through to the C++ UpdateScene().
 */
native final noexport function ForceImmediateSceneUpdate();

/**
 * Clears and rebuilds the complete DockingStack.  It is not necessary to manually rebuild the DockingStack when
 * simply adding or removing widgets from the scene, since those types of actions automatically updates the DockingStack.
 */
native final function RebuildDockingStack();

/**
 * Iterates through the scene's DockingStack, and evaluates the Position values for each widget owned by this scene
 * into actual pixel values, then stores that result in the widget's RenderBounds field.
 */
native final function ResolveScenePositions();

/**
 * Register an object with the scene so that it receive calls to Tick.
 *
 * @param	ObjectToRegister	the object that should be registered with the scene
 * @param	InsertIndex			the index [into the array of tickable objects] where the object should be inserted; if not
 *								specified, adds the object to the end of the list.  Provides callers with a way to e.g.
 *								guarantee that they receive the call to tick before some other object in the list.
 *
 * @return	TRUE if the object was successfully registered with the scene.  FALSE if the object was already in the list or
 *			an invalid positive index was specified (other than INDEX_NONE).
 */
native final function bool RegisterTickableObject( UITickableObject ObjectToRegister, optional int InsertIndex=INDEX_NONE );

/**
 * Unregisters an object with the scene so that it no longer receives calls to Tick.
 *
 * @param	ObjectToRemove	the object that should be removed from the scene's list of tickable objects.
 *
 * @return	TRUE if the object was successfully removed from the scene.
 */
native final function bool UnregisterTickableObject( UITickableObject ObjectToRemove );

/**
 * Finds the location of a tickable object.
 *
 * @param	ObjectToFind	the object to search for
 *
 * @return	the index into the scene's TickableObjects array for the specified object, or INDEX_NONE if it isn't found.
 */
native final function int FindTickableObjectIndex( UITickableObject ObjectToFind ) const;

/**
 * Gets the data store for this scene, creating one if necessary.
 */
native final function SceneDataStore GetSceneDataStore();

/**
 * Notifies all children that are bound to readable data stores to retrieve their initial value from those data stores.
 */
native final function LoadSceneDataValues();

/**
 * Notifies all children of this scene that are bound to writable data stores to publish their values to those data stores.
 *
 * @param	bUnbindSubscribers	if TRUE, all data stores bound by widgets and strings in this scene will be unbound.
 */
native final function SaveSceneDataValues( optional bool bUnbindSubscribers );

/**
 * Makes all the widgets in this scene unsubscribe from their bound datastores.
 */
native final function UnbindSubscribers();

/**
 * Find the data store that has the specified tag.  If the data store's tag is SCENE_DATASTORE_TAG, the scene's
 * data store is returned, otherwise searches through the global data stores for a data store with a Tag matching
 * the specified name.
 *
 * @param	DataStoreTag	A name corresponding to the 'Tag' property of a data store
 * @param	InPlayerOwner		The player owner to use for resolving the datastore.  If NULL, the scene's playerowner will be used instead.
 *
 * @return	a pointer to the data store that has a Tag corresponding to DataStoreTag, or NULL if no data
 *			were found with that tag.
 */
native final function UIDataStore ResolveDataStore( Name DataStoreTag, optional LocalPlayer InPlayerOwner );

/**
 * Returns the scene that is above this one in the scene client's stack of active scenes.
 *
 * @param	bRequireMatchingPlayerOwner		TRUE indicates that only a scene that has the same value for PlayerOwner as this
 *											scene may be considered the "next" scene to this one
 * @param	bIgnoreUnfocusedScenes			indicates that scenes which cannot accept focus should be skipped.
 *
 * @return	a reference to the next scene above this scene in the ActiveScenes array which meets the criteria specified by the input
 *			parameters, or None if there isn't one.
 */
native final function UIScene GetNextScene( bool bRequireMatchingPlayerOwner=true, optional bool bIgnoreUnfocusedScenes );

/**
 * Returns the scene that is below this one in the scene client's stack of active scenes.
 *
 * @param	bRequireMatchingPlayerOwner		TRUE indicates that only a scene that has the same value for PlayerOwner as this
 *											scene may be considered the "previous" scene to this one
 * @param	bIgnoreUnfocusedScenes			indicates that scenes which cannot accept focus should be skipped.
 *
 * @return	a reference to the next scene below this scene in the ActiveScenes array which meets the criteria specified by the input
 *			parameters, or None if there isn't one.
 */
native final function UIScene GetPreviousScene( bool bRequireMatchingPlayerOwner=true, optional bool bIgnoreUnfocusedScenes );

/**
 * Wrapper for checking whether this scene's parent should also be rendered.
 */
native final function bool ShouldRenderParentScenes() const;

/**
 * Accessor for retrieving the scene's configured post-process group.
 *
 * @return	the post-process group that this scene is configured to use.
 */
native final noexport function EUIPostProcessGroup GetScenePostProcessGroup() const;

/**
 * Changes the screen input mode for this scene.
 */
native final function SetSceneInputMode( EScreenInputMode NewInputMode );

/**
 * Accessor for retrieving the scene's input mode.
 *
 * @param	bMemberValueOnly	specify TRUE to skip calling the delegate and just return the value of SceneInputMode
 *
 * @return	if the scene's GetSceneInputModeOverride delegate is set, returns the result from that.  Otherwise, the value of this scene's
 *			SceneInputMode.
 *
 */
native final noexportheader function EScreenInputMode GetSceneInputMode( optional bool bMemberValueOnly );

/**
 * Accessor for retrieving the scene's render mode.  Forces render mode to be SPLITRENDER_FullScreen
 *
 * @return	the value of this scene's SceneRenderMode member.
 */
native final noexportheader function ESplitscreenRenderMode GetSceneRenderMode() const;

/**
 * Accessor for changing the value of this scene's SceneRenderMode var.
 */
native final noexportheader function SetSceneRenderMode( ESplitscreenRenderMode NewRenderMode );

/**
 * Returns the current WorldInfo
 */
native static function WorldInfo GetWorldInfo();

/**
 * Wrapper for easily determining whether this scene is in the scene client's list of active scenes.
 *
 * @param	bTopmostScene	specify TRUE to check whether the scene is also the scene client's topmost scene.
 */
native final function bool IsSceneActive( optional bool bTopmostScene ) const;

/**
 * Returns the scene's default context menu widget, creating one if necessary.
 */
native final function UIContextMenu GetDefaultContextMenu();

/**
 * Returns the scene's currently active context menu, if there is one.
 */
native final function UIContextMenu GetActiveContextMenu() const;

/**
 * Changes the scene's ActiveContextMenu to the one specified.
 *
 * @param	NewContextMenu	the new context menu to activate, or NULL to clear any active context menus.
 * @param	PlayerIndex		the index of the player to display the context menu for.
 *
 * @return	TRUE if the scene's ActiveContextMenu was successfully changed to the new value.
 */
native final function bool SetActiveContextMenu( UIContextMenu NewContextMenu, int PlayerIndex );

/**
 * Debug function for spewing the scene's docking stack.
 */
native final function LogDockingStack() const;

/* == Events == */
/**
 * Callback for retrieving the widget that provides hints about which item is currently focused.
 *
 * @param	bQueryOnly	specify TRUE to indicate that a focus hint should not be created if it doesn't already exist.
 *
 * @return	the widget used for displaying the global focused control hint.
 */
event UIObject GetFocusHint( optional bool bQueryOnly );

/**
 * Called just after the scene is added to the ActiveScenes array, or when this scene has become the active scene as a result
 * of closing another scene.
 *
 * @param	bInitialActivation		TRUE if this is the first time this scene is being activated; FALSE if this scene has become active
 *									as a result of closing another scene or manually moving this scene in the stack.
 */
event SceneActivated( bool bInitialActivation )
{
	local int EventIndex;
	local array<UIEvent> EventList;
	local UIEvent_SceneActivated SceneActivatedEvent;

	FindEventsOfClass( class'UIEvent_SceneActivated', EventList );
	for ( EventIndex = 0; EventIndex < EventList.Length; EventIndex++ )
	{
		SceneActivatedEvent = UIEvent_SceneActivated(EventList[EventIndex]);
		if ( SceneActivatedEvent != None )
		{
			SceneActivatedEvent.bInitialActivation = bInitialActivation;
			SceneActivatedEvent.ConditionalActivateUIEvent(LastPlayerIndex, Self, Self, bInitialActivation);
		}
	}

	if ( bInitialActivation )
	{
		BeginSceneOpenAnimation();
	}
	else
	{
		if ( SceneAnimation_RegainingFocus != '' && IsAnimating(SceneAnimation_RegainingFocus) )
		{
			StopUIAnimation(SceneAnimation_RegainingFocus,,false);
		}

		BeginSceneRegainedFocusAnimation();
	}
}

/** Called just after this scene is removed from the active scenes array */
event SceneDeactivated()
{
	ActivateEventByClass( LastPlayerIndex,class'UIEvent_SceneDeactivated', Self, true );
}

/**
 * Determines the appropriate PlayerInput mask for this scene, based on the scene's input mode.
 */
final event CalculateInputMask()
{
	local int ActivePlayers, ChildIndex;
	local GameUISceneClient GameSceneClient;
	local byte PlayerIndex, NewMask, TestMask, SceneMask;
	local EScreenInputMode InputMode;
	local array<UIObject> SceneChildren;

	NewMask = GetInputMask();
	GameSceneClient = GameUISceneClient(SceneClient);
	if ( GameSceneClient != None )
	{
		InputMode = GetSceneInputMode();

		switch ( InputMode )
		{
		// if we only accept input from the player that opened this scene, our input mask should only contain the
		// gamepad id for our player owner
		case INPUTMODE_Locked:
		case INPUTMODE_MatchingOnly:
		case INPUTMODE_Selective:
			// if we aren't associated with a player, we'll accept input from anyone
			if ( PlayerOwner == None )
			{
				NewMask = 0;
				ActivePlayers = GetActivePlayerCount();
				for ( PlayerIndex = 0; PlayerIndex < ActivePlayers; PlayerIndex++ )
				{
					NewMask = NewMask | (1 << PlayerIndex);
				}
			}
			else
			{
				PlayerIndex = GameSceneClient.Outer.Outer.Outer.GamePlayers.Find(PlayerOwner);
				if ( PlayerIndex == INDEX_NONE )
				{
					NewMask = 0xF;
				}
				else
				{
					NewMask = 1 << PlayerIndex;
					if ( InputMode == INPUTMODE_Selective )
					{
						SceneMask = NewMask;

						// if selective, check all children in this scene - if any have a specific PlayerInputMask set, make sure the scene
						// PlayerInputMask supports the players for that widget.
						SceneChildren = GetChildren(true);
						for ( ChildIndex = 0; ChildIndex < SceneChildren.Length; ChildIndex++ )
						{
							TestMask = SceneChildren[ChildIndex].GetInputMask(false,true);

							//`log("SceneChildren[" $ ChildIndex $ "]:" $ SceneChildren[ChildIndex].Name @ `showvar(TestMask));
							SceneMask = SceneMask|TestMask;
						}
					}
				}
			}
			break;

		case INPUTMODE_Free:
		case INPUTMODE_ActiveOnly:
			NewMask = 0xF;
			break;

		case INPUTMODE_Simultaneous:
			// reset the InputMask to 0
			NewMask = 0;
			ActivePlayers = GetActivePlayerCount();
			for ( PlayerIndex = 0; PlayerIndex < ActivePlayers; PlayerIndex++ )
			{
				NewMask = NewMask | (1 << PlayerIndex);
			}
			break;

		case INPUTMODE_None:
			// don't support input from anyone.
			NewMask = 0;
			// @todo ronp - or is there...?
			break;

		default:
			`warn(`location @"(" $ SceneTag $ ") unhandled ScreenInputMode '"$GetEnum(enum'EScreenInputMode', InputMode)$"'.  PlayerInputMask will be set to 0");
			break;
		}

`if(`isdefined(dev_build))
		`log(`location @ "(" $ SceneTag $ ") setting PlayerInputMask to "$NewMask@" (SceneMask:" $ SceneMask $ ").  SceneInputMode:"$GetEnum(enum'EScreenInputMode',InputMode) @ "PlayerIndex:" $ PlayerIndex @ "ControllerID:" $ (PlayerOwner != None ? string(PlayerOwner.ControllerId) : "255") @ "PlayerCount:"$ class'UIInteraction'.static.GetPlayerCount(),,'DevUI');
`endif
	}

	SetInputMask(NewMask, true);
	SetInputMask(NewMask|SceneMask, false, true);
}

/* == Overrides == */
/**
 * Called immediately after a child has been added to this screen object.
 *
 * @param	WidgetOwner		the screen object that the NewChild was added as a child for
 * @param	NewChild		the widget that was added
 */
event AddedChild( UIScreenObject WidgetOwner, UIObject NewChild )
{
	Super.AddedChild(WidgetOwner, NewChild);

	NewChild.SetInputMask(PlayerInputMask, true);
	if ( GetSceneInputMode() == INPUTMODE_Selective && NewChild.GetInputMask(false,true) != 0 )
	{
		RequestSceneInputMaskUpdate();
	}
}

/**
 * Called immediately after a child has been removed from this screen object.
 *
 * @param	WidgetOwner		the screen object that the widget was removed from.
 * @param	OldChild		the widget that was removed
 * @param	ExclusionSet	used to indicate that multiple widgets are being removed in one batch; useful for preventing references
 *							between the widgets being removed from being severed.
 *							NOTE: If a value is specified, OldChild will ALWAYS be part of the ExclusionSet, since it is being removed.
 */
event RemovedChild( UIScreenObject WidgetOwner, UIObject OldChild, optional array<UIObject> ExclusionSet )
{
	local UITickableObject TickableObject;

	Super.RemovedChild(WidgetOwner, OldChild, ExclusionSet);

	if ( GetSceneInputMode() == INPUTMODE_Selective && OldChild.GetInputMask(false,true) != 0 )
	{
		RequestSceneInputMaskUpdate();
	}

	// if this widget implements the tickable object interface, make sure it's unregistered.
	TickableObject = UITickableObject(OldChild);
	if ( TickableObject != None )
	{
		UnregisterTickableObject(TickableObject);
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
	local GameUISceneClient GameSceneClient;

	Super.SetVisibility(bIsVisible);

	GameSceneClient = GameUISceneClient(SceneClient);
	if( GameSceneClient != None )
	{
		GameSceneClient.RequestCursorRenderUpdate();
	}
}

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
	local int AnimatorIndex, SequenceIndex, TrackIndex, FrameIndex, PPTrackMask;
	local EUIAnimType TrackType;
	local PostProcessSettings CurrentSettings;

	AnimatorIndex = FindAnimatorIndex(Sender);
	if ( AnimatorIndex == INDEX_NONE && Sender != None )
	{
		AnimatingObjects[AnimatingObjects.Length] = Sender;
	}

	Super.UIAnimationStarted(Sender, AnimName, TrackTypeMask, bSetAnimatingFlag);

	// some types of animations provide their own durations, so if the duration for a track is INDEX_NONE, this means that
	// we should use the duration from the source animation data
	PPTrackMask = EAT_PPBloom|EAT_PPBlurSampleSize|EAT_PPBlurAmount;
	if ( (TrackTypeMask&PPTrackMask) != 0 && AnimGetCurrentPPSettings(CurrentSettings) )
	{
		SequenceIndex = FindAnimationSequenceIndex(AnimName);
		for ( TrackIndex = 0; TrackIndex < AnimStack[SequenceIndex].AnimationTracks.Length; TrackIndex++ )
		{
			TrackType = AnimStack[SequenceIndex].AnimationTracks[TrackIndex].TrackType;
			if ( TrackType == EAT_PPBloom || TrackType == EAT_PPBlurSampleSize || TrackType == EAT_PPBlurAmount )
			{
				for ( FrameIndex = 0; FrameIndex < AnimStack[SequenceIndex].AnimationTracks[TrackIndex].KeyFrames.Length; FrameIndex++ )
				{
					if ( AnimStack[SequenceIndex].AnimationTracks[TrackIndex].KeyFrames[FrameIndex].RemainingTime == -1.f )
					{
						// copy the duration from the current ppsettings into the remaining time
						if ( TrackType == EAT_PPBloom )
						{
							AnimStack[SequenceIndex].AnimationTracks[TrackIndex].KeyFrames[FrameIndex].RemainingTime = CurrentSettings.Bloom_InterpolationDuration;
						}
						else
						{
							// this else block assumes that the only other two types of PP animations are both DOF effects, so assert to this effect
							`assert(TrackType == EAT_PPBlurSampleSize || TrackType == EAT_PPBlurAmount);
							AnimStack[SequenceIndex].AnimationTracks[TrackIndex].KeyFrames[FrameIndex].RemainingTime = CurrentSettings.DOF_InterpolationDuration;
						}

						// we break here because there should only be at most one keyframe with a time of -1
						break;
					}
				}
			}
		}
	}

	if ( OnQueryBeginAnimation_DisableInput(AnimName, TrackTypeMask) )
	{
		bAnimationBlockingInput = true;
		//@todo ronp animations - should we recalculate the scene's input mask??
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
	if ( Sender != None && !Sender.IsAnimating() )
	{
		AnimatingObjects.RemoveItem(Sender);
	}

	Super.UIAnimationEnded(Sender, AnimName, TrackTypeMask);

	if ( !IsAnimating() )
	{
		AnimatingObjects.RemoveItem(Self);
	}

	if ( OnQueryEndAnimation_EnableInput(AnimName, TrackTypeMask) )
	{
		bAnimationBlockingInput = false;
	}
}

/* == Unrealscript == */

/**
 * Default handler for the OnCreateScene delegate
 */
function SceneCreated( UIScene CreatedScene );

/**
 * Called when the local player is about to travel to a new URL.  This callback should be used to perform any preparation
 * tasks, such as updating status text and such.  All cleanup should be done from NotifyGameSessionEnded, as that function
 * will be called in some cases where NotifyClientTravel is not.
 *
 * @param	TravelURL		a string containing the mapname (or IP address) to travel to, along with option key/value pairs
 * @param	TravelType		indicates whether the player will clear previously added URL options or not.
 * @param	bIsSeamless		indicates whether seamless travelling will be used.
 */
function NotifyPreClientTravel( string TravelURL, ETravelType TravelType, bool bIsSeamless );

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 */
function NotifyGameSessionEnded()
{
	if( bCloseOnLevelChange && SceneClient != None )
	{
		CloseScene( Self, true, true );
	}
}

/**
 * Notification that the login status a player has changed.
 *
 * @param	ControllerId	the id of the gamepad for the player that changed login status
 * @param	NewStatus		the value for the player's current login status
 *
 * @return	TRUE if this scene wishes to handle the event and prevent further processing.
 */
function bool NotifyLoginStatusChanged( int ControllerId, ELoginStatus NewStatus )
{
	local UIScene ParentScene;
	local bool bResult;

	// propagate to the scene below this one
	ParentScene = GetPreviousScene(false, true);
	if ( ParentScene != None )
	{
		bResult = ParentScene.NotifyLoginStatusChanged(ControllerId, NewStatus);
	}

	return bResult;
}

/**
 * Called when a gamepad (or other controller) is inserted or removed)
 *
 * @param	ControllerId	the id of the gamepad that was added/removed.
 * @param	bConnected		indicates the new status of the gamepad.
 */
function NotifyControllerStatusChanged( int ControllerId, bool bConnected )
{
	local UIScene ParentScene;

	ParentScene = GetPreviousScene(false);

	// default behavior is to just pass the notification to the next scene down
	if ( ParentScene != None )
	{
		ParentScene.NotifyControllerStatusChanged(ControllerId, bConnected);
	}
}

/**
 * Notification that the player's connection to the platform's online service is changed.
 */
function NotifyOnlineServiceStatusChanged( EOnlineServerConnectionStatus NewConnectionStatus )
{
	local UIScene ParentScene;

	ParentScene = GetPreviousScene(false);
	if ( NewConnectionStatus != OSCS_Connected && bRequiresOnlineService )
	{
		//@todo - should we always force the scene closed without allowing it to perform closing animations?
		// seems like we'd only want to do this if the this is not the last scene being closed.  but then again,
		// we will usually be displaying a message box or something to notify the user that the network status changed
		// so perhaps it's best to skip all animations
		CloseScene( Self, true, /*ParentScene == None || !ParentScene.bRequiresOnlineService*/true );
	}

	// propagate to the scene below this one
	if ( ParentScene != None )
	{
		ParentScene.NotifyOnlineServiceStatusChanged(NewConnectionStatus);
	}
}

/**
 * Called when the status of the platform's network connection changes.
 */
function NotifyLinkStatusChanged( bool bConnected )
{
	local UIScene ParentScene;

	ParentScene = GetPreviousScene(false);
	if ( !bConnected && bRequiresNetwork )
	{
		//@todo - should we always force the scene closed without allowing it to perform closing animations?
		// seems like we'd only want to do this if the this is not the last scene being closed.  but then again,
		// we will usually be displaying a message box or something to notify the user that the network status changed
		// so perhaps it's best to skip all animations
		CloseScene( Self, true, /*ParentScene == None || !ParentScene.bRequiresNetwork*/true );
	}

	// propagate to the scene below this one
	if ( ParentScene != None )
	{
		ParentScene.NotifyLinkStatusChanged(bConnected);
	}
}

/**
 * Called when a storage device is inserted or removed.
 */
function NotifyStorageDeviceChanged()
{
	local UIScene ParentScene;

	ParentScene = GetPreviousScene(false);

	// default behavior is to just pass the notification to the next scene down
	if ( ParentScene != None )
	{
		ParentScene.NotifyStorageDeviceChanged();
	}
}

/**
 * Called when a new player has been added to the list of active players (i.e. split-screen join)
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was inserted
 * @param	AddedPlayer		the player that was added
 */
function NotifyPlayerAdded( int PlayerIndex, LocalPlayer AddedPlayer )
{
	CreatePlayerData(PlayerIndex, AddedPlayer);

	// native code will request a scene update
//	RequestSceneInputMaskUpdate();
}

/**
 * Called when a player has been removed from the list of active players (i.e. split-screen players)
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was located
 * @param	RemovedPlayer	the player that was removed
 */
function NotifyPlayerRemoved( int PlayerIndex, LocalPlayer RemovedPlayer )
{
	local bool bRemovingPlayerOwner;

	bRemovingPlayerOwner = PlayerOwner == RemovedPlayer;
	RemovePlayerData(PlayerIndex, RemovedPlayer);
	// native code will request a scene update
//	RequestSceneInputMaskUpdate();

//	@fixme - this code was broken (was checking PlayerOwner after the native code had wiped out the reference), so was never executing.
//	investigate whether we should re-enable this code after Gears2 branches.
	if ( bRemovingPlayerOwner )
	{
//		UnbindSubscribers();
	}
}


/**
 * Opens a new instance of a UIScene resource, optionally activating the scene's opening animation as well as the currently active scene's
 * focus-lost animations.
 *
 * @param	SceneToOpen			a reference to the scene resource that should be instanced and activated.
 * @param	ScenePlayerOwner	the player that should have control of the scene.
 * @param	ForcedPriority		overrides the scene's SceneStackPriority value to allow callers to modify where the scene is placed in the stack, by default.
 * @param	bSkipAnimation		specify TRUE to indicate that opening animations should be bypassed.
 * @param	SceneDelegate		allows the caller to hook into the new scene's OnSceneActivated delegate.
 *
 * @return	a reference to an instance of the specified scene resource, which is guaranteed to be in the list of active scenes; NULL if the
 *			scene couldn't be activated.
 */
event UIScene OpenScene( UIScene SceneToOpen, optional LocalPlayer ScenePlayerOwner=GetPlayerOwner(), optional byte ForcedPriority, optional bool bSkipAnimation=false, optional delegate<OnSceneActivated> SceneDelegate=None)
{
	local UIScene ActiveScene, SceneInstance;
	local GameUISceneClient GameSceneClient;

	if ( SceneToOpen != None )
	{
		GameSceneClient = GetSceneClient();
		if ( GameSceneClient != None )
		{
			GameSceneClient.InitializeScene(SceneToOpen, ScenePlayerOwner, SceneInstance);
			if ( SceneInstance != None )
			{
				//@todo - support bSkipAnimation.....
				if ( SceneDelegate != None )
				{
					SceneInstance.OnSceneActivated = SceneDelegate;
				}

				ActiveScene = GameSceneClient.GetActiveScene(ScenePlayerOwner, true);
				if ( ActiveScene != None )
				{
//				`log(`location @ "1" @ `showvar(ActiveScene));
					ActiveScene.StopSceneAnimation(ActiveScene.SceneAnimation_Close);
				}

				if ( GameSceneClient.OpenScene(SceneInstance, ScenePlayerOwner, SceneInstance, ForcedPriority) )
				{
					// this player may have been removed, so reset the variable we're using to point to the correct one
					if ( ScenePlayerOwner != SceneInstance.PlayerOwner )
					{
						ActiveScene = GameSceneClient.GetActiveScene(SceneInstance.PlayerOwner);
						if ( ActiveScene != None && ActiveScene == SceneInstance )
						{
							ActiveScene = ActiveScene.GetPreviousScene(true, true);
						}
						ScenePlayerOwner = SceneInstance.PlayerOwner;
					}

					if ( bSkipAnimation )
					{
						if ( ActiveScene != None )
						{
//				`log(`location @ "2" @ `showvar(ActiveScene));
							ActiveScene.StopSceneAnimation(ActiveScene.SceneAnimation_LoseFocus);
						}

						if ( SceneInstance != None )
						{
//				`log(`location @ "3" @ `showvar(ActiveScene));
							SceneInstance.StopSceneAnimation(SceneInstance.SceneAnimation_Open);
						}
					}
					else if ( ActiveScene != None )
					{
						if ( ActiveScene != GameSceneClient.GetActiveScene(ScenePlayerOwner, true) )
						{
//				`log(`location @ "4" @ `showvar(ActiveScene) @ `showvar(GameSceneClient.GetActiveScene(ScenePlayerOwner),CurrentActiveScene) @ `showvar(ScenePlayerOwner));
							ActiveScene.StopSceneAnimation(ActiveScene.SceneAnimation_Open, false);
							ActiveScene.BeginSceneLostFocusAnimation();
						}
						else
						{
							// the previously active scene is still the active scene, which means that the scene we just opened
							// had a lower priority than the currently active scene - fast-forward the opening animation and
							// trigger the lost focus animation.
//				`log(`location @ "5" @ `showvar(ActiveScene) @ `showvar(GameSceneClient.GetActiveScene(ScenePlayerOwner),CurrentActiveScene) @ `showvar(ScenePlayerOwner) @ `showvar(SceneInstance));
							SceneInstance.StopSceneAnimation(ActiveScene.SceneAnimation_Open);
							SceneInstance.BeginSceneLostFocusAnimation();
						}
					}
				}
			}
		}
	}

	return SceneInstance;
}

/**
 * Closes the specified scene, optionally activating the scene's closing animation.
 *
 * @param	SceneToClose			a reference to the scene instance that should be closed; if not specified, closes this scene.
 * @param	bCloseChildScenes		specify FALSE to prevent scenes opened after this one from being automatically closed.
 * @param	bForceCloseImmediately	specify TRUE to indicate that the scene's OnQueryCloseSceneAllowed delegate should be ignored.  Usually
 *									used in cases where you need to ensure the scene goes away immediately, rather than e.g. activating
 *									a close animation which would cause the scene to remain active for a few more frames.
 *
 * @return	TRUE if the scene was closed or the closing animation was activated.  FALSE if the scene couldn't be closed and the closing
 *			animation wasn't started.
 */
event bool CloseScene( optional UIScene SceneToClose=Self, optional bool bCloseChildScenes=true, optional bool bForceCloseImmediately )
{
	local GameUISceneClient GameSceneClient;
	local int SceneIndex;
	local UIScene NextSceneInStack;
	local bool bResult;

	// explicitly using SceneClient (instead of GameSceneClient) so that this will work correctly in the editor
	if ( SceneClient != None && SceneToClose != None )
	{
		if ( bForceCloseImmediately || !SceneToClose.BeginSceneCloseAnimation(bCloseChildScenes) )
		{
			bResult = SceneClient.CloseScene(SceneToClose,bCloseChildScenes,bForceCloseImmediately);
		}
		else
		{
			GameSceneClient = GetSceneClient();

			// we didn't want to force the scene to close, and we aren't performing a closing animation
			if ( GameSceneClient != None && bCloseChildScenes )
			{
				// close all child scenes without performing their closing animations.
				SceneIndex = GameSceneClient.FindSceneIndex(SceneToClose);
				if ( SceneIndex != INDEX_NONE )
				{
					NextSceneInStack = GameSceneClient.GetNextSceneFromIndex(SceneIndex, SceneToClose.PlayerOwner, true);
					while ( NextSceneInStack != None && NextSceneInStack.SceneStackPriority <= SceneToClose.SceneStackPriority )
					{
						if ( !NextSceneInStack.bExemptFromAutoClose )
						{
							CloseScene(NextSceneInStack, false, true);
						}
						NextSceneInStack = GameSceneClient.GetNextSceneFromIndex(SceneIndex, SceneToClose.PlayerOwner, true);
					}
				}
			}

			bResult = true;
		}
	}

	return bResult;
}

/**
 * Find the index into the array of currently animating child widgets for a child of this scene.
 *
 * @param	SearchObj	the widget to find the index for.
 *
 * @return	the index into the AnimatingObjects array for the specified object, or INDEX_NONE if it isn't in the array.
 */
function int FindAnimatorIndex( UIScreenObject SearchObj )
{
	local int Index, Result;

	Result = INDEX_NONE;
	if ( SearchObj != None )
	{
		for ( Index = 0; Index < AnimatingObjects.Length; Index++ )
		{
			if ( AnimatingObjects[Index] == SearchObj )
			{
				Result = Index;
				break;
			}
		}
	}

	return Result;
}

/**
 * Wrapper function for activating an animation sequence on this widget.
 *
 * @param	AnimationSequenceName	the name of the animation sequence to activate; should match the 'SeqName' of one of the UIAnimationSeq
 *									objects defined in the game scene client class.
 * @param	TrackCompletedDelegate	optional function for receiving a notification when a track in the animation sequence has completed.
 *
 * @return	TRUE if the animation sequence was triggered successfully.
 */
function bool BeginSceneAnimation( name AnimationSequenceName, optional delegate<OnUIAnim_TrackCompleted> TrackCompletedDelegate )
{
	local bool bResult;

	if ( AnimationSequenceName != '' && !IsEditor() )
	{
		if ( TrackCompletedDelegate != None )
		{
			Add_UIAnimTrackCompletedHandler(TrackCompletedDelegate);
		}

		PlayUIAnimation(AnimationSequenceName);
		bResult = true;
	}

	return bResult;
}

/**
 * Wrapper for stopping an active UI animtion sequence.
 *
 * @param	AnimationSequenceName	the name of the animation sequence to stop; should match the 'SeqName' of one of the UIAnimationSeq
 *									objects defined in the game scene client class.
 * @param	bFinalize				indicates whether the widget should apply the final frame of the animation (i.e. simulate the animation
 *									completing)
 */
function bool StopSceneAnimation( name AnimationSequenceName, optional bool bFinalize=true )
{
	local bool bResult;

	if ( AnimationSequenceName != '' && !IsEditor() && IsAnimating(AnimationSequenceName) )
	{
		StopUIAnimation(AnimationSequenceName,,bFinalize);
		bResult = true;
	}

	return bResult;
}

/**
 * Wrapper for activating the scene's opening animation.
 */
function BeginSceneOpenAnimation()
{
	local bool bIsPerformingLoseFocusAnimation, bIsPerformingCloseAnimation;

	bIsPerformingLoseFocusAnimation = SceneAnimation_LoseFocus != '' && IsAnimating(SceneAnimation_LoseFocus);
	bIsPerformingCloseAnimation = SceneAnimation_Close != '' && IsAnimating(SceneAnimation_Close);

	// the opening animation is triggered from OnSceneActivated, which means that this scene could have opened another scene or could
	// already be in the process of closing via code executed in Initialize or PostInitialize - so check for these first.
	if ( !bIsPerformingLoseFocusAnimation && !bIsPerformingCloseAnimation )
	{
		BeginSceneAnimation(SceneAnimation_Open, OnOpenAnimationComplete);
	}
}

/**
 * Wrapper for activating the scene's closing animation.
 *
 * @return	TRUE if the closing animation was successfully activated.
 */
function bool BeginSceneCloseAnimation( bool bCloseChildScenes )
{
	local UIScene ParentScene;
	local bool bResult;

	if ( BeginSceneAnimation(SceneAnimation_Close, (bCloseChildScenes ? OnCloseAnimationComplete : OnCloseAnimationComplete_IgnoreChildScenes) ) )
	{
		//@todo ronp animation - this animation should be activated by the parent scene...hmm, need a callback for beginning an
		// animation, then the parent scene simply hooks into that callback for this scene's closing animation.
		ParentScene = GetPreviousScene();
		if ( ParentScene != None )
		{
			ParentScene.BeginSceneRegainingFocusAnimation();
		}

		bResult = true;
	}

	return bResult;
}

/**
 * Wrapper for activating the scene's lost-focus animation (this animation is played when a new scene is becoming active).
 */
function BeginSceneLostFocusAnimation()
{
	BeginSceneAnimation(SceneAnimation_LoseFocus, OnLostFocusAnimationComplete);
}

/**
 * Wrapper for activating the scene's regain-focus animation, which is played when the next scene up is the top-most scene and it
 * begins to close
 */
function BeginSceneRegainingFocusAnimation()
{
	BeginSceneAnimation(SceneAnimation_RegainingFocus, OnRegainingFocusAnimationComplete);
}

/**
 * Wrapper for activating the scene's reactivate animation, which is played when this scene has just become the top-most scene due
 * to another scene closing.
 */
function BeginSceneRegainedFocusAnimation()
{
	BeginSceneAnimation(SceneAnimation_RegainedFocus, OnRegainedFocusAnimationComplete);
}

/* == Delegate handlers == */
/**
 * Handler for the completion of this scene's opening animation...
 *
 * @warning - if you override this in a child class, keep in mind that this function will not be called if the scene has no opening animation.
 */
function OnOpenAnimationComplete( UIScreenObject Sender, name AnimName, int TrackTypeMask )
{
	`log(`location @ `showobj(Sender) @ `showvar(AnimName),TrackTypeMask==0,'DevUIAnimation');
	if ( TrackTypeMask == 0 && AnimName == SceneAnimation_Open )
	{
		Remove_UIAnimTrackCompletedHandler(OnOpenAnimationComplete);
	}
}
/**
 * Handler for the completion of this scene's closing animation
 *
 * @warning - if you override this in a child class, keep in mind that this function will not be called if the scene has no closing animation.
 */
function OnCloseAnimationComplete( UIScreenObject Sender, name AnimName, int TrackTypeMask )
{
	local GameUISceneClient GameSceneClient;

	`log(`location @ `showobj(Sender) @ `showvar(AnimName),TrackTypeMask==0,'DevUIAnimation');
	if ( TrackTypeMask == 0 && AnimName == SceneAnimation_Close )
	{
		Remove_UIAnimTrackCompletedHandler(OnCloseAnimationComplete);
		GameSceneClient = GetSceneClient();
		if ( GameSceneClient != None )
		{
			GameSceneClient.CloseScene(Self);
		}
	}
}
/**
 * Handler for the completion of this scene's closing animation
 *
 * @warning - if you override this in a child class, keep in mind that this function will not be called if the scene has no closing animation.
 */
function OnCloseAnimationComplete_IgnoreChildScenes( UIScreenObject Sender, name AnimName, int TrackTypeMask )
{
	local GameUISceneClient GameSceneClient;

	`log(`location @ `showobj(Sender) @ `showvar(AnimName),TrackTypeMask==0,'DevUIAnimation');
	if ( TrackTypeMask == 0 && AnimName == SceneAnimation_Close )
	{
		Remove_UIAnimTrackCompletedHandler(OnCloseAnimationComplete_IgnoreChildScenes);

		GameSceneClient = GetSceneClient();
		if ( GameSceneClient != None )
		{
			GameSceneClient.CloseScene(Self, false);
		}
	}
}

/**
 * Handler for the completion of this scene's lost-focus animation
 *
 * @warning - if you override this in a child class, keep in mind that this function will not be called if the scene has no lost-focus animation.
 */
function OnLostFocusAnimationComplete( UIScreenObject Sender, name AnimName, int TrackTypeMask )
{
	`log(`location @ `showobj(Sender) @ `showvar(AnimName),TrackTypeMask==0,'DevUIAnimation');
	if ( TrackTypeMask == 0 && AnimName == SceneAnimation_LoseFocus )
	{
		Remove_UIAnimTrackCompletedHandler(OnLostFocusAnimationComplete);
	}
}
/**
 * Handler for the completion of this scene's 'becoming active again' animation
 *
 * @warning - if you override this in a child class, keep in mind that this function will not be called if the scene has no 'becoming active again' animation.
 */
function OnRegainingFocusAnimationComplete( UIScreenObject Sender, name AnimName, int TrackTypeMask )
{
	`log(`location @ `showobj(Sender) @ `showvar(AnimName),TrackTypeMask==0,'DevUIAnimation');
	if ( TrackTypeMask == 0 && AnimName == SceneAnimation_RegainingFocus )
	{
		Remove_UIAnimTrackCompletedHandler(OnRegainingFocusAnimationComplete);
	}
}
/**
 * Handler for the completion of this scene's re-activated animation
 *
 * @warning - if you override this in a child class, keep in mind that this function will not be called if the scene has no re-activated animation.
 */
function OnRegainedFocusAnimationComplete( UIScreenObject Sender, name AnimName, int TrackTypeMask )
{
	`log(`location @ `showobj(Sender) @ `showvar(AnimName),TrackTypeMask==0,'DevUIAnimation');
	if ( TrackTypeMask == 0 && AnimName == SceneAnimation_RegainedFocus )
	{
		Remove_UIAnimTrackCompletedHandler(OnRegainedFocusAnimationComplete);
	}
}

/* === Debug === */
function LogRenderBounds( int Indent )
{
	local int i;

	`log("");
	`log("Render bounds for '" $ SceneTag $ "'" @ "(" $ Position.Value[0] $ "," $ Position.Value[1] $ "," $ Position.Value[2] $ "," $ Position.Value[3] $ ")");
	for ( i = 0; i < Children.Length; i++ )
	{
		Children[i].LogRenderBounds(3);
	}
}

function LogCurrentState( int Indent )
{
`if(`notdefined(FINAL_RELEASE))
	local int i;
	local UIState CurrentState;

	`log("");
	CurrentState = GetCurrentState();
	`log("Menu state for scene '" $ Name $ "':" @ CurrentState.Name);
	for ( i = 0; i < Children.Length; i++ )
	{
		Children[i].LogCurrentState(3);
	}
`endif
}

function DebugShowAnimators()
{
`if(`notdefined(FINAL_RELEASE))
	local int i, ChildIndex;
	local array<UIObject> SceneChildren, AnimatingChildren;

	SceneChildren = GetChildren(true);
	for ( ChildIndex = 0; ChildIndex < SceneChildren.Length; ChildIndex++ )
	{
		if ( SceneChildren[ChildIndex].IsAnimating() )
		{
			AnimatingChildren.AddItem(SceneChildren[ChildIndex]);
		}
	}

	`log(Name @ "has" @ AnimationCount @ "active animations");
	if ( IsAnimating() )
	{
		`log("  " $ i++ $ ")" @ Class.Name @ Name);
		for ( ChildIndex = 0; ChildIndex < AnimatingChildren.Length; ChildIndex++ )
		{
			`log("    " $ i++ $ ")" @ AnimatingChildren[ChildIndex].Class.Name @ PathName(AnimatingChildren[ChildIndex]));
		}
	}
`endif
}

DefaultProperties
{
	bUpdateDockingStack=true
	bUpdateScenePositions=true
	bUpdateNavigationLinks=true
	bUpdatePrimitiveUsage=true
	bCloseOnLevelChange=true
	bSaveSceneValuesOnClose=true
	bFlushPlayerInput=true
	bReevaluateRotationSupport=true
	bCaptureMatchedInput=true
	
	DefaultContextMenuClass=class'Engine.UIContextMenu'

	bDisplayCursor=true
	bPauseGameWhileActive=true
	SceneInputMode=INPUTMODE_Locked
	SceneRenderMode=SPLITRENDER_PlayerOwner
	LastPlayerIndex=INDEX_NONE
	SceneStackPriority=DEFAULT_SCENE_PRIORITY
	PlayerInputMask=15

	// defaults to 4:3
	CurrentViewportSize=(X=1024.f,Y=768.f)

	SceneOpenedCue=SceneOpened
	SceneClosedCue=SceneClosed

	DefaultStates.Add(class'UIState_Focused')
	DefaultStates.Add(class'UIState_Active')

	// Events
	Begin Object Class=UIEvent_Initialized Name=SceneInitializedEvent
		OutputLinks(0)=(LinkDesc="Output")
		SubobjectVersionModifier=2
	End Object
	Begin Object Class=UIEvent_SceneActivated Name=SceneActivatedEvent
		SubobjectVersionModifier=1
		OutputLinks(0)=(LinkDesc="Output")
	End Object
	Begin Object Class=UIEvent_SceneDeactivated Name=SceneDeactivatedEvent
		SubobjectVersionModifier=1
		OutputLinks(0)=(LinkDesc="Output")
	End Object
	Begin Object Class=UIEvent_OnEnterState Name=EnteredStateEvent
	End Object
	Begin Object Class=UIEvent_OnLeaveState Name=LeftStateEvent
	End Object


	Begin Object Class=UIComp_Event Name=SceneEventComponent
		DefaultEvents.Add((EventTemplate=SceneInitializedEvent))
		DefaultEvents.Add((EventTemplate=SceneActivatedEvent))
		DefaultEvents.Add((EventTemplate=SceneDeactivatedEvent))
		DefaultEvents.Add((EventTemplate=EnteredStateEvent))
		DefaultEvents.Add((EventTemplate=LeftStateEvent))
	End Object

	EventProvider=SceneEventComponent
	ScenePostProcessGroup=UIPostProcess_None
}
