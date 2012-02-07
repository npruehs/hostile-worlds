
class UDKWeaponPawn extends UDKVehicleBase
	native
	nativereplication
	notplaceable;

/** MyVehicle points to the vehicle that houses this WeaponPawn and is replicated */
var repnotify UDKVehicle MyVehicle;

/** MyVehicleWeapon points to the weapon associated with this WeaponPawn and is replicated */
var repnotify UDKWeapon MyVehicleWeapon;

/** An index in to the Seats array of the vehicle housing this WeaponPawn.  It is replicated */
var repnotify int MySeatIndex;

replication
{
	if (Role == ROLE_Authority)
		MySeatIndex, MyVehicle, MyVehicleWeapon;
}

cpptext
{
	virtual void TickSpecial( FLOAT DeltaSeconds );
	virtual AVehicle* GetVehicleBase();
	INT* GetOptimizedRepList(BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel);
}

/**
 * @param RequestedBy - the Actor requesting the target location
 * @param bRequestAlternateLoc (optional) - return a secondary target location if there are multiple
 * @return the optimal location to fire weapons at this actor
 */
simulated native function vector GetTargetLocation(optional Actor RequestedBy, optional bool bRequestAlternateLoc) const;

