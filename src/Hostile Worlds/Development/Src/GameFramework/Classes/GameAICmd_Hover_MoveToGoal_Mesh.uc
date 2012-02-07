/**
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*/

class GameAICmd_Hover_MoveToGoal_Mesh extends GameAICommand;


// transient storage of final dest (only valid for one frame as real final dest is a based position)
var transient vector Transient_FinalDest;
var transient Actor Find;
var transient Actor Goal;
var float	Radius;
var transient bool    bWasFiring;

var float	DesiredHoverHeight;
var transient float	CurrentHoverHeight;

var float	SubGoalReachDist;

/** how close to get to the enemy (only valid of bCompleteMove is TRUE) */
var transient float GoalDistance;

/** current vector destination */
var transient vector MoveVectDest;
var transient vector LastMoveVectDest;

/** storage of initial desired move location */
var transient vector InitialFinalDestination;
var transient int MoveFailCounter;
var int MaxMoveFails;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool HoverToGoal( GameAIController AI, Actor InGoal, float InGoalDistance, float InHoverHeight )
{
	local GameAICmd_Hover_MoveToGoal_Mesh Cmd;

	if( AI != None && AI.Pawn != None && AI.Pawn.bCanFly)
	{
		Cmd = new(AI) class'GameAICmd_Hover_MoveToGoal_Mesh';
		if( Cmd != None )
		{
			Cmd.GoalDistance = InGoalDistance;
			Cmd.Goal = InGoal;
			Cmd.InitialFinalDestination = InGoal.GetDestination(AI);
			Cmd.DesiredHoverHeight = InHoverHeight;
			Cmd.CurrentHoverHeight = InHoverHeight;
			AI.PushCommand( Cmd );
			return TRUE;
		}
	}

	return FALSE;
}

static function bool HoverToPoint( GameAIController AI, vector InPoint, float InGoalDistance, float InHoverHeight )
{
	local GameAICmd_Hover_MoveToGoal_Mesh Cmd;

	if( AI != None && AI.Pawn != None && AI.Pawn.bCanFly)
	{
		Cmd = new(AI) class'GameAICmd_Hover_MoveToGoal_Mesh';
		if( Cmd != None )
		{
			Cmd.GoalDistance = InGoalDistance;
			Cmd.Goal = none;
			Cmd.InitialFinalDestination = InPoint;
			Cmd.DesiredHoverHeight = InHoverHeight;
			Cmd.CurrentHoverHeight = InHoverHeight;
			AI.PushCommand( Cmd );
			return TRUE;
		}
	}

	return FALSE;
}


