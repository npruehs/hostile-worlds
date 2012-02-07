/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKGameUISceneClient extends GameUISceneClient
	native;

var transient Font		ToastFont;

/** Debug values */
var(Debug)  bool bShowRenderTimes;
var float PreRenderTime;
var float RenderTime;
var float TickTime;
var float AnimTime;
var float AvgTime;
var float AvgRenderTime;
var float FrameCount;
var float StringRenderTime;

/** Screen warning message text.  Will be implicitly visible when string isn't empty. */
var transient string ScreenWarningMessage;

/** Whether or not to dim the entire screen, used for the network dialog on ps3. */
var transient bool bDimScreen;

cpptext
{
	/**
	 * Render all the active scenes
	 */
	virtual void RenderScenes( FCanvas* Canvas );

	virtual void Render_Scene( FCanvas* Canvas, UUIScene* Scene, EUIPostProcessGroup UIPostProcessGroup );
	virtual void Tick(FLOAT DeltaTime);

	/**
	 * We are going to override this and give UDKUIScenes a chance at the input first
	 */
	virtual UBOOL InputKey(INT ControllerId,FName Key,EInputEvent Event,FLOAT AmountDepressed=1.f,UBOOL bGamepad=FALSE);

protected:

	/**
	 * Determines whether the any active scenes process axis input.
	 *
	 * @param	bProcessAxisInput	receives the flags for whether axis input is needed for each player.
	 */
	virtual void CheckAxisInputSupport( UBOOL* bProcessAxisInput[UCONST_MAX_SUPPORTED_GAMEPADS] ) const;
}

/**
 * Returns the WorldInfo
 */
native static  function WorldInfo GetWorldInfo();

native function bool IsInSeamlessTravel();

/** @return TRUE if there are any scenes currently accepting input, FALSE otherwise. */
native function bool IsUIAcceptingInput();

/**
 * Displays a screen warning message.  This message will be displayed prominently centered in the viewport and
 * will persist until you call ClearScreenWarningMessage().  It's useful for important modal warnings, such
 * as when the controller is disconnected on a console platform.
 *
 * @param Message Message to display
 */
function ShowScreenWarningMessage( string Message )
{
	ScreenWarningMessage = Message;
}

/**
 * Clears the screen warning message if one was set.  It will no longer be rendered.
 */
function ClearScreenWarningMessage()
{
	ScreenWarningMessage = "";
}

defaultproperties
{
	Begin Object Class=UIAnimationSeq Name=seqRotPitchNeg90
		SeqName=RotPitchNeg90
//		SeqDuration=0.6
		Tracks(0)=(TrackType=EAT_Rotation,KeyFrames=((RemainingTime=0.0,Data=(DestAsRotator=(Pitch=16384))),(RemainingTime=0.6,Data=(DestAsRotator=(Pitch=0)))))
	End Object
	AnimSequencePool.Add(seqRotPitchNeg90)

	Begin Object Class=UIAnimationSeq Name=seqRotPitch90
		SeqName=RotPitch90
//		SeqDuration=0.6
		Tracks(0)=(TrackType=EAT_Rotation,KeyFrames=((RemainingTime=0.0,Data=(DestAsRotator=(Pitch=0))),(RemainingTime=0.6,Data=(DestAsRotator=(Pitch=16384)))))
	End Object
	AnimSequencePool.Add(seqRotPitch90)

	Begin Object Class=UIAnimationSeq Name=seqFadeIn
		SeqName=FadeIn
//		SeqDuration=1.0
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.0)),(RemainingTime=1.0,Data=(DestAsFloat=1.0))))
	End Object
	AnimSequencePool.Add(seqFadeIn)

	Begin Object Class=UIAnimationSeq Name=seqFadeOut
		SeqName=FadeOut
