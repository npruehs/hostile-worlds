// ============================================================================
// HWFogOfWarManager
// Manages the correct rendering of all fog of war volumes, and reveals and
// hides all units as appropriate.
//
// Author:  Nick Pruehs
// Date:    2011/02/23
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWFogOfWarManager extends Actor;

/** The number of seconds between two updates of the visibility mask of a player. */
const VISIBILITY_UPDATE_INTERVAL = 0.5f;


/** The map this manager renders the fog of war on. */
var HWMapInfoActor Map;

/** The mask that tells where this player has vision. */
var HWVisibilityMask VisibilityMask;

/** The index of the team the player rendering the fog of war belongs to. */
var int TeamIndex;

/** The textures used as opacity parameters for the fog volumes. */
var array<ScriptedTexture> FogOfWarTextures;

/** The textures that indicate "no vision" for each particular height level. */
var array<ScriptedTexture> FogOfWarBaseTextures;

/** The color that indicates "no vision" on a fog of war texture. */
var LinearColor ClearColor;


/**
 * Initializes this fog of war manager, creating a new visibility mask or using
 * the server ones, if available, and setting up all fog of war volumes.
 * 
 * @param TheMap
 *      the map the manager should render the fog of war on
 * @param Player
 *      the player that should be handicapped by the fog of war managed by this instance
 * @param TheTeamIndex
 *      the index of the team the player rendering the fog of war belongs to,
 *      in case the PRI has not been replicated yet
 */
function Initialize(HWMapInfoActor TheMap, HWPlayerController Player, int TheTeamIndex)
{
	Map = TheMap;
	TeamIndex = TheTeamIndex;

	if (WorldInfo.NetMode == NM_Client)
	{
		VisibilityMask = new class'HWVisibilityMask';
		VisibilityMask.Initialize(Map, TeamIndex);
	}
	else
	{
		// use server visibility mask on Listen servers and stand-alone games
		VisibilityMask = HWTeamInfo(Player.PlayerReplicationInfo.Team).VisibilityMask;
	}

	SetupFogOfWarVolumes();

	// update visibility at a rate less frequent than the frame rate
	SetTimer(VISIBILITY_UPDATE_INTERVAL, true, 'UpdateVisibility');
}

/** Prepares all fog of war volumes for rendering. */
function SetupFogOfWarVolumes()
{
	local array<FogVolumeConstantDensityInfo> FogOfWarVolumes;
	local FogVolumeConstantDensityInfo FogOfWarVolume;
	local int VolumeCount;
	local int i;

	// prepare the opacity textures for the fog volumes
	FogOfWarTextures[0] = ScriptedTexture(class'ScriptedTexture'.static.Create(Map.NumberOfTilesXY, Map.NumberOfTilesXY,, ClearColor));
	FogOfWarTextures[0].Render = RenderFogOfWarTexture0;

	FogOfWarBaseTextures[0] = ScriptedTexture(class'ScriptedTexture'.static.Create(Map.NumberOfTilesXY, Map.NumberOfTilesXY,, ClearColor));
	FogOfWarBaseTextures[0].Render = RenderFogOfWarBaseTexture0;
	FogOfWarBaseTextures[0].bNeedsUpdate = true;

	// more height levels?
	if (Map.TileHeights.Length > 0)
	{
		FogOfWarTextures[1] = ScriptedTexture(class'ScriptedTexture'.static.Create(Map.NumberOfTilesXY, Map.NumberOfTilesXY,, ClearColor));
		FogOfWarTextures[1].Render = RenderFogOfWarTexture1;

		FogOfWarBaseTextures[1] = ScriptedTexture(class'ScriptedTexture'.static.Create(Map.NumberOfTilesXY, Map.NumberOfTilesXY,, ClearColor));
		FogOfWarBaseTextures[1].Render = RenderFogOfWarBaseTexture1;
		FogOfWarBaseTextures[1].bNeedsUpdate = true;

		// even more height levels?
		if (Map.TileHeights.Length > 1)
		{
			FogOfWarTextures[2] = ScriptedTexture(class'ScriptedTexture'.static.Create(Map.NumberOfTilesXY, Map.NumberOfTilesXY,, ClearColor));
			FogOfWarTextures[2].Render = RenderFogOfWarTexture2;

			FogOfWarBaseTextures[2] = ScriptedTexture(class'ScriptedTexture'.static.Create(Map.NumberOfTilesXY, Map.NumberOfTilesXY,, ClearColor));
			FogOfWarBaseTextures[2].Render = RenderFogOfWarBaseTexture2;
			FogOfWarBaseTextures[2].bNeedsUpdate = true;
		}
	}

	// find all fog of war volumes and initialize them
	foreach AllActors(class'FogVolumeConstantDensityInfo', FogOfWarVolume)
	{
		FogOfWarVolumes.AddItem(FogOfWarVolume);
	}

	// sort the volumes by the z-coordinate of their locations
	FogOfWarVolumes.Sort(SortFogOfWarVolumes);

	VolumeCount = Min(FogOfWarVolumes.Length, FogOfWarTextures.Length);

	`log("Found "$FogOfWarVolumes.Length$" fog of war volumes and "$FogOfWarTextures.Length$" height levels.");
	`log("Initializing "$VolumeCount$" fog of war volumes...");

	for (i = 0; i < VolumeCount; i++)
	{
		SetupFogOfWarVolume(FogOfWarVolumes[i], FogOfWarTextures[i]);
	}
}

/** The delegate used for sorting the fog volumes by the z-coordinate of their locations. */
delegate int SortFogOfWarVolumes(FogVolumeConstantDensityInfo A, FogVolumeConstantDensityInfo B)
{
	return int(B.Location.Z - A.Location.Z);
}

