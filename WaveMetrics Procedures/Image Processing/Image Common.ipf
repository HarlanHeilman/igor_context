#pragma rtGlobals=2		// Use modern global access method.
//#include <Keyword-Value>	// OBSOLETE even if we don't use it here, other files do
#pragma version=6.13			// shipped with Igor 6.13
#include <Autosize Images>
#include <Graph Utility Procs>, version>=6.1	// for WMGetRECREATIONFromInfo
#include <ImageTransformPanel>
 
// 14JAN05 moved WM_GetDisplayed3DPlane here from Image Line Profile.

// This routine returns a full path to an auxillary data folder associated with the
// given wave. The data folder is created if necessary and resides at the same level
// as the given wave. The name is derived from the wave by appending _WMUF.
// A zero length string is returned if failure.
//
Function/S WMGetWaveAuxDF(w)
	Wave/Z w
	
	if( !WaveExists(w) )
		return ""
	endif
	String ds= NameOfWave(w)+"_WMUF"
	if( strlen(ds)>31 )
		DoAlert 1, "name of image wave is too long to append needed suffex"
		return ""
	endif
	String dfSav= GetDataFolder(1)
	String s= GetWavesDataFolder(w,1)		// full path to wave's df
	SetDataFolder s
	NewDataFolder/O/S $ds
	s= GetDataFolder(1)
	SetDataFolder dfSav
	return s
end

// same as above but does not create the data folder
Function/S WMGetWaveAuxDFPath(w)
	Wave/Z w
	
	if( !WaveExists(w) )
		return ""
	endif
	String ds= NameOfWave(w)+"_WMUF"
	if( strlen(ds)>31 )
		DoAlert 1, "name of image wave is too long to append needed suffex"
		return ""
	endif
	return GetWavesDataFolder(w,1)+PossiblyQuotename(ds)+":"
end



// This routine is used to fetch a full path to the image wave in the top
// graph. A zero length string is returned if failure.
//
Function/S WMGetImageWave(grfName)
	String grfName							// use zero len str to speicfy top graph

	String s= ImageNameList(grfName, ";")
	Variable p1= StrSearch(s,";",0)
	if( p1<0 )
		return ""			// no image in top graph
	endif
	s= s[0,p1-1]
	Wave w= ImageNameToWaveRef(grfName, s)
	return GetWavesDataFolder(w,2)		// full path to wave including name
end

// This routine fetches the name of the top graph containing an image
Function/S WMTopImageGraph()

	String grfName
	Variable i=0
	do
		grfName= WinName(i, 1)
		if( strlen(grfName) == 0 )
			break
		endif
		if( strlen( ImageNameList(grfName, ";")) != 0 )
			break
		endif
		i += 1
	while(1)
	return grfName
end		

// This routine returns the name of the top image in the top graph
Function/S WMTopImageName()

	String grfName
	Variable i=0
	do
		grfName= WinName(i, 1)
		if( strlen(grfName) == 0 )
			break
		endif
		String list=ImageNameList(grfName, ";")
		if( strlen( list) != 0 )
			return StringFromList(0,list,";")
			break
		endif
		i += 1
	while(1)
	return ""
end		

// Gets image z-scaling from specified image graph.
// returns zmin, zmax as single complex number. Uses NaN to mean autoscale
Function/C WMReadImageRange(grfname,imagew)
	String grfname
	Wave imagew
	
	Variable zmin, zmax
	
	String s= ImageInfo(grfname, NameOfWave(imagew), 0)
	Variable v1= StrSearch(s,"ctab= {",0)
	v1 += strlen("ctab= {")
	Variable v2= StrSearch(s,",",v1)
	zmin= str2num(s[v1,v2-1])			// will be NaN if autoscale char: *
	v1= v2+1
	v2= StrSearch(s,",",v1)
	zmax= str2num(s[v1,v2-1])
	return cmplx(zmin,zmax)
end

