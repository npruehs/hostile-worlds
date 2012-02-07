// ============================================================================
// HWArtifactManager
// Controls the intelligent reactivation of artifacts depending on the game situation.
//
// Author:  Marcel Koehler
// Date:    2010/12/05
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWArtifactManager extends Actor
	config(HostileWorlds);

/** The time that has to pass until the next artifact round begins after the last artifact was acquired, in seconds. */
const TIME_UNTIL_NEXT_ARTIFACT_ROUND = 5;

/** A reference to the HWGame in order to notify it if a player scores victory points. */
var HWGame Game;

/** The number of victory points that is divided between all artifacts every round. */
//const VICTORY_POINTS_PER_ROUND = 240; // TODO Enable this again to hardcode the VICTORY_POINTS_PER_ROUND
var config int VictoryPointsPerRound;

/** A list of all existing HWArtifacts */
var array<HWArtifact> Artifacts;

/** Counter of available artifacts */
var int ArtifactsAvailable;

/** Counter of artifact rounds */
var int ArtifactRound;

/** The number of victory points a team gains for collecting an artifact this round. */
var int VictoryPointsPerArtifact;

/** The total number of different rounds in the artifact cycle. */
var int ArtifactCycleRoundsTotal;


simulated event PostBeginPlay()
{
	local HWArtifact Artifact;

	super.PostBeginPlay();

	if (WorldInfo.NetMode < NM_Client)
	{
		// spawn the initial artifacts
		foreach AllActors(class'HWArtifact', Artifact) 
		{
			Artifact.ArtifactManager = self;
			Artifacts.AddItem(Artifact);
		}
	}
}

/** 
 *  To be called by HWArtifacts if they are acquired. 
 *  Decreases the ArtifactsAvailable counter,  
 *  activates a new set of artifacts if the acquired artifact was the last available,
 *  assigns the current VictoryPointsPerArtifact to the player of the given
 *  squad member,
 *  and calls CheckScore() on the game.
 *  
 *  @param Artifact
 *      the acquired artifact
 *  
 *  @param SquadMember
 *      the squad member that succeeded in acquiring an artifact
 */
function ArtifactAcquiredBy(HWArtifact Artifact, HWSquadMember SquadMember)
{
	local STextUpEffect TextUpEffect;

	ArtifactsAvailable--;

	if(ArtifactsAvailable == 0)
	{
		SetTimer(TIME_UNTIL_NEXT_ARTIFACT_ROUND, false, 'NextArtifactRound');
	}

	// award points
	SquadMember.OwningPlayerRI.Team.Score += VictoryPointsPerArtifact;
	`Log(class$".ArtifactAcquiredBy() Team "$SquadMember.OwningPlayerRI.Team$" scored "$VictoryPointsPerArtifact$" points!");

	// remember acquired artifact for score screen
	SquadMember.OwningPlayer.TotalArtifactsAcquired++;

	// notify the game
	Game.CheckScore(SquadMember.OwningPlayerRI);

	// Show awarded VictoryPoints as TextUpEffect
	TextUpEffect.Location = Artifact.Location;
	TextUpEffect.Text = string(VictoryPointsPerArtifact);
	TextUpEffect.Color = SquadMember.OwningPlayerRI.Team.TeamColor;
	TextUpEffect.Scale.X = 2;
	TextUpEffect.Scale.Y = 2;
	SquadMember.OwningPlayer.ClientShowTextUpEffect(TextUpEffect);
}

/** 
 *  Activates a new set of artifacts (currently all existing artifacts are activated),
 *  calculates the VictoryPointsPerArtifact
 *  and increases the ArtifactRound counter 
 */
function NextArtifactRound()
{
	local HWArtifact Artifact;
	local int CurrentCycleRound;

	ArtifactRound++;
	CurrentCycleRound = ArtifactRound % ArtifactCycleRoundsTotal;
	// Since Cycle Steps are not 0 based indexed, use ArtifactCycleRoundsTotal if modulo gives 0
	if(CurrentCycleRound == 0)
	{
		CurrentCycleRound = ArtifactCycleRoundsTotal;
	}

	// Activate all artifacts for the current cycle step
	foreach Artifacts(Artifact) 
	{
		if(Artifact.CanBeActivated(CurrentCycleRound))
		{
			Artifact.Activate();

			ArtifactsAvailable++;
		}
	}

	if(ArtifactsAvailable == 0)
	{
		`Log("ERROR"@class$".NextArtifactRound() No artifacts could be activated for round:"@ArtifactRound@"! None of the HWArtifactLocations on this map has a value for this round in its CycleRoundsActive array!");

		return;
	}

	// remember the number of victory points to award for each artifact of this round
	VictoryPointsPerArtifact = VictoryPointsPerRound / ArtifactsAvailable;

	// replicate to clients
	foreach Artifacts(Artifact) 
	{
		if (Artifact.bAvailable)
		{
			Artifact.VictoryPoints = VictoryPointsPerArtifact;
		}
	}

	`Log(class$".NextArtifactRound() ArtifactRound:"@ArtifactRound@"CycleRound:"@CurrentCycleRound@"ArtifactsAvailable:"@ArtifactsAvailable@"VictoryPointsPerArtifact:"@VictoryPointsPerArtifact);
}

function Reset()
{
	local HWArtifact Artifact;

	super.Reset();

	ArtifactsAvailable = 0;
	ArtifactRound = 0;
	VictoryPointsPerArtifact = 0;

	foreach Artifacts(Artifact)
	{
		Artifact.Deactivate();
	}

	// Return to the class state in order to process NextArtifactRound() and ArtifactAcquiredBy() calls again
	GoToState('');
}

state RoundEnded
{
	ignores NextArtifactRound, ArtifactAcquiredBy;
}

DefaultProperties
{
}
