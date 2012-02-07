`include(UIDev.uci)

/**
 * A specialized list class which interacts with a special UI sequence object to provide the designer with a very simple,
 * high-level view of the various paths into and out of a scene.  Each element in this list will correspond to a selection
 * that takes the user to a different scene.  When one of these lists are added to a scene, it will automatically create
 * a special sequence object that generates an output link for each item in the list.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UINavigationList extends UIList
	native(inherit)
	`devplaceable;

/**
 * @return	a reference to the gear-specific static game resource data store.
 */
static final function UIDataStore_GameResource GetGameResourceDataStore()
{
	return UIDataStore_GameResource(StaticResolveDataStore(class'UIDataStore_GameResource'.default.Tag));
}

/**
 * Wrapper for getting the path name for the scene associated with the currently selected list item.
 */
function string GetSelectedScenePath()
{
	return GetScenePathAtIndex(Index);
}

/**
 * Wrapper for getting the ItemTag for the currently selected list item.
 */
function string GetSelectedItemTag()
{
	return GetItemTagAtIndex(Index);
}

/**
 * Gets the item tag for the navigaiton item at the specified index.
 *
 * @param	DesiredIndex	the index of the element to retrieve the item tag for
 *
 * @return	the path name of the scene associated with the navigation item at the specified index, or an empty string if the specified
 *			index is invalid or the list isn't bound to the GameResources data store.
 */
function string GetItemTagAtIndex( int DesiredIndex )
{
	local string ItemTag, ProviderAccessTag, MarkupString;
	local int pos, SelectedItem;
	local UIDataStore_GameResource GameResourceDS;
	local UIProviderScriptFieldValue ScenePathValue;

	if ( DesiredIndex >= 0 && DesiredIndex < GetItemCount() )
	{
		SelectedItem = Items[DesiredIndex];
		if ( SelectedItem != INDEX_NONE )
		{
			// at this point, MarkupString looks something like:
			// NavigationMenuItems;SceneName.NavigationItems
			MarkupString = string(DataSource.DataStoreField);
			pos = InStr(MarkupString, ".");
			if ( pos != INDEX_NONE )
			{
				// pull off the provider reference
				ProviderAccessTag = Left(DataSource.DataStoreField, pos);

				// then build the appropriate string for accessing the data we're looking for
				// it will need to look like NavigationItems;0.ItemTag
				MarkupString = Mid(MarkupString, pos+1) $ ";" $ SelectedItem $ ".ItemTag";

				// now retrieve the value of this data field from the resource data store.
				GameResourceDS = GetGameResourceDataStore();
				if ( GameResourceDS.GetProviderFieldValue(name(ProviderAccessTag), name(MarkupString), INDEX_NONE, ScenePathValue) )
				{
					ItemTag = ScenePathValue.StringValue;
				}
			}
		}
	}

	return ItemTag;
}

/**
 * Gets the path name of the scene associated with a list element.
 *
 * @param	DesiredIndex	the index of the element to retrieve a scene path name for.
 *
 * @return	the path name of the scene associated with the navigation item at the specified index, or an empty string if the specified
 *			index is invalid or the list isn't bound to the GameResources data store.
 */
function string GetScenePathAtIndex( int DesiredIndex )
{
	local string ScenePath, ProviderAccessTag, MarkupString;
	local int pos, SelectedItem;
	local UIDataStore_GameResource GameResourceDS;
	local UIProviderScriptFieldValue ScenePathValue;

	if ( DesiredIndex >= 0 && DesiredIndex < GetItemCount() )
	{
		SelectedItem = Items[DesiredIndex];
		if ( SelectedItem != INDEX_NONE )
		{
			// at this point, MarkupString looks something like:
			// NavigationMenuItems;SceneName.NavigationItems
			MarkupString = string(DataSource.DataStoreField);
			pos = InStr(MarkupString, ".");
			if ( pos != INDEX_NONE )
			{
				// pull off the provider reference
				ProviderAccessTag = Left(DataSource.DataStoreField, pos);

				// then build the appropriate string for accessing the data we're looking for
				// it will need to look like NavigationItems;0.DestinationScenePath
				MarkupString = Mid(MarkupString, pos+1) $ ";" $ SelectedItem $ ".DestinationScenePath";

				// now retrieve the value of this data field from the resource data store.
				GameResourceDS = GetGameResourceDataStore();
				if ( GameResourceDS.GetProviderFieldValue(name(ProviderAccessTag), name(MarkupString), INDEX_NONE, ScenePathValue) )
				{
					ScenePath = ScenePathValue.StringValue;
				}
			}
		}
	}

	return ScenePath;
}

DefaultProperties
{
	Position={(	Value[UIFACE_Right]=300,ScaleType[UIFACE_Right]=EVALPOS_PixelOwner,
				Value[UIFACE_Bottom]=400,ScaleType[UIFACE_Bottom]=EVALPOS_PixelOwner)}

	Begin Object Name=ListPresentationComponent
		bDisplayColumnHeaders=false
	End Object
}
