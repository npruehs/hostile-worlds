/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 *  Our UIScenes provide PreRender and tick passes to our Widgets
 */

class UDKUIScene extends UIScene
	abstract
	native
	dependson(OnlinePlayerInterface,UDKGameInteraction);

var(Editor) transient bool bEditorRealTimePreview;

// hack to prevent the in-game command/taunt menu from causing the player's motion to stutter on consoles..
// @todo ronp - real fix is to toggle whether the UI controller performs axis repeat delays by looking at whether the current scene
// handles axis input, but this requires fixing all the scenes that are currently hardwired into the ProcessRawInputKey delegate.
var(Flags)	bool	bIgnoreAxisInput;

/** Global scene references, only scenes that are used in-game and in-menus should be referenced here. */
var transient UIScene MessageBoxScene;
var transient UIScene InputBoxScene;

/** Pending scene to open since we are waiting for the current scene's exit animation to end. */
var transient UIScene PendingOpenScene;

var	transient	int		PendingPlayerOwnerIndex;

/** Pending scene to close since we are waiting for the current scene's exit animation to end. */
var transient UIScene PendingCloseScene;

/** Animation flags, used by the tick function to determine which update func to call. */
var transient bool bShowingScene;
var transient bool bHidingScene;

/** Whether to call script tick for this scene */
var bool bShouldPerformScriptTick;

/** Whether or not to skip the kismet notify for the close scene that is pending. */
var transient bool bSkipPendingCloseSceneNotify;

/** Menu is waiting for ready signal to close itself (used by midgame menu at start of match) */
var transient bool bWaitingForReady;

/** Callback for when the scene's show animation has ended. */
delegate OnShowAnimationEnded();

/** Callback for when the scene's hide animation has ended. */
delegate OnHideAnimationEnded();

/** Callback for when a scene has opened after hiding the topmost scene. */
delegate OnSceneOpened(UIScene OpenedScene, bool bInitialActivation);

cpptext
{
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );
	virtual void Tick( FLOAT DeltaTime );
	virtual void TickChildren(UUIScreenObject* ParentObject, FLOAT DeltaTime);
	virtual void PreRender(FCanvas* Canvas);

	virtual UBOOL PreChildrenInputKey(INT ControllerId,FName Key,EInputEvent Event,FLOAT AmountDepressed=1.f,UBOOL bGamepad=FALSE) 
	{ 
		if (bWaitingForReady && Event == IE_Released && Key == FName(TEXT("XBoxTypeS_A")) )
		{
			if (SceneClient)
			{
				bWaitingForReady = FALSE;
				eventCloseScene(this);
			}
			return TRUE;
		}
		
		return FALSE; 
	}

	static void AutoPlaceChildren(UUIScreenObject *const BaseObject);

	/**
	 * Appends any command-line switches that should be carried over to the new process when starting a dedicated server instance.
	 */
	static void AppendPersistentSwitches( FString& ExtraSwitches );
}

/**
 * Sets the screen resolution.
 *
 * @param ResX			Width of the screen
 * @param ResY			Height of the screen
 * @param bFullscreen	Whether or not we are fullscreen.
 */
native function SetScreenResolution(int ResX, int ResY, bool bFullscreen);

/**
 * Get the UDKPlayerController that is associated with this Hud
 */
native function UDKPlayerController GetUDKPlayerOwner(optional int PlayerIndex=-1);

/**
 * Returns the Pawn associated with this Hud
 */
native function Pawn GetPawnOwner();

/**
 * @Returns the contents of GIsGame
 */
native function bool IsGame();

/** Starts a dedicated server and kills the current process. */
native function StartDedicatedServer(string TravelURL);

/** @return Return a reference to the UDK specific version of the UI interaction. */
function UDKGameInteraction GetUTInteraction()
{
	return UDKGameInteraction(GetCurrentUIController());
}

/**
  * Called every frame if bShouldPerformScriptTick is true
  * @PARAM DeltaTime is the time in seconds for this frame
  */
