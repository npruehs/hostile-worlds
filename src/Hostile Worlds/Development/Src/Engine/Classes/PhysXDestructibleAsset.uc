/*=============================================================================
	PhysXDestructibleAsset.uc: Destructible Vertical Component.
	Copyright 2007-2008 AGEIA Technologies.
=============================================================================*/

class PhysXDestructibleAsset extends Object
	native(Mesh);

struct native PhysXDestructibleAssetChunk
{
	var int		Index;
	var int		FragmentIndex;
	var float	Volume;
	var float	Size;
	var int		Depth;
	var int		ParentIndex;
	var int		FirstChildIndex;
	var int		NumChildren;
	var int		MeshIndex;
	var int		BoneIndex;
	var name	BoneName;
	var int		BodyIndex;
};

/* Breadth first chunk tree hierarchy. */
var					Array<PhysXDestructibleAssetChunk>	ChunkTree;

/* Skeletal Meshes used to hold the pieces. */
var()	const 		Array<SkeletalMesh>					Meshes;

/* Corresponding Physics Assets for the meshes. */
var()	const		Array<PhysicsAsset>					Assets;

/* Deepest chunk level */
var()	const		int									MaxDepth;

cpptext
{
	void ComputeChunkSurfaceAreaAndVolume( INT ChunkIndex, FLOAT & Area, FLOAT & Volume ) const;
}
