/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTCarriedObject extends UDKCarriedObject
	abstract 
	notplaceable
    dependson(UTPlayerController);

var bool			bLastSecondSave;
/** set when leaving Dropped state, to stop some of its state functions from doing anything during EndState() */
var bool bLeavingDroppedState;

/** Distance within which a bot can toss this to a player teammate */
var float		TossDistance;

var repnotify UTPlayerReplicationInfo HolderPRI;
var Pawn      Holder;

var float           TakenTime;
var float           MaxDropTime;
var Controller FirstTouch;			// Who touched this objective first
var array<Controller> Assists;		// Who touches it after

// HUD Rendering
var float MapSize;
var TextureCoordinates IconCoords;	/** Coordiates of the icon associated with this object */
var Texture2D IconTexture;

var name 	GameObjBone3P;       /**  Bone to which this carriedobject should be attached in third person */
var vector	GameObjOffset3P;     /**  Offset from attachment bone in third person */
var rotator	GameObjRot3P;        /**  Rotation from attachment bone in third person */
var vector GameObjOffset1P; /** Offset from holder Location in first person */
var rotator GameObjRot1P; /** Offset from holder Rotation in first person */

/** sound to play when we are picked up */
var SoundCue PickupSound;
/** sound to play when we are dropped */
var SoundCue DroppedSound;
/** sound to play when we are sent home */
var SoundCue ReturnedSound;

var Pawn 			OldHolder;
var PointLightComponent FlagLight;
var float			DefaultRadius, DefaultHeight;

/** announcements used when telling player to pick this object up */
var array<ObjectiveAnnouncementInfo> NeedToPickUpAnnouncements;

/** Used for highlighting on minimap */
var float HighlightScale;
var float MaxHighlightScale;
var float HighlightSpeed;
var float LastHighlightUpdate;

var bool bUseTeamColorForIcon;

/** Used by bots sending voice messages about enemy flag carrier */
var float LastFlagSeeTime;
var int LastSeeMessageIndex;

var LinearColor RedColor, BlueColor, GoldColor;

var ForceFeedbackWaveform PickUpWaveForm;

replication
{
    if (Role == ROLE_Authority)
		HolderPRI;
}

// Initialization
function PostBeginPlay()
{
    HomeBase = UTGameObjective(Owner);
    SetOwner(None);

    Super.PostBeginPlay();

	if ( CylinderComponent(CollisionComponent) != None )
	{
		DefaultRadius = CylinderComponent(CollisionComponent).CollisionRadius;
		DefaultHeight = CylinderComponent(CollisionComponent).CollisionHeight;
	}
}

/**
  * Called when player "uses" this flag
  * Return true if use had an effect
  */
function bool FlagUse(Controller C)
{
	return false;
}

/** returns true if should be rendered for passed in player */
simulated function bool ShouldMinimapRenderFor(PlayerController PC)
{
	return true;
}

simulated function HighlightOnMinimap(int Switch)
{
	if ( HighlightScale < 1.25 )
	{
		HighlightScale = MaxHighlightScale;
		LastHighlightUpdate = WorldInfo.TimeSeconds;
	}
}

simulated function Texture2D GetIconTexture()
{
	return class'UTHUD'.default.IconHudTexture;
}

simulated function DrawIcon(Canvas Canvas, vector IconLocation, float IconWidth, float IconAlpha)
{
	local float YoverX;
	local LinearColor DrawColor;

	if ( bUseTeamColorForIcon )
	{
		DrawColor = (Team.TeamIndex == 0) ? RedColor : BlueColor;
	}
	else
	{
		DrawColor = GoldColor;
	}
	DrawColor.A = IconAlpha;
	YoverX = IconCoords.VL / IconCoords.UL;
	Canvas.SetPos(IconLocation.X - 0.5 * IconWidth, IconLocation.Y - 0.5 * IconWidth * YoverX);
	Canvas.DrawTile(IconTexture, IconWidth, IconWidth * YoverX , IconCoords.U, IconCoords.V, IconCoords.UL, IconCoords.VL, DrawColor);
}

