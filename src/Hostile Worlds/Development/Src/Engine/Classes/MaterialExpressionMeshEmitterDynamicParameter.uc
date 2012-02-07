/**
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*/
class MaterialExpressionMeshEmitterDynamicParameter extends MaterialExpressionDynamicParameter
	native(Material)
	collapsecategories
	hidecategories(Object);

cpptext
{
	virtual INT Compile(FMaterialCompiler* Compiler);
	virtual FString GetCaption() const;
}

defaultproperties
{
}
