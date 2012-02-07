/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class AnimNotify_Kismet extends AnimNotify
	native(Anim);

var() name NotifyName;

cpptext
{
	// AnimNotify interface.
	virtual void Notify( class UAnimNodeSequence* NodeSeq );
}
