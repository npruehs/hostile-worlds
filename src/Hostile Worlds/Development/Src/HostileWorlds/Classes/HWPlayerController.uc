// ============================================================================
// HWPlayerController
// Implements Hostile Worlds player logic, like selected units or pressed mouse
// buttons.
//
// Author:  Marcel Koehler, Nick Pruehs
// Date:    2010/08/13
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================

class HWPlayerController extends PlayerController
	config(HostileWorlds);

/** The number of seconds order target destinations are shown by the HUD in seconds. */
const SHOW_ORDER_TARGET_DESTINATION_DURATION = 3;

/** The number of seconds before a player leaves combat again after having been attacked. */
const TIME_BEFORE_LEAVING_COMBAT = 5;

/** The amount the alien range level of a player increases by for each alien killed. */
const ALIEN_RAGE_INCREASE_PER_KILL = 0.03f;

/** The amount the alien range level of a player decreases by for each squad member lost. */
const ALIEN_RAGE_DECREASE_PER_LOSS = 0.3f;

// ----------------------------------------------------------------------------
// Mouse and Viewport.

/** The position of the player's mouse cursor on the screen. */
var Vector2D MouseLocationScreen;

/** 
 *  The location of the player's mouse cursor in 3D world coordinates, 
 *  as provided by a trace with level geometry (from the camera location along the normal vector of the deprojected mouse screen location). 
 */
var Vector MouseLocationWorld;

/** The actor the mouse currently hovers over. */
var Actor TraceActor;

/** The total time the left mouse button has been down this click. */
var float MouseLeftClickDuration;

/** The timestamp of the last left click. */
var float MouseLeftClickLastTime;

/** The total time the right mouse button has been down this click. */
var float MouseRightClickDuration;

/** Whether the left mouse button is currently being pressed or not. */
var bool bLeftMousePressed;

/** Whether the left mouse button has been double clicked in rapid succession. */
var bool bLeftMouseDoubleClick;

/** Whether the right mouse button is currently being pressed or not. */
var bool bRightMousePressed;

/** The size of the window the user plays in. */
var Vector2D ViewportSize;

/** The distance from any screen edge the mouse cursor must be within in order to cause the camera to scroll. */
var int MouseScrollThreshold;

// ----------------------------------------------------------------------------
// Unit Selection.

/** The point on the screen the user started to drag a selection box at. */
var Vector2D GroupSelectionStart;

/** The units currently selected by this player. */
var array<HWSelectable> SelectedUnits;

/** The collection of commanders currently selected by this player. */
var array<HWSquadMember> SelectedCommanders;

/** The collection of squad members of the first class currently selected by this player. */
var array<HWSquadMember> SelectedSquadMembers1;

/** The collection of squad members of the second class currently selected by this player. */
var array<HWSquadMember> SelectedSquadMembers2;

/** The collection of squad members of the third class currently selected by this player. */
var array<HWSquadMember> SelectedSquadMembers3;

/** The strongest squad member among the ones selected by this player. */
var HWSelectable StrongestSelectedUnit;

/** The control groups this player defined by pressing the CTRL key. */
var array<HWSelectable>
	ControlGroup1, ControlGroup2, ControlGroup3, ControlGroup4, ControlGroup5,
	ControlGroup6, ControlGroup7, ControlGroup8, ControlGroup9, ControlGroup0;

struct SLastSelection
{
	var byte GroupIndex;
	var float Time;
};

/** Struct for remembering the index and time of the last control group recalled by the player. */
var SLastSelection LastSelection;

/** Whether the HUD should (de-)select units after its next deprojection. */
var bool bShouldUpdateSelection;

/** The maximum time between two identical group selections that are considered a double selection, in seconds. */
var config float DoubleSelectionTime;

/** Whether the player is currently holding the SHIFT key in order to change the set of selected units. */
var bool bShiftSelecting;

// ----------------------------------------------------------------------------
// Gameplay.

/** Settings defined by the player. Use GetPlayerSettings() to access this variable and avoid Accessed None errors. */
var private HWPlayerSettings PlayerSettings;

/** The number of shards this player has available. */
var int Shards;

/** The number of shards spent on calling squad members. */
var int ExtraShardsSpent;

/** The number of squad members this player controls. */
var int SquadMembers;

/** The commander of this player. */
var HWCommander Commander;

/** The time the commander of this player has died. */
var int TimeCommanderDied;

/** The manager for the fog of war handicaping this player. */
var HWFogOfWarManager FogOfWarManager;

/** The map this player plays on. */
var HWMapInfoActor Map;

/** Whether this player has been recently attacked, or not. */
var bool bInCombat;

/** Whether this player has won the match, not. */
var bool bWinner;

/** The race this player has picked. */
var HWRace Race;

/** A basic order that can be issued to any squad member. */
enum EBasicOrder
{
	ORDER_Move,
	ORDER_Stop,
	ORDER_HoldPosition,
	ORDER_Attack,
	ORDER_AttackMove
};

/** A struct encapsulating a chat message received by this player. */
struct ChatMessage
{
	var string SendingPlayerName;
	var string Text;
};

/** The list of chat messages received by this player. */
var array<ChatMessage> ReceivedMessages;

/** The current alien rage level of this player. The damage of alien attacks targeting this player is scaled by his or her alien rage. */ 
var float AlienRage;

// ----------------------------------------------------------------------------
// GUI Interaction.

/** The ability the player is currently choosing a target unit or location for. */
var HWAbility AbilityToChooseTargetFor;

/** The target location the player has chosen for the ability currently being triggered. */
var Vector AbilityTargetLocation;

/** Whether destination location of the attached actor's current order is currently shown. */
var bool bShowOrderTargetDestination;

/** The pre-match lobby screen of this player. */
var HWGFxScreen_PreMatchLobby PreMatchLobby;

/** Whether to show framerates or not. */
var bool bShouldShowFPS;

/** Whether framerates are currently shown, or not. */
var bool bShowingFPS;

/** Whether the last mouse click has been processed by the Scaleform GFx GUI and should not be passed to the engine. */
var bool bScaleformButtonClicked;

/** The dialog window telling this player that a connection error occured. */
var HWGFxDialog DialogConnectionError;

// ----------------------------------------------------------------------------
// Messages.

/** The error message to show when the player tries to use an ability that his squad member has not learned yet. */
var localized string ErrorAbilityNotLearnedYet;

/** The error message to show when the player tries to spend more shards than he or she has. */
var localized string ErrorNotEnoughShards;

/** The message to show while the player is choosing a target unit for an ability. */
var localized string MessageChooseTargetUnit;

/** The message to show while the player is choosing a target location for an ability. */
var localized string MessageChooseTargetLocation;

/** The message to show while the player is choosing a target location for respawning his or her commander. */
var localized string MessageChooseTargetLocationForCommanderRespawn;

/** The message to show when the player has chosen an invalid spawn location for his or her commander. */
var localized string ErrorCantSpawnCommanderHere;

/** The message to show when the player has chosen a spawn location for his or her commander that is too close to an artifact. */
var localized string ErrorCantSpawnCommanderNextToArtifacts;

/** The message to show when the player has chosen a spawn location for his or her commander this is too far away from all spawn points. */
var localized string ErrorMustSpawnAtASpawnPoint;

/** The message to show while the player is choosing a target location for a move order. */
var localized string MessageChooseTargetLocationForMove;

/** The message to show while the player is choosing a target location for an attack order. */
var localized string MessageChooseTargetLocationForAttack;

/** The message to show if the player wins the game. */
var localized string MessagePlayerWins;

/** The message to show if the player looses the game. */
var localized string MessagePlayerLooses;

/** The message to show when the client has received the game scores. */
var localized string MessageViewScores;

/** The message to show when the player tries to promote a squad member that is already at maximum level. */
var localized string ErrorMaximumLevel;

/** The message to show when the player tries to target the terrain with an ability that required a target unit. */
var localized string ErrorTargetMustBeAUnit;

/** The message to show when the player tries to call a new squad member when he or she already has reached the maximum count. */
var localized string ErrorTooManySquadMembers;

/** The message to show when the player tries to dismiss his or her commander. */
var localized string ErrorCannotDismissCommander;

/** The message to show when the player tries to interact with a dead commander. */
var localized string ErrorCommanderDead;

/** The message to show when the player tries to acquire an artifact without having learned the required ability. */
var localized string ErrorHarvesterRequired;

/** The message to show when the player tries to issue an attack order for blinded units. */
var localized string ErrorCantDoThatWhileBlinded;

/** The message to show when the players tries to call squad member while being in combat. */
var localized string ErrorCantCallSquadMembersInCombat;

// ----------------------------------------------------------------------------
// Sound.

/** The audio component used for playing voice notifications. */
var AudioComponent ACVoiceNotifications;

/** The audio component used for playing battle cries. */
var AudioComponent ACBattleCry;

/** The audio component used for playing unit voice sounds. */
var AudioComponent ACVoiceUnits;

/** The audio component used for playing interface error sounds. */
var AudioComponent ACInterfaceError;

/** The audio component used for playing the calm in-game music. */
var AudioComponent ACDynamicMusicCalm;

/** The audio component used for playing the intense in-game music. */
var AudioComponent ACDynamicMusicIntense;

/** The sound to be played whenever the player tries to spend more shards than he or she has. */
var SoundCue SoundNotEnoughShards;

/** The sound to be played whenever the commander of a player has fallen. */
var SoundCue SoundCommanderHasFallen;

/** The sound to be played whenever the forces of an allied player are under attack. */
var SoundCue SoundAllyUnderAttack;

/** The sound to be played whenever an allied commander has fallen. */
var SoundCue SoundAlliedCommanderHasFallen;

/** The sound to be played whenever the player's units are under attack. */
var SoundCue SoundUnitsUnderAttack;

/** The last time the player has been notified that his or her units are under attack. */
var int LastTimeUnitsUnderAttack;

/** The minimum time between two "units under attack" notifications, in seconds. */
var config float NotifyIntervalUnitsUnderAttack;

/** The last time a unit voice sound has been played. */
var int LastTimeVoiceUnits;

/** The minimum time between two unit voice sounds being played, in seconds. */
var config float IntervalVoiceUnits;

/** The sound to be played whenever an error occurs. */
var SoundCue SoundInterfaceError;

/** The time the last dynamic music was faded in with, in seconds. Used for looping dynamic music. */
var float LastMusicFadeInTime;

// ----------------------------------------------------------------------------
// Score Screen.

var int TotalAliensKilled;
var int TotalSquadMembersKilled;
var int TotalSquadMembersLost;
var int TotalSquadMembersDismissed;
var int TotalReinforcementsCalled;

var int TotalShardsFarmed;
var int TotalArtifactsAcquired;
var int TotalVision;
var int TotalVisionK;
var int TotalActions;

var int TotalDamageTaken;
var int TotalDamageDealt;
var int TotalDamageHealed;

var int TotalAbilitiesTriggered;
var int TotalTacticalAbilitiesTriggered;
var int TotalKnockbacksCaused;
var int TotalKnockbacksTaken;

var int TotalTimeSpentInDamageArea;
var int TotalTimeSpentInSlowArea;
var int TotalTowersCaptured;

var repnotify HWGameResults Results;


// ----------------------------------------------------------------------------
// Player Initialization.

/**
 * Initializes this player, rasterizing the map into tiles and height levels
 * if not already done, initializing the HUD and the minimap.
 * 
 * @param TheMap
 *      the map the player plays on
 * @param ScoreLimit
 *      the score limit of the game, in case the GRI has not been replicated
 *      yet
 * @param TimeLimit
 *      the time limit of the game, in case the GRI has not been replicated
 *      yet
 */
reliable client function ClientInitializeLobby(HWMapInfoActor TheMap, int ScoreLimit, int TimeLimit)
{
	// intiailize map tile size and height levels
	Map = TheMap;

	if (WorldInfo.NetMode == NM_Client)
	{
		Map.Initialize();
	}

	// intiailize minimap and special mouse cursors
	HWHud(myHUD).InitializeHUD(Map);

	// show pre-match lobby, if not PIE
	if (WorldInfo.NetMode != NM_Standalone && WorldInfo.NetMode != NM_DedicatedServer)
	{
		PreMatchLobby = new class'HWGFxScreen_PreMatchLobby';
		PreMatchLobby.ShowView();
		PreMatchLobby.SetScoreAndTimeLimit(ScoreLimit, TimeLimit);
	}
}

/**
 * Prepares this player for the match, initializing the fog of war and
 * beginning to replicate APM statistics.
 * 
 * @param TeamIndex
 *      the team index of this player, in case the GRI has not been replicated
 *      yet
 */
reliable client function ClientInitializeMatch(int TeamIndex)
{
	// prepare fog of war
	FogOfWarManager = Spawn(class'HWFogOfWarManager', self);
	FogOfWarManager.Initialize(Map, self, TeamIndex);
		
	// replicate action counter to server
	SetTimer(5.0f, true, 'ReplicateTotalActionsToServer');
}

/** Hides the HUD of this player. Useful for menu levels. */
reliable client function HideHUD()
{
	myHUD.bShowHUD = false;
}

