//=============================================================================
// GameCameraBlockingVolume:  
// used to block the camera only (all other types of collision are ignored)
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class GameCameraBlockingVolume extends BlockingVolume
	hidecategories(Collision)
	native
	placeable;

cpptext
{
	// overidden to ignore blocking by anything except a camera actor
	virtual UBOOL IgnoreBlockingBy( const AActor *Other) const;		
	virtual UBOOL ShouldTrace(UPrimitiveComponent* Primitive,AActor *SourceActor, DWORD TraceFlags);
	virtual void SetCollisionForPathBuilding(UBOOL bNowPathBuilding);

};

defaultproperties
{
	bWorldGeometry=false
}
