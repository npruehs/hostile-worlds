/**
 * A game viewport (FViewport) is a high-level abstract interface for the
 * platform specific rendering, audio, and input subsystems.
 * GameViewportClient is the engine's interface to a game viewport.
 * Exactly one GameViewportClient is created for each instance of the game.  The
 * only case (so far) where you might have a single instance of Engine, but
 * multiple instances of the game (and thus multiple GameViewportClients) is when
 * you have more than one PIE window running.
 *
 * Responsibilities:
 * propagating input events to the global interactions list
 *
 *
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class GameViewportClient extends Object
	within Engine
	transient
	native
	Inherits(FViewportClient)
	Inherits(FExec)
	config(Engine)
;

/** The platform-specific viewport which this viewport client is attached to. */
var const pointer Viewport{FViewport};

/** The platform-specific viewport frame which this viewport is contained by. */
var const pointer ViewportFrame{FViewportFrame};

/** A list of interactions which have a chance at all input before the player's interactions. */
var init protected array<Interaction> GlobalInteractions;

/** The class for the UI controller */
var	class<UIInteraction>	UIControllerClass;

/** The viewport's UI controller */
var UIInteraction			UIController;

/** The viewport's console.   Might be null on consoles */
var Console ViewportConsole;

/** The show flags used by the viewport's players. */
var const qword ShowFlags;

/** @name Localized transition messages. */
//@{
var localized string LoadingMessage;
var localized string SavingMessage;
var localized string ConnectingMessage;
var localized string PausedMessage;
var localized string PrecachingMessage;
//@}

/** if TRUE then the title safe border is drawn */
var bool bShowTitleSafeZone;
/** Max/Recommended screen viewable extents as a percentage */
struct native TitleSafeZoneArea
{
	var float MaxPercentX;
	var float MaxPercentY;
	var float RecommendedPercentX;
	var float RecommendedPercentY;
};
/** border of safe area */
var TitleSafeZoneArea TitleSafeZone;

/**
 * Indicates whether the UI is currently displaying a mouse cursor.  Prevents GameEngine::Tick() from recapturing
 * mouse input while the UI has active scenes that mouse input.
 */
var	transient	bool		bDisplayingUIMouseCursor;

/**
 * Indicates that the UI needs to receive all mouse input events.  Usually enabled when the user is interacting with a
 * draggable widget, such as a scrollbar or slider.
 */
var	transient	bool		bUIMouseCaptureOverride;

var transient	bool		bOverrideDiffuseAndSpecular;

/**
 * Enum of the different splitscreen types
 */
enum ESplitScreenType
{
	eSST_NONE,				// No split
	eSST_2P_HORIZONTAL,		// 2 player horizontal split
	eSST_2P_VERTICAL,		// 2 player vertical split
	eSST_3P_FAVOR_TOP,		// 3 Player split with 1 player on top and 2 on bottom
	eSST_3P_FAVOR_BOTTOM,	// 3 Player split with 1 player on bottom and 2 on top
	eSST_4P,				// 4 Player split
};

/**
 * The 4 different kinds of safezones
 */
enum ESafeZoneType
{
	eSZ_TOP,
	eSZ_BOTTOM,
	eSZ_LEFT,
	eSZ_RIGHT,
};

/**
 * Structure to store splitscreen data.
 */
struct native PerPlayerSplitscreenData
{
	var float SizeX;
	var float SizeY;
	var float OriginX;
	var float OriginY;
};

/**
 * Structure containing all the player splitscreen datas per splitscreen configuration.
 */
struct native SplitscreenData
{
	var array<PerPlayerSplitscreenData> PlayerData;
};

/** Array of the screen data needed for all the different splitscreen configurations */
var array<SplitscreenData> SplitscreenInfo;

/**
 * The splitscreen layout type that the player wishes to use;  this value usually comes from places like the player's profile
 */
var protected{protected}	ESplitScreenType	DesiredSplitscreenType;

/**
 * The splitscreen type that is actually being used; takes into account the number of players and other factors (such as cinematic mode)
 * that could affect the splitscreen mode that is actually used.
 */
var	protected{protected}	ESplitscreenType	ActiveSplitscreenType;

/** Defaults for intances where there are multiple configs for a certain number of players */
var const ESplitScreenType Default2PSplitType;
var const ESplitScreenType Default3PSplitType;

/** set to disable world rendering */
var bool bDisableWorldRendering;

// Progress Indicator - used by the engine to provide status messages (see SetProgressMessage())
var string ProgressMessage[2];
var float ProgressTimeOut;
var float ProgressFadeTime;

/** debug property display functionality
 * to interact with this, use "display", "displayall", "displayclear"
 */
struct native DebugDisplayProperty
{
	/** the object whose property to display. If this is a class, all objects of that class are drawn. */
	var Object Obj;
	/** name of the property to display */
	var name PropertyName;
	/** whether PropertyName is a "special" value not directly mapping to a real property (e.g. state name) */
	var bool bSpecialProperty;
};
var array<DebugDisplayProperty> DebugProperties;

/** Stores the pointer to any data needed for scaleform (if defined)*/
var native const pointer ScaleformInteraction { UGFxInteraction };

/** DEBUG: If TRUE, the GFx UI will NOT be rendered at runtime.  Note that to REMOVE GFx functionality permanently, you should compile with WITH_GFx set to 0.  This bool is for debugging only. */
var config bool bDebugNoGFxUI;

/** A temporary workaround for seeing dobule cursors in UDK Game. We need a complete solution that handles this robustly for all GFx UIs */
var config bool bUseHardwareCursorWhenWindowed;

