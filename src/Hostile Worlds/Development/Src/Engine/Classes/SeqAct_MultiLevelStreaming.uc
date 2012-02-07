/**
 * SeqAct_MultiLevelStreaming
 *
 * Kismet action exposing loading and unloading of multiple levels at once.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_MultiLevelStreaming extends SeqAct_LevelStreamingBase
	native(Sequence);

struct native LevelStreamingNameCombo
{
	/** Cached LevelStreaming object that is going to be loaded/ unloaded on request.	*/
	var		const LevelStreaming		Level;
	/** LevelStreaming object name.														*/
	var()	const Name					LevelName;
};

/** Array of levels to load/ unload														*/
var() array<LevelStreamingNameCombo>	Levels;

/** Should any levels not contained in Levels be unloaded? */
var() bool bUnloadAllOtherLevels;

var transient bool bStatusIsOk;

cpptext
{
	void Activated();
	UBOOL UpdateOp(FLOAT DeltaTime);
	virtual void DrawExtraInfo(FCanvas* Canvas, const FVector& BoxCenter);
	virtual void UpdateStatus();
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
};

defaultproperties
{
	ObjName="Stream Levels"
}
