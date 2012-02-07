/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This interface deals with capturing gameplay events for logging with an online service
 */
interface OnlineEventsInterface;

/**
 * Sends the profile data to the server for statistics aggregation
 *
 * @param UniqueId the unique id for the player
 * @param PlayerNick the player's nick name
 * @param ProfileSettings the profile object that is being sent
 *
 * @return true if the async task was started successfully, false otherwise
 */
function bool UploadProfileData(UniqueNetId UniqueId,string PlayerNick,OnlineProfileSettings ProfileSettings);

/**
 * Sends the data contained within the gameplay events object to the online server for statistics
 *
 * @param Events the object that has the set of events in it
 *
 * @return true if the async send started ok, false otherwise
 */
function bool UploadGameplayEventsData(OnlineGameplayEvents Events);

/**
 * Sends the hardware data to the server for statistics aggregation
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
function bool UpdatePlaylistPopulation(int PlaylistId,int NumPlayers);