event TickScene(float DeltaTime);

/**
 * Returns whether or not the input passed in is a gamepad input event.
 *
 * @param KeyName	Key name to check
 *
 * @return Returns TRUE if the input key is from a gamepad, FALSE otherwise.
 */
event bool IsControllerInput(name KeyName)
{
	local bool bResult;
	local array<name> Keys;
	local int KeyIdx;

	bResult=false;

	Keys.length=24;

	Keys[0]='XboxTypeS_LeftThumbstick';
	Keys[1]='XboxTypeS_RightThumbstick';
	Keys[2]='XboxTypeS_Back';
	Keys[3]='XboxTypeS_Start';
	Keys[4]='XboxTypeS_A';
	Keys[5]='XboxTypeS_B';
	Keys[6]='XboxTypeS_X';
	Keys[7]='XboxTypeS_Y';
	Keys[8]='XboxTypeS_LeftShoulder';
	Keys[9]='XboxTypeS_RightShoulder';
	Keys[10]='XboxTypeS_LeftTrigger';
	Keys[11]='XboxTypeS_RightTrigger';
	Keys[12]='XboxTypeS_DPad_Up';
	Keys[13]='XboxTypeS_DPad_Down';
	Keys[14]='XboxTypeS_DPad_Right';
	Keys[15]='XboxTypeS_DPad_Left';
	Keys[16]='Gamepad_LeftStick_Up';
	Keys[17]='Gamepad_LeftStick_Down';
	Keys[18]='Gamepad_LeftStick_Right';
	Keys[19]='Gamepad_LeftStick_Left';
	Keys[20]='Gamepad_RightStick_Up';
	Keys[21]='Gamepad_RightStick_Down';
	Keys[22]='Gamepad_RightStick_Right';
	Keys[23]='Gamepad_RightStick_Left';

	for(KeyIdx=0; KeyIdx<Keys.length; KeyIdx++)
	{
		if(KeyName==Keys[KeyIdx])
		{
			bResult=true;
			break;
		}
	}

	return bResult;
}

/** Trims whitespace from the beginning and end of a string. */
static function string TrimWhitespace(string InString)
{
	local int StartIdx;
	local int EndIdx;
	local string FinalString;

	for(StartIdx=0; StartIdx<Len(InString); StartIdx++)
	{
		if(Asc(Mid(InString,StartIdx,1))!=32)
		{
			break;
		}
	}

	for(EndIdx=Len(InString)-1; EndIdx>=0; EndIdx--)
	{
		if(Asc(Mid(InString,EndIdx,1))!=32)
		{
			break;
		}
	}

	if(StartIdx<=EndIdx)
	{
		FinalString=Mid(InString,StartIdx,EndIdx-StartIdx+1);
	}

	return FinalString;
}

/**
 * Returns the PRI associated with this hud
 */
function PlayerReplicationInfo GetPRIOwner()
{
	local UDKPlayerController UTPOwner;
	
	UTPOwner = GetUDKPlayerOwner();
	return (UTPOwner != None) 
		?  UTPOwner.PlayerReplicationInfo
		: None;
}

/**
 * Executes a console command.
 *
 * @param string Cmd	Command to execute.
 */
final function ConsoleCommand(string Cmd, optional bool bWriteToLog)
{
	local LocalPlayer LP;
	local UIInteraction UIController;

	if ( Cmd != "" )
	{
		UIController = GetCurrentUIController();
		LP = GetPlayerOwner(0);
		if ( LP == None )
		{
			if ( UIController != None )
			{
				LP = UIController.GetLocalPlayer(0);
			}
		}

		if ( LP != None )
		{
			if ( LP.Actor != None )
			{
				LP.Actor.ConsoleCommand(Cmd, bWriteToLog);
			}
			else if ( UIController != None && UIController.Outer.ViewportConsole != None )
			{
				UIController.Outer.ViewportConsole.ConsoleCommand(Cmd);
			}
		}
	}
}


