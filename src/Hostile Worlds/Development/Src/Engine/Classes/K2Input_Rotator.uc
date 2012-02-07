/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Input_Rotator extends K2Input
	native(K2);

var rotator  DefaultRotator;

cpptext
{
#if WITH_EDITOR
	virtual FString GetValueString();
	virtual FString GetValueCodeString();
	virtual void SetDefaultFromString(const FString& InString);
#endif
}

defaultproperties
{
	Type=K2CT_Rotator
}