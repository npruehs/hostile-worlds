// ============================================================================
// HWHud
// Allows computing the mouse cursor position and drawing selection boxes,
// version information or information on selected units.
//
// Author:  Nick Pruehs, Marcel Koehler
// Date:    2010/08/31
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================

class HWHud extends HUD
	config(HostileWorlds);

/** The time error messages are shown, in seconds. */
const DURATION_ERROR_MESSAGES = 3;

/** The number of pixels health bars are drawn above the heads of the units. */
const HEALTH_BAR_OFFSET = 5;

/** The height of health bars on the screen, in pixels. */
const HEALTH_BAR_HEIGHT = 7;

/** The width of health bars on the screen, in pixels. */
const HEALTH_BAR_WIDTH = 40;

/** The width and height of the borders of the health bars, in pixels. */
const HEALTH_BAR_BORDER_WIDTH = 1;

/** The number of pixels player names are drawn above the heads of the units. */
const PLAYER_NAME_OFFSET = 25;

/** The number of pixels level-up effects are drawn right of the units. */
const LEVELUP_EFFECT_OFFSET = 5;

/** 
 *  How big the distance between the mouse cursor location, from mouse click to mouse release, 
 *  must be in order to do a group selection. 
 *  If the distance is less this value a single unit selection is done instead.
 *  30 seems to be an ok value.
 *  */
const GROUP_SELECTION_DISTANCE_THRESHOLD = 30;

/** Whether to draw actor pathfinding routes, or not. */
var bool bDrawRoutes;

/** Whether to draw all health bars, or just the ones of selected units. */
var bool bShowHealthBars;

/** The texture of the mouse cursor. */
var Texture2D CursorTexture;

/** The texture of the mouse cursor that is shown if the player is choosing a target. */
var Texture2D ChooseTargetCursorTexture;

/** Whether this HUD is currently showing a mouse cursor indicating an area of effect, or not. */
var bool bShowingAOEMouseCursor;

/** The mouse cursor used by this HUD for indicating areas of effect. */
var HWDe_MouseCursorAoE MouseCursorAOE;

/** A status message that is shown for important game occurences (e.g. Winning / Loosing). */
var string StatusMessage;

/** The error message currently being shown. */
var string ErrorMessage;

/** The message that tells the player what ability he or she is currently choosing a target for. */
var string ChooseTargetMessage;

/** The message to be displayed while the player's commander is dead. */
var localized string MessageCommanderDead;

/** The message telling how many seconds remain until the player can resurrect his or her commander. */
var localized string MessageCommanderDeadTimeRemaining;

/** The message telling how to resurrect the commander. */
var localized string MessageCommanderDeadResurrect;

/** The color to use for the message to be displayed while the player's commander is dead. */
var Color ColorCommanderDead;

/** Whether the player is currently choosing a target for an ability - he or she may not select other units then. */
var bool bChoosingTarget;

/** Whether the player has chosen a target for an ability and may select other units in the next frame again. */
var bool bStopChoosingTargetNextFrame;

/** A reference to the HWMapInfoActor that allows tranformations between world space and tile space. */
var HWMapInfoActor Map;

/** The minimap to be drawn. */
var HWMinimap Minimap;

struct SLevelUpEffect
{
	var HWSquadMember SquadMember;
	var int Level;
	var int Progress;
};

/** The list of level-up effects to draw. */
var array<SLevelUpEffect> LevelUpEffects;

/** The duration of level-up effects, in seconds. */
var int LevelUpEffectDuration;

/** The list of textures used for drawing level-up effects. */
var array<Texture2D> LevelUpGraphics;

/** The list of text-up effects to draw. */
var array<STextUpEffect> TextUpEffects;

/** The duration of text-up effects, in seconds. */
var int TextUpEffectDuration;

/** A cached reference to the player settings. */
var HWPlayerSettings PlayerSettings;

/** The window containing the ability buttons of the selected unit(s). */
var HWGFxHUD_Abilities GFxHUD_AbilitiesMC;

/** The status windows showing information on the selected unit(s). */
var HWGFxHUD_StatusWindow GFxHUD_StatusWindowMC;

/** The submenus allowing calling squad members and triggering tactical abilities. */
var HWGFxHUD_Submenus GFxHUD_SubmenusMC;

/** The command window providing access to all standard orders. */
var HWGFxHUD_CommandWindow GFxHUD_CommandWindowMC;

/** The window showing the current team scores and score limit. */
var HWGFxHUD_VictoryPoints GFxHUD_VictoryPointsMC;

/** The window showing the current shards, squad members and match time. */
var HWGFxHUD_InfoBar GFxHUD_InfoBarMC;

/** The window showing the minimap. */
var HWGFxHUD_Minimap GFxHUD_MinimapMC;

/** The window showing all chat messages received by the local player. */
var HWGFxHUD_ChatLog GFxHUD_ChatLogMC;

/** The movie clip containing the mouse cursor to be drawn with highest priority. */
var HWGFxHUD_Mouse GFxHUD_MouseMC;


/**
 * Initializes this HUD, preparing the minimap for rendering the minimap
 * texture, the fog of war and all visible units.
 * 
 * @param TheMap
 *      the map to show on the minimap
 */
