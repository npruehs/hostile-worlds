/**
 * Specialization type of sequence used to store the events associated with a single widget.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UISequence extends Sequence
	native(UISequence)
	implements(UIEventContainer);

cpptext
{
	/** UISequence interface */
	/**
	 * Adds a new sequence to this sequence's NestedSequences array, calling Modify() on this sequence.
	 *
	 * @param	NewNestedSequence	the sequence to add to the NestedSequence array
	 *
	 * @return	TRUE if the new sequence was successfully added to the NestedSequences list, or if was already in that list.
	 */
	virtual UBOOL AddNestedSequence( USequence* NewNestedSequence );

	/**
	 * Removes the specified sequence from this sequences list of NestedSequences
	 *
	 * @param	SequenceToRemove	the sequence to remove
	 *
	 * @return	TRUE if the sequence was successfully removed from the NestedSequences list, or if it didn't exist in the list.
	 */
	virtual UBOOL RemoveNestedSequence( USequence* SequenceToRemove );

	/**
	 * Determines whether this sequence contains any ops that can execute logic during the game.  Called when this sequence is saved
	 * to determine whether it should be marked to be loaded in the game.  Marks any ops which aren't linked to other ops so that they
	 * aren't loaded in the game.
	 *
	 * @return	returns TRUE if this sequence contains ops that execute logic, thus needs to be loaded in the game.
	 */
	UBOOL CalculateSequenceLoadFlags();

private:
	/**
	 * Determines whether this non-standalone object is referenced by a stand-alone sequnce object; if the object is not rooted, it will be marked
	 * with the RF_NotForClient|RF_NotForServer|RF_Marked object flags.
	 *
	 * @param	SeqObj	the sequence object to check
	 *
	 * @return	TRUE if SeqObj is a stand-alone sequence object or is referenced [directly or indirectly] by a standalone sequence object
	 */
	UBOOL IsSequenceObjectRooted( USequenceObject* SeqObj );

public:

	/* === USequence interface === */
	/**
	 * Initialize this kismet sequence.
	 *  - Adds all UIEvents to the UIEvents list.
	 */
	virtual void InitializeSequence();

	/**
	 * Conditionally creates the log file for this sequence.
	 */
	virtual void CreateKismetLog();

	/**
	 * Adds a new SequenceObject to this containers's list of ops.
	 *
	 * @param	NewObj		the sequence object to add.
	 * @param	bRecurse	if TRUE, recursively add any sequence objects attached to this one
	 *
	 * @return	TRUE if the object was successfully added to the sequence.
	 *
	 * @note: this implementation is necessary to fulfill the UIEventContainer interface contract
	 */
	virtual UBOOL AddSequenceObject( USequenceObject* NewObj, UBOOL bRecurse=FALSE );

	/**
	 * Removes the specified object from the SequenceObjects array, severing any links to that object.
	 *
	 * @param	ObjectToRemove	the SequenceObject to remove from this sequence.  All links to the object will be cleared.
	 * @param	ModifiedObjects	a list of objects that have been modified the objects that have been
	 */
	virtual void RemoveObject( USequenceObject* ObjectToRemove );

	/* === USequenceOp interface === */
	/**
	 * Since UISequences can only be activated as a result of opening a new scene, override USequence's implementation
	 */
	virtual void Activated() {}

	/* === USequenceObject interface === */
	/**
	 * Returns whether the specified SequenceObject can exist in this sequence without being linked to anything else (i.e. does not require
	 * another sequence object to activate it).
	 *
	 * @param	SeqObj	the sequence object to check
	 *
	 * @return	TRUE if the sequecne object does not require a separate "stand-alone" sequence object to reference it, in order to be loaded in game.
	 */
	virtual UBOOL IsObjectStandalone( USequenceObject* SeqObj ) const;

	/** Get the name of the class used to help out when handling events in UnrealEd.
	 * @return	String name of the helper class.
	 */
	virtual const FString GetEdHelperClassName() const
	{
		return FString( TEXT("UnrealEd.UISequenceHelper") );
	}

	/* === UObject interface === */
	/**
	 * This version removes the RF_Public flag if it exists on a non-prefab sequence.
	 */
	virtual void PostLoad();

	/**
	 * Called after importing property values for this object (paste, duplicate or .t3d import)
	 * Allow the object to perform any cleanup for properties which shouldn't be duplicated or
	 * are unsupported by the script serialization.
	 *
	 * This version clears the value of ParentSequence since we want this to be set when the owning widget that was just
	 * pasted is initialized.
	 */
	virtual void PostEditImport();

	/**
	 * Determines whether this object is contained within a UPrefab.
	 *
	 * @param	OwnerPrefab		if specified, receives a pointer to the owning prefab.
	 *
	 * @return	TRUE if this object is contained within a UPrefab; FALSE if it IS a UPrefab or isn't contained within one.
	 */
	virtual UBOOL IsAPrefabArchetype( class UObject** OwnerPrefab=NULL ) const;

	/**
	 * @return	TRUE if the object is contained within a UIPrefabInstance.
	 */
	virtual UBOOL IsInPrefabInstance() const;
}

/**
 * List of UIEvent objects contained by this UISequence.
 */
var	private{private}	const	transient	noimport	init	array<UIEvent>	UIEvents;

/**
 * Return the UIScreenObject that owns this sequence.
 */
native final function UIScreenObject GetOwner() const;

/* == UIEventContainer interface == */
/**
 * Retrieves the UIEvents contained by this container.
 *
 * @param	out_Events	will be filled with the UIEvent instances stored in by this container
 * @param	LimitClass	if specified, only events of the specified class (or child class) will be added to the array
 */
native final function GetUIEvents( out array<UIEvent> out_Events, optional class<UIEvent> LimitClass );

/**
 * Adds a new SequenceObject to this containers's list of ops
 *
 * @param	NewObj		the sequence object to add.
 * @param	bRecurse	if TRUE, recursively add any sequence objects attached to this one
 *
 * @return	TRUE if the object was successfully added to the sequence.
 */
native final noexport function bool AddSequenceObject( SequenceObject NewObj, optional bool bRecurse );

/**
 * Removes the specified SequenceObject from this container's list of ops.
 *
 * @param	ObjectToRemove	the sequence object to remove
 */
native final function RemoveSequenceObject( SequenceObject ObjectToRemove );

/**
 * Removes the specified SequenceObjects from this container's list of ops.
 *
 * @param	ObjectsToRemove		the objects to remove from this sequence
 */
native final function RemoveSequenceObjects( const out array<SequenceObject> ObjectsToRemove );

DefaultProperties
{
	ObjName="Widget Events"

	ObjPosX=904
	ObjPosY=64
}