//		SeqDuration=1.0
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=1.0)),(RemainingTime=1.0,Data=(DestAsFloat=0.0))))
	End Object
	AnimSequencePool.Add(seqFadeOut)


	/** For the first time the scene is open. */
	Begin Object Class=UIAnimationSeq Name=seqSceneShowInitial
		SeqName=SceneShowInitial
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.0)),(RemainingTime=0.125,Data=(DestAsFloat=1.0))))
		Tracks(1)=( TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=1.0,Y=0.0,Z=0.0))), (RemainingTime=0.125,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqSceneShowInitial)

	/** For non-initial showings of the scene. */
	Begin Object Class=UIAnimationSeq Name=seqSceneShowRepeat
		SeqName=SceneShowRepeat
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.0)),(RemainingTime=0.125,Data=(DestAsFloat=1.0))))
		Tracks(1)=( TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=-1.0,Y=0.0,Z=0.0))), (RemainingTime=0.125,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqSceneShowRepeat)

	/** For when we are hiding a scene without closing it. */
	Begin Object Class=UIAnimationSeq Name=seqSceneHide
		SeqName=SceneHide
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=1.0)),(RemainingTime=0.125,Data=(DestAsFloat=0.0))))
		Tracks(1)=( TrackType=EAT_RelPosition,KeyFrames=((RemainingTime=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))),(RemainingTime=0.124,Data=(DestAsVector=(X=-1.0,Y=0.0,Z=0.0))), (RemainingTime=0.001,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqSceneHide)

	/** For when we are hiding a scene by closing it. */
	Begin Object Class=UIAnimationSeq Name=seqSceneHideClosing
		SeqName=SceneHideClosing
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=1.0)),(RemainingTime=0.125,Data=(DestAsFloat=0.0))))
		Tracks(1)=( TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (RemainingTime=0.125,Data=(DestAsVector=(X=1.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqSceneHideClosing)

	// Button Bar
	Begin Object Class=UIAnimationSeq Name=seqButtonBarShow
		SeqName=ButtonBarShow
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.0)),(RemainingTime=0.125,Data=(DestAsFloat=1.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=0.0,Y=1.0,Z=0.0))), (RemainingTime=0.125,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqButtonBarShow)

	Begin Object Class=UIAnimationSeq Name=seqButtonBarHide
		SeqName=ButtonBarHide
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=1.0)),(RemainingTime=0.125,Data=(DestAsFloat=0.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (RemainingTime=0.125,Data=(DestAsVector=(X=0.0,Y=1.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqButtonBarHide)

	// Title Label
	Begin Object Class=UIAnimationSeq Name=seqTitleLabelShow
		SeqName=TitleLabelShow
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.0)),(RemainingTime=0.125,Data=(DestAsFloat=1.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=0.0,Y=-1.0,Z=0.0))), (RemainingTime=0.125,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqTitleLabelShow)

	Begin Object Class=UIAnimationSeq Name=seqTitleLabelHide
		SeqName=TitleLabelHide
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=1.0)),(RemainingTime=0.125,Data=(DestAsFloat=0.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (RemainingTime=0.125,Data=(DestAsVector=(X=0.0,Y=-1.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqTitleLabelHide)

	// Tab Pages
	Begin Object Class=UIAnimationSeq Name=seqTabPageEnterRight
		SeqName=TabPageEnterRight
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.0)),(RemainingTime=0.0625,Data=(DestAsFloat=0.0)),(RemainingTime=0.0625,Data=(DestAsFloat=1.0))))
		//Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=1.0,Y=0.0,Z=0.0))), (RemainingTime=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
		Tracks(1)=(TrackType=EAT_RelRotation,KeyFrames=((RemainingTime=0.0625,Data=(DestAsRotator=(Pitch=16834))),(RemainingTime=0.0625,Data=(DestAsRotator=(Pitch=0)))))
	End Object
	AnimSequencePool.Add(seqTabPageEnterRight)

	Begin Object Class=UIAnimationSeq Name=seqTabPageEnterLeft
		SeqName=TabPageEnterLeft
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.0)),(RemainingTime=0.125,Data=(DestAsFloat=1.0))))
		//Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=-1.0,Y=0.0,Z=0.0))), (RemainingTime=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
		Tracks(1)=(TrackType=EAT_RelRotation,KeyFrames=((RemainingTime=0.0,Data=(DestAsRotator=(Pitch=-16834))),(RemainingTime=0.125,Data=(DestAsRotator=(Pitch=0)))))
	End Object
	AnimSequencePool.Add(seqTabPageEnterLeft)

	Begin Object Class=UIAnimationSeq Name=seqTabPageExitRight
		SeqName=TabPageExitRight
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=1.0)),(RemainingTime=0.124,Data=(DestAsFloat=0.0)),(RemainingTime=0.001,Data=(DestAsFloat=0.0))))
		//Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (RemainingTime=0.99,Data=(DestAsVector=(X=1.0,Y=0.0,Z=0.0))), (RemainingTime=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
		Tracks(1)=(TrackType=EAT_RelRotation,KeyFrames=((RemainingTime=0.0,Data=(DestAsRotator=(Pitch=0))),(RemainingTime=0.124,Data=(DestAsRotator=(Pitch=16834))),(RemainingTime=0.001,Data=(DestAsRotator=(Pitch=0)))))
	End Object
	AnimSequencePool.Add(seqTabPageExitRight)

	Begin Object Class=UIAnimationSeq Name=seqTabPageExitLeft
		SeqName=TabPageExitLeft
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=1.0)),(RemainingTime=0.124,Data=(DestAsFloat=0.0)),(RemainingTime=0.001,Data=(DestAsFloat=0.0))))
		//Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (RemainingTime=0.99,Data=(DestAsVector=(X=-1.0,Y=0.0,Z=0.0))), (RemainingTime=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
		Tracks(1)=(TrackType=EAT_RelRotation,KeyFrames=((RemainingTime=0.0,Data=(DestAsRotator=(Pitch=0))),(RemainingTime=0.124,Data=(DestAsRotator=(Pitch=-16834))),(RemainingTime=0.001,Data=(DestAsRotator=(Pitch=0)))))
	End Object
	AnimSequencePool.Add(seqTabPageExitLeft)

	// Online Toast
	Begin Object Class=UIAnimationSeq Name=seqOnlineToastShow
		SeqName=OnlineToastShow
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.0)),(RemainingTime=0.125,Data=(DestAsFloat=1.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=0.0,Y=1.0,Z=0.0))), (RemainingTime=0.124,Data=(DestAsVector=(X=0.0,Y=-0.1,Z=0.0))), (RemainingTime=0.001,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqOnlineToastShow)

	Begin Object Class=UIAnimationSeq Name=seqOnlineToastHide
		SeqName=OnlineToastHide
