/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Output_Object extends K2Output
	native(K2);

var class<object>  ObjClass;

cpptext
{
#if WITH_EDITOR
	virtual FString GetTypeAsCodeString();
#endif
}