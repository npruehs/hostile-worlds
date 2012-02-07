/**
 * UISceneClient used for rendering scenes in the editor.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class EditorUISceneClient extends UISceneClient
	native
	inherits(FCallbackEventDevice)
	transient;

/** the scene associated with this scene client.  Always valid, even when the scene is currently being edited */
var const			transient		UIScene					Scene;

/** pointer to the UISceneManager singleton.  set by the scene manager when an EditorUISceneClient is created */
var const			transient		UISceneManager			SceneManager;

/** pointer to the editor window for the scene associated with this scene client.  Only valid while the scene is being edited */
var const	native	transient		pointer					SceneWindow{class WxUIEditorBase};

/** canvas scene for rendering 3d primtives/lights. Created during Init */
var const	native 	transient		pointer					ClientCanvasScene{class FCanvasScene};

/** TRUE if the scene for rendering 3d prims on this UI has been initialized */
var const 			transient 		bool					bIsUIPrimitiveSceneInitialized;

cpptext
{
	/* =======================================
		UUISceneClient interface
	======================================= */
	/** Default constructor */
	UEditorUISceneClient();

	/**
	 * Retrieves the virtual offset for the viewport that renders the specified scene.  Only relevant in the UI editor.
	 * Non-zero when the user has panned or zoomed the UI editor such that the 0,0 viewport position is no longer the same
	 * as the 0,0 canvas location.
	 *
	 * @param	out_ViewportOffset	[out] will be filled in with the delta between the viewport's actual origin and virtual origin.
	 *
	 * @return	TRUE if the viewport origin was successfully retrieved
	 */
	virtual UBOOL GetViewportOffset( const UUIScene* Scene, FVector2D& out_ViewportOffset );

	/**
	 * Retrieves the scale factor for the viewport that renders the specified scene.  Only relevant in the UI editor.
	 */
	virtual FLOAT GetViewportScale( const UUIScene* Scene ) const;

	/**
	 * Retrieves the virtual point of origin for the viewport that renders the specified scene
	 *
	 * In the game, this will be non-zero if Scene is for split-screen and isn't for the first player.
	 * In the editor, this will be equal to the value of the gutter region around the viewport.
	 *
	 * @param	out_ViewportOrigin	[out] will be filled in with the position of the virtual origin point of the viewport.
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
	 * Changes the active skin to the skin specified, initializes the skin and performs all necessary cleanup and callbacks.
	 * This method should only be called from script.
	 *
	 * @param	NewActiveScene	The skin to activate
	 *
	 * @return	TRUE if the skin was successfully changed.
	 */
	virtual UBOOL ChangeActiveSkin( UUISkin* NewActiveSkin );

	/**
	 * Refreshes all existing UI elements with the styles from the currently active skin, then propagates the call
	 * to all child editors.
	 */
	virtual void OnActiveSkinChanged();

	/**
	 * Called when user opens the specified scene for editing.  Creates the editor window, initializes the scene's state,
	 * and converts it into "editing" mode.
	 *
	 * @param	Scene			the scene to open; if the scene specified is contained in a content package, a copy of the scene will be created
	 *							and the copy will be opened instead.
	 *
	 * @return TRUE if the scene was successfully opened
	 */
	virtual UBOOL OpenScene( class UUIScene* Scene, class ULocalPlayer* UnusedPlayer=NULL, class UUIScene** UnusedScene=NULL, BYTE UnusedForcedPriority=UCONST_DEFAULT_SCENE_PRIORITY );

	/**
	 * Deactivates the specified scene and removes it from the stack of scenes.
	 *
	 * @param	Scene				the scene to deactivate
	 *
	 * @return true if the scene was successfully deactivated
	 */
	virtual UBOOL CloseScene( class UUIScene* Scene, UBOOL bUnusedParm=TRUE, UBOOL bUnusedForceClose=FALSE );

	/**
	 * Generates a thumbnail for the scene using the current viewport image.
	 *
	 * @param	Scene	the scene to generate a thumbnail for.
	 *
	 */
	virtual void GenerateSceneThumbnail( class UUIScene* Scene );

	/**
	 * Provides the scene client with a way to apply a platform input type other than the actual input type being used.
	 * Primarily for simulating platforms in the editor.
	 *
	 * @param	OwningPlayer		the player to use for determining the real platform input type, if necessary.
	 * @param	SimulatedPlatform	receives the value of the platform that should be used.
	 *
	 * @return	TRUE if the scene client wants to override the current platform input type.
	 */
	virtual UBOOL GetSimulatedPlatformInputType( BYTE& SimulatedPlatform ) const;

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

	/**
	 * Renders the scene associated with this scene client.
	 */
	virtual void RenderScenes( FCanvas* Canvas );

	/**
	 * Returns if this UI requires a CanvasScene for rendering 3D primitives
	 *
	 * @return TRUE if 3D primitives are used
	 */
	virtual UBOOL UsesUIPrimitiveScene() const;

	/**
	 * Returns the internal CanvasScene that may be used by this UI
	 *
	 * @return canvas scene or NULL
	 */
	virtual class FCanvasScene* GetUIPrimitiveScene();

	/**
	 * Detaches and cleans up the ClientCanvasScene.
	 */
	virtual void DetachUIPrimitiveScene();

	/**
	 * Determine if the canvas scene for primitive rendering needs to be initialized
	 *
	 * @return TRUE if InitUIPrimitiveScene should be called
	 */
	virtual UBOOL NeedsInitUIPrimitiveScene();

	/**
	 * Re-initializes all primitives in the specified scene.  Will occur on the next tick.
	 *
	 * @param	Sender	the scene to re-initialize primitives for.
	 */
	virtual void RequestPrimitiveReinitialization( class UUIScene* Sender );

	/**
	 * Gives all UIScenes a chance to create, attach, and/or initialize any primitives contained in the UIScene.
	 *
	 * @param	CanvasScene		the scene to use for attaching any 3D primitives
	 */
	virtual void InitializePrimitives( class FCanvasScene* CanvasScene );

	/**
	 * Updates 3D primitives for all active scenes
	 *
	 * @param	CanvasScene		the scene to use for attaching any 3D primitives
	 */
	virtual void UpdateActivePrimitives( class FCanvasScene* CanvasScene );

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
	virtual UBOOL IsSceneInitialized( const class UUIScene* Scene ) const;

	/* =======================================
		UEditorUISceneClient interface
	======================================= */

	/**
	 * Called when a scene is about to be deleted in the generic browser.  Closes any open editor windows for this scene
	 * and clears all references.
	 *
	 * @param	Scene	the scene being deleted
	 */
	void NotifyDeleteScene();

	/* === FCallbackEventDevice interface === */
	/**
	 * Called when the viewport has been resized.
	 */
	virtual void Send( ECallbackEventType InType, class FViewport* InViewport, UINT InMessage);

	/* ==============================================
		FExec interface
	============================================== */
	virtual UBOOL Exec(const TCHAR* Cmd,FOutputDevice& Ar);

	/* ==============================================
		UObject interface
	============================================== */
	/**
	 * Called to finish destroying the object.
	 */
	virtual void FinishDestroy();
}

exec function ShowDockingStacks()
{
	if ( Scene != None )
	{
		Scene.LogDockingStack();
	}
}


DefaultProperties
{
}