//		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=1.0)),(RemainingTime=0.125,Data=(DestAsFloat=0.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (RemainingTime=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (RemainingTime=0.0125,Data=(DestAsVector=(X=0.0,Y=-0.1,Z=0.0))),(RemainingTime=0.1125,Data=(DestAsVector=(X=0.0,Y=1.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqOnlineToastHide)

	Begin Object Class=UIAnimationSeq Name=seqBriefingSlide
		SeqName=BriefingSlide
//		SeqDuration=0.3
		Tracks(0)=(TrackType=EAT_Position,KeyFrames=((RemainingTime=0.0,Data=(DestAsVector=(X=0.587586,Y=0.131716,Z=0.0))), (RemainingTime=0.3,Data=(DestAsVector=(X=0.046690,Y=0.131716,Z=0.0)))))
		Tracks(1)=(TrackType=EAT_Rotation,KeyFrames=((RemainingTime=0.0,Data=(DestAsRotator=(Pitch=-910))),(RemainingTime=0.3,Data=(DestAsRotator=(Pitch=910))) ))
	End Object
	AnimSequencePool.Add(seqBriefingSlide)

	Begin Object Class=UIAnimationSeq Name=seqExpandDetails
		SeqName=ExpandDetails
//		SeqDuration=0.5
		Tracks(0)=(TrackType=EAT_Bottom,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.080291)),(RemainingTime=0.25,Data=(DestAsFloat=0.520268)),(RemainingTime=0.125,Data=(DestAsFloat=0.537188)),(RemainingTime=0.075,Data=(DestAsFloat=0.623491)),(RemainingTime=0.05,Data=(DestAsFloat=0.659028))))
		Tracks(1)=(TrackType=EAT_Right,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.344721)),(RemainingTime=0.25,Data=(DestAsFloat=0.454769)),(RemainingTime=0.125,Data=(DestAsFloat=0.524769)),(RemainingTime=0.075,Data=(DestAsFloat=0.544769)),(RemainingTime=0.05,Data=(DestAsFloat=0.554769))))
	End Object
	AnimSequencePool.Add(seqExpandDetails);

	Begin Object Class=UIAnimationSeq Name=seqContractDetails
		SeqName=ContractDetails
//		SeqDuration=0.5
		Tracks(0)=(TrackType=EAT_Bottom,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.659028)),(RemainingTime=0.1,Data=(DestAsFloat=0.456527)),(RemainingTime=0.275,Data=(DestAsFloat=0.182490)),(RemainingTime=0.05,Data=(DestAsFloat=0.1086578)),(RemainingTime=0.075,Data=(DestAsFloat=0.080291))))
		Tracks(1)=(TrackType=EAT_Right,KeyFrames=((RemainingTime=0.0,Data=(DestAsFloat=0.554769)),(RemainingTime=0.25,Data=(DestAsFloat=0.374721)),(RemainingTime=0.125,Data=(DestAsFloat=0.3684065)),(RemainingTime=0.05,Data=(DestAsFloat=0.353256)),(RemainingTime=0.075,Data=(DestAsFloat=0.344721))))
	End Object
	AnimSequencePool.Add(seqContractDetails);
}