// This routine makes backups of the data in the same data folder as
// the source wave. If a wave of the same name but with the suffex _Back
// does NOT exist then the source is duplicated as such a name. This wave
// is used for the restore button.
// The source wave is always duplicated as a wave with the suffex _UnDo
// which is used by the Undo button.
//
Function WMSaveWaveBackups(w)
	Wave w

	String s= GetWavesDataFolder(w,1)
	String dfSav= GetDataFolder(1)
	SetDataFolder s
	String bakName= NameOfWave(w)+"_Back"
	if( exists(bakName) != 1 )
		Duplicate/O w,$bakName
	endif
	Duplicate/O w,$(NameOfWave(w)+"_UnDo")
	SetDataFolder dfSav
end

// This routine restores wave w from backups that have been saved using WMSaveWaveBackups
// It can also delete the backups depending on kind:
// use -1 to kill backups, use 0 to restore from _UnDo, 1 to restore from _Back
// Returns 0 if success, 1 if backups did not exist and tried restore or undo
// When doing a restore the current data is stored in _UnDo so you can undo a restore
//
Function WMRestoreWaveBackups(w,kind)
	Wave/Z w
	Variable kind
	
	if( !WaveExists(w) )
		return 2	// should never happen
	endif

	variable fail= 1

	String s= GetWavesDataFolder(w,1)
	String dfSav= GetDataFolder(1)
	SetDataFolder s

	String bakName= NameOfWave(w)+"_Back"
	String undoName= NameOfWave(w)+"_UnDo"

	do
		if( kind == -1 )
			KillWaves/Z $bakName,$undoName		// don't care if they existed or not
			fail= 0
			break
		endif
		if( kind == 0 )
			if( exists(undoName) == 1 )
				NewDataFolder rwtmp	// tmp wave may or may not be created here
				Duplicate/O $undoName,:rwtmp:tmpw
				Duplicate/O w,$undoName
				Duplicate/O :rwtmp:tmpw,w
				KillDataFolder rwtmp
				fail= 0
			endif
		else // must be 1
			if( exists(bakName) == 1 )
				Duplicate/O w,$undoName
				Duplicate/O $bakName,w
				fail= 0
			endif
		endif
	while(0)
	SetDataFolder dfSav
	return fail
end

Function WMWithin(a,b,c)
	variable a,b,c
	
	if( a < b )
		return 0
	endif
	if( a > c )
		return 0
	endif
	return 1
end


// a button proc used in several procedure files
Function WMImageBPUndo(ctrlName) : ButtonControl
	String ctrlName

	String pw= WMGetImageWave(WMTopImageGraph())
	Wave/Z w= $pw
	if( !WaveExists(w) )
		beep
		return 0
	endif

	variable fail= 1
	do
		if( CmpStr(ctrlName,"buttonUndo") == 0 )
			fail= WMRestoreWaveBackups(w,0)
			break
		endif
		if( CmpStr(ctrlName,"buttonRestore") == 0 )
			fail=WMRestoreWaveBackups(w,1)
			break
		endif
		
		//
		// NOTE: this is no longer used. It is still here just in case..
		//
		if( CmpStr(ctrlName,"buttonDone") == 0 )
			fail= 0
			DoAlert 2,"Delete backups?"
			if( V_FLag == 3 )								// cancel button
				break;
			endif
			if( V_FLag == 1 )
				WMRestoreWaveBackups(w,-1)
			endif
			DoWindow/K $WinName(0, 64)				// this be us
			KillDataFolder root:Packages:WMImProcess:
			break
		endif
	while(0)
	if( fail )
		Print "no backup waves found"
		beep
	endif
End

