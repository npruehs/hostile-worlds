/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
/** activates/deactivates infinite ammo for the target(s) */
class UTSeqAct_InfiniteAmmo extends SequenceAction;

var() bool bInfiniteAmmo;

defaultproperties
{
	ObjCategory="Pawn"
	ObjName="Infinite Ammo"
	bInfiniteAmmo=true
}
