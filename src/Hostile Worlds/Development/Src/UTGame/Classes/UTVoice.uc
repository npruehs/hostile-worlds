/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVoice extends UTLocalMessage
	abstract;

var Array<SoundNodeWave> AckSounds;
var Array<SoundNodeWave> FriendlyFireSounds;
var Array<SoundNodeWave> GotYourBackSounds;
var Array<SoundNodeWave> NeedOurFlagSounds;
var Array<SoundNodeWave> SniperSounds;
var Array<SoundNodeWave> InPositionSounds;
var Array<SoundNodeWave> HaveFlagSounds;
var Array<SoundNodeWave> AreaSecureSounds;

var SoundNodeWave IncomingSound;
var SoundNodeWave EnemyFlagCarrierSound;
var SoundNodeWave EnemyFlagCarrierHereSound;
var SoundNodeWave EnemyFlagCarrierHighSound;
var SoundNodeWave EnemyFlagCarrierLowSound;
var SoundNodeWave MidfieldSound;
var SoundNodeWave GotOurFlagSound;

/** Offset into actor specific location speech array */
var int LocationSpeechOffset;

/** Index offsets for message groups */
const ACKINDEXSTART = 600;
const FRIENDLYFIREINDEXSTART = 700;
const GOTYOURBACKINDEXSTART = 800;
const NEEDOURFLAGINDEXSTART = 900;
const SNIPERINDEXINDEXSTART = 1000;
const LOCATIONUPDATEINDEXSTART = 1100;
const INPOSITIONINDEXSTART = 1200;
const ENEMYSTATUSINDEXSTART = 1300;
const KILLEDVEHICLEINDEXSTART = 1400;
const ENEMYFLAGCARRIERINDEXSTART = 1500;
const HOLDINGFLAGINDEXSTART = 1600;
const AREASECUREINDEXSTART = 1700;
const GOTOURFLAGINDEXSTART = 1900;
const NODECONSTRUCTEDINDEXSTART = 2000;

static function int GetAckMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	if ( default.AckSounds.Length == 0)
	{
		return -1;
	}
	return ACKINDEXSTART + Rand(default.AckSounds.Length);
}

static function int GetFriendlyFireMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	if ( (default.FriendlyFireSounds.Length == 0) || (Recipient == None) || (UTPlayerController(Recipient.Owner) == None) )
	{
		return -1;
	}
	UTPlayerController(Recipient.Owner).LastFriendlyFireTime = Sender.WorldInfo.TimeSeconds;

	return FRIENDLYFIREINDEXSTART + Rand(default.FriendlyFireSounds.Length);
}

static function int GetGotYourBackMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	if ( default.GotYourBackSounds.Length == 0)
	{
		return -1;
	}
	return GOTYOURBACKINDEXSTART + Rand(default.GotYourBackSounds.Length);
}

static function int GetNeedOurFlagMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	if ( default.NeedOurFlagSounds.Length == 0)
	{
		return -1;
	}
	return NEEDOURFLAGINDEXSTART + Rand(default.NeedOurFlagSounds.Length);
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	UTPlayerController(P).PlayAnnouncement(default.class, Switch, RelatedPRI_1, OptionalObject );
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	local UTPickupFactory F;
	local UTGameObjective O;
	local UTCTFFlag Flag;

	MessageIndex -= 500;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.AckSounds.Length )
	{
		return default.AckSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.FriendlyFireSounds.Length )
	{
		return default.FriendlyFireSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.GotYourBackSounds.Length )
	{
		return default.GotYourBackSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.NeedOurFlagSounds.Length )
	{
		return default.NeedOurFlagSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.SniperSounds.Length )
	{
		return default.SniperSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < 100 )
	{
		if ( (OptionalObject == None) || (MessageIndex == 10) )
		{
			return default.MidFieldSound;
		}
		O = UTGameObjective(OptionalObject);
		if ( O != None )
		{
			return O.GetLocationSpeechFor(PC, default.LocationSpeechOffset, MessageIndex);
		}
		F = UTPickupFactory(OptionalObject);
		if ( F != None )
		{
			return (default.LocationSpeechOffset < F.LocationSpeech.Length) ? F.LocationSpeech[default.LocationSpeechOffset] : None;
		}
		return default.MidFieldSound;
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.InPositionSounds.Length )
	{
		return default.InPositionSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex == 0 )
	{
		// Enemy sound - "incoming", orb/flag carrier, or vehicle
		return EnemySound(PC, OptionalObject);
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex == 0 )
	{
		return KilledVehicleSound(PC, OptionalObject);
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < 100 )
	{
		// ping enemy flag carrier
		Flag = UTCTFFlag(OptionalObject);

		if ( (Flag != None) && PC.WorldInfo.GRI.OnSameTeam(Flag, PC) )
		{
			Flag.LastLocationPingTime = PC.WorldInfo.TimeSeconds;
		}
		// enemy flag carrier here
		if ( MessageIndex == 2 )
			return default.EnemyFlagCarrierHighSound;
		else if ( MessageIndex == 3)
			return default.EnemyFlagCarrierLowSound;

		return default.EnemyFlagCarrierHereSound;
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < 100 )
	{
		MessageIndex -= 50;
		if ( MessageIndex < 0 )
		{
			return None;
		}
		if ( MessageIndex < default.HaveFlagSounds.Length )
		{
			return default.HaveFlagSounds[MessageIndex];
		}
		return None;
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.AreaSecureSounds.Length )
	{
		return default.AreaSecureSounds[MessageIndex];
	}
	MessageIndex -= 200;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex == 0 )
	{
		return default.GotOurFlagSound;
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	return None;
}

