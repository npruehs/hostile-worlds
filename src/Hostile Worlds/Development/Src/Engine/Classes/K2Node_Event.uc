/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Node_Event extends K2Node_Code
	native(K2);

var string      EventName;
var function    Function;

cpptext
{
#if WITH_EDITOR
	virtual void CreateAutoConnectors();

	virtual FString GetDisplayName();
	virtual FColor GetBorderColor();

	void GetEventText(FK2CodeGenContext& Context, TArray<struct FK2CodeLine>& OutCode);
#endif
}
