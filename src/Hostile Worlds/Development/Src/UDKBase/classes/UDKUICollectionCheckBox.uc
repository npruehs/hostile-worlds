/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Checkbox widget that works with collection datasources.
 */
class UDKUICollectionCheckBox extends UICheckbox
	native
	placeable;

cpptext
{
public:
	/**
	 * Resolves DataSource into the list element provider that it references.
	 */
	void ResolveListElementProvider();

protected:
	/** @return Returns the number of possible values for the field we are bound to. */
	INT GetNumValues();

	/**
	 * @param ListIndex		List index to get the value of.
	 * @param OutValue	Storage string for the list value
	 *
	 * @return Returns TRUE if we were able to get a value, FALSE otherwise
	 */
	UBOOL GetListValue(INT ListIndex, FString &OutValue);

	/**
	 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
	 *
	 * @return	TRUE if this subscriber successfully resolved and applied the updated value.
	 */
	virtual UBOOL RefreshSubscriberValue(INT BindingIndex=-1);

	/**
	 * Resolves this subscriber's data store binding and publishes this subscriber's value to the appropriate data store.
	 *
	 * @param	out_BoundDataStores	contains the array of data stores that widgets have saved values to.  Each widget that
	 *								implements this method should add its resolved data store to this array after data values have been
	 *								published.  Once SaveSubscriberValue has been called on all widgets in a scene, OnCommit will be called
	 *								on all data stores in this array.
	 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
	 *								objects which have multiple data store bindings.  How this parameter is used is up to the
	 *								class which implements this interface, but typically the "primary" data store will be index 0.
	 *
	 * @return	TRUE if the value was successfully published to the data store.
	 */
	virtual UBOOL SaveSubscriberValue(TArray<class UUIDataStore*>& out_BoundDataStores,INT BindingIndex=-1);

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
	virtual void NotifyDataStoreValueUpdated( class UUIDataStore* SourceDataStore, UBOOL bValuesInvalidated, FName PropertyTag, class UUIDataProvider* SourceProvider, INT ArrayIndex );
};

/** the list element provider referenced by DataSource */
var	const	transient			UIListElementProvider	DataProvider;

/**
 * Changed the checked state of this checkbox and activates a checked event.
 *
 * @param	bShouldBeChecked	TRUE to turn the checkbox on, FALSE to turn it off
 * @param	PlayerIndex			the index of the player that generated the call to SetValue; used as the PlayerIndex when activating
 *								UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
native function SetValue( bool bShouldBeChecked, optional int PlayerIndex=INDEX_NONE );

defaultproperties
{
	ValueDataSource=(RequiredFieldType=DATATYPE_Collection)
}
