/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTCTFSquadAI extends UTSquadAI;

var float LastSeeFlagCarrier;
var UTCTFFlag FriendlyFlag, EnemyFlag;
var NavigationPoint HidePath;

/** separate alternate route caches for the two flags */
var array<AlternateRoute> EnemyFlagRoutes;
var array<AlternateRoute> FriendlyFlagRoutes;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if ( (UTGame(WorldInfo.Game) != None) && UTGame(WorldInfo.Game).bAllowHoverboard )
	{
		bShouldUseGatherPoints = false;
	}
}
	
function bool AllowDetourTo(UTBot B,NavigationPoint N)
{
	if ( !UTPlayerReplicationInfo(B.PlayerReplicationInfo).bHasFlag )
		return true;

	if ( (B.RouteGoal != FriendlyFlag.HomeBase) || !FriendlyFlag.bHome )
		return true;
	return ( N.LastDetourWeight * B.RouteDist > 2 );
}

function bool ShouldUseAlternatePaths()
{
	return true;
}

function SetAlternatePathTo(NavigationPoint NewRouteObjective, UTBot RouteMaker)
{
	local UTBot M;

	// override updating route objective so we can switch route cache
	if (NewRouteObjective != RouteObjective && FriendlyFlag != None && EnemyFlag != None)
	{
		// save routes for current objective
		if (RouteObjective == FriendlyFlag.HomeBase)
		{
			FriendlyFlagRoutes = SquadRoutes;
		}
		else if (RouteObjective == EnemyFlag.HomeBase)
		{
			EnemyFlagRoutes = SquadRoutes;
		}
		// restore routes for new objective
		if (NewRouteObjective == FriendlyFlag.HomeBase)
		{
			SquadRoutes = FriendlyFlagRoutes;
		}
		else if (NewRouteObjective == EnemyFlag.HomeBase)
		{
			SquadRoutes = EnemyFlagRoutes;
		}
		else
		{
			SquadRoutes.length = 0;
		}
		SquadRouteIteration = SquadRoutes.length % MaxSquadRoutes;
		RouteObjective = NewRouteObjective;
		// re-enable squad routes for any bots that had it disabled for the old objective
		for (M = SquadMembers; M != None; M = M.NextSquadMember)
		{
			M.bUsingSquadRoute = true;
		}
		PendingSquadRouteMaker = RouteMaker;
	}

	Super.SetAlternatePathTo(NewRouteObjective, RouteMaker);
}

/* BeDevious()
return true if bot should use guile in hunting opponent (more expensive)
*/
function bool BeDevious(Pawn Enemy)
{
	return false;
}

/* FindPathToObjective()
Returns path a bot should use moving toward a base
*/
function bool FindPathToObjective(UTBot B, Actor O)
{
	// don't ever use gather points when have flag
	if ( UTPlayerReplicationInfo(B.PlayerReplicationInfo).bHasFlag )
	{
		B.bFinalStretch = true;
	}

	return Super.FindPathToObjective(B, O);
}

/* GoPickupFlag()
have bot go pickup dropped friendly flag
*/
function bool GoPickupFlag(UTBot B)
{
	local UTTeamAI TeamAI;
	
	if ( FindPathToObjective(B,FriendlyFlag) )
	{
		TeamAI = UTTeamInfo(Team).AI;
		if ( WorldInfo.TimeSeconds - UTCTFTeamAI(TeamAI).LastGotFlag > 6 )
		{
			UTCTFTeamAI(TeamAI).LastGotFlag = WorldInfo.TimeSeconds;
			B.SendMessage(None, 'GOTOURFLAG', 20);
		}
		B.GoalString = "Pickup friendly flag";
		return true;
	}
	return false;
}

function actor FormationCenter(Controller C)
{
	if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) )
		return SquadObjective;
	if ( (EnemyFlag.Holder != None) && (GetOrders() != 'Defend') && !SquadLeader.IsA('PlayerController') )
		return EnemyFlag.Holder;
	return SquadLeader.Pawn;
}

