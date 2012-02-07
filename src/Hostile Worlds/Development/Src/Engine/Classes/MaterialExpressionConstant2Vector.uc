/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionConstant2Vector extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

var() float	R,
			G;

cpptext
{
	virtual INT Compile(FMaterialCompiler* Compiler);
	virtual FString GetCaption() const;
}

defaultproperties
{
	MenuCategories(0)="Constants"
	MenuCategories(1)="Vectors"
}
