/**
 * UDK Specialized version of UIMeshWidget, adds some lights and optionally rotates the model.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKUIMeshWidget extends UIMeshWidget
	native
	placeable;

cpptext
{
	/* === UUIObject interface === */
	/**
	 * Updates 3D primitives for this widget.
	 *
	 * @param	CanvasScene		the scene to use for updating any 3D primitives
	 */
	virtual void UpdateWidgetPrimitives( FCanvasScene* CanvasScene );

	/* === UUIScreenObject interface === */
	/**
	 * Attach and initialize any 3D primitives for this widget and its children.
	 *
	 * @param	CanvasScene		the scene to use for attaching 3D primitives
	 */
	virtual void InitializePrimitives( class FCanvasScene* CanvasScene );
}

/** Amount of degrees to rotate per second. */
var() vector	RotationRate;

/** Light for the mesh widget. */
var() SkeletalMeshComponent SkeletalMeshComp;

/** Light for the mesh widget. */
var() LightComponent DefaultLight;

/** Light direction. */
var() vector	LightDirection;

/** Light for the mesh widget. */
var() LightComponent DefaultLight2;

/** Light direction. */
var() vector	LightDirection2;

/** Base Height to use for scaling, all meshes are fit within this height. A value of < 0 means no auto scaling. */
var() float			BaseHeight;

defaultproperties
{
	bDebugShowBounds=false
	BaseHeight=-1.0f

	Begin Object Class=SkeletalMeshComponent Name=WidgetSKMesh
	End Object
	SkeletalMeshComp=WidgetSKMesh

	Begin Object Class=DirectionalLightComponent Name=WidgetLight
	End Object
	DefaultLight=WidgetLight
	LightDirection=(X=0.0f,Y=45.0f,Z=180.0f)

	Begin Object Class=DirectionalLightComponent Name=WidgetLight2
	End Object
	DefaultLight2=WidgetLight2
	LightDirection2=(X=0.0f,Y=-45.0f,Z=180.0f)
}