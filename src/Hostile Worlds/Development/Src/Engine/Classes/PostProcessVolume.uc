/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Used to affect post process settings in the game and editor.
 */
class PostProcessVolume extends Volume
	native
	placeable
	dependson(DOFEffect)
	hidecategories(Advanced,Collision,Volume);


/**  LUT Blender for efficient Color Grading (LUT: color look up table, RGB_new = LUT[RGB_old]) blender. */
struct native LUTBlender
{
	// is emptied at end of each frame, each value stored need to be unique, the value 0 is used for neutral
	var array<Texture> LUTTextures;
	// is emptied at end of each frame
	var array<float> LUTWeights;

	structcpptext
	{
		/** constructor, by default not even the Neutral element is defined */
		FLUTBlender();

		UBOOL IsLUTEmpty() const;

		/** new = lerp(old, Rhs, Weight) (main thread only)
		*
		* @param Texture 0 is a valid entry and is used for neutral
		* @param Weight 0..1
		*/
		void LerpTo(UTexture* Texture, float Weight);

		/** resolve to one LUT (render thread only)*/
		const FTextureRHIRef ResolveLUT(class FViewInfo& View, const struct ColorTransformMaterialProperties& ColorTransform);

		/** Is updated every frame if GColorGrading is set to debug mode, empty if not */
		static UBOOL GetDebugInfo(FString& Out);

		void CopyToRenderThread(FLUTBlender& Dest) const;

		/**
		* Clean the container and adds the neutral LUT. 
		* should be called after the render thread copied the data
		*/
		void Reset();

	private:

		/**
		*
		* @param Texture 0 is used for the neutral LUT
		*/
		void SetLUT(UTexture *Texture);


		/** 
		* add a LUT to the ones that are blended together 
		*
		* @param Texture can be 0 then the call is ignored
		* @param Weight 0..1
		*/
		void PushLUT(UTexture* Texture, float Weight);

		/** @return 0xffffffff if not found */
		UINT FindIndex(UTexture* Tex) const;

		/** @return count */
		UINT GenerateFinalTable(FTexture* OutTextures[], float OutWeights[], UINT MaxCount) const;
	}
};

struct native PostProcessSettings
{
	/** Determines if bEnableBloom variable will be overridden. */
	var	bool			bOverride_EnableBloom;
	
	/** Determines if bEnableDOF variable will be overridden. */
	var	bool			bOverride_EnableDOF;
	
	/** Determines if bEnableMotionBlur variable will be overridden. */
	var	bool			bOverride_EnableMotionBlur;
	
	/** Determines if bEnableSceneEffect variable will be overridden. */
	var	bool			bOverride_EnableSceneEffect;
	
	/** Determines if bAllowAmbientOcclusion variable will be overridden. */
	var	bool			bOverride_AllowAmbientOcclusion;
	
	/** Determines if bOverrideRimShaderColor variable will be overridden. */
	var	bool			bOverride_OverrideRimShaderColor;
	
	/** Determines if Bloom_Scale variable will be overridden. */
	var	bool			bOverride_Bloom_Scale;

	/** Determines if Bloom_Threshold variable will be overridden. */
	var	bool			bOverride_Bloom_Threshold;

	/** Determines if Bloom_Tint variable will be overridden. */
	var	bool			bOverride_Bloom_Tint;

	/** Determines if Bloom_ScreenBlendThreshold variable will be overridden. */
	var	bool			bOverride_Bloom_ScreenBlendThreshold;
	
	/** Determines if Bloom_InterpolationDuration variable will be overridden. */
	var	bool			bOverride_Bloom_InterpolationDuration;
	
	/** Determines if DOF_FalloffExponent variable will be overridden. */
	var	bool			bOverride_DOF_FalloffExponent;
	
	/** Determines if DOF_BlurKernelSize variable will be overridden. */
	var	bool			bOverride_DOF_BlurKernelSize;
	
