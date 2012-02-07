/**
 * UT Heads Up Display
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTHUD extends UTHUDBase
	dependson(UTWeapon)
	config(Game);

var class<UTLocalMessage> WeaponSwitchMessage;

/** Cached reference to the another hud texture */
var const Texture2D AltHudTexture;
var const Texture2D TalkingTexture;
var const Texture2D UT3GHudTexture;

var const LinearColor LC_White;

var const color GrayColor;

/** used to pulse the scaled of several hud elements */
var float LastAmmoPickupTime, LastHealthPickupTime, LastArmorPickupTime;

/** The Pawn that is currently owning this hud */
var Pawn PawnOwner;

/** Points to the UT Pawn.  Will be resolved if in a vehicle */
var UTPawn UTPawnOwner;

/** Cached typed reference to the PRI */
var UTPlayerReplicationInfo UTOwnerPRI;

/** Debug flag to show AI information */
var bool bShowAllAI;

var bool bHudMessageRendered;

/******************************************************************************************
  UI/SCENE data for the hud
 ******************************************************************************************/

/** The Scoreboard. */
var UTUIScene_Scoreboard ScoreboardSceneTemplate;

/** A collection of fonts used in the hud */
var array<font> HudFonts;

/******************************************************************************************
 Character Portraits
 ******************************************************************************************/

/** The material used to display the portrait */
var material CharPortraitMaterial;

/** The MI that we will set */
var MaterialInstanceConstant CharPortraitMI;

/** How far down the screen will it be rendered */
var float CharPortraitYPerc;

/** When sliding in, where should this image stop */
var float CharPortraitXPerc;

/** How long until we are done */
var float CharPortraitTime;

/** Total Amount of time to display a portrait for */
var float CharPortraitSlideTime;

/** % of Total time to slide In/Out.  It will be used on both sides.  Ex.  If set to 0.25 then
    the slide in will be 25% of the total time as will the slide out leaving 50% of the time settled
    on screen. **/
var float CharPortraitSlideTransitionTime;

/** How big at 1024x768 should this be */
var vector2D CharPortraitSize;

/** Holds the PRI of the person speak */
var UTPlayerReplicationInfo CharPRI;

/** Holds the PRI of who we want to switch to */
var UTPlayerReplicationInfo CharPendingPRI;


/******************************************************************************************
 WEAPONBAR
 ******************************************************************************************/

/** If true, weapon bar is never displayed */
var config bool bShowWeaponbar;

/** If true, only weapon bar if have pendingweapon */
var config bool bOnlyShowWeaponBarIfChanging;

/** Scaling to apply to entire weapon bar */
var float WeaponBarScale;

var float WeaponBoxWidth, WeaponBoxHeight;

/** Resolution dependent HUD scaling factor */
var float HUDScaleX, HUDScaleY;
var linearcolor TeamHUDColor;
var color TeamTextColor;

/** Weapon bar top left corner at 1024x768, normal scale */
var float WeaponBarY;

/** List of weapons to display in weapon bar */
var UTWeapon WeaponList[10];
var float CurrentWeaponScale[10];

var float SelectedWeaponScale;
var float BounceWeaponScale;
var float SelectedWeaponAlpha;
var float OffWeaponAlpha;
var float EmptyWeaponAlpha;
var float LastHUDUpdateTime;
var int BouncedWeapon;
var float WeaponScaleSpeed;
var float WeaponBarXOffset;
var float WeaponXOffset;
var float SelectedBoxScale;
var float WeaponYScale;
var float WeaponYOffset;
var float WeaponAmmoLength;
var float WeaponAmmoThickness;
var float WeaponAmmoOffsetX;
var float WeaponAmmoOffsetY;
var float SelectedWeaponAmmoOffsetX;
var bool bNoWeaponNumbers;
var float LastWeaponBarDrawnTime;

/******************************************************************************************
 MOTD
 ******************************************************************************************/

var UTUIScene_MOTD MOTDSceneTemplate;

/******************************************************************************************
 Messaging
 ******************************************************************************************/

/** Y offsets for local message areas - value above 1 = special position in right top corner of HUD */
var float MessageOffset[7];

/******************************************************************************************
 Map / Radar
 ******************************************************************************************/

/** The background texture for the map */
var Texture2D MapBackground;

/** Holds the default size in pixels at 1024x768 of the map */
var config float MapDefaultSize;

/** The orders to display when rendering the map */
var string DisplayedOrders;

/** last time at which displayedorders was updated */
var float OrderUpdateTime;

var Weapon LastSelectedWeapon;

/******************************************************************************************
 Safe Regions
 ******************************************************************************************/

/** The percentage of the view that should be considered safe */
var config float SafeRegionPct;

/** Holds the full width and height of the viewport */
var float FullWidth, FullHeight;

/******************************************************************************************
 The damage direction indicators
 ******************************************************************************************/
/**
 * Holds the various data for each Damage Type
 */
struct native DamageInfo
{
	var	float	FadeTime;
	var float	FadeValue;
	var MaterialInstanceConstant MatConstant;
};

/** Holds the Max. # of indicators to be shown */
var int MaxNoOfIndicators;

/** List of DamageInfos. */
var array<DamageInfo> DamageData;

/** This holds the base material that will be displayed */
var Material BaseMaterial;

/** How fast should it fade out */
var float FadeTime;

/** Name of the material parameter that controls the position */
var name PositionalParamName;

/** Name of the material parameter that controls the fade */
var name FadeParamName;

/******************************************************************************************
 The Distortion Effect (Full Screen)
 ******************************************************************************************/

/** current hit effect intensity (default.HitEffectIntensity is max) */
var float HitEffectIntensity;

/** maximum hit effect color */
var LinearColor MaxHitEffectColor;

/** whether we're currently fading out the hit effect */
var bool bFadeOutHitEffect;

/** the amount the time it takes to fade the hit effect from the maximum values (default.HitEffectFadeTime is max) */
var float HitEffectFadeTime;

/** reference to the hit effect */
var MaterialEffect HitEffect;

/** material instance for the hit effect */
var transient MaterialInstanceConstant HitEffectMaterialInstance;

/******************************************************************************************
 Widget Locations / Visibility flags
 ******************************************************************************************/

var globalconfig bool bShowClock;
var vector2d ClockPosition;

var globalconfig bool bShowDoll;
var vector2d DollPosition;
var float LastDollUpdate;
var float DollVisibility;

var TextureCoordinates HealthBGCoords;
var float HealthOffsetX;
var float HealthBGOffsetX;   //position of the health bg relative to overall lower left position
var float HealthBGOffsetY;
var float HealthIconX;	   //position of the health + icon relative to the overall left position
var float HealthIconY;
var float HealthTextX;	  //position of the health text relative to the overall left position
var float HealthTextY;
var int LastHealth;
var float HealthPulseTime;

var TextureCoordinates ArmorBGCoords;
var float ArmorBGOffsetX;	//position of the armor bg relative to overall lower left position
var float ArmorBGOffsetY;
var float ArmorIconX;	   //position of the armor shield icon relative to the overall left position
var float ArmorIconY;
var float ArmorTextX;	   //position of the armor text relative to the overall left position
var float ArmorTextY;
var int LastArmorAmount;
var float ArmorPulseTime;

var globalconfig bool bShowAmmo;
var vector2d AmmoPosition;
var float AmmoBarOffsetY; //Padding beneath right side ammo/icon
var TextureCoordinates AmmoBGCoords;
var float AmmoTextOffsetX;
var float AmmoTextOffsetY;

var UTWeapon LastWeapon;
var int LastAmmoCount;
var float AmmoPulseTime;

var bool bHasMap;
var globalconfig bool bShowMap;
var vector2d MapPosition;

var globalconfig bool bShowPowerups;
var vector2d PowerupDims;
var float PowerupYPos;

/** How long to fade */
var float PowerupTransitionTime;

/** true while displaying powerups */
var bool bDisplayingPowerups;

var globalconfig bool bShowScoring;
var vector2d ScoringPosition;
var bool bShowFragCount;

var bool bHasLeaderboard;
var bool bShowLeaderboard;

var float FragPulseTime;
var int LastFragCount;

var globalconfig bool bShowVehicle;
var vector2d VehiclePosition;
var bool bShowVehicleArmorCount;

var globalconfig float DamageIndicatorSize;

/** width of background on either side of the nameplate */
var float NameplateWidth;
var float NameplateBubbleWidth;

/** Coordinates of the nameplate background*/
var TextureCoordinates NameplateLeft;
var TextureCoordinates NameplateCenter;
var TextureCoordinates NameplateBubble;
var TextureCoordinates NameplateRight;

var LinearColor BlackBackgroundColor;

/******************************************************************************************
 Localize Strings 
 ******************************************************************************************/

var localized string WarmupString;				// displayed when playing warmup round
var localized string WaitingForMatch;			// Waiting for the match to begin
var localized string PressFireToBegin;			// Press [Fire] to begin
var localized string SpectatorMessage;			// When you are a spectator
var localized string DeadMessage;				// When you are dead
var localized string FireToRespawnMessage;  	// Press [Fire] to Respawn
var localized string YouHaveWon;				// When you win the match
var localized string YouHaveLost;				// You have lost the match

var localized string PlaceMarks[4];

/************************************************************************/
/*  Pawndoll                                                            */
/************************************************************************/
var TextureCoordinates PawnDollBGCoords;
var float DollOffsetX;		//position of the armor bg relative to overall lower left position	
var float DollOffsetY;
var float DollWidth;
var float DollHeight;
var float VestX;			//Body armor position relative to doll
var float VestY;
var float VestWidth;
var float VestHeight;
var float ThighX;		    //Thigh armor position relative to doll
var float ThighY;
var float ThighWidth;
var float ThighHeight;
var float HelmetX;		    //Helmet armor position relative to doll
var float HelmetY;
var float HelmetWidth;
var float HelmetHeight;
var float BootX;			//Jump boot position relative to doll
var float BootY;
var float BootWidth;
var float BootHeight;

/******************************************************************************************
 Misc vars used for laying out the hud
 ******************************************************************************************/

var float THeight;
var float TX;
var float TY;

// Colors
var const linearcolor AmmoBarColor, RedLinearColor, BlueLinearColor, DMLinearColor, WhiteLinearColor, GoldLinearColor, SilverLinearColor;

/******************************************************************************************
 Splitscreen
 ******************************************************************************************/

/** This will be true if this is the first player */
var bool bIsFirstPlayer;

var() texture2D BkgTexture;
var() TextureCoordinates BkgTexCoords;
var() color BkgTexColor;

/**
 * Draws a textured centered around the current position
 */
function DrawTileCentered(texture2D Tex, float xl, float yl, float u, float v, float ul, float vl, LinearColor C)
{
	local float x,y;

	x = Canvas.CurX - (xl * 0.5);
	y = Canvas.CurY - (yl * 0.5);

	Canvas.SetPos(x,y, Canvas.CurZ);
	Canvas.DrawTile(Tex, xl,yl,u,v,ul,vl,C);
}

function SetDisplayedOrders(string OrderText)
{
	DisplayedOrders = OrderText;
	OrderUpdateTime = WorldInfo.TimeSeconds;
}

exec function ShowMenu()
{
	UTPlayerController(PlayerOwner).ShowMidGameMenu('ScoreTab',true);
}

/** Add missing elements to HUD */
exec function GrowHUD()
{
	if ( Class'WorldInfo'.Static.IsConsoleBuild() )
	{
		return;
	}

	if ( !bShowDoll )
	{
		bShowDoll = true;
	}
	else if ( !bShowAmmo || !bShowVehicle )
	{
		bShowAmmo = true;
		bShowVehicle = true;
	}
	else if ( !bShowScoring )
	{
		bShowScoring = true;
	}
	else if ( !bShowWeaponbar )
	{
		bShowWeaponBar = true;
	}
	else if ( !bShowVehicleArmorCount )
	{
		bShowVehicleArmorCount = true;
	}
	else if ( !bShowPowerups )
	{
		bShowPowerups = true;
	}
	else if ( !bShowMap || !bShowLeaderboard )
	{
		bShowMap = true;
		bShowLeaderboard = true;
	}
	else if ( !bShowClock )
	{
		bShowClock = true;
	}
}

