//=============================================================================
// Canvas: A drawing canvas.
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class Canvas extends Object
	native
	transient;

/**
 * Holds texture information with UV coordinates as well.
 */
struct native CanvasIcon
{
	/** Source texture */
	var Texture Texture;
	/** UV coords */
	var float U, V, UL, VL;
};

/** info for glow when using depth field rendering */
struct native DepthFieldGlowInfo
{
	/** whether to turn on the outline glow (depth field fonts only) */
	var bool bEnableGlow;
	/** base color to use for the glow */
	var LinearColor GlowColor;
	/** if bEnableGlow, outline glow outer radius (0 to 1, 0.5 is edge of character silhouette)
	 * glow influence will be 0 at GlowOuterRadius.X and 1 at GlowOuterRadius.Y
	*/
	var vector2d GlowOuterRadius;
	/** if bEnableGlow, outline glow inner radius (0 to 1, 0.5 is edge of character silhouette)
	 * glow influence will be 1 at GlowInnerRadius.X and 0 at GlowInnerRadius.Y
	 */
	var vector2d GlowInnerRadius;

	structcpptext
	{
		FDepthFieldGlowInfo()
		{}
		FDepthFieldGlowInfo(EEventParm)
		{
			appMemzero(this, sizeof(FDepthFieldGlowInfo));
		}
		UBOOL operator==(const FDepthFieldGlowInfo& Other) const
		{
			if (Other.bEnableGlow != bEnableGlow)
			{
				return false;
			}
			else if (!bEnableGlow)
			{
				// if the glow is disabled on both, the other values don't matter
				return true;
			}
			else
			{
				return (Other.GlowColor == GlowColor && Other.GlowOuterRadius == GlowOuterRadius && Other.GlowInnerRadius == GlowInnerRadius);
			}
		}
		UBOOL operator!=(const FDepthFieldGlowInfo& Other) const
		{
			return !(*this == Other);
		}
	}
};

/** information used in font rendering */
struct native FontRenderInfo
{
	/** whether to clip text */
	var bool bClipText;
	/** whether to turn on shadowing */
	var bool bEnableShadow;
	/** depth field glow parameters (only usable if font was imported with a depth field) */
	var DepthFieldGlowInfo GlowInfo;
};

/** Simple 2d triangle with UVs */
struct native CanvasUVTri
{
	/** Position of first vertex */
	var()   vector2d    V0_Pos;
	/** UV of first vertex */
	var()   vector2d    V0_UV;

	/** Position of second vertex */
	var()   vector2d    V1_Pos;
	/** UV of second vertex */
	var()   vector2d    V1_UV;

	/** Position of third vertex */
	var()   vector2d    V2_Pos;
	/** UV of third vertex */
	var()   vector2d    V2_UV;
};

// Modifiable properties.
var font    Font;            // Font for DrawText.
var float   OrgX, OrgY;      // Origin for drawing.
var float   ClipX, ClipY;    // Bottom right clipping region.
var float   CurX, CurY, CurZ;// Current position for drawing.
var float   CurYL;           // Largest Y size since DrawText.
var color   DrawColor;       // Color for drawing.
var bool    bCenter;         // Whether to center the text.
var bool    bNoSmooth;       // Don't bilinear filter.
var const int SizeX, SizeY;  // Zero-based actual dimensions.

// Internal.
var native const pointer Canvas{FCanvas};
var native const pointer SceneView{FSceneView};

var Plane ColorModulate;
var Texture2D DefaultTexture;

cpptext
{
	// UCanvas interface.
	void Init();
	void Update();

	void DrawTile(UTexture* Tex, FLOAT X, FLOAT Y, FLOAT Z, FLOAT XL, FLOAT YL, FLOAT U, FLOAT V, FLOAT UL, FLOAT VL, const FLinearColor& Color,EBlendMode BlendMode=BLEND_Translucent);
	void DrawMaterialTile(UMaterialInterface* Tex, FLOAT X, FLOAT Y, FLOAT Z, FLOAT XL, FLOAT YL, FLOAT U, FLOAT V, FLOAT UL, FLOAT VL);
	static void ClippedStrLen(UFont* Font, FLOAT ScaleX, FLOAT ScaleY, INT& XL, INT& YL, const TCHAR* Text);
	void VARARGS WrappedStrLenf(UFont* Font, FLOAT ScaleX, FLOAT ScaleY, INT& XL, INT& YL, const TCHAR* Fmt, ...);
	INT WrappedPrint(UBOOL Draw, INT& XL, INT& YL, UFont* Font, FLOAT ScaleX, FLOAT ScaleY, UBOOL Center, const TCHAR* Text, const FFontRenderInfo& RenderInfo = FFontRenderInfo(EC_EventParm));
	void DrawText(const FString& Text);
	void DrawTileStretched(UTexture* Tex, FLOAT Left, FLOAT Top, FLOAT Depth, FLOAT AWidth, FLOAT AHeight, FLOAT U, FLOAT V, FLOAT UL, FLOAT VL, FLinearColor DrawColor,UBOOL bStretchHorizontally=1,UBOOL bStretchVertically=1,FLOAT ScalingFactor=1.0);
}

