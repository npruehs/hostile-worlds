//=============================================================================
// LocalPlayer
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class LocalPlayer extends Player
	within Engine
	config(Engine)
	native
	transient;

/** The controller ID which this player accepts input from. */
var int ControllerId;

/** The master viewport containing this player's view. */
var GameViewportClient ViewportClient;

/** The coordinates for the upper left corner of the master viewport subregion allocated to this player. 0-1 */
var vector2d Origin;

/** The size of the master viewport subregion allocated to this player. 0-1 */
var vector2d Size;

/** Chain of post process effects for this player view */
var const PostProcessChain PlayerPostProcess;
var const array<PostProcessChain> PlayerPostProcessChains;

var private native const pointer ViewState{FSceneViewStateInterface};

struct SynchronizedActorVisibilityHistory
{
	var pointer State;
	var pointer CriticalSection;
};

var private native transient const SynchronizedActorVisibilityHistory ActorVisibilityHistory;

/** The location of the player's view the previous frame. */
var transient vector LastViewLocation;

struct native CurrentPostProcessVolumeInfo
{
	/** Last pp settings used when blending to the next set of volume values. */
	var PostProcessSettings	LastSettings;
	/** The last post process volume that was applied to the scene */
	var PostProcessVolume LastVolumeUsed;
	/** Time when a new post process volume was set */
	var float BlendStartTime;
	/** Time when the settings blend was last updated. */
	var float LastBlendTime;
};

/** The Post Process value used  */
var const noimport transient CurrentPostProcessVolumeInfo CurrentPPInfo;

/** Baseline Level Post Process Info */
var const noimport transient CurrentPostProcessVolumeInfo LevelPPInfo; 


/** Delta between the override and the lower levels of the post process stack (level and camera) */
var PostProcessSettings OverridePPDeltaSettings;
/** Amount of time it takes to recover from the override post process effect */
var config float OverridePPRecoveryTime;
/** Time the override started */
var float OverridePPStartTime;
/** Time the override ended */
var float OverridePPEndTime;
/** Last value of the override opacity */
var float OverridePPOpacity;
/** Whether to override the post process settings or not */
var bool bOverridePostProcessSettings;
/** The post process settings to override to */
var PostProcessSettings PostProcessSettingsOverride;
/** Whether or not we are currently recovering from a post process override. */
var bool bRecoveryFromPostProcessOverride;


/** The last map this player remembers being on. Used to determine if the map has changed and the pp needs to be reset to default*/
var string LastMap;
/** Whether or not to use the next map's defaults and ditch the current pp settings */
var bool bWantToResetToMapDefaultPP;

/** set when we've sent a split join request */
var const editconst transient bool bSentSplitJoin;

cpptext
{
	/** Is object propagation currently overriding our view? */
	static UBOOL bOverrideView;
	static FVector OverrideLocation;
	static FRotator OverrideRotation;

	// Constructor.
	ULocalPlayer();

	/**
	 *	Rebuilds the PlayerPostProcessChain.
	 *	This should be called whenever the chain array has items inserted/removed.
	 */
	void RebuildPlayerPostProcessChain();

	/**
	 * Updates the post-process settings for the player's view.
	 * @param ViewLocation - The player's current view location.
	 */
	virtual void UpdatePostProcessSettings(const FVector& ViewLocation);
	
	/** Update a specific CurrentPostProcessVolumeInfo with the settings and volume specified 
	 *
	 *	@param PPInfo - The CurrentPostProcessVolumeInfo struct to update
	 *	@param NewSettings - The PostProcessSettings to apply to PPInfo
	 *	@param NewVolume - The PostProcessVolume to apply to PPInfo
	 */
	virtual void UpdatePPSetting(FCurrentPostProcessVolumeInfo& PPVolume, FPostProcessSettings& NewSettings, const FLOAT CurrentWorldTime);

	/**
	 * Calculate the view settings for drawing from this view actor
	 *
	 * @param	View - output view struct
	 * @param	ViewLocation - output actor location
	 * @param	ViewRotation - output actor rotation
	 * @param	Viewport - current client viewport
	 * @param	ViewDrawer - optional drawing in the view
	 */
	FSceneView* CalcSceneView( FSceneViewFamily* ViewFamily, FVector& ViewLocation, FRotator& ViewRotation, FViewport* Viewport, FViewElementDrawer* ViewDrawer=NULL );

	// UObject interface.
	virtual void FinishDestroy();

	// FExec interface.
	virtual UBOOL Exec(const TCHAR* Cmd,FOutputDevice& Ar);

	void ExecMacro( const TCHAR* Filename, FOutputDevice& Ar );

}

