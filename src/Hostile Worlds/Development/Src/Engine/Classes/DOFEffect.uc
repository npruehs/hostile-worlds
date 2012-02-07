/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Depth of Field post process effect
 *
 */
class DOFEffect extends PostProcessEffect
	native
	abstract;

/** exponent to apply to blur amount after it has been normalized to [0,1] */
var() float FalloffExponent;
/** affects the size of the Poisson disc kernel, can affect bloom as well */
var() float BlurKernelSize;
/** [0,1] value for clamping how much blur to apply to items in front of the focus plane */
var() float MaxNearBlurAmount;
/** [0,1] value for clamping how much blur to apply to items behind the focus plane */
var() float MaxFarBlurAmount;
/** blur color for debugging etc */
var() color ModulateBlurColor;

/** control how the focus point is determined */
var() enum EFocusType
{
	// use distance from the view
	FOCUS_Distance,
	// use a world space point
	FOCUS_Position	
} FocusType;
/** inner focus radius */
var() float FocusInnerRadius;
/** used when FOCUS_Distance is enabled */
var() float FocusDistance;
/** used when FOCUS_Position is enabled */
var() vector FocusPosition;

cpptext
{
	// UPostProcessEffect interface

	/**
	 * Creates a proxy to represent the render info for a post process effect
	 * @param WorldSettings - The world's post process settings for the view.
	 * @return The proxy object.
	 */
	virtual class FPostProcessSceneProxy* CreateSceneProxy(const FPostProcessSettings* WorldSettings);

	/**
	 * @param View - current view
	 * @return TRUE if the effect should be rendered
	 */
	virtual UBOOL IsShown(const FSceneView* View) const;

	// UObject inteface

	/** callback for changed property */
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
}

defaultproperties
{
	// typical settings
	FocusType=FOCUS_Distance
	FocusDistance=800
	FocusInnerRadius=400
	FalloffExponent=2
	BlurKernelSize=2
	MaxNearBlurAmount=1
	MaxFarBlurAmount=1
	ModulateBlurColor=(R=255,G=255,B=255,A=255);
}