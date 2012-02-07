/**
 * GameTypes
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class GameTypes extends Object
	native;

/** the name of the movie to show while loading */
const	LOADING_MOVIE	= "LoadingMovie";

/** DEPRECATED.  Defines a camera-animation-driven screenshake. */
struct native ScreenShakeAnimStruct
{
	var CameraAnim	Anim;

	/** If TRUE, code will choose which anim to play based on relative location to the player.  Anim is treated as "front" in this case. */
	var bool			bUseDirectionalAnimVariants;
	var CameraAnim	Anim_Left;
	var CameraAnim	Anim_Right;
	var CameraAnim	Anim_Rear;

	var float			AnimPlayRate;
	var float			AnimScale;
	var float			AnimBlendInTime;
	var float			AnimBlendOutTime;

	/**
	* If TRUE, play a random snippet of the animation of length RandomSegmentDuration.  Implies bLoop and bRandomStartTime = TRUE.
	* If FALSE, play the full anim once, non-looped.
	*/
	var bool			bRandomSegment;
	var float			RandomSegmentDuration;

	/** TRUE to only allow a single instance of the specified anim to play at any given time. */
	var bool			bSingleInstance;

	structdefaultproperties
	{
		AnimPlayRate=1.f
		AnimScale=1.f
		AnimBlendInTime=0.2f
		AnimBlendOutTime=0.2f
	}
};

 /** DEPRECATED. Shake start offset parameter */
 enum EShakeParam
 {
 	ESP_OffsetRandom,	// Start with random offset (default)
 	ESP_OffsetZero,		// Start with zero offset
 };
 
 /** DEPRECATED.  Shake vector params */
 struct native ShakeParams
 {
 	var EShakeParam	X, Y, Z;
 
 	var transient const byte Padding;
 };
 
 /** DEPRECATED.  Defines a code-driven (sinusoidal) screenshake */
 struct native ScreenShakeStruct
 {
 	/** Time in seconds to go until current screen shake is finished */
 	var	float	TimeToGo;
 	/** Duration in seconds of current screen shake */
 	var	float	TimeDuration;
 
 	/** view rotation amplitude */
 	var	vector	RotAmplitude;
 	/** view rotation frequency */
 	var vector	RotFrequency;
 	/** view rotation Sine offset */
 	var		vector	RotSinOffset;
 	/** rotation parameters */
 	var	ShakeParams	RotParam;
 
 	/** view offset amplitude */
 	var	vector	LocAmplitude;
 	/** view offset frequency */
 	var	vector	LocFrequency;
 	/** view offset Sine offset */
 	var		vector	LocSinOffset;
 	/** location parameters */
 	var	ShakeParams	LocParam;
 
 	/** FOV amplitude */
 	var	float	FOVAmplitude;
 	/** FOV frequency */
 	var	float	FOVFrequency;
 	/** FOV Sine offset */
 	var		float	FOVSinOffset;
 	/** FOV parameters */
 	var	EShakeParam	FOVParam;
 
 	/**
 	 * Unique name for this shake.  Only 1 instance of a shake with a particular
 	 * name can be playing at once.  Subsequent calls to add the shake will simply
 	 * restart the existing shake with new parameters.  This is useful for animating
 	 * shake parameters.
 	 */
 	var	Name		ShakeName;
 
	// @FIXME JF, remove these from GameFramework
  	/** True to use TargetingDampening multiplier while player is targeted, False to use global defaults (see TargetingAlpha). */
  	var	bool		bOverrideTargetingDampening;
   	/** Amplitude multiplier to apply while player is targeting.  Ignored if bOverrideTargetingDampening == FALSE */
  	var	float		TargetingDampening;
 
 	structdefaultproperties
 	{
 		TimeDuration=1.f
 		RotAmplitude=(X=100,Y=100,Z=200)
 		RotFrequency=(X=10,Y=10,Z=25)
 		LocAmplitude=(X=0,Y=3,Z=5)
 		LocFrequency=(X=1,Y=10,Z=20)
 		FOVAmplitude=2
 		FOVFrequency=5
 		ShakeName=""
 	}
 };


/** replicated information on a hit we've taken */
struct native TakeHitInfo
{
	/** the location of the hit */
	var vector				HitLocation;
	/** how much momentum was imparted */
	var vector				Momentum;
	/** the damage type we were hit with */
	var class<DamageType>	DamageType;
	/** the weapon that shot us */
	var Pawn				InstigatedBy;
	/** the bone that was hit on our Mesh (if any) */
	var byte				HitBoneIndex;
	/** the physical material that was hit on our Mesh (if any) */
	var PhysicalMaterial	PhysicalMaterial;
	/** how much damage was delivered */
	var float				Damage;
	/** For radial damage, this is the point of origin. If damage was not radial, will be the same as HitLocation. */
	var vector              RadialDamageOrigin;
};

/** Struct to map specialmove label/class and allow overrides via the same label key */
struct native GameSpecialMoveInfo
{
	var() Name						SpecialMoveName;
	var() class<GameSpecialMove>	SpecialMoveClass;

	/** Instance of the special move class */
	var() GameSpecialMove			SpecialMoveInstance;
};

/** Container for all special move properties */
struct native SpecialMoveStruct
{
	/** Special Move being performed. */
	var Name		SpecialMoveName;
	/** Interaction Pawn */
	var GamePawn	InteractionPawn;
	/** Optional Interaction Actor */
	var Actor       InteractionActor;
	/** Additional Replicated Flags */
	var INT			Flags;
};

struct native AICmdHistoryItem
{
	var class<GameAICommand> CmdClass;
	var float                TimeStamp;
	var String               VerboseString;
};


defaultproperties
{

}
