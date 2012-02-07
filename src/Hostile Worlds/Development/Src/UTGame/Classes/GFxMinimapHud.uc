/**********************************************************************

Copyright   :   Copyright 2006-2007 Scaleform Corp. All Rights Reserved.

Portions of the integration code is from Epic Games as identified by Perforce annotations.
Copyright 2010 Epic Games, Inc. All rights reserved.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/

/**
 * GFx HUD Demo for UTGame.
 * Related Flash content:   ut3_hud.fla
 * 
 * 
 */

class GFxMinimapHud extends GFxMoviePlayer;

var WorldInfo    ThisWorld;
var GFxMinimap   Minimap;
var float        Radius;
var float        CurZoomf, NormalZoomf, MaxZoomf, MinZoomf;

struct MessageRow
{
	var GFxObject  MC, TF;
	var float     StartFadeTime;
	var int       Y;
};

var GFxObject     LogMC;
var array<MessageRow>   Messages, FreeMessages;
var float               MessageHeight;
var int                 NumMessages;

var GFxObject     PlayerStatsMC, TeamStatsMC;
var GFxObject     HealthTF, HealthBarMC, AmmoCountTF, AmmoBarMC, MaxAmmoMC, ArmorTF, ArmorMC, VArmorMC, VArmorTF, TimeTF;
var GFxObject     WeaponMC, ArmorPercTF;

var GFxObject     CenterTextMC, CenterTextTF;
var GFxObject     ScoreBarMC[2], ScoreTF[2], FlagCarrierMC[2], FlagCarrierTF[2], EnemyNameTF;

var GFxObject     HitLocMC[8], MultiKillN_TF, MultiKillMsg_TF, MultiKillMC;
var GFxObject     ReticuleMC, RBotMC, RRightMC, RTopMC, RLeftMC;

var UTVehicle LastVehicle;
var UTWeapon     LastWeapon;
var float        LastHealth, LastArmor, LastVHealth;
var int          LastAmmoCount;
var int          LastScore[2];
var byte         LastFlagHome[2];
var UTPlayerReplicationInfo  LastEnemy, LastFlagCarrier[2];

var UTGameReplicationInfo GRI;

/** IF true, set this HUD up a a team HUD */
var bool bIsTeamHUD;

/** If true, let weapons draw their crosshairs instead of using GFx crosshair */
var bool bDrawWeaponCrosshairs;

/*
 * Callback fired from Flash when Minimap is loaded.
 *   "ExternalInterface.call("RegisterMinimapView", this)";
 *   
 * Used to pass a reference to the MovieClip which is loaded
 * from Flash back to UnrealScript.
 */
function registerMiniMapView(GFxMinimap mc, float r)
{
    Minimap = mc;
	Radius = r;
	CurZoomf = 64;
	NormalZoomf = 64;
	Minimap.Init(self);
	Minimap.SetVisible(false);
	Minimap.SetFloat("_xscale", 85);
	Minimap.SetFloat("_yscale", 85);
}

/*
 * Creates a new LogMessage MovieClip for use in the 
 * log.
 */
function GFxObject CreateMessageRow()
{
	return LogMC.AttachMovie("LogMessage", "logMessage"$NumMessages++);
}

/*
 * Initalizes a new MessageRow and adds it to the list
 * of available log MessageRow MovieClips for reuse.
 */
function GFxObject InitMessageRow()
{
	local MessageRow mrow;

	mrow.Y = 0;
	mrow.MC = CreateMessageRow();

	mrow.TF = mrow.MC.GetObject("message").GetObject("textField");
	mrow.TF.SetBool("html", true);
	mrow.TF.SetString("htmlText", "");

	FreeMessages.AddItem(mrow);
	return mrow.MC;
}

/*
 * Initialization method for HUD.
 * 
 * Caches all the references to MovieClips that will be updated throughout
 * the HUD's lifespan.
 * 
 * For the record, GetVariableObject is not as fast as GFxObject::GetObject() but
 * nevertheless is used here for convenience.
 * 
 */
