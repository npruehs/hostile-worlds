/**
 * UISceneClient used when playing a game.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class GameUISceneClient extends UISceneClient
	within UIInteraction
	native(UIPrivate)
	DependsOn(UIMessageBoxBase)
	config(UI);

/**
 * the list of scenes currently open.  A scene corresponds to a top-level UI construct, such as a menu or HUD
 * There is always at least one scene in the stack - the transient scene.  The transient scene is used as the
 * container for all widgets created by unrealscript and is always rendered last.
 */
var	const	transient protected{protected}		array<UIScene>		ActiveScenes;

/**
 * The mouse cursor that is currently being used.  Updated by scenes & widgets as they change states by calling ChangeMouseCursor.
 */
var	const	transient							UITexture			CurrentMouseCursor;

/**
 * Determines whether the cursor should be rendered.  Set by UpdateMouseCursor()
 */
var	const	transient							bool				bRenderCursor;

/** Cached DeltaTime value from the last Tick() call */
var	const	transient							float				LatestDeltaTime;

/** The time (in seconds) that the last "key down" event was recieved from a key that can trigger double-click events */
var	const	transient							double				DoubleClickStartTime;

/**
 * The location of the mouse the last time a key press was received.  Used to determine when to simulate a double-click
 * event.
 */
var const	transient							IntPoint			DoubleClickStartPosition;

/** Textures for general use by the UI */
var	const	transient							Texture				DefaultUITexture[EUIDefaultPenColor];

/**
 * map of controllerID to list of keys which were pressed when the UI began processing input
 * used to ignore the initial "release" key event from keys which were already pressed when the UI began processing input.
 */
var	const	transient	native					Map_Mirror			InitialPressedKeys{TMap<INT,TArray<FName> >};

/**
 * Indicates that the input processing status of the UI has potentially changed; causes UpdateInputProcessingStatus to be called
 * in the next Tick().
 */
var	const	transient							bool				bUpdateInputProcessingStatus;

/**
* Indicates that the input processing status of the UI has potentially changed; causes UpdateCursorRenderStatus to be called
* in the next Tick().
*/
var const	transient							bool				bUpdateCursorRenderStatus;

/**
 * Indicates that the viewport size being used by one or more scenes is out of date; triggers a call to NotifyViewportResized during the
 * next tick.
 */
var			transient							bool				bUpdateSceneViewportSizes;

/** Controls whether debug input commands are accepted */
var			config								bool				bEnableDebugInput;
/** Controls whether debug information about the scene is rendered */
var			config								bool				bRenderDebugInfo;
/** Controls whether debug information is rendered at the top or bottom of the screen */
var	globalconfig								bool				bRenderDebugInfoAtTop;
/** Controls whether debug information is rendered about the active control */
var	globalconfig								bool				bRenderActiveControlInfo;
/** Controls whether debug information is rendered about the currently focused control */
var	globalconfig								bool				bRenderFocusedControlInfo;
/** Controls whether debug information is rendered about the targeted control */
var	globalconfig								bool				bRenderTargetControlInfo;
/** Controls whether a widget must be visible to become the debug target */
var	globalconfig								bool				bSelectVisibleTargetsOnly;
var	globalconfig								bool				bInteractiveMode;
var	globalconfig								bool				bDisplayFullPaths;
var	globalconfig								bool				bShowWidgetPath;
var	globalconfig								bool				bShowRenderBounds;
var	globalconfig								bool				bShowCurrentState;
var	globalconfig								bool				bShowMousePos;

/**
 * The class to use for displaying message boxes.
 */
var			transient				class<UIMessageBoxBase>			MessageBoxClass;

/**
 * A multiplier value (between 0.0 and 1.f) used for adjusting the transparency of scenes rendered behind scenes which have
 * bRenderParentScenes set to TRUE.  The final alpha used for rendering background scenes is cumulative.
 */
var	config										float				OverlaySceneAlphaModulation;

/**
 * Controls whether a widget can become the scene client's ActiveControl if it isn't in the top-most/focused scene.
 * False allows widgets in background scenes to become the active control.
 */
var	config										bool				bRestrictActiveControlToFocusedScene;

/**
 * Controls whether the UI system should prevent the game from recieving input whenever it's active.  For games with
 * interactive menus that remain on-screen during gameplay, you'll want to change this value to FALSE.
 */
var	const	config								bool				bCaptureUnprocessedInput;

/**
 * Controls whether players are automatically created and removed to match the number of players that are signed into a profile.
 */
var	const	config								bool				bSynchronizePlayers;

/**
 * For debugging - the widget that is currently being watched.
 */
var	const	transient							UIScreenObject		DebugTarget;

/** Holds a list of all available animations for an object */
var transient array<UIAnimationSeq> AnimSequencePool;

/** Will halt the restoring of the menu progression */
var			transient							bool				bKillRestoreMenuProgression;

/** toggles single-step mode, where only a single scene update is performed when a key is pressed */
var(ZDebug)	transient							bool				bDebugResolveScene;

/** while this is TRUE, scenes will not perform updates */
var(ZDebug)	transient							bool				bBlockSceneUpdates;

/** indicates that bDebugResolveScene should be set to TRUE when the next scene is opened */
var(ZDebug)	transient							bool				bBlockUpdatesAfterStackModification;

/** The list of navigation aliases to check input support for */
var const transient array<name> NavAliases;

/** The list of axis input keys to check input support for */
var const transient array<name> AxisInputKeys;

