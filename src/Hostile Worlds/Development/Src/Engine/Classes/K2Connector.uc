/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Connector extends Object
	native;

enum EK2ConnectorType
{
	K2CT_Bool,
	K2CT_Int,
	K2CT_Float,
	K2CT_Vector,
	K2CT_Rotator,
	K2CT_String,
	K2CT_Object,
	K2CT_Exec,
	K2CT_Unsupported
};

enum EK2ConnectorDirection
{
	K2CD_Input,
	K2CD_Output
};

var     K2NodeBase	        OwningNode;
var     string		        ConnName;

var     EK2ConnectorType    Type;

cpptext
{
#if WITH_EDITOR
	/** Util to get the type of this connector as a code string */
	virtual FString GetTypeAsCodeString();
#endif
}