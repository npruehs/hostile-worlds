/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class AnimNotify_PlayParticleEffect extends AnimNotify
	native(Anim);

/** The Particle system to play **/
var() ParticleSystem PSTemplate;

/** If this effect should be considered extreme content **/
var() bool bIsExtremeContent;

/** If this particle system should be attached to the location.**/
var() bool bAttach;

/** The socketname in which to play the particle effect.  Looks for a socket name first then bone name **/
var() name SocketName;

/** The bone name in which to play the particle effect. Looks for a socket name first then bone name **/
var() name BoneName;

/** If TRUE, the particle system will play in the viewer as well as in game */
var() editoronly bool bPreview;

/** If Owner is hidden, skip particle effect */
var() bool bSkipIfOwnerIsHidden;

cpptext
{
	// AnimNotify interface.
	virtual void Notify( class UAnimNodeSequence* NodeSeq );
}

defaultproperties
{
	NotifyColor=(R=200,G=255,B=200)
	bSkipIfOwnerIsHidden=TRUE
}

