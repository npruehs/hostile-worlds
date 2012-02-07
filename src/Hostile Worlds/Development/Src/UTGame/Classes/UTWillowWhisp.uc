/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


/** used to show the path to game objectives */
class UTWillowWhisp extends UTReplicatedEmitter;

const MAX_WAYPOINTS = 15;

/** path points to travel to */
var vector WayPoints[MAX_WAYPOINTS];
/** total number of valid points in WayPoints list */
var repnotify int NumPoints;
/** current position in WayPoints list */
var int Position;

replication
{
	if (bNetInitial)
		NumPoints, WayPoints;
}

simulated function PostBeginPlay()
{
	local int i, Start;
	local PlayerController P;
	local Actor HitActor;
	local Vector HitLocation,HitNormal;

	Super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		P = PlayerController(Owner);
		if (P == None || P.Pawn == None)
		{
			Destroy();
		}
		else
		{
			SetLocation(P.Pawn.Location);

			WayPoints[0] = Location + P.Pawn.GetCollisionHeight() * vect(0,0,1) + 200.0 * vector(P.Rotation);
			HitActor = Trace(HitLocation, HitNormal, WayPoints[0], Location, false);
			if (HitActor != None)
			{
				WayPoints[0] = HitLocation;
			}
			NumPoints++;

			if (P.RouteCache[0] != None && P.RouteCache.length > 1 && P.ActorReachable(P.RouteCache[1]))
			{
				Start = 1;
			}
			for (i = Start; NumPoints < MAX_WAYPOINTS && i < P.RouteCache.length && P.RouteCache[i] != None; i++)
			{
				WayPoints[NumPoints++] = P.RouteCache[i].Location + P.Pawn.GetCollisionHeight() * Vect(0,0,1);
			}
		}
	}
}

simulated event SetInitialState()
{
	bScriptInitialized = true;

	if (Role == ROLE_Authority)
	{
		if (PlayerController(Owner).IsLocalPlayerController())
		{
			StartNextPath();
		}
		else
		{
			//@warning: can't set bHidden because that would get replicated
			ParticleSystemComponent.DeactivateSystem();
			LifeSpan = ServerLifeSpan;
			SetPhysics(PHYS_None);
		}
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'NumPoints')
	{
		StartNextPath();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated event SetTemplate(ParticleSystem NewTemplate, optional bool bDestroyOnFinish)
{
	Super(Emitter).SetTemplate(NewTemplate, bDestroyOnFinish);
}

simulated function StartNextPath()
{
	local Pawn OwnerPawn;
	local UTWillowWhisp OtherWhisp;

	if (Position == 0 && PlayerController(Owner) != None && PlayerController(Owner).IsLocalPlayerController())
	{
		// destroy old instances
		foreach DynamicActors(class'UTWillowWhisp', OtherWhisp)
		{
			if (OtherWhisp != self && OtherWhisp.Owner == Owner)
			{
				OtherWhisp.Destroy();
			}
		}
	}
	if ( (UTPlayerController(Owner) != None) && UTPlayerController(Owner).bHideObjectivePaths )
	{
		Destroy();
		return;
	}

	if (++Position >= NumPoints)
	{
		LifeSpan = 5.0;
		Velocity = vect(0,0,0);
		ParticleSystemComponent.DeactivateSystem();
		SetPhysics(PHYS_None);
		GotoState('');
	}
	else
	{
		OwnerPawn = (PlayerController(Owner) != None) ? PlayerController(Owner).Pawn : None;
		if (Position == 0 && OwnerPawn != None)
		{
			SetRotation(OwnerPawn.Rotation);
			SetLocation(OwnerPawn.Location + vector(OwnerPawn.Rotation) * 60.0);
		}
		
		SetRotation (rotator(WayPoints[Position] - Location));
		GotoState('Pathing');
	}
}

state Pathing
{
	simulated function Tick(float DeltaTime)
	{
		local float MaxSpeed;
		local Pawn OwnerPawn;

		if ( (UTPlayerController(Owner) != None) && UTPlayerController(Owner).bHideObjectivePaths )
		{
			Destroy();
			return;
		}

		SetRotation (rotator(WayPoints[Position] - Location));

		OwnerPawn = (PlayerController(Owner) != None) ? PlayerController(Owner).Pawn : None;
		if (OwnerPawn != None)
		{
			if (VSize(Location - OwnerPawn.Location) < OwnerPawn.GroundSpeed && vector(Rotation) dot vector(OwnerPawn.Rotation) > 0.0)
			{
				// go faster when near owner to get some separation
				MaxSpeed = OwnerPawn.GroundSpeed + 300.0;
			}
			else
			{
				MaxSpeed = VSize(OwnerPawn.Velocity) + 60.0;
				RotationRate = default.RotationRate;
			}
		}
		else
		{
			MaxSpeed = 60.0;
		}

		Velocity = vector(Rotation) * MaxSpeed;
		if (VSize(WayPoints[Position] - Location) < FMax(80.0, VSize(Velocity) * DeltaTime * 3.0))
		{
			StartNextPath();
		}
	}

	simulated function BeginState(name PreviousStateName)
	{
		SetPhysics(PHYS_Projectile);
	}
}

defaultproperties
{
	EmitterTemplate=ParticleSystem'GamePlaceholders.Effects.P_WillowWhisp'
	LifeSpan=24.0
	Physics=PHYS_Projectile
	bOnlyRelevantToOwner=true
	bOnlyOwnerSee=false
	Position=-1
	bReplicateMovement=false
}