/**
 * Spawns and initialized the commander for this player.
 * 
 * @param ServerMap
 *      a reference to the map the commander spawns in;
 *      required due to race conditions in GameInfo::PostLogin
 *      and HWGame::SpawnDefaultPawnFor
 * @param SpawnLocation
 *      the location to spawn the commander at
 * @param SpawnRotation
 *      the rotation to spawn the commander with
 */
function SpawnCommander(HWMapInfoActor ServerMap, Vector SpawnLocation, Rotator SpawnRotation)
{
	Commander = Spawn(Race.CommanderClass, self,, SpawnLocation, SpawnRotation);
	Commander.Initialize(ServerMap, self);

	ClientNotifyCommanderAlive(true);
}

/** Notifies this player that a connection error has occured. */
function NotifyConnectionError(string ErrorMessage)
{
	DialogConnectionError = new class'HWGFxDialog';
	DialogConnectionError.ShowView();
	DialogConnectionError.InitDialogError(ErrorMessage, DialogConnectionErrorOK);
}

/** Hides the connection error dialog and returns to the main menu. */
function DialogConnectionErrorOK()
{
	DialogConnectionError.Close(true);

	ConsoleCommand("disconnect");
}

// ----------------------------------------------------------------------------
// Player Ticking.

event PlayerTick(float DeltaTime)
{
	// process player input for this frame
    super.PlayerTick(DeltaTime);

	MouseLocationScreen = HWHud(myHUD).GetMouseCoordinates();

	// accumulate the time the mouse buttons have been down
	if(bLeftMousePressed)
	{
		MouseLeftClickDuration += DeltaTime;
	}
	
	if (bRightMousePressed) 
	{
		MouseRightClickDuration += DeltaTime;
	}

	if (GetPlayerSettings().bMouseScrollEnabled)
	{
		DoMouseScroll();
	}

	UpdateSelectedEffects();
	HWHud(myHUD).UpdateStatusWindow();
}

/** Makes the camera scroll if the mouse cursor is near a screen edge (defined by MouseScrollThreshold) */
function DoMouseScroll()
{
	local HWCamera Cam;
	Cam = HWCamera(PlayerCamera);

	if (MouseLocationScreen.X < MouseScrollThreshold) 
	{
		Cam.MouseScrollLeft();
	}
	else
	{
		Cam.MouseScrollLeftStop();
	}

	if (MouseLocationScreen.X > (ViewportSize.X - MouseScrollThreshold)) 
	{
		Cam.MouseScrollRight();
	}
	else
	{
		Cam.MouseScrollRightStop();
	}

	if (MouseLocationScreen.Y < MouseScrollThreshold) 
	{
		Cam.MouseScrollUp();
	} 
	else
	{
		Cam.MouseScrollUpStop();
	}

	if (MouseLocationScreen.Y > (ViewportSize.Y - MouseScrollThreshold)) 
	{
		Cam.MouseScrollDown();
	}
	else
	{
		Cam.MouseScrollDownStop();
	}
}

/** 
 *  Updates the location of the Selected effect for all selected units.
 */
function UpdateSelectedEffects()
{
	local HWSelectable s;
	local HWPawn p;
	local HWSquadMember sm;

	foreach SelectedUnits(s) 
	{
		p = HWPawn(s);

		if (p != none)
		{
			if (p.DecalSelected != none && p.Location != p.DecalSelected.Location)
			{
				p.DecalSelected.SetLocation(p.Location);
			}

			sm = HWSquadMember(p);

			if (sm != none && sm.AbilityRadius != none && !sm.AbilityRadius.bHidden)
			{
				sm.AbilityRadius.SetLocation(sm.Location);
			}
		}
	}
}

/** Override the base implementation and do nothing in order to prevent mesh == none errors because the HWPlayerController's HWPlayerPawn doesn't have a mesh*/
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
);

// ----------------------------------------------------------------------------
// Mouse and Viewport.

/** Makes the player camera start scrolling left. */
exec function ScrollLeft()
{
	HWCamera(PlayerCamera).KeyScrollLeft();
}

/** Makes the player camera start scrolling right. */
exec function ScrollRight()
{
	HWCamera(PlayerCamera).KeyScrollRight();
}

/** Makes the player camera start scrolling up. */
exec function ScrollUp()
{
	HWCamera(PlayerCamera).KeyScrollUp();
}

/** Makes the player camera start scrolling down. */
exec function ScrollDown()
{
	HWCamera(PlayerCamera).KeyScrollDown();
}

/** Makes the player camera stop scrolling left. */
exec function ScrollLeftStop()
{
	HWCamera(PlayerCamera).KeyScrollLeftStop();
}

/** Makes the player camera stop scrolling right. */
exec function ScrollRightStop()
{
	HWCamera(PlayerCamera).KeyScrollRightStop();
}

/** Makes the player camera stop scrolling up. */
exec function ScrollUpStop()
{
	HWCamera(PlayerCamera).KeyScrollUpStop();
}

/** Makes the player camera stop scrolling down. */
exec function ScrollDownStop()
{
	HWCamera(PlayerCamera).KeyScrollDownStop();
}

/** Executed each time the user scrolls up their mouse wheel. Makes the camera zoom in a bit. */
exec function CameraZoomIn()
{
	HWCamera(PlayerCamera).ZoomIn();
}

/** Executed each time the user scrolls down their mouse wheel. Makes the camera zoom out a bit. */
exec function CameraZoomOut()
{
	HWCamera(PlayerCamera).ZoomOut();
}

/**
 * Executed each time the user presses the Y key.
 */
exec function CameraYawNegative()
{
	HWCamera(PlayerCamera).CamRotYawModifier = -1;
}

/**
 * Executed each time the user presses the X key.
 */
exec function CameraYawPositive()
{
	HWCamera(PlayerCamera).CamRotYawModifier = 1;
}

/**
 * Executed each time the user releases the X or Y key.
 */
exec function CameraYawStop()
{
	HWCamera(PlayerCamera).CamRotYawModifier = 0;
}

function SetViewTarget(Actor NewViewTarget, optional ViewTargetTransitionParams TransitionParams)
{
	// caution: super call causes strange red and yellow lines to be drawn

	// update camera location
	if (PlayerCamera != none && NewViewTarget != none)
	{
		HWCamera(PlayerCamera).SetLocation(NewViewTarget.Location);
	}
}

exec function StartFire(optional byte FireModeNum)
{
	// remember which mouse button has been pressed, and how long
	if (FireModeNum == 0) 
	{
		bLeftMousePressed = true;
		MouseLeftClickDuration = 0;		

		GroupSelectionStart = HWHud(myHUD).GetMouseCoordinates();

		// prohibit scrolling as long as the player is drawing a selection box
		HWCamera(PlayerCamera).ProhibitScrolling();
	}

	if (FireModeNum == 1)
	{
		bRightMousePressed = true;
		MouseRightClickDuration = 0;
	}
}

exec function StopFire(optional byte FireModeNum )
{
	// increase action counter for APM computation
	TotalActions++;

	// remember any mouse clicks and give the Scaleform GFx GUI the opportunity to check whether a GUI button has been clicked before processing the click
    if (FireModeNum == 0)
    {
       	ReleasedLeftMouseButton();
    }

    if (FireModeNum == 1)
    {
        ReleasedRightMouseButton();
    }
}

/**
 * Called if the left mouse button has been released last frame, and processes
 * the click if it has not already been processed by the Scaleform GFx GUI.
 * Returns true is the click has been processed, and false otherwise.
 */
