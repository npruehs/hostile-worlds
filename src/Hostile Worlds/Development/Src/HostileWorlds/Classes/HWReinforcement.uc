// ============================================================================
// HWReinforcement
// An abstract reinforcements unit of Hostile Worlds. Can have a limited
// lifetime and/or ammo count.
//
// Author:  Nick Pruehs
// Date:    2011/03/14
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWReinforcement extends HWPawn
	abstract;

/** The total lifetime of this unit, in seconds. */
var config float ReinforcementLifeTime;

/** The number of projectiles this unit can fire before it dies. */
var config int AmmoCount;

/** The remaining number of projectiles this unit can fire before it dies. */
var int AmmoCountCurrent;

/** The templates of the particle system to show if while this unit is active corresponding to each team. */
var ParticleSystem ActivatedTemplateTeam1;
var ParticleSystem ActivatedTemplateTeam2;

/** The template of the particle systems to show if this unit is destroyed corresponding to each team. */
var ParticleSystem DestroyedTemplateTeam1;
var ParticleSystem DestroyedTemplateTeam2;


function Initialize(HWMapInfoActor TheMap, optional Actor A)
{
	super.Initialize(TheMap, A);

	if (ReinforcementLifeTime > 0)
	{
		SetTimer(ReinforcementLifeTime, false, 'LifeTimeUp');
	}

	AmmoCountCurrent = AmmoCount;

	// remember reinforcements called for score screen
	OwningPlayer.TotalReinforcementsCalled++;

	// set initial team color on server
	ChangeColor(TeamIndex);
}

function FireProjectile()
{
	super.FireProjectile();

	if (AmmoCount > 0)
	{
		AmmoCountCurrent--;

		if (AmmoCountCurrent <= 0)
		{
			// ammo depleted
			Kill(class'HWDT_Dismiss');
		}
	}
}

/** Called as soon as the lifetime of this unit is up. Kills this unit without having its owner entering combat. */
function LifeTimeUp()
{
	Kill(class'HWDT_Dismiss');
}


DefaultProperties
{
	bUsesTeamColors=true
}
