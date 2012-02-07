/*=============================================================================
	GenericBrowserType_ApexDestructibleAsset.uc: Apex integration for Destructible Assets.
	Copyright 2008-2009 NVIDIA corporation..
=============================================================================*/

class GenericBrowserType_ApexDestructibleAsset
	extends GenericBrowserType
	native;

cpptext
{
	virtual void Init();
}
	
defaultproperties
{
	Description="Apex destructible asset"
}