/** @return Returns the player index of the player owner for this scene. */
function int GetPlayerIndex()
{
	local int PlayerIndex;
	local LocalPlayer LP;

	LP = GetPlayerOwner();
	if ( LP != None )
	{
		PlayerIndex = class'UIInteraction'.static.GetPlayerIndex(LP.ControllerId);
	}
	else
	{
		PlayerIndex = GetBestPlayerIndex();
	}

	return PlayerIndex;
}

/**
 * Opens a UI Scene given a reference to a scene to open.
 *
 * @param SceneToOpen	Scene that we want to open.
 */
function UIScene OpenSceneByName(string SceneToOpen, bool bSkipAnimation=false, optional delegate<OnSceneActivated> SceneDelegate=None)
{
	local UIScene SceneToOpenReference;
	SceneToOpenReference = UIScene(DynamicLoadObject(SceneToOpen, class'UIScene'));

	if(SceneToOpenReference != None)
	{
		return OpenScene(SceneToOpenReference,/*LocalPlayer*/,/*ForcedPriority*/,bSkipAnimation,SceneDelegate);
	}
	else
	{
		return None;
	}
}

/**
 * Opens a UI Scene given a reference to a scene to open.
 *
 * @param	SceneToOpen		Scene that we want to open.
 * @param	bSkipAnimation	specify TRUE to indicate that opening animations should be bypassed.
 * @param	SceneDelegate	if specified, will be called when the scene has finished opening.
 */
function UIScene OpenScene(UIScene SceneToOpen, optional LocalPlayer ScenePlayerOwner=GetPlayerOwner(), optional byte UnusedForcedPriority, optional bool bSkipAnimation=false, optional delegate<OnSceneActivated> SceneDelegate=None)
{
	local UIScene Result;
	local UDKUIScene CurrentScene;
	local bool bOpenNow;
	local UDKGameInteraction UIController;

	// Try to hide the current scene.

	// only hide the current scene if the scene we're about to open doesn't render its parent scenes
	UIController = GetUTInteraction();
	if ( UIController != None )
	{
		bOpenNow = true;
		OnSceneOpened = SceneDelegate;
		CurrentScene = UDKUIScene(UIController.SceneClient.GetActiveScene(ScenePlayerOwner, true));
		if ( !bSkipAnimation && SceneToOpen != None && (!SceneToOpen.bRenderParentScenes || ((CurrentScene != None) && CurrentScene.bAlwaysRenderScene)) )
		{
			if(CurrentScene != None && !CurrentScene.bRenderParentScenes )
			{
				CurrentScene.OnHideAnimationEnded = OnCurrentScene_HideAnimationEnded;
				if(CurrentScene.BeginHideAnimation(false))
				{
					// Block input while animating
					UIController.BlockUIInput(true);

					bHidingScene = true;
					PendingOpenScene = SceneToOpen;
					PendingPlayerOwnerIndex = UIController.Outer.Outer.GamePlayers.Find(ScenePlayerOwner);
					bOpenNow = false;
				}
				else
				{
					CurrentScene.OnHideAnimationEnded = None;
				}
			}
		}

		// If no hide animation was started, just show the scene we are opening.
		if ( bOpenNow )
		{
			PendingPlayerOwnerIndex = UIController.Outer.Outer.GamePlayers.Find(ScenePlayerOwner);
			Result = FinishOpenScene(SceneToOpen, bSkipAnimation, true);
		}
	}

	return Result;
}

/** Callback for when the current scene's hide animation has completed. */
function OnCurrentScene_HideAnimationEnded()
{
	FinishOpenScene(PendingOpenScene);
}

/**
 * Finishes opening a scene, usually called when a hide animation has ended.
 *
 * @param	SceneToOpen			the scene to open
 * @param	bSkipAnimation		specify TRUE to bypass the scene's opening animation
 * @param	bSkipKismetNotify	specify TRUE to prevent the 'OpeningMenu' level event from being activated.
 *
 * @return	reference to the UIScene instance that was opened.
 */
