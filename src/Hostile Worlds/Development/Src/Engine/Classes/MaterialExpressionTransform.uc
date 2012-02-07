/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionTransform extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

/** input expression for this transform */
var ExpressionInput	Input;

/** Source coordinate space of the vector */
var() const enum EMaterialVectorCoordTransformSource
{
	TRANSFORMSOURCE_World,
	TRANSFORMSOURCE_Local,
	TRANSFORMSOURCE_Tangent
} TransformSourceType;

/** Destination coordinate space of the vector */
var() const enum EMaterialVectorCoordTransform
{
	TRANSFORM_World,
	TRANSFORM_View,
	TRANSFORM_Local,
	TRANSFORM_Tangent
} TransformType;

cpptext
{
	virtual INT Compile(FMaterialCompiler* Compiler);
	virtual FString GetCaption() const;

	/**
	 * Replaces references to the passed in expression with references to a different expression or NULL.
	 * @param	OldExpression		Expression to find reference to.
	 * @param	NewExpression		Expression to replace reference with.
	 */
	virtual void SwapReferenceTo(UMaterialExpression* OldExpression,UMaterialExpression* NewExpression = NULL);
}

defaultproperties
{
	MenuCategories(0)="VectorOps"
	TransformSourceType=TRANSFORMSOURCE_Tangent
}