/**
 * Draws a texture to an axis-aligned quad at CurX,CurY.
 *
 * @param	Tex - The texture to render.
 * @param	XL - The width of the quad in pixels.
 * @param	YL - The height of the quad in pixels.
 * @param	U - The U coordinate of the quad's upper left corner, in normalized coordinates.
 * @param	V - The V coordinate of the quad's upper left corner, in normalized coordinates.
 * @param	UL - The range of U coordinates which is mapped to the quad.
 * @param	VL - The range of V coordinates which is mapped to the quad.
 * @param	LColor - Color to colorize this texture.
 * @param	bClipTile - Whether to clip the texture (FALSE by default).
 */
native noexport final function DrawTile(Texture Tex, float XL, float YL, float U, float V, float UL, float VL, optional LinearColor LColor, optional bool ClipTile, optional EBlendMode Blend);


/**
 * Optimization call to pre-allocate vertices and triangles for future DrawTile() calls.
 *		NOTE: Num is number of subsequent DrawTile() calls that will be made in a row with the 
 *			same Texture and Blend settings. If other draws (Text, different textures, etc) are
 *			done before the Num DrawTile calls, the optimization will not work and will only waste memory.
 *
 * @param	Num - The number of DrawTile calls that will follow this function call
 * @param	Tex - The texture that will be used to render tiles.
 * @param	Blend - The blend mode that will be used for tiles.
 */
native noexport final function PreOptimizeDrawTiles(INT Num, Texture Tex, optional EBlendMode Blend);

/**
 * Draws the emissive channel of a material to an axis-aligned quad at CurX,CurY.
 *
 * @param	Mat - The material which contains the emissive expression to render.
 * @param	XL - The width of the quad in pixels.
 * @param	YL - The height of the quad in pixels.
 * @param	U - The U coordinate of the quad's upper left corner, in normalized coordinates.
 * @param	V - The V coordinate of the quad's upper left corner, in normalized coordinates.
 * @param	UL - The range of U coordinates which is mapped to the quad.
 * @param	VL - The range of V coordinates which is mapped to the quad.
 * @param	bClipTile - Whether to clip the texture (FALSE by default).
 */
native noexport final function DrawMaterialTile
(
				MaterialInterface	Mat,
				float				XL,
				float				YL,
	optional	float				U,
	optional	float				V,
	optional	float				UL,
	optional	float				VL,
	optional	bool				bClipTile
);

native final function DrawRotatedTile( Texture Tex, rotator Rotation, float XL, float YL,  float U, float V,float UL, float VL,
									  optional float AnchorX=0.5f, optional float AnchorY=0.5f);

native final function DrawRotatedMaterialTile( MaterialInterface Mat, rotator Rotation, float XL, float YL,  optional float U=0.f, optional float V=0.f,
											  optional float UL=0.f, optional float VL=0.f, optional float AnchorX=0.5f, optional float AnchorY=0.5f);

native noexport final function DrawTileStretched(Texture Tex, float XL, float YL,  float U, float V, float UL, float VL, optional LinearColor LColor/* = DrawColor*/, optional bool bStretchHorizontally/* = true*/, optional bool bStretchVertically/* = true*/, optional float ScalingFactor/* = 1.0*/);

/**
 *	Draw a number of triangles on the canvas
 *	@param Tex			Texture to apply to triangles
 *	@param Triangles	Array of triangles to render
 */
native final function DrawTris( Texture Tex, array<CanvasUVTri> Triangles );

