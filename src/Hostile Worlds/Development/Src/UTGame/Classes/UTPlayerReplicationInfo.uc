/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTPlayerReplicationInfo extends PlayerReplicationInfo;

/** Whether this PRI is holding special game object. */
var bool				bHasFlag;

/** True if associated bot is currently holding its position */
var bool bHolding;

/** True if player is female */
var bool				bIsFemale;

var int 		spree;
var int			MultiKillLevel;
var float		LastKillTime;

var UTSquadAI Squad;
var private UTCarriedObject		HasFlag;

var class<UTVoice>		VoiceClass;

var UTPlayerReplicationInfo LastKillerPRI;	/** Used for revenge reward, and for avoiding respawning near killer */

var color DefaultHudColor;

var vector HUDLocation;

/************************************
 *  Character class related variables
 ************************************/

/** Class that the player has chosen to be */
var repnotify class<UTFamilyInfo> CharClassInfo;

/** Texture of render of custom character head. */
var	Texture		CharPortrait;

/** The clan tag for this player */
var databinding string ClanTag;

/************************************
 *  Stats related variables
 ************************************/
struct native IntStat
{
	var name	StatName;
	var int		StatValue;
};

/** holds all kill stats (this player's kills, sorted by weapon/damagetype) */
var Array<IntStat> KillStats;

/** holds all death stats (this player's deaths instigated by another player, sorted by weapon/damagetype)*/
var Array<IntStat> DeathStats;

/** holds all suicide stats (this player's suicides, sorted by weapon/damagetype)*/
var Array<IntStat> SuicideStats;

/** holds event stats (mostly reward announcer related */
var Array<IntStat> EventStats;

/** Stats of vehicles killed by this player */
var Array<IntStat> VehicleKillStats;

/** Armor, health, and powerups picked up by this player */
var Array<IntStat> PickupStats;

struct native TimeStat
{
	var name StatName;
	var float TotalTime;
	var float CurrentStart;
};

/** Time spent driving, sorted by vehicle */
var Array<TimeStat> DrivingStats;

/** Time spent holding powerups and flag/orb */
var Array<TimeStat> PowerupTimeStats;

var localized string OrdersString[8];
var byte OrdersIndex;

replication
{
	if (bNetDirty)
		bHasFlag, bHolding, Squad, OrdersIndex, ClanTag, CharClassInfo, bIsFemale;
}

simulated event Destroyed()
{
	Super.Destroyed();
}

simulated function bool ShouldBroadCastWelcomeMessage(optional bool bExiting)
{
	return Super.ShouldBroadcastWelcomeMessage(bExiting);
}

function int IncrementKillStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	Len = KillStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( KillStats[i].StatName == NewStatName )
		{
			KillStats[i].StatValue++;
			return KillStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	KillStats[Len] = NewStat;
	return 1;
}

function int IncrementDeathStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	Len = DeathStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( DeathStats[i].StatName == NewStatName )
		{
			DeathStats[i].StatValue++;
			return DeathStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	DeathStats[Len] = NewStat;
	return 1;
}

function int IncrementSuicideStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	Len = SuicideStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( SuicideStats[i].StatName == NewStatName )
		{
			SuicideStats[i].StatValue++;
			return SuicideStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	SuicideStats[Len] = NewStat;
	return 1;
}

function int IncrementEventStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	Len = EventStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( EventStats[i].StatName == NewStatName )
		{
			EventStats[i].StatValue++;
			return EventStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	EventStats[Len] = NewStat;
	return 1;
}

