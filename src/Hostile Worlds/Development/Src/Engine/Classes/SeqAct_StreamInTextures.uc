/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_StreamInTextures extends SeqAct_Latent
	native(Sequence);

cpptext
{
	void Activated();
	UBOOL UpdateOp(FLOAT deltaTime);
	void DeActivated();
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void PostLoad();
	virtual void UpdateObject();

	virtual void ApplyForceMipSettings( UBOOL bEnable, FLOAT Duration );
}

/** Whether we should stream in textures based on location or usage. If TRUE, textures surrounding the attached actors will start to stream in. If FALSE, textures used by the attached actors will start to stream in. */
var	deprecated bool	bLocationBased;

/** Number of seconds to force the streaming system to stream in all of the target's textures or enforce bForceMiplevelsToBeResident */
var()	float	Seconds;

/** Is this streaming currently active? */
var const bool	bStreamingActive;

/** Timestamp for when we should stop the forced texture streaming. */
var const float StopTimestamp;

/** Textures surrounding the LocationActors will begin to stream in */
var() array<Object> LocationActors;

/** Array of Materials to set bForceMiplevelsToBeResident on their textures for the duration of this action. */
var() array<MaterialInterface> ForceMaterials;

/** Texture groups that will use extra (higher resolution) mip-levels. */
var(CinematicMipLevels) const TextureGroupContainer	CinematicTextureGroups;

/** Internal bitfield representing the selection in CinematicTextureGropus. */
var native private transient const int		SelectedCinematicTextureGroups;

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

static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 1;
}

defaultproperties
{
	ObjName="Stream In Textures"
	ObjCategory="Actor"
	Seconds=15.0
	bStreamingActive=false
	StopTimestamp=0.0
	InputLinks(0)=(LinkDesc="Start")
	InputLinks(1)=(LinkDesc="Stop")

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Actor",PropertyName=Targets)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Location",PropertyName=LocationActors)
}