function bool VisibleToEnemiesOf(Actor A, UTBot B)
{
	if ( (B.Enemy != None) && FastTrace(A.Location, B.Enemy.Location + B.Enemy.GetCollisionHeight() * vect(0,0,1)) )
		return true;
	return false;
}

function NavigationPoint FindHidePathFor(UTBot B)
{
	//local PickupFactory P;
	local PickupFactory Best;
/* //@todo FIXMESTEVE
	//local float NewD, BestD;
	local int MyTeamNum, EnemyTeamNum;

	MyTeamNum = Team.TeamIndex;
	if ( MyTeamNum == 0 )
		EnemyTeamNum = 1;

	// look for nearby inventory
	// stay away from enemies, and enemy base
	// don't go too far
	foreach WorldInfo.AllNavigationPoints(class'PickupFactory', P)
		if ( (P.BaseDist[MyTeamNum] < FMin(2400,0.7*P.BaseDist[EnemyTeamNum]))
			&& !FastTrace(P.Location + (88 - 2*P.CollisionHeight)*Vect(0,0,1), Location + (88 - 2*P.CollisionHeight)*Vect(0,0,1)) )
		{
			// FIXME - at start of match, clear NearestBase if visible to other base, instead of tracing here
			if ( Best == None )
			{
				if ( !VisibleToEnemiesOf(P,B) )
				{
					Best = P;
					if ( Best.ReadyToPickup(3) )
						BestD = Best.BotDesireability(B.Pawn);
				}
			}
			else if ( !Best.ReadyToPickup(3) )
			{
				if ( (P.ReadyToPickup(3) || (FRand() < 0.5))
					&& !VisibleToEnemiesOf(P,B)  )
				{
					Best = P;
					BestD = Best.BotDesireability(B.Pawn);
				}
			}
			else if ( P.ReadyToPickup(3) )
			{
				NewD = P.BotDesireability(B.Pawn);
				if ( (NewD > BestD) && !VisibleToEnemiesOf(P,B) )
				{
					Best = P;
					BestD = NewD;
				}
			}
		}
*/
	Best = None;
	return Best;
}

function bool CheckVehicle(UTBot B)
{
	if (B.RouteGoal != B.MoveTarget || Vehicle(B.RouteGoal) == None) // so bot will get in obstructing vehicle to drive it out of the way
	{
		if ( (EnemyFlag.Holder == None) && (VSize(B.Pawn.Location - EnemyFlag.Position().Location) < 1600) )
			return false;
		if ( UTPlayerReplicationInfo(B.PlayerReplicationInfo).bHasFlag && (VSize(B.Pawn.Location - FriendlyFlag.HomeBase.Location) < 1600) )
			return false;
	}

	return Super.CheckVehicle(B);
}