/** Remove elements from HUD */
exec function ShrinkHUD()
{
	if ( Class'WorldInfo'.Static.IsConsoleBuild() )
	{
		return;
	}

	if ( bShowClock )
	{
		bShowClock = false;
	}
	else if ( bShowMap || bShowLeaderboard )
	{
		bShowMap = false;
		bShowLeaderboard = false;
	}
	else if ( bShowPowerups )
	{
		bShowPowerups = false;
	}
	else if ( bShowVehicleArmorCount )
	{
		bShowVehicleArmorCount = false;
	}
	else if ( bShowWeaponbar )
	{
		bShowWeaponBar = false;
	}
	else if ( bShowScoring )
	{
		bShowScoring = false;
	}
	else if ( bShowAmmo || bShowVehicle )
	{
		bShowAmmo = false;
		bShowVehicle = false;
	}
	else if ( bShowDoll )
	{
		bShowDoll = false;
	}
}

/**
 * Create a list of actors needing post renders for.  Also Create the Hud Scene
 */
simulated function PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();

	if ( UTConsolePlayerController(PlayerOwner) != None )
	{
		bNoWeaponNumbers = true;
	}

	// Setup Damage indicators,etc.

	// Create the 3 Damage Constants
	DamageData.Length = MaxNoOfIndicators;

	for (i = 0; i < MaxNoOfIndicators; i++)
	{
		DamageData[i].FadeTime = 0.0f;
		DamageData[i].FadeValue = 0.0f;
		DamageData[i].MatConstant = new(self) class'MaterialInstanceConstant';
		if (DamageData[i].MatConstant != none && BaseMaterial != none)
		{
			DamageData[i].MatConstant.SetParent(BaseMaterial);
		}
	}

	// create hit effect material instance
	HitEffect = MaterialEffect(LocalPlayer(UTPlayerOwner.Player).PlayerPostProcess.FindPostProcessEffect('HitEffect'));
	if (HitEffect != None)
	{
		if (MaterialInstanceConstant(HitEffect.Material) != None && HitEffect.Material.GetPackageName() == 'Transient')
		{
			// the runtime material already exists; grab it
			HitEffectMaterialInstance = MaterialInstanceConstant(HitEffect.Material);
		}
		else
		{
			HitEffectMaterialInstance = new(HitEffect) class'MaterialInstanceConstant';
			HitEffectMaterialInstance.SetParent(HitEffect.Material);
			HitEffect.Material = HitEffectMaterialInstance;
		}
		HitEffect.bShowInGame = false;
	}
}

function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType, optional float LifeTime )
{
	local class<LocalMessage> MsgClass;

	if ( bMessageBeep )
	{
		PlayerOwner.PlayBeepSound();
	}

	MsgClass = class'UTSayMsg';
	if (MsgType == 'Say' || MsgType == 'TeamSay')
	{
		Msg = PRI.PlayerName$": "$Msg;
		if (MsgType == 'TeamSay')
		{
			MsgClass = class'UTTeamSayMsg';
		}
	}

	AddConsoleMessage(Msg, MsgClass, PRI, LifeTime);
}

/**
 * Given a default screen position (at 1024x768) this will return the hud position at the current resolution.
 * NOTE: If the default position value is < 0.0f then it will attempt to place the right/bottom face of
 * the "widget" at that offset from the ClipX/Y.
 *
 * @Param Position		The default position (in 1024x768 space)
 * @Param Width			How wide is this "widget" at 1024x768
 * @Param Height		How tall is this "widget" at 1024x768
 *
 * @returns the hud position
 */
function Vector2D ResolveHUDPosition(vector2D Position, float Width, float Height)
{
	local vector2D FinalPos;
	FinalPos.X = (Position.X < 0) ? Canvas.ClipX - (Position.X * ResolutionScale) - (Width * ResolutionScale)  : Position.X * ResolutionScale;
	FinalPos.Y = (Position.Y < 0) ? Canvas.ClipY - (Position.Y * ResolutionScale) - (Height * ResolutionScale) : Position.Y * ResolutionScale;

	return FinalPos;
}


/* toggles displaying scoreboard (used by console controller)
*/
exec function ReleaseShowScores()
{
	SetShowScores(false);
}

exec function SetShowScores(bool bNewValue)
{
	local UTGameReplicationInfo GRI;

	if (!bNewValue && (WorldInfo.IsInSeamlessTravel() || (UTPlayerOwner != None && UTPlayerOwner.bDedicatedServerSpectator)))
	{
		return;
	}

	GRI = UTGameReplicationInfo(WorldInfo.GRI);

	if ( GRI != none )
	{
		GRI.ShowScores(bNewValue, UTPlayerOwner, ScoreboardSceneTemplate);
	}
}

function GetScreenCoords(float PosY, out float ScreenX, out float ScreenY, out HudLocalizedMessage InMessage )
{
	local float Offset, MapSize;

	if ( PosY > 1.0 )
	{
		// position under minimap
		Offset = PosY - int(PosY);
		if ( Offset < 0 )
		{
			Offset = Offset + 1.0;
		}
		if ( bIsSplitScreen )
		{
			ScreenY = (0.15 + Offset) * Canvas.ClipY;
		}
		else
		{
		ScreenY = (0.38 + Offset) * Canvas.ClipY;
		}
		ScreenX = 0.98 * Canvas.ClipX - InMessage.DX;
		return;
	}

    ScreenX = 0.5 * Canvas.ClipX;
    ScreenY = (PosY * HudCanvasScale * Canvas.ClipY) + (((1.0f - HudCanvasScale) * 0.5f) * Canvas.ClipY);

    ScreenX -= InMessage.DX * 0.5;
    ScreenY -= InMessage.DY * 0.5;

	// make sure not behind minimap
   	if ( bHasMap && bShowMap && !bIsSplitScreen )
   	{
		MapSize = MapDefaultSize * Canvas.ClipY/768;
		if ( (ScreenY < MapPosition.Y*Canvas.ClipY + MapSize)
			&& (ScreenX + InMessage.DX > MapPosition.X*Canvas.ClipX - MapSize) )
		{
			// adjust left from minimap
			ScreenX = FMax(1, MapPosition.X*Canvas.ClipX - MapSize - InMessage.DX);
		}
	}
}


function DrawMessageText(HudLocalizedMessage LocalMessage, float ScreenX, float ScreenY)
{
	local color CanvasColor;
	local string StringMessage;

	if ( Canvas.Font == none )
	{
		Canvas.Font = GetFontSizeIndex(0);
	}

	StringMessage = LocalMessage.StringMessage;
	if ( LocalMessage.Count > 0 )
	{
		if ( Right(StringMessage, 1) ~= "." )
		{
			StringMessage = Left(StringMessage, Len(StringMessage) -1);
		}
		StringMessage = StringMessage$" X "$LocalMessage.Count;
	}

	CanvasColor = Canvas.DrawColor;

	// first draw drop shadow string
	Canvas.DrawColor = BlackColor;
	Canvas.DrawColor.A = CanvasColor.A;
	Canvas.SetPos( ScreenX+2, ScreenY+2 );
	Canvas.DrawText( StringMessage, false, , , TextRenderInfo );

	// now draw string with normal color
	Canvas.DrawColor = CanvasColor;
	Canvas.SetPos( ScreenX, ScreenY );
	Canvas.DrawText( StringMessage, false, , , TextRenderInfo );
}

/**
 * Perform any value precaching, and set up various safe regions
 *
 * NOTE: NO DRAWING should ever occur in PostRender.  Put all drawing code in DrawHud().
 */
event PostRender()
{
	local int TeamIndex;
	local LocalPlayer Lp;

	bIsSplitscreen = class'Engine'.static.IsSplitScreen();
	LP = LocalPlayer(PlayerOwner.Player);
	bIsFirstPlayer = (LP != none) && (LP.Outer.GamePlayers[0] == LP);

	UTGRI = UTGameReplicationInfo(WorldInfo.GRI);

	// Clear the flag
	bHudMessageRendered = false;

	PawnOwner = Pawn(PlayerOwner.ViewTarget);
	if ( PawnOwner == None )
	{
		PawnOwner = PlayerOwner.Pawn;
	}

	UTPawnOwner = UTPawn(PawnOwner);
	if ( UTPawnOwner == none )
	{
		if ( UDKVehicleBase(PawnOwner) != none )
		{
			UTPawnOwner = UTPawn( UDKVehicleBase(PawnOwner).Driver);
		}
	}

	UTOwnerPRI = UTPlayerReplicationInfo(UTPlayerOwner.PlayerReplicationInfo);

	// draw any debug text in real-time
	PlayerOwner.DrawDebugTextList(Canvas,RenderDelta);

	// Cache the current Team Index of this hud and the GRI
	TeamIndex = 2;
	if ( PawnOwner != None )
	{
		if ( (PawnOwner.PlayerReplicationInfo != None) && (PawnOwner.PlayerReplicationInfo.Team != None) )
		{
			TeamIndex = PawnOwner.PlayerReplicationInfo.Team.TeamIndex;
		}
	}
	else if ( (PlayerOwner.PlayerReplicationInfo != None) && (PlayerOwner.PlayerReplicationInfo.team != None) )
	{
		TeamIndex = PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;
	}

	HUDScaleX = Canvas.ClipX/1280;
	HUDScaleY = Canvas.ClipX/1280;

	ResolutionScaleX = Canvas.ClipX/1024;
	ResolutionScale = Canvas.ClipY/768;
	if ( bIsSplitScreen )
		ResolutionScale *= 2.0;

	GetTeamColor(TeamIndex, TeamHUDColor, TeamTextColor);

	FullWidth = Canvas.ClipX;
	FullHeight = Canvas.ClipY;

	// Always update the Damage Indicator
	UpdateDamage();

	// Handle displaying the scoreboard.  Allow the Mid Game Menu to override displaying
	// it.
	if ( bShowScores || (UTGRI == None) || (UTGRI.CurrentMidGameMenu != none) )
	{
		return;
	}

	if ( UTPlayerOwner.bViewingMap )
	{
		return;
	}

	if ( bShowHud && bShowGameHud )
	{
		DrawHud();
	}

	// let iphone draw any always present overlays

	if (bShowMobileHud)
	{
		DrawInputZoneOverlays();
	}

	RenderMobileMenu();
}

/**
 * This is the main drawing pump.  It will determine which hud we need to draw (Game or PostGame).  Any drawing that should occur
 * regardless of the game state should go here.
 */
