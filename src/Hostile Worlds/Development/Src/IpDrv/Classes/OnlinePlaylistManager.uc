/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class holds the set of playlists that the game exposes, handles
 * downloading updates to the playlists via MCP/TitleFiles, and creates the
 * game settings objects that make up a playlist
 */
class OnlinePlaylistManager extends Object
	native
	inherits(FTickableObject)
	config(Playlist);

/** Contains a game settings class name to load and instance using the specified URL to override defaults */
struct native ConfiguredGameSetting
{
	/** The unique (within the playlist) id for this game setting */
	var int GameSettingId;
	/** The name of the class to load and instance */
	var string GameSettingsClassName;
	/** The URL to use to replace settings with (see UpdateFromURL()) */
	var string Url;
	/** Holds the object that was created for this entry in a playlist */
	var transient OnlineGameSettings GameSettings;
};

/** A playlist contains 1 or more game configurations that players can choose between */
struct native Playlist
{
	/** Holds the list of game configurations that are part of this playlist */
	var array<ConfiguredGameSetting> ConfiguredGames;
	/** The unique id for this playlist */
	var int PlaylistId;
	/** The string to use to lookup the display name for this playlist */
	var string LocalizationString;
	/** The set of content/maps (or DLC bundles) that must be present in order to play on this playlist */
	var array<int> ContentIds;
	/** The number of players per team if different from the defaults */
	var int TeamSize;
	/** The number of teams per match if different from the defaults */
	var int TeamCount;
	/** The string to use in the UI for this playlist */
	var string Name;
	/** Whether this playlist is arbitrated or not */
	var bool bIsArbitrated;
	/** Whether dedicated server searches are supported with this playlist */
	var bool bDisableDedicatedServerSearches;
};

/** This is the complete set of playlists available to choose from */
var config array<Playlist> Playlists;

/** The file names to request when downloading a playlist from MCP/TMS/etc */
var array<string> PlaylistFileNames;

/** The set of UIDataStore_GameResource objects to refresh once the download has completed */
var config array<name> DatastoresToRefresh;

/** Used to know when we should finalize the objects */
var int DownloadCount;

/** Incremented when successful to determine whether to update at all */
var int SuccessfulCount;

/** The version number of the playlist that was downloaded */
var config int VersionNumber;

/** Holds the overall and per region playlist population numbers */
struct native PlaylistPopulation
{
	/** The unique id for this playlist */
	var int PlaylistId;
	/** The total across all regions */
	var int WorldwideTotal;
	/** The total for the player's region */
	var int RegionTotal;
};

/** The list of playlists and the number of players in them */
var config array<PlaylistPopulation> PopulationData;

/** The total number of players across all playlists worldwide */
var int WorldwideTotalPlayers;

/** The total number of players across all playlists in the region */
var int RegionTotalPlayers;

/** Cached object ref that we use for accessing the TitleFileInterface */
var transient OnlineTitleFileInterface TitleFileInterface;

/** The name of the population data file to request */
var string PopulationFileName;

/** The next time the playlist population data needs to be sent */
var transient float NextPlaylistPopulationUpdateTime;

/** How often (in seconds) we should update the population data */
var config float PlaylistPopulationUpdateInterval;

/** The lowest number playlist id to report to the backend. Used to turn off "not mp" playlist ids */
var config int MinPlaylistIdToReport;

/** The playlist id that is being played */
var transient int CurrentPlaylistId;

/** The name of the interface to request as our upload object */
var config name EventsInterfaceName;

/** The datacenter id to use for this machine */
var config int DataCenterId;

/** The name of the datacenter file to request */
var string DataCenterFileName;

cpptext
{
// FTickableObject interface

	/**
	 * Returns whether it is okay to tick this object. E.g. objects being loaded in the background shouldn't be ticked
	 * till they are finalized and unreachable objects cannot be ticked either.
	 *
	 * @return	TRUE if tickable, FALSE otherwise
	 */
	virtual UBOOL IsTickable() const
	{
		// We cannot tick objects that are unreachable or are in the process of being loaded in the background.
		return !HasAnyFlags(RF_Unreachable | RF_AsyncLoading);
	}

	/**
	 * Used to determine if an object should be ticked when the game is paused.
	 *
	 * @return always TRUE as networking needs to be ticked even when paused
	 */
	virtual UBOOL IsTickableWhenPaused() const
	{
		return TRUE;
	}

	/**
	 * Determines whether an update of the playlist population information is needed or not
	 *
	 * @param DeltaTime the amount of time that has passed since the last tick
	 */
	virtual void Tick(FLOAT DeltaTime);
}

