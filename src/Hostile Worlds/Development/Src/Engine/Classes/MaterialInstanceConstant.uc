/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MaterialInstanceConstant extends MaterialInstance
	native(Material)
	hidecategories(Object)
	collapsecategories;


struct native FontParameterValue
{
	var() name		ParameterName;
	var() Font		FontValue;
	var() int		FontPage;
	var	  guid		ExpressionGUID;
};

struct native ScalarParameterValue
{
	var() name	ParameterName;
	var() float	ParameterValue;
	var	  guid	ExpressionGUID;
};

struct native TextureParameterValue
{
	var() name		ParameterName;
	var() Texture	ParameterValue;
	var	  guid		ExpressionGUID;
};

struct native VectorParameterValue
{
	var() name			ParameterName;
	var() LinearColor	ParameterValue;
	var	  guid			ExpressionGUID;
};



var() const array<FontParameterValue>		FontParameterValues;
var() const array<ScalarParameterValue>		ScalarParameterValues;
var() const array<TextureParameterValue>	TextureParameterValues;
var() const array<VectorParameterValue>		VectorParameterValues;


cpptext
{
	// Constructor.
	UMaterialInstanceConstant();

	// UMaterialInstance interface.
	virtual void InitResources();

	/**
	* Checks if any of the static parameter values are outdated based on what they reference (eg a normalmap has changed format)
	*
	* @param	EditorParameters	The new static parameters. 
	*/
	virtual void CheckStaticParameterValues(FStaticParameterSet* EditorParameters);

	// UMaterialInterface interface.
	virtual UBOOL GetFontParameterValue(FName ParameterName,class UFont*& OutFontValue, INT& OutFontPage);
	virtual UBOOL GetScalarParameterValue(FName ParameterName,FLOAT& OutValue);
	virtual UBOOL GetTextureParameterValue(FName ParameterName,class UTexture*& OutValue);
	virtual UBOOL GetVectorParameterValue(FName ParameterName,FLinearColor& OutValue);

	// UObject interface.
	virtual void PostLoad();
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/**
	* Refreshes parameter names using the stored reference to the expression object for the parameter.
	*/
	virtual void UpdateParameterNames();

	/**
	 *	Cleanup the TextureParameter lists in the instance
	 *
	 *	@param	InRefdTextureParamsMap		Map of actual TextureParams used by the parent.
	 *
	 *	NOTE: This is intended to be called only when cooking for stripped platforms!
	 */
	virtual void CleanupTextureParameterReferences(const TMap<FName,UTexture*>& InRefdTextureParamsMap);
};

// SetParent - Updates the parent.

native function SetParent(MaterialInterface NewParent);

// Set*ParameterValue - Updates the entry in ParameterValues for the named parameter, or adds a new entry.

native function SetScalarParameterValue(name ParameterName, float Value);
native function SetTextureParameterValue(name ParameterName, Texture Value);
native function SetVectorParameterValue(name ParameterName, const out LinearColor Value);

/**
* Sets the value of the given font parameter.  
*
* @param	ParameterName	The name of the font parameter
* @param	OutFontValue	New font value to set for this MIC
* @param	OutFontPage		New font page value to set for this MIC
*/
native function SetFontParameterValue(name ParameterName, Font FontValue, int FontPage);


/** Removes all parameter values */
native function ClearParameterValues();


defaultproperties
{

}