//@todo ronp animation - bSkipKismetNotify!
function UIScene FinishOpenScene(UIScene SceneToOpen, bool bSkipAnimation=false, bool bSkipKismetNotify=false)
{
	local UIScene OpenedScene;
	local UDKUIScene OpenedUTScene;
	local UDKGameInteraction UIController;
	local UDKUIScene UTSceneToOpen;
	local LocalPlayer LP;

	// Reenable input
	UIController = GetUTInteraction();
	if ( UIController != None )
	{
		UIController.BlockUIInput(false);

		// Clear any references and delegates set
		UTSceneToOpen = UDKUIScene(SceneToOpen);

		if(UTSceneToOpen != None)
		{
			UTSceneToOpen.OnHideAnimationEnded = None;
			UTSceneToOpen.OnShowAnimationEnded = None;
		}

		LP = UIController.GetLocalPlayer(PendingPlayerOwnerIndex);
		PendingOpenScene = None;
		OnHideAnimationEnded = None;

		OpenedScene = none;

		// Get the UI Controller and try to open the scene.
		if ( SceneToOpen != none && UIController.SceneClient != none  )
		{
			// Have the UI system look to see if the scene exists.  If it does
			// use that so that split-screen shares scenes
			OpenedScene = UIController.SceneClient.FindSceneByTag(SceneToOpen.SceneTag, LP);
			if ( OpenedScene == none )
			{
				// Nothing, just create a new instance
				UIController.SceneClient.InitializeScene(SceneToOpen, LP, OpenedScene);
				if ( OpenedScene != None )
				{
					if ( OnSceneOpened != None )
					{
						OpenedScene.OnSceneActivated = OnSceneOpened;
					}

					UIController.SceneClient.OpenScene(OpenedScene, LP, OpenedScene);
				}

				PendingPlayerOwnerIndex = INDEX_NONE;
				OpenedUTScene = UDKUIScene(OpenedScene);
				if(OpenedUTScene != None)
				{
					if(OpenedUTScene.BeginShowAnimation(true,bSkipAnimation))
					{
						OpenedUTScene.bShowingScene=true;
					}
				}
			}
		}

		// Activate kismet for opening scene
		if ( !bSkipKismetNotify )
		{
			ActivateLevelEvent('OpeningMenu');
		}

		// Clear scene open delegate
		OnSceneOpened = None;
	}

	PendingPlayerOwnerIndex = INDEX_NONE;
	return OpenedScene;
}

/** Opens a scene without any special hiding animation for previous scenes. */
static function UIScene StaticOpenScene(UIScene SceneToOpen)
{
	local GameUISceneClient GameSceneClient;
	local UIScene OpenedScene;
	local UDKUIScene OpenedUTScene;

	// Get the UI Controller and try to open the scene.
	GameSceneClient = GetSceneClient();
	if ( SceneToOpen != none && GameSceneClient != none  )
	{
		// Have the UI system look to see if the scene exists.  If it does
		// use that so that split-screen shares scenes
		OpenedScene = GameSceneClient.FindSceneByTag( SceneToOpen.SceneTag );
		if (OpenedScene == none)
		{
			// Nothing, just create a new instance
			GameSceneClient.OpenScene(SceneToOpen, None, OpenedScene);

			OpenedUTScene = UDKUIScene(OpenedScene);
			if(OpenedUTScene != None)
			{
				if(OpenedUTScene.BeginShowAnimation())
				{
					OpenedUTScene.bShowingScene=true;
				}
			}
		}
	}

	return OpenedUTScene;
}

/**
 * Closes a UI Scene given a reference to an previously open scene.
 *
 * @param SceneToClose			Scene that we want to close.
 * @param bSkipKismetNotify		Whether or not to close the kismet notify for the scene.
 * @param bSkipAnimation		Whether or not to skip the close animation for this scene.
 */