// assumes curMat is displayed as an image in the graph specified by winName
// newMat is appended using the same axes. Does not honor x or y waves or
// multiple instances.
// Brings graph to the front. In future, when /W=win is supported, rewrite to avoid this effect.
Function WMImageAppendOverlay(winName,curMat,newMat)
	String winName
	Wave curMat,newMat
	
	DoWindow/F $winName
	if( V_Flag==0 )
		Abort "No graph named "+winName
	endif
	
	String info=ImageInfo("",NameOfWave(curMat),0)
	if( strlen(info)==0 )
		Abort "No image named "+NameOfWave(curMat)
	endif
	
	Execute "AppendImage"+StringByKey("AXISFLAGS",info)+" "+GetWavesDataFolder(newMat,2)
end
	
// assumes curMat is displayed as an image in the graph specified by winName
// Creates a clone of the graph but using newMat rather than curMat
// Does not honor x or y waves or multiple instances.
Function WMCloneImage(winName,curMat,newMat)
	String winName
	Wave curMat,newMat
	
	String info=ImageInfo(winName,NameOfWave(curMat),0)
	if( strlen(info)==0 )
		Abort "No image named "+NameOfWave(curMat)
	endif
	String modInfo= WMGetRECREATIONFromInfo(info)
	String winStyle= WinRecreation(winName,1)
	
	Execute "Display;AppendImage"+StringByKey("AXISFLAGS",info)+" "+GetWavesDataFolder(newMat,2)
	if( strlen(modInfo) )
		// 03DEC09  cleanup the recreation part so that it can be used in a command.
		modInfo=RemoveEnding(ReplaceString(";", modInfo, ","),",")
		Execute "ModifyImage "+PossiblyQuoteName(NameOfWave(newMat))+" "+modInfo
	endif
	ApplyStyleMacro(winStyle)
	
	DoAutoSizeImage(0,-1)			// -1 for flip vert flag new. Means don't change current setting.
end
	

Function WMDupTopImage()
	String ImGrfName= WMTopImageGraph()
	Wave/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif
	String dfSav= GetDataFolder(1)
	SetDataFolder $GetWavesDataFolder(w,1)
	String newWName= UniqueName(NameOfWave(w)+"Copy",1,1)
	Duplicate/O w,$newWName

	WMCloneImage(ImGrfName,w,$newWName)
	SetDataFolder dfSav
end

// the following function is used to determine if the top image has more than one plane.  If
// so it puts an alert suggesting that the user convert the image to grayscale or pick up a single
// plane
Function isColorImage()

	String pw= WMGetImageWave(WMTopImageGraph())
	Wave/Z w= $pw
	if( !WaveExists(w) )
		return 1
	else
		if(DimSize(w,2)>0)
			doAlert 2, "The operation selected works with 2D gray-scale images.  The top image appears to have more than one plane.  Use ImageTransform to convert the wave before proceeding. \rDo you want to transform the image?"
			
			if(V_Flag==1)
				ImageTransformPanel()
			endif
			return 1
		endif
		
		return 0				// normal gray scale image
	endif
End

// the following function returns 1 if the wave is valid and contains 3 planes.
Function isColorWave(ww)
	Wave/Z ww
	
	if(WaveExists(ww)==0)
		return 0
	endif
	
	if(DimSize(ww,2)==3)
		return 1
	endif
	return 0;
End

// the following returns the plane number displayed in 3D (or 4D) image as in 
// ModifyImage imageName plane=xyz
Function WM_GetTopDisplayed3DPlane()

	String iNameList= ImageNameList("", ";")
	String imageName=StringFromList(0,iNameList,";")
	String sss=imageinfo("",imageName,0)
	return numberbykey("plane",sss,"=")
End

//*******************************************************************************************************
// 09JAN03
// Given a name of an image e.g., "graph0", the following function returns the plane displayed in the
// graph.  If the image is a 2D image or if the image is an RGB image, the function returns 0.
Function WM_GetDisplayed3DPlane(graphName)
	String graphName
	
	Wave w=$WMGetImageWave(graphName)
	String info=ImageInfo(graphName,NameOfWave(imageWaveName),0)
	String sub=info[strSearch(info,"plane",0),strlen(info)]
	
	return NumberByKey("plane", sub, "=")
End

//*******************************************************************************************************