function Init(optional LocalPlayer player)
{
	local int j;
	local GFxObject TempWidget;
	
	super.Init(player);

	ThisWorld = GetPC().WorldInfo;
	GRI = UTGameReplicationInfo(GetPC().WorldInfo.GRI);

    Start();
    Advance(0);

    NumMessages = 0;
	LastHealth = -110;
	LastArmor = -110;
	LastAmmoCount = -110;
	LastScore[0] = -110;
	LastScore[1] = -110;

	TempWidget = GetVariableObject("_root.expBar"); 
	if ( TempWidget != None ) 
	{ 
		TempWidget.SetBool("_visible", false);
	}

    TempWidget = GetVariableObject("_root.rank"); 
	if ( TempWidget != None ) 
	{
		TempWidget.SetBool("_visible", false);
	}

    TempWidget = GetVariableObject("_root.billboard"); 
	if ( TempWidget != None ) 
	{
		TempWidget.SetBool("_visible", false);
	}

	TempWidget = GetVariableObject("_root.title"); 
	if ( TempWidget != None ) 
	{
		TempWidget.SetBool("_visible", false);
	}
    TempWidget = GetVariableObject("_root.stats"); 
	if ( TempWidget != None ) 
	{
		TempWidget.SetBool("_visible", false);
	}

    TempWidget = GetVariableObject("_root.flag"); 
	if ( TempWidget != None ) 
	{
		TempWidget.SetVisible(false);
	}

	TempWidget = GetVariableObject("_root.teamStats.redWinning"); 
	if ( TempWidget != None ) 
	{
		TempWidget.SetVisible(false);
	}

	TempWidget = GetVariableObject("_root.teamStats.blueWinning"); 
	if ( TempWidget != None ) 
	{
		TempWidget.SetVisible(false);
	}

    LogMC = GetVariableObject("_root.log");
    for (j = 0; j < 15; j++)
		InitMessageRow();

    TeamStatsMC = GetVariableObject("_root.teamStats");
    PlayerStatsMC = GetVariableObject("_root.playerStats");
    PlayerStatsMC.GotoAndStopI(3);
    VArmorTF = GetVariableObject("_root.playerStats.vehicleN");
    VArmorMC = GetVariableObject("_root.playerStats.healthVehicle");
    PlayerStatsMC.GotoAndStopI(2);
    WeaponMC = GetVariableObject("_root.playerStats.weapon");
    HealthTF = GetVariableObject("_root.playerStats.healthN");
    HealthBarMC = GetVariableObject("_root.playerStats.health");
    AmmoCountTF = GetVariableObject("_root.playerStats.ammoN");
    AmmoBarMC = GetVariableObject("_root.playerStats.ammo");
    MaxAmmoMC = GetVariableObject("_root.playerStats.ammo.ammoBG");
    ArmorTF = GetVariableObject("_root.playerStats.armorN");
    ArmorMC = GetVariableObject("_root.playerStats.armor");
    ArmorPercTF = GetVariableObject("_root.playerStats.armorPerc");

	EnemyNameTF = GetVariableObject("_root.teamStats.redName");
	CenterTextTF = GetVariableObject("_root.centerTextMC.centerText.textField");
	CenterTextMC = GetVariableObject("_root.centerTextMC");

    ReticuleMC = GetVariableObject("_root.reticule");
    RBotMC = GetVariableObject("_root.reticule.bottom");
    RTopMC = GetVariableObject("_root.reticule.top");
    RLeftMC = GetVariableObject("_root.reticule.left");
    RRightMC = GetVariableObject("_root.reticule.right");

	MultiKillMC = GetVariableObject("_root.popup");

    TimeTF = GetVariableObject("_root.teamStats.roundTime");

	if ( bIsTeamHUD )
	{
		ScoreBarMC[0] = GetVariableObject("_root.teamStats.teamRed");
		ScoreTF[0] = GetVariableObject("_root.teamStats.scoreRed");
		ScoreBarMC[1] = GetVariableObject("_root.teamStats.teamBlue");
		ScoreTF[1] = GetVariableObject("_root.teamStats.scoreBlue");
		FlagCarrierMC[0] = GetVariableObject("_root.flagRed");
		FlagCarrierMC[1] = GetVariableObject("_root.flagBlue");
	}
	else
	{
		ScoreBarMC[1] = GetVariableObject("_root.teamStats.teamRed");
		ScoreTF[1] = GetVariableObject("_root.teamStats.scoreRed");
		ScoreBarMC[0] = GetVariableObject("_root.teamStats.teamBlue");
		ScoreTF[0] = GetVariableObject("_root.teamStats.scoreBlue");
		FlagCarrierMC[0] = GetVariableObject("_root.flagBlue");
		FlagCarrierMC[1] = GetVariableObject("_root.flagRed");
	}

	if ( bIsTeamHUD )
	{
		EnemyNameTF.SetVisible(false);
		FlagCarrierTF[0] = FlagCarrierMC[0].GetObject("textField");
		FlagCarrierTF[1] = FlagCarrierMC[1].GetObject("textField");
		FlagCarrierTF[0].SetText("");
		FlagCarrierTF[1].SetText("");
	}
	else
	{
		EnemyNameTF.SetText("");
		FlagCarrierMC[0].SetVisible(false);
		FlagCarrierMC[1].SetVisible(false);
		ScoreBarMC[0].SetVisible(false);
		ScoreBarMC[1].SetVisible(false);
		ScoreTF[0].SetVisible(false);
		ScoreTF[1].SetVisible(false);
		TeamStatsMC.SetVisible(false);  // FIXMESTEVE - also removes clock
	}

	HitLocMC[0] = GetVariableObject("_root.dirHit.t");
	HitLocMC[1] = GetVariableObject("_root.dirHit.tr");
	HitLocMC[2] = GetVariableObject("_root.dirHit.r");
	HitLocMC[3] = GetVariableObject("_root.dirHit.br");
	HitLocMC[4] = GetVariableObject("_root.dirHit.b");
	HitLocMC[5] = GetVariableObject("_root.dirHit.bl");
	HitLocMC[6] = GetVariableObject("_root.dirHit.l");
	HitLocMC[7] = GetVariableObject("_root.dirHit.tl");

    LogMC.SetFloat("_yrotation", -15);
    TeamStatsMC.SetFloat("_yrotation", -15);

    FlagCarrierMC[0].SetFloat("_yrotation", 15);
	FlagCarrierMC[1].SetFloat("_yrotation", 15);
    PlayerStatsMC.SetFloat("_yrotation", 15);

    ClearStats(true);
}

