/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTProj_LoadedRocket extends UTProj_Rocket;

/** Used for the curling rocket effect */

var repnotify byte FlockIndex;
var UTProj_LoadedRocket Flock[2];

var() float	FlockRadius;
var() float	FlockStiffness;
var() float FlockMaxForce;
var() float	FlockCurlForce;
var bool bCurl;
var vector Dir;

replication
{
	if ( bNetInitial && (Role == ROLE_Authority) )
		FlockIndex, bCurl;
}


simulated function Destroyed()
{
	ClearTimer('FlockTimer');
	super.Destroyed();
}

simulated event ReplicatedEvent(name VarName)
{
	local UTProj_LoadedRocket R;
	local int i;

	if ( VarName == 'FlockIndex' )
	{
		if ( FlockIndex != 0 )
		{
			SetTimer(0.1, true, 'FlockTimer');

			// look for other rockets
			if ( Flock[1] == None )
			{
				ForEach DynamicActors(class'UTProj_LoadedRocket',R)
					if ( R.FlockIndex == FlockIndex )
					{
						Flock[i] = R;
						if ( R.Flock[0] == None )
							R.Flock[0] = self;
						else if ( R.Flock[0] != self )
							R.Flock[1] = self;
						i++;
						if ( i == 2 )
							break;
					}
			}
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function FlockTimer()
{
	local vector ForceDir, CurlDir;
	local float ForceMag;
	local int i;

	// initialize Dir, if necessary
	if (IsZero(Dir))
	{
		Dir = Normal(Velocity);
	}

	Velocity = Default.Speed * Normal(Dir * 0.5 * Default.Speed + Velocity);

	// Work out force between flock to add madness
	for(i=0; i<2; i++)
	{
		if(Flock[i] == None)
			continue;

		// Attract if distance between rockets is over 2*FlockRadius, repulse if below.
		ForceDir = Flock[i].Location - Location;
		ForceMag = FlockStiffness * ( (2 * FlockRadius) - VSize(ForceDir) );
		Acceleration = Normal(ForceDir) * Min(ForceMag, FlockMaxForce);

		// Vector 'curl'
		CurlDir = Flock[i].Velocity Cross ForceDir;
		if ( bCurl == Flock[i].bCurl )
			Acceleration += Normal(CurlDir) * FlockCurlForce;
		else
			Acceleration -= Normal(CurlDir) * FlockCurlForce;
	}
}

defaultproperties
{
	checkradius=20.0

	// Flocking
	FlockRadius=12
	FlockStiffness=-40
	FlockMaxForce=600
	FlockCurlForce=450
}