/**
 * Creates an actor for this player.
 * @param URL - The URL the player joined with.
 * @param OutError - If an error occurred, returns the error description.
 * @return False if an error occurred, true if the play actor was successfully spawned.
 */
native final function bool SpawnPlayActor(string URL,out string OutError);

/** sends a splitscreen join command to the server to allow a splitscreen player to connect to the game
 * the client must already be connected to a server for this function to work
 * @note this happens automatically for all viewports that exist during the initial server connect
 * 	so it's only necessary to manually call this for viewports created after that
 * if the join fails (because the server was full, for example) all viewports on this client will be disconnected
 */
native final function SendSplitJoin();

/**
 * Tests the visibility state of an actor in the most recent frame of this player's view to complete rendering.
 * @param TestActor - The actor to check visibility for.
 * @return True if the actor was visible in the frame.
 */
native final function bool GetActorVisibility(Actor TestActor) const;

/** Zeroes out the OverridePPDeltaSettings struct */
native final function ZeroOverridePPDeltaSettings();

/**
 * Overrides the current post process settings.
 */
simulated function OverridePostProcessSettings( PostProcessSettings OverrideSettings, float StartBlendTime )
{
	PostProcessSettingsOverride = OverrideSettings;
	//Only zero if we weren't already dealing with another override before this
	if (!bOverridePostProcessSettings && !bRecoveryFromPostProcessOverride)
	{
		ZeroOverridePPDeltaSettings();
	}
	bOverridePostProcessSettings = true;
	OverridePPStartTime = StartBlendTime;
}

/**
 * Update the override post process settings
 */
simulated function UpdateOverridePostProcessSettings( PostProcessSettings OverrideSettings )
{
	PostProcessSettingsOverride = OverrideSettings;
}

/**
 * Clear the overriding of the post process settings.
 *  If an override was occurring, this will cause it to fall into a recovery state if the RecoveryTime is greater than 0
 *  If an override recovery was occurring, then this will change the length of the currently occurring override recovery to the RecoveryTime
 * @param RecoveryTime - The amount of time you want to take to recover from the override you are clearing.
 */
simulated function ClearPostProcessSettingsOverride(optional float RecoveryTime = -1.0)
{
	if (bOverridePostProcessSettings || bRecoveryFromPostProcessOverride)
	{
		//Below 0 is invalid, use default value
		if (RecoveryTime < 0)
		{
			OverridePPRecoveryTime = default.OverridePPRecoveryTime;
		}
		else
		{
			OverridePPRecoveryTime = RecoveryTime;
		}
		bOverridePostProcessSettings = false;
		//If recovery time is 0, then we just kill it.
		if (OverridePPRecoveryTime == 0.0)
		{
			ZeroOverridePPDeltaSettings();
			bRecoveryFromPostProcessOverride = false;
		}
		else //we want to recover
		{
			//Only modify the end time if we weren't already recovering
			if (!bRecoveryFromPostProcessOverride)
			{
				bRecoveryFromPostProcessOverride = true;
				OverridePPEndTime = -1.0;
			}
		}
	}
}

/**
 * Changes the ControllerId for this player; if the specified ControllerId is already taken by another player, changes the ControllerId
 * for the other player to the ControllerId currently in use by this player.
 *
 * @param	NewControllerId		the ControllerId to assign to this player.
 */
