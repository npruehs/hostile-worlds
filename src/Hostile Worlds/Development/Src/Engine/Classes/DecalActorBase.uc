/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class DecalActorBase extends Actor
	native(Decal)
	abstract;

var() editconst const DecalComponent Decal;

cpptext
{
	// UObject interface.
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	// AActor interface.
	virtual void PostEditImport();
	virtual void PostEditMove(UBOOL bFinished);
	virtual void EditorApplyScale(const FVector& DeltaScale, const FMatrix& ScaleMatrix, const FVector* PivotLocation, UBOOL bAltDown, UBOOL bShiftDown, UBOOL bCtrlDown);

	// AActor interface.
	/**
	 * Function that gets called from within Map_Check to allow this actor to check itself
	 * for any potential errors and register them with map check dialog.
	 */
	virtual void CheckForErrors();
}

defaultproperties
{
	TickGroup=TG_DuringAsyncWork

	Begin Object Class=DecalComponent Name=NewDecalComponent
		DecalTransform=DecalTransform_OwnerAbsolute
		bStaticDecal=TRUE
	End Object
	Decal=NewDecalComponent
	Components.Add(NewDecalComponent)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_DecalActorIcon'
		Scale=0.15
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	Begin Object Class=ArrowComponent Name=ArrowComponent0
		bTreatAsASprite=True
		HiddenGame=true
	End Object
	Components.Add(ArrowComponent0)

	bStatic=true
	bMovable=false
}
