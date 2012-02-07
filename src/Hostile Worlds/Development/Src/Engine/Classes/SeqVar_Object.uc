/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqVar_Object extends SequenceVariable
	native(Sequence);

cpptext
{
	virtual UObject** GetObjectRef( INT Idx )
	{
		if( Idx != 0 )
		{
			return NULL;
		}
		return &ObjValue;
	}

	virtual FVector* GetRef();

	virtual FString GetValueStr()
	{
		return FString::Printf(TEXT("%s"),ObjValue!=NULL?*ObjValue->GetName():TEXT("???"));
	}

	virtual void OnExport()
	{
		ObjValue = NULL;
	}

	// USequenceVariable interface
	virtual void DrawExtraInfo(FCanvas* Canvas, const FVector& CircleCenter);

	virtual UBOOL SupportsProperty(UProperty *Property)
	{
		return (Property->IsA(UObjectProperty::StaticClass()) ||
				(Property->IsA(UArrayProperty::StaticClass()) && ((UArrayProperty*)Property)->Inner->IsA(UObjectProperty::StaticClass())));
	}

	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	virtual void PublishValue(USequenceOp *Op, UProperty *Property, FSeqVarLink &VarLink);
	virtual void PopulateValue(USequenceOp *Op, UProperty *Property, FSeqVarLink &VarLink);
}

var() protected Object ObjValue;

/** Local copy of the actor location, used as a dummy when treating an Actor as a vector, to prevent accidental writes to the Actor location */
var transient vector ActorLocation;

var const array<class<Object> > SupportedClasses;

/** returns the object this variable is currently pointing to
 * if this variable represents a list of objects, only returns the first one
 */
function Object GetObjectValue()
{
	return ObjValue;
}

/** sets the object this variable points to */
function SetObjectValue(Object NewValue)
{
	ObjValue = NewValue;
}

defaultproperties
{
	ObjName="Object"
	ObjCategory="Object"
	ObjColor=(R=255,G=0,B=255,A=255)		// purple
	SupportedClasses=(class'Object')
}