static function SoundNodeWave EnemySound(PlayerController PC, object OptionalObject)
{
	local class<UTVehicle> VehicleClass;
	local UTPlayerReplicationInfo PRI;
	local UTPlayerController UTPC;
	local UTCTFFlag Flag;

	VehicleClass = class<UTVehicle>(OptionalObject);

	if ( VehicleClass == None )
	{
		PRI = UTPlayerReplicationInfo(OptionalObject);
		if ( (PRI == None) || !PRI.bHasFlag || (PC.WorldInfo.GRI == None) || (PC.WorldInfo.GRI.GameClass == None) )
		{
			UTPC = UTPlayerController(PC);
			if ( (UTPC != None) && (UTPC.WorldInfo.TimeSeconds - UTPC.LastIncomingMessageTime > 35) )
			{
				UTPC.LastIncomingMessageTime = UTPC.WorldInfo.TimeSeconds;
			return default.IncomingSound;
		}
			return None;
		}

		Flag = UTCTFFlag(PRI.GetFlag());
		if ( Flag != None )
		{
			Flag.LastLocationPingTime = PC.WorldInfo.TimeSeconds;
		}
		
		if ( default.LocationSpeechOffset < 3 )
		{
			return default.EnemyFlagCarrierSound;
		}

		// HACK since these voices can't give location
		if ( (UTPC != None) && (UTPC.WorldInfo.TimeSeconds - UTPC.LastIncomingMessageTime > 25) )
		{
			UTPC.LastIncomingMessageTime = UTPC.WorldInfo.TimeSeconds;
		return default.EnemyFlagCarrierSound;
	}
		return None;
	}

	if ( VehicleClass.default.EnemyVehicleSound.Length > default.LocationSpeechOffset )
	{
		return VehicleClass.default.EnemyVehicleSound[default.LocationSpeechOffset];
	}
	
	UTPC = UTPlayerController(PC);
	if ( (UTPC != None) && (UTPC.WorldInfo.TimeSeconds - UTPC.LastIncomingMessageTime > 35) )
	{
		UTPC.LastIncomingMessageTime = UTPC.WorldInfo.TimeSeconds;
		return default.IncomingSound;
	}
	return None;
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return "";
}

static function bool AllowVoiceMessage(name MessageType, UTPlayerController PC, PlayerController Recipient)
{
	local float CurrentTime;

	if ( PC.WorldInfo.NetMode == NM_Standalone )
		return true;

	CurrentTime = PC.WorldInfo.TimeSeconds;
	if ( CurrentTime - PC.OldMessageTime < 4 )
	{
		if ( (MessageType == 'TAUNT') || (CurrentTime - PC.OldMessageTime < 1) )
		{
			return false;
		}
	}
	if ( (Recipient != None) && Recipient.IsPlayerMuted(PC.PlayerReplicationInfo.UniqueID) )
	{
		return false;
	}
	if ( CurrentTime - PC.OldMessageTime < 6 )
		PC.OldMessageTime = CurrentTime + 3;
	else
		PC.OldMessageTime = CurrentTime;

	return true;
}

/**
  *
  */
