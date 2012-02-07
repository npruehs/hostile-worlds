/** only allows polys that contain cover from the specified CoverLink */
class NavMeshPath_SameCoverLink extends NavMeshPathConstraint
	native(AI);

cpptext
{
	virtual UBOOL EvaluatePath( FNavMeshEdgeBase* Edge, FNavMeshPolyBase* SrcPoly, FNavMeshPolyBase* DestPoly,
					const FNavMeshPathParams& PathParams, INT& out_PathCost, INT& out_HeuristicCost )
	{
		for (INT i = 0; i < DestPoly->PolyCover.Num(); i++)
		{
			if (*DestPoly->PolyCover(i) == TestLink)
			{
				return TRUE;
			}
		}

		return FALSE;
	}
}

var CoverLink TestLink;

static final function SameCoverLink(NavigationHandle NavHandle, CoverLink InLink)
{
	local NavMeshPath_SameCoverLink NewConstraint;

	NewConstraint = NavMeshPath_SameCoverLink(NavHandle.CreatePathConstraint(default.class));
	NewConstraint.TestLink = InLink;
	NavHandle.AddPathConstraint(NewConstraint);
}

function Recycle()
{
	Super.Recycle();
	TestLink = None;
}