simulated function RenderMapIcon(UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner)
{
	local float CurrentScale;

	if ( HighlightScale > 1.0 )
	{
		CurrentScale = (WorldInfo.TimeSeconds - LastHighlightUpdate)/HighlightSpeed;
		HighlightScale = FMax(1.0, HighlightScale - CurrentScale * MaxHighlightScale);
		CurrentScale = HighlightScale;
	}
	else
	{
		CurrentScale = 1.0;
	}
	DrawIcon(Canvas, HUDLocation, IconCoords.UL * (Canvas.ClipY/720) * MapSize * CurrentScale, 1.0);

}

simulated function RenderEnemyMapIcon(UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, UTGameObjective NearbyObjective)
{
	local float YoverX,IconWidth;
	local float FlashScale, CurrentScale;
	local LinearColor DrawColor;

	FlashScale = 0.5*abs(cos(2*WorldInfo.TimeSeconds));
	DrawColor = (Team.TeamIndex == 0) ? RedColor : BlueColor;
	DrawColor.G = FlashScale;

	if ( HighlightScale > 1.0 )
	{
		CurrentScale = (WorldInfo.TimeSeconds - LastHighlightUpdate)/HighlightSpeed;
		HighlightScale = FMax(1.0, HighlightScale - CurrentScale * MaxHighlightScale);
		CurrentScale = HighlightScale;
	}
	else
	{
		CurrentScale = 1.0;
	}

	IconWidth = IconCoords.UL * (Canvas.ClipY/720) * MapSize * CurrentScale;
	YoverX = IconCoords.VL / IconCoords.UL;
	Canvas.SetPos(HudLocation.X - 0.5 * IconWidth, HudLocation.Y - 0.5 * IconWidth * YoverX);
	Canvas.DrawTile(IconTexture, IconWidth, IconWidth * YoverX , IconCoords.U, IconCoords.V, IconCoords.UL, IconCoords.VL, DrawColor);
}

// State transitions
function SetHolder(Controller C)
{
	local int i;
	local UTPlayerController PC;
	local UTBot B;
	local Controller OtherC;

	//`log(self$" setholder c="$c,, 'GameObject');
	LogTaken(c);
	Holder = C.Pawn;
	if ( UTPawn(Holder) != None )
	{
		UTPawn(Holder).DeactivateSpawnProtection();
	}
	HolderPRI = UTPlayerReplicationInfo(Holder.PlayerReplicationInfo);
	HolderPRI.SetFlag(self);
	HolderPRI.bForceNetUpdate = TRUE;
	LastFlagSeeTime = WorldInfo.TimeSeconds - 11;
	GotoState('Held');

	// AI Related
	C.MoveTimer = -1;
	Holder.MakeNoise(2.0);

	// update players and bots that were coming for this object
	PC = UTPlayerController(C);
	if (PC != None)
	{
		PC.CheckAutoObjective(true);

		PC.ClientPlayForceFeedbackWaveform(PickUpWaveForm);
	}
	foreach WorldInfo.AllControllers(class'Controller', OtherC)
	{
		PC = UTPlayerController(OtherC);
		if (PC != None)
		{
			if (PC.LastAutoObjective == self)
			{
				PC.CheckAutoObjective(true);
			}
		}
		else if (OtherC.MoveTarget == self || OtherC.MoveTarget == HomeBase || OtherC.RouteGoal == self || OtherC.RouteGoal == HomeBase)
		{
			B = UTBot(OtherC);
			if (B != None && B.Squad != None)
			{
				UTSquadAI(B.Squad).Retask(B);
			}
		}
	}

	// Track First Touch
	if (FirstTouch == None)
		FirstTouch = C;

	// Track Assists
	for (i=0;i<Assists.Length;i++)
		if (Assists[i] == C)
		  return;

	Assists.Length = Assists.Length+1;
  	Assists[Assists.Length-1] = C;

	SendFlagMessage(C);
}

function SendFlagMessage(Controller C)
{
	C.SendMessage(None, 'HOLDINGFLAG', 10);
}

function Score()
{
	GetKismetEventObjective().TriggerFlagEvent('Captured', Holder != None ? Holder.Controller : None);
	//`log(self$" score holder="$holder,, 'GameObject');

	// Don't return the flag if the game has ended
	if ( !WorldInfo.Game.bGameEnded )
	{
		Disable('Touch');
		SetLocation(HomeBase.Location + (HomeBaseOffset >> HomeBase.Rotation));
		SetRotation(HomeBase.Rotation);
		CalcSetHome();
		GotoState('Home');
	}
}

