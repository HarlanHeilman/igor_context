#pragma rtGlobals=3		// Use modern global access method.
#pragma version=6.2		// shipped with Igor 6.2
#pragma IgorVersion=6.2	// for #pragma rtGlobals=3
#include <AppendImageToGizmo>
#include <GizmoTextures>, menus=0
#include <GizmoUtils>

// JP100511: Obsolete: Better routines are now in AppendImageToGizmo.ipf
// Removed <GizmoBottomImage> from All Gizmo Procedures.ipf as of Igor 6.2
// and replaced it with <AppendImageToGizmo>

Function WM_addGizmoBottomImage()	// This is the routine old Gizmo XOP called, left in place for compatibility.
	// WM_addGizmoBottomImageFromFile()	// Obsolete
	WMGizmoImagePanel()	// Show the Append/Modify Image Panel
End

Function WM_addGizmoBottomImageFromFile()

	String oldDF=GetDataFolder(1)
	try
		ImageLoad/z/Q/O
		if(V_flag==0)
			Abort
		endif
		Wave/Z imageWave=$StringFromList(0,S_waveNames)
		if(WaveExists(imageWave)==0)
			Abort
		endif
		
		if(DimSize(imageWave,2)!=3)
			doAlert 0, "RGB image required"
			KillWaves/Z imageWave
			Abort
		endif
		InterpolateForTexture(imageWave,NameOfWave(imageWave))	// overwrite
		Variable widthRows= DimSize(imageWave,0)
		Variable heightCols= DimSize(imageWave,1)

		ImageTransform/TEXT=9 imageToTexture imageWave
		Wave W_Texture
		String textureWaveName=UniqueName("W_Texture", 1, 0)
		Rename W_Texture,$textureWaveName
		WM_addTextureAtBottom("",W_Texture,widthRows,heightCols)
	catch
	
	endtry
	SetDataFolder oldDF
End

Function/S WM_addTextureAtBottom(gizmoName, textureWave, widthPixels, heightPixels)
	String gizmoName
	Wave textureWave					// texture wave made by ImageTransform/TEXT=9 imageToTexture
	Variable widthPixels, heightPixels	// texture dimensions
	
	 return WM_AddTextureAtZ(gizmoName, textureWave, widthPixels, heightPixels, 0, -1)
End

// Returns the names of the added texture and quad objects as a list: "texName;quadName;"
Function/S WM_addTextureAtZ(gizmoName, textureWave, widthPixels, heightPixels, doNearestNeighbor, vertexZ)
	String gizmoName
	Wave textureWave					// texture wave made by ImageTransform/TEXT=9 imageToTexture
	Variable widthPixels, heightPixels	// texture dimensions
	Variable doNearestNeighbor			// if true, use nearest neighbor for the texture instead of linear
	Variable vertexZ					// ortho range, -1 is the bottom of the central box, +1 is the top
	
	if( strlen(gizmoName) == 0 )
		gizmoName= TopGizmo()
	endif

	String textureWaveName=NameOfWave(textureWave)
	String cmd
	String texName = UniqueGizmoObjectName(gizmoName,"map_texture0","objectItemExists")
	
	sprintf cmd, "AppendToGizmo/N=%s texture=%s",gizmoName,texName
	Execute cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s property={ SRCWAVE,%s}",gizmoName,texName,textureWaveName
	Execute cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s property={ PRIORITY,1}",gizmoName,texName
	Execute cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ WIDTH,%d}",gizmoName,texName,widthPixels
	Execute cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ HEIGHT,%d}",gizmoName,texName,heightPixels
	Execute cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ SCoordinates,0.5,0,0,0.5}",gizmoName,texName
	Execute cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ TCoordinates,0,0.5,0,0.5}",gizmoName,texName	
	Execute cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ ENVMODE,8449}",gizmoName,texName
	Execute cmd
	
	if( doNearestNeighbor )
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ MAGMODE,9728}",gizmoName,texName
		Execute cmd
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ MINMODE,9728}",gizmoName,texName
		Execute cmd
	endif

	// quad = {v1x,v1y,v1z,v2x,v2y,v2z,v3x,v3y,v3z,v4x,v4y,v4z }
	String quadName= UniqueGizmoObjectName(gizmoName,"map_quad0","objectItemExists")
	sprintf cmd, "AppendToGizmo/N=%s quad={-1,-1,%g,-1,1,%g,1,1,%g,1,-1,%g},name=%s",gizmoName,vertexZ,vertexZ,vertexZ,vertexZ,quadName
	Execute cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s property={ textureType,1}",gizmoName,quadName
	Execute cmd
	sprintf cmd,"ModifyGizmo/N=%s modifyObject=%s property={ calcNormals,1}",gizmoName,quadName
	Execute cmd
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, object=%s",gizmoName,texName
	Execute cmd
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, object=%s",gizmoName,quadName
	Execute cmd

	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, opName=ClearTexture0, operation=ClearTexture",gizmoName
	Execute cmd
	
	return texName+";"+quadName+";"
End
