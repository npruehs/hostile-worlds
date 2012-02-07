/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 */
class UTDmgType_RanOver extends UTDamageType
	abstract;

var int NumMessages;

static function int IncrementKills(UTPlayerReplicationInfo KillerPRI)
{
	local int KillCount;

	KillCount = super.IncrementKills(KillerPRI);
	if ( (KillCount != Default.RewardCount)  && (UTPlayerController(KillerPRI.Owner) != None) )
	{
		SmallReward(UTPlayerController(KillerPRI.Owner), KillCount);
	}
	return KillCount;
}

static function SmallReward(UTPlayerController Killer, int KillCount)
{
	Killer.ReceiveLocalizedMessage(class'UTVehicleKillMessage', KillCount % 4);
}

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	Super.SpawnHitEffect(P,Damage,Momentum,BoneName,HitLocation);
	if(UTPawn(P) != none)
	{
		UTPawn(P).SoundGroupClass.Static.PlayCrushedSound(P);
	}
}

defaultproperties
{
	KillStatsName=EVENT_RANOVERKILLS
	DeathStatsName=EVENT_RANOVERDEATHS
	SuicideStatsName=SUICIDES_ENVIRONMENT
	RewardCount=10
	RewardEvent=REWARD_ROADRAMPAGE
	RewardAnnouncementClass=class'UTVehicleKillMessage'
	RewardAnnouncementSwitch=7
	GibPerterbation=0.5
	bLocationalHit=false
	bNeverGibs=true
	bUseTearOffMomentum=true
	bExtraMomentumZ=false
	bVehicleHit=true

	NumMessages=4
}
