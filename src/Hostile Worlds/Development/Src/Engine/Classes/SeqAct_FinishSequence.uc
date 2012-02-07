/**
 * Upon activation this action triggers the associated output link
 * of the owning Sequence.
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_FinishSequence extends SequenceAction
	native(Sequence);

cpptext
{
protected:
	FString GetDisplayTitle() const;
public:
	virtual void Activated();
	virtual void OnCreated();
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
}

/** Text label to use on the sequence output link */
var() string OutputLabel;

defaultproperties
{
	ObjName="Finish Sequence"
	ObjCategory="Misc"
	OutputLabel="Out"
	OutputLinks.Empty
	VariableLinks.Empty
}
