/**
* MobilePlayerInput
*
* This is the base class for processing input for mobile devices while in the game
*
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*/

class MobilePlayerInput extends PlayerInput within GamePlayerController
	native
	DependsOn(MobileInputZone)
	config(Game);

/** 
 * This structure contains data for individual touch events queued for a specific touch handle
 */
 
struct native TouchDataEvent
{
	/** Holds the type of event */
	var MobileInputzone.EZoneTouchEvent EventType;

	/** Holds the current location of the touch */
	var vector2D Location;

	/** Holds the device timestamp of when this event occurred */
	var double DeviceTime;
};



/** 
 * the MPI keeps track of all touches coming from a device.  When the status of a touch changes, it tracks it and then passes it along to 
 * the associated MobileInputZone.
 */
 
struct native TouchData
{
	/** Holds the ID of the current touch */
	var int Handle;

	/** Holds the current location of the touch */
	var vector2D Location;

	/** Total distance that the finger moved since it initially touched down */
	var float TotalMoveDistance;

	/** Holds the device timestamp of when the original touch occurred */
	var double InitialDeviceTime;

	/** How long this touch has been active */
	var float TouchDuration;

	/** Device timestamp of most recent event */
	var double MoveEventDeviceTime;

	/** Time delta between the movement events the last time this touch moved */
	var float MoveDeltaTime;

	/** If true, this touch entry is in use, otherwise feel free to use it for touches */
	var bool bInUse;

	/** Holds the zone that is currently processing this touch */
	var MobileInputZone Zone;

	/** Holds the current state of the touch */
	var MobileInputzone.EZoneTouchEvent State;

	/** Events queued up for this touch.  Because we may receive several touch movement events per tick,
	    we store a list of events and process them in order when we can. */
	var array<TouchDataEvent> Events;
};

/** Keeps track of all of the touches currently active on a device */
const NumTouchDataEntries		= 5;
var (Input) TouchData Touches[NumTouchDataEntries];

/**
 * The object that the user is currently interacting with.
 * e.g. When a user presses on the button, this button is the
 * interactive object until the user raises her finger and causes
 * an UnTouch event.
 */
var MobileMenuObject InteractiveObject;

/** Defines a mobile input group */
struct native MobileInputGroup
{
	/** The name of this group */
	var string GroupName;

	/** The List of zones associated with this group */
	var editinline array<MobileInputZone> AssociatedZones;
};

/** Holds a list of available groups */
var (Input) EditInline array<MobileInputGroup> MobileInputGroups;

/** Holds the index of the current group */
var (Input) int CurrentMobileGroup;

/** Holds a list of mobile input zones. */
var (Input) editinline array<MobileInputZone> MobileInputZones;

/** Record of each MobileInputZone class (and subclasses) instances */
struct native MobileInputZoneClassMap
{
	/* Name of the instance */
	var string Name;

	/* Class type of the instance */
	var class<MobileInputZone> ClassType;
};

/** Classes that inherit from MobileInputZone - filled in by NativeInitializeInputSystem() */
var array<MobileInputZoneClassMap> MobileInputZoneClasses;

/** If True, this mobile input system support an accelerometer */
var (Input) const bool bSupportsAccelerometer;

/** Holds the current Tilt value for mobile devices */
var (Input) float MobilePitch;

/** Holds the center value for the pitch. */
var (Input) float MobilePitchCenter;

/** Pitch sensitivity */
var (Input) float MobilePitchMultiplier;

/** Holds the current Yaw value for mobile devices */
var (Input) float MobileYaw;

/** Holds the center value for the Yaw. */
var (Input) float MobileYawCenter;

/** Pitch sensitivity */
var (Input) float MobileYawMultiplier;

/** How much of a dead zone should the pitch have */
var (input) config float MobilePitchDeadzoneSize;

/** How much of a dead zone should the yaw have */
var (input) config float MobileYawDeadzoneSize;

/** Used to determine if a touch is a double tap */
var (input) config float MobileDoubleTapTime;

/** You have to hold down a tap at least this long to register it as a tap */
var (input) config float MobileMinHoldForTap;

/** Used to determine how quickly to send repeat events for touch+held */
var (input) config float MobileTapRepeatTime;

