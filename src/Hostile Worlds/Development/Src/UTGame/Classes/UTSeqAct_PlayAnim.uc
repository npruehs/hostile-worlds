/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTSeqAct_PlayAnim extends SequenceAction;

/** The name of the anim to play **/
var() name AnimName;

/** Whether or not to loop the anim **/
var() bool bLooping;


defaultproperties
{
	ObjName="Pawn Anim"
	ObjCategory="Pawn"
}
