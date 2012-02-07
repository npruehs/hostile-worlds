/**
 * Controls the UI system.
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIInteraction extends Interaction
	within GameViewportClient
	native(UserInterface)
	config(UI)
	transient
	inherits(FExec,FGlobalDataStoreClientManager,FCallbackEventDevice);

/** the default UISkin - used whenever the skin specified by UISkinName couldn't be loaded */
const DEFAULT_UISKIN = "DefaultUISkin.DefaultSkin";

/** the class to use for the scene client */
var											class<GameUISceneClient>				SceneClientClass;

/**
 * Acts as the interface between the UIInteraction and the active scenes.
 */
var const transient							GameUISceneClient						SceneClient;

/**
 * The path name for the UISkin that should be used
 */
var	config									string									UISkinName;

/**
 * The names of all UISoundCues that can be used in the game.
 */
var	config									array<name>								UISoundCueNames;

/** list of keys that can trigger double-click events */
var	transient								array<name>								SupportedDoubleClickKeys;

/**
 * Manages all persistent global data stores.  Created when UIInteraction is initialized using the value of
 * GEngine.DataStoreClientClass.
 */
var	const transient private{private}		DataStoreClient							DataStoreManager;

`if(`isdefined(STORAGE_MANAGER_IMPLEMENTED))
/**
 * Singleton for managing connected storage devices.
 */