cpptext
{
	/* =======================================
		FExec interface
	======================================= */
	virtual UBOOL Exec(const TCHAR* Cmd,FOutputDevice& Ar);

	/* =======================================
		UUISceneClient interface
	======================================= */
	/**
	 * Performs any initialization for the UISceneClient.
	 *
	 * @param	InitialSkin		UISkin that should be set to the initial ActiveSkin
	 */
	virtual void InitializeClient( UUISkin* InitialSkin );

	/**
	 * Changes the active skin to the skin specified, initializes the skin and performs all necessary cleanup and callbacks.
	 * This method should only be called from script.
	 *
	 * @param	NewActiveScene	The skin to activate
	 *
	 * @return	TRUE if the skin was successfully changed.
	 */
	virtual UBOOL ChangeActiveSkin( UUISkin* NewActiveSkin );

	/**
	 * Refreshes all existing UI elements with the styles from the currently active skin.
	 */
	virtual void OnActiveSkinChanged();

	/**
	 * Called when the UI controller receives a CALLBACK_ViewportResized notification.
	 *
	 * @param	SceneViewport	the viewport that was resized
	 */
	virtual void NotifyViewportResized( FViewport* SceneViewport );

	/**
	 * Retrieves the point of origin for the viewport for the scene specified.  This should always be 0,0 during the game,
	 * but may be different in the UI editor if the editor window is configured to have a gutter around the viewport.
	 *
	 * @param	out_ViewportOrigin	[out] will be filled in with the position of the starting point of the viewport.
	 *
	 * @return	TRUE if the viewport origin was successfully retrieved
	 */
	virtual UBOOL GetViewportOrigin( const UUIScene* Scene, FVector2D& out_ViewportOrigin );

	/**
	 * Retrieves the size of the viewport for the scene specified.
	 *
	 * @param	out_ViewportSize	[out] will be filled in with the width & height that the scene should use as the viewport size
	 *
	 * @return	TRUE if the viewport size was successfully retrieved
	 */
	virtual UBOOL GetViewportSize( const UUIScene* Scene, FVector2D& out_ViewportSize );

	/**
	 * Recalculates the matrix used for projecting local coordinates into screen (normalized device)
	 * coordinates.  This method should be called anytime the viewport size or origin changes.
	 */
	virtual void UpdateCanvasToScreen();

	/**
	 * Process an input event which interacts with the in-game scene debugging overlays
	 *
	 * @param	Key		the key that was pressed
	 * @param	Event	the type of event received
	 *
	 * @return	TRUE if the input event was processed; FALSE otherwise.
	 */
	UBOOL DebugInputKey( FName Key, EInputEvent Event );

	/**
	 * Check a key event received by the viewport.
	 *
	 * @param	Viewport - The viewport which the key event is from.
	 * @param	ControllerId - The controller which the key event is from.
	 * @param	Key - The name of the key which an event occured for.
	 * @param	Event - The type of event which occured.
	 * @param	AmountDepressed - For analog keys, the depression percent.
	 * @param	bGamepad - input came from gamepad (ie xbox controller)
	 *
	 * @return	True to consume the key event, false to pass it on.
	 */
	virtual UBOOL InputKey(INT ControllerId,FName Key,EInputEvent Event,FLOAT AmountDepressed=1.f,UBOOL bGamepad=FALSE);

	/**
	 * Check an axis movement received by the viewport.
	 *
	 * @param	Viewport - The viewport which the axis movement is from.
	 * @param	ControllerId - The controller which the axis movement is from.
	 * @param	Key - The name of the axis which moved.
	 * @param	Delta - The axis movement delta.
	 * @param	DeltaTime - The time since the last axis update.
	 *
	 * @return	True to consume the axis movement, false to pass it on.
	 */
	virtual UBOOL InputAxis(INT ControllerId,FName Key,FLOAT Delta,FLOAT DeltaTime, UBOOL bGamepad=FALSE);

	/**
	 * Check a character input received by the viewport.
	 *
	 * @param	Viewport - The viewport which the axis movement is from.
	 * @param	ControllerId - The controller which the axis movement is from.
	 * @param	Character - The character.
	 *
	 * @return	True to consume the character, false to pass it on.
	 */
	virtual UBOOL InputChar(INT ControllerId,TCHAR Character);

	/* =======================================
		UGameUISceneClient interface
	======================================= */
	/**
	 * Creates the scene that will be used to contain transient widgets that are created in unrealscript
	 */
	void CreateTransientScene();

	/**
	 * Creates a new instance of the scene class specified.
	 *
	 * @param	SceneTemplate	the template to use for the new scene
	 * @param	InOuter			the outer for the scene
	 * @param	SceneTag		if specified, the scene will be given this tag when created
	 * @param	SceneClass		the class to use for creating the new scene; if not specified, uses the SceneTemplate's class
	 *
	 * @return	a UIScene instance of the class specified
	 */
	 UUIScene* CreateScene( UUIScene* SceneTemplate, UObject* InOuter, FName SceneTag=NAME_None, UClass* SceneClass=NULL );

	/**
	 * Determines which widget is currently under the mouse cursor by performing hit tests against bounding regions.
	 */
	void UpdateActiveControl();

	/**
	 * Resets the time and mouse position values used for simulating double-click events to the current value or invalid values.
	 */
	void ResetDoubleClickTracking( UBOOL bClearValues );

	/**
	 * Checks the current time and mouse position to determine whether a double-click event should be simulated.
	 */
	UBOOL ShouldSimulateDoubleClick() const;

	/**
	 * Determines whether the any active scenes process axis input.
	 *
	 * @param	bProcessAxisInput	receives the flags for whether axis input is needed for each player.
	 */
	virtual void CheckAxisInputSupport( UBOOL* bProcessAxisInput[UCONST_MAX_SUPPORTED_GAMEPADS] ) const;

	/**
	 * Set the mouse position to the coordinates specified
	 *
	 * @param	NewX	the X position to move the mouse cursor to (in pixels)
	 * @param	NewY	the Y position to move the mouse cursor to (in pixels)
	 */
	virtual void SetMousePosition( INT NewMouseX, INT NewMouseY );

	/**
	 * Sets the values of MouseX & MouseY to the current position of the mouse
	 */
	virtual void UpdateMousePosition();

	/**
	 * Gets the size (in pixels) of the mouse cursor current in use.
	 *
	 * @return	TRUE if MouseXL/YL were filled in; FALSE if there is no mouse cursor or if the UI is configured to not render a mouse cursor.
	 */
	virtual UBOOL GetCursorSize( FLOAT& MouseXL, FLOAT& MouseYL );

	/**
	 * Called whenever a scene is added or removed from the list of active scenes.  Calls any functions that handle updating the
	 * status of various tracking variables, such as whether the UI is currently capable of processing input.
	 *
	 * @param	PlayerIndex		the index of the player that owns the scene that was just added or removed, or 0 if the scene didn't have
	 *							a player owner.
	 */
	virtual void SceneStackModified( INT PlayerIndex );

	/**
	 * Changes the resource that is currently being used as the mouse cursor.  Called by widgets as they changes states which
	 * affect the mouse cursor
	 *
	 * @param	CursorName	the name of the mouse cursor resource to use.  Should correspond to a name from the active UISkin's
	 *						MouseCursorMap
	 *
	 * @return	TRUE if the cursor was successfully changed.  FALSE if the cursor name was invalid or wasn't found in the current
	 *			skin's MouseCursorMap
	 */
	virtual UBOOL ChangeMouseCursor( FName CursorName );

	/**
	 * Adds the specified scene to the list of active scenes, loading the scene and performing initialization as necessary.
	 *
	 * @param	Scene			the scene to open; if the scene specified is contained in a content package, a copy of the scene will be created
	 *							and the copy will be opened instead.
	 * @param	SceneOwner		the player that should be associated with the new scene.  Will be assigned to the scene's
	 *							PlayerOwner property.
	 * @param	OpenedScene		the scene that was actually opened.  If Scene is located in a content package, OpenedScene will be
	 *							the copy of the scene that was created.  Otherwise, OpenedScene will be the same as the scene passed in.
	 * @param	ForcedPriority	overrides the scene's SceneStackPriority value to allow callers to modify where the scene is placed in the stack.
	 *
	 * @return TRUE if the scene was successfully opened
	 */
	virtual UBOOL OpenScene( UUIScene* Scene, ULocalPlayer* SceneOwner=NULL, UUIScene** OpenedScene=NULL, BYTE ForcedPriority=UCONST_DEFAULT_SCENE_PRIORITY );

	/**
	 * Instances, initializes, and activates the specified scene, inserting it into the scene stack at the specified location.
	 *
	 * @param	DesiredInsertIndex	the index [into the ActiveScenes array] to insert the scene.  the scene's SceneStackPriority will take precedence over this value.
	 * @param	Scene				the scene to open; if the scene specified is contained in a content package, a copy of the scene will be created
	 *								and the copy will be opened instead.
	 * @param	SceneOwner			the player that should be associated with the new scene.  Will be assigned to the scene's
	 *								PlayerOwner property.
	 * @param	OpenedScene			the scene that was actually opened.  If Scene is located in a content package, OpenedScene will be
	 *								the copy of the scene that was created.  Otherwise, OpenedScene will be the same as the scene passed in.
	 * @param	ActualInsertIndex	receives the location where the scene was actually inserted into the scene stack.
	 * @param	ForcedPriority		overrides the scene's SceneStackPriority value to allow callers to modify where the scene is placed in the stack.
	 *
	 * @return TRUE if the scene was successfully activated and inserted into the scene stack (although not necessarily at the DesiredSceneIndex)
	 */
	virtual UBOOL InsertScene( INT DesiredInsertIndex, UUIScene* Scene, ULocalPlayer* SceneOwner=NULL, UUIScene** OpenedScene=NULL, INT* ActualInsertIndex=NULL, BYTE ForcedPriority=UCONST_DEFAULT_SCENE_PRIORITY );

	/**
	 * Instances, initializes, and activates a scene, replacing an existing scene's location in the scene stack.  The existing scene will be deactivated and no longer part
	 * of the scene stack.  The location in the scene stack for the new scene instance may be modified if its SceneStackPriority requires the scene stack to be resorted.
	 *
	 * @param	SceneInstanceToReplace	the scene that should be replaced.
	 * @param	SceneToOpen				the scene that will replace the existing scene.  If the scene specified is contained in a content package, the scene will be duplicated and
	 *									the duplicate will be added instead.
	 * @param	SceneOwner				the player that should be associated with the new scene.  Will be assigned to the scene's
	 *									PlayerOwner property.
	 * @param	OpenedScene				the scene that was actually opened.  If Scene is located in a content package, OpenedScene will be
	 *									the copy of the scene that was created.  Otherwise, OpenedScene will be the same as the scene passed in.
	 * @param	ForcedPriority			overrides the scene's SceneStackPriority value to allow callers to modify where the scene is placed in the stack.
	 *
	 * @return TRUE if the scene was successfully activated and inserted into the scene stack (although not necessarily at the DesiredSceneIndex)
	 */
	virtual UBOOL ReplaceScene( UUIScene* SceneInstanceToReplace, UUIScene* SceneToOpen, ULocalPlayer* SceneOwner=NULL, UUIScene** OpenedScene=NULL, BYTE ForcedPriority=UCONST_DEFAULT_SCENE_PRIORITY );

	/**
	 * Instances, initializes, and activates a scene, replacing an existing scene's location in the scene stack.  The existing scene will be deactivated and no longer part
	 * of the scene stack.  The location in the scene stack for the new scene instance may be modified if its SceneStackPriority requires the scene stack to be resorted.
	 *
	 * @param	IndexOfSceneToReplace	the index into the stack of scenes for the scene to be replaced.
	 * @param	SceneToOpen				the scene that will replace the existing scene.  If the scene specified is contained in a content package, the scene will be duplicated and
	 *									the duplicate will be added instead.
	 * @param	SceneOwner				the player that should be associated with the new scene.  Will be assigned to the scene's
	 *									PlayerOwner property.
	 * @param	OpenedScene				the scene that was actually opened.  If Scene is located in a content package, OpenedScene will be
	 *									the copy of the scene that was created.  Otherwise, OpenedScene will be the same as the scene passed in.
	 * @param	ForcedPriority			overrides the scene's SceneStackPriority value to allow callers to modify where the scene is placed in the stack.
	 *
	 * @return TRUE if the scene was successfully activated and inserted into the scene stack (although not necessarily at the DesiredSceneIndex)
	 */
	virtual UBOOL ReplaceSceneAtIndex( INT IndexOfSceneToReplace, UUIScene* SceneToOpen, ULocalPlayer* SceneOwner=NULL, UUIScene** OpenedScene=NULL, BYTE ForcedPriority=UCONST_DEFAULT_SCENE_PRIORITY );

	/**
	 * Deactivates the specified scene and removes it from the stack of scenes.
	 *
	 * @param	Scene				the scene to deactivate
	 * @param	bCloseChildScenes	normally any scenes which are higher in the stack than the scene being closed are also closed.  Specify
	 *								FALSE To override this behavior.
	 * @param	bForceCloseImmediately
	 *								indicates that the result of calling the scene's OnQueryCloseSceneAllowed delegate should be ignored; used
	 *								when closing all scenes as the result of a map change, for example.
	 *
	 * @return true if the scene was successfully deactivated
	 */
	virtual UBOOL CloseScene( UUIScene* Scene, UBOOL bCloseChildScenes=TRUE, UBOOL bForceCloseImmediately=FALSE );

	/**
	 * Deactivates the scene located at the specified index in the stack of scenes.
	 *
	 * @param	SceneStackIndex		the index in the stack of scenes for the scene that should be deactivated
	 * @param	bCloseChildScenes	normally any scenes which are higher in the stack than the scene being closed are also closed.  Specify
	 *								FALSE To override this behavior.
	 * @param	bForceCloseImmediately
	 *								indicates that the result of calling the scene's OnQueryCloseSceneAllowed delegate should be ignored; used
	 *								when closing all scenes as the result of a map change, for example.
	 *
	 * @return true if the scene was successfully deactivated
	 */
	virtual UBOOL CloseSceneAtIndex( INT SceneStackIndex, UBOOL bCloseChildScenes=TRUE, UBOOL bForceCloseImmediately=FALSE );

	/**
	 * Called once a frame to update the UI's state.
	 *
	 * @param	DeltaTime - The time since the last frame.
	 */
	virtual void Tick(FLOAT DeltaTime);

	/**
	 * Render all the active scenes
	 */
	virtual void RenderScenes( FCanvas* Canvas );

	/**
	 * Re-initializes all primitives in the specified scene.  Will occur on the next tick.
	 *
	 * @param	Sender	the scene to re-initialize primitives for.
	 */
	virtual void RequestPrimitiveReinitialization( UUIScene* Sender );

	/**
	 * Gives all UIScenes a chance to create, attach, and/or initialize any primitives contained in the UIScene.
	 *
	 * @param	CanvasScene		the scene to use for attaching any 3D primitives
	 */
	virtual void InitializePrimitives( FCanvasScene* CanvasScene );

	/**
	 * Updates 3D primitives for all active scenes
	 *
	 * @param	CanvasScene		the scene to use for attaching any 3D primitives
	 */
	virtual void UpdateActivePrimitives( FCanvasScene* CanvasScene );

private:
	/**
	 * @return	TRUE if the scene meets the conditions defined by the bitmask specified.
	 */
	UBOOL SceneMatchesFilter( DWORD FilterFlagMask, UUIScene* TestScene ) const;

	#if WITH_GFx
	/**
	 * @return	TRUE if the scene meets the conditions defined by the bitmask specified.
	 */
	UBOOL GFxMovieMatchesFilter( DWORD FilterFlagMask, class FGFxMovie* TestMovie ) const;
	#endif //WITH_GFx
public:
	/**
	 * Returns true if there is an unhidden fullscreen UI active
	 *
	 * @param	Flags	modifies the logic which determines wether hte UI is active
	 *
	 * @return TRUE if the UI is currently active
	 */
	virtual UBOOL IsUIActive( DWORD Flags=SCENEFILTER_Any ) const;

	/**
	 * Returns whether the specified scene has been fully initialized.  Different from UUIScene::IsInitialized() in that this
	 * method returns true only once all objects related to this scene have been created and initialized (e.g. in the UI editor
	 * only returns TRUE once the editor window for this scene has finished creation).
	 *
	 * @param	Scene	the scene to check.
	 */
	virtual UBOOL IsSceneInitialized( const UUIScene* Scene ) const;

protected:

	/**
	 * Gets the list of scenes that should be rendered.  Some active scenes might not be rendered if scenes later in the
	 * scene stack prevent it, for example.
	 */
	virtual void GetScenesToRender( TArray<UUIScene*>& ScenesToRender );

	/**
	 * Determines whether the scene will become the topmost scene and (if necessary) adjusts the desired stack index and requested priority
	 * if the requested values aren't compatible with the scene client's current state and active scenes.
	 *
	 * @param	SceneToActivate			the scene that is being activated
	 * @param	DesiredStackIndex		the desired location [into the ActiveScenes array] for the new scene.  A value of INDEX_NONE indicates
	 *									that the scene should be added to the top of the stack.  Value will be set to the actual index that the
	 *									scene should be inserted.
	 * @param	DesiredScenePriority	the priority to use for the new scene.  Any scenes with a SceneStackPriority higher than this value
	 *									will remain on top.
	 *
	 * @return	TRUE if the new scene will become the topmost scene.
	 */
	UBOOL ValidateDesiredStackIndex( UUIScene* SceneToActivate, INT& DesiredStackIndex, INT& DesiredStackPriority ) const;

	/**
	 * Adds the specified scene to the list of active scenes.
	 *
	 * @param	SceneToActivate		the scene to activate
	 * @param	DesiredStackIndex	the location in the list of active scenes to put the new scene.  If INDEX_NONE
	 *								is specified, the scene is added to the top of the stack.
	 * @param	ForcedPriority		overrides the scene's SceneStackPriority value to allow callers to modify where the scene is placed in the stack.
	 */
	virtual void ActivateScene( UUIScene* SceneToActivate, INT DesiredStackIndex=INDEX_NONE, BYTE ForcedScenePriority=0 );

	/**
	 * Removes the specified scene from the list of active scenes.  If this scene is not the top-most scene, all
	 * scenes which occur after the specified scene in the ActiveScenes array will be deactivated as well.
	 *
	 * @param	SceneToDeactivate	the scene to remove
	 * @param	bCloseChildScenes	normally any scenes which are higher in the stack than the scene being closed are also closed.  Specify
	 *								FALSE To override this behavior.
	 * @param	bForceCloseImmediately
	 *								indicates that the result of calling the scene's OnQueryCloseSceneAllowed delegate should be ignored; used
	 *								when closing all scenes as the result of a map change, for example.
	 *
	 * @return	TRUE if the scene was successfully removed from the list of active scenes.
	 */
	virtual UBOOL DeactivateScene( UUIScene* SceneToDeactivate, UBOOL bCloseChildScenes=TRUE, UBOOL bForceCloseImmediately=FALSE );

	/**
	 * Searches all scenes to determine if any are configured to display a cursor.  Sets the value of bRenderCursor accordingly.
	 */
	virtual void UpdateCursorRenderStatus();

	/**
	 * Updates the value of UIInteraction.bProcessingInput to reflect whether any scenes are capable of processing input.
	 */
	void UpdateInputProcessingStatus();

	/**
	 * Clears the arrays of pressed keys for all local players in the game; used when the UI begins processing input.  Also
	 * updates the InitialPressedKeys maps for all players.
	 */
	void FlushPlayerInput();

	/**
	 * Renders debug information to the screen canvas.
	 */
	virtual void RenderDebugInfo( FCanvas* Canvas );

public:
	/**
	 * Ensures that the game's paused state is appropriate considering the state of the UI.  If any scenes are active which require
	 * the game to be paused, pauses the game...otherwise, unpauses the game.
	 *
	 * @param	PlayerIndex		the index of the player that owns the scene that was just added or removed, or 0 if the scene didn't have
	 *							a player owner.
	 */
	virtual void UpdatePausedState( INT PlayerIndex );
}