function InitializeHUD(HWMapInfoActor TheMap)
{
	Map = TheMap;

	Minimap = new class'HWMinimap';
	Minimap.Initialize(Map, HWPlayerController(PlayerOwner));

	MouseCursorAoE = Spawn(class'HWDe_MouseCursorAoE', PlayerOwner);

	// grab a cached reference to the player settings
	PlayerSettings = HWPlayerController(PlayerOwner).GetPlayerSettings();
}

/** Loads and initializes the Scaleform GFx GUI. */
function LoadGUI()
{
	GFxHUD_AbilitiesMC = new class'HWGFxHUD_Abilities';
	GFxHUD_AbilitiesMC.myHUD = self;
	GFxHUD_AbilitiesMC.Start();
	GFxHUD_AbilitiesMC.SetAlignment(Align_CenterRight);
	GFxHUD_AbilitiesMC.Update();
	
	GFxHUD_StatusWindowMC = new class'HWGFxHUD_StatusWindow';
	GFxHUD_StatusWindowMC.myHUD = self;
	GFxHUD_StatusWindowMC.Start();
	GFxHUD_StatusWindowMC.SetAlignment(Align_BottomCenter);
	GFxHUD_StatusWindowMC.Update();

	GFxHUD_SubmenusMC = new class'HWGFxHUD_Submenus';
	GFxHUD_SubmenusMC.myHUD = self;
	GFxHUD_SubmenusMC.Start();
	GFxHUD_SubmenusMC.SetAlignment(Align_TopLeft);
	GFxHUD_SubmenusMC.Update();

	GFxHUD_CommandWindowMC = new class'HWGFxHUD_CommandWindow';
	GFxHUD_CommandWindowMC.myHUD = self;
	GFxHUD_CommandWindowMC.Start();
	GFxHUD_CommandWindowMC.SetAlignment(Align_BottomRight);
	GFxHUD_CommandWindowMC.Update();
	GFxHUD_CommandWindowMC.NotifyCommanderAlive(true);

	GFxHUD_VictoryPointsMC = new class'HWGFxHUD_VictoryPoints';
	GFxHUD_VictoryPointsMC.myHUD = self;
	GFxHUD_VictoryPointsMC.Start();
	GFxHUD_VictoryPointsMC.SetAlignment(Align_TopCenter);
	GFxHUD_VictoryPointsMC.Update();

	GFxHUD_InfoBarMC = new class'HWGFxHUD_InfoBar';
	GFxHUD_InfoBarMC.myHUD = self;
	GFxHUD_InfoBarMC.Start();
	GFxHUD_InfoBarMC.SetAlignment(Align_TopRight);
	
	UpdateInfoBar();

	GFxHUD_MinimapMC = new class'HWGFxHUD_Minimap';
	GFxHUD_MinimapMC.myHUD = self;
	GFxHUD_MinimapMC.Start();
	GFxHUD_MinimapMC.SetAlignment(Align_BottomLeft);

	GFxHUD_ChatLogMC = new class'HWGFxHUD_ChatLog';
	GFxHUD_ChatLogMC.myHUD = self;
	GFxHUD_ChatLogMC.Start();
	GFxHUD_ChatLogMC.SetAlignment(Align_Center);
	GFxHUD_ChatLogMC.Close(false);

	GFxHUD_MouseMC = new class'HWGFxHUD_Mouse';
	GFxHUD_MouseMC.Start();
}

/** Unloads the Scaleform GFx GUI. */
function UnloadGUI()
{
	GFxHUD_AbilitiesMC.Close(true);
	GFxHUD_StatusWindowMC.Close(true);
	GFxHUD_SubmenusMC.Close(true);
	GFxHUD_SubmenusMC.DialogSurrender.Close(true);
	GFxHUD_CommandWindowMC.Close(true);
	GFxHUD_VictoryPointsMC.Close(true);
	GFxHUD_InfoBarMC.Close(true);
	GFxHUD_MinimapMC.Close(true);
	GFxHUD_ChatLogMC.Close(true);
	GFxHUD_MouseMC.Close(true);
}

/** Returns the position of the player's mouse cursor on the screen. */
function Vector2D GetMouseCoordinates()
{
    local Vector2D MousePosition;
    local UIInteraction UIController;
    local GameUISceneClient GameSceneClient;

    UIController  = PlayerOwner.GetUIController();

    if ( UIController != None)
    {
        GameSceneClient = UIController.SceneClient;
        if ( GameSceneClient != None )
        {
            MousePosition.X = GameSceneClient.MousePosition.X;
            MousePosition.Y = GameSceneClient.MousePosition.Y;
        }
    }

    return MousePosition;
}

