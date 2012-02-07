/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTPlayerInput extends UDKPlayerInput within UTPlayerController;

var float LastDuckTime;
var bool  bHoldDuck;
var Actor.EDoubleClickDir ForcedDoubleClick;

simulated exec function Duck()
{
	if ( UTPawn(Pawn)!= none )
	{
		if (bHoldDuck)
		{
			bHoldDuck=false;
			bDuck=0;
			return;
		}

		bDuck=1;

		if ( WorldInfo.TimeSeconds - LastDuckTime < DoubleClickTime )
		{
			bHoldDuck = true;
		}

		LastDuckTime = WorldInfo.TimeSeconds;
	}
}

simulated exec function UnDuck()
{
	if (!bHoldDuck)
	{
		bDuck=0;
	}
}

exec function Jump()
{
	local UTPawn P;

	if (!IsMoveInputIgnored())
	{
		// jump cancels feign death
		P = UTPawn(Pawn);
		if (P != None && P.bFeigningDeath)
		{
			P.FeignDeath();
		}
		else
		{
		 	if (bDuck>0)
		 	{
		 		bDuck = 0;
		 		bHoldDuck = false;
		 	}
			Super.Jump();
		}
	}
}


defaultproperties
{
	bEnableFOVScaling=true
}