var	const transient private{private}		StorageDeviceManager					StorageManager;
`endif

/**
 * Singleton object which stores ui key mapping configuration data.
 */
var	const transient	public{private}			UIInputConfiguration					UIInputConfig;

/**
 * Runtime generated lookup table that maps a widget class to its list of input key aliases
 */
var const native transient			Map{UClass*,struct FUIInputAliasClassMap*}		WidgetInputAliasLookupTable;

/**
 * Indicates whether there are any active scenes capable of processing input.  Set in UpdateInputProcessingStatus, based
 * on whether there are any active scenes which are capable of processing input.
 */
var	const	transient						bool									bProcessInput;

/**
 * Globally enables/ disables widget tooltips.
 */
var	const	config							bool									bDisableToolTips;

/**
 * Controls whether widgets automatically receive focus when they become active.  Set TRUE to enable this behavior.
 */
var	const	config							bool									bFocusOnActive;

/**
 * The amount of movement required before the UI will process a joystick's axis input.
 */
var	const	config							float									UIJoystickDeadZone;

/**
 * Mouse & joystick axis input will be multiplied by this amount in the UI system.  Higher values make the cursor move faster.
 */
var	const	config							float									UIAxisMultiplier;

/**
 * The amount of time (in seconds) to wait between generating simulated button presses from axis input.
 */
var	const	config							float									AxisRepeatDelay;

/**
 * The amount of time (in seconds) to wait between generating repeat events for mouse buttons (which are not handled by windows).
 */
var	const	config							float									MouseButtonRepeatDelay;

/**
 * The maximum amount of time (in seconds) that can pass between a key press and key release in order to trigger a double-click event
 */
var	const	config							float									DoubleClickTriggerSeconds;

/**
 * The maximum number of pixels to allow between the current mouse position and the last click's mouse position for a double-click
 * event to be triggered
 */
var	const	config							int										DoubleClickPixelTolerance;

/** determines how many seconds must pass after a tooltip has been activated before it is made visible */
var	const	config							float									ToolTipInitialDelaySeconds;

/** determines the number of seconds to display a tooltip before it will automatically be hidden */
var	const	config							float									ToolTipExpirationSeconds;

/** if this is TRUE, then focused widgets will not appear to become "active" when moused over - their appearance will remain "focused" */
var	const	config							bool									bFocusedStateRules;

/**
 * Tracks information relevant to simulating IE_Repeat input events.
 */
struct native transient UIKeyRepeatData
{
	/**
	 * The name of the axis input key that is currently being held.  Used to determine which type of input event
	 * to simulate (i.e. IE_Pressed, IE_Released, IE_Repeat)
	 */
	var	name	CurrentRepeatKey;

	/**
	 * The time (in seconds since the process started) when the next simulated input event will be generated.
	 */
	var	double	NextRepeatTime;

structcpptext
{
    /** Constructors */
	FUIKeyRepeatData()
	: CurrentRepeatKey(NAME_None)
	, NextRepeatTime(0.f)
	{}
}
};

/**
 * Contains parameters for emulating button presses using axis input.
 */
struct native transient UIAxisEmulationData extends UIKeyRepeatData
{
	/**
	 * Determines whether to emulate button presses.
	 */
	var	bool	bEnabled;

structcpptext
{
    /** Constructors */
	FUIAxisEmulationData()
	: FUIKeyRepeatData(), bEnabled(TRUE)
	{}

	/**
	 * Toggles whether this axis emulation is enabled.
	 */
	void EnableAxisEmulation( UBOOL bShouldEnable )
	{
		if ( bEnabled != bShouldEnable )
		{
			bEnabled = bShouldEnable;
			CurrentRepeatKey = NAME_None;
			NextRepeatTime = 0.f;
		}
	}
}
};

/**
 * Tracks the mouse button that is currently being held down for simulating repeat input events.
 */
var	const			transient		UIKeyRepeatData									MouseButtonRepeatInfo;

/**
 * Runtime mapping of the axis button-press emulation configurations.  Built in UIInteraction::InitializeAxisInputEmulations() based
 * on the values retrieved from UIInputConfiguration.
 */
var	const	native	transient		Map{FName,struct FUIAxisEmulationDefinition}	AxisEmulationDefinitions;

/**
 * Tracks the axis key-press emulation data for all players in the game.
 */
var					transient		UIAxisEmulationData								AxisInputEmulation[MAX_SUPPORTED_GAMEPADS];

/** canvas scene for rendering 3d primtives/lights. Created during Init */
var const	native 	transient		pointer											CanvasScene{class FCanvasScene};

/** TRUE if the scene for rendering 3d prims on this UI has been initialized */
var const 			transient 		bool											bIsUIPrimitiveSceneInitialized;

cpptext
{
	/* =======================================
		UObject interface
	======================================= */
	/**
	* Called to finish destroying the object.
	*/
	virtual void FinishDestroy();

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

	/* =======================================
		FExec interface
	======================================= */
	virtual UBOOL Exec(const TCHAR* Cmd,FOutputDevice& Ar);

	/* === FCallbackEventDevice interface === */
	/**
	 * Called for notifications that require no additional information.
	 */
	virtual void Send( ECallbackEventType InType );

	/**
	 * Called when the viewport has been resized.
	 */
	virtual void Send( ECallbackEventType InType, FViewport* InViewport, UINT InMessage);

	/* ==============================================
		FGlobalDataStoreClientManager interface
	============================================== */
	/**
	 * Initializes the singleton data store client that will manage the global data stores.
	 */
	virtual void InitializeGlobalDataStore();

	/* =======================================
		UInteraction interface
	======================================= */
	/**
	 * Called when UIInteraction is added to the GameViewportClient's Interactions array
	 */
	virtual void Init();

	/**
	 * Called once a frame to update the interaction's state.
	 *
	 * @param	DeltaTime - The time since the last frame.
	 */
	virtual void Tick(FLOAT DeltaTime);

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
		UUIInteraction interface
	======================================= */
	/**
	 * Constructor
	 */
	UUIInteraction();

	/**
	 * Cleans up all objects created by this UIInteraction, including unrooting objects and unreferencing any other objects.
	 * Called when the UI system is being closed down (such as when exiting PIE).
	 */
	virtual void TearDownUI();

	/**
	 * Initializes the axis button-press/release emulation map.
	 */
	void InitializeAxisInputEmulations();

	/**
	 * Initializes all of the UI input alias names.
	 */
	void InitializeUIInputAliasNames();

	/**
	 * Initializes all of the UI event key lookup maps.
	 */
	void InitializeInputAliasLookupTable();

	/**
	 * Load the UISkin specified by UISkinName
	 *
	 * @return	a pointer to the UISkin object corresponding to UISkinName, or
	 *			the default UISkin if the configured skin couldn't be loaded
	 */
	class UUISkin* LoadInitialSkin() const;

	/**
	 * Notifies the scene client to render all scenes
	 */
	void RenderUI( FCanvas* Canvas );

	/**
	 * Returns the CDO for the configured scene client class.
	 */
	class UGameUISceneClient* GetDefaultSceneClient() const;

	/**
	 * Returns the UIInputConfiguration singleton, creating one if necessary.
	 */
	class UUIInputConfiguration* GetInputSettings();

	/**
	 * Returns the number of players currently active.
	 */
	static INT GetPlayerCount();

	/**
	 * Retrieves the index (into the Engine.GamePlayers array) for the player which has the ControllerId specified
	 *
	 * @param	ControllerId	the gamepad index of the player to search for
	 *
	 * @return	the index [into the Engine.GamePlayers array] for the player that has the ControllerId specified, or INDEX_NONE
	 *			if no players have that ControllerId
	 */
	static INT GetPlayerIndex( INT ControllerId );

	/**
	 * Returns the index [into the Engine.GamePlayers array] for the player specified.
	 *
	 * @param	Player	the player to search for
	 *
	 * @return	the index of the player specified, or INDEX_NONE if the player is not in the game's list of active players.
	 */
	static INT GetPlayerIndex( class ULocalPlayer* Player );

	/**
	 * Retrieves the ControllerId for the player specified.
	 *
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player to retrieve the ControllerId for
	 *
	 * @return	the ControllerId for the player at the specified index in the GamePlayers array, or INDEX_NONE if the index is invalid
	 */
	static INT GetPlayerControllerId( INT PlayerIndex );

	/**
	 * Returns TRUE if button press/release events should be emulated for the specified axis input.
	 *
	 * @param	AxisKeyName		the name of the axis key that
	 */
	static UBOOL ShouldEmulateKeyPressForAxis( const FName& AxisKeyName );

	/**
	 * Returns a reference to the global data store client, if it exists.
	 *
	 * @return	the global data store client for the game.
	 */
	static class UDataStoreClient* GetDataStoreClient();

//	/**
//	 * @return	reference to the global storage device manager.
//	 */
//	static class UStorageDeviceManager* GetStorageManager();

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
	 * Determine if the canvas scene for primitive rendering needs to be initialized
	 *
	 * @return TRUE if InitUIPrimitiveScene should be called
	 */
	virtual UBOOL NeedsInitUIPrimitiveScene();

	/**
	 * Setup a canvas scene by adding primtives and lights to it from this UI
	 *
	 * @param InCanvasScene - scene for rendering 3D prims
	 */
	virtual void InitUIPrimitiveScene( class FCanvasScene* InCanvasScene );

	/**
	 * Updates the actor components in the canvas scene
	 *
	 * @param InCanvasScene - scene for rendering 3D prims
	 */
	virtual void UpdateUIPrimitiveScene( class FCanvasScene* InCanvasScene );
}

/**
 * Returns the number of players currently active.
 */
static native noexportheader final function int GetPlayerCount() const;

/**
 * Retrieves the index (into the Engine.GamePlayers array) for the player which has the ControllerId specified
 *
 * @param	ControllerId	the gamepad index of the player to search for
 *
 * @return	the index [into the Engine.GamePlayers array] for the player that has the ControllerId specified, or INDEX_NONE
 *			if no players have that ControllerId
 */
static native noexportheader final function int GetPlayerIndex( int ControllerId );

/**
 * Retrieves the ControllerId for the player specified.
 *
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player to retrieve the ControllerId for
 *
 * @return	the ControllerId for the player at the specified index in the GamePlayers array, or INDEX_NONE if the index is invalid
 */
static native noexportheader final function int GetPlayerControllerId( int PlayerIndex );

/**
 * Returns a reference to the global data store client, if it exists.
 *
 * @return	the global data store client for the game.
 */
static native noexportheader final function DataStoreClient GetDataStoreClient();

///**
// * @return	reference to the global storage device manager.
// */
//static native noexportheader final function StorageDeviceManager GetStorageManager();

/**
 * Plays the sound cue associated with the specified name
 *
 * @param	SoundCueName	the name of the UISoundCue to play; should corresond to one of the values of the UISoundCueNames array.
 * @param	PlayerIndex		allows the caller to indicate which player controller should be used to play the sound cue.  For the most
 *							part, all sounds can be played by the first player, regardless of who generated the play sound event.
 *
 * @return	TRUE if the sound cue specified was found in the currently active skin, even if there was no actual USoundCue associated
 *			with that UISoundCue.
 */
native final function bool PlayUISound( name SoundCueName, optional int PlayerIndex=0 );

/**
 * Create a temporary widget for presenting data from unrealscript
 *
 * @param	WidgetClass		the widget class to create
 * @param	WidgetTag		the tag to assign to the widget.
 * @param	Owner			the UIObject that should contain the widget
 *
 * @return	a pointer to a fully initialized widget of the class specified, contained within the transient scene
 */
native final function coerce UIObject CreateTransientWidget(class<UIObject> WidgetClass, Name WidgetTag, optional UIObject Owner);

// Scene stuff
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
native final function coerce UIScene CreateScene( class<UIScene> SceneClass, optional name SceneTag, optional UIScene SceneTemplate );

/**
 * Wrapper for retrieving a LocalPlayer reference for one of the players in the GamePlayers array.
 *
 * @param	PlayerIndex		the index of the player reference to retrieve.
 *
 * @return	a reference to the LocalPlayer object at the specified index in the Engine's GamePlayers array, or None if the index isn't valid.
 */
static final function LocalPlayer GetLocalPlayer( int PlayerIndex )
{
	local UIInteraction UIController;
	local LocalPlayer Result;

	UIController = class'UIRoot'.static.GetCurrentUIController();
	if ( UIController != None && PlayerIndex >= 0 && PlayerIndex < UIController.Outer.Outer.GamePlayers.Length )
	{
		Result = UIController.Outer.Outer.GamePlayers[PlayerIndex];
	}

	return Result;
}

/**
 * Called when a new player has been added to the list of active players (i.e. split-screen join)
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was inserted
 * @param	AddedPlayer		the player that was added
 */
function NotifyPlayerAdded( int PlayerIndex, LocalPlayer AddedPlayer )
{
	local UIAxisEmulationData Empty;

	// make sure the axis emulation data for this player has been reset
	if ( PlayerIndex >=0 && PlayerIndex < MAX_SUPPORTED_GAMEPADS )
	{
		Empty.CurrentRepeatKey = 'None';
		AxisInputEmulation[PlayerIndex] = Empty;
	}

	if ( SceneClient != None )
	{
		SceneClient.NotifyPlayerAdded(PlayerIndex, AddedPlayer);
	}

`if(`isdefined(STORAGE_MANAGER_IMPLEMENTED))
	if ( StorageManager != None )
	{
		StorageManager.PlayerCreated(AddedPlayer.ControllerId);
	}
`endif
}