function bool ReleasedLeftMouseButton()
{
	// clear flag
	bLeftMousePressed = false;
	
	// enable scrolling again
	HWCamera(PlayerCamera).AllowScrolling();

	// don't process click further if Scaleform GFx GUI already did
	if (bScaleformButtonClicked)
	{
		bScaleformButtonClicked = false;
		return false;
	}

	// tell the HUD that we might want to (de-)select units
	bShouldUpdateSelection = true;

	// check for double click
	if(`TimeSince(MouseLeftClickLastTime) <= DoubleSelectionTime)
	{
		bLeftMouseDoubleClick = true;
	}

	MouseLeftClickLastTime = WorldInfo.TimeSeconds;

	return true;
}

/**
 * Called if the right mouse button has been released last frame, and processes
 * the click if it has not already been processed by the Scaleform GFx GUI.
 * Returns true if the click has been processed, and false otherwise.
 */
function bool ReleasedRightMouseButton()
{
	local HWSelectable s;
	local HWPawn EnemyPawn;
	local HWSquadMember SquadMember;

	local HWArtifact Artifact;
	local HWAb_AcquireArtifact HarvesterAbility;

	local string ErrorMessage;

	// clear flag
	bRightMousePressed = false;

	// don't process click further if Scaleform GFx GUI already did
	if (bScaleformButtonClicked)
	{
		bScaleformButtonClicked = false;
		return false;
	}

	// check if we are just choosing a target and have cancelled
	if (!IsInState('ChoosingTarget'))
	{
		EnemyPawn = HWPawn(TraceActor);

		// only HWPawns can be attacked
		if (EnemyPawn != none && !EnemyPawn.bHidden)
		{
			// check if an enemy unit has been clicked
			if (EnemyPawn.OwningPlayer == none ||
				EnemyPawn.OwningPlayer.PlayerReplicationInfo.Team.TeamIndex != PlayerReplicationInfo.Team.TeamIndex)
			{
				EnemyPawn.ShowAttackedCircle(true);
				IssueBasicOrder(ORDER_Attack);
				return true;
			}
		}

		// check if an artifact has been clicked
		Artifact = HWArtifact(TraceActor);

		if (Artifact != none)
		{
			// check whether a harvester is selected
			foreach SelectedUnits(s)
			{
				SquadMember = HWSquadMember(s);

				if (SquadMember != none && SquadMember.OwningPlayer == self)
				{
					// check whether the selected squad member can harvest artifacts
					HarvesterAbility = HWAb_AcquireArtifact(SquadMember.HasAbility(class'HWAb_AcquireArtifact'));

					if (HarvesterAbility != none)
					{
						if (HarvesterAbility.CheckPreconditions(ErrorMessage) && HarvesterAbility.CheckTarget(Artifact, ErrorMessage))
						{
							// issue the selected unit the order to move and use the ability
							ServerIssueAbilityOrderTargetingUnit(HWAIController(SquadMember.Controller), HarvesterAbility, Artifact);
							ShowOrderTargetDestination();
						}
						else
						{
							ShowErrorMessage(ErrorMessage);
						}

						return true;
					}
				}
			}

			// none of the selected squad members is able to harvest the artifact
			ShowErrorMessage(ErrorHarvesterRequired);
			return true;
		}

		// if not, issue move orders to all selected units...
		IssueBasicOrder(ORDER_Move, MouseLocationWorld);
	}

	return true;
}

// ----------------------------------------------------------------------------
// Unit Selection.

/** 
 * Saves the set of units currently selected to the control group with the
 * specified index.
 * 
 * @param Index
 *      the index of the control group to save the current selection to
 */
exec function SaveControlGroup(byte Index)
{
	local HWSelectable s;

	// increase action counter for APM computation
	TotalActions++;

	/*
	 * Why so ugly code?
	 * 
	 * 1. Nested arrays are not allowed in UnrealScript:
	 *      array<T>[10] results in a compile-time error.
	 *      
	 * 2. No pointers to arrays.
	 *      local array<T> A, B;
	 *      A = B;
	 *      
	 *      results in A being a copy of B, not a reference to it.
	 *      
	 * 3. Call-by-value semantics for arrays passed to functions.
	 *      function Foo(array<T> A) works on a copy of A, not
	 *      on A itself.
	 *      
	 * Thanks UnrealScript.
	 */
	switch (Index)
	{
		case 1:
			ControlGroup1.Length = 0;

			foreach SelectedUnits(s)
			{
				ControlGroup1.AddItem(s);
			}

			break;
		case 2:
			ControlGroup2.Length = 0;

			foreach SelectedUnits(s)
			{
				ControlGroup2.AddItem(s);
			}

			break;
		case 3:
			ControlGroup3.Length = 0;

			foreach SelectedUnits(s)
			{
				ControlGroup3.AddItem(s);
			}

			break;
		case 4:
			ControlGroup4.Length = 0;

			foreach SelectedUnits(s)
			{
				ControlGroup4.AddItem(s);
			}

			break;
		case 5:
			ControlGroup5.Length = 0;

			foreach SelectedUnits(s)
			{
				ControlGroup5.AddItem(s);
			}

			break;
		case 6:
			ControlGroup6.Length = 0;

			foreach SelectedUnits(s)
			{
				ControlGroup6.AddItem(s);
			}

			break;
		case 7:
			ControlGroup7.Length = 0;

			foreach SelectedUnits(s)
			{
				ControlGroup7.AddItem(s);
			}

			break;
		case 8:
			ControlGroup8.Length = 0;

			foreach SelectedUnits(s)
			{
				ControlGroup8.AddItem(s);
			}

			break;
		case 9:
			ControlGroup9.Length = 0;

			foreach SelectedUnits(s)
			{
				ControlGroup9.AddItem(s);
			}

			break;
		case 0:
			ControlGroup0.Length = 0;

			foreach SelectedUnits(s)
			{
				ControlGroup0.AddItem(s);
			}

			break;
	}
}

/** 
 * Selects the set of units saved to the control group with the
 * specified index. If the same group is selected within a short amount
 * of time, the camera focus is set to that group.
 * 
 * @param Index
 *      the index of the control group to select
 */
exec function SelectControlGroup(byte Index)
{
	local HWSelectable s;
	local bool bDoubleSelection;

	// increase action counter for APM computation
	TotalActions++;

	CancelChoosingTarget();

	ClearSelection();

	// check for double selection
	bDoubleSelection = LastSelection.GroupIndex == Index && `TimeSince(LastSelection.Time) < DoubleSelectionTime;

	// why so ugly code? see SaveControlGroup for more information...
	switch (Index)
	{
		case 1:
			foreach ControlGroup1(s)
			{
				SelectedUnits.AddItem(s);
			}

			break;
		case 2:
			foreach ControlGroup2(s)
			{
				SelectedUnits.AddItem(s);
			}

			break;
		case 3:
			foreach ControlGroup3(s)
			{
				SelectedUnits.AddItem(s);
			}

			break;
		case 4:
			foreach ControlGroup4(s)
			{
				SelectedUnits.AddItem(s);
			}

			break;
		case 5:
			foreach ControlGroup5(s)
			{
				SelectedUnits.AddItem(s);
			}

			break;
		case 6:
			foreach ControlGroup6(s)
			{
				SelectedUnits.AddItem(s);
			}

			break;
		case 7:
			foreach ControlGroup7(s)
			{
				SelectedUnits.AddItem(s);
			}

			break;
		case 8:
			foreach ControlGroup8(s)
			{
				SelectedUnits.AddItem(s);
			}

			break;
		case 9:
			foreach ControlGroup9(s)
			{
				SelectedUnits.AddItem(s);
			}

			break;
		case 0:
			foreach ControlGroup0(s)
			{
				SelectedUnits.AddItem(s);
			}

			break;
	}

	RefreshSelection();

	if (bDoubleSelection)
	{
		SetFocusOnUnitGroup(SelectedUnits);
	}

	// remember this group recall for possible double selections
	LastSelection.GroupIndex = Index;
	LastSelection.Time = WorldInfo.TimeSeconds;
}

/**
 * Selects the commander or displays an error message if he's dead.
 * 
 * @param bCancelChoosingTarget
 *      whether to cancel choosing an ability target in the next frame, or not
 * @param bFocus
 *      whether to set the camera focus on the commander, or not
 */
exec function SelectCommander(optional bool bCancelChoosingTarget = true, optional bool bFocus = true)
{
	// increase action counter for APM computation
	TotalActions++;

	// in cinematic mode, stop the cinematic
	if(bCinematicMode)
	{
		TriggerGlobalEventClass(class'UTSeqEvent_SkipCinematic', self);

		return;
	}

	if(Commander != none)
	{
		if (bCancelChoosingTarget)
		{
			CancelChoosingTarget();
		}
		
		ClearSelection();

		SelectedUnits.AddItem(Commander);

		RefreshSelection();

		if (bFocus)
		{
			SetViewTarget(Commander);
		}
	}
	else
	{
		ShowErrorMessage(ErrorCommanderDead);
	}
}

/** Deselects all units. */
function ClearSelection()
{
	local HWSelectable s;

	foreach SelectedUnits(s)
	{
		s.Deselect(false);
	}

	SelectedUnits.Length = 0;
}

/** Updates the HUD, finds and remembers the strongest selected unit and plays its Selected sound. */
function RefreshSelection()
{
	local HWSelectable s;

	foreach SelectedUnits(s)
	{
		s.Select(self, false);
	}

	NotifySelectionChanged();

	if (StrongestSelectedUnit != none)
	{
		ClientPlayVoiceUnit(StrongestSelectedUnit, StrongestSelectedUnit.SoundSelected);
	}
}

/**
 * Sets the camera view focus to the specified unit group.
 * 
 * @param Units
 *      the unit group to focus
 */
function SetFocusOnUnitGroup(array<HWSelectable> Units)
{
	if (Units.Length > 0)
	{
		SetViewTarget(Units[0]);
	}
}

/** Remembers that the player is holding the SHIFT key in order to change the set of selected units. */
exec function EnableShiftSelection()
{
	bShiftSelecting = true;
}

/** Notes that the player stopped holding the SHIFT key. */
exec function DisableShiftSelection()
{
	bShiftSelecting = false;
}

/** 
 *  Called whenever a unit has been destroyed.
 *  Deselects the passed unit and destroys its selection effect.
 *  
 *  @param p
 *      the unit to deselect
 */
reliable client function DeselectUnit(HWPawn p)
{
	// skip this if the player is about to leave the game
	if (myHUD != none)
	{
		SelectedUnits.RemoveItem(p);

		// detach the selected circle
		if (p.DecalSelected != none)
		{
			p.DecalSelected.Destroy();
			p.DecalSelected = none;
		}

		NotifySelectionChanged();
	}
}

/**
 * Finds and remembers the strongest unit among the ones selected by this
 * player, and makes the HUD update all buttons.
 * 
 * Finding the strongest selected unit is done as follows:
 * 
 * 1. If a commader has been selected, marks the commander with the highest
 * level as strongest unit and returns.
 * 
 * 2. If a squad member of the first squad member class of this player's race
 * has been selected, marks the squad member with the highest level of that
 * class as strongest unit and returns.
 * 
 * 3. Performs step 2 for the two other squad members classes of this player's
 * race, in order, and returns if any squad member is found.
 * 
 * If two or more squad members of the same class have the same level, the
 * choice among these squad members is arbitrary.
 * 
 * If no squad member is selected, the choice arbritrary.
 */
function NotifySelectionChanged()
{
	local HWSelectable Unit;
	local HWSquadMember SquadMember;

	// reset selection
	StrongestSelectedUnit = none;
	SelectedCommanders.Length = 0;
	SelectedSquadMembers1.Length = 0;
	SelectedSquadMembers2.Length = 0;
	SelectedSquadMembers3.Length = 0;

	// any unit selected at all?
	if (SelectedUnits.Length == 0)
	{
		HWHud(myHUD).Update();
		return;
	}

	// put all selected squad members into buckets
	foreach SelectedUnits(Unit)
	{
		SquadMember = HWSquadMember(Unit);

		if (SquadMember != none)
		{	
			switch (SquadMember.Class)
			{
				case Race.CommanderClass:
					SelectedCommanders.AddItem(SquadMember);
					break;

				case Race.SquadMemberClasses[0]:
					SelectedSquadMembers1.AddItem(SquadMember);
					break;

				case Race.SquadMemberClasses[1]:
					SelectedSquadMembers2.AddItem(SquadMember);
					break;

				case Race.SquadMemberClasses[2]:
					SelectedSquadMembers3.AddItem(SquadMember);
					break;

				default:
					break;
			}
		}
	}

	// sort squad members by class precedence and level
	if (SelectedCommanders.Length > 0)
	{
		StrongestSelectedUnit = FindStrongestSquadMemberAmong(SelectedCommanders);
	}
	else if (SelectedSquadMembers1.Length > 0)
	{
		StrongestSelectedUnit = FindStrongestSquadMemberAmong(SelectedSquadMembers1);
	}
	else if (SelectedSquadMembers2.Length > 0)
	{
		StrongestSelectedUnit = FindStrongestSquadMemberAmong(SelectedSquadMembers2);
	}
	else if (SelectedSquadMembers3.Length > 0)
	{
		StrongestSelectedUnit = FindStrongestSquadMemberAmong(SelectedSquadMembers3);
	}
	else
	{
		// no order is implied on non-squad members; the "strongest" unit is arbitrary
		StrongestSelectedUnit = SelectedUnits[0];
	}

	// tell the HUD that the selection has changed
	HWHud(myHUD).Update();
}

/**
 * Finds the squad member with the highest level among the ones in the passed set.
 * 
 * @param inSquadMembers
 *      the set to check
 */
function HWSquadMember FindStrongestSquadMemberAmong(array<HWSquadMember> inSquadMembers)
{
	local HWSquadMember StrongestSquadMember;
	local HWSquadMember SquadMember;

	if (inSquadMembers.Length == 0)
	{
		return none;
	}

	StrongestSquadMember = inSquadMembers[0];

	foreach inSquadMembers(SquadMember) 
	{
		if (SquadMember.Level > StrongestSquadMember.Level)
		{
			StrongestSquadMember = SquadMember;
		}
	}

	return StrongestSquadMember;
}

/**
 * Finds the unit that has been created first among the ones in the passed set.
 * 
 * @param Units
 *      the set to check
 */
function HWPawn FindYoungestUnitAmong(array<HWPawn> Units)
{
	local HWPawn YoungestUnit;
	local HWPawn p;

	if (Units.Length == 0)
	{
		return none;
	}

	YoungestUnit = Units[0];

	foreach Units(p) 
	{
		if (p.CreationTime < YoungestUnit.CreationTime)
		{
			YoungestUnit = p;
		}
	}

	return YoungestUnit;
}

/**
 * Returns the strongest selected squad member of the class with the specified
 * index within the squad member class array of this player's race.
 * 
 * @param Index
 *      the index of the squad member class to find a selected squad member of
 */
function HWSquadMember FindStrongestSquadMemberByIndex(int Index)
{
	switch (Index)
	{
		case 1:
			return FindStrongestSquadMemberAmong(SelectedSquadMembers1);

		case 2:
			return FindStrongestSquadMemberAmong(SelectedSquadMembers2);

		case 3:
			return FindStrongestSquadMemberAmong(SelectedSquadMembers3);
	}

	return none;
}

/**
 * Returns the squad member with the specified class index within this player's
 * race's squad member array with the lowest structure.
 * 
 * @param Index
 *      the index of the class to find the weakest squad member of
 */
function HWSquadMember FindWeakestSquadMemberByClassIndex(int Index)
{
	local Actor a;
	local HWSquadMember WeakestSquadMember;
	local HWSquadMember SquadMember;
	local float WeakestStructurePercentage;
	local float StructurePercentage;

	WeakestStructurePercentage = 1.0f;

	// iterate all own squad members of the specified class
	foreach DynamicActors(Race.SquadMemberClasses[Index], a)
	{
		SquadMember = HWSquadMember(a);

		if (SquadMember.OwningPlayer == self)
		{
			// find squad member with lowest structure percentage
			StructurePercentage = float(SquadMember.Health) / float(SquadMember.HealthMax);

			if (StructurePercentage <= WeakestStructurePercentage)
			{
				WeakestStructurePercentage = WeakestStructurePercentage;
				WeakestSquadMember = SquadMember;
			}
		}
	}

	return WeakestSquadMember;
}

/** Focusses the strongest selected squad member. */
function FocusStrongestSelectedUnit()
{
	// increase action counter for APM computation
	TotalActions++;

	SetViewTarget(StrongestSelectedUnit);
}

/**
 * Focusses the strongest selected squad member of the class with the specified
 * index within the squad member class array of this player's race.
 * 
 * @param Index
 *      the index of the squad member class to focus a selected squad member of
 */
function FocusStrongestSelectedSMByIndex(int Index)
{
	// increase action counter for APM computation
	TotalActions++;

	SetViewTarget(FindStrongestSquadMemberByIndex(Index));
}

/** Selets all own squad members. */
exec function SelectAllSquadMembers()
{
	local HWSquadMember SquadMember;

	// increase action counter for APM computation
	TotalActions++;

	CancelChoosingTarget();

	ClearSelection();

	foreach DynamicActors(class'HWSquadMember', SquadMember)
	{
		if (SquadMember.OwningPlayer == self)
		{
			SelectedUnits.AddItem(SquadMember);
		}
	}

	RefreshSelection();
}

/**
 * Select all own culled squad members of the specified class.
 * 
 * @param Index
 *      the index of the class to select all own culled squad members of
 * @param bCancelChoosingTarget
 *      whether to cancel choosing target, or not
 */
function SelectCulledSquadMembersByClassIndex(int Index, optional bool bCancelChoosingTarget = true)
{
	local Actor a;
	local HWSquadMember SquadMember;

	// increase action counter for APM computation
	TotalActions++;

	if (bCancelChoosingTarget)
	{
		CancelChoosingTarget();
	}
	
	ClearSelection();

	// select all own culled squad members of the specified class
	foreach DynamicActors(Race.SquadMemberClasses[Index], a)
	{
		SquadMember = HWSquadMember(a);

		if (SquadMember.OwningPlayer == self && SquadMember.bCulled)
		{
			SelectedUnits.AddItem(SquadMember);
		}
	}

	RefreshSelection();
}

/** Returns all own units among the selected ones. */
function array<HWSelectable> FindSelectedOwnUnits()
{
	local array<HWSelectable> OwnUnits;
	local HWSelectable Selectable;
	local HWPawn Unit;

	foreach SelectedUnits(Selectable)
	{
		Unit = HWPawn(Selectable);

		if (Unit != none && Unit.OwningPlayer == self)
		{
			OwnUnits.AddItem(Unit);
		}
	}

	return OwnUnits;
}

/**
 * Returns all selected squad members of the class with the specified index.
 * 
 * @param Index
 *      the index of the class to get all selected squad members of
 */
function array<HWSquadMember> FindSelectedSquadMembersByClassIndex(int Index)
{
	local array<HWSquadMember> SelectedSquadMembers;

	switch (Index)
	{
		case 0:
			SelectedSquadMembers = SelectedSquadMembers1;
			break;
		case 1:
			SelectedSquadMembers = SelectedSquadMembers2;
			break;
		case 2:
			SelectedSquadMembers = SelectedSquadMembers3;
			break;
		default:
			break;
	}

	return SelectedSquadMembers;
}

// ----------------------------------------------------------------------------
// Gameplay.

/**
 * Spawns a squad member of the class with the specified index next to this
 * player's commander, if he or she has not yet reached the squad member limit
 * and has got enough shards.
 * 
 * @param Index
 *      the index of the class of the squad member to spawn, within this
 *      player's race
 */
exec function CallSquadMember(byte Index)
{
	local class<HWSquadMember> SquadMemberClass;
	local int TotalSquadMembers;
	local int ShardsRequired;
	
	if (bInCombat)
	{
		ShowErrorMessage(ErrorCantCallSquadMembersInCombat);
		return;
	}

	// grab the correct squad member class from this player's race
	SquadMemberClass = Race.SquadMemberClasses[Index];

	// increase action counter for APM computation
	TotalActions++;

	// take squad members in spawn queue into account
	TotalSquadMembers = SquadMembers + Commander.UnitsToSpawn.Length;

	// check squad member cap
	if (TotalSquadMembers >= class'HWSquadMember'.const.SQUAD_MEMBERS_MAXIMUM)
	{
		ShowErrorMessage(ErrorTooManySquadMembers);
		return;
	}

	// do we have to pay shards yet?
	ShardsRequired = GetSquadMemberCost();

	if (Shards < ShardsRequired)
	{
		ShowErrorMessage(ErrorNotEnoughShards@ShardsRequired, false);
		ClientPlayVoiceNotification(SoundNotEnoughShards);
		return;
	}

	// call new squad member
	ServerCallSquadMember(SquadMemberClass);
}

/** 
 *  Returns the cost (shards) to call an additional SquadMember.
 */
function int GetSquadMemberCost()
{
	local int TotalSquadMembers;

	TotalSquadMembers = SquadMembers;

	// take squad members in spawn queue into account (only if commander is alive)
	if(Commander != none)
	{
		TotalSquadMembers += Commander.UnitsToSpawn.Length;
	}

	return (TotalSquadMembers >= (class'HWSquadMember'.const.SQUAD_MEMBERS_MAXIMUM / 2)) ?
		class'HWSquadMember'.const.SQUAD_MEMBER_COST :
		0;
}

/**
 * Checks the level cap of the specified squad member and the number of
 * available shards, and promotes the selected squad member, if possible,
 * learning the passed ability.
 * 
 * @param SquadMember
 *      the squad member to promote
 * @param Ability
 *      the ability to learn
 */
function PromoteSquadMember(HWSquadMember SquadMember, HWAbility Ability)
{
	local int ShardsRequired;

	// check level cap
	if (SquadMember.Level >= class'HWSquadMember'.const.SQUAD_MEMBER_LEVEL_MAXIMUM)
	{
		ShowErrorMessage(ErrorMaximumLevel);
		return;
	}

	// check if the player can pay enough shards
	ShardsRequired = SquadMember.ShardsRequiredForPromotion();

	if (Shards < ShardsRequired)
	{
		ShowErrorMessage(ErrorNotEnoughShards@ShardsRequired, false);
		ClientPlayVoiceNotification(SoundNotEnoughShards);
		return;
	}

	// promote the squad member and pay the shards
	ClientShowLevelUpEffect(SquadMember);
	ServerPromoteSquadMember(SquadMember, Ability);
}

/**
 * Dismisses the strongest selected squad member, if it's not the commander,
 * adding shards.
 */
exec function DismissSquadMember()
{
	local HWSquadMember StrongestSM;

	// increase action counter for APM computation
	TotalActions++;

	// get the strongest selected unit
	StrongestSM = HWSquadMember(StrongestSelectedUnit);

	if (StrongestSM != none)
	{
		//// check if its the commander
		//if (HWCommander(StrongestSelectedUnit) != none)
		//{
		//	ShowErrorMessage(ErrorCannotDismissCommander);
		//	return;
		//}

		// dismiss the squad member and add shards
		ServerDismissSquadMember(StrongestSM);
	}
}

/**
 * Dismisses the strongest selected squad member of the class with the
 * specified index within the squad member class array of this player's
 * race.
 * 
 * @param Index
 *      the index of the squad member class to dismiss a selected squad member
 *      of
 */
function DismissStrongestSelectedSMByIndex(int Index)
{
	// increase action counter for APM computation
	TotalActions++;

	ServerDismissSquadMember(FindStrongestSquadMemberByIndex(Index));
}

/**
 * Dismisses the squad member of the class with the specified index with
 * the lowest structure.
 * 
 * @param Index
 *      the index of the class to dismiss the weakest squad member of
 */
function DismissWeakestSquadMemberByClassIndex(int Index)
{
	local HWSquadMember WeakestSquadMember;

	// increase action counter for APM computation
	TotalActions++;

	WeakestSquadMember = FindWeakestSquadMemberByClassIndex(Index);

	if (WeakestSquadMember != none)
	{
		ServerDismissSquadMember(WeakestSquadMember);
	}
}

/** Notifies this player and all allies that his or her commander has died, remembering the time. */
function NotifyCommanderDied()
{
	Commander = none;
	TimeCommanderDied = WorldInfo.GRI.ElapsedTime;
	ClientNotifyCommanderAlive(false);

	// notify all allies that our commander has fallen
	HWGame(WorldInfo.Game).NotifyCommanderDied(self);
}

/**
 * Notifies this client that its commander has died or respawned and it should
 * update its HUD.
 * 
 * @param bAlive
 *      whether the commander of this client is alive
 */
reliable client function ClientNotifyCommanderAlive(bool bAlive)
{
	// skip this if the player is about to leave the game
	if (myHUD != none)
	{
		HWHud(myHUD).NotifyCommanderAlive(bAlive);

		if (!bAlive)
		{
			ClientPlayVoiceNotification(SoundCommanderHasFallen);
		}
	}
}

/** Notifies ths player that an allied commander has fallen. */
unreliable client function ClientNotifyAlliedCommanderDied()
{
	ClientPlayVoiceNotification(SoundAlliedCommanderHasFallen);

	`log("Allied commander died!");
}

/** Prompts the player to chose a target location for respawning his or her commander. */
exec function RespawnCommander()
{
	// increase action counter for APM computation
	TotalActions++;

	if (Commander == none && WorldInfo.GRI.ElapsedTime - TimeCommanderDied >= class'HWCommander'.const.RESURRECTION_TIME)
	{
		HUDStartChoosingTarget(MessageChooseTargetLocationForCommanderRespawn);
		HWHud(myHUD).SetSpawnPointsVisible(true);
		GotoState('ChoosingTargetLocationForCommanderRespawn');
	}
}

/**
 * Spawns a squad member of the specified class next to this player's
 * commander, if he or she has not yet reached the squad member limit
 * and has got enough shards.
 * 
 * @param SquadMemberClass
 *      the class of the squad member to spawn
 */
reliable server function ServerCallSquadMember(class<HWSquadMember> SquadMemberClass)
{
	local int TotalSquadMembers;
	local int ShardsRequired;

	// take squad members in spawn queue into account
	TotalSquadMembers = SquadMembers + Commander.UnitsToSpawn.Length;

	// do we have to pay shards yet?
	ShardsRequired =
		(TotalSquadMembers >= (class'HWSquadMember'.const.SQUAD_MEMBERS_MAXIMUM / 2)) ?
		class'HWSquadMember'.const.SQUAD_MEMBER_COST :
		0;

	// check preconditions
	if ((TotalSquadMembers < class'HWSquadMember'.const.SQUAD_MEMBERS_MAXIMUM) && (Shards >= ShardsRequired))
	{
		// spawn new squad member
		Commander.AddUnitToSpawnQueue(SquadMemberClass, class'HWSquadMember'.const.MAX_SPAWN_OFFSET, self);
		Commander.SpawnUnits();
		Shards -= ShardsRequired;
		ExtraShardsSpent += ShardsRequired;

		// write log output for analyzing tool
		`log("SERVER: Squad Member \""$SquadMemberClass.default.MenuName$"\" called by "$PlayerReplicationInfo.PlayerName);
	}
}

