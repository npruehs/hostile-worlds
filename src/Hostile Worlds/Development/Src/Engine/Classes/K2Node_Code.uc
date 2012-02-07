/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class K2Node_Code extends K2NodeBase
	native(K2);


cpptext
{
#if WITH_EDITOR
	virtual void GetCodeText(struct FK2CodeGenContext& Context, TArray<struct FK2CodeLine>& OutCode);

	virtual void CreateConnectorsFromFunction(UFunction* InFunction, UClass* ReturnConClass = NULL);

	class UK2Node_Code* GetCodeNodeFromOutputName(const FString& OutputName);

	virtual FString GetCodeFromParamInput(const FString& InputName, struct FK2CodeGenContext& Context);

	/** Get the set of pure function nodes that need to be processed before this node can be */
	void GetDependentPureFunctions(struct FK2CodeGenContext& Context, TArray<class UK2Node_FuncPure*>& OutPureFuncs);

	/** Generate code to assign any output vars to local variables */
	void GetMemberVarAssignCode(struct FK2CodeGenContext& Context, TArray<struct FK2CodeLine>& OutCode);
#endif
};

