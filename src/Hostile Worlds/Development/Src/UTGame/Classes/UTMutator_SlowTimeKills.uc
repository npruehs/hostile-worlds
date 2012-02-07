// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
class UTMutator_SlowTimeKills extends UTMutator;

var float SlowTime;
var float RampUpTime;
var float SlowSpeed;

function bool MutatorIsAllowed()
{
	return (WorldInfo.NetMode == NM_Standalone);
}


function ScoreKill(Controller Killer, Controller Killed)
{
	if ( PlayerController(Killer) != None )
	{
		WorldInfo.Game.SetGameSpeed(SlowSpeed);
		SetTimer(SlowTime, false);
	}
	if ( NextMutator != None )
	{
		NextMutator.ScoreKill(Killer,Killed);
	}
}

function Timer()
{
	GotoState('Rampup');
}

state Rampup
{
	function Tick(float DeltaTime)
	{
		local float NewGameSpeed;

		NewGameSpeed = WorldInfo.Game.GameSpeed + DeltaTime/RampUpTime;
		if ( NewGameSpeed >= 1 )
		{
			WorldInfo.Game.SetGameSpeed(1.0);
			GotoState('');
		}
		else
		{
			WorldInfo.Game.SetGameSpeed(NewGameSpeed);
		}
	}
}

defaultproperties
{
	RampUpTime=0.1
	SlowTime=0.3
	SlowSpeed=0.25

	GroupNames[0]="GAMESPEED"
}
