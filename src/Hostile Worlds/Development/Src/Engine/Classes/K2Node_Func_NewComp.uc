/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Node_Func_NewComp extends K2Node_Func
	native(K2);

/** Template object used by this function (duplicated) to create a new component. */
var     ActorComponent      ComponentTemplate;

cpptext
{
#if WITH_EDITOR
	// K2NodeBase

	virtual FString GetDisplayName();

	virtual FString GetCodeFromParamInput(const FString& InputName, struct FK2CodeGenContext& Context);	
#endif
};