function StartDrivingStat(name NewStatName)
{
	local int i, Len;
	local TimeStat NewStat;

	Len = DrivingStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( DrivingStats[i].StatName == NewStatName )
		{
			DrivingStats[i].CurrentStart = WorldInfo.TimeSeconds;
			return;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.CurrentStart = WorldInfo.TimeSeconds;
	DrivingStats[Len] = NewStat;
	return;
}

function StopDrivingStat(name NewStatName)
{
	local int i, Len;

	Len = DrivingStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( DrivingStats[i].StatName == NewStatName )
		{
			DrivingStats[i].TotalTime = DrivingStats[i].TotalTime + WorldInfo.TimeSeconds - DrivingStats[i].CurrentStart;
			return;
		}
	}

	// didn't find it - just fail
	`warn("Stopped driving stat "$NewStatName$" without starting it");
	return;
}

function int IncrementVehicleKillStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	Len = VehicleKillStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( VehicleKillStats[i].StatName == NewStatName )
		{
			VehicleKillStats[i].StatValue++;
			return VehicleKillStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	VehicleKillStats[Len] = NewStat;
	return 1;
}

function int IncrementPickupStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	Len = PickupStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( PickupStats[i].StatName == NewStatName )
		{
			PickupStats[i].StatValue++;
			return PickupStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	PickupStats[Len] = NewStat;
	return 1;
}

function StartPowerupTimeStat(name NewStatName)
{
	local int i, Len;
	local TimeStat NewStat;

	Len = PowerupTimeStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( PowerupTimeStats[i].StatName == NewStatName )
		{
			PowerupTimeStats[i].CurrentStart = WorldInfo.TimeSeconds;
			return;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.CurrentStart = WorldInfo.TimeSeconds;
	PowerupTimeStats[Len] = NewStat;
	return;
}

function StopPowerupTimeStat(name NewStatName)
{
	local int i, Len;

	Len = PowerupTimeStats.Length;
	for (i=0; i<Len; i++ )
	{
		if (PowerupTimeStats[i].StatName == NewStatName)
		{
			if (PowerupTimeStats[i].CurrentStart >= 0.0)
			{
				PowerupTimeStats[i].TotalTime = PowerupTimeStats[i].TotalTime + WorldInfo.TimeSeconds - PowerupTimeStats[i].CurrentStart;
				//Mark the current start in case we call stop twice
				PowerupTimeStats[i].CurrentStart = -1.0;
			}

			return;
		}
	}

	// didn't find it - just fail
	`warn("Stopped powerup time stat "$NewStatName$" without starting it");
	return;
}

function SetFlag(UTCarriedObject NewFlag)
{
	HasFlag = NewFlag;
	bHasFlag = (HasFlag != None);

	// flag carriers try to strafe a lot
	Controller(Owner).bForceStrafe = bHasFlag;
}

function UTCarriedObject GetFlag()
{
	return HasFlag;
}

function IncrementKills(bool bEnemyKill )
{
	if ( bEnemyKill )
	{
		if ( WorldInfo.TimeSeconds - LastKillTime < 4 )
		{
			MultiKillLevel++;
		}
		else
		{
			MultiKillLevel = 0;
		}

		if ( bEnemyKill )
			LastKillTime = WorldInfo.TimeSeconds;

		spree++;
		if ( spree > 4 )
		{
			UTGame(WorldInfo.Game).NotifySpree(self, spree);
		}
	}
	else
	{
		MultiKillLevel = 0;
	}
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	SetFlag(None);
	Spree = 0;

	KillStats.length = 0;
	DeathStats.length = 0;
	SuicideStats.length = 0;
	EventStats.length = 0;
	VehicleKillStats.length = 0;
	PickupStats.length = 0;
	DrivingStats.length = 0;
	PowerupTimeStats.length = 0;
}

simulated function string GetCallSign()
{
	return PlayerName;
}

/* epic ===============================================
* ::OverrideWith
Get overridden properties from old PRI
*/
function OverrideWith(PlayerReplicationInfo PRI)
{
	local UTPlayerReplicationInfo UTPRI;

	Super.OverrideWith(PRI);

	UTPRI = UTPlayerReplicationInfo(PRI);
	if ( UTPRI == None )
		return;
}

/* epic ===============================================
* ::CopyProperties
Copy properties which need to be saved in inactive PRI
*/
function CopyProperties(PlayerReplicationInfo PRI)
{
	local UTPlayerReplicationInfo UTPRI;

	Super.CopyProperties(PRI);

	UTPRI = UTPlayerReplicationInfo(PRI);
	if ( UTPRI == None )
		return;

    UTPRI.CharClassInfo = CharClassInfo;

	UTPRI.bIsFemale = bIsFemale;

	UTPRI.KillStats = KillStats;
	UTPRI.DeathStats = DeathStats;
	UTPRI.SuicideStats = SuicideStats;
}

function SeamlessTravelTo(PlayerReplicationInfo NewPRI)
{
	local UTPlayerReplicationInfo UTPRI;

	Super.SeamlessTravelTo(NewPRI);

	// copy constructed character data directly
	UTPRI = UTPlayerReplicationInfo(NewPRI);
	if (UTPRI != None)
	{
        UTPRI.CharClassInfo = CharClassInfo;

		UTPRI.CharPortrait = CharPortrait;
		UTPRI.VoiceClass = VoiceClass;
	}
}

