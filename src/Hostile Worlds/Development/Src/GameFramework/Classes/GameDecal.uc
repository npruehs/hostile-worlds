/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class GameDecal extends DecalComponent
	native(Decal)
	abstract;


/** The vast majority of our decals have an MITV/MIC attached to them.  So we are just going to store that here.  So we don't have to keep allocating it **/
var transient MaterialInstanceTimeVarying MITV_Decal;

/** Pawn that owns us basically */
var transient Pawn Instigator;



defaultproperties
{
	MaxDrawDistance=4000
}