//function bool CloseScene( optional UIScene SceneToClose=Self, bool bSkipKismetNotify=false, bool bForceCloseImmediately=false)
function bool CloseScene( optional UIScene SceneToClose=Self, bool bCloseChildScenes=true, bool bForceCloseImmediately=false )
{
	local UDKUIScene UTSceneToClose;
	local bool bResult;

	UTSceneToClose = UDKUIScene(SceneToClose);
	if ( UTSceneToClose.IsSceneActive() )
	{
		if(UTSceneToClose != None && !bForceCloseImmediately && UTSceneToClose.BeginHideAnimation(true))
		{
			// Block input while animating
			GetUTInteraction().BlockUIInput(true);

			UTSceneToClose.bHidingScene = true;
			UTSceneToClose.OnHideAnimationEnded = OnPendingCloseScene_HideAnimationEnded;
			PendingCloseScene = UTSceneToClose;
			//@fixme ronp - what was this being used for?
			bSkipPendingCloseSceneNotify = bForceCloseImmediately;
			bResult = false;
		}
		else
		{
			FinishCloseScene(SceneToClose, bForceCloseImmediately/*, bSkipKismetNotify*/);
			bResult = true;
		}
	}

	return bResult;
}

/** Callback for when the scene we are closing's hide animation has completed. */
function OnPendingCloseScene_HideAnimationEnded()
{
	FinishCloseScene(PendingCloseScene, false, bSkipPendingCloseSceneNotify);
}

/**
 * Closes a UI Scene given a reference to an previously open scene.
 *
 * @param SceneToClose	Scene that we want to close.
 */
function FinishCloseScene(UIScene SceneToClose, bool bSkipAnimations=false, bool bSkipKismetNotify=false)
{
	local UDKUIScene UTSceneToClose;
	local UDKUIScene TopScene;

	// Reenable input
	GetUTInteraction().BlockUIInput(false);

	UTSceneToClose = UDKUIScene(SceneToClose);

	if(UTSceneToClose != None)
	{
		UTSceneToClose.bHidingScene = false;
		UTSceneToClose.OnHideAnimationEnded = None;
	}

	PendingCloseScene = None;

	if ( SceneToClose != none )
	{
		TopScene = UDKUIScene(SceneToClose.GetPreviousScene());
		SceneClient.CloseScene(SceneToClose);

		// If the scene we just closed wasn't set to render its parent scenes, then begin the show animation on the topmost scene.
		if ( TopScene != None && !SceneToClose.bRenderParentScenes && !TopScene.bAlwaysRenderScene )
		{
			// Active show animation on topmost scene
			TopScene.BeginShowAnimation(false, bSkipAnimations);
		}
	}

	if( !bSkipKismetNotify )
	{
		ActivateLevelEvent('ClosingMenu');
	}
}

/**
 * Starts the show animation for the scene.
 *
 * @param	bInitialActivation	TRUE if the scene is being opened; FALSE if the another scene was closed causing this one to become the
 *								topmost scene.
 * @param	bBypassAnimation	TRUE to force all animations to their last frame, effectively bypassing animations.  This can
 *								be necessary for e.g. scenes which start out off-screen or something.
 *
 * @return TRUE if there's animation for this scene, FALSE otherwise.
 */
function bool BeginShowAnimation(bool bInitialActivation=true, bool bBypassAnimation=false)
{
	return FALSE;
}

/**
 * Starts the exit animation for the scene.
 *
 * @return TRUE if there's animation for this scene, FALSE otherwise.
 */
function bool BeginHideAnimation(bool bClosingScene=false)
{
	return FALSE;
}

/** Called when an animation on this scene has finished. */
event UIAnimationEnded( UIScreenObject AnimTarget, name AnimName, int TrackType )
{
	Super.UIAnimationEnded(AnimTarget, AnimName, TrackType);

	if ( TrackType == 0 )
	{
		if(bHidingScene)
		{
			bHidingScene = false;
			OnHideAnimationEnded();
		}
		else if(bShowingScene)
		{
			bShowingScene = false;
			OnShowAnimationEnded();
		}
	}
}

