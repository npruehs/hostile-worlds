//=============================================================================
// DemoRecSpectator - spectator for demo recordings to replicate ClientMessages
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class DemoRecSpectator extends UTPlayerController;

var bool bFindPlayer;

/** local copy of RealViewTarget as the C++ code might clear it in some cases we don't want to for demo spectators */
var PlayerReplicationInfo MyRealViewTarget;

/** if set, camera rotation is always forced to viewtarget rotation */
var config bool bLockRotationToViewTarget;

/** If set, automatically switches players every AutoSwitchPlayerInterval seconds */
var config bool bAutoSwitchPlayers;

/** Interval to use if bAutoSwitchPlayers is TRUE */
var config float AutoSwitchPlayerInterval;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( PlayerReplicationInfo != None )
	{
		PlayerReplicationInfo.bOutOfLives = true;
	}
}

simulated event ReceivedPlayer()
{
	Super.ReceivedPlayer();

	// DemoRecSpectators don't go through the login process, so manually call ClientSetHUD()
	// so the spectator has it when playing back the demo
	if (Role == ROLE_Authority && WorldInfo.Game != None)
	{
		ClientSetHUD(WorldInfo.Game.HUDType);
	}
}

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.PlayerName = "DemoRecSpectator";
	PlayerReplicationInfo.bIsSpectator = true;
	PlayerReplicationInfo.bOnlySpectator = true;
	PlayerReplicationInfo.bOutOfLives = true;
	PlayerReplicationInfo.bWaitingPlayer = false;
}

exec function Slomo(float NewTimeDilation)
{
	WorldInfo.DemoPlayTimeDilation = NewTimeDilation;
}

exec function ViewClass( class<actor> aClass, optional bool bQuiet, optional bool bCheat )
{
	local actor other, first;
	local bool bFound;

	first = None;

	ForEach AllActors( aClass, other )
	{
		if ( bFound || (first == None) )
		{
			first = other;
			if ( bFound )
				break;
		}
		if ( other == ViewTarget )
			bFound = true;
	}

	if ( first != None )
	{
		SetViewTarget(first);
		SetBehindView(ViewTarget != self);
	}
	else
		SetViewTarget(self);
}

//==== Called during demo playback ============================================

exec function DemoViewNextPlayer()
{
	local Pawn P, Pick;
	local bool bFound;

	// view next player
	foreach WorldInfo.AllPawns(class'Pawn', P)
	{
		if (P.PlayerReplicationInfo != None)
		{
			if (Pick == None)
			{
				Pick = P;
			}
			if (bFound)
			{
				Pick = P;
				break;
			}
			else
			{
				bFound = (RealViewTarget == P.PlayerReplicationInfo || ViewTarget == P);
			}
		}
	}

	SetViewTarget(Pick);
}

function SetViewTarget(Actor NewViewTarget, optional ViewTargetTransitionParams TransitionParams)
{
	Super.SetViewTarget(NewViewTarget, TransitionParams);

	// this check is so that a Pawn getting gibbed doesn't break finding that player again
	// must manually clear MyRealViewTarget when player controlled switch back to viewing self
	if (NewViewTarget != self)
	{
		MyRealViewTarget = RealViewTarget;
	}
}

unreliable server function ServerViewSelf(optional ViewTargetTransitionParams TransitionParams)
{
	Super.ServerViewSelf(TransitionParams);

	MyRealViewTarget = None;
}

reliable client function ClientSetRealViewTarget(PlayerReplicationInfo NewTarget)
{
	SetViewTarget(self); // will find Pawn from RealViewTarget next tick
	RealViewTarget = NewTarget;
	MyRealViewTarget = NewTarget;
	bFindPlayer = (NewTarget == None);
}

function bool SetPause(bool bPause, optional delegate<CanUnpause> CanUnpauseDelegate = CanUnpause)
{
	// allow the spectator to pause demo playback
	if (WorldInfo.NetMode == NM_Client)
	{
		WorldInfo.Pauser = (bPause) ? PlayerReplicationInfo : None;
		return true;
	}
	else
	{
		return false;
	}
}

