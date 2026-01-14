#pragma rtGlobals=2		// Use modern global access method.
#include <Image Common>
 
// Image Contrast Package
// Version 0.90, LH971209
// Supports only Gray scale (or false color) images
// TO DO: Add log and exp, user supplied (not drawn),documentation
// Problem: Undo button also does redo which is confusing.
//
// Create user interface window by calling the following from a button or a menu:
// WMCreateImageContrastGraph()
// AG20MAY03 
// changed button name so it is more intuitive.
// added /W to controlInfo.

Function WMCreateImageContrastGraph()

	if(isColorImage())
		return 0;
	endif
	DoWindow/F WMContrastAdjustGraph
	if( V_Flag==1 )
		return 0
	endif

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMImProcess
	NewDataFolder/O root:Packages:WMImProcess:ImageContrast
	
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:ImageContrast

	String/G ImGrfName= WMTopImageGraph()
	if( NumVarOrDefault("inited",0) == 0 )
		Variable/G inited=1
		Variable/G gamma= 1
		Variable/G levels= 5	// both posterize and ramp
		Make/O contY= {0,1}, contX={0,1}
		Make/O userY={0,0.5,1}, userX={0,0.5,1}
	endif
	
	SetDataFolder dfSav
	
	Wave w= $WMGetImageWave(ImGrfName)
	
	Wave/Z wclu= $WMGenImageContrastLUW(ImGrfName)
	if( !WaveExists(wclu) )
		Abort "No Image graph found"
		return 0
	endif
	WMImageContrastAdjustGraph(wclu)

	AutoPositionWindow/E/M=1/R=$ImGrfName
	
	return 0;
end

// Generate if necessary and return path to a contrast lookup wave
// Name is same as image wave but with _CLU suffex. Created in same DF
// as source and is initially 1 to 1
Function/S WMGenImageContrastLUW(ImGrfName)
	String ImGrfName
	
	Wave/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return ""
	endif
	
	String wn= NameOfWave(w)+"_CLU"
	String pu= GetWavesDataFolder(w, 1)
	String dfSav= GetDataFolder(1)
	SetDataFolder pu
	if( !WaveExists($wn) )			// first visit this wave?
		Make/N=1000 $wn
		Wave wclu= $wn
		SetScale x,0,1,wclu
		wclu=x
	endif
	Wave wclu= $wn
	SetDataFolder dfSav
	
	return GetWavesDataFolder(wclu,2)		// full path to wave including name
end


Function WMImageContrastUpdateProc()
	String newImGrfName= WMTopImageGraph()
	SVAR ImGrfName= root:Packages:WMImProcess:ImageContrast:ImGrfName
		
	Wave/Z wclu= $WMGenImageContrastLUW(newImGrfName)
	if( !WaveExists(wclu) )
//		beep
		return 0
	endif
	if( CmpStr(newImGrfName,ImGrfName)!= 0 )
		ReplaceWave trace=$NameOfWave(WaveRefIndexed("", 0, 1)),wclu
	endif
	ImGrfName= newImGrfName
	WMUpdateContrastFctn("")
end

Function WMImageContrastWindowProc(infoStr)
	String infoStr
	
	if( StrSearch(infoStr,"EVENT:activate",0) >=0 )
		WMImageContrastUpdateProc()
		return 1
	endif
	return 0
end


#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif


Function WMImageContrastAdjustGraph(wclu)
	Wave wclu

	// specify size in pixels to match user controls
	Variable x0=104*PanelResolution("")/ScreenResolution, y0= 56*PanelResolution("")/ScreenResolution
	Variable x1=450*PanelResolution("")/ScreenResolution, y1= 346*PanelResolution("")/ScreenResolution

	Display/K=1 /W=(x0,y0,x1,y1) wclu as "Image Contrast Lookup"
	DoWindow/C WMContrastAdjustGraph

	Label left "output"
	Label bottom "input"
	ControlBar 58
	PopupMenu ContFctn,pos={6,3},size={152,24},proc=WMContFctnPopMenuProc,title="Function:"
	PopupMenu ContFctn,mode=1,value= #"\"Linear;Invert;Gamma;Uniform;Posterize;Ramps;User Drawn\""
	Button Apply,pos={10,34},size={65,20},proc=WMContrastButtonProc,title="Apply"
	Button Apply,help={"Click to cause the image display to use the selected function. Does not modify the data."}
	Button ContToData,pos={133,33},size={100,20},proc=WMContrastButtonProc,title="Change Data"
	Button ContToData,help={"Click to modify the data with current lookup table."}
	Button ContUndo,pos={255,33},size={70,20},proc=WMContrastButtonProc,title="Undo"
	Button ContUndo,help={"Undoes the last undoable operation."}
	DoUpdate
	SetWindow kwTopWin,hook=WMImageContrastWindowProc
	WMImageContrastWindowProc("EVENT:activate")
