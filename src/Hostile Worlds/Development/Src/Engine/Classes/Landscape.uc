/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class Landscape extends Info
	dependson(LightComponent)
	native(Terrain)
	showcategories(Movement,Collision)
	placeable;

/** Combined material used to render the landscape */
var() Material	LandscapeMaterial;

/** Layers that can be painted on the landscape */
var() array<Name> LayerNames;

/** Map of material instance constants used to for the components,
    with a bitmask representing which layers are required as the key */
var const native map{DWORD,class UMaterialInstanceConstant*} MaterialInstanceConstantMap;

/** The array of LandscapeComponent that are used by the landscape */
var const array<LandscapeComponent>	LandscapeComponents;

/** Array of LandscapeHeightfieldCollisionComponent */
var const array<LandscapeHeightfieldCollisionComponent>	CollisionComponents;


var const native pointer DataInterface{struct FLandscapeDataInterface};

cpptext
{
	// AActor interface
	virtual void UpdateComponentsInternal(UBOOL bCollisionUpdate = FALSE);
	virtual void InitRBPhys();
	virtual void InitRBPhysEditor();

	// UObject interface
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);
	virtual void PostEditMove(UBOOL bFinished);
	virtual void Serialize(FArchive& Ar);
	virtual void BeginDestroy();

	// ALandscape interface
	UBOOL ImportFromOldTerrain(class ATerrain* OldTerrain);
	void Import(INT VertsX, INT VertsY, INT ComponentSizeQuads, INT NumSubsections, INT SubsectionSizeQuads, WORD* HeightData, TArray<FName> ImportLayerNames, BYTE* AlphaDataPointers[] );
	struct FLandscapeDataInterface* GetDataInterface();
}

defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'EditorResources.S_Terrain'
	End Object

	DrawScale3D=(X=128.0,Y=128.0,Z=256.0)
	bEdShouldSnap=True
	bCollideActors=True
	bBlockActors=True
	bWorldGeometry=True
	bStatic=True
	bNoDelete=True
	bHidden=False
}
 