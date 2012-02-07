/**
 * +Added support for pulsing and fading the drawing components.  It adds an UpdateFade() function that
 * will return the current fade value giving the deltatime.  The child is responsible for called SetOpacity()
 * passing in whatever value is included.  This is possibly a temporary solution
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UIComp_DrawComponents extends UIComponent
	within UIObject
	native(UIPrivate);

// FADING

enum EFadeType
{
	EFT_None,			// No fading, Opacity will
	EFT_Fading,			// Fading to a specific Alpha
	EFT_Pulsing			// Pulsing between Alpha 0.0 and FadeTarget
};

/** Where the fade is going */

var(Rendering) transient EFadeType FadeType;

var(Rendering) transient float FadeAlpha;
var(Rendering) transient float FadeTarget;
var(Rendering) transient float FadeTime;

/** Used to create a delta for fading */
var transient float LastRenderTime;

/** Used for pulsing.  This is the rate at which it will occur */
var transient float FadeRate;

/** How Much Longer until we reach the target Alpha */

cpptext
{
	/**
	 * @Returns true if an update is needed
	 * @Param	FadeValue - In: The current Alpha, Out: The New Alpha
	 */
	UBOOL UpdateFade(FLOAT& FadeAlpha);
}

function final native Fade(float FromAlpha, float ToAlpha, float TargetFadeTime);
function final native Pulse(optional float MaxAlpha=1.0, optional float MinAlpha=0.0, optional float PulseRate=1.0);
function final native ResetFade();

/** OnFadeComplete will be called as soon as the fade has been completed */
delegate OnFadeComplete(UIComp_DrawComponents Sender);

defaultproperties
{
	FadeType = EFT_None
}
