/**
 * UI-specific version of the ConsoleCommand action, which is capable of automatically attaching to the owning widget.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIAction_ConsoleCommand extends UIAction;

var() string Command;

DefaultProperties
{
	ObjName="Console Command"

	ObjCategory="Misc"

	bAutoTargetOwner=true

	VariableLinks.Add((ExpectedType=class'SeqVar_String',LinkDesc="Command",PropertyName=Command))
}