/** 
 * Promotes the specified squad member and makes the player pay shards,
 * learning the passed ability.
 * 
 * @param Sm
 *      the squad member to promote
 * @param Ab
 *      the ability to learn
 */
reliable server function ServerPromoteSquadMember(HWSquadMember Sm, HWAbility Ab)
{
	local int ShardsRequired;

	ShardsRequired = Sm.ShardsRequiredForPromotion();

	if (Shards >= ShardsRequired)
	{
		Sm.Promote();
		Ab.bLearned = true;
		Shards -= ShardsRequired;
	}
}

/**
 * Dismisses the specified squad member and adds shards.
 * 
 * @param Sm
 *      the squad member to dismiss
 */
reliable server function ServerDismissSquadMember(HWSquadMember Sm)
{
	local int ShardsEarned;

	// don't dismiss squad members of other players
	if (Sm.OwningPlayer == self && !Sm.BeingDismissed())
	{
		ShardsEarned = Sm.ShardsEarnedWhenDismissed();
		Sm.Dismiss();
		Shards += ShardsEarned;

		if (ExtraShardsSpent > 0)
		{
			ExtraShardsSpent -= class'HWSquadMember'.const.SQUAD_MEMBER_COST;
		}
	}
}

/**
 * Tries to spawn a new commander for this player at the specified location.
 * Shows an error message instead if the location is not next a spawn point.
 * 
 * @param SpawnLocation
 *      the location to spawn a new commander at
 */
function TryRespawnCommanderAt(Vector SpawnLocation)
{
	local HWDe_SpawnArea SpawnArea;
	local bool bIntersectsSpawnArea;

	// check for spawn areas
	foreach DynamicActors(class'HWDe_SpawnArea', SpawnArea)
	{
		bIntersectsSpawnArea = bIntersectsSpawnArea || SpawnArea.Contains(SpawnLocation);
	}

	if (bIntersectsSpawnArea)
	{
		ServerRespawnCommander(SpawnLocation);
	}
	else
	{
		ShowErrorMessage(ErrorMustSpawnAtASpawnPoint);
	}
}

/**
 * Tries to spawn a new commander at the specified location if this player's
 * commander has been dead long enough, taking spawn areas into account.
 * 
 * @param SpawnLocation
 *      the location to try to spawn the commander at
 */
reliable server function ServerRespawnCommander(Vector SpawnLocation)
{
	local HWDe_SpawnArea SpawnArea;
	local bool bIntersectsSpawnArea;

	local Rotator SpawnRotation;
	local Vector CollisionBoxExtent;
	local Actor a;

	if (Commander == none && WorldInfo.GRI.ElapsedTime - TimeCommanderDied >= class'HWCommander'.const.RESURRECTION_TIME)
	{
		// check for spawn areas
		foreach DynamicActors(class'HWDe_SpawnArea', SpawnArea)
		{
			bIntersectsSpawnArea = bIntersectsSpawnArea || SpawnArea.Contains(SpawnLocation);
		}

		if (bIntersectsSpawnArea)
		{
			// prevent collisions with world geometry
			SpawnLocation.Z += 10;
			SpawnRotation.Yaw = StartSpot.Rotation.Yaw;

			CollisionBoxExtent.X = class'HWSelectable'.const.COLLISION_CHECK_RADIUS;
			CollisionBoxExtent.Y = class'HWSelectable'.const.COLLISION_CHECK_RADIUS;

			// check SpawnLocation for collision with the world geometry
			if (FindSpot(CollisionBoxExtent, SpawnLocation))
			{
				// check for encroaching actors
				foreach CollidingActors(class'Actor', a, class'HWSelectable'.const.COLLISION_CHECK_RADIUS, SpawnLocation)
				{
					ShowErrorMessage(ErrorCantSpawnCommanderHere);
					return;
				}

				// try and spawn the commander
				SpawnCommander(Map, SpawnLocation, SpawnRotation);

				if (Commander == none)
				{
					ShowErrorMessage(ErrorCantSpawnCommanderHere);
				}
				else
				{
					HUDStopChoosingTarget();
					GotoState('PlayerWalking');
				}
			}
			else
			{
				ShowErrorMessage(ErrorCantSpawnCommanderHere);
			}
		}
		else
		{
			ShowErrorMessage(ErrorMustSpawnAtASpawnPoint);
		}
	}
}

/**
 * Notifies this player and all allies that the passed unit has taken damage.
 * Enters combat if the damage source is not a damage area.
 * 
 * @param Unit
 *      the unit under attack
 * @param DamageType
 *      the type of the damage taken
 */
function NotifyTakeDamage(HWPawn Unit, class<DamageType> DamageType)
{
	if (DamageType != class'HWDT_DamageArea' && DamageType != class'HWDT_Dismiss')
	{
		EnterCombat();
	}

	ClientNotifyTakeDamage(Unit, DamageType);

	// notify all allies that we're under attack
	HWGame(WorldInfo.Game).NotifyTakeDamage(self);
}

