/*=============================================================================
	ApexAsset.uc: Wrapper for an NxApexAsset, an APEX base class. Apex Asset
	Copyright 2008-2009 NVIDIA corporation.
=============================================================================*/

/****
* This is the base class for ApexAssets
*
**/
class ApexAsset extends Object
	hidecategories(Object)
	native(Mesh);

var native transient const array<ApexComponentBase> ApexComponents;

cpptext
{
	public:
		/** Display strings for the generic browser */
		virtual	TArray<FString>	GetGenericBrowserInfo();

	   	/** virtual method to return the number of materials used by this asset */
		virtual UINT                GetNumMaterials(void) const   { return 0; }
		/** virtual method to return a particular material by index */
		virtual UMaterialInterface *GetMaterial(UINT Index) const { return 0; }
		/** Returns the default NxParameterized::Interface for this asset. */
		virtual void * GetNxParameterized(void) { return 0; };

	protected:
		// Called when the Asset gets rebuilt (in editor only).
		void OnApexAssetLost(void);
		void OnApexAssetReset(void);
}

defaultproperties
{
}