/* OrdersForFlagCarrier()
Tell bot what to do if he's carrying the flag
*/
function bool OrdersForFlagCarrier(UTBot B)
{
	local UTCTFBase FlagBase;

	if ( CheckVehicle(B) )
	{
		return true;
	}

	// pickup dropped flag if see it nearby
	// FIXME - don't use pure distance - also check distance returned from pathfinding
	if ( !FriendlyFlag.bHome )
	{
		// if one-on-one ctf, then get flag back
		if ( Team.Size == 1 )
		{
			// make sure healthed/armored/ammoed up
			if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
			{
				B.SetAttractionState();
				return true;
			}

			if ( FriendlyFlag.Holder == None )
			{
				if ( GoPickupFlag(B) )
					return true;
				return false;
			}
			else
			{
				if ( (B.Enemy != None) && (B.Enemy.PlayerReplicationInfo != None) && !UTPlayerReplicationInfo(B.Enemy.PlayerReplicationInfo).bHasFlag )
					FindNewEnemyFor(B,(B.Enemy != None) && B.LineOfSightTo(B.Enemy));
				if ( WorldInfo.TimeSeconds - LastSeeFlagCarrier > 6 )
					LastSeeFlagCarrier = WorldInfo.TimeSeconds;
				B.GoalString = "Attack enemy flag carrier";
				if ( B.IsSniping() )
					return false;
				B.bPursuingFlag = true;
				return ( TryToIntercept(B,FriendlyFlag.Holder,EnemyFlag.Homebase) );
			}
		}
		// otherwise, only get if convenient
		if ( (FriendlyFlag.Holder == None) && B.LineOfSightTo(FriendlyFlag.Position())
			&& (VSize(B.Pawn.Location - FriendlyFlag.Location) < 1500.f)
			&& GoPickupFlag(B) )
			return true;

		// otherwise, go hide
		if ( HidePath != None )
		{
			if ( B.Pawn.ReachedDestination(HidePath) )
			{
				if ( ((B.Enemy == None) || (WorldInfo.TimeSeconds - B.LastSeenTime > 7)) && (FRand() < 0.7) )
				{
					HidePath = None;
					if ( B.Enemy == None )
						B.WanderOrCamp();
					else
						B.DoStakeOut();
					return true;
				}
			}
			else if ( B.SetRouteToGoal(HidePath) )
				return true;
		}
	}
	else
		B.bPursuingFlag = false;
	HidePath = None;

	// super pickups if nearby
	// see if should get superweapon/ pickup
	if ( (B.Skill > 2) && (Vehicle(B.Pawn) == None) )
	{
		if ( (!FriendlyFlag.bHome || (VSize(FriendlyFlag.HomeBase.Location - B.Pawn.Location) > 2000))
				&& B.Pawn.ValidAnchor()
				&& CheckSuperItem(B, 800.0) )
		{
			B.GoalString = "Get super item" @ B.RouteGoal;
			B.SetAttractionState();
			return true;
		}
	}

	B.GoalString = "Return to Base with enemy flag!";
	if ( !FindPathToObjective(B,FriendlyFlag.HomeBase) )
	{
		B.GoalString = "No path to home base for flag carrier";
		// FIXME - suicide after a while
		return false;
	}
	if ( B.MoveTarget == FriendlyFlag.HomeBase )
	{
		B.GoalString = "Near my Base with enemy flag!";
		if ( !FriendlyFlag.bHome )
		{
			B.SendMessage(None, 'NEEDOURFLAG', 25);
			B.GoalString = "NEED OUR FLAG BACK!";
			if ( B.Skill > 1 )
				HidePath = FindHidePathFor(B);
			if ( (HidePath != None) && B.SetRouteToGoal(HidePath) )
				return true;
			return false;
		}
		ForEach TouchingActors(class'UTCTFBase', FlagBase)
		{
			if ( FlagBase == FriendlyFlag.HomeBase )
			{
				FriendlyFlag.Touch(B.Pawn, None, B.Pawn.Location, vect(0,0,1));
				break;
			}
		}
	}
	return true;
}

function bool MustKeepEnemy(Pawn E)
{
	if ( (E != None) && (E.PlayerReplicationInfo != None) && UTPlayerReplicationInfo(E.PlayerReplicationInfo).bHasFlag && (E.Health > 0) )
		return true;
	return false;
}

function bool NearEnemyBase(UTBot B)
{
	return EnemyFlag.Homebase.BotNearObjective(B);
}

function bool NearHomeBase(UTBot B)
{
	return FriendlyFlag.Homebase.BotNearObjective(B);
}

function bool FlagNearBase()
{
	if ( WorldInfo.TimeSeconds - FriendlyFlag.TakenTime < UTCTFBase(FriendlyFlag.HomeBase).BaseExitTime )
		return true;

	return ( VSize(FriendlyFlag.Position().Location - FriendlyFlag.HomeBase.Location) < UTGameObjective(FriendlyFlag.HomeBase).BaseRadius );
}

function bool OverrideFollowPlayer(UTBot B)
{
	if ( !EnemyFlag.bHome )
		return false;

	if ( EnemyFlag.HomeBase.BotNearObjective(B) )
		return UTGameObjective(EnemyFlag.HomeBase).TellBotHowToDisable(B);
	return false;
}

