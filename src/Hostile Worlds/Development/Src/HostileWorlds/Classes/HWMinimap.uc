// ============================================================================
// HWMinimap
// Provides functionality to draw a minimap, including the map's texture, fog
// of war and all visible units.
//
// Author:  Nick Pruehs
// Date:    2011/01/09
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWMinimap extends Object;

/** The texture showing the terrain of the map, the fog-of-war, the unit positions and the view frustrum. */
var ScriptedTexture MinimapTexture;

/** The texture that contains visibility information for the local player. */
var ScriptedTexture FogOfWarTexture;

/** The color fog of war is drawn with on the minimap. */
var LinearColor FogOfWarColor;

/** The color visible areas are drawn with on the minimap. */
var LinearColor VisibleColor;

/** The texture that is drawn at the position of every own unit on the minimap to indicate its sight radius. */
var Texture2D TextureSightRadius;

/** A type-casted reference to the local player. */
var HWPlayerController LocalPlayer;

/** The height and width of a box indication the position of an unit on the minimap, in pixels. */
var int MinimapUnitSize;

/** The color of own units on the minimap. */
var Color MinimapColorOwnUnits;

/** The color of neutral units on the minimap. */
var Color MinimapColorNeutralUnits;

/** The color of allied units on the minimap. */
var Color MinimapColorAlliedUnits;

/** The color of enemy units on the minimap. */
var Color MinimapColorEnemyUnits;

/** The color of artifacts on the minimap. */
var Color MinimapColorArtifact;

/** The color of spawn points on the minimap. */
var Color MinimapColorSpawnPoint;

/** The map shown by this minimap. */
var HWMapInfoActor Map;

/** Whether the terrain is shown on the minimap, or not. */
var bool bShowTerrain;

/** Whether the fog of war is shown on the minimap, or not. */
var bool bShowFogOfWar;

/** Whether units and game objects are shown on the minimap, or not. */
var bool bShowUnits;

/** Whether unit positions are drawn with player colors, or own units in green and enemy ones in red instead. */
var bool bUseTeamColors;

/** The height and width of the minimap on the screen, in pixels. */
var int MinimapSize;

/** The quotient of the minimap and the map tile resolution. */
var float ZoomFactor;

/** A heuristic approximation of the screen-to-tile space ratio. */
var float ViewFrustrumScale;


/**
 * Initializes this minimap, remembering the local player for drawing all units
 * using the correct color, and preparing a texture for rendering the fog of
 * war.
 * 
 * @param TheMap
 *      the map to be shown by this minimap
 * @param TheLocalPlayer
 *      the player this minimap is shown
 */
simulated function Initialize(HWMapInfoActor TheMap, HWPlayerController TheLocalPlayer)
{
	Map = TheMap;
	LocalPlayer = TheLocalPlayer;

	SetMinimapSize(MinimapSize);
}

simulated function RenderMinimapTexture(Canvas Canvas)
{
	// draw terrain
	if (bShowTerrain)
	{
		Canvas.SetPos(0, 0);
		Canvas.SetDrawColor(255, 255, 255, 255);
		Canvas.DrawTile(Map.MinimapTexture, MinimapSize, MinimapSize, 0, 0, Map.MinimapTexture.SizeX, Map.MinimapTexture.SizeY);
	}

	// draw fog of war
	if (bShowFogOfWar)
	{
		FogOfWarTexture.bNeedsUpdate = true;

		Canvas.SetPos(0, 0);
		Canvas.SetDrawColor(255, 255, 255, 100);
		Canvas.DrawTexture(FogOfWarTexture, 1.0f);
	}

	// draw unit positions
	if (bShowUnits)
	{
		DrawUnits(Canvas);
	}

	// draw spawn points
	if (LocalPlayer != none && LocalPlayer.Commander == none)
	{
		DrawSpawnPoints(Canvas);
	}
	
	// draw view frustrum
	DrawViewFrustrum(Canvas);
}

