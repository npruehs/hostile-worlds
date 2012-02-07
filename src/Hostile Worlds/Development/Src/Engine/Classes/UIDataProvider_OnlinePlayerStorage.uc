/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for mapping properties in an OnlineGameSettings
 * object to something that the UI system can consume.
 */
class UIDataProvider_OnlinePlayerStorage extends UIDataProvider_OnlinePlayerDataBase
	native(inherit)
	config(Game)
	dependson(OnlineSubsystem)
	transient;

/** The storage settings that are used to load/save with the online subsystem */
var OnlinePlayerStorage Profile;

/** For displaying in the provider tree */
var const name ProviderName;

/**
 * If there was an error, it was possible the read was already in progress. This
 * indicates to re-read upon a good completion
 */
var bool bWasErrorLastRead;

/** Keeps a list of providers for each storage settings id */
struct native PlayerStorageArrayProvider
{
	/** The storage settings id that this provider is for */
	var int PlayerStorageId;
	/** Cached to avoid extra look ups */
	var name PlayerStorageName;
	/** The provider object to expose the data with */
	var UIDataProvider_OnlinePlayerStorageArray Provider;
};

/** The list of mappings from settings id to their provider */
var array<PlayerStorageArrayProvider> PlayerStorageArrayProviders;

cpptext
{
	/**
	 * Tells the provider the settings object it is resposible for exposing to
	 * the UI
	 *
	 * @param InSettings the settings object to expose
	 */
	virtual void BindPlayerStorage(UOnlinePlayerStorage* InStorage);

	/**
	 * Resolves the value of the data field specified and stores it in the output parameter.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	OutFieldValue	receives the resolved value for the property specified.
	 *							@see GetDataStoreValue for additional notes
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL GetFieldValue(const FString& FieldName,FUIProviderFieldValue& OutFieldValue,INT ArrayIndex = INDEX_NONE);

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
	 * Builds a list of available fields from the array of properties in the
	 * game settings object
	 *
	 * @param OutFields	out value that receives the list of exposed properties
	 */
	virtual void GetSupportedDataFields(TArray<FUIDataProviderField>& OutFields);

	/**
	 * Resolves PropertyName into a list element provider that provides list elements for the property specified.
	 *
	 * @param	PropertyName	the name of the property that corresponds to a list element provider supported by this data store
	 *
	 * @return	a pointer to an interface for retrieving list elements associated with the data specified, or NULL if
	 *			there is no list element provider associated with the specified property.
	 */
	virtual TScriptInterface<class IUIListElementProvider> ResolveListElementProvider( const FString& PropertyName );
}
/**
 * Reads the data
 *
 * @param PlayerInterface is the OnlinePlayerInterface used
 * @param LocalUserNum the user that we are reading the data for
 * @param PlayerStorage the object to copy the results to and contains the list of items to read
 *
 * @return true if the call succeeds, false otherwise
 */
function bool ReadData(OnlinePlayerInterface PlayerInterface, byte LocalUserNum, OnlinePlayerStorage PlayerStorage)
{
	return PlayerInterface.ReadPlayerStorage(LocalUserNum, PlayerStorage);
}

/**
 * Writes the online  data for a given local user to the online data store
 *
 * @param PlayerInterface is the OnlinePlayerInterface used
 * @param LocalUserNum the user that we are writing the data for
 * @param PlayerStorage the object that contains the list of items to write
 *
 * @return true if the call succeeds, false otherwise
 */
function bool WriteData(OnlinePlayerInterface PlayerInterface, byte LocalUserNum,OnlinePlayerStorage PlayerStorage)
{
	return PlayerInterface.WritePlayerStorage(LocalUserNum,PlayerStorage);
}

/**
 * Sets the delegate used to notify the gameplay code that the last read request has completed 
 *
 * @param PlayerInterface is the OnlinePlayerInterface used
 * @param LocalUserNum which user to watch for read complete notifications
 */
function AddReadCompleteDelegate(OnlinePlayerInterface PlayerInterface, byte LocalUserNum)
{
	PlayerInterface.AddReadPlayerStorageCompleteDelegate(LocalUserNum,OnReadStorageComplete);
}

/**
 * Clears the delegate used to notify the gameplay code that the last read request has completed 
 *
 * @param PlayerInterface is the OnlinePlayerInterface used
 * @param LocalUserNum which user to stop watching for read complete notifications
 */
function ClearReadCompleteDelegate(OnlinePlayerInterface PlayerInterface, byte LocalUserNum)
{
	PlayerInterface.ClearReadPlayerStorageCompleteDelegate(LocalUserNum,OnReadStorageComplete);
}


