/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// CheatManager
// Object within playercontroller that manages "cheat" commands
// only spawned in single player mode
//=============================================================================

class UTCheatManager extends CheatManager within PlayerController;

var class<LocalMessage> LMC;
var SpeechRecognition RecogObject;

exec function ViewFlag()
{
	local AIController C;

	foreach WorldInfo.AllControllers(class'AIController', C)
	{
		if (UTPlayerReplicationInfo(C.PlayerReplicationInfo) != None && UTPlayerReplicationInfo(C.PlayerReplicationInfo).bHasFlag)
		{
			SetViewTarget(C.Pawn);
			return;
		}
	}
}

exec function Glow(float F)
{
	local UTVehicle V;

	ForEach DynamicActors(class'UTVehicle' , V)
	{
		V.LightEnvironment.AmbientGlow = MakeLinearColor(F,F,F,1.0);
	}
}

exec function LM( string MessageClassName )
{
	LMC = class<LocalMessage>(DynamicLoadObject(MessageClassName, class'Class'));
}

exec function LMS( int switch )
{
	ReceiveLocalizedMessage(LMC, switch, PlayerReplicationInfo, PlayerReplicationInfo);
}

/** Summon a vehicle */
exec function SummonV( string ClassName )
{
	local class<actor> NewClass;
	local vector SpawnLoc;

	`log( "Fabricate " $ ClassName );
	NewClass = class<actor>( DynamicLoadObject( "UTGameContent.UTVehicle_"$ClassName, class'Class' ) );
	if ( NewClass == None )
	{
		NewClass = class<actor>( DynamicLoadObject( "UTGameContent.UTVehicle_"$ClassName$"_Content", class'Class' ) );
	}
	if( NewClass!=None )
	{
		if ( Pawn != None )
			SpawnLoc = Pawn.Location;
		else
			SpawnLoc = Location;
		Spawn( NewClass,,,SpawnLoc + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
	}
}

/* AllWeapons
	Give player all available weapons
*/
exec function AllWeapons()
{
	if( (WorldInfo.NetMode!=NM_Standalone) || (Pawn == None) )
		return;

	GiveWeapon("UTGame.UTWeap_LinkGun");
	GiveWeapon("UTGameContent.UTWeap_RocketLauncher_Content");
	GiveWeapon("UTGameContent.UTWeap_ShockRifle");
	GiveWeapon("UTGame.UTWeap_Physicsgun");
}

exec function DoubleUp()
{
	
}

exec function PhysicsGun()
{
	if (Pawn != None)
	{
		GiveWeapon("UTGame.UTWeap_PhysicsGun");
	}
}

/* AllAmmo
	Sets maximum ammo on all weapons
*/
exec function AllAmmo()
{
	if ( (Pawn != None) && (UTInventoryManager(Pawn.InvManager) != None) )
	{
		UTInventoryManager(Pawn.InvManager).AllAmmo(true);
		UTInventoryManager(Pawn.InvManager).bInfiniteAmmo = true;
	}
}

exec function Invisible(bool B)
{
	if ( UTPawn(Pawn) != None )
	{
		UTPawn(Pawn).SetInvisible(B);
	}
}

exec function FreeCamera()
{
	UTPlayerController(Outer).bFreeCamera = !UTPlayerController(Outer).bFreeCamera;
	UTPlayerController(Outer).SetBehindView(UTPlayerController(Outer).bFreeCamera);
}

exec function ViewBot()
{
	local Controller first;
	local bool bFound;
	local AIController C;

	foreach WorldInfo.AllControllers(class'AIController', C)
	{
		if (C.Pawn != None && C.PlayerReplicationInfo != None)
		{
			if (bFound || first == None)
			{
				first = C;
				if (bFound)
				{
					break;
				}
			}
			if (C.PlayerReplicationInfo == RealViewTarget)
			{
				bFound = true;
			}
		}
	}

	if ( first != None )
	{
		SetViewTarget(first);
		UTPlayerController(Outer).SetBehindView(true);
		UTPlayerController(Outer).bFreeCamera = true;
		FixFOV();
	}
	else
		ViewSelf(true);
}

exec function KillBadGuys()
{
	local playercontroller PC;
	local UTPawn p;

	PC = UTPlayerController(Outer);

	if (PC!=none)
	{
		ForEach DynamicActors(class'UTPawn', P)
		{
			if ( !WorldInfo.GRI.OnSameTeam(P,PC) && (PC.Pawn != none && PC.Pawn != P) )
			{
				P.TakeDamage(20000,PC, P.Location, Vect(0,0,0),class'UTDmgType_Rocket');
			}
		}
	}
}

exec function RBGrav(float NewGravityScaling)
{
	WorldInfo.RBPhysicsGravityScaling = NewGravityScaling;
}

/** allows suiciding with a specific damagetype and health value for testing death effects */
exec function SuicideBy(string Type, optional int DeathHealth)
{
	local class<DamageType> DamageType;

	if (Pawn != None)
	{
		if (InStr(Type, ".") == -1)
		{
			Type = "UTGame." $ Type;
		}
		DamageType = class<DamageType>(DynamicLoadObject(Type, class'Class'));
		if (DamageType != None)
		{
			Pawn.Health = DeathHealth;
			if (Pawn.IsA('UTPawn'))
			{
				UTPawn(Pawn).AccumulateDamage = -DeathHealth;
				UTPawn(Pawn).AccumulationTime = WorldInfo.TimeSeconds;
			}
			Pawn.Died(Outer, DamageType, Pawn.Location);
		}
	}
}

exec function EditWeapon(string WhichWeapon)
{
	local utweapon Weapon;
	local array<string> weaps;
	local string s;
	local int i;
	if (WhichWeapon != "")
	{
		ConsoleCommand("Editactor class="$WhichWeapon);
	}
	else
	{
		foreach AllActors(class'UTWeapon',Weapon)
		{
			s = ""$Weapon.Class;
			if ( Weaps.Find(s) < 0 )
			{
				Weaps.Length = Weaps.Length + 1;
				Weaps[Weaps.Length-1] = s;
			}
		}

		for (i=0;i<Weaps.Length;i++)
		{
			`log("Weapon"@i@"="@Weaps[i]);
		}
	}
}

