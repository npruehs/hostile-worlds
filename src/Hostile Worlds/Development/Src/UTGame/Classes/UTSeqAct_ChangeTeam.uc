/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTSeqAct_ChangeTeam extends SequenceAction;

var() byte NewTeamNum;

event Activated()
{
	local SeqVar_Object ObjVar;
	local Pawn P;
	local Controller C;
	local UTTeamGame Game;

	Game = UTTeamGame(GetWorldInfo().Game);
	if (Game != None)
	{
		foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Target")
		{
			// find the object to change the team of
			C = Controller(ObjVar.GetObjectValue());
			if (C == None)
			{
				P = Pawn(ObjVar.GetObjectValue());
				if (P != None)
				{
					if (P.Controller != None)
					{
						C = P.Controller;
					}
					else if (UTVehicle(P) != None)
					{
						// vehicle with no controller has its own team
						UTVehicle(P).SetTeamNum(NewTeamNum);
					}
				}
			}
			// if we got a player, change its team
			if (C != None && C.PlayerReplicationInfo != None)
			{
				if (C.PlayerReplicationInfo.Team != None)
				{
					C.PlayerReplicationInfo.Team.RemoveFromTeam(C);
					C.PlayerReplicationInfo.Team = None;
				}
				if (NewTeamNum != 255)
				{
					Game.Teams[NewTeamNum].AddToTeam(C);
				}
				// update the pawn (teamskins, etc)
				if (C.Pawn != None)
				{
					C.Pawn.NotifyTeamChanged();
				}
			}
		}
	}
}

defaultproperties
{
	ObjCategory="Team"
	ObjName="Change Team"
	bCallHandler=false
}
