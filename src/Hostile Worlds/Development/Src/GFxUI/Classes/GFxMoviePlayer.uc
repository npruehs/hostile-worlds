/**********************************************************************

Filename    :   GFxMoviePlayer.uc
Content     :   Unreal Scaleform GFx integration

Copyright   :   (c) 2006-2007 Scaleform Corp. All Rights Reserved.

Portions of the integration code is from Epic Games as identified by Perforce annotations.
Copyright (c) 2010 Epic Games, Inc. All rights reserved.

Notes       :   Since 'ucc' will prefix all class names with 'U'
                there is not conflict with GFx file / class naming.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/


class GFxMoviePlayer extends Object
    native
	config(UI);

/** GFx Internals */
var const native transient pointer pMovie{class FGFxMovie};
var const native transient pointer pCaptureKeys{class TSet<NAME_INDEX>};
var const native transient pointer pFocusIgnoreKeys{class TSet<NAME_INDEX>};
var private const native transient Map{UClass*,void*} ASUClasses;
var private const native transient Map{int,UObject*} ASUObjects;
var private const transient int NextASUObject;

/** Reference to the movie currently being played */
var SwfMovie MovieInfo;

/** TRUE after Start() is called, FALSE after Close() is called. */
var const bool bMovieIsOpen;

/** Texture that the movie should be rendered to.  If NULL, the movie will be rendered to the frame buffer. */
var() TextureRenderTarget2D RenderTexture;

/** Index into the GamePlayers array for the LocalPlayer who owns this movie */
var public transient int LocalPlayerOwnerIndex;

/** Object that should receive ExternalInterface calls from ActionScript.  If unspecified, all ExternalInterface calls will be routed through the movie player itself */
var public Object ExternalInterface;
/** List of keys that this movie player is listening for, and will capture (i.e. not send on to the game) */
var array<name> CaptureKeys;
/** If this is a focus movie, all input will be sent to the movie EXCEPT these keys */
var array<name> FocusIgnoreKeys;

/** If TRUE, this movie player will render even if bShowHud is FALSE.  Usually set to TRUE for menus, and FALSE for HUDs */
var bool bDisplayWithHudOff;

/**
 *  Stores a mapping between a movie's image resource ("Linkage" identifier on an image resource in the movie) and an Unreal texture resource.  This allows
 *  runtime remapping of the images used by the movie.  Any texture with a linkage identifier can be replaced at runtime using SetExternalTexture()
 */
struct native ExternalTexture
{
  var() string  Resource;
  var() Texture Texture;
};
/** Array of ExternalTexture bindings that will automatically replaced when the movie player loads a new movie */
var array<ExternalTexture> ExternalTextures;

/** 
 *  Structure that binds a sound theme name to an actual UISoundTheme to handle sound events from objects in this movie.  Sound events can be fired by
 *  CLIK widgets or manually by the artist.  Each event contains a theme name, and an event to play.  This mapping binds the theme names specified
 *  by the artist to a UISoundTheme asset, which then binds event names to various sound cues or actions.
 */
struct native SoundThemeBinding
{
	/** Name of the sound theme, specified by the artist in the movie */
	var() Name          ThemeName;
	/** Corresponding sound theme to handle sound events for this ThemeName */
	var() UISoundTheme  Theme;
};
/** Stores an array of bindings between sound theme names and actual UISoundThemes */
var() array<SoundThemeBinding> SoundThemes;

/** 
 *  Timing modes for playback of the movie
 *      - TM_Game:  Movie will be advanced using the game's delta time (i.e. pausing the game pauses the movie)
 *      - TM_Real:  Movie will proceed at normal playback speed, disregarding slomo and pause
 */
enum GFxTimingMode
{
  TM_Game,
  TM_Real
};
var private GFxTimingMode TimingMode;

/**
 *  Rendering modes for the player
 *      - RTM_Opaque:           No blending, opaque overlay
 *      - RTM_Alpha:            Use with BLEND_Translucent, doesn't support add
 *      - RTM_AlphaComposite:   Use with BLEND_AlphaComposite
 */