/**
 * Delegate fired when the playlist has been downloaded and processed
 */
delegate OnReadPlaylistComplete();

/**
 * Reads the playlist from either MCP or from some form of title storage
 */
function DownloadPlaylist()
{
	local OnlineSubsystem OnlineSub;
	local int FileIndex;

	if (SuccessfulCount == 0)
	{
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None &&
			OnlineSub.Patcher != None)
		{
			// Request notification of file downloads
			OnlineSub.Patcher.AddReadFileDelegate(OnReadTitleFileComplete);
			// Reset our counts since we might be re-downloading
			DownloadCount = 0;
			SuccessfulCount = 0;
			// Don't rebuild the list of files when already there
			if (PlaylistFileNames.Length == 0)
			{
				DetermineFilesToDownload();
			}
			// Iterate the files that we read and request them
			for (FileIndex = 0; FileIndex < PlaylistFileNames.Length; FileIndex++)
			{
				OnlineSub.Patcher.AddFileToDownload(PlaylistFileNames[FileIndex]);
			}
			// Download the datacenter file now too
			ReadDataCenterId();
		}
		else
		{
			`Log("No online layer present, using defaults for playlist");
			// Initialize all playlist objects with defaults
			FinalizePlaylistObjects();
			// Notify the completion
			OnReadPlaylistComplete();
		}
	}
	else
	{
		// Notify the completion
		OnReadPlaylistComplete();
	}
}

/** Uses the current loc setting and game ini name to build the download list */
native function DetermineFilesToDownload();

/**
 * Notifies us when the download of the playlist file is complete
 *
 * @param bWasSuccessful true if the download completed ok, false otherwise
 * @param FileName the file that was downloaded (or failed to)
 */
function OnReadTitleFileComplete(bool bWasSuccessful,string FileName)
{
	local OnlineSubsystem OnlineSub;
	local int FileIndex;

	for (FileIndex = 0; FileIndex < PlaylistFileNames.Length; FileIndex++)
	{
		if (PlaylistFileNames[FileIndex] == FileName)
		{
			// Increment how many we've downloaded
			DownloadCount++;
			SuccessfulCount += int(bWasSuccessful);
			// If they have all been downloaded, rebuild the playlist
			if (DownloadCount == PlaylistFileNames.Length)
			{
				if (SuccessfulCount != DownloadCount)
				{
					`Log("PlaylistManager: not all files downloaded correctly, using defaults where applicable");
				}
				// Rebuild the playlist and update any objects/ui
				FinalizePlaylistObjects();
				// Notify our requester
				OnReadPlaylistComplete();

				// Remove the delegates since we are done
				OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
				if (OnlineSub != None &&
					OnlineSub.Patcher != None)
				{
					OnlineSub.Patcher.ClearReadFileDelegate(OnReadTitleFileComplete);
				}

				// Force an update of the playlist population data
				NextPlaylistPopulationUpdateTime = PlaylistPopulationUpdateInterval;
				// Now read the worldwide population
				ReadPlaylistPopulation();
			}
		}
	}
}

/**
 * Uses the configuration data to create the requested objects and then applies any
 * specific game settings changes to them
 */
native function FinalizePlaylistObjects();

/**
 * Finds the game settings object associated with this playlist and game settings id
 *
 * @param PlaylistId the playlist we are searching
 * @param GameSettingsId the game settings id being searched for
 *
 * @return the game settings specified or None if not found
 */
function OnlineGameSettings GetGameSettings(int PlaylistId,int GameSettingsId)
{
	local int PlaylistIndex;
	local int GameIndex;

	// Find the matching playlist
	PlaylistIndex = Playlists.Find('PlaylistId',PlaylistId);
	if (PlaylistIndex != INDEX_NONE)
	{
		// Search through the registered games for this playlist
		for (GameIndex = 0; GameIndex < Playlists[PlaylistIndex].ConfiguredGames.Length; GameIndex++)
		{
			if (Playlists[PlaylistIndex].ConfiguredGames[GameIndex].GameSettingId == GameSettingsId)
			{
				return Playlists[PlaylistIndex].ConfiguredGames[GameIndex].GameSettings;
			}
		}
	}
	return None;
}