static function SendVoiceMessage(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype, class<DamageType> DamageType)
{
	local UTPlayerController PC, SenderPC, RecipientPC;
	local int MessageIndex;
	local bool bFoundFriendlyPlayer;
	local UTPlayerReplicationInfo SenderPRI;

	// Can message be sent?
	SenderPRI = UTPlayerReplicationInfo(Sender.PlayerReplicationInfo);
	if ( SenderPRI == None )
	{
		return;
	}
	SenderPC = UTPlayerController(Sender);
	RecipientPC = (Recipient != None) ? UTPlayerController(Recipient.Owner) : None;

	// early out if not sending to any players
	if ( (RecipientPC == None) && Sender.WorldInfo.Game.bTeamGame )
	{
		// make sure have players on my team
		foreach Sender.WorldInfo.AllControllers(class'UTPlayerController', PC)
		{
			if ( (Sender.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo != None) 
				&& (Sender.PlayerReplicationInfo.Team == PC.PlayerReplicationInfo.Team) && (Sender != PC) )
			{
				bFoundFriendlyPlayer = true;
				break;
			}
		}
		if ( !bFoundFriendlyPlayer )
		{
			return;
		}
	}
	if ( (SenderPC != None) && !AllowVoiceMessage(MessageType, SenderPC, RecipientPC) )
	{
		return;
	}

	MessageIndex = GetMessageIndex(Sender, Recipient, MessageType, DamageType);
	if ( MessageIndex == -1 )
	{
		// already handled special case (like status)
		return;
	}
	if ( Recipient != None )
	{
		if ( RecipientPC != None )
		{
			RecipientPC.ReceiveBotVoiceMessage(SenderPRI, MessageIndex, None);
		}
		return;
	}

	foreach Sender.WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		if ( ((PC == Sender) || !Sender.WorldInfo.Game.bTeamGame || Sender.WorldInfo.GRI.bMatchIsOver || ((Sender.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo != None) && (Sender.PlayerReplicationInfo.Team == PC.PlayerReplicationInfo.Team)))
			&& !PC.IsPlayerMuted(Sender.PlayerReplicationInfo.UniqueID) )
		{
				PC.ReceiveBotVoiceMessage(SenderPRI, MessageIndex, None);
		}
	}
}

static function int GetMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype, class<DamageType> DamageType)
{
    switch (Messagetype)
    {
		case 'TAUNT':
			return -1;

		case 'INJURED':
			InitCombatUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'STATUS':
			InitStatusUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'INCOMING':
		case 'INCOMINGVEHICLE':
			SendEnemyStatusUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'LOCATION':
			SendLocationUpdate(Sender, Recipient, MessageType, UTGame(Sender.WorldInfo.Game), Sender.Pawn);
			return -1;

		case 'INPOSITION':
			SendInPositionMessage(Sender, Recipient, MessageType);
			return -1;

		case 'MANDOWN':
			return -1;

		case 'FRIENDLYFIRE':
			return GetFriendlyFireMessageIndex(Sender, Recipient, MessageType);

		case 'ENCOURAGEMENT':
			return -1;

		case 'FLAGKILL':
			return -1;

		case 'ACK':
			return GetAckMessageIndex(Sender, Recipient, MessageType);

		case 'SNIPER':
			InitSniperUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'GOTYOURBACK':
			return GetGotYourBackMessageIndex(Sender, Recipient, MessageType);

		case 'HOLDINGFLAG':
			SetHoldingFlagUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'GOTOURFLAG':
			return GOTOURFLAGINDEXSTART;

		case 'NEEDOURFLAG':
			return GetNeedOurFlagMessageIndex(Sender, Recipient, MessageType);

		case 'ENEMYFLAGCARRIERHERE':
			SendEnemyFlagCarrierHereUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'VEHICLEKILL':
			SendKilledVehicleMessage(Sender, Recipient, MessageType);
			return -1;
	}
	return -1;
}

static function InitStatusUpdate(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	local UTBot B;
	local name BotOrders;

	B = UTBot(Sender);
	if ( B != None )
	{
		if ( B.Pawn == None )
		{
			return;
		}
		BotOrders = B.GetOrders();
		if ( (BotOrders == 'defend') || (BotOrders == 'hold') )
		{
			if ( (UTDefensePoint(B.Pawn.Anchor) != None)
				|| ((UTGameObjective(B.Squad.SquadObjective) != None) &&
					(VSizeSq(B.Pawn.Location - B.Squad.SquadObjective.Location) < Square(UTGameObjective(B.Squad.SquadObjective).BaseRadius))) )
			{
				InitCombatUpdate(Sender, Recipient, MessageType);
				return;
			}
		}
	}
	if ( SendLocationUpdate(Sender, Recipient, Messagetype, UTGame(Sender.WorldInfo.Game), Sender.Pawn, true) || (B == None) )
	{
		return;
	}

	InitCombatUpdate(Sender, Recipient, MessageType);
}

