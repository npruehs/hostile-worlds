/**
 * operational AI control for TeamGame
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSquadAI extends UDKTeamOwnedInfo
	native;

var UDKGameObjective SquadObjective;

// Alternate path support
var NavigationPoint RouteObjective;
var array<NavigationPoint> ObjectiveRouteCache;

/** when generating a new ObjectiveRouteCache for the same objective, the previous is stored here so bots still following it don't get disrupted */
var array<NavigationPoint> PreviousObjectiveRouteCache;

/** bot that we want to use to generate the route (usually SquadLeader) */
var UDKBot PendingSquadRouteMaker;

/** current alternate route iteration (loops back to start after reaching MaxSquadRoutes) */
var int SquadRouteIteration;

struct native AlternateRoute
{
	var array<NavigationPoint> RouteCache;
};

/** list of alternate routes. Each one higher in the list was created by first adding cost to the nodes in all previous routes */
var array<AlternateRoute> SquadRoutes;

/** maximum size of SquadRoutes list */
var int MaxSquadRoutes;


replication
{
	if ( Role == ROLE_Authority )
		SquadObjective;
}
