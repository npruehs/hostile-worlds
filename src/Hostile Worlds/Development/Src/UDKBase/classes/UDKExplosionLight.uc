/**
 * Light that changes its radius, brightness, and color over its lifespan based on user specified points.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKExplosionLight extends PointLightComponent
	native;

/** set false after frame rate dependent properties have been tweaked. */
var bool bCheckFrameRate;

/** used to initialize light properties from TimeShift on spawn so you don't have to update initial values in two places */
var bool bInitialized;

/** HighDetailFrameTime - if frame time is less than this (means high frame rate), force super high detail. */
var float HighDetailFrameTime;

/** Lifetime - how long this explosion has been going */
var float Lifetime;

/** Index into TimeShift array */
var int TimeShiftIndex;

struct native LightValues
{
	var float StartTime;
	var float Radius;
	var float Brightness;
	var color LightColor;
};

/** Specifies brightness, radius, and color of light at various points in its lifespan */
var() array<LightValues> TimeShift;

/**
  * Reset light timeline position to start
  */
final native function ResetLight();

/** called when the light has burnt out */
delegate OnLightFinished(UDKExplosionLight Light);

cpptext
{
	virtual void Attach();
	virtual void Tick(FLOAT DeltaTime);
}

defaultproperties
{
	HighDetailFrameTime=+0.015
	bCheckFrameRate=true
	Brightness=8
	Radius=256
	CastShadows=false
	LightColor=(R=255,G=255,B=255,A=255)
}