// **********************************************************************************
// The MobilePlayerInput is also the hub for the mobile menu system. 
// **********************************************************************************

/** This is the menu stack. */  
var (menus) array<MobileMenuScene> MobileMenuStack;

/** Used for debugging native code */
var (debug) string NativeDebugString;

/** This will be set in NativeInitializeInputZones if -SimMobile is on the command line. */
var (debug) bool bFakeMobileTouches;

// Holds the amount of time the view port has been inactive
var (Current) float MobileInactiveTime; 

cpptext
{
	/**
	 * Takes a touch and looks up the InputZone that would handle it.
	 *
	 * @param TouchLocation		 Where the touch occurred
	 * @returns the zone that will be managing this touch
	 */
	UMobileInputZone* HitTest(FVector2D TouchLocation);

	/**
	 * Handle a touch event coming from the device. 
	 *
	 * NOTE: no processing of the touch happens here.  This just tracks the touch in the Touches stack.  Processing 
	 * happens each tick
	 *
	 * @param Handle			the id of the touch
	 * @param Type				What type of event is this
	 * @param TouchLocation		Where the touch occurred
	 * @param DeviceTimestamp	Input event timestamp from the device
	 */
	virtual void InputTouch(UINT Handle, BYTE Type, FVector2D TouchLocation, DOUBLE DeviceTimestamp);


	/**
	 * Handles the Tilt
	 *
	 * @Param Pitch - The current pitch on the device
	 * @Param Yaw - The current Yaw on the device
	 */
	virtual void InputTilt(FLOAT NewPitch, FLOAT NewYaw);

	/**
	 * ProcessTouches is called every frame.  It's here where the magic occurs.
	 *
	 * @param DeltaTime		Much time has elapsed since the last processing
	 */
	virtual void ProcessTouches(FLOAT DeltaTime);

	/**
	 * When input comes in to the player input, the first thing we need to do is process it for
	 * the menus.
	 *
	 * @param TouchHandle       A unique id for the touch
	 * @param EventType         What type of event is this
	 * @param TouchLocation     Where the touch occurred
	 *
	 * @returns true if the menu system swallowed the input
	 */
	UBOOL ProcessMenuInput(UINT TouchHandle, EZoneTouchEvent EventType, FVector2D TouchLocation);

};

/** 
 * If set, this delegate will be called when the device is tilted. 
 *
 * @param PlayerInput	Reference ot the player input that sent along the delegate call
 * @param DeltaPitch	The change in pitch from the last call
 * @param DeltaYaw		The change in yaw from the last call.
 * 
 */
delegate OnMobileTilt(PlayerInput PlayerInput, float DeltaPitch, float DeltaYaw);

/**
 * Invoked when the mobile menus did not process an ZoneEvent_Touch.
 */
delegate OnTouchNotHandledInMenu();

/**
 * Perform any native initialization of the subsystem
 */
native function NativeInitializeInputSystem();

/**
 * Iterates over the zones and pre-calculates the actual bounds based on the current device resolution
 */
native function NativeInitializeInputZones();

/**
 * Allows the game to send a InputKey event though the viewport.
 *
 * @param Key				the new of the key we are sending
 * @param Event				the Type of event
 * @param AmountDepressed	the strength of the event
 */
native function SendInputKey(name Key, EInputEvent Event, float AmountDepressed);

/**
 * Allows the game to send an InputAxis event through the viewport                                                                     
 *
 * @param Key				the key we are sending
 * @param	Delta			the movement delta for the axis
 * @param	DeltaTime		the time (in seconds) since the last axis update.
 */
native function SendInputAxis(name Key, FLOAT Delta, FLOAT DeltaTime);

/**
 * Handle touch events in the 3D world. To use this assign the OnTapDelegate in a MobileInputZone to this function.
 *
 * @param Zone		        The mobile Input zone that triggered the delegate
 * @param EventType	        The type of input event that occurred
 * @param TouchLocation	    The screen location of the touch event
 * 
 * @return true if the world actor swallows the input
 */
native function bool ProcessWorldTouch(MobileInputZone Zone, EZoneTouchEvent EventType, Vector2D TouchLocation);

/**
 * The player controller will call this function directly after creating the input system
 */
