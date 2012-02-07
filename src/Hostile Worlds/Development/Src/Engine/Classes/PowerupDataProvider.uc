/**
 * Provides data about a powerup currently in inventory.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class PowerupDataProvider extends InventoryDataProvider
	native(inherit);

/**
 * Script hook for preventing a particular child of DataClass from being represented by this dynamic data provider.
 *
 * @param	PotentialDataSourceClass	a child class of DataClass that is being considered as a candidate for binding by this provider.
 *
 * @return	return FALSE to prevent PotentialDataSourceClass's properties from being added to the UI editor's list of bindable
 *			properties for this data provider; also prevents any instances of PotentialDataSourceClass from binding to this provider
 *			at runtime.
 */
event bool IsValidDataSourceClass( class PotentialDataSourceClass )
{
	local bool bResult;

	bResult = Super.IsValidDataSourceClass(PotentialDataSourceClass);
	if ( bResult )
	{
		// weapons are handled by their own provider type
		bResult = !ClassIsChildOf(PotentialDataSourceClass, class'Engine.Weapon');
	}

	return bResult;
}

DefaultProperties
{
	DataClass=class'Engine.Inventory'
}
