/**
 * Abstract base class for all classes related to UI animation.  This class simply defines the data structures used the UI animation system.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIAnimation extends UIRoot
	native(UIPrivate)
	HideCategories(Object)
	abstract;


// Describes what value is animated on a given Opperation
enum EUIAnimType
{
	/** no animation */
	EAT_None,
	/** position animation */

	EAT_Position,

	/**
	 * Position animation; not implemented by all widget types.
	 * Values for this animation type are treated as a percentage of the current left or top position.  The widget's position is never
	 * actually changed - rendering simply applies a tranform to render the widget at a different location.
	 */
	EAT_PositionOffset,

	/**
	 * relative position animation; values are specified as a percentage of the widget's size.  i.e. 1.0 for the X component means
	 * move the widget such that it's left face is moved to the current location of its right face, while maintaining the same width.
	 * @todo - not yet implemented
	 */
	EAT_RelPosition,

	/** rotation */
	EAT_Rotation,

	/**
	 * animation of rotation, relative to original rotation
	 * @todo - not yet implemented
	 */
	EAT_RelRotation,

	/** widget color animation */
	EAT_Color,

	/** widget opacity animation */
	EAT_Opacity,

	/** widget visibility animation */
	EAT_Visibility,

	/**
	 * widget scale animation
	 */
	EAT_Scale,

	/** left face animation */
	EAT_Left,

	/** top face animation */
	EAT_Top,

	/** right face animation */
	EAT_Right,

	/** bottom face animation */
	EAT_Bottom,

	/** post-process bloom amount */
	EAT_PPBloom,

	/** post-process blur sample size (kernel) */
	EAT_PPBlurSampleSize,

	/** post-process blur amount (0 - 1) */
	EAT_PPBlurAmount,
};

/**
 * Defines the types of interpolation that can be used for animation.  (based on EViewTargetBlendFunction)
 *
 * @todo - hook up...
 */
enum EUIAnimationInterpMode
{
	/** simple linear interpolation */
	UIANIMMODE_Linear,

	/** small ease in, small ease out, static values */
//	UIANIMMODE_Cubic,

	/** start of animation takes longer */
	UIANIMMODE_EaseIn,

	/** end of animation takes longer */
	UIANIMMODE_EaseOut,

	/** beginning and end of animation take longer */
	UIANIMMODE_EaseInOut,
};

/**
 * Different types of looping behaviors for UI animations.
 */
enum EUIAnimationLoopMode
{
	/** no looping */
	UIANIMLOOP_None,

	/**
	 * loops sequentially through keyframes, then starts over at beginning
	 * i.e. 0, 1, 2, 3, 0, 1, 2, 3
	 */
	UIANIMLOOP_Continuous,

	/**
	 * when the final keyframe is reached, reverses the order of the frames
	 * i.e. 0, 1, 2, 3, 2, 1, 0, 1, 2, 3....
	 */
	UIANIMLOOP_Bounce,
};

/** The different type of notification events */
//@fixme - not yet implemented
enum EUIAnimNotifyType
{
	EANT_WidgetFunction,
	EANT_SceneFunction,
	EANT_KismetEvent,
	EANT_Sound,
};

/**
 * Holds information about a given notify
 * @fixme - not yet implemented
 */
struct native UIAnimationNotify
{
	// What type of notication is this
	var	EUIAnimNotifyType	NotifyType;

	/** Holds the name of the function to call or UI sound to play */
	var name				NotifyName;
};


/**
 * We don't have unions in script so we burn a little more space
 * than I would like.  Which value will be used depends on the OpType.
 */
struct native UIAnimationRawData
{
	//@fixme - refactor into objects, similar to sequence objects or animnodes
	var float				DestAsFloat;
	var LinearColor 		DestAsColor;
	var Rotator				DestAsRotator;
	var Vector				DestAsVector;
	var UIAnimationNotify   DestAsNotify;
};

/**
 * Contains information about a single frame or destination in an animation sequence.
 */
struct native UIAnimationKeyFrame
{
	/**
	 * The amount of time (in seconds) that it should take for the data in this keyframe
	 */
	var		float					RemainingTime;

	/**
	 * Specifies which interpolation algorithm should be used for this keyframe.
	 */
	var		EUIAnimationInterpMode	InterpMode;

	/**
	 * For interpolation modes which require it (ease-in, ease-out), affects the degree of the curve.
	 */
	var		float					InterpExponent;