function InitInputSystem()
{
	NativeInitializeInputSystem();	

	// We only want to initialize the 
	if (bFakeMobileTouches || WorldInfo.IsConsoleBuild(CONSOLE_Mobile))
	{
		InitializeInputZones();
	}
}

/**
 * Initializes the input zones
 */
function InitializeInputZones()
{
	local FrameworkGame Game;
	local int i,j;
	local MobileInputZone Zone;

	`log("Initializing Input zones");

	// Create all of the zones required by the game
	Game = FrameworkGame(WorldInfo.Game);
	if (Game != none)
	{
		`log("No of Config Groups:"@Game.RequiredMobileInputConfigs.Length);

		// Allocate Space
		MobileInputGroups.Length = Game.RequiredMobileInputConfigs.Length;

		for(i=0;i<Game.RequiredMobileInputConfigs.Length;i++)
		{
			// Add a Group for this config.

			`log("Building Group"@Game.RequiredMobileInputConfigs[i].GroupName);

			// Attempt to add a game-defined, optional "DebugZone" if not final release script
			`if(`notdefined(FINAL_RELEASE))
				Zone = FindOrAddZone("DebugZone");
				if (Zone != none)
				{
					`log("    Adding special DebugZone");
					MobileInputGroups[i].AssociatedZones.AddItem(Zone);
				}
			`endif
				
			MobileInputGroups[i].GroupName = Game.RequiredMobileInputConfigs[i].GroupName;
			for (j=0;j < Game.RequiredMobileInputConfigs[i].RequireZoneNames.Length;j++)
			{
				Zone = FindOrAddZone(Game.RequiredMobileInputConfigs[i].RequireZoneNames[j]);
				`log("    Adding zone"@Zone.Name);
				MobileInputGroups[i].AssociatedZones.AddItem(Zone);
			}
		}

		// Perform the native initialization for them
		NativeInitializeInputZones();
	}

}

/**
 * Search for zone in the list and return it if found                                                                     
 *
 * @param ZoneName	- The name of the Mobile Input Zone we are looking for
 * @returns a zone.
 */
function MobileInputzone FindZone(string ZoneName)
{
	local int i;
	for (i=0;i<MobileInputZones.Length;i++)
	{
		if (MobileInputZones[i].Name == Name(ZoneName))
		{
			return MobileInputZones[i];
		}
	}

	return none;
}

/**
 * Searchings the zone array for a zone and returns it if found.  Otherwise add it and return the new zone
 *
 * @param ZoneName	- The name of the Mobile Input Zone we are looking for
 * @returns a zone.
 */
function MobileInputZone FindorAddZone(string ZoneName)
{
	local MobileInputZone Zone;
	local class<MobileInputZone> ClassType;
	local int ClassIndex;

	Zone = FindZone(ZoneName);
	if (Zone == None)
	{
		ClassType = class'MobileInputZone';

		// Search for the class type that is associated with ZoneName in the ini file.
		for (ClassIndex = 0; ClassIndex < MobileInputZoneClasses.length; ClassIndex++)
		{
			if (ZoneName == MobileInputZoneClasses[ClassIndex].Name)
			{
				ClassType = MobileInputZoneClasses[ClassIndex].ClassType;
				break;
			}
		}
		Zone = new(none,ZoneName) ClassType;
		Zone.InputOwner = self;

		MobileInputZones.AddItem(Zone);
	}
	return Zone;
}

function bool HasZones()
{
	return (MobileInputGroups.Length>0 && CurrentMobileGroup < MobileInputGroups.Length);
}

function array<MobileInputZone> GetCurrentZones()
{
	return MobileInputGroups[CurrentMobileGroup].AssociatedZones;
}

