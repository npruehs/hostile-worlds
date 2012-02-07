/**
 * UTPlayerController
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTPlayerController extends UDKPlayerController
	dependson(UTPawn)
	dependson(UTProfileSettings)
	dependson(UTPlayerReplicationInfo)
	config(Game);

`include(UTOnlineConstants.uci)

var					bool	bLateComer;
var					bool	bIsTyping;

var globalconfig	bool	bAutoTaunt;

/** Set to team this player has been identified (with announcement) as being on */
var					byte	IdentifiedTeam;

/** If true, switch to vehicle's rotation when possessing it (except for roll) */
var	globalconfig	bool	bUseVehicleRotationOnPossess;

var bool	bViewingMap;

/** If true, HUD minimap is zoomed and rotates around player */
var bool bRotateMinimap;

/** Used to keep spectator cameras from going out of world boundaries */
var bool	bCameraOutOfWorld;

var globalconfig enum EPawnShadowMode
{
	SHADOW_None,
	SHADOW_Self,
	SHADOW_All
} PawnShadowMode;

var globalconfig bool bFirstPersonWeaponsSelfShadow;

var		bool	bBehindView;

/** if true, while in the spectating state, behindview will be forced on a player */
var bool bForceBehindView;

var bool bFreeCamera;

enum EWeaponHand
{
	HAND_Right,
	HAND_Left,
	HAND_Centered,
	HAND_Hidden,
};
var globalconfig EWeaponHand WeaponHandPreference;
var EWeaponHand	WeaponHand;

var vector		DesiredLocation;

var UTAnnouncer Announcer;
var UTMusicManager MusicManager;

var globalconfig	bool			bNoTextToSpeechVoiceMessages;
var globalconfig	bool			bTextToSpeechTeamMessagesOnly;

var float LastTauntAnimTime;
var float LastKickWarningTime;

var localized string MsgPlayerNotFound;

/** set when the last camera anim we played was caused by damage - we only let damage shakes override other damage shakes */
var bool bCurrentCamAnimIsDamageShake;
/** set if camera anim modifies FOV - don't do any FOV interpolation while camera anim is playing */
var bool bCurrentCamAnimAffectsFOV;
/** Vibration  */
var ForceFeedbackWaveform CameraShakeShortWaveForm, CameraShakeLongWaveForm;


/** camera anim played when hit (blend strength depends on damage taken) */
var CameraAnim DamageCameraAnim;

var globalconfig	bool	bLandingShake;

var float LastCameraTimeStamp; /** Used during matinee sequences */
var class<Camera> MatineeCameraClass;

var config bool bCenteredWeaponFire;

/** cached result of GetPlayerViewPoint() */
var Actor CalcViewActor;
var vector CalcViewActorLocation;
var rotator CalcViewActorRotation;
var vector CalcViewLocation;
var rotator CalcViewRotation;
var float CalcEyeHeight;
var vector CalcWalkBob;

/** Last time a warning about a shot being fired at my pawn was accepted. */
var float	LastWarningTime;

/** How fast (degrees/sec) should a zoom occur */
var float FOVLinearZoomRate;

/** If TRUE, FOV interpolation for zooming is nonlineear, using FInterpTo.  If FALSE, use linear interp. */
var transient bool bNonlinearZoomInterpolation;

/** Interp speed (as used in FInterpTo) for nonlinear FOV interpolation. */
var transient float FOVNonlinearZoomInterpSpeed;

/** Used to scale changes in rotation when the FOV is zoomed */
var float ZoomRotationModifier;

/** Whether or not we should retrieve settings from the profile on next tick. */
var transient bool bRetrieveSettingsFromProfileOnNextTick;

/** Whether or not we are quitting to the main menu. */
var transient bool bQuittingToMainMenu;

/** vars for debug freecam, which allows camera to view player from all angles */
var transient bool		bDebugFreeCam;
var transient rotator	DebugFreeCamRot;

/** last time ServerShowPathToBase() was executed, to avoid spamming the world with path effects */
var float LastShowPathTime;

/** enum for the various options for the game telling the player what to do next */
enum EAutoObjectivePreference
{
	AOP_Disabled, // turned off
	AOP_NoPreference,
	AOP_Attack, // tell what to do to attack
	AOP_Defend, // tell what to do to defend
	AOP_OrbRunner,
	AOP_SpecialOps,

};
var globalconfig EAutoObjectivePreference AutoObjectivePreference;

/** last objective CheckAutoObjective() sent a notification about */
var Actor LastAutoObjective;

/** Indicates what control mode is desired for vehicles. */
var EUTVehicleControls	VehicleControlType;

/** Set when use fails to enter nearby vehicle (to prevent smart use from also putting you on hoverboard) */
var bool bJustFoundVehicle;

/** Holds the template for the command menu */
var UTUIScene_CommandMenu CommandMenuTemplate;
var UTUIScene_CommandMenu CommandMenu;

/** Holds the current Map Scene */
var UTUIScene CurrentMapScene;

/** Struct to define values for different post processing presets. */
struct native PostProcessInfo
{
	var float Shadows;
	var float MidTones;
	var float HighLights;
	var float Desaturation;
};

/** Array of possible preset values for post process. */
var transient array<PostProcessInfo>	PostProcessPresets;

/** Last bullseye announcement (hacky - don't want multiple close together) */
var float LastBullseyeTime;

/** Last "use" time - used to limit "use" frequency */
var	float	LastUseTime;

/** to limit frequency of voice messages */
var float OldMessageTime;

/** To limit frequency of received "friendly fire" voice messages */
var float LastFriendlyFireTime;

/** The data store that holds data needed to translate bound input events to strings for UI */
var UTUIDataStore_StringAliasBindingsMap BoundEventsStringDataStore;

var config bool bNoCrosshair;

var config bool bSimpleCrosshair;

var bool bAlreadyReset;

var float NextAdminCmdTime;

var globalconfig float OnFootDefaultFOV;

/** Last time "incoming" message was received by this player */
var float LastIncomingMessageTime;

/** Last time combat update message was received by this player */
var float LastCombatUpdateTime;

/** Used to prevent too frequent team changes */
var float LastTeamChangeTime;

/** If true, the server has muted all text chat from this player */
var bool bServerMutedText;

/** If true, don't show the path arrows to your objective */
var globalconfig bool bHideObjectivePaths;

/** If true, and have profile, load settings from it */
var bool bShouldLoadSettingsFromProfile;


/**
 * Change Camera mode - only in single player
 *
 * @param	New camera mode to set
 */
exec function Camera( name NewMode )
{
	if ( WorldInfo.NetMode == NM_Standalone )
	{
		ServerCamera(NewMode);
	}
}

reliable server function ServerThrowWeapon()
{
    if ( Pawn.CanThrowWeapon() )
    {
		Pawn.ThrowActiveWeapon();
    }
}

exec function SwitchHud()
{
	local class<HUD> NewHUDClass;

	`log("SWITCHEROO THE HUD "$WorldInfo.GRI.GameClass);
	NewHUDClass = WorldInfo.GRI.GameClass.Default.HUDType;
	if ( UTGFxHUDWrapper(myHUD) == None )
	{
		NewHUDClass = WorldInfo.GRI.GameClass.Default.bTeamGame ? class'UTGFxTeamHudWrapper' : class'UTGFxHudWrapper';
	}
	ClientSetHud(NewHUDClass);
}

event InitInputSystem()
{
	local LocalPlayer LP;

	LP = LocalPlayer(Player);

	Super.InitInputSystem();

	AddOnlineDelegates(true);

	// we do this here so that we only bother to create it for local players
	CameraAnimPlayer = new(self) class'CameraAnimInst';

	// see if character processing was already completed
	// this can happen on clients if a PlayerController class switch is performed
	// and the GRI is received before the new PlayerController
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		CharacterProcessingComplete();
	}

	if (WorldInfo.NetMode == NM_ListenServer && PlayerReplicationInfo != none )
	{
		PlayerReplicationInfo.IsInvalidName();
	}

	if (bDedicatedServerSpectator)
	{
		LP.ViewportClient.bDisableWorldRendering = true;
	}
	else
	{
		SaveServerToHistory();
	}

	// reset the post processing when we get a new PC
	LP.RemoveAllPostProcessingChains();
	LP.InsertPostProcessingChain(LP.Outer.GetWorldPostProcessChain(), INDEX_NONE, true);

}

/**
 * Saves the UniqueNetId for the current server to the player's list of recently visited servers (server history).
 */
function SaveServerToHistory()
{
	local LocalPlayer LP;
	local OnlineGameSettings CurrentGameSettings;
	local UTDataStore_GameSearchHistory HistoryDataStore;

	LP = LocalPlayer(Player);

	// we've successfully joined an online match - add this server's unique PlayerId to the list of recently joined matches
	if ( WorldInfo.NetMode == NM_Client && LP != None && OnlineSub != None && OnlineSub.GameInterface != None && OnlineSub.PlayerInterface != None )
	{
		CurrentGameSettings = OnlineSub.GameInterface.GetGameSettings('Game');
		if ( CurrentGameSettings != None )
		{
			HistoryDataStore = UTDataStore_GameSearchHistory(class'UTUIScene'.static.FindDataStore('UTGameHistory', LP));
			if ( HistoryDataStore != None )
			{
				HistoryDataStore.AddServer(LP.ControllerId, CurrentGameSettings.OwningPlayerId);
			}
		}
	}
}

event PlayerTick( float DeltaTime )
{
	Super.PlayerTick(DeltaTime);

	// This needs to be done here because it ensures that all datastores have been registered properly
	// it also ensures we do not update the profile settings more than once.
	if( bRetrieveSettingsFromProfileOnNextTick )
	{
		RetrieveSettingsFromProfile();
		bRetrieveSettingsFromProfileOnNextTick = FALSE;
	}
}

/** Called from the UTTeamGameMessage, this will cause all TeamColored Images on the hud to pulse. */
function PulseTeamColor()
{
	PulseTimer = default.PulseTimer;
	bPulseTeamColor = true;
}

/** tells the server about the character this player is using */
reliable server function ServerSetCharacterClass(class<UTFamilyInfo> CharClass)
{
	local UTTeamInfo Team;
	local UTPlayerReplicationInfo PRI;

	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);

	PRI.CharClassInfo = CharClass;

	// force bots on player's team to be same faction
	if ((WorldInfo.NetMode == NM_Standalone || WorldInfo.NetMode == NM_ListenServer) && IsLocalPlayerController())
	{
		Team = UTTeamInfo(PlayerReplicationInfo.Team);
		if (Team != None)
		{
			Team.Faction = PRI.CharClassInfo.default.Faction;
		}
	}
}

/** Clear the contents of the command to bind key cache */
simulated function ClearStringAliasBindingMapCache()
{
	BoundEventsStringDataStore.ClearBoundKeyCache();
}

/**
* Creates and initializes the "PlayerOwner" and "PlayerSettings" data stores.  This function assumes that the PlayerReplicationInfo
* for this player has not yet been created, and that the PlayerOwner data store's PlayerDataProvider will be set when the PRI is registered.
*
* Overloaded so we can initialize game specific player data stores.
*/
simulated protected function RegisterCustomPlayerDataStores()
{
	local LocalPlayer LP;
	local DataStoreClient DataStoreManager;
	local class<UTUIDataStore_StringAliasBindingsMap> StringAliasBindingsMapDataStoreClass;

`if(`notdefined(FINAL_RELEASE))
	local string PlayerName;

	PlayerName = PlayerReplicationInfo != None ? PlayerReplicationInfo.PlayerName : "None";
`endif


	// only create player data store for local players
	LP = LocalPlayer(Player);

	`log(">>" @ `location @ "(" $ PlayerName $ ")" @ `showobj(LP),,'DevDataStore');
	Super.RegisterCustomPlayerDataStores();

	if ( LP != None )
	{
		`log(">> UTPlayerController::RegisterCustomPlayerDataStores -" @ Self @ "(" $ PlayerName $ ")",,'DevDataStore');

		// get a reference to the main data store client
		DataStoreManager = class'UIInteraction'.static.GetDataStoreClient();
		if ( DataStoreManager != None )
		{
			// find the "PlayerOwner" data store registered for this player; there shouldn't be one...
			BoundEventsStringDataStore = UTUIDataStore_StringAliasBindingsMap(DataStoreManager.FindDataStore('StringAliasBindings',LP));
			if ( BoundEventsStringDataStore == None )
			{
				// find the appropriate class to use for the PlayerSettings data store
				StringAliasBindingsMapDataStoreClass = class<UTUIDataStore_StringAliasBindingsMap>(DataStoreManager.FindDataStoreClass(class'UTUIDataStore_StringAliasBindingsMap'));
				if ( StringAliasBindingsMapDataStoreClass != None )
				{
					// create the PlayerOwner data store
					BoundEventsStringDataStore = DataStoreManager.CreateDataStore(StringAliasBindingsMapDataStoreClass);
					if ( BoundEventsStringDataStore != None )
					{
						// and register it
						if ( !DataStoreManager.RegisterDataStore(BoundEventsStringDataStore, LP) )
						{
							`log("Failed to register 'StringAliasBindings' data store for player:"@ Self @ "(" $ PlayerName $ ")");
						}
					}
					else
					{
						`log("Failed to create 'StringAliasBindings' data store for player:"@ Self @ "(" $ PlayerName $ ") using class" @ StringAliasBindingsMapDataStoreClass,,'DevDataStore');
					}
				}
			}
			else
			{
				`log("'StringAliasBindings' data store already registered for player:"@ Self @ "(" $ PlayerName $ ")",,'DevDataStore');
			}
		}
	}

	`log("<<" @ `location @ "(" $ PlayerName $ ")",,'DevDataStore');
}

/**
* Unregisters the "PlayerOwner" data store for this player.  Called when this PlayerController is destroyed.
*
* Overloaded so we can unregister game specific player data stores.
*/
simulated function UnregisterPlayerDataStores()
{
	local LocalPlayer LP;
	local DataStoreClient DataStoreManager;

`if(`notdefined(FINAL_RELEASE))
	local string PlayerName;

	PlayerName = PlayerReplicationInfo != None ? PlayerReplicationInfo.PlayerName : "None";
`endif

	// only execute for local players
	LP = LocalPlayer(Player);
	if ( LP != None )
	{
		`log(">> UTPlayerController::UnregisterPlayerDataStores -" @ Self @ "(" $ PlayerName $ ")",,'DevDataStore');

		// unregister it from the data store client and clear our reference
		// get a reference to the main data store client
		DataStoreManager = class'UIInteraction'.static.GetDataStoreClient();
		if ( DataStoreManager != None )
		{
			// unregister the bound events string data store
			if ( BoundEventsStringDataStore != None )
			{
				if ( !DataStoreManager.UnregisterDataStore(BoundEventsStringDataStore) )
				{
					`log("Failed to unregister 'StringAliasBindings' data store for player:"@ Self @ "(" $ PlayerName $ ")");
				}

				// clear the reference
				BoundEventsStringDataStore = None;
			}
			else
			{
				`log("'StringAliasBindings' data store not registered for player:" @ Self @ "(" $ PlayerName $ ")",,'DevDataStore');
			}
		}
		else
		{
			`log("Data store client not found!",,'DevDataStore');
		}

		`log("<< UTPlayerController::UnregisterPlayerDataStores" @ "(" $ PlayerName $ ")",,'DevDataStore');
	}

	Super.UnregisterPlayerDataStores();
}

/** Sets online delegates to respond to for this PC. */
function AddOnlineDelegates(bool bRegisterVoice)
{
	// this is done automatically in net games so only need to call it for standalone.
	if (bRegisterVoice && WorldInfo.NetMode == NM_Standalone && VoiceInterface != None)
	{
		VoiceInterface.RegisterLocalTalker(LocalPlayer(Player).ControllerId);
		VoiceInterface.AddRecognitionCompleteDelegate(LocalPlayer(Player).ControllerId, SpeechRecognitionComplete);
	}

	// Register a callback for when the profile finishes reading.
	if (OnlineSub != None)
	{
		if (OnlineSub.PlayerInterface != None)
		{
			OnlineSub.PlayerInterface.AddReadProfileSettingsCompleteDelegate(LocalPlayer(Player).ControllerId, OnReadProfileSettingsComplete);
			OnlineSub.PlayerInterface.AddFriendInviteReceivedDelegate(LocalPlayer(Player).ControllerId,OnFriendInviteReceived);
			OnlineSub.PlayerInterface.AddReceivedGameInviteDelegate(LocalPlayer(Player).ControllerId,OnGameInviteReceived);
			OnlineSub.PlayerInterface.AddFriendMessageReceivedDelegate(LocalPlayer(Player).ControllerId,OnFriendMessageReceived);
		}

		if(OnlineSub.SystemInterface != None)
		{
			OnlineSub.SystemInterface.AddConnectionStatusChangeDelegate(OnConnectionStatusChange);
			OnlineSub.SystemInterface.AddLinkStatusChangeDelegate(OnLinkStatusChanged);

			// Do an initial controller check
			if(OnlineSub.SystemInterface.IsControllerConnected(LocalPlayer(Player).ControllerId)==false)
			{
				OnControllerChanged(LocalPlayer(Player).ControllerId, false);
			}
		}
	}
}

/** Clears previously set online delegates. */
event ClearOnlineDelegates()
{
	local LocalPlayer LP;

	Super.ClearOnlineDelegates();

	LP = LocalPlayer(Player);
	if ( OnlineSub != None
	&&	(Role < ROLE_Authority || LP != None))
	{
		if (LP != None)
		{
			if (VoiceInterface != None)
			{
				VoiceInterface.ClearRecognitionCompleteDelegate(LP.ControllerId, SpeechRecognitionComplete);
				// Only unregister voice support if we aren't traveling to a MP game
				if (OnlineSub.GameInterface == None ||
					(OnlineSub.GameInterface != None && OnlineSub.GameInterface.GetGameSettings('Game') == None))
				{
					VoiceInterface.UnregisterLocalTalker(LP.ControllerId);
				}
			}

			if (OnlineSub.PlayerInterface != None)
			{
				OnlineSub.PlayerInterface.ClearReadProfileSettingsCompleteDelegate(LP.ControllerId, OnReadProfileSettingsComplete);
				OnlineSub.PlayerInterface.ClearFriendInviteReceivedDelegate(LP.ControllerId,OnFriendInviteReceived);
				OnlineSub.PlayerInterface.ClearReceivedGameInviteDelegate(LP.ControllerId,OnGameInviteReceived);
				OnlineSub.PlayerInterface.ClearFriendMessageReceivedDelegate(LP.ControllerId,OnFriendMessageReceived);
			}
		}

		if(OnlineSub.SystemInterface != None)
		{
			OnlineSub.SystemInterface.ClearConnectionStatusChangeDelegate(OnConnectionStatusChange);
			OnlineSub.SystemInterface.ClearLinkStatusChangeDelegate(OnLinkStatusChanged);
		}
	}
}

/**
 * Looks at the current game state and uses that to set the
 * rich presence strings
 *
 * Licensees should override this in their player controller derived class
 */
reliable client function ClientSetOnlineStatus()
{
	local LocalPlayer LP;
	local array<LocalizedStringSetting> StringSettings;
	local array<SettingsProperty> Properties;
	local OnlineGameSettings GameSettings;
	local string MapName;
	local string GameName;

	LP = LocalPlayer(Player);

	// If we are not a client, then set the game settings object info also.
	if( OnlineSub.GameInterface != None &&
		WorldInfo.NetMode != NM_Client)
	{
		GameSettings=OnlineSub.GameInterface.GetGameSettings('Game');
		if(GameSettings != None)
		{
			MapName = WorldInfo.GetMapName();
			GameName = WorldInfo.GetGameClass().default.Outer.name$"."$WorldInfo.GetGameClass().name;

			GameSettings.SetPropertyFromStringByName('CustomMapName', MapName);
			GameSettings.SetPropertyFromStringByName('CustomGameMode', GameName);

			if(GameSettings.bIsLanMatch==false && OnlineSub.GameInterface.UpdateOnlineGame('Game',GameSettings)==false)
			{
				`Log("UTPlayerController::ClientSetOnlineStatus() - Error occured updating online game settings.");
			}
		}
	}

	//@todo: Hook this up properly.
	OnlineSub.PlayerInterface.SetOnlineStatus(LP.ControllerId, 0, StringSettings, Properties);
}

`if(`notdefined(ShippingPC))
`define	debugexec exec
`else
`define debugexec
`endif

/**
 * Called when a system level connection change notification occurs. If we are
 * playing a Live match, we may need to notify and go back to the menu. Otherwise
 * silently ignore this.
 *
 * @param ConnectionStatus the new connection status.
 */
`{debugexec} function OnConnectionStatusChange(EOnlineServerConnectionStatus ConnectionStatus)
{
	local GameUISceneClient SceneClient;
	local OnlineGameSettings GameSettings;
	local bool bInvalidConnectionStatus;

	// We need to always bail in this case
	if (ConnectionStatus == OSCS_DuplicateLoginDetected)
	{
		// Two people can't play or badness will happen
		`Log("Detected another user logging-in with this profile.");
		SetFrontEndErrorMessage("<Strings:UTGameUI.Errors.DuplicateLogin_Title>",
			"<Strings:UTGameUI.Errors.DuplicateLogin_Message>");

		bInvalidConnectionStatus = true;
	}
	else
	{
		// Only care about this if we aren't in a standalone netmode.
		if(WorldInfo.NetMode != NM_Standalone)
		{
			// We know we have an online subsystem or this delegate wouldn't be called
			GameSettings = OnlineSub.GameInterface.GetGameSettings('Game');
			if (GameSettings != None)
			{
				// If we are a internet match, this really matters
				if (!GameSettings.bIsLanMatch)
				{
					// We are playing a internet match. Determine whether the connection
					// status change requires us to drop and go to the menu
					switch (ConnectionStatus)
					{
					case OSCS_ConnectionDropped:
					case OSCS_NoNetworkConnection:
					case OSCS_ServiceUnavailable:
					case OSCS_UpdateRequired:
					case OSCS_ServersTooBusy:
					case OSCS_NotConnected:
						SetFrontEndErrorMessage("<Strings:UTGameUI.Errors.ConnectionLost_Title>",
							"<Strings:UTGameUI.Errors.ConnectionLost_Message>");
						bInvalidConnectionStatus = true;
						break;
					}
				}
			}
		}
	}

	// notify the UI scene client, which will propagate the notification to all scenes.  Any scenes
	// which require a valid online service will close themselves.
	SceneClient = class'UIRoot'.static.GetSceneClient();
	if ( SceneClient != None )
	{
		SceneClient.NotifyOnlineServiceStatusChanged(ConnectionStatus);
	}

	`log(`location@`showenum(EOnlineServerConnectionStatus,ConnectionStatus)@`showvar(bInvalidConnectionStatus),,'DevOnline');
	if ( bInvalidConnectionStatus )
	{
		QuitToMainMenu();
	}
}