function DrawHUD()
{
	local float SelectionBoxX;
	local float SelectionBoxY;	
	local float SelectionBoxWidth;	
	local float SelectionBoxHeight;

	local float TextLengthX;
	local float TextLengthY;

	local HWSelectable s;
	local HWPawn p;
	local HWAIController c;

	local HWPlayerController Player;
	Player = HWPlayerController(PlayerOwner);

	// draw selection box
	if (Player.bLeftMousePressed)
	{
		Canvas.DrawColor = MakeColor(255, 255, 255, 100);

		SelectionBoxX = fMin(Player.GroupSelectionStart.X, Player.MouseLocationScreen.X);
		SelectionBoxY = fMin(Player.GroupSelectionStart.Y, Player.MouseLocationScreen.Y);

		SelectionBoxWidth = Abs(Player.GroupSelectionStart.X - Player.MouseLocationScreen.X);
		SelectionBoxHeight = Abs(Player.GroupSelectionStart.Y - Player.MouseLocationScreen.Y);

		Canvas.SetPos(SelectionBoxX, SelectionBoxY);
		Canvas.DrawRect(SelectionBoxWidth, SelectionBoxHeight);
	}

	// show order target destinations (only in PlayerWalking state)
	if (PlayerOwner.IsInState('PlayerWalking') && Player.bShowOrderTargetDestination)
	{
		foreach Player.SelectedUnits(s) 
		{
			p = HWPawn(s);

			if (p != none && p.OwningPlayer == Player)
			{
				c = HWAIController(p.Controller);

				if (c != none)
				{
					switch (c.CurrentOrder)
					{
						case O_Moving: 
							Draw3DLine(p.Location, c.OrderTargetDestination, GreenColor);
							break;

						case O_Attacking:  
							if(c.OrderTargetUnit != none)
							{
								Draw3DLine(p.Location, c.OrderTargetUnit.Location, RedColor);
							}
							break;

						case O_UsingAbilityTargetingUnit:
							if(c.OrderedAbilityTargetingUnit.TargetUnit != none)
							{
								Draw3DLine(p.Location, c.OrderedAbilityTargetingUnit.TargetUnit.Location, MakeColor(255, 255, 0, 255));
							}
							break;

						case O_UsingAbilityTargetingLocation:
							Draw3DLine(p.Location, c.OrderedAbilityTargetingLocation.TargetLocation, MakeColor(255, 255, 0, 255));
							break;

						default:
							break;
					}
				}
			}
		}
	}

	// show "Resurrect Commander" message
	if (Player.IsInState('PlayerWalking') && Player.Commander == none)
	{
		ShowCommanderResurrectionInfo();
	}

	// show error message
	Canvas.TextSize(ErrorMessage, TextLengthX, TextLengthY);
	Canvas.SetPos((Canvas.SizeX - TextLengthX) / 2, Canvas.SizeY - 250);
	Canvas.DrawColor = MakeColor(255, 0, 0, 255);
    Canvas.DrawText(ErrorMessage, false);

	// show choose target message (only in PlayerWalking state)
	if(PlayerOwner.IsInState('PlayerWalking'))
	{
		Canvas.TextSize(ChooseTargetMessage, TextLengthX, TextLengthY);
		Canvas.SetPos((Canvas.SizeX - TextLengthX) / 2, Canvas.SizeY - 280);
		Canvas.DrawColor = MakeColor(255, 255, 0, 255);
		Canvas.DrawText(ChooseTargetMessage, false);
	}

	// show status message
	Canvas.TextSize(StatusMessage, TextLengthX, TextLengthY);
	TextLengthX *= 2;
	Canvas.SetPos((Canvas.SizeX - TextLengthX) / 2, Canvas.SizeY - 280);
	Canvas.DrawColor = MakeColor(255, 0, 0, 255);
	Canvas.DrawText(StatusMessage, false, 2, 2);
}

/** Tells that player that his or her commander is dead, and when and how to resurrect him. */
function ShowCommanderResurrectionInfo()
{
	local HWPlayerController Player;
	local string Message;
	local float TextLengthX;
	local float TextLengthY;
	local int TimeRemaining;
	
	if (WorldInfo.GRI != none)
	{
		Player = HWPlayerController(PlayerOwner);

		// tell the player that the commander is dead
		Message = MessageCommanderDead;

		// compute time remaining before the commander can be resurrected
		TimeRemaining = class'HWCommander'.const.RESURRECTION_TIME - (WorldInfo.GRI.ElapsedTime - Player.TimeCommanderDied);

		if (TimeRemaining > 0)
		{
			// tell the player the number of remaining seconds
			Message @= Repl(MessageCommanderDeadTimeRemaining, "%1", TimeRemaining);    
		}
		else
		{
			// tell the player how to resurrect the commander
			Message @= MessageCommanderDeadResurrect;
		}

		// show message
		ColorCommanderDead.R = (ColorCommanderDead.R + 2) % 255;

		Canvas.TextSize(Message, TextLengthX, TextLengthY);
		Canvas.SetPos((Canvas.SizeX - TextLengthX) / 2, Canvas.SizeY - 220);
		Canvas.DrawColor = ColorCommanderDead;
		Canvas.DrawText(Message, false);
	}
}

/**
 * Makes this HUD showing a special mouse cursor indicating an area of
 * effect with the passed radius.
 * 
 * @param Radius
 *      the radius of the area of effect to show
 */
function SwitchToAOEMouseCursor(float Radius)
{
	bShowingAOEMouseCursor = true;

	MouseCursorAOE.SetRadius(Radius);
	MouseCursorAOE.SetHidden(false);
}

