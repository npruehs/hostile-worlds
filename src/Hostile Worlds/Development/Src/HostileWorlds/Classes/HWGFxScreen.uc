// ============================================================================
// HWGFxScreen
// Base class for any screen in Hostile Worlds.
//
// Related Flash content: n/a
//
// Author:  Nick Pruehs
// Date:    2011/03/29
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxScreen extends HWGFxView;


function ShowView()
{
	super.ShowView();

	// don't scale menu screens
	SetViewScaleMode(SM_NoScale);

	if (FrontEnd != none)
	{
		FrontEnd.SetScreenTitle(ViewTitle);
	}
}

DefaultProperties
{
}
