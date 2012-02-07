/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Parses a game stats file written to disk and uploads it to a database backend
 */
class GameStatsDBUploader extends GameplayEventsHandler
	native
	config(Game);

cpptext
{
	/** The function that does the actual handling of data (override with particular implementation) */
	virtual void HandleEvent(struct FGameEventHeader& GameEvent, class IGameEvent* GameEventData);

	/** Cleanup the native memory allocations */
	virtual void BeginDestroy();

private:
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FGameStringEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FGameIntEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FTeamIntEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FPlayerStringEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FPlayerIntEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FPlayerFloatEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FPlayerSpawnEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FPlayerLoginEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FPlayerLocationsEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FPlayerKillDeathEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FPlayerPlayerEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FWeaponIntEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FDamageIntEvent* GameEventData);
	void UploadEvent(struct FGameEventHeader& GameEvent, struct FProjectileIntEvent* GameEventData);
};

/** Helper to upload stats to a remote database */
var	const private native transient pointer DBUploader {struct FGameStatsRemoteDB};

/** A chance to do something after the stream ends */
native event PostProcessStream();

/** Upload all the serialized header/footer information */
native function bool UploadMetadata();

defaultproperties
{
}