event PostRender()
{
    local HWPlayerController HWPlayerCtrl;
    local HWCamera PlayerCam;
	local Vector MouseWorldOrigin, MouseWorldDirection;
	local Vector TempHitLocation, TempHitNormal;
	local Vector2D selectionDistanceVector, CanvasFrom, CanvasTo;
	local float selectionDistance;

	local HWSelectable s;

	local Vector StartTrace;
	local Vector EndTrace;
	local Vector RayDir;

    super.PostRender();

	if (bShowHUD)
	{
		HWPlayerCtrl = HWPlayerController(PlayerOwner);
		PlayerCam = HWCamera(HWPlayerCtrl.PlayerCamera);	

		// cull all selectables
		CanvasTo.X = Canvas.SizeX;
		CanvasTo.Y = Canvas.SizeY;

		foreach AllActors(class'HWSelectable', s)
		{
			s.bCulled = vIsBetween(Canvas.Project(s.Location), CanvasFrom, CanvasTo);
		}

		// deproject the 2D mouse coordinates into 3D world
		Canvas.DeProject(HWPlayerCtrl.MouseLocationScreen, MouseWorldOrigin, MouseWorldDirection);

		// calculate a trace from the player camera position...
		StartTrace = PlayerCam.ViewTarget.POV.Location;
	    
		// ... in direction of the deprojection of the mouse cursor...
		RayDir = MouseWorldDirection;

		// ... scaled by 5000...
		EndTrace = StartTrace + RayDir * 5000;

		// ... and remember the first actor hit
		HWPlayerCtrl.TraceActor = Trace(TempHitLocation, TempHitNormal, EndTrace, StartTrace, true);

		// do a 2nd trace with level geometry only and set HWPlayerCtrl.MouseLocationWorld
		Trace(HWPlayerCtrl.MouseLocationWorld, TempHitNormal, EndTrace, StartTrace, false);

		// Pawn(PlayerOwner.ViewTarget) might be None on client on early game start up
		if (bDrawRoutes && Pawn(PlayerOwner.ViewTarget) != None)
		{
			super.DrawRoute(Pawn(PlayerOwner.ViewTarget));
		}

		// check whether the user changed the window size - required for scrolling for example
		HWPlayerCtrl.ViewportSize.X = Canvas.SizeX;
		HWPlayerCtrl.ViewportSize.Y = Canvas.SizeY;

		// can use Canvas for projection here only, as it is None everywhere else;
		// so selection logic has to be done here :/ RTSFramework does it here, too...
		if (HWPlayerCtrl.bShouldUpdateSelection || HWPlayerCtrl.bLeftMouseDoubleClick)
		{
			// don't select new units while choosing a target for an ability
			if (!bChoosingTarget)
			{
				s = HWSelectable(HWPlayerCtrl.TraceActor);

				// clear selection
				if (!HWPlayerCtrl.bShiftSelecting)
				{
					HWPlayerCtrl.ClearSelection();
				}
				
				// double click selection
				if(HWPlayerCtrl.bLeftMouseDoubleClick)
				{
					// select all objects of the same class as the traced object, and are owned by the corresponding controller
					SelectByClass(HWPlayerCtrl, s);
				}
				// group or single click selection
				else
				{
					// check if the distance between the mouse cursor's location, from mouse click to mouse release, is big enough to do a group selection
					selectionDistanceVector = HWPlayerCtrl.GroupSelectionStart - HWPlayerCtrl.MouseLocationScreen;
					selectionDistance = Sqrt(selectionDistanceVector.X * selectionDistanceVector.X + selectionDistanceVector.Y * selectionDistanceVector.Y);

					// select new units by box
					if(selectionDistance >= GROUP_SELECTION_DISTANCE_THRESHOLD)
					{
						foreach AllActors(class'HWSelectable', s)
						{
							TrySelect(HWPlayerCtrl, s);
						}
					}
					
					// select the currently traced actor if not already selected or hidden:
					// this causes single unit selection if selectionDistance < GROUP_SELECTION_DISTANCE_THRESHOLD
					// and selects a missed unit under the bottom right corner of the spanned selection.					
					if (s != none)
					{	
						if (s.SelectedBy == none)
						{
							s.Select(HWPlayerCtrl);
						}
						else
						{
							if (HWPlayerCtrl.bShiftSelecting)
							{
								s.Deselect();
							}
						}
					}
				}

				HWPlayerCtrl.NotifySelectionChanged();

				// play the Selected sound of the new strongest selected unit
				// This is not moved to the NotifySelectionChanged method as that method has too many return paths.
				if (HWPlayerCtrl.StrongestSelectedUnit != none)
				{
					HWPlayerCtrl.ClientPlayVoiceUnit(HWPlayerCtrl.StrongestSelectedUnit, HWPlayerCtrl.StrongestSelectedUnit.SoundSelected);
				}
			}
		}

		// draw the minimap
		if (PlayerOwner.IsInState('PlayerWalking') && Minimap != none)
		{
			GFxHUD_MinimapMC.Update();
		}

		// draw health bars above the heads of all selected units
		DrawHealthBars();

		// draw player name
		DrawPlayerName();

		// draw level up effects
		DrawLevelUpEffects();

		// draw text up effects
		DrawTextUpEffects();
		
		// update AoE mouse cursor location
		MouseCursorAOE.SetLocation(HWPlayerCtrl.MouseLocationWorld);

		// --- seems to be the last function call each frame; clear all flags ---
		HWPlayerCtrl.bShouldUpdateSelection = false;
		HWPlayerCtrl.bLeftMouseDoubleClick = false;

		if (bStopChoosingTargetNextFrame)
		{
			StopChoosingTarget();
			bStopChoosingTargetNextFrame = false;
		}
	}
}

