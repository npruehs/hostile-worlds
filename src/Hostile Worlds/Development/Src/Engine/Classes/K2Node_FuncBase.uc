/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Node_FuncBase extends K2Node_Code
	native(K2);

/** Pointer to the function that this node will generate a call to */
var function    Function;

cpptext
{
#if WITH_EDITOR
	// K2NodeBase
	virtual FString GetDisplayName();

	// K2Node_Code
	virtual void GetCodeText(struct FK2CodeGenContext& Context, TArray<struct FK2CodeLine>& OutCode);

	// K2Node_FuncBase

	/** Gets the name of the function currently being used by this node */
	FString GetFunctionName();
#endif
};