end

Function WMUpdateContrastFctn(funcName)
	String funcName
	
	if( strlen(funcName) == 0 )
		ControlInfo/W=WMContrastAdjustGraph ContFctn
		funcName= S_Value
	endif
	
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:ImageContrast

	Wave contY= contY
	Wave contX= contX
	Wave userY= userY
	Wave userX= userX
	
	RemoveFromGraph/Z contY
	RemoveFromGraph/Z userY

	if( CmpStr(funcName,"User Drawn") == 0 )
		AppendToGraph userY vs userX
		ModifyGraph rgb(userY)=(0,0,65535)
		GraphWaveEdit /M userY
	endif

	if( CmpStr(funcName,"Gamma") == 0 )
		NVAR Gamma= root:Packages:WMImProcess:ImageContrast:Gamma
		Make/O/N=100 contY,contX
		contX= p/99
		contY= contX^(1/Gamma)
		AppendToGraph contY vs contX
		ModifyGraph rgb(contY)=(0,0,65535)
	endif

	if( CmpStr(funcName,"Linear") == 0 )
		contY={0,1}
		contX={0,1}
		AppendToGraph contY vs contX
		ModifyGraph rgb(contY)=(0,0,65535)
	endif

	if( CmpStr(funcName,"Invert") == 0 )
		contY={1,0}
		contX={0,1}
		AppendToGraph contY vs contX
		ModifyGraph rgb(contY)=(0,0,65535)
	endif

	if( CmpStr(funcName,"Uniform") == 0 )
		SVAR ImGrfName= root:Packages:WMImProcess:ImageContrast:ImGrfName
		Wave w= $WMGetImageWave(ImGrfName)
		Make/O/N=999 contY,contX
		Histogram/B=1 w,contY
		
//		WaveStats/Q contY
//		contY[V_MaxLoc]=0

		InsertPoints 0,1,contY,contX	// force integral to start from 0

		Integrate contY
		contY= contY/contY[999]
		contX= p/999
		AppendToGraph contY vs contX
		ModifyGraph rgb(contY)=(0,0,65535)
	endif

	if( CmpStr(funcName,"Log") == 0 )
		SVAR ImGrfName= root:Packages:WMImProcess:ImageContrast:ImGrfName
		Wave w= $WMGetImageWave(ImGrfName)
		Make/O/N=1000 contY,contX
		Histogram/B=1 w,contY
		Integrate contY
		contY= (exp(contY/contY[999])-1)/(exp(1)-1)
		contX= p/999
		AppendToGraph contY vs contX
		ModifyGraph rgb(contY)=(0,0,65535)
	endif

	if( (CmpStr(funcName,"Posterize") == 0) %| ( CmpStr(funcName,"Ramps") == 0) )
		NVAR levels= root:Packages:WMImProcess:ImageContrast:levels
		variable npts= 2*(levels-1)+2		// 2 vertices each interior point + start and end
		ReDimension/N=(npts) contY,contX

		contX= floor((p/(npts-1))*levels+0.5)/levels
		if( CmpStr(funcName,"Posterize") == 0 )
			contY= floor((p/(npts-1))*(levels-1)+0.5)/(levels-1)
		else
			contY= mod(p,2)
		endif
		AppendToGraph contY vs contX
		ModifyGraph rgb(contY)=(0,0,65535)
	endif

	SetDataFolder dfSav
end