function DrawHUD()
{
	local float x,y,w,h,xl,yl;
	local vector ViewPoint;
	local rotator ViewRotation;

	// post render actors before creating safe region
	if (UTGRI != None && !UTGRI.bMatchIsOver && bShowHud && PawnOwner != none  )
	{
		Canvas.Font = GetFontSizeIndex(0);
		PlayerOwner.GetPlayerViewPoint(ViewPoint, ViewRotation);
		DrawActorOverlays(Viewpoint, ViewRotation);
	}

	// Create the safe region
	w = FullWidth * SafeRegionPct;
	X = Canvas.OrgX + (Canvas.ClipX - w) * 0.5;

	// We have some extra logic for figuring out how things should be displayed
	// in split screen.

	h = FullHeight * SafeRegionPct;

	if ( bIsSplitScreen )
	{
		if ( bIsFirstPlayer )
		{
			Y = Canvas.ClipY - H;
		}
		else
		{
			Y = 0.0f;
		}
	}
	else
	{
		Y = Canvas.OrgY + (Canvas.ClipY - h) * 0.5;
	}

	Canvas.OrgX = X;
	Canvas.OrgY = Y;
	Canvas.ClipX = w;
	Canvas.ClipY = h;
	Canvas.Reset(true);

	// Set up delta time
	RenderDelta = WorldInfo.TimeSeconds - LastHUDRenderTime;
	LastHUDRenderTime = WorldInfo.TimeSeconds;

	// If we are not over, draw the hud
	if (UTGRI != None && !UTGRI.bMatchIsOver)
	{
		PlayerOwner.DrawHud( Self );
		DrawGameHud();
	}
	else	// Match is over
	{
		DrawPostGameHud();

		// still draw pause message
		if ( WorldInfo.Pauser != None )
		{
			Canvas.Font = GetFontSizeIndex(2);
			Canvas.Strlen(class'UTGameViewportClient'.default.LevelActionMessages[1],xl,yl);
			Canvas.SetDrawColor(255,255,255,255);
			Canvas.SetPos(0.5*(Canvas.ClipX - XL), 0.44*Canvas.ClipY);
			Canvas.DrawText(class'UTGameViewportClient'.default.LevelActionMessages[1]);
		}
	}

	LastHUDUpdateTime = WorldInfo.TimeSeconds;
}

exec function ShowAllAI()
{
	bShowAllAI = !bShowAllAI;
}

exec function ShowSquadRoutes()
{
	local UTBot B;
	local int i, j;
	local byte Red, Green, Blue;

	if (PawnOwner != None)
	{
		B = UTBot(PawnOwner.Controller);
		if (B != None && B.Squad != None)
		{
			FlushPersistentDebugLines();
			for (i = 0; i < B.Squad.SquadRoutes.length; i++)
			{
				Red = Rand(255);
				Green = Rand(255);
				Blue = Rand(255);
				for (j = 0; j < B.Squad.SquadRoutes[i].RouteCache.length - 1; j++)
				{
					DrawDebugLine( B.Squad.SquadRoutes[i].RouteCache[j].Location,
							B.Squad.SquadRoutes[i].RouteCache[j + 1].Location,
							Red, Green, Blue, true );
				}
			}
		}
	}
}

/**
 * This function is called to draw the hud while the game is still in progress.  You should only draw items here
 * that are always displayed.  If you want to draw something that is displayed only when the player is alive
 * use DrawLivingHud().
 */
function DrawGameHud()
{
	local float xl, yl, ypos;
	local float TempResScale;
	local Pawn P;
	local int i, len;
	local UniqueNetId OtherPlayerNetId;

	// Draw any spectator information
	if (UTOwnerPRI != None)
	{
		if (UTOwnerPRI.bOnlySpectator || UTPlayerOwner.IsInState('Spectating'))
		{
			P = Pawn(UTPlayerOwner.ViewTarget);
			if (P != None && P.PlayerReplicationInfo != None && P.PlayerReplicationInfo != UTOwnerPRI)
			{
				if (  UTPlayerOwner.bBehindView )
				{
				DisplayHUDMessage(SpectatorMessage @ "-" @ P.PlayerReplicationInfo.PlayerName, 0.05, 0.15);
			}
			}
			else
			{
				DisplayHUDMessage(SpectatorMessage, 0.05, 0.15);
			}
		}
		else if ( UTOwnerPRI.bIsSpectator )
		{
			if (UTGRI != None && UTGRI.bMatchHasBegun)
			{
				DisplayHUDMessage(PressFireToBegin);
			}
			else
			{
				DisplayHUDMessage(WaitingForMatch);
			}

		}
		else if ( UTPlayerOwner.IsDead() )
		{
		 	DisplayHUDMessage( UTPlayerOwner.bFrozen ? DeadMessage : FireToRespawnMessage );
		}
	}

	// Draw the Warmup if needed
	if (UTGRI != None && UTGRI.bWarmupRound)
	{
		Canvas.Font = GetFontSizeIndex(2);
		Canvas.DrawColor = WhiteColor;
		Canvas.StrLen(WarmupString, XL, YL);
		Canvas.SetPos((Canvas.ClipX - XL) * 0.5, Canvas.ClipY * 0.175);
		Canvas.DrawText(WarmupString);
	}

	if ( bCrosshairOnFriendly )
	{
		// verify that crosshair trace might hit friendly
		bGreenCrosshair = CheckCrosshairOnFriendly();
		bCrosshairOnFriendly = false;
	}
	else
	{
		bGreenCrosshair = false;
	}

	if ( bShowDebugInfo )
	{
		Canvas.Font = GetFontSizeIndex(0);
		Canvas.DrawColor = ConsoleColor;
		Canvas.StrLen("X", XL, YL);
		YPos = 0;
		PlayerOwner.ViewTarget.DisplayDebug(self, YL, YPos);

		if (ShouldDisplayDebug('AI') && (Pawn(PlayerOwner.ViewTarget) != None))
		{
			DrawRoute(Pawn(PlayerOwner.ViewTarget));
		}
		return;
	}

	if (bShowAllAI)
	{
		DrawAIOverlays();
	}

	if ( WorldInfo.Pauser != None )
	{
		Canvas.Font = GetFontSizeIndex(2);
		Canvas.Strlen(class'UTGameViewportClient'.default.LevelActionMessages[1],xl,yl);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.SetPos(0.5*(Canvas.ClipX - XL), 0.44*Canvas.ClipY);
		Canvas.DrawText(class'UTGameViewportClient'.default.LevelActionMessages[1]);
	}

	DisplayLocalMessages();
	DisplayConsoleMessages();

	Canvas.Font = GetFontSizeIndex(1);

	// Check if any remote players are using VOIP
	if ( (CharPRI == None) && (PlayerOwner.VoiceInterface != None) && (WorldInfo.NetMode != NM_Standalone)
		&& (WorldInfo.GRI != None) )
	{
		len = WorldInfo.GRI.PRIArray.Length;
		for ( i=0; i<len; i++ )
		{
			OtherPlayerNetId = WorldInfo.GRI.PRIArray[i].UniqueID;
			if ( PlayerOwner.VoiceInterface.IsRemotePlayerTalking(OtherPlayerNetId)
				&& (WorldInfo.GRI.PRIArray[i] != PlayerOwner.PlayerReplicationInfo)
				&& (UTPlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]) != None)
				&& (PlayerOwner.GameplayVoiceMuteList.Find('Uid', OtherPlayerNetId.Uid) == INDEX_NONE) )
			{
				ShowPortrait(UTPlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]));
				break;
			}
		}
	}

	// Draw the character portrait
	if ( CharPRI != None  )
	{
		DisplayPortrait(RenderDelta);
	}

	if ( bShowClock && !bIsSplitScreen )
	{
   		DisplayClock();
   	}

	if (bIsSplitScreen && bShowScoring)
	{
		DisplayScoring();
	}

	// If the player isn't dead, draw the living hud
	if ( !UTPlayerOwner.IsDead() )
	{
		DrawLivingHud();
	}

	if ( bHasMap && bShowMap )
	{
		TempResScale = ResolutionScale;
		if (bIsSplitScreen)
		{
			ResolutionScale *=2;
		}
		DisplayMap();
		ResolutionScale = TempResScale;
	}

	DisplayDamage();

	if (UTPlayerOwner.bIsTyping && WorldInfo.NetMode != NM_Standalone)
	{
		DrawMicIcon();
	}
}

function DrawMicIcon()
{
	local vector2d Pos;
	Pos.X = 0.0;
	Pos.Y = Canvas.ClipY * (CharPortraitYPerc + 0.05) + CharPortraitSize.Y * (Canvas.ClipY/768.0) + 6;
	Canvas.SetPos(Pos.X,Pos.Y);
	Canvas.DrawTile(TalkingTexture, 64, 64, 0, 0, 64, 64);
}

function DisplayLocalMessages()
{
	if (!PlayerOwner.bCinematicMode)
	{
		MaxHUDAreaMessageCount = bIsSplitScreen ? 1 : 2;
		Super.DisplayLocalMessages();
	}
}

/**
 * Anything drawn in this function will be displayed ONLY when the player is living.
 */
function DrawLivingHud()
{
    local UTWeapon Weapon;
    local float Alpha;

	if ( !bIsSplitScreen && bShowScoring )
	{
		DisplayScoring();
	}

	// Pawn Doll
	if ( bShowDoll && UTPawnOwner != none )
	{
		DisplayPawnDoll();
	}

	// If we are driving a vehicle, give it hud time
	if ( bShowVehicle && UDKVehicleBase(PawnOwner) != none )
	{
		if ( UTVehicle(PawnOwner) != None )
		{
			UTVehicle(PawnOwner).DisplayHud(self, Canvas, VehiclePosition);
		}
		else if ( UTWeaponPawn(PawnOwner) != None )
		{
			UTWeaponPawn(PawnOwner).DisplayHud(self, Canvas, VehiclePosition);
		}
	}

	// Powerups
	if ( bShowPowerups && UTPawnOwner != none && UTPawnOwner.InvManager != none )
	{
		DisplayPowerups();
	}

	// Manage the weapon.  NOTE: Vehicle weapons are managed by the vehicle
	// since they are integrated in to the vehicle health bar
	if( PawnOwner != none )
	{
		Alpha = TeamHUDColor.A;
		if ( bShowWeaponBar )
    	{
			DisplayWeaponBar();
		}
		else if ( (Vehicle(PawnOwner) != None) && (PawnOwner.Weapon != LastSelectedWeapon) )
		{
			LastSelectedWeapon = PawnOwner.Weapon;
			PlayerOwner.ReceiveLocalizedMessage( class'UTWeaponSwitchMessage',,,, LastSelectedWeapon );
		}
		else if ( (PawnOwner.InvManager != None) && (PawnOwner.InvManager.PendingWeapon != None) && (PawnOwner.InvManager.PendingWeapon != LastSelectedWeapon) )
		{
			LastSelectedWeapon = PawnOwner.InvManager.PendingWeapon;
			PlayerOwner.ReceiveLocalizedMessage( class'UTWeaponSwitchMessage',,,, LastSelectedWeapon );
		}

		// The weaponbar potentially tweaks TeamHUDColor's Alpha.  Reset it here
		TeamHudColor.A = Alpha;

		if ( bShowAmmo )
		{
			Weapon = UTWeapon(PawnOwner.Weapon);
			if ( Weapon != none && UTVehicleWeapon(Weapon) == none )
			{
				DisplayAmmo(Weapon);
			}
		}
	}
}

/**
 * This function is called when we are drawing the hud but the match is over.
 */
function DrawPostGameHud()
{
	local bool bWinner;

	if (WorldInfo.GRI != None
		&& PlayerOwner.PlayerReplicationInfo != None
		&& !PlayerOwner.PlayerReplicationInfo.bOnlySpectator
		&& !PlayerOwner.IsInState('InQueue') )
	{
		if ( UTPlayerReplicationInfo(WorldInfo.GRI.Winner) != none )
		{
			bWinner = UTPlayerReplicationInfo(WorldInfo.GRI.Winner) == UTOwnerPRI;
		}
		// automated testing will not have a valid winner
		else if( WorldInfo.GRI.Winner != none )
		{
			bWinner = WorldInfo.GRI.Winner.GetTeamNum() == UTPlayerOwner.GetTeamNum();
		}

		DisplayHUDMessage((bWinner ? YouHaveWon : YouHaveLost));
	}

	DisplayConsoleMessages();
}

