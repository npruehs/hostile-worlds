/**
 * Provides a list of events that a widget can process.  The outer for a UIComp_Event MUST be a UIScreenObject.
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_Event extends UIComponent
	native(inherit);

/**
 * Events which should be implemented for this widget by default.  For example, a button should respond to
 * mouse clicks without requiring the designer to attach a UIEvent_ProcessClick event to every button.
 * To accomplish this, in the UIButton class's defaultproperties you would define a UIEvent_ButtonClick object
 * using a subobject definition, then add that event to the DefaultEvents array for the EventProvider of the UIButton class.
 * Since this property will almost always have values assigned in defaults (via the subobject definition for this object)
 * it isn't marked instanced (see the @note in the next comment).  Instead, these objects will be manually instanced when
 * a new widget is created.
 */
var					array<UIRoot.DefaultEventSpecification>			DefaultEvents;

/**
 * The sequence that contains the events implemented for this widget.
 *
 * @note: do not give this variable a default value, or each time a UIComp_Event object is loaded from disk,
 * StaticConstructObject (well, really InitProperties) will construct an object of this type that will be
 * immediately overwritten when the UIComp_Event object is serialized from disk.
 */
var					UISequence										EventContainer;

/**
 * The UIEvent responsible for routing input key events to kismet actions.  Created at runtime whenever input keys
 * are registered with the owning wiget.
 */
var	transient		UIEvent_ProcessInput							InputProcessor;

/** List of disabled UI event aliases that will not have their input subscribed. */
var						array<name>					DisabledEventAliases;

