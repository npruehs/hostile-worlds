// ============================================================================
// HWMapInfoActor
// Placed by level designers in order to indicate the center of the map and its
// extents. Provides a texture to be used as minimap.
//
// Author:  Nick Pruehs
// Date:    2011/01/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWMapInfoActor extends Actor
	placeable;

/** The texture to be used as minimap. */
var() Texture2D MinimapTexture;

/** The box describing the map extents. */
var() const editconst DrawBoxComponent MapExtentsComponent;

/** The box describing the camera bounds. */
var() const editconst DrawBoxComponent CameraBounds;

/** The total number of different rounds in the artifact cycle. */
var() const int ArtifactCycleRoundsTotal;

/** The number of tiles of the map in x- and y-direction. */
var int NumberOfTilesXY;

/** The width or height of this map, whichever is higher, in UU. */
var float MapDimUU;

/** The tile size in uu. */
var float TileSizeUU;

/** The height levels of the map tiles. */
var array<byte> TileHeights;

/** The center locations of all map tiles in world space. */
var array<Vector> TileCenterLocations;

/** The suggested number of players per team. */
var int SuggestedPlayersPerTeam[2];

/** The human-readable size of this map. */
var enum EMapSize
{
	SIZE_Small,
	SIZE_Medium,
	SIZE_Large,
	SIZE_Unknown
} MapSize;

/** Human-readable description of a small map size. */
var localized string MapSizeSmall;

/** Human-readable description of a medium map size. */
var localized string MapSizeMedium;

/** Human-readable description of a large map size. */
var localized string MapSizeLarge;

/** Human-readable description of an unknown map size. */
var localized string MapSizeUnknown;


/** Initializes this map info actor, computing the size and height of all tiles. */
simulated function Initialize()
{
	local int i;
	local int x;
	local int y;
	local int h;

	local array<float> HeightLevels;
	local HWHeightLevelActor HeightLevelActor;

	local Vector TileLocation;

	local Vector TraceStart;
	local Vector TraceEnd;

	local Vector TraceHitNormal;


	// compute the size of all tiles
	MapDimUU = FMax(MapExtentsComponent.BoxExtent.X, MapExtentsComponent.BoxExtent.Y) * 2;
	TileSizeUU = MapDimUU / NumberOfTilesXY;

	// get all height levels
	`log("Collecting height levels...");

	foreach AllActors(class'HWHeightLevelActor', HeightLevelActor)
	{
		HeightLevels.AddItem(HeightLevelActor.Location.Z);
	}

	HeightLevels.Sort(SortHeightLevels);

	for (i = 0; i < HeightLevels.Length; i++)
	{
		`log("Height level "$(i + 1)$" starts at z = "$HeightLevels[i]);
	}

	// trace the height level for each map tile
	TileHeights.Length = NumberOfTilesXY * NumberOfTilesXY;
	TileCenterLocations.Length = NumberOfTilesXY * NumberOfTilesXY;

	for (y = 0; y < NumberOfTilesXY; y++)
	{
		for (x = 0; x < NumberOfTilesXY; x++)
		{
			// translate the tile coordinate into world space
			TileLocation.X = (float(x) / float(NumberOfTilesXY) - 0.5f) * MapDimUU + Location.X;
			TileLocation.Y = (float(y) / float(NumberOfTilesXY) - 0.5f) * MapDimUU + Location.Y;

			// trace the height of the map tile in world space
			TraceStart = TileLocation;
			TraceStart.Z = 1000;

			TraceEnd = TileLocation;
			TraceEnd.Z = -1000;

			Trace(TileLocation, TraceHitNormal, TraceEnd, TraceStart, false);

			// remember tile center location
			TileCenterLocations[y * NumberOfTilesXY + x] = TileLocation;

			// translate the tile's height from world space into a height level
			for (h = 0; h < HeightLevels.Length; h++)
			{
				if (TileLocation.Z >= HeightLevels[h])
				{
					TileHeights[y * NumberOfTilesXY + x] = h + 1;
				}
			}
		}
	}

	// prepare human-readable suggested players and size of this map
	FindSuggestedPlayers();
	FindMapSize();
}

/** The delegate used for sorting the height level array. */
delegate int SortHeightLevels(float A, float B)
{
	return int(B - A);
}

/** 
 *  Translates a given location in world coordinates to tile coordinates.
 *  
 *  @param LocationToTranslate
 *      the location to translate
 */
simulated function IntPoint GetMapTileFromLocation(Vector LocationToTranslate)
{
	local IntPoint Tile;
	local Vector NormalizedOffsetFromCenter;

	// compute the offset of the passed location from the map center and normalize to [-0.5 .. +0.5]
	NormalizedOffsetFromCenter.X = (LocationToTranslate.X - Location.X) / MapDimUU;
	NormalizedOffsetFromCenter.Y = (LocationToTranslate.Y - Location.Y) / MapDimUU;

	// transform the normalized coordinates to [0..1] and compute the tile coordinates
	Tile.X = int((NormalizedOffsetFromCenter.X + 0.5) * NumberOfTilesXY);
	Tile.Y = int((NormalizedOffsetFromCenter.Y + 0.5) * NumberOfTilesXY);

	return Tile;
}

