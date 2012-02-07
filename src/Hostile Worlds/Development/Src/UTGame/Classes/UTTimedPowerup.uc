/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTTimedPowerup extends UTInventory
	abstract;

/** the amount of time remaining before the powerup expires 
 * @note: only counts down while the item is owned by someone (not when on a dropped pickup)
 */
var float TimeRemaining;

/** Used to determine which symbol represents this object on the paperdoll */
var int HudIndex;

/** Sound played when powerup's time is up */
var SoundCue PowerupOverSound;

/** Name used for the stats system */
var name PowerupStatName;

/** Coordinates on icon texture for this powerup's icon */
var TextureCoordinates IconCoords;	

var float TransitionTime;
var float TransitionDuration;
var float WarningTime;	// Beging flashing when there is < this amount of time

/** post processing applied while holding this powerup */
var vector PP_Scene_HighLights;
var float PP_Scene_Desaturation;

simulated event Tick(float DeltaTime)
{
	if ( (Owner != None) && (TimeRemaining > 0.0) )
	{
		CustomTimeDilation = Owner.CustomTimeDilation;
		TimeRemaining -= DeltaTime;
		if (TimeRemaining <= 0.0)
		{
			TimeExpired();
		}
	}
	else
	{
		CustomTimeDilation = 1.0;
	}
}

function GivenTo(Pawn NewOwner, optional bool bDoNotActivate)
{
	Super.GivenTo(NewOwner, bDoNotActivate);
	ClientSetTimeRemaining(TimeRemaining);
	TimeRemaingUpdated();

	//Start the timer on the powerup stat
	UTPlayerReplicationInfo(NewOwner.PlayerReplicationInfo).StartPowerupTimeStat(GetPowerupStatName());
}

reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	Super.ClientGivenTo(NewOwner, bDoNotActivate);

	AdjustPPEffects(NewOwner, false);
}

/** applies and removes any post processing effects while holding this item */
simulated function AdjustPPEffects(Pawn P, bool bRemove)
{
	local UTPlayerController PC;

	if (P != None)
	{
		PC = UTPlayerController(P.Controller);
		if (PC == None && P.DrivenVehicle != None)
		{
			PC = UTPlayerController(P.DrivenVehicle.Controller);
		}
		if (PC != None)
		{
			if (bRemove)
			{
				PC.PostProcessModifier.Scene_HighLights -= PP_Scene_Highlights;
				PC.PostProcessModifier.Scene_Desaturation -= PP_Scene_Desaturation;
			}
			else
			{
				PC.PostProcessModifier.Scene_HighLights += PP_Scene_Highlights;
				PC.PostProcessModifier.Scene_Desaturation += PP_Scene_Desaturation;
			}
		}
	}
}

reliable client function ClientLostItem()
{
	AdjustPPEffects(Pawn(Owner), true);

	Super.ClientLostItem();
}

/** called by the server on the client to tell it how much time the UDamage has for the HUD timer */
reliable client function ClientSetTimeRemaining(float NewTimeRemaining)
{
	TimeRemaining = NewTimeRemaining;
	TimeRemaingUpdated();
}

simulated function TimeRemaingUpdated()
{
	TransitionTime = TransitionDuration;
}

simulated function DisplayPowerup(Canvas Canvas, UTHud HUD, float ResolutionScale,out float YPos)
{
	local float FlashAlpha, Scaler;
	local float XPos;
	local string TimeRemainingAsString;
	local int TimeRemainingAsInt;
	local LinearColor TeamColor;

	if (TransitionTime > 0.0)
	{
		TransitionTime -= HUD.RenderDelta;
		if (TransitionTime < 0.0)
		{
			TransitionTime = 0.0;
		}
	}

	Scaler = TransitionTime / TransitionDuration;
	if (TimeRemaining < 1.0)
	{
		FlashAlpha = TimeRemaining;
	}
	else
	{
		FlashAlpha = (TimeRemaining <= WarningTime) ? 0.25 + (0.75*abs(cos(TimeRemaining))) : 1.0;
	}

	// Draw the icon
	TeamColor = Hud.TeamHudColor;
	TeamColor.A = FlashAlpha;
	Scaler = 1.0 + (12 * Scaler);
	XPos = (Canvas.ClipX * 0.025);
	Canvas.SetPos(XPos+20 * ResolutionScale, YPos+20 * ResolutionScale);
	Hud.DrawTileCentered(Hud.AltHudTexture, IconCoords.UL * ResolutionScale * Scaler , IconCoords.VL * ResolutionScale * Scaler, IconCoords.U, IconCoords.V, IconCoords.UL, IconCoords.VL, TeamColor);

	// Draw the Time Remaining;
    TimeRemainingAsInt = Max(0, int(TimeRemaining+1));
	TimeRemainingAsString = string(TimeRemainingAsInt);

	XPos += (35 * ResolutionScale);
	Canvas.SetDrawColor(255,255,255,255*FlashAlpha);
	Hud.DrawGlowText(TimeRemainingAsString, XPos, YPos, 40 * ResolutionScale);

	YPos -= 50 * ResolutionScale;

}

function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	local DroppedPickup Drop;

	if (ItemClass == Class)
	{
		Drop = DroppedPickup(Pickup);
		if (Drop != None && UTTimedPowerup(Drop.Inventory) != None)
		{
			TimeRemaining += UTTimedPowerup(Drop.Inventory).TimeRemaining;
		}
		else
		{
			TimeRemaining += default.TimeRemaining;
		}
		ClientSetTimeRemaining(TimeRemaining);
		Pickup.PickedUpBy(Instigator);
		AnnouncePickup(Instigator);
		return true;
	}

	return false;
}

/** called when TimeRemaining reaches zero */
function TimeExpired()
{
	local UTPlayerReplicationInfo UTPRI;
	if(PowerUpOverSound != none)
	{
		Instigator.PlaySound(PowerupOverSound);
	}

	//Stop the timer on the powerup stat
	if (Instigator.DrivenVehicle != None)
	{
		UTPRI = UTPlayerReplicationInfo(Instigator.DrivenVehicle.PlayerReplicationInfo);
	}
	else
	{
		UTPRI = UTPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	}
	if (UTPRI != None)
	{
		UTPRI.StopPowerupTimeStat(GetPowerupStatName());
	}

	Destroy();
}

static function float BotDesireability(Actor PickupHolder, Pawn P, Controller C)
{
	return default.MaxDesireability;
}

static function float DetourWeight(Pawn Other, float PathWeight)
{
	return (default.MaxDesireability / PathWeight);
}

/**
* Stats
*/
function name GetPowerupStatName()
{
	if ( Default.PowerupStatName != '' )
	{
		return Default.PowerupStatName;
	}

	return 'INVALID_POWERUPSTAT';
}

defaultproperties
{
	bPredictRespawns=true
	bDelayedSpawn=true
	bDropOnDeath=true
	RespawnTime=90.000000
	MaxDesireability=2.0

	TimeRemaining=30.0
	TransitionDuration=0.5
	WarningTime=3.0
}