simulated function RenderFogOfWarTexture(Canvas Canvas)
{
	local HWSelectable s;
	local IntPoint Tile;
	local float SightRadiusScale;

	// avoid "Accessed None" errors in map initialization
	if (LocalPlayer != none && LocalPlayer.PlayerReplicationInfo != none && LocalPlayer.PlayerReplicationInfo.Team != none)
	{
		Canvas.SetDrawColor(VisibleColor.R, VisibleColor.G, VisibleColor.B, VisibleColor.A);

		foreach Map.DynamicActors(class'HWSelectable', s)
		{
			// iterate all units owned by the local player
			if (s.TeamIndex == LocalPlayer.PlayerReplicationInfo.Team.TeamIndex)
			{
				// get unit location on minimap
				Tile = Map.GetMapTileFromLocation(s.Location);

				// draw sight radius circle texture
				SightRadiusScale = float(s.SightRadiusTiles) / (float(TextureSightRadius.SizeX) / 2);

				Canvas.SetPos((Tile.X - s.SightRadiusTiles) * ZoomFactor, (Tile.Y - s.SightRadiusTiles) * ZoomFactor);
				Canvas.DrawTextureBlended(TextureSightRadius, SightRadiusScale * ZoomFactor, BLEND_Additive);
			}
		}
	}
}

/**
 * Draws the positions of all visible units to the passed canvas.
 * 
 * @param Canvas
 *      the canvas to draw to
 */
simulated function DrawUnits(Canvas Canvas)
{
	local HWSelectable s;
	local HWPawn Unit;
	local IntPoint UnitPos;
	local bool bDrawUnit;
	local LinearColor PlayerColor;

	// draw the positons of all units
	foreach Map.DynamicActors(class'HWSelectable', s)
	{
		bDrawUnit = false;

		if (s.ShowOnMiniMap())
		{
			// translates the unit's position to tile coordinates
			UnitPos = Map.GetMapTileFromLocation(s.Location);

			// show artifacts regardless of fog of war
			if(HWArtifact(s) != none)
			{
				bDrawUnit = true;

				Canvas.SetDrawColor
						(MinimapColorArtifact.R,
						MinimapColorArtifact.G,
						MinimapColorArtifact.B,
						MinimapColorArtifact.A);
			}
			// show all other units only if visible
			else if (!(LocalPlayer.FogOfWarManager.VisibilityMask.IsMapTileHidden(UnitPos)))
			{
				bDrawUnit = true;

				// set the draw color according to the unit's owner
				Unit = HWPawn(s);

				// neutral units
				if (Unit == none || Unit.OwningPlayerRI == none)
				{
					Canvas.SetDrawColor
						(MinimapColorNeutralUnits.R,
						MinimapColorNeutralUnits.G,
						MinimapColorNeutralUnits.B,
						MinimapColorNeutralUnits.A);
				}
				else
				{
					 if (bUseTeamColors)
					 {
						// own units
						if (Unit.OwningPlayerRI == LocalPlayer.PlayerReplicationInfo)
						{
							Canvas.SetDrawColor
								(MinimapColorOwnUnits.R,
								MinimapColorOwnUnits.G,
								MinimapColorOwnUnits.B,
								MinimapColorOwnUnits.A);
						}
						// allied units
						else if (Unit.TeamIndex == LocalPlayer.PlayerReplicationInfo.Team.TeamIndex)
						{
							Canvas.SetDrawColor
								(MinimapColorAlliedUnits.R,
								MinimapColorAlliedUnits.G,
								MinimapColorAlliedUnits.B,
								MinimapColorAlliedUnits.A);
						}
						// enemy units
						else
						{
							Canvas.SetDrawColor
								(MinimapColorEnemyUnits.R,
								MinimapColorEnemyUnits.G,
								MinimapColorEnemyUnits.B,
								MinimapColorEnemyUnits.A);
						}
					 }
					 else
					 {
						PlayerColor = Unit.TeamColors[Unit.TeamIndex];

						Canvas.SetDrawColor
							(PlayerColor.R * 255,
							 PlayerColor.G * 255,
							 PlayerColor.B * 255,
							 PlayerColor.A * 255);
					 }
				}	
			}

			if (bDrawUnit)
			{
				// set the canvas position to the upper left corner of the box indiciating the unit position
				Canvas.SetPos
					((UnitPos.X - MinimapUnitSize / 2) * ZoomFactor,
					 (UnitPos.Y - MinimapUnitSize / 2) * ZoomFactor);

				// draw the unit to the units texture
				Canvas.DrawRect(MinimapUnitSize * ZoomFactor, MinimapUnitSize * ZoomFactor);
			}
		}
	}
}