/**
 * Called when a player has been removed from the list of active players (i.e. split-screen players)
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was located
 * @param	RemovedPlayer	the player that was removed
 */
function NotifyPlayerRemoved( int PlayerIndex, LocalPlayer RemovedPlayer )
{
	local int PlayerCount, NextPlayerIndex, i;
	local UIAxisEmulationData Empty;


	// clear the axis emulation data for this player
	if ( PlayerIndex >=0 && PlayerIndex < MAX_SUPPORTED_GAMEPADS )
	{
		// if we removed a player from the middle of the list, we need to migrate all of the axis emulation data from
		// that player's previous slot into the new slot
		PlayerCount = GetPlayerCount();

		// PlayerCount has to be less that MAX_SUPPORTED_GAMEPADS if we just removed a player; if it does not, it means
		// that someone changed the order in which NotifyPlayerRemoved is called so that the player is actually removed from
		// the array after calling NotifyPlayerRemoved.  If that happens, this assertion is here to ensure that this code is
		// updated as well.
		Assert(PlayerCount < MAX_SUPPORTED_GAMEPADS);

		// we removed a player that was in a middle slot - migrate the data for all subsequence players into the correct position
		for ( i = PlayerIndex; i < PlayerCount; i++ )
		{
			NextPlayerIndex = i + 1;
			AxisInputEmulation[i].NextRepeatTime = AxisInputEmulation[NextPlayerIndex].NextRepeatTime;
			AxisInputEmulation[i].CurrentRepeatKey = AxisInputEmulation[NextPlayerIndex].CurrentRepeatKey;
			AxisInputEmulation[i].bEnabled = AxisInputEmulation[NextPlayerIndex].bEnabled;
		}

		Empty.CurrentRepeatKey = 'None';
		AxisInputEmulation[PlayerCount] = Empty;
	}

`if(`isdefined(STORAGE_MANAGER_IMPLEMENTED))
	if ( StorageManager != None )
	{
		StorageManager.PlayerRemoved(RemovedPlayer.ControllerId);
	}