final function SetControllerId( int NewControllerId )
{
	local LocalPlayer OtherPlayer;
	local int CurrentControllerId;

	if ( ControllerId != NewControllerId )
	{
		`log(Name @ "changing ControllerId from" @ ControllerId @ "to" @ NewControllerId,,'PlayerManagement');

		// first, unregister the player's data stores if we already have a PlayerController.
		if ( Actor != None )
		{
			Actor.PreControllerIdChange();
		}

		CurrentControllerId = ControllerId;

		// set this player's ControllerId to -1 so that if we need to swap controllerIds with another player we don't
		// re-enter the function for this player.
		ControllerId = -1;

		// see if another player is already using this ControllerId; if so, swap controllerIds with them
		OtherPlayer = ViewportClient.FindPlayerByControllerId(NewControllerId);
		if ( OtherPlayer != None )
		{
			OtherPlayer.SetControllerId(CurrentControllerId);
		}

		ControllerId = NewControllerId;
		if ( Actor != None )
		{
			Actor.PostControllerIdChange();
		}
	}
}

/**
 * Add the given post process chain to the chain at the given index.
 *
 *	@param	InChain		The post process chain to insert.
 *	@param	InIndex		The position to insert the chain in the complete chain.
 *						If -1, insert it at the end of the chain.
 *	@param	bInClone	If TRUE, create a deep copy of the chains effects before insertion.
 *
 *	@return	boolean		TRUE if the chain was inserted
 *						FALSE if not
 */
native function bool InsertPostProcessingChain(PostProcessChain InChain, int InIndex, bool bInClone);

/**
 * Remove the post process chain at the given index.
 *
 *	@param	InIndex		The position to insert the chain in the complete chain.
 *
 *	@return	boolean		TRUE if the chain was removed
 *						FALSE if not
 */
native function bool RemovePostProcessingChain(int InIndex);

/**
 * Remove all post process chains.
 *
 *	@return	boolean		TRUE if the chain array was cleared
 *						FALSE if not
 */
native function bool RemoveAllPostProcessingChains();

/**
 *	Get the PPChain at the given index.
 *
 *	@param	InIndex				The index of the chain to retrieve.
 *
 *	@return	PostProcessChain	The post process chain if found; NULL if not.
 */
native function PostProcessChain GetPostProcessChain(int InIndex);

/**
 *	Forces the PlayerPostProcess chain to be rebuilt.
 *	This should be called if a PPChain is retrieved using the GetPostProcessChain,
 *	and is modified directly.
 */
native function TouchPlayerPostProcessChain();

/** transforms 2D screen coordinates into a 3D world-space origin and direction
 * @note: use the Canvas version where possible as it already has the necessary information,
 *	whereas this function must gather it and is therefore slower
 * @param ScreenPos - relative screen coordinates (0 to 1, relative to this player's viewport region)
 * @param WorldOrigin (out) - world-space origin vector
 * @param WorldDirection (out) - world-space direction vector
 */
native final function DeProject(vector2D RelativeScreenPos, out vector WorldOrigin, out vector WorldDirection);

/** retrieves this player's unique net ID from the online subsystem */
final event UniqueNetId GetUniqueNetId()
{
	local UniqueNetId Result;
	local GameEngine TheEngine;

	TheEngine = GameEngine(Outer);
	if (TheEngine != None && TheEngine.OnlineSubsystem != None && TheEngine.OnlineSubsystem.PlayerInterface != None)
	{
		TheEngine.OnlineSubsystem.PlayerInterface.GetUniquePlayerId(ControllerId, Result);
	}

	return Result;
}
/** retrieves this player's name/tag from the online subsytem
 * if this function returns a non-empty string, the returned name will replace the "Name" URL parameter
 * passed around in the level loading and connection code, which normally comes from DefaultEngine.ini
 */
final event string GetNickname()
{
	local GameEngine TheEngine;

	TheEngine = GameEngine(Outer);
	if (TheEngine != None && TheEngine.OnlineSubsystem != None && TheEngine.OnlineSubsystem.PlayerInterface != None)
	{
		return TheEngine.OnlineSubsystem .PlayerInterface.GetPlayerNickname(ControllerId);
	}
	else
	{
		return "";
	}
}

defaultproperties
{
	bOverridePostProcessSettings=false
}