/** kills all the bots that are not the current viewtarget */
exec function KillOtherBots()
{
	local UTBot B;

	UTGame(WorldInfo.Game).DesiredPlayerCount = WorldInfo.Game.NumPlayers + 1;
	foreach WorldInfo.AllControllers(class'UTBot', B)
	{
		if ((B.Pawn == None || B.Pawn != ViewTarget) && (B.PlayerReplicationInfo == None || B.PlayerReplicationInfo != RealViewTarget))
		{
			if (B.Pawn != None)
			{
				B.Pawn.Suicide();
			}
			B.Destroy();
		}
	}
}



//// START:  Decal testing code
exec function SpawnABloodDecal()
{
	LeaveADecal( Pawn.Location, vect(0,0,0) );
}

simulated function LeaveADecal( vector HitLoc, vector HitNorm )
{
	local MaterialInstance MIC_Decal;
	local Actor TraceActor;
	local vector out_HitLocation;
	local vector out_HitNormal;
	local vector TraceDest;
	local vector TraceStart;
	local vector TraceExtent;
	local TraceHitInfo HitInfo;

	// these should be randomized
	TraceStart = HitLoc + ( Vect(0,0,15));
	TraceDest =  HitLoc - ( Vect(0,0,100));

	TraceActor = Trace( out_HitLocation, out_HitNormal, TraceDest, TraceStart, false, TraceExtent, HitInfo, TRACEFLAG_PhysicsVolumes );

	if( TraceActor != None )
	{
		MIC_Decal = new(Outer) class'MaterialInstanceTimeVarying';
		MIC_Decal.SetParent( MaterialInstanceTimeVarying'CH_Gibs.Decals.BloodSplatter' );

		WorldInfo.MyDecalManager.SpawnDecal(MIC_Decal, out_HitLocation, rotator(-out_HitNormal), 200, 200, 10, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex);

		MaterialInstanceTimeVarying(MIC_Decal).SetScalarStartTime( 'DissolveAmount',  3.0f );
		MaterialInstanceTimeVarying(MIC_Decal).SetScalarStartTime( 'BloodAlpha',  3.0f );
		MIC_Decal.SetScalarParameterValue( 'DissolveAmount',  3.0f );
		MIC_Decal.SetScalarParameterValue( 'BloodAlpha',  3.0f );
	}
}