`endif

	if ( SceneClient != None )
	{
		SceneClient.NotifyPlayerRemoved(PlayerIndex, RemovedPlayer);
	}
}

/**
 * Set the mouse position to the coordinates specified
 *
 * @param	NewX	the X position to move the mouse cursor to (in pixels)
 * @param	NewY	the Y position to move the mouse cursor to (in pixels)
 */
final function SetMousePosition( int NewMouseX, int NewMouseY )
{
	SceneClient.SetMousePosition(NewMouseX, NewMouseY);
}

/** @return Returns the current login status for the specified controller id. */
static final event ELoginStatus GetLoginStatus( int ControllerId )
{
	local ELoginStatus Result;
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	Result = LS_NotLoggedIn;

	if ( ControllerId != INDEX_NONE )
	{
		// Figure out if we have an online subsystem registered
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None)
			{
				// Get status
				Result = PlayerInterface.GetLoginStatus(ControllerId);
			}
		}
	}

	return Result;
}

/** @return	the lowest common denominator for the login status of all local players */
final function ELoginStatus GetLowestLoginStatusOfControllers()
{
	local ELoginStatus Result, LoginStatus;
	local int PlayerIndex;

	Result = LS_LoggedIn;

	for( PlayerIndex = 0; PlayerIndex < GamePlayers.Length; PlayerIndex++ )
	{
		LoginStatus = GetLoginStatus( GamePlayers[PlayerIndex].ControllerId );
		if ( LoginStatus < Result )
		{
			Result = LoginStatus;
		}
	}

	return Result;
}

/** @return Returns the current status of the platform's network connection. */
static final event bool HasLinkConnection()
{
	local bool bResult;
	local OnlineSubsystem OnlineSub;
	local OnlineSystemInterface SystemInterface;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		SystemInterface = OnlineSub.SystemInterface;
		if (SystemInterface != None)
		{
			bResult = SystemInterface.HasLinkConnection();
		}
	}

	return bResult;
}

/** @return Returns whether or not the specified player is logged in at all. */
static final event bool IsLoggedIn( int ControllerId, optional bool bRequireOnlineLogin )
{
	local bool bResult;
	local ELoginStatus LoginStatus;

	LoginStatus = GetLoginStatus(ControllerId);

	bResult = (LoginStatus == LS_LoggedIn) || (LoginStatus == LS_UsingLocalProfile && !bRequireOnlineLogin);
	return bResult;
}

/** @return	the number of players signed into the online service */
static final function int GetLoggedInPlayerCount( optional bool bRequireOnlineLogin )
{
	local int ControllerId, Result;

	for ( ControllerId = 0; ControllerId < MAX_SUPPORTED_GAMEPADS; ControllerId++ )
	{
		if ( IsLoggedIn(ControllerId, bRequireOnlineLogin) )
		{
			Result++;
		}
	}

	return Result;
}

/** Returns the number of guests logged in */
static final function int GetNumGuestsLoggedIn()
{
	local OnlineSubsystem OnlineSub;
	local int ControllerId;
	local int GuestCount;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None && OnlineSub.PlayerInterface != none)
	{
		for (ControllerId = 0; ControllerId < MAX_SUPPORTED_GAMEPADS; ControllerId++)
		{
			if (OnlineSub.PlayerInterface.IsGuestLogin(ControllerId))
			{
				GuestCount++;
			}
		}
	}
	return GuestCount;
}

/**
 * Check whether a gamepad is connected and turned on.
 *
 * @param	ControllerId	the id of the gamepad to check
 *
 * @return	TRUE if the gamepad with the specified id is connected.
 */
static final function bool IsGamepadConnected( int ControllerId )
{
	local bool bResult;
	local OnlineSubsystem OnlineSub;
	local OnlineSystemInterface SystemInterface;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		SystemInterface = OnlineSub.SystemInterface;
		if (SystemInterface != None)
		{
			bResult = SystemInterface.IsControllerConnected(ControllerId);
		}
	}

	return bResult;
}

/**
 * @param	ControllerConnectionStatusOverrides		array indicating the connection status of each gamepad; should always contain
 *													MAX_SUPPORTED_GAMEPADS elements; useful when executing code as a result of a controller
 *													insertion/removal notification, as IsControllerConnected isn't reliable in that case.
 *
 * @return	the number of gamepads which are currently connected and turned on.
 */
static final function int GetConnectedGamepadCount( optional array<bool> ControllerConnectionStatusOverrides )
{
	local int i, Result;

	for ( i = 0; i < MAX_SUPPORTED_GAMEPADS; i++ )
	{
		if ( i < ControllerConnectionStatusOverrides.Length )
		{
			if ( ControllerConnectionStatusOverrides[i] )
			{
				Result++;
			}
		}
		else if ( IsGamepadConnected(i) )
		{
			Result++;
		}
	}

	return Result;
}

/** @return Returns whether or not the specified player can play online. */
static final event bool CanPlayOnline( int ControllerId )
{
	local EFeaturePrivilegeLevel Result;
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	Result = FPL_Disabled;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			Result = PlayerInterface.CanPlayOnline(ControllerId);
		}
	}

	return Result!=FPL_Disabled;
}

/** @return	whether all local players can play online or not */
final function bool CanAllPlayOnline()
{
	local int PlayerIndex;

	for( PlayerIndex = 0; PlayerIndex < GamePlayers.Length; PlayerIndex++ )
	{
		if ( !CanPlayOnline(GamePlayers[PlayerIndex].ControllerId) )
		{
			return false;
		}
	}

	return true;
}

/**
 * Wrapper for getting the NAT type
 */
static final event ENATType GetNATType()
{
	local OnlineSubsystem OnlineSub;
	local OnlineSystemInterface SystemInterface;
	local ENATType Result;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		SystemInterface = OnlineSub.SystemInterface;
		if (SystemInterface != None)
		{
			Result = SystemInterface.GetNATType();
		}
	}

	return Result;
}

/* === Interaction interface === */

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 */
function NotifyGameSessionEnded()
{
	// notify the UI first so that all player data stores are still around for their subscribers to publish to.
	if ( SceneClient != None )
	{
		SceneClient.NotifyGameSessionEnded();
	}

	if ( DataStoreManager != None )
	{
		DataStoreManager.NotifyGameSessionEnded();
	}

	if ( UIInputConfig != None )
	{
		UIInputConfig.NotifyGameSessionEnded();
	}
}

DefaultProperties
{
	SceneClientClass=class'GameUISceneClient'
}