/* == Delegates == */

/* == Natives == */
/**
 * @return	the current netmode, or NM_MAX if there is no valid world
 */
native static final function WorldInfo.ENetMode GetCurrentNetMode();

/**
 * Get a reference to the transient scene, which is used to contain transient widgets that are created by unrealscript
 *
 * @return	pointer to the UIScene that owns transient widgets
 */
native final function UIScene GetTransientScene() const;

/**
 * Creates an instance of the scene class specified.  Used to create scenes from unrealscript.  Does not initialize
 * the scene - you must call OpenScene, passing in the result of this function as the scene to be opened.
 *
 * @param	SceneClass		the scene class to open
 * @param	SceneTag		if specified, the scene will be given this tag when created
 * @param	SceneTemplate	if specified, will be used as the template for the newly created scene if it is a subclass of SceneClass
 *
 * @return	a UIScene instance of the class specified
 */
native final noexport function coerce UIScene CreateScene( class<UIScene> SceneClass, optional name SceneTag, optional UIScene SceneTemplate );

/**
 * Create a temporary widget for presenting data from unrealscript
 *
 * @param	WidgetClass		the widget class to create
 * @param	WidgetTag		the tag to assign to the widget.
 * @param	Owner			the UIObject that should contain the widget
 *
 * @return	a pointer to a fully initialized widget of the class specified, contained within the transient scene
 * @todo - add support for metacasting using a property flag (i.e. like spawn auto-casts the result to the appropriate type)
 */
