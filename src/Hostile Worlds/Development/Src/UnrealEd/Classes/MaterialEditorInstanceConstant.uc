/**
 * MaterialEditorInstanceConstant.uc: This class is used by the material instance editor to hold a set of inherited parameters which are then pushed to a material instance.
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MaterialEditorInstanceConstant extends Object
	native
	hidecategories(Object)
	dependson(UnrealEdTypes)
	collapsecategories;

struct native EditorParameterValue
{
	var() bool			bOverride;
	var() name			ParameterName;
	var   Guid			ExpressionId;
};

struct native EditorVectorParameterValue extends EditorParameterValue
{
	var() LinearColor	ParameterValue;
};

struct native EditorScalarParameterValue extends EditorParameterValue
{
	var() float		ParameterValue;
};

struct native EditorTextureParameterValue extends EditorParameterValue
{
    var() Texture	ParameterValue;
};

struct native EditorFontParameterValue extends EditorParameterValue
{
    var() Font		FontValue;
	var() int		FontPage;
};

struct native EditorStaticSwitchParameterValue extends EditorParameterValue
{
    var() bool		ParameterValue;

structcpptext
{
	/** Constructor */
	FEditorStaticSwitchParameterValue(const FStaticSwitchParameter& InParameter) : ParameterValue(InParameter.Value)
	{
		//initialize base class members
		bOverride = InParameter.bOverride;
		ParameterName = InParameter.ParameterName;
		ExpressionId = InParameter.ExpressionGUID;
	}
}
};

struct native ComponentMaskParameter
{
	var() bool R;
	var() bool G;
	var() bool B;
	var() bool A;

structcpptext
{
	/** Constructor */
	FComponentMaskParameter(UBOOL InR, UBOOL InG, UBOOL InB, UBOOL InA) :
		R(InR),
		G(InG),
		B(InB),
		A(InA)
	{
	}
}
};

struct native EditorStaticComponentMaskParameterValue extends EditorParameterValue
{
    var() ComponentMaskParameter		ParameterValue;

structcpptext
{
	/** Constructor */
	FEditorStaticComponentMaskParameterValue(const FStaticComponentMaskParameter& InParameter) : ParameterValue(InParameter.R, InParameter.G, InParameter.B, InParameter.A)
	{
		//initialize base class members
		bOverride = InParameter.bOverride;
		ParameterName = InParameter.ParameterName;
		ExpressionId = InParameter.ExpressionGUID;
	}
}
};

/** Physical material to use for this graphics material. Used for sounds, effects etc.*/
var() PhysicalMaterial									PhysMaterial;

/** Physical material mask settings to use. */
var() PhysicalMaterialMaskSettings PhysicalMaterialMask;

// since the Parent may point across levels and the property editor needs to import this text, it must be marked crosslevel so it doesn't set itself to NULL in FindImportedObject
var() crosslevelpassive MaterialInterface				Parent;
var() array<EditorVectorParameterValue>					VectorParameterValues;
var() array<EditorScalarParameterValue>					ScalarParameterValues;
var() array<EditorTextureParameterValue>				TextureParameterValues;
var() array<EditorFontParameterValue>					FontParameterValues;
var() array<EditorStaticSwitchParameterValue>			StaticSwitchParameterValues;
var() array<EditorStaticComponentMaskParameterValue>	StaticComponentMaskParameterValues;
var	  MaterialInstanceConstant							SourceInstance;
var const transient duplicatetransient	  array<Guid>	VisibleExpressions;
var(Mobile) texture										FlattenedTexture;

/** The Lightmass override settings for this object. */
var(Lightmass)	LightmassParameterizedMaterialSettings	LightmassSettings;

cpptext
{
	// UObject interface.
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/** Regenerates the parameter arrays. */
	void RegenerateArrays();

	/** Copies the parameter array values back to the source instance. */
	void CopyToSourceInstance();

	/** Copies static parameters to the source instance, which will be marked dirty if a compile was necessary */
	void CopyStaticParametersToSourceInstance();

	/** 
	 * Sets the source instance for this object and regenerates arrays. 
	 *
	 * @param MaterialInterface		Instance to use as the source for this material editor instance.
	 */
	void SetSourceInstance(UMaterialInstanceConstant* MaterialInterface);
}
