/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// GenericBrowserType_AITree: AI Behavior Tree
//=============================================================================

class GenericBrowserType_AITree
	extends GenericBrowserType
	native;

cpptext
{
	virtual void Init();

	virtual UBOOL ShowObjectEditor( UObject* InObject );
	virtual void QuerySupportedCommands( class USelection* InObjects, TArray< FObjectSupportedCommandType >& OutCommands ) const;
}
	
defaultproperties
{
	Description="AI Tree"
}