enum GFxRenderTextureMode
{
  RTM_Opaque,
  RTM_Alpha,
  RTM_AlphaComposite
};
var public GFxRenderTextureMode RenderTextureMode;

/** Whether to gamma correct this movie before writing to the destination surface. */
var public bool bEnableGammaCorrection;

struct native GFxDataStoreBinding
{
    var() UIDataStoreBinding					    DataSource;
    var() string							        VarPath;
    var() string									ModelId;
    var() string									ControlId;
    var() bool										bEditable;
    var() array<name>								CellTags;
    
    var   const transient array<byte>				ModelIdUtf8;
    var   const transient array<byte>				ControlIdUtf8;
    var	  const	transient UIListElementProvider		ListDataProvider;
    var   const transient array<name>				FullCellTags;
    var	  const transient native pointer            ModelRef {class GFxValue};
    var	  const transient native pointer            ControlRef {class GFxValue};
    
    structdefaultproperties
    {
        bEditable=True
    }
};
var array<GFxDataStoreBinding> DataStoreBindings;
var private transient GFxDataStoreSubscriber DataStoreSubscriber;

/** 
 *  Widget class binding:  To associate a CLIK widget instance in a movie with a particular UnrealScript subclass of GFxObject, add the widget's Flash name here, and specify the class.
 *  This will cause the GFxObject parameter of WidgetInitialized() to be created as the appropriate subclass.
 */
struct native GFxWidgetBinding
{
	var() name                  WidgetName;
	var() class<GFxObject>      WidgetClass;
};
var array<GFxWidgetBinding> WidgetBindings;

/** 
 *  Stores bindings for forwarding WidgetInitialized() calls on to a specific GFxObject instance for widgets within a certain movie object path.  Entries can be added / removed from
 *  the widget binding mapping using SetWidgetPathBinding() 
 */
var const native map{FName,UGFxObject*}   WidgetPathBindings;

/** If TRUE, a widget within this movie player was initialized this frame.  This will cause the PostWidgetInit event to be fired after the Advance() of the movie is complete  */
var const transient bool    bWidgetsInitializedThisFrame;

/** If TRUE, widgets that have an initialization callback that are NOT handled by WidgetInitialized() will log out a notification for debugging */
var bool bLogUnhandedWidgetInitializations;

/** If TRUE, this movie player will be allowed to accept input events.  Defaults to TRUE */
var bool bAllowInput;

/** If TRUE, this movie player will be allowed to accept focus events.  Defaults to TRUE */
var bool bAllowFocus;

/** The priority of this movie player. Used to determine render and focus order when multiple movie players are open simultaneously */
var private byte Priority;

/** If TRUE, MovieToLoad will be played immediately after loading */
var bool        bAutoPlay;

/** If TRUE, the game will pause while this scene is up */
var bool        bPauseGameWhileActive;

/** If TRUE, the movie will be closed on a level change 
 *  NOTE: ONLY TIMINGMODE TM_REAL movies can stay open during level change
 */
var bool        bCloseOnLevelChange;

/** If TRUE, only the LocalPlayerOwner's input can be directed here */
var bool        bOnlyOwnerFocusable;

/** If TRUE, any input received from a LocalPlayer that is not the owner of this movieplayer will be discarded and not acted upon 
 *  This should be used in conjunction with bOnlyOwnerFocusable to make movieplayers that only respond to one player, but consume all input from the other players  
 */
var bool        bDiscardNonOwnerInput;

/** If TRUE, this movie player will capture input */
var bool        bCaptureInput;

/** IF TRUE, this movie player will ignore mouse input */
var bool        bIgnoreMouseInput;

cpptext
{
    UGFxMoviePlayer();

	virtual void Cleanup();
	virtual void FinishDestroy();
	virtual void Serialize(FArchive& Ar);
    UBOOL Load(const FString& Filename, UBOOL InitFirstFrame = TRUE);
	void ProcessDataStoreCall(const char* methodName, const GFxValue* args, int argCount);
	
	class UGFxObject* CreateValue(const void* GFxObject, UClass* Type);
	class UGFxObject* CreateValueAddRef(const void* GFxObject, UClass* Type);
	UBOOL GetPrototype(UClass *Class, void* Proto);
}