	/** Determines if DOF_BlurBloomKernelSize variable will be overridden. */
	var	bool			bOverride_DOF_BlurBloomKernelSize;
	
	/** Determines if DOF_MaxNearBlurAmount variable will be overridden. */
	var	bool			bOverride_DOF_MaxNearBlurAmount;
	
	/** Determines if DOF_MaxFarBlurAmount variable will be overridden. */
	var	bool			bOverride_DOF_MaxFarBlurAmount;
	
	/** Determines if DOF_ModulateBlurColor variable will be overridden. */
	var	bool			bOverride_DOF_ModulateBlurColor;
	
	/** Determines if DOF_FocusType variable will be overridden. */
	var	bool			bOverride_DOF_FocusType;
	
	/** Determines if DOF_FocusInnerRadius variable will be overridden. */
	var	bool			bOverride_DOF_FocusInnerRadius;
	
	/** Determines if DOF_FocusDistance variable will be overridden. */
	var	bool			bOverride_DOF_FocusDistance;
	
	/** Determines if DOF_FocusPosition variable will be overridden. */
	var	bool			bOverride_DOF_FocusPosition;
	
	/** Determines if DOF_InterpolationDuration variable will be overridden. */
	var	bool			bOverride_DOF_InterpolationDuration;
	
	/** Determines if MotionBlur_MaxVelocity variable will be overridden. */
	var	bool			bOverride_MotionBlur_MaxVelocity;
	
	/** Determines if MotionBlur_Amount variable will be overridden. */
	var	bool			bOverride_MotionBlur_Amount;
	
	/** Determines if MotionBlur_FullMotionBlur variable will be overridden. */
	var	bool			bOverride_MotionBlur_FullMotionBlur;
	
	/** Determines if MotionBlur_CameraRotationThreshold variable will be overridden. */
	var	bool			bOverride_MotionBlur_CameraRotationThreshold;
	
	/** Determines if MotionBlur_CameraTranslationThreshold variable will be overridden. */
	var	bool			bOverride_MotionBlur_CameraTranslationThreshold;
	
	/** Determines if MotionBlur_InterpolationDuration variable will be overridden. */
	var	bool			bOverride_MotionBlur_InterpolationDuration;
	
	/** Determines if Scene_Desaturation variable will be overridden. */
	var	bool			bOverride_Scene_Desaturation;
	
	/** Determines if Scene_HighLights variable will be overridden. */
	var	bool			bOverride_Scene_HighLights;
	
	/** Determines if Scene_MidTones variable will be overridden. */
	var	bool			bOverride_Scene_MidTones;
	
	/** Determines if Scene_Shadows variable will be overridden. */
	var	bool			bOverride_Scene_Shadows;
	
	/** Determines if Scene_InterpolationDuration variable will be overridden. */
	var	bool			bOverride_Scene_InterpolationDuration;
	
	/** Determines if RimShader_Color variable will be overridden. */
	var	bool			bOverride_RimShader_Color;
	
	/** Determines if RimShader_InterpolationDuration variable will be overridden. */
	var	bool			bOverride_RimShader_InterpolationDuration;

	/** Whether to use bloom effect.																*/
	var()	bool			bEnableBloom<editcondition=bOverride_EnableBloom>;
	/** Whether to use depth of field effect.														*/
	var()	bool			bEnableDOF<editcondition=bOverride_EnableDOF>;
	/** Whether to use motion blur effect.															*/
	var()	bool			bEnableMotionBlur<editcondition=bOverride_EnableMotionBlur>;
	/** Whether to use the material/ scene effect.													*/
	var()	bool			bEnableSceneEffect<editcondition=bOverride_EnableSceneEffect>;
	/** Whether to allow ambient occlusion.															*/
	var()	bool			bAllowAmbientOcclusion<editcondition=bOverride_AllowAmbientOcclusion>;
	/** Whether to override the rim shader color.													*/
	var()	bool			bOverrideRimShaderColor<editcondition=bOverride_OverrideRimShaderColor>;

