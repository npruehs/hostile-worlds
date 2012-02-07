/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for retrieving the friends list from the online
 * subsystem and populating the UI with that data.
 */
class UIDataStore_OnlinePlayerData extends UIDataStore_Remote
	native(inherit)
	implements(UIListElementProvider)
	config(Engine)
	transient;

/** Provides access to the player's online friends list */
var UIDataProvider_OnlineFriends FriendsProvider;

/** Holds the player controller that this data store is associated with */
var int PlayerControllerId;

/** The online nick name for the player */
var string PlayerNick;

/** The number of new downloads for this player */
var int NumNewDownloads;

/** The total number of downloads for this player */
var int NumTotalDownloads;

/** The name of the OnlineProfileSettings class to use as the default */
var config string ProfileSettingsClassName;

/** The class that should be created when a player is bound to this data store */
var class<OnlineProfileSettings> ProfileSettingsClass;

/** Provides access to the player's profile data */
var UIDataProvider_OnlineProfileSettings ProfileProvider;

/** The name of the OnlinePlayerStorage class to use as the default */
var config string PlayerStorageClassName;

/** The class that should be created when a player is bound to this data store */
var class<OnlinePlayerStorage> PlayerStorageClass;

/** Provides access to the player's storage data */
var UIDataProvider_OnlinePlayerStorage StorageProvider;

/** Provides access to any friend messages */
var UIDataProvider_OnlineFriendMessages FriendMessagesProvider;

/** Provides access to the list of achievements for this player */
var	UIDataProvider_PlayerAchievements AchievementsProvider;

/** The name of the data provider class to use as the default for friends */
var config string FriendsProviderClassName;

/** The class that should be created when a player is bound to this data store */
var class<UIDataProvider_OnlineFriends> FriendsProviderClass;

/** The name of the data provider class to use as the default for messages */
var config string FriendMessagesProviderClassName;

/** The class that should be created when a player is bound to this data store */
var class<UIDataProvider_OnlineFriendMessages> FriendMessagesProviderClass;

/** The name of the data provider class to use as the default for enumerating achievements */
var config string AchievementsProviderClassName;

/** The class that should be created when a player is bound to this data store for providing achievements data to the UI */
var class<UIDataProvider_PlayerAchievements> AchievementsProviderClass;

/** The name of the data provider class to use as the default for party chat members */
var config string PartyChatProviderClassName;

/** The class that should be created when a player is bound to this data store */
var class<UIDataProvider_OnlinePartyChatList> PartyChatProviderClass;

/** The provider instance for the party chat data */
var UIDataProvider_OnlinePartyChatList PartyChatProvider;

