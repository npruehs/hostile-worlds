/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Extended version of combo box for UT3.
 */
class UDKUIComboBox extends UIComboBox
	native;

var name	ToggleButtonStyleName;
var name	ToggleButtonCheckedStyleName;
var name	EditboxBGStyleName;
var name	ListBackgroundStyleName;

cpptext
{
	/* === UUIComboBox interface === */
	/**
	 * Called whenever the selected item is modified.  Activates the SliderValueChanged kismet event and calls the OnValueChanged
	 * delegate.
	 *
	 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
	 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
	 * @param	NotifyFlags		optional parameter for individual widgets to use for passing additional information about the notification.
	 */
	virtual void NotifyValueChanged( INT PlayerIndex=INDEX_NONE, INT NotifyFlags=0 );

	/* === UUIScreenObject interface === */
	/**
	 * Called when the currently active skin has been changed.  Reapplies this widget's style and propagates
	 * the notification to all children.
	 */
	virtual void NotifyActiveSkinChanged()
	{
		Super::NotifyActiveSkinChanged();

		// reapply the styles to the combobox
		SetupChildStyles();
	}

	/**
	 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
	 *
	 * @param	BindingIndex		indicates which data store binding should be modified.  Valid values and their meanings are:
	 *									-1:	all data sources
	 *									0:	list data source
	 *									1:	caption data source
	 *
	 * @return	TRUE if this subscriber successfully resolved and applied the updated value.
	 */
	virtual UBOOL RefreshSubscriberValue(INT BindingIndex=INDEX_NONE);

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
	virtual UBOOL SaveSubscriberValue( TArray<class UUIDataStore*>& out_BoundDataStores, INT BindingIndex=INDEX_NONE );
}

/** Called after initialization. */
event Initialized()
{
	Super.Initialized();

	// Make it so the list can't save out its value
	UDKUIList(ComboList).bAllowSaving=false;

	// Set subwidget styles.
	SetupChildStyles();
}

/**
 * Called immediately after a child has been added to this screen object.
 *
 * @param	WidgetOwner		the screen object that the NewChild was added as a child for
 * @param	NewChild		the widget that was added
 */
event AddedChild( UIScreenObject WidgetOwner, UIObject NewChild )
{
	Super.AddedChild( WidgetOwner, NewChild );

	if ( WidgetOwner == Self && NewChild != None && NewChild == ComboList )
	{
		// we want the list to only be as wide as the editbox
		SetListDocking(true);
	}
}


/** Initializes styles for child widgets. */
native function SetupChildStyles();

/**
 * @returns the Selection Index of the currently selected list item
 */
function Int GetSelectionIndex()
{
	return ( ComboList != none ) ? ComboList.Index : -1;
}

/**
 * Sets the current index for the list.
 *
 * @param	NewIndex		The new index to select
 */
function SetSelectionIndex(int NewIndex)
{
	if ( ComboList != none && NewIndex >= 0 && NewIndex < ComboList.GetItemCount() )
	{
		ComboList.SetIndex(NewIndex);
	}
}



/**
 * Sets the currently selected item.
 *
 * @param ItemIndex		Not the list index but the index of the item which is a value of the Items array.
 */
function SetSelectedItem(int ItemIndex)
{
	local int ItemIter;

	for(ItemIter=0; ItemIter<ComboList.Items.length; ItemIter++)
	{
		if(ComboList.Items[ItemIter]==ItemIndex)
		{
			ComboList.SetIndex(ItemIter);
			break;
		}
	}
}


defaultproperties
{
	ComboListClass=class'UDKBase.UDKUIList'
	ToggleButtonStyleName="ComboBoxUp"
	ToggleButtonCheckedStyleName="ComboBoxDown"
	EditboxBGStyleName="DefaultEditboxImageStyle"
	ListBackgroundStyleName="ComboListBackgroundStyle"
}
