/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class GenericBrowserType_DMC
	extends GenericBrowserType
	native;

cpptext
{
	virtual void Init();
	virtual UBOOL ShowObjectEditor( UObject* InObject );

	virtual void QuerySupportedCommands( class USelection* InObjects, TArray< FObjectSupportedCommandType >& OutCommands ) const;

	virtual INT QueryDefaultCommand( TArray<UObject*>& InObjects ) const;

}
	
defaultproperties
{
	Description="Designer Made Class"
}