function NotifyGameSessionEnded()
{
	local int i;

	for (i=0;i<Children.Length;i++)
	{
		NotifyChildGameSessionEnded(Children[i]);
		if ( UDKUI_Widget(Children[i]) != none )
		{
			UDKUI_Widget(Children[i]).NotifyGameSessionEnded();
		}
	}

	Super.NotifyGameSessionEnded();
}

function NotifyChildGameSessionEnded(UIObject Child)
{
	local int i;

	for ( i=0; i<Child.Children.Length; i++ )
	{
		NotifyChildGameSessionEnded(Child.Children[i]);
		if ( UDKUI_Widget(Child.Children[i]) != none )
		{
			UDKUI_Widget(Child.Children[i]).NotifyGameSessionEnded();
		}
	}
}

/**
 * Allows easy access to playing a sound
 *
 * @Param	InSoundCue		The Cue to play
 * @Param	SoundLocation	Where in the world to play it.  Defaults at the Player's position
 */

function PlaySound( SoundCue InSoundCue)
{
	local UDKPlayerController PC;

	PC = GetUDKPlayerOwner();
	if ( PC != none )
	{
		PC.ClientPlaySound(InSoundCue);
	}
}

/** @return Returns a datastore given its tag and player owner. */
static function UIDataStore FindDataStore(name DataStoreTag, optional LocalPlayer InPlayerOwner)
{
	local DataStoreClient DSClient;
	local UIDataStore Result;

	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		Result = DSClient.FindDataStore(DataStoreTag, InPlayerOwner);
	}

	return Result;
}

/** @return Returns the controller id of a player given its player index. */
function int GetPlayerControllerId(int PlayerIndex)
{
	return class'UIInteraction'.static.GetPlayerControllerId(PlayerIndex);;
}

/** Activates a level remote event in kismet. */
native function ActivateLevelEvent(name EventName);


/**
 * Saves the profile for the specified player index.
 *
 * @param PlayerIndex	The player index of the player to save the profile for.
 */
function SavePlayerProfile(optional int PlayerIndex=GetBestPlayerIndex())
{
	local UIDataStore_OnlinePlayerData	PlayerDataStore;
	PlayerDataStore = UIDataStore_OnlinePlayerData(FindDataStore('OnlinePlayerData', GetPlayerOwner(PlayerIndex)));

	if(PlayerDataStore != none)
	{
		`Log("UDKUIScene::SaveProfile() - Saving player profile for player index "$PlayerIndex);
		PlayerDataStore.SaveProfileData();
	}
}

/** @return Returns the name of the specified player if they have an alias or are logged in, or "DefaultPlayer" otherwise. */
function string GetPlayerName(int PlayerIndex=GetBestPlayerIndex())
{
	local string PlayerName;

	if(IsLoggedIn(GetPlayerControllerId(PlayerIndex)))
	{
		PlayerName=GetUDKPlayerOwner(PlayerIndex).OnlinePlayerData.PlayerNick;
	}
	else
	{
		PlayerName=GetUDKPlayerOwner(PlayerIndex).PlayerReplicationInfo.PlayerName;
	}

	// Replace invalid characters
	PlayerName = Repl(PlayerName," ","_");
	PlayerName = Repl(PlayerName,"?","_");
	PlayerName = Repl(PlayerName,"=","_");

	return PlayerName;
}

/** @return Generates a set of URL options common to both instant action and host game. */
function string GetCommonOptionsURL()
{
	local string URL;
	local string OutStringValue;

	// Set player name using the OnlinePlayerData
	// @todo: Need to add support for setting 2nd player nick.
	URL $= "?name=" $ GetPlayerName();


	// Set player alias
	if(GetDataStoreStringValue("<OnlinePlayerData:ProfileData.Alias>", OutStringValue, self, GetPlayerOwner()) && Len(OutStringValue)>0)
	{
		OutStringValue = Repl(OutStringValue," ","_");
		OutStringValue = Repl(OutStringValue,"?","_");
		OutStringValue = Repl(OutStringValue,"=","_");

		URL $= "?alias="$OutStringValue;
	}

	return URL;
}

/** @return Returns a reference to the online subsystem game interface. */
static function OnlineGameInterface GetGameInterface()
{
	local OnlineSubsystem OnlineSub;
	local OnlineGameInterface GameInt;

	// Display the login UI
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		GameInt = OnlineSub.GameInterface;
	}
	else
	{
		`Log("UDKUIScene::GetGameInterface() - Unable to find OnlineSubSystem!");
	}

	return GameInt;
}