/*
*/
function DisplayWeaponBar()
{
	local int i, SelectedWeapon, LastWeapIndex, PrevWeapIndex, NextWeapIndex, FirstWeaponIndex;
	local float TotalOffsetX, OffsetX, OffsetY, BoxOffsetSize, OffsetSizeX, OffsetSizeY, DesiredWeaponScale[10], Delta, MaxWidth;
	local UTWeapon W;
	local UTVehicle V;
	local LinearColor FadedAmmoBarColor;
	local float SelectedAmmoBarX, SelectedAmmoBarY, AlphaScale, AmmoCountScale;
	local Rotator r;
	local Inventory Inv;

	// never show weapon bar in split screen
	if ( (PawnOwner == None) || bIsSplitScreen )
	{
		return;
	}

	FirstWeaponIndex = WorldInfo.bUseConsoleInput ? 1 : 0;
	if ( (PawnOwner.InvManager != None) && (UTWeapon(PawnOwner.InvManager.PendingWeapon) != None)
		&& (UTWeapon(PawnOwner.InvManager.PendingWeapon).InventoryGroup >FirstWeaponIndex) )
	{
		LastWeaponBarDrawnTime = WorldInfo.TimeSeconds;
	}

	if ( (PawnOwner.Weapon == None) || (PawnOwner.InvManager == None) || (UTVehicle(PawnOwner) != None) )
	{
		V = UTVehicle(PawnOwner);
		if ( V != None )
		{
			if ( V.bHasWeaponBar )
			{
				V.DisplayWeaponBar(Canvas, self);
			}
			else if ( PawnOwner.Weapon != LastSelectedWeapon )
			{
				LastSelectedWeapon = PawnOwner.Weapon;
				PlayerOwner.ReceiveLocalizedMessage( WeaponSwitchMessage, 0, None, None, LastSelectedWeapon );
			}
		}
		return;
	}
	if ( bOnlyShowWeaponBarIfChanging )
	{
		if ( WorldInfo.TimeSeconds - LastWeaponBarDrawnTime > 1.0 )
		{
			return;
		}
		AlphaScale = FClamp(1.0 - 3.0 * (WorldInfo.TimeSeconds - LastWeaponBarDrawnTime - 0.333), 0.0, 1.0);
	}
	else
	{
		AlphaScale = 1.0;
	}

	for ( i=0; i<10; i++ )
	{
		WeaponList[i] = None;
	}
	i = 0;
	Inv = PawnOwner.InvManager.InventoryChain;
	while (Inv != None)
	{
		W = UTWeapon(Inv);
		if (W != None && W.InventoryGroup < 11 && W.InventoryGroup > 0)
		{
			WeaponList[W.InventoryGroup-1] = W;
		}
		Inv = Inv.Inventory;
	}

	SelectedWeapon = (PawnOwner.InvManager.PendingWeapon != None) ? UTWeapon(PawnOwner.InvManager.PendingWeapon).InventoryGroup-1 : UTWeapon(PawnOwner.Weapon).InventoryGroup-1;
	Delta = WeaponScaleSpeed * (WorldInfo.TimeSeconds - LastHUDUpdateTime);
	BoxOffsetSize = HUDScaleX * WeaponBarScale * WeaponBoxWidth;
	PrevWeapIndex = -1;
	NextWeapIndex = -1;
	LastWeapIndex = -1;

	if ( (PawnOwner.InvManager.PendingWeapon != None) && (PawnOwner.InvManager.PendingWeapon != LastSelectedWeapon) )
	{
		LastSelectedWeapon = PawnOwner.InvManager.PendingWeapon;

		// clear any pickup messages for this weapon
		for ( i=0; i<8; i++ )
		{
			if( LocalMessages[i].Message == None )
			{
				break;
			}
			if( LocalMessages[i].OptionalObject == LastSelectedWeapon.Class )
			{
				LocalMessages[i].EndOfLife = WorldInfo.TimeSeconds - 1.0;
				break;
			}
		}

		PlayerOwner.ReceiveLocalizedMessage( WeaponSwitchMessage, 0, None, None, LastSelectedWeapon );
	}

	// calculate offsets
	for ( i=FirstWeaponIndex; i<10; i++ )
	{
		if ( WeaponList[i] != None )
		{
			// optimization if needed - cache desiredweaponscale[] when pending weapon changes
			if ( SelectedWeapon == i )
			{
				PrevWeapIndex = LastWeapIndex;
				if ( BouncedWeapon == i )
				{
					DesiredWeaponScale[i] = SelectedWeaponScale;
				}
				else
				{
					DesiredWeaponScale[i] = BounceWeaponScale;
					if ( CurrentWeaponScale[i] >= DesiredWeaponScale[i] )
					{
						BouncedWeapon = i;
					}
				}
			}
			else
			{
				if ( LastWeapIndex == SelectedWeapon )
				{
					NextWeapIndex = i;
				}
				DesiredWeaponScale[i] = 1.0;
			}
			if ( CurrentWeaponScale[i] != DesiredWeaponScale[i] )
			{
				if ( DesiredWeaponScale[i] > CurrentWeaponScale[i] )
				{
					CurrentWeaponScale[i] = FMin(CurrentWeaponScale[i]+Delta,DesiredWeaponScale[i]);
				}
				else
				{
					CurrentWeaponScale[i] = FMax(CurrentWeaponScale[i]-Delta,DesiredWeaponScale[i]);
				}
			}
			TotalOffsetX += CurrentWeaponScale[i] * BoxOffsetSize;
			LastWeapIndex = i;
		}
		else 
		{
			CurrentWeaponScale[i] = 0;
		}
	}

	OffsetX = HUDScaleX * WeaponBarXOffset + 0.5 * (Canvas.ClipX - TotalOffsetX);
	OffsetY = Canvas.ClipY - HUDScaleY * WeaponBarY;

	// draw weapon boxes
	Canvas.SetDrawColor(255,255,255,255);
	OffsetSizeX = HUDScaleX * WeaponBarScale * 96 * SelectedBoxScale;
	OffsetSizeY = HUDScaleY * WeaponBarScale * 64 * SelectedBoxScale;
	FadedAmmoBarColor = AmmoBarColor;
	FadedAmmoBarColor.A *= AlphaScale;
	for ( i=FirstWeaponIndex; i<10; i++ )
	{
		if ( WeaponList[i] != None )
		{
			Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
			if ( SelectedWeapon == i )
			{
				//Current slot overlay
				TeamHUDColor.A = SelectedWeaponAlpha * AlphaScale;
				Canvas.DrawTile(AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 530, 248, 69, 49, TeamHUDColor);

				Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
				Canvas.DrawTile(AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 459, 148, 69, 49, TeamHUDColor);

				Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
				Canvas.DrawTile(AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 459, 248, 69, 49, TeamHUDColor);

				// draw ammo bar ticks for selected weapon
				SelectedAmmoBarX = HUDScaleX * (SelectedWeaponAmmoOffsetX - WeaponBarXOffset) + OffsetX;
				SelectedAmmoBarY = Canvas.ClipY - HUDScaleY * (WeaponBarY + CurrentWeaponScale[i]*WeaponAmmoOffsetY);
				Canvas.SetPos(SelectedAmmoBarX, SelectedAmmoBarY);
				MaxWidth = CurrentWeaponScale[i]*HUDScaleY * WeaponBarScale * WeaponAmmoLength;

				Canvas.DrawTileStretched(AltHudTexture, MaxWidth, CurrentWeaponScale[i]*HUDScaleY*WeaponBarScale*WeaponAmmoThickness, 407, 479, FMin(118, MaxWidth), 16, FadedAmmoBarColor);
			}
			else
			{
				TeamHUDColor.A = OffWeaponAlpha * AlphaScale;
				Canvas.DrawTile(AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 459, 148, 69, 49, TeamHUDColor);

				// draw slot overlay?
				if ( i == PrevWeapIndex )
				{
					Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
					Canvas.DrawTile(AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 530, 97, 69, 49, TeamHUDColor);
				}
				else if ( i == NextWeapIndex )
				{
					Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
					Canvas.DrawTile(AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 530, 148, 69, 49, TeamHUDColor);
				}
			}
			OffsetX += CurrentWeaponScale[i] * BoxOffsetSize;
		}
	}

	// draw weapon ammo bars
	// Ammo Bar:  273,494 12,13 (The ammo bar is meant to be stretched)
	Canvas.SetDrawColor(255,255,255,255);
	OffsetX = HUDScaleX * WeaponAmmoOffsetX + 0.5 * (Canvas.ClipX - TotalOffsetX);
	OffsetSizeY = HUDScaleY * WeaponBarScale * WeaponAmmoThickness;
	FadedAmmoBarColor = AmmoBarColor;
	FadedAmmoBarColor.A *= AlphaScale;
	for ( i=FirstWeaponIndex; i<10; i++ )
	{
		if ( (WeaponList[i] != None) && (WeaponList[i].AmmoCount > 0) )
		{
			if ( SelectedWeapon == i )
			{
				Canvas.SetPos(SelectedAmmoBarX - 0.2*HUDScaleY * WeaponBarScale * WeaponAmmoLength*CurrentWeaponScale[i], SelectedAmmoBarY);
			}
			else
			{
				Canvas.SetPos(OffsetX, Canvas.ClipY - HUDScaleY * (WeaponBarY + CurrentWeaponScale[i]*WeaponAmmoOffsetY));
			}
			AmmoCountScale = 0.3 + FMin(1.0,float(WeaponList[i].AmmoCount)/float(WeaponList[i].MaxAmmoCount));
			Canvas.DrawTileStretched(AltHudTexture, HUDScaleY * WeaponBarScale * WeaponAmmoLength*CurrentWeaponScale[i]*AmmoCountScale, CurrentWeaponScale[i]*OffsetSizeY, 273, 494,12,13, FadedAmmoBarColor);
		}
		OffsetX += CurrentWeaponScale[i] * BoxOffsetSize;
	}

	// draw weapon numbers
	if ( !bNoWeaponNumbers )
	{
		OffsetX = HUDScaleX * (WeaponAmmoOffsetX + WeaponXOffset) * 0.5 + 0.5 * (Canvas.ClipX - TotalOffsetX);
		OffsetY = Canvas.ClipY - HUDScaleY * (WeaponBarY + WeaponYOffset);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.DrawColor.A = 255.0 * AlphaScale;
		Canvas.Font = HudFonts[0];
		for ( i=0; i<10; i++ )
		{
			if ( WeaponList[i] != None )
			{
				Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
				Canvas.DrawText(string((I+1)%10));
				OffsetX += CurrentWeaponScale[i] * BoxOffsetSize;
			}
		}
	}

	// draw weapon icons
	OffsetX = HUDScaleX * WeaponXOffset + 0.5 * (Canvas.ClipX - TotalOffsetX);
	OffsetY = Canvas.ClipY - HUDScaleY * (WeaponBarY + WeaponYOffset);
	OffsetSizeX = HUDScaleX * WeaponBarScale * 100;
	OffsetSizeY = HUDScaleY * WeaponBarScale * WeaponYScale;
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.DrawColor.A = 255.0 * AlphaScale;

	r.Yaw=2048;

	for ( i=FirstWeaponIndex; i<10; i++ )
	{
		if ( WeaponList[i] != NONE )
		{
			OffsetSizeX = HUDScaleX * WeaponBarScale * 100;
			OffsetSizeY = OffsetSizeX * (WeaponList[i].IconCoordinates.VL / WeaponList[i].IconCoordinates.UL);

			Canvas.SetPos(OffsetX, OffsetY - 1.1f * OffsetSizeY * CurrentWeaponScale[i]);
			Canvas.DrawRotatedTile(IconHudTexture, r,
					CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY,
					WeaponList[i].IconCoordinates.U, WeaponList[i].IconCoordinates.V, WeaponList[i].IconCoordinates.UL, WeaponList[i].IconCoordinates.VL,1.0,1.0);
			OffsetX += CurrentWeaponScale[i] * BoxOffsetSize;
		}
	}
}

/**
 * Draw the Map
 */
