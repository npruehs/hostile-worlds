/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class LightFunction extends Object
	native(Light)
	hidecategories(Object)
	collapsecategories
	editinlinenew;

var() const MaterialInterface	SourceMaterial;
var() vector					Scale;

defaultproperties
{
	Scale=(X=1024.0,Y=1024.0,Z=1024.0)
}