exec function Pause()
{
	if (WorldInfo.NetMode == NM_Client)
	{
		ServerPause();
	}
}

auto state Spectating
{
	function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		if( bAutoSwitchPlayers )
		{
			SetTimer( AutoSwitchPlayerInterval, true, 'DemoViewNextPlayer');
		}
	}

	exec function StartFire(optional byte FireModeNum)
	{
		SetBehindView(true);
		DemoViewNextPlayer();
	}

	/** used to start out the demo view on the local player - should be called when recording, not playback */
	function SendInitialViewTarget()
	{
		local PlayerController PC;

		foreach LocalPlayerControllers(class'PlayerController', PC)
		{
			if (!PC.PlayerReplicationInfo.bOnlySpectator)
			{
				ClientSetRealViewTarget(PC.PlayerReplicationInfo);
				return;
			}
		}
		// send None so demo playback knows it should just pick the first Pawn it can find
		ClientSetRealViewTarget(None);
	}

	simulated event GetPlayerViewPoint(out vector CameraLocation, out rotator CameraRotation)
	{
		Global.GetPlayerViewPoint(CameraLocation, CameraRotation);
	}

	exec function BehindView()
	{
		SetBehindView(!bBehindView);
	}

	event PlayerTick( float DeltaTime )
	{
		local Pawn P;

		Global.PlayerTick( DeltaTime );

		// attempt to find a player to view.
		if (Role == ROLE_AutonomousProxy)
		{
			if (RealViewTarget == None && MyRealViewTarget != None)
			{
				RealViewTarget = MyRealViewTarget;
			}

			if ((RealViewTarget==None || RealViewTarget==PlayerReplicationInfo) && bFindPlayer)
			{
				DemoViewNextPlayer();
				if (RealViewTarget != None && RealViewTarget != PlayerReplicationInfo)
				{
					bFindPlayer = false;
				}
			}
			else
			{
				// reacquire ViewTarget if the player switched Pawns
				if ( RealViewTarget != None && RealViewTarget != PlayerReplicationInfo &&
					(Pawn(ViewTarget) == None || Pawn(ViewTarget).PlayerReplicationInfo != RealViewTarget) )
				{
					foreach WorldInfo.AllPawns(class'Pawn', P)
					{
						if (P.PlayerReplicationInfo == RealViewTarget)
						{
							SetViewTarget(P);
							break;
						}
					}
				}
			}

			if (Pawn(ViewTarget) != None)
			{
				TargetViewRotation = ViewTarget.Rotation;
				TargetViewRotation.Pitch = Pawn(ViewTarget).RemoteViewPitch << 8;
			}
		}
	}
Begin:
	if (Role == ROLE_Authority)
	{
		// it takes two ticks to guarantee that all the relevant actors have been recorded into the demo
		// (necessary for the reference in ClientSetRealViewTarget()'s parameter to be valid during playback)
		Sleep(0.0);
		Sleep(0.0);
		SendInitialViewTarget();
	}
}

simulated event GetPlayerViewPoint(out vector CameraLocation, out rotator CameraRotation)
{
	bFreeCamera = (!bLockRotationToViewTarget && (bBehindView || Vehicle(ViewTarget) != None));
	Super.GetPlayerViewPoint(CameraLocation, CameraRotation);
}

function UpdateRotation(float DeltaTime)
{
	local rotator NewRotation;

	if (bLockRotationToViewTarget)
	{
		SetRotation(ViewTarget.Rotation);
	}
	else
	{
		Super.UpdateRotation(DeltaTime);
	}

	if (Rotation.Roll != 0)
	{
		NewRotation = Rotation;
		NewRotation.Roll = 0;
		SetRotation(NewRotation);
	}
}

defaultproperties
{
	RemoteRole=ROLE_AutonomousProxy
	bDemoOwner=1
	bBehindView=true
}