cpptext
{
	// Constructor.
	UGameViewportClient();

	/**
	 * Cleans up all rooted or referenced objects created or managed by the GameViewportClient.  This method is called
	 * when this GameViewportClient has been disassociated with the game engine (i.e. is no longer the engine's GameViewport).
	 */
	virtual void DetachViewportClient();

	/**
	 * Called every frame to allow the game viewport to update time based state.
	 * @param	DeltaTime	The time since the last call to Tick.
	 */
	void Tick( FLOAT DeltaTime );

	// FViewportClient interface.
	virtual void RedrawRequested(FViewport* InViewport) {}

	/**
	 * Routes an input key event received from the viewport to the Interactions array for processing.
	 *
	 * @param	Viewport		the viewport the input event was received from
	 * @param	ControllerId	gamepad/controller that generated this input event
	 * @param	Key				the name of the key which an event occured for (KEY_Up, KEY_Down, etc.)
	 * @param	EventType		the type of event which occured (pressed, released, etc.)
	 * @param	AmountDepressed	(analog keys only) the depression percent.
	 * @param	bGamepad - input came from gamepad (ie xbox controller)
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL InputKey(FViewport* Viewport,INT ControllerId,FName Key,EInputEvent EventType,FLOAT AmountDepressed=1.f,UBOOL bGamepad=FALSE);

	/**
	 * Routes an input axis (joystick, thumbstick, or mouse) event received from the viewport to the Interactions array for processing.
	 *
	 * @param	Viewport		the viewport the input event was received from
	 * @param	ControllerId	the controller that generated this input axis event
	 * @param	Key				the name of the axis that moved  (KEY_MouseX, KEY_XboxTypeS_LeftX, etc.)
	 * @param	Delta			the movement delta for the axis
	 * @param	DeltaTime		the time (in seconds) since the last axis update.
	 *
	 * @return	TRUE to consume the axis event, FALSE to pass it on.
	 */
	virtual UBOOL InputAxis(FViewport* Viewport,INT ControllerId,FName Key,FLOAT Delta,FLOAT DeltaTime, UBOOL bGamepad=FALSE);

	/**
	 * Routes a character input event (typing) received from the viewport to the Interactions array for processing.
	 *
	 * @param	Viewport		the viewport the input event was received from
	 * @param	ControllerId	the controller that generated this character input event
	 * @param	Character		the character that was typed
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL InputChar(FViewport* Viewport,INT ControllerId,TCHAR Character);

	/** Returns the platform specific forcefeedback manager associated with this viewport */
	virtual class UForceFeedbackManager* GetForceFeedbackManager(INT ControllerId);

	/**
	 * @return	the splitscreen type that is currently being used
	 */
	FORCEINLINE ESplitScreenType GetCurrentSplitscreenType() const
	{
		return static_cast<ESplitScreenType>(ActiveSplitscreenType);
	}

	/**
	* Callback to allow game viewport to override the splitscreen settings
	* @param NewSettings - settings to modify
	* @param SplitScreenType - current splitscreen type being used
	*/
	virtual void OverrideSplitscreenSettings(FSystemSettingsData& SplitscreenSettings,ESplitScreenType SplitScreenType) const {}

	/**
 	 * @return whether or not this Controller has Tilt Turned on
	 **/
	virtual UBOOL IsControllerTiltActive( INT ControllerID ) const;

	/**
	 * sets whether or not the the player wants to utilize the Tilt functionality
	 **/
	virtual void SetControllerTiltDesiredIfAvailable( INT ControllerID, UBOOL bActive );

	/**
	 * sets whether or not the Tilt functionality is turned on
	 **/
	virtual void SetControllerTiltActive( INT ControllerID, UBOOL bActive );

	/**
	 * sets whether or not to ONLY use the tilt input controls
	 **/
	virtual void SetOnlyUseControllerTiltInput( INT ControllerID, UBOOL bActive );

	/**
	 * sets whether or not to use the tilt forward and back input controls
	 **/
	virtual void SetUseTiltForwardAndBack( INT ControllerID, UBOOL bActive );

	/**
	 * @return whether or not this Controller has a keyboard available to be used
	 **/
	virtual UBOOL IsKeyboardAvailable( INT ControllerID ) const;

	/**
	 * @return whether or not this Controller has a mouse available to be used
	 **/
	virtual UBOOL IsMouseAvailable( INT ControllerID ) const;


	/**
	 * Changes the value of bUIMouseCaptureOverride.
	 */
	FORCEINLINE void SetMouseCaptureOverride( UBOOL bOverride )
	{
		bUIMouseCaptureOverride = bOverride;
	}

	/**
	 * Retrieves the cursor that should be displayed by the OS
	 *
	 * @param	Viewport	the viewport that contains the cursor
	 * @param	X			the x position of the cursor
	 * @param	Y			the Y position of the cursor
	 *
	 * @return	the cursor that the OS should display
	 */
	virtual EMouseCursor GetCursor( FViewport* Viewport, INT X, INT Y );

	/**
	 * Callback to let the game engine know the UI software mouse cursor is being rendered.
	 *
	 * @param	bVisible	Whether the UI software mouse cursor is visible or not
	 */
	void OnShowUIMouseCursor( UBOOL bVisible );

	virtual void Precache();
	virtual void Draw(FViewport* Viewport,FCanvas* Canvas);
	virtual void LostFocus(FViewport* Viewport);
	virtual void ReceivedFocus(FViewport* Viewport);
	virtual UBOOL IsFocused(FViewport* Viewport);
	virtual void CloseRequested(FViewport* Viewport);
	virtual UBOOL RequiresHitProxyStorage() { return 0; }

	/**
	 * Determines whether this viewport client should receive calls to InputAxis() if the game's window is not currently capturing the mouse.
	 * Used by the UI system to easily receive calls to InputAxis while the viewport's mouse capture is disabled.
	 */
	virtual UBOOL RequiresUncapturedAxisInput() const;

	// FExec interface.
	virtual UBOOL Exec(const TCHAR* Cmd,FOutputDevice& Ar);

	/**
	 * Set this GameViewportClient's viewport and viewport frame to the viewport specified
	 */
	virtual void SetViewportFrame( FViewportFrame* InViewportFrame );

	/**
	 * Set this GameViewportClient's viewport to the viewport specified
	 */
	virtual void SetViewport( FViewport* InViewportFrame );

	/** sets bDropDetail and other per-frame detail level flags on the current WorldInfo
	 * @param DeltaSeconds - amount of time passed since last tick
	 */
	virtual void SetDropDetail(FLOAT DeltaSeconds);
	
	#if WITH_GFx
	    virtual UObject* GetUObject() { return this; }
	#endif
	}

/**
 * Provides script-only child classes the opportunity to handle input key events received from the viewport.
 * This delegate is called before the input key event is passed to the interactions array for processing.
 *
 * @param	ControllerId	the controller that generated this input key event
 * @param	Key				the name of the key which an event occured for (KEY_Up, KEY_Down, etc.)
 * @param	EventType		the type of event which occured (pressed, released, etc.)
 * @param	AmountDepressed	for analog keys, the depression percent.
 * @param	bGamepad		input came from gamepad (ie xbox controller)
 *
 * @return	return TRUE to indicate that the input event was handled.  if the return value is TRUE, this input event will not
 *			be passed to the interactions array.
 */
delegate bool HandleInputKey( int ControllerId, name Key, EInputEvent EventType, float AmountDepressed, optional bool bGamepad );

/**
 * Provides script-only child classes the opportunity to handle input axis events received from the viewport.
 * This delegate is called before the input axis event is passed to the interactions array for processing.
 *
 * @param	ControllerId	the controller that generated this input axis event
 * @param	Key				the name of the axis that moved  (KEY_MouseX, KEY_XboxTypeS_LeftX, etc.)
 * @param	Delta			the movement delta for the axis
 * @param	DeltaTime		the time (in seconds) since the last axis update.
 * @param	bGamepad		input came from gamepad (ie xbox controller)
 *
 * @return	return TRUE to indicate that the input event was handled.  if the return value is TRUE, this input event will not
 *			be passed to the interactions array.
 */
delegate bool HandleInputAxis( int ControllerId, name Key, float Delta, float DeltaTime, bool bGamepad);

/**
 * Provides script-only child classes the opportunity to handle character input (typing) events received from the viewport.
 * This delegate is called before the character event is passed to the interactions array for processing.
 *
 * @param	ControllerId	the controller that generated this character input event
 * @param	Unicode			the character that was typed
 *
 * @return	return TRUE to indicate that the input event was handled.  if the return value is TRUE, this input event will not
 *			be passed to the interactions array.
 */
delegate bool HandleInputChar( int ControllerId, string Unicode );

