/**
 * This sequence object provides a fast way to activate different actions based on the value of an object variable containing
 * which references a UIScreenObject.  Automatically generates a unique OutputLink for each widget value added by the designer.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UICond_SwitchWidget extends SeqCond_SwitchObject;

/**
 * Determines whether this class should be displayed in the list of available ops in the level kismet editor.
 *
 * @return	TRUE if this sequence object should be available for use in the level kismet editor
 */
event bool IsValidLevelSequenceObject()
{
	return false;
}

DefaultProperties
{
	ObjName="Switch Widget"
	MetaClass=class'Engine.UIScreenObject'
}