	/** Scale for the blooming.																		*/
	var()	interp float	Bloom_Scale<editcondition=bOverride_Bloom_Scale>;
	/** Bloom threshold																		*/
	var()	interp float	Bloom_Threshold<editcondition=bOverride_Bloom_Threshold>;
	/** Bloom tint color																		*/
	var()	interp color	Bloom_Tint<editcondition=bOverride_Bloom_Tint>;
	/** Bloom screen blend threshold																		*/
	var()	interp float	Bloom_ScreenBlendThreshold<editcondition=bOverride_Bloom_ScreenBlendThreshold>;
	/** Duration over which to interpolate values to.												*/
	var()	float			Bloom_InterpolationDuration<editcondition=bOverride_Bloom_InterpolationDuration>;

	/** Exponent to apply to blur amount after it has been normalized to [0,1].						*/
	var()	interp float	DOF_FalloffExponent<editcondition=bOverride_DOF_FalloffExponent>;
	/** affects the size of the Poisson disc kernel, can affect bloom as well */
	var()	interp float	DOF_BlurKernelSize<editcondition=bOverride_DOF_BlurKernelSize>;
	/** the radius of the bloom effect */
	var()	interp float	DOF_BlurBloomKernelSize<editcondition=bOverride_DOF_BlurBloomKernelSize>;
	/** [0,1] value for clamping how much blur to apply to items in front of the focus plane.		*/
	var()	interp float	DOF_MaxNearBlurAmount<editcondition=bOverride_DOF_MaxNearBlurAmount>;
	/** [0,1] value for clamping how much blur to apply to items behind the focus plane.			*/
	var()	interp float	DOF_MaxFarBlurAmount<editcondition=bOverride_DOF_MaxFarBlurAmount>;
	/** Blur color for debugging etc.																*/
	var()	color			DOF_ModulateBlurColor<editcondition=bOverride_DOF_ModulateBlurColor>;
	/** Controls how the focus point is determined.													*/
	var()	EFocusType		DOF_FocusType<editcondition=bOverride_DOF_FocusType>;
	/** Inner focus radius.																			*/
	var()	interp float	DOF_FocusInnerRadius<editcondition=bOverride_DOF_FocusInnerRadius>;
	/** Used when FOCUS_Distance is enabled.														*/
	var()	interp float	DOF_FocusDistance<editcondition=bOverride_DOF_FocusDistance>;
	/** Used when FOCUS_Position is enabled.														*/
	var()	vector			DOF_FocusPosition<editcondition=bOverride_DOF_FocusPosition>;
	/** Duration over which to interpolate values to.												*/
	var()	float			DOF_InterpolationDuration<editcondition=bOverride_DOF_InterpolationDuration>;

	/** Maximum blur velocity amount.  This is a clamp on the amount of blur.						*/
	var()	interp float	MotionBlur_MaxVelocity<editcondition=bOverride_MotionBlur_MaxVelocity>;
	/** This is a scalar on the blur																*/
	var()	interp float	MotionBlur_Amount<editcondition=bOverride_MotionBlur_Amount>;
	/** Whether everything (static/dynamic objects) should motion blur or not. If disabled, only moving objects may blur. */
	var()	bool			MotionBlur_FullMotionBlur<editcondition=bOverride_MotionBlur_FullMotionBlur>;
	/** Threshhold for when to turn off motion blur when the camera rotates swiftly during a single frame (in degrees). */
	var()	interp float	MotionBlur_CameraRotationThreshold<editcondition=bOverride_MotionBlur_CameraRotationThreshold>;
	/** Threshhold for when to turn off motion blur when the camera translates swiftly during a single frame (in world units). */
	var()	interp float	MotionBlur_CameraTranslationThreshold<editcondition=bOverride_MotionBlur_CameraTranslationThreshold>;
	/** Duration over which to interpolate values to.												*/
	var()	float			MotionBlur_InterpolationDuration<editcondition=bOverride_MotionBlur_InterpolationDuration>;

