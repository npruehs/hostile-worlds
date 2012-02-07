/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Node_Func extends K2Node_FuncBase
	native(K2);

cpptext
{
#if WITH_EDITOR
	virtual void GetCodeText(struct FK2CodeGenContext& Context, TArray<struct FK2CodeLine>& OutCode);
	virtual FColor GetBorderColor();

	virtual void CreateAutoConnectors();
#endif
};