/** constructor for FontRenderInfo */
static final function FontRenderInfo CreateFontRenderInfo(optional bool bClipText, optional bool bEnableShadow, optional LinearColor GlowColor, optional vector2D GlowOuterRadius, optional vector2D GlowInnerRadius)
{
	local FontRenderInfo Result;

	Result.bClipText = bClipText;
	Result.bEnableShadow = bEnableShadow;
	Result.GlowInfo.bEnableGlow = (GlowColor.A != 0.0);
	if (Result.GlowInfo.bEnableGlow)
	{
		Result.GlowInfo.GlowOuterRadius = GlowOuterRadius;
		Result.GlowInfo.GlowInnerRadius = GlowInnerRadius;
	}
	return Result;
}

native noexport final function StrLen(coerce string String, out float XL, out float YL); // Wrapped!
native noexport final function TextSize(coerce string String, out float XL, out float YL); // Clipped!

native noexport final function DrawText(coerce string Text, optional bool CR = true, optional float XScale = 1.0, optional float YScale = 1.0, optional const out FontRenderInfo RenderInfo);

/** Convert a 3D vector to a 2D screen coords. */
native noexport final function vector Project(vector location);

/** transforms 2D screen coordinates into a 3D world-space origin and direction
 * @param ScreenPos - screen coordinates in pixels
 * @param WorldOrigin (out) - world-space origin vector
 * @param WorldDirection (out) - world-space direction vector
 */
native noexport final function DeProject(vector2D ScreenPos, out vector WorldOrigin, out vector WorldDirection);

/**
 * Pushes a translation matrix onto the canvas.
 *
 * @param TranslationVector		Translation vector to use to create the translation matrix.
 */
native noexport final function PushTranslationMatrix(vector TranslationVector);

/** Pops the topmost matrix from the canvas transform stack. */
native noexport final function PopTransform();

// UnrealScript functions.
event Reset(optional bool bKeepOrigin)
{
	Font        = Default.Font;
	if ( !bKeepOrigin )
	{
		OrgX        = Default.OrgX;
		OrgY        = Default.OrgY;
	}
	CurX        = Default.CurX;
	CurY        = Default.CurY;
	DrawColor   = Default.DrawColor;
	CurYL       = Default.CurYL;
	bCenter     = false;
	bNoSmooth   = false;
}

native final function SetPos(float PosX, float PosY, float PosZ=1.0);

final function SetOrigin(float X, float Y)
{
	OrgX = X;
	OrgY = Y;
}

final function SetClip(float X, float Y)
{
	ClipX = X;
	ClipY = Y;
}

final function DrawTexture(Texture Tex, float Scale)
{
	if (Tex != None)
	{
		DrawTile(Tex, Tex.GetSurfaceWidth()*Scale, Tex.GetSurfaceHeight()*Scale, 0, 0, Tex.GetSurfaceWidth(), Tex.GetSurfaceHeight());
	}
}

final function DrawTextureBlended(Texture Tex, float Scale,EBlendMode Blend)
{
	local LinearColor DrawColorLinear;

	DrawColorLinear = ColorToLinearColor(DrawColor);
	if (Tex != None)
	{
		DrawTile(Tex, Tex.GetSurfaceWidth()*Scale, Tex.GetSurfaceHeight()*Scale, 0, 0, Tex.GetSurfaceWidth(), Tex.GetSurfaceHeight(),DrawColorLinear,,Blend);
	}
}

/**
 * Fake CanvasIcon constructor.
 */
final function CanvasIcon MakeIcon(Texture Texture, optional float U, optional float V, optional float UL, optional float VL)
{
	local CanvasIcon Icon;
	if (Texture != None)
	{
		Icon.Texture = Texture;
		Icon.U = U;
		Icon.V = V;
		Icon.UL = (UL != 0.f ? UL : Texture.GetSurfaceWidth());
		Icon.VL = (VL != 0.f ? VL : Texture.GetSurfaceHeight());
	}
	return Icon;
}

/**
 * Draw a CanvasIcon at the desired canvas position.
 */
final function DrawIcon(CanvasIcon Icon, float X, float Y, optional float Scale)
{
	if (Icon.Texture != None)
	{
		// verify properties are valid
		if (Scale <= 0.f)
		{
			Scale = 1.f;
		}
		if (Icon.UL == 0.f)
		{
			Icon.UL = Icon.Texture.GetSurfaceWidth();
		}
		if (Icon.VL == 0.f)
		{
			Icon.VL = Icon.Texture.GetSurfaceHeight();
		}
		// set the canvas position
		CurX = X;
		CurY = Y;
		// and draw the texture
		DrawTile(Icon.Texture, Abs(Icon.UL) * Scale, Abs(Icon.VL) * Scale, Icon.U, Icon.V, Icon.UL, Icon.VL);
	}
}

