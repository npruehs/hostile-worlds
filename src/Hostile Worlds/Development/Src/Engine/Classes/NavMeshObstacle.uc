/**
 *  Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class NavMeshObstacle extends Actor
	native(AI)
	implements(Interface_NavMeshPathObstacle)
	placeable;

var() bool bEnabled;
var() bool bPreserveInternalGeo;

cpptext
{
	/**
	 * this function should populate out_polyshape with a list of verts which describe this object's 
	 * convex bounding shape
	 * @param out_PolyShape - output array which holds the vertex buffer for this obstacle's bounding polyshape
	 * @return TRUE if this object should block things right now (FALSE means this obstacle shouldn't affect the mesh)
	 */
	virtual UBOOL GetBoundingShape(TArray<FVector>& out_PolyShape);

	/**
	 * when TRUE polys internal to this obstacle will be preserved, but still split. (useful for things like cost volumes that 
	 * need to adjust cost but not completely destroy parts of the mesh
	 * @return TRUE if polys should be preserved internal to this obstacle
	 */
	virtual UBOOL PreserveInternalPolys() { return bPreserveInternalGeo; }

	/**
	 * For debugging.  Verifies that this pathobject is still alive and well and not orphaned or deleted
	 * @return - TRUE If this path object is in good working order
	 */
	virtual UBOOL VerifyObstacle()
	{
		return !IsPendingKill();
	}

};

native function RegisterObstacle();
native function UnRegisterObstacle();

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if(bEnabled)
	{
		RegisterObstacle();
	}	
}

simulated function OnToggle(SeqAct_Toggle Action)
{
	// Turn ON
	if (Action.InputLinks[0].bHasImpulse)
	{
		bEnabled=true;
	}
	// Turn OFF
	else if (Action.InputLinks[1].bHasImpulse)
	{
		bEnabled=false;
	}
	// Toggle
	else if (Action.InputLinks[2].bHasImpulse)
	{
		bEnabled = !bEnabled;
	}

	SetEnabled(bEnabled);
}

function SetEnabled(bool bInEnabled)
{
	if(bInEnabled)
	{
		RegisterObstacle();
	}
	else
	{
		UnRegisterObstacle();
	}
}

defaultproperties
{
	bStatic=false
	bNoDelete=false
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Keypoint'
		HiddenGame=False
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	Begin Object Class=DrawBoxComponent Name=DrawBox0
		BoxColor=(R=64,G=70,B=255,A=255)
		BoxExtent=(X=200.0, Y=200.0, Z=200.0);
		bDrawWireBox=true
		//HiddenGame=False
	End Object
	Components.Add(DrawBox0)
}