/**
 * Executes a console command in the context of this viewport.
 * @param	Command - The command to execute.
 * @return  The output of the command will be returned.
 */
native function string ConsoleCommand(string Command);

/**
 * Retrieve the size of the main viewport.
 *
 * @param	out_ViewportSize	[out] will be filled in with the size of the main viewport
 */
native final function GetViewportSize( out Vector2D out_ViewportSize );

/** @return Whether or not the main viewport is fullscreen or windowed. */
native final function bool IsFullScreenViewport();

/**
 * Determine whether a fullscreen viewport should be used in cases where there are multiple players.
 *
 * @return	TRUE to use a fullscreen viewport; FALSE to allow each player to have their own area of the viewport.
 */
native final function bool ShouldForceFullscreenViewport() const;

/**Function that allow for custom numbers of interactions dictated in code*/
native function int GetNumCustomInteractions();
/**Defining the above mentioned custom interactions*/
native function class<UIInteraction> GetCustomInteractionClass(int InIndex);
/**Passing the custom interaction object back to native code to do with it as it likes*/
native function SetCustomInteractionObject(Interaction InInteraction);

/**
 * Adds a new player.
 * @param ControllerId - The controller ID the player should accept input from.
 * @param OutError - If no player is returned, OutError will contain a string describing the reason.
 * @param SpawnActor - True if an actor should be spawned for the new player.
 * @return The player which was created.
 */
