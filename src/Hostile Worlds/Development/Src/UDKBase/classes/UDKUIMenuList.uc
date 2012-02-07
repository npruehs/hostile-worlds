/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * List widget used in many of the UT menus that renders using z-ordering to simulate a 'circular' list.
 */
class UDKUIMenuList extends UDKSimpleList
	native
	DontAutoCollapseCategories(Data)
	implements(UIDataStoreSubscriber);

/** The data store that this list is bound to */
var(Data)						UIDataStoreBinding		DataSource;

/** the list element provider referenced by DataSource */
var	const	transient			UIListElementProvider	DataProvider;

/**
 * The data source that this list will get and save its currently selected indices from.
 */
var(Data)	editconst private		UIDataStoreBinding		SelectedIndexDataSource;

/** Current items of the list, these index into the list dataprovider. */
var transient array<int> MenuListItems;

/** Whether or not we are currently animating. */
var bool bIsRotating;

/** Time we started rotating the items in this widget. */
var float StartRotationTime;

/**
 * Called when the user presses Enter (or any other action bound to UIKey_SubmitListSelection) while this list has focus.
 *
 * @param	Sender	the list that is submitting the selection
 */
delegate OnSubmitSelection( UIObject Sender, optional int PlayerIndex=GetBestPlayerIndex() );

event PostInitialize()
{
	OnSubmitSelection = none;
	OnValueChanged = none;

	Super.PostInitialize();
}

/** Regenerates the list of options for this menu list. */
native function RegenerateOptions();

/** Bunch of functions to mimic simple UIList functionality. */
/** @return Returns the currently selected item. */
function int GetCurrentItem()
{
	return MenuListItems[Selection];
}

/** Sets the currently selected item. */
function SetIndex(int NewIndex)
{
	SelectItem(NewIndex);
}

/** Callback for when the user has picked a list item. */
function ItemChosen(int PlayerIndex)
{
	Super.ItemChosen(PlayerIndex);
	OnSubmitSelection(self, PlayerIndex);
}

event SelectItem(int NewSelection)
{
	local bool bSendNotification;

	// Only send notification if the selection changes.
	bSendNotification = (Selection != NewSelection);

	Super.SelectItem(NewSelection);

	if ( bSendNotification )
	{
		OnValueChanged(self, GetBestPlayerIndex());
	}
}

/**
 * Gets the cell field value for a specified list and list index.
 *
 * @param InList		List to get the cell field value for.
 * @param InCellTag		Tag to get the value for.
 * @param InListIndex	Index to get the value for.
 * @param OutValue		Storage variable for the final value.
 */
static function native bool GetCellFieldValue(UIObject InList, name InCellTag, int InListIndex, out UIProviderFieldValue OutValue);

/**
 * Gets the cell field value for a specified list and list index.
 *
 * @param InList		List to get the cell field value for.
 * @param InCellTag		Tag to get the value for.
 * @param InListIndex	Index to get the value for.
 * @param OutValue		Storage variable for the final value.
 */
static final function bool GetCellFieldString(UIObject InList, name InCellTag, int InListIndex, out string OutValue)
{
	local bool bResult;
	local UIProviderFieldValue FieldValue;

	bResult = false;

	if(GetCellFieldValue(InList, InCellTag, InListIndex, FieldValue) == true)
	{
		OutValue = FieldValue.StringValue;
		bResult = true;
	}
	//`log("GCFS" @ `showobj(InList)@`showvar(InCellTag)@`showvar(InListIndex)@`showvar(OutValue)@`showvar(bResult),,'SBDEBUG');

	return bResult;
}

/** returns the first list index the has the specified value for the specified cell, or INDEX_NONE if it couldn't be found */
native static final function int FindCellFieldString(UIObject InObject, name InCellTag, string FindValue, optional bool bCaseSensitive);


/** UIDataSourceSubscriber interface */
/**
 * Sets the data store binding for this object to the text specified.
 *
 * @param	MarkupText			a markup string which resolves to data exposed by a data store.  The expected format is:
 *								<DataStoreTag:DataFieldTag>
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 */
native final virtual function SetDataStoreBinding( string MarkupText, optional int BindingIndex=INDEX_NONE );

/**
 * Retrieves the markup string corresponding to the data store that this object is bound to.
 *
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 *
 * @return	a datastore markup string which resolves to the datastore field that this object is bound to, in the format:
 *			<DataStoreTag:DataFieldTag>
 */
native final virtual function string GetDataStoreBinding( optional int BindingIndex=INDEX_NONE ) const;

/**
 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
 *
 * @return	TRUE if this subscriber successfully resolved and applied the updated value.
 */
native final virtual function bool RefreshSubscriberValue( optional int BindingIndex=INDEX_NONE );

/**
 * Retrieves the list of data stores bound by this subscriber.
 *
 * @param	out_BoundDataStores		receives the array of data stores that subscriber is bound to.
 */
native final virtual function GetBoundDataStores( out array<UIDataStore> out_BoundDataStores );

/**
 * Notifies this subscriber to unbind itself from all bound data stores
 */
native final virtual function ClearBoundDataStores();

/**
 * Handler for the UIDataStore.OnDataStoreValueUpdated delegate.  Used by data stores to indicate that some data provided by the data
 * has changed.  Subscribers should use this function to refresh any data store values being displayed with the updated value.
 * notify subscribers when they should refresh their values from this data store.
 *
 * @param	SourceDataStore		the data store that generated the refresh notification; useful for subscribers with multiple data store
 *								bindings, to tell which data store sent the notification.
 * @param	PropertyTag			the tag associated with the data field that was updated; Subscribers can use this tag to determine whether
 *								there is any need to refresh their data values.
 * @param	SourceProvider		for data stores which contain nested providers, the provider that contains the data which changed.
 * @param	ArrayIndex			for collection fields, indicates which element was changed.  value of INDEX_NONE indicates not an array
 *								or that the entire array was updated.
 */
native function NotifyDataStoreValueUpdated( UIDataStore SourceDataStore, bool bValuesInvalidated, name PropertyTag, UIDataProvider SourceProvider, int ArrayIndex );

defaultproperties
{
	DataSource=(RequiredFieldType=DATATYPE_Collection)
	bHotTracking=false
}