/**
 * Notifies the client that the passed unit has taken damage.
 * Plays a sound notification if it's been some time since the last notification
 * and the attacked unit is outside the viewport.
 * 
 * @param Unit
 *      the unit under attack
 * @param DamageType
 *      the type of the damage taken
 */
unreliable client function ClientNotifyTakeDamage(HWPawn Unit, class<DamageType> DamageType)
{
	if (DamageType != class'HWDT_DamageArea' && DamageType != class'HWDT_Dismiss')
	{
		// check last notification time - we don't want to annoy the player ;)
		if ((WorldInfo.GRI.ElapsedTime - LastTimeUnitsUnderAttack > NotifyIntervalUnitsUnderAttack) || (LastTimeUnitsUnderAttack == 0))
		{
			// check whether player has already logged out
			if (PlayerCamera != none)
			{
				// is the attacked unit outside the viewport?
				if (!Unit.bCulled)
				{
					ClientPlayVoiceNotification(SoundUnitsUnderAttack);
					LastTimeUnitsUnderAttack = WorldInfo.GRI.ElapsedTime;
				}
			}
		}
	}
}

/** Notifies this player that an ally's forces are under attack. */
unreliable client function ClientNotifyAllyUnderAttack()
{
	// check last notification time - we don't want to annoy the player ;)
	if ((WorldInfo.GRI.ElapsedTime - LastTimeUnitsUnderAttack > NotifyIntervalUnitsUnderAttack) || (LastTimeUnitsUnderAttack == 0))
	{
		ClientPlayVoiceNotification(SoundAllyUnderAttack);
		LastTimeUnitsUnderAttack = WorldInfo.GRI.ElapsedTime;

		`log("Ally under attack!");
	}
}

/** Triggers all Kismet Combat Entered events and sets up a timer for triggering Combat Left events. */
reliable client function EnterCombat()
{
	if (!bInCombat)
	{
		// we are in combat now!
		bInCombat = true;

		ClientEnterCombat();
	}

	// refresh timer
	SetTimer(TIME_BEFORE_LEAVING_COMBAT, false, 'LeaveCombat');
}

/** Triggers all Kismet Combat Entered events and sets up a timer for triggering Combat Left events. */
reliable client function ClientEnterCombat()
{
	local Sequence GameSequence;
	local array<SequenceObject> Events;
	local int i;

	// trigger Kismet events
	GameSequence = WorldInfo.GetGameSequence();

	if (GameSequence != none)
	{
		GameSequence.FindSeqObjectsByClass(class'HWSeqEvent_CombatEntered', true, Events);

		for (i = 0; i < Events.Length; i++)
		{
			HWSeqEvent_CombatEntered(Events[i]).CheckActivate(self, self);
		}
	}
}

/** Triggers all Kismet Combat Left events. */
function LeaveCombat()
{
	if (bInCombat)
	{
		// leave combat
		bInCombat = false;

		ClientLeaveCombat();
	}
}

/** Triggers all Kismet Combat Left events. */
reliable client function ClientLeaveCombat()
{
	local Sequence GameSequence;
	local array<SequenceObject> Events;
	local int i;

	// trigger Kismet events
	GameSequence = WorldInfo.GetGameSequence();

	if (GameSequence != none)
	{
		GameSequence.FindSeqObjectsByClass(class'HWSeqEvent_CombatLeft', true, Events);

		for (i = 0; i < Events.Length; i++)
		{
			HWSeqEvent_CombatLeft(Events[i]).CheckActivate(self, self);
		}
	}
}

/**
 * Hides all map tiles the passed unit has vision on for this player.
 * 
 * @param Unit
 *      the unit to reset the vision for
 */
reliable client function ResetVisionFor(HWSelectable Unit)
{
	// skip this if the player is about to leave the game
	if (FogOfWarManager != none)
	{
		FogOfWarManager.VisibilityMask.HideMapTilesFor(Unit);
	}
}

/** Increases the alien rage level of this player. */
function AlienRageIncrease()
{
	AlienRage = FMin(AlienRage + ALIEN_RAGE_INCREASE_PER_KILL, 1.f);
	`log("Alien Rage level of "$self$" is now at "$int(AlienRage * 100)$"%");
}

/** Decreases the alien rage level of this player. */
function AlienRageDecrease()
{
	AlienRage = FMax(0.f, AlienRage - ALIEN_RAGE_DECREASE_PER_LOSS);
	`log("Alien Rage level of "$self$" is now at "$int(AlienRage * 100)$"%");
}

/** 
 *  Replicates this player's action counter to the server, as the server does
 *  not (need to) know about every action counter increase immediately, but
 *  at the end of each match when preparing the score screen.
 */
function ReplicateTotalActionsToServer()
{
	ServerSetTotalActions(TotalActions);
}

/** 
 * Sets the server-side action counter of this player to the specified value.
 * 
 * @param inTotalActions
 *      the new value of this player's action counter
 */
reliable server function ServerSetTotalActions(int inTotalActions)
{
	TotalActions = inTotalActions;
}

/** Gets settings defined by the player. Never returns None. */ 
function HWPlayerSettings GetPlayerSettings()
{
	if (PlayerSettings == none)
	{
		PlayerSettings = Spawn(class'HWPlayerSettings', self);
	}

	return PlayerSettings;
}

/**
 * Makes this player update his or her scores window.
 * 
 * @param Team1Score
 *      the current score of team 1
 * @param Team2Score
 *      the current score of team 2
 * @param ScoreLimit
 *      the score limit of the current match
 */
reliable client function ClientUpdateScores(int Team1Score, int Team2Score, int ScoreLimit)
{
	HWHud(myHUD).UpdateScores(Team1Score, Team2Score, ScoreLimit);
}

reliable client event TeamMessage(PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime)
{
	local ChatMessage Msg;

	super.TeamMessage(PRI, S, Type, MsgLifeTime);

	// remember this message for displaying it in the chat log
	Msg.SendingPlayerName = PRI.PlayerName;
	Msg.Text = S;

	ReceivedMessages.AddItem(Msg);

	// update chat log
	HWHud(myHUD).UpdateChatLog(Msg.SendingPlayerName, Msg.Text);
}

/** Shows or hides the Surrender dialog. */
exec function ExitGame();

// ----------------------------------------------------------------------------
// Basic Orders.

/** Prompts the player to choose a target for a move order. */
exec function TriggerMoveOrder()
{
	// increase action counter for APM computation
	TotalActions++;

	HUDStartChoosingTarget(MessageChooseTargetLocationForMove);
	GotoState('ChoosingTargetLocationForMove');
}

/** Makes all units selected by this player stop at once. */
exec function TriggerStopOrder()
{
	// increase action counter for APM computation
	TotalActions++;

	IssueBasicOrder(ORDER_Stop);
}

/** Makes all units selected by this player hold their position. */
exec function TriggerHoldPositionOrder()
{
	// increase action counter for APM computation
	TotalActions++;

	IssueBasicOrder(ORDER_HoldPosition);
}

/** Prompts the player to choose a target for an attack order. */
exec function TriggerAttackOrder()
{
	// increase action counter for APM computation
	TotalActions++;

	HUDStartChoosingTarget(MessageChooseTargetLocationForAttack);
	GotoState('ChoosingTargetLocationForAttack');
}

/**
 * Iterates the units selected by this player, picking all own units,
 * issuing the passed basic order to them and playing the appropriate
 * sound.
 * 
 * @param Order
 *      the order to issue
 */
function IssueBasicOrder(EBasicOrder Order, optional Vector TargetLocation)
{
	local HWSelectable s;
	local HWPawn p;
	local HWPawn EnemyPawn;
	local bool bAllUnitsBlinded;

	if (Order == ORDER_Attack)
	{
		// checks have already been made before
		EnemyPawn = HWPawn(TraceActor);

		// assume all own units are blinded and try to find one that is not
		bAllUnitsBlinded = true;
	}

	foreach SelectedUnits(s) 
	{
		p = HWPawn(s);

		if (p != none)
		{
			// check if its an own unit
			if (p.OwningPlayer == self)
			{
				switch (Order)
				{
					case ORDER_Move:
						ServerIssueMoveOrder(HWAIController(p.Controller), TargetLocation);
						ShowOrderTargetDestination();
						break;

					case ORDER_Stop:
						ServerIssueStopOrder(HWAIController(p.Controller));
						HideOrderTargetDestination();
						break;

					case ORDER_HoldPosition:
						ServerIssueHoldPositionOrder(HWAIController(p.Controller));
						HideOrderTargetDestination();
						break;

					case ORDER_Attack:
						if (!p.bBlinded)
						{
							ServerIssueAttackOrder(HWAIController(p.Controller), EnemyPawn);
							ShowOrderTargetDestination();
							bAllUnitsBlinded = false;
						}
						break;

					case ORDER_AttackMove:
						ServerIssueAttackMoveOrder(HWAIController(p.Controller), TargetLocation);
						ShowOrderTargetDestination();
						break;
				}
			}
		}
	}

	// play the appropriate sound if possible
	if (bAllUnitsBlinded)
	{
		ShowErrorMessage(ErrorCantDoThatWhileBlinded);
	}
	else
	{
		p = HWPawn(StrongestSelectedUnit);

		if (p != none && p.OwningPlayer == self)
		{
			switch (Order)
			{
				case ORDER_Move:
				case ORDER_Attack:
				case ORDER_AttackMove:
					ClientPlayVoiceUnit(p, p.SoundOrderConfirmed);
					break;

				case ORDER_Stop:
				case ORDER_HoldPosition:
					break;
			}
		}
	}
}

/** 
 * Server function used to issue a MoveOrder on the given HWAIController to the given TargetLocation.
 */
reliable server function ServerIssueMoveOrder(HWAIController C, Vector TargetLocation)
{
	C.IssueMoveOrder(TargetLocation);
}

/** 
 * Server function used to issue a StopOrder on the given HWAIController.
 */
reliable server function ServerIssueStopOrder(HWAIController C)
{
	C.IssueStopOrder();
}

/** 
 * Server function used to issue a HoldPosition order on the given HWAIController.
 */
reliable server function ServerIssueHoldPositionOrder(HWAIController C)
{
	C.IssueHoldPositionOrder();
}

/** 
 * Server function used to issue an AttackOrder on the given HWAIController on the given EnemyUnit.
 */
reliable server function ServerIssueAttackOrder(HWAIController C, HWPawn EnemyUnit)
{
	local HWVisibilityMask ServerVisibilityMask;

	// check whether the target unit died before the client function call reached the server
	if (EnemyUnit != none)
	{
		// cloaked EnemyUnits can't be attacked
		if(EnemyUnit.bCloaked)
		{
			// as this is prevented already on the client this player must be cheating
			`log(`location@C.Unit.OwningPlayerRI@"tried to issue an attack order on the cloaked enemy unit:"@EnemyUnit);

			return;
		}

		// grab the server visibility mask for the team of the player
		ServerVisibilityMask = HWTeamInfo(C.Unit.OwningPlayerRI.Team).VisibilityMask;

		// only issue the order if it's valid according to that mask
		if (!ServerVisibilityMask.IsMapTileHidden(Map.GetMapTileFromLocation(EnemyUnit.Location)))
		{
			C.IssueAttackOrder(EnemyUnit);
		}
		else
		{
			// ... and log any players that try to cheat ;)
			`log(C.Unit.OwningPlayerRI$" tried to issue an attack order targeting "$EnemyUnit$" which is invisible to his or her team!");
		}
	}
}

/** 
 * Server function used to issue an AttackMoveOrder on the given HWAIController to the given TargetLocation.
 */
reliable server function ServerIssueAttackMoveOrder(HWAIController C, Vector TargetLocation)
{
	C.IssueAttackMoveOrder(TargetLocation);
}

// ----------------------------------------------------------------------------
// Ability Orders.

/**
 *  Checks the availability of the ability with the specified index within the
 *  ability array of the strongest selected squad member and makes
 *  the player choose a target, if required. Tries to promote the
 *  squad member if the ability has not been learned yet,
 *  
 *  @param Index
 *      the number of the ability to activate
 */
exec function ActivateAbilityByIndex(byte Index)
{
	local HWSquadMember StrongestSM;
	local HWAbility Ability;

	// get the strongest selected unit
	StrongestSM = HWSquadMember(StrongestSelectedUnit);

	if (StrongestSM != none && StrongestSM.OwningPlayer == self)
	{
		Ability = StrongestSM.Abilities[Index];
		ActivateAbility(Ability);
	}
}

/**
 *  Selects the commander and checks the availability of the tactical ability
 *  with the specified index, making the player choose a target. Shows an
 *  error message if the commander is dead, instead.
 *  
 *  @param Index
 *      the number of the tactical ability to activate
 */
function ActivateTacticalAbilityByIndex(byte Index)
{
	if (Commander != none)
	{
		SelectCommander(false, false);
		ActivateAbility(Commander.Abilities[Index]);
	}
	else
	{
		ShowErrorMessage(ErrorCommanderDead);
	}
}

/**
 *  Checks the availability of the specified ability and makes the player
 *  choose a target, if required. Triest to promote the squad member owning
 *  the ability if it has not been learned yet,
 *  
 *  @param Ability
 *      the ability to activate
 */
