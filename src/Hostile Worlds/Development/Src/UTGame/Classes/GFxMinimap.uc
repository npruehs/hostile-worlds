/**********************************************************************

Copyright   :   Copyright 2006-2007 Scaleform Corp. All Rights Reserved.

Portions of the integration code is from Epic Games as identified by Perforce annotations.
Copyright 2010 Epic Games, Inc. All rights reserved.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/

class GFxMinimap extends GFxObject;

//var public PlayerController PlayerOwner;

var GFxMinimapHud           Hud;
var WorldInfo				ThisWorld;
var UTMapInfo				MapInfo;
var int                     MapTexSize;
var bool					bNeedsUpdateData;
var GFxObject                PlayerIcon, CompassIcon, MapMC;
var array<GFxObject>         EnemyIcons, MyTeamIcons, FlagIcons, ObjectiveIcons;
var matrix                  IconMatrix;
var GFxObject                IconsRedMC, IconsBlueMC, IconsFlagMC;
var int                     IconsRedCount, IconsBlueCount, IconsFlagCount;

var array<UTGameObjective>  Objectives;

function Init(GFxMinimapHud h)
{
	local ASValue		 av;
	local array<ASValue> args;
	local ASDisplayInfo  DI;
	local UTTeamInfo   TeamInfo;

	local UTGameReplicationInfo GRI;

	Hud = h;
	bNeedsUpdateData = true;
	ThisWorld = GetPC().WorldInfo;
	MapInfo = UTMapInfo(ThisWorld.GetMapInfo());

    PlayerIcon = GetObject("player");
    CompassIcon = GetObject("compass");
    MapMC = GetObject("map");

	if (MapInfo.MapTexture != none)
	{
		MapTexSize = Texture2D(MapInfo.MapTexture).SizeX;
		SetString("mapImagePath", "img://" $ PathName(MapInfo.MapTexture));
	}

	IconsRedMC = GetObject("icons_player_red");
	IconsBlueMC = GetObject("icons_player_blue");
	IconsFlagMC = GetObject("icons_flag");

    GRI = UTGameReplicationInfo(GetPC().WorldInfo.GRI);

     if ( UTGFxTeamHUD(H) != None )
     {
        TeamInfo = UTTeamInfo(GRI.Teams[0]);
        if (TeamInfo.TeamFlag != none)
        {
            FlagIcons = GenFlagIcons(2);
            av.Type = AS_Number;
            av.n = 3;
            args.AddItem(av);
            FlagIcons[0].Invoke("gotoAndStop", args);
            args[0].n = 2;
            FlagIcons[1].Invoke("gotoAndStop", args);
        }
    }

	DI = GetDisplayInfo();
	DI.X += 30;
	DI.visible = false;
	SetDisplayInfo(DI);
}

function UpdateData()
{
	SetVisible(true);

	MapInfo.VerifyMapExtent();

/*
	Objectives.length = 0;
  	foreach ThisWorld.AllNavigationPoints(class'UTGameObjective', Obj)
	{
		Objectives.AddItem(Obj);
	}
*/
    bNeedsUpdateData = false;
}

function array<GFxObject> GenFriendIcons(int n)
{
   	local array<GFxObject> Icons;
   	local GFxObject IconMC;
    local int i;
	for (i = 0; i < n; i++)
    {
        IconMC = IconsBlueMC.AttachMovie("player_blue", "player_blue"$IconsBlueCount++);
        Icons[i] = IconMC;
    }
    return Icons;
}

function array<GFxObject> GenEnemyIcons(int n)
{
	local array<GFxObject> Icons;
	local GFxObject IconMC;
    local int i;
	for (i = 0; i < n; i++)
    {
        IconMC = IconsRedMC.AttachMovie("player_red", "player_red"$IconsRedCount++);
        Icons[i] = IconMC;
    }
    return Icons;
}

