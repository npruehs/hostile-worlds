/**
 * Base class for all UI component classes.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIComponent extends Component
	within UIScreenObject
	native(UserInterface)
	abstract
	DependsOn(UIRoot);

cpptext
{
	/* === UObject interface === */
	/**
	 * Called just after a property in this object's archetype is modified, immediately after this object has been de-serialized
	 * from the archetype propagation archive.
	 *
	 * Allows objects to perform reinitialization specific to being de-serialized from an FArchetypePropagationArc and
	 * reinitialized against an archetype. Only called for instances of archetypes, where the archetype has the RF_ArchetypeObject flag.
	 */
	virtual void PostSerializeFromPropagationArchive();

	/**
	 * Builds a list of objects which have this object in their archetype chain.
	 *
	 * All archetype propagation for UIScreenObjects is handled by the UIPrefab/UIPrefabInstance code, so this version just
	 * skips the iteration.
	 *
	 * @param	Instances	receives the list of objects which have this one in their archetype chain
	 */
	virtual void GetArchetypeInstances( TArray<UObject*>& Instances );

	/**
	 * Serializes all objects which have this object as their archetype into GMemoryArchive, then recursively calls this function
	 * on each of those objects until the full list has been processed.
	 * Called when a property value is about to be modified in an archetype object.
	 *
	 * Since archetype propagation for UIScreenObjects is handled by the UIPrefab code, this version simply routes the call
	 * to the owning UIPrefab so that it can handle the propagation at the appropriate time.
	 *
	 * @param	AffectedObjects		unused
	 */
	virtual void SaveInstancesIntoPropagationArchive( TArray<UObject*>& AffectedObjects );

	/**
	 * De-serializes all objects which have this object as their archetype from the GMemoryArchive, then recursively calls this function
	 * on each of those objects until the full list has been processed.
	 *
	 * Since archetype propagation for UIScreenObjects is handled by the UIPrefab code, this version simply routes the call
	 * to the owning UIPrefab so that it can handle the propagation at the appropriate time.
	 *
	 * @param	AffectedObjects		unused
	 */
	virtual void LoadInstancesFromPropagationArchive( TArray<UObject*>& AffectedObjects );

	/**
	 * Determines whether this object is contained within a UIPrefab.
	 *
	 * @param	OwnerPrefab		if specified, receives a pointer to the owning prefab.
	 *
	 * @return	TRUE if this object is contained within a UIPrefab; FALSE if this object IS a UIPrefab or is not
	 *			contained within a UIPrefab.
	 */
	virtual UBOOL IsAPrefabArchetype( UObject** OwnerPrefab=NULL ) const;

	/**
	 * @return	TRUE if the object is contained within a UIPrefabInstance.
	 */
	virtual UBOOL IsInPrefabInstance() const;
}

DefaultProperties
{

}
