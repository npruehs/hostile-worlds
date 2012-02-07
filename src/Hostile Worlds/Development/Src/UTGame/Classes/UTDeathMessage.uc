/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//
// A Death Message.
//
// Switch 0: Kill
//	RelatedPRI_1 is the Killer.
//	RelatedPRI_2 is the Victim.
//	OptionalObject is the DamageType Class.
//

class UTDeathMessage extends UTLocalMessage
	config(game);

var(Message) localized string KilledString, SomeoneString;
var config bool bNoConsoleDeathMessages;

static function color GetConsoleColor( PlayerReplicationInfo RelatedPRI_1 )
{
    return class'HUD'.Default.GreenColor;
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string KillerName, VictimName;
	local class<UTDamageType> KillDamageType;

	KillDamageType = (Class<UTDamageType>(OptionalObject) != None) ? Class<UTDamageType>(OptionalObject) : class'UTDamageType';

	if (RelatedPRI_1 == None)
		KillerName = Default.SomeoneString;
	else
		KillerName = RelatedPRI_1.PlayerName;

	if (RelatedPRI_2 == None)
		VictimName = Default.SomeoneString;
	else
		VictimName = RelatedPRI_2.PlayerName;

	if ( Switch == 1 )
	{
		// suicide
		return class'GameInfo'.Static.ParseKillMessage(
			KillerName,
			VictimName,
			KillDamageType.Static.SuicideMessage(RelatedPRI_2) );
	}

	return class'GameInfo'.Static.ParseKillMessage(
		KillerName,
		VictimName,
		KillDamageType.Static.DeathMessage(RelatedPRI_1, RelatedPRI_2) );
}

static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Switch == 1 )
	{
		if ( RelatedPRI_2 == P.PlayerReplicationInfo )
		{
			UTPlayerController(P).ClientMusicEvent(2);
			UTPlayerReplicationInfo(RelatedPRI_2).MultiKillLevel = 0;
		}
		if ( !Default.bNoConsoleDeathMessages )
		{
			Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		}
		return;
	}
	if ( (RelatedPRI_1 == P.PlayerReplicationInfo)
		|| ((P.PlayerReplicationInfo != None) && P.PlayerReplicationInfo.bIsSpectator && (Pawn(P.ViewTarget) != None) && (Pawn(P.ViewTarget).PlayerReplicationInfo == RelatedPRI_1)) )
	{
		UTPlayerController(P).ClientMusicEvent(1);
		// Interdict and send the child message instead.
		if ( P.myHud != None )
			P.myHUD.LocalizedMessage(
				class'UTKillerMessage',
				RelatedPRI_1,
				RelatedPRI_2,
				class'UTKillerMessage'.static.GetString(Switch, RelatedPRI_1 == P.PlayerReplicationInfo, RelatedPRI_1, RelatedPRI_2, OptionalObject),
				Switch,
				class'UTKillerMessage'.static.GetPos(Switch, P.myHUD),
				class'UTKillerMessage'.static.GetLifeTime(Switch),
				class'UTKillerMessage'.static.GetFontSize(Switch, RelatedPRI_1, RelatedPRI_2, P.PlayerReplicationInfo),
				class'UTKillerMessage'.static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2),
				OptionalObject );

		if ( !Default.bNoConsoleDeathMessages )
			Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

		// check multikills
		if ( P.Role == ROLE_Authority )
		{
			// multikills checked already in LogMultiKills()
			if ( UTPlayerReplicationInfo(RelatedPRI_1).MultiKillLevel > 0 )
				P.ReceiveLocalizedMessage( class'UTMultiKillMessage', UTPlayerReplicationInfo(RelatedPRI_1).MultiKillLevel );
		}
		else if ( ( RelatedPRI_1 != RelatedPRI_2 ) && ( RelatedPRI_2 != None)
			&& ((RelatedPRI_2.Team == None) || (RelatedPRI_1.Team != RelatedPRI_2.Team)) )
		{
			if ( (P.WorldInfo.TimeSeconds - UTPlayerReplicationInfo(RelatedPRI_1).LastKillTime < 4) && (Switch != 1) )
			{
				UTPlayerReplicationInfo(RelatedPRI_1).MultiKillLevel++;
				P.ReceiveLocalizedMessage( class'UTMultiKillMessage', UTPlayerReplicationInfo(RelatedPRI_1).MultiKillLevel );
			}
			else
			{
				UTPlayerReplicationInfo(RelatedPRI_1).MultiKillLevel = 0;
			}
			UTPlayerReplicationInfo(RelatedPRI_1).LastKillTime = P.WorldInfo.TimeSeconds;
		}
		else
		{
			UTPlayerReplicationInfo(RelatedPRI_1).MultiKillLevel = 0;
		}
	}
	else if (RelatedPRI_2 == P.PlayerReplicationInfo)
	{
		UTPlayerController(P).ClientMusicEvent(2);
		if ( P.myHud != None )
			P.myHUD.LocalizedMessage(
				class'UTVictimMessage',
				RelatedPRI_1,
				RelatedPRI_2,
				class'UTVictimMessage'.static.GetString(Switch, true, RelatedPRI_1, RelatedPRI_2, OptionalObject),
				0,
				class'UTVictimMessage'.static.GetPos(Switch, P.myHUD),
				class'UTVictimMessage'.static.GetLifeTime(Switch),
				class'UTVictimMessage'.static.GetFontSize(Switch, RelatedPRI_1, RelatedPRI_2, P.PlayerReplicationInfo),
				class'UTVictimMessage'.static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2),
				OptionalObject );
		UTPlayerReplicationInfo(RelatedPRI_2).MultiKillLevel = 0;
		if ( !Default.bNoConsoleDeathMessages )
			Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}
	else if ( !Default.bNoConsoleDeathMessages )
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
	MessageArea=1
	DrawColor=(R=255,G=0,B=0,A=255)
    bIsSpecial=false
}
