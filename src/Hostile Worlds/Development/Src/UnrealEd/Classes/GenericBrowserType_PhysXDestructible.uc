/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// GenericBrowserType_PhysXDestructible: PhysX destructibles
//=============================================================================

class GenericBrowserType_PhysXDestructible
	extends GenericBrowserType
	native;

cpptext
{
	virtual void Init();
	virtual UBOOL ShowObjectEditor(UObject *InObject);
}
	
defaultproperties
{
	Description="PhysX Destructibles"
}
