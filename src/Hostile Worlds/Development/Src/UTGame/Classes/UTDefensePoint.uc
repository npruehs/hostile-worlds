/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
/** defines a place bots should defend. Bots automatically determine reasonable defending positions in sight of their
 * objective (e.g. flag room), so these should only be used for hard to reach camping spots or choke points far from the objective area
 */
class UTDefensePoint extends UDKScriptedNavigationPoint
	placeable;

var Controller CurrentUser;
var UTDefensePoint NextDefensePoint;	// list of defensepoints for same objective
var() UDKGameObjective DefendedObjective;
var bool bFirstScript;				// first script in list of scripts
var() bool bSniping;				// bots should snipe when using this script as a defense point
var() bool bOnlyOnFoot; 		// bot should not attempt to use this script while in a vehicle
var() bool bOnlySkilled;		// low skill bots shouldn't use this defense point
var() class<Weapon> WeaponPreference;	// bots using this defense point will preferentially use this weapon
/** defensepoint grouping - bots will make sure each group has at least one defender before assigning a second */
var() name DefenseGroup;
var() enum EDefensePriority
{
	/** this point will be used after automatic defensepoints */
	DEFPRI_Low,
	/** this point will be used before automatic defensepoints */
	DEFPRI_High,
} DefensePriority;

/** sprites used for this actor in the editor, depending on which team DefendedObjective is on (if possible to determine in editor) */
var editoronly array<Texture2D> TeamSprites;

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	FreePoint();
}

function FreePoint()
{
	CurrentUser = None;
}

function bool CheckForErrors()
{
	if ( DefendedObjective == None )
	{
		`Log(Self$" has no DefendedObjective!");
		return true;
	}

	return Super.CheckForErrors();
}

function PreBeginPlay()
{
	local UTDefensePoint S, Last;

	Super.PreBeginPlay();

	if ( DefendedObjective == None )
	{
		`Warn(self @ "has no DefendedObjective!");
	}
	else if ( bFirstScript )
	{
		Last = self;
		// first one initialized - create script list
		ForEach AllActors(class'UTDefensePoint',S)
			if ( (S != self) && (S.DefendedObjective == DefendedObjective) )
			{
				Last.NextDefensePoint = S;
				S.bFirstScript = false;
				Last = S;
			}
	}
}

/** determines if this point is higher priority than the passed in point
 * @param S - the point to check against
 * @param B - the bot that's checking
 * @param bAutoPointsInUse - whether other bot(s) on this team are using the automatic defensepoints (so allow low priority)
 * @param bPrioritizeSameGroup - if true, prefer defensepoints of the same group as current, all else being equal
 * @param NumChecked - the number of usable points so far
 * @return whether this point is a better choice
 */
function bool HigherPriorityThan(UTDefensePoint S, UTBot B, bool bAutoPointsInUse, bool bPrioritizeSameGroup, out int NumChecked)
{
	if ( bBlocked || (bOnlySkilled && B.Skill < 3.0) || (bOnlyOnFoot && Vehicle(B.Pawn) != None) ||
		(!bAutoPointsInUse && DefensePriority < DEFPRI_High) )
	{
		return false;
	}
	if (CurrentUser != None && !CurrentUser.bDeleteMe && CurrentUser != B && WorldInfo.GRI.OnSameTeam(CurrentUser, B))
	{
		if (UTBot(CurrentUser) != None && UTBot(CurrentUser).DefensePoint != self)
		{
			UTBot(CurrentUser).DefensePoint = None;
		}
		else
		{
			return false;
		}
	}
	if (S == None || S.DefensePriority < DefensePriority)
	{
		return true;
	}
	if (S.DefensePriority > DefensePriority)
	{
		return false;
	}
	if (B.FavoriteWeapon != None && ClassIsChildOf(WeaponPreference, B.FavoriteWeapon))
	{
		return true;
	}
	if (bPrioritizeSameGroup && S.DefenseGroup != DefenseGroup)
	{
		return false;
	}
	NumChecked++;
	return (FRand() < 1.0 / float(NumChecked));
}

function Actor GetMoveTarget()
{
	return self;
}

defaultproperties
{
	Begin Object NAME=Sprite
		Sprite=Texture2D'EnvyEditorResources.DefensePoint'
	End Object

	TeamSprites[0]=Texture2D'EnvyEditorResources.RedDefense'
	TeamSprites[1]=Texture2D'EnvyEditorResources.BlueDefense'

	bStatic=true
	bCollideWhenPlacing=true
	bFirstScript=true
}
