/**
* MobileInputZone
* Controls how mobile input is handled
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*/

class MobileInputZone extends object
	PerObjectConfig
	Config(Game)
	native;

/** Describes the type of zone */
enum EZoneType
{
	ZoneType_Button,
	ZoneType_Joystick,
	ZoneType_Trackball,
	ZoneType_Slider,
	ZoneType_SubClassed,
};

/**
 * Describes the state of the zone.                                                                     
 */
enum EZoneState
{
	ZoneState_Inactive,
	ZoneState_Activating,
	ZoneState_Active,
	ZoneState_Deactivating,
};

/** 
 * Describes the type of event that has occurred 
 */
enum EZoneTouchEvent
{
	ZoneEvent_Touch,
	ZoneEvent_Update,
	ZoneEvent_Stationary,
	ZoneEvent_UnTouch,
	ZoneEvent_Cancelled,
};

/**
 * Defines which way the zone slides                                                                     
 */
enum EZoneSlideType
{
	ZoneSlide_UpDown,
	ZoneSlide_DownUp,
	ZoneSlide_LeftRight,
	ZoneSlide_RightLeft,
};

/** What type of zone is this. */
var (Zone) config EZoneType Type;

/** State of the zone */
var (Zone) EZoneState State;

/** For button zones, the Caption property will be displayed in the center of the button */
var (Zone) config string Caption;

/** Input to send to input subsystem on event (vertical input for analog, can be NAME_None) */
var (Input) config name InputKey;

/** Input to send for horizontal analog input (can be NAME_None) */
var (Input) config name HorizontalInputKey;

/** Input to send for tap input (e.g. for tap-to-fire) */
var (Input) config name TapInputKey;

/** Input to send from a double tap */
var (Input) config name DoubleTapInputKey;

/** Multiplier to scale the analog vertical input by */
var (Input) config float VertMultiplier;

/** Multiplier to scale the analog horizontal input by */
var (Input) config float HorizMultiplier;

/** How much acceleration to apply to Trackball or Joystick movement (0.0 for none, no upper bounds) */
var (Input) config float Acceleration;

/** How much input smoothing to apply to Trackball or Joystick movement (0.0 for none, 1.0 for max) */
var (Input) config float Smoothing;

/** How much escape velocity to use for Trackball movement (0.0 for none, 1.0 for max) */
var (Input) config float EscapeVelocityStrength;

/** If true, this control will use it's "strength" to scale the movement of the pawn */
var (Input) config bool bScalePawnMovement;

/** Top left corner */
var (Bounds) config float X, Y;

/** Size of the zone */
var (Bounds) config float SizeX, SizeY;

/** Size of active Zone.  Note if it's set to 0, then SizeX/SizeY will be copied here.  
    This setting is used when you have a zone that has bCenterOnEvent set and defines the size of 
	zone when it's active  */
var (Bounds) config float ActiveSizeX, ActiveSizeY;

/** If any of the bReleative vars are true, then the corresponding X/Y/SizeX/SizeY will be consider a percentage of the viewport */
var (Bounds) config bool bRelativeX;
var (Bounds) config bool bRelativeY;
var (Bounds) config bool bRelativeSizeX;
var (Bounds) config bool bRelativeSizeY;

/** if true, then this zone will be centered around the original X value.  NOTE: X will be updated to reflect it's actual position */
var (bounds) config bool bCenterX;

/** if true, then this zone will be centered around the original Y value.  NOTE: Y will be updated to reflect it's actual position */
var (bounds) config bool bCenterY;

/** Border is an invisible region around the zone.  The border is included in hit determination. */
var (Bounds) config float Border;	


/** Do we draw anything on screen for this zone? */
var (Options) config bool bIsInvisible;

/** If true, then this double tap will be considered a quick press/release, other wise it's tap and hold */
var (Options) config bool bQuickDoubleTap;

/** If true, this zone will have it's "center" set when you touch it, otherwise the center will be set to the center of the zone */
var (Options) config bool bCenterOnEvent;

/** If true, the tilt zone will float within the SizeX/SizeY */
var (Options) config bool bFloatingTiltZone;

/** Determines what type of slide it is */
var (Options) config EZoneSlideType SlideType;

var (Options) config float TapDistanceConstraint;

/** If true, the zone will gracefully transition from Inactive to Active and vice-versus.  NOTE: transitions are strickly visual.  A
    zone becomes active or inactive the moment a touch is applied or removed */
var (Transitions) config bool bUseGentleTransitions;

/** How fast should a zone for from active to inactive */
var (Tansitions) config float ActivateTime;

/** How fast a zone should go from inactive to active */
var (Tansitions) config float DeactivateTime;


/** Zone Rendering Parameters */

/** If true, the zone will render little guide lines for debugging */
var (Rendering) config bool bRenderGuides;

/** Holds the color to use when drawing images */
var (Rendering) config color RenderColor;

/** Holds the alpha value to use if the zone is inactive */
var (Rendering) config float InactiveAlpha;

/** This is a fixed adjustment that will be added to the zone's caption's X.  It's used to align fonts correctly */
var (Rendering) config float CaptionXAdjustment;

/** This is a fixed adjustment that will be added to the zone's caption's Y.  It's used to align fonts correctly */
var (Rendering) config float CaptionYAdjustment;

/** Holds the Initialize location where the zone was touched */
var (Current) Vector2D InitialLocation;

/** For Joystick and Trackball, this is where in the zone the user is currently holding down */
var (Current) Vector2D CurrentLocation;