/**********************************************************************************************
 Teleporting
 *********************************************************************************************/

/**
 * The function is used to setup the conditions that allow a teleport.  It also defers to the gameinfo
 *
 * @Param		DestinationActor 	The actor to teleport to
 * @param		OwnerPawn			returns the pawn owned by the controlling owner casts to UTPawn
 *
 * @returns		True if the teleport is allowed
 */

function bool AllowClientToTeleport(Actor DestinationActor, out UTPawn OwnerPawn)
{
	local Controller OwnerC;

	OwnerC = Controller(Owner);

//	`log("##"@OwnerC@DestinationActor@UTGame(WorldInfo.Game).AllowClientToTeleport(Self, DestinationActor));


	if ( OwnerC != none && DestinationActor != None &&
			UTGame(WorldInfo.Game) != none && UTGame(WorldInfo.Game).AllowClientToTeleport(Self, DestinationActor) )
	{
		// Cast the Pawn as we know we need it.
		OwnerPawn = UTPawn(OwnerC.Pawn);
		if ( OwnerPawn != none )
		{
			if (bHasFlag)
			{
				GetFlag().Drop();
			}
			return true;
		}
	}

	return false;
}

/**
 * This function is used to teleport directly to actor.  Currently, only 2 types of actors
 * support teleporting.  UTGameObjectives and UTVehicle_Leviathans.
 *
 * @param	DestinationActor	This is the Actor the player is trying to teleport to
 */

server reliable function ServerTeleportToActor(Actor DestinationActor)
{
	local UTPawn OwnedPawn;
	
	if ( AllowClientToTeleport(DestinationActor, OwnedPawn) )
	{
		// Handle teleporting to Game Objectives
		if ( UTGameObjective(DestinationActor) != none )
		{
			UTGameObjective(DestinationActor).TeleportTo( OwnedPawn );
		}
	}
}

simulated event color GetHudColor()
{
	if ( Team != none )
	{
		return Team.GetHudColor();
	}
	else
	{
		return DefaultHudColor;
	}
}

simulated event ReplicatedEvent(name VarName)
{
	local UTPawn UTP;

	if ( VarName == 'Team' )
	{
		foreach WorldInfo.AllPawns(class'UTPawn', UTP)
		{
			if (UTP.PlayerReplicationInfo == self || (UTP.DrivenVehicle != None && UTP.DrivenVehicle.PlayerReplicationInfo == self))
			{
				UTP.NotifyTeamChanged();
			}
		}
	}
    else if ( VarName == 'CharClassInfo' )
    {
		foreach WorldInfo.AllPawns(class'UTPawn', UTP)
		{
			if (UTP.PlayerReplicationInfo == self || (UTP.DrivenVehicle != None && UTP.DrivenVehicle.PlayerReplicationInfo == self))
			{
				UTP.SetCharacterClassFromInfo(CharClassInfo);
			}
		}
    }

	Super.ReplicatedEvent(VarName);
}

reliable simulated client function ShowMidGameMenu(bool bInitial)
{
	if ( !AttemptMidGameMenu() )
	{
		SetTimer(0.2,true,'AttemptMidGameMenu');
	}
}

simulated function bool AttemptMidGameMenu()
{
	local UTPlayerController PlayerOwner;
	local UTGameReplicationInfo GRI;

	PlayerOwner = UTPlayerController(Owner);

	if ( PlayerOwner != none )
	{
		GRI = UTGameReplicationInfo(WorldInfo.GRI);
		if (GRI != none)
		{
			GRI.ShowMidGameMenu(PlayerOwner,'ScoreTab',true);
			if ( GRI.CurrentMidGameMenu != none )
			{
				GRI.CurrentMidGameMenu.bInitial = true;

			}
			ClearTimer('AttemptMidGameMenu');
			return true;
		}
	}

	return false;
}

defaultproperties
{
	LastKillTime=-5.0
	DefaultHudColor=(R=64,G=255,B=255,A=255)
	VoiceClass=class'UTGame.UTVoice_Robot'
	CharPortrait=Texture2D'CH_IronGuard_Headshot.HUD_Portrait_Liandri'

	CharClassInfo=class'UTGame.UTFamilyInfo_Liandri_Male'
}
