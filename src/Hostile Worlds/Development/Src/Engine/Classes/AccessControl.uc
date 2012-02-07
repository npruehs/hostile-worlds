//=============================================================================
// AccessControl.
//
// AccessControl is a helper class for GameInfo.
// The AccessControl class determines whether or not the player is allowed to
// login in the PreLogin() function, and also controls whether or not a player
// can enter as a spectator or a game administrator.
//
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class AccessControl extends Info
	config(Game);

var globalconfig array<string>   IPPolicies;
var globalconfig array<UniqueNetID> BannedIDs;
var	localized string          IPBanned;
var	localized string	      WrongPassword;
var	localized string          NeedPassword;
var localized string          SessionBanned;
var localized string		  KickedMsg;
var localized string          DefaultKickReason;
var localized string		  IdleKickReason;
var class<Admin> AdminClass;

var private globalconfig string AdminPassword;	    // Password to receive bAdmin privileges.
var private globalconfig string GamePassword;		    // Password to enter game.

var localized string ACDisplayText[3];
var localized string ACDescText[3];

var bool bDontAddDefaultAdmin;


/**
 * @return	TRUE if the specified player has admin priveleges.
 */
function bool IsAdmin(PlayerController P)
{
	if ( P != None )
	{
		if ( Admin(P) != None )
		{
			return true;
		}

		if ( P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.bAdmin )
		{
			return true;
		}
	}

	return false;
}

function bool SetAdminPassword(string P)
{
	AdminPassword = P;
	return true;
}

function SetGamePassword(string P)
{
	GamePassword = P;
	WorldInfo.Game.UpdateGameSettings();
}

function bool RequiresPassword()
{
	return GamePassword != "";
}

/**
 * Takes a string and tries to find the matching controller associated with it.  First it searches as if the string is the
 * player's name.  If it doesn't find a match, it attempts to resolve itself using the target as the player id.
 *
 * @Params	Target		The search key
 *
 * @returns the controller assoicated with the key.  NONE is a valid return and means not found.
 */
function Controller GetControllerFromString(string Target)
{
	local Controller C,FinalC;
	local int i;

	FinalC = none;
	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		if (C.PlayerReplicationInfo != None && (C.PlayerReplicationInfo.PlayerName ~= Target || C.PlayerReplicationInfo.PlayerName ~= Target))
		{
			FinalC = C;
			break;
		}
	}

	// if we didn't find it by name, attemtp to convert the target to a player index and look him up if possible.
	if ( C == none && WorldInfo != none && WorldInfo.GRI != none )
	{
		for (i=0;i<WorldInfo.GRI.PRIArray.Length;i++)
		{
			if ( String(WorldInfo.GRI.PRIArray[i].PlayerID) == Target )
			{
				FinalC = Controller(WorldInfo.GRI.PRIArray[i].Owner);
				break;
			}
		}
	}

	return FinalC;
}

function Kick( string Target )
{
	local Controller C;

	C = GetControllerFromString(Target);
	if ( C != none && C.PlayerReplicationInfo != None )
	{
		if (PlayerController(C) != None)
		{
			KickPlayer(PlayerController(C), DefaultKickReason);
		}
		else if (C.PlayerReplicationInfo != None)
		{
			if (C.Pawn != None)
			{
				C.Pawn.Destroy();
			}
			if (C != None)
			{
				C.Destroy();
			}
		}
	}
}

