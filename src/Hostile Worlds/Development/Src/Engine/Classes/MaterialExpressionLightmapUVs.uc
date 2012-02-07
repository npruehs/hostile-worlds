/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 *	A material expression that routes LightmapUVs to the material.
 */
class MaterialExpressionLightmapUVs extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

cpptext
{
	// UMaterialExpression interface.
    /**
	 * Creates the new shader code chunk needed for the Abs expression
	 *
	 * @param	Compiler - Material compiler that knows how to handle this expression
	 * @return	Index to the new FMaterialCompiler::CodeChunk entry for this expression
	 */	
	virtual INT Compile( FMaterialCompiler* Compiler );

	/**
	 *	Get the outputs supported by this expression.
	 *
	 *	@param	Outputs		The TArray of outputs to fill in.
	 */
	virtual void GetOutputs(TArray<FExpressionOutput>& Outputs) const;

	/**
	 * Textual description for this material expression
	 *
	 * @return	Caption text
	 */	
	virtual FString GetCaption() const;
}

defaultproperties
{
	bShowOutputNameOnPin=true
	bHidePreviewWindow=true

	MenuCategories(0)="Coordinates"
}
