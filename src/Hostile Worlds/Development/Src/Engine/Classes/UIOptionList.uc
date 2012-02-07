/**
 * Option widget that works similar to a read only combobox.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIOptionList extends UIOptionListBase
	native(UIPrivate)
	placeable;

/** Current index in the datastore */
var	transient 			int						CurrentIndex;

/** the list element provider referenced by DataSource */
var	transient	const	UIListElementProvider	DataProvider;

cpptext
{
	/**
	 * Resolves DataSource into the list element provider that it references.
	 */
	virtual void ResolveListElementProvider();

protected:
	/* === UUIOptionList interface === */
	/** @return Returns the number of possible values for the field we are bound to. */
	INT GetNumValues() const;

	/* === UUIOptionListBase interface === */
	/**
	 * Updates the string component with the current value of the optionlist.
	 */
	virtual void UpdateStringComponent();

public:
	/**
	 * @return	TRUE if the user is allowed to decrement the value of this widget
	 */
	virtual UBOOL HasPrevValue() const;
	/**
	 * @return	TRUE if the user is allowed to increment the value of this widget
	 */
	virtual UBOOL HasNextValue() const;

	/** Moves the current selection to the left. */
	virtual void OnMoveSelectionLeft(INT PlayerIndex);

	/** Moves the current selection to the right. */
	virtual void OnMoveSelectionRight(INT PlayerIndex);

	/* === UUIDataStoreSubscriber interface === */
	/**
	 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
	 *
	 * @return	TRUE if this subscriber successfully resolved and applied the updated value.
	 */
	virtual UBOOL RefreshSubscriberValue(INT BindingIndex=INDEX_NONE);

	/* === UUIDataStorePublisher interface === */
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
	virtual UBOOL SaveSubscriberValue(TArray<class UUIDataStore*>& out_BoundDataStores,INT BindingIndex=INDEX_NONE);
}

/* === Natives === */
/**
* @param ListIndex		List index to get the value of.
* @param OutValue		Storage string for the list value
*
* @return Returns TRUE if we were able to get a value, FALSE otherwise
*/
native final function bool GetListValue( int ListIndex, out string OutValue );

/**
 * Decrements the widget to the previous value
 */
native function SetPrevValue();

/**
 * Increments the widget to the next value
 */
native function SetNextValue();

/** Function to determine if the value at the currently selected index is valid */
native function bool IsCurrValueValid();

/** Delegate that can be used to determine if IsCurrValueValid() should succeed or not */
delegate bool OnIsCurrValueValid();

/** @return Returns the current index of the optionbutton. */
native function int GetCurrentIndex() const;

/**
 * Sets a new index for the option button.
 *
 * @param NewIndex		New index for the option button.
 */
native function SetCurrentIndex( int NewIndex );

defaultproperties
{
}

