// ============================================================================
// HWSeqAct_ChangeOwner
// A Hostile Worlds sequence action that hands the linked units over to the
// team with the specified index.
//
// Author:  Nick Pruehs
// Date:    2011/03/20
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSeqAct_ChangeOwner extends HWSequenceAction;

/** The units to change the owner of. */
var() array<Object> Units;

/** The index of the team the units should belong to. */
var() int NewTeamIndex;


event Activated()
{
	local Object o;
	local HWSelectable Unit;

	foreach Units(o)
	{
		Unit = HWSelectable(o);

		if (Unit != none)
		{
			Unit.ChangeOwner(NewTeamIndex);
		}
		else
		{
			`log("(KISMET) "$self$" has been linked to target object "$o$" which is not a Hostile Worlds unit!");
		}
	}
	
	super.Activated();
}


DefaultProperties
{
	ObjName="Unit - Change Owner"

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Units",PropertyName=Units)
}
