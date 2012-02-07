/**
 * UISequence used to contain sequence objects which are associated with a particular UIState.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIStateSequence extends UISequence
	native(inherit);

cpptext
{
	/* === UUIStateSequence interface === */
	/**
	 * Returns the index [into the SequenceObjects array] of the UIEvent_MetaObject used to represent the owner state's
	 * custom input actions in the UI kismet editor, or INDEX_NONE if it can't be found.
	 */
	INT FindInputMetaObjectIndex() const;

	/**
	 * Creates a new UIEvent_InputMetaObject that will be used to display all of the input events for this state sequence, if one does not already exist
	 * in this sequence's SequenceObjects array.  Initializes the input meta object with the data from the owning state's custom input actions.
	 */
	void InitializeInputMetaObject();

	/**
	 * Copies all values from the input meta object into the owning state's custom input actions, then removes the meta object from the sequence's
	 * list of SequenceObjects.
	 */
	void SaveInputMetaObject();

	/**
	 * Determines whether the specified sequence op is referenced by the owning state's StateInputActions array.
	 */
	UBOOL IsStateInputAction( class USequenceOp* SeqOp ) const;

	/** USequence interface */
	/**
	 * Adds the specified SequenceOp to this sequence's list of ActiveOps.
	 *
	 * @param	NewSequenceOp	the sequence op to add to the list
	 * @param	bPushTop		if TRUE, adds the operation to the top of stack (meaning it will be executed first),
	 *							rather than the bottom
	 *
	 * @return	TRUE if the sequence operation was successfully added to the list.
	 */
	virtual UBOOL QueueSequenceOp( USequenceOp* NewSequenceOp, UBOOL bPushTop=FALSE );

	/**
	 * Returns whether the specified SequenceObject can exist in this sequence without being linked to anything else (i.e. does not require
	 * another sequence object to activate it).  This version also considers actions which are referenced only through the state's StateInputActions array
	 * to be standalone ops.
	 *
	 * @param	SeqObj	the sequence object to check
	 *
	 * @return	TRUE if the sequecne object does not require a separate "stand-alone" sequence object to reference it, in order to be loaded in game.
	 */
	virtual UBOOL IsObjectStandalone( USequenceObject* SeqObj ) const;

	/**
	 * Finds all sequence objects contained by this sequence which are linked to the specified sequence object.  This version
	 * also checks the owning state's input array to determine whether the specified op is referenced.
	 *
	 * @param	SearchObject		the sequence object to search for link references to
	 * @param	out_Referencers		if specified, receieves the list of sequence objects contained by this sequence
	 *								which are linked to the specified op
	 *
	 * @return	TRUE if at least one object in the sequence objects array is linked to the specified op.
	 */
	virtual UBOOL FindSequenceOpReferencers( USequenceObject* SearchObject, TArray<USequenceObject*>* out_Referencers=NULL );

	/* === UObject interface === */
	/**
	 * Presave function. Gets called once before an object gets serialized for saving. This function is necessary
	 * for save time computation as Serialize gets called three times per object from within UObject::SavePackage.
	 * @warning: Objects created from within PreSave will NOT have PreSave called on them!!!
	 *
	 * This version of the function pushes the input meta object's inputs created back to the parent state's event array.
	 */
	virtual void PreSave();

	/**
	 * Called just before a property in this object's archetype is to be modified, prior to serializing this object into
	 * the archetype propagation archive.
	 *
	 * Allows objects to perform special cleanup or preparation before being serialized into an FArchetypePropagationArc
	 * against its archetype. Only called for instances of archetypes, where the archetype has the RF_ArchetypeObject flag.
	 *
	 * This version saves the data from the meta object into the owning state and removes the meta object from the SequenceObjects array.
	 */
	virtual void PreSerializeIntoPropagationArchive();

	/**
	 * Called just after a property in this object's archetype is modified, immediately after this object has been de-serialized
	 * from the archetype propagation archive.
	 *
	 * Allows objects to perform reinitialization specific to being de-serialized from an FArchetypePropagationArc and
	 * reinitialized against an archetype. Only called for instances of archetypes, where the archetype has the RF_ArchetypeObject flag.
	 *
	 * This version re-creates and re-initializes the meta object from the data in the owning state's list of input actions.
	 */
	virtual void PostSerializeFromPropagationArchive();
}

/**
 * Returns the UIState that created this UIStateSequence.
 */
native final function UIState GetOwnerState() const;

DefaultProperties
{

}