function DisplayMap()
{
	local UTMapInfo MI;
	local float ScaleY, W,H,X,Y, ScreenX, ScreenY, XL, YL, OrdersScale, ScaleIn, ScaleAlpha;
	local color CanvasColor;
	local float AdjustedViewportHeight;


	if ( DisplayedOrders != "" )
	{
		// draw orders
		Canvas.Font = GetFontSizeIndex(2);
		Canvas.StrLen(DisplayedOrders, XL, YL);

		// reduce font size if too big
		if( XL > 0.0f )
		{
			OrdersScale = FMin(1.0, 0.3*Canvas.ClipX/XL);
		}

		// scale in initially
		ScaleIn = FMax(1.0, (0.6+OrderUpdateTime-WorldInfo.TimeSeconds)/0.15);
		ScaleAlpha = FMin(1.0, 4.5 - ScaleIn);
		OrdersScale *= ScaleIn;

		ScreenY = 0.01 * Canvas.ClipY;
		ScreenX = 0.98 * Canvas.ClipX - OrdersScale*XL;

		// first draw drop shadow string
		if ( ScaleIn < 1.1 )
		{
			Canvas.DrawColor = BlackColor;
			Canvas.SetPos( ScreenX+2, ScreenY+2 );
			Canvas.DrawText( DisplayedOrders, false, OrdersScale, OrdersScale, TextRenderInfo );
		}

		// now draw string with normal color
		Canvas.DrawColor = LightGoldColor;
		Canvas.DrawColor.A = 255 * ScaleAlpha;
		Canvas.SetPos( ScreenX, ScreenY );
		Canvas.DrawText( DisplayedOrders, false, OrdersScale, OrdersScale, TextRenderInfo );
		Canvas.DrawColor = CanvasColor;
	}

	// no minimap in splitscreen
	if ( bIsSplitScreen )
		return;

	// draw map
	MI = UTMapInfo( WorldInfo.GetMapInfo() );
	if ( MI != none )
	{
		AdjustedViewportHeight = bIsSplitScreen ? Canvas.ClipY * 2 : Canvas.ClipY;

		ScaleY = AdjustedViewportHeight/768;
		H = MapDefaultSize * ScaleY;
		W = MapDefaultSize * ScaleY;

		X = Canvas.ClipX - (Canvas.ClipX * (1.0 - MapPosition.X)) - W;
		Y = (AdjustedViewportHeight * MapPosition.Y);

		MI.DrawMap(Canvas, UTPlayerController(PlayerOwner), X, Y, W ,H, false, (Canvas.ClipX / AdjustedViewportHeight) );
	}
}

/** draws AI goal overlays over each AI pawn */
function DrawAIOverlays()
{
	local UTBot B;
	local vector Pos;
	local float XL, YL;
	local string Text;

	Canvas.Font = GetFontSizeIndex(0);

	foreach WorldInfo.AllControllers(class'UTBot', B)
	{
		if (B.Pawn != None)
		{
			// draw route
			DrawRoute(B.Pawn);
			// draw goal string
			if ((vector(PlayerOwner.Rotation) dot (B.Pawn.Location - PlayerOwner.ViewTarget.Location)) > 0.f)
			{
				Pos = Canvas.Project(B.Pawn.Location + B.Pawn.GetCollisionHeight() * vect(0,0,1.1));
				Text = B.GetHumanReadableName() $ ":" @ B.GoalString;
				Canvas.StrLen(Text, XL, YL);
				Pos.X = FClamp(Pos.X, 0.f, Canvas.ClipX - XL);
				Pos.Y = FClamp(Pos.Y, 0.f, Canvas.ClipY - YL);
				Canvas.SetPos(Pos.X, Pos.Y);
				if (B.PlayerReplicationInfo != None && B.PlayerReplicationInfo.Team != None)
				{
					Canvas.DrawColor = B.PlayerReplicationInfo.Team.GetHUDColor();
					// brighten the color a bit
					Canvas.DrawColor.R = Min(Canvas.DrawColor.R + 64, 255);
					Canvas.DrawColor.G = Min(Canvas.DrawColor.G + 64, 255);
					Canvas.DrawColor.B = Min(Canvas.DrawColor.B + 64, 255);
				}
				else
				{
					Canvas.DrawColor = ConsoleColor;
				}
				Canvas.DrawColor.A = LocalPlayer(PlayerOwner.Player).GetActorVisibility(B.Pawn) ? 255 : 128;
				Canvas.DrawText(Text);
			}
		}
	}
}


/************************************************************************************************************
 * Accessors for the UI system for opening scenes (scoreboard/menus/etc)
 ***********************************************************************************************************/

function UIInteraction GetUIController(optional out LocalPlayer LP)
{
	LP = LocalPlayer(PlayerOwner.Player);
	if ( LP != none )
	{
		return LP.ViewportClient.UIController;
	}

	return none;
}

/**
 * OpenScene - Opens a UIScene
 *
 * @Param Template	The scene template to open
 */
function UTUIScene OpenScene(UTUIScene Template)
{
	return UTUIScene(UTPlayerOwner.OpenUIScene(Template));
}


/************************************************************************************************************
 Misc / Utility functions
************************************************************************************************************/

exec function StartMusic()
{
	if (UTPlayerOwner.MusicManager == None)
	{
		UTPlayerOwner.MusicManager = Spawn(MusicManagerClass, UTPlayerOwner);
	}
}

static simulated function GetTeamColor(int TeamIndex, optional out LinearColor ImageColor, optional out Color TextColor)
{
	switch ( TeamIndex )
	{
		case 0 :
			ImageColor = Default.RedLinearColor;
			TextColor = Default.LightGoldColor;
			break;
		case 1 :
			ImageColor = Default.BlueLinearColor;
			TextColor = Default.LightGoldColor;
			break;
		default:
			ImageColor = Default.DMLinearColor;
			ImageColor.A = 1.0f;
			TextColor = Default.LightGoldColor;
			break;
	}
}


/************************************************************************************************************
 Damage Indicator
************************************************************************************************************/

/**
 * Called from various functions.  It allows the hud to track when a hit is scored
 * and display any indicators.
 *
 * @Param	HitDir		- The vector to which the hit came at
 * @Param	Damage		- How much damage was done
 * @Param	DamageType  - Type of damage
 */
function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
	local Vector Loc;
	local Rotator Rot;
	local float DirOfHit_L;
	local vector AxisX, AxisY, AxisZ;
	local vector ShotDirection;
	local bool bIsInFront;
	local vector2D	AngularDist;
	local float PositionInQuadrant;
	local float Multiplier;
	local float DamageIntensity;
	local class<UTDamageType> UTDamage;
	local Pawn P;

	if ( (PawnOwner != None) && (PawnOwner.Health > 0) )
	{
		DamageIntensity = PawnOwner.InGodMode() ? 0.5 : (float(Damage)/100.0 + float(Damage)/float(PawnOwner.Health));
	}
	else
	{
		DamageIntensity = FMax(0.2, 0.02*float(Damage));
	}

	if ( damageType.default.bLocationalHit )
	{
		// Figure out the directional based on the victims current view
		PlayerOwner.GetPlayerViewPoint(Loc, Rot);
		GetAxes(Rot, AxisX, AxisY, AxisZ);

		ShotDirection = Normal(HitDir - Loc);
		bIsInFront = GetAngularDistance( AngularDist, ShotDirection, AxisX, AxisY, AxisZ);
		GetAngularDegreesFromRadians(AngularDist);

		Multiplier = 0.26f / 90.f;
		PositionInQuadrant = Abs(AngularDist.X) * Multiplier;

		// 0 - .25  UpperRight
		// .25 - .50 LowerRight
		// .50 - .75 LowerLeft
		// .75 - 1 UpperLeft
		if( bIsInFront )
		{
			DirOfHit_L = (AngularDist.X > 0) ? PositionInQuadrant : -1*PositionInQuadrant;
		}
		else
		{
			DirOfHit_L = (AngularDist.X > 0) ? 0.52+PositionInQuadrant : 0.52-PositionInQuadrant;
		}

		// Cause a damage indicator to appear
		DirOfHit_L = -1 * DirOfHit_L;
		FlashDamage(DirOfHit_L);
	}
	else
	{
		FlashDamage(0.1);
		FlashDamage(0.9);
	}

	// If the owner on the hoverboard, check against the owner health rather than vehicle health
	if (UTVehicle_Hoverboard(PawnOwner) != None)
	{
		P = UTVehicle_Hoverboard(PawnOwner).Driver;
	}
	else
	{
		P = PawnOwner;
	}

	if (DamageIntensity > 0 && HitEffect != None)
	{
		DamageIntensity = FClamp(DamageIntensity, 0.2, 1.0);
		if ( (P == None) || (P.Health <= 0) )
		{
			// long effect duration if killed by this damage
			HitEffectFadeTime = PlayerOwner.MinRespawnDelay * 2.0;
		}
		else
		{
			HitEffectFadeTime = default.HitEffectFadeTime * DamageIntensity;
		}
		HitEffectIntensity = default.HitEffectIntensity * DamageIntensity;
		UTDamage = class<UTDamageType>(DamageType);
		MaxHitEffectColor = (UTDamage != None && UTDamage.default.bOverrideHitEffectColor) ? UTDamage.default.HitEffectColor : default.MaxHitEffectColor;
		HitEffectMaterialInstance.SetScalarParameterValue('HitAmount', HitEffectIntensity);
		HitEffectMaterialInstance.SetVectorParameterValue('HitColor', MaxHitEffectColor);
		HitEffect.bShowInGame = true;
		bFadeOutHitEffect = true;
	}
}

/**
 * Configures a damage directional indicator and makes it appear
 *
 * @param	FlashPosition		Where it should appear
 */
function FlashDamage(float FlashPosition)
{
	local int i,MinIndex;
	local float Min;

	Min = 1.0;

	// Find an available slot

	for (i = 0; i < MaxNoOfIndicators; i++)
	{
		if (DamageData[i].FadeValue <= 0.0)
		{
			DamageData[i].FadeValue = 1.0;
			DamageData[i].FadeTime = FadeTime;
			DamageData[i].MatConstant.SetScalarParameterValue(PositionalParamName,FlashPosition);
			DamageData[i].MatConstant.SetScalarParameterValue(FadeParamName,1.0);

			return;
		}
		else if (DamageData[i].FadeValue < Min)
		{
			MinIndex = i;
			Min = DamageData[i].FadeValue;
		}
	}

	// Set the data

	DamageData[MinIndex].FadeValue = 1.0;
	DamageData[MinIndex].FadeTime = FadeTime;
	DamageData[MinIndex].MatConstant.SetScalarParameterValue(PositionalParamName,FlashPosition);
	DamageData[MinIndex].MatConstant.SetScalarParameterValue(FadeParamName,1.0);

}


/**
 * Update Damage always needs to be called
 */
function UpdateDamage()
{
	local int i;
	local float HitAmount;
	local LinearColor HitColor;

	for (i=0; i<MaxNoOfIndicators; i++)
	{
		if (DamageData[i].FadeTime > 0)
		{
			DamageData[i].FadeValue += ( 0 - DamageData[i].FadeValue) * (RenderDelta / DamageData[i].FadeTime);
			DamageData[i].FadeTime -= RenderDelta;
			DamageData[i].MatConstant.SetScalarParameterValue(FadeParamName,DamageData[i].FadeValue);
		}
	}

	// Update the color/fading on the full screen distortion
	if (bFadeOutHitEffect)
	{
		HitEffectMaterialInstance.GetScalarParameterValue('HitAmount', HitAmount);
		HitAmount -= HitEffectIntensity * RenderDelta / HitEffectFadeTime;

		if (HitAmount <= 0.0)
		{
			HitEffect.bShowInGame = false;
			bFadeOutHitEffect = false;
		}
		else
		{
			HitEffectMaterialInstance.SetScalarParameterValue('HitAmount', HitAmount);
			// now scale the color
			HitEffectMaterialInstance.GetVectorParameterValue('HitColor', HitColor);
			HitColor = HitColor - MaxHitEffectColor * (RenderDelta / HitEffectFadeTime);
			HitEffectMaterialInstance.SetVectorParameterValue('HitColor', HitColor);
		}
	}
}