function ActivateAbility(HWAbility Ability)
{
	local array<HWSelectable> OwnUnits;
	local array<HWSquadMember> SquadMembersWithAbility;
	local string ErrorMessage;
	local HWSquadMember SquadMember;
	local HWAbility AbilityToShowRadiusOf;

	// increase action counter for APM computation
	TotalActions++;

	if (Ability != none)
	{
		// check if the player can pay the ability
		if (Ability.ShardsRequired > Shards)
		{
			ShowErrorMessage(ErrorNotEnoughShards@Ability.ShardsRequired, false);
			ClientPlayVoiceNotification(SoundNotEnoughShards);
			return;
		}

		OwnUnits = FindSelectedOwnUnits();
		SquadMembersWithAbility = FindSquadMembersWithAbility(OwnUnits, Ability.Class);

		if (SquadMembersWithAbility.Length == 0)
		{
			// check if the squad member already learned that ability
			if (!Ability.bLearned)
			{
				// promote a squad member if not
				PromoteSquadMember(Ability.OwningUnit, Ability);

				// notify the HUD of the new ability pool
				HWHud(myHUD).Update();

				return;
			}

			// check preconditions
			if (!Ability.CheckPreconditions(ErrorMessage))
			{
				ShowErrorMessage(ErrorMessage);
				return;
			}
		}

		// remember the ability the player needs to choose a target for
		AbilityToChooseTargetFor = SquadMembersWithAbility[0].HasAbility(Ability.class);

		// show all ability radii
		foreach SquadMembersWithAbility(SquadMember)
		{
			AbilityToShowRadiusOf = SquadMember.HasAbility(Ability.class);

			if (AbilityToShowRadiusOf.bShowAbilityRadius)
			{
				AbilityToShowRadiusOf.OwningUnit.AbilityRadius.SetRadius(Ability.Range);
				AbilityToShowRadiusOf.OwningUnit.AbilityRadius.SetHidden(false);
			}
		}

		if (AbilityToChooseTargetFor.IsA('HWAbilityTargetingUnit'))
		{
			// make the next left-click be used as target for the ability
			HUDStartChoosingTarget(MessageChooseTargetUnit@AbilityToChooseTargetFor.AbilityName);
			GotoState('ChoosingTargetUnitForAbility');
			return;
		}

		if (AbilityToChooseTargetFor.IsA('HWAbilityTargetingLocation'))
		{
			if (AbilityToChooseTargetFor.IsA('HWAbilityTargetingLocationAOE'))
			{
				HWHud(myHUD).SwitchToAOEMouseCursor(HWAbilityTargetingLocationAOE(AbilityToChooseTargetFor).AbilityRadius);
			}

			// make the next left-click be used as target for the ability
			HUDStartChoosingTarget(MessageChooseTargetLocation@AbilityToChooseTargetFor.AbilityName);
			GotoState('ChoosingTargetLocationForAbility');
			return;
		}
	}
}

/**
 * Filters the passed unit set for squad members that have an ability of the
 * specified class ready. If bIgnoreCurrentOrders is set to true, the ability
 * must not being activated for the squad member to be added to the result set.
 * 
 * @param Units
 *      the unit set to filter
 * @param AbilityClass
 *      the ability to look for
 * @param bIgnoreCurrentOrders
 *      whether to ignore if the ability is already being activated;
 *      defaults to true
 */
function array<HWSquadMember> FindSquadMembersWithAbility(array<HWSelectable> Units, class<HWAbility> AbilityClass, optional bool bIgnoreCurrentOrders = true)
{
	local HWSelectable Selectable;
	local HWSquadMember SquadMember;
	local HWAbility Ability;
	local string ErrorMessage;

	local array<HWSquadMember> ResultSet;

	// get all squad members in the passed unit set
	foreach Units(Selectable)
	{
		SquadMember = HWSquadMember(Selectable);

		if (SquadMember != none)
		{
			// check if the squad member has the specified ability ready
			Ability = SquadMember.HasAbility(AbilityClass);

			if (Ability != none && Ability.CheckPreconditions(ErrorMessage))
			{
				// if required, check if the ability is already being activated
				if (bIgnoreCurrentOrders || !Ability.bBeingActivated)
				{
					ResultSet.AddItem(SquadMember);
				}
			}
		}
	}

	return ResultSet;
}

/**
 * Tries to find the most suitable selected squad member for smart-casting an
 * ability of the specified class.
 * 
 * 1. Filters the set of selected units for squad members that have the
 * required ability learned, ready and not being used already.
 * 
 * 2. Sorts this set of squad members by increasing distance from the target
 * location.
 * 
 * 3. Returns the squad member closest to the target location that has the
 * ability ready.
 * 
 * Special cases:
 * 
 * - If all squad members already have orders for using that ability, considers
 * all squad members instead. The closest squad member has its ability replaced
 * in that case.
 * 
 * - Returns None if no squad member has the ability learned and ready. 
 * 
 * See the German article http://starcraft2.ingame.de/content.php?c=99837&s=941
 * for more information.
 */
function HWSquadMember DetermineSquadMemberForSmartcast(class<HWAbility> AbilityClass)
{
	// filtered lists
	local array<HWSelectable> OwnUnits;
	local array<HWSquadMember> UnitSet;

	OwnUnits = FindSelectedOwnUnits();

	// 1. filter by learned, ready and not being used
	UnitSet = FindSquadMembersWithAbility(OwnUnits, AbilityClass, false);

	// if all are busy, ignore current ability orders
	if (UnitSet.Length == 0)
	{
		UnitSet = FindSquadMembersWithAbility(OwnUnits, AbilityClass);
	}

	// 2. sort by distance
	if (UnitSet.Length > 0)
	{
		UnitSet.Sort(SortSquadMembersByDistance);

		return UnitSet[0];
	}
	else
	{
		return none;
	}
}

/** 
 * Delegate function used for sorting squad members by increasing distance
 * from the target location of the ability currently being triggered.
 */
delegate int SortSquadMembersByDistance(HWSquadMember A, HWSquadMember B)
{
	local float DistanceA;
	local float DistanceB;

	DistanceA = Abs(VSize(A.Location - AbilityTargetLocation));
	DistanceB = Abs(VSize(B.Location - AbilityTargetLocation));

	return int(DistanceB - DistanceA);
}

/**
 *  Tries to choose the specified target for the current ability, and
 *  displays an error message of the target is invalid.
 *  
 *  @param Target
 *      the target for the ability
 */
function ChooseTargetUnitForAbility(HWSelectable Target)
{
	local HWSquadMember SquadMember;
	local string ErrorMessage;

	// make the ability check whether the target is valid
	if (AbilityToChooseTargetFor.OwningUnit.OwningPlayer == self && Target != none && !Target.bHidden)
	{
		// find most suitable squad member for smart-casting that ability
		AbilityTargetLocation = Target.Location;
		SquadMember = DetermineSquadMemberForSmartcast(AbilityToChooseTargetFor.Class);

		if (SquadMember == none)
		{
			return;
		}

		// go on with squad member that is most suitable for smart-casting
		AbilityToChooseTargetFor = SquadMember.HasAbility(AbilityToChooseTargetFor.Class);

		if (HWAbilityTargetingUnit(AbilityToChooseTargetFor).CheckTarget(Target, ErrorMessage))
		{
			// issue the selected unit the order to move and use the ability
			ServerIssueAbilityOrderTargetingUnit(HWAIController(AbilityToChooseTargetFor.OwningUnit.Controller), HWAbilityTargetingUnit(AbilityToChooseTargetFor), Target);

			HUDStopChoosingTarget();
			GotoState('PlayerWalking');
		}
		else
		{
			ShowErrorMessage(ErrorMessage);
		}
	}
	else
	{
		ShowErrorMessage(ErrorTargetMustBeAUnit);
	}
}

/**
 *  Choose the specified target location for the current ability.
 *  
 *  @param TargetLocation
 *      the target location for the ability
 */
function ChooseTargetLocationForAbility(Vector TargetLocation)
{
	local HWSquadMember SquadMember;
	local string ErrorMessage;

	if (AbilityToChooseTargetFor.OwningUnit.OwningPlayer == self)
	{
		// find most suitable squad member for smart-casting the ability
		AbilityTargetLocation = TargetLocation;
		SquadMember = DetermineSquadMemberForSmartcast(AbilityToChooseTargetFor.Class);

		if (SquadMember == none)
		{
			return;
		}

		// go on with squad member that is most suitable for smart-casting
		AbilityToChooseTargetFor = SquadMember.HasAbility(AbilityToChooseTargetFor.Class);

		if (HWAbilityTargetingLocation(AbilityToChooseTargetFor).CheckTargetLocation(TargetLocation, ErrorMessage))
		{
			// issue the selected unit the order to move and use the ability
			ServerIssueAbilityOrderTargetingLocation(HWAIController(AbilityToChooseTargetFor.OwningUnit.Controller), HWAbilityTargetingLocation(AbilityToChooseTargetFor), TargetLocation);

			HUDStopChoosingTarget();
			ShowOrderTargetDestination();
			GotoState('PlayerWalking');
		}
		else
		{
			ShowErrorMessage(ErrorMessage);
		}
	}
}

/** 
 * Server function used to issue an AbilityOrder on the given HWAIController with the given Ability targeting a unit.
 */
