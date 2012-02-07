/**
 * Abstract base class for UI events.
 * A UIEvent is some event that a widget can respond to.  It could be an input event such as a button press, or a system
 * event such as receiving data from a remote system.  UIEvents are generally not bound to a particular type of widget;
 * programmers choose which events are available to widgets, and artists decide which events to implement.
 *
 * Features:
 *	Able to execute multiple actions when the event is called.
 *	Able to operate on multiple widgets simultaneously.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIEvent extends SequenceEvent
	native(UISequence)
	abstract
	placeable;

/**
 * An additional value to add to the result of GetObjClassVersion() for use in UIEvent subobject definitions.  This value
 * is intended only for use when overriding link arrays in subobjects, thus should never be set in defaultproperties.
 */
var	const		int				SubobjectVersionModifier;

/** the widget that contains this event */
var	noimport	UIScreenObject	EventOwner;

/** the object that initiated this event; specific to each event */
var				Object			EventActivator;

/** the name that is displayed for this event in the list of widget events in the editor */
// superceded by SequenceObject.ObjName
//var	localized	string			DisplayName;

/**
 * a short description of what this event does - displayed as a tooltip in the editor when the user hovers over this
 * event in the editor
 */
var	localized	string			Description;

/**
 * Indicates whether this event should be added to widget sequences.  Used for special-case handling of certain types
 * of events.
 */
var	bool						bShouldRegisterEvent;

/**
 * Indicates whether this activation of this event type should be propagated up the parent chain.
 */
var	bool						bPropagateEvent;

cpptext
{
	/** USequenceOp interface */
	/**
	 * Allows the operation to initialize the values for any VariableLinks that need to be filled prior to executing this
	 * op's logic.  This is a convenient hook for filling VariableLinks that aren't necessarily associated with an actual
	 * member variable of this op, or for VariableLinks that are used in the execution of this ops logic.
	 *
	 * Initializes the value of the "Activator", "Player Index", and "Gamepad Id" VariableLinks
	 */
	virtual void InitializeLinkedVariableValues();

	/** USequenceEvent inteface */
	virtual UBOOL RegisterEvent();

	/**
	 * This version of the DrawSeqObj function only draws the UIEvent if it is the UIEvent_MetaObject type.
	 */
	virtual void DrawSeqObj(FCanvas* Canvas, UBOOL bSelected, UBOOL bMouseOver, INT MouseOverConnType, INT MouseOverConnIndex, FLOAT MouseOverTime);

	/**
	 * Determines whether this UIAction can be activated.
	 *
	 * @param	ControllerIndex			the index of the player that activated this event
	 * @param	InEventOwner			the widget that contains this UIEvent
	 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents
	 * @param	bActivateImmediately	specify true to indicate that we'd like to know whether this event can be activated immediately
	 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
	 *									will be activated
	 */
	virtual UBOOL CanBeActivated( INT ControllerIndex, UUIScreenObject* InEventOwner, UObject* InEventActivator=NULL, UBOOL bActivateImmediately=FALSE, const TArray<INT>* IndicesToActivate=NULL );

	/**
	 * Activates this event if CanBeActivated returns TRUE.
	 *
	 * @param	ControllerIndex			the index of the player that activated this event
	 * @param	InEventOwner			the widget that contains this UIEvent
	 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents
	 * @param	bActivateImmediately	specify true to indicate that we'd like to know whether this event can be activated immediately
	 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
	 *									will be activated
	 *
	 * @return	TRUE if the event was activated successfully, FALSE if the event couldn't be activated.
	 */
	virtual UBOOL ConditionalActivateUIEvent( INT ControllerIndex, UUIScreenObject* InEventOwner, UObject* InEventActivator=NULL, UBOOL bActivateImmediately=FALSE, const TArray<INT>* IndicesToActivate=NULL );

	/**
	 * Activates this UIEvent, adding it the list of active sequence operations in the owning widget's EventProvider
	 *
	 * @param	ControllerIndex			the index of the player that activated this event
	 * @param	InEventOwner			the widget that contains this UIEvent
	 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents
	 * @param	bActivateImmediately	specify true to indicate that we'd like to know whether this event can be activated immediately
	 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
	 *									will be activated
	 *
	 * @return	TRUE if the event was activated successfully, FALSE if the event couldn't be activated.
	 */
	virtual UBOOL ActivateUIEvent( INT ControllerIndex, UUIScreenObject* InEventOwner, UObject* InEventActivator=NULL, UBOOL bActivateImmediately=FALSE, const TArray<INT>* IndicesToActivate=NULL );

	/** Get the name of the class used to help out when handling events in UnrealEd.
	 * @return	String name of the helper class.
	 */
	virtual const FString GetEdHelperClassName() const
	{
		return FString( TEXT("UnrealEd.UISequenceObjectHelper") );
	}

private:
	// hide these inherited methods from UIEvents
	virtual UBOOL CheckActivate(AActor *InOriginator, AActor *InInstigator, UBOOL bTest=FALSE, TArray<INT>* ActivateIndices = NULL, UBOOL bPushTop = FALSE) { check(0); return FALSE; }
	virtual void ActivateEvent(AActor *InOriginator, AActor *InInstigator, TArray<INT> *ActivateIndices = NULL, UBOOL bPushTop = FALSE, UBOOL bFromQueued = FALSE) { check(0); }
}