/**
 * Called when the platform's network link status changes.  If we are playing a match on a remote server, we need to go back
 * to the front end menus and notify the player.
 */
`{debugexec} function OnLinkStatusChanged( bool bConnected )
{
	local GameUISceneClient SceneClient;
	local string ErrorDisplay;

	`log(`location@`showvar(bConnected),,'DevNet');

	// notify the UI scene client, which will propagate the notification to all scenes.  Any scenes
	// which require a valid network connection will close themselves.
	SceneClient = class'UIRoot'.static.GetSceneClient();
	if ( SceneClient != None )
	{
		SceneClient.NotifyLinkStatusChanged(bConnected);
	}

	if ( !bConnected && WorldInfo != None && WorldInfo.Game != None)
	{
		// Don't quit to main menu if we are playing instant action
		if (WorldInfo.NetMode != NM_Standalone)
		{
			// if we're no longer connected to the network, check to see if another error message has been set
			// only display our message if none are currently set.
			if (!class'UIRoot'.static.GetDataStoreStringValue("<Registry:FrontEndError_Display>", ErrorDisplay)
			||	int(ErrorDisplay) == 0 )
			{
				SetFrontEndErrorMessage("<Strings:UTGameUI.Errors.Error_Title>", "<Strings:UTGameUI.Errors.NetworkLinkLost_Message>");
				QuitToMainMenu();
			}
		}
	}
}

/** Callback for when the profile finishes reading for this PC. */
function OnReadProfileSettingsComplete(byte LocalUserNum,bool bWasSuccessful)
{
	if (bWasSuccessful)
	{
		bRetrieveSettingsFromProfileOnNextTick=TRUE;
	}
}

/** Callback for when a game invite has been received. */
function OnGameInviteReceived(byte LocalUserNum,string RequestingNick)
{
}

/** Callback for when a friend request has been received. */
function OnFriendInviteReceived(byte LocalUserNum,UniqueNetId RequestingPlayer,string RequestingNick,string Message)
{
}

/**
 * Called when a friend invite arrives for a local player
 *
 * @param LocalUserNum the user that is receiving the invite
 * @param SendingPlayer the player sending the friend request
 * @param SendingNick the nick of the player sending the friend request
 * @param Message the message to display to the recipient
 *
 * @return true if successful, false otherwise
 */
function OnFriendMessageReceived(byte LocalUserNum,UniqueNetId SendingPlayer,string SendingNick,string Message)
{
}

/** Override to display a message to the user */
function NotifyInviteFailed()
{
	Super.NotifyInviteFailed();
	SetFrontEndErrorMessage("<Strings:UTGameUI.Errors.UnableToJoinInvite_Title>",
		"<Strings:UTGameUI.Errors.UnableToJoinInvite_Message>");
	QuitToMainMenu();
}

/** Override to display a message to the user */
function NotifyNotAllPlayersCanJoinInvite()
{
	Super.NotifyNotAllPlayersCanJoinInvite();
	SetFrontEndErrorMessage("<Strings:UTGameUI.Errors.NotAllPlayersCanJoin_Title>",
		"<Strings:UTGameUI.Errors.NotAllPlayersCanJoin_Message>");
	QuitToMainMenu();
}

/** Override to display a message to the user */
function NotifyNotEnoughSpaceInInvite()
{
	Super.NotifyNotEnoughSpaceInInvite();
	SetFrontEndErrorMessage("<Strings:UTGameUI.Errors.NotEnoughInviteSpace_Title>",
		"<Strings:UTGameUI.Errors.NotEnoughInviteSpace_Message>");
	QuitToMainMenu();
}

reliable client function ClientWasKicked()
{
	ClientSetProgressMessage(PMT_ConnectionFailure, Localize("AccessControl", "KickedMsg", "Engine"));
}

/**
 * Sets a error message in the registry datastore that will display to the user the next time they are in the frontend.
 *
 * @param Title		Title of the messagebox.
 * @param Message	Message of the messagebox.
 */
static function SetFrontEndErrorMessage(string Title, string Message)
{
	class'UIRoot'.static.SetDataStoreStringValue("<Registry:FrontEndError_Title>", Title);
	class'UIRoot'.static.SetDataStoreStringValue("<Registry:FrontEndError_Message>", Message);
	class'UIRoot'.static.SetDataStoreStringValue("<Registry:FrontEndError_Display>", "1");
}

/** Called when returning to the main menu. */
function QuitToMainMenu()
{
	bQuittingToMainMenu = true;

	if(CleanupOnlineSubsystemSession(true)==false)
	{
		`Log("UTPlayerController::QuitToMainMenu() - Online cleanup failed, finishing quit.");
		FinishQuitToMainMenu();
	}
}

/** Called after onlinesubsystem game cleanup has completed. */
function FinishQuitToMainMenu()
{
	// stop any movies currently playing before we quit out
	class'Engine'.static.StopMovie(true);

	// Call disconnect to force us back to the menu level
	ConsoleCommand("Disconnect");

	`Log("------ QUIT TO MAIN MENU --------");
}

/** Cleans up online subsystem game sessions and posts stats if the match is arbitrated. */
function bool CleanupOnlineSubsystemSession(bool bWasFromMenu)
{
	//local int Item;

	if (WorldInfo.NetMode != NM_Standalone &&
		OnlineSub != None &&
		OnlineSub.GameInterface != None &&
		OnlineSub.GameInterface.GetGameSettings('Game') != None)
	{
		// Set the end delegate so we can know when that is complete and call destroy
		OnlineSub.GameInterface.AddEndOnlineGameCompleteDelegate(OnEndOnlineGameComplete);
		OnlineSub.GameInterface.EndOnlineGame('Game');

		return true;
	}

	return false;
}

/**
 * Called when the online game has finished ending.
 */
function OnEndOnlineGameComplete(name SessionName,bool bWasSuccessful)
{
	OnlineSub.GameInterface.ClearEndOnlineGameCompleteDelegate(OnEndOnlineGameComplete);

	if(bQuittingToMainMenu)
	{
		// Set the destroy delegate so we can know when that is complete
		OnlineSub.GameInterface.AddDestroyOnlineGameCompleteDelegate(OnDestroyOnlineGameComplete);

		// Now we can destroy the game
		if ( !OnlineSub.GameInterface.DestroyOnlineGame('Game') )
		{
			OnDestroyOnlineGameComplete('Game',true);
		}
	}
}

/**
 * Called when the destroy online game has completed. At this point it is safe
 * to travel back to the menus
 *
 * @param SessionName the name of the session the event is for
 * @param bWasSuccessful whether it worked ok or not
 */
function OnDestroyOnlineGameComplete(name SessionName,bool bWasSuccessful)
{
	OnlineSub.GameInterface.ClearDestroyOnlineGameCompleteDelegate(OnDestroyOnlineGameComplete);
	FinishQuitToMainMenu();
}

reliable client function ClientSetSpeechRecognitionObject(SpeechRecognition NewRecognitionData)
{
	if (VoiceInterface != None)
	{
		VoiceInterface.SetSpeechRecognitionObject(LocalPlayer(Player).ControllerId, NewRecognitionData);
	}
}

/** set to VoiceInterface's speech recognition delegate; called when words are recognized */
function SpeechRecognitionComplete()
{
	local array<SpeechRecognizedWord> Words;
	local SpeechRecognizedWord ReplicatedWords[3];
	local int i;
//	local String DebugStr;

	VoiceInterface.GetRecognitionResults(LocalPlayer(Player).ControllerId, Words);

	if (Words.length > 0)
	{
		for (i = 0; i < 3 && i < Words.length; i++)
		{
			ReplicatedWords[i] = Words[i];
//			DebugStr = DebugStr @ Words[i].WordText;
//			`log(WorldInfo.TimeSeconds@"recognized word"@Words[i].WordText);
		}

//		TeamMessage(PlayerReplicationInfo, DebugStr, 'Say', 8.f);

		ServerProcessSpeechRecognition(ReplicatedWords);
	}
}

reliable server function ServerProcessSpeechRecognition(SpeechRecognizedWord ReplicatedWords[3])
{
	local array<SpeechRecognizedWord> Words;
	local int i;
	local UTGame Game;

	Game = UTGame(WorldInfo.Game);
	if (Game != None)
	{
		for (i = 0; i < 3; i++)
		{
			if (ReplicatedWords[i].WordText != "")
			{
				Words[Words.length] = ReplicatedWords[i];
			}
		}

		Game.ProcessSpeechRecognition(self, Words);
	}
}

/** turns on/off voice chat/recognition */
exec function ToggleSpeaking(bool bNowOn)
{
	local LocalPlayer LP;

	if (VoiceInterface != None)
	{
		LP = LocalPlayer(Player);
		if (LP != None)
		{
			if (bNowOn)
			{
				VoiceInterface.StartNetworkedVoice(LP.ControllerId);
				if ( WorldInfo.NetMode != NM_Client )
				{
					VoiceInterface.StartSpeechRecognition(LP.ControllerId);
				}
			}
			else
			{
				VoiceInterface.StopNetworkedVoice(LP.ControllerId);
				if ( WorldInfo.NetMode != NM_Client )
				{
					VoiceInterface.StopSpeechRecognition(LP.ControllerId);
				}
			}
		}
	}
}

/* ClientHearSound()
Replicated function from server for replicating audible sounds played on server
UTPlayerController implementation considers sounds from its pawn as local, even if the pawn is not the viewtarget
*/
unreliable client event ClientHearSound(SoundCue ASound, Actor SourceActor, vector SourceLocation, bool bStopWhenOwnerDestroyed, optional bool bIsOccluded )
{
	local AudioComponent AC;

	if ( SourceActor == None )
	{
		AC = GetPooledAudioComponent(ASound, SourceActor, bStopWhenOwnerDestroyed, true, SourceLocation);
		if (AC == None)
		{
			return;
		}
		AC.bUseOwnerLocation = false;
		AC.Location = SourceLocation;
	}
	else if ( (SourceActor == GetViewTarget()) || (SourceActor == self) || (SourceActor == Pawn) )
	{
		AC = GetPooledAudioComponent(ASound, None, bStopWhenOwnerDestroyed);
		if (AC == None)
		{
			return;
		}
		AC.bAllowSpatialization = false;
	}
	else
	{
		AC = GetPooledAudioComponent(ASound, SourceActor, bStopWhenOwnerDestroyed);
		if (AC == None)
		{
			return;
		}
		if (!IsZero(SourceLocation) && SourceLocation != SourceActor.Location)
		{
			AC.bUseOwnerLocation = false;
			AC.Location = SourceLocation;
		}
	}
	if ( bIsOccluded )
	{
		// if occluded reduce volume: @FIXME do something better
		AC.VolumeMultiplier *= 0.5;
		// AC.LowPassFilterApplied = true;
	}
	AC.Play();
}

function bool AimingHelp(bool bInstantHit)
{
	return bAimingHelp && ((WorldInfo.NetMode == NM_Standalone) || UTGameReplicationInfo(WorldInfo.GRI).bStoryMode) && (WorldInfo.Game.GameDifficulty < 4);
}

/**
* @returns the a scaling factor for the distance from the collision box of the target to accept aiming help (for instant hit shots)
*/
function float AimHelpModifier()
{
	local float AimingHelp;

	AimingHelp = FOVAngle < DefaultFOV - 8 ? 0.5 : 0.75;

	// reduce aiming help at higher difficulty levels
	if ( WorldInfo.Game.GameDifficulty > 2 )
		AimingHelp *= 0.33 * (5 - WorldInfo.Game.GameDifficulty);

	return AimingHelp;
}

/**
 * Adjusts weapon aiming direction.
 * Gives controller a chance to modify the aiming of the pawn. For example aim error, auto aiming, adhesion, AI help...
 * Requested by weapon prior to firing.
 * UTPlayerController implementation doesn't adjust aim, but sets the shottarget (for warning enemies)
 *
 * @param	W, weapon about to fire
 * @param	StartFireLoc, world location of weapon fire start trace, or projectile spawn loc.
 * @param	BaseAimRot, original aiming rotation without any modifications.
 */
function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{
	local vector	FireDir, HitLocation, HitNormal;
	local actor		BestTarget, HitActor;
	local float		bestAim, bestDist, MaxRange;
	local rotator	BaseAimRot;

	BaseAimRot = (Pawn != None) ? Pawn.GetBaseAimRotation() : Rotation;
	FireDir	= vector(BaseAimRot);
	MaxRange = W.MaxRange();
	HitActor = Trace(HitLocation, HitNormal, StartFireLoc + MaxRange * FireDir, StartFireLoc, true);

	if ( (HitActor != None) && HitActor.bProjTarget )
	{
		BestTarget = HitActor;
	}
	else if ( ((WorldInfo.Game != None) &&(WorldInfo.Game.Numbots > 0)) || AimingHelp(true) )
	{
		// guess who target is
		// @todo FIXMESTEVE
		bestAim = 0.95;
		BestTarget = PickTarget(class'Pawn', bestAim, bestDist, FireDir, StartFireLoc, MaxRange);
		if (W != None && W.GetProjectileClass() == None)
		{
			InstantWarnTarget(BestTarget, W, vector(BaseAimRot));
		}
	}

	ShotTarget = Pawn(BestTarget);
   	return BaseAimRot;
}


/** Tries to find a vehicle to drive within a limited radius. Returns true if successful */
function bool FindVehicleToDrive()
{
	return ( CheckVehicleToDrive(true) != None );
}

/** returns the Vehicle passed in if it can be driven
  */
function UTVehicle CheckPickedVehicle(UTVehicle V, bool bEnterVehicle)
{
	local UTPlayerReplicationInfo PRI;

	if ( (V == None) || !bEnterVehicle )
	{
		return V;
	}
	// check if I would drop my flag
	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	if ( PRI.bHasFlag && !V.bCanCarryFlag && (!V.bTeamLocked || WorldInfo.GRI.OnSameTeam(self,V)) )
	{
		if ( V.bRequestedEntryWithFlag )
		{
			V.bRequestedEntryWithFlag = false;
			ClientSetRequestedEntryWithFlag(V, false, 0);
		}
		else
		{
			V.bRequestedEntryWithFlag = true;
			ClientSetRequestedEntryWithFlag(V, true, 0);
			bJustFoundVehicle = true;
			return None;
		}
	}
	if ( V.TryToDrive(Pawn) )
	{
		return V;
	}
	bJustFoundVehicle = true;
	return None;
}

/** sets bRequestedEntryWithFlag on the given vehicle to update the HUD */
reliable client function ClientSetRequestedEntryWithFlag(UTVehicle V, bool bNewValue, int MessageIndex)
{
	if ( bNewValue )
	{
		ReceiveLocalizedMessage(class'UTVehicleCantCarryFlagMessage', MessageIndex);
	}
	if (V != None)
	{
		V.bRequestedEntryWithFlag = bNewValue;
	}
}

/** Returns vehicle which can be driven
  * @PARAM bEnterVehicle if true then player enters the found vehicle
  */
function UTVehicle CheckVehicleToDrive(bool bEnterVehicle)
{
	local UTVehicle V, PickedVehicle;
	local vector ViewDir, HitLocation, HitNormal, ViewPoint;
	local rotator ViewRotation;
	local Actor HitActor;
	local float CheckDist;

	bJustFoundVehicle = false;

	// first try to get in vehicle I'm standing on
	PickedVehicle = CheckPickedVehicle(UTVehicle(Pawn.Base), bEnterVehicle);
	if ( (PickedVehicle != None) || bJustFoundVehicle )
	{
		return PickedVehicle;
	}

	// see if looking at vehicle
	ViewPoint = Pawn.GetPawnViewLocation();
	ViewRotation = Rotation;
	CheckDist = Pawn.VehicleCheckRadius * VehicleCheckRadiusScaling;
	ViewDir = CheckDist * vector(ViewRotation);
	HitActor = Trace(HitLocation, HitNormal, ViewPoint + ViewDir, ViewPoint, true,,,TRACEFLAG_Blocking);

	PickedVehicle = CheckPickedVehicle(UTVehicle(HitActor), bEnterVehicle);
	if ( (PickedVehicle != None) || bJustFoundVehicle )
	{
		return PickedVehicle;
	}

	// make sure not just looking above vehicle
	ViewRotation.Pitch = 0;
	ViewDir = CheckDist * vector(ViewRotation);
	HitActor = Trace(HitLocation, HitNormal, ViewPoint + ViewDir, ViewPoint, true,,,TRACEFLAG_Blocking);

	PickedVehicle = CheckPickedVehicle(UTVehicle(HitActor), bEnterVehicle);
	if ( (PickedVehicle != None) || bJustFoundVehicle )
	{
		return PickedVehicle;
	}

	// make sure not just looking above vehicle
	ViewRotation.Pitch = -5000;
	ViewDir = CheckDist * vector(ViewRotation);
	HitActor = Trace(HitLocation, HitNormal, ViewPoint + ViewDir, ViewPoint, true,,,TRACEFLAG_Blocking);

	PickedVehicle = CheckPickedVehicle(UTVehicle(HitActor), bEnterVehicle);
	if ( (PickedVehicle != None) || bJustFoundVehicle )
	{
		return PickedVehicle;
	}

	// special case for vehicles like Darkwalker
	if ( UTGame(WorldInfo.Game) != None )
	{
		for ( V=UTGame(WorldInfo.Game).VehicleList; V!=None; V=V.NextVehicle )
		{
			if ( V.bHasCustomEntryRadius && V.InCustomEntryRadius(Pawn) )
			{
				V = CheckPickedVehicle(V, bEnterVehicle);
				if ( (V != None) || bJustFoundVehicle )
				{
					return V;
				}
			}
		}
	}

	return None;
}

exec function ToggleMinimap()
{
	bRotateMiniMap = !bRotateMiniMap;
}

exec function DropFlag()
{
	ServerDropFlag();
}

reliable server function ServerDropFlag()
{
	if ( UTPawn(Pawn) != None )
	{
		UTPawn(Pawn).DropFlag();
		if (UTPawn(Pawn).bCanPickupInventory)
		{
			UTPawn(Pawn).bCanPickupInventory = false;
			SetTimer(0.2, false, 'EnableInventoryPickup', UTPawn(Pawn));
		}
	}
}

/** LandingShake()
returns true if controller wants landing view shake
*/
simulated function bool LandingShake()
{
	return bLandingShake;
}

simulated function PlayBeepSound()
{
	PlaySound(SoundCue'A_Gameplay.Gameplay.MessageBeepCue', true);
}

/* epic ===============================================
* ::ReceiveWarning
*
* Notification that the pawn is about to be shot by a
* trace hit weapon.
*
* =====================================================
*/
event ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
	if ( WorldInfo.TimeSeconds - LastWarningTime < 1.0 )
		return;
	LastWarningTime = WorldInfo.TimeSeconds;
	if ( (shooter != None) && !WorldInfo.GRI.OnSameTeam(shooter,self) )
		ClientMusicEvent(0);
}

