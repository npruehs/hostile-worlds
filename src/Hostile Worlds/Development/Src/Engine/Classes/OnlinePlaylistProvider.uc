/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Per object config provider that exposes dynamic playlists to the UI system
 */
class OnlinePlaylistProvider extends UIResourceDataProvider
	PerObjectConfig
	Config(Playlist);

/** Unique identifier for this Playlist */
var	config int PlaylistId;

/** List of the names of the OnlinePlaylistGameTypeProvider for the game modes supported by this playlist */
var config array<Name> PlaylistGameTypeNames;

/** Localized display name for the playlist */
var config localized string DisplayName;

/** Whether this playlist is arbitrated or not */
var config bool bIsArbitrated;

/** Value to determine sorting priority (highest is first in the list) */
var config int Priority;