	/** Desaturation amount.																		*/
	var()	interp float	Scene_Desaturation<editcondition=bOverride_Scene_Desaturation>;
	/** Controlling white point.																	*/
	var()	interp vector	Scene_HighLights<editcondition=bOverride_Scene_HighLights>;
	/** Controlling gamma curve.																	*/
	var()	interp vector	Scene_MidTones<editcondition=bOverride_Scene_MidTones>;
	/** Controlling black point.																	*/
	var()	interp vector	Scene_Shadows<editcondition=bOverride_Scene_Shadows>;
	/** Duration over which to interpolate values to.												*/
	var()	float			Scene_InterpolationDuration<editcondition=bOverride_Scene_InterpolationDuration>;

	/** Controlling rim shader color.																*/
	var()   LinearColor		RimShader_Color<editcondition=bOverride_RimShader_Color>;
	/** Duration over which to interpolate values to.												*/
	var()	float			RimShader_InterpolationDuration<editcondition=bOverride_RimShader_InterpolationDuration>;
	/** name of the LUT texture e.g. MyPackage01.LUTNeutral, empty if not used						*/
	var()	Texture			ColorGrading_LookupTable;
	/** used to blend color grading LUT in a very similar way we blend scalars */
	var	const private transient	LUTBlender ColorGradingLUT;