native final function coerce UIObject CreateTransientWidget( class<UIObject> WidgetClass, Name WidgetTag, optional UIObject Owner );

/**
 * Searches through the ActiveScenes array for a UIScene with the tag specified
 *
 * @param	SceneTag	the name of the scene to locate
 * @param	SceneOwner	if specified, only scenes that have the specified SceneOwner will be considered.
 *
 * @return	pointer to the UIScene that has a SceneName matching SceneTag, or NULL if no scenes in the ActiveScenes
 *			stack have that name
 */
native final function UIScene FindSceneByTag( name SceneTag, optional LocalPlayer SceneOwner ) const;

/**
 * Searches through the ActiveScenes array for a UIScene with the tag specified
 *
 * @param	SceneToFind	the scene to locate
 *
 * @return	index [into the ActiveScenes array] for the scene specified, or INDEX_NONE
 *			if it isn't found.
 */
native final function int FindSceneIndex( const UIScene SceneToFind ) const;

/**
 * Accessor for getting a reference to a scene at a given index
 *
 * @param	SceneIndex	should be an index into the ActiveScenes array for the scene to get a reference to.
 *
 * @return	the scene instance at the specified location in the ActiveScenes array, or None or the index was invalid.
 */
native final function UIScene GetSceneAtIndex( int SceneIndex ) const;

/**
 * Searches through the ActiveScenes array for a UIScene with the tag specified
 *
 * @param	SceneTag	the name of the scene to locate
 *
 * @return	index [into the ActiveScenes array] for the scene specified, or INDEX_NONE
 *			if it isn't found.
 */
native final function int FindSceneIndexByTag( name SceneTag, optional LocalPlayer SceneOwner ) const;

/**
 * Accessor for getting the number of currently active scenes.
 *
 * @param	MatchingPlayerOwner		if specified, only scenes with this PlayerOwner will be counted.
 * @param	bIgnoreUnfocusedScenes	specify TRUE to skip scenes which cannot accept focus (i.e. bNeverFocus = true)
 *
 * @return	the number of active scenes which meet the criteria specified by the input parameters.
 */
native final function int GetActiveSceneCount( optional LocalPlayer MatchingPlayerOwner, optional bool bIgnoreUnfocusedScenes ) const;

/**
 * Wrapper for getting a reference to the currently active scene.
 *
 * @param	MatchingPlayerOwner		if specified, the top-most scene with this player as its PlayerOwner will be returned.
 * @param	bIgnoreUnfocusedScenes	specify TRUE to only return the top-most scenes that can accept focus.
 *
 * @return	a reference to the top-most scene in the scene stack which meets the conditions of the input parameters.
 */
native final function UIScene GetActiveScene( optional LocalPlayer MatchingPlayerOwner, optional bool bIgnoreUnfocusedScenes ) const;

/**
 * Accessor for getting a reference to a scene's "parent" scene.
 *
 * @param	SourceScene						the scene to find a parent scene for
 * @param	bRequireMatchingPlayerOwner		indicates whether the returned scene must be a scene opened by the same player as SourceScene.
 * @param	bIgnoreUnfocusedScenes			indicates that scenes which cannot accept focus should be skipped.
 *
 * @return	a reference to the next scene below SourceScene in the ActiveScenes array which meets the criteria specified by the input
 *			parameters, or None if there isn't one.
 */
native final function UIScene GetPreviousScene( const UIScene SourceScene, optional bool bRequireMatchingPlayerOwner=true, optional bool bIgnoreUnfocusedScenes ) const;

/**
 * Accessor for getting a reference to a scene's "parent" scene based on the scene's index in the ActiveScenes array.
 *
 * @param	StartingSceneIndex		the index into the ActiveScenes array of the scene to find a parent scene for
 * @param	MatchingPlayerOwner		if specified, only scenes owned by this player will be considered.
 * @param	bIgnoreUnfocusedScenes	indicates that scenes which cannot accept focus should be skipped.
 *
 * @return	a reference to the next scene below the source scene in the ActiveScenes array which meets the criteria specified by the input
 *			parameters, or None if there isn't one.
 */
native final function UIScene GetPreviousSceneFromIndex( int StartingSceneIndex, optional LocalPlayer MatchingPlayerOwner, optional bool bIgnoreUnfocusedScenes ) const;

/**
 * Accessor for getting a reference to the first parent scene of SourceScene, that can process input for SourceScene's PlayerOwner.
 *
 * @param	SourceScene						the scene to find a parent scene for
 * @param	bIgnoreUnfocusedScenes			indicates that scenes which cannot accept focus should be skipped.
 *
 * @return	a reference to the next scene below SourceScene in the ActiveScenes array which meets the criteria specified by the input
 *			parameters, or None if there isn't one.
 */
native final function UIScene GetPreviousInputProcessingScene( const UIScene SourceScene, optional bool bIgnoreUnfocusedScenes=true ) const;

/**
 * Accessor for getting a reference to a scene's "child" scene.
 *
 * @param	SourceScene						the scene to find a child scene for
 * @param	bRequireMatchingPlayerOwner		indicates whether the returned scene must be a scene opened by the same player as SourceScene.
 * @param	bIgnoreUnfocusedScenes			indicates that scenes which cannot accept focus should be skipped.
 *
 * @return	a reference to the next scene above SourceScene in the ActiveScenes array which meets the criteria specified by the input
 *			parameters, or None if there isn't one.
 */
native final function UIScene GetNextScene( const UIScene SourceScene, optional bool bRequireMatchingPlayerOwner=true, optional bool bIgnoreUnfocusedScenes ) const;

/**
 * Accessor for getting a reference to a scene's "child" scene.
 *
 * @param	StartingSceneIndex		the scene to find a child scene for
 * @param	MatchingPlayerOwner		if specified, only scenes owned by this player will be considered.
 * @param	bIgnoreUnfocusedScenes	indicates that scenes which cannot accept focus should be skipped.
 *
 * @return	a reference to the next scene above the source scene in the ActiveScenes array which meets the criteria specified by the input
 *			parameters, or None if there isn't one.
 */
native final function UIScene GetNextSceneFromIndex( int StartingSceneIndex, optional LocalPlayer MatchingPlayerOwner, optional bool bIgnoreUnfocusedScenes ) const;

/**
 * Iterates over all scenes in the active scenes array.
 *
 * @param	SceneClass			only scenes derived from this class will be returned.
 * @param	OutScene			receives the value of each scene in the ActiveScenes array which meets the criteria of the input parameters.
 * @param	bIterateBackwards	indicates that the scenes should be returned in reverse order.
 * @param	StartingIndex		allows callers to specify a specific location into the ActiveScenes array to start the iteration.
 * @param	SceneFilterMask		allows callers to control the types of scenes allowed.  The value should be a bitmask of the SCENEFILTER_
 *								const values defined in UISceneClient.
 */
native final iterator function AllActiveScenes( class<UIScene> SceneClass, out UIScene OutScene, optional bool bIterateBackwards, optional int StartingIndex=INDEX_NONE, optional int SceneFilterMask=SCENEFILTER_Any );