final function DrawRect(float RectX, float RectY, optional Texture Tex = DefaultTexture)
{
	DrawTile(Tex, RectX, RectY, 0, 0, Tex.GetSurfaceWidth(), Tex.GetSurfaceHeight());
}

final simulated function DrawBox(float width, float height)
{
	local int X, Y;

	X = CurX;
	Y = CurY;

	// normalize CurX, CurY (eliminate float precision errors)
	SetPos(X, Y);

	// draw the left side
	DrawRect(2, height);
	// then move cursor to top-right
	SetPos(X + width - 2, Y);

	// draw the right face
	DrawRect(2, height);
	// then move the cursor to the top-left (+2 to account for the line we already drew for the left-face)
	SetPos(X + 2, Y);

	// draw the top face
	DrawRect(width - 4, 2);
	// then move the cursor to the bottom-left (+2 to account for the line we already drew for the left-face)
	SetPos(X + 2, Y + height - 2);

	// draw the bottom face
	DrawRect(width - 4, 2);
	// move the cursor back to its original position
	SetPos(X, Y);
}

native final function SetDrawColor(byte R, byte G, byte B, optional byte A = 255);

native noexport final function Draw2DLine(float X1, float Y1, float X2, float Y2, color LineColor);

native final function DrawTextureLine(vector StartPoint, vector EndPoint, float Perc, float Width, color LineColor, Texture LineTexture, float U, float V, float UL, float VL );
native final function DrawTextureDoubleLine(vector StartPoint, vector EndPoint, float Perc, float Spacing, float Width,	color LineColor, color AltLineColor, Texture Tex, float U, float V, float UL, float VL);


/**
 * Draws a graph comparing 2 variables.  Useful for visual debugging and tweaking.
 *
 * @param Title		Label to draw on the graph, or "" for none
 * @param ValueX	X-axis value of the point to plot
 * @param ValueY	Y-axis value of the point to plot
 * @param UL_X		X screen coord of the upper-left corner of the graph
 * @param UL_Y		Y screen coord of the upper-left corner of the graph
 * @param W			Width of the graph, in pixels
 * @param H			Height of the graph, in pixels
 * @param RangeX	Range of values expressed by the X axis of the graph
 * @param RangeY	Range of values expressed by the Y axis of the graph
 */
function DrawDebugGraph(coerce string Title, float ValueX, float ValueY, float UL_X, float UL_Y, float W, float H, vector2d RangeX, vector2d RangeY)
{
	`define GRAPH_ICONSIZE		8

	local int X, Y;

	// draw graph box
	SetDrawColor(255, 255, 255, 255);
	SetPos(UL_X, UL_Y);
	DrawBox(W, H);

	// plot point
	SetDrawColor(255, 255, 0, 255);
	X = UL_X + GetRangePctByValue(RangeX, ValueX) * W - `GRAPH_ICONSIZE/2;
	Y = UL_Y + GetRangePctByValue(RangeY, ValueY) * H - `GRAPH_ICONSIZE/2;
	SetPos(X, Y);
	DrawRect(`GRAPH_ICONSIZE, `GRAPH_ICONSIZE);

	// plot lines
	SetDrawColor(128, 128, 0, 128);
	Draw2DLine(UL_X, Y, UL_X+W, Y, DrawColor);		// horiz
	Draw2DLine(X, UL_Y, X, UL_Y+H, DrawColor);		// vert

	// x value at bottom
	SetDrawColor(255, 255, 0, 255);
	SetPos(X, UL_Y+H+16);
	DrawText(ValueX);

	// y value on right
	SetPos(UL_X+W+8, Y);
	DrawText(ValueY);

	// title
	if (Title != "")
	{
		SetPos(UL_X, UL_Y-16);
		DrawText(Title);
	}
}

defaultproperties
{
	DrawColor=(R=127,G=127,B=127,A=255)
	Font="EngineFonts.SmallFont"
	ColorModulate=(X=1,Y=1,Z=1,W=1)
	DefaultTexture="EngineResources.WhiteSquareTexture"
}