Function WMApplyContrastFctn(funcName)
	String funcName
	
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:ImageContrast

	Wave contY= contY
	Wave contX= contX
	Wave userY= userY
	Wave userX= userX

	SVAR ImGrfName= root:Packages:WMImProcess:ImageContrast:ImGrfName
	Wave/Z wclu= $WMGenImageContrastLUW(ImGrfName)
	if( !WaveExists(wclu) )
		beep
		return 0	// should never happen
	endif

	// most ops use this
	Redimension/N=1000 wclu
	SetScale/I x,0,1,wclu
	
	Variable isLinear= CmpStr(funcName,"Linear") == 0

	do
		if( isLinear )
			wclu= x
			break
		endif

		if( CmpStr(funcName,"User Drawn") == 0 )
			SetScale/P x,0,1,userY,userX
			wclu= userY(BinarySearchInterp(userX, x))
			break
		endif
	
		if( CmpStr(funcName,"Gamma") == 0 )
			NVAR Gamma= root:Packages:WMImProcess:ImageContrast:Gamma
			wclu= x^(1/Gamma)
			break
		endif

		SetScale/P x,0,1,contY,contX
		wclu= contY(BinarySearchInterp(contX, x))
	while(0)

	Wave w= $WMGetImageWave(ImGrfName)

	if( isLinear )
		ModifyImage/W=$ImGrfName $NameOfWave(w),lookup=$""	// Linear is same as no lookup
	else
		ModifyImage/W=$ImGrfName $NameOfWave(w),lookup=wclu
	endif

	SetDataFolder dfSav
End


Function WMApplyContFctnToData(funcName)
	String funcName

	if( CmpStr(funcName,"Linear") == 0 )
		return 0			// nop
	endif
	
	WMApplyContrastFctn(funcName)		// make sure data is fresh
	
	SVAR ImGrfName= root:Packages:WMImProcess:ImageContrast:ImGrfName
	Wave w= $WMGetImageWave(ImGrfName)
	Wave wclu= $WMGenImageContrastLUW(ImGrfName)
	
	WMSaveWaveBackups(w)

	Variable/C cur= WMReadImageRange(ImGrfName,w)
	WaveStats/Q w
	Variable nzmin,nzmax,dz
	
	if( NumType(real(cur)) == 0 )
		nzmin= real(cur)
	else
		nzmin= V_min
	endif
	if( NumType(imag(cur)) == 0 )
		nzmax= imag(cur)
	else
		nzmax= V_max
	endif
	dz= nzmax-nzmin
	w= wclu((w-nzmin)/dz)*dz+nzmin

	ModifyImage/W=$ImGrfName $NameOfWave(w),lookup=$""	// don't apply function twice
	wclu= x
	WMUpdateContrastFctn(funcName)			// just in case fctn involves image data (hist)
end



Function WMContrastButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=WMContrastAdjustGraph ContFctn

	if( CmpStr(ctrlName,"Apply") == 0 )
		WMApplyContrastFctn(S_value)
	endif
	if( CmpStr(ctrlName,"ContToData") == 0 )
		WMApplyContFctnToData(S_value)
	endif
	if( CmpStr(ctrlName,"ContUndo") == 0 )
		SVAR ImGrfName= root:Packages:WMImProcess:ImageContrast:ImGrfName
		Wave w= $WMGetImageWave(ImGrfName)
		WMRestoreWaveBackups(w,0)				// if desired we could alert user to error return
		WMUpdateContrastFctn("")			// just in case fctn involves image data (hist)
	endif
End


Function WMContFctnPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	Variable isWin= CmpStr(IgorInfo(2)[0,2],"Win")==0
	Variable fsize=12
	if( isWin )
		fsize=10
	endif
	
	if( CmpStr(popStr,"Gamma") == 0 )
		SetVariable Gamma,fsize=fsize,pos={202,7},size={100,15},proc=WMGammaSetVarProc,title="Gamma:"
		SetVariable Gamma,help={"Postitive lightens dark areas while negative darkens."}
		SetVariable Gamma,format="%.2f"
		SetVariable Gamma,limits={-Inf,Inf,0.1},value= root:Packages:WMImProcess:ImageContrast:gamma
	else
		KillControl Gamma
	endif


	if( (CmpStr(popStr,"Posterize") == 0) %| (CmpStr(popStr,"Ramps") == 0) )
		SetVariable Levels,fsize=fsize,pos={172,5},size={90,15},proc=WMLevelsSetVarProc,title="Levels"
		SetVariable Levels,help={"Enter the desired number of horizontal levels. "}
		SetVariable Levels,format="%d"
		SetVariable Levels,limits={2,100,1},value= root:Packages:WMImProcess:ImageContrast:levels
	else
		KillControl Levels
	endif
	
	WMUpdateContrastFctn(popStr)
End


Function WMGammaSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	ControlInfo/W=WMContrastAdjustGraph ContFctn

	WMUpdateContrastFctn(S_value)
End


Function WMLevelsSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	ControlInfo/W=WMContrastAdjustGraph ContFctn

	WMUpdateContrastFctn(S_value)
End