function array<GFxObject> GenFlagIcons(int n)
{
    local array<GFxObject> Icons;
    local GFxObject IconMC;
    local int i;
	for (i = 0; i < n; i++)
    {
        IconMC = IconsFlagMC.AttachMovie("flag", "flag"$IconsFlagCount++);
        Icons[i] = IconMC;
    }
    return Icons;
}

function UpdateIcons(out array<Actor> Actors, out array<GFxObject> ActorIcons, bool bIsRedIconType)
{
	local ASDisplayInfo d;
	local array<GFxObject> Icons;
	local int i;
	local vector V;
	local GFxObject Val;

	d.hasVisible = true;
	if (ActorIcons.length < Actors.length)
	{
		if ( bIsRedIconType )
		{
			Icons = GenEnemyIcons(Actors.length-ActorIcons.length);
		}
		else
		{
			Icons = GenFriendIcons(Actors.length-ActorIcons.length);
		}

		foreach Icons(Val) { ActorIcons.AddItem(Val); }
	}
	else
	{
		d.Visible = false;
		for (i = Actors.length; i < ActorIcons.length; i++)
			ActorIcons[i].SetDisplayInfo(d);
	}

	d.hasX = true; d.hasY = true;
	d.Visible = true;
	for (i = 0; i < Actors.length; i++)
	{
		V = TransformVector(IconMatrix, Actors[i].Location);
		d.Visible = (VSize2d(V) < Hud.Radius);
		d.X = V.X;
		d.Y = V.Y;
		ActorIcons[i].SetDisplayInfo(d);
	}
}