	structcpptext
	{
		FPostProcessSettings()
		{}

		FPostProcessSettings(INT A)
		{
			bOverride_EnableBloom = TRUE;
			bOverride_EnableDOF = TRUE;
			bOverride_EnableMotionBlur = TRUE;
			bOverride_EnableSceneEffect = TRUE;
			bOverride_AllowAmbientOcclusion = TRUE;
			bOverride_OverrideRimShaderColor = TRUE;

			bOverride_Bloom_Scale = TRUE;
			bOverride_Bloom_Threshold = TRUE;
			bOverride_Bloom_Tint = TRUE;
			bOverride_Bloom_ScreenBlendThreshold = TRUE;
			bOverride_Bloom_InterpolationDuration = TRUE;

			bOverride_DOF_FalloffExponent = TRUE;
			bOverride_DOF_BlurKernelSize = TRUE;
			bOverride_DOF_BlurBloomKernelSize = TRUE;
			bOverride_DOF_MaxNearBlurAmount = TRUE;
			bOverride_DOF_MaxFarBlurAmount = TRUE;
			bOverride_DOF_ModulateBlurColor = TRUE;
			bOverride_DOF_FocusType = TRUE;
			bOverride_DOF_FocusInnerRadius = TRUE;
			bOverride_DOF_FocusDistance = TRUE;
			bOverride_DOF_FocusPosition = TRUE;
			bOverride_DOF_InterpolationDuration = TRUE;

			bOverride_MotionBlur_MaxVelocity = TRUE;
			bOverride_MotionBlur_Amount = TRUE;
			bOverride_MotionBlur_FullMotionBlur = TRUE;
			bOverride_MotionBlur_CameraRotationThreshold = TRUE;
			bOverride_MotionBlur_CameraTranslationThreshold = TRUE;
			bOverride_MotionBlur_InterpolationDuration = TRUE;
			bOverride_Scene_Desaturation = TRUE;
			bOverride_Scene_HighLights = TRUE;
			bOverride_Scene_MidTones = TRUE;
			bOverride_Scene_Shadows = TRUE;
			bOverride_Scene_InterpolationDuration = TRUE;
			bOverride_RimShader_Color = TRUE;
			bOverride_RimShader_InterpolationDuration = TRUE;

			bEnableBloom=TRUE;
			bEnableDOF=FALSE;
			bEnableMotionBlur=TRUE;
			bEnableSceneEffect=TRUE;
			bAllowAmbientOcclusion=TRUE;
			bOverrideRimShaderColor=FALSE;

			Bloom_Scale=1;
			Bloom_Threshold=1;
			Bloom_Tint=FColor(255,255,255);
			Bloom_ScreenBlendThreshold=10;
			Bloom_InterpolationDuration=1;

			DOF_FalloffExponent=4;
			DOF_BlurKernelSize=16;
			DOF_BlurBloomKernelSize=16;
			DOF_MaxNearBlurAmount=1;
			DOF_MaxFarBlurAmount=1;
			DOF_ModulateBlurColor=FColor(255,255,255,255);
			DOF_FocusType=FOCUS_Distance;
			DOF_FocusInnerRadius=2000;
			DOF_FocusDistance=0;
			DOF_InterpolationDuration=1;

			MotionBlur_MaxVelocity=1.0f;
			MotionBlur_Amount=0.5f;
			MotionBlur_FullMotionBlur=TRUE;
			MotionBlur_CameraRotationThreshold=90.0f;
			MotionBlur_CameraTranslationThreshold=10000.0f;
			MotionBlur_InterpolationDuration=1;

			Scene_Desaturation=0;
			Scene_HighLights=FVector(1,1,1);
			Scene_MidTones=FVector(1,1,1);
			Scene_Shadows=FVector(0,0,0);
			Scene_InterpolationDuration=1;

			RimShader_Color=FLinearColor(0.470440f,0.585973f,0.827726f,1.0f);
			RimShader_InterpolationDuration=1;
		}

		/**
		 * Blends the settings on this structure marked as override setting onto the given settings
		 *
		 * @param	ToOverride	The settings that get overridden by the overridable settings on this structure. 
		 * @param	Alpha		The opacity of these settings. If Alpha is 1, ToOverride will equal this setting structure.
		 */
		void OverrideSettingsFor( FPostProcessSettings& ToOverride, FLOAT Alpha=1.f ) const;

		/**
		 * Enables the override setting for the given post-process setting.
		 *
		 * @param	PropertyName	The post-process property name to enable.
		 */
		void EnableOverrideSetting( const FName& PropertyName );

		/**
		 * Disables the override setting for the given post-process setting.
		 *
		 * @param	PropertyName	The post-process property name to enable.
		 */
		void DisableOverrideSetting( const FName& PropertyName );

		/**
		 * Sets all override values to false, which prevents overriding of this struct.
		 *
		 * @note	Overrides can be enabled again. 
		 */
		void DisableAllOverrides();

		/**
		 * Enables bloom for the post process settings.
		 */
		FORCEINLINE void EnableBloom()
		{
			bOverride_EnableBloom = TRUE;
			bEnableBloom = TRUE;
		}

		/**
		 * Enables DOF for the post process settings.
		 */
		FORCEINLINE void EnableDOF()
		{
			bOverride_EnableDOF = TRUE;
			bEnableDOF = TRUE;
		}

		/**
		 * Enables motion blur for the post process settings.
		 */
		FORCEINLINE void EnableMotionBlur()
		{
			bOverride_EnableMotionBlur = TRUE;
			bEnableMotionBlur = TRUE;
		}

		/**
		 * Enables scene effects for the post process settings.
		 */
		FORCEINLINE void EnableSceneEffect()
		{
			bOverride_EnableSceneEffect = TRUE;
			bEnableSceneEffect = TRUE;
		}

		/**
		 * Enables rim shader color for the post process settings.
		 */
		FORCEINLINE void EnableRimShader()
		{
			bOverride_OverrideRimShaderColor = TRUE;
			bOverrideRimShaderColor = TRUE;
		}

		/**
		 * Disables the override to enable bloom if no overrides are set for bloom settings.
		 */
		void DisableBloomOverrideConditional();

		/**
		 * Disables the override to enable DOF if no overrides are set for DOF settings.
		 */
		void DisableDOFOverrideConditional();

		/**
		 * Disables the override to enable motion blur if no overrides are set for motion blur settings.
		 */
		void DisableMotionBlurOverrideConditional();

		/**
		 * Disables the override to enable scene effect if no overrides are set for scene effect settings.
		 */
		void DisableSceneEffectOverrideConditional();

		/**
		 * Disables the override to enable rim shader if no overrides are set for rim shader settings.
		 */
		void DisableRimShaderOverrideConditional();
		
		/** Zeros all numerical settings */
		void ZeroSettings();
		
		/** Computes the delta between all numerical values of two PostProcessSettings objects
		 *	Delta = NewSettings - This
		 *
		 *	@param NewSettings - The settings object to compare against
		 *	@param DeltaSettings - The settings object that will contain the resulting delta
		 */
		void ComputeDeltaSettings(FPostProcessSettings& NewSettings, FPostProcessSettings& DeltaSettings);
		
		/** Adds the numerical values of two PostProcessSettings objects together
		 *	Only makes sense when used in conjunction with a PP Settings Delta
		 *
		 *	@param OtherSettings - The settings object to add with this one
		 *	@param ResultSettings - The settings object that will contain the resulting delta
		 */
		void AddSettings(FPostProcessSettings& OtherSettings, FPostProcessSettings& ResultSettings);
		
		/** Multiply the numerical values of a PostProcessSettings object by a float
		 *	Only makes sense when used in conjunction with a PP Settings Delta
		 *
		 *	@param Scale - The float to multiply the values by
		 *	@param ResultSettings - The settings object that will contain the resulting delta
		 */
		void ScaleSettings(FLOAT Scale, FPostProcessSettings& ResultSettings);
	}