/**
 * Binds the player to this provider. Starts the async friends list gathering
 *
 * @param InPlayer the player that we are retrieving friends for
 */
event OnRegister(LocalPlayer InPlayer)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	Super.OnRegister(InPlayer);

	// If the player is None, we are in the editor
	if (PlayerControllerId != -1)
	{
		// Figure out if we have an online subsystem registered
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None)
			{
				// Register that we are interested in any sign in change for this player
				PlayerInterface.AddLoginChangeDelegate(OnLoginChange);
				// Set our callback function per player
				AddReadCompleteDelegate(PlayerInterface,PlayerControllerId);
				// Start the async task
				if (ReadData(PlayerInterface,PlayerControllerId,Profile) == false)
				{
					bWasErrorLastRead = true;
				}
			}
		}
	}

	if ( Profile != None )
	{
		Profile.NotifySettingValueUpdated = OnSettingValueUpdated;
	}
}

/**
 * Clears our delegate for getting login change notifications
 */
event OnUnregister()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;
	
	if (Profile != None && Profile.NotifySettingValueUpdated == OnSettingValueUpdated)
	{
		Profile.NotifySettingValueUpdated = None;
	}

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
			ClearReadCompleteDelegate(PlayerInterface,PlayerControllerId);
		}
	}
	Super.OnUnregister();
}

/**
 * Handles the notification that the async read of the storage data is done
 *
 * @param bWasSuccessful whether the call succeeded or not
 */
function OnReadStorageComplete(byte LocalUserNum,bool bWasSuccessful)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	if (bWasSuccessful == true)
	{
		if (!bWasErrorLastRead)
		{
			// Notify any subscribers that we have new data
			NotifyPropertyChanged();
		}
		else
		{
			// Figure out if we have an online subsystem registered
			OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
			if (OnlineSub != None)
			{
				// Grab the player interface to verify the subsystem supports it
				PlayerInterface = OnlineSub.PlayerInterface;
				if (PlayerInterface != None)
				{
					bWasErrorLastRead = false;
					// Read again to copy any data from a read in progress
					if (ReadData(PlayerInterface,PlayerControllerId,Profile) == false)
					{
						bWasErrorLastRead = true;
					}
				}
			}
		}
	}
	else
	{
		bWasErrorLastRead = true;
		`Log("Failed to read online storage data",,'DevOnline');
	}
}

/**
 * Executes a refetching of the storage data when the login for this player changes
 *
 * @param LocalUserNum the player that logged in/out
 */
function OnLoginChange(byte LocalUserNum)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;
	local ELoginStatus LoginStatus;
	local UniqueNetId NetId;

	if (LocalUserNum == PlayerControllerId)
	{
		// Figure out if we have an online subsystem registered
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None)
			{
				LoginStatus = PlayerInterface.GetLoginStatus(PlayerControllerId);
				PlayerInterface.GetUniquePlayerId(PlayerControllerId,NetId);
				if (LoginStatus == LS_NotLoggedIn)/* ||
					PC.PlayerReplicationInfo.UniqueId != NetId)*/
				{
					// Reset the profile only when they've signed out
					Profile.SetToDefaults();
				}
			}
		}
		RefreshStorageData();
	}
}

/**
 * Reads this user's storage data from the online subsystem.
 */
function RefreshStorageData()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None &&
			PlayerInterface.GetLoginStatus(PlayerControllerId) > LS_NotLoggedIn)
		{
			`Log("Login change...requerying storage data");
			// Start the async task
			if (ReadData(PlayerInterface, PlayerControllerId,Profile) == false)
			{
				// Notify any owner data stores that we have changed data
				NotifyPropertyChanged();
			}
		}
	}
}

/**
 * Writes the storage data to the online subsystem for this user
 */
event bool SaveStorageData()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			// Start the async task
			return WriteData(PlayerInterface, PlayerControllerId,Profile);
		}
	}
	return false;
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
	local UIDataProvider_OnlinePlayerStorageArray ArrayProvider;

	for ( ProviderIdx = 0; ProviderIdx < PlayerStorageArrayProviders.Length; ProviderIdx++ )
	{
		if ( SettingName == PlayerStorageArrayProviders[ProviderIdx].PlayerStorageName )
		{
			ArrayProvider = PlayerStorageArrayProviders[ProviderIdx].Provider;
			ArrayProviderPropertyChanged(ArrayProvider, SettingName);
			break;
		}
	}
}


defaultproperties
{
	ProviderName=PlayerStorageData
	WriteAccessType=ACCESS_WriteAll
}
