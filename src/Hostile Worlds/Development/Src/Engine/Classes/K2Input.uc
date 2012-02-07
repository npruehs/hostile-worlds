/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Input extends K2Connector
	native;

var K2Output FromOutput;


cpptext
{
#if WITH_EDITOR
	void Break();

	virtual FString GetValueCodeString();
	virtual FString GetValueString();
	virtual void SetDefaultFromString(const FString& InString) {}
#endif
}