/** Draws health bars above the heads of all selected or visible units. */
function DrawHealthBars()
{
	local HWPlayerController Player;
	local HWCamera Camera;
	local HWSelectable Selectable;
	local HWPawn P;
	
	// get the local player
	Player = HWPlayerController(PlayerOwner);

	if (Player.GetPlayerSettings().bAlwaysShowHealthBars || bShowHealthBars)
	{
		// check whether player has already logged out
		Camera = HWCamera(Player.PlayerCamera);

		if (Camera != none)
		{
			foreach DynamicActors(class'HWSelectable', Selectable)
			{
				// skip cloaked enemy pawns
				if(HWPawn(Selectable) != none)
				{
					P = HWPawn(Selectable);
					if(P.OwningPlayer != Player && p.bCloaked)
					{
						continue;
					}
				}

				// iterate all visible units
				if (!Selectable.bHidden 
					&& Selectable.bCulled 
					&& Selectable.Health > 0 
					&& Selectable.bShowHealthbar)
				{
					DrawHealthBarFor(HWPawn(Selectable));
				}
			}
		}
	}
	else
	{
		// iterate all selected units
		foreach Player.SelectedUnits(Selectable)
		{
			DrawHealthBarFor(HWPawn(Selectable));
		}
	}
}

/** Draws the name of the owning player above the head of the unit currently hovered. */
function DrawPlayerName()
{
	local HWPlayerController Player;
	local HWPawn Unit;

	local Vector PlayerNameLocation3D;
	local Vector PlayerNameLocation2D;

	local string PlayerName;
	local float TextLengthX;
	local float TextLengthY;

	// get the local player
	Player = HWPlayerController(PlayerOwner);

	// get the hovered unit
	Unit = HWPawn(Player.TraceActor);

	if (Unit != none && !Unit.bHidden && Unit.OwningPlayerRI != none)
	{
		// project the unit's location into screen space
		PlayerNameLocation3D = Unit.Location;
		PlayerNameLocation3D.Z += Unit.CylinderComponent.CollisionHeight;
		PlayerNameLocation2D = Canvas.Project(PlayerNameLocation3D);

		// move the player name a little above the unit's head
		PlayerNameLocation2D.Y -= PLAYER_NAME_OFFSET;

		// center player name
		PlayerName = Unit.OwningPlayerRI.PlayerName;

		Canvas.TextSize(PlayerName, TextLengthX, TextLengthY);

		PlayerNameLocation2D.X -= TextLengthX / 2;
		PlayerNameLocation2D.Y -= TextLengthY / 2;

		// draw player name
		Canvas.DrawColor = WhiteColor;
		Canvas.SetPos(PlayerNameLocation2D.X, PlayerNameLocation2D.Y);
		Canvas.DrawText(PlayerName);
	}	
}

/** 
 * Draws a health bar above the specified unit, and an additional shield bar
 * if it's a squad member.
 * 
 * @param Unit
 *      the unit to draw the health bar for
 */
function DrawHealthBarFor(HWPawn Unit)
{
	local HWSquadMember SquadMember;

	local Vector HealthBarLocation3D;
	local Vector HealthBarLocation2D;

	local float HealthPercentage;
	local int HealthBarWidth;

	if (Unit != none)
	{
		// project the unit's location into screen space
		HealthBarLocation3D = Unit.Location;
		HealthBarLocation3D.Z += Unit.CylinderComponent.CollisionHeight;
		HealthBarLocation2D = Canvas.Project(HealthBarLocation3D);

		// move the health bar a little above the unit's head
		HealthBarLocation2D.Y -= HEALTH_BAR_OFFSET;

		// comute top-left corner of the health bar
		HealthBarLocation2D.X -= HEALTH_BAR_WIDTH / 2;
		HealthBarLocation2D.Y -= HEALTH_BAR_HEIGHT / 2;

		// draw white border
		Canvas.DrawColor = MakeColor(255, 255, 255, 255);
		Canvas.SetPos(HealthBarLocation2D.X, HealthBarLocation2D.Y);
		Canvas.DrawRect(HEALTH_BAR_WIDTH, HEALTH_BAR_HEIGHT);

		// draw health bar
		HealthBarWidth = HEALTH_BAR_WIDTH - 2 * HEALTH_BAR_BORDER_WIDTH;
		HealthPercentage = float(Unit.Health) / float(Unit.HealthMax);

		Canvas.DrawColor = GetHealthColor(Unit);
		Canvas.SetPos
			(HealthBarLocation2D.X + HEALTH_BAR_BORDER_WIDTH,
			 HealthBarLocation2D.Y + HEALTH_BAR_BORDER_WIDTH);
		Canvas.DrawRect
			(Round(HealthBarWidth * HealthPercentage),
			 HEALTH_BAR_HEIGHT - 2 * HEALTH_BAR_BORDER_WIDTH);

		// check whether we have to draw a shield bar, too...
		SquadMember = HWSquadMember(Unit);

		if (SquadMember != none)
		{
			// draw shield bar above the health bar
			HealthBarLocation2D.Y -= HEALTH_BAR_HEIGHT;

			// draw white border again
			Canvas.DrawColor = MakeColor(255, 255, 255, 255);
			Canvas.SetPos(HealthBarLocation2D.X, HealthBarLocation2D.Y);
			Canvas.DrawRect(HEALTH_BAR_WIDTH, HEALTH_BAR_HEIGHT);

			// draw shield bar
			HealthPercentage = float(SquadMember.ShieldsCurrent) / float(SquadMember.ShieldsMax);
			HealthBarWidth = HEALTH_BAR_WIDTH - 2 * HEALTH_BAR_BORDER_WIDTH;

			Canvas.DrawColor = MakeColor(0, 0, 255, 255);
			Canvas.SetPos
				(HealthBarLocation2D.X + HEALTH_BAR_BORDER_WIDTH,
				 HealthBarLocation2D.Y + HEALTH_BAR_BORDER_WIDTH);
			Canvas.DrawRect
				(Round(HealthBarWidth * HealthPercentage),
				 HEALTH_BAR_HEIGHT - 2 * HEALTH_BAR_BORDER_WIDTH);

			if (SquadMember.DismissTimeRemaining > 0)
			{
				// draw dismiss bar
				HealthBarLocation2D.Y -= HEALTH_BAR_HEIGHT;

				Canvas.DrawColor = MakeColor(255, 255, 255, 255);
				Canvas.SetPos(HealthBarLocation2D.X, HealthBarLocation2D.Y);
				Canvas.DrawRect(HEALTH_BAR_WIDTH, HEALTH_BAR_HEIGHT);

				HealthPercentage = SquadMember.DismissTimeRemaining / class'HWSquadMember'.const.DISMISS_TIME;

				Canvas.DrawColor = MakeColor(128, 128, 128, 255);
				Canvas.SetPos
					(HealthBarLocation2D.X + HEALTH_BAR_BORDER_WIDTH,
					 HealthBarLocation2D.Y + HEALTH_BAR_BORDER_WIDTH);
				Canvas.DrawRect
					(Round(HealthBarWidth * HealthPercentage),
					 HEALTH_BAR_HEIGHT - 2 * HEALTH_BAR_BORDER_WIDTH);
			}
		}
	}
}

