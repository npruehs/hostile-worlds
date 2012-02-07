/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class is responsible for retrieving the friends list from the online
 * subsystem and populating the UI with that data.
 */
class UIDataProvider_OnlineFriendMessages extends UIDataProvider_OnlinePlayerDataBase
	native(inherit)
	implements(UIListElementCellProvider)
	dependson(OnlineSubsystem)
	transient;

/** Gets a copy of the friends messages from the online subsystem */
var array<OnlineFriendMessage> Messages;

/** The column name to display in the UI */
var localized string SendingPlayerNameCol;

/** The column name to display in the UI */
var localized string bIsFriendInviteCol;

/** The column name to display in the UI */
var localized string bWasAcceptedCol;

/** The column name to display in the UI */
var localized string bWasDeniedCol;

/** The column name to display in the UI */
var localized string MessageCol;

/** The person that sent the last invite */
var string LastInviteFrom;

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
		CellTags.Set(FName(TEXT("SendingPlayerNick")),*SendingPlayerNameCol);
		CellTags.Set(FName(TEXT("bIsFriendInvite")),*bIsFriendInviteCol);
		CellTags.Set(FName(TEXT("bWasAccepted")),*bWasAcceptedCol);
		CellTags.Set(FName(TEXT("bWasDenied")),*bWasDeniedCol);
		CellTags.Set(FName(TEXT("Message")),*MessageCol);
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
	virtual UBOOL GetCellFieldType( FName FieldName, const FName& CellTag, BYTE& out_CellFieldType )
	{
		out_CellFieldType = DATATYPE_Property;
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
	virtual void GetSupportedDataFields(TArray<struct FUIDataProviderField>& out_Fields)
	{
		new(out_Fields)FUIDataProviderField(FName(TEXT("FriendMessages")),DATATYPE_Collection);
		new(out_Fields)FUIDataProviderField(FName(TEXT("LastInviteFrom")));
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
				// Add the callbacks for messages
				PlayerInterface.AddFriendMessageReceivedDelegate(PlayerControllerId,OnFriendMessageReceived);
				PlayerInterface.AddFriendInviteReceivedDelegate(PlayerControllerId,OnFriendInviteReceived);
				PlayerInterface.AddReceivedGameInviteDelegate(PlayerControllerId,OnGameInviteReceived);
				// Read any messages that are waiting
				ReadMessages();
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
			// Clear our callback function per player
			PlayerInterface.ClearLoginChangeDelegate(OnLoginChange);
			// Clear the callbacks for messages
			PlayerInterface.ClearFriendMessageReceivedDelegate(PlayerControllerId,OnFriendMessageReceived);
			PlayerInterface.ClearFriendInviteReceivedDelegate(PlayerControllerId,OnFriendInviteReceived);
			PlayerInterface.ClearReceivedGameInviteDelegate(PlayerControllerId,OnGameInviteReceived);
		}
	}
	Super.OnUnregister();
}

/** Copies the messages from the subsystem */
function ReadMessages()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	Messages.Length = 0;
	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None &&
			PlayerInterface.GetLoginStatus(PlayerControllerId) > LS_NotLoggedIn)
		{
			// Make a copy of the friends messages for the UI
			PlayerInterface.GetFriendMessages(PlayerControllerId,Messages);
		}
	}
	// Notify any subscribers that we have new data
	NotifyPropertyChanged();
}

/**
 * Called when a friend invite arrives for a local player
 *
 * @param LocalUserNum the user that is receiving the invite
 * @param RequestingPlayer the player sending the friend request
 * @param RequestingNick the nick of the player sending the friend request
 * @param Message the message to display to the recipient
 */
function OnFriendInviteReceived(byte LocalUserNum,UniqueNetId RequestingPlayer,string RequestingNick,string Message)
{
	ReadMessages();
}

/**
 * Handles the notification that a friend message was received
 *
 * @param LocalUserNum the user that is receiving the message
 * @param SendingPlayer the player sending the message 
 * @param SendingNick the nick of the player sending the message
 * @param Message the message to display to the recipient
 */
function OnFriendMessageReceived(byte LocalUserNum,UniqueNetId SendingPlayer,string SendingNick,string Message)
{
	ReadMessages();
}

/**
 * Executes a refetching of the friends data when the login for this player
 * changes
 *
 * @param LocalUserNum the player that logged in/out
 */
function OnLoginChange(byte LocalUserNum)
{
	if (LocalUserNum == PlayerControllerId)
	{
		ReadMessages();
	}
}

/**
 * Handles the notification that a game invite has arrived
 *
 * @param LocalUserNum the user that is receiving the invite
 * @param InviterName the nick name of the person sending the invite
 */
function OnGameInviteReceived(byte LocalUserNum,string InviterName)
{
	LastInviteFrom = InviterName;
	ReadMessages();
}