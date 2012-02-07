/**
 *
 * Widget which looks like a UIOptionList but contains a numeric range for its data instead of a list of strings
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UINumericOptionList extends UIOptionListBase
	native(UIPrivate)
	placeable;

/**
 * The value and range parameters for this numeric optionlist.
 */
var(Data)	UIRangeData		RangeValue;

cpptext
{
protected:
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

	/* === UObject interface === */
	/**
	 * Called when a property value from a member struct or array has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);

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
 * Change the value of this slider at runtime.
 *
 * @param	NewValue			the new value for the slider.
 * @param	bPercentageValue	TRUE indicates that the new value is formatted as a percentage of the total range of this slider.
 *
 * @return	TRUE if the slider's value was changed
 */
native final function bool SetValue( coerce float NewValue, optional bool bPercentageValue );

/**
 * Gets the current value of this slider
 *
 * @param	bPercentageValue	TRUE to format the result as a percentage of the total range of this slider.
 */
native final function float GetValue( optional bool bPercentageValue ) const;

defaultproperties
{
	DataSource=(RequiredFieldType=DATATYPE_RangeProperty)
	RangeValue=(NudgeValue=1.f)
}