/** 
 * Returns a color for representing the current health of the passed unit.
 * The lower the health, the more the color turns red.
 * 
 * @param Unit
 *      the unit to get a color for
 */
function Color GetHealthColor(HWPawn Unit)
{
	local float HealthPercentage;
	local Color HealthColor;

	// compute the health percentage of the passed unit
	HealthPercentage = float(Unit.Health) / float(Unit.HealthMax);

	// the lower the health, the more the color turns red
	HealthColor.R = Round((1.0f - HealthPercentage) * 255);
	HealthColor.G = Round(HealthPercentage * 255);
	HealthColor.B = 0;
	HealthColor.A = 255;

	return HealthColor;
}

/**
 * Adds a level-up effect to be drawn for the specified squad member.
 * 
 * @param SquadMember
 *      the squad member that has been promoted
 */
function AddLevelUpEffectFor(HWSquadMember SquadMember)
{
	local SLevelUpEffect LevelUpEffect;

	LevelUpEffect.SquadMember = SquadMember;
	LevelUpEffect.Level = SquadMember.Level;
	
	LevelUpEffects.AddItem(LevelUpEffect);
}

/** Draws all level-up effects, making them fly upwards and fade away. */
function DrawLevelUpEffects()
{
	local int i;

	for (i = 0; i < LevelUpEffects.Length; i++)
	{
		DrawLevelUpEffect(LevelUpEffects[i]);

		LevelUpEffects[i].Progress++;

		if (LevelUpEffects[i].Progress > LevelUpEffectDuration)
		{
			LevelUpEffects.Remove(i, 1);
			i--;
		}
	}
}

/** Draws all text effects, making them fly upwards and fade away. */
function DrawTextUpEffects()
{
	local int i;

	for (i = 0; i < TextUpEffects.Length; i++)
	{
		DrawTextUpEffect(TextUpEffects[i]);

		TextUpEffects[i].Progress++;

		if (TextUpEffects[i].Progress > TextUpEffectDuration)
		{
			TextUpEffects.Remove(i, 1);
			i--;
		}
	}
}

/**
 * Draws the specified level-up effect.
 * 
 * @param LevelUpEffect
 *      the effect to draw
 */
function DrawLevelUpEffect(SLevelUpEffect LevelUpEffect)
{
	local Vector LevelUpEffectLocation3D;
	local Vector LevelUpEffectLocation2D;
	local byte Alpha;

	// project the unit's location into screen space
	LevelUpEffectLocation3D = LevelUpEffect.SquadMember.Location;
	LevelUpEffectLocation3D.Z += LevelUpEffect.SquadMember.CylinderComponent.CollisionHeight;
	LevelUpEffectLocation2D = Canvas.Project(LevelUpEffectLocation3D);

	// move the level-up effect next to the unit and make it "fly" upwards
	LevelUpEffectLocation2D.X += LEVELUP_EFFECT_OFFSET;
	LevelUpEffectLocation2D.Y -= LevelUpEffect.Progress / 2;

	// draw level-up effect
	Alpha = (1.0f - float(LevelUpEffect.Progress) / float(LevelUpEffectDuration)) * 255;

	Canvas.DrawColor = MakeColor(255, 255, 255, Alpha);
	Canvas.SetPos(LevelUpEffectLocation2D.X, LevelUpEffectLocation2D.Y);
	Canvas.DrawTexture(LevelUpGraphics[LevelUpEffect.Level], 1.0f);
}

/**
 * Draws the specified text-up effect.
 * 
 * @param TextUpEffect
 *      the effect to draw
 */