/* epic ===============================================
* ::ReceiveProjectileWarning
*
* Notification that the pawn is about to be shot by a
* projectile.
*
* =====================================================
*/
function ReceiveProjectileWarning(Projectile proj)
{
	if ( WorldInfo.TimeSeconds - LastWarningTime < 1.0 )
		return;
	LastWarningTime = WorldInfo.TimeSeconds;
	if ( (proj.Instigator != None) && !WorldInfo.GRI.OnSameTeam(proj.Instigator,self) && (proj.Speed > 0) )
	{
		SetTimer(VSize(proj.Location - Pawn.Location)/proj.Speed,false,'ProjectileWarningTimer');
	}
}

function ProjectileWarningTimer()
{
	ClientMusicEvent(0);
}

function PlayWinMessage(bool bWinner)
{
/* //@todo FIXMESTEVE
	if ( bWinner )
		bDisplayWinner = true;
	else
		bDisplayLoser = true;
*/
}

simulated function bool TriggerInteracted()
{
	local UTGameObjective O, Best;
	local vector ViewDir, PawnLoc2D, VLoc2D;
	local float NewDot, BestDot;

	// check base UTGameObjective first
	if (UTGameObjective(Pawn.Base) != None)
	{
		return true;
	}

	// handle touched UTGameObjectives next
	ForEach Pawn.TouchingActors(class'UTGameObjective', O)
	{
		if ( O.UsedBy(Pawn) )
			return true;
	}

	// now handle nearby UTGameObjectives
	ViewDir = vector(Rotation);
	PawnLoc2D = Pawn.Location;
	PawnLoc2D.Z = 0;
	ForEach Pawn.OverlappingActors(class'UTGameObjective', O, Pawn.VehicleCheckRadius)
	{
		if ( O.bAllowRemoteUse )
		{
			// Pawn must be facing objective or overlapping it
			VLoc2D = O.Location;
			Vloc2D.Z = 0;
			NewDot = Normal(VLoc2D-PawnLoc2D) Dot ViewDir;
			if ( NewDot > BestDot )
			{
				// check that objective is visible
				if ( FastTrace(O.Location,Pawn.Location) )
				{
					Best = O;
					BestDot = NewDot;
				}
			}
		}
	}
	if ( Best != None && Best.UsedBy(Pawn) )
		return true;

	// no UT specific triggers used, fall back to general case
	return super.TriggerInteracted();
}

exec function PlayVehicleHorn()
{
	local UTVehicle V;

	V = UTVehicle(Pawn);
	if ( (V != None) && (V.Health > 0) && (WorldInfo.TimeSeconds - LastTauntAnimTime > 0.3)  )
	{
		ServerPlayVehicleHorn();
		LastTauntAnimTime = WorldInfo.TimeSeconds;
	}
}

unreliable server function ServerPlayVehicleHorn()
{
	local UTVehicle V;

	V = UTVehicle(Pawn);
	if ( (V != None) && (V.Health > 0)  )
	{
		V.PlayHorn();
	}
}

exec function Taunt(int TauntIndex)
{
	local UTVehicle UTV;
	local UTPawn UTP;

	UTP = UTPawn(Pawn);
	if(UTP == None)
	{
		UTV = UTVehicle(Pawn);
		if(UTV != None)
		{
			UTP = UTPawn(UTV.Driver);
		}
	}

	if(UTP != None)
	{
		switch(TauntIndex)
		{
		case 0:
			UTP.PlayEmote('TauntA', -1);
			break;

		case 1:
			UTP.PlayEmote('TauntB', -1);
			break;

		case 2:
			UTP.PlayEmote('TauntC', -1);
			break;
		}
	}
}

function Typing( bool bTyping )
{
	bIsTyping = bTyping;
}

simulated event Destroyed()
{
	if (LocalPlayer(Player) != None)
	{
		LocalPlayer(Player).ViewportClient.bDisableWorldRendering = false;
	}

	Super.Destroyed();

	if (Announcer != None)
	{
		Announcer.Destroy();
	}
	if (MusicManager != None)
	{
		MusicManager.Destroy();
	}
}

/**
 * Attempts to pause/unpause the game when a controller becomes
 * disconnected/connected
 *
 * @param ControllerId the id of the controller that changed
 * @param bIsConnected whether the controller is connected or not
 */
function OnControllerChanged(int ControllerId,bool bIsConnected)
{
	local LocalPlayer LocPlayer;

	// Call parent implementation (this will pause/unpause the game if needed)
	super.OnControllerChanged( ControllerId, bIsConnected );

	// Don't worry about remote players
	LocPlayer = LocalPlayer(Player);

	if (WorldInfo.IsConsoleBuild() && (WorldInfo.Game == None || !WorldInfo.Game.IsAutomatedPerfTesting()))
	{
		// If the controller that changed, is attached to the this playercontroller
		if (LocPlayer != None && LocPlayer.ControllerId == ControllerId)
		{
			bIsControllerConnected = bIsConnected;

			//@todo fix this to work again once UI changes are merged back into main
// 			if(bIsConnected)
// 			{
// 				class'UTUIScene'.static.ClearScreenWarningMessage();
// 			}
// 			else
// 			{
// 				class'UTUIScene'.static.ShowScreenWarningMessage(Localize("ToastMessages","ReconnectController","UTGameUI")$" ("$(ControllerId+1)$")");
// 			}
		}
	}
}



