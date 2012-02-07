/**
 * Panel class that locks its position and size to match the safe region for the viewport.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UISafeRegionPanel extends UIContainer
	config(Game)
	placeable
	native(UIPrivate);

enum ESafeRegionType
{
	ESRT_FullRegion,
	ESRT_TextSafeRegion
};

/** This holds the type of region to create */
var(SafeRegion) ESafeRegionType RegionType;

/** Holds a list of percentages that define each region */
var(SafeRegion) config editinline float RegionPercentages[ESafeRegionType];

/** If true, the panel will force the 4x3 Aspect Ratio */
var(SafeRegion) bool	bForce4x3AspectRatio;
var(SafeRegion) bool 	bUseFullRegionIn4x3;
var(SafeRegion)	bool	bPrimarySafeRegion;

cpptext
{
	/**
	 * Called at the beginning of the first scene update and propagated to all widgets in the scene.  Provides classes with
	 * an opportunity to initialize anything that couldn't be setup earlier due to lack of a viewport.
	 *
	 * This version sets the scene's PrimarySafeRegionPanel value to this panel if bPrimarySafeRegion is TRUE
	 */
	virtual void PreInitialSceneUpdate();

	/**
	 * Initializes the panel and sets its position to match the safe region.
	 */
	virtual void ResolveFacePosition( EUIWidgetFace Face );

	/**
	 * @return Returns TRUE if this widget can be resized, repositioned, or rotated, FALSE otherwise.
	 */
	virtual UBOOL IsTransformable() const
	{
		return FALSE;
	}

	/**
	 * Performs the actual alignment
	 */
	virtual void AlignPanel();

	/**
	 * Called when a property value has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);
}

defaultproperties
{
	bPrimarySafeRegion=true
}