function KickBan( string Target )
{
	local PlayerController P;
	local string IP;

	P =  PlayerController( GetControllerFromString(Target) );
	if ( NetConnection(P.Player) != None )
	{
		if (!WorldInfo.IsConsoleBuild())
		{
			IP = P.GetPlayerNetworkAddress();
			if( CheckIPPolicy(IP) )
			{
				IP = Left(IP, InStr(IP, ":"));
				`Log("Adding IP Ban for: "$IP);
				IPPolicies[IPPolicies.length] = "DENY," $ IP;
				SaveConfig();
			}
		}

		if ( P.PlayerReplicationInfo.UniqueId != P.PlayerReplicationInfo.default.UniqueId &&
			!IsIDBanned(P.PlayerReplicationInfo.UniqueID) )
		{
			BannedIDs.AddItem(P.PlayerReplicationInfo.UniqueId);
			SaveConfig();
		}
		KickPlayer(P, DefaultKickReason);
		return;
	}
}

function bool ForceKickPlayer(PlayerController C, string KickReason)
{
	if (C != None && NetConnection(C.Player)!=None )
	{
		if (C.Pawn != None)
		{
			C.Pawn.Suicide();
		}
		C.ClientWasKicked();
		if (C != None)
		{
			C.Destroy();
		}
		return true;
	}
	return false;
}

function bool KickPlayer(PlayerController C, string KickReason)
{
	// Do not kick logged admins
	if (C != None && !IsAdmin(C) && NetConnection(C.Player)!=None )
	{
		return ForceKickPlayer(C, KickReason);
	}
	return false;
}

function bool AdminLogin( PlayerController P, string Password )
{
	if (AdminPassword == "")
		return false;

	if (Password == AdminPassword)
	{
		P.PlayerReplicationInfo.bAdmin = true;
		return true;
	}
	return false;
}

function bool AdminLogout(PlayerController P)
{
	if (P.PlayerReplicationInfo.bAdmin)
	{
		P.PlayerReplicationInfo.bAdmin = false;
		P.bGodMode = false;
		P.Suicide();

		return true;
	}

	return false;
}

function AdminEntered( PlayerController P )
{
	local string LoginString;

	LoginString = P.PlayerReplicationInfo.PlayerName@"logged in as a server administrator.";

	`log(LoginString);
	WorldInfo.Game.Broadcast( P, LoginString );
}
function AdminExited( PlayerController P )
{
	local string LogoutString;

	LogoutString = P.PlayerReplicationInfo.PlayerName$"is no longer logged in as a server administrator.";

	`log(LogoutString);
	WorldInfo.Game.Broadcast( P, LogoutString );
}

/**
 * Parses the specified string for admin auto-login options
 *
 * @param	Options		a string containing key/pair options from the URL (?key=value,?key=value)
 *
 * @return	TRUE if the options contained name and password which were valid for admin login.
 */
function bool ParseAdminOptions( string Options )
{
	local string InAdminName, InPassword;

	InPassword = class'GameInfo'.static.ParseOption( Options, "Password" );
	InAdminName= class'GameInfo'.static.ParseOption( Options, "AdminName" );

	return ValidLogin(InAdminName, InPassword);
}

/**
 * @return	TRUE if the specified username + password match the admin username/password
 */
function bool ValidLogin(string UserName, string Password)
{
	return (AdminPassword != "" && Password==AdminPassword);
}

//
// Accept or reject a player on the server.
// Fails login if you set the OutError to a non-empty string.
//
event PreLogin(string Options, string Address, out string OutError, bool bSpectator)
{
	// Do any name or password or name validation here.
	local string InPassword;

	OutError="";
	InPassword = WorldInfo.Game.ParseOption( Options, "Password" );

	if( (WorldInfo.NetMode != NM_Standalone) && WorldInfo.Game.AtCapacity(bSpectator) )
	{
		OutError = PathName(WorldInfo.Game.GameMessageClass) $ ".MaxedOutMessage";
	}
	else if ( GamePassword != "" && Caps(InPassword) != Caps(GamePassword) &&
		(AdminPassword == "" || Caps(InPassword) != Caps(AdminPassword)) )
	{
		OutError = (InPassword == "") ? "Engine.AccessControl.NeedPassword" : "Engine.AccessControl.WrongPassword";
	}

	if (!CheckIPPolicy(Address))
	{
		OutError = "Engine.AccessControl.IPBanned";
	}
}


function bool CheckIPPolicy(string Address)
{
	local int i, j;
`if(`notdefined(FINAL_RELEASE))
	local int LastMatchingPolicy;
`endif
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;

	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = True;
	for(i=0; i<IPPolicies.Length; i++)
	{
		j = InStr(IPPolicies[i], ",");
		if(j==-1)
			continue;
		Policy = Left(IPPolicies[i], j);
		Mask = Mid(IPPolicies[i], j+1);
		if(Policy ~= "ACCEPT")
			bAcceptPolicy = True;
			else if(Policy ~= "DENY")
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				`if(`notdefined(FINAL_RELEASE))
				LastMatchingPolicy = i;
				`endif
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				`if(`notdefined(FINAL_RELEASE))
				LastMatchingPolicy = i;
				`endif
			}
		}
	}

	if(!bAcceptAddress)
	{
		`Log("Denied connection for "$Address$" with IP policy "$IPPolicies[LastMatchingPolicy]);
	}

	return bAcceptAddress;
}

function bool IsIDBanned(const out UniqueNetID NetID)
{
	local int i;

	for (i = 0; i < BannedIDs.length; i++)
	{
		if (BannedIDs[i] == NetID)
		{
			return true;
		}
	}
	return false;
}

defaultproperties
{
	AdminClass=class'Engine.Admin'
}