function DisplayDamage()
{
	local int i;

		// Update the fading on the directional indicators.
		for (i=0; i<MaxNoOfIndicators; i++)
		{
			if (DamageData[i].FadeTime > 0)
			{

				Canvas.SetPos( ((Canvas.ClipX * 0.5) - (DamageIndicatorSize * 0.5 * ResolutionScale)),
					((Canvas.ClipY * 0.5) - (DamageIndicatorSize * 0.5 * ResolutionScale)));

				Canvas.DrawMaterialTile( DamageData[i].MatConstant, DamageIndicatorSize * ResolutionScale, DamageIndicatorSize * ResolutionScale, 0.0, 0.0, 1.0, 1.0);
			}
		}
	}

/************************************************************************************************************
************************************************************************************************************/


static simulated function DrawBackground(float X, float Y, float Width, float Height, LinearColor DrawColor, Canvas DrawCanvas)
{
	DrawCanvas.SetPos(X,Y);
	DrawColor.R *= 0.25;
	DrawColor.G *= 0.25;
	DrawColor.B *= 0.25;
	DrawCanvas.DrawTile(Default.AltHudTexture, Width, Height, 631,202,98,48, DrawColor);
}

static simulated function DrawBeaconBackground(float X, float Y, float Width, float Height, LinearColor DrawColor, Canvas DrawCanvas)
	{
	DrawCanvas.SetPos(X,Y);
		DrawColor.R *= 0.25;
		DrawColor.G *= 0.25;
		DrawColor.B *= 0.25;
	DrawCanvas.DrawTile(Default.UT3GHudTexture, Width, Height, 137,91,101,34, DrawColor);
}

/**
  * Draw a beacon healthbar
  * @PARAM Width is the actual health width
  * @PARAM MaxWidth corresponds to the max health
  */
static simulated function DrawHealth(float X, float Y, float Width, float MaxWidth, float Height, Canvas DrawCanvas, optional byte Alpha=255)
{
	local float HealthX;
	local color DrawColor, BackColor;

	// Bar color depends on health
	HealthX = Width/MaxWidth;

	DrawColor = Default.GrayColor;
	DrawColor.B = 16;
	if (HealthX > 0.8)
	{
		DrawColor.R = 112;
	}
	else if (HealthX < 0.4 )
	{
		DrawColor.G = 80;
	}
	DrawColor.A = Alpha;
	BackColor = default.GrayColor;
	BackColor.A = Alpha;
	DrawBarGraph(X,Y,Width,MaxWidth,Height,DrawCanvas,DrawColor,BackColor);
}

static simulated function DrawBarGraph(float X, float Y, float Width, float MaxWidth, float Height, Canvas DrawCanvas, Color BarColor, Color BackColor)
{
	// Draw health bar backdrop ticks
	if ( MaxWidth > 24.0 )
	{
		// determine size of health bar caps
		DrawCanvas.DrawColor = BackColor;
		DrawCanvas.SetPos(X,Y);
		DrawCanvas.DrawTile(default.AltHudTexture,MaxWidth,Height,407,479,FMin(MaxWidth,118),16);
	}

	DrawCanvas.DrawColor = BarColor;
	DrawCanvas.SetPos(X, Y);
	DrawCanvas.DrawTile(default.AltHudTexture,Width,Height,277,494,4,13);
}

/**
 * Creates a string from the time
 */
static function string FormatTime(int Seconds)
{
	local int Hours, Mins;
	local string NewTimeString;

	Hours = Seconds / 3600;
	Seconds -= Hours * 3600;
	Mins = Seconds / 60;
	Seconds -= Mins * 60;
	NewTimeString = "" $ ( Hours > 9 ? String(Hours) : "0"$String(Hours)) $ ":";
	NewTimeString = NewTimeString $ ( Mins > 9 ? String(Mins) : "0"$String(Mins)) $ ":";
	NewTimeString = NewTimeString $ ( Seconds > 9 ? String(Seconds) : "0"$String(Seconds));

	return NewTimeString;
}

static function Font GetFontSizeIndex(int FontSize)
{
	return default.HudFonts[Clamp(FontSize,0,3)];
}

/**
 * Given a PRI, show the Character portrait on the screen.
 *
 * @Param ShowPRI					The PRI to show
 * @Param bOverrideCurrentSpeaker	If true, we will quickly slide off the current speaker and then bring on this guy
 */
simulated function ShowPortrait(UTPlayerReplicationInfo ShowPRI, optional float PortraitDuration, optional bool bOverrideCurrentSpeaker)
{
	if ( ShowPRI != none && ShowPRI.CharPortrait != none )
	{
		// See if there is a current speaker
		if ( CharPRI != none )  // See if we should override this speaker
		{
			if ( ShowPRI == CharPRI )
			{
				if ( CharPortraitTime >= CharPortraitSlideTime * CharPortraitSlideTransitionTime )
				{
					CharPortraitSlideTime += 2.0;
					CharPortraitTime = FMax(CharPortraitTime, CharPortraitSlideTime * CharPortraitSlideTransitionTime);
				}
			}
			else if ( bOverrideCurrentSpeaker )
			{
				CharPendingPRI = ShowPRI;
				HidePortrait();
    		}
			return;
		}

		// Noone is sliding in, set us up.
		// Make sure we have the Instance
		if ( CharPortraitMI == none )
		{
			CharPortraitMI = new(Outer) class'MaterialInstanceConstant';
			CharPortraitMI.SetParent(CharPortraitMaterial);
		}

		// Set the image
		CharPortraitMI.SetTextureParameterValue('PortraitTexture',ShowPRI.CharPortrait);
		CharPRI = ShowPRI;
		CharPortraitTime = 0.0;
		CharPortraitSlideTime = FMax(2.0, PortraitDuration);
	}
}

/** If the portrait is visible, this will immediately try and hide it */
simulated function HidePortrait()
{
	local float CurrentPos;

	// Figure out the slide.

	CurrentPos = CharPortraitTime / CharPortraitSlideTime;

	// Slide it back out the equal percentage

	if (CurrentPos < CharPortraitSlideTransitionTime)
	{
		CharPortraitTime = CharPortraitSlideTime * (1.0 - CurrentPos);
	}

	// If we aren't sliding out, do it now

	else if ( CurrentPos < (1.0 - CharPortraitSlideTransitionTime ) )
	{
		CharPortraitTime = CharPortraitSlideTime * (1.0 - CharPortraitSlideTransitionTime);
	}
}

/**
 * Render the character portrait on the screen.
 *
 * @Param	RenderDelta		How long since the last render
 */
simulated function DisplayPortrait(float DeltaTime)
{
	local float CurrentPos, LocalPos, XPos, YPos, W, H;

	H = CharPortraitSize.Y * (Canvas.ClipY/768.0);
	W = CharPortraitSize.X * (Canvas.ClipY/768.0);

	CharPortraitTime += DeltaTime * (CharPendingPRI != none ? 1.5 : 1.0);

	CurrentPos = CharPortraitTime / CharPortraitSlideTime;
	// Figure out what we are doing
	if (CurrentPos < CharPortraitSlideTransitionTime)	// Sliding In
	{
		LocalPos = CurrentPos / CharPortraitSlideTransitionTime;
		XPos = FCubicInterp((W * -1), 0.0, (Canvas.ClipX * CharPortraitXPerc), 0.0, LocalPos);
	}
	else if ( (CurrentPos < 1.0 - CharPortraitSlideTransitionTime) )	// Sitting there
	{
		XPos = Canvas.ClipX * CharPortraitXPerc;
	}
	else if ( (PlayerOwner.VoiceInterface != None) && PlayerOwner.VoiceInterface.IsRemotePlayerTalking(CharPRI.UniqueID) )
	{
		XPos = Canvas.ClipX * CharPortraitXPerc;
		CharPortraitTime = (1.0 - CharPortraitSlideTransitionTime) * CharPortraitSlideTime;
	}
	else if ( CurrentPos < 1.0 )	// Sliding out
	{
		LocalPos = (CurrentPos - (1.0 - CharPortraitSlideTransitionTime)) / CharPortraitSlideTransitionTime;
		XPos = FCubicInterp((W * -1), 0.0, (Canvas.ClipX * CharPortraitXPerc), 0.0, 1.0-LocalPos);
	}
	else	// Done, reset everything
	{
		CharPRI = none;
		if ( CharPendingPRI != none )	// If we have a pending PRI, then display it
		{
			ShowPortrait(CharPendingPRI);
			CharPendingPRI = none;
		}
		return;
	}

	// Draw the portrait
	YPos = Canvas.ClipY * CharPortraitYPerc;
	Canvas.SetPos(XPos, YPos);
	Canvas.DrawColor = Whitecolor;
	Canvas.DrawMaterialTile(CharPortraitMI,W,H,0.0,0.0,1.0,1.0);
	Canvas.SetPos(XPos,YPos + H + 5);
	Canvas.Font = HudFonts[0];
	Canvas.DrawText(CharPRI.PlayerName);
}

/**
 * Displays the MOTD Scene
 */
function DisplayMOTD()
{
	OpenScene(MOTDSceneTemplate);
}

/**
 * Displays a HUD message
 */
function DisplayHUDMessage(string Message, optional float XOffsetPct = 0.05, optional float YOffsetPct = 0.05)
{
	local float XL,YL;
	local float BarHeight, Height, YBuffer, XBuffer, YCenter;

	if (!bHudMessageRendered)
	{
		// Preset the Canvas
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.Font = GetFontSizeIndex(2);
		Canvas.StrLen(Message,XL,YL);

		// Figure out sizes/positions
		BarHeight = YL * 1.1;
		YBuffer = Canvas.ClipY * YOffsetPct;
		XBuffer = Canvas.ClipX * XOffsetPct;
		Height = YL * 2.0;

		YCenter = Canvas.ClipY - YBuffer - (Height * 0.5);

		// Draw the Bar
		Canvas.SetPos(0,YCenter - (BarHeight * 0.5) );
		Canvas.DrawTile(AltHudTexture, Canvas.ClipX, BarHeight, 382, 441, 127, 16);

		// Draw the Symbol
		Canvas.SetPos(XBuffer, YCenter - (Height * 0.5));
		Canvas.DrawTile(AltHudTexture, Height * 1.33333, Height, 734,190, 82, 70);

		// Draw the Text
		Canvas.SetPos(XBuffer + Height * 1.5, YCenter - (YL * 0.5));
		Canvas.DrawText(Message);

		bHudMessageRendered = true;
	}
}

function DisplayClock()
{
	local string Time;
	local vector2D POS;

	if (UTGRI != None)
	{
		POS = ResolveHudPosition(ClockPosition,183,44);
		Time = FormatTime(UTGRI.TimeLimit != 0 ? UTGRI.RemainingTime : UTGRI.ElapsedTime);

		Canvas.SetPos(POS.X, POS.Y);
		Canvas.DrawTile(AltHudTexture, 183 * ResolutionScale,44 * ResolutionScale,490,395,181,44,TeamHudColor);

		Canvas.DrawColor = WhiteColor;
		DrawGlowText(Time, POS.X + (28 * ResolutionScale), POS.Y, 39 * ResolutionScale);
	}
}

