/**
 * This class acts as a cosmetic container for grouping widgets in the UI editor.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UILayer extends UILayerBase
	native(Private);

cpptext
{
	/**
	 * Retrieves the list of child nodes for this UILayer.
	 *
	 * @param	out_ChildNodes	receives the list of children of this UILayerNode
	 * @param	bRecurse	if FALSE, will only add children of this UILayerNode; if TRUE, will add children of this UILayerNode,
	 *						along with the children of those nodes, recursively.
	 *
	 * @return	TRUE if this nodes were added to the out_ChildNodes array, FALSE otherwise.
	 */
	UBOOL GetChildNodes( TArray<struct FUILayerNode*>& out_ChildNodes, UBOOL bRecurse=FALSE );

	/**
	 * Returns the child layer node that contains the specified object as its layer object.
	 *
	 * @param	NodeObject	the child layer object to look for
	 * @param	bRecurse	if TRUE, searches all children of this object recursively
	 *
	 * @return	a pointer to a node contained by this object that has the specified object, or
	 *			NULL if no node with that specified object was found
	 */
	struct FUILayerNode* FindChild( class UObject* NodeObject, UBOOL bRecurse=FALSE );

	/**
	 * Find any child nodes with the specified name
	 *
	 * @param	NodeTitle	the name of the child to find
	 * @param	out_ChildNodes	receives the list of children
	 * @param	bRecurse	if TRUE, searches all children of this object recursively
	 *
	 * @return	number of children added to out_ChildNodes
	 */
	INT FindChildNodes( const FString& NodeTitle, TArray<struct FUILayerNode*>& out_ChildNodes, UBOOL bRecurse=FALSE );

	/**
	 * Returns whether this layer contains the specified child in its list of children.
	 *
	 * @param	NodeTitle	the name of the child layer to look for
	 * @param	bRecurse	if TRUE, searches all children of this object recursively
	 *
	 * @return	TRUE if the child layer is contained by this layer object
	 */
	UBOOL ContainsChild( const FString& NodeTitle, UBOOL bRecurse=FALSE );

	/* === UObject interface === */

	/**
	 * Prior to 06-28, UILayer objects used to have the RF_Standalone flag.  Clear the flag if it is still set on this UILayer.
	 */
	virtual void PostLoad();
}

/**
 * Represents a single node in the UI editor layer brower.
 */
struct native UILayerNode
{
	/**
	 * Indicates whether this layer node is active.  Locked layer nodes cannot be selected in the UI editor window
	 */
	var		const	private{private}	bool		bLocked;

	/**
	 * Indicates whether this layer node is visible.  Hidden layer nodes are not rendered in the UI editor window.
	 */
	var		const	private{private}	bool		bVisible;

	/**
	 * The object associated with this layer node.  Only UILayer and UIObject are valid.
	 */
	var		const	private{private}	Object		LayerObject;

	/**
	 * The UILayer that contains this layer node.
	 */
	var		const	private{private}	UILayer		ParentLayer;

structcpptext
{
	/** Default constructor - does not initialize values for members */
	FUILayerNode() {}

	/** Event constructor - used when passing this struct to an unrealscript event; zero initializes all members */
	FUILayerNode(EEventParm)
	{
		appMemzero(this,sizeof(FUILayerNode));
	}

	/** Standard constructors */
	FUILayerNode( class UUILayer* InLayer, class UUILayer* InParentLayer );
	FUILayerNode( class UUIObject* InWidget, class UUILayer* InParentLayer );

	/** Copy constructors */
	FUILayerNode( const struct FUILayerNode& Other )
	: bLocked(Other.bLocked), bVisible(Other.bVisible), LayerObject(Other.LayerObject), ParentLayer(Other.ParentLayer)
	{}

	/** Comparison operator */
	UBOOL operator==( const struct FUILayerNode& Other ) const
	{
		return bLocked		== Other.bLocked
			&& bVisible		== Other.bVisible
			&& LayerObject	== Other.LayerObject
			&& ParentLayer	== Other.ParentLayer;
	}
	UBOOL operator!=( const struct FUILayerNode& Other ) const
	{
		return bLocked		!= Other.bLocked
			|| bVisible		!= Other.bVisible
			|| LayerObject	!= Other.LayerObject
			|| ParentLayer	!= Other.ParentLayer;
	}

	/**
	 * Changes whether this layer node is locked.
	 */
	void SetLocked( UBOOL bLockLayer )
	{
		bLocked = bLockLayer;
	}

	/**
	 * Changes whether this layer node is visible.
	 */
	void SetVisible( UBOOL bShowLayer )
	{
		bVisible = bShowLayer;
	}

	/**
	 * Changes the object associated with this layer node.
	 *
	 * @param	InObject	the object to associate with this layer node; must be of type UIObject or UILayer
	 */
	UBOOL SetLayerObject( class UObject* InObject );

	/**
	 * Changes the UILayer that contains this layer node.
	 *
	 * @param	NewParent	the UILayer that now contains this layer node
	 */
	void SetLayerParent( class UUILayer* NewParent )
	{
		ParentLayer = NewParent;
	}

	/**
	 * Returns whether this layer node should be visible.
	 */
	UBOOL IsVisible() const
	{
		return bVisible;
	}

	/**
	 * Returns whether this layer node should be locked.
	 */
	UBOOL IsLocked() const
	{
		return bLocked;
	}

	/**
	 * Returns TRUE if the object associated with this layer node is of type UILayer.
	 */
	UBOOL IsUILayer() const;

	/**
	 * Returns TRUE if the object associated with this layer node is of type UIObject.
	 */
	UBOOL IsUIObject() const;

	/**
	 * Gets the object associated with this layer node, casted to a UILayer.
	 */
	class UUILayer* GetUILayer() const;

	/**
	 * Gets the object associated with this layer node, casted to a UIObject.
	 */
	class UUIObject* GetUIObject() const;

	/**
	 * Gets the object associated with this layer node.
	 */
	class UObject* GetLayerObject() const
	{
		return LayerObject;
	}

	/**
	 * Returns the UILayer that contains this layer node.
	 */
	class UUILayer* GetParentLayer() const
	{
		return ParentLayer;
	}
}

structdefaultproperties
{
	bVisible=true
}
};

/** The designer-specified friendly name for this layer */
var		string					LayerName;

/** the child nodes of this layer */
var		array<UILayerNode>		LayerNodes;

/**
 * Inserts the specified node at the specified location
 *
 * @param	NodeToInsert	the layer node that should be inserted into this UILayer's LayerNodes array
 * @param	InsertIndex		if specified, the index where the new node should be inserted into the LayerNodes array. if not specified
 *							the new node will be appended to the end of the array.
 *
 * @return	TRUE if the node was successfully inserted into this UILayer's list of child nodes.
 */
native final function bool InsertNode( const out UILayerNode NodeToInsert, optional int InsertIndex=INDEX_NONE );

/**
 * Removes the specified node
 *
 * @param	ExistingNode	the layer node that should be removed from this UILayer's LayerNodes array
 *
 * @return	TRUE if the node was successfully removed from this UILayer's list of child nodes.
 */
native final function bool RemoveNode( const out UILayerNode ExistingNode );

/**
 * Finds the index [into the LayerNodes array] for a child node that contains the specified object as its layer object.
 *
 * @param	NodeObject	the child layer object to look for.
 *
 * @return	the index into the LayerNodes array for the child node which contains the specified object as its layer object,
 *			or INDEX_NONE if no child nodes were found that containc the specified object as its layer object.
 */
native final function int FindNodeIndex( const Object NodeObject ) const;

DefaultProperties
{

}
