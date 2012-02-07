/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Online toast message scene.
 */
class UTUIScene_OnlineToast extends UTUIScene;

/** Reference to the message label for the toast. */
var transient UILabel MessageLabel;

/** The time the toast message was displayed at. */
var transient float	ShowStartTime;

/** Whether or not this toast is in the showing or hiding state. */
var transient bool bFullyVisible;

/** Amount of time to display the toast for. */
var() float ToastDuration;

event PostInitialize()
{
	Super.PostInitialize();

	// Store widget references
	MessageLabel = UILabel(FindChild('lblMessage',true));
}

event TickScene(FLOAT DeltaTime)
{
	local WorldInfo WI;

	if( bFullyVisible )
	{	
		WI = GetWorldInfo();

		if( (WI != None) && (WI.RealTimeSeconds-ShowStartTime > ToastDuration) )
		{
			FinishToast();
			bFullyVisible = false;
		}
	}
}

/** Sets the current message for this scene. */
function SetMessage(string Message)
{
	MessageLabel.SetDataStoreBinding(Message);
	ShowStartTime = GetWorldInfo().RealTimeSeconds;
	bFullyVisible = true;
}

/** Called when the toast is complete and ready to be hidden. */
function FinishToast()
{
	bFullyVisible = false;
	CloseScene(self);
}

/**
 * Starts the show animation for the scene.
 *
 * @param	bInitialActivation	TRUE if the scene is being opened; FALSE if the another scene was closed causing this one to become the
 *								topmost scene.
 * @param	bBypassAnimation	TRUE to force all animations to their last frame, effectively bypassing animations.  This can
 *								be necessary for e.g. scenes which start out off-screen or something.
 *
 *
 * @return TRUE if there's animation for this scene, FALSE otherwise.
 */
function bool BeginShowAnimation(bool bInitialActivation=true, bool bBypassAnimation=false)
{
	local UIObject MainRegion;

	MainRegion = FindChild('imgBG', true);
	MainRegion.StopUIAnimation('OnlineToastHide');
	MainRegion.PlayUIAnimation('OnlineToastShow',,,,bBypassAnimation ? 1.0 : 0.0);

	return true;
}

/**
 * Starts the exit animation for the scene.
 *
 * @return TRUE if there's animation for this scene, FALSE otherwise.
 */
function bool BeginHideAnimation(bool bClosingScene=false)
{
	local UIObject MainRegion;

	MainRegion = FindChild('imgBG', true);
	MainRegion.Add_UIAnimTrackCompletedHandler(OnAnimToastHideEnded);
	MainRegion.PlayUIAnimation('OnlineToastHide');

	return true;
}

/** Callback for when the hide animation has ended. */
function OnAnimToastHideEnded( UIScreenObject AnimTarget, name AnimName, int TrackTypeMask )
{
	if ( TrackTypeMask == 0 )
	{
		AnimTarget.Remove_UIAnimTrackCompletedHandler(OnAnimToastHideEnded);
		OnHideAnimationEnded();
	}
}


defaultproperties
{
	bRenderParentScenes=true
	bPauseGameWhileActive=false
	bIgnoreAxisInput=true
	bFlushPlayerInput=false
	bAlwaysRenderScene=true
	SceneInputMode=INPUTMODE_None
	ToastDuration=5.0f
	bShouldPerformScriptTick=true
}