/**
 * Determine if any game settings exist for the given playlistid
 *
 * @param PlaylistId playlist to check for game settings
 * @return TRUE if game settings exist for the given id
 */
function bool HasAnyGameSettings(int PlaylistId)
{
	local int PlaylistIndex;
	local int GameIndex;

	// Find the matching playlist
	PlaylistIndex = Playlists.Find('PlaylistId',PlaylistId);
	if (PlaylistIndex != INDEX_NONE)
	{
		// Search through the registered games for this playlist
		for (GameIndex = 0; GameIndex < Playlists[PlaylistIndex].ConfiguredGames.Length; GameIndex++)
		{
			if (Playlists[PlaylistIndex].ConfiguredGames[GameIndex].GameSettings != None)
			{
				return true;
			}
		}
	}
	return false;
}
			
/*
 * Determines if this playlist can be found on dedicated servers
 *
 * @param PlaylistId playlist to check for dedicated server support
 */
function bool PlaylistSupportsDedicatedServers(int PlaylistId)
{
	local int PlaylistIndex;

	// Find the playlist
	PlaylistIndex = Playlists.Find('PlaylistId',PlaylistId);
	if (PlaylistIndex != INDEX_NONE)
	{
		// Search through the registered games for this playlist
		return !Playlists[PlaylistIndex].bDisableDedicatedServerSearches;
	}
	return false;
}

/**
 * Finds the team information for the specified playlist and returns it in the out vars
 *
 * @param PlaylistId the playlist being searched for
 * @param TeamSize out var getting the number of players per team
 * @param TeamCount out var getting the number of teams per match
 */
function GetTeamInfoFromPlaylist(int PlaylistId,out int TeamSize,out int TeamCount)
{
	local int PlaylistIndex;

	TeamSize = 0;
	TeamCount = 0;
	// Find the playlist
	PlaylistIndex = Playlists.Find('PlaylistId',PlaylistId);
	if (PlaylistIndex != INDEX_NONE)
	{
		TeamSize = Playlists[PlaylistIndex].TeamSize;
		TeamCount = Playlists[PlaylistIndex].TeamCount;
	}
}

/**
 * Finds the specified playlist and return the content ids in the out var
 *
 * @param PlaylistId the playlist being searched for
 * @param ContentIds the list to set the content ids in
 */
function GetContentIdsFromPlaylist(int PlaylistId,out array<int> ContentIds)
{
	local int PlaylistIndex;

	// Find the matching playlist
	PlaylistIndex = Playlists.Find('PlaylistId',PlaylistId);
	if (PlaylistIndex != INDEX_NONE)
	{
		ContentIds = Playlists[PlaylistIndex].ContentIds;
	}
}

/**
 * Allows the playlists to be re-requested from the server
 */
function Reset()
{
	local OnlineSubsystem OnlineSub;

	DownloadCount = 0;
	SuccessfulCount = 0;

	// Clear out any cached file contents if present
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None &&
		OnlineSub.Patcher != None)
	{
		OnlineSub.Patcher.ClearCachedFiles();
	}
}

/**
 * Reads the player population data for playlists by region
 */
