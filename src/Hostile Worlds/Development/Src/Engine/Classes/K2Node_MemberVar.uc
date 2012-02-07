/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Node_MemberVar extends K2Node_Code
	native(K2);

var EK2ConnectorType    VarType;

var string              VarName;

cpptext
{
#if WITH_EDITOR
	virtual FString GetDisplayName();
	virtual UBOOL InputDefaultsAreEditable();

	virtual void CreateAutoConnectors();

	virtual void CreateConnectorsFromVariable(UProperty* InVar);
#endif
}