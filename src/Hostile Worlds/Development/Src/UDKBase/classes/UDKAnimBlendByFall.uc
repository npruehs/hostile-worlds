/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKAnimBlendByFall extends UDKAnimBlendBase
	native(Animation);

enum EBlendFallTypes
{
	FBT_Up,				// jump
	FBT_Down,
	FBT_PreLand,
	FBT_Land,
	// variants for double jump
	FBT_DblJumpUp,
	FBT_DblJumpDown,		
	FBT_DblJumpPreLand,		
	FBT_DblJumpLand,		
	FBT_None
};

/** If TRUE, double jump versions of the inputs will be ignored. */
var() bool					bIgnoreDoubleJumps;

/** Time before predicted landing to trigger pre-land animation. */
var() float					PreLandTime;

/** Time before landing we should start becoming upright again. */
var() float					PreLandStartUprightTime;

/** Time to become upright when executing double jump. */
var() float					ToDblJumpUprightTime;

/** True if a double jump was performed and we should use the DblJump states. */
var transient bool			bDidDoubleJump;

/** 
 * This fall is used for dodging.  When it's true, the Falling node progress through 
 * it's states in an alternate manner
 */
var bool 					bDodgeFall;		

/** The current state this node believes the pawn to be in */

var const EBlendFallTypes 	FallState;				

/** Set internally, this variable holds the size of the velocity at the last tick */

var const float				LastFallingVelocity;	

/** Cached pointer to parent leaning node. */
var const UDKAnimNodeJumpLeanOffset	CachedLeanNode;

cpptext
{
	virtual void InitAnim( USkeletalMeshComponent* meshComp, UAnimNodeBlendBase* Parent );
	virtual	void TickAnim(FLOAT DeltaSeconds);
	virtual void SetActiveChild( INT ChildIndex, FLOAT BlendTime );
	virtual void OnChildAnimEnd(UAnimNodeSequence* Child, FLOAT PlayedTime, FLOAT ExcessTime);
	virtual void ChangeFallState(EBlendFallTypes NewState);
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void RenameChildConnectors();
	virtual void OnCeaseRelevant();
}


defaultproperties
{
	FallState=FBT_None
	bDodgeFall=false
	
	Children(0)=(Name="Up",Weight=1.0)
	Children(1)=(Name="Down")
	Children(2)=(Name="Pre-Land")
	Children(3)=(Name="Land")
	Children(4)=(Name="DoubleJump Up")
	Children(5)=(Name="DoubleJump Down")
	Children(6)=(Name="DoubleJump Pre-Land")
	Children(7)=(Name="DoubleJump Land")
	bFixNumChildren=true
}
