/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTJumpLiftExit extends LiftExit;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( (MyLiftCenter != None) && (WorldInfo.Game.GameDifficulty < 4) )
	{
		ExtraCost = 10000000;
		bBlocked = true;
	}
}

function WaitForLift(Pawn Other)
{
	Super.WaitForLift(Other);
	if (MyLiftCenter != None && MyLiftCenter.MyLift != None)
	{
		MyLiftCenter.MyLift.bMonitorZVelocity = true;
	}
}


function bool CanBeReachedFromLiftBy(Pawn Other)
{
	local float RealJumpZ;
	local vector NewVelocity;

	if (Other.Base == MyLiftCenter.MyLift && MyLiftCenter.MyLift.MaxZVelocity > 0.f)
	{
		RealJumpZ = Other.JumpZ;
		Other.JumpZ += MyLiftCenter.MyLift.MaxZVelocity;
		if (!Other.SuggestJumpVelocity(NewVelocity, Location + vect(0,0,1) * Other.GetCollisionHeight(), Other.Location))
		{
			Other.JumpZ = RealJumpZ;
			return false;
		}
		Other.Velocity = NewVelocity;
		Other.bWantsToCrouch = false;
		Other.Controller.MoveTarget = self;
		Other.Controller.SetDestinationPosition( Location );
		Other.Acceleration = vect(0,0,0);
		if ( UTPawn(Other) != None )
		{
			UTPawn(Other).bNoJumpAdjust = true;
			UTPawn(Other).bReadyToDoubleJump = true;
		}
		Other.SetPhysics(PHYS_Falling);
		UTBot(Other.Controller).SetFall();
		if ( UTPawn(Other).bRequiresDoubleJump )
		{
			UTBot(Other.Controller).bNotifyApex = true;
			UTBot(Other.Controller).bPendingDoubleJump = true;
		}
		Other.DestinationOffset = 50;
		Other.JumpZ = RealJumpZ;
		return true;
	}
	return false;
}

defaultproperties
{
	bExitOnly=true
	ExtraCost=500
}
