/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqVar_Character extends SeqVar_Object
	abstract
	native(Sequence);

cpptext
{
	UObject** GetObjectRef( INT Idx );

	virtual FString GetValueStr()
	{
		return ObjName;
	}

	virtual UBOOL SupportsProperty(UProperty *Property)
	{
		return FALSE;
	}

	virtual void CheckForErrors();
}

/** Pawn class for the character we're looking for */
var class<Pawn> PawnClass;

defaultproperties
{
	ObjCategory="Player"
}
