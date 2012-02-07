// ============================================================================
// HWAb_AirStrike
// Ability that allows to call an air strike onto a target location.
//
// Author:  Marcel Koehler
// Date:    2011/04/15
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAb_AirStrike extends HWAbilityTargetingLocationAOE;

/** The warning time of the incoming air strike (blinking decal on the target location), in seconds. */
var const float WarnTime;

/** The radius in which the grenades can randomly spawn. */
var const int GrenadeSpawnRadius;

/** The height at which the grenades spawn above the TargetLocation. */
var const int GrenadeSpawnHeight;

/** The interval at which the grenades spawn, in seconds. */
var const float GrenadeSpawnInterval;

/** The total numbers of grenades to spawn. */
var config int GrenadeNumber;

/** The drop speed of the missiles, in UU/sec. */
var config float GrenadeSpeed;

/** The damage dealt when a missile explodes. */
var config float GrenadeDamage;

/** The damage radius of each grenade. */
var config float GrenadeDamageRadius;

/** The counter of fired grenades. */
var int GrenadesFired;

/** A decal indicating the radius of the air strike. */
var HWDe_AirStrikeRadius AirStrikeDecal;


function TriggerAbility()
{
	super.TriggerAbility();

	GrenadesFired = 0;
	SetTimer(WarnTime, false, 'StartFiring');
}

simulated function OnAbilityTriggered()
{
	super.OnAbilityTriggered();

	AirStrikeDecal = Spawn(class'HWDe_AirStrikeRadius', self, , TargetLocation);
	AirStrikeDecal.SetRadius(AbilityRadius);
	AirStrikeDecal.SetHidden(false);

	SetTimer(WarnTime, false, 'HideDecal');
}

simulated function HideDecal()
{
	AirStrikeDecal.SetHidden(true);
}

function StartFiring()
{
	GoToState('Firing');
}

function FireGrenade()
{
	local Vector StartLocation;
	local Vector RandomTargetLocation;
	local HWProj_ConcussionGrenade Grenade;

	StartLocation = class'HWGame'.static.GetRandomLocationInRadius(TargetLocation, GrenadeSpawnRadius, , , true);
	StartLocation.Z = TargetLocation.Z + GrenadeSpawnHeight;

	RandomTargetLocation = class'HWGame'.static.GetRandomLocationInRadius(TargetLocation, AbilityRadius, , , true);
	RandomTargetLocation.Z = TargetLocation.Z;

	Grenade = Spawn(class'HWProj_ConcussionGrenade', OwningUnit,,StartLocation);		
	Grenade.Initialize
		(OwningUnit,
		 GrenadeSpeed,
		 GrenadeDamage,
		 GrenadeDamageRadius,
		 RandomTargetLocation, 
		 0.1);
	Grenade.bKnocksTargetBack=true;
	Grenade.ImpactOffset=10;
}

simulated static function string GetHTMLDescription()
{
	local string Result;

	Result = Repl(default.Description, "%1", class'HWHud'.static.HTMLMarkup(default.GrenadeNumber));
	Result = Repl(Result, "%2", class'HWHud'.static.HTMLMarkup(class'HWHud'.static.FloatToString(default.GrenadeDamage, 2)));

	return Result;
}

state Firing
{
	Begin:
		if(GrenadesFired < GrenadeNumber)
		{
			FireGrenade();
			GrenadesFired++;
			Sleep(GrenadeSpawnInterval);

			goto('Begin');
		}
		else
		{
			GoToState('');
		}
}

DefaultProperties
{
	WarnTime=1.5
	GrenadeSpawnRadius=300
	GrenadeSpawnHeight=800
	GrenadeSpawnInterval=0.3

	AbilityIconSubmenu=Texture2D'UI_HWSubmenus.T_UI_Submenu_AirStrike_Test'
}