function bool CheckSquadObjectives(UTBot B)
{
	local bool bSeeFlag;
	local actor FlagCarrierTarget;
	local controller FlagCarrier;

	if ( UTPlayerReplicationInfo(B.PlayerReplicationInfo).bHasFlag )
		return OrdersForFlagCarrier(B);

	AddTransientCosts(B,1);

	if (EnemyFlag.Holder != None)
	{
		FlagCarrier = EnemyFlag.Holder.Controller;
		if (FlagCarrier == None && EnemyFlag.Holder.DrivenVehicle != None)
		{
			FlagCarrier = EnemyFlag.Holder.DrivenVehicle.Controller;
		}
	}

	if ( !FriendlyFlag.bHome  )
	{
		bSeeFlag = B.LineOfSightTo(FriendlyFlag.Position());
		if ( Team.Size == 1 )
		{
			if (CheckVehicle(B))
			{
				return true;
			}
			if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
			{
				B.SetAttractionState();
				return true;
			}

			// keep attacking if 1-0n-1
			if ( (FriendlyFlag.Holder != None) || (VSize(B.Pawn.Location - FriendlyFlag.Position().Location) > VSize(B.Pawn.Location - EnemyFlag.Position().Location)) )
				return FindPathToObjective(B,EnemyFlag.Position());
		}
		if ( bSeeFlag )
		{
			if ( FriendlyFlag.Holder == None )
			{
				if ( GoPickupFlag(B) )
					return true;
			}
			else
			{
				if ( (B.Enemy == None) || ((B.Enemy.PlayerReplicationInfo != None) && !UTPlayerReplicationInfo(B.Enemy.PlayerReplicationInfo).bHasFlag) )
					FindNewEnemyFor(B,(B.Enemy != None) && B.LineOfSightTo(B.Enemy));
				if ( WorldInfo.TimeSeconds - LastSeeFlagCarrier > 6 )
				{
					LastSeeFlagCarrier = WorldInfo.TimeSeconds;
					B.SendMessage(None, 'ENEMYFLAGCARRIERHERE', 14);
				}
				B.GoalString = "Attack enemy flag carrier";
				if ( B.IsSniping() )
					return false;
				B.bPursuingFlag = true;
				return ( TryToIntercept(B,FriendlyFlag.Holder,EnemyFlag.Homebase) );
			}
		}

		if ( GetOrders() == 'Attack' )
		{
			// break off attack only if needed
			if ( B.bPursuingFlag || bSeeFlag || (B.LastRespawnTime > FriendlyFlag.TakenTime) || NearHomeBase(B)
				|| ((WorldInfo.TimeSeconds - FriendlyFlag.TakenTime > UTCTFBase(FriendlyFlag.HomeBase).BaseExitTime) && !NearEnemyBase(B)) )
			{
				if (B.Enemy == None && CheckVehicle(B))
				{
					return true;
				}
				B.bPursuingFlag = true;
				B.GoalString = "Go after enemy holding flag rather than attacking";
				if ( FriendlyFlag.Holder != None )
					return TryToIntercept(B,FriendlyFlag.Holder,EnemyFlag.Homebase);
				else if ( GoPickupFlag(B) )
					return true;

			}
			else if ( B.bReachedGatherPoint )
				B.GatherTime = WorldInfo.TimeSeconds - 10;
		}
		else if ( (PlayerController(SquadLeader) == None) && !B.IsSniping()
			&& ((CurrentOrders != 'Defend') || bSeeFlag || B.bPursuingFlag || FlagNearBase()) )
		{
			if (B.Enemy == None && CheckVehicle(B))
			{
				return true;
			}
			// FIXME - try to leave one defender at base
			B.bPursuingFlag = true;
			B.GoalString = "Go find my flag";
			if ( FriendlyFlag.Holder != None )
				return TryToIntercept(B,FriendlyFlag.Holder,EnemyFlag.Homebase);
			else if ( GoPickupFlag(B) )
				return true;
		}
	}
	B.bPursuingFlag = false;

	if ( (SquadObjective == EnemyFlag.Homebase) && (B.Enemy != None) && FriendlyFlag.Homebase.BotNearObjective(B)
		&& (WorldInfo.TimeSeconds - B.LastSeenTime < 3) )
	{
		if ( !EnemyFlag.bHome && (EnemyFlag.Holder == None ) && B.LineOfSightTo(EnemyFlag.Position()) )
			return FindPathToObjective(B,EnemyFlag.Position());

		B.GoalString = "Intercept incoming enemy!";
		return false;
	}

	if ( (EnemyFlag.Holder == None) && (EnemyFlag.bHome || (WorldInfo.TimeSeconds - B.ForcedFlagDropTime > 8)) )
	{
		if ( !EnemyFlag.bHome || EnemyFlag.Homebase.BotNearObjective(B) )
		{
			if (CheckVehicle(B))
			{
				return true;
			}
			B.GoalString = "Near enemy flag!";
			return FindPathToObjective(B,EnemyFlag.Position());
		}
	}
	else if ( (GetOrders() != 'Defend') && !SquadLeader.IsA('PlayerController') )
	{
		// make flag carrier squad leader if on same squad
		if ( (SquadLeader != FlagCarrier) && IsOnSquad(FlagCarrier) )
			SetLeader(FlagCarrier);

		if ( (B.Enemy != None) && B.Enemy.LineOfSightTo(FlagCarrier.Pawn) )
		{
			B.GoalString = "Fight enemy threatening flag carrier";
			B.FightEnemy(true,0);
			return true;
		}

		if ( ((FlagCarrier.MoveTarget == FriendlyFlag.HomeBase)
			|| ((FlagCarrier.RouteCache.Length > 1) && (FlagCarrier.RouteCache[1] == FriendlyFlag.HomeBase)))
			&& (B.Enemy != None)
			&& B.LineOfSightTo(FriendlyFlag.HomeBase) )
		{
			B.GoalString = "Fight enemy while waiting for flag carrier to score";
			if ( B.LostContact(7) )
				B.LoseEnemy();
			if ( B.Enemy != None )
			{
				B.FightEnemy(false,0);
				return true;
			}
		}

		if (CheckVehicle(B))
		{
			return true;
		}

		if ( (AIController(FlagCarrier) != None) && (FlagCarrier.MoveTarget != None)
			&& (FlagCarrier.InLatentExecution(FlagCarrier.LATENT_MOVETOWARD)) )
		{
			if ( FlagCarrier.RouteCache.length > 1 && FlagCarrier.RouteCache[0] == FlagCarrier.MoveTarget
				&& FlagCarrier.RouteCache[1] != None )
			{
				FlagCarrierTarget = FlagCarrier.RouteCache[1];
			}
			else
			{
				FlagCarrierTarget = FlagCarrier.MoveTarget;
			}
		}
		else
			FlagCarrierTarget = FlagCarrier.Pawn;
		FindPathToObjective(B,FlagCarrierTarget);
		if ( (B.MoveTarget == FlagCarrierTarget) || (B.MoveTarget == FlagCarrier.MoveTarget) )
		{
			if ( B.Enemy != None )
			{
				B.GoalString = "Fight enemy while waiting for flag carrier";
				if ( B.LostContact(7) )
					B.LoseEnemy();
				if ( B.Enemy != None )
				{
					B.FightEnemy(false,0);
					return true;
				}
			}
			if ( !B.bInitLifeMessage )
			{
				B.bInitLifeMessage = true;
				B.SendMessage(EnemyFlag.Holder.PlayerReplicationInfo, 'GOTYOURBACK', 10);
			}
			if ( (B.MoveTarget == FlagCarrier.Pawn)
				&& ((VSize(B.Pawn.Location - FlagCarrier.Pawn.Location) < 250) || (FlagCarrier.Pawn.Acceleration == vect(0,0,0))) )
				return false;
			if ( B.Pawn.ReachedDestination(FlagCarrierTarget) || (FlagCarrier.Pawn.Acceleration == vect(0,0,0))
				|| (FlagCarrier.MoveTarget == FriendlyFlag.HomeBase)
				|| (FlagCarrier.RouteCache.length > 1 && FlagCarrier.RouteCache[1] == FriendlyFlag.HomeBase) )
			{
				B.WanderOrCamp();
				B.GoalString = "Back up the flag carrier!";
				return true;
			}
		}

		B.GoalString = "Find the flag carrier - move to "$B.MoveTarget;
		return ( B.MoveTarget != None );
	}
	return Super.CheckSquadObjectives(B);
}

