/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * - This is a simple Horz. List that uses graphics.
 */

class UDKSimpleImageList extends UDKDrawPanel
	native;

var() editinlineuse array<Texture2D> ImageList;

var transient  int ItemCount;
var transient  int Selection, OldSelection;

var() float DefaultCellWidth, DefaultCellHeight;
var() float Padding;

var transient  float TransitionTime;

var transient float ResScale;

struct native SimpleImageListData
{
	var name Tag;
	var int Count;
	var int ImageIndex;
	var TextureCoordinates UVs;
	var float CurMultiplier;
	var float Multipliers[2];
	var float TransitionTime;
	var float TransitionAlpha;
	var float Bounds[4];
	var bool bWasRendered;

	structdefaultproperties
	{
		CurMultiplier=1.0
		Multipliers(0)=1.0
		Multipliers(1)=1.0
		TransitionTime=0.0
		TransitionAlpha=1.0
		bWasRendered = false;
	}
};

var transient array<SimpleImageListData> List;

var transient  float WindowWidth;
var transient  float ListWidthInPixel;

/** Size of the selection bubble, used to calculate alpha for items around the selected item. */
var() int BubbleRadius;

/** If true, the positions have been invalidated so recalculate the sizes/etc. */
var transient bool bInvalidated;

var transient  float ListWidthInPixels;

var transient  float LastMouseUpdate;

var transient  float WindowLeft;

var transient  float PaddingThisFrame;

var transient  float SelectionModifier;

var transient  float StartSelectionTime;

var transient  float LastRenderTime;

var transient  bool bTransitioning;

var transient float SelectionAlpha;

var transient float WindowScaling;

/*	======================================================================
		Natives
	====================================================================== */

native function UpdateAnimation(FLOAT DeltaTime);


/**
 * Setup the input system
 */
event PostInitialize()
{
	Super.PostInitialize();
	OnProcessInputKey=ProcessInputKey;
}

/*	======================================================================
		Input
	====================================================================== */


event GetSupportedUIActionKeyNames(out array<Name> out_KeyNames )
{
	out_KeyNames[out_KeyNames.Length] = 'SelectionLeft';
	out_KeyNames[out_KeyNames.Length] = 'SelectionRight';
	out_KeyNames[out_KeyNames.Length] = 'SelectionHome';
	out_KeyNames[out_KeyNames.Length] = 'SelectionEnd';
	out_KeyNames[out_KeyNames.Length] = 'Select';
	out_keyNames[out_KeyNames.Length] = 'Click';
	out_keyNames[out_KeyNames.Length] = 'MouseMoveX';
	out_keyNames[out_KeyNames.Length] = 'MouseMoveY';
}

/**
 * @Returns the mouse position in widget space
 */
function Vector GetMousePosition()
{
	local int x,y;
	local vector2D MousePos;
	local vector AdjustedMousePos;
	class'UIRoot'.static.GetCursorPosition( X, Y );
	MousePos.X = X;
	MousePos.Y = Y;
	AdjustedMousePos = PixelToCanvas(MousePos);
	AdjustedMousePos.X -= GetPosition(UIFACE_Left,EVALPOS_PixelViewport);
	AdjustedMousePos.Y -= GetPosition(UIFACE_Top, EVALPOS_PixelViewport);
	return AdjustedMousePos;
}

function bool ProcessInputKey( const out SubscribedInputEventParameters EventParms )
{
	if (EventParms.EventType == IE_Pressed || EventParms.EventType == IE_Repeat || EventParms.EventType == IE_DoubleClick)
	{
		if ( EventParms.InputAliasName == 'SelectionLeft' )
		{
			SelectItem(Selection - 1);
			PlayUISound('ListUp');
			return true;
		}
		else if ( EventParms.InputAliasName == 'SelectionRight' )
		{
			SelectItem(Selection + 1);
			PlayUISound('ListDown');
			return true;
		}
		if ( EventParms.InputAliasName == 'SelectionHome' )
		{
			SelectItem(0);
			PlayUISound('ListUp');
			return true;
		}
		else if ( EventParms.InputAliasName == 'SelectionEnd' )
		{
			SelectItem(List.Length-1);
			PlayUISound('ListDown');
			return true;
		}
		else if ( EventParms.InputAliasName == 'Click' )
		{
			if ( EventParms.EventType == IE_DoubleClick )
			{
				ItemChosen(EventParms.PlayerIndex);
			}
			return true;
		}

	}
	else if ( EventParms.EventType == IE_Released )
	{
		if(EventParms.InputAliasName == 'Click')
		{
			PlayUISound('ListSubmit');
			SelectUnderCursor();
			return true;
		}
		else if ( EventParms.InputAliasName == 'Select' )
		{
			PlayUISound('ListSubmit');
			ItemChosen(EventParms.PlayerIndex);
			return true;
		}
	}

	return false;
}