	structdefaultproperties
	{
		bOverride_EnableBloom=TRUE
		bOverride_EnableDOF=TRUE
		bOverride_EnableMotionBlur=TRUE
		bOverride_EnableSceneEffect=TRUE
		bOverride_AllowAmbientOcclusion=TRUE
		bOverride_OverrideRimShaderColor=TRUE
		bOverride_Bloom_Scale=TRUE
		bOverride_Bloom_Threshold=TRUE
		bOverride_Bloom_Tint=TRUE
		bOverride_Bloom_ScreenBlendThreshold=TRUE
		bOverride_Bloom_InterpolationDuration=TRUE
		bOverride_DOF_FalloffExponent=TRUE
		bOverride_DOF_BlurKernelSize=TRUE
		bOverride_DOF_BlurBloomKernelSize=TRUE
		bOverride_DOF_MaxNearBlurAmount=TRUE
		bOverride_DOF_MaxFarBlurAmount=TRUE
		bOverride_DOF_ModulateBlurColor=TRUE
		bOverride_DOF_FocusType=TRUE
		bOverride_DOF_FocusInnerRadius=TRUE
		bOverride_DOF_FocusDistance=TRUE
		bOverride_DOF_FocusPosition=TRUE
		bOverride_DOF_InterpolationDuration=TRUE
		bOverride_MotionBlur_MaxVelocity=TRUE
		bOverride_MotionBlur_Amount=TRUE
		bOverride_MotionBlur_FullMotionBlur=TRUE
		bOverride_MotionBlur_CameraRotationThreshold=TRUE
		bOverride_MotionBlur_CameraTranslationThreshold=TRUE
		bOverride_MotionBlur_InterpolationDuration=TRUE
		bOverride_Scene_Desaturation=TRUE
		bOverride_Scene_HighLights=TRUE
		bOverride_Scene_MidTones=TRUE
		bOverride_Scene_Shadows=TRUE
		bOverride_Scene_InterpolationDuration=TRUE
		bOverride_RimShader_Color=TRUE
		bOverride_RimShader_InterpolationDuration=TRUE

		bEnableBloom=TRUE
		bEnableDOF=FALSE
		bEnableMotionBlur=TRUE
		bEnableSceneEffect=TRUE
		bAllowAmbientOcclusion=TRUE
		bOverrideRimShaderColor=FALSE
		
		Bloom_Scale=1
		Bloom_Threshold=1
		Bloom_Tint=(R=255,G=255,B=255)
		Bloom_ScreenBlendThreshold=10
		Bloom_InterpolationDuration=1

		DOF_FalloffExponent=4
		DOF_BlurKernelSize=16
		DOF_BlurBloomKernelSize=16
		DOF_MaxNearBlurAmount=1
		DOF_MaxFarBlurAmount=1
		DOF_ModulateBlurColor=(R=255,G=255,B=255,A=255)
		DOF_FocusType=FOCUS_Distance
		DOF_FocusInnerRadius=2000
		DOF_FocusDistance=0
		DOF_InterpolationDuration=1

		MotionBlur_MaxVelocity=1.0
		MotionBlur_Amount=0.5
		MotionBlur_FullMotionBlur=TRUE
		MotionBlur_CameraRotationThreshold=45.0
		MotionBlur_CameraTranslationThreshold=10000.0
		MotionBlur_InterpolationDuration=1

		Scene_Desaturation=0
		Scene_HighLights=(X=1,Y=1,Z=1)
		Scene_MidTones=(X=1,Y=1,Z=1)
		Scene_Shadows=(X=0,Y=0,Z=0)
		Scene_InterpolationDuration=1

		RimShader_Color=(R=0.470440f,G=0.585973f,B=0.827726f,A=1.0f)
		RimShader_InterpolationDuration=1
	}

};

