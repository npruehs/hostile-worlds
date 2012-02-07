/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Our Widgets are collections of UIObjects that are group together with
 * the glue logic to make them tick.
 */

class UDKUI_Widget extends UIObject
	abstract
	native;

/** If true, this object require tick */
var bool bRequiresTick;

/** Whether this widget can accept focus on consoles */
var bool bCanAcceptFocusOnConsole;

/** Cached link to the UDKUIScene that owns this widget */
var UDKUIScene UTSceneOwner;

cpptext
{
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );
	virtual void Tick_Widget(FLOAT DeltaTime){};
	virtual void PreRender_Widget(FCanvas* Canvas){};

	/**
	  * WARNING: This function does not check the destination and assumes it is valid.
	  *
	  * LookupProperty - Finds a property of a source actor and returns it's value.
	  *
	  * @param		SourceActor			The actor to search
	  * @param		SourceProperty		The property to look up
	  * @out param 	DestPtr				A Point to the storgage of the value
	  *
	  * @Returns true if the look up succeeded
	  */
	virtual UBOOL LookupProperty(AActor* SourceActor, FName SourceProperty, BYTE* DestPtr);

}

/** === Focus Handling === */
/**
 * Determines whether this widget can become the focused control.
 * Check whether on console and bCanAcceptFocusOnConsole=true
 */
native function bool CanAcceptFocus( optional int PlayerIndex=0, optional bool bIncludeParentVisibility=true ) const;

function NotifyGameSessionEnded();

/** @return Returns a datastore given its tag. */
function UIDataStore FindDataStore(name DataStoreTag)
{
	local UIDataStore	Result;

	Result = StaticResolveDataStore(DataStoreTag);

	return Result;
}

/** @return Returns the controller id of a player given its player index. */
function int GetPlayerControllerId(int PlayerIndex)
{
	local int Result;

	Result = GetCurrentUIController().GetPlayerControllerId(PlayerIndex);;

	return Result;
}

/** stub (implemented by UTUIButtonBar) */
function Clear();

/** stub (implemented by UTUIButtonBar) */
function SetSubFocus(int Index, UIObject NewFocus);

event UIButton GetButton(int Index);

function int AppendButton(string ButtonTextMarkup, delegate<UIObject.OnClicked> ButtonDelegate);

defaultproperties
{
	bCanAcceptFocusOnConsole=true
}