function ItemChosen(int PlayerIndex)
{
	OnItemChosen(self, Selection,PlayerIndex);
}

function bool MouseInBounds()
{
	local Vector MousePos;
	local float w,h;

	MousePos = GetMousePosition();

    w = GetBounds(UIORIENT_Horizontal, EVALPOS_PixelViewport);
    h = GetBounds(UIORIENT_Vertical, EVALPOS_PixelViewport);

	return ( MousePos.X >=0 && MousePos.X < w && MousePos.Y >=0 && MousePos.Y < h );
}


/**
 * All are in pixels
 *
 * @Param X1		Left
 * @Param Y1		Top
 * @Param X2		Right
 * @Param Y2		Bottom
 *
 * @Returns true if the mouse is within the bounds given
 */
function bool CursorCheck(float X1, float Y1, float X2, float Y2)
{
	local vector MousePos;;

	MousePos = GetMousePosition();

	return ( (MousePos.X >= X1 && MousePos.X <= X2) && (MousePos.Y >= Y1 && MousePos.Y <= Y2) );
}


/**
 * Select whichever widget happens to be under the cursor
 */
function SelectUnderCursor()
{
	local int w;
	local vector AdjustedMousePos;
	local int i;

	AdjustedMousePos = GetMousePosition();

	w = GetBounds(UIORIENT_Horizontal, EVALPOS_PixelViewport);

	if ( AdjustedMousePos.X >= 0 && AdjustedMousePos.X <= w)
	{
		for (i=0;i<List.Length;i++)
		{
			if ( List[i].bWasRendered && CursorCheck( List[i].Bounds[0], List[i].Bounds[1], List[i].Bounds[2], List[i].Bounds[3]) )
			{
				SelectItem(i);
				break;
			}
		}
	}
}

/*	======================================================================
		List Management
	====================================================================== */

event AddItem(name NewTag, int Count, int NewImageIndex, TextureCoordinates NewUVs)
{
	local int Index;
	Index = List.Length;
	List.Length = Index+1;
	List[Index].Tag = NewTag;
	List[Index].Count = Count;
	List[Index].ImageIndex = NewImageIndex;
	List[Index].UVs = NewUVs;
	List[Index].CurMultiplier = 1.0;

	bInvalidated = true;

	// Select the first item

	if (List.Length == 1)
	{
		SelectItem(Index);
	}
	else
	{
		SelectItem(Selection);
	}

}

/**
 * Removes an item from the list
 */
event RemoveItem(int IndexToRemove)
{
	List.Remove(IndexToRemove,1);
	bInvalidated = true;

}

/**
 * Empties the list
 */
event Empty()
{
	Selection = -1;
	List.Remove(0,List.Length);
	bInvalidated = true;

}


function name GetSelectedTag()
{
	if (Selection < List.Length)
	{
		return List[Selection].Tag;
	}
	return '';
}

/**
 * Starts an item down the road to transition
 */
function SetTransition(int ItemIndex, float NewDestinationTransition)
{
	if (NewDestinationTransition != List[ItemIndex].CurMultiplier )
	{
		List[ItemIndex].Multipliers[0] = List[ItemIndex].CurMultiplier;
		List[ItemIndex].Multipliers[1] = NewDestinationTransition;
		List[ItemIndex].Transitiontime = TransitionTime;
	}
}


/**
 * Selects an item
 */

event SelectItem(int NewSelection)
{
	if(NewSelection != Selection)
	{
		NewSelection = Clamp(NewSelection,0,List.Length-1);

		OldSelection = Selection;
		Selection = NewSelection;

		StartSelectionTime = UDKUIScene( GetScene() ).GetWorldInfo().RealTimeSeconds;
		SelectionAlpha = 0.0f;
		bTransitioning = true;

		if (Selection != OldSelection)
		{
			OnSelectionChange(self, Selection);
		}
	}
}


/*	======================================================================
		Rendering / Sizing - All of these function assume Canvas is valid.
	====================================================================== */

/**
 * SizeList is called directly before rendering anything in the list.
 */

event SizeList()
{
	local int i;
	local float Size;


	WindowWidth = GetBounds(UIORIENT_Horizontal, EVALPOS_PixelViewport);
    PaddingThisFrame = WindowWidth * Padding * ResScale;

	ListWidthInPixel = 0;
	for (i=0;i<List.Length;i++)
	{
		Size = DefaultCellWidth * List[i].CurMultiplier;
		ListWidthInPixel += Size + PaddingThisFrame;
	}

	WindowScaling = GetBounds(UIORIENT_Vertical, EVALPOS_PixelViewport) / 142;
	WindowLeft = (WindowWidth * 0.5) - (ListWidthInPixel * WindowScaling * 0.5);
}

