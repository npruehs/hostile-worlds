// ============================================================================
// HWVisibilityMask
// Manages player visibility across the playable map area, rasterized into
// tiles.
//
// Author:  Nick Pruehs
// Date:    2011/01/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWVisibilityMask extends Object;

/** The tiles the map consists of. A value greater than zero indicates that a tile is visible to the player. */
var array<byte> MapTiles;

/** The map this visibility mask is imposed on. */
var HWMapInfoActor Map;

/** The team this visibility mask manages the vision of. */
var int Team;

/** The map tiles to hide in the next update. */
var array<IntPoint> TilesToHide;


/**
 * Initializes this visibility mask, resetting all tiles to hidden.
 * 
 * @param TheMap
 *      the map this visibility mask is imposed on
 * @param TeamIndex
 *      the team this visibility mask manages the vision of
 */
simulated function Initialize(HWMapInfoActor TheMap, int TeamIndex)
{
	Map = TheMap;
	MapTiles.Length = Map.NumberOfTilesXY * Map.NumberOfTilesXY;
	Team = TeamIndex;
}

/**
 * Hides all map tiles that are currently visible to the specified unit,
 * resetting its vision.
 * 
 * @param Spotter
 *      the unit the vision is reset of
 */
simulated function HideMapTilesFor(HWSelectable Spotter)
{
	local IntPoint Tile;

	foreach Spotter.VisibleTiles(Tile)
	{
		TilesToHide.AddItem(Tile);
	}
	
	Spotter.VisibleTiles.Length = 0;
}

/** Clears this visibility mask. */
simulated function HideMapTiles()
{
	local IntPoint Tile;

	foreach TilesToHide(Tile)
	{
		MapTiles[Tile.Y * Map.NumberOfTilesXY + Tile.X] = 0;
	}
	
	TilesToHide.Length = 0;
}

/**
 * Reveals the passed map tiles spotted by the specified unit.
 * 
 * @param Tiles
 *      the tiles to reveal on this visibility mask
 * @param Spotter
 *      the unit that has vision on these tiles
 */
simulated function RevealMapTiles(array<IntPoint> Tiles, HWSelectable Spotter)
{
	local IntPoint Tile;
	local int TileIndex;
	local HWPawn Unit;
	local HWPlayerController PC;

	if (Spotter.Health > 0)
	{
		foreach Tiles(Tile)
		{
			TileIndex = Tile.Y * Map.NumberOfTilesXY + Tile.X;

			if (MapTiles[TileIndex] == 0)
			{
				MapTiles[TileIndex] = 1;
				Spotter.RememberVisibleTile(Tile.X, Tile.Y);

				// remember vision for score screen
				Unit = HWPawn(Spotter);

				if (Unit != none)
				{
					PC = Unit.OwningPlayer;

					if (PC != none)
					{
						PC.TotalVision++;
					}
				}
				else
				{
					// spotter emits vision for whole team
					foreach Spotter.WorldInfo.AllControllers(class'HWPlayerController', PC)
					{
						if (PC.PlayerReplicationInfo.Team.TeamIndex == Spotter.TeamIndex)
						{
							PC.TotalVision++;
						}
					}
				}
			}
		}
	}
}

/**
 * Returns true if the specified tile is hidden on this visibility mask, and
 * false otherwise.
 * 
 * @param Tile
 *      the tile to check
 * @return
 *      whether the specified tile is hidden on this visibility mask
 */
simulated function bool IsMapTileHidden(IntPoint Tile)
{
	if (Tile.X < 0 || Tile.Y < 0 || Tile.X >= Map.NumberOfTilesXY || Tile.Y >= Map.NumberOfTilesXY)
	{
		// map tile out of bounds
		return false;
	}

	return (MapTiles[Tile.Y * Map.NumberOfTilesXY + Tile.X] == 0);
}

/**
 * Updates this visibility mask, re-computing the vision for the team this mask
 * belongs to.
 */
simulated function Update()
{
	local HWSelectable s;
	local IntPoint Tile;
	local array<IntPoint> Tiles;

	// reset visibility
	foreach Map.DynamicActors(class'HWSelectable', s)
	{
		if (s.TeamIndex == Team)
		{
			HideMapTilesFor(s);
		}
	}

	HideMapTiles();

	// compute new visibility
	foreach Map.DynamicActors(class'HWSelectable', s)
	{
		if (s.TeamIndex == Team)
		{
			Tile = Map.GetMapTileFromLocation(s.Location);
			Tiles = Map.GetVisibleTilesAround(Tile, s.SightRadiusTiles);
			RevealMapTiles(Tiles, s);
		}
	}
}

DefaultProperties
{
}