event SoakPause(Pawn P)
{
	`log("Soak pause by "$P);
	SetViewTarget(P);
	SetPause(true);
	bBehindView = true;
	myHud.bShowDebugInfo = true;
}

function DrawHUD( HUD H )
{
	// force scoreboard on if dedicated server spectator
	if (bDedicatedServerSpectator && !H.bShowScores)
	{
		H.ShowScores();
	}

	if( (Pawn != None) && (UTWeapon(Pawn.Weapon) != None) )
	{
		UTWeapon(Pawn.Weapon).ActiveRenderOverlays(H);
	}
}

event KickWarning()
{
	if ( WorldInfo.TimeSeconds - LastKickWarningTime > 0.5 )
	{
		ReceiveLocalizedMessage( class'UTIdleKickWarningMessage', 0, None, None, self );
		LastKickWarningTime = WorldInfo.TimeSeconds;
	}
}

/* CheckJumpOrDuck()
Called by ProcessMove()
handle jump and duck buttons which are pressed
*/
function CheckJumpOrDuck()
{
	if ( Pawn == None )
	{
		return;
	}
	if ( bDoubleJump && (bUpdating || ((UTPawn(Pawn) != None) && UTPawn(Pawn).CanDoubleJump())) )
	{
		UTPawn(Pawn).DoDoubleJump( bUpdating );
	}
    else if ( bPressedJump )
	{
		Pawn.DoJump( bUpdating );
	}
	if ( Pawn.Physics != PHYS_Falling && Pawn.bCanCrouch )
	{
		// crouch if pressing duck
		Pawn.ShouldCrouch(bDuck != 0);
	}
}

exec function FOV(float F)
{
	if( (F >= 40.0) || (WorldInfo.NetMode==NM_Standalone) || PlayerReplicationInfo.bOnlySpectator )
	{
		OnFootDefaultFOV = FClamp(F, 40, 120);
		if ( Vehicle(Pawn) == None )
		{
			FixFOV();
		}
		SaveConfig();
	}
}

function FixFOV()
{
	if ( OnFootDefaultFOV < 40 )
	{
		OnFootDefaultFOV = 90.0;
	}
	OnFootDefaultFOV = FClamp(OnFootDefaultFOV, 40, 120);
	FOVAngle = OnFootDefaultFOV;
	DesiredFOV = OnFootDefaultFOV;
	DefaultFOV = OnFootDefaultFOV;
}

function Restart(bool bVehicleTransition)
{
	Super.Restart(bVehicleTransition);

	// re-check auto objective every time the player respawns
	if (!bVehicleTransition)
	{
		// use timer to spread out spawn CPU cost a little
		SetTimer(0.1, false, 'CheckAutoObjective');
	}
}

reliable client function ClientRestart(Pawn NewPawn)
{
	local UTVehicle V;

	Super.ClientRestart(NewPawn);
	ServerPlayerPreferences(WeaponHandPreference, bAutoTaunt, bCenteredWeaponFire, AutoObjectivePreference, VehicleControlType);

	if (NewPawn != None)
	{
		// FIXMESTEVE - do this by calling simulated function in Pawn (in base PlayerController version)
		// apply vehicle FOV
		V = UTVehicle(NewPawn);
		if (V == None && NewPawn.IsA('UTWeaponPawn'))
		{
			V = UTVehicle(NewPawn.GetVehicleBase());
		}
		if (V != None)
		{
			DefaultFOV = V.DefaultFOV;
			DesiredFOV = DefaultFOV;
			FOVAngle = DesiredFOV;
		}
		else
		{
			FixFOV();
		}
		// if new pawn has empty weapon, autoswitch to new one
		// (happens when switching from Redeemer remote control, for example)
		if (NewPawn.Weapon != None && !NewPawn.Weapon.HasAnyAmmo())
		{
			SwitchToBestWeapon();
		}
	}
	else
	{
		FixFOV();
	}
}

function SetViewTarget(Actor NewViewTarget, optional ViewTargetTransitionParams TransitionParams)
{
	local UTVehicle V;
	local Pawn P;
	local EPawnShadowMode AdjustedShadowMode;

	ClearCameraEffect();

	// FIXMESTEVE - do this by calling simulated function in Pawn (in base PlayerController version)
	if ( UTPawn(ViewTarget) != None )
	{
		UTPawn(ViewTarget).AdjustPPEffects(self, true);
	}

	Super.SetViewTarget(NewViewTarget, TransitionParams);
	if ( UTPawn(ViewTarget) != None )
	{
		UTPawn(ViewTarget).AdjustPPEffects(self, false);
	}

	// set sound pitch adjustment based on customtimedilation
	if ( ViewTarget.CustomTimeDilation < 1.0 )
	{
		ConsoleCommand( "SETSOUNDMODE Slow", false );
	}
	else
	{
		ConsoleCommand( "SETSOUNDMODE Default", false );
	}

	// remove other players' shadows if viewing drop detail vehicle
	if (IsLocalPlayerController())
	{
		if (class'Engine'.static.IsSplitScreen())
		{
			AdjustedShadowMode = SHADOW_None;
		}
		else
		{
			V = UTVehicle(ViewTarget);
			if (V == None && Pawn(ViewTarget) != None)
			{
				V = UTVehicle(Pawn(ViewTarget).GetVehicleBase());
			}
			if (PawnShadowMode > SHADOW_None && V != None && V.bDropDetailWhenDriving && WorldInfo.GetDetailMode() < DM_Medium)
			{
				AdjustedShadowMode = SHADOW_Self;
			}
			else
			{
				AdjustedShadowMode = PawnShadowMode;
			}
		}
		foreach WorldInfo.AllPawns(class'Pawn', P)
		{
			if (UTPawn(P) != None)
			{
				UTPawn(P).UpdateShadowSettings(AdjustedShadowMode == SHADOW_All || (AdjustedShadowMode == SHADOW_Self && ViewTarget == P));
			}
			else if (UTVehicle(P) != None)
			{
				UTVehicle(P).UpdateShadowSettings(AdjustedShadowMode == SHADOW_All || (AdjustedShadowMode == SHADOW_Self && ViewTarget == P));
			}
		}
	}
}

/** attempts to find an objective for the player to complete depending on their settings and tells the player about it
 * @note: needs to be called on the server, not the client (because that's where the AI is)
 * @param bOnlyNotifyDifferent - if true, only send messages to the player if the selected objective is different from the previous one
 */
function CheckAutoObjective(bool bOnlyNotifyDifferent)
{
	local Actor ObjectiveActor;

	if (Pawn != None && PlayerReplicationInfo != None)
	{
		ObjectiveActor = UTGame(WorldInfo.Game).GetAutoObjectiveFor(self);
		if ( ObjectiveActor != None )
		{
			SetAutoObjective(ObjectiveActor, bOnlyNotifyDifferent);
		}
		else
		{
			LastAutoObjective = None;
			ClientSetAutoObjective(LastAutoObjective);
		}
	}
}

function SetAutoObjective(Actor ObjectiveActor, bool bOnlyNotifyDifferent)
{
	local UTGameObjective DesiredObjective;
	local int i;

	DesiredObjective = UTGameObjective(ObjectiveActor);
	if ( DesiredObjective != None )
	{
		ObjectiveActor = DesiredObjective.GetAutoObjectiveActor(self);
		DesiredObjective = UTGameObjective(ObjectiveActor);
	}
	if (ObjectiveActor != LastAutoObjective || !bOnlyNotifyDifferent)
	{
		LastAutoObjective = ObjectiveActor;
		ClientSetAutoObjective(LastAutoObjective);

		if ( WorldInfo.TimeSeconds - LastShowPathTime > 0.5 )
		{
			LastShowPathTime = WorldInfo.TimeSeconds;

		// spawn willow whisp
		if (DesiredObjective != None)
		{
			for (i = 0; i < DesiredObjective.ShootSpots.length; i++)
			{
				if (DesiredObjective.ShootSpots[i] != None)
				{
					DesiredObjective.ShootSpots[i].bTransientEndPoint = true;
				}
			}
		}
		if (FindPathToward(LastAutoObjective) != None)
		{
			Spawn(class'UTWillowWhisp', self,, Pawn.Location);
		}
	}
}
}

/** client-side notification of the current auto objective */
reliable client function ClientSetAutoObjective(Actor NewAutoObjective)
{
	LastAutoObjective = NewAutoObjective;

	ReceiveLocalizedMessage(class'UTObjectiveAnnouncement', AutoObjectivePreference,,, LastAutoObjective);
}

/* epic ===============================================
* ::Possess
*
* Handles attaching this controller to the specified
* pawn.
*
* =====================================================
*/
event Possess(Pawn inPawn, bool bVehicleTransition)
{
	Super.Possess(inPawn, bVehicleTransition);

	// force garbage collection when possessing pawn, to avoid GC during gameplay
	if ( bVehicleTransition )
	{
		if ( (WorldInfo.NetMode == NM_Client) || (WorldInfo.NetMode == NM_Standalone) )
		{
			WorldInfo.ForceGarbageCollection();
		}
	}
}

function AcknowledgePossession(Pawn P)
{
	local rotator NewViewRotation;

	Super.AcknowledgePossession(P);

	if ( LocalPlayer(Player) != None )
	{
		ClientEndZoom();
		if (bUseVehicleRotationOnPossess && Vehicle(P) != None && UTWeaponPawn(P) == None)
		{
			NewViewRotation = P.Rotation;
			NewViewRotation.Roll = 0;
			SetRotation(NewViewRotation);
		}
		ServerPlayerPreferences(WeaponHandPreference, bAutoTaunt, bCenteredWeaponFire, AutoObjectivePreference, VehicleControlType);

		if ( (PlayerReplicationInfo != None)
			&& (PlayerReplicationInfo.Team != None)
			&& (IdentifiedTeam != PlayerReplicationInfo.Team.TeamIndex) )
		{
			// identify your team the first time you spawn on it
			IdentifiedTeam = PlayerReplicationInfo.Team.TeamIndex;
			if ( IdentifiedTeam < 2 )
			{
				ReceiveLocalizedMessage( class'UTTeamGameMessage', IdentifiedTeam+1, PlayerReplicationInfo);
			}
		}
	}
}

simulated event ReceivedPlayer()
{
	Super.ReceivedPlayer();

	if (LocalPlayer(Player) != None)
	{
		ServerPlayerPreferences(WeaponHandPreference, bAutoTaunt, bCenteredWeaponFire, AutoObjectivePreference, VehicleControlType);
	}
	else
	{
		// default auto objective preference to None for non-local players so we don't send objective info
		// until we've received the client's preference
		AutoObjectivePreference = AOP_Disabled;
	}
}

reliable server function ServerPlayerPreferences(EWeaponHand NewWeaponHand, bool bNewAutoTaunt, bool bNewCenteredWeaponFire, EAutoObjectivePreference NewAutoObjectivePreference, EUTVehicleControls NewVehicleControls)
{
	ServerSetHand(NewWeaponHand);
	ServerSetAutoTaunt(bNewAutoTaunt);

	bCenteredWeaponFire = bNewCenteredWeaponFire;
	VehicleControlType = NewVehicleControls;

	if (AutoObjectivePreference != NewAutoObjectivePreference)
	{
		AutoObjectivePreference = NewAutoObjectivePreference;
		CheckAutoObjective(false);
	}
}

reliable server function ServerSetHand(EWeaponHand NewWeaponHand)
{
	WeaponHand = NewWeaponHand;
}

function SetHand(EWeaponHand NewWeaponHand)
{
	WeaponHandPreference = NewWeaponHand;
	WeaponHand = WeaponHandPreference;
	SaveConfig();

	ServerSetHand(NewWeaponHand);
}

event ResetCameraMode()
{}

/**
* return whether viewing in first person mode
*/
function bool UsingFirstPersonCamera()
{
	return !bBehindView;
}

// ------------------------------------------------------------------------

reliable server function ServerSetAutoTaunt(bool Value)
{
	bAutoTaunt = Value;
}

exec function SetAutoTaunt(bool Value)
{
	Default.bAutoTaunt = Value;
	StaticSaveConfig();
	bAutoTaunt = Value;

	ServerSetAutoTaunt(Value);
}

exec function ToggleScreenShotMode()
{
	if ( UTHUDBase(myHUD).bCrosshairShow )
	{
		UTHUDBase(myHUD).bCrosshairShow = false;
		SetHand(HAND_Hidden);
		myHUD.bShowHUD = false;
		if ( UTPawn(Pawn) != None )
			UTPawn(Pawn).TeamBeaconMaxDist = 0;
	}
	else
	{
		// return to normal
		UTHUDBase(myHUD).bCrosshairShow = true;
		SetHand(HAND_Right);
		myHUD.bShowHUD = true;
		if ( UTPawn(Pawn) != None )
			UTPawn(Pawn).TeamBeaconMaxDist = UTPawn(Pawn).default.TeamBeaconMaxDist;
	}
}

reliable client function PlayStartupMessage(byte StartupStage)
{
	if ( StartupStage == 7 )
	{
		ReceiveLocalizedMessage( class'UTTimerMessage', 17, PlayerReplicationInfo );
	}
	else
	{
		ReceiveLocalizedMessage( class'UTStartupMessage', StartupStage, PlayerReplicationInfo );
	}
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local int iDam;

	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);

	iDam = Clamp(Damage,0,250);
	if ( (iDam > 0 || bGodMode) && (Pawn != None) )
	{
		ClientPlayTakeHit(hitLocation - Pawn.Location, iDam, damageType);
	}
}

unreliable client function ClientPlayTakeHit(vector HitLoc, byte Damage, class<DamageType> DamageType)
{
	DamageShake(Damage, DamageType);
	HitLoc += Pawn.Location;

	if ( UDKHUD(MyHUD) != None )
	{
		UDKHUD(MyHUD).DisplayHit(HitLoc, Damage, DamageType);
	}
}

/**
 * Limit use frequency
 */
unreliable server function ServerUse()
{
	if ( (LastUseTime == WorldInfo.TimeSeconds) || ((Vehicle(Pawn) != None) && (WorldInfo.TimeSeconds - LastUseTime < 1.0)) )
	{
		return;
	}
	LastUseTime = WorldInfo.TimeSeconds;
	PerformedUseAction();
}

exec function Use()
{
	if( Role < Role_Authority )
	{
		PerformedUseAction();
	}
	ServerUse();
}

simulated function bool PerformedUseAction()
{
	local UTCarriedObject Flag;

	bJustFoundVehicle = false;
	if (Pawn != None && Pawn.IsInState('FeigningDeath'))
	{
		// can't use things while feigning death
		return true;
	}
	else
	{
		if ( (Pawn != None) && (Vehicle(Pawn) == None) )
		{
		  ForEach Pawn.TouchingActors(class'UTCarriedObject', Flag)
		  {
			  if ( Flag.FlagUse(self) )
			  {
				  return true;
			  }
		  }
		}

		//Stop flying
		if (Pawn.Physics == PHYS_Flying)
		{
			UTPawn(Pawn).StopFlying();
		}

		return Super.PerformedUseAction();
	}
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
	ignores SeePlayer, HearNoise, Bump;

	event bool NotifyLanded(vector HitNormal, Actor FloorActor)
	{
		if (DoubleClickDir == DCLICK_Active)
		{
			DoubleClickDir = DCLICK_Done;
			ClearDoubleClick();
		}
		else
		{
			DoubleClickDir = DCLICK_None;
		}

		if (Global.NotifyLanded(HitNormal, FloorActor))
		{
			return true;
		}

		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
			DoubleClickDir = DCLICK_Active;
		else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
		{
			if ( UTPawn(Pawn).Dodge(DoubleClickMove) )
				DoubleClickDir = DCLICK_Active;
		}

		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
	}

    function PlayerMove( float DeltaTime )
    {
		GroundPitch = 0;
		Super.PlayerMove(DeltaTime);
	}
}

state PlayerFlying
{
	ignores SeePlayer, HearNoise, Bump;

	function PlayerMove(float DeltaTime)
	{
		Super.PlayerMove(DeltaTime);
		CheckJumpOrDuck();
	}
}

function ServerSpectate()
{
	GotoState('Spectating');
}

state RoundEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide, DrawHud;

	exec function PrevWeapon() {}
	exec function NextWeapon() {}
	exec function SwitchWeapon(byte T) {}
	exec function ToggleMelee() {}

	/**
	 * Limit the player's view rotation. (Pitch component).
	 */
	event Rotator LimitViewRotation( Rotator ViewRotation, float ViewPitchMin, float ViewPitchMax )
	{
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;

		if( ViewRotation.Pitch > 8192 &&
			ViewRotation.Pitch < (65535+ViewPitchMin) )
		{
			if( ViewRotation.Pitch < 32768 )
			{
				ViewRotation.Pitch = 8192;
			}
			else
			{
				ViewRotation.Pitch = 65535 + ViewPitchMin;
			}
		}

		return ViewRotation;
	}

	unreliable client function LongClientAdjustPosition
	(
		float TimeStamp,
		name newState,
		EPhysics newPhysics,
		float NewLocX,
		float NewLocY,
		float NewLocZ,
		float NewVelX,
		float NewVelY,
		float NewVelZ,
		Actor NewBase,
		float NewFloorX,
		float NewFloorY,
		float NewFloorZ
	)
	{
		if ( newState == 'PlayerWaiting' )
			GotoState( newState );
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local Rotator DeltaRot, ViewRotation;

		GetAxes(Rotation,X,Y,Z);
		// Update view rotation.
		ViewRotation = Rotation;
		// Calculate Delta to be applied on ViewRotation
		DeltaRot.Yaw	= PlayerInput.aTurn;
		DeltaRot.Pitch	= PlayerInput.aLookUp;
		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
		SetRotation(ViewRotation);

		ViewShake(DeltaTime);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		bPressedJump = false;
	}

	function ShowScoreboard()
	{
		local UTGameReplicationInfo GRI;

		if ( CommandMenu != none )
		{
			CommandMenu.CloseScene();
			CommandMenu = none;
		}

		GRI = UTGameReplicationInfo(WorldInfo.GRI);
		if (GRI != None && GRI.bMatchIsOver && !GRI.bStoryMode)
		{
			ShowMidGameMenu('ScoreTab',true);
		}
		else if (myHUD != None)
		{
			myHUD.SetShowScores(true);
		}
		AutoContinueToNextRound();
	}

	/** This will auto continue to the next round.  Very useful doing soak testing and testing traveling to next level **/
	function AutoContinueToNextRound()
	{
		if ( Role == ROLE_Authority && WorldInfo.Game.ShouldAutoContinueToNextRound() )
		{
			myHUD.SetShowScores(false);
			StartFire( 0 );
		}
	}

	function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		// this is a good stop gap measure for any cases that we miss / other code getting turned on / called
		// there is never a case where we want the tilt to be on at this point
		SetOnlyUseControllerTiltInput( FALSE );
		SetUseTiltForwardAndBack( TRUE );
		SetControllerTiltActive( FALSE );

		if (UTGame(WorldInfo.Game) != None)
		{
			// don't let player restart the game until the end game sequence is complete
			SetTimer(FMax(GetTimerRate(), UTGame(WorldInfo.Game).ResetTimeDelay), false);
		}

		bAlreadyReset = false;

		if ( myHUD != None )
		{
			myHUD.SetShowScores(false);
			// the power core explosion is 15 seconds  so we wait 1 additional for the awe factor (the total time of the matinee is 18-20 seconds to avoid popping back to start)
			// so for DM/CTF will get to see the winner in GLORIOUS detail and listen to the smack talking
			SetTimer(16, false, 'ShowScoreboard');
		}
	}

	function EndState(name NextStateName)
	{
		Super.EndState(NextStateName);
		SetBehindView(false);
		StopViewShaking();
		StopCameraAnim(true);
		if (myHUD != None)
		{
			myHUD.SetShowScores(false);
		}
	}
}

function ShowScoreboard();

state Dead
{
	ignores SeePlayer, HearNoise, KilledBy, NextWeapon, PrevWeapon;

	exec function SwitchWeapon(byte T){}
	exec function ToggleMelee() {}
	exec function StartFire( optional byte FireModeNum )
	{
		if ( bFrozen )
		{
			if ( !IsTimerActive() || GetTimerCount() > MinRespawnDelay )
				bFrozen = false;
			return;
		}
		if ( PlayerReplicationInfo.bOutOfLives )
			ServerSpectate();
		else
			super.StartFire( FireModeNum );
	}

	function Timer()
	{
		if (!bFrozen)
			return;

		// force garbage collection while dead, to avoid GC during gameplay
		if ( (WorldInfo.NetMode == NM_Client) || (WorldInfo.NetMode == NM_Standalone) )
		{
			WorldInfo.ForceGarbageCollection();
		}
		bFrozen = false;
		bUsePhysicsRotation = false;
		bPressedJump = false;
	}

	reliable client event ClientSetViewTarget( Actor A, optional ViewTargetTransitionParams TransitionParams )
	{
		if( A == None )
		{
			ServerVerifyViewTarget();
			return;
		}
		// don't force view to self while dead (since server may be doing it having destroyed the pawn)
		if ( A == self )
			return;
		SetViewTarget( A, TransitionParams );
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot, ViewRotation, RealRotation;
		local int tries, besttry;
		local float bestdist, newdist, RealCameraScale;
		local int startYaw;
		local UTPawn P;

		if ( UTVehicle(ViewTarget) != None )
		{
			if (Pawn!=none)
			{
				Pawn.SetDesiredRotation(Rotation);
			}
			bUsePhysicsRotation = true;
			return;
		}

		ViewRotation = Rotation;
		RealRotation = ViewRotation;
		ViewRotation.Pitch = 56000;
		SetRotation(ViewRotation);
		P = UTPawn(ViewTarget);
		if ( P != None )
		{
			RealCameraScale = P.CurrentCameraScale;
			P.CurrentCameraScale = P.CameraScale;
		}

		// use current rotation if possible
		CalcViewActor = None;
		cameraLoc = ViewTarget.Location;
		GetPlayerViewPoint( cameraLoc, cameraRot );
		if ( P != None )
		{
			newdist = VSize(cameraLoc - ViewTarget.Location);
			if (newdist < P.CylinderComponent.CollisionRadius + P.CylinderComponent.CollisionHeight )
			{
				// find alternate camera rotation
				tries = 0;
				besttry = 0;
				bestdist = 0.0;
				startYaw = ViewRotation.Yaw;

				for (tries=1; tries<16; tries++)
				{
					CalcViewActor = None;
					cameraLoc = ViewTarget.Location;
					ViewRotation.Yaw += 4096;
					SetRotation(ViewRotation);
					GetPlayerViewPoint( cameraLoc, cameraRot );
					newdist = VSize(cameraLoc - ViewTarget.Location);
					if (newdist > bestdist)
					{
						bestdist = newdist;
						besttry = tries;
					}
				}
				ViewRotation.Yaw = startYaw + besttry * 4096;
			}
			P.CurrentCameraScale = RealCameraScale;
		}
		SetRotation(RealRotation);
		if (Pawn!=none)
		{
			Pawn.SetDesiredRotation (MakeRotator(ViewRotation.Pitch, ViewRotation.Yaw, 0));
		}
		bUsePhysicsRotation = true;
	}

	function BeginState(Name PreviousStateName)
	{
		local UTWeaponLocker WL;
		local UTWeaponPickupFactory WF;

		LastAutoObjective = None;
		if ( Pawn(Viewtarget) != None )
		{
			SetBehindView(true);
		}
		Super.BeginState(PreviousStateName);

		if ( LocalPlayer(Player) != None )
		{
			ForEach WorldInfo.AllNavigationPoints(class'UTWeaponLocker',WL)
				WL.NotifyLocalPlayerDead(self);
			ForEach WorldInfo.AllNavigationPoints(class'UTWeaponPickupFactory',WF)
				WF.NotifyLocalPlayerDead(self);
		}

		if ( CurrentMapScene != none )
		{
		//@todo ronp animation
			CurrentMapScene.CloseScene();
		}

		if (Role == ROLE_Authority && UTGame(WorldInfo.Game) != None && UTGame(WorldInfo.Game).ForceRespawn())
		{
			SetTimer(MinRespawnDelay, true, 'DoForcedRespawn');
		}
	}

	/** forces player to respawn if it is enabled */
	function DoForcedRespawn()
	{
		if (PlayerReplicationInfo.bOnlySpectator)
		{
			ClearTimer('DoForcedRespawn');
		}
		else
		{
			ServerRestartPlayer();
		}
	}

	function EndState(name NextStateName)
	{
		bUsePhysicsRotation = false;
		Super.EndState(NextStateName);
		SetBehindView(false);
		StopViewShaking();
		ClearTimer('DoForcedRespawn');
	}

Begin:
    Sleep(5.0);
	if ( (ViewTarget == None) || (ViewTarget == self) || (VSize(ViewTarget.Velocity) < 1.0) )
	{
		Sleep(1.0);
		if (myHUD != None)
		{
			//@FIXME: disabled temporarily for E3 due to scoreboard stealing input
			//myHUD.SetShowScores(true);
		}
	}
	else
		Goto('Begin');
}

/**
 * list important UTPlayerController variables on canvas. HUD will call DisplayDebug() on the current ViewTarget when
 * the ShowDebug exec is used
 *
 * @param	HUD		- HUD with canvas to draw on
 * @input	out_YL		- Height of the current font
 * @input	out_YPos	- Y position on Canvas. out_YPos += out_YL, gives position to draw text for next debug line.
 */
simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	local Canvas Canvas;

	Canvas = HUD.Canvas;
	Canvas.SetDrawColor(255,255,255,255);

	Canvas.DrawText("CONTROLLER "$GetItemName(string(self))$" Physics "$GetPhysicsName()$" Pawn "$GetItemName(string(Pawn))$" Yaw "$Rotation.Yaw);
	out_YPos += out_YL;
	Canvas.SetPos(4, out_YPos);

	if ( Pawn == None )
	{
		if ( PlayerReplicationInfo == None )
			Canvas.DrawText("NO PLAYERREPLICATIONINFO", false);
		else
			PlayerReplicationInfo.DisplayDebug(HUD, out_YL, out_YPos);
		out_YPos += out_YL;
		Canvas.SetPos(4, out_YPos);

		super(Actor).DisplayDebug(HUD, out_YL, out_YPos);
	}
	else if (HUD.ShouldDisplayDebug('AI'))
	{
		if ( Enemy != None )
			Canvas.DrawText(" STATE: "$GetStateName()$" Timer: "$GetTimerCount()$" Enemy "$Enemy.GetHumanReadableName(), false);
		else
			Canvas.DrawText(" STATE: "$GetStateName()$" Timer: "$GetTimerCount()$" NO Enemy ", false);
		out_YPos += out_YL;
		Canvas.SetPos(4, out_YPos);
	}

	if (PlayerCamera != None && HUD.ShouldDisplayDebug('camera'))
	{
		PlayerCamera.DisplayDebug( HUD, out_YL, out_YPos );
	}
}

function Reset()
{
	Super.Reset();
	if ( PlayerCamera != None )
	{
		PlayerCamera.Destroy();
	}
}

reliable client function ClientReset()
{
	local UTGameObjective O;

	Super.ClientReset();
	if ( PlayerCamera != None )
	{
		PlayerCamera.Destroy();
	}

	foreach WorldInfo.AllNavigationPoints(class'UTGameObjective', O)
	{
		O.ClientReset();
	}
}

exec function BehindView()
{
	if ( WorldInfo.NetMode == NM_Standalone )
		SetBehindView(!bBehindView);
}

function SetBehindView(bool bNewBehindView)
{
	bBehindView = bNewBehindView;
	if ( !bBehindView )
	{
		bFreeCamera = false;
	}

	if (LocalPlayer(Player) == None)
	{
		ClientSetBehindView(bNewBehindView);
	}
	else if (UTPawn(ViewTarget) != None)
	{
		UTPawn(ViewTarget).SetThirdPersonCamera(bNewBehindView);
	}
	// make sure we recalculate camera position for this frame
	LastCameraTimeStamp = WorldInfo.TimeSeconds - 1.0;
}

reliable client function ClientSetBehindView(bool bNewBehindView)
{
	if (LocalPlayer(Player) != None)
	{
		SetBehindView(bNewBehindView);
	}
	// make sure we recalculate camera position for this frame
	LastCameraTimeStamp = WorldInfo.TimeSeconds - 1.0;
}

/**
 * Set new camera mode
 *
 * @param	NewCamMode, new camera mode.
 */
function SetCameraMode( name NewCamMode )
{
	// will get set back to true below, if necessary
	bDebugFreeCam = FALSE;

	if ( PlayerCamera != None )
	{
		Super.SetCameraMode(NewCamMode);
	}
	else if ( NewCamMode == 'ThirdPerson' )
	{
		if ( !bBehindView )
			SetBehindView(true);
	}
	else if ( NewCamMode == 'FreeCam' )
	{
		if ( !bBehindView )
		{
			SetBehindView(true);
		}
		bDebugFreeCam = TRUE;
		DebugFreeCamRot = Rotation;
	}
	else
	{
		if ( bBehindView )
			SetBehindView(false);
	}
}

function SpawnCamera()
{
	local Actor OldViewTarget;

	// Associate Camera with PlayerController
	PlayerCamera = Spawn(MatineeCameraClass, self);
	if (PlayerCamera != None)
	{
		OldViewTarget = ViewTarget;
		PlayerCamera.InitializeFor(self);
		PlayerCamera.SetViewTarget(OldViewTarget);
	}
	else
	{
		`Log("Couldn't Spawn Camera Actor for Player!!");
	}
}