reliable server function ServerIssueAbilityOrderTargetingUnit(HWAIController C, HWAbilityTargetingUnit Ability, HWSelectable TargetUnit)
{
	local HWVisibilityMask ServerVisibilityMask;
	local string ErrorMessage;

	// check whether the target unit died before the client function call reached the server
	if (TargetUnit != none)
	{
		// cloaked pawns can't be targeted
		if(HWPawn(TargetUnit) != none && HWPawn(TargetUnit).bCloaked)
		{
			// as this is prevented already on the client this player must be cheating
			`log(`location@C.Unit.OwningPlayerRI@"tried to issue an ability order on the cloaked unit:"@TargetUnit);

			return;
		}

		if (Ability.bLearned && Ability.CheckPreconditions(ErrorMessage) && Ability.ShardsRequired <= Shards)
		{
			// do a visibility check on the TargetUnit
			if(Ability.bDoVisibilityCheck)
			{
				// grab the server visibility mask for the team of the player
				ServerVisibilityMask = HWTeamInfo(C.Unit.OwningPlayerRI.Team).VisibilityMask;

				// only issue the order if it's valid according to that mask
				if (!ServerVisibilityMask.IsMapTileHidden(Map.GetMapTileFromLocation(TargetUnit.Location)))
				{
					// Assign the given TargetUnit to the Ability (since it is only set on the client and not the server)
					Ability.TargetUnit = TargetUnit;

					C.IssueAbilityOrder(Ability);
				}
				else
				{
					// ... and log any players that try to cheat ;)
					`log(C.Unit.OwningPlayerRI$" tried to issue an ability order targeting "$TargetUnit$" which is invisible to his or her team!");
				}
			}
			else
			{
				// Assign the given TargetUnit to the Ability (since it is only set on the client and not the server)
				Ability.TargetUnit = TargetUnit;

				C.IssueAbilityOrder(Ability);
			}
		}
	}
}

/** 
 * Server function used to issue an AbilityOrder on the given HWAIController with the given Ability targeting a location.
 */
reliable server function ServerIssueAbilityOrderTargetingLocation(HWAIController C, HWAbilityTargetingLocation Ability, Vector TargetLocation)
{
	local string ErrorMessage;

	if (Ability.bLearned && Ability.CheckPreconditions(ErrorMessage) && Ability.ShardsRequired <= Shards)
	{
		// Assign the given TargetLocation to the Ability (since it is only set on the client and not the server)
		Ability.TargetLocation = TargetLocation;

		C.IssueAbilityOrder(Ability);
	}
}

// ----------------------------------------------------------------------------
// GUI Interaction.

/** 
 *  Makes the HUD show the specified error message for a short time and plays
 *  an error sound.
 *  
 *  @param ErrorMessage
 *      the error message to show
 *  @param bPlayErrorSound
 *      whether to play an error sound, or not
 */
reliable client function ShowErrorMessage(string ErrorMessage, optional bool bPlayErrorSound = true)
{
	HWHud(myHUD).ShowErrorMessage(ErrorMessage);

	if (bPlayErrorSound && !ACInterfaceError.IsPlaying())
	{
		ACInterfaceError.Location = Location;
		ACInterfaceError.SoundCue = SoundInterfaceError;
		ACInterfaceError.Play();
	}
}

/** 
 *  Makes the HUD show the specified status message for the given duration.
 *  
 *  @param StatusMessage
 *      the status message to show
 */
reliable client function ShowStatusMessage(string StatusMessage, int Duration)
{
	// skip this if the player is about to leave the game
	if (myHUD != none)
	{
		HWHud(myHUD).ShowStatusMessage(StatusMessage, Duration);
	}
}

/** Cancels choosing an ability target, making mouse click work normally again. */
function CancelChoosingTarget()
{
	HUDStopChoosingTarget();
	GotoState('PlayerWalking');
}

/**
 * Makes the HUD draw the specified choose target message and ignore
 * further unit selections.
 * 
 * @param ChooseTargetMessage
 *      the message to show
 */
reliable client function HUDStartChoosingTarget(string ChooseTargetMessage)
{
	HWHud(myHUD).StartChoosingTarget(ChooseTargetMessage);
}

/** Hides the current choose target message and allows unit selection again. */
reliable client function HUDStopChoosingTarget()
{
	local HWSquadMember SquadMember;

	HWHud(myHUD).StopChoosingTargetNextFrame();

	// hide ability radiii
	foreach DynamicActors(class'HWSquadMember', SquadMember)
	{
		SquadMember.AbilityRadius.SetHidden(true);
	}
}

/**
 * Shows the destination location of the selected units for some seconds.
 */
simulated function ShowOrderTargetDestination()
{
	bShowOrderTargetDestination = true;

	SetTimer(SHOW_ORDER_TARGET_DESTINATION_DURATION,,'HideOrderTargetDestination');
}

/**
 * Hides the destination location of the selected units.
 */
simulated function HideOrderTargetDestination()
{
	bShowOrderTargetDestination = false;
}

/** Makes the HUD draw all health bars, not just the ones of selected units. */
exec function ShowHealthBars()
{
	HWHud(myHUD).bShowHealthBars = true;
}

/** Makes the HUD draw just the health bars of selected units, not all ones. */
exec function HideHealthBars()
{
	HWHud(myHUD).bShowHealthBars = false;
}

/** 
 * Makes the HUD show a level-up effect next to the promoted squad member,
 * and plays a level-up sound.
 * 
 * @param SquadMember
 *      the squad member that has been promoted
 */
reliable client function ClientShowLevelUpEffect(HWSquadMember SquadMember)
{
	HWHud(myHUD).AddLevelUpEffectFor(SquadMember);

	SquadMember.PlaySoundPromoted();
}

reliable client function ClientShowTextUpEffect(STextUpEffect TextUpEffect)
{
	HWHud(myHUD).TextUpEffects.AddItem(TextUpEffect);
}

/** Notifies this player controller that the last mouse click has been processed by the Scaleform GFx GUI and should not be processed by the engine. */
function NotifyScaleformButtonClicked()
{
	bScaleformButtonClicked = true;
}

/** Toggle whether the terrain is shown on the minimap, or not. */
exec function ToggleMinimapTerrain()
{
	HWHud(myHUD).Minimap.bShowTerrain = !HWHud(myHUD).Minimap.bShowTerrain;
}

/** Toggle whether the fog of war is shown on the minimap, or not. */
exec function ToggleMinimapFogOfWar()
{
	HWHud(myHUD).Minimap.bShowFogOfWar = !HWHud(myHUD).Minimap.bShowFogOfWar;
}

/** Toggle whether units and game objects are shown on the minimap, or not. */
exec function ToggleMinimapUnits()
{
	HWHud(myHUD).Minimap.bShowUnits = !HWHud(myHUD).Minimap.bShowUnits;
}

 /** Toggles whether unit positions are drawn with player colors, or own units in green and enemy ones in red instead. */
function ToggleMinimapTeamColors()
{
	HWHud(myHUD).Minimap.bUseTeamColors = !HWHud(myHUD).Minimap.bUseTeamColors;
}

/**
 * Moves the camera to the specified location in tile space.
 * 
 * @param x
 *      the x-coordinate in tile space to move the camera to
 * @param y
 *      the y-coordinate in tile space to move the camera to
 */
function MinimapScroll(int x, int y)
{
	local Vector CameraLocation;

	if (PlayerCamera != none)
	{
		// translate tile coordinates to world coordinates
		CameraLocation = Map.GetCenterOfMapTile(x, y);

		// use the same z-coordinate as at player initialization
		CameraLocation.Z = StartSpot.Location.Z;

		// move the camera
		HWCamera(PlayerCamera).SetLocation(CameraLocation);
	}
}

/**
 * Uses the specified location in tile space as target for the current action.
 * 
 * @param x
 *      the x-coordinate in tile space to use as target
 * @param y
 *      the y-coordinate in tile space to use as target
 */
function MinimapClick(int x, int y);

/**
 * Uses the specified location in tile space as target for a move order.
 * 
 * @param x
 *      the x-coordinate in tile space to use as target
 * @param y
 *      the y-coordinate in tile space to use as target
 */
function MinimapRightClick(int x, int y)
{
	local Vector TargetLocation;

	// translate tile coordinates to world coordinates
	TargetLocation = Map.GetCenterOfMapTile(x, y);
		
	// issue move order
	IssueBasicOrder(ORDER_Move, TargetLocation);
}


// ----------------------------------------------------------------------------
// Sound.

/**
 * Uses the voice notification audio component for playing the passed sound
 * cue, if it is not already playing some.
 * 
 * These are triggered by the server, and thus need to be routed to the client.
 * 
 * @param Sound
 *      the sound be played
 */
unreliable client function ClientPlayVoiceNotification(SoundCue Sound)
{
	if (!ACVoiceNotifications.IsPlaying())
	{
		ACVoiceNotifications.SoundCue = Sound;
		ACVoiceNotifications.Play();
	}
}

/**
 * Uses the unit voice audio component for playing the passed sound
 * cue, if it is not already playing some.
 * 
 * These are triggered by the HUD or the local player controller only, and
 * thus no network traffic is generated. On the other hand, these should not
 * be played by the server.
 * 
 * @param Unit
 *      the unit whose sound is played
 * @param Sound
 *      the sound be played
 */
unreliable client function ClientPlayVoiceUnit(HWSelectable Unit, SoundCue Sound)
{
	if (!ACVoiceUnits.IsPlaying() && WorldInfo.GRI != none)
	{
		// check last unit voice sound time - we don't want to annoy the player ;)
		if ((WorldInfo.GRI.ElapsedTime - LastTimeVoiceUnits > IntervalVoiceUnits) || (LastTimeVoiceUnits == 0))
		{
			if (Unit != none)
			{
				ACVoiceUnits.Location = Unit.Location;
			}
			
			ACVoiceUnits.SoundCue = Sound;
			ACVoiceUnits.OnAudioFinished = VoiceUnitsPlayed;
			ACVoiceUnits.Play();
		}	
	}
}

/** 
 *  Called whenever the unit voice audio component finishes playing a sound.
 *  Remembers the time so the next sound won't be played immediately.
 *  
 *  @param AC
 *      ignored
 */
function VoiceUnitsPlayed(AudioComponent AC)
{
	LastTimeVoiceUnits = WorldInfo.GRI.ElapsedTime;
}

/**
 * Plays the passed battle cry sound at the specified location.
 * 
 * @param inLocation
 *      the location to play the sound at
 * @param SoundBattleCry
 *      the sound to play
 */
unreliable client function ClientPlaySoundBattleCry(Vector inLocation, SoundCue SoundBattleCry)
{
	if (!ACBattleCry.IsPlaying())
	{
		ACBattleCry.Location = inLocation;
		ACBattleCry.SoundCue = SoundBattleCry;
		ACBattleCry.Play();
	}
}

/** Sets the volume of all sound effects, music and voices to the ones specified in the player settings. */
reliable client function ClientSetSoundVolume()
{
	local float VolumeMaster;
	local float VolumeSFX;
	local float VolumeMusic;
	local float VolumeVoice;

	VolumeMaster = GetPlayerSettings().VolumeMaster;
	VolumeSFX = GetPlayerSettings().VolumeSFX;
	VolumeMusic = GetPlayerSettings().VolumeMusic;
	VolumeVoice = GetPlayerSettings().VolumeVoice;

	SetAudioGroupVolume('SFX', VolumeMaster * VolumeSFX / 10000.0f);
	SetAudioGroupVolume('Music', VolumeMaster * VolumeMusic / 10000.0f);
	SetAudioGroupVolume('Voice', VolumeMaster * VolumeVoice / 10000.0f);
}

/**
 * Fades in the passed music, using the specified audio component, and fading out the other one.
 * 
 * @param MusicToPlay
 *      the music to play
 * @param FadeInTime
 *      the time taken for the music to fade in
 * @param FadeOutTime
 *      the time taken for the other music to fade out
 * @param bIntense
 *      whether to use the intense music audio component, or the calm one
 */
reliable client function ClientPlayDynamicMusic(SoundCue MusicToPlay, float FadeInTime, float FadeOutTime, bool bIntense)
{
	if (bIntense)
	{
		if (ACDynamicMusicCalm.IsPlaying())
		{
			ACDynamicMusicCalm.FadeOut(FadeOutTime, 0.f);
		}

		ACDynamicMusicIntense.SoundCue = MusicToPlay;
		ACDynamicMusicIntense.FadeIn(FadeInTime, 1.f);
		ACDynamicMusicCalm.OnAudioFinished = ClientLoopDynamicMusic;
	}
	else
	{
		if (ACDynamicMusicIntense.IsPlaying())
		{
			ACDynamicMusicIntense.FadeOut(FadeOutTime, 0.f);
		}
		
		ACDynamicMusicCalm.SoundCue = MusicToPlay;
		ACDynamicMusicCalm.FadeIn(FadeInTime, 1.f);
		ACDynamicMusicCalm.OnAudioFinished = ClientLoopDynamicMusic;
	}

	LastMusicFadeInTime = FadeInTime;
}

/**
 * Callback function for finishing dynamic music audio components.
 * Loops the dynamic music if the owning player's combat state has not
 * changed as the audio componont finished (i.e. the audio component
 * didn't finish to a FadeOut call).
 * 
 * @param AC
 *      the dynamic music audio component that finished playing
 */
reliable client function ClientLoopDynamicMusic(AudioComponent AC)
{
	if (bInCombat && AC == ACDynamicMusicIntense)
	{
		ACDynamicMusicIntense.FadeIn(LastMusicFadeInTime, 1.f);
	}
	else if (!bInCombat && AC == ACDynamicMusicCalm)
	{
		ACDynamicMusicCalm.FadeIn(LastMusicFadeInTime, 1.f);
	}
}

// ----------------------------------------------------------------------------
// Cheats.

/** Adds the specified number of victory points for this player. */
exec function VictoryPoints(int Value)
{
	PlayerReplicationInfo.Team.Score += Value;
}

// ----------------------------------------------------------------------------
// Game Over and Reset.

function GameHasEnded(optional Actor EndGameFocus, optional bool bIsWinner)
{
	super.GameHasEnded(EndGameFocus, bIsWinner);

	// server - no need to wait for the scores
	ShowStatusMessage(MessageViewScores, MaxInt);

	// remember whether this player is in the winning team
	bWinner = bIsWinner;
}

/**
 * Overriding the base implementation in PlayerController.ClientGameEnded() 
 * in order to additionally change the PlayerCamera position to the EndGameFocus.Location
 * and display a status message.
 */
reliable client function ClientGameEnded(Actor EndGameFocus, bool bIsWinner)
{
	super.ClientGameEnded(EndGameFocus, bIsWinner);

	// client - show victory or defeat message until scores have been replicated
	if(bIsWinner)
	{
		`Log(self$".ClientGameEnded()"@MessagePlayerWins);
		ShowStatusMessage(MessagePlayerWins, MaxInt);
	}
	else
	{
		`Log(self$".ClientGameEnded()"@MessagePlayerLooses);
		ShowStatusMessage(MessagePlayerLooses, MaxInt);
	}

	// remember whether this player is in the winning team
	bWinner = bIsWinner;
}

/** Called on the server on reset. */
function Reset()
{
	super.Reset();	

	Shards = 0;
	ExtraShardsSpent = 0;

	// Caution: don't set SquadMembers to 0 here! 
	// Doing so would interfere with the counter decrementation on the HWSquadMember.Destroyed() call, resulting in a negative SquadMembers number on round end.
	
	OnReset();
}

/** Called on the client on reset. */
reliable client function ClientReset()
{
	super.ClientReset();

	if(WorldInfo.NetMode == NM_Client)
	{
		HWHud(myHUD).Reset();
	}

	OnReset();
}

/** Resets variables for resets triggered on server or client. */
simulated function OnReset()
{
	SelectedUnits.Length = 0;
	
	AbilityToChooseTargetFor = none;
	bShowOrderTargetDestination = false;
}

// ----------------------------------------------------------------------------
// Pre-Match Lobby.

/**
 * Notifies this client that another player with the passed name has joined
 * the specified team.
 * 
 * @param PlayerName
 *      the name of the joining player
 * @param TeamIndex
 *      the team index of the joining player
 * @param Slot
 *      the team slot of the joining player
 */
reliable client function ClientOtherPlayerJoined(string PlayerName, int TeamIndex, int Slot);

/**
 * Notifies this client that another player with the passed name has left
 * the specified team.
 * 
 * @param PlayerName
 *      the name of the leaving player
 * @param TeamIndex
 *      the team index of the leaving player
 * @param Slot
 *      the team slot of the leaving player
 */
reliable client function ClientOtherPlayerLeft(string PlayerName, int TeamIndex, int Slot);

/** Tells the server that this player wants to change its team. */
reliable server function ServerSwitchTeam()
{
	 SwitchTeam();
}

/**
 * Notifies this client that a player has changed its team.
 * 
 * @param PlayerName
 *      the name of the player that changed its team
 * @param OldTeamIndex
 *      the previous index of the team of the player
 * @param OldSlot
 *      the previous team slot of the player
 * @param NewTeamIndex
 *      the new index of the team of the player
 * @param NewSlot
 *      the new team slot of the player
 */
reliable client function ClientPlayerChangedTeam(string PlayerName, int OldTeamIndex, int OldSlot,  int NewTeamIndex, int NewSlot);

/** Nofities this client that the server is shutting down. */
reliable client function ClientNotifyServerShutDown();

/** Broadcasts a chat message to all other players. */
reliable client function ClientBroadcastChatMessage(string Message);

/** Shows basic profiling information, if not already doing so. Servers don't want to do this for each player, and clients don't have access to GameInfo. */
reliable client function ClientShowFPS()
{
	if (bShouldShowFPS && !bShowingFPS)
	{
		ConsoleCommand("STAT FPS");
		ConsoleCommand("STAT UNIT");
		bShowingFPS = true;
	}
}

/** Hides or shows the HUD. */
exec function ToggleScreenShotMode()
{
	myHUD.bShowHUD = !myHUD.bShowHUD;

	ConsoleCommand("STAT FPS");
	ConsoleCommand("STAT UNIT");

	bShowingFPS = !bShowingFPS;
}

// ----------------------------------------------------------------------------
// States.

auto state PlayerWaiting
{
	reliable client function ClientOtherPlayerJoined(string PlayerName, int TeamIndex, int Slot)
	{
		if (PreMatchLobby != none)
		{
			PreMatchLobby.PlayerJoined(PlayerName, TeamIndex, Slot);
		}
	}

	reliable client function ClientOtherPlayerLeft(string PlayerName, int TeamIndex, int Slot)
	{
		if (PreMatchLobby != none)
		{
			PreMatchLobby.PlayerLeft(PlayerName, TeamIndex, Slot);
		}
	}

	reliable client function ClientPlayerChangedTeam(string PlayerName, int OldTeamIndex, int OldSlot,  int NewTeamIndex, int NewSlot)
	{
		if (PreMatchLobby != none)
		{
			PreMatchLobby.PlayerChangedTeam(PlayerName, OldTeamIndex, OldSlot, NewTeamIndex, NewSlot);
		}
	}

	reliable client function ClientBroadcastChatMessage(string Message)
	{
		// TODO use Say(string) instead to enable flood protection
		ServerSay(Message);
	}

	reliable client event TeamMessage(PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime)
	{
		super.TeamMessage(PRI, S, Type, MsgLifeTime);

		if (PreMatchLobby != none)
		{
			PreMatchLobby.ChatMessageReceived(PRI.PlayerName, S);
		}
	}

	reliable client event ClientWasKicked()
	{
		if (PreMatchLobby != none)
		{
			PreMatchLobby.PlayerKicked();
		}
	}

	reliable client function ClientNotifyServerShutDown()
	{
		if (PreMatchLobby != none)
		{
			PreMatchLobby.ServerShutDown();
		}
	}

	// don't restart player on left-click
	exec function StartFire(optional byte FireModeNum);
}

state PlayerWalking
{
	event BeginState(Name PreviousStateName)
	{
		if (PreviousStateName == 'PlayerWaiting' ||     // server
			PreviousStateName == 'WaitingForPawn')      // client
		{
			// match has begin, close pre-match lobby on client
			if (PreMatchLobby != none)
			{
				PreMatchLobby.HideView();
			}

			// load the GUI
			if (myHUD != none)
			{
				HWHud(myHUD).LoadGUI();
			}

			// show FPS on client if not already doing so
			//ClientShowFPS();
		}
	}

	exec function ExitGame()
	{
		if (WorldInfo.NetMode != NM_Standalone)
		{
			// show surrender dialog
			HWHud(myHUD).GFxHUD_SubmenusMC.ToggleDialogSurrender();
		}
		else
		{
			// if PIE, unload Scaleform GFx GUI and quit
			HWHud(myHUD).UnloadGUI();
			ConsoleCommand("quit");
		}
	}
}

state ChoosingTarget extends PlayerWalking
{
	ignores MinimapScroll, MinimapRightClick;

	function bool ReleasedRightMouseButton()
	{
		if (global.ReleasedRightMouseButton())
		{
			// if Scaleform didn't process the click, stop choosing a target
			CancelChoosingTarget();
			return true;
		}

		return false;
	}
}

state ChoosingTargetUnitForAbility extends ChoosingTarget
{
	function bool ReleasedLeftMouseButton()
	{
		if (global.ReleasedLeftMouseButton())
		{
			// if Scaleform didn't process the click, start choosing a target
			ChooseTargetUnitForAbility(HWSelectable(TraceActor));
			ShowOrderTargetDestination();
			return true;
		}
		
		return false;
	}
}

state ChoosingTargetLocationForAbility extends ChoosingTarget
{
	function bool ReleasedLeftMouseButton()
	{
		if (global.ReleasedLeftMouseButton())
		{
			// if Scaleform didn't process the click, start choosing a target
			ChooseTargetLocationForAbility(MouseLocationWorld);
			return true;
		}

		return false;
	}

	function MinimapClick(int x, int y)
	{
		local Vector TargetLocation;

		// translate tile coordinates to world coordinates
		TargetLocation = Map.GetCenterOfMapTile(x, y);
		
		// issue ability order
		ChooseTargetLocationForAbility(TargetLocation);
	}
}

state ChoosingTargetLocationForCommanderRespawn extends ChoosingTarget
{
	function bool ReleasedLeftMouseButton()
	{
		if (global.ReleasedLeftMouseButton())
		{
			// if Scaleform didn't process the click, try to respawn the commander
			TryRespawnCommanderAt(MouseLocationWorld);
			return true;
		}

		return false;
	}

	function MinimapClick(int x, int y)
	{
		local Vector TargetLocation;

		// translate tile coordinates to world coordinates
		TargetLocation = Map.GetCenterOfMapTile(x, y);
		
		// try to respawn the commander
		TryRespawnCommanderAt(TargetLocation);
	}
}

state ChoosingTargetLocationForMove extends ChoosingTarget
{
	function bool ReleasedLeftMouseButton()
	{
		if (global.ReleasedLeftMouseButton())
		{
			// if Scaleform didn't process the click, start issuing orders
			IssueBasicOrder(ORDER_Move, MouseLocationWorld);
			HUDStopChoosingTarget();
			GotoState('PlayerWalking');
			return true;
		}
		
		return false;
	}

	function MinimapClick(int x, int y)
	{
		local Vector TargetLocation;

		// translate tile coordinates to world coordinates
		TargetLocation = Map.GetCenterOfMapTile(x, y);
		
		// issue move order
		IssueBasicOrder(ORDER_Move, TargetLocation);
		HUDStopChoosingTarget();
		GotoState('PlayerWalking');
	}
}

state ChoosingTargetLocationForAttack extends ChoosingTarget
{
	function bool ReleasedLeftMouseButton()
	{
		local HWPawn EnemyPawn;

		if (global.ReleasedLeftMouseButton())
		{
			// if Scaleform didn't process the click, check if an enemy unit has been clicked
			EnemyPawn = HWPawn(TraceActor);

			// only HWPawns can be attacked
			if (EnemyPawn != none && !EnemyPawn.bHidden)
			{
				// check if an enemy unit has been clicked
				if (EnemyPawn.OwningPlayer == none ||
					EnemyPawn.OwningPlayer.PlayerReplicationInfo.Team.TeamIndex != PlayerReplicationInfo.Team.TeamIndex)
				{
					IssueBasicOrder(ORDER_Attack);
					HUDStopChoosingTarget();
					GotoState('PlayerWalking');
					return true;
				}
			}

			// player has clicked on the ground - issue attack-move order instead
			IssueBasicOrder(ORDER_AttackMove, MouseLocationWorld);
			HUDStopChoosingTarget();
			GotoState('PlayerWalking');
			return true;
		}
		
		return false;
	}

	function MinimapClick(int x, int y)
	{
		local Vector TargetLocation;

		// translate tile coordinates to world coordinates
		TargetLocation = Map.GetCenterOfMapTile(x, y);
		
		// issue attack-move order
		IssueBasicOrder(ORDER_AttackMove, TargetLocation);
		HUDStopChoosingTarget();
		GotoState('PlayerWalking');
	}
}

state RoundEnded
{
	// ignores copied from PlayerController
	ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide,
	// additional ignores for HWPlayerController
	StopFire, ActivateAbilityByIndex, TriggerMoveOrder, TriggerStopOrder, TriggerHoldPositionOrder, TriggerAttackOrder, DismissSquadMember, CallSquadMember, RespawnCommander;
	
	event BeginState(Name PreviousStateName)
	{
		local Pawn P;

		// Call TurnOff() on all pawns here, in order to freeze them on the client
		if(Role < ROLE_Authority)
		{
			ForEach DynamicActors(class'Pawn', P)
			{
				P.TurnOff();
			}
		}
	}

	exec function StartFire(optional byte FireModeNum)
	{
		local HWGFxScreen_Scores ScoreScreen;

		if (Results != none)
		{
			// show scores if already replicated
			ScoreScreen = new class'HWGFxScreen_Scores';
			ScoreScreen.ShowView();
		}
	}

	// --- uncomment these functions to restore restart logic again ---

	//event BeginState(Name PreviousStateName)
	//{
	//	local Pawn P;

	//	bFrozen = TRUE;
	//	// calls Timer() after the given time
	//	SetTimer(float(TIME_FREEZE_AFTER_ROUND), FALSE); 

	//	// Call TurnOff() on all pawns here, in order to freeze them on the client
	//	if(Role < ROLE_Authority)
	//	{
	//		ForEach DynamicActors(class'Pawn', P)
	//		{
	//			P.TurnOff();
	//		}
	//	}
	//}

	//reliable server function ServerReStartGame()
	//{
	//	if (WorldInfo.Game.PlayerCanRestartGame(self))
	//	{
	//		WorldInfo.Game.ResetLevel();
	//	}
	//}

	//exec function StartFire(optional byte FireModeNum)
	//{
	//	// Opposed to the implementation in PlayerController let PlayerControllers with ROLE_AutonomousProxy also restart the game (necessary if using a dedicated server)
	//	if (Role < ROLE_AutonomousProxy)
	//	{
	//		return;
	//	}

	//	if (!bFrozen)
	//	{
	//		ServerReStartGame();
	//	}
	//	else if (!IsTimerActive())
	//	{
	//		SetTimer(1.5, false);
	//	}
	//}

	//event Timer()
	//{
	//	bFrozen = false;
	//}

	// --- -------------------------------------------------------- ---
}

// ----------------------------------------------------------------------------
// Replication.

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'Results')
	{
		ShowStatusMessage(MessageViewScores, MaxInt);
		`log("Received game results.");
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

replication
{
	// replicate if server
	if (Role == ROLE_Authority && (bNetInitial || bNetDirty))
		Shards, ExtraShardsSpent, SquadMembers, Commander, TimeCommanderDied, AlienRage, Results, bInCombat;
}


DefaultProperties
{
	CameraClass=class'HWCamera'

	Begin Object Class=HWRace_Humans Name=NewRace
	End Object
	Race=NewRace

	MouseScrollThreshold=10;

	RemoteRole = ROLE_AutonomousProxy;

	Begin Object Class=AudioComponent name=NewACVoiceNotifications
	End Object
	ACVoiceNotifications=NewACVoiceNotifications
	Components.Add(NewACVoiceNotifications)

	Begin Object Class=AudioComponent name=NewACVoiceUnits
	End Object
	ACVoiceUnits=NewACVoiceUnits
	Components.Add(NewACVoiceUnits)

	Begin Object Class=AudioComponent name=NewACBattleCry
	End Object
	ACBattleCry=NewACBattleCry
	Components.Add(NewACBattleCry)

	Begin Object Class=AudioComponent name=NewACInterfaceError
	End Object
	ACInterfaceError=NewACInterfaceError
	Components.Add(NewACInterfaceError)

	Begin Object Class=AudioComponent name=NewACDynamicMusicCalm
		bIsMusic=true
	End Object
	ACDynamicMusicCalm=NewACDynamicMusicCalm
	Components.Add(NewACDynamicMusicCalm)

	Begin Object Class=AudioComponent name=NewACDynamicMusicIntense
		bIsMusic=true
	End Object
	ACDynamicMusicIntense=NewACDynamicMusicIntense
	Components.Add(NewACDynamicMusicIntense)

	SoundAlliedCommanderHasFallen=SoundCue'A_Test_Voice_Interface.AlliedCommanderFallen_Cue'
	SoundAllyUnderAttack=SoundCue'A_Test_Voice_Interface.AlliesUnderAttack_Cue'
	SoundCommanderHasFallen=SoundCue'A_Test_Voice_Interface.CommanderFallen_Cue'
	SoundNotEnoughShards=SoundCue'A_Test_Voice_Interface.NotEnoughShards_Cue'
	SoundUnitsUnderAttack=SoundCue'A_Test_Voice_Interface.UnitsUnderAttack_Cue'

	SoundInterfaceError=SoundCue'A_Sounds_General.A_General_InterfaceErrorCue_Test'

	bShouldShowFPS=true
}
