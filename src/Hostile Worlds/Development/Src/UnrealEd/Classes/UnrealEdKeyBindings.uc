/**
 * This class handles hotkey binding management for the editor.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UnrealEdKeyBindings extends Object
	Config(EditorKeyBindings)
	native;

/** An editor hotkey binding to a parameterless exec. */
struct native EditorKeyBinding
{
	var bool bCtrlDown;
	var bool bAltDown;
	var bool bShiftDown;
	var name Key;
	var name CommandName;
};

/** Array of keybindings */
var config array<EditorKeyBinding> KeyBindings;