/** @return Returns a reference to the online subsystem player interface. */
static function OnlinePlayerInterface GetPlayerInterface()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInt;

	// Display the login UI
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		PlayerInt = OnlineSub.PlayerInterface;
	}
	else
	{
		`Log("UDKUIScene::GetPlayerInterface() - Unable to find OnlineSubSystem!");
	}

	return PlayerInt;
}

/** @return Returns a reference to the online subsystem player interface ex. */
static function OnlinePlayerInterfaceEx GetPlayerInterfaceEx()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterfaceEx PlayerIntEx;

	// Display the login UI
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		PlayerIntEx = OnlineSub.PlayerInterfaceEx;
	}
	else
	{
		`Log("UDKUIScene::GetPlayerInterfaceEx() - Unable to find OnlineSubSystem!");
	}

	return PlayerIntEx;
}

/**
 * Converts a 2D Screen coordiate in to 3D space
 *
 * @Param	LocalPlayerOwner		The LocalPlayer that owns the viewport where the projection occurs
 * @Param	WorldLocation			The world location to project to
 * @Param	OutScreenLocation		Returns the location in 2D space
 */
native function ViewportProject(LocalPlayer LocalPlayerOwner, vector WorldLocation, out vector OutScreenLocation);

/**
 * Converts a 2D Screen coordiate in to 3D space
 *
 * @Param	LocalPlayerOwner		The LocalPlayer that owns the viewport where the projection occurs
 * @Param	ScreenLocation			Where on the screen are we converting from
 * @Param	OutLocation				Returns the Location in world space
 * @Param	OutDirection			Returns the view direction
 */
native function ViewportDeProject(LocalPlayer LocalPlayerOwner, vector ScreenLocation, out vector OutLocation, out vector OutDirection);

/** Function that sets up a buttonbar for this scene, automatically routes the call to the currently selected tab of the scene as well. */
function SetupButtonBar();


/** @return Opens the message box scene and returns a reference to it. */
function UDKUIScene_MessageBox GetMessageBoxScene(optional UIScene SceneReference = None)
{
	if (SceneReference == None)
	{
		SceneReference = MessageBoxScene;
	}

	return UDKUIScene_MessageBox(OpenScene(SceneReference,/*LocalPlayer*/,/*ForcedPriority*/,true));
}

/** @return Opens the input box scene and returns a reference to it. */
function UDKUIScene_InputBox GetInputBoxScene()
{
	return UDKUIScene_InputBox(OpenScene(InputBoxScene,/*LocalPlayer*/,/*ForcedPriority*/,true));
}


/**
 * Displays a very simple OK message box with the specified message and title.
 *
 * @param Message		Message markup for the messagebox
 * @param Title			Title markup for the messagebox
 *
 * @return	Returns a reference to the message box scene that was displayed.
 */
function UDKUIScene_MessageBox DisplayMessageBox (string Message, optional string Title="")
{
	local UDKUIScene_MessageBox MessageBoxReference;

	MessageBoxReference = GetMessageBoxScene();

	if(MessageBoxReference != none)
	{
		MessageBoxReference.Display(Message, Title);
	}

	return MessageBoxReference;
}

defaultproperties
{
	PendingPlayerOwnerIndex=INDEX_NONE
}

