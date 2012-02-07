/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionDepthBiasBlend extends MaterialExpressionTextureSample
	native(Material)
	collapsecategories
	hidecategories(Object);

/** 
 * MaterialExpressionDepthBiasBlend: 
 * Blends the pixel with the destination pixel based on the following formula:
 *	Color = (SrcZ < (DstZ - ((1 - Bias) * BiasScale))) ? SrcColor :
 *			(DstZ < SrcZ) ? DstColor :
 *			Lerp(DstColor, SrcColor, (DstZ - SrcZ) / ((1 - Bias) * BiasScale))
 * for use in a material
 */

/** normalize the depth values to [near,far] -> [0,1]	*/
var()	bool		bNormalize;

/** 
 *	The bias scale value
 */
var()	float		BiasScale;

/** 
 *	The depth bias input
 *	This can be a constant, texture sample, etc.
 *
 *	NOTE: No bias expression indicates a bias of 1.0f.
 */
var ExpressionInput	Bias;

cpptext
{
	/**
	 *	Compile the material expression
	 *
	 *	@param	Compiler	Pointer to the material compiler to use
	 *
	 *	@return	INT			The compiled code index
	 */	
	virtual INT Compile(FMaterialCompiler* Compiler);

	/**
	 *	Get the outputs associated with the expression
	 *
	 *	@param	Outputs		The array that contains the output expression
	 */	
	virtual void GetOutputs(TArray<FExpressionOutput>& Outputs) const;

	/**
	 */	
	virtual INT GetWidth() const;

	/**
	 */	
	virtual FString GetCaption() const;

	/**
	 */	
	virtual INT GetLabelPadding() { return 8; }

	/**
	 * Replaces references to the passed in expression with references to a different expression or NULL.
	 * @param	OldExpression		Expression to find reference to.
	 * @param	NewExpression		Expression to replace reference with.
	 */
	virtual void SwapReferenceTo(UMaterialExpression* OldExpression,UMaterialExpression* NewExpression = NULL);
}

defaultproperties
{
	BiasScale=1.0
	MenuCategories(0)="Obsolete"
}
