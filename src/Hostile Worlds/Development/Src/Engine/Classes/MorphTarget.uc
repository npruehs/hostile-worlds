/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MorphTarget extends Object
	native(Anim)
	noexport
	hidecategories(Object);
	
/** morph mesh vertex data for each LOD */
var	const native array<int>		MorphLODModels; //FMorphTargetLODModel

/** Material Parameter control **/
var(Material)				INT							MaterialSlotId;
var(Material)				Name						ScalarParameterName;
var				transient	MaterialInstanceConstant	MaterialInstanceConstant;