/**
 * Render the list.  At this point each cell should be sized, etc.
 */
event DrawPanel()
{
	local int DrawIndex;
	local float XPos, YPos, CellWidth,CellHeight;
	local float TimeSeconds,DeltaTime;
	local WorldInfo WI;
	local vector2D VS;

	GetViewportSize(VS);
	ResScale = VS.Y / 768;

	// If the list is empty, exit right away.

	if ( List.Length == 0 )
	{
		return;
	}

	WI = UDKUIScene( GetScene() ).GetWorldInfo();
	TimeSeconds = WI.RealTimeSeconds * WI.TimeDilation;
	DeltaTime = TimeSeconds - LastRenderTime;
	LastRenderTime = TimeSeconds;

	UpdateAnimation(DeltaTime * UDKUIScene( GetScene() ).GetWorldInfo().TimeDilation);


	// FIXME: Big optimization if we don't have to recalc the
	// list size each frame.  We should only have to do this the resoltuion changes,
	// if we have added items to the list, or if the list is moving.  But for now this is
	// fine.

	bInvalidated = true;

	SizeList();

	XPos = WindowLeft;
	YPos = 0;	// Figure out where to start rendering

	// Draw all items
	DrawIndex = 0;
	for (DrawIndex = 0; DrawIndex < List.Length; DrawIndex++)
	{
		// Determine if we are past the end of the visible portion of the list..

		CellWidth = (DefaultCellWidth * List[DrawIndex].CurMultiplier * WindowScaling);
		CellHeight = (DefaultCellHeight * List[DrawIndex].CurMultiplier * WindowScaling);

		// Calculate the Bounds

    	List[DrawIndex].Bounds[0] = XPos;
    	List[DrawIndex].Bounds[1] = YPos;
    	List[DrawIndex].Bounds[2] = XPos + CellWidth;
    	List[DrawIndex].Bounds[3] = YPos + CellHeight;

		// Clear the rendered flag

    	List[DrawIndex].bWasRendered = false;

		// Allow a delegate first crack at rendering, otherwise use the default
		// string rendered.

		if ( !OnDrawItem(self, DrawIndex, XPos, YPos) )
		{
			DrawItem(DrawIndex, XPos, YPos);
	    	List[DrawIndex].bWasRendered = true;
		}
		XPos += CellWidth + PaddingThisFrame;
	}

}


/** @return Returns an item's height given the current position of the selection bar. */
event float GetItemScale(int ItemIdx, float SelectionPos)
{
	local float Dist;

	Dist = FClamp(ItemIdx - SelectionPos, -BubbleRadius, BubbleRadius);
	Dist /= BubbleRadius;
	Dist *= (PI / 2.0f);
	Dist = FMax(Cos(Dist),0.5f) * 2.0f - 1.0f;
	Dist = Dist * (SelectionModifier-1.0f) + 1.0f;
	Dist = Dist / SelectionModifier;

	return Dist;

}

/** @return Converts an item's scale width to pixels. */
function float GetItemWidthInPixels(float ItemScale)
{
	return ItemScale * DefaultCellWidth;
}
/**
 * This delegate allows anyone to alter the drawing code of the list.
 *
 * @Returns true to skip the default drawing
 */
delegate bool OnDrawItem(UDKSimpleImageList SimpleList, int ItemIndex, float XPos, out float YPos)
{
	return false;
}

/**
 * This delegate is called when an item in the list is chosen.
 */
delegate OnItemChosen(UDKSimpleImageList SourceList, int SelectedIndex, int PlayerIndex);

/**
 * This delegate is called when the selection index changes
 */
delegate OnSelectionChange(UDKSimpleImageList SourceList, int NewSelectedIndex);


/**
 * Draws an item to the screen.
 */

function DrawItem(int ItemIndex, float XPos, out float YPos)
{
	local float Scaler;
	local int i,Cnt, M;

	Cnt = Clamp(List[ItemIndex].Count,1,3);
	M = (Cnt-1) * (8 * ResScale);

	for (i=0;i<Cnt;i++)
	{
		Scaler = WindowScaling * List[ItemIndex].CurMultiplier;
		Canvas.SetPos(XPos+M, YPos+M);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.DrawTile(ImageList[List[ItemIndex].ImageIndex],  DefaultCellWidth * Scaler, DefaultCellHeight * Scaler,
							List[ItemIndex].UVs.U,List[ItemIndex].UVs.V,List[ItemIndex].UVs.UL,List[ItemIndex].UVs.VL);

		M -= (8 * ResScale);
	}
}

defaultproperties
{
	// States
	DefaultStates.Add(class'Engine.UIState_Active')

	DefaultCellWidth=96
	DefaultCellHeight=128
	SelectionModifier=1.3

    TransitionTime=0.125
	BubbleRadius=2
	Selection=-1

}
