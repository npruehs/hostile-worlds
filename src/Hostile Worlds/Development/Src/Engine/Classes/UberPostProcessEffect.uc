/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Uber post process effect
 *
 */
class UberPostProcessEffect extends DOFBloomMotionBlurEffect
	native;

/** */
var() vector SceneShadows;
/** */
var() vector SceneHighLights;
/** */
var() vector SceneMidTones;
/** */
var() float  SceneDesaturation;
/** 
 * Enables the tone mapper (maps HDR colors into LDR range) which allows more film like images. Also allows to used color grading 
 * When using:
 *   Lights just have to be brighter overall, something that looked good in
 *   a light of 1-2 looks correct in a light of 3 or 4, but there also needs
 *   to be some ambient light, if it's pure black it'll look really bad but
 *   with some bounce lighting or environment light it'll look nice.
 *
 */
var() bool bEnableHDRTonemapper;

cpptext
{
	// UPostProcessEffect interface

	/**
	 * Creates a proxy to represent the render info for a post process effect
	 * @param WorldSettings - The world's post process settings for the view.
	 * @return The proxy object.
	 */
	virtual class FPostProcessSceneProxy* CreateSceneProxy(const FPostProcessSettings* WorldSettings);

	// UObject interface

	/**
	* Called after this instance has been serialized.  UberPostProcessEffect should only
	* ever exists in the SDPG_PostProcess scene
	*/
	virtual void PostLoad();
	
	/**
	 * Called when properties change.  UberPostProcessEffect should only
	 * ever exists in the SDPG_PostProcess scene
	 */
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/**
	* Tells the SceneRenderer is this effect includes the uber post process.
	*/
	virtual UBOOL IncludesUberpostprocess() const
	{
		return TRUE;
	}
}

//
// The UberPostProcessingEffect performs DOF, Bloom, Material (Sharpen/Desaturate) and Tone Mapping
//
// For the DOF and Bloom parameters see DOFAndBloomEffect.uc.  The Material parameters are used as
// follows:
//
// Color0 = ((InputColor - SceneShadows) / SceneHighLights) ^ SceneMidTones
// Color1 = Luminance(Color0)
//
// OutputColor = Color0 * (1 - SceneDesaturation) + Color1 * SceneDesaturation
//

defaultproperties
{
    SceneShadows=(X=0.0,Y=0.0,Z=-0.003);
    SceneHighLights=(X=0.8,Y=0.8,Z=0.8);
    SceneMidTones=(X=1.3,Y=1.3,Z=1.3);
    SceneDesaturation=0.4; 
	bEnableHDRTonemapper=FALSE;
}