exec function TiltIt( bool bActive )
{
	SetControllerTiltActive( bActive );
}


exec function ShowStickBindings()
{
	local int BindIndex;
	`log( PlayerInput.Bindings.Length );

	for( BindIndex = 0; BindIndex < PlayerInput.Bindings.Length; ++BindIndex )
	{
		if( ( PlayerInput.Bindings[BindIndex].Name == 'XboxTypeS_LeftX' )
			||  ( PlayerInput.Bindings[BindIndex].Name == 'XboxTypeS_LeftY' )
			||  ( PlayerInput.Bindings[BindIndex].Name == 'XboxTypeS_RightX' )
			||  ( PlayerInput.Bindings[BindIndex].Name == 'XboxTypeS_RightY' )
			||  ( PlayerInput.Bindings[BindIndex].Name == 'GBA_Look_Gamepad' )

			)
		{
			`log( " name: " $ PlayerInput.Bindings[BindIndex].Name $ " command: " $ PlayerInput.Bindings[BindIndex].Command );
			//PlayerInput.Bindings[BindIndex].Command = TheCommand;
		}
		//`log( " " $ PlayerInput.Bindings[BindIndex].Command );
	}
}

exec function SetStickBind( float val )
{
	local int BindIndex;
	local string cmd;

	`log( "SetStickBind" );

	for( BindIndex = 0; BindIndex < PlayerInput.Bindings.Length; ++BindIndex )
	{
		if( 
			( PlayerInput.Bindings[BindIndex].Name == 'XboxTypeS_RightY' )
			||  ( PlayerInput.Bindings[BindIndex].Name == 'GBA_Look_Gamepad' )
			)
		{
			cmd = "Axis aLookup Speed=" $ val $ " DeadZone=0.3";
			PlayerInput.Bindings[BindIndex].Command = cmd;
			`log( " command: " $ cmd @ PlayerInput.Bindings[BindIndex].Command );
		}
	}
}

exec function KillAll(class<actor> aClass)
{
	local Actor A;
	local PlayerController PC;

	foreach WorldInfo.AllControllers(class'PlayerController', PC)
	{
		PC.ClientMessage("Killed all "$string(aClass));
	}

	if ( ClassIsChildOf(aClass, class'AIController') )
	{
		UTGame(WorldInfo.Game).KillBots();
		return;
	}
	if ( ClassIsChildOf(aClass, class'Pawn') )
	{
		KillAllPawns(class<Pawn>(aClass));
		return;
	}
	ForEach DynamicActors(class 'Actor', A)
		if ( ClassIsChildOf(A.class, aClass) )
			A.Destroy();
}

// Kill non-player pawns and their controllers
function KillAllPawns(class<Pawn> aClass)
{
	local Pawn P;

	UTGame(WorldInfo.Game).KillBots();
	ForEach DynamicActors(class'Pawn', P)
		if ( ClassIsChildOf(P.Class, aClass)
			&& !P.IsPlayerPawn() )
		{
			if ( P.Controller != None )
				P.Controller.Destroy();
			P.Destroy();
		}
}

DefaultProperties
{

}