/**
 *  ActionScript type specifiers, for use with ASValue.  Note that AS_Number corresponds to a float in UnrealScript.
 */
enum ASType
{
  AS_Undefined,
  AS_Null,
  AS_Number,
  AS_String,
  AS_Boolean
};

/** 
 *  Generic struct used for passing generic data to and from ActionScript.  Should be used as little as possible because of overhead, except in cases where it is unavoidable
 */
struct native ASValue
{
  var() ASType      Type;
  var() bool        b;
  var() float       n;
  var() init string s;
  
  structdefaultproperties
  {
    Type=AS_Undefined
  }
};

enum GFxScaleMode
{
    SM_NoScale,
    SM_ShowAll,
    SM_ExactFit,
    SM_NoBorder
};

enum GFxAlign
{
    Align_Center,
    Align_TopCenter,
    Align_BottomCenter,
    Align_CenterLeft,
    Align_CenterRight,
    Align_TopLeft,
    Align_TopRight,
    Align_BottomLeft,
    Align_BottomRight
};

//=========================================================================
//  General MoviePlayer Functions
//

/** Start playing the movie. Returns false if there were load errors.  Can be overridden to perform other setup, but be sure to call Super.Start() first. */
virtual native event bool Start(optional bool StartPaused = false);

/** Advances the movie by the specified time.  After the movie is started via Start(), Advance(0.f) can be called to initialize all the objects on the first frame without actually advancing the movie **/
native final function Advance(float time);

/**
 * Delegate that if set, will be fired whenever the movie gets an Advance() call.
 * 
 * @param   DeltaTime   Amount of time the movie has advanced
 */
delegate OnPostAdvance(float DeltaTime);

/** Pauses / unpauses the movie playback */
native function SetPause(optional bool bPausePlayback = TRUE);

/** Close the movie */
native final function Close(optional bool Unload = TRUE);

/** Called when a movie is closed to allow cleanup and handling */
event OnClose();

/** See whether we need to attempt to unpause the game when the scene closes */
final event ConditionalClearPause()
{
	local LocalPlayer LP;

	// Only try to unpause if this movie tried to pause the game when it opened
	if( bPauseGameWhileActive )
	{
		LP = GetLP();
		if( (LP != None) && (LP.Actor != None) )
		{
			LP.Actor.SetPause(FALSE);
		}
	}
}

/** Set movie to play (for script-created objects) */
function SetMovieInfo(SwfMovie data)
{
	MovieInfo = data;
}

/** Sets the timing mode of the movie to either advance with game time (respecting game pause and time dilation), or real time (disregards game pause and time dilation) */
native function SetTimingMode(GFxTimingMode mode);

/** Set a handler for ActionScript ExternalInterface calls for the movie being played.  If no handler is specified, calls will be processed by this GFxMoviePlayer */
function SetExternalInterface(Object h)
{
    ExternalInterface = h;
}

/** Specifies a resource (linkage identifier in the movie) to be replaced by the specified texture */
native function bool SetExternalTexture(string resource, Texture texture);

native function RefreshDataStoreBindings();
native function PublishDataStoreValues();

native function SetPriority(byte NewPriority);


//=========================================================================
//  MoviePlayer Viewport Functions
//

native final function GameViewportClient GetGameViewportClient();

/** Sets the viewport location and size for the movie being played */
native final function SetViewport(int x, int y, int width, int height);

native final function SetViewScaleMode(GFxScaleMode SM);
native final function SetAlignment(GFxAlign a);
native final function GetVisibleFrameRect(out float x0, out float y0, out float x1, out float y1);

/** 3D View functions */
native final function SetView3D(const out matrix matView);			// const out - force pass by reference
native final function SetPerspective3D(const out matrix matPersp);


//=========================================================================
//  MoviePlayer Input Functions
//

/**Sets whether or not a movie is allowed to receive focus.  Defaults to true*/
native final function SetMovieCanReceiveFocus(bool bCanReceiveFocus);

/**Sets whether or not a movie is allowed to receive input.  Defaults to true*/
native final function SetMovieCanReceiveInput(bool bCanReceiveInput);


