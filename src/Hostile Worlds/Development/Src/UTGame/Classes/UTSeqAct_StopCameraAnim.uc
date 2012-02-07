/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * UT-specific CameraAnim action to provide for stopping a playing cameraanim.
 */

class UTSeqAct_StopCameraAnim extends SequenceAction;

/** True to stop immediately, regardless of BlendOutTime specified when the anim was played. */
var()	bool		bStopImmediately;

/**
 * Return the version number for this class.  Child classes should increment this method by calling Super then adding
 * a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
 * link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
 * Super.GetObjClassVersion() should be incremented by 1.
 *
 * @return	the version number for this specific class.
 */
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 0;
}

defaultproperties
{
	ObjName="Stop Camera Animation"
	ObjCategory="Camera"
}
