/**
 * Serves as the interface between a UIScene and scene owners.  Provides scenes with all
 * data necessary for operation and routes rendering to the scenes.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UISceneClient extends UIRoot
	native(UserInterface)
	abstract
	inherits(FExec)
	transient;

/** the viewport to use for rendering scenes */
var const transient	native					pointer				RenderViewport{FViewport};

/**
 * The active UISkin.  Only one UISkin can be active at a time.
 * The special data store name 'Styles' always corresponds to the ActiveSkin.
 */
var	transient 								UISkin				ActiveSkin;

/**
 * the location of the mouse
 *
 * @fixme splitscreen
 */
var const transient							IntPoint			MousePosition;

/**
 * Represents the widget/scene that is currently under the mouse cursor.
 *
 * @fixme splitscreen
 */
var	const transient							UIObject			ActiveControl;

/**
 * Manager all persistent global data stores.  Set by the object that creates the scene client.
 */
var	const transient							DataStoreClient		DataStoreManager;

/** Material instance parameter for UI widget opacity. */
var transient				MaterialInstanceConstant			OpacityParameter;

/** Name of the opacity parameter. */
var const transient			name								OpacityParameterName;

/**
 * Stores the 3D projection matrix being used to render the UI.
 */
var	const transient							matrix				CanvasToScreen;
var	const transient							matrix				InvCanvasToScreen;


/** Post process chain to be applied when rendering UI Scenes */
var transient								PostProcessChain	UIScenePostProcess;
/** if TRUE then post processing is enabled using the UIScenePostProcess */
var transient								bool				bEnablePostProcess;

/**
 * Used to limit which scenes should be considered when determining whether the UI should be considered "active"
 * Represented in C++ as enums values.
 */
const	SCENEFILTER_None				=0x00000000;
/** Include the transient scene */
const	SCENEFILTER_IncludeTransient	=0x00000001;
/** Consider only scenes which can process input */
const	SCENEFILTER_InputProcessorOnly	=0x00000002;
/** Consider only scenes which require the game to be paused */
const	SCENEFILTER_PausersOnly			=0x00000004;
/** Consider only scenes which support 3D primitives rendering */
const	SCENEFILTER_PrimitiveUsersOnly	=0x00000008;
/** Only consider scenes which render full-screen */
const	SCENEFILTER_UsesPostProcessing	=0x00000010;
/** Include only those scenes which can receive focus (i.e. bNeverFocus=false) */
const	SCENEFILTER_ReceivesFocus		=0x00000020;
/** Any scene */
const	SCENEFILTER_Any					=0xFFFFFFFF;

