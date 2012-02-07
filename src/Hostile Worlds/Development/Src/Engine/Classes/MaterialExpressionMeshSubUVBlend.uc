/**
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*/
class MaterialExpressionMeshSubUVBlend extends MaterialExpressionMeshSubUV
	native(Material);

cpptext
{
	virtual INT Compile(FMaterialCompiler* Compiler);
	virtual FString GetCaption() const;
}

defaultproperties
{
	MenuCategories(0)="Texture"
	MenuCategories(1)="Particles"
}