/* GetPlayerViewPoint: Returns Player's Point of View
	For the AI this means the Pawn's Eyes ViewPoint
	For a Human player, this means the Camera's ViewPoint */
simulated event GetPlayerViewPoint( out vector POVLocation, out Rotator POVRotation )
{
	local float DeltaTime;
	local UTPawn P;

	P = IsLocalPlayerController() ? UTPawn(CalcViewActor) : None;

	if (LastCameraTimeStamp == WorldInfo.TimeSeconds
		&& CalcViewActor == ViewTarget
		&& CalcViewActor != None
		&& CalcViewActor.Location == CalcViewActorLocation
		&& CalcViewActor.Rotation == CalcViewActorRotation
		)
	{
		if ( (P == None) || ((P.EyeHeight == CalcEyeHeight) && (P.WalkBob == CalcWalkBob)) )
		{
			// use cached result
			POVLocation = CalcViewLocation;
			POVRotation = CalcViewRotation;
			return;
		}
	}

	DeltaTime = WorldInfo.TimeSeconds - LastCameraTimeStamp;
	LastCameraTimeStamp = WorldInfo.TimeSeconds;

	// support for using CameraActor views
	if ( CameraActor(ViewTarget) != None )
	{
		if ( PlayerCamera == None )
		{
			super.ResetCameraMode();
			SpawnCamera();
		}
		super.GetPlayerViewPoint( POVLocation, POVRotation );
	}
	else
	{
		if ( PlayerCamera != None )
		{
			PlayerCamera.Destroy();
			PlayerCamera = None;
		}

		if ( ViewTarget != None )
		{
			POVRotation = Rotation;
			if ( (PlayerReplicationInfo != None) && PlayerReplicationInfo.bOnlySpectator && (UTVehicle(ViewTarget) != None) )
			{
				UTVehicle(ViewTarget).bSpectatedView = true;
				ViewTarget.CalcCamera( DeltaTime, POVLocation, POVRotation, FOVAngle );
				UTVehicle(ViewTarget).bSpectatedView = false;
			}
			else
			{
			ViewTarget.CalcCamera( DeltaTime, POVLocation, POVRotation, FOVAngle );
			}
			if ( bFreeCamera )
			{
				POVRotation = Rotation;
			}
		}
		else
		{
			CalcCamera( DeltaTime, POVLocation, POVRotation, FOVAngle );
			return;
		}
	}

	// apply view shake
	POVRotation = Normalize(POVRotation + ShakeRot);
	POVLocation += ShakeOffset >> Rotation;

	if( CameraEffect != none )
	{
		CameraEffect.UpdateLocation(POVLocation, POVRotation, GetFOVAngle());
	}


	// cache result
	CalcViewActor = ViewTarget;
	CalcViewActorLocation = ViewTarget.Location;
	CalcViewActorRotation = ViewTarget.Rotation;
	CalcViewLocation = POVLocation;
	CalcViewRotation = POVRotation;

	if ( P != None )
	{
		CalcEyeHeight = P.EyeHeight;
		CalcWalkBob = P.WalkBob;
	}
}


unreliable client function ClientMusicEvent(int EventIndex)
{
	if ( MusicManager != None )
		MusicManager.MusicEvent(EventIndex);
}

/**
  * return true if music manager is already playing action track
  * return true if no music manager (no need to tell non-existent music manager to change tracks
  */
function bool AlreadyInActionMusic()
{
	return (MusicManager != None) ? MusicManager.AlreadyInActionMusic() : true;
}

exec function Music(int EventIndex)
{
	MusicManager.MusicEvent(EventIndex);
}

reliable client function ClientPlayAnnouncement(class<UTLocalMessage> InMessageClass, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
	PlayAnnouncement(InMessageClass, MessageIndex, PRI, OptionalObject);
}

function PlayAnnouncement(class<UTLocalMessage> InMessageClass, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
	// Wait for player to be up to date with replication when joining a server, before stacking up messages
	if ( WorldInfo.GRI == None || Announcer == None ||
		(UTGameReplicationInfo(WorldInfo.GRI) != None && UTGameReplicationInfo(WorldInfo.GRI).bAnnouncementsDisabled) )
	{
		return;
	}
	Announcer.PlayAnnouncement(InMessageClass, MessageIndex, PRI, OptionalObject);
}


/** Causes a view shake based on the amount of damage
	Should only be called on the owning client */
function DamageShake(int Damage, class<DamageType> DamageType)
{
	local float BlendWeight;
	local class<UTDamageType> UTDamage;
	local CameraAnim AnimToPlay;

	UTDamage = class<UTDamageType>(DamageType);
	if (UTDamage != None && UTDamage.default.DamageCameraAnim != None)
	{
		AnimToPlay = UTDamage.default.DamageCameraAnim;
	}
	else
	{
		AnimToPlay = DamageCameraAnim;
	}
	if (AnimToPlay != None)
	{
		// don't override other anims unless it's another, weaker damage anim
		BlendWeight = FClamp(Damage / 200.0, 0.0, 1.0);
		if ( CameraAnimPlayer != None && ( CameraAnimPlayer.bFinished ||
						(bCurrentCamAnimIsDamageShake && CameraAnimPlayer.CurrentBlendWeight < BlendWeight) ) )
		{
			PlayCameraAnim(AnimToPlay, BlendWeight,,,,, true);
		}
	}
}

/** Turns off any view shaking */
function StopViewShaking()
{
	if (CameraAnimPlayer != None)
	{
		CameraAnimPlayer.Stop();
	}
}

/** plays the specified camera animation with the specified weight (0 to 1)
 * local client only
 */
function PlayCameraAnim( CameraAnim AnimToPlay, optional float Scale=1.f, optional float Rate=1.f,
			optional float BlendInTime, optional float BlendOutTime, optional bool bLoop, optional bool bIsDamageShake )
{
	local Camera MatineeAnimatedCam;

	bCurrentCamAnimAffectsFOV = false;

	// if we have a real camera, e.g we're watching through a matinee camera,
	// send the CameraAnim to be played there
	MatineeAnimatedCam = PlayerCamera;
	if (MatineeAnimatedCam != None)
	{
		MatineeAnimatedCam.PlayCameraAnim(AnimToPlay, Rate, Scale, BlendInTime, BlendOutTime, bLoop, FALSE);
	}
	else if (CameraAnimPlayer != None)
	{
		// play through normal UT camera
		CamOverridePostProcess = class'CameraActor'.default.CamOverridePostProcess;
		CameraAnimPlayer.Play(AnimToPlay, self, Rate, Scale, BlendInTime, BlendOutTime, bLoop, false);
	}

	// Play controller vibration - don't do this if damage, as that has its own handling
	if( !bIsDamageShake && !bLoop && WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( AnimToPlay.AnimLength <= 1 )
		{
			ClientPlayForceFeedbackWaveform(CameraShakeShortWaveForm);
		}
		else
		{
			ClientPlayForceFeedbackWaveform(CameraShakeLongWaveForm);
		}
	}

	bCurrentCamAnimIsDamageShake = bIsDamageShake;
}

/** Stops the currently playing camera animation. */
function StopCameraAnim(optional bool bImmediate)
{
	if (CameraAnimPlayer != None)
	{
		CameraAnimPlayer.Stop(bImmediate);
	}
}

/** Allows changing camera anim strength on the fly */
function SetCameraAnimStrength(float NewStrength)
{
	if ( CameraAnimPlayer != None )
	{
		CameraAnimPlayer.BasePlayScale = NewStrength;
	}
}

unreliable client event ClientPlayCameraAnim( CameraAnim AnimToPlay, optional float Scale=1.f, optional float Rate=1.f,
											 optional float BlendInTime, optional float BlendOutTime, optional bool bLoop,
											 optional bool bRandomStartTime, optional ECameraAnimPlaySpace Space=CAPS_CameraLocal, optional rotator CustomPlaySpace )
{
	PlayCameraAnim(AnimToPlay, Scale, Rate, BlendInTime, BlendOutTime, bLoop);
}

reliable client event ClientStopCameraAnim(CameraAnim AnimToStop)
{
	StopCameraAnim(true);
}

function OnPlayCameraAnim(UTSeqAct_PlayCameraAnim InAction)
{
	ClientPlayCameraAnim(InAction.AnimToPlay, InAction.IntensityScale, InAction.Rate, InAction.BlendInTime, InAction.BlendOutTime);
}

function OnStopCameraAnim(UTSeqAct_StopCameraAnim InAction)
{
	ClientStopCameraAnim(CameraAnimPlayer.CamAnim);
}


/** Sets ShakeOffset and ShakeRot to the current view shake that should be applied to the camera */
function ViewShake(float DeltaTime)
{
	if (CameraAnimPlayer != None && !CameraAnimPlayer.bFinished)
	{
		// advance the camera anim - the native code will set ShakeOffset/ShakeRot appropriately
		CamOverridePostProcess = class'CameraActor'.default.CamOverridePostProcess;
		CameraAnimPlayer.AdvanceAnim(DeltaTime, false);
	}
	else
	{
		ShakeOffset = vect(0,0,0);
		ShakeRot = rot(0,0,0);
	}
}

simulated exec function ToggleMelee()
{
	if ( (Pawn != None) && (Pawn.Weapon != None) && Vehicle(Pawn) == none)
	{
		if ( Pawn.Weapon.bMeleeWeapon )
		{
			UTInventoryManager(Pawn.InvManager).SwitchToPreviousWeapon();
		}
		else
		{
			SwitchWeapon(1);
		}
	}
}

simulated exec function ToggleTranslocator()
{
	if ( (Pawn != None) && !IsMoveInputIgnored() )
	{
		SwitchWeapon(0);
	}
}

//=====================================================================
// UT specific implementation of networked player movement functions
//

function CallServerMove
(
	SavedMove NewMove,
    vector ClientLoc,
    byte ClientRoll,
    int View,
    SavedMove OldMove
)
{
	local vector BuildAccel;
	local byte OldAccelX, OldAccelY, OldAccelZ;

	// compress old move if it exists
	if ( OldMove != None )
	{
		// old move important to replicate redundantly
		BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccelX = CompressAccel(BuildAccel.X);
		OldAccelY = CompressAccel(BuildAccel.Y);
		OldAccelZ = CompressAccel(BuildAccel.Z);

		OldServerMove(OldMove.TimeStamp,OldAccelX, OldAccelY, OldAccelZ, OldMove.CompressedFlags());
	}

	if ( PendingMove != None )
	{
		DualServerMove
		(
			PendingMove.TimeStamp,
			PendingMove.Acceleration * 10,
			PendingMove.CompressedFlags(),
			((PendingMove.Rotation.Yaw & 65535) << 16) + (PendingMove.Rotation.Pitch & 65535),
			NewMove.TimeStamp,
			NewMove.Acceleration * 10,
			ClientLoc,
			NewMove.CompressedFlags(),
			ClientRoll,
			View
		);
	}
    else if ( (NewMove.Acceleration * 10 == vect(0,0,0)) && (NewMove.DoubleClickMove == DCLICK_None) && !NewMove.bDoubleJump )
    {
		ShortServerMove
		(
			NewMove.TimeStamp,
			ClientLoc,
			NewMove.CompressedFlags(),
			ClientRoll,
			View
		);
    }
    else
		ServerMove
	(
	    NewMove.TimeStamp,
	    NewMove.Acceleration * 10,
	    ClientLoc,
			NewMove.CompressedFlags(),
	    ClientRoll,
	    View
	);
}

/* ShortServerMove()
compressed version of server move for bandwidth saving
*/
unreliable server function ShortServerMove
(
	float TimeStamp,
	vector ClientLoc,
	byte NewFlags,
	byte ClientRoll,
	int View
)
{
    ServerMove(TimeStamp,vect(0,0,0),ClientLoc,NewFlags,ClientRoll,View);
}

