/**
 * Bare bones example of rendering a 3D primitive from a UIScene using a StaticMeshComponent.  Though functional, this class is intended
 * primarily as an example of how to attach and use 3D primitives in UIScenes.  3D primitives can be used in any widget class - it doesn't
 * necessarily need to derive from this class.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIMeshWidget extends UIObject
	native(UIPrivate)
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

var(Appearance)	const	editconst	StaticMeshComponent		Mesh;



DefaultProperties
{
	bSupports3DPrimitives=true
	bSupportsPrimaryStyle=false	// no style

	bDebugShowBounds=true
	DebugBoundsColor=(R=128,G=0,B=64)

	Begin Object Class=StaticMeshComponent Name=WidgetMesh
	End Object
	Mesh=WidgetMesh
}