function EnemyFlagTakenBy(Controller C)
{
	local UTBot M;

	if ( (PlayerController(SquadLeader) == None) && (SquadLeader != C) )
		SetLeader(C);

	if ( (UTBot(C) != None) && (VSize(C.Pawn.Location - EnemyFlag.HomeBase.Location) < 500) )
	{
		if (EnemyFlag.bHome)
		{
			UTBot(C).Pawn.SetAnchor(EnemyFlag.HomeBase);
		}
		SetAlternatePathTo(FriendlyFlag.HomeBase, UTBot(C));
	}

	for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		if ( (M.MoveTarget == EnemyFlag) || (M.MoveTarget == EnemyFlag.HomeBase) )
			M.MoveTimer = FMin(M.MoveTimer,0.05 + 0.15 * FRand());
}

function bool AllowTaunt(UTBot B)
{
	return ( (FRand() < 0.5 - 0.06 * B.Skill) && (PriorityObjective(B) < 1));
}

function bool ShouldDeferTo(Controller C)
{
	if ( UTPlayerReplicationInfo(C.PlayerReplicationInfo).bHasFlag )
		return true;
	return Super.ShouldDeferTo(C);
}

function byte PriorityObjective(UTBot B)
{
	if ( UTPlayerReplicationInfo(B.PlayerReplicationInfo).bHasFlag )
	{
		if ( FriendlyFlag.HomeBase.BotNearObjective(B) )
			return 255;
		return 2;
	}

	if ( FriendlyFlag.Holder != None )
		return 1;

	return 0;
}

