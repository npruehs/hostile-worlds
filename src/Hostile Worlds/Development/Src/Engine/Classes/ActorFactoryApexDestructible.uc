/*=============================================================================
	ActorFactoryApexDestructible.uc: Apex integration for Destructible Assets
	Copyright 2008-2009 NVIDIA corporation..
=============================================================================*/

class ActorFactoryApexDestructible extends ActorFactory
	config(Editor)
	native;

cpptext
{
	virtual AActor* CreateActor( const FVector* const Location, const FRotator* const Rotation, const class USeqAct_ActorFactory* const ActorFactoryData );
	virtual UBOOL CanCreateActor(FString& OutErrorMsg, UBOOL bFromAssetOnly = FALSE);
	virtual void AutoFillFields(class USelection* Selection);
	virtual FString GetMenuName();
}

var()	ApexDestructibleAsset		DestructibleAsset;

defaultproperties
{
	MenuName="Add ApexDestructibleActor"
	NewActorClass=class'Engine.ApexDestructibleActor'
}