	/** This holds the array of AnimationOps that will be applied to this Widget */
	var		UIAnimationRawData		Data;

	structdefaultproperties
	{
		InterpMode=UIANIMMODE_Linear
		InterpExponent=1.5f
	}

	structcpptext
	{
		/** Constructors */
		FUIAnimationKeyFrame() {}
		FUIAnimationKeyFrame(EEventParm)
		{
			appMemzero(this, sizeof(FUIAnimationKeyFrame));
		}
		FUIAnimationKeyFrame(ENativeConstructor)
		: RemainingTime(0.f), InterpMode(UIANIMMODE_Linear)
		, InterpExponent(1.5f), Data(EC_EventParm)
		{
		}
	}
};


/**
 * This defines a single animation track.  Each track will animation only a single type of data.
 */
struct native UIAnimTrack
{
	/** The type of animation date contained in this track */
	var	EUIAnimType									TrackType;

	/** Holds the actual key frame data */
	var	array<UIAnimationKeyFrame>					KeyFrames;

	/**
	 * Stores a copy of the KeyFrames array for the purposes of looping.
	 */
	var	transient	array<UIAnimationKeyFrame>		LoopFrames;
};


/**
 * This structure holds information about a single animation sequence.  Each animation sequence contains a single "track", which holds the
 * individual keyframe data for each data-type supported by UI animation.  When all keyframes for a single track have completed executing,
 * the track is removed from the widget's copy of the UIAnimSequence.
 *
 * All members of this struct are initialized at runtime based on a UIAnimationSeq subobject template defined in the game's subclass of
 * Engine.GameUISceneClient.
 */

struct native transient UIAnimSequence
{
	/** The Template to use */
	var		UIAnimationSeq			SequenceRef;

	/** Array of animation tracks which are currently active */
	var		array<UIAnimTrack>		AnimationTracks;

	/** controls how this animation sequence loops */
	var		EUIAnimationLoopMode	LoopMode;

	/** How fast are we playing this back */
	var		float					PlaybackRate;

	structcpptext
	{
		/** Constructors */
		FUIAnimSequence() {}
		FUIAnimSequence(EEventParm)
		{
			appMemzero(this, sizeof(FUIAnimSequence));
		}


		/**
		 * Applies the specified track's current keyframe data to the widget.
		 *
		 * @param	Target		the widget to apply the update to.
		 * @param	TrackIndex	the index of the track to apply data from
		 * @param	DeltaTime	the time (in seconds) since the beginning of the last frame; used to determine how much to interpolate
		 *						the current keyframe's value.
		 *
		 * @return	TRUE if the widget's state was updated with the current keyframe's data.
		 */
		UBOOL ApplyUIAnimation( UUIScreenObject* Target, INT TrackIndex, FLOAT DeltaTime );

		/**
		 * Wrapper for verifying whether the index is a valid index for the track's keyframes array.
		 *
		 * @param	TrackIndex	the index [into the Tracks array] for the track to check
		 * @param	FrameIndex	the index [into the KeyFrames array of the track] for the keyframe to check
		 *
		 * @return	TRUE if the specified track contains a keyframe at the specified index.
		 */
		UBOOL IsValidFrameIndex( INT TrackIndex, INT FrameIndex ) const;

		/**
		 * Wrapper for getting the length of a specific frame in one of this animation sequence's tracks.
		 *
		 * @param	TrackIndex			the index [into the Tracks array] for the track to check
		 * @param	FrameIndex			the index [into the KeyFrames array of the track] for the keyframe to check
		 * @param	out_FrameLength		receives the remaining seconds for the frame specified
		 *
		 * @return	TRUE if the call succeeded; FALSE if an invalid track or frame index was specified.
		 */
		UBOOL GetFrameLength( INT TrackIndex, INT FrameIndex, FLOAT& out_FrameLength ) const;

		/**
		 * Wrapper for getting the length of a specific track in this animation sequence.
		 *
		 * @param	TrackIndex	the index [into the Tracks array] for the track to check
		 * @param	out_TrackLength		receives the remaining number of seconds for the track specified.
		 *
		 * @return	TRUE if the call succeeded; FALSE if an invalid track index was specified.
		 */
		UBOOL GetTrackLength( INT TrackIndex, FLOAT& out_TrackLength ) const;

		/**
		 * Wrapper for getting the length of this animation sequence.
		 *
		 * @return	the total number of seconds in this animation sequence.
		 */
		FLOAT GetSequenceLength() const;
	}
};

defaultproperties
{
}
