/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Input_Bool extends K2Input
	native(K2);

var bool    bDefaultBool;

cpptext
{
#if WITH_EDITOR
	virtual FString GetValueString();
	virtual void SetDefaultFromString(const FString& InString);
#endif
}

defaultproperties
{
	Type=K2CT_Bool
}