function DrawTextUpEffect(STextUpEffect TextUpEffect)
{
	local Vector TextUpEffectLocation2D;

	// project the unit's location into screen space
	TextUpEffectLocation2D = Canvas.Project(TextUpEffect.Location);

	// make the text-up effect "fly" upwards
	TextUpEffectLocation2D.Y -= TextUpEffect.Progress / 2;

	// fade out
	TextUpEffect.Color.A = (1.0f - float(TextUpEffect.Progress) / float(TextUpEffectDuration)) * 255;	

	// draw text-up effect
	if(TextUpEffect.Scale.X != 0 && TextUpEffect.Scale.Y != 0)
	{
		DrawCanvasText(TextUpEffect.Text, TextUpEffectLocation2D.X, TextUpEffectLocation2D.Y, TextUpEffect.Color, TextUpEffect.Scale.X, TextUpEffect.Scale.Y);
	}
	else
	{
		DrawCanvasText(TextUpEffect.Text, TextUpEffectLocation2D.X, TextUpEffectLocation2D.Y, TextUpEffect.Color);
	}
}

/** Helper function which wraps all function calls required to draw the given text on the canvas. */
function DrawCanvasText(string Text, float PosX, float PosY, Color TextColor, optional float ScaleX = 1.0, optional float ScaleY = 1.0)
{
	local float TextLengthX, TextLengthY;

	Canvas.TextSize(Text, TextLengthX, TextLengthY);
	Canvas.SetPos(PosX - (TextLengthX / 2), PosY - (TextLengthY / 2));
	Canvas.DrawColor = TextColor;
    Canvas.DrawText(Text, false, ScaleX, ScaleY);
}

/**
 * Compares the selection box coordinates of the passed player with the
 * coordinates of the specified selectable object. If the object is within
 * the selection box, it is selected by the player.
 * 
 * @param Player
 *      the player who wants to select the object
 * @param s
 *      the object to check
 */
function TrySelect(HWPlayerController Player, HWSelectable s)
{
	if (vIsBetween(Canvas.Project(s.Location), Player.GroupSelectionStart, Player.MouseLocationScreen))
	{
		s.Select(Player);
	}
}

/** 
 *  Selects all HWSelectables of the same class and team as the given HWSelectable, 
 *  whose projected location is inside the canvas and are not hidden.
 *   
 *  @param Player
 *       the player who wants to select the object
 *  @param s
 *       the reference HWSelectable
 */
function SelectByClass(HWPlayerController Player, HWSelectable s)
{
	local HWSelectable sCurrent;
	local Vector2D vectorA, vectorB;
	
	if(Player == none || s == none || s.bHidden)
	{
		return;
	}

	vectorB.X = Canvas.SizeX;
	vectorB.Y = Canvas.SizeY;

	foreach AllActors(class'HWSelectable', sCurrent)
	{
		if(    sCurrent.Class == s.Class 
			&& sCurrent.TeamIndex == s.TeamIndex
			&& vIsBetween(Canvas.Project(sCurrent.Location), vectorA, vectorB))
		{
			sCurrent.Select(Player);
		}
	}
}

/**
 * Checks whether the first point is contained by the rectangle that is spanned by the
 * points A and B.
 * 
 * @param checkVector
 *      the point to check
 * @param vectorA
 *      one corner of the rectangle to span
 * @param vectorB
 *      the second corner of the rectangle to span
 */
function bool vIsBetween(Vector checkVector, Vector2D vectorA, Vector2D vectorB) 
{
	return (checkVector.X > fMin(vectorA.X, vectorB.X) && checkVector.X < fMax(vectorA.X, vectorB.X) &&
			checkVector.Y > fMin(vectorA.Y, vectorB.Y) && checkVector.Y < fMax(vectorA.Y, vectorB.Y));
}

/** 
 *  Makes the HUD draw the specified error message for a short time.
 *  
 *  @param Msg
 *      the error message to show
 */
function ShowErrorMessage(string Msg)
{
	ErrorMessage = Msg;
	SetTimer(DURATION_ERROR_MESSAGES, false, 'HideErrorMessage');
}

/** Hides the current error message. */
function HideErrorMessage()
{
	ErrorMessage = "";
}

/** 
 *  Makes the HUD draw the specified status message for a short time.
 *  
 *  @param Msg
 *      the status message to show
 */
function ShowStatusMessage(string Msg, int duration)
{
	StatusMessage = Msg;
	SetTimer(duration, false, 'HideStatusMessage');
}

/** Hides the current status message. */
function HideStatusMessage()
{
	StatusMessage = "";
}

/**
 * Draws the specified choose target message and ignores further unit selections.
 * 
 * @param Msg
 *      the message to show
 */
function StartChoosingTarget(string Msg)
{
	ChooseTargetMessage = Msg;
	bChoosingTarget = true;
}

/** Hides the current choose target message and allows unit selection again. */
function StopChoosingTarget()
{
	ChooseTargetMessage = "";
	bChoosingTarget = false;

	bShowingAOEMouseCursor = false;
	MouseCursorAOE.SetHidden(true);

	SetSpawnPointsVisible(false);

	// hide all error messages that might have occured while choosing a target
	HideErrorMessage();
}

/**
 * Shows or hides spawn points where players can respawn their commanders.
 * 
 * @param bVisible
 *      whether the spawn points should be visible, or not
 */
function SetSpawnPointsVisible(bool bVisible)
{
	local HWSpawnPoint SpawnPoint;

	foreach AllActors(class'HWSpawnPoint', SpawnPoint)
	{
		SpawnPoint.SpawnArea.SetHidden(!bVisible);
	}
}

/** 
 *  Hides the current choose target message and allows unit selection again in
 *  the next frame. This is required due to a timing problem that causes the
 *  chosen target to become selected immediately otherwise.
 */
function StopChoosingTargetNextFrame()
{
	bStopChoosingTargetNextFrame = true;
}