function Pushed()
{
	Super.Pushed();

	if( (!NavigationHandle.ComputeValidFinalDestination(InitialFinalDestination)) ||
		!NavigationHandle.SetFinalDestination(InitialFinalDestination))
	{
		`AILog("ABORTING! Final destination"@InitialFinalDestination@"is not reachable! (ComputeValidFinalDestination returned FALSE)");
		GotoState('DelayFailure');
	}
	else
	{
		GotoState('Moving');
	}
}

function bool HandlePathObstruction(Actor BlockedBy)
{

	// ! intentionally does not pass on to children

	MoveTimer = -1.f; // kills latent moveto's
	GotoState('MoveDown');
	
	return false;
}

state DelayFailure
{
Begin:
	MoveTo(Pawn.Location);
	Sleep( 0.5f );

	Status = 'Failure';
	PopCommand( self );
}


state MoveDown `DEBUGSTATE
{
	
	// find a safe altitude to fly to 
	function vector GetMoveDest()
	{
		local vector HitLocation;
		local vector HitNormal;
		local vector Dest;
		local actor HitActor;
		
		// find the poly we're above and try to fly to that
		if(NavigationHandle.LineCheck(Pawn.Location, Pawn.Location + vect(0.f,0.f,-4096.f),vect(5,5,5),HitLocation,HitNormal))
		{
			// if we didn't hit the mesh for some reason, trace against geo
			HitActor = Trace(HitLocation,HitNormal,Pawn.Location + vect(0,0,-4096.f),Pawn.Location);
			if(HitActor == none)
			{
				`AILog(GetFuncName()@"Could not find surface to adjust height to!");
				return Pawn.Location;
			}		
		}

		Dest = HitLocation;
		Dest.Z += Pawn.GetCollisionHeight() * 1.5f;
		
		return Dest;
	}
Begin:
	MoveTo(GetMoveDest());
	Sleep(1.0f);
	GotoState('Moving');

};

state Moving `DEBUGSTATE
{

	final function bool ReachedDest(vector Dest)
	{
		local float latDistSq;
		local float VertDist;
		latDistSq = VSizeSq2D(Pawn.Location - Dest);
		if(latDistSq < SubGoalReachDist * SubGoalReachDist)
		{
			VertDist = abs(Pawn.Location.Z - Dest.Z);
			if(VertDist < max(SubGoalReachDist,CurrentHoverHeight+(Pawn.GetCollisionHeight()*2)) && NavigationHandle.PointReachable(Dest))
			{
				return true;
			}
		}

		return false;
	}

Begin:
	`AILog("BEGIN TAG"@GetSTatename());

	if( Enemy != none )
	{
		Radius	= Pawn.GetCollisionRadius() + Enemy.GetCollisionRadius();
	}
// 	if( IsEnemyBasedOnInterpActor(Enemy) == TRUE )
// 	{
// 		Transient_FinalDest = Vect2BP(Enemy.Base.Location);
// 		Find	= Enemy.Base;
// 		Radius	= 0.f;
// 	}
	Radius = FMax(Radius, GoalDistance);

	Transient_FinalDest = BP2Vect(NavigationHandle.FinalDestination);
	if( NavigationHandle.PointReachable(Transient_FinalDest) )
	{
		MoveVectDest = Transient_FinalDest;
		MoveVectDest.Z += CurrentHoverHeight;
		if( !NavigationHandle.PointReachable(MoveVectDest))
		{
			MoveVectDest = Transient_FinalDest;
		}
		`AILog("Moving directly to " $ `showvar(Transient_FinalDest) );
		MoveTo(MoveVectDest,Enemy);
	}
	else
	{
		
		// Try to find path to enemy
		
		if( !GeneratePathToLocation( Transient_FinalDest,GoalDistance, TRUE ) )
		{
			// If no path available
			`AILog("Could not find path to enemy!!!" @ `showvar(Transient_FinalDest) );

			//`AILog("Retrying with mega debug on");
			//NavigationHandle.bDebugConstraintsAndGoalEvals = TRUE;
			//NavigationHandle.bUltraVerbosePathDebugging = TRUE;
			//GeneratePathToLocation( Transient_FinalDest,GoalDistance, TRUE );

			GotoState( 'Fallback' );
		}
		else
		{
			//debug
			`AILog( "Found path!" @ `showvar(Transient_FinalDest), 'Move' );
			//NavigationHandle.DrawPathCache( , TRUE );
			//NavigationHandle.bDebugConstraintsAndGoalEvals = TRUE;


			while(!ReachedDest(Transient_FinalDest))
			{
				LastMoveVectDest=MoveVectDest;
				if(!NavigationHandle.GetNextMoveLocation(MoveVectDest,SubGoalReachDist+5.0f) || VSizeSq(MoveVectDest-LastMoveVectDest) < 1.0f)
				{
					++MoveFailCounter;
				}
				else
				{
					MoveFailCounter = 0;
				}


				if(MoveFailCounter > MaxMoveFails || MoveVectDest == vect(0,0,0))
				{
					`AILog("Failed move" @ `showvar(MoveFailCounter) @ "times" @ `showvar(MoveVectDest) @ "bailing from move" @ `showvar(NavigationHandle.PathCache.EdgeList.Length) );

					//`AILog("Retrying with mega debug on");
					//NavigationHandle.bDebugConstraintsAndGoalEvals = TRUE;
					//NavigationHandle.bUltraVerbosePathDebugging = TRUE;
					//GeneratePathToLocation( Transient_FinalDest,GoalDistance, TRUE );
					//DebugBreak( DEBUGGER_Both );
					//WorldInfo.bPlayersOnlyPending = TRUE;
					Goto('FailedMove');
				}

				Transient_FinalDest = BP2Vect(NavigationHandle.FinalDestination);

				//DrawDebugLine(Pawn.Location,Transient_FinalDest,255,255,0,TRUE);

				// if we're moving directly to our final goal, call movetoward 
				if(VSizeSq2D(MoveVectDest - Transient_FinalDest) < 1.0)
				{					
					`AILog("Moving to final dest"@"("$`showvar(Transient_FinalDest)$") " $ `showvar(MoveVectDest) @ `showvar(Pawn.Location)  );
					MoveTo(Transient_FinalDest, Enemy,SubGoalReachDist);

				}
				else
				{
					`AILog("Moving to" @ `showvar(MoveVectDest) @ `showvar(Pawn.Location) @ `showvar(VSize(MoveVectDest - Pawn.Location) )  );
					MoveTo(MoveVectDest,Enemy,SubGoalReachDist);
				}
			}

			`AILog("Arrived at destination!");
				
		}
	}

	GotoState('DelaySuccess');


FailedMove:

	`AILog( "Failed move.  Now ZeroMovementVariables" );

	MoveTo(Pawn.Location);
	Pawn.ZeroMovementVariables();
	GotoState('DelayFailure');
}



state Fallback `DEBUGSTATE
{
	function vector FindAPointWhereICanHoverTo(float Inradius, optional float minRadius=0, optional float entityRadius = 32, optional bool bDirectOnly=true, optional int MaxPoints=-1,optional float ValidHitBoxSize)
	{
		local array<vector> poses;
//		local int i;
		local vector extent;
		local vector validhitbox;

		Extent.X = entityRadius;
		Extent.Y = entityRadius;
		Extent.Z = entityRadius;

		validhitbox = vect(1,1,1) * ValidHitBoxSize;
		NavigationHandle.GetValidPositionsForBox(Pawn.Location,Inradius,Extent,bDirectOnly,poses,MaxPoints,minRadius,validhitbox);
// 		for(i=0;i<Poses.length;++i)
// 		{
// 			DrawDebugStar(poses[i],55.f,255,255,0,TRUE);
// 			if(i < poses.length-1 )
// 			{
// 				DrawDebugLine(poses[i],poses[i+1],255,255,0,TRUE);
// 			}
// 		}

		if( poses.length > 0)
		{
			return Poses[Rand(Poses.Length)];
		}
		else
		{
			GotoState('DelayFailure');
			return vect(0,0,0);
		}
	}


Begin:

	`AILog( "Fallback! We now try MoveTo directly to a point" );

	MoveTo( FindAPointWhereICanHoverTo( 2048 ),, SubGoalReachDist );
	Sleep(0.5f);

	GotoState('Moving');

}




/** Allows subclasses to determine if our enemy is based on an interp actor or not **/
function bool IsEnemyBasedOnInterpActor( Pawn InEnemy )
{
	return FALSE;
}



defaultproperties
{
	SubGoalReachDist=128.0
	MaxMoveFails=5
}
