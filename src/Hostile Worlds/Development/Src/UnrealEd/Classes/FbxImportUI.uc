/**
 * Copyright 2010 Autodesk, Inc. All Rights Reserved.
 * 
 * Fbx Importer UI options.
 */

class FbxImportUI extends Object
	native
	config(EditorUserSettings)
	AutoExpandCategories( General, SkeletalMesh, StaticMesh, Materials)
	DontSortCategories( General, SkeletalMesh, StaticMesh, Materials)
	HideCategories(Object);

/** Import mesh type */
enum EFBXImportType
{
	/** Static mesh */
	FBXIT_StaticMesh<DisplayName=Static Mesh>,

	/** Skeletal mesh */
	FBXIT_SkeletalMesh<DisplayName=Skeletal Mesh>,
};


/** Type of asset to import from the FBX file */
var(General) EFBXImportType MeshTypeToImport<DisplayName=Import Type>;

/** Use the string in "Name" field as full name of mesh. The option only works when the scene contains one mesh. */
var(General) config bool bOverrideFullName;

/** Enable this to strip namespace prefixes from imported assets */
var(General) config bool bRemoveNamespaces;

/** Enables importing of mesh LODs from FBX LOD groups, if present in the FBX file */
var(General) config bool bImportMeshLODs;

/** Override the normals/tangents data if the mesh has any. */
var(General) config bool bOverrideTangents<DisplayName=Override Tangents>;

/** True to import morph target meshes from the FBX file */
var(SkeletalMesh) config bool bImportMorphTargets;

/** True to import animations from the FBX File */
var(SkeletalMesh) config bool bImportAnimations;

/** Enables importing of 'rigid animation' (unskinned, hierarchy-based animation) from this FBX file */
var(SkeletalMesh) config bool bImportRigidAnimation<EditCondition=bImportAnimations>;

/** Enable this option to resample imported animation at 30 frames per second */
var(SkeletalMesh) config bool bResampleAnimations<EditCondition=bImportAnimations>;

/** For static meshes, enabling this option will combine all meshes in the FBX into a single monolithic mesh in Unreal */
var(StaticMesh) config bool bCombineMeshes;

/** For static meshes, enabling this option will read normals from the FBX file instead of calculating them. */
var(StaticMesh) config bool bExplicitNormals;

/** Whether to automatically create Unreal materials for materials found in the FBX scene */ 
var(Materials) config bool bImportMaterials;

/** The option works only when option "Import Material" is OFF. If "Import Material" is ON, textures are always imported. */
var(Materials) config bool bImportTextures;

/** If either importing of textures (or materials) is enabled, this option will cause normal map values to be inverted */
var(Materials) config bool bInvertNormalMaps;

/** If enabled, materials and textures will be imported into sub-groups named "Materials" or "Textures" */
var(Materials) config bool bAutoCreateGroups<DisplayName=Create Groups Automatically>;

