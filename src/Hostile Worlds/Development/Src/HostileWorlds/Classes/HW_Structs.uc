// ============================================================================
// HWArtifact
// Container class for structs.
// Must be compiled before all other classes in order for all structs to be accessible.
//
// Author:  Marcel Koehler, Nick Pruehs
// Date:    2010/07/08
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================

class HW_Structs extends Object;

struct STextUpEffect
{
	var string Text;
	var Vector Location;
	var Color Color;
	var Vector2D Scale;
	var int Progress;
};

DefaultProperties
{
}