/** called to drop the flag
 */
function Drop(optional Controller Killer)
{
	local UTPlayerController PC;

	OldHolder = Holder;
	HomeBase.ObjectiveChanged();
	RotationRate.Yaw = Rand(200000) - 100000;
	RotationRate.Pitch = Rand(200000 - Abs(RotationRate.Yaw)) - 0.5 * (200000 - Abs(RotationRate.Yaw));

	if ( (OldHolder != None) && (OldHolder.health > 0) )
	{
		Velocity = 0.5 * Holder.Velocity;
		if ( Holder.Health > 0 )
			Velocity += 300*vector(Holder.Rotation) + 100 * (0.5 + FRand()) * VRand();
	}
	Velocity.Z = 250;
	if ( PhysicsVolume.bWaterVolume )
		Velocity *= 0.5;

	//`log(self$" drop holder="$holder,, 'GameObject');
	BaseBoneName = '';
	BaseSkelComponent = None;

	SetLocation(Holder.Location);
	if ( Killer != None )
	{
		LogDropped(Killer);
	}
	else
	{
		LogDropped(Holder.Controller);
	}
	GotoState('Dropped');

	ForEach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		PC.CheckAutoObjective(true);
	}
}

/** called to send the flag to its home base
 * @param Returner the player responsible for returning the flag (may be None)
 */
function SendHome(Controller Returner)
{
	local UTPlayerController PC;

	CalcSetHome();
	LogReturned(Returner);
	PlaySound(ReturnedSound);
	GotoState('Home');

	ForEach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		if ( PC.LastAutoObjective == self )
		{
			PC.CheckAutoObjective(true);
		}
	}
}

/** called when a Kismet action returns the flag */
function KismetSendHome()
{
	BroadcastReturnedMessage();
	SendHome(None);
}

function BroadcastReturnedMessage()
{
	if ( !WorldInfo.GRI.bMatchIsOver )
	{
		BroadcastLocalizedMessage(MessageClass, 3 + 7 * GetTeamNum(), None, None, Team);
	}
}

function BroadcastDroppedMessage(Controller EventInstigator)
{
	if ( !WorldInfo.GRI.bMatchIsOver )
	{
		if ( EventInstigator == None )
			BroadcastLocalizedMessage(MessageClass, 2 + 7 * GetTeamNum(), HolderPRI, None, Team);
		else
			BroadcastLocalizedMessage(MessageClass, 2 + 7 * GetTeamNum(), HolderPRI, EventInstigator.PlayerReplicationInfo, Team);
	}
}

function BroadcastTakenFromBaseMessage(Controller EventInstigator)
{
	BroadcastLocalizedMessage(MessageClass, 6 + 7 * GetTeamNum(), EventInstigator.PlayerReplicationInfo, None, Team);
}

function BroadcastTakenDroppedMessage(Controller EventInstigator)
{
	if ( !WorldInfo.GRI.bMatchIsOver )
	{
		BroadcastLocalizedMessage(MessageClass, 4 + 7 * GetTeamNum(), EventInstigator.PlayerReplicationInfo, None, Team);
	}
}

// Helper funcs
protected function CalcSetHome()
{
	local Controller c;

	// AI Related
	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		if (c.MoveTarget == self)
		{
			c.MoveTimer = -1.0;
		}
	}

	OldHolder = None;

	// Reset the assists and First Touch
	FirstTouch = None;
	while (Assists.Length!=0)
	  Assists.Remove(0,1);
}

