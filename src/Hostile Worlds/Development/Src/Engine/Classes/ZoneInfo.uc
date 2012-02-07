//=============================================================================
// Deprecated.
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class ZoneInfo extends Info
	native;

//-----------------------------------------------------------------------------
// Zone properties.

var() float KillZ;		// any actor falling below this level gets destroyed
var() float SoftKill;
var() class<KillZDamageType> KillZDamageType<AllowAbstract>;
var() bool bSoftKillZ;	// SoftKill units of grace unless land

defaultproperties
{
	KillZ=-262143.0  // this is HALF_WORLD_MAX1
	SoftKill=2500.0
	bStatic=true
	bNoDelete=true
	bGameRelevant=true
	KillZDamageType=class'KillZDamageType'
}