static function string FormatTime(int Seconds)
{
	local int Hours, Mins;
	local string NewTimeString;

	Hours = Seconds / 3600;
	Seconds -= Hours * 3600;
	Mins = Seconds / 60;
	Seconds -= Mins * 60;
	if (Hours > 0)
		NewTimeString = ( Hours > 9 ? String(Hours) : "0"$String(Hours)) $ ":";
	NewTimeString = NewTimeString $ ( Mins > 9 ? String(Mins) : "0"$String(Mins)) $ ":";
	NewTimeString = NewTimeString $ ( Seconds > 9 ? String(Seconds) : "0"$String(Seconds));

	return NewTimeString;
}

function ClearStats(optional bool clearScores)
{
	local GFxObject.ASDisplayInfo DI;
	DI.hasXScale = true;
	DI.XScale = 0;

	if (LastVehicle != none)
	{
		PlayerStatsMC.GotoAndStopI(2);
		LastVehicle = none;
	}
	if (LastHealth != -10)
	{
		HealthTF.SetString("text", "");
		HealthBarMC.SetDisplayInfo(DI);
		LastHealth = -10;
	}
	if (LastArmor != -10)
	{
		if (ArmorMC != none)
		{
			ArmorMC.SetVisible(false);
		}
		//ArmorPercTF.SetVisible(false);
		ArmorTF.SetString("text", "");		
		LastArmor = -10;
	}
	if (LastAmmoCount != -10)
	{
		AmmoCountTF.SetString("text", "");
		AmmoBarMC.GotoAndStopI(51);
		LastAmmoCount = -10;
	}
	if (LastWeapon != none)
	{
		WeaponMC.SetVisible(false);
		MaxAmmoMC.GotoAndStopI(51);
		LastWeapon = none;
	}

	if (clearScores && LastScore[0] != -100000)
	{
		if ( bIsTeamHUD )
		{
			LastScore[0] = -100000;
			LastScore[1] = -100000;
			ScoreTF[0].SetString("text", "");
			ScoreTF[1].SetString("text", "");
			ScoreBarMC[0].SetDisplayInfo(DI);
			ScoreBarMC[1].SetDisplayInfo(DI);
			FlagCarrierTF[0].SetText("");
			FlagCarrierTF[1].SetText("");
		}
		TimeTF.SetString("text", "");
		LastEnemy = none;
		EnemyNameTF.SetText("");
	}
}