/**
 * Triggers a call to UpdateInputProcessingStatus on the next Tick().
 */
native final function RequestInputProcessingUpdate();

/**
 * Triggers a call to UpdateCursorRenderStatus on the next Tick().
 */
native final function RequestCursorRenderUpdate();

/**
 * Callback which allows the UI to prevent unpausing if scenes which require pausing are still active.
 * @see PlayerController.SetPause
 */
native final function bool CanUnpauseInternalUI();

/**
 * Changes this scene client's ActiveControl to the specified value, which might be NULL.  If there is already an ActiveControl
 *
 * @param	NewActiveControl	the widget that should become to ActiveControl, or NULL to clear the ActiveControl.
 *
 * @return	TRUE if the ActiveControl was updated successfully.
 */
native function bool SetActiveControl( UIObject NewActiveControl );

/* == Events == */

/**
 * Wrapper for pausing the game.
 *
 * @param	bDesiredPauseState	TRUE indicates that the game should be paused.
 * @param	PlayerIndex			the index [into Engine GamePlayers array] for the player that should be used for pausing the game; can
 *								affect whether the game is actually paused or not (i.e. if the player is an admin in a multi-player match,
 *								for example).
 */
event PauseGame( bool bDesiredPauseState, optional int PlayerIndex=0 )
{
	local PlayerController PlayerOwner;

	if ( GamePlayers.Length > 0 )
	{
		PlayerIndex = Clamp(PlayerIndex, 0, GamePlayers.Length - 1);
		PlayerOwner = GamePlayers[PlayerIndex].Actor;
		if ( PlayerOwner != None )
		{
			PlayerOwner.SetPause(bDesiredPauseState, CanUnpauseInternalUI);
		}
	}
}

/**
 * Returns whether widget tooltips should be displayed.
 */
event bool CanShowToolTips()
{
	// if tooltips are disabled globally, can't show them
	if ( bDisableToolTips )
		return false;

	// the we're currently dragging a slider or resizing a list column or something, don't display tooltips
//	if ( ActivePage != None && ActivePage.bCaptureMouse )
//		return false;
//
	// if we're currently in the middle of a drag-n-drop operation, don't show tooltips
//	if ( DropSource != None || DropTarget != None )
//		return false;

	return true;
}

/**
 * Called when the scene client is first initialized.
 */
event InitializeSceneClient()
{
	local OnlineSubsystem OnlineSub;

	Super.InitializeSceneClient();

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if ( OnlineSub != None )
	{
		if ( OnlineSub.SystemInterface != None)
		{
			// Set the system wide connection changed callback
			OnlineSub.SystemInterface.AddConnectionStatusChangeDelegate(NotifyOnlineServiceStatusChanged);
			OnlineSub.SystemInterface.AddLinkStatusChangeDelegate(NotifyLinkStatusChanged);
			OnlineSub.SystemInterface.AddControllerChangeDelegate(NotifyControllerChanged);
			OnlineSub.SystemInterface.AddStorageDeviceChangeDelegate(NotifyStorageDeviceChanged);
		}
		else
		{
			`log(`location @ "no Online System interface found!",,'DevOnline');
		}

		if ( OnlineSub.PlayerInterface != None )
		{
			// this is a little silly....but it's the only way to get reliable notifications...
			OnlineSub.PlayerInterface.AddLoginChangeDelegate(OnLoginChange);
		}
		else
		{
			`log(`location @ "no Online Player interface found!",,'DevOnline');
		}
	}
	else
	{
		`log(`location @ "no OnlineSubsystem found!",,'DevOnline');
	}
}

/**
 * Synchronizes the number of local players to the number of signed-in controllers.  Games should override this method if more complex
 * logic is desired (for example, if inactive gamepads [gamepads that are signed in but not associated with a player] are allowed).
 *
 * @param	bAllowJoins					controls whether creating new player is allowed; if true, a player will be created for any gamepad
 *										that is signed into a profile and not already associated with a player (up to MAX_SUPPORTED_GAMEPADS)
 * @param	bAllowRemoval				controls whether removing players is allowed; if true, any existing players that are not signed into
 *										a profile will be removed.
 *
 * @note: if both bAllowJoins and bAllowRemoval are FALSE, only effect will be removal of extra players (i.e. player count higher than
 *	MAX_SUPPORTED_GAMEPADS)
 */