function ReadPlaylistPopulation()
{
	local OnlineSubsystem OnlineSub;

	// Get the object to download with the first time
	if (TitleFileInterface == None)
	{
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Ask for the interface by name
			TitleFileInterface = OnlineSub.TitleFileInterface;
		}
	}
	if (TitleFileInterface != None)
	{
		// Force an update of this information
		TitleFileInterface.ClearDownloadedFile(PopulationFileName);
		// Set the callback for notifications of files completing
		TitleFileInterface.AddReadTitleFileCompleteDelegate(OnReadPlaylistPopulationComplete);
		// Request the playlist population numbers
		TitleFileInterface.ReadTitleFile(PopulationFileName);
	}
	else
	{
		`warn("Cannot download playlist population due to missing TitleFileInterface object");
	}
}

/**
 * Notifies us when the download of a file is complete
 *
 * @param bWasSuccessful true if the download completed ok, false otherwise
 * @param FileName the file that was downloaded (or failed to)
 */
function OnReadPlaylistPopulationComplete(bool bWasSuccessful,string FileName)
{
	local array<byte> FileData;

	if (bWasSuccessful)
	{
		if (FileName == PopulationFileName)
		{
			// Read the contents so that they can be processed
			if (TitleFileInterface.GetTitleFileContents(FileName,FileData))
			{
				ParsePlaylistPopulationData(FileData);
			}
		}
	}
	else
	{
		`Log("Failed to download the file ("$FileName$") from TitleFileInterface");
	}
}

/**
 * Converts the data into the structure used by the playlist manager
 *
 * @param Data the data that was downloaded
 */
native function ParsePlaylistPopulationData(const out array<byte> Data);

/**
 * Finds the population information for the specified playlist and returns it in the out vars
 *
 * @param PlaylistId the playlist being searched for
 * @param WorldwideTotal out var getting the number of players worldwide
 * @param RegionTotal out var getting the number of players in this region
 */
function GetPopulationInfoFromPlaylist(int PlaylistId,out int WorldwideTotal,out int RegionTotal)
{
	local int PlaylistIndex;

	WorldwideTotal = 0;
	RegionTotal = 0;
	// Find the playlist
	PlaylistIndex = PopulationData.Find('PlaylistId',PlaylistId);
	if (PlaylistIndex != INDEX_NONE)
	{
		WorldwideTotal = PopulationData[PlaylistIndex].WorldwideTotal;
		RegionTotal = PopulationData[PlaylistIndex].RegionTotal;
	}
}

/**
 * Called once enough time has elapsed that a playlist update is required
 *
 * @param NumPlayers the numbers of players to report (easier to get at in native)
 */
event SendPlaylistPopulationUpdate(int NumPlayers)
{
	local OnlineEventsInterface EventsInterface;
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		EventsInterface = OnlineEventsInterface(OnlineSub.GetNamedInterface(EventsInterfaceName));
		if (EventsInterface != None)
		{
			`Log("Updating playlist population with PlaylistId="$CurrentPlaylistId$" and NumPlayers="$NumPlayers);
			// Send this to the network backend
			EventsInterface.UpdatePlaylistPopulation(CurrentPlaylistId,NumPlayers);
		}
	}
}

/**
 * Asks the network backend which datacenter this machine is to use
 */
function ReadDataCenterId()
{
	local OnlineSubsystem OnlineSub;

	// Get the object to download with the first time
	if (TitleFileInterface == None)
	{
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Ask for the interface by name
			TitleFileInterface = OnlineSub.TitleFileInterface;
		}
	}
	if (TitleFileInterface != None)
	{
		// Set the callback for notifications of files completing
		TitleFileInterface.AddReadTitleFileCompleteDelegate(OnReadDataCenterIdComplete);
		// Request the datacenter id
		TitleFileInterface.ReadTitleFile(DataCenterFileName);
	}
	else
	{
		`warn("Cannot download datacenter id due to missing TitleFileInterface object");
	}
}

/**
 * Notifies us when the download of a file is complete
 *
 * @param bWasSuccessful true if the download completed ok, false otherwise
 * @param FileName the file that was downloaded (or failed to)
 */
function OnReadDataCenterIdComplete(bool bWasSuccessful,string FileName)
{
	local array<byte> FileData;

	if (bWasSuccessful)
	{
		if (FileName == DataCenterFileName)
		{
			// Read the contents so that they can be processed
			if (TitleFileInterface.GetTitleFileContents(FileName,FileData))
			{
				ParseDataCenterId(FileData);
			}
		}
	}
	else
	{
		`Log("Failed to download the file ("$FileName$") from TitleFileInterface");
	}
}

/**
 * Converts the data into the datacenter id
 *
 * @param Data the data that was downloaded
 */
native function ParseDataCenterId(const out array<byte> Data);

defaultproperties
{
	PopulationFileName="PlaylistPopulationData.ini"
	DataCenterFileName="DataCenter.Id"
}