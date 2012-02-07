/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for mapping properties in an Settings
 * object to something that the UI system can consume.
 */
class UIDataProvider_Settings extends UIDynamicDataProvider
	native(inherit)
	transient;

/** Holds the settings object that will be exposed to the UI */
var Settings Settings;

/** Keeps a list of providers for each settings id */
struct native SettingsArrayProvider
{
	/** The settings id that this provider is for */
	var int SettingsId;
	/** Cached to avoid extra look ups */
	var name SettingsName;
	/** The provider object to expose the data with */
	var UIDataProvider_SettingsArray Provider;
};

/** The list of mappings from settings id to their provider */
var array<SettingsArrayProvider> SettingsArrayProviders;

/** Whether this provider is a row in a list (removes array handling) */
var bool bIsAListRow;

cpptext
{
	/**
	 * Resolves the value of the data field specified and stores it in the output parameter.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	out_FieldValue	receives the resolved value for the property specified.
	 *							@see GetDataStoreValue for additional notes
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL GetFieldValue(const FString& FieldName,FUIProviderFieldValue& out_FieldValue,INT ArrayIndex = INDEX_NONE);

	/**
	 * Resolves the value of the data field specified and stores the value specified to the appropriate location for that field.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	FieldValue		the value to store for the property specified.
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL SetFieldValue(const FString& FieldName,const FUIProviderScriptFieldValue& FieldValue,INT ArrayIndex = INDEX_NONE);

	/**
	 * Generates filler data for a given tag. Uses the OnlineDataType to determine
	 * what the hardcoded filler data will look like
	 *
 	 * @param DataTag the tag to generate filler data for
 	 *
	 * @return a string containing example data
	 */
	virtual FString GenerateFillerData(const FString& DataTag);

	/**
	 * Builds a list of available fields from the array of properties in the
	 * game settings object
	 *
	 * @param OutFields	out value that receives the list of exposed properties
	 */
	virtual void GetSupportedDataFields(TArray<FUIDataProviderField>& OutFields);

	/**
	 * Gets the list of data fields (and their localized friendly name) for the fields exposed this provider.
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param	out_CellTags	receives the name/friendly name pairs for all data fields in this provider.
	 */
	virtual void GetElementCellTags( FName FieldName, TMap<FName,FString>& out_CellTags );

	/**
	 * Resolves PropertyName into a list element provider that provides list elements for the property specified.
	 *
	 * @param	PropertyName	the name of the property that corresponds to a list element provider supported by this data store
	 *
	 * @return	a pointer to an interface for retrieving list elements associated with the data specified, or NULL if
	 *			there is no list element provider associated with the specified property.
	 */
	virtual TScriptInterface<class IUIListElementProvider> ResolveListElementProvider(const FString& PropertyName);

	/**
	 * Binds the new settings object to this provider. Sets the type to instance
	 *
	 * @param NewSettings the new object to bind
	 * @param bIsInList whether to use list handling or not
	 *
	 * @return TRUE if bound ok, FALSE otherwise
	 */
	UBOOL BindSettings(USettings* NewSettings,UBOOL bIsInList = FALSE);
}

/**
 * Called once BindProviderInstance has successfully verified that DataSourceInstance is of the correct type.  Child classes
 * can override this function to handle storing the reference, for example.
 */
event ProviderInstanceBound( Object DataSourceInstance )
{
	local Settings SettingsObject;

	Super.ProviderInstanceBound(DataSourceInstance);

	//@todo ronp - might need to call NotifyPropertyChanged on the DataProvider_Settings array object, actually
	SettingsObject = Settings(DataSourceInstance);
	if ( SettingsObject != None )
	{
		SettingsObject.NotifySettingValueUpdated = OnSettingValueUpdated;
		SettingsObject.NotifyPropertyValueUpdated = OnSettingValueUpdated;
	}
}

/**
 * Called immediately after this data provider's DataSource is disassociated from this data provider.
 */
event ProviderInstanceUnbound( Object DataSourceInstance )
{
	local Settings SettingsObject;

	Super.ProviderInstanceBound(DataSourceInstance);

	SettingsObject = Settings(DataSourceInstance);
	if ( SettingsObject != None )
	{
		if ( SettingsObject.NotifySettingValueUpdated == OnSettingValueUpdated )
		{
			SettingsObject.NotifySettingValueUpdated = None;
		}
		if ( SettingsObject.NotifyPropertyValueUpdated == OnSettingValueUpdated )
		{
			SettingsObject.NotifyPropertyValueUpdated = None;
		}
	}
}

/**
 * Called when a setting or property which is bound to one of our array providers is updated.
 *
 * @param	SourceProvider		the data provider that generated the notification
 * @param	PropTag				the property that changed
 */
function ArrayProviderPropertyChanged( UIDataProvider SourceProvider, optional name PropTag )
{
	local int Index;
	local delegate<OnDataProviderPropertyChange> Subscriber;

	// Loop through and notify all subscribed delegates
	for (Index = 0; Index < ProviderChangedNotifies.Length; Index++)
	{
		Subscriber = ProviderChangedNotifies[Index];
		Subscriber(SourceProvider, PropTag);
	}
}


/**
 * Handler for the OnDataProviderPropertyChange delegate in our internal array providers.  Determines which provider sent the update
 * and propagates that update to this provider's own list of listeners.
 *
 * @param	SettingName		the name of the setting that was changed.
 */
function OnSettingValueUpdated( name SettingName )
{
	local int ProviderIdx;
	local UIDataProvider_SettingsArray ArrayProvider;

	if ( !bIsAListRow )
	{
		for ( ProviderIdx = 0; ProviderIdx < SettingsArrayProviders.Length; ProviderIdx++ )
		{
			if ( SettingName == SettingsArrayProviders[ProviderIdx].SettingsName )
			{
				ArrayProvider = SettingsArrayProviders[ProviderIdx].Provider;
				ArrayProviderPropertyChanged(ArrayProvider, SettingName);
				break;
			}
		}
	}
	else
	{
		NotifyPropertyChanged(SettingName);
	}
}

defaultproperties
{
	WriteAccessType=ACCESS_WriteAll
}