/**
 * Draws all spawn points to the passed canvas.
 * 
 * @param Canvas
 *      the canvas to draw to
 */
simulated function DrawSpawnPoints(Canvas Canvas)
{
	local HWSpawnPoint SpawnPoint;
	local IntPoint Tile;
	local int SpawnRadius;
	local float SpawnRadiusTextureScale;

	Canvas.SetDrawColor(MinimapColorSpawnPoint.R, MinimapColorSpawnPoint.G, MinimapColorSpawnPoint.B, MinimapColorSpawnPoint.A);

	foreach Map.AllActors(class'HWSpawnPoint', SpawnPoint)
	{
		// get spawn point location on minimap
		Tile = Map.GetMapTileFromLocation(SpawnPoint.Location);

		// draw spawn point circle texture
		SpawnRadius = Round(class'HWDe_SpawnArea'.default.InitialRadius / Map.TileSizeUU);
		SpawnRadiusTextureScale = float(SpawnRadius) / (float(TextureSightRadius.SizeX) / 2);

		Canvas.SetPos((Tile.X - SpawnRadius) * ZoomFactor, (Tile.Y - SpawnRadius) * ZoomFactor);
		Canvas.DrawTexture(TextureSightRadius, SpawnRadiusTextureScale * ZoomFactor);
	}
}

/**
 * Draws an heuristic approximation of the view frustrum on the passed canvas.
 * 
 * @param Canvas
 *      the canvas to draw the minimap on
 */
simulated function DrawViewFrustrum(Canvas Canvas)
{
	local IntPoint CameraLocation;
	local IntPoint ViewFrustrumSize;

	// get the camera location on the minimap
	CameraLocation = Map.GetMapTileFromLocation(LocalPlayer.PlayerCamera.Location);

	// approximate the view frustrum bounds
	ViewFrustrumSize.X = LocalPlayer.ViewportSize.X / ViewFrustrumScale;
	ViewFrustrumSize.Y = LocalPlayer.ViewportSize.Y / ViewFrustrumScale;

	// draw the view frustrum
	Canvas.SetPos
		((CameraLocation.X - ViewFrustrumSize.X / 2) * ZoomFactor,
		 (CameraLocation.Y - ViewFrustrumSize.Y / 2) * ZoomFactor);
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.DrawBox(ViewFrustrumSize.X * ZoomFactor, ViewFrustrumSize.Y * ZoomFactor);
}

/**
 * Set the width and height of this minimap to the specified number of pixels.
 * 
 * @param NewMinimapSize
 *      the new width and height of this minimap
 */
function SetMinimapSize(int NewMinimapSize)
{
	MinimapSize = NewMinimapSize;

	FogOfWarTexture = ScriptedTexture(class'ScriptedTexture'.static.Create(MinimapSize, MinimapSize,, FogOfWarColor));
	FogOfWarTexture.Render = RenderFogOfWarTexture;

	MinimapTexture = ScriptedTexture(class'ScriptedTexture'.static.Create(MinimapSize, MinimapSize,, FogOfWarColor));
	MinimapTexture.Render = RenderMinimapTexture;

	ZoomFactor = MinimapSize / Map.NumberOfTilesXY;
}


DefaultProperties
{
	MinimapUnitSize=3

	MinimapColorOwnUnits=(R=0,G=255,B=0,A=255)
	MinimapColorNeutralUnits=(R=255,G=255,B=0,A=255)
	MinimapColorAlliedUnits=(R=0,G=255,B=255,A=255)
	MinimapColorEnemyUnits=(R=255,G=0,B=0,A=255)
	MinimapColorArtifact=(R=0,G=0,B=255,A=255)
	MinimapColorSpawnPoint=(R=0,G=255,B=0,A=255)

	FogOfWarColor=(R=0,G=0,B=0,A=255)
	VisibleColor=(R=255,G=255,B=255,A=255)

	TextureSightRadius=Texture2D'FX_FogOfWar.T_FX_SightRadius'

	bShowTerrain=true
	bShowFogOfWar=true
	bShowUnits=true
	bUseTeamColors=true

	MinimapSize=192
	ViewFrustrumScale=20.0f
}