event SynchronizePlayers(optional bool bAllowJoins=true, optional bool bAllowRemoval=true )
{
	local int PlayerIndex, ControllerId;
	local string ErrorString;
	local LocalPlayer PlayerRef;

	if ( IsAllowedToModifyPlayerCount() )
	{
		for ( ControllerId = 0; ControllerId < MAX_SUPPORTED_GAMEPADS; ControllerId++ )
		{
			PlayerIndex = GetPlayerIndex(ControllerId);
			if ( IsGamepadConnected(ControllerId) )
			{
				if ( PlayerIndex == INDEX_NONE && bAllowJoins )
				{
					// found a gamepad that is connected but has no player associated with it.
					if ( GamePlayers.Length < MAX_SUPPORTED_GAMEPADS )
					{
						`log(`location @ "attempting to create a new local player -" @ `showvar(ControllerId));
						PlayerRef = CreatePlayer(ControllerId, ErrorString, true);
					}
					else
					{
						`log(`location @ "unable to create player for gamepad" @ ControllerId @ "because the max player count has been reached (" $ MAX_SUPPORTED_GAMEPADS $ ")");
					}
				}
			}
			else if ( PlayerIndex != INDEX_NONE && bAllowRemoval && !IsLoggedIn(ControllerId) )
			{
				PlayerRef = GamePlayers[PlayerIndex];

				// found an existing player that is no longer logged in
				if ( GamePlayers.Length > 1 )
				{
					`log(`location @ "attempting to remove local player that is no longer signed-in:" @ `showvar(ControllerId) @ "(" $ `showvar(PlayerIndex) $ ")");
					if ( !RemovePlayer(PlayerRef) )
					{
						`warn(`location @ "failed to remove player at index" @ PlayerIndex $ "!");
					}
				}
				else
				{
					`log(`location @ "player" @ PlayerIndex @ "is no longer signed-in but cannot be removed because it is the last player");
				}
			}
		}

		// remove any extra players
		while ( GamePlayers.Length > Max(1, MAX_SUPPORTED_GAMEPADS) )
		{
			`log(`location @ "attempting to remove local player to match the maximum number of players allowed:" @ `showvar(ControllerId) @ "(" $ `showvar(PlayerIndex) $ ")");
			PlayerRef = GamePlayers[PlayerIndex];
			if ( !RemovePlayer(PlayerRef) )
			{
				`warn(`location @ "failed to remove player at index" @ PlayerIndex $ "!");
			}
		}
	}
}

/* == Unrealscript == */
/**
 * Accessor for controlling whether the scene client is allowed to add or remove players.
 */
function bool IsAllowedToModifyPlayerCount()
{
	return bSynchronizePlayers;
}

/**
 * Called when the local player is about to travel to a new URL.  This callback should be used to perform any preparation
 * tasks, such as updating status text and such.  All cleanup should be done from NotifyGameSessionEnded, as that function
 * will be called in some cases where NotifyClientTravel is not.
 *
 * @param	TravellingPlayer	the player that received the call to ClientTravel
 * @param	TravelURL			a string containing the mapname (or IP address) to travel to, along with option key/value pairs
 * @param	TravelType			indicates whether the player will clear previously added URL options or not.
 * @param	bIsSeamlessTravel	indicates whether seamless travelling will be used.
 */
function NotifyClientTravel( PlayerController TravellingPlayer, string TravelURL, ETravelType TravelType, bool bIsSeamlessTravel )
{
	local int SceneIndex;
	local array<UIScene> CurrentlyActiveScenes;
	local UIScene NextScene;
	local LocalPlayer TravellingLP;

	if ( TravellingPlayer != None )
	{
		TravellingLP = LocalPlayer(TravellingPlayer.Player);
	}

	// copy the list of active scenes into a temporary array in case scenes start removing themselves when
	// they receive this notification
	CurrentlyActiveScenes = ActiveScenes;

	// propagate the notification to all scenes that are relevant to this player, starting with the most recently
	// opened scene (or the top-most, anyway)
	for ( SceneIndex = CurrentlyActiveScenes.Length - 1; SceneIndex >= 0; SceneIndex-- )
	{
		NextScene = CurrentlyActiveScenes[SceneIndex];
		if ( NextScene != None
		&&	(NextScene.PlayerOwner == TravellingLP || NextScene.PlayerOwner == None) )
		{
			NextScene.NotifyPreClientTravel(TravelURL, TravelType, bIsSeamlessTravel);
		}
	}
}

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 */
function NotifyGameSessionEnded()
{
	local int i;
	local array<UIScene> CurrentlyActiveScenes;

	// bPendingLevelChange = true;
	SaveMenuProgression();

	// copy the list of active scenes into a temporary array in case scenes start removing themselves when
	// they receive this notification
	CurrentlyActiveScenes = ActiveScenes;

	// starting with the most recently opened scene (or the top-most, anyway), notify them all that the
	// map is about to change
	for ( i = CurrentlyActiveScenes.Length - 1; i >= 0; i-- )
	{
		if ( CurrentlyActiveScenes[i] != None )
		{
			CurrentlyActiveScenes[i].NotifyGameSessionEnded();
		}
		else
		{
			CurrentlyActiveScenes.Remove(i,1);
		}
	}

	// if any scenes are still open (usually due to not calling Super.NotifyGameSessionEnded()) try to close them again
	for ( i = CurrentlyActiveScenes.Length - 1; i >= 0; i-- )
	{
		if ( CurrentlyActiveScenes[i].bCloseOnLevelChange )
		{
			CurrentlyActiveScenes[i].CloseScene(CurrentlyActiveScenes[i], true, true);
		}
	}
}

function OnLoginChange(byte ControllerId)
{
	local UIScene Scene;
	local ELoginStatus Status;

	Status = GetLoginStatus(ControllerId);
	Scene = GetActiveScene();
	if ( Scene != None )
	{
		Scene.NotifyLoginStatusChanged(ControllerId, Status);
	}
}

/**
 * Called when a gamepad (or other controller) is inserted or removed)
 *
 * @param	ControllerId	the id of the gamepad that was added/removed.
 * @param	bConnected		indicates the new status of the gamepad.
 */
function NotifyControllerChanged( int ControllerId, bool bConnected )
{
	local UIScene Scene;

	`log(`location @ `showvar(ControllerId) @ `showvar(bConnected) ,,'RON_DEBUG');
	Scene = GetActiveScene();
	if ( Scene != None )
	{
		Scene.NotifyControllerStatusChanged(ControllerId, bConnected);
	}
}

/**
 * Called when a system level connection change notification occurs.
 *
 * @param ConnectionStatus the new connection status.
 */
function NotifyOnlineServiceStatusChanged( EOnlineServerConnectionStatus NewConnectionStatus )
{
	local UIScene Scene;

	Scene = GetActiveScene();
	if ( Scene != None )
	{
		Scene.NotifyOnlineServiceStatusChanged(NewConnectionStatus);
	}
}

/**
 * Called when the status of the platform's network connection changes.
 */
function NotifyLinkStatusChanged( bool bConnected )
{
	local UIScene Scene;

	Scene = GetActiveScene();
	if ( Scene != None )
	{
		Scene.NotifyLinkStatusChanged(bConnected);
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
	local int SceneIndex;
	local array<UIScene> CurrentScenes;

	// notify all currently active scenes about the new player
	CurrentScenes = ActiveScenes;
	for ( SceneIndex = 0; SceneIndex < CurrentScenes.Length; SceneIndex++ )
	{
		CurrentScenes[SceneIndex].NotifyPlayerAdded(PlayerIndex, AddedPlayer);
	}

//	`log(`location @ `showvar(PlayerIndex) @ `showvar(AddedPlayer) @ `showvar(bUpdateSceneViewportSizes));
	if ( IsUIActive(SCENEFILTER_InputProcessorOnly) )
	{
		RequestInputProcessingUpdate();
	}
}

/**
 * Called when a player has been removed from the list of active players (i.e. split-screen players)
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was located
 * @param	RemovedPlayer	the player that was removed
 */
function NotifyPlayerRemoved( int PlayerIndex, LocalPlayer RemovedPlayer )
{
	local int SceneIndex;
	local array<UIScene> CurrentScenes;

	// notify all currently active scenes about the player removal
	CurrentScenes = ActiveScenes;
	for ( SceneIndex = 0; SceneIndex < CurrentScenes.Length; SceneIndex++ )
	{
		CurrentScenes[SceneIndex].NotifyPlayerRemoved(PlayerIndex, RemovedPlayer);
	}

	if ( IsUIActive(SCENEFILTER_InputProcessorOnly) )
	{
		RequestInputProcessingUpdate();
	}
}

/**
 * Called when a storage device is inserted or removed.
 */
function NotifyStorageDeviceChanged()
{
	local UIScene Scene;

	Scene = GetActiveScene();
	if ( Scene != None )
	{
		Scene.NotifyStorageDeviceChanged();
	}
}

/**
 * Stores the list of currently active scenes which are restorable to the Registry data store for retrieval when
 * returning back to the front end menus.
 */
function SaveMenuProgression()
{
	local DataStoreClient DSClient;
	local UIDataStore_Registry RegistryDS;
	local UIDynamicFieldProvider RegistryProvider;
	local int i;
	local UIScene SceneResource, CurrentScene, NextScene;
	local string ScenePathName;

	// can only restore menu progression in the front-end
	if ( class'WorldInfo'.static.IsMenuLevel() )
	{
		DSClient = class'UIInteraction'.static.GetDataStoreClient();
		if ( DSClient != None )
		{
			RegistryDS = UIDataStore_Registry(DSClient.FindDataStore('Registry'));
			if ( RegistryDS != None )
			{
				RegistryProvider = RegistryDS.GetDataProvider();
				if ( RegistryProvider != None )
				{
					// clear out any existing values.
					RegistryProvider.ClearCollectionValueArray('MenuProgression');

					`log("Storing menu progression (" $ ActiveScenes.Length @ "open scenes)",,'DevUI');
					for ( i = 0; i < ActiveScenes.Length - 1; i++ )
					{
						// for each open scene, check to see if the next scene in the stack is configured to be restored
						//@todo - this assumes that the scene stack is completely linear; this code may need to be altered
						// if your game doesn't have a linear scene progression.
						CurrentScene = ActiveScenes[i];
						NextScene = ActiveScenes[i + 1];

						if ( CurrentScene != None && NextScene != None && CurrentScene != NextScene )
						{
							// for each scene, we use the scene's tag as the "key" or CellTag in the Registry's 'MenuProgression'
							// collection array.  if the next scene in the stack can be restored, store the path name of its
							// archetype as the value for this scene's entry in the menu progression.  Basically we just want to
							// remember which scene should be opened next when this scene is opened.
							if ( NextScene.bMenuLevelRestoresScene )
							{
								SceneResource = UIScene(NextScene.ObjectArchetype);
								if ( SceneResource != None )
								{
									ScenePathName = PathName(SceneResource);
									if ( RegistryProvider.InsertCollectionValue(
										'MenuProgression', ScenePathName, INDEX_NONE, false, false, CurrentScene.SceneTag) )
									{
										`log("Storing" @ ScenePathName @ "as next menu in progression for" @ CurrentScene.SceneTag,,'DevUI');

										//@todo - call a function in NextScene to notify it that it has been placed in the list of
										// scenes that will be restored.  This allows the scene to store additional information,
										// such as the currently active tab page [for scenes which have tab controls].
									}
									else
									{
										`warn("Failed to store scene '" $ ScenePathName $ "' menu progression in Registry");
										break;
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

/**
 * Clears out any existing stored menu progression values.
 */
function ClearMenuProgression()
{
	local DataStoreClient DSClient;
	local UIDataStore_Registry RegistryDS;
	local UIDynamicFieldProvider RegistryProvider;

	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		RegistryDS = UIDataStore_Registry(DSClient.FindDataStore('Registry'));
		if ( RegistryDS != None )
		{
			RegistryProvider = RegistryDS.GetDataProvider();
			if ( RegistryProvider != None )
			{
				// clear out the stored menu progression
				RegistryProvider.ClearCollectionValueArray('MenuProgression');
			}
		}
	}
}

/**
 * Re-opens the scenes which were saved off to the Registry data store.  Should be called from your game's main front-end
 * menu.
 *
 * @param	BaseScene	the scene to use as the starting point for restoring scenes; if not specified, uses the currently
 *						active scene.
 */
function RestoreMenuProgression( optional UIScene BaseScene )
{
	local DataStoreClient DSClient;
	local UIDataStore_Registry RegistryDS;
	local UIDynamicFieldProvider RegistryProvider;
	local UIScene CurrentScene, NextSceneTemplate, SceneInstance;
	local string ScenePathName;
	local bool bHasValidNetworkConnection;
	local LocalPlayer PlayerOwner;

	bKillRestoreMenuProgression = false;

	// can only restore menu progression in the front-end
	if ( class'WorldInfo'.static.IsMenuLevel() )
	{
		// if no BaseScene was specified, use the currently active scene.
		if ( BaseScene == None && IsUIActive() )
		{
			BaseScene = ActiveScenes[ActiveScenes.Length - 1];
		}

		if ( BaseScene != None )
		{
			DSClient = class'UIInteraction'.static.GetDataStoreClient();
			if ( DSClient != None )
			{
				RegistryDS = UIDataStore_Registry(DSClient.FindDataStore('Registry'));
				if ( RegistryDS != None )
				{
					RegistryProvider = RegistryDS.GetDataProvider();
					if ( RegistryProvider != None )
					{
						`log("Restoring menu progression from '" $ PathName(BaseScene) $ "'",,'DevUI');
						bHasValidNetworkConnection = class'UIInteraction'.static.HasLinkConnection();

						//@fixme splitscreen
						PlayerOwner = GamePlayers[0];
						CurrentScene = BaseScene;
						while ( CurrentScene != None && !bKillRestoreMenuProgression )
						{
							ScenePathName = "";

							// get the path name of the scene that should come after CurrentScene
							if ( RegistryProvider.GetCollectionValue('MenuProgression', 0, ScenePathName, false, CurrentScene.SceneTag) )
							{
								if ( ScenePathName != "" )
								{
									// found it - open the scene.
									NextSceneTemplate = UIScene(DynamicLoadObject(ScenePathName, class'UIScene'));
									if ( NextSceneTemplate != None )
									{
										// if this scene requires a network connection and we don't have one,
										if ( NextSceneTemplate.bRequiresNetwork && !bHasValidNetworkConnection )
										{
											break;
										}

										SceneInstance = CurrentScene.OpenScene(NextSceneTemplate, PlayerOwner,,true);
										if ( SceneInstance != None )
										{
											CurrentScene = SceneInstance;

											//@todo - notify the scene that it has been restored.  This allows the scene to perform
											// additional custom initialization, such as activating a specific page in a tab control, for example.
										}
										else
										{
											`warn("Failed to restore scene '" $ PathName(NextSceneTemplate) $ "': call to OpenScene failed.");
											break;
										}
									}
									else
									{
										`warn("Failed to restore scene '" $ ScenePathName $ "' by name: call to DynamicLoadObject() failed.");
										break;
									}
								}
								else
								{
									`log(`location@"'MenuProgression' value was empty for '" $ PathName(CurrentScene) $ "'",,'DevUI');
									break;
								}
							}
							else
							{
								`log(`location@"No 'MenuProgression' found in the Registry data store for '" $ CurrentScene.SceneTag $ "'",,'DevUI');
								break;
							}
						}

						// clear out the stored menu progression
						RegistryProvider.ClearCollectionValueArray('MenuProgression');
					}
				}
			}
		}
	}
}

/**
 * Utility function for creating an instance of a message box.  The scene must still be activated by calling OpenScene.
 *
 * @param	SceneTag				the name to use for the message box scene.  useful for e.g. preventing multiple copies of the same message from appearing.
 * @param	CustomMessageBoxClass	allows callers to override the default message box class for custom message types.
 * @param	SceneTemplate			optional scene resource to use as the template for the new message box instance.
 *
 * @return	an instance of the message box class specified.
 */
static function UIMessageBoxBase CreateUIMessageBox( name SceneTag, optional class<UIMessageBoxBase> CustomMessageBoxClass=default.MessageBoxClass, optional UIMessageBoxBase SceneTemplate )
{
	local UIMessageBoxBase Result;
	local GameUISceneClient GameSceneClient;

	if ( SceneTag != '' )
	{
		GameSceneClient = class'UIRoot'.static.GetSceneClient();
		if ( GameSceneClient != None )
		{
			Result = GameSceneClient.CreateScene(CustomMessageBoxClass, SceneTag, SceneTemplate);
		}
	}

	return Result;
}

/**
 * Displays a message box using the default message box class.
 *
 * @param	SceneTag			the name to use for the message box scene.  useful for e.g. preventing multiple copies of the same message from appearing.
 * @param	Title				the string or datastore markup to use as the message box title
 * @param	Message				the string or datastore markup to use for the message box text
 * @param	Question			the string or datastore markup to use for the question text
 * @param	ButtonAliases		the list of aliases to use in the message box's button bar; this determines which options are available as well
 *								as which input keys the message box responds to.  Aliases must be registered in the Engine.UIDataStore_InputAlias
 *								section of the input .ini file.
 * @param	SelectionCallback	the function to call when the user selects an option
 * @param	ScenePlayerOwner	the player to associate the message box with.  only this player will be able to dismiss the message box.
 * @param	out_CreatedScene	allows the caller to receive a reference to the scene that was opened.
 * @param	ForcedPriority		allows the player to override the message box class's default scene priority
 *
 * @return	TRUE if the message box was successfully shown.
 */
static function bool ShowUIMessage( name SceneTag, string Title, string Message, string Question, array<name> ButtonAliases, delegate<UIMessageBoxBase.OnOptionSelected> SelectionCallback, optional LocalPlayer ScenePlayerOwner, optional out UIMessageBoxBase out_CreatedScene, optional byte ForcedPriority )
{
	local UIScene ExistingScene;
	local UIMessageBoxBase MessageBox;
	local GameUISceneClient GameSceneClient;
	local bool bResult;

	out_CreatedScene = None;
	GameSceneClient = class'UIRoot'.static.GetSceneClient();
	if ( GameSceneClient != None )
	{
		// see if there is already a message box with the specified tag
		ExistingScene = GameSceneClient.FindSceneByTag(SceneTag, ScenePlayerOwner);
		if ( ExistingScene == None )
		{
			MessageBox = CreateUIMessageBox(SceneTag);
			if ( MessageBox != None )
			{
				ExistingScene = MessageBox.OpenScene(MessageBox, ScenePlayerOwner, ForcedPriority);
				if ( ExistingScene != None )
				{
					MessageBox = UIMessageBoxBase(ExistingScene);
					MessageBox.SetupMessageBox(Title, Message, Question, ButtonAliases, SelectionCallback);
					out_CreatedScene = MessageBox;
					bResult = true;
				}
			}
		}
	}

	return bResult;
}

/**
 * Closes a message box opened with ShowUIMessage.
 *
 * @param	SceneTag			the name of the scene to close; should be the same value passed for SceneTag to ShowUIMessage
 * @param	ScenePlayerOwner	the player associated with the message box
 * @param	bCloseChildScenes	specify TRUE to close any scenes which were opened after the message box.
 *
 * @return	TRUE if the scene was successfully closed.
 */
static function bool ClearUIMessageScene( name SceneTag, optional LocalPlayer ScenePlayerOwner, optional bool bCloseChildScenes=false )
{
	local GameUISceneClient GameSceneClient;
	local UIScene ExistingScene;
	local bool bResult;

	GameSceneClient = class'UIRoot'.static.GetSceneClient();
	if ( GameSceneClient != None )
	{
		// see if there is already a message box with the specified tag
		ExistingScene = GameSceneClient.FindSceneByTag(SceneTag, ScenePlayerOwner);
		if ( ExistingScene != None )
		{
			//@todo - simulate cancel?
			bResult = ExistingScene.CloseScene(ExistingScene, bCloseChildScenes, true);
		}
	}

	return bResult;
}

exec function ShowDockingStacks()
{
	local int i;

	for ( i = 0; i < ActiveScenes.Length; i++ )
	{
		ActiveScenes[i].LogDockingStack();
	}
}

exec function ShowRenderBounds()
{
	local int i;

	for ( i = 0; i < ActiveScenes.Length; i++ )
	{
		ActiveScenes[i].LogRenderBounds(0);
	}
}

exec function ShowMenuStates()
{
	local int i;

	for ( i = 0; i < ActiveScenes.Length; i++ )
	{
		ActiveScenes[i].LogCurrentState(0);
	}
}

exec function ToggleDebugInput( optional bool bEnable=!bEnableDebugInput )
{
	bEnableDebugInput = bEnable;
	`log( (bEnableDebugInput ? "Enabling" : "Disabling") @ "debug input processing");
}

`if(`notdefined(ShippingPC))
exec function CreateMenu( class<UIScene> SceneClass, optional int PlayerIndex=INDEX_NONE )
{
	local UIScene Scene;
	local LocalPlayer SceneOwner;

	`log("Attempting to create script menu '" $ SceneClass $"'");

	Scene = CreateScene(SceneClass);
	if ( Scene != None )
	{
		if ( PlayerIndex != INDEX_NONE )
		{
			SceneOwner = GamePlayers[PlayerIndex];
		}

		OpenScene(Scene, SceneOwner);
	}
	else
	{
		`log("Failed to create menu '" $ SceneClass $"'");
	}
}

exec function OpenMenu( string MenuPath, optional int PlayerIndex=INDEX_NONE )
{
	local UIScene Scene;
	local LocalPlayer SceneOwner;

	`log("Attempting to load menu by name '" $ MenuPath $"'");
	Scene = UIScene(DynamicLoadObject(MenuPath, class'UIScene'));
	if ( Scene != None )
	{
		if ( PlayerIndex != INDEX_NONE )
		{
			SceneOwner = GamePlayers[PlayerIndex];
		}

		OpenScene(Scene,SceneOwner);
	}
	else
	{
		`log("Failed to load menu '" $ MenuPath $"'");
	}
}

exec function CloseMenu( optional name SceneName )
{
	local int i;
	local UIScene Scene;

	if ( SceneName == '' )
	{
		Scene = GetActiveScene();
		if ( Scene != None )
		{
			`log("Closing topmost scene '" $ Scene.GetWidgetPathName() $ "'");
			CloseScene(Scene);
		}
		else
		{
			`log("No scenes currently open");
		}
	}
	else
	{
		for ( i = 0; i < ActiveScenes.Length; i++ )
		{
			if ( ActiveScenes[i].SceneTag == SceneName )
			{
				`log("Closing scene '"$ ActiveScenes[i].GetWidgetPathName() $ "'");
				CloseScene(ActiveScenes[i], false, true);
				return;
			}
		}

		`log("No scenes found in ActiveScenes array with name matching '"$SceneName$"'");
	}
}

exec function ShowDataStoreField( string DataStoreMarkup )
{
	local string Value;

	if ( class'UIRoot'.static.GetDataStoreStringValue(DataStoreMarkup, Value) )
	{
		`log("Successfully retrieved value for markup string (" $ DataStoreMarkup $ "): '" $ Value $ "'");
	}
	else
	{
		`log("Failed to resolve value for data store markup (" $ DataStoreMarkup $ ")");
	}
}

exec function RefreshFormatting()
{
	local UIScene ActiveScene;

	ActiveScene = GetActiveScene(none, true);
	if ( ActiveScene != None )
	{
		`log("Forcing a formatting update and scene refresh for" @ ActiveScene);
		ActiveScene.RequestFormattingUpdate();
	}
}

/**
 * Debug console command for dumping all registered data stores to the log
 *
 * @param	bFullDump	specify TRUE to show detailed information about each registered data store.
 */
exec function ShowDataStores( optional bool bVerbose )
{
	`log("Dumping data store info to log - if you don't see any results, you probably need to unsuppress DevDataStore");

	if ( DataStoreManager != None )
	{
		DataStoreManager.DebugDumpDataStoreInfo(bVerbose);
	}
	else
	{
		`log(Self @ "has a NULL DataStoreManager!",,'DevDataStore');
	}
}

/**
 * Handler for debug message box OnOptionSelected delegate.
 *
 * @param	Sender				the message box that generated this call
 * @param	SelectedInputAlias	the alias of the button that the user selected.  Should match one of the aliases passed into
 *								this message box.
 * @param	PlayerIndex			the index of the player that selected the option.
 *
 * @return	TRUE to indicate that the message box should close itself.
 */
function bool DebugMessageOptionSelected( UIMessageBoxBase Sender, name SelectedInputAlias, int PlayerIndex )
{
	`log(`location @ `showobj(Sender) @ `showvar(SelectedInputAlias) @ `showvar(PlayerIndex));
	return true;
}
exec function DebugShowMessage( string Message, optional string Aliases="GenericCancel,GenericAccept", optional string Title, optional string Question )
{
	local array<string> ButtonAliasStrings;
	local array<name> ButtonAliases;
	local int i;

	if ( Message != "" )
	{
		ParseStringIntoArray(Aliases, ButtonAliasStrings, ",", true);
		ButtonAliases.Length = ButtonAliasStrings.Length;
		for ( i = 0; i < ButtonAliasStrings.Length; i++ )
		{
			ButtonAliases[i] = name(ButtonAliasStrings[i]);
		}

		ShowUIMessage('DebugTestMessage', Title, Message, Question, ButtonAliases, DebugMessageOptionSelected);
	}
}
`endif

exec function ShowMenuProgression()
{
	local DataStoreClient DSClient;
	local UIDataStore_Registry RegistryDS;
	local UIDynamicFieldProvider RegistryProvider;
	local array<string> Values;
	local array<name> SceneTags;
	local int SceneIndex, MenuIndex;

	`log("Current stored menu progression:");
	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		RegistryDS = UIDataStore_Registry(DSClient.FindDataStore('Registry'));
		if ( RegistryDS != None )
		{
			RegistryProvider = RegistryDS.GetDataProvider();
			if ( RegistryProvider != None )
			{
				if ( RegistryProvider.GetCollectionValueSchema('MenuProgression', SceneTags) )
				{
					for ( SceneIndex = 0; SceneIndex < SceneTags.Length; SceneIndex++ )
					{
						if ( RegistryProvider.GetCollectionValueArray('MenuProgression', Values, false, SceneTags[SceneIndex]) )
						{
							for ( MenuIndex = 0; MenuIndex < Values.Length; MenuIndex++ )
							{
								`log("    Scene:" @ SceneTags[SceneIndex] @ "Menu" @ MenuIndex $ ":" @ Values[MenuIndex]);
							}
						}
						else
						{
							`log("No menu progression data found for scene" @ SceneIndex $ ":" @ SceneTags[SceneIndex]);
						}
					}
				}
				else
				{
					`log("No menu progression data found in the Registry data store");
				}
			}
		}
	}
}

/**
 * Helper function to deduce the PlayerIndex of a Player
 * 
 * @param P - The LocalPlayer for whom you wish to deduce their PlayerIndex
 * 
 * @return Returns the index into the GamePlayers array that references this Player. If it cannot find the player, it returns 0.
 */
function int FindLocalPlayerIndex(Player P)
{
	local Engine Engine;
	local int i;

	Engine = class'Engine'.static.GetEngine();
	for (i = 0; i < Engine.GamePlayers.length; i++)
	{
		if (Engine.GamePlayers[i] == P)
		{
			return i;
		}
	}
	return 0;
}

// ===============================================
// ANIMATIONS
// ===============================================
/**
 * Attempt to find an animation in the AnimSequencePool.
 *
 * @Param SequenceName		The sequence to find
 * @returns the sequence if it was found otherwise returns none
 */
native final function UIAnimationSeq FindUIAnimation(name NameOfSequence) const;

DefaultProperties
{
	DefaultUITexture(UIPEN_White)=Texture2D'EngineResources.WhiteSquareTexture'
	DefaultUITexture(UIPEN_Black)=Texture2D'EngineResources.Black'
	DefaultUITexture(UIPEN_Grey)=Texture2D'EngineResources.Gray'

	MessageBoxClass=class'Engine.UIMessageBox'

	NavAliases(0)="UIKEY_NavFocusUp"
	NavAliases(1)="UIKEY_NavFocusDown"
	NavAliases(2)="UIKEY_NavFocusLeft"
	NavAliases(3)="UIKEY_NavFocusRight"

	AxisInputKeys(0)="KEY_Gamepad_LeftStick_Up"
	AxisInputKeys(1)="KEY_Gamepad_LeftStick_Down"
	AxisInputKeys(2)="KEY_Gamepad_LeftStick_Right"
	AxisInputKeys(3)="KEY_Gamepad_LeftStick_Left"
	AxisInputKeys(4)="KEY_Gamepad_RightStick_Up"
	AxisInputKeys(5)="KEY_Gamepad_RightStick_Down"
	AxisInputKeys(6)="KEY_Gamepad_RightStick_Right"
	AxisInputKeys(7)="KEY_Gamepad_RightStick_Left"
	AxisInputKeys(8)="KEY_SIXAXIS_AccelX"
	AxisInputKeys(9)="KEY_SIXAXIS_AccelY"
	AxisInputKeys(10)="KEY_SIXAXIS_AccelZ"
	AxisInputKeys(11)="KEY_SIXAXIS_Gyro"
	AxisInputKeys(12)="KEY_XboxTypeS_LeftX"
	AxisInputKeys(13)="KEY_XboxTypeS_LeftY"
	AxisInputKeys(14)="KEY_XboxTypeS_RightX"
	AxisInputKeys(15)="KEY_XboxTypeS_RightY"
}
