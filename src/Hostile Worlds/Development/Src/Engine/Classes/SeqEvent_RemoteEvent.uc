/**
 * Activated by the ActivateRemoteEvent action.
 * Originator: current WorldInfo
 * Instigator: the actor that is assigned [in editor] as the ActivateRemoteEvent action's Instigator
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqEvent_RemoteEvent extends SequenceEvent
	native(Sequence);

cpptext
{
protected:
	FString GetDisplayTitle() const;
public:
	virtual void DrawExtraInfo(FCanvas* Canvas, const FVector& BoxCenter);
	virtual void UpdateStatus();
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
};

/** Name of this event for remote activation */
var() Name EventName;

/** For use in Kismet, to indicate if this variable is ok. Updated in UpdateStatus. */
var transient bool bStatusIsOk;


static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 1;
}



defaultproperties
{
	ObjName="Remote Event"
	MaxTriggerCount=0

	EventName=DefaultEvent
	bPlayerOnly=FALSE
}
