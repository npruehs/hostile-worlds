/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Depth of Field post process effect
 *
 */
class DOFAndBloomEffect extends DOFEffect
	native;

/** A scale applied to blooming colors. */
var() float BloomScale;

/** Any component of a pixel's color must be larger than this to contribute bloom. */
var() float BloomThreshold;

/** Multiplies against the bloom color. */
var() color BloomTint;

/** 
 * Scene color luminance must be less than this to receive bloom. 
 * This behaves like Photoshop's screen blend mode and prevents over-saturation from adding bloom to already bright areas.
 * The default value of 1 means that a pixel with a luminance of 1 won't receive any bloom, but a pixel with a luminance of .5 will receive half bloom.
 */
var() float BloomScreenBlendThreshold;

/** A multiplier applied to all reads of scene color. */
var() float SceneMultiplier;

/** the radius of the bloom effect */
var() float BlurBloomKernelSize;

/** Whether Bloom and DOF should be processed independently pass (slower, more memory, does not work with ShaderModel2.0)          */
var deprecated bool bEnableSeparateBloom;

/** Whether the reference Depth of Field effect is enabled, requires BlurKernelSize to be 0 (very slow, might not be maintained, not for production) */
var() bool bEnableReferenceDOF;

/** Whether the reference Depth of Field high quality mode is enabled */
var() bool bEnableDepthOfFieldHQ;

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
}

defaultproperties
{
	BloomScale=1.0
	BloomThreshold=1.0
	BloomTint=(R=255,G=255,B=255)
	BloomScreenBlendThreshold=10
	SceneMultiplier=1.0
	BlurKernelSize=16.0
	BlurBloomKernelSize=16.0
	bEnableReferenceDOF=false
	bEnableDepthOfFieldHQ=false
}