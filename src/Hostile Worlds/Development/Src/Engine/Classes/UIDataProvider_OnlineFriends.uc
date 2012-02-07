/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for retrieving the friends list from the online
 * subsystem and populating the UI with that data.
 */
class UIDataProvider_OnlineFriends extends UIDataProvider_OnlinePlayerDataBase
	native(inherit)
	implements(UIListElementCellProvider)
	dependson(OnlineSubsystem)
	transient;

/** Gets a copy of the friends data from the online subsystem */
var array<OnlineFriend> FriendsList;

/** The column name to display in the UI */
var localized string NickNameCol;

/** The column name to display in the UI */
var localized string PresenceInfoCol;

/** The column name to display in the UI */
var localized string FriendStateCol;

/** The column name to display in the UI */
var localized string bIsOnlineCol;

/** The column name to display in the UI */
var localized string bIsPlayingCol;

/** The column name to display in the UI */
var localized string bIsPlayingThisGameCol;

/** The column name to display in the UI */
var localized string bIsJoinableCol;

/** The column name to display in the UI */
var localized string bHasVoiceSupportCol;

/** The column name to display in the UI */
var localized string bHaveInvitedCol;

/** The column name to display in the UI */
var localized string bHasInvitedYouCol;

/** The text to use when offline */
var localized string OfflineText;

/** The text to use when online */
var localized string OnlineText;

/** The text to use when away */
var localized string AwayText;

/** The text to use when busy */
var localized string BusyText;

cpptext
{
/* === IUIListElement interface === */

	/**
	 * Returns the names of the exposed members in OnlineFriend
	 *
	 * @see OnlineFriend structure in OnlineSubsystem
	 */
	virtual void GetElementCellTags(FName FieldName, TMap<FName,FString>& CellTags)
	{
		CellTags.Set(FName(TEXT("NickName")),*NickNameCol);
		CellTags.Set(FName(TEXT("PresenceInfo")),*PresenceInfoCol);
		CellTags.Set(FName(TEXT("FriendState")),*FriendStateCol);
		CellTags.Set(FName(TEXT("bIsOnline")),*bIsOnlineCol);
		CellTags.Set(FName(TEXT("bIsPlaying")),*bIsPlayingCol);
		CellTags.Set(FName(TEXT("bIsPlayingThisGame")),*bIsPlayingThisGameCol);
		CellTags.Set(FName(TEXT("bIsJoinable")),*bIsJoinableCol);
		CellTags.Set(FName(TEXT("bHasVoiceSupport")),*bHasVoiceSupportCol);
		CellTags.Set(FName(TEXT("bHaveInvited")),*bHaveInvitedCol);
		CellTags.Set(FName(TEXT("bHasInvitedYou")),*bHasInvitedYouCol);
	}

	/**
	 * Retrieves the field type for the specified cell.
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param	CellTag				the tag for the element cell to get the field type for
	 * @param	out_CellFieldType	receives the field type for the specified cell; should be a EUIDataProviderFieldType value.
	 *
	 * @return	TRUE if this element cell provider contains a cell with the specified tag, and out_CellFieldType was changed.
	 */
	virtual UBOOL GetCellFieldType(FName FieldName, const FName& CellTag,BYTE& CellFieldType)
	{
		CellFieldType = DATATYPE_Property;
		return TRUE;
	}

	/**
	 * Resolves the value of the cell specified by CellTag and stores it in the output parameter.
	 *
	 * @param	FieldName		the name of the field the desired cell tags are associated with.  Used for cases where a single data provider
	 *							instance provides element cells for multiple collection data fields.
	 * @param	CellTag			the tag for the element cell to resolve the value for
	 * @param	ListIndex		the UIList's item index for the element that contains this cell.  Useful for data providers which
	 *							do not provide unique UIListElement objects for each element.
	 * @param	out_FieldValue	receives the resolved value for the property specified.
	 *							@see GetDataStoreValue for additional notes
	 * @param	ArrayIndex		optional array index for use with cell tags that represent data collections.  Corresponds to the
	 *							ArrayIndex of the collection that this cell is bound to, or INDEX_NONE if CellTag does not correspond
	 *							to a data collection.
	 */
	virtual UBOOL GetCellFieldValue( FName FieldName, const FName& CellTag, INT ListIndex, FUIProviderFieldValue& out_FieldValue, INT ArrayIndex=INDEX_NONE );

/* === UIDataProvider interface === */

	/**
	 * Gets the list of data fields exposed by this data provider.
	 *
	 * @param	out_Fields	will be filled in with the list of tags which can be used to access data in this data provider.
	 *						Will call GetScriptDataTags to allow script-only child classes to add to this list.
	 */
	virtual void GetSupportedDataFields( TArray<struct FUIDataProviderField>& out_Fields )
	{
		new(out_Fields) FUIDataProviderField( FName(TEXT("Friends")), DATATYPE_Collection );
	}

	/**
	 * Resolves the value of the data field specified and stores it in the output parameter.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	out_FieldValue	receives the resolved value for the property specified.
	 *							@see GetDataStoreValue for additional notes
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL GetFieldValue( const FString& FieldName, struct FUIProviderFieldValue& out_FieldValue, INT ArrayIndex=INDEX_NONE );
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
				PlayerInterface.AddReadFriendsCompleteDelegate(PlayerControllerId,OnFriendsReadComplete);
				// Start the async task
				PlayerInterface.ReadFriendsList(PlayerControllerId);
			}
		}
	}
}

/**
 * Clears our delegate for getting login change notifications
 */
event OnUnregister()
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
			// Set our callback function per player
			PlayerInterface.ClearReadFriendsCompleteDelegate(PlayerControllerId,OnFriendsReadComplete);
			// Clear our delegate
			PlayerInterface.ClearLoginChangeDelegate(OnLoginChange);
		}
	}
	Super.OnUnregister();
}

/**
 * Handles the notification that the async read of the friends data is done
 *
 * @param bWasSuccessful whether the call completed ok or not
 */
function OnFriendsReadComplete(bool bWasSuccessful)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	if (bWasSuccessful == true)
	{
		// Figure out if we have an online subsystem registered
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None)
			{
				// Make a copy of the friends data for the UI
				PlayerInterface.GetFriendsList(PlayerControllerId,FriendsList);
			}
		}
		// Notify any subscribers that we have new data
		NotifyPropertyChanged();
	}
	else
	{
		`Log("Failed to read friends list",,'DevOnline');
	}
}

/**
 * Executes a refetching of the friends data when the login for this player
 * changes
 *
 * @param LocalUserNum the player that logged in/out
 */
function OnLoginChange(byte LocalUserNum)
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	FriendsList.Length = 0;
	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None &&
			PlayerInterface.GetLoginStatus(PlayerControllerId) > LS_NotLoggedIn)
		{
			// Start the async task
			PlayerInterface.ReadFriendsList(PlayerControllerId);
		}
	}
	// Notify any subscribers that we have changed data
	NotifyPropertyChanged();
}

/** Re-reads the friends list to freshen any cached data */
event RefreshFriendsList()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

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
				// Start the async task
				PlayerInterface.ReadFriendsList(PlayerControllerId);
				`log("Refreshing friends list");
			}
		}
	}
}