cpptext
{
	/**
	 * Returns the widget associated with this event provider.
	 */
	class UUIScreenObject* GetOwner() const;

	/**
	 * Called when the screen object that owns this UIComp_Event is created.  Creates the UISequence which will contain
	 * the events for this widget, instances any objects assigned to the DefaultEvents array and adds those instances
	 * to the sequence container.
	 */
	void Created();

	/**
	 * Determines which sequences should be instanced for the widget that owns this event component.  Note that this method
	 * does not care whether the sequences have ALREADY been instanced - it just determines whether a sequence should be instanced
	 * in the case where the corresponding sequence container has a NULL sequence.
	 *
	 * @param	out_EventsToInstance	will receive the list of indexes of the event templates which have linked ops, thus need to be instanced
	 *
	 * @return	TRUE if the global sequence for this component should be instanced.
	 */
	UBOOL ShouldInstanceSequence( TArray<INT>& out_EventsToInstance );

	/**
	 * Determines whether the specified event template should be instanced when this event component is initializing its sequence.
	 *
	 * @param	DefaultIndex	index into the DefaultEvents array for the event to check
	 *
	 * @return	returns TRUE if the event located at the specified index is valid for instancing; FALSE otherwise.
	 *			Note that this function does not care whether the event has ALREADY been instanced or not - just whether
	 *			it is valid to instance that event.
	 */
	UBOOL ShouldInstanceDefaultEvent( INT DefaultIndex );

	/**
	 * Creates the sequence for this event component
	 *
	 * @param	SequenceName	optionally specify the name for the sequence container....used by the T3D import code to
	 *							make sure that the new sequence can be resolved by other objects which reference it
	 *
	 * @return	a pointer to a new UISequence which has this component as its Outer
	 */
	class UUISequence* CreateEventContainer( FName SequenceName=NAME_None ) const;

	/**
	 * Initializes the sequence associated with this event component.  Assigns the parent sequence for the EventContainer
	 * to the UISequence associated with the widget that owns this component's owner widget.
	 *
	 * @param	bInitializeSequence		if TRUE, calls InitializeSequence on the sequence owned by this widget.  Should only
	 *									be TRUE in the game.
	 */
	void InitializeEventProvider( UBOOL bInitializeSequence=GIsGame );

	/**
	 * Cleans up any references to objects contained in other widgets.  Called when the owning widget is removed from the scene.
	 */
	void CleanupEventProvider();

	/**
	 * Adds the specified sub-sequence to the widget's list of nested sequences.
	 *
	 * @param	StateSequence	the sequence to add.  This should be a sequence owned by one of the UIStates in this
	 *							widget's InactiveStates array.
	 *
	 * @return	TRUE if the sequence was successfully added to [or if it already existed] the widget's sequence
	 */
	virtual UBOOL PushStateSequence( class UUIStateSequence* StateSequence );

	/**
	 * Removes the specified sub-sequence from the widget's list of nested sequences.
	 *
	 * @param	StateSequence	the sequence to remove.  This should be a sequence owned by one of the UIStates in this
	 *							widget's InactiveStates array.
	 *
	 * @return	TRUE if the sequence was successfully removed [or wasn't in the list] from the widget's sequence
	 */
	virtual UBOOL PopStateSequence( class UUIStateSequence* StateSequence );

protected:
	/**
	 * Creates a UIEvent_ProcessInput object for routing input events to actions.
	 */
	void CreateInputProcessor();

	/**
	 * Assigns the parent sequence for this widget's sequence to the sequence owned by this widget's parent, if necessary.
	 */
	void SetParentSequence();

	/**
	 * Creates instances for any newly attached actions, variables, etc. that were declared in the class defaultproperties which don't exist in the sequence.
	 *
	 * @param	StateInstanceMap	maps the DefaultStates array to the UIState instance of that class living in the owning widget's InactiveStates array
	 * @param	EventsToInstance	the indexes for the elements of the DefaultEvents array which should be instanced.
	 */
	void InstanceEventTemplates( TMap<UClass*,UUIState*>& StateInstanceMap, const TArray<INT>& EventsToInstance );

	/**
	 * Creates an UIEvent instance using the DefaultEvent template located at the index specified.
	 *
	 * @param	TargetContainer		the UIEventContainer that will contain the newly instanced ops
	 * @param	DefaultIndex	index into the DefaultEvents array for the template to use when creating the event
	 *
	 * @return	a pointer to the UIEvent instance that was creatd, or NULL if it couldn't be created for some reason
	 */
	UUIEvent* InstanceDefaultEvent( class IUIEventContainer* TargetContainer, INT DefaultIndex );

	/**
	 * Used for initializing sequence operations which have been instanced from event templates assigned to the
	 * DefaultEvents array.  Iterates through the op's input links, output links, and variable links, instancing
	 * any linked sequence objects which are contained within a class default object.
	 *
	 * @param	TargetContainer		the UIEventContainer that will contain the newly instanced ops
	 * @param	OpInstance			the SequenceOp to initialize.  This should either be a UIEvent created during
	 *								UUIComp_Event::Created() or some other sequence op referenced by an script-declared
	 */
	void InitializeInstancedOp( class IUIEventContainer* TargetContainer, class USequenceOp* OpInstance );

	/**
	 * Generates a list of UIEvent instances that have been previously created and added to either the widget's sequence
	 * or one of its states.
	 *
	 * @param	StateInstanceMap		map of UIState classes to the corresonding instance of that UIState from the owning widget's
	 *									InactiveStates array
	 * @param	out_ExistingEventMap	Will be filled with the list of previously instanced UIEvents, mapped to
	 *									their corresponding containers
	 */
	void GetInstancedEvents( TMap<UClass*,UUIState*>& StateInstanceMap, TMultiMap<IUIEventContainer*,UUIEvent*>& out_ExistingEventMap );

public:
	/** Fixup default event templates that were incorrectly instanced */
	virtual void PostLoad();
}

/**
 * Adds the input events for the specified state to the owning scene's InputEventSubscribers
 *
 * @param	InputEventOwner		the state that contains the input keys that should be registered with the scene
 * @param	PlayerIndex			the index of the player to register the input keys for
 */
native final function RegisterInputEvents( UIState InputEventOwner, int PlayerIndex );

/**
 * Removes the input events for the specified state from the owning scene's InputEventSubscribers
 *
 * @param	InputEventOwner		the state that contains the input keys that should be removed from the scene
 * @param	PlayerIndex			the index of the player to unregister input keys for
 */
native final function UnregisterInputEvents( UIState InputEventOwner, int PlayerIndex );

DefaultProperties
{
}
