/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTGameObjective extends UDKGameObjective
	abstract
	hidecategories(VehicleUsage);

var		bool	bAlreadyRendered;

/** Allow use if player is within Pawn's VehicleCheckRadius */
var		bool	bAllowRemoteUse;

var		byte			StartTeam;

/* Nodes with Higher DefensePriority are defended first */
var(Objective)	byte			DefensePriority;

var UTSquadAI		DefenseSquad;	// squad defending this objective;
var	UTDefensePoint	DefensePoints;

var(Objective)	localized String	ObjectiveName;

/** bots in vehicles should go to one of these and then proceed on foot */
var() array<NavigationPoint> VehicleParkingSpots;
var() Volume				MyBaseVolume;
var() float							BaseRadius;

// Score sharing
struct native ScorerRecord
{
	var UTPlayerReplicationInfo PRI;
	var float		Pct;
};
var array<ScorerRecord>	Scorers;

var		int		Score;				// score given to player that completes this objective

var		bool				bFirstObjective;		// First objective in list of objectives defended by same team
var		UTGameObjective		NextObjective;			// list of objectives defended by the same team

var LinearColor ControlColor[3];

var TextureCoordinates AttackCoords;

var float IconPosX, IconPosY;
var float IconExtentX, IconExtentY;
var Material HudMaterial;

var bool bHasSensor;
var float MaxSensorRange;
var float CameraViewDistance;				/** distance away for camera when viewtarget */

var array<UTVehicleFactory> VehicleFactories;

/** true when in the constructing state */
var bool bIsConstructing;

/** true when in the disabled state */
var bool bIsDisabled;

/** true when in the active state */
var bool bIsActive;

var array<PlayerStart> PlayerStarts;

/** list of teamskinned static meshes that we should notify when our team changes */
var array<UTTeamStaticMesh> TeamStaticMeshes;

/** announcement to use when directing a player to attack this objective */
var(Announcements) ObjectiveAnnouncementInfo AttackAnnouncement;
/** announcement to use when directing a player to defend this objective */
var(Announcements) ObjectiveAnnouncementInfo DefendAnnouncement;

/** Used for highlighting on minimap */
var float HighlightScale;

var float MaxHighlightScale;

var float HighlightSpeed;

var float MinimapIconScale;

var float LastHighlightUpdate;

/** Last time trace test check for drawing postrender beacon was performed */
var float LastPostRenderTraceTime;

/** true is last trace test check for drawing postrender beacon succeeded */
var bool bPostRenderTraceSucceeded;

/** Max distance for drawing beacon for non-critical objective */
var float MaxBeaconDistance;

var bool bHasLocationSpeech;

var(VoiceMessage) Array<SoundNodeWave> LocationSpeech;

var LinearColor AttackLinearColor;

var bool bScriptRenderAdditionalMinimap;

simulated function PostBeginPlay()
{
	local UTGameObjective O, CurrentObjective;
	local PlayerController PC;
	local int i;

	super.PostBeginPlay();
	StartTeam = DefenderTeamIndex;

	// add to objective list
	if ( bFirstObjective )
	{
		CurrentObjective = Self;
		//@note: we have to use AllActors here so if paths haven't been rebuilt we don't get multiple objectives executing this code
		foreach AllActors(class'UTGameObjective', O)
		{
			if (O != self)
			{
				CurrentObjective.NextObjective = O;
				O.bFirstObjective = false;
				CurrentObjective = O;
			}
		}
	}

	if ( Role == Role_Authority )
	{
		StartTeam	= DefenderTeamIndex;

		// find defensepoints
		ForEach WorldInfo.AllNavigationPoints(class'UTDefensePoint', DefensePoints)
			if ( DefensePoints.bFirstScript && (DefensePoints.DefendedObjective == self) )
				break;

		// find AreaVolume
		if ( MyBaseVolume != None )
		{
			MyBaseVolume.AssociatedActor = Self;
		}
	}

	// add to local HUD's post-rendered list
	ForEach LocalPlayerControllers(class'PlayerController', PC)
		if ( PC.MyHUD != None )
			PC.MyHUD.AddPostRenderedActor(self);

	// clear out any empty parking spot entries
	while (i < VehicleParkingSpots.length)
	{
		if (VehicleParkingSpots[i] == None)
		{
			VehicleParkingSpots.Remove(i, 1);
		}
		else
		{
			i++;
		}
	}
}