cpptext
{
/* === UIDataStore interface === */

	/**
	 * Loads the game specific OnlineProfileSettings class
	 */
	virtual void LoadDependentClasses(void);

	/**
	 * Creates the data providers exposed by this data store
	 */
	virtual void InitializeDataStore(void);

	/**
	 * Forwards the calls to the data providers so they can do their start up
	 *
	 * @param Player the player that will be associated with this DataStore
	 */
	virtual void OnRegister(ULocalPlayer* Player);

	/**
	 * Tells all of the child providers to clear their player data
	 *
	 * @param Player ignored
	 */
	virtual void OnUnregister(ULocalPlayer*);

	/**
	 * Gets the list of data fields exposed by this data provider
	 *
	 * @param OutFields Filled in with the list of fields supported by its aggregated providers
	 */
	virtual void GetSupportedDataFields(TArray<FUIDataProviderField>& OutFields);

	/**
	 * Parses the data store reference and resolves the data provider and field that is referenced by the markup.
	 *
	 * @param	MarkupString	a markup string that can be resolved to a data field contained by this data provider, or one of its
	 *							internal data providers.
	 * @param	out_FieldOwner	receives the value of the data provider that owns the field referenced by the markup string.
	 * @param	out_FieldTag	receives the value of the property or field referenced by the markup string.
	 * @param	out_ArrayIndex	receives the optional array index for the data field referenced by the markup string.  If there is no array index embedded in the markup string,
	 *							value will be INDEX_NONE.
	 *
	 * @return	TRUE if this data store was able to successfully resolve the string specified.
	 */
	virtual UBOOL ParseDataStoreReference( const FString& MarkupString, class UUIDataProvider*& out_FieldOwner, FString& out_FieldTag, INT& out_ArrayIndex );

	/**
	 * Gets the value for the specified field
	 *
	 * @param	FieldName		the field to look up the value for
	 * @param	OutFieldValue	out param getting the value
	 * @param	ArrayIndex		ignored
	 */
	virtual UBOOL GetFieldValue(const FString& FieldName,FUIProviderFieldValue& OutFieldValue,INT ArrayIndex=INDEX_NONE );

	/**
	 * Resolves PropertyName into a list element provider that provides list elements for the property specified.
	 *
	 * @param	PropertyName	the name of the property that corresponds to a list element provider supported by this data store
	 *
	 * @return	a pointer to an interface for retrieving list elements associated with the data specified, or NULL if
	 *			there is no list element provider associated with the specified property.
	 */
	virtual TScriptInterface<class IUIListElementProvider> ResolveListElementProvider( const FString& PropertyName );

/* === IUIListElementProvider interface === */

	/**
	 * Retrieves the list of all data tags contained by this element provider which correspond to list element data.
	 *
	 * @return	the list of tags supported by this element provider which correspond to list element data.
	 */
	virtual TArray<FName> GetElementProviderTags();

	/**
	 * Returns the number of list elements associated with the data tag specified.
	 *
	 * @param	FieldName	the name of the property to get the element count for.  guaranteed to be one of the values returned
	 *						from GetElementProviderTags.
	 *
	 * @return	the total number of elements that are required to fully represent the data specified.
	 */
	virtual INT GetElementCount( FName FieldName );

	/**
	 * Retrieves the list elements associated with the data tag specified.
	 *
	 * @param	FieldName		the name of the property to get the element count for.  guaranteed to be one of the values returned
	 *							from GetElementProviderTags.
	 * @param	out_Elements	will be filled with the elements associated with the data specified by DataTag.
	 *
	 * @return	TRUE if this data store contains a list element data provider matching the tag specified.
	 */
	virtual UBOOL GetListElements( FName FieldName, TArray<INT>& out_Elements );

	/**
	 * Retrieves a list element for the specified data tag that can provide the list with the available cells for this list element.
	 * Used by the UI editor to know which cells are available for binding to individual list cells.
	 *
	 * @param	FieldName		the tag of the list element data provider that we want the schema for.
	 *
	 * @return	a pointer to some instance of the data provider for the tag specified.  only used for enumerating the available
	 *			cell bindings, so doesn't need to actually contain any data (i.e. can be the CDO for the data provider class, for example)
	 */
	virtual TScriptInterface<class IUIListElementCellProvider> GetElementCellSchemaProvider( FName FieldName );

	/**
	 * Retrieves a UIListElementCellProvider for the specified data tag that can provide the list with the values for the cells
	 * of the list element indicated by CellValueProvider.DataSourceIndex
	 *
	 * @param	FieldName		the tag of the list element data field that we want the values for
	 * @param	ListIndex		the list index for the element to get values for
	 *
	 * @return	a pointer to an instance of the data provider that contains the value for the data field and list index specified
	 */
	virtual TScriptInterface<class IUIListElementCellProvider> GetElementCellValueProvider( FName FieldName, INT ListIndex );
}

/**
 * Handler for this data store internal settings data providers OnDataProviderPropertyChange delegate.  When the setting associated with that
 * provider is updated, issues a refresh notification which causes e.g. widgets to refresh their values.
 *
 * @param	SourceProvider	the data provider that generated the notification
 * @param	SettingsName	the name of the setting that changed
 */
native final function OnSettingProviderChanged( UIDataProvider SourceProvider, optional name SettingsName );

/**
 * Binds the player to this provider. Starts the async friends list gathering
 *
 * @param InPlayer the player that we are retrieving friends for
 */
event OnRegister(LocalPlayer InPlayer)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	if (InPlayer != None)
	{
		PlayerControllerId = InPlayer.ControllerId;
		// Figure out if we have an online subsystem registered
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None)
			{
				// We need to know when the player's login changes
				PlayerInterface.AddLoginChangeDelegate(OnLoginChange);
			}
			if (OnlineSub.PlayerInterfaceEx != None)
			{
				// We need to know when the player changes data (change nick name, etc)
				OnlineSub.PlayerInterfaceEx.AddProfileDataChangedDelegate(PlayerControllerId,OnPlayerDataChange);
			}
			if (OnlineSub.ContentInterface != None)
			{
				// Set the delegate for updating the downloadable content info
				OnlineSub.ContentInterface.AddQueryAvailableDownloadsComplete(PlayerControllerId,OnDownloadableContentQueryDone);
			}
		}
		//If we do not have an online subsystem, nor any settings, then we want the default settings.
		else if (ProfileProvider != none && ProfileProvider.Profile != none)
		{
			 ProfileProvider.Profile.SetToDefaults();
		}

		RegisterDelegates();

		// Force a refresh
		OnLoginChange(PlayerControllerId);
	}
}

/**
 * Clears our delegate for getting login change notifications
 */