function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, UTBot B)
{
	if ( (NewThreat.PlayerReplicationInfo != None)
		&& UTPlayerReplicationInfo(NewThreat.PlayerReplicationInfo).bHasFlag
		&& bThreatVisible )
	{
		if ( (VSize(B.Pawn.Location - NewThreat.Location) < 1500) || (B.Pawn.Weapon != None && UTWeapon(B.Pawn.Weapon).bSniping)
			|| (VSize(NewThreat.Location - EnemyFlag.HomeBase.Location) < 2000) )
			return current + 6;
		else
			return current + 1.5;
	}
	else if ( NewThreat.IsHumanControlled() )
		return current + 0.1;
	else
		return current;
}

function bool AllowContinueOnFoot(UTBot B, UTVehicle V)
{
	if ( V.ImportantVehicle() )
	{
		// really don't want to get out of important vehicle
		if ( B.RouteGoal == FriendlyFlag )
		{
			if ( VSizeSq(V.Location - FriendlyFlag.Position().Location) > 1000000.0 )
			{
				return false;
			}
		}
		else if ( V.Health > 0.2*V.Default.Health )
		{
			return false;
		}
	}
	// not if can cover flag carrier from here
	if ( EnemyFlag.Holder != None && EnemyFlag.Holder != B.Pawn &&
		(B.Enemy == None || B.Enemy.PlayerReplicationInfo == None || !UTPlayerReplicationInfo(B.Enemy.PlayerReplicationInfo).bHasFlag) &&
		B.LineOfSightTo(EnemyFlag.Holder) )
	{
		return false;
	}
	else
	{
		return Super.AllowContinueOnFoot(B, V);
	}
}

function ModifyAggression(UTBot B, out float Aggression);

defaultproperties
{
	MaxSquadSize=3
	bShouldUseGatherPoints=true
}