/* == Delegates == */
/**
 * Allows script-only child classes or other objects to include additional logic for determining whether this event is eligible for activation.
 *
 * @param	ControllerIndex			the index of the player that activated this event
 * @param	InEventOwner			the widget that owns this UIEvent
 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents;  typically the widget
 *									that triggered the event activation.
 * @param	bActivateImmediately	TRUE if the caller wishes to perform immediate activation.
 * @param	IndicesToActivate		indexes of the elements [into the Output array] that are going to be activated.  If empty,
 *									all output links will be activated
 *
 * @return	TRUE if this event can be activated
 */
delegate bool AllowEventActivation( int ControllerIndex, UIScreenObject InEventOwner, Object InEventActivator, bool bActivateImmediately, out const array<int> IndicesToActivate );

/* == Natives == */
/**
 * Returns the widget that contains this UIEvent.
 */
native final function UIScreenObject GetOwner() const;

/**
 * Returns the scene that contains this UIEvent.
 */
native final function UIScene GetOwnerScene() const;

/**
 * Determines whether this UIAction can be activated.
 *
 * @param	ControllerIndex			the index of the player that activated this event
 * @param	InEventOwner			the widget that contains this UIEvent
 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents
 * @param	bActivateImmediately	specify true to indicate that we'd like to know whether this event can be activated immediately
 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
 *									will be activated
 *
 * @return	TRUE if this event can be activated
 *
 * @note: noexport so that the native function header can take a TArray<INT> pointer as the last parameter
 */
native final noexport function bool CanBeActivated( int ControllerIndex, UIScreenObject InEventOwner, optional Object InEventActivator, optional bool bActivateImmediately, optional out const array<int> IndicesToActivate );

/**
 * Activates this event if CanBeActivated returns TRUE.
 *
 * @param	ControllerIndex			the index of the player that activated this event
 * @param	InEventOwner			the widget that contains this UIEvent
 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents
 * @param	bActivateImmediately	if TRUE, the event will be activated immediately, rather than deferring activation until the next tick
 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
 *									will be activated
 *
 * @return	TRUE if this event was successfully activated
 *
 * @note: noexport so that the native function header can take a TArray<INT> pointer as the last parameter
 */
native final noexport function bool ConditionalActivateUIEvent( int ControllerIndex, UIScreenObject InEventOwner, optional Object InEventActivator, optional bool bActivateImmediately, optional out const array<int> IndicesToActivate );

/**
 * Activates this UIEvent, adding it the list of active sequence operations in the owning widget's EventProvider
 *
 * @param	ControllerIndex			the index of the player that activated this event
 * @param	InEventOwner			the widget that contains this UIEvent
 * @param	InEventActivator		an optional object that can be used for various purposes in UIEvents
 * @param	bActivateImmediately	if TRUE, the event will be activated immediately, rather than deferring activation until the next tick
 * @param	IndicesToActivate		Indexes into this UIEvent's Output array to activate.  If not specified, all output links
 *									will be activated
 *
 * @return	TRUE if this event was successfully activated
 *
 * @note: noexport so that the native function header can take a TArray<INT> pointer as the last parameter
 */
native final noexport function bool ActivateUIEvent( int ControllerIndex, UIScreenObject InEventOwner, optional Object InEventActivator, optional bool bActivateImmediately, optional out const array<int> IndicesToActivate );

/* == Events == */
/**
 * Determines whether this class should be displayed in the list of available ops in the level kismet editor.
 *
 * @return	TRUE if this sequence object should be available for use in the level kismet editor
 */
event bool IsValidLevelSequenceObject()
{
	return false;
}

/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	return true;
}

/**
 * Allows events to override the default behavior of not instancing event templates during the game (@see UIComp_Event::InstanceEventTemplates); by default, events templates
 * declared in widget defaultproperties are only instanced if the template definition contains linked ops.  If your event class performs some other actions which affect the game
 * when it's activated, you can use this function to force the UI to instance this event for widgets created at runtime in the game.
 *
 * @return	return TRUE to force the UI to always instance event templates of this event type, even if there are no linked ops.
 */
event bool ShouldAlwaysInstance()
{
	return false;
}

/* == UnrealScript == */

/**
 * Return the version number for this class.  Child classes should increment this method by calling Super then adding
 * a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
 * link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
 * Super.GetObjClassVersion() should be incremented by 1.
 *
 * @return	the version number for this specific class.
 */
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + default.SubobjectVersionModifier + 2;
}

DefaultProperties
{
	ObjCategory="UI"
	MaxTriggerCount=0
	bShouldRegisterEvent=true
	bClientSideOnly=true

	bPropagateEvent=true

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Activator",bWriteable=true)

	// the index for the player that activated this event
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Player Index",PropertyName=PlayerIndex,bWriteable=true,bHidden=true)

	// the gamepad id for the player that activated this event
	VariableLinks.Add((ExpectedType=class'SeqVar_Int',LinkDesc="Gamepad Id",PropertyName=GamepadID,bWriteable=true,bHidden=true))
}