function Update(float Scale)
{
	local Pawn P;
    local ASDisplayInfo d;
    local array<Actor> MyTeam;
    local array<Actor> Enemy;
	local UTPawn UTP;
	local UTVehicle UTV;
	local int j;
	local float f;
	local vector V;
	local matrix M;
	local float MapScale;
	local UTTeamInfo Team;
	local bool bInSensorRange, bIsRedIconType;
	local vector MapOffset;
	local PlayerController PC;

	PC = GetPC();

	Scale = 1.0/Scale;

	if (PC.Pawn == None)
	{
		return;
	}

    if (bNeedsUpdateData)
		UpdateData();

    // player
    d.hasRotation = true;
    if (UTPlayerController(PC).bRotateMinimap)
    {
		d.Rotation = 0;
	    PlayerIcon.SetDisplayInfo(d);
		d.Rotation = ((PC.Rotation.Yaw) & 65535) * (-360.0/65536.0);
	    CompassIcon.SetDisplayInfo(d);

	    f = -((PC.Rotation.Yaw + 16384) & 65535) * (Pi/32768.0);
	    IconMatrix.XPlane.X = cos(f) * Scale;
	    IconMatrix.XPlane.Y = sin(f) * Scale;
	    IconMatrix.YPlane.X = -sin(f) * Scale;
	    IconMatrix.YPlane.Y = cos(f) * Scale;
	    IconMatrix.WPlane.X = 0;
	    IconMatrix.WPlane.Y = 0;
	    IconMatrix.WPlane.Z = 0;
	    IconMatrix.WPlane.W = 1;
        IconMatrix.WPlane = TransformVector(IconMatrix, -PC.Pawn.Location);
    }
    else
    {
		d.Rotation = 0;
	    CompassIcon.SetDisplayInfo(d);
		d.Rotation = ((PC.Rotation.Yaw) & 65535) * (360.0/65536.0);
	    PlayerIcon.SetDisplayInfo(d);

	    f = -Pi*0.5;
	    IconMatrix.XPlane.X = 0;
	    IconMatrix.XPlane.Y = -Scale;
	    IconMatrix.YPlane.X = Scale;
	    IconMatrix.YPlane.Y = 0;
	    IconMatrix.WPlane.X = 0;
	    IconMatrix.WPlane.Y = 0;
	    IconMatrix.WPlane.Z = 0;
	    IconMatrix.WPlane.W = 1;
        IconMatrix.WPlane = TransformVector(IconMatrix, -PC.Pawn.Location);
	}
	d.hasRotation = false;

	// terrain
	if (MapInfo != none && MapInfo.MapTexture != none)
	{
		f -= Pi*0.5;
		MapScale = Hud.NormalZoomf/(2.0 * Hud.CurZoomf);
	    M.XPlane.X = -cos(f) * MapScale;
		M.XPlane.Y = -sin(f) * MapScale;
	    M.YPlane.X = sin(f) * MapScale;
		M.YPlane.Y = -cos(f) * MapScale;
		MapOffset.X = -MapTexSize*0.5f;
		MapOffset.Y = -MapTexSize*0.5f;
		M.WPlane.X = 0;
		M.WPlane.Y = 0;
		M.WPlane.Z = 0;
		M.WPlane.W = 1;
		M.WPlane = TransformVector(M, MapOffset);
		f = Pi*1.5-f;
		V = (MapInfo.MapCenter - PC.Pawn.Location) * MapTexSize/MapInfo.MapExtent;
		MapScale = (Hud.NormalZoomf/(2.0 * Hud.CurZoomf));
		M.WPlane.X += (V.X * cos(f) + V.Y * sin(f)) * MapScale;
		M.WPlane.Y += (V.Y * cos(f) - V.X * sin(f)) * MapScale;
		MapMC.SetDisplayMatrix(M);
	}

	// other players
    foreach ThisWorld.AllPawns(class'Pawn', P)
	{
		if ( P.bHidden || (P.Health <=0) || P.IsInvisible() || (P.DrivenVehicle != None) ||
			 (P.PlayerReplicationInfo == None) || (P == PC.Pawn))
			continue;
		UTP = UTPawn(P);
		UTV = UTVehicle(P);
		if ((UTP == None) && (UTV == None))
			continue;
		if (ThisWorld.GRI.OnSameTeam(PC, P))
			MyTeam.AddItem(P);
		else
			Enemy.AddItem(P);
	}

	bIsRedIconType = (PC.PlayerReplicationInfo.Team == None) || (PC.PlayerReplicationInfo.Team.TeamIndex == 0);

	UpdateIcons(Enemy, EnemyIcons, !bIsRedIconType);
	UpdateIcons(MyTeam, MyTeamIcons, bIsRedIconType);

	// flags
	d.hasX = true; d.hasY = true;
	d.hasVisible = true;
	d.Visible = true;
	if ( UTTeamInfo(PC.PlayerReplicationInfo.Team) != None )
	{
		for ( j=0; j<2; j++ )
		{
			Team = UTTeamInfo(ThisWorld.GRI.Teams[j]);
			if (Team != None && Team.TeamFlag != None)
			{
				bInSensorRange = true;//Team.TeamFlag.ShouldMinimapRenderFor(PC);
/*
				i = 0;
				if ( !bInSensorRange )
				{
					for ( i=0; i<Sensors.Length; i++ )
					{
						if ( VSizeSq(Team.TeamFlag.Location - Sensors[i].Location) < Square(Sensors[i].MaxSensorRange) )
						{
							bInSensorRange = true;
							break;
						}
					}
				}
*/
				if ( bInSensorRange )
				{
					d.visible = true;
					V = TransformVector(IconMatrix, Team.TeamFlag.Location);
					V.Z = 0;
					// place flag icon on minimap frame if too far away
					if (VSizeSq(V) > Hud.Radius*Hud.Radius)
						V = Normal(V) * Hud.Radius;
					d.X = V.X;
					d.Y = V.Y;
				}
				else
					d.visible = false;

				FlagIcons[j].SetDisplayInfo(d);
			}
		}
	}
}

defaultproperties
{
    IconsRedCount = 0
    IconsBlueCount = 0
    IconsFlagCount = 0
}