exec function ActivateInputGroup(string GroupName)
{
	local int i;
	for (i=0;i<MobileInputGroups.Length;i++)
	{
		if (MobileInputGroups[i].GroupName == GroupName)
		{
			CurrentMobileGroup = i;
			return;
		}
	}

	`log("Attempted to activate a mobile input group" @ GroupName @ "that did not exist.");
}

/**
 * Switch to the input config with the specified group name
 */
exec function SetMobileInputConfig(string GroupName)
{
	local int NewConfig;
	for( NewConfig=0; NewConfig<MobileInputGroups.Length; NewConfig++ )
	{
		if( MobileInputGroups[NewConfig].GroupName ~= GroupName )
			break;
	}
	if( NewConfig < MobileInputGroups.Length )
	{
		CurrentMobileGroup = NewConfig;
		`Log("MobileInputConfig="$CurrentMobileGroup);
	}
	else
	{
		`Warn("Could not find a MobileInputGroup called" @ GroupName);
	}
}

// **********************************************************************************
// Menu System
// **********************************************************************************

/**
 *  Call this function to open a menu scene.
 *
 * @param SceneClass - The class of the menu scene to open.
 * @param Mode - Optional string that lets the opener pass extra information to the scene
 */
event MobileMenuScene OpenMenuScene(class<MobileMenuScene> SceneClass, optional string Mode)
{

	local MobileMenuScene Scene;
	local Vector2D ViewportSize;

	if (SceneClass != none)
	{
		// We have the menu scene, create it.

		Scene = new(outer) SceneClass;
		if (Scene != none)
		{
			`log("### OpenMenuScene "@SceneClass);
			LocalPlayer(Outer.Player).ViewportClient.GetViewportSize(ViewportSize);
			Scene.InitMenuScene(self, ViewportSize.X, ViewportSize.Y);
			MobileMenuStack.InsertItem(0,Scene);
			Scene.Opened(Mode);
			return Scene;
		}
		else
		{
			`log("Could not create menu scene " $ SceneClass);
		}
	}

	return none;

}

/**
 * Call this function to close a menu scene.  Remove it from the stack and notify the scene/etc.
 *
 * @param SceneToClose - The actual scene to close.
 */
event CloseMenuScene(MobileMenuScene SceneToClose)
{
	local int i,idx;

	// Check to make sure the Scene wants to let itself close
	if (SceneToClose.Closing())
	{
		idx = -1;
		// Find the scene in the stack
		for (i=0;i<MobileMenuStack.Length;i++)
		{
			if (MobileMenuStack[i] == SceneToClose)
			{
				idx = i;
				break;
			}
		}

		if (idx>=0)
		{

			MobileMenuStack.Remove(idx,1);
			SceneToClose.Closed();
		}
	}
}

/**
 * Start the rendering chain for the UI Scenes
 *
 * @param Canvas - The canvas for drawing
 */
event RenderMenus(Canvas Canvas,float RenderDelta)
{
	local int i;
	Canvas.Reset();
	for (i = MobileMenuStack.Length-1; i >= 0; i--)
	{
		MobileMenuStack[i].RenderScene(Canvas,RenderDelta);
	}
}

/**
 * We need a PreClientTravel to clean up the menu system.
 */
function PreClientTravel( string PendingURL, ETravelType TravelType, bool bIsSeamlessTravel)
{
	local int i;
	Super.PreClientTravel(PendingURL, TravelType, bIsSeamlessTravel);
	for (i = MobileMenuStack.Length-1; i >= 0; i--)
	{
		MobileMenuStack[i].Closed();
	}
}


exec function MobileMenuCommand(string MenuCommand)
{
	local int i;
	for (i = 0; i < MobileMenuStack.Length; i++)
	{
		if (MobileMenuStack[i].MobileMenuCommand(MenuCommand))
		{
			return;
		}
	}
}

/**
 * Opens a menu by class
 *
 * @Param MenuClassName - the name of the class to open
 */
exec function OpenMobileMenu(string MenuClassName)
{
	local class<MobileMenuScene> MenuClass;

	MenuClass = class<MobileMenuScene>(DynamicLoadObject(MenuClassName,class'class'));
	if (MenuClass != none)
	{
		OpenMenuScene(MenuClass);
	}
}

/**
 * Opens a menu by class and passes extra info to the scene
 *
 * @Param MenuClassName - the name of the class to open - REQUIRES QUOTES!
 * @Param Mode - the extra mode information to pass to the scene (two strings in OpenMobileMenu above breaks a.b for class names!)
 */
exec function OpenMobileMenuMode(string MenuClassName, string Mode)
{
	local class<MobileMenuScene> MenuClass;

	MenuClass = class<MobileMenuScene>(DynamicLoadObject(MenuClassName,class'class'));
	if (MenuClass != none)
	{
		OpenMenuScene(MenuClass, Mode);
	}
}