static function InitCombatUpdate(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	local int MessageIndex;

	if ( Sender.Enemy == None )
	{
		if ( default.AreaSecureSounds.Length == 0 )
		{
			return;
		}
		MessageIndex = AREASECUREINDEXSTART + Rand(default.AreaSecureSounds.Length);
	}
	else
	{
		return;
	}
	SendLocalizedMessage(Sender, Recipient, MessageType, MessageIndex);
}

static function SetHoldingFlagUpdate(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	local int MessageIndex;

	MessageIndex = HOLDINGFLAGINDEXSTART;
	if ( default.HaveFlagSounds.Length == 0 )
	{
		return;
	}
	MessageIndex += 50 + Rand(default.HaveFlagSounds.Length);
	SendLocalizedMessage(Sender, Recipient, MessageType, MessageIndex);
}

static function SendLocalizedMessage(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype, int MessageIndex, optional object LocationObject)
{
	local UTPlayerController PC;
	local UTPlayerReplicationInfo SenderPRI;

	SenderPRI = UTPlayerReplicationInfo(Sender.PlayerReplicationInfo);
	if ( SenderPRI == None )
	{
		return;
	}
	if ( Recipient != None )
	{
		PC = UTPlayerController(Recipient.Owner);
		if ( PC != None )
		{
			PC.ReceiveBotVoiceMessage(SenderPRI, MessageIndex, LocationObject);
		}
	}
	else
	{
		foreach Sender.WorldInfo.AllControllers(class'UTPlayerController', PC)
		{
			if ( (!Sender.WorldInfo.Game.bTeamGame || ((Sender.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo != None) && (Sender.PlayerReplicationInfo.Team == PC.PlayerReplicationInfo.Team)))
				&& !PC.IsPlayerMuted(Sender.PlayerReplicationInfo.UniqueID) )
			{
				PC.ReceiveBotVoiceMessage(SenderPRI, MessageIndex, LocationObject);
			}
		}
	}
}

static function SendEnemyFlagCarrierHereUpdate(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	local Actor LocationObject;
	local int MessageIndex;
	local UTGame G;
	local Pawn StatusPawn;
	local UTCarriedObject Flag;

	G = UTGame(Sender.WorldInfo.Game);
	StatusPawn = Sender.Enemy;
	if ( StatusPawn == None )
	{
		return;
	}
	Flag = UTPlayerReplicationInfo(StatusPawn.PlayerReplicationInfo).GetFlag();
	if ( Flag == None )
	{
		return;
	}

	if ( (G != None) && G.bTeamGame && (StatusPawn != None) && G.GetLocationFor(StatusPawn, LocationObject, MessageIndex, default.LocationSpeechOffset) )
	{
		if ( (Sender.WorldInfo.TimeSeconds - Flag.LastFlagSeeTime < 20)
			&& (MessageIndex == Flag.LastSeeMessageIndex) )
		{
			// don't repeat same flag carrier message too often
			return;
		}

		Flag.LastFlagSeeTime = Sender.WorldInfo.TimeSeconds;
		Flag.LastSeeMessageIndex = MessageIndex;

		MessageIndex += ENEMYFLAGCARRIERINDEXSTART;
		SendLocalizedMessage(Sender, Recipient, MessageType, MessageIndex, Flag);

		// also send location phrase if near/inside base
		if  ( MessageIndex < 1502 )
		{
			MessageIndex -= 400;
			SendLocalizedMessage(Sender, Recipient, MessageType, MessageIndex, LocationObject);
		}
	}
}

static function InitSniperUpdate(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	local int MessageIndex;
	local UTGame G;

	if ( default.SniperSounds.Length == 0 )
	{
		return;
	}
	MessageIndex = SNIPERINDEXINDEXSTART + Rand(default.SniperSounds.Length);
	SendLocalizedMessage(Sender, Recipient, MessageType, MessageIndex);

	// now play sniper location
	G = UTGame(Sender.WorldInfo.Game);
	if ( (G == None) || (G.Sniper == None) )
	{
		return;
	}
	SendLocationUpdate(Sender, Recipient, Messagetype, G, G.Sniper);
}