function ClearHolder()
{
	local int i;
	local UTGameReplicationInfo GRI;
	local UTPlayerReplicationInfo PRI;
	local UTBot B;

	if (Holder == None)
		return;

	if ( Holder.PlayerReplicationInfo == None )
	{
		GRI = UTGameReplicationInfo(WorldInfo.Game.GameReplicationInfo);
		for (i=0; i<GRI.PRIArray.Length; i++)
		{
			PRI = UTPlayerReplicationInfo(GRI.PRIArray[i]);
			if ( PRI.GetFlag() == self )
			{
				PRI.SetFlag(None);
				PRI.bForceNetUpdate = TRUE;
				B = UTBot(PRI.Owner);
			}
		}
	}
	else
	{
		UTPlayerReplicationInfo(Holder.PlayerReplicationInfo).SetFlag(None);
		Holder.PlayerReplicationInfo.bForceNetUpdate = TRUE;
		B = UTBot(Holder.Controller);
	}

	Holder = None;
	HolderPRI = None;

	if ( B != None )
	{
		B.SetMaxDesiredSpeed();
	}
}

function Actor Position()
{
	if (Holder != None)
	{
		return Holder;
	}
	else if (bHome)
	{
		return HomeBase;
	}
	else
	{
		return self;
	}
}

function bool ValidHolder(Actor other)
{
	local Pawn p;
	local UTPawn UTP;
	local UTBot B;

	p = Pawn(other);
	if ( p == None || p.Health <= 0 || !p.bCanPickupInventory || !p.IsPlayerPawn() || Vehicle(p.base) != None || p == OldHolder
		|| (UTVehicle(p) != None && !UTVehicle(p).bCanCarryFlag) )
	{
		return false;
	}

	// feigning death pawns can't pick up flags
	UTP = UTPawn(Other);
	if (UTP != None && UTP.IsInState('FeigningDeath'))
	{
		return false;
	}

	B = UTBot(P.Controller);
	if (B != None)
	{
		B.NoVehicleGoal = None;
	}

	return true;
}

// Events
singular event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
    if (!ValidHolder(Other))
	return;

    SetHolder(Pawn(Other).Controller);
}

