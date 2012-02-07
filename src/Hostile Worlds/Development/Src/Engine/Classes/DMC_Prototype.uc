/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class DMC_Prototype extends K2GraphBase
	native(Prefab);

/** Pointer to the parent class that the generated class should derive from */
var     Class           ParentClass;

/** Pointer to 'most recent' version of generated class */
var     Class           GeneratedClass;

/** String indicating script functions for this class */
var     string          FunctionCode;

/** Text string that holds default properties for this class */
var     string          DefaultPropText;


/** Struct indicating a new variable added to this generated class */
struct native DMCNewVar
{
	/** Name of new variable */
	var()   Name            VarName;

	/** Type of the new variable */
	var()   Name            VarType;

	structcpptext
	{
		/** Output this variable as a line of code declaration */
		FString ToCodeString(const FString VarSect);
	}
};

/** Array of new variables to be added to generated class */
var()   array<DMCNewVar>    NewVars;


cpptext
{
	virtual void PostLoad();
}