simulated function bool IsStandalone()
{
	return false;
}

simulated function vector GetHUDOffset(PlayerController PC, Canvas Canvas)
{
	local float Z;

	Z = 460;
	if ( PC.ViewTarget != None )
	{
		Z += 0.1 * VSize(PC.ViewTarget.Location - Location);
	}

	return Z*vect(0,0,1);
}

simulated function int GetLocationMessageIndex(UTBot B, Pawn StatusPawn)
{
	return 0;
}

simulated function SoundNodeWave GetLocationSpeechFor(PlayerController PC, int LocationSpeechOffset, int MessageIndex)
{
	return (LocationSpeechOffset < LocationSpeech.Length) ? LocationSpeech[LocationSpeechOffset] : None;
}

/** @return the actor that the given player should use to complete this objective */
function Actor GetAutoObjectiveActor(UTPlayerController PC)
{
	return self;
}

simulated function Destroyed()
{
	local PlayerController PC;

	Super.Destroyed();

	// remove from local HUD's post-rendered list
	ForEach LocalPlayerControllers(class'PlayerController', PC)
		if ( PC.MyHUD != None )
			PC.MyHUD.RemovePostRenderedActor(self);
}

/** adds the given team static mesh to our list and initializes its team */
simulated function AddTeamStaticMesh(UTTeamStaticMesh SMesh)
{
	TeamStaticMeshes[TeamStaticMeshes.length] = SMesh;
	SMesh.SetTeamNum(DefenderTeamIndex);
}

