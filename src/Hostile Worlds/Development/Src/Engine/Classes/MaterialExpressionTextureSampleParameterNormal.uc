/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionTextureSampleParameterNormal extends MaterialExpressionTextureSampleParameter
	native(Material)
	collapsecategories
	hidecategories(Object);

//the override that will be set when this expression is being compiled from a static permutation
var const native transient pointer InstanceOverride{const FNormalParameter};

cpptext
{
	virtual INT Compile(FMaterialCompiler* Compiler);
	virtual FString GetCaption() const;
	virtual UBOOL TextureIsValid( UTexture* InTexture );
	virtual const TCHAR* GetRequirements();
	
	/**
	 *	Sets the default texture if none is set
	 */
	virtual void SetDefaultTexture();

	/**
	 *	Since there are no input expressions, the ClearInputExpressions function is not required.
	 */
}

defaultproperties
{
	Texture=Texture2D'EngineMaterials.DefaultNormal'
	bUsedByStaticParameterSet=true
	MenuCategories(0)="Texture"
	MenuCategories(1)="Parameters"
}
