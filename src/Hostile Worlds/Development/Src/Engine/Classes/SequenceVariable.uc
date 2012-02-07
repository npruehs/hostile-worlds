/**
 * Base class for all variables used by SequenceOps.
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SequenceVariable extends SequenceObject
	native(Sequence)
	abstract;

cpptext
{
	// UObject interface
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	// USequenceObject interface
	virtual void DrawSeqObj(FCanvas* Canvas, UBOOL bSelected, UBOOL bMouseOver, INT MouseOverConnType, INT MouseOverConnIndex, FLOAT MouseOverTime);
	virtual FIntRect GetSeqObjBoundingBox();

	virtual UObject** GetObjectRef( INT Idx )
	{
		return NULL;
	}

	virtual FString GetValueStr()
	{
		return FString(TEXT("Undefined"));
	}

	/**
	 * Used for property exposure to variable links, allows variables
	 * to determine what types they can support.
	 */
	virtual UBOOL SupportsProperty(UProperty *Property)
	{
		return FALSE;
	}

	/**
	 * Returns whether this SequenceObject can exist in a sequence without being linked to anything else (i.e. does not require
	 * another sequence object to activate it)
	 */
	virtual UBOOL IsStandalone() const;

	/**
	 * Copies the value stored by this SequenceVariable to the SequenceOp member variable that it's associated with.
	 *
	 * @param	Op			the sequence op that contains the value that should be copied from this sequence variable
	 * @param	Property	the property in Op that will receive the value of this sequence variable
	 * @param	VarLink		the variable link in Op that this sequence variable is linked to
	 */
	virtual void PublishValue(USequenceOp *Op, UProperty *Property, FSeqVarLink &VarLink) {}

	/**
	 * Copy the value from the member variable this VariableLink is associated with to this VariableLink's value.
	 *
	 * @param	Op			the sequence op that contains the value that should be copied to this sequence variable
	 * @param	Property	the property in Op that contains the value to copy into this sequence variable
	 * @param	VarLink		the variable link in Op that this sequence variable is linked to
	 */
	virtual void PopulateValue(USequenceOp *Op, UProperty *Property, FSeqVarLink &VarLink) {}

	/**
	 * Allows the sequence variable to execute additional logic after copying values from the SequenceOp's members to the sequence variable.
	 *
	 * @param	SourceOp	the sequence op that contains the value that should be copied to this sequence variable
	 * @param	VarLink		the variable link in Op that this sequence variable is linked to
	 */
	virtual void PostPopulateValue( USequenceOp* SourceOp, FSeqVarLink& VarLink ) {}

	// USequenceVariable interface
	virtual void DrawExtraInfo(FCanvas* Canvas, const FVector& CircleCenter) {}

	FIntPoint GetVarConnectionLocation();
}

/** This is used by SeqVar_Named to find a variable anywhere in the levels sequence. */
var()	name	VarName;

/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	return true;
}

defaultproperties
{
	ObjName="Undefined Variable"
	ObjColor=(R=0,G=0,B=0,A=255)	// black
	bDrawLast=true
}

