/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
// CURRENTLY UNSUPPORTED
class AITree extends K2GraphBase
	native(AI)
	hidecategories(Object);


cpptext
{
	virtual void PostLoad();
	virtual void FillRootList();
};

struct native AITreeUtilityInfo
{
	var() class<AICommandBase>  CommandClass;
	var() float                 UtilityRating;
};

/** Struct that allows AI Controller to store state information about the AI tree 
 *  Used because multiple AI can share the same tree content and they should not be altering the actual tree
 */
struct native AITreeHandle
{
	/** Name of the active root node */
	var const Name                  ActiveRootName;
	/** Ptr to active root node */
	var AICommandNodeRoot           ActiveRoot;

	/** List of command nodes that we want to ignore */
	var array<AICommandNodeBase>    DisabledNodes;

//don't need in final release?
	var(Debug) transient array<AITreeUtilityInfo>   LastUtilityRatingList;
	var(Debug) transient array<AITreeUtilityInfo>   LastUtilityRatingListAtChange;	

	structcpptext
	{
		UBOOL IsNodeDisabled( UAICommandNodeBase* Node );
	}
};

/** List of all roots available in the tree */
var array<AICommandNodeRoot>    RootList;

/** Set active root to root node with given name */
native function bool SetActiveRoot( Name InName, out AITreeHandle Handle );

native function array< class<AICommandBase> > EvaluateTree( AIController InAI, out AITreeHandle Handle );

defaultproperties
{

}