/** Adds a key to the list of keys that get eaten by the movie being played, and not passed down to the game */
native final function AddCaptureKey(name key);
native final function ClearCaptureKeys();

/** Adds a key to the FocusIgnore list, which prevents key presses from being sent to the movie if this is the focus movie */
native final function AddFocusIgnoreKey(name key);
native final function ClearFocusIgnoreKeys();

/** Clears out all pressed keys from the player's input */
native final function FlushPlayerInput(bool capturekeysonly);

/** Can be overridden to filter input to this movie.  Return TRUE to trap the input, FALSE to let it pass through to Gfx */
event bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent);


//=========================================================================
//  ActionScript Accessor Functions
//

/**
 *  Accessors for ActionScript / GFx Objects
 *  
 *  If you know the type of the variable or object you're accessing, it is best to use one of the type specific accessor functions, as they are significantly faster.
 *  Avoid using the slower ASValue functions if possible.
 */
native function ASValue GetVariable(string path);
native function bool GetVariableBool(string path);
native function float GetVariableNumber(string path);
native function string GetVariableString(string path);
/** 
 *  Returns a GFxObject for the specified path.  If the type parameter is specified, the returned object will be of the specified class.  Note the return value is
 *  not coerced though, so if you specify a type, you must manually cast the result
 */
native function GFxObject GetVariableObject(string path, optional class<GFxObject> type);

native function SetVariable(string path, ASValue Arg);
native function SetVariableBool(string path, bool b);
native function SetVariableNumber(string path, float f);
native function SetVariableString(string path, string s);
native function SetVariableObject(string path, GFxObject Object);

/**
 *  Array accessor functions
 *  
 *  As with the normal member accessor functions, it is always best to use the accessor for the specific type, rather than the generic ASValue implementations
 */
native function bool GetVariableArray(string path, int index, out array<ASValue> arg);
native function bool GetVariableIntArray(string path, int index, out array<int> arg);
native function bool GetVariableFloatArray(string path, int index, out array<float> arg);
native function bool GetVariableStringArray(string path, int index, out array<string> arg);

native function bool SetVariableArray(string path, int index, array<ASValue> Arg);
native function bool SetVariableIntArray(string path, int index, array<int> Arg);
native function bool SetVariableFloatArray(string path, int index, array<float> Arg);
native function bool SetVariableStringArray(string path, int index, array<string> Arg);

/** Used to create a new object of a specific ActionScript class.  Note that the ASClass specified must be available in the movie you are trying to create it in! */
native function GFxObject CreateObject(string ASClass, optional class<GFxObject> type);
native function GFxObject CreateArray();

/**
 *  Function property setters
 *  
 *  Use this function to set function properties in ActionScript to UnrealScript delegates, using the delegate from the calling UnrealScript function.
 *  This is a useful method for getting callbacks from ActionScript into UnrealScript.
 *  
 *  Example:       
 *      // Sets OtherObject's "onClick" function object to the delegate specified in f
 *      function SetOnEvent(GFxObject OtherObject, delegate<OnEvent> f)
 *      {
 *          ActionScriptSetFunction(OtherObject, "onClick");
 *      }
 */
protected native noexport final function ActionScriptSetFunction(GFxObject Object, string Member);


//=========================================================================
//  ActionScript Function Interfaces
//

/** 
 *  Calls an ActionScript function on the movie, with the values from the args array as its parameters.  This is slower than creating a wrapper function to call the ActionScript method
 *  using one of the ActionScript*() methods below, but does not require a subclass to implement.  Use this for one-off functions, or functions with variable length arguments
 */
native function ASValue Invoke(string method, array<ASValue> args);

/**
 *  ActionScript function call wrappers
 *  
 *  These functions, when called from within a UnrealScript function, invoke an ActionScript function with the specified method name, with the parameters of the wrapping UnrealScript 
 *  function.  This is the preferred method for calling ActionScript functions from UnrealScript, as it is faster than Invoke, with less overhead.
 *  
 *  Example:    To call the following ActionScript function from UnrealScript -
 *  
 *                  function MyActionScriptFunction(Param1:String, Param2:Number, Param3:Object):Void;
 *                  
 *              Use the following UnrealScript code -
 *              
 *                  function CallMyActionScriptFunction(string Param1, float Param2, GFxObject Param3)
 *                  {
 *                      ActionScriptVoid("_root.MyActionScriptFunction");
 *                  }
 */