`define		DECLARE_SCENEFILTER_TYPE(type) `{type}=UCONST_`{type},
cpptext
{

	/**
	 * Used to limit which scenes should be considered when determining whether the UI should be considered "active"
	 */
	enum ESceneFilterTypes
	{
		`DECLARE_SCENEFILTER_TYPE(SCENEFILTER_None)

		/** Include the transient scene */
		`DECLARE_SCENEFILTER_TYPE(SCENEFILTER_IncludeTransient)

		/** Consider only scenes which can process input */
		`DECLARE_SCENEFILTER_TYPE(SCENEFILTER_InputProcessorOnly)

		/** Consider only scenes which require the game to be paused */
		`DECLARE_SCENEFILTER_TYPE(SCENEFILTER_PausersOnly)

		/** Consider only scenes which support 3D primitives rendering */
		`DECLARE_SCENEFILTER_TYPE(SCENEFILTER_PrimitiveUsersOnly)

		/** Only consider scenes which render full-screen */
		`DECLARE_SCENEFILTER_TYPE(SCENEFILTER_UsesPostProcessing)

		/** Include only those scenes which can receive focus (i.e. bNeverFocus=false) */
		`DECLARE_SCENEFILTER_TYPE(SCENEFILTER_ReceivesFocus)

		/** Include ANY scene, regardless of feature set */
		`DECLARE_SCENEFILTER_TYPE(SCENEFILTER_Any)
	};

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
	 * Assigns the viewport that scenes will use for rendering.
	 *
	 * @param	inViewport	the viewport to use for rendering scenes
	 */
	virtual void SetRenderViewport( FViewport* SceneViewport );

	/**
	 * Changes the active skin to the skin specified
	 */
	void SetActiveSkin( UUISkin* NewActiveSkin );

	/**
	 * Changes the active skin to the skin specified, initializes the skin and performs all necessary cleanup and callbacks.
	 * This method should only be called from script.
	 *
	 * @param	NewActiveScene	The skin to activate
	 *
	 * @return	TRUE if the skin was successfully changed.
	 */
	virtual UBOOL ChangeActiveSkin( UUISkin* NewActiveSkin ) PURE_VIRTUAL(UUISceneClient::ChangeActiveSkin, return FALSE;);

	/**
	 * Refreshes all existing UI elements with the styles from the currently active skin.
	 */
	virtual void OnActiveSkinChanged() PURE_VIRTUAL(UUISceneClient::OnActiveSkinChanged,);

	/**
	 * Retrieves the virtual offset for the viewport that renders the specified scene.  Only relevant in the UI editor.
	 * Non-zero when the user has panned or zoomed the UI editor such that the 0,0 viewport position is no longer the same
	 * as the 0,0 canvas location.
	 *
	 * @param	out_ViewportOffset	[out] will be filled in with the delta between the viewport's actual origin and virtual origin.
	 *
	 * @return	TRUE if the viewport origin was successfully retrieved
	 */
	virtual UBOOL GetViewportOffset( const UUIScene* Scene, FVector2D& out_ViewportOffset )
	{
		out_ViewportOffset = FVector2D(0,0);
		return FALSE;
	}

	/**
	 * Retrieves the scale factor for the viewport that renders the specified scene.  Only relevant in the UI editor.
	 */
	virtual FLOAT GetViewportScale( const UUIScene* Scene ) const
	{
		return 1.f;
	}

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
	virtual UBOOL GetViewportOrigin( const UUIScene* Scene, FVector2D& out_ViewportOrigin )
	{
		out_ViewportOrigin = FVector2D(0,0);
		return TRUE;
	}

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
	virtual void UpdateCanvasToScreen() PURE_VIRTUAL(UUISceneClient::UpdateCanvasToScreen,);

	/**
	 * Provides the scene client with a way to apply a platform input type other than the actual input type being used.
	 * Primarily for simulating platforms in the editor.
	 *
	 * @param	OwningPlayer		the player to use for determining the real platform input type, if necessary.
	 * @param	SimulatedPlatform	receives the value of the platform that should be used.
	 *
	 * @return	TRUE if the scene client wants to override the current platform input type.
	 */
	virtual UBOOL GetSimulatedPlatformInputType( BYTE& SimulatedPlatform ) const { return FALSE; }

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
	virtual UBOOL InputKey(INT ControllerId,FName Key,EInputEvent Event,FLOAT AmountDepressed=1.f,UBOOL bGamepad=FALSE) PURE_VIRTUAL(UUISceneClient::InputKey,return FALSE;);

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
	virtual UBOOL InputAxis(INT ControllerId,FName Key,FLOAT Delta,FLOAT DeltaTime, UBOOL bGamepad=FALSE) PURE_VIRTUAL(UUISceneClient::InputAxis,return FALSE;);

	/**
	 * Check a character input received by the viewport.
	 *
	 * @param	Viewport - The viewport which the axis movement is from.
	 * @param	ControllerId - The controller which the axis movement is from.
	 * @param	Character - The character.
	 *
	 * @return	True to consume the character, false to pass it on.
	 */
	virtual UBOOL InputChar(INT ControllerId,TCHAR Character) PURE_VIRTUAL(UUISceneClient::InputChar,return FALSE;);

	/**
	 * Initializes the specified scene without opening it.
	 *
	 * @param	Scene				the scene to initialize;  if the scene specified is contained in a content package, a copy of the scene
	 *								will be created, and that scene will be initialized instead.
	 * @param	SceneOwner			the player that should be associated with the new scene.  Will be assigned to the scene's
	 *								PlayerOwner property.
	 * @param	InitializedScene	the scene that was actually initialized.  If Scene is located in a content package, InitializedScene will be
	 *								the copy of the scene that was created.  Otherwise, InitializedScene will be the same as the scene passed in.
	 *
	 * @return	TRUE if the scene was successfully initialized
	 */
	virtual UBOOL InitializeScene( class UUIScene* Scene, class ULocalPlayer* SceneOwner=NULL, class UUIScene** InitializedScene=NULL );

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
	virtual UBOOL OpenScene( class UUIScene* Scene, class ULocalPlayer* SceneOwner=NULL, class UUIScene** OpenedScene=NULL, BYTE ForcedPriority=UCONST_DEFAULT_SCENE_PRIORITY )
	{
		return FALSE;
	}

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
	virtual UBOOL InsertScene( INT DesiredInsertIndex, class UUIScene* Scene, class ULocalPlayer* SceneOwner=NULL, class UUIScene** OpenedScene=NULL, INT* ActualInsertIndex=NULL, BYTE ForcedPriority=UCONST_DEFAULT_SCENE_PRIORITY )
	{
		return OpenScene(Scene, SceneOwner, OpenedScene, ForcedPriority);
	}

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
	virtual UBOOL ReplaceScene( class UUIScene* SceneInstanceToReplace, class UUIScene* SceneToOpen, class ULocalPlayer* SceneOwner=NULL, class UUIScene** OpenedScene=NULL, BYTE ForcedPriority=UCONST_DEFAULT_SCENE_PRIORITY )
	{
		return FALSE;
	}

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
	virtual UBOOL ReplaceSceneAtIndex( INT IndexOfSceneToReplace, class UUIScene* SceneToOpen, class ULocalPlayer* SceneOwner=NULL, class UUIScene** OpenedScene=NULL, BYTE ForcedPriority=UCONST_DEFAULT_SCENE_PRIORITY )
	{
		return FALSE;
	}

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
	virtual UBOOL CloseScene( class UUIScene* Scene, UBOOL bCloseChildScenes=TRUE, UBOOL bForceCloseImmediately=FALSE )
	{
		return FALSE;
	}

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
	virtual UBOOL CloseSceneAtIndex( INT SceneStackIndex, UBOOL bCloseChildScenes=TRUE, UBOOL bForceCloseImmediately=FALSE )
	{
		return FALSE;
	}

	/**
	 * Perform 2D rendering for all active scenes
	 *
	 * @param	Canvas	the canvas to use for rendering.
	 */
	virtual void RenderScenes( class FCanvas* Canvas ) PURE_VIRTUAL(UUISceneClient::RenderScenes,);

	/**
	 * Renders the specified scene and its widgets using a 2D plane
	 *
	 * @param	Canvas	the canvas to use for rendering.
	 * @param	Scene	the UIScene to render
	 * @param	UIPostProcessGroup	Group determines current pp pass that is being rendered
	 */
	virtual void Render_Scene( class FCanvas* Canvas, UUIScene* Scene, EUIPostProcessGroup UIPostProcessGroup );

	/**
	 * Renders the specified scene's post process
	 *
	 * @param	Canvas	the canvas to use for rendering.
	 * @param	Scene	the UIScene to render
	 * @param	UIPostProcessGroup	Group determines current pp pass that needs to be rendered
	 */
	virtual void Render_Scene_PostProcess( class FCanvas* Canvas, UUIScene* Scene, EUIPostProcessGroup UIPostProcessGroup );

	/**
	 * Re-initializes all primitives in the specified scene.  Will occur on the next tick.
	 *
	 * @param	Sender	the scene to re-initialize primitives for.
	 */
	virtual void RequestPrimitiveReinitialization( class UUIScene* Sender ) PURE_VIRTUAL(UUISceneClient::RequestPrimitiveReinitialization,);

	/**
	 * Gives all UIScenes a chance to create, attach, and/or initialize any primitives contained in the UIScene.
	 *
	 * @param	CanvasScene		the scene to use for attaching any 3D primitives
	 */
	virtual void InitializePrimitives( class FCanvasScene* CanvasScene ) PURE_VIRTUAL(UUISceneClient::InitializePrimitives,);

	/**
	 * Updates 3D primitives for all active scenes
	 *
	 * @param	CanvasScene		the scene to use for attaching any 3D primitives
	 */
	virtual void UpdateActivePrimitives( class FCanvasScene* CanvasScene ) PURE_VIRTUAL(UUISceneClient::UpdateActivePrimitives,);

	/**
	 * Updates 3D primitives for the specified scene and its child widgets.
	 *
	 * @param	CanvasScene	the scene to use for attaching any 3D primitives
	 * @param	Scene		the UIScene to update
	 */
	virtual void Update_ScenePrimitives( FCanvasScene* Canvas, UUIScene* Scene );

	/**
	 * Returns true if there is an unhidden fullscreen UI active
	 *
	 * @param	Flags	modifies the logic which determines wether hte UI is active
	 *
	 * @return TRUE if the UI is currently active
	 */
	virtual UBOOL IsUIActive( DWORD Flags=SCENEFILTER_Any ) const PURE_VIRTUAL(UUISceneClient::IsUIActive,return FALSE;);

	/**
	 * Returns whether the specified scene has been fully initialized.  Different from UUIScene::IsInitialized() in that this
	 * method returns true only once all objects related to this scene have been created and initialized (e.g. in the UI editor
	 * only returns TRUE once the editor window for this scene has finished creation).
	 *
	 * @param	Scene	the scene to check.
	 */
	virtual UBOOL IsSceneInitialized( const class UUIScene* Scene ) const PURE_VIRTUAL(UUISceneClient::IsSceneInitialized,return TRUE;);

	/**
	 * Returns true if the UI scenes should be rendered with post process
	 *
	 * @return TRUE if post process is enabled for any of the UI scenes
	 */
	virtual UBOOL UsesPostProcess() const;
}

/**
 * Changes the active skin to the skin specified, initializes the skin and performs all necessary cleanup and callbacks.
 * This method should only be called from script.
 *
 * @param	NewActiveScene	The skin to activate
 *
 * @return	TRUE if the skin was successfully changed.
 */
native final noexportheader function bool ChangeActiveSkin( UISkin NewActiveSkin );

/**
 * Returns true if there is an unhidden fullscreen UI active
 *
 * @param	Flags	a bitmask of values which alter the result of this method;  the bits are derived from the ESceneFilterTypes
 *					enum (which is native-only); script callers must pass these values literally
 *
 * @return TRUE if the UI is currently active
 */
native final noexportheader function bool IsUIActive( optional int Flags=SCENEFILTER_Any ) const;

/**
 * Returns whether the specified scene has been fully initialized.  Different from UUIScene::IsInitialized() in that this
 * method returns true only once all objects related to this scene have been created and initialized (e.g. in the UI editor
 * only returns TRUE once the editor window for this scene has finished creation).
 *
 * @param	Scene	the scene to check.
 *
 * @note: noexport because the C++ version is a pure virtual
 */
native final noexportheader function bool IsSceneInitialized( UIScene Scene ) const;

/**
 * Initializes the specified scene without opening it.
 *
 * @param	Scene				the scene to initialize;  if the scene specified is contained in a content package, a copy of the scene
 *								will be created, and that scene will be initialized instead.
 * @param	SceneOwner			the player that should be associated with the new scene.  Will be assigned to the scene's
 *								PlayerOwner property.
 * @param	InitializedScene	the scene that was actually initialized.  If Scene is located in a content package, InitializedScene will be
 *								the copy of the scene that was created.  Otherwise, InitializedScene will be the same as the scene passed in.
 *
 * @return	TRUE if the scene was successfully initialized
 *
 * @note - noexport to handle the optional out parameter correctly
 */
native final noexportheader function bool InitializeScene( UIScene Scene, optional LocalPlayer SceneOwner, optional out UIScene InitializedScene );

/**
 * Adds the specified scene to the list of active scenes, loading the scene and performing initialization as necessary.
 *
 * @param	Scene			the scene to open; if the scene specified is contained in a content package, a copy of the scene will be created
 *							and the copy will be opened instead.
 * @param	SceneOwner		the player that should be associated with the new scene.  Will be assigned to the scene's
 *							PlayerOwner property.
 * @param	OpenedScene		the scene that was actually opened.  If Scene is located in a content package, OpenedScene will be
 *							the copy of the scene that was created.  Otherwise, OpenedScene will be the same as the scene passed in.
 * @param	ForcedPriority	overrides the scene's SceneStackPriority value to allow callers to modify where the scene is placed in the stack, by default.
 *
 * @return TRUE if the scene was successfully opened
 *
 * @note - noexport to handle the optional out parameter correctly
 */
native final noexportheader function bool OpenScene( UIScene Scene, optional LocalPlayer SceneOwner, optional out UIScene OpenedScene, optional byte ForcedPriority );

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
native final noexportheader function bool InsertScene( int DesiredInsertIndex, UIScene Scene, optional LocalPlayer SceneOwner, optional out UIScene OpenedScene, optional out int ActualInsertIndex, optional byte ForcedPriority );

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
native final noexportheader function bool ReplaceScene( UIScene SceneInstanceToReplace, UIScene SceneToOpen, optional LocalPlayer SceneOwner, optional out UIScene OpenedScene, optional byte ForcedPriority);

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
native final noexportheader function bool ReplaceSceneAtIndex( int IndexOfSceneToReplace, UIScene SceneToOpen, optional LocalPlayer SceneOwner, optional out UIScene OpenedScene, optional byte ForcedPriority );

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
native final noexportheader function bool CloseScene( UIScene Scene, optional bool bCloseChildScenes=true, optional bool bForceCloseImmediately );

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
native final noexportheader function bool CloseSceneAtIndex( int SceneStackIndex, optional bool bCloseChildScenes=true, optional bool bForceCloseImmediately );

/**
 * Loads the skin package containing the skin with the specified tag, and sets that skin as the currently active skin.
 * @todo
 */
//native final function SetActiveSkin( Name SkinTag );

/**
 * Set the mouse position to the coordinates specified
 *
 * @param	NewX	the X position to move the mouse cursor to (in pixels)
 * @param	NewY	the Y position to move the mouse cursor to (in pixels)
 */
native final virtual function SetMousePosition( int NewMouseX, int NewMouseY );

/**
 * Changes the resource that is currently being used as the mouse cursor.  Called by widgets as they changes states, or when
 * some action occurs which affects the mouse cursor.
 *
 * @param	CursorName	the name of the mouse cursor resource to use.  Should correspond to a name from the active UISkin's
 *						MouseCursorMap
 *
 * @return	TRUE if the cursor was successfully changed.
 */
native final virtual function bool ChangeMouseCursor( name CursorName );

/**
 * Changes the matrix for projecting local (pixel) coordinates into world screen (normalized device)
 * coordinates.  This method should be called anytime the viewport size or origin changes.
 */
native final noexportheader function UpdateCanvasToScreen();

/**
 * Returns the current canvas to screen projection matrix.
 *
 * @param	Widget	if specified, the returned matrix will include the widget's tranformation matrix as well.
 *
 * @return	a matrix which can be used to project 2D pixel coordines into 3D screen coordinates. ??
 */
native final function matrix GetCanvasToScreen( optional const UIObject Widget ) const;

/**
 * Returns the inverse of the local to world screen projection matrix.
 *
 * @param	Widget	if specified, the returned matrix will include the widget's tranformation matrix as well.
 *
 * @return	a matrix which can be used to transform normalized device coordinates (i.e. origin at center of screen) into
 *			into 0,0 based pixel coordinates. ??
 */
native final function matrix GetInverseCanvasToScreen( optional const UIObject Widget ) const;

/**
 * Called when the scene client is first initialized.
 */
event InitializeSceneClient();

DefaultProperties
{
	OpacityParameterName=UI_Opacity

	// enable post processing of UI by default
	bEnablePostProcess=True
}