unreliable client function LongClientAdjustPosition( float TimeStamp, name NewState, EPhysics NewPhysics,
					float NewLocX, float NewLocY, float NewLocZ,
					float NewVelX, float NewVelY, float NewVelZ, Actor NewBase,
					float NewFloorX, float NewFloorY, float NewFloorZ )
{
	local UTPawn P;
	local vector OldPos, NewPos;

	P = UTPawn(Pawn);
	if (P != None)
	{
		OldPos = P.Mesh.GetPosition();
	}

	Super.LongClientAdjustPosition( TimeStamp, NewState, NewPhysics, NewLocX, NewLocY, NewLocZ,
					NewVelX, NewVelY, NewVelZ, NewBase, NewFloorX, NewFloorY, NewFloorZ );

	// allow changing location of rigid body pawn if feigning death
	if (P != None && P.bFeigningDeath && P.Physics == PHYS_RigidBody)
	{
		// the actor's location (and thus the mesh) were moved in the Super call, so we just need
		// to tell the physics system to do the same
		NewPos = P.Mesh.GetPosition();
		if (VSizeSq(NewPos - OldPos) > REP_RBLOCATION_ERROR_TOLERANCE_SQ)
		{
			P.Mesh.SetRBPosition(P.Mesh.GetPosition());
		}
	}
}

auto state PlayerWaiting
{
	exec function SwitchWeapon(byte F){}

	/** called when the actor falls out of the world 'safely' (below KillZ and such) */
	simulated event FellOutOfWorld(class<DamageType> dmgType)
	{
		bCameraOutOfWorld = true;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector OldLocation;

		OldLocation = Location;
		super.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);

		if ( bCameraOutOfWorld )
		{
			bCameraOutOfWorld = false;
			SetLocation(OldLocation);
		}
	}

	exec function StartFire( optional byte FireModeNum )
	{
		ServerReStartPlayer();
	}

	reliable server function ServerRestartPlayer()
	{
		Super.ServerRestartPlayer();
		if (WorldInfo.Game.bWaitingToStartMatch && UTGame(WorldInfo.Game).bWarmupRound && UTGame(WorldInfo.Game).WarmupTime > 1.0)
		{
			WorldInfo.Game.RestartPlayer(self);
		}
	}
}

function ViewNextBot()
{
	if ( CheatManager != None )
		CheatManager.ViewBot();
}

exec function SwitchWeapon(byte T)
{
	if (UTPawn(Pawn) != None)
		UTPawn(Pawn).SwitchWeapon(t);
	else if (UDKVehicleBase(Pawn) != none)
		UDKVehicleBase(Pawn).SwitchWeapon(t);
}

unreliable server function ServerViewSelf(optional ViewTargetTransitionParams TransitionParams)
{
	local rotator POVRotation;
	local vector POVLocation;

	GetPlayerViewPoint( POVLocation, POVRotation );
	SetLocation(POVLocation);
	SetRotation(POVRotation);
	SetBehindView(false);
	SetViewTarget( Self, TransitionParams );
}

exec function ViewPlayerByName(string PlayerName);

unreliable server function ServerViewPlayerByName(string PlayerName)
{
	local int i;
	for (i=0;i<WorldInfo.GRI.PRIArray.Length;i++)
	{
		if (WorldInfo.GRI.PRIArray[i].PlayerName ~= PlayerName)
		{
			if ( WorldInfo.Game.CanSpectate(self, WorldInfo.GRI.PRIArray[i]) )
			{
				SetViewTarget(WorldInfo.GRI.PRIArray[i]);
			}
			return;
		}
	}

	ClientMessage(MsgPlayerNotFound);
}

exec function ViewObjective()
{
	ServerViewObjective();
}

unreliable server function ServerViewObjective()
{
	if ( (UTGame(WorldInfo.Game) != none) && (WorldInfo.NetMode == NM_Standalone) )
		UTGame(WorldInfo.Game).ViewObjective(self);
}

exec function PrevWeapon()
{
	if ( (Vehicle(Pawn) != None) || (Pawn == None) )
	{
		AdjustCameraScale(true);
	}
	else if (!Pawn.IsInState('FeigningDeath'))
	{
		Super.PrevWeapon();
	}
}

exec function NextWeapon()
{
	if ( (Vehicle(Pawn) != None) || (Pawn == None) )
	{
		AdjustCameraScale(false);
	}
	else if (!Pawn.IsInState('FeigningDeath'))
	{
		Super.NextWeapon();
	}
}

/** moves the camera in or out */
exec function AdjustCameraScale(bool bIn)
{
	if (Pawn(ViewTarget) != None)
	{
		Pawn(ViewTarget).AdjustCameraScale(bIn);
	}
}

state WaitingForPawn
{
	exec function SwitchWeapon(byte F){}

	/** called when the actor falls out of the world 'safely' (below KillZ and such) */
	simulated event FellOutOfWorld(class<DamageType> dmgType)
	{
		bCameraOutOfWorld = true;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector OldLocation;

		OldLocation = Location;
		super.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);

		if ( bCameraOutOfWorld )
		{
			bCameraOutOfWorld = false;
			SetLocation(OldLocation);
		}
	}

	simulated event GetPlayerViewPoint( out vector out_Location, out Rotator out_Rotation )
	{
		if ( PlayerCamera == None )
		{
			out_Location = Location;
			out_Rotation = BlendedTargetViewRotation;
		}
		else
			Global.GetPlayerViewPoint(out_Location, out_Rotation);
	}
}

state Spectating
{
	exec function SwitchWeapon(byte F){}

	function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		if ( CurrentMapScene != none )
		{
		//@todo ronp animation
			CurrentMapScene.CloseScene();
		}

		// Ugly hack to change to follow bots around after they are spawned if automated perf testing is enabled.
		// This should be replaced with a more robust solution.
		if( WorldInfo.Game!=None && WorldInfo.Game.IsAutomatedPerfTesting() )
		{
			SetTimer( 5.0f, FALSE, 'SetServerViewNextPlayer' ); // get the spectating going asap instead of waiting for 30secs.  need to wait some as the player will not be spawned yet
			SetTimer( 30.0f, TRUE, 'ServerViewNextPlayer');
		}
	}

	function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		// Reset timer set in BeginState.
		ClearTimer( 'ServerViewNextPlayer' );
	}

	function SetServerViewNextPlayer()
	{
		ServerViewNextPlayer();
	}

	/** called when the actor falls out of the world 'safely' (below KillZ and such) */
	simulated event FellOutOfWorld(class<DamageType> dmgType)
	{
		bCameraOutOfWorld = true;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector OldLocation;

		OldLocation = Location;
		super.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);

		if ( bCameraOutOfWorld )
		{
			bCameraOutOfWorld = false;
			SetLocation(OldLocation);
		}
	}

	exec function ViewPlayerByName(string PlayerName)
	{
		ServerViewPlayerByName(PlayerName);
	}

	exec function BehindView()
	{
		bForceBehindView = !bForceBehindview;
	}

	/**
	 * The Prev/Next weapon functions are used to move forward and backwards through the player list
	 */

	exec function PrevWeapon()
	{
		ServerViewPrevPlayer();
	}

	exec function NextWeapon()
	{
		ServerViewNextPlayer();
	}

	/**
	 * Fire will select the next/prev objective
	 */
	exec function StartFire( optional byte FireModeNum )
	{
		ServerViewObjective();
	}

	unreliable server function ServerViewObjective()
	{
		if ( UTGame(WorldInfo.Game) != none )
			UTGame(WorldInfo.Game).ViewObjective(self);
	}

	/**
	 * AltFire - Resets to Free Camera Mode
	 */
	exec function StartAltFire( optional byte FireModeNum )
	{
		ServerViewSelf();
	}

	/**
	 * Handle forcing behindview/etc
	 */
	simulated event GetPlayerViewPoint( out vector out_Location, out Rotator out_Rotation )
	{
		// Force first person mode if we're performing automated perf testing.
		if( WorldInfo.Game!=None && WorldInfo.Game.IsAutomatedPerfTesting() )
		{
			SetBehindView(false);
		}
		else if (bBehindview != bForceBehindView && UTPawn(ViewTarget)!=None)
		{
			SetBehindView(bForceBehindView);
		}
		Global.GetPlayerViewPoint(out_Location, out_Rotation);
	}
}

/**
 * This state is used when the player is out of the match waiting to be brought back in
 */
state InQueue extends Spectating
{
	function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		PlayerReplicationInfo.bIsSpectator = true;
	}

	function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);

		SetBehindView(false);
	}
}

/** Internal.  Returns FALSE if we're restricted from commincating, TRUE otherwise. */
simulated private function bool CanCommunicate()
{
	if ( (OnlineSub != None) && (OnlineSub.PlayerInterface != None) && (LocalPlayer(Player) != None) )
	{
		return ( OnlineSub.PlayerInterface.CanCommunicate(LocalPlayer(Player).ControllerId) != FPL_Disabled && !bServerMutedText );
	}

	// assume we are allowed to talk unless the online layer specifically says we cannot
	return !bServerMutedText;
}

exec function ShowMap()
{
	local byte DesiredBase;
	local UTPlayerReplicationInfo UTPRI;

	UTPRI = UTPlayerReplicationInfo(PlayerReplicationInfo);

	if ( (UTCTFHUD(myHUD) != None) && (UTPRI != None) && (UTPRI.Team != None) )
	{
		DesiredBase = UTPRI.bHasFlag ? UTPRI.Team.TeamIndex : (1 - UTPRI.Team.TeamIndex);
		BasePath(DesiredBase);
	}
}

server reliable function ServerViewingMap(bool bNewValue)
{
	bViewingMap = bNewValue;
}


function UTUIScene_MidGameMenu ShowMidGameMenu(optional name TabTag,optional bool bEnableInput)
{
	local UTGameReplicationInfo GRI;

	if ( CommandMenu != none )
	{
		CommandMenu.CloseScene();
		CommandMenu = none;
	}

	GRI = UTGameReplicationInfo(WorldInfo.GRI);
	if ( GRI != none )
	{
		return GRI.ShowMidGameMenu(self, TabTag, bEnableInput);
	}

	return none;
}


/* epic ===============================================
* ::ClientGameEnded
*
* Replicated equivalent to GameHasEnded().
*
 * @param	EndGameFocus - actor to view with camera
 * @param	bIsWinner - true if this controller is on winning team
* =====================================================
*/
reliable client function ClientGameEnded(optional Actor EndGameFocus, optional bool bIsWinner)
{
	if( EndGameFocus == None )
		ServerVerifyViewTarget();
	else
	{
		SetViewTarget(EndGameFocus);
	}

	if ( (PlayerReplicationInfo != None) && !PlayerReplicationInfo.bOnlySpectator )
		PlayWinMessage( bIsWinner );

	ClientEndZoom();

	GotoState('RoundEnded');

	SetBehindView(true);
}

/* epic ===============================================
* ::RoundHasEnded
*
 * @param	EndRoundFocus - actor to view with camera
* =====================================================
*/
function RoundHasEnded(optional Actor EndRoundFocus)
{
	SetViewTarget(EndRoundFocus);
	ClientRoundEnded(EndRoundFocus);
	GotoState('RoundEnded');
}

/* epic ===============================================
* ::ClientRoundEnded
*
 * @param	EndRoundFocus - actor to view with camera
* =====================================================
*/
reliable client function ClientRoundEnded(Actor EndRoundFocus)
{
	if( EndRoundFocus == None )
		ServerVerifyViewTarget();
	else
	{
		SetViewTarget(EndRoundFocus);
	}
	ClientEndZoom();

	GotoState('RoundEnded');

	SetBehindView(true);
}

/* epic ===============================================
* ::CheckBulletWhip
*
 * @param	BulletWhip - whip sound to play
 * @param	FireLocation - where shot was fired
 * @param	FireDir	- direction shot was fired
 * @param	HitLocation - impact location of shot
* =====================================================
*/
function CheckBulletWhip(soundcue BulletWhip, vector FireLocation, vector FireDir, vector HitLocation)
{
	local vector PlayerDir;
	local float Dist, PawnDist;

	if ( ViewTarget != None  )
	{
		// if bullet passed by close enough, play sound
		// first check if bullet passed by at all
		PlayerDir = ViewTarget.Location - FireLocation;
		Dist = PlayerDir Dot FireDir;
		if ( (Dist > 0) && ((FireDir Dot (HitLocation - ViewTarget.Location)) > 0) )
		{
			// check distance from bullet to vector
			PawnDist = VSize(PlayerDir);
			if ( Square(PawnDist) - Square(Dist) < 40000 )
			{
				// check line of sight
				if ( FastTrace(ViewTarget.Location + class'UTPawn'.default.BaseEyeheight*vect(0,0,1), FireLocation + Dist*FireDir) )
				{
					PlaySound(BulletWhip, true,,, HitLocation);
				}
			}
		}
	}
}
/* epic ===============================================
* ::PawnDied - Called when a pawn dies
*
 * @param	P - The pawn that died
* =====================================================
*/

function PawnDied(Pawn P)
{
	LastAutoObjective = None;
	Super.PawnDied(P);
	ClientPawnDied();
}

/**
 * Client-side notification that the pawn has died.
 */
reliable client simulated function ClientPawnDied()
{
	// Unduck if ducking
	bDuck = 0;

	// End Zooming

	EndZoom();
}

/** shows the path to the specified team's base or other main objective */
exec function BasePath(byte Num)
{
	if (PlayerReplicationInfo.Team != None)
	{
		ServerShowPathToBase(num);
	}
}

reliable server function ServerShowPathToBase(byte TeamNum)
{
	if (Pawn != None && WorldInfo.TimeSeconds - LastShowPathTime > 0.5)
	{
		LastShowPathTime = WorldInfo.TimeSeconds;

		UTGame(WorldInfo.Game).ShowPathTo(self, TeamNum);
	}
}

exec function BecomeActive()
{
	if (PlayerReplicationInfo.bOnlySpectator)
	{
		ServerBecomeActivePlayer();
	}
}

//spectating player wants to become active and join the game
reliable server function ServerBecomeActivePlayer()
{
	local UTGame Game;

	Game = UTGame(WorldInfo.Game);
	if ( PlayerReplicationInfo.bOnlySpectator && !WorldInfo.IsInSeamlessTravel() && HasClientLoadedCurrentWorld()
		&& Game != None && Game.AllowBecomeActivePlayer(self) )
	{
		SetBehindView(false);
		FixFOV();
		ServerViewSelf();
		PlayerReplicationInfo.bOnlySpectator = false;
		Game.NumSpectators--;
		Game.NumPlayers++;
		PlayerReplicationInfo.Reset();
		BroadcastLocalizedMessage(Game.GameMessageClass, 1, PlayerReplicationInfo);
		if (Game.bTeamGame)
		{
			//@FIXME: get team preference!
			Game.ChangeTeam(self, Game.PickTeam(0, None), false);
		}
		if (!Game.bDelayedStart)
		{
			// start match, or let player enter, immediately
			Game.bRestartLevel = false;  // let player spawn once in levels that must be restarted after every death
			if (Game.bWaitingToStartMatch)
			{
				Game.StartMatch();
			}
			else
			{
				Game.RestartPlayer(self);
			}
			Game.bRestartLevel = Game.Default.bRestartLevel;
		}
		else
		{
			GotoState('PlayerWaiting');
			ClientGotoState('PlayerWaiting');
		}

		ClientBecameActivePlayer();
	}
}

reliable client function ClientBecameActivePlayer()
{
	UpdateURL("SpectatorOnly", "", false);
}

exec function FlushDebug()
{
	FlushPersistentDebugLines();
}

/*********************************************************************************************
 * Zooming Functions
 *********************************************************************************************/

/** called through camera anim code when it modifies FOVAngle */
function OnUpdatePropertyFOVAngle()
{
	bCurrentCamAnimAffectsFOV = true;
	// adjust the anim's FOV so that it is relative to our desired FOV
	FOVAngle = DesiredFOV + (FOVAngle - 90.0);
}

/**
 * Called each frame from PlayerTick this function is used to transition towards the DesiredFOV
 * if not already at it.
 *
 * @Param	DeltaTime 	-	Time since last update
 */
function AdjustFOV(float DeltaTime)
{
	local float DeltaFOV;

	if (FOVAngle != DesiredFOV && (!bCurrentCamAnimAffectsFOV || CameraAnimPlayer.bFinished))
	{
		if (bNonlinearZoomInterpolation)
		{
			// do nonlinear interpolation
			FOVAngle = FInterpTo(FOVAngle, DesiredFOV, DeltaTime, FOVNonlinearZoomInterpSpeed);
		}
		else
		{
			// do linear interpolation
			if ( FOVLinearZoomRate > 0.0 )
			{
				DeltaFOV = FOVLinearZoomRate * DeltaTime;

				if (FOVAngle > DesiredFOV)
				{
					FOVAngle = FMax( DesiredFOV, (FOVAngle - DeltaFOV) );
				}
				else
				{
					FOVAngle = FMin( DesiredFOV, (FOVAngle + DeltaFOV) );
				}
			}
			else
			{
				FOVAngle = DesiredFOV;
			}
		}
	}
}

/**
 * This function will cause the PlayerController to begin zooming to a new FOV Level.
 *
 * @Param	NewDesiredFOV		-	The new FOV Value to head towards
 * @Param	NewZoomRate			- 	The rate of transition in degrees per second
 */

simulated function StartZoom(float NewDesiredFOV, float NewZoomRate)
{
	FOVLinearZoomRate = NewZoomRate;
	DesiredFOV = NewDesiredFOV;

	// clear out any nonlinear zoom info
	bNonlinearZoomInterpolation = FALSE;
	FOVNonlinearZoomInterpSpeed = 0.f;
}

/*
 * @Param	bNonlinearInterp	-	TRUE to use FInterpTo, which provides for a nonlinear interpolation with a decelerating arrival characteristic.
 *									FALSE for Linear interpolation.
 */
simulated function StartZoomNonlinear(float NewDesiredFOV, float NewZoomInterpSpeed)
{
	DesiredFOV = NewDesiredFOV;
	FOVNonlinearZoomInterpSpeed = NewZoomInterpSpeed;

	// clear out any linear zoom info
	bNonlinearZoomInterpolation = TRUE;
	FOVLinearZoomRate = 0.f;
}