/**
 * Priority of this volume. In the case of overlapping volumes the one with the highest priority
 * is chosen. The order is undefined if two or more overlapping volumes have the same priority.
 */
var()							float					Priority;

/**
 * Post process settings to use for this volume.
 */
var()							PostProcessSettings		Settings;

/** Next volume in linked listed, sorted by priority in descending order.							*/
var const noimport transient	PostProcessVolume		NextLowerPriorityVolume;


/** Whether this volume is enabled or not.															*/
var()							bool					bEnabled;

replication
{
	if (bNetDirty)
		bEnabled;
}

/**
 * Kismet support for toggling bDisabled.
 */
simulated function OnToggle(SeqAct_Toggle action)
{
	if (action.InputLinks[0].bHasImpulse)
	{
		// "Turn On" -- mapped to enabling of volume.
		bEnabled = TRUE;
	}
	else if (action.InputLinks[1].bHasImpulse)
	{
		// "Turn Off" -- mapped to disabling of volume.
		bEnabled = FALSE;
	}
	else if (action.InputLinks[2].bHasImpulse)
	{
		// "Toggle"
		bEnabled = !bEnabled;
	}
	ForceNetRelevant();
	SetForcedInitialReplicatedProperty(Property'Engine.PostProcessVolume.bEnabled', (bEnabled == default.bEnabled));
}

cpptext
{
	/**
	 * Routes ClearComponents call to Super and removes volume from linked list in world info.
	 */
	virtual void ClearComponents();
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void PostLoad();
protected:
	/**
	 * Routes UpdateComponents call to Super and adds volume to linked list in world info.
	 */
	virtual void UpdateComponentsInternal(UBOOL bCollisionUpdate = FALSE);
public:
}

defaultproperties
{
	Begin Object Name=BrushComponent0
		CollideActors=False
		BlockActors=False
		BlockZeroExtent=False
		BlockNonZeroExtent=False
		BlockRigidBody=False
	End Object

	bCollideActors=False
	bBlockActors=False
	bProjTarget=False
	bStatic=false
	bTickIsDisabled=true

	SupportedEvents.Empty
	SupportedEvents(0)=class'SeqEvent_Touch'

	bEnabled=True
}
