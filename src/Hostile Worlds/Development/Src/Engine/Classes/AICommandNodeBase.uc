/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class AICommandNodeBase extends K2NodeBase
	native(AI);

cpptext
{
#if WITH_EDITOR
	virtual FString GetDisplayName();
	virtual void CreateAutoConnectors();
#endif
};

var() class<AICommandBase>      CommandClass;


native function AICommandNodeBase   SelectBestChild( AIController InAI, out AITreeHandle Handle );


defaultproperties
{
}