function RemoveMessage()
{

}

function AddMessage(string type, string msg)
{
	local MessageRow mrow;
	local GFxObject.ASDisplayInfo DI;
	local int j;

	if (Len(msg) == 0)
		return;

	if (FreeMessages.Length > 0)
	{
		mrow = FreeMessages[FreeMessages.Length-1];
		FreeMessages.Remove(FreeMessages.Length-1,1);
	}
	else
	{
		mrow = Messages[Messages.Length-1];
		Messages.Remove(Messages.Length-1,1);
	}

	mrow.TF.SetString(type, msg);
	mrow.Y = 0;
	DI.hasY = true;
	DI.Y = 0;
	mrow.MC.SetDisplayInfo(DI);
	mrow.MC.GotoAndPlay("show");
	for (j = 0; j < Messages.Length; j++)
	{
		Messages[j].Y -= MessageHeight;
		DI.Y = Messages[j].Y;
		Messages[j].MC.SetDisplayInfo(DI);
	}
	Messages.InsertItem(0,mrow);
}

function UpdateGameHUD(UTPlayerReplicationInfo PRI)
{
	local UTPlayerReplicationInfo MaxPRI;
	local int i, j;

	MaxPri = none;
	i = -10000000;
	for (j = 0; j < GRI.PRIArray.length; j++)
	{
		if (GRI.PRIArray[j] != PRI && GRI.PRIArray[j].Score > i && (GRI.PRIArray[j].Score > 0 || GRI.PRIArray[j].Score > PRI.Score))
		{
			i = GRI.PRIArray[j].Score;
			MaxPRI = UTPlayerReplicationInfo(GRI.PRIArray[j]);
		}
	}
	if (MaxPri != LastEnemy)
	{
		EnemyNameTF.SetText(MaxPRI != none ? MaxPRI.PlayerName : "");
		LastEnemy = MaxPri;
	}
}

