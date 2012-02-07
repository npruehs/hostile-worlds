// ============================================================================
// HWGameResults
// A collection of game stats to be sent from the server to all clients after
// a match is over. This way all players can see the stats of all players, even
// if any player logs out or the server shuts down.
//
// Author:  Nick Pruehs
// Date:    2010/11/04
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGameResults extends Actor;

var string MapName;
var int MapTime;

var string PlayerNames[8];

var int ScoresUnits[8];
var int ScoresResources[8];
var int ScoresCombat[8];
var int ScoresAbilities[8];
var int ScoresTotal[8];

var int TotalAliensKilled[8];
var int TotalSquadMembersKilled[8];
var int TotalSquadMembersLost[8];
var int TotalSquadMembersDismissed[8];
var int TotalReinforcementsCalled[8];

var int TotalShardsFarmed[8];
var int TotalArtifactsAcquired[8];
var int TotalVision[8];
var int TotalActions[8];

var int TotalDamageDealt[8];
var int TotalDamageTaken[8];
var int TotalDamageHealed[8];

var int TotalAbilitiesTriggered[8];
var int TotalTacticalAbilitiesTriggered[8];
var int TotalKnockbacksCaused[8];
var int TotalKnockbacksTaken[8];

var int TotalTimeSpentInDamageArea[8];
var int TotalTimeSpentInSlowArea[8];
var int TotalTowersCaptured[8];


/** Computes meta scores for everything the players have achieved during the match. */
function ComputeScores()
{
	local int i;

	for (i = 0; i < 8; i++)
	{
		if (PlayerNames[i] != "")
		{
			// computation base is clearing an alien camp with ten weak aliens

			// unit scores should be somehow equal to resource scores - weak alien gives 50 shards
			ScoresUnits[i] = TotalAliensKilled[i] * 50;
			ScoresUnits[i] += TotalSquadMembersKilled[i] * 200;

			// acquiring an artifact should be somehow equal to clearing an alien camp
			ScoresResources[i] = TotalShardsFarmed[i];
			ScoresResources[i] += TotalArtifactsAcquired[i] * 500;

			// killing ten aliens requires 10  * 60 = 600 damage to be done
			ScoresCombat[i] = TotalDamageDealt[i] * (500.0f / 600.0f);

			// three grenades should be enough to clear an entire alien camp
			ScoresAbilities[i] = TotalAbilitiesTriggered[i] / 3 * 50;

			// sum scores
			ScoresTotal[i] = ScoresUnits[i] + ScoresResources[i] + ScoresCombat[i] + ScoresAbilities[i];
		}
	}
}

replication
{
	// replicate if server
	if (Role == ROLE_Authority && (bNetInitial || bNetDirty))
		MapName, MapTime, PlayerNames,

		ScoresUnits, ScoresResources, ScoresCombat, ScoresAbilities, ScoresTotal,

		TotalShardsFarmed, TotalArtifactsAcquired, TotalVision, TotalActions,
		TotalAbilitiesTriggered, TotalTacticalAbilitiesTriggered, TotalKnockbacksCaused, TotalKnockbacksTaken,
		TotalAliensKilled, TotalSquadMembersKilled, TotalSquadMembersLost, TotalSquadMembersDismissed, TotalReinforcementsCalled,
		TotalDamageDealt, TotalDamageTaken, TotalDamageHealed,
		TotalTimeSpentInDamageArea, TotalTimeSpentInSlowArea, TotalTowersCaptured;
}

DefaultProperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
}