event OnUnregister()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	if (PlayerControllerId != -1)
	{
		ClearDelegates();

		// Figure out if we have an online subsystem registered
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None)
			{
				// Clear our delegate
				PlayerInterface.ClearLoginChangeDelegate(OnLoginChange);
			}
			if (OnlineSub.PlayerInterfaceEx != None)
			{
				// Clear for GC reasons
				OnlineSub.PlayerInterfaceEx.ClearProfileDataChangedDelegate(PlayerControllerId,OnPlayerDataChange);
			}
			if (OnlineSub.ContentInterface != None)
			{
				// Clear the delegate for updating the downloadable content info
				OnlineSub.ContentInterface.ClearQueryAvailableDownloadsComplete(PlayerControllerId,OnDownloadableContentQueryDone);
			}
		}
	}
}

/**
 * Refetches the player's nick name from the online subsystem
 *
 * @param LocalUserNum the player that logged in/out
 */
function OnLoginChange(byte LocalUserNum)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	if (LocalUserNum == PlayerControllerId)
	{
		// Figure out if we have an online subsystem registered
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None &&
				PlayerInterface.GetLoginStatus(PlayerControllerId) > LS_NotLoggedIn)
			{
				// Start a query for downloadable content...
				if(OnlineSub.ContentInterface != None)
				{
					OnlineSub.ContentInterface.QueryAvailableDownloads(PlayerControllerId);
				}
				// Get the name and force a refresh
				PlayerNick = PlayerInterface.GetPlayerNickname(PlayerControllerId);
			}
			else
			{
				PlayerNick = "";
				NumNewDownloads = 0;
				NumTotalDownloads = 0;
			}
		}
		RefreshSubscribers();
	}
}

/**
 * Refetches the player's nick name from the online subsystem
 */
function OnPlayerDataChange()
{
	local OnlineSubsystem OnlineSub;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		if (OnlineSub.PlayerInterface != None)
		{
			// Get the name and force a refresh
			PlayerNick = OnlineSub.PlayerInterface.GetPlayerNickname(PlayerControllerId);
			RefreshSubscribers();
		}
	}
}

/**
 * Registers the delegates with the providers so we can know when async data changes
 */
function RegisterDelegates()
{
	FriendsProvider.AddPropertyNotificationChangeRequest(OnSettingProviderChanged);
	FriendMessagesProvider.AddPropertyNotificationChangeRequest(OnSettingProviderChanged);
	ProfileProvider.AddPropertyNotificationChangeRequest(OnSettingProviderChanged);
	AchievementsProvider.AddPropertyNotificationChangeRequest(OnSettingProviderChanged);
	StorageProvider.AddPropertyNotificationChangeRequest(OnSettingProviderChanged);
}

function ClearDelegates()
{
	FriendsProvider.RemovePropertyNotificationChangeRequest(OnSettingProviderChanged);
	FriendMessagesProvider.RemovePropertyNotificationChangeRequest(OnSettingProviderChanged);
	ProfileProvider.RemovePropertyNotificationChangeRequest(OnSettingProviderChanged);
	AchievementsProvider.RemovePropertyNotificationChangeRequest(OnSettingProviderChanged);
	StorageProvider.RemovePropertyNotificationChangeRequest(OnSettingProviderChanged);
}

/**
 * Caches the downloadable content info for the player we're bound to
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnDownloadableContentQueryDone(bool bWasSuccessful)
{
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None && OnlineSub.ContentInterface != None)
	{
		if (bWasSuccessful == true)
		{
			// Read the data and tell the UI to refresh
			OnlineSub.ContentInterface.GetAvailableDownloadCounts(PlayerControllerId,
				NumNewDownloads,NumTotalDownloads);
			RefreshSubscribers();
		}
		else
		{
			`Log("Failed to query for downloaded content");
		}
	}
}

/** Forwards the call to the provider */
event bool SaveProfileData()
{
	if (ProfileProvider != None)
	{
		return ProfileProvider.SaveStorageData();
	}
	return false;
}

/**
 * Retrieves a player profile which has been cached by the online subsystem.
 *
 * @param	ControllerId	the controller ID for the player to retrieve the profile for.
 *
 * @return	a player profile which was previously created and cached by the online subsystem for
 *			the specified controller id.
 */
static event OnlineProfileSettings GetCachedPlayerProfile( int ControllerId )
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;
	local OnlineProfileSettings Result;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			Result = PlayerInterface.GetProfileSettings(ControllerId);
		}
	}
	return Result;
}

/**
 * Retrieves a player storage which has been cached by the online subsystem.
 *
 * @param	ControllerId	the controller ID for the player to retrieve the profile for.
 *
 * @return	a player storage which was previously created and cached by the online subsystem for
 *			the specified controller id.
 */
static event OnlinePlayerStorage GetCachedPlayerStorage( int ControllerId )
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;
	local OnlinePlayerStorage Result;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			Result = PlayerInterface.GetPlayerStorage(ControllerId);
		}
	}
	return Result;
}

defaultproperties
{
	Tag=OnlinePlayerData
	// So something shows up in the editor
	PlayerNick="PlayerNickNameHere"
	PlayerControllerId=-1
}