function TickHud(float DeltaTime)
{
	local UTPawn UTP;
	local UTVehicle UTV;
	local UTWeaponPawn UWP;
	local int TotalArmor;
	local UTWeapon Weapon;
	local int i;
	local float f;
	local UTPlayerReplicationInfo PRI;
	local GFxObject.ASDisplayInfo DI;
	local GFxObject.ASColorTransform Cxform;
	local PlayerController PC;

	PC = GetPC();

	GRI = UTGameReplicationInfo(PC.WorldInfo.GRI);
	PRI = UTPlayerReplicationInfo(PC.PlayerReplicationInfo);

	if ( GRI != None )
	{
		// score & time
		TimeTF.SetString("text", FormatTime(GRI.TimeLimit != 0 ? GRI.RemainingTime : GRI.ElapsedTime));

		if ( PRI != None )
		{
			UpdateGameHUD(PRI);
		}
	}

	UTP = UTPawn(PC.Pawn);

	if (UTP == None)
	{
		UTV = UTVehicle(PC.Pawn);
		if ( UTV == None )
		{
			UWP = UTWeaponPawn(PC.Pawn);
			if ( UWP != None )
			{
				UTV = UTVehicle(UWP.MyVehicle);
				UTP = UTPawn(UWP.Driver);
			}
		}
		else
		{
			UTP = UTPawn(UTV.Driver);
		}

		if (UTV == None)
		{
			ClearStats();
			return;
		}
		else if (UTVehicle_Hoverboard(UTV) != none)
		{
			UTV = none;
		}
	}

	Minimap.Update(CurZoomf);
	if (UTV != LastVehicle)
	{

        if (UTV == none)
			PlayerStatsMC.GotoAndStopI(2);
		else
			PlayerStatsMC.GotoAndStopI(3);

		LastVehicle = UTV;
		LastHealth = -101;
		LastArmor = -101;
		LastAmmoCount = -101;
		LastWeapon = none;
	}

	if (LastHealth != UTP.Health)
	{
		HealthTF.SetText(UTP.Health);
		DI.hasXScale = true;
		DI.XScale = (100.0 * float(UTP.Health)) / float(UTP.HealthMax);

		if (DI.XScale >= 100)
		{
			DI.XScale = 101;

			f = FMin((UTP.Health-100)/100.f + 0.15f, 1);
			Cxform.Multiply.R = 1-f;
			Cxform.Multiply.G = 1-f;
			Cxform.Multiply.B = 1-f;
			Cxform.Add.B = 255.f*f;
		}
		HealthBarMC.SetColorTransform(Cxform);
		HealthBarMC.SetDisplayInfo(DI);
		LastHealth = UTP.Health;
	}

	TotalArmor = UTP.GetShieldStrength();
	if (TotalArmor != LastArmor)
	{
		if (TotalArmor > 0)
		{
			if (ArmorMC != none)
			{
				ArmorMC.SetVisible(true);
				ArmorMC.GotoAndStopI(TotalArmor >= 100 ? 100 : (1 + TotalArmor));
			}
			ArmorTF.SetText(TotalArmor);
			//ArmorPercTF.SetVisible(true);
		}
		else
		{
			if (ArmorMC != none)
			{
				ArmorMC.SetVisible(false);
			}
			ArmorTF.SetText("");
			//ArmorPercTF.SetVisible(false);
		}
		LastArmor = TotalArmor;
	}

	Weapon = UTWeapon(UTP.Weapon);
	if (Weapon != none && UTV == none)
	{
		if (Weapon != LastWeapon)
		{
			if (Weapon.AmmoDisplayType == EAWDS_None)
				AmmoCountTF.SetText("");
			i = (Weapon.MaxAmmoCount > 50 ? 50 : Weapon.MaxAmmoCount);
			MaxAmmoMC.GotoAndStopI(51 - i);
			WeaponMC.SetVisible(true);
			WeaponMC.GotoAndStopI(Weapon.InventoryGroup);
			LastWeapon = Weapon;
		}
		i = Weapon.GetAmmoCount();
		if (i != LastAmmoCount)
		{
			LastAmmoCount = i;
			AmmoCountTF.SetText(i);
			if (i > 50)
				i = 50;
			AmmoBarMC.GotoAndStopI(51 - i);
			AmmoBarMC.SetVisible(true);
		}
	}
	else if (Weapon != LastWeapon)
	{
		AmmoCountTF.SetText("");
		AmmoBarMC.SetVisible(false);
		WeaponMC.SetVisible(false);
	}

	if (UTV != none)
	{
		if (UTV.Health != LastVHealth)
		{
			VArmorTF.SetText(UTV.Health);
			DI.hasXScale = true;
			DI.XScale = (100.0 * float(UTV.Health)) / float(UTV.HealthMax);
			if (DI.XScale > 100)
				DI.XScale = 100;
			VArmorMC.SetDisplayInfo(DI);
			LastVHealth = UTV.Health;
		}
	}
}

