/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
 
/** 
 * Defines the parameters for an in world looping ambient sound e.g. a wind sound
 */
 
class SoundNodeAmbient extends SoundNode
	native( Sound )
	hidecategories( Object )
	AutoExpandCategories( Attenuation, LowPassFilter, Modulation, Sounds, Spatialization )
	DontSortCategories( Attenuation, LowPassFilter, Modulation, Sounds, Spatialization )
	dependson( SoundNodeAttenuation )
	editinlinenew;

struct native AmbientSoundSlot
{
	var()	SoundNodeWave	Wave;
	var()	float			PitchScale;
	var()	float			VolumeScale;
	var()	float			Weight;

	structdefaultproperties
	{
		PitchScale=1.0
		VolumeScale=1.0
		Weight=1.0
	}
	
	structcpptext
	{
		FAmbientSoundSlot( void )
		{
			PitchScale = 1.0f;
			VolumeScale = 1.0f;
			Weight = 1.0f;
		}
	}
};

/* The settings for attenuating. */
var( Attenuation )		bool					bAttenuate<ToolTip=Enable attenuation via volume>;
var( Attenuation )		bool					bSpatialize<ToolTip=Enable the source to be positioned in 3D>;
var( Attenuation )		float					dBAttenuationAtMax<ToolTip=The volume at maximum distance in deciBels>;

/** What kind of attenuation model to use */
var( Attenuation )		SoundDistanceModel		DistanceModel<ToolTip=The type of volume versus distance algorithm to use>;

var( Attenuation )		float					RadiusMin<ToolTip=The range at which the sound starts attenuating>;
var( Attenuation )		float					RadiusMax<ToolTip=The range at which the sound has attenuated completely>;

/* The settings for attenuating with a low pass filter. */
var( LowPassFilter )	bool					bAttenuateWithLPF<ToolTip=Enable attenuation via low pass filter>;
var( LowPassFilter )	float					LPFRadiusMin<ToolTip=The range at which to start applying a low passfilter>;
var( LowPassFilter )	float					LPFRadiusMax<ToolTip=The range at which to apply the maximum amount of low pass filter>;

var( Modulation )		float					PitchMin<ToolTip=The lower bound of pitch (1.0 is no change)>;
var( Modulation )		float					PitchMax<ToolTip=The upper bound of pitch (1.0 is no change)>;

var( Modulation )		float					VolumeMin<ToolTip=The lower bound of volume (1.0 is no change)>;
var( Modulation )		float					VolumeMax<ToolTip=The upper bound of volume (1.0 is no change)>;

var( Sounds )			array<AmbientSoundSlot>	SoundSlots<ToolTip=Sounds to play>;

var			deprecated	SoundNodeWave			Wave;
var			deprecated	bool					bAttenuateWithLowPassFilter;
var			deprecated	rawdistributionfloat	MinRadius;
var			deprecated	rawdistributionfloat	MaxRadius;
var			deprecated	rawdistributionfloat	LPFMinRadius;
var			deprecated	rawdistributionfloat	LPFMaxRadius;
var			deprecated	rawdistributionfloat	PitchModulation;
var			deprecated	rawdistributionfloat	VolumeModulation;

defaultproperties
{
	bAttenuate=true
	bSpatialize=true
	dBAttenuationAtMax=-60
	RadiusMin=2000
	RadiusMax=5000
	DistanceModel=ATTENUATION_Linear
	
	bAttenuateWithLowPassFilter=false
	LPFRadiusMin=3500
	LPFRadiusMax=7000

	VolumeMin=0.7
	VolumeMax=0.7
	PitchMin=1.0
	PitchMax=1.0

	// Deprecated defaults
	Begin Object Class=DistributionFloatUniform Name=DistributionMinRadius
		Min=400
		Max=400
	End Object
	MinRadius=(Distribution=DistributionMinRadius)

	Begin Object Class=DistributionFloatUniform Name=DistributionMaxRadius
		Min=5000
		Max=5000
	End Object
	MaxRadius=(Distribution=DistributionMaxRadius)

	Begin Object Class=DistributionFloatUniform Name=DistributionLPFMinRadius
		Min=1500
		Max=1500
	End Object
	LPFMinRadius=(Distribution=DistributionLPFMinRadius)

	Begin Object Class=DistributionFloatUniform Name=DistributionLPFMaxRadius
		Min=2500
		Max=2500
	End Object
	LPFMaxRadius=(Distribution=DistributionLPFMaxRadius)

	Begin Object Class=DistributionFloatUniform Name=DistributionPitch
		Min=1
		Max=1
	End Object
	PitchModulation=(Distribution=DistributionPitch)
	
	Begin Object Class=DistributionFloatUniform Name=DistributionVolume
		Min=0.7
		Max=0.7
	End Object
	VolumeModulation=(Distribution=DistributionVolume)
}