simulated event FellOutOfWorld(class<DamageType> dmgType)
{
	if ( Role == ROLE_Authority )
	{
		AutoSendHome();
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bHome')
	{
		if (bHome)
		{
			ClientReturnedHome();
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/** called on the client when the flag is returned */
simulated function ClientReturnedHome()
{
	// things can go a little screwy with replication ordering due to all the base/physics/location changes that go on
	// so we use this to make sure the flag's where it should be clientside
	if (HomeBase != None)
	{
		SetLocation(HomeBase.Location + (HomeBaseOffset >> HomeBase.Rotation));
		SetRotation(HomeBase.Rotation);
		SetPhysics(PHYS_None);
	}
}

event NotReachableBy(Pawn P)
{
	if ( (Physics != PHYS_Falling) && (WorldInfo.Game.NumBots > 0) )
	{
		SendHome(None);
	}
}

event Landed(vector HitNormal, actor FloorActor)
{
	local UTBot B;
	local rotator NewRot;

	NewRot = Rot(16384,0,0);
	NewRot.Yaw = Rotation.Yaw;
	SetRotation(NewRot);
	OldHolder = None;

	//`log(self$" landed",, 'GameObject');

	// tell nearby bots about this
	foreach WorldInfo.AllControllers(class'UTBot', B)
	{
		if ( B.Pawn != None && B.RouteGoal != self && B.MoveTarget != self
			&& VSize(B.Pawn.Location - Location) < 1600.f && B.LineOfSightTo(self) )
		{
			UTSquadAI(B.Squad).Retask(B);
		}
	}
}

/** returns the game objective we should trigger Kismet flag events on */
function UDKGameObjective GetKismetEventObjective()
{
	return HomeBase;
}

// Logging
function LogTaken(Controller EventInstigator)
{
	GetKismetEventObjective().TriggerFlagEvent('Taken', EventInstigator);
}

function LogReturned(Controller EventInstigator)
{
	GetKismetEventObjective().TriggerFlagEvent('Returned', EventInstigator);
}

// Logging
function LogDropped(Controller EventInstigator)
{
	GetKismetEventObjective().TriggerFlagEvent('Dropped', EventInstigator);
	if ( bLastSecondSave && (EventInstigator != Holder.Controller) )
	{
		BroadcastLocalizedMessage(class'UTLastSecondMessage', 1, HolderPRI, None, Team);
		if ( UTPlayerReplicationInfo(EventInstigator.PlayerReplicationInfo) != None )
		{
			UTPlayerReplicationInfo(EventInstigator.PlayerReplicationInfo).IncrementEventStat('EVENT_LASTSECONDSAVE');
		}
	}
	else
	{
		BroadcastDroppedMessage(EventInstigator);
	}
	bLastSecondSave = false;
}

function CheckTouching()
{
	local int i;
	local Controller BestToucher;
	local Pawn PastHolder;

	PastHolder = OldHolder;
	OldHolder = None;
	for ( i=0; i<Touching.Length; i++ )
	{
		if ( ValidHolder(Touching[i]) )
		{
			if ( PlayerController(Pawn(Touching[i]).Controller) != None )
			{
				if ( PastHolder != Touching[i] )
				{
			SetHolder(Pawn(Touching[i]).Controller);
				}
			return;
		}
			else if ( BestToucher == None )
			{
				// players get priority over bots
				BestToucher = Pawn(Touching[i]).Controller;
			}
		}
	}

	if ( BestToucher != None )
	{
		SetHolder(BestToucher);
	}
}

/** send home without player intervention (timed out, fell out of world, etc) */
function AutoSendHome()
{
	BroadcastReturnedMessage();
	SendHome(None);
}

// States
auto state Home
{
	ignores SendHome, KismetSendHome, Score, Drop;

	function LogTaken(Controller EventInstigator)
	{
		Global.LogTaken(EventInstigator);
		BroadcastTakenFromBaseMessage(EventInstigator);
	}

	function Timer()
	{
		local vector FinalLoc;

		FinalLoc = HomeBase.Location + (HomeBaseOffset >> HomeBase.Rotation);
		if (VSize2D(Location - FinalLoc) > 10.0 || Abs(Location.Z - FinalLoc.Z) > CylinderComponent(CollisionComponent).CollisionHeight)
		{
			BroadcastReturnedMessage();
			`log(self$" Home.Timer: had to sendhome",, 'Error');
			BeginState('');
		}
	}

	function BeginState(Name PreviousStateName)
	{
		SetTimer(1.0, true);

		Disable('Touch');
		bHome = true;
		if (SetLocation(HomeBase.Location + (HomeBaseOffset >> HomeBase.Rotation)))
		{
			SetRotation(HomeBase.Rotation);
			SetCollision(true, false);
			Enable('Touch');
		}
		else
		{
			`Warn("Failed to return flag home!");
			// let timer try again later
		}
	}

	function EndState(Name NextStateName)
	{
		SetTimer(0.0, false);
		bHome = false;
		TakenTime = WorldInfo.TimeSeconds;
	}

Begin:
	// check if an enemy was standing on the base
	Sleep(0.05);
	CheckTouching();
}

state Held
{
	ignores SetHolder;

	function SendHome(Controller Returner)
	{
		// go through most of the drop code before returning home to make sure everything gets reset properly
		OldHolder = Holder;
		HomeBase.ObjectiveChanged();

		BaseBoneName = '';
		BaseSkelComponent = None;
		SetLocation(Holder.Location);

		GotoState('Dropped');

		Global.SendHome(Returner);
	}

	function KismetSendHome()
	{
		BroadcastReturnedMessage();
		SendHome(None);
	}

	function Timer()
	{
		if (Holder == None)
		{
			`Log(self$" Held.Timer: had to sendhome",, 'Error');
			BroadcastReturnedMessage();
			SendHome(None);
		}
	}

	function BeginState(Name PreviousStateName)
	{
		UTGameReplicationInfo(WorldInfo.GRI).SetFlagHeldEnemy(GetTeamNum());
		WorldInfo.GRI.bForceNetUpdate = TRUE;
		bCollideWorld = false;
		SetCollision(false, false);
		SetLocation(Holder.Location);
		if ( UTPawn(Holder) != None )
		{
			UTPawn(Holder).HoldGameObject(self);
		}
		bForceNetUpdate = TRUE;
		SetTimer(10.0, true);
		HomeBase.ObjectiveChanged();
		if (PickupSound != None)
		{
			PlaySound(PickupSound);
		}
	}

	function EndState(Name NextStateName)
	{
		//`log(self$" held.endstate",, 'GameObject');
		ClearHolder();
		SetBase(None);
		SetHardAttach(FALSE);
		bForceNetUpdate = TRUE;
	}
}

/** stubs for Dropped functions in case the state gets exited early due to flag being in invalid location */
function CheckFit();
function CheckPain();

state Dropped
{
	ignores Drop;

	function LogTaken(Controller EventInstigator)
	{
		Global.LogTaken(EventInstigator);
		BroadcastTakenDroppedMessage(EventInstigator);
	}

	function CheckFit()
	{
		local vector X,Y,Z;

		GetAxes(OldHolder.Rotation, X,Y,Z);
		SetRotation(rotator(-1 * X));
		if ( !SetLocation(OldHolder.Location - 2 * OldHolder.GetCollisionRadius() * X + OldHolder.GetCollisionHeight() * vect(0,0,0.5))
		    && !SetLocation(OldHolder.Location) && (OldHolder.GetCollisionRadius() > 0) )
		{
			SetCollisionSize(FMin(DefaultRadius,0.8 * OldHolder.GetCollisionRadius()), FMin(DefaultHeight, 0.8 * OldHolder.GetCollisionHeight()));
			if ( !SetLocation(OldHolder.Location) )
			{
				//`log(self$" Drop sent flag home",,'Error');
				AutoSendHome();
				return;
			}
		}
	}

	function CheckPain()
	{
		if (IsInPain())
		{
			AutoSendHome();
		}
	}

	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		CheckPain();
	}

	singular function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if (!bLeavingDroppedState)
		{
			CheckPain();
		}
	}

	function Timer()
	{
		AutoSendHome();
	}

	singular event BaseChange()
	{
		if (Pawn(Base) != None)
		{
			// landing on Pawns is not allowed
			if (bLeavingDroppedState)
			{
				SetBase(None);
				SetHardAttach(FALSE);
			}
			else
			{
				Velocity = 100.0 * VRand();
				Velocity.Z += 200.0;
				SetPhysics(PHYS_Falling);
			}
		}
	}

	function BeginState(Name PreviousStateName)
	{
		if (DroppedSound != None)
		{
			PlaySound(DroppedSound);
		}
		UTGameReplicationInfo(WorldInfo.GRI).SetFlagDown(GetTeamNum());
		WorldInfo.GRI.bForceNetUpdate = TRUE;
		SetTimer(MaxDropTime, false);
		SetPhysics(PHYS_Falling);
		bCollideWorld = true;
		SetCollisionSize(0.75 * DefaultRadius, DefaultHeight);
		SetCollision(true, false);
		CheckFit();
		CheckPain();
	}

	function EndState(Name NextStateName)
	{
		//`log(self$" dropped.endstate",, 'GameObject');
		bLeavingDroppedState = true;
		SetPhysics(PHYS_None);
		bForceNetUpdate = TRUE;
		bCollideWorld = false;
		SetCollisionSize(DefaultRadius, DefaultHeight);
		ClearTimer();
		bLeavingDroppedState = false;
	}
Begin:
	// check if an enemy was standing on the flag
	Sleep(0.05);
	CheckTouching();
}

defaultproperties
{
	Physics=PHYS_None
	bOrientOnSlope=true
	RemoteRole=ROLE_SimulatedProxy
	bReplicateMovement=true
	bIgnoreRigidBodyPawns=true

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=+0048.000000
		CollisionHeight=+0030.000000
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	MaxDropTime=25.f
	bUpdateSimulatedPosition=true
	bAlwaysRelevant=true

	TossDistance=1500

	IconCoords=(U=599,V=236,UL=25,VL=25)
	MapSize=1.0

	MaxHighlightScale=8.0
	HighlightSpeed=10.0

	LastSeeMessageIndex=-1
	
	RedColor=(R=1.0,A=1.0)
	BlueColor=(B=1.0,A=1.0)
	GoldColor=(R=1.0,G=1.0,A=1.0)
	IconTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseA'

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformPickUp
		Samples(0)=(LeftAmplitude=80,RightAmplitude=80,LeftFunction=WF_LinearIncreasing,RightFunction=WF_LinearIncreasing,Duration=0.2)
	End Object
	PickUpWaveForm=ForceFeedbackWaveformPickUp
}