/**
 * Sets up the passed fog of war volume by creating a new material instance
 * constant for it which uses the passed texture as opacity input.
 * 
 * @param FogOfWarVolume
 *      the volume to be set up
 * @param FogOfWarTexture
 *      the texture to be used as opacity input for the material
 */
function SetupFogOfWarVolume(FogVolumeConstantDensityInfo FogOfWarVolume, ScriptedTexture FogOfWarTexture)
{
	local MaterialInstanceConstant FogOfWarMatInst;

	FogOfWarMatInst = new(None) Class'MaterialInstanceConstant';
	FogOfWarMatInst.SetParent(FogOfWarVolume.DensityComponent.FogMaterial);
	FogOfWarMatInst.SetTextureParameterValue('FogOfWarTexture', FogOfWarTexture);
	FogOfWarVolume.DensityComponent.FogMaterial = FogOfWarMatInst;
	FogOfWarVolume.DensityComponent.ForceUpdate(false);
}

/** The render delegate used to render the opacity texture of the lowest fog of war volume. */
function RenderFogOfWarTexture0(Canvas Canvas)
{
	RenderFogOfWarTexture(Canvas, 0);
}

/** The render delegate used to render the opacity texture of the mid fog of war volume. */
function RenderFogOfWarTexture1(Canvas Canvas)
{
	RenderFogOfWarTexture(Canvas, 1);
}

/** The render delegate used to render the opacity texture of the highest fog of war volume. */
function RenderFogOfWarTexture2(Canvas Canvas)
{
	RenderFogOfWarTexture(Canvas, 2);
}

/**
 * Renders a fog of war texture to the passed canvas indicating vision
 * on the passed height level.
 * 
 * On a given height level h, tiles belonging to all other height levels
 * are considered "visible" in order to prevent strange artifacts like
 * overlapping additive fog or fog inside of closed static meshes.
 * 
 * @param Canvas
 *      the canvas to render the fog of war texture to
 * @param HeightLevel
 *      the height level to render the fog of war texture of
 */
function RenderFogOfWarTexture(Canvas Canvas, int HeightLevel)
{
	// the fog of war texture is automatically cleared to black ("no vision")

	local HWSelectable s;
	local IntPoint Tile;

	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.DrawTexture(FogOfWarBaseTextures[HeightLevel], 1.0f);

	foreach DynamicActors(class'HWSelectable', s)
	{
		// iterate all units owned by the local player
		if (s.TeamIndex == TeamIndex)
		{
			// draw a visible tile to the fog of war texture
			foreach s.VisibleTiles(Tile)
			{
				Canvas.SetPos(Map.NumberOfTilesXY - Tile.X, Tile.Y);
				Canvas.DrawRect(1, 1);
			}
		}
	}

}

/** 
 * The render delegate used to render the base of the opacity texture of the lowest fog of war volume.
 * See RenderFogOfWarTexture(Canvas, int) for further information.
 */
function RenderFogOfWarBaseTexture0(Canvas Canvas)
{
	RenderFogOfWarBaseTexture(Canvas, 0);
}

/** 
 * The render delegate used to render the base of the opacity texture of the mid fog of war volume.
 * See RenderFogOfWarTexture(Canvas, int) for further information.
 */
function RenderFogOfWarBaseTexture1(Canvas Canvas)
{
	RenderFogOfWarBaseTexture(Canvas, 1);
}

/** 
 * The render delegate used to render the base of the opacity texture of the highest fog of war volume.
 * See RenderFogOfWarTexture(Canvas, int) for further information.
 */
function RenderFogOfWarBaseTexture2(Canvas Canvas)
{
	RenderFogOfWarBaseTexture(Canvas, 2);
}

/** 
 * Renders the base of the opacity texture of the a fog of war volume.
 * See RenderFogOfWarTexture(Canvas, int) for further information.
 */
function RenderFogOfWarBaseTexture(Canvas Canvas, int HeightLevel)
{
	// the fog of war texture is automatically cleared to black

	local int x;
	local int y;

	Canvas.SetDrawColor(255, 255, 255, 255);

	for (y = 0; y < Map.NumberOfTilesXY; y++)
	{
		for (x = 0; x < Map.NumberOfTilesXY; x++)
		{
			// mark all tiles on other height levels as visible
			if (Map.GetTileHeightAt(x, y) != HeightLevel)
			{
				Canvas.SetPos(Map.NumberOfTilesXY - x, y);
				Canvas.DrawRect(1, 1);
			}
		}
	}
}

/** Tells the visibility of this player it needs to re-compute the vision. */
function UpdateVisibility()
{
	local ScriptedTexture FogOfWarTexture;

	// update visibility mask, if not already done by the server
	if (WorldInfo.NetMode == NM_Client)
	{
		VisibilityMask.Update();
	}

	// update all fog of war volumes
	foreach FogOfWarTextures(FogOfWarTexture)
	{
		FogOfWarTexture.bNeedsUpdate = true;
	}

	// reveal and hide units as appropriate
	ApplyFogOfWar();
}

/** Applies the visibility mask of this player, hiding and revealing enemy units. */
function ApplyFogOfWar()
{
	local IntPoint Tile;
	local HWSelectable s;

	foreach DynamicActors(class'HWSelectable', s)
	{
		// iterate all units belonging to the own team
		if (s.TeamIndex == TeamIndex)
		{
			// own units are never hidden
			s.Show();
		}
		else
		{
			// check whether the unit is visible or not
			Tile = Map.GetMapTileFromLocation(s.Location);

			if (VisibilityMask.IsMapTileHidden(Tile))
			{
				// if it just turned invisible, deselect and hide it
				s.Hide();

			}
			else
			{
				s.Show();
			}
		}
	}
}

DefaultProperties
{
	ClearColor=(R=0,G=0,B=0,A=255)
}
