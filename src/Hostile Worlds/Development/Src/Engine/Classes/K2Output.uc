/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Output extends K2Connector
	native;

var array<K2Input>  ToInputs;



cpptext
{
#if WITH_EDITOR
	void BreakConnectionTo(UK2Input* ToInput);

	void BreakAllConnections();
#endif
}