function DisplayPawnDoll()
{
	local vector2d POS;
	local string Amount;
	local int Health;
	local float xl,yl;
	local float ArmorAmount;
	local linearcolor ScaledWhite, ScaledTeamHUDColor;

	POS = ResolveHudPosition(DollPosition,216, 115);
	Canvas.DrawColor = WhiteColor;

	// should doll be visible?
	ArmorAmount = UTPawnOwner.GetShieldStrength();

	if ( (ArmorAmount > 0) || (UTPawnOwner.JumpbootCharge > 0) )
	{
		DollVisibility = FMin(DollVisibility + 3.0 * (WorldInfo.TimeSeconds - LastDollUpdate), 1.0);
	}
	else
	{
		DollVisibility = FMax(DollVisibility - 3.0 * (WorldInfo.TimeSeconds - LastDollUpdate), 0.0);
	}
	LastDollUpdate = WorldInfo.TimeSeconds;

	POS.X = POS.X + (DollVisibility - 1.0)*HealthOffsetX*ResolutionScale;
	ScaledWhite = LC_White;
	ScaledWhite.A = DollVisibility;
	ScaledTeamHUDColor = TeamHUDColor;
	ScaledTeamHUDColor.A = FMin(DollVisibility, TeamHUDColor.A);

	// First, handle the Pawn Doll
	if ( DollVisibility > 0.0 )
	{
		// The Background
		Canvas.SetPos(POS.X,POS.Y);
		Canvas.DrawTile(AltHudTexture, PawnDollBGCoords.UL * ResolutionScale, PawnDollBGCoords.VL * ResolutionScale, PawnDollBGCoords.U, PawnDollBGCoords.V, PawnDollBGCoords.UL, PawnDollBGCoords.VL, ScaledTeamHUDColor);

		// The ShieldBelt/Default Doll
		Canvas.SetPos(POS.X + (DollOffsetX * ResolutionScale), POS.Y + (DollOffsetY * ResolutionScale));
		if ( UTPawnOwner.ShieldBeltArmor > 0.0f )
		{
			DrawTileCentered(AltHudTexture, DollWidth * ResolutionScale, DollHeight * ResolutionScale, 71, 224, 56, 109,ScaledWhite);
		}
		else
		{
			DrawTileCentered(AltHudTexture, DollWidth * ResolutionScale, DollHeight * ResolutionScale, 4, 224, 56, 109, ScaledTeamHUDColor);
		}

		if ( UTPawnOwner.VestArmor > 0.0f )
		{
			Canvas.SetPos(POS.X + (VestX * ResolutionScale), POS.Y + (VestY * ResolutionScale));
			DrawTileCentered(AltHudTexture, VestWidth * ResolutionScale, VestHeight * ResolutionScale, 132, 220, 46, 28, ScaledWhite);
		}

		if (UTPawnOwner.ThighpadArmor > 0.0f )
		{
			Canvas.SetPos(POS.X + (ThighX * ResolutionScale), POS.Y + (ThighY * ResolutionScale));
			DrawTileCentered(AltHudTexture, ThighWidth * ResolutionScale, ThighHeight * ResolutionScale, 134, 263, 42, 28, ScaledWhite);
		}

		if (UTPawnOwner.JumpBootCharge > 0 )
		{
			Canvas.SetPos(POS.X + BootX*ResolutionScale, POS.Y + BootY*ResolutionScale);
			DrawTileCentered(AltHudTexture, BootWidth * ResolutionScale, BootHeight * ResolutionScale, 222, 263, 54, 26, ScaledWhite);

			Canvas.Strlen(string(UTPawnOwner.JumpBootCharge),XL,YL);
			Canvas.SetPos(POS.X + (BootX-1)*ResolutionScale - 0.5*XL, POS.Y + (BootY+3)*ResolutionScale - 0.5*YL);
			Canvas.DrawText(  UTPawnOwner.JumpBootCharge, false, , , TextRenderInfo );
		}
	}

	// Next, the health and Armor widgets

   	// Draw the Health Background
	Canvas.SetPos(POS.X + HealthBGOffsetX * ResolutionScale,POS.Y + HealthBGOffsetY * ResolutionScale);
	
	Canvas.DrawTile(AltHudTexture, HealthBGCoords.UL * ResolutionScale, HealthBGCoords.VL * ResolutionScale, HealthBGCoords.U, HealthBGCoords.V, HealthBGCoords.UL, HealthBGCoords.VL, TeamHudColor);
	Canvas.DrawColor = WhiteColor;

	// Draw the Health Text
	Health = UTPawnOwner.Health;

	// Figure out if we should be pulsing
	if ( Health > LastHealth )
	{
		HealthPulseTime = WorldInfo.TimeSeconds;
	}
	LastHealth = Health;

	Amount = (Health > 0) ? ""$Health : "0";
	DrawGlowText(Amount, POS.X + HealthTextX * ResolutionScale, POS.Y + HealthTextY * ResolutionScale, 60 * ResolutionScale, HealthPulseTime,true);

	// Draw the Health Icon
	Canvas.SetPos(POS.X + HealthIconX * ResolutionScale, POS.Y + HealthIconY * ResolutionScale);
	DrawTileCentered(AltHudTexture, 42 * ResolutionScale , 30 * ResolutionScale, 216, 102, 56, 40, LC_White);

	// Only Draw the Armor if there is any
	// TODO - Add fading
	if ( ArmorAmount > 0 )
	{
		if (ArmorAmount > LastArmorAmount)
		{
			ArmorPulseTime = WorldInfo.TimeSeconds;
		}
		LastArmorAmount = ArmorAmount;

    	// Draw the Armor Background
		Canvas.SetPos(POS.X + ArmorBGOffsetX * ResolutionScale,POS.Y + ArmorBGOffsetY * ResolutionScale);
		Canvas.DrawTile(AltHudTexture, ArmorBGCoords.UL * ResolutionScale, ArmorBGCoords.VL * ResolutionScale, ArmorBGCoords.U, ArmorBGCoords.V, ArmorBGCoords.UL, ArmorBGCoords.VL, ScaledTeamHudColor);
		Canvas.DrawColor = WhiteColor;
		Canvas.DrawColor.A = 255.0 * DollVisibility;

		// Draw the Armor Text
		DrawGlowText(""$INT(ArmorAmount), POS.X + ArmorTextX * ResolutionScale, POS.Y + ArmorTextY * ResolutionScale, 45 * ResolutionScale, ArmorPulseTime,true);

		// Draw the Armor Icon
		Canvas.SetPos(POS.X + ArmorIconX * ResolutionScale, POS.Y + ArmorIconY * ResolutionScale);
		DrawTileCentered(AltHudTexture, (33 * ResolutionScale) , (24 * ResolutionScale), 225, 68, 42, 32, ScaledWhite);
	}
}

function DisplayAmmo(UTWeapon Weapon)
{
	local vector2d POS;
	local string Amount;
	local float BarWidth, PercValue;
	local int AmmoCount;

	if ( Weapon.AmmoDisplayType == EAWDS_None )
	{
		return;
	}

	// Resolve the position
	POS = ResolveHudPosition(AmmoPosition,AmmoBGCoords.UL,AmmoBGCoords.VL);

	if ( Weapon.AmmoDisplayType != EAWDS_BarGraph )
	{
		// Figure out if we should be pulsing
		AmmoCount = Weapon.GetAmmoCount();

		if ( AmmoCount > LastAmmoCount && LastWeapon == Weapon )
		{
			AmmoPulseTime = WorldInfo.TimeSeconds;
		}

		LastWeapon = Weapon;
		LastAmmoCount = AmmoCount;

		// Draw the background
		Canvas.SetPos(POS.X,POS.Y - (AmmoBarOffsetY * ResolutionScale));
		Canvas.DrawTile(AltHudTexture, AmmoBGCoords.UL * ResolutionScale, AmmoBGCoords.VL * ResolutionScale, AmmoBGCoords.U, AmmoBGCoords.V, AmmoBGCoords.UL, AmmoBGCoords.VL, TeamHudColor);

		// Draw the amount
		Amount = ""$AmmoCount;
		Canvas.DrawColor = WhiteColor;

		DrawGlowText(Amount, POS.X + (AmmoTextOffsetX * ResolutionScale), POS.Y - ((AmmoBarOffsetY + AmmoTextOffsetY) * ResolutionScale), 58 * ResolutionScale, AmmoPulseTime,true);
	}

	// If we have a bar graph display, do it here
	if ( Weapon.AmmoDisplayType != EAWDS_Numeric )
	{
		PercValue = Weapon.GetPowerPerc();

		Canvas.SetPos(POS.X + (40 * ResolutionScale), POS.Y - 8 * ResolutionScale);
		Canvas.DrawTile(AltHudTexture, 76 * ResolutionScale, 18 * ResolutionScale, 376,458, 88, 14, LC_White);

		BarWidth = 70 * ResolutionScale;
		DrawHealth(POS.X + (43 * ResolutionScale), POS.Y - 4 * ResolutionScale, BarWidth * PercValue,  BarWidth, 16, Canvas);
	}
}

function DisplayPowerups()
{
	local UTTimedPowerup TP;
	local float YPos;

	if ( bIsSplitScreen )
	{
		YPos = Canvas.ClipY * 0.55;
	}
	else
	{
		YPos = Canvas.ClipY * PowerupYPos;
	}

	bDisplayingPowerups = false;
	if (bShowPowerups)
	{
		foreach UTPawnOwner.InvManager.InventoryActors(class'UTTimedPowerup', TP)
		{
			TP.DisplayPowerup(Canvas, self, ResolutionScale, YPos);
			bDisplayingPowerups = true;
		}
	}
}

function DisplayScoring()
{
	local vector2d POS;

	if ( bShowFragCount || (bHasLeaderboard && bShowLeaderboard) )
	{
		POS = ResolveHudPosition(ScoringPosition, 115,44);

		if ( bShowFragCount )
		{
			DisplayFragCount(POS);
		}

		if ( bHasLeaderboard )
		{
			DisplayLeaderBoard(POS);
		}
	}
}


function DisplayFragCount(vector2d POS)
{
	local int FragCount;
	local UTPlayerReplicationInfo FragPRI;
	
	FragPRI = ((PawnOwner != None) && (PawnOwner.PlayerReplicationInfo != None)) ? UTPlayerReplicationInfo(PawnOwner.PlayerReplicationInfo) : UTOwnerPRI;  

	Canvas.SetPos(POS.X, POS.Y);
	Canvas.DrawTile(AltHudTexture, 115 * ResolutionScale, 44 * ResolutionScale, 374, 395, 115, 44, TeamHudColor);
	Canvas.DrawColor = WhiteColor;

	// Figure out if we should be pulsing

	FragCount = (FragPRI != None) ? FragPRI.Score : 0.0;
	if ( FragCount > LastFragCount )
	{
		FragPulseTime = WorldInfo.TimeSeconds;
		LastFragCount = FragCount;
	}

	DrawGlowText(""$FragCount, POS.X + (87 * ResolutionScale), POS.Y + (-2 * ResolutionScale), 42 * ResolutionScale, FragPulseTime,true);
}

/*
*   Draws a nameplate behind text
*   @param Pos - top center of the nameplate
*   @param Wordwidth - width the name takes up (already accounts for resolution)
*   @param NameplateColor - linear color for the background texture
*   @param WordHeight - height of the nameplate (already accounts for resolution)
*/
function DrawNameplateBackground(vector2d Pos, float WordWidth, LinearColor NameplateColor, optional float WordHeight = 0.0)
{
	local float NameplateHeight, EndCapWidth;

	if (WordHeight > 0)
	{
		NameplateHeight = WordHeight;
	}
	else
	{
		NameplateHeight = NameplateCenter.VL * ResolutionScale;
	}
	
	EndCapWidth = NameplateWidth * ResolutionScale;

	//Start to the right half the length of the text
	Canvas.SetPos(Pos.X - (0.5 * WordWidth) - EndCapWidth, Pos.Y);
	Canvas.DrawTile(UT3GHudTexture, EndCapWidth, NameplateHeight, NameplateLeft.U, NameplateLeft.V, NameplateLeft.UL, NameplateLeft.VL, NameplateColor);
	Canvas.DrawTile(UT3GHudTexture, WordWidth, NameplateHeight, NameplateCenter.U, NameplateCenter.V, NameplateCenter.UL, NameplateCenter.VL, NameplateColor); 
	Canvas.DrawTile(UT3GHudTexture, EndCapWidth, NameplateHeight, NameplateRight.U, NameplateRight.V, NameplateRight.UL, NameplateRight.VL, NameplateColor);
}

function DisplayLeaderBoard(vector2d POS)
{
	local string Work,MySpreadStr;
	local int i, MySpread, MyPosition, LeaderboardCount;
	local float XL,YL;
	local vector2d BackgroundPos;
	local bool bTravelling;
	local UTPlayerReplicationInfo FragPRI;

	FragPRI = ((PawnOwner != None) && (PawnOwner.PlayerReplicationInfo != None)) ? UTPlayerReplicationInfo(PawnOwner.PlayerReplicationInfo) : UTOwnerPRI;  

	if ( (UTGRI == None) || (FragPRI == None) )
	{
		return;
	}

	POS.X = 0.99*Canvas.ClipX;
	POS.Y += 50 * ResolutionScale;

	// Figure out your Spread
	bTravelling = WorldInfo.IsInSeamlessTravel() || FragPRI.bFromPreviousLevel;
	for (i = 0; i < UTGRI.PRIArray.length; i++)
	{
		if (bTravelling || !UTGRI.PRIArray[i].bFromPreviousLevel)
		{
			break;
		}
	}
	if ( UTGRI.PRIArray[i] == FragPRI )
	{
		if ( UTGRI.PRIArray.Length > i + 1 )
		{
			MySpread = FragPRI.Score - UTGRI.PRIArray[i + 1].Score;
		}
		else
	{
		MySpread = 0;
		}
		MyPosition = 0;
	}
	else
	{
		MySpread = FragPRI.Score - UTGRI.PRIArray[i].Score;
		MyPosition = UTGRI.PRIArray.Find(FragPRI);
	}

	if (MySpread >0)
	{
		MySpreadStr = "+"$String(MySpread);
	}
	else
	{
		MySpreadStr = string(MySpread);
	}

	// Draw the Spread
	Work = string(MyPosition+1) $ PlaceMarks[min(MyPosition,3)] $ " / " $ MySpreadStr;

	Canvas.Font = GetFontSizeIndex(2);
	Canvas.SetDrawColor(255,255,255,255);

	Canvas.Strlen(Work,XL,YL);
	BackgroundPos.X = POS.X - (0.5 * XL);
	BackgroundPos.Y = POS.Y;
	DrawNameplateBackground(BackgroundPos, XL, BlackBackgroundColor, YL);
	Canvas.SetPos(POS.X - XL, POS.Y);
	Canvas.DrawText(Work, , , , TextRenderInfo);

	if ( bShowLeaderboard )
	{
		POS.Y += YL * 1.2;

		// Draw the leaderboard
		Canvas.Font = GetFontSizeIndex(1);
		Canvas.SetDrawColor(200,200,200,255);
		for (i = 0; i < UTGRI.PRIArray.Length && LeaderboardCount < 3; i++)
		{
			if ( UTGRI.PRIArray[i] != None && !UTGRI.PRIArray[i].bOnlySpectator &&
				(bTravelling || !UTGRI.PRIArray[i].bFromPreviousLevel) )
			{
				Work = string(i+1) $ PlaceMarks[i] $ ":" @ UTGRI.PRIArray[i].PlayerName;
				Canvas.StrLen(Work,XL,YL);
				BackgroundPos.X = POS.X - (0.5 * XL);
				BackgroundPos.Y = POS.Y;
				DrawNameplateBackground(BackgroundPos, XL, BlackBackgroundColor, (1.05 * YL));
				Canvas.SetPos(POS.X-XL,POS.Y+(2*ResolutionScale));
				Canvas.DrawText( Work, , , , TextRenderInfo );
				POS.Y += (1.05 * YL);

				LeaderboardCount++;
			}
		}
	}
}

/**
 * Display current messages
 */
function DisplayConsoleMessages()
{
	local int Idx, XPos, YPos;
	local float XL, YL;

	if (ConsoleMessages.Length == 0 || PlayerOwner.bCinematicMode)
	{
		return;
	}

	for (Idx = 0; Idx < ConsoleMessages.Length; Idx++)
	{
		if ( ConsoleMessages[Idx].Text == "" || ConsoleMessages[Idx].MessageLife < WorldInfo.TimeSeconds )
		{
			ConsoleMessages.Remove(Idx--,1);
		}
	}
	ConsoleMessagePosX = bDisplayingPowerups ? 0.1 : 0.0;
	XPos = (ConsoleMessagePosX * HudCanvasScale * Canvas.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * Canvas.SizeX);
	YPos = (ConsoleMessagePosY * HudCanvasScale * Canvas.SizeY) + (((1.0 - HudCanvasScale) / 2.0) * Canvas.SizeY);

	Canvas.Font = GetFontSizeIndex(0);

	Canvas.TextSize ("A", XL, YL);

	YPos -= YL * ConsoleMessages.Length; // DP_LowerLeft
	YPos -= YL; // Room for typing prompt

	for (Idx = 0; Idx < ConsoleMessages.Length; Idx++)
	{
		if (ConsoleMessages[Idx].Text == "")
		{
			continue;
		}
		Canvas.StrLen( ConsoleMessages[Idx].Text, XL, YL );
		Canvas.SetPos( XPos, YPos );
		Canvas.DrawColor = ConsoleMessages[Idx].TextColor;
		Canvas.DrawText( ConsoleMessages[Idx].Text, false );
		YPos += YL;
	}
}

defaultproperties
{
	bHasLeaderboard=true
	bHasMap=false
	bShowFragCount=true

	WeaponBarScale=0.75
	WeaponBarY=16
	SelectedWeaponScale=1.5
	BounceWeaponScale=2.25
	SelectedWeaponAlpha=1.0
	OffWeaponAlpha=0.5
	EmptyWeaponAlpha=0.4
	WeaponBoxWidth=100.0
	WeaponBoxHeight=64.0
	WeaponScaleSpeed=10.0
	WeaponBarXOffset=70
	WeaponXOffset=60
	SelectedBoxScale=1.0
	WeaponYScale=64
	WeaponYOffset=8

	WeaponAmmoLength=48
	WeaponAmmoThickness=16
	SelectedWeaponAmmoOffsetX=110
	WeaponAmmoOffsetX=100
	WeaponAmmoOffsetY=16

`if(`notdefined(MOBILE))
	AltHudTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseA'

	ScoreboardSceneTemplate=Scoreboard_DM'UI_Scenes_Scoreboards.sbDM'
`endif

	HudFonts(0)=MultiFont'UI_Fonts_Final.HUD.MF_Small'
	HudFonts(1)=MultiFont'UI_Fonts_Final.HUD.MF_Medium'
	HudFonts(2)=MultiFont'UI_Fonts_Final.HUD.MF_Large'
	HudFonts(3)=MultiFont'UI_Fonts_Final.HUD.MF_Huge'
	
	CharPortraitMaterial=Material'UI_HUD.Materials.CharPortrait'
	CharPortraitYPerc=0.15
	CharPortraitXPerc=0.01
	CharPortraitSlideTime=2.0
	CharPortraitSlideTransitionTime=0.175
	CharPortraitSize=(X=96,Y=120)

	CurrentWeaponScale(0)=1.0
	CurrentWeaponScale(1)=1.0
	CurrentWeaponScale(2)=1.0
	CurrentWeaponScale(3)=1.0
	CurrentWeaponScale(4)=1.0
	CurrentWeaponScale(5)=1.0
	CurrentWeaponScale(6)=1.0
	CurrentWeaponScale(7)=1.0
	CurrentWeaponScale(8)=1.0
	CurrentWeaponScale(9)=1.0

	MessageOffset(0)=0.15
	MessageOffset(1)=0.242
	MessageOffset(2)=0.36
	MessageOffset(3)=0.58
	MessageOffset(4)=0.78
	MessageOffset(5)=0.83
	MessageOffset(6)=2.0

	GlowFonts(0)=font'UI_Fonts_Final.HUD.F_GlowPrimary'
	GlowFonts(1)=font'UI_Fonts_Final.HUD.F_GlowSecondary'

  	LC_White=(R=1.0,G=1.0,B=1.0,A=1.0)

	PulseDuration=0.33
	PulseSplit=0.25
	PulseMultiplier=0.5

	MaxNoOfIndicators=3
	BaseMaterial=Material'UI_HUD.HUD.M_UI_HUD_DamageDir'
	FadeTime=0.5
	PositionalParamName=DamageDirectionRotation
	FadeParamName=DamageDirectionAlpha

	HitEffectFadeTime=0.50
	HitEffectIntensity=0.25
	MaxHitEffectColor=(R=2.0,G=-1.0,B=-1.0)

	GrayColor=(R=160,G=160,B=160,A=192)
	PowerupYPos=0.75
	MaxHUDAreaMessageCount=2

	AmmoBarColor=(R=7.0,G=7.0,B=7.0,A=1.0)
	RedLinearColor=(R=3.0,G=0.0,B=0.05,A=0.8)
	BlueLinearColor=(R=0.5,G=0.8,B=10.0,A=0.8)
	DMLinearColor=(R=1.0,G=1.0,B=1.0,A=0.5)
	WhiteLinearColor=(R=1.0,G=1.0,B=1.0,A=1.0)
	GoldLinearColor=(R=1.0,G=1.0,B=0.0,A=1.0)
	SilverLinearColor=(R=0.75,G=0.75,B=0.75,A=1.0)

	MapPosition=(X=0.99,Y=0.05)
	ClockPosition=(X=0,Y=0)
	DollPosition=(X=0,Y=-1)
	AmmoPosition=(X=-1,Y=-1)
	ScoringPosition=(X=-1,Y=0)
	VehiclePosition=(X=-1,Y=-1)

    WeaponSwitchMessage=class'UTWeaponSwitchMessage'

	TalkingTexture=Texture2D'PS3Patch.Talking'
`if(`notdefined(MOBILE))
	UT3GHudTexture=Texture2D'UI_GoldHud.HUDIcons'
`endif

	HealthBGCoords=(U=73,UL=143,V=111,VL=57)
	HealthOffsetX=65
	HealthBGOffsetX=65
	HealthBGOffsetY=59
	HealthIconX=80
	HealthIconY=88
	HealthTextX=185
	HealthTextY=55

	ArmorBGCoords=(U=74,UL=117,V=69,VL=42)
	ArmorBGOffsetX=65
	ArmorBGOffsetY=18
	ArmorIconX=80
	ArmorIconY=42
	ArmorTextX=160
	ArmorTextY=17

	AmmoBGCoords=(U=1,UL=162,V=368,VL=53)
	AmmoBarOffsetY=2
	AmmoTextOffsetX=125
	AmmoTextOffsetY=3

	PawnDollBGCoords=(U=9,UL=65,V=52,VL=116)
	DollOffsetX=35
	DollOffsetY=58
	DollWidth=56
	DollHeight=109
	VestX=36
	VestY=31
	VestWidth=46
	VestHeight=28
	ThighX=36
	ThighY=72
	ThighWidth=42
	ThighHeight=28
	HelmetX=36
	HelmetY=13
	HelmetWidth=22
	HelmetHeight=25
	BootX=37
	BootY=100
	BootWidth=54 
	BootHeight=26


	NameplateWidth=8			//width of the left/right endcaps
	NameplateBubbleWidth=15		//width of the middle divot
	NameplateLeft=(U=224, UL=14, V=11, VL=35);
	NameplateCenter=(U=238, UL=5, V=11, VL=35);
	NameplateBubble=(U=243, UL=26, V=11, VL=35);
	NameplateRight=(U=275, UL=14, V=11, VL=35);

	BlackBackgroundColor=(R=0.7,G=0.7,B=0.7,A=0.7)

	TextRenderInfo=(bClipText=true)
}