/**
 * This function will stop the zooming process keeping the current FOV Angle
 */
simulated function StopZoom()
{
	DesiredFOV = FOVAngle;
	FOVLinearZoomRate = 0.0f;
}

/**
 * This function will end a zoom and reset the FOV to the default value
 */

simulated function EndZoom()
{
	DesiredFOV = DefaultFOV;
	FOVAngle = DefaultFOV;
	FOVLinearZoomRate = 0.0f;
	FOVNonlinearZoomInterpSpeed = 0.f;
}

/** Ends a zoom, but interpolates nonlinearly back to the default value. */
simulated function EndZoomNonlinear(float ZoomInterpSpeed)
{
	DesiredFOV = DefaultFOV;
	FOVNonlinearZoomInterpSpeed = ZoomInterpSpeed;

	// clear out any linear zoom info
	bNonlinearZoomInterpolation = TRUE;
	FOVLinearZoomRate = 0.f;
}

/**
 * Allows the server to tell the client to end zoom
 */
reliable simulated client function ClientEndZoom()
{
	EndZoom();
}

function UpdateRotation( float DeltaTime )
{
	local rotator DeltaRot;

	if (bDebugFreeCam)
	{
		// Calculate Delta to be applied on ViewRotation
		DeltaRot.Yaw	= PlayerInput.aTurn;
		DeltaRot.Pitch	= PlayerInput.aLookUp;
		ProcessViewRotation( DeltaTime, DebugFreeCamRot, DeltaRot );
	}
	else
	{
		super.UpdateRotation(DeltaTime);
	}
}

/** debug command for bug reports */
exec function GetPlayerLoc()
{
	`Log("Location:" @ Location,, 'PlayerLoc');
	`Log("Rotation:" @ Rotation,, 'PlayerLoc');
}

/** called when the GRI finishes processing custom character meshes */
function CharacterProcessingComplete()
{
	local string LastMovie;
	local LocalPlayer LP;

	LastMovie = class'Engine'.Static.GetLastMovieName();

	if(InStr(LastMovie, "UT_loadmovie") != -1)
	{
		// stop the loading movie that was up during precaching
		class'Engine'.static.StopMovie(true);
	}

	// if the controller was yanked while we were loading, we couldn't pause the game because that would cause character construction
	// to never complete, so check for a missing controller now

	// don't check for None so that we know if we don't have a valid OnlineSub at this point.
	LP = LocalPlayer(Player);
	if ( LP != None )
	{
		if ( OnlineSub != None && OnlineSub.SystemInterface != None && 
			!OnlineSub.SystemInterface.IsControllerConnected(LP.ControllerId) )
		{
			OnControllerChanged(LP.ControllerId, false);
		}
	}
}

function bool CanRestartPlayer()
{
	//local UTGame Game;

	//Game = UTGame(WorldInfo.Game);
	//return ((bInitialProcessingComplete || (Game != None && Game.bQuickStart)) && Super.CanRestartPlayer());
    return Super.CanRestartPlayer();
}

/**
 * Sets the ClanTag for this player.
 *
 * @param InClanTag	New clan tag for the player.
 */
reliable server function ServerSetClanTag(string InClanTag)
{
	if ( Len(InClanTag) > 16 )
	{
		InClanTag = Left(InClanTag, 16);
	}
	UTPlayerReplicationInfo(PlayerReplicationInfo).ClanTag = InClanTag;
}

/** Loads the player's custom character from their profile. */
function LoadCharacterFromProfile(UTProfileSettings Profile)
{
	local string OutStringValue;
	local bool bRandomCharacter;
	local class<UTFamilyInfo> CharClass;

	bRandomCharacter = true;

	// get character info and send to server
	if(Profile.GetProfileSettingValueStringByName('CharacterClass', OutStringValue))
	{
		if(Len(OutStringValue)>0)
		{
			`Log("UTPlayerController::LoadCharacterFromProfile() - Loaded character class"@OutStringValue@"from profile.");
			CharClass = class<UTFamilyInfo>(DynamicLoadObject(OutStringValue, class'Class'));
			ServerSetCharacterClass(CharClass);
			bRandomCharacter = false;
		}
	}

	// Autogenerate character data if they do not have a character set.
	if (bRandomCharacter)
	{
		`Log("UTPlayerController::LoadCharacterFromProfile() - Character data not found, generating a random character.");
		CharClass = class<UTFamilyInfo>(DynamicLoadObject(class'UTCharInfo'.static.GetRandomCharClassName(), class'Class'));
		ServerSetCharacterClass(CharClass);
	}
}

function SendMessage(PlayerReplicationInfo Recipient, name MessageType, float Wait, optional class<DamageType> DamageType)
{
	if ( (MessageType == 'TAUNT') && (Recipient != None) && (UTPlayerController(Recipient.Owner) != None) && !UTPlayerController(Recipient.Owner).bAutoTaunt )
	{
		// don't autotaunt people who don't want it
		return;
	}
	UTPlayerReplicationInfo(PlayerReplicationInfo).VoiceClass.static.SendVoiceMessage(self, Recipient, MessageType, DamageType);
}

/**
  * Receive a voice message from a bot - process locally, since character may be different on client
  */
unreliable client function ReceiveBotVoiceMessage(UTPlayerReplicationInfo SenderPRI, int MessageIndex, object LocationObject)
{
	if ( SenderPRI.VoiceClass != None )
	{
		ReceiveLocalizedMessage( SenderPRI.VoiceClass, MessageIndex, SenderPRI,, LocationObject );
	}
}

/** Gathers player settings from the client's profile. */
exec function RetrieveSettingsFromProfile()
{
	LoadSettingsFromProfile(true);
}

/**
 * Updates sound volumes and screen brightness.
 * Done in a seperate function so it can be called by the sliders to update these values in real time without doing a lot of extra work.
 */
function UpdateVolumeAndBrightness()
{
	local int OutIntValue;
	local UTProfileSettings Profile;

	Profile = UTProfileSettings(OnlinePlayerData.ProfileProvider.Profile);

	// Set volumes
	if(Profile.GetProfileSettingValueIntByName('SFXVolume', OutIntValue))
	{
		SetAudioGroupVolume( 'SFX', (OutIntValue / 10.0f) );
	}

	if(Profile.GetProfileSettingValueIntByName('VoiceVolume', OutIntValue))
	{
		SetAudioGroupVolume( 'Dialog', (OutIntValue / 10.0f) );
	}

	if(Profile.GetProfileSettingValueIntByName('AnnouncerVolume', OutIntValue))
	{
		SetAudioGroupVolume( 'Announcer', (OutIntValue / 10.0f) );
	}

	if(Profile.GetProfileSettingValueIntByName('MusicVolume', OutIntValue))
	{
		SetAudioGroupVolume( 'Music', (OutIntValue / 10.0f) );
	}

	if(Profile.GetProfileSettingValueIntByName('AmbianceVolume', OutIntValue))
	{
		SetAudioGroupVolume( 'Ambient', (OutIntValue / 10.0f) );
	}

	// Set Gamma
	if(Profile.GetProfileSettingValueIntByName('Gamma', OutIntValue))
	{
		SetGamma(OutIntValue / 10.0f);
	}
}

function LoadSettingsFromProfile(bool bLoadCharacter)
{
	local int PlayerIndex, OutIntValue, NewNetSpeed, WeapInstIdx, WeapClassIdx;
	local float OutFloatValue;
	local string OutStringValue;
	local UTProfileSettings Profile;
	local UTHUD MyUTHUD;
	local UTWeapon W;
	local class<UTWeapon> WeapClass;

	// get a list of all existing weapon instances
	local array<class<UTWeapon> > WeaponClasses;
	local array<UTWeapon> WeaponInstances;

	if (LocalPlayer(Player) == None)
	{
		return;
	}

	// If we are NOT epic internal, then do not set any settings.
	if (!bShouldLoadSettingsFromProfile )
	{
		`Log("UTPlayerController::LoadSettingsFromProfile() - Not an Epic internal build, skipping setting profile settings.");
		return;
	}

	MyUTHUD = UTHUD(myHUD);
	Profile = UTProfileSettings(OnlinePlayerData.ProfileProvider.Profile);

	if(Profile != none)
	{
		PlayerIndex = GetUIPlayerIndex();

		`Log("Retrieving Profile Settings for UI PlayerIndex " $ PlayerIndex);

		// If we're the 2nd player and we are not logged-in, then set the profile to defaults.
		if(PlayerIndex == 1 && OnlineSub!=None && OnlineSub.PlayerInterface!=None && OnlineSub.PlayerInterface.GetLoginStatus(LocalPlayer(Player).ControllerId)==LS_NotLoggedIn)
		{
			`Log("UTPlayerController::OnReadProfileSettingsComplete() - 2nd player not logged in, resetting profile to defaults, ControllerId: " $ LocalPlayer(Player).ControllerId);
			if(OnlinePlayerData.ProfileProvider.Profile != None)
			{
				OnlinePlayerData.ProfileProvider.Profile.SetToDefaults();
			}
		}

		///////////////////////////////////////////////////////////////////////////
		// Player Custom Character
		///////////////////////////////////////////////////////////////////////////

		if(Profile.GetProfileSettingValueId(class'UTProfileSettings'.const.UTPID_AllowCustomCharacters, OutIntValue))
		{
			class'UTGameReplicationInfo'.default.bForceDefaultCharacter = (OutIntValue == UTPID_VALUE_NO);
			if (UTGameReplicationInfo(WorldInfo.GRI) != None)
			{
				UTGameReplicationInfo(WorldInfo.GRI).bForceDefaultCharacter = class'UTGameReplicationInfo'.default.bForceDefaultCharacter;
			}
		}

		if (bLoadCharacter)
		{
			LoadCharacterFromProfile(Profile);
		}

		///////////////////////////////////////////////////////////////////////////
		// Shared Options - These options are shared between all players on this machine.
		///////////////////////////////////////////////////////////////////////////

		// Only allow player 0 to set shared options.
		if(PlayerIndex==0)
		{
			UpdateVolumeAndBrightness();
		}

		///////////////////////////////////////////////////////////////////////////
		// Video Options
		///////////////////////////////////////////////////////////////////////////

		// PostProcessPreset
		if(Profile.GetProfileSettingValueIdByName('PostProcessPreset', OutIntValue))
		{
			if(OutIntValue < PostProcessPresets.length)
			{
				Player.PP_DesaturationMultiplier = PostProcessPresets[OutIntValue].Desaturation;
				Player.PP_HighlightsMultiplier = PostProcessPresets[OutIntValue].Highlights;
				Player.PP_MidTonesMultiplier = PostProcessPresets[OutIntValue].MidTones;
				Player.PP_ShadowsMultiplier = PostProcessPresets[OutIntValue].Shadows;
			}
		}

		if(Profile.GetProfileSettingValueIdByName('EnableHardwarePhysics', OutIntValue))
		{
			SetHardwarePhysicsEnabled(OutIntValue==UTPID_VALUE_YES);
		}

		if(Profile.GetProfileSettingValueIdByName('Subtitles', OutIntValue))
		{
			SetShowSubtitles(OutIntValue==UTPID_VALUE_YES);
		}



		///////////////////////////////////////////////////////////////////////////
		// Audio Options
		///////////////////////////////////////////////////////////////////////////

		// AnnounceSetting
		if (Announcer != None && Profile.GetProfileSettingValueIdByName('AnnounceSetting', OutIntValue))
		{
			Announcer.AnnouncerLevel = byte(OutIntValue);
		}

		// AutoTaunt
		if(Profile.GetProfileSettingValueIdByName('AutoTaunt', OutIntValue))
		{
			SetAutoTaunt(OutIntValue==UTPID_VALUE_YES);
		}

		// MuteVoice
		if( Profile.GetProfileSettingValueIdByName( 'MuteVoice', OutIntValue ) )
		{
			if( VoiceInterface != None )
			{
				// Is muting enabled?
				if( OutIntValue == 1 )
				{
					// Prevent us from hearing anyone
					VoiceInterface.MuteAll( PlayerIndex, false );		// Allow friends?
				}
				else
				{
					// Allow us to hear everyone
					VoiceInterface.UnmuteAll( PlayerIndex );
				}
			}
		}

		// TextToSpeechMode
		if(Profile.GetProfileSettingValueIdByName('TextToSpeechMode', OutIntValue))
		{
			switch(OutIntValue)
			{
			case TTSM_None:
				bNoTextToSpeechVoiceMessages=true;
				bTextToSpeechTeamMessagesOnly=false;
				break;
			case TTSM_TeamOnly:
				bNoTextToSpeechVoiceMessages=false;
				bTextToSpeechTeamMessagesOnly=true;
				break;
			case TTSM_All:default:
				bNoTextToSpeechVoiceMessages=false;
				bTextToSpeechTeamMessagesOnly=false;
			}
		}

		///////////////////////////////////////////////////////////////////////////
		// Input Options
		///////////////////////////////////////////////////////////////////////////

		if ( PlayerInput != none )
		{
			// Invert Y
			if(Profile.GetProfileSettingValueIdByName('InvertY', OutIntValue))
			{
				PlayerInput.bInvertMouse = (OutIntValue==PYIO_On);
			}

			// Invert X
			if(Profile.GetProfileSettingValueIdByName('InvertX', OutIntValue))
			{
				PlayerInput.bInvertTurn = (OutIntValue==PXIO_On);
			}

			// Mouse Smoothing
			if(Profile.GetProfileSettingValueIdByName('MouseSmoothing', OutIntValue))
			{
				PlayerInput.bEnableMouseSmoothing = (OutIntValue==UTPID_VALUE_YES);
			}

			// Mouse Sensitivity (Game)
			if(Profile.GetProfileSettingValueIntByName('MouseSensitivityGame', OutIntValue))
			{
				// Fix up non-patch values
				if ( OutIntValue < 11 )
				{
					OutIntValue = 5 * OutIntValue * 100;
					Profile.SetProfileSettingValueInt(423, OutIntValue); // UTPID_MouseSensitivityGame = 423
				}
				PlayerInput.MouseSensitivity = OutIntValue / 100.0;	// Mouse sensitivity is between 0-100
			}

			// MouseAccelTreshold
			if(Profile.GetProfileSettingValueIntByName('MouseAccelTreshold', OutIntValue))
			{
				// @todo: Hookup
				//PlayerInput.MouseAccelTreshold = OutIntValue / 10.0f;
			}

			// ReduceMouseLag
			if(Profile.GetProfileSettingValueIdByName('ReduceMouseLag', OutIntValue))
			{
				// @todo: Hookup
				//PlayerInput.ReduceMouseLag = (OutIntValue==UTPID_VALUE_YES);
			}

			// Enable Joystick
			if(Profile.GetProfileSettingValueIdByName('EnableJoystick', OutIntValue))
			{
				if ( OutIntValue==UTPID_VALUE_YES )
				{
					ConsoleCommand("ALLOWJOYSTICKINPUT");
				}
				else
				{
					ConsoleCommand("DISABLEJOYSTICKINPUT");
			}
		}

		// Vehicle control type
		if(Profile.GetProfileSettingValueIdByName('VehicleControls', OutIntValue))
		{
			VehicleControlType = EUTVehicleControls(OutIntValue);
			// Send to server
			ServerPlayerPreferences(WeaponHandPreference, bAutoTaunt, bCenteredWeaponFire, AutoObjectivePreference, VehicleControlType);
		}

		// DodgeDoubleClickTime
		if(Profile.GetProfileSettingValueIntByName('DodgeDoubleClickTime', OutIntValue))
		{
			PlayerInput.DoubleClickTime = OutIntValue / 100.0f;
		}
		}

		///////////////////////////////////////////////////////////////////////////
		// Game Options
		///////////////////////////////////////////////////////////////////////////

		// Crosshair Type
		if(Profile.GetProfileSettingValueIdByName('CrosshairType', OutIntValue))
		{
			switch(OutIntValue)
			{
			case CHT_None:
				bSimpleCrosshair=false;
				bNoCrosshair=true;
				break;
			case CHT_Simple:
				bSimpleCrosshair=true;
				bNoCrosshair=false;
				break;
			case CHT_Normal:default:
				bSimpleCrosshair=false;
				bNoCrosshair=false;
				break;
			}
		}

		// Weapon Bob
		if(Profile.GetProfileSettingValueIdByName('ViewBob', OutIntValue))
		{
			class'UTPawn'.default.bWeaponBob = (OutIntValue == PYIO_On);
			if (UTPawn(Pawn) != None)
			{
				UTPawn(Pawn).bWeaponBob = class'UTPawn'.default.bWeaponBob;
			}
		}

		// GoreLevel
		if(Profile.GetProfileSettingValueIdByName('GoreLevel', OutIntValue))
		{
			class'GameInfo'.default.GoreLevel = OutIntValue;
		}

		// WeaponSwitchOnPickup
		if(Profile.GetProfileSettingValueIdByName('WeaponSwitchOnPickup', OutIntValue))
		{
			bNeverSwitchOnPickup = (OutIntValue != UTPID_VALUE_YES);
		}

		// Auto Aim
		if(Profile.GetProfileSettingValueIdByName('AutoAim', OutIntValue))
		{
			bAimingHelp = (OutIntValue==PAAO_On);
		}

		// NetworkConnection
		if( !WorldInfo.IsConsoleBuild() && Profile.GetProfileSettingValueIdByName('NetworkConnection', OutIntValue) )
		{
			// @todo: Find reasonable values for these.
			switch(OutIntValue)
			{
			case NETWORKTYPE_Modem:
				NewNetSpeed = 2600;
				break;
			case NETWORKTYPE_ISDN:
				NewNetSpeed = 7000;
				break;
			case NETWORKTYPE_Cable:
				NewNetSpeed = 10000;
				break;
			case NETWORKTYPE_LAN:
				NewNetSpeed = 15000;
				break;
			default:
				NewNetSpeed = 10000;
				break;
			}
			SetNetSpeed(NewNetSpeed);
			ServerSetNetSpeed(NewNetSpeed);
			`Log("UTPlayerController - Setting netspeed to "$NewNetSpeed);
		}

		// Set the player's name to their profile id.
		SetName(OnlinePlayerData.PlayerNick);

		// ClanTag
		if(Profile.GetProfileSettingValueByName('ClanTag', OutStringValue))
		{
			if ( Len(OutStringValue) > 16 )
			{
				OutStringValue = Left(OutStringValue, 16);
			}
			ServerSetClanTag(OutStringValue);
		}

		///////////////////////////////////////////////////////////////////////////
		// Weapon Options
		///////////////////////////////////////////////////////////////////////////

		// WeaponHand
		if(Profile.GetProfileSettingValueIdByName('WeaponHand', OutIntValue))
		{
			SetHand(EWeaponHand(OutIntValue));
		}

		foreach DynamicActors(class'UTWeapon', W)
		{
			WeaponInstances.AddItem(W);
		}
		// SmallWeapons
		if(Profile.GetProfileSettingValueIdByName('SmallWeapons', OutIntValue))
		{
			class'UTWeapon'.default.bSmallWeapons = (OutIntValue==UTPID_VALUE_YES);
			for ( WeapInstIdx = 0; WeapInstIdx < WeaponInstances.Length; WeapInstIdx++ )
			{
				W = WeaponInstances[WeapInstIdx];
				W.bSmallWeapons = class'UTWeapon'.default.bSmallWeapons;
			}
		}

		// DisplayWeaponBar
		if(Profile.GetProfileSettingValueIdByName('DisplayWeaponBar', OutIntValue))
		{
			if(MyUTHUD != None)
			{
				MyUTHUD.bShowWeaponbar = (OutIntValue==UTPID_VALUE_YES);
			}
		}

		// LinkGunPriority
		WeaponClasses.AddItem(class'UTWeap_LinkGun');
		if(Profile.GetProfileSettingValueFloat(class'UTProfileSettings'.const.UTPID_LinkGunPriority, OutFloatValue))
		{
			class'UTWeap_LinkGun'.default.Priority=OutFloatValue;
		}

		// RocketLauncherPriority
		WeaponClasses.AddItem(class'UTWeap_RocketLauncher');
		if(Profile.GetProfileSettingValueFloat(class'UTProfileSettings'.const.UTPID_RocketLauncherPriority, OutFloatValue))
		{
			class'UTWeap_RocketLauncher'.default.Priority=OutFloatValue;
		}

		// ShockRiflePriority
		WeaponClasses.AddItem(class'UTWeap_ShockRifleBase');
		if(Profile.GetProfileSettingValueFloat(class'UTProfileSettings'.const.UTPID_ShockRiflePriority, OutFloatValue))
		{
			class'UTWeap_ShockRifleBase'.default.Priority=OutFloatValue;
		}

		// now propagate the new priority values to all instances and child classes
		for ( WeapClassIdx = 0; WeapClassIdx < WeaponClasses.Length; WeapClassIdx++ )
		{
			WeapClass = WeaponClasses[WeapClassIdx];
			for ( WeapInstIdx = 0; WeapInstIdx < WeaponInstances.Length; WeapInstIdx++ )
			{
				W = WeaponInstances[WeapInstIdx];
				if ( ClassIsChildof(W.Class, WeapClass) )
				{
					W.Priority = WeapClass.default.Priority;

					// this might seem a little redundant, but it the easiest way to propagate default values down
					// to content child classes
					W.default.Priority = W.Priority;
				}
			}
		}

		///////////////////////////////////////////////////////////////////////////
		// HUD Options
		///////////////////////////////////////////////////////////////////////////

		if(MyUTHUD != None)
		{
			// ShowMap
			if(Profile.GetProfileSettingValueIdByName('ShowMap', OutIntValue))
			{
				MyUTHUD.bShowMap = (OutIntValue==UTPID_VALUE_YES);
			}

			// ShowClock
			if(Profile.GetProfileSettingValueIdByName('ShowClock', OutIntValue))
			{
				MyUTHUD.bShowClock = (OutIntValue==UTPID_VALUE_YES);
			}

			// Hijack ShowDoll for hiding path
			if(Profile.GetProfileSettingValueIdByName('ShowDoll', OutIntValue))
			{
				bHideObjectivePaths = (OutIntValue==UTPID_VALUE_NO);
			}

			// Hijack MouseSmoothingStrength for crosshair size
			if(Profile.GetProfileSettingValueIntByName('MouseSmoothingStrength', OutIntValue))
			{
				// Fix up non-patch values
				if ( OutIntValue < 2 )
				{
					OutIntValue = 10;
					Profile.SetProfileSettingValueInt(425, OutIntValue); // UTPID_MouseSmoothingStrength = 425
				}
				UTHUDBase(MyHUD).ConfiguredCrosshairScaling = 0.1 * OutIntValue;
			}

			// ShowScoring
			if(Profile.GetProfileSettingValueIdByName('ShowScoring', OutIntValue))
			{
				MyUTHUD.bShowScoring = (OutIntValue==UTPID_VALUE_YES);
			}

			// ShowLeaderboard
			if(Profile.GetProfileSettingValueIdByName('ShowLeaderboard', OutIntValue))
			{
				MyUTHUD.bShowLeaderboard = (OutIntValue==UTPID_VALUE_YES);
			}

			// ShowVehicleArmorCount
			if(Profile.GetProfileSettingValueIdByName('ShowVehicleArmorCount', OutIntValue))
			{
				MyUTHUD.bShowVehicleArmorCount = (OutIntValue==UTPID_VALUE_YES);
			}

			// RotateMap
			if(Profile.GetProfileSettingValueIdByName('RotateMap', OutIntValue))
			{
				bRotateMinimap = (OutIntValue==UTPID_VALUE_YES);
			}
		}

		Profile.ApplyAllKeyBindings(PlayerInput);
	}
}

/**
 * Attempts to open a UI Scene.
 *
 * @Param	Template		The Template of the scene to open.
 * @Returns the opened scene
 */
simulated function UIScene OpenUIScene(UIScene Template)
{
	local UTGameReplicationInfo GRI;

	GRI = UTGameReplicationInfo(WorldInfo.GRI);
	if ( GRI != none )
	{
		return GRI.OpenUIScene(self, Template);
	}

	return none;
}

/**
 * Saves the current profile complete with UI scene
 */
function UTUIScene_SaveProfile SaveProfile(optional Int PlayerIndex)
{
	local UTGameUISCeneClient SC;
	local UTUIScene_SaveProfile SP;

	SC = UTGameUISCeneClient(class'UIRoot'.static.GetSceneClient());
	if ( SC != none )
	{
		SP = SC.ShowSaveProfileScene(self);
		if ( SP != none )
		{
			SP.PlayerIndexToSave = PlayerIndex;
		}
	}

	return SP;
}

function BullseyeMessage()
{
	if ( WorldInfo.TimeSeconds - LastBullseyeTime > 2.0 )
	{
		ReceiveLocalizedMessage( class'UTWeaponKillRewardMessage', 1 );
		LastBullseyeTime = WorldInfo.TimeSeconds;
		UTPlayerReplicationInfo(PlayerReplicationInfo).IncrementEventStat('EVENT_BULLSEYE');
	}
}

/**
 * Don't allow team changes if we are in single player, or too frequently
 */
reliable server function ServerChangeTeam(int N)
{
	if ( (WorldInfo.TimeSeconds > LastTeamChangeTime + 1.0) && !UTGameReplicationInfo(WorldInfo.GRI).bStoryMode)
	{
		LastTeamChangeTime = WorldInfo.TimeSeconds;
		Super.ServerChangeTeam(N);
	}
}

event GetSeamlessTravelActorList(bool bToEntry, out array<Actor> ActorList)
{
	ShowScoreboard();
	Super.GetSeamlessTravelActorList(bToEntry, ActorList);
}

/** Allows the local player or admin to kick a player */
reliable server function ServerKickBan(string PlayerToKick, bool bBan)
{
	if (PlayerReplicationInfo.bAdmin || LocalPlayer(Player) != none )
	{
		if (bBan)
		{
			WorldInfo.Game.AccessControl.KickBan(PlayerToKick);
		}
		else
		{
			WorldInfo.Game.AccessControl.Kick(PlayerToKick);
		}
	}
}

simulated private function bool AllowTTSMessageFrom(PlayerReplicationInfo PRI)
{
	local UTGameReplicationInfo GRI;
	local int SpeakerTeamID, MyTeamID;

	if (bNoTextToSpeechVoiceMessages)
	{
		return FALSE;
	}
	else if ( !bTextToSpeechTeamMessagesOnly || (PRI == PlayerReplicationInfo) )
	{
		return TRUE;
	}

	// else need to check for teammate (in a team game)
	GRI = UTGameReplicationInfo(WorldInfo.GRI);
	if (GRI != None)
	{
		if (GRI.GameClass.default.bTeamGame)
		{
			SpeakerTeamID = PRI.GetTeamNum();
			if (SpeakerTeamID != 255)
			{
				MyTeamID = PlayerReplicationInfo.GetTeamNum();
				if (MyTeamID == SpeakerTeamID)
				{
					return TRUE;
				}
			}
		}
	}

	return FALSE;
}

unreliable server function ServerSay( string Msg )
{
	if ( !bServerMutedText )
	{
		super.ServerSay(Msg);
	}
}

unreliable server function ServerTeamSay( string Msg )
{
	if ( !bServerMutedText )
	{
		Super.ServerTeamSay(Msg);
	}
}

function bool AllowTextMessage(string Msg)
{
	return (CanCommunicate() && Super.AllowTextMessage(Msg));
}

/******************************************
 Admin functions
 ******************************************/

function bool AdminCmdOk()
{
	//If we are the server then commands are ok
	if (WorldInfo.NetMode == NM_ListenServer && LocalPlayer(Player) != None)
	{
		return true;
	}

	if (WorldInfo.TimeSeconds < NextAdminCmdTime)
	{
		return false;
	}

	NextAdminCmdTime = WorldInfo.TimeSeconds + 5.0;
	return true;
}

exec function AdminLogin(string Password)
{
	if (Password != "" && AdminCmdOk() )
	{
		ServerAdminLogin(Password);
	}
}

reliable server function ServerAdminLogin(string Password)
{
	if ( (WorldInfo.Game.AccessControl != none) && AdminCmdOk() )
	{
		if ( WorldInfo.Game.AccessControl.AdminLogin(self, Password) )
		{
			WorldInfo.Game.AccessControl.AdminEntered(Self);
		}
	}
}

exec function AdminLogOut()
{
	if ( AdminCmdOk() )
	{
		ServerAdminLogOut();
	}
}

reliable server function ServerAdminLogOut()
{
	if ( WorldInfo.Game.AccessControl != none )
	{
		if ( WorldInfo.Game.AccessControl.AdminLogOut(self) )
		{
			WorldInfo.Game.AccessControl.AdminExited(Self);
		}
	}
}

// Execute an administrative console command on the server.
exec function Admin( string CommandLine )
{
	if (PlayerReplicationInfo.bAdmin)
	{
		ServerAdmin(CommandLine);
	}
}

reliable server function ServerAdmin( string CommandLine )
{
	local string Result;

	if ( PlayerReplicationInfo.bAdmin )
	{
		Result = ConsoleCommand( CommandLine );
		if( Result!="" )
			ClientMessage( Result );
	}
}

exec function AdminKickBan( string S )
{
	if (PlayerReplicationInfo.bAdmin)
	{
		ServerKickBan(S,true);
	}
}


exec function AdminKick( string S )
{
	if ( PlayerReplicationInfo.bAdmin )
	{
		ServerKickBan(S,false);
	}
}

exec function AdminPlayerList()
{
	local PlayerReplicationInfo PRI;

	if (PlayerReplicationInfo.bAdmin)
	{
		ClientMessage("Player List:");
		foreach DynamicActors(class'PlayerReplicationInfo', PRI)
		{
			ClientMessage(PRI.PlayerID$"."@PRI.PlayerName @ "Ping:" @ INT((float(PRI.Ping) / 250.0 * 1000.0)) $ "ms)");
		}
	}
}

exec function AdminRestartMap()
{
	if (PlayerReplicationInfo.bAdmin)
	{
		ServerRestartMap();
	}
}

reliable server function ServerRestartMap()
{
	if ( PlayerReplicationInfo.bAdmin )
	{
		WorldInfo.ServerTravel("?restart", false);
	}
}

exec function AdminChangeMap( string URL )
{
	if (PlayerReplicationInfo.bAdmin)
	{
		ServerChangeMap(URL);
	}
}

reliable server function ServerChangeMap(string URL)
{
	if ( PlayerReplicationInfo.bAdmin )
	{
		WorldInfo.ServerTravel(URL);
	}
}

exec function AdminForceVoiceMute(string TargetPlayer)
{
	if ( PlayerReplicationInfo.bAdmin )
	{
		ServerForceVoiceMute(TargetPlayer);
	}
}

reliable server function ServerForceVoiceMute(string TargetPlayer)
{
	local PlayerController PC;
	local PlayerController TargetPlayerPC;

	if ( PlayerReplicationInfo.bAdmin )
	{
		TargetPlayerPC = UTPlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(TargetPlayer));
		if ( TargetPlayerPC != none )
		{
			ClientMessage("Muting (Voice):"@TargetPlayerPC.PlayerReplicationInfo.PlayerName);
			foreach WorldInfo.AllControllers(class'PlayerController', PC)
			{
				PC.ServerMutePlayer(TargetPlayerPC.PlayerReplicationInfo.UniqueId);
			}
		}
	}
}