static function SendEnemyStatusUpdate(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	local UTPlayerReplicationInfo EnemyPRI;
	local object EnemyObject;
	local UTVehicle V;
	local int MessageIndex;

	if ( Sender.Enemy == None )
	{
		return;
	}

	// possibly say "incoming!" or identify if flag/orb carrier or big vehicle
	MessageIndex = ENEMYSTATUSINDEXSTART;
	EnemyPRI = UTPlayerReplicationInfo(Sender.Enemy.PlayerReplicationInfo);
	EnemyObject = EnemyPRI;
	if ( (EnemyObject == None) || !EnemyPRI.bHasFlag )
	{
		// maybe send vehicle class instead
		V = UTVehicle(Sender.Enemy);
		if ( (V != None) && V.bHasEnemyVehicleSound && (V.EnemyVehicleSound.Length > default.LocationSpeechOffset) )
		{
			EnemyObject = V.class;
			V.LastEnemyWarningTime = Sender.WorldInfo.TimeSeconds;
		}
		else
		{
			V = None;
		}
	}
	SendLocalizedMessage(Sender, Recipient, MessageType, MessageIndex, EnemyObject);

	if ( (V == None) && !EnemyPRI.bHasFlag )
	{
		// don't say "incoming" + location
		return;
	}

	// send enemy location update
	SendLocationUpdate(Sender,Recipient, Messagetype, UTGame(Sender.WorldInfo.Game), Sender.Enemy);
}

static function SendKilledVehicleMessage(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	local UTBot B;

	B = UTBot(Sender);
	if ( (B == None) || (B.KilledVehicleClass == None) )
	{
		return;
	}
	SendLocalizedMessage(Sender, Recipient, MessageType, KILLEDVEHICLEINDEXSTART, B.KilledVehicleClass);
}

static function SoundNodeWave KilledVehicleSound(PlayerController PC, object OptionalObject)
{
	local class<UTVehicle> VehicleClass;

	VehicleClass = class<UTVehicle>(OptionalObject);

	if ( VehicleClass == None )
	{
		return None;
	}

	return (VehicleClass.default.VehicleDestroyedSound.Length > default.LocationSpeechOffset)
				? VehicleClass.default.VehicleDestroyedSound[default.LocationSpeechOffset]
				: None;
}

static function bool SendLocationUpdate(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype, UTGame G, Pawn StatusPawn, optional bool bDontSendMidfield)
{
	local Actor LocationObject;
	local int MessageIndex;

	if ( (G != None) && G.bTeamGame && (StatusPawn != None) && G.GetLocationFor(StatusPawn, LocationObject, MessageIndex, default.LocationSpeechOffset) )
	{
		if ( bDontSendMidfield && (MessageIndex == 10) )
		{
			return false;
		}
		MessageIndex += LOCATIONUPDATEINDEXSTART;
		SendLocalizedMessage(Sender, Recipient, MessageType, MessageIndex, LocationObject);
		return true;
	}
	return false;
}

static function SendInPositionMessage(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	if ( default.InPositionSounds.Length > 0)
	{
		SendLocalizedMessage(Sender, Recipient, MessageType, INPOSITIONINDEXSTART + Rand(default.InPositionSounds.Length));
	}
	InitCombatUpdate(Sender, Recipient, MessageType);
}

/**
 * Kill regular voice messages if doing banter, or if there are too many voice messages in front of them
 */
static function bool ShouldBeRemoved(UTQueuedAnnouncement MyAnnouncement, class<UTLocalMessage> NewAnnouncementClass, int NewMessageIndex)
{
	local UTQueuedAnnouncement A;
	local int VoiceMessageCount, MaxCount;

	if ( NewAnnouncementClass == class'UTScriptedVoiceMessage' )
	{
		return true;
	}
	if ( ClassIsChildOf(NewAnnouncementClass, class'UTVoice') )
	{
		// check how many voice messages are between me and end
		MaxCount = ((MyAnnouncement.MessageIndex >= LOCATIONUPDATEINDEXSTART) && (MyAnnouncement.MessageIndex < LOCATIONUPDATEINDEXSTART+100))
					? 0
					: 1;
		For ( A=MyAnnouncement.NextAnnouncement; A!=None; A=A.NextAnnouncement )
		{
			if ( ClassIsChildOf(A.AnnouncementClass, class'UTVoice') )
			{
				VoiceMessageCount++;
				if ( VoiceMessageCount > MaxCount )
				{
					return true;
				}
			}
		}
	}
	return false;
}


/*
 * Don't play voice message if banter is playing.
 *
 */
static function bool AddAnnouncement(UTAnnouncer Announcer, int MessageIndex, optional PlayerReplicationInfo PRI, optional Object OptionalObject)
{
	local UTQueuedAnnouncement A;

	For ( A=Announcer.Queue; A!=None; A=A.NextAnnouncement )
	{
		if ( A.AnnouncementClass == class'UTScriptedVoiceMessage' )
		{
			return false;
		}
	}

	super.AddAnnouncement(Announcer, MessageIndex, PRI, OptionalObject);
	return false;
}

defaultproperties
{
	bShowPortrait=true
	bIsConsoleMessage=false
	AnnouncementDelay=0.75
	AnnouncementPriority=-1
	AnnouncementVolume=2.0
}