/** 
 *  Returns the center of a given map tile in world space.
 *  
 *  @param x
 *      the x-coordinate of the tile to get the center location of
 *  @param y
 *      the y-coordinate of the tile to get the center location of
 */
simulated function Vector GetCenterOfMapTile(int x, int y)
{
	return TileCenterLocations[y * NumberOfTilesXY + x];
}

/**
 * Computes a list of tiles that represent a circle with the specified radius
 * around the given center tile. All returned tiles are on the same height
 * level as the specified center tile, or below.
 * 
 * @param Center
 *      the tile that is the center of the computed circle
 * @param Radius
 *      the radius of the circle
 * @return
 *      a circle of tiles around the given center
 */
simulated function array<IntPoint> GetVisibleTilesAround(IntPoint Center, int Radius)
{
	local array<IntPoint> Tiles;
	local IntPoint Tile;
	local int i;
	local int j;
	local int x;
	local int y;

	local byte CenterHeight;

	// get the height level of the circle's center tile
	CenterHeight = GetTileHeight(Center);

	// XXX VERY simple circle algorithm
	for (j = - Radius; j < Radius; j++)
	{
		for (i = - Radius; i < Radius; i++)
		{
			x = Center.X + i;
			y = Center.Y + j;

			// check if within circle
			if (x >= 0 && y >= 0 && x < NumberOfTilesXY && y < NumberOfTilesXY && (i * i + j * j < Radius * Radius))
			{
				// check tile height
				if (GetTileHeightAt(x, y) <= CenterHeight)
				{
					Tile.X = x;
					Tile.Y = y;

					Tiles.AddItem(Tile);
				}
			}
		}
	}

	return Tiles;
}

/**
 * Returns the height level of the tile at the specified location in tile-space.
 * 
 * @param X
 *      the x-coordinate of the tile to get the height level of
 * @param Y
 *      the y-coordinate of the tile to get the height level of
 */
simulated function byte GetTileHeightAt(int X, int Y)
{
	return TileHeights[Y * NumberOfTilesXY + X];
}

/**
 * Returns the height level of the specified tile.
 * 
 * @param Tile
 *      the tile to get the height level of
 */
simulated function byte GetTileHeight(IntPoint Tile)
{
	return TileHeights[Tile.Y * NumberOfTilesXY + Tile.X];
}

/**
 * Returns the height level of the tile at the specified location in world-space.
 * 
 * @param LocationToTranslate
 *      the location of the tile to get the height level of
 */
simulated function byte GetTileHeightFromLocation(Vector LocationToTranslate)
{
	return GetTileHeight(GetMapTileFromLocation(LocationToTranslate));
}

/**
 * Returns the extents of map.
 * 
 * Why simulated? Why, why, why, just why? ^^
 */
simulated function Vector GetMapSize()
{
	return MapExtentsComponent.BoxExtent;
}

/** Counts the player starts of each team on this map. */
simulated function FindSuggestedPlayers()
{
	local PlayerStart StartPosition;

	SuggestedPlayersPerTeam[0] = 0;
	SuggestedPlayersPerTeam[1] = 0;

	// iterate all start positions
	foreach AllActors(class'PlayerStart', StartPosition)
	{
		if (StartPosition.bEnabled)
		{
			// remember start position for team
			if (StartPosition.TeamIndex == 0 || StartPosition.TeamIndex == 1)
			{
				SuggestedPlayersPerTeam[StartPosition.TeamIndex]++;
			}

			// start position suitable for every team
			if (StartPosition.TeamIndex == 255)
			{
				SuggestedPlayersPerTeam[0]++;
				SuggestedPlayersPerTeam[1]++;
			}
		}
	}
}

/** Finds a human-readable description of the size of this map. */
simulated function FindMapSize()
{
	if (MapDimUU < 10000.0f)
	{
		MapSize = SIZE_Small;
	}
	else if (MapDimUU < 20000.0f)
	{
		MapSize = SIZE_Medium;
	}
	else
	{
		MapSize = SIZE_Large;
	}
}

/** Returns the human-readable description of the size of this map. */
simulated function string GetHumanReadableMapSize()
{
	switch (MapSize)
	{
		case SIZE_Small:
			return MapSizeSmall;
		case SIZE_Medium:
			return MapSizeMedium;
		case SIZE_Large:
			return MapSizeLarge;
		case SIZE_Unknown:
			return MapSizeUnknown;
	}
}


DefaultProperties
{
	Begin Object Class=DrawBoxComponent Name=DrawBox0
		BoxColor=(R=0,G=255,B=0,A=255)
		BoxExtent=(X=1024, Y=1024, Z=0)
	End Object
	MapExtentsComponent=DrawBox0
	Components.Add(DrawBox0)

	Begin Object Class=DrawBoxComponent Name=DrawBox1
		BoxColor=(R=0,G=0,B=255,A=255)
		BoxExtent=(X=1024, Y=1024, Z=0)
	End Object
	CameraBounds=DrawBox1
	Components.Add(DrawBox1)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.Flag1'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	bNoDelete=true
	bStatic=true

	NumberOfTilesXY=192

	MapSize=SIZE_Unknown
}