/**
 * Notifies this HUD that it should update itself because the commander of the
 * local player has died or respawned.
 * 
 * @param bAlive
 *      whether the commander of the local player is alive
 */
function NotifyCommanderAlive(bool bAlive)
{
	if (GFxHUD_CommandWindowMC != none)
	{
		GFxHUD_CommandWindowMC.NotifyCommanderAlive(bAlive);
	}
}

/** Updates this HUD based on the current selection of the local player. */
function Update()
{
	GFxHUD_AbilitiesMC.Update();
	GFxHUD_StatusWindowMC.Update();
	GFxHUD_CommandWindowMC.Update();
}

/** Updates the status window of this HUD based on the current selection of the local player. */
function UpdateStatusWindow()
{
	if (GFxHUD_StatusWindowMC != none)
	{
		GFxHUD_StatusWindowMC.Update();
	}
}

/**
 * Updates the scores window of this HUD.
 * 
 * @param Team1Score
 *      the current score of team 1
 * @param Team2Score
 *      the current score of team 2
 * @param ScoreLimit
 *      the score limit of the current match
 */
function UpdateScores(int Team1Score, int Team2Score, int ScoreLimit)
{
	GFxHUD_VictoryPointsMC.Update(Team1Score, Team2Score, ScoreLimit);
}

/** Updates the shards, squad members and game clock of the info bar of this HUD, and again in a second. */
function UpdateInfoBar()
{
	GFxHUD_InfoBarMC.Update();

	SetTimer(WorldInfo.TimeDilation, true, 'UpdateInfoBar');
}

/**
 * Adds the passed text sent by the player with the specified name to this
 * player's chat log.
 * 
 * @param SendingPlayerName
 *      the name of the player who sent the message
 * @param Text
 *      the text of the message sent
 */
function UpdateChatLog(string SendingPlayerName, string Text)
{
	GFxHUD_ChatLogMC.Update(SendingPlayerName, Text);
}

/** Shows the chat log with all messages received by this player. */
function ShowChatLog()
{
	GFxHUD_ChatLogMC.Start();
}

/**
 * Changes the tooltip shown next to the command window. Supports basic HTML.
 * 
 * @param Tooltip
 *      the new tooltip to show
 */
function ShowTooltip(string Tooltip)
{
	GFxHUD_CommandWindowMC.ShowTooltip(Tooltip);
}

/** Clears the tooltip shown next to the command window. */
function ClearTooltip()
{
	GFxHUD_CommandWindowMC.ClearTooltip();
}

/**
 * Formats the passed float, returning a string with the specified number
 * of decimals.
 * 
 * Idea taken from http://www.ataricommunity.com/forums/showthread.php?t=342899
 * 
 * @param f
 *      the float to format
 * @param Precision
 *      the number of decimals to show
 */
function static string FloatToString(float f, optional int Precision)
{
	local int i;

	i = int(f);

	if (f - i == 0)
	{
		return string(i);
	}

	if (Precision < 1)
	{
		Precision = 1;
	}

	return string(i)$"."$left(mid(string(f - i), 2), Precision);
}

/**
 * Returns a hex representation of the passed byte.
 * 
 * @param b
 *      the byte to get a hex representation of
 */
function string ByteToHex(byte b)
{
	local string Hex;
	local byte HexDigits[2];
	local int i;

	Hex = "";
	HexDigits[0] = b / 16;
	HexDigits[1] = b % 16;

	for (i = 0; i < 2; i++)
	{
		if (HexDigits[i] < 10)
		{
			Hex $= string(HexDigits[i]);
			continue;
		}

		switch (HexDigits[i])
		{
			case 10:
				Hex $= "A";
				break;
			case 11:
				Hex $= "B";
				break;
			case 12:
				Hex $= "C";
				break;
			case 13:
				Hex $= "D";
				break;
			case 14:
				Hex $= "E";
				break;
			case 15:
				Hex $= "F";
				break;
			default:
				Hex $= "X";
				break;
		}
	}

	return Hex;
}

/**
 * Surrounds the passed string with highlighting HTML markup.
 * 
 * @param s
 *      the string to highlight
 */
simulated static function string HTMLMarkup(coerce string s)
{
	return "<b><font color=\"#FFFF00\">"$s$"</font></b>";
}

simulated function Reset()
{
	super.Reset();

	bDrawRoutes = false;
	bShowHealthBars = false;
	StatusMessage = "";
	ErrorMessage = "";
	ChooseTargetMessage = "";
	bChoosingTarget = false;
	bStopChoosingTargetNextFrame = false;
}

DefaultProperties
{
	bDrawRoutes=true

	CursorTexture=Texture2D'UI_HWMisc.T_UI_CursorStandard_Test'
	ChooseTargetCursorTexture=Texture2D'UI_HWMisc.T_UI_CursorChooseTarget_Test'

	ColorCommanderDead=(R=255,G=0,B=0,A=255);

	LevelUpEffectDuration=120
	
	LevelUpGraphics(1)=Texture2D'UI_HWMisc.T_UI_LevelUp1_Test'
	LevelUpGraphics(2)=Texture2D'UI_HWMisc.T_UI_LevelUp2_Test'
	LevelUpGraphics(3)=Texture2D'UI_HWMisc.T_UI_LevelUp3_Test'
	LevelUpGraphics(4)=Texture2D'UI_HWMisc.T_UI_LevelUp4_Test'

	TextUpEffectDuration=120
}
