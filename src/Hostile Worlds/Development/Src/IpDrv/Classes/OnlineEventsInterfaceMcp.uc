/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Provides an in game gameplay events/stats upload mechanism via the MCP backend
 */
class OnlineEventsInterfaceMcp extends MCPBase
	native
	implements(OnlineEventsInterface);

/** The types of events that are to be uploaded */
enum EEventUploadType
{
	EUT_GenericStats,
	EUT_ProfileData,
	EUT_HardwareData,
	EUT_MatchmakingData,
	EUT_PlaylistPopulation
};

/** Holds the configuration and instance data for event uploading */
struct native EventUploadConfig
{
	/** The type of upload this config is for */
	var const EEventUploadType UploadType;
	/** The URL to send the data to */
	var const string UploadUrl;
	/** The amount of time to wait before erroring out */
	var const float TimeOut;
	/** Whether to compress the data before sending or not */
	var const bool bUseCompression;
};

/**
 * This is the array of upload task configurations
 */
var const config array<EventUploadConfig> EventUploadConfigs;

/** List of HTTP downloader objects that are POSTing the data */
var native const array<pointer> HttpPostObjects{class FHttpDownloadString};

/** A list of upload types that are disabled (don't upload) */
var config array<EEventUploadType> DisabledUploadTypes;

/** if true, the stats data will be sent as a binary blob instead of XML */
var const config bool bBinaryStats;

cpptext
{
// FTickableObject interface
	/**
	 * Ticks any outstanding async tasks that need processing
	 *
	 * @param DeltaTime the amount of time that has passed since the last tick
	 */
	virtual void Tick(FLOAT DeltaTime);

// Event upload specific methods
	/**
	 * Finds the upload config for the type
	 *
	 * @param UploadType the type of upload that is being processed
	 *
	 * @return pointer to the config item or NULL if not found
	 */
	inline FEventUploadConfig* FindUploadConfig(BYTE UploadType)
	{
		// Make sure this config wasn't disabled
		INT ItemIndex = DisabledUploadTypes.FindItemIndex(UploadType);
		if (ItemIndex == INDEX_NONE)
		{
			for (INT EventIndex = 0; EventIndex < EventUploadConfigs.Num(); EventIndex++)
			{
				if (EventUploadConfigs(EventIndex).UploadType == UploadType)
				{
					return &EventUploadConfigs(EventIndex);
				}
			}
		}
		return NULL;
	}

	/**
	 * Common method for POST-ing a payload to an URL (determined by upload type)
	 *
	 * @param UploadType the type of upload that is happening
	 * @param Payload the data to send
	 *
	 * @return TRUE if the send started successfully, FALSE otherwise
	 */
	virtual UBOOL UploadPayload(BYTE UploadType,const FString& Payload);

	/**
	 * Common method for POST-ing a payload to an URL (determined by upload type)
	 *
	 * @param UploadType the type of upload that is happening
	 * @param Payload the data to send
	 *
	 * @return TRUE if the send started successfully, FALSE otherwise
	 */
	virtual UBOOL UploadBinaryPayload(BYTE UploadType,const TArray<BYTE>& Payload);

	/**
	 * Final method for POST-ing a payload to a URL.  At this point it is assumed to be binary data
	 *
	 * @param bWasText will be true if the original post was text data
	 * @param UploadType the type of upload that is happening
	 * @param Payload the data to send
	 *
	 * @return TRUE if the send started successfully, FALSE otherwise
	 */	
	virtual UBOOL UploadFinalPayload(UBOOL bWasText, BYTE UploadType, const TArray<BYTE>& Payload );

	/**
	 * Converts the net id to a string
	 *
	 * @param Id the net id to convert
	 *
	 * @return the string form of the id
	 */
	virtual FString FormatAsString(const FUniqueNetId& Id)
	{
		return FString::Printf(TEXT("0x%016I64X"),(QWORD&)Id);
	}

	/**
	 * Filters out escape characters that can't be sent to MCP via XML and
	 * replaces them with the XML allowed sequences
	 *
	 * @param Source the source string to modify
	 *
	 * @return a new string with the data escaped
	 */
	virtual FString EscapeString(const FString& Source);

	/**
	 * Builds the URL of additional parameters used when posting playlist population data
	 *
	 * @param PlaylistId the playlist id being reported
	 * @param NumPlayers the number of players on the host
	 *
	 * @return the URL to use with all of the per platform extras
	 */
	virtual FString BuildPlaylistPopulationURLParameters(INT PlaylistId,INT NumPlayers);
}

/**
 * Sends the profile data to the server for statistics aggregation
 *
 * @param UniqueId the unique id for the player
 * @param PlayerNick the player's nick name
 * @param ProfileSettings the profile object that is being sent
 *
 * @return true if the async task was started successfully, false otherwise
 */
native function bool UploadProfileData(UniqueNetId UniqueId,string PlayerNick,OnlineProfileSettings ProfileSettings);

/**
 * Sends the data contained within the gameplay events object to the online server for statistics
 *
 * @param Events the object that has the set of events in it
 *
 * @return true if the async send started ok, false otherwise
 */
native function bool UploadGameplayEventsData(OnlineGameplayEvents Events);

/**
 * Sends the hardware data to the online server for statistics aggregation
 *
 * @param UniqueId the unique id for the player
 * @param PlayerNick the player's nick name
 *
 * @return true if the async task was started successfully, false otherwise
 */
function bool UploadHardwareData(UniqueNetId UniqueId,string PlayerNick);

/**
 * Sends the network backend the playlist population for this host
 *
 * @param PlaylistId the playlist we are updating the population for
 * @param NumPlayers the number of players on this host in this playlist
 *
 * @return true if the async send started ok, false otherwise
 */
native function bool UpdatePlaylistPopulation(int PlaylistId,int NumPlayers);