event LocalPlayer CreatePlayer(int ControllerId, out string OutError, bool bSpawnActor)
{
	local LocalPlayer NewPlayer;
	local int InsertIndex;

	`log("Creating new player with ControllerId" @ ControllerId @ "(" $ GamePlayers.Length @ "existing players)",,'PlayerManagement');
	Assert(LocalPlayerClass != None);

	NewPlayer = new(Outer) LocalPlayerClass;
	NewPlayer.ViewportClient = Self;
	NewPlayer.ControllerId = ControllerId;

	InsertIndex = AddLocalPlayer(NewPlayer);
	if ( bSpawnActor && InsertIndex != INDEX_NONE )
	{
		if (GetCurrentWorldInfo().NetMode != NM_Client)
		{
			// server; spawn a new PlayerController immediately
			if (!NewPlayer.SpawnPlayActor("", OutError))
			{
				RemoveLocalPlayer(NewPlayer);
				NewPlayer = None;
			}
		}
		else
		{
			// client; ask the server to let the new player join
			NewPlayer.SendSplitJoin();
		}
	}

	if (OutError != "")
	{
		`Log("Player creation failed with error:" @ OutError);
	}
	else
	{
		`log("Successfully created new player with ControllerId" @ ControllerId $ ":" @ NewPlayer @ "- inserted into GamePlayers array at index" @ InsertIndex
			@ "(" $ GamePlayers.Length @ "existing players)",,'PlayerManagement');

		if ( NewPlayer != None && InsertIndex != INDEX_NONE )
		{
			// let all interactions know about this
			NotifyPlayerAdded(InsertIndex, NewPlayer);
		}
	}
	return NewPlayer;
}

/**
 * Removes a player.
 * @param Player - The player to remove.
 * @return whether the player was successfully removed. Removal is not allowed while connected to a server.
 */
event bool RemovePlayer(LocalPlayer ExPlayer)
{
	local int OldIndex;

	// can't destroy viewports while connected to a server
	if (ExPlayer.Actor.Role == ROLE_Authority)
	{
		`log("Removing player" @ ExPlayer @ " with ControllerId" @ ExPlayer.ControllerId @ "at index" @ GamePlayers.Find(ExPlayer)@ "(" $ GamePlayers.Length @ "existing players)",,'PlayerManagement');

`if(`isdefined(FIXING_SIGNIN_ISSUES))
ScriptTrace();
`endif

		// Disassociate this viewport client from the player.
		ExPlayer.ViewportClient = None;
		if ( ExPlayer.Actor != None )
		{
			// Destroy the player's actors.
			ExPlayer.Actor.Destroy();
		}

		// Remove the player from the global and viewport lists of players.
		OldIndex = RemoveLocalPlayer(ExPlayer);
		if ( OldIndex != INDEX_NONE )
		{
			// let all interactions know about this
			NotifyPlayerRemoved(OldIndex, ExPlayer);
		}

		`log("Finished removing player " @ ExPlayer @ " with ControllerId" @ ExPlayer.ControllerId @ "at index" @ OldIndex@ "(" $ GamePlayers.Length @ "remaining players)",,'PlayerManagement');
		return true;
	}
	else
	{
		`log("Not removing player" @ ExPlayer @ " with ControllerId" @ ExPlayer.ControllerId @ "because player does not have appropriate role (" $ GetEnum(enum'ENetRole',ExPlayer.Actor.Role) $ ")",,'PlayerManagement');
		return false;
	}
}

/**
 * Finds a player by controller ID.
 * @param ControllerId - The controller ID to search for.
 * @return None or the player with matching controller ID.
 */
final event LocalPlayer FindPlayerByControllerId(int ControllerId)
{
	local int PlayerIndex;
	for(PlayerIndex = 0;PlayerIndex < GamePlayers.Length;PlayerIndex++)
	{
		if(GamePlayers[PlayerIndex].ControllerId == ControllerId)
		{
			return GamePlayers[PlayerIndex];
		}
	}
	return None;
}

`if(`notdefined(ShippingPC))
/**
 * Debug console command to create a player.
 * @param ControllerId - The controller ID the player should accept input from.
 */
exec function DebugCreatePlayer(int ControllerId)
{
	local string Error;

	CreatePlayer(ControllerId, Error, TRUE);
}

/** Rotates controller ids among gameplayers, useful for testing splitscreen with only one controller. */
exec function SSSwapControllers()
{
	local int Idx, TmpControllerID;
	TmpControllerID = GamePlayers[0].ControllerID;

	for (Idx=0; Idx<GamePlayers.Length-1; ++Idx)
	{
		GamePlayers[Idx].ControllerID = GamePlayers[Idx+1].ControllerID;
	}
	GamePlayers[GamePlayers.Length-1].ControllerID = TmpControllerID;
}

/**
 * Debug console command to remove the player with a given controller ID.
 * @param ControllerId - The controller ID to search for.
 */
exec function DebugRemovePlayer(int ControllerId)
{
	local LocalPlayer ExPlayer;

	ExPlayer = FindPlayerByControllerId(ControllerId);
	if(ExPlayer != None)
	{
		RemovePlayer(ExPlayer);
	}
}

/** debug test for testing splitscreens */
exec function SetSplit( int mode )
{
	SetSplitscreenConfiguration( ESplitScreenType(mode) );
}

/**
* Exec for toggling the display of the title safe area
*/
exec function ShowTitleSafeArea()
{
	bShowTitleSafeZone = !bShowTitleSafeZone;
}

/**
 * Sets the player which console commands will be executed in the context of.
 */
exec function SetConsoleTarget(int PlayerIndex)
{
	if(PlayerIndex >= 0 && PlayerIndex < GamePlayers.Length)
	{
		ViewportConsole.ConsoleTargetPlayer = GamePlayers[PlayerIndex];
	}
	else
	{
		ViewportConsole.ConsoleTargetPlayer = None;
	}
}
`endif

/**
 * Initialize the game viewport.
 * @param OutError - If an error occurs, returns the error description.
 * @return False if an error occurred, true if the viewport was initialized successfully.
 */
event bool Init(out string OutError)
{
	local PlayerManagerInteraction PlayerInteraction;
	local int NumCustomInteractions;
	local class<UIInteraction> CustomInteractionClass;
	local UIInteraction CustomInteraction;
	local int Idx;

	assert(Outer.ConsoleClass != None);

	ActiveSplitscreenType = DesiredSplitscreenType;

	// Create the viewport's console.
	ViewportConsole = new(Self) Outer.ConsoleClass;
	if ( InsertInteraction(ViewportConsole) == -1 )
	{
		OutError = "Failed to add interaction to GlobalInteractions array:" @ ViewportConsole;
		return false;
	}

	// Initialize custom interactions
	NumCustomInteractions = GetNumCustomInteractions();
	for ( Idx = 0; Idx < NumCustomInteractions; Idx++ )
	{
		CustomInteractionClass = GetCustomInteractionClass(Idx);
		CustomInteraction = new(Self) CustomInteractionClass;
		if ( InsertInteraction(CustomInteraction) == -1 )
		{
			OutError = "Failed to add interaction to GlobalInteractions array:" @ CustomInteraction;
			return false;
		}
		SetCustomInteractionObject(CustomInteraction);
	}

	assert(UIControllerClass != None);

	// Create a interaction to handle UI input.
	UIController = new(Self) UIControllerClass;
	if ( InsertInteraction(UIController) == -1 )
	{
		OutError = "Failed to add interaction to GlobalInteractions array:" @ UIController;
		return false;
	}

	// Create the viewport's player management interaction.
	PlayerInteraction = new(Self) class'PlayerManagerInteraction';
	if ( InsertInteraction(PlayerInteraction) == -1 )
	{
		OutError = "Failed to add interaction to GlobalInteractions array:" @ PlayerInteraction;
		return false;
	}

	// Disable the old UI system, if desired for debugging
	if( bDebugNoGFxUI )
	{
		DebugSetUISystemEnabled(TRUE, FALSE);
	}
	
	// create the initial player - this is necessary or we can't render anything in-game.
	return CreateInitialPlayer(OutError);
}

/**
 * Create the game's initial player at startup.  First search for a player that is signed into the OnlineSubsystem; if none are found,
 * create a player with a ControllerId of 0.
 *
 * @param	OutError	receives the error string if an error occurs while creating the player.
 *
 * @return	TRUE if a player was successfully created.
 */
function bool CreateInitialPlayer( out string OutError )
{
	local int ControllerId;
	local bool bFoundInitialGamepad, bResult;

	for ( ControllerId = 0; ControllerId < class'UIRoot'.const.MAX_SUPPORTED_GAMEPADS; ControllerId++ )
	{
		if ( UIController.IsLoggedIn(ControllerId) )
		{
			bFoundInitialGamepad = true;
			bResult = CreatePlayer(ControllerId, OutError, false) != None;
			break;
		}
	}

	if ( !bFoundInitialGamepad || !bResult )
	{
		// find the first connected gamepad
		for ( ControllerId = 0; ControllerId < class'UIRoot'.const.MAX_SUPPORTED_GAMEPADS; ControllerId++ )
		{
			if ( UIController.IsGamepadConnected(ControllerId) )
			{
				bFoundInitialGamepad = true;
				bResult = CreatePlayer(ControllerId, OutError, false) != None;
				break;
			}
		}
	}

	if ( !bFoundInitialGamepad || !bResult )
	{
		bResult = CreatePlayer(0, OutError, false) != None;
	}

	return bResult;
}

/**
 * Inserts an interaction into the GlobalInteractions array at the specified index
 *
 * @param	NewInteraction	the interaction that should be inserted into the array
 * @param	Index			the position in the GlobalInteractions array to insert the element.
 *							if no value (or -1) is specified, inserts the interaction at the end of the array
 *
 * @return	the position in the GlobalInteractions array where the element was placed, or -1 if the element wasn't
 *			added to the array for some reason
 */
event int InsertInteraction( Interaction NewInteraction, optional int InIndex = -1 )
{
	local int Result;

	Result = -1;
	if ( NewInteraction != None )
	{
		// if the specified index is -1, assume that the item should be added to the end of the array
		if ( InIndex == -1 )
		{
			InIndex = GlobalInteractions.Length;
		}

		// if the index is a negative value other than -1, don't add the element as someone made a mistake
		if ( InIndex >= 0 )
		{
			// clamp the Index to avoid expanding the array needlessly
			Result = Clamp(InIndex, 0, GlobalInteractions.Length);

			// now insert the item
			GlobalInteractions.Insert(Result, 1);
			GlobalInteractions[Result] = NewInteraction;
			NewInteraction.Init();
			NewInteraction.OnInitialize();
		}
		else
		{
			`warn("Invalid insertion index specified:" @ InIndex);
		}
	}

	return Result;
}

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 */
event GameSessionEnded()
{
	local int i;

	for ( i = 0; i < GlobalInteractions.Length; i++ )
	{
		GlobalInteractions[i].NotifyGameSessionEnded();
	}
}

/**
 * Sets the screen layout configuration that the player wishes to use when in split-screen mode.
 */
function SetSplitscreenConfiguration( ESplitScreenType SplitType )
{
	DesiredSplitscreenType = SplitType;
}

/**
 * @return	the actual splitscreen type being used, taking into account the number of players.
 */
function ESplitScreenType GetSplitscreenConfiguration()
{
	return ActiveSplitscreenType;
}

/**
 * Sets the value of ActiveSplitscreenConfiguration based on the desired split-screen layout type, current number of players, and any other
 * factors that might affect the way the screen should be layed out.
 */
function UpdateActiveSplitscreenType()
{
	local ESplitScreenType SplitType;

	SplitType = DesiredSplitscreenType;
	switch ( GamePlayers.Length )
	{
		case 0:
		case 1:
			SplitType = eSST_NONE;
			break;

		case 2:
			if ( (SplitType != eSST_2P_HORIZONTAL) && (SplitType != eSST_2P_VERTICAL) )
			{
				SplitType = Default2PSplitType;
			}
			break;

		case 3:
			if ( (SplitType != eSST_3P_FAVOR_TOP) && (SplitType != eSST_3P_FAVOR_BOTTOM) )
			{
				SplitType = Default3PSplitType;
			}
			break;

		default:
			SplitType = eSST_4P;
			break;
	}

	ActiveSplitscreenType = SplitType;
}

/**
 * Called before rendering to allow the game viewport to allocate subregions to players.
 */
event LayoutPlayers()
{
	local int Idx;
	local ESplitScreenType SplitType;

	UpdateActiveSplitscreenType();
	SplitType = GetSplitscreenConfiguration();

	// Initialize the players
	for ( Idx = 0; Idx < GamePlayers.Length; Idx++ )
	{
		if ( SplitType < SplitscreenInfo.Length && Idx < SplitscreenInfo[SplitType].PlayerData.Length )
		{
			GamePlayers[Idx].Size.X =	SplitscreenInfo[SplitType].PlayerData[Idx].SizeX;
			GamePlayers[Idx].Size.Y =	SplitscreenInfo[SplitType].PlayerData[Idx].SizeY;
			GamePlayers[Idx].Origin.X =	SplitscreenInfo[SplitType].PlayerData[Idx].OriginX;
			GamePlayers[Idx].Origin.Y =	SplitscreenInfo[SplitType].PlayerData[Idx].OriginY;
		}
		else
		{
			GamePlayers[Idx].Size.X =	0.f;
			GamePlayers[Idx].Size.Y =	0.f;
			GamePlayers[Idx].Origin.X =	0.f;
			GamePlayers[Idx].Origin.Y =	0.f;
		}
	}
}

/** called before rending subtitles to allow the game viewport to determine the size of the subtitle area
 * @param Min top left bounds of subtitle region (0 to 1)
 * @param Max bottom right bounds of subtitle region (0 to 1)
 */
event GetSubtitleRegion(out vector2D MinPos, out vector2D MaxPos)
{
	MaxPos.X = 1.0f;
	MaxPos.Y = (GamePlayers.length == 1) ? 0.9f : 0.5f;
}

/**
* Convert a LocalPlayer to it's index in the GamePlayer array
* Returns -1 if the index could not be found.
*/
final function int ConvertLocalPlayerToGamePlayerIndex( LocalPlayer LPlayer )
{
	return GamePlayers.Find( LPlayer );
}

/**
 * Whether the player at LocalPlayerIndex's viewport has a "top of viewport" safezone or not.
 */
final function bool HasTopSafeZone( int LocalPlayerIndex )
{
	switch ( GetSplitscreenConfiguration() )
	{
		case eSST_NONE:
		case eSST_2P_VERTICAL:
			return true;

		case eSST_2P_HORIZONTAL:
		case eSST_3P_FAVOR_TOP:
			return (LocalPlayerIndex == 0) ? true : false;

		case eSST_3P_FAVOR_BOTTOM:
		case eSST_4P:
			return (LocalPlayerIndex < 2) ? true : false;
	}

	return false;
}

/**
* Whether the player at LocalPlayerIndex's viewport has a "bottom of viewport" safezone or not.
*/
final function bool HasBottomSafeZone( int LocalPlayerIndex )
{
	switch ( GetSplitscreenConfiguration() )
	{
		case eSST_NONE:
		case eSST_2P_VERTICAL:
			return true;

		case eSST_2P_HORIZONTAL:
		case eSST_3P_FAVOR_TOP:
			return (LocalPlayerIndex == 0) ? false : true;

		case eSST_3P_FAVOR_BOTTOM:
		case eSST_4P:
			return (LocalPlayerIndex > 1) ? true : false;
	}

	return false;
}

/**
 * Whether the player at LocalPlayerIndex's viewport has a "left of viewport" safezone or not.
 */
final function bool HasLeftSafeZone( int LocalPlayerIndex )
{
	switch ( GetSplitscreenConfiguration() )
	{
		case eSST_NONE:
		case eSST_2P_HORIZONTAL:
			return true;

		case eSST_2P_VERTICAL:
			return (LocalPlayerIndex == 0) ? true : false;

		case eSST_3P_FAVOR_TOP:
			return (LocalPlayerIndex < 2) ? true : false;

		case eSST_3P_FAVOR_BOTTOM:
		case eSST_4P:
			return (LocalPlayerIndex == 0 || LocalPlayerIndex == 2) ? true : false;
	}

	return false;
}

/**
 * Whether the player at LocalPlayerIndex's viewport has a "right of viewport" safezone or not.
 */
final function bool HasRightSafeZone( int LocalPlayerIndex )
{
	switch ( GetSplitscreenConfiguration() )
	{
		case eSST_NONE:
		case eSST_2P_HORIZONTAL:
			return true;

		case eSST_2P_VERTICAL:
		case eSST_3P_FAVOR_BOTTOM:
			return (LocalPlayerIndex > 0) ? true : false;

		case eSST_3P_FAVOR_TOP:
			return (LocalPlayerIndex == 1) ? false : true;

		case eSST_4P:
			return (LocalPlayerIndex == 0 || LocalPlayerIndex == 2) ? false : true;
	}

	return false;
}

/**
* Get the total pixel size of the screen.
* This is different from the pixel size of the viewport since we could be in splitscreen
*/
final function GetPixelSizeOfScreen( out float out_Width, out float out_Height, canvas Canvas, int LocalPlayerIndex )
{
	switch ( GetSplitscreenConfiguration() )
	{
	case eSST_NONE:
		out_Width = Canvas.ClipX;
		out_Height = Canvas.ClipY;
		return;
	case eSST_2P_HORIZONTAL:
		out_Width = Canvas.ClipX;
		out_Height = Canvas.ClipY * 2;
		return;
	case eSST_2P_VERTICAL:
		out_Width = Canvas.ClipX * 2;
		out_Height = Canvas.ClipY;
		return;
	case eSST_3P_FAVOR_TOP:
		if ( LocalPlayerIndex == 0 )
		{
			out_Width = Canvas.ClipX;
		}
		else
		{
			out_Width = Canvas.ClipX * 2;
		}
		out_Height = Canvas.ClipY * 2;
		return;
	case eSST_3P_FAVOR_BOTTOM:
		if ( LocalPlayerIndex == 2 )
		{
			out_Width = Canvas.ClipX;
		}
		else
		{
			out_Width = Canvas.ClipX * 2;
		}
		out_Height = Canvas.ClipY * 2;
		return;
	case eSST_4P:
		out_Width = Canvas.ClipX * 2;
		out_Height = Canvas.ClipY * 2;
		return;
	}
}

/**
* Calculate the amount of safezone needed for a single side for both vertical and horizontal dimensions
*/
final function CalculateSafeZoneValues( out float out_Horizontal, out float out_Vertical, canvas Canvas, int LocalPlayerIndex, bool bUseMaxPercent )
{
	local float ScreenWidth, ScreenHeight, XSafeZoneToUse, YSafeZoneToUse;

	XSafeZoneToUse = bUseMaxPercent ? TitleSafeZone.MaxPercentX : TitleSafeZone.RecommendedPercentX;
	YSafeZoneToUse = bUseMaxPercent ? TitleSafeZone.MaxPercentY : TitleSafeZone.RecommendedPercentY;

	GetPixelSizeOfScreen( ScreenWidth, ScreenHeight, Canvas, LocalPlayerIndex );
	out_Horizontal = (ScreenWidth * (1 - XSafeZoneToUse) / 2.0f);
	out_Vertical = (ScreenHeight * (1 - YSafeZoneToUse) / 2.0);
}

/*
 * Return pixel size of the deadzone based on which local player it is, and which zone they want to inquire
 */
final function float CalculateDeadZone( LocalPlayer LPlayer, ESafeZoneType SZType, canvas Canvas, optional bool bUseMaxPercent )
{
	local bool bHasSafeZone;
	local int LocalPlayerIndex;
	local float HorizSafeZoneValue, VertSafeZoneValue;

	if ( LPlayer != None )
	{
		LocalPlayerIndex = ConvertLocalPlayerToGamePlayerIndex( LPlayer );

		if ( LocalPlayerIndex != -1 )
		{
			// see if this player should have a safe zone for this particular zonetype
			switch ( SZType )
			{
			case eSZ_TOP:
				bHasSafeZone = HasTopSafeZone( LocalPlayerIndex );
				break;
			case eSZ_BOTTOM:
				bHasSafeZone = HasBottomSafeZone( LocalPlayerIndex );
				break;
			case eSZ_LEFT:
				bHasSafeZone = HasLeftSafeZone( LocalPlayerIndex );
				break;
			case eSZ_RIGHT:
				bHasSafeZone = HasRightSafeZone( LocalPlayerIndex );
				break;
			}

			// if they need a safezone, then calculate it and return it
			if ( bHasSafeZone )
			{
				// calculate the safezones
				CalculateSafeZoneValues( HorizSafeZoneValue, VertSafeZoneValue, Canvas, LocalPlayerIndex, bUseMaxPercent );

				if ( SZType == eSZ_TOP || SZType == eSZ_BOTTOM )
				{
					return VertSafeZoneValue;
				}
				else
				{
					return HorizSafeZoneValue;
				}
			}
		}
	}

	return 0.f;
}

/*
* Return true if the safe zone exists
* pixel size of the deadzone for all sides (right/left/top/bottom) based on which local player it is
*/
final function bool CalculateDeadZoneForAllSides( LocalPlayer LPlayer, Canvas Canvas, out float fTopSafeZone, out float fBottomSafeZone, out float fLeftSafeZone, out float fRightSafeZone, optional bool bUseMaxPercent )
{
	// save separate - if the split screen is in bottom right, then
	local bool bHasTopSafeZone, bHasBottomSafeZone, bHasRightSafeZone, bHasLeftSafeZone;
	local int LocalPlayerIndex;
	local float HorizSafeZoneValue, VertSafeZoneValue;

	if ( LPlayer != None )
	{
		LocalPlayerIndex = ConvertLocalPlayerToGamePlayerIndex( LPlayer );

		if ( LocalPlayerIndex != -1 )
		{
			// see if this player should have a safe zone for any particular zonetype
			bHasTopSafeZone = HasTopSafeZone( LocalPlayerIndex );
			bHasBottomSafeZone = HasBottomSafeZone( LocalPlayerIndex );
			bHasLeftSafeZone = HasLeftSafeZone( LocalPlayerIndex );
			bHasRightSafeZone = HasRightSafeZone( LocalPlayerIndex );

			// if they need a safezone, then calculate it and save it
			if ( bHasTopSafeZone || bHasBottomSafeZone || bHasLeftSafeZone || bHasRightSafeZone)
			{
				// calculate the safezones
				CalculateSafeZoneValues( HorizSafeZoneValue, VertSafeZoneValue, Canvas, LocalPlayerIndex, bUseMaxPercent );

				if (bHasTopSafeZone)
				{
					fTopSafeZone = VertSafeZoneValue;
				}
				else
				{
					fTopSafeZone = 0.f;
				}

				if (bHasBottomSafeZone)
				{
					fBottomSafeZone = VertSafeZoneValue;
				}
				else
				{
					fBottomSafeZone = 0.f;
				}

				if (bHasLeftSafeZone)
				{
					fLeftSafeZone = HorizSafeZoneValue;
				}
				else
				{
					fLeftSafeZone = 0.f;
				}

				if (bHasRightSafeZone)
				{
					fRightSafeZone = HorizSafeZoneValue;
				}
				else
				{
					fRightSafeZone = 0.f;
				}

				return TRUE;
			}
		}
	}

	return FALSE;
}

/**
 * Calculate the pixel value of the center of the viewport - this takes the safezones into consideration.
 */
final function CalculatePixelCenter( out float out_CenterX, out float out_CenterY, LocalPlayer LPlayer, canvas Canvas, optional bool bUseMaxPercent )
{
	local int LocalPlayerIndex;
	local float HorizSafeZoneValue, VertSafeZoneValue;

	// get the center of the viewport
	out_CenterX = Canvas.ClipX / 2.f;
	out_CenterY = Canvas.ClipY / 2.f;

	// calculate any safezone adjustments
	if ( LPlayer != None )
	{
		// get the index into the GamePlayer array
		LocalPlayerIndex = ConvertLocalPlayerToGamePlayerIndex( LPlayer );

		if ( LocalPlayerIndex != -1 )
		{
			// calculate the safezones
			CalculateSafeZoneValues( HorizSafeZoneValue, VertSafeZoneValue, Canvas, LocalPlayerIndex, bUseMaxPercent );

			// apply the safezone adjustments where needed
			switch ( GetSplitscreenConfiguration() )
			{
				case eSST_NONE:
				return;

				case eSST_2P_HORIZONTAL:
					if ( LocalPlayerIndex == 0 )
					{
						out_CenterY += VertSafeZoneValue/2;
					}
					else
					{
						out_CenterY -= VertSafeZoneValue/2;
					}
				return;

				case eSST_2P_VERTICAL:
					if ( LocalPlayerIndex == 0 )
					{
						out_CenterX += HorizSafeZoneValue/2;
					}
					else
					{
						out_CenterX -= HorizSafeZoneValue/2;
					}
				return;

				case eSST_3P_FAVOR_TOP:
					if ( LocalPlayerIndex == 0 )
					{
						out_CenterY += VertSafeZoneValue/2;
					}
					else
					{
						out_CenterY -= VertSafeZoneValue/2;
						if ( LocalPlayerIndex == 1 )
						{
							out_CenterX += HorizSafeZoneValue/2;
						}
						else
						{
							out_CenterX -= HorizSafeZoneValue/2;
						}
					}
				return;

				case eSST_3P_FAVOR_BOTTOM:
					if ( LocalPlayerIndex == 2 )
					{
						out_CenterY -= VertSafeZoneValue/2;
					}
					else
					{
						out_CenterY += VertSafeZoneValue/2;
						if ( LocalPlayerIndex == 0 )
						{
							out_CenterX += HorizSafeZoneValue/2;
						}
						else
						{
							out_CenterX -= HorizSafeZoneValue/2;
						}
					}
				return;

				case eSST_4P:
					if ( LocalPlayerIndex < 2 )
					{
						out_CenterY += VertSafeZoneValue/2;
					}
					else
					{
						out_CenterY -= VertSafeZoneValue/2;
					}

					if ( LocalPlayerIndex == 0 || LocalPlayerIndex == 2 )
					{
						out_CenterX += HorizSafeZoneValue/2;
					}
					else
					{
						out_CenterX -= HorizSafeZoneValue/2;
					}
				return;
			}
		}
	}
}

/**
 * Called every frame to allow the game viewport to update time based state.
 * @param	DeltaTime - The time since the last call to Tick.
 */
event Tick(float DeltaTime);

/**
* Draw the safe area using the current TitleSafeZone settings
*/
function DrawTitleSafeArea( canvas Canvas )
{
	// red colored max safe area box
	Canvas.SetDrawColor(255,0,0,255);
	Canvas.SetPos(Canvas.ClipX * (1 - TitleSafeZone.MaxPercentX) / 2.0, Canvas.ClipY * (1 - TitleSafeZone.MaxPercentY) / 2.0);
	Canvas.DrawBox(Canvas.ClipX * TitleSafeZone.MaxPercentX, Canvas.ClipY * TitleSafeZone.MaxPercentY);

	// yellow colored recommended safe area box
	Canvas.SetDrawColor(255,255,0,255);
	Canvas.SetPos(Canvas.ClipX * (1 - TitleSafeZone.RecommendedPercentX) / 2.0, Canvas.ClipY * (1 - TitleSafeZone.RecommendedPercentY) / 2.0);
	Canvas.DrawBox(Canvas.ClipX * TitleSafeZone.RecommendedPercentX, Canvas.ClipY * TitleSafeZone.RecommendedPercentY);
}

/**
 * Called after rendering the player views and HUDs to render menus, the console, etc.
 * This is the last rendering call in the render loop
 * @param Canvas - The canvas to use for rendering.
 */
event PostRender(Canvas Canvas)
{
	if( bShowTitleSafeZone )
	{
		DrawTitleSafeArea(Canvas);
	}

	// Render the console.
	ViewportConsole.PostRender_Console(Canvas);

	// Draw the transition screen.
	DrawTransition(Canvas);

	if (ProgressTimeOut > class'Engine'.static.GetCurrentWorldInfo().TimeSeconds)
	{
		DisplayProgressMessage(Canvas);
	}
}

/**
 * display progress messages in center of screen
 */
function DisplayProgressMessage(Canvas Canvas)
{
	local int i, LineCount;
	local float FontDX, FontDY;
	local float X, Y;
	local byte Alpha;
	local float TimeLeft;

	TimeLeft = ProgressTimeOut - class'Engine'.static.GetCurrentWorldInfo().TimeSeconds;
	Alpha = (TimeLeft >= ProgressFadeTime) ? 255 : byte((255 * TimeLeft) / ProgressFadeTime);

	LineCount = 0;

	for (i = 0; i < ArrayCount(ProgressMessage); i++)
	{
		if (ProgressMessage[i] != "")
		{
			LineCount++;
		}
	}

	Canvas.Font = class'Engine'.Static.GetMediumFont();
	Canvas.TextSize ("A", FontDX, FontDY);

	X = (0.5 * Canvas.SizeX);
	Y = (0.5 * Canvas.SizeY);

	Y -= FontDY * (float(LineCount) / 2.0);

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	for (i = 0; i < ArrayCount(ProgressMessage); i++)
	{
		if (ProgressMessage[i] != "")
		{
			Canvas.DrawColor.A = Alpha;

			Canvas.TextSize(ProgressMessage[i], FontDX, FontDY);
			Canvas.SetPos(X - (FontDX / 2.0), Y);
			Canvas.DrawText(ProgressMessage[i]);

			Y += FontDY;
		}
	}
}

/**
 * Displays the transition screen.
 * @param Canvas - The canvas to use for rendering.
 */
function DrawTransition(Canvas Canvas)
{
	switch(Outer.TransitionType)
	{
		case TT_Loading:
			DrawTransitionMessage(Canvas,LoadingMessage);
			break;
		case TT_Saving:
			DrawTransitionMessage(Canvas,SavingMessage);
			break;
		case TT_Connecting:
			DrawTransitionMessage(Canvas,ConnectingMessage);
			break;
		case TT_Precaching:
			DrawTransitionMessage(Canvas,PrecachingMessage);
			break;
		case TT_Paused:
			DrawTransitionMessage(Canvas,PausedMessage);
			break;
	}
}

/**
 * Print a centered transition message with a drop shadow.
 */
function DrawTransitionMessage(Canvas Canvas,string Message)
{
	local float XL, YL;

	Canvas.Font = class'Engine'.Static.GetLargeFont();
	Canvas.bCenter = false;
	Canvas.StrLen( Message, XL, YL );
	Canvas.SetPos(0.5 * (Canvas.ClipX - XL) + 1, 0.66 * Canvas.ClipY - YL * 0.5 + 1);
	Canvas.SetDrawColor(0,0,0);
	Canvas.DrawText( Message, false );
	Canvas.SetPos(0.5 * (Canvas.ClipX - XL), 0.66 * Canvas.ClipY - YL * 0.5);
	Canvas.SetDrawColor(0,0,255);;
	Canvas.DrawText( Message, false );
}

/**
 * Notifies all interactions that a new player has been added to the list of active players.
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was inserted
 * @param	AddedPlayer		the player that was added
 */
final function NotifyPlayerAdded( int PlayerIndex, LocalPlayer AddedPlayer )
{
	local int InteractionIndex;

	LayoutPlayers();
	for ( InteractionIndex = 0; InteractionIndex < GlobalInteractions.Length; InteractionIndex++ )
	{
		if ( GlobalInteractions[InteractionIndex] != None )
		{
			GlobalInteractions[InteractionIndex].NotifyPlayerAdded(PlayerIndex, AddedPlayer);
		}
	}
}

/**
 * Notifies all interactions that a new player has been added to the list of active players.
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was located
 * @param	RemovedPlayer	the player that was removed
 */
final function NotifyPlayerRemoved( int PlayerIndex, LocalPlayer RemovedPlayer )
{
	local int InteractionIndex;

	LayoutPlayers();
	for ( InteractionIndex = GlobalInteractions.Length - 1; InteractionIndex >= 0; InteractionIndex-- )
	{
		if ( GlobalInteractions[InteractionIndex] != None )
		{
			GlobalInteractions[InteractionIndex].NotifyPlayerRemoved(PlayerIndex, RemovedPlayer);
		}
	}
}

/**
 * Adds a LocalPlayer to the local and global list of Players.
 *
 * @param	NewPlayer	the player to add
 */
private final function int AddLocalPlayer( LocalPlayer NewPlayer )
{
	local int InsertIndex;

	InsertIndex = INDEX_NONE;
	if ( NewPlayer != None )
	{
		// add to list
		InsertIndex = GamePlayers.Length;
		GamePlayers[InsertIndex] = NewPlayer;
	}
	return InsertIndex;
}

/**
 * Removes a LocalPlayer from the local and global list of Players.
 *
 * @param	ExistingPlayer	the player to remove
 */
private final function int RemoveLocalPlayer( LocalPlayer ExistingPlayer )
{
	local int Index;

	Index = GamePlayers.Find(ExistingPlayer);
	if ( Index != INDEX_NONE )
	{
		GamePlayers.Remove(Index,1);
	}

	return Index;
}

/** handler for global state messages, generally network connection related (failures, download progress, etc) */
event SetProgressMessage(EProgressMessageType MessageType, string Message, optional string Title, optional bool bIgnoreFutureNetworkMessages)
{
	if (MessageType == PMT_Clear)
	{
		ClearProgressMessages();
	}
	else
	{
		if ( MessageType == PMT_ConnectionFailure )
		{
			NotifyConnectionError(Message, Title);
		}
		else if ( MessageType != PMT_SocketFailure )
		{
			if ( Title != "" )
			{
				ProgressMessage[0] = Title;
				ProgressMessage[1] = Message;
			}
			else
			{
				ProgressMessage[1] = "";
				ProgressMessage[0] = Message;
			}
		}
		else if (MessageType == PMT_SocketFailure)
		{
			//@FIXME: bIgnoreNetworkMessages needs to die
			if (!Outer.GamePlayers[0].Actor.bIgnoreNetworkMessages)
			{
				NotifyConnectionError(Message, Title);
			}
		}
	}
	//@FIXME: bIgnoreNetworkMessages needs to die
	if (!Outer.GamePlayers[0].Actor.bIgnoreNetworkMessages)
	{
		Outer.GamePlayers[0].Actor.bIgnoreNetworkMessages = bIgnoreFutureNetworkMessages;
	}
}

/**
 * Notifies the player that an attempt to connect to a remote server failed, or an existing connection was dropped.
 *
 * @param	Message		a description of why the connection was lost
 * @param	Title		the title to use in the connection failure message.
 */
function NotifyConnectionError( optional string Message=Localize("Errors", "ConnectionFailed", "Engine"), optional string Title=Localize("Errors", "ConnectionFailed_Title", "Engine") )
{
	local WorldInfo WI;

	WI = class'Engine'.static.GetCurrentWorldInfo();
	`log(`location @ `showvar(Title) @ `showvar(Message) @ `showenum(ENetMode,WI.NetMode,NetMode) @ `showvar(WI.GetURLMap(),Map) ,,'DevNet');
	if (WI.NetMode != NM_Standalone)
	{
		if ( WI.Game != None )
		{
			// Mark the server as having a problem
			WI.Game.bHasNetworkError = true;
		}

		//@todo: should we have a Travel() function in this class?
		ConsoleCommand("start ?failed");
	}
}

exec event SetProgressTime(float T)
{
	ProgressTimeOut = T + class'Engine'.static.GetCurrentWorldInfo().TimeSeconds;
}

exec function ClearProgressMessages()
{
	local int i;

	for (i=0; i<ArrayCount(ProgressMessage); i++)
	{
		ProgressMessage[i] = "";
	}
}

/**
 * Retrieves a reference to a LocalPlayer.
 *
 * @param	PlayerIndex		if specified, returns the player at this index in the GamePlayers array.  Otherwise, returns
 *							the player associated with the owner scene.
 *
 * @return	the player that owns this scene or is located in the specified index of the GamePlayers array.
 */
native final function LocalPlayer GetPlayerOwner(int PlayerIndex);

/** Called after the primary player has been changed so that the UI references to the owner are switched */
native final function FixupOwnerReferences();

/**
 * Makes a player the primary player
 * @param PlayerIndex - The index of the player to be made into the primary player
 */
function BecomePrimaryPlayer(int PlayerIndex)
{
	local array<LocalPlayer> OtherPlayers;
	local LocalPlayer PlayerOwner, NextPlayer, OriginalPrimaryPlayer;

	if (UIController != None && PlayerIndex > 0 && PlayerIndex < UIController.GetPlayerCount())
	{
		OriginalPrimaryPlayer = GetPlayerOwner(0);

		// get the player that owns this scene
		PlayerOwner = GetPlayerOwner(PlayerIndex);
		if (PlayerOwner == None)
		{
			`log("GameViewportClient:BecomePrimaryPlayer has failed to find the player owner for index" @ PlayerIndex @ "ABORTING!!!");
			return;
		}

		if (PlayerOwner != None)
		{
			NextPlayer = OriginalPrimaryPlayer;
			while (NextPlayer != None && NextPlayer != PlayerOwner)
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
			while (OtherPlayers.Length > 0)
			{
				NextPlayer = OtherPlayers[0];

				UIController.Outer.Outer.GamePlayers.InsertItem(1, NextPlayer);
				UIController.NotifyPlayerAdded(1, NextPlayer);

				OtherPlayers.Remove(0, 1);
			}
		}

		// if we have a new primary player, reload their profile so that their settings will be applied and fixup references
		NextPlayer = GetPlayerOwner(0);
		if (OriginalPrimaryPlayer != NextPlayer)
		{
			FixupOwnerReferences();
			NextPlayer.Actor.ReloadProfileSettings();
		}
	}
}

/** DEBUG: function to easily allow script to turn on / off the two UI systems for developing during the transition from the old UI to the new GFx UI */
native function DebugSetUISystemEnabled(bool bOldUISystemActive, bool bGFxUISystemActive);

defaultproperties
{
	UIControllerClass=class'Engine.UIInteraction'
	TitleSafeZone=(MaxPercentX=0.9,MaxPercentY=0.9,RecommendedPercentX=0.8,RecommendedPercentY=0.8)

	Default2PSplitType=eSST_2P_HORIZONTAL
	Default3PSplitType=eSST_3P_FAVOR_TOP
	DesiredSplitscreenType=eSST_NONE

	ProgressFadeTime=1.0
	ProgressTimeOut=8.0

	SplitscreenInfo(eSST_None)=			(PlayerData=((SizeX=1.0f,SizeY=1.0f,OriginX=0.0f,OriginY=0.0f)))

	SplitscreenInfo(eSST_2P_HORIZONTAL)={(PlayerData=(
										(SizeX=1.0f,SizeY=0.5f,OriginX=0.0f,OriginY=0.0f),
										(SizeX=1.0f,SizeY=0.5f,OriginX=0.0f,OriginY=0.5f))
										)}

	SplitscreenInfo(eSST_2P_VERTICAL)={(PlayerData=(
										(SizeX=0.5f,SizeY=1.0f,OriginX=0.0f,OriginY=0.0f),
										(SizeX=0.5f,SizeY=1.0f,OriginX=0.5f,OriginY=0.0))
										)}

	SplitscreenInfo(eSST_3P_FAVOR_TOP)={(PlayerData=(
										(SizeX=1.0f,SizeY=0.5f,OriginX=0.0f,OriginY=0.0f),
										(SizeX=0.5f,SizeY=0.5f,OriginX=0.0f,OriginY=0.5f),
										(SizeX=0.5f,SizeY=0.5f,OriginX=0.5f,OriginY=0.5f))
										)}

	SplitscreenInfo(eSST_3P_FAVOR_BOTTOM)={(PlayerData=(
										(SizeX=0.5f,SizeY=0.5f,OriginX=0.0f,OriginY=0.0f),
										(SizeX=0.5f,SizeY=0.5f,OriginX=0.5f,OriginY=0.0f),
										(SizeX=1.0f,SizeY=0.5f,OriginX=0.0f,OriginY=0.5f))
										)}

	SplitscreenInfo(eSST_4P)={(PlayerData=(
										(SizeX=0.5f,SizeY=0.5f,OriginX=0.0f,OriginY=0.0f),
										(SizeX=0.5f,SizeY=0.5f,OriginX=0.5f,OriginY=0.0f),
										(SizeX=0.5f,SizeY=0.5f,OriginX=0.0f,OriginY=0.5f),
										(SizeX=0.5f,SizeY=0.5f,OriginX=0.5f,OriginY=0.5f))
										)}
}