protected native noexport final function ActionScriptVoid(string path);
protected native noexport final function int ActionScriptInt(string path);
protected native noexport final function float ActionScriptFloat(string path);
protected native noexport final function string ActionScriptString(string path);
protected native noexport final function GFxObject ActionScriptObject(string path);


//=========================================================================
//  Widget Initialization Functions
//

/** Callback when a CLIK widget with enableInitCallback set to TRUE is initialized.  Returns TRUE if the widget was handled, FALSE if not. */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget);

/** Callback when a CLIK widget with enableInitCallback set to TRUE is unloaded.  Returns TRUE if the widget was handled, FALSE if not. */
event bool WidgetUnloaded(name WidgetName, name WidgetPath, GFxObject Widget);

/** Callback when at least one CLIK widget with enableInitCallback set to TRUE has been initialized in a frame */
event PostWidgetInit();

/** 
 *  Sets a widget to handle WidgetInitialized() callbacks for a given widget path.  Used when you want a specific widget within the movie to handle WidgetInitialized() calls
 *  for its own children.  The most derived path handler will be called for any given widget 
 *  
 *  Example:  For WidgetInitialized() on the widget with the path _level0.a.b.c.d, if a path binding was set for _level0.a and _level0.a.b, the widget bound to path _level0.a.b
 *              would receive the call
 *  
 *  Passing in None for WidgetToBind will remove a Widget from being bound to that path
 */
final native function SetWidgetPathBinding(GFxObject WidgetToBind, name Path);

/** 
 *  This should be called when a new GFxMoviePlayer is initialized.  Handles the setting up of the LocalPlayerIndex, as well as automatically starting / advancing the movie if desired 
 *
 *  @param LocPlayerIdx - Index in the LocalPlayers array for the LocalPlayer that owns this movie
 */
function Init(optional LocalPlayer LocPlay)
{
	LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocPlay);
	if(LocalPlayerOwnerIndex == INDEX_NONE)
	{
		LocalPlayerOwnerIndex = 0;
	}

	if( MovieInfo != None )
	{
		if( bAutoPlay )
		{
			Start();
			Advance(0.f);
		}
	}
}

/**
 * Helper function to get the owning local player for this movie
 * 
 * @return The LocalPlayer corresponding to the LocalPlayerOwnerIndex that owns this movie
 */
event LocalPlayer GetLP()
{
	local Engine Eng;

	Eng = class'Engine'.static.GetEngine();

	//If it is an INDEX_NONE, try the default player
	if (LocalPlayerOwnerIndex < 0)
	{
		LocalPlayerOwnerIndex = 0;
	}
	//If it is completely invalid return none
	else if  (LocalPlayerOwnerIndex >= Eng.GamePlayers.Length)
	{
		return none;
	}
	return  Eng.GamePlayers[LocalPlayerOwnerIndex];
}

/**
 * Helper function to get the owning player controller for this movie
 * 
 * @return The PlayerController corresponding to the LocalPlayerOwnerIndex that owns this movie
 */
event PlayerController GetPC()
{
	local LocalPlayer LocalPlayerOwner;
	
	LocalPlayerOwner = GetLP();
	if (LocalPlayerOwner == none)
	{
		return none;
	}
	return LocalPlayerOwner.Actor;
}


/** 
 *  Routes a console command through the player's PlayerController
 *  
 *  @param Command - The console command to run
 */
function ConsoleCommand( string Command )
{
	local PlayerController PC;

	PC = GetPC();
	if( PC != None )
	{
		PC.ConsoleCommand(Command);
	}
}

defaultproperties
{
    bEnableGammaCorrection=FALSE
    bDisplayWithHudOff=TRUE
	bLogUnhandedWidgetInitializations=TRUE

	bAllowInput=TRUE
	bAllowFocus=TRUE

	bCloseOnLevelChange=TRUE

	Priority=1
}
