/*=============================================================================
	GenericBrowserType_ApexGenericAsset.uc: Apex integration for Generic Assets.
	Copyright 2008-2009 NVIDIA corporation..
=============================================================================*/

class GenericBrowserType_ApexGenericAsset
	extends GenericBrowserType
	native;

cpptext
{
	virtual void Init();
}

defaultproperties
{
	Description="Apex generic asset"
}