function ToggleCrosshair(bool bToggle)
{
	bToggle = !bDrawWeaponCrosshairs && bToggle && !UTPlayerController(GetPC()).bNoCrosshair && UTHUDBase(GetPC().myHUD).bCrosshairShow;

    ReticuleMC.SetVisible(bToggle);
    RBotMC.SetVisible(bToggle);
    RTopMC.SetVisible(bToggle);
    RLeftMC.SetVisible(bToggle);
    RRightMC.SetVisible(bToggle);
}

function MinimapZoomOut()
{
	if (CurZoomf < MaxZoomf)
		CurZoomf *= 2;
}

function MinimapZoomIn()
{
	if (CurZoomf > MinZoomf)
		CurZoomf *= 0.5;
}

function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
	local Vector Loc;
	local Rotator Rot;
	local float DirOfHit;
	local vector AxisX, AxisY, AxisZ;
	local vector ShotDirection;
	local bool bIsInFront;
	local vector2D	AngularDist;

	if ( damageType.default.bLocationalHit )
	{
		// Figure out the directional based on the victims current view
		GetPC().GetPlayerViewPoint(Loc, Rot);
		GetAxes(Rot, AxisX, AxisY, AxisZ);

		ShotDirection = Normal(HitDir - Loc);
		bIsInFront = GetAngularDistance( AngularDist, ShotDirection, AxisX, AxisY, AxisZ);
		GetAngularDegreesFromRadians(AngularDist);
		DirOfHit = AngularDist.X;

		if( bIsInFront )
		{
			DirOfHit = AngularDist.X;
			if (DirOfHit < 0)
			DirOfHit += 360;
		}
		else
			DirOfHit = 180 + AngularDist.X;
	}
	else
		DirOfHit = 180;

	HitLocMC[int(DirOfHit/45.f)].GotoAndPlay("on");
}

function ShowMultiKill(int n, string msg)
{
	if (MultiKillN_TF == none)
	{
		MultiKillN_TF = GetVariableObject("_root.popup.popupNumber.textField");
		MultiKillMsg_TF = GetVariableObject("_root.popup.popupText.textField");
	}

	MultiKillN_TF.SetText(n+1);
	MultiKillMsg_TF.SetText(msg);
	MultiKillMC.GotoAndPlay("on");
}

function SetCenterText(string text)
{
	CenterTextTF.SetText(text);
	CenterTextMC.GotoAndPlay("on");
}

function string GetRank(PlayerReplicationInfo PRI)
{
	local int i;
	local int j;

	i = -10000000;
	for (j = 0; j < GRI.PRIArray.length; j++)
	{
		if (GRI.PRIArray[j].Score > i)
		{
			i = GRI.PRIArray[j].Score;
		}
	}
	if (PRI.Score >= i && PRI.Score > 0)
		return "<img src='rank15'>";
	return "";
}

function AddDeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed, class<UTDamageType> Dmg)
{
	local string msg;
	local byte index;

	if (Killer != none)
		msg = GetRank(Killer) @ Killer.PlayerName;
	if ((Dmg!= None) && (Dmg.default.DamageWeaponClass != none) )
	{
		// Linkgun used to be InventoryGroup=5 in UT3, so need special case here
		index = ClassIsChildOf(Dmg.default.DamageWeaponClass, class'UTWeap_Linkgun') ? 5 : Dmg.default.DamageWeaponClass.default.InventoryGroup;
	}

	if ( index < 12 )
		msg @= "<img src='ut3_weapon" $ index $ "'>";
	else
		msg @= "<img src='skull'>";

	msg @= GetRank(Killed) @ Killed.PlayerName;

	AddMessage("htmlText", msg);
}

defaultproperties
{
	bDisplayWithHudOff=FALSE
	MinZoomf=16
	MaxZoomf=128
	MessageHeight=38
	MovieInfo=SwfMovie'UDKHud.udk_hud'
	bEnableGammaCorrection=false
	bDrawWeaponCrosshairs=true

	bAllowInput=FALSE;
	bAllowFocus=FALSE;
}