exec function AdminForceVoiceUnMute(string TargetPlayer)
{
	if ( PlayerReplicationInfo.bAdmin )
	{
		ServerForceVoiceUnMute(TargetPlayer);
	}
}

reliable server function ServerForceVoiceUnMute(string TargetPlayer)
{
	local PlayerController PC;
	local PlayerController TargetPlayerPC;

	if ( PlayerReplicationInfo.bAdmin )
	{
		TargetPlayerPC = UTPlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(TargetPlayer));
		ClientMessage("UnMuting (Voice):"@TargetPlayerPC.PlayerReplicationInfo.PlayerName);
		if ( TargetPlayerPC != none )
		{
			foreach WorldInfo.AllControllers(class'PlayerController', PC)
			{
				PC.ServerUnMutePlayer(TargetPlayerPC.PlayerReplicationInfo.UniqueId);
			}
		}
	}
}


exec function AdminForceTextMute(string TargetPlayer)
{
	if ( PlayerReplicationInfo.bAdmin )
	{
		ServerForceTextMute(TargetPlayer);
	}
}

reliable server function ServerForceTextMute(string TargetPlayer)
{
	local UTPlayerController TargetPlayerPC;

	if ( PlayerReplicationInfo.bAdmin )
	{
		TargetPlayerPC = UTPlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(TargetPlayer));
		if ( TargetPlayerPC != none )
		{
			ClientMessage("Muting (Text):"@TargetPlayerPC.PlayerReplicationInfo.PlayerName);
			TargetPlayerPC.bServerMutedText = true;
		}
	}
}

exec function AdminForceTextUnMute(string TargetPlayer)
{
	if ( PlayerReplicationInfo.bAdmin )
	{
		ServerForceTextUnMute(TargetPlayer);
	}
}

reliable server function ServerForceTextUnMute(string TargetPlayer)
{
	local UTPlayerController TargetPlayerPC;

	if ( PlayerReplicationInfo.bAdmin )
	{
		TargetPlayerPC = UTPlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(TargetPlayer));
		if ( TargetPlayerPC != none )
		{
			ClientMessage("UnMuting (Text):"@TargetPlayerPC.PlayerReplicationInfo.PlayerName);
			TargetPlayerPC.bServerMutedText = false;
		}
	}
}

exec function Disconnect()
{
	QuitToMainMenu();
}

defaultproperties
{
	DesiredFOV=90.000000
	DefaultFOV=90.000000
	FOVAngle=90.000
	CameraClass=None
	CheatClass=class'UTCheatManager'
	InputClass=class'UTGame.UTPlayerInput'
	LastKickWarningTime=-1000.0
	bForceBehindview=true
	DamageCameraAnim=CameraAnim'FX_HitEffects.DamageViewShake'
	MatineeCameraClass=class'Engine.Camera'
	bCheckSoundOcclusion=true
	ZoomRotationModifier=0.5
	VehicleCheckRadiusScaling=1.0
	bRotateMiniMap=false
	bShouldLoadSettingsFromProfile=false

	PulseTimer=5.0;

`if(`notdefined(MOBILE))
	CommandMenuTemplate=UTUIScene_CommandMenu'UI_InGameHud.Menus.CommandMenu'
`endif

	PostProcessPresets(PPP_Default)=(Shadows=1.0, Midtones=1.0, Highlights=1.0, Desaturation=1.0)
	PostProcessPresets(PPP_Muted)=(Shadows=0.9, Midtones=0.95, Highlights=1.45, Desaturation=1.2)
	PostProcessPresets(PPP_Vivid)=(Shadows=1.5, Midtones=1.3, Highlights=0.85, Desaturation=1.0)
	PostProcessPresets(PPP_Intense)=(Shadows=1.5, Midtones=1.15, Highlights=0.6, Desaturation=1.2)

	MinRespawnDelay=1.5
	IdentifiedTeam=255
	OldMessageTime=-100.0
	LastTeamChangeTime=-1000.0

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform7
		Samples(0)=(LeftAmplitude=60,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.200)
	End Object
	CameraShakeShortWaveForm=ForceFeedbackWaveform7

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform8
		Samples(0)=(LeftAmplitude=60,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.400)
	End Object
	CameraShakeLongWaveForm=ForceFeedbackWaveform8
}
