/**
 * Provides the UI with read/write access to settings which affect gameplay, such as gameinfo, mutator, and maplist settings.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * @todo - make this class also expose a copy of all settings as an array called "Settings" so that the UI can autogenerate lists
 * of menu options, ala GUIMultiOptionList in UT2004.
 *
 * @fixme - not ready for use yet!
 */
class SessionSettingsProvider extends UISettingsProvider
	within UIDataStore_SessionSettings
	native(inherit)
	abstract;

cpptext
{
	/* === UUIDynamicDataProvider interface === */
	/**
	 * Determines whether the specified class should be represented by this settings data provider.
	 *
	 * @param	PotentialDataSourceClass	a pointer to a UClass that is being considered for binding by this provider.
	 *
	 * @return	TRUE to allow the databinding properties of PotentialDataSourceClass to be displayed in the UI editor's data store browser
	 *			under this data provider.
	 */
	UBOOL IsValidDataSourceClass( UClass* PotentialDataSourceClass );

	/**
	 * Builds an array of classes that are supported by this data provider.  Used in the editor to generate the list of
	 * supported data fields.  Since settings data providers are only created during the game, the editor needs a way to
	 * retrieve the list of data field tags that can be bound without requiring instances of this data provider's DataClass to exist.
	 *
	 * @note: only called in the editor!
	 */
	void GetSupportedClasses( TArray<UClass*>& out_Classes );

	/* === UIDataProvider interface === */
	/**
	 * Gets the list of data fields exposed by this data provider.
	 *
	 * @param	out_Fields	will be filled in with the list of tags which can be used to access data in this data provider.
	 *						Will call GetScriptDataTags to allow script-only child classes to add to this list.
	 */
	virtual void GetSupportedDataFields( TArray<struct FUIDataProviderField>& out_Fields );
}

/**
 * this is the UISettingsClient class that is used as the interface for retrieving metadata from data sources;  only used
 * by C++ to easily determine whether arbitrary classes implement the correct interface for use by this data provider
 */
var	const				private		class<UISettingsClient>		ProviderClientClass;

/**
 * The metaclass for this data provider.  Classes indicate which properties are available for use by settings data stores
 * by marking the property with a keyword.  Must implement the UISettingsClient interface.
 */
var	const							class						ProviderClientMetaClass;

/**
 * the class that will provide the properties and metadata for the settings exposed in this provider.  Set by calling
 * BindProviderInstance.
 */
var	const	transient				class						ProviderClient;

/* == Natives == */
/**
 * Associates this data provider with the specified class.
 *
 * @param	DataSourceClass	a pointer to the specific child of Dataclass that this data provider should present data for.
 *
 * @return	TRUE if the class specified was successfully associated with this data provider.  FALSE if the object specified
 *			wasn't of the correct type or was otherwise invalid.
 */
native final function bool BindProviderClient( class DataSourceClass );

/**
 * Clears the reference to the class associated with this data provider.
 *
 * @return	TRUE if the class reference was successfully cleared.
 */
native final function bool UnbindProviderClient();

/* == Events == */

/**
 * Called once BindProviderInstance has successfully verified that DataSourceInstance is of the correct type.  Child classes
 * can override this function to handle storing the reference, for example.
 */
event ProviderClientBound( class DataSourceClass );

/**
 * Called immediately after this data provider's DataSource is disassociated from this data provider.
 */
event ProviderClientUnbound( class DataSourceClass );

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
	return true;
}

/**
 * Allows the data provider to clear any references that would interfere with garbage collection.
 */
function bool CleanupDataProvider()
{
	if ( ProviderClient != None )
	{
		return UnbindProviderClient();
	}

	return false;
}

DefaultProperties
{
	ProviderTag=SessionSettingsProvider

	ProviderClientClass=class'Engine.UISettingsClient'
}