/** For Joystick, this is the center of the analog zone to calculate the analog values from */
var (Current) Vector2D CurrentCenter;

/** For Joystick and Trackball, array of previous locations so that we can smooth input over frames */
var (Current) Vector2D PreviousLocations[6];

/** For Joystick and Trackball, array of previous movement time deltas so that we can smooth input over frames */
var (Current) float PreviousMoveDeltaTimes[6];

/** For Joystick and Trackball, how many previous locations we're currently storing */
var (Current) int PreviousLocationCount;

/** Used to calculate a double tap on this zone */
var (Current) float LastTouchTime;

/** How long since we last repeated a tap */
var (Current) float TimeSinceLastTapRepeat;

/** A Reference back to the Player Input that controls this array Input zone */
var (Current) MobilePlayerInput InputOwner;

/** Holds the current transition time */
var (Current) float TransitionTime;

/** This will be true if this tap was a double tap.  It's required in order to make sure we release the DoubleTapInputKey if it was a tap and hold */
var (Current) bool bIsDoubleTapAndHold;

/** For Trackball, how much escape velocity is left to apply */
var (Current) Vector2D EscapeVelocity;


cpptext
{
	/**
	 * Processes a touch event
	 *
	 * @param DeltaTime		Much time has elapsed since the last processing
	 * @param Handle		The unique ID of this touch
	 * @param EventType		The type of event that occurred
	 * @param TouchLocation	Where on the device has the touch occurred.
	 * @param TouchDuration	How long since the touch started
	 * @param MoveDeltaTime	Time delta between the movement events the last time this touch moved
 	 */
	void virtual ProcessTouch(FLOAT DeltaTime, UINT Handle, EZoneTouchEvent EventType, FVector2D TouchLocation, FLOAT TouchTotalMoveDistance, FLOAT TouchDuration, FLOAT MoveDeltaTime);

	/**
	 * All zones that are in the active group get 'Ticked' at the end of the ProcessTouches event                                                                
	 *
	 * @param DeltaTime		Much time has elapsed since the last processing
	 */
	void virtual TickZone(FLOAT DeltaTime);

 	/**
	 * Applies any remaining escape velocity for this zone
	 *
	 * @param DeltaTime		Much time has elapsed since the last processing
	 */
	void ApplyEscapeVelocity( FLOAT DeltaTime );


protected:
	/**
	 * Computes average location and movement time for the zone's active touch 
	 *
	 * @param	InTimeToAverageOver			How long a duration to average over (max)
	 * @param	OutSmoothedLocation			(Out) Average location
	 * @param	OutSmoothedMoveDeltaTime	(Out) Average movement delta time
	 */
	void ComputeSmoothedMovement( const FLOAT InTimeToAverageOver, FVector2D& OutSmoothedLocation, FLOAT& OutSmoothedMoveDeltaTime ) const;
}


/**
 * Called to activate a zone.
 */
native function ActivateZone();

/**
 * Called to deactivate a zone                                                                     
 */
native function DeactivateZone();

/**
 * A delegate that allows script to override the process.  We use delegates here
 *
 * @param Zone		The Mobile Input zone that triggered the delegate
 * @param Handle	The unique ID of this touch
 * @param EventType The type of event that occurred
 * @param Location	Where on the device has the touch occurred.
 * @returns true if we need to swallow the touch
*/

delegate bool OnProcessInputDelegate(MobileInputZone Zone, float DeltaTime, int Handle, EZoneTouchEvent EventType, Vector2D TouchLocation);


/**
 * A delegate that allows script to manage Tap events.
 *
 * @param Zone		The mobile Input zone that triggered the delegate
 * @param Location	Where on the device has the touch occurred.
 * @param EventType The type of event that occurred
 * @returns true if we need to swallow the tap
 */
delegate bool OnTapDelegate(MobileInputZone Zone, EZoneTouchEvent EventType, Vector2D TouchLocation);

/**
 * A delegate that allows script to manage Double Tap events.
 *
 * @param Zone		The mobile Input zone that triggered the delegate
 * @param Location	Where on the device has the touch occurred.
 * @param EventType The type of event that occurred
 * @returns true if we need to swallow the double tap
 */
delegate bool OnDoubleTapDelegate(MobileInputZone Zone, EZoneTouchEvent EventType, Vector2D TouchLocation);


/**
 * This is a delegate that allows script to get values of a slide zone. 
 *
 * @param Zone			The mobile Input zone that triggered the delegate
 * @param EventType		The type of event that occurred
 * @param SlideVlaue	Holds the offset value of the slides in a +/- range in pixels.  So 0 = Resting at normal.  
 * @param ViewportSize	Holds the size of the current viewport.
 */
delegate bool OnProcessSlide(MobileInputZone Zone, EZoneTouchEvent EventType, int SlideValue, Vector2D ViewportSize);

/**
 * Allows other actors to override the drawing of this zone.  Note this is called before the default drawing code 
 * and if it returns true, will abort the drawing sequence
 * 
 * @param Zone		 The mobile Input zone that triggered the delegate
 * @param Canvas	 The canvas to draw on
 * @returns true to stop the rendering
 */
delegate bool OnPreDrawZone(MobileInputZone Zone, Canvas Canvas);

/**
 * Allows other actors to supplement the drawing of this zone.  Note this is called after the default drawing code 
 * 
 * @param Zone		 The mobile Input zone that triggered the delegate
 * @param Canvas	 The canvas to draw on
 */
delegate OnPostDrawZone(MobileInputZone Zone, Canvas Canvas);


defaultproperties
{
}