/** updates TeamStaticMeshes array for a change in our team */
simulated function UpdateTeamStaticMeshes()
{
	local int i;

	for (i = 0; i < TeamStaticMeshes.length; i++)
	{
		TeamStaticMeshes[i].SetTeamNum(DefenderTeamIndex);
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'DefenderTeamIndex')
	{
		UpdateTeamStaticMeshes();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/** FindNearestFriendlyNode()
returns nearest node at which team can spawn
*/
function UTGameObjective FindNearestFriendlyNode(int TeamIndex)
{
	return None;
}

function bool UsedBy(Pawn P)
{
	return false;
}

/**
 *	Calculate camera view point, when viewing this actor.
 *
 * @param	fDeltaTime	delta time seconds since last update
 * @param	out_CamLoc	Camera Location
 * @param	out_CamRot	Camera Rotation
 * @param	out_FOV		Field of View
 *
 * @return	true if Actor should provide the camera point of view.
 */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector HitNormal, DesiredCamLoc;

	DesiredCamLoc = Location - vector(out_CamRot) * CameraViewDistance;
	if ( Trace(out_CamLoc, HitNormal, DesiredCamLoc, Location, false,vect(12,12,12)) == None )
	{
		out_CamLoc = DesiredCamLoc;
	}

	return false;
}

simulated function HighlightOnMinimap(int Switch)
{
	if ( HighlightScale < 1.25 )
	{
		HighlightScale = MaxHighlightScale;
		LastHighlightUpdate = WorldInfo.TimeSeconds;
	}
}

/**
  * Called if bScriptRenderAdditionalMinimap=true
  */
simulated event RenderMinimap( UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, float ColorPercent );

/**
  * Called if rendering full size map
  */
simulated function RenderExtraDetails( UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, float ColorPercent, bool bSelected )
{
	if (bSelected)
	{
		DrawMapSelection(MP,Canvas,PlayerOwner);
	}
}

simulated function DrawMapSelection( UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner )
{
	Canvas.SetPos(HUDLocation.X - 12 * MP.MapScale, HUDLocation.Y - 12 * MP.MapScale * Canvas.ClipY / Canvas.ClipX);
	Canvas.SetDrawColor(255,255,0,255);
	Canvas.DrawTile(class'UTHUD'.default.AltHudTexture,25*MP.MapScale,25*MP.MapScale,273,494,12,13);
}

/** @Returns true if this objective is critical and needs immediate attention */
simulated event bool IsCritical()
{
	return false;
}

simulated function bool IsNeutral()
{
	return false;
}

simulated event bool IsActive()
{
	return false;
}

function bool Shootable()
{
	return false;
}

function bool TellBotHowToHeal(UTBot B)
{
	return false;
}

simulated function bool TeamLink(int TeamNum)
{
	return false;
}

simulated function bool NeedsHealing()
{
	return false;
}

function bool CanDoubleJump(Pawn Other)
{
	return true;
}

function bool BotNearObjective(AIController C)
{
	local UTBot B;
	
	B = UTBot(C); // FIXMESTEVE!!! UDKBot should be passed in param
	if ( NearObjective(B.Pawn)
		|| ((B.RouteGoal == self) && (B.RouteDist < 2500))
		|| (B.bWasNearObjective && (VSize(Location - B.Pawn.Location) < BaseRadius)) )
	{
		B.bWasNearObjective = true;
		return true;
	}

	B.bWasNearObjective = false;
	return false;
}

function bool NearObjective(Pawn P)
{
	if (MyBaseVolume != None)
	{
		return P.IsInVolume(MyBaseVolume);
	}
	else
	{
		return (VSize(Location - P.Location) < BaseRadius && P.LineOfSightTo(self));
	}
}

simulated function string GetHumanReadableName()
{
	return ObjectiveName;
}

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(UTBot B)
{
	return UTSquadAI(B.Squad).FindPathToObjective(B,self);
}

function int GetNumDefenders()
{
	if ( DefenseSquad == None )
		return 0;
	return DefenseSquad.GetSize();
	// FIXME - max defenders per defensepoint, when all full, report big number
}

function bool BetterObjectiveThan(UTGameObjective Best, byte DesiredTeamNum, byte RequesterTeamNum)
{
	if ( bIsDisabled || (DefenderTeamIndex != DesiredTeamNum) )
		return false;

	if ( (Best == None) || (Best.DefensePriority < DefensePriority) )
		return true;

	return false;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	super.Reset();

	DefenseSquad		= None;
	DefenderTeamIndex	= StartTeam;
	Scorers.Length		= 0;
	bForceNetUpdate = TRUE;
}

/** called by UTPlayerController::ClientReset() when restarting level without reloading
 * performs any clientside only actions
 */
simulated function ClientReset();

// Score Sharing

/* Keep track of players who contributed in completing the objective to share the score */
function AddScorer( UTPlayerReplicationInfo PRI, float Pct )
{
	local ScorerRecord	S;
	local int			i;

	// Look-up existing entry
	if ( Scorers.Length > 0 )
		for (i=0; i<Scorers.Length; i++)
			if ( Scorers[i].PRI == PRI )
			{
				Scorers[i].Pct += Pct;
				return;
			}

	// Add new entry
	S.PRI		= PRI;
	S.Pct	= Pct;
	Scorers[Scorers.Length] = S;
}

/* Share score between contributors */
function ShareScore( int TotalScore, string EventDesc )
{
	local int	i;
	local float	SharedScore;

	for (i=0; i<Scorers.Length; i++)
	{
		if ( (Scorers[i].PRI == None) || Scorers[i].PRI.bDeleteMe )	// FIXME: obsolete player (left game)
			continue;

		//SharedScore = Round(float(TotalScore) * Scorers[i].Pct);
		SharedScore = float(TotalScore) * Scorers[i].Pct;
		if ( SharedScore > 0 )
		{
			Scorers[i].PRI.Score += SharedScore;
		}
	}
}

function SetTeam(byte TeamIndex)
{
	DefenderTeamIndex = TeamIndex;
	UpdateTeamStaticMeshes();
}


/** Used by PlayerController.FindGoodView() in RoundEnded State */
simulated function FindGoodEndView(PlayerController PC, out Rotator GoodRotation)
{
	local vector cameraLoc;
	local rotator cameraRot, ViewRotation;
	local int tries;
	local float bestdist, newdist, FOVAngle;

	ViewRotation = GoodRotation;
	ViewRotation.Pitch = 56000;
	tries = 0;
	bestdist = 0.0;
	for (tries=0; tries<16; tries++)
	{
		cameraLoc = Location;
		cameraRot = ViewRotation;
		CalcCamera( 0, cameraLoc, cameraRot, FOVAngle );
		newdist = VSize(cameraLoc - Location);
		if (newdist > bestdist)
		{
			bestdist = newdist;
			GoodRotation = cameraRot;
		}
		ViewRotation.Yaw += 4096;
	}
}

/**
 * Will attempt to teleport a pawn to this objective
 */

function bool TeleportTo(UTPawn Traveler)
{
	return false;
}

function bool ValidSpawnPointFor(byte TeamIndex)
{
    return ( (DefenderTeamIndex == TeamIndex) && !bUnderAttack );
}

/** returns the UTCarriedObject (if any) associated with this objective */
function UTCarriedObject GetFlag();

/** turns on or off the alarm sound played when under attack */
function SetAlarm(bool bNowOn);

/** triggers all UTSeqEvent_FlagEvent attached to this objective with the given flag event type */
function TriggerFlagEvent(name EventType, Controller EventInstigator)
{
	local UTSeqEvent_FlagEvent FlagEvent;
	local int i;

	for (i = 0; i < GeneratedEvents.length; i++)
	{
		FlagEvent = UTSeqEvent_FlagEvent(GeneratedEvents[i]);
		if (FlagEvent != None)
		{
			FlagEvent.Trigger(EventType, EventInstigator);
		}
	}
}

/** mark NavigationPoints the given Pawn can shoot this objective from as endpoints for pathfinding
 * this is so that the AI can figure out how to get in range of objectives that are shootable but not reachable
 */
simulated function MarkShootSpotsFor(Pawn P)
{
	local float Range;
	local int i;

	if (P.Weapon != None)
	{
		Range = P.Weapon.MaxRange();
		for (i = 0; i < ShootSpots.length; i++)
		{
			if (ShootSpots[i] != None && VSize(ShootSpots[i].Location - Location) < Range)
			{
				ShootSpots[i].bTransientEndPoint = true;
			}
		}
	}
}

/** returns whether the given Pawn has reached one of our VehicleParkingSpots */
function bool ReachedParkingSpot(Pawn P)
{
	local int i;

	for (i = 0; i < VehicleParkingSpots.length; i++)
	{
		if (P.ReachedDestination(VehicleParkingSpots[i]))
		{
			return true;
		}
	}

	return false;
}

defaultproperties
{
	bHasSensor=false
	Score=5
	BaseRadius=+2000.0
	bReplicateMovement=false
	bOnlyDirtyReplication=true
	bMustBeReachable=true
	bFirstObjective=true
	NetUpdateFrequency=1
	DefenderTeamIndex=2

	ControlColor(0)=(R=1,G=0,B=0,A=1)
	ControlColor(1)=(R=0,G=0,B=1,A=1)
	ControlColor(2)=(R=1,G=1,B=1,A=1)

	HudMaterial=Material'UI_HUD.Icons.M_UI_HUD_Icons01'
	MaxSensorRange=2800.0

	CameraViewDistance=400.0

	SupportedEvents.Add(class'UTSeqEvent_FlagEvent')

	MaxHighlightScale=8.0
	HighlightSpeed=10.0
	MinimapIconScale=20.0

	AttackCoords=(U=583,V=266,UL=52,VL=57)
	IconCoords=(U=537,V=296,UL=46,VL=31)
`if(`notdefined(MOBILE))
	IconHudTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseB'
`endif
	AttackLinearColor=(R=1.0,G=1.0,B=1.0,A=1.0)
}
