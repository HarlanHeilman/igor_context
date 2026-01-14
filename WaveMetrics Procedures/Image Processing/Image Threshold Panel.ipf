#pragma rtGlobals=2		// Use modern global access method.
 
#include <Image Common>

// Image Threshold package
// Version 0.9, LH971230
//
//	Creates binary wave with name of source with _Bin suffex
//	Creates numeric variables with the threshold values using name of wave with
//		TH1_ and Th2_ prefixes. Th2 is usually INF unless manual thresholding
//		was used and the user entered a value for the upper limit. Th1 will be NaN
//		if adaptive thresholding is specified.
//	Vars and bin wave are created in same data folder as source.
//
// Create user interface window by calling the following from a button or a menu:
// WMCreateImageThresholdGraph()
//
//	Search for TODO
//   	AG17JUN99
// 	Modified size so that when using large fonts on the PC buttons are better positioned.
//	Modified update and the hook so that the hook function gets called immediately after the panel is created.
// 	Removed comment from the #include <Image Common>
//		AG01MAY03
//	Added color popup to let the user set the color of the binary mask.
// 		AG21MAY03
//	changed panel to include a bottom control bar.  Moved some controls for better readability and 
//  added a print command checkbox.
//		AG05FEB04
// 	added support for 3D waves displayed with a slider control.  The slider procedure will call the imageThreshold
//	if root:Packages:WMImProcess:ImageThreshold:ImGrfName has the same name as the current graph.


#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif


Function WMCreateImageThresholdGraph()

//	if(isColorImage())  05FEB04
//		return 0;
//	endif
	
	DoWindow/F WMImageThresholdGraph
	if( V_Flag==1 )
		return 0
	endif

	NewDataFolder/O root:WinGlobals
	NewDataFolder/O root:WinGlobals:WMImageThresholdGraph
	String/G root:WinGlobals:WMImageThresholdGraph:S_TraceOffsetInfo= ""

	String dfSav= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:WMImProcess
	NewDataFolder/O/S root:Packages:WMImProcess:ImageThreshold
	
	Variable/G zmin,zmax,zminmaxDummy
	SetFormula zminmaxDummy,"WMSetImThreshFromCursors(root:WinGlobals:WMImageThresholdGraph:S_TraceOffsetInfo)"
	
	Make/O zminDrag={-Inf,Inf},zmaxDrag={-Inf,Inf},xDrag={0,0}
	Make/O/N=100 hist=x

	String/G ImGrfName= ""
	
	Variable/G inited,method,action,invert
	if( inited==0 )
		inited=1
		method= 1		// popup menu number
		action=1		// popup menu number
	endif
			
	// specify size in pixels to match user controls
	Variable x0=10*PanelResolution("")/ScreenResolution, y0= 356*PanelResolution("")/ScreenResolution
	Variable x1=470*PanelResolution("")/ScreenResolution, y1= 561*PanelResolution("")/ScreenResolution

	Display/K=1/L=lnew /W=(x0,y0,x1,y1) hist as "Image Threshold Adjust"

	SetDataFolder root:Packages:WMImProcess:ImageThreshold:
	AppendToGraph/L=lnew zminDrag,:zmaxDrag vs xDrag

	SetDataFolder dfSav

	ModifyGraph margin(left)=56
	ModifyGraph mode(hist)=1
	ModifyGraph quickdrag(zminDrag)=1,live(zminDrag)=1
	ModifyGraph quickdrag(zmaxDrag)=1,live(zmaxDrag)=1
	ModifyGraph lSize(zminDrag)=2,lSize(zmaxDrag)=2
	ModifyGraph rgb(hist)=(0,0,0),rgb(zmaxDrag)=(1,4,52428)
	ModifyGraph lblPos(lnew)=47
	ModifyGraph freePos(lnew)=7
	Label bottom "Level"

	DoWindow/C WMImageThresholdGraph

	ControlBar 56
	ControlBar/B 38
	SetVariable MinVar,pos={15,35},size={92,15},proc=WMThreshMinMaxVarSetVarProc,title="min:"
	SetVariable MinVar,help={"Set minimum threshold here or drag red vertical cursor"}
	SetVariable MinVar,limits={-Inf,Inf,0},value= root:Packages:WMImProcess:ImageThreshold:zmin
	SetVariable MaxVar,pos={114,35},size={91,15},proc=WMThreshMinMaxVarSetVarProc,title="max:"
	SetVariable MaxVar,help={"Set maximum threshold here or drag blue vertical cursor"}
	SetVariable MaxVar,limits={-Inf,Inf,0},value= root:Packages:WMImProcess:ImageThreshold:zmax
	PopupMenu method,pos={140,7},size={111,20},proc=WMImageThreshMethodPopMenuProc,title="Method:"
	PopupMenu method,mode=1,popvalue="Manual",value= #"\"Manual;Iterated;Bimodal fit;Adaptive;Fuzzy-Entropy;Fuzzy-Mean Gray\""
	CheckBox Invert,pos={244,35},size={49,14},proc=WMImageThreshCheckProc,title="Invert"
	CheckBox Invert,help={"When checked, values above threshold produce zero."}
	CheckBox Invert,value= 0
	PopupMenu itColorPop,pos={14,7},size={82,20},proc=itColorPopProc,title="Color"
	PopupMenu itColorPop,help={"Set the color of the binary overlay."}
	PopupMenu itColorPop,mode=1,popColor= (65535,65535,0),value= #"\"*COLORPOP*\""
	CheckBox itPrintCmdCheck,pos={334,35},size={93,14},title="Print Command"
	CheckBox itPrintCmdCheck,value= 0
	SetWindow kwTopWin,hook=WMImageThresholdWindowProc
	NewPanel/W=(0.2,0.71,0.8,0.8)/FG=(GL,GB,FR,FB)/HOST=# 
	ModifyPanel frameStyle=0
	Button done,pos={373,9},size={55,20},proc=WMImageThreshDoneButtonProc,title="Done"
	Button thresholdHelp,pos={305,9},size={55,20},proc=thresholdHelp,title="Help"
	PopupMenu action,pos={12,10},size={180,20},proc=WMImageThreshActionPopMenuProc,title="When done:"
	PopupMenu action,mode=1,popvalue="Remove Overlay",value= #"\"Remove Overlay;Keep Overlay;Replace Data;New Image\""
	RenameWindow #,PBottom
	SetActiveSubwindow ##
	AutoPositionWindow/E/M=1/R=$ImGrfName
	DoUpdate
	SetWindow kwTopWin,hook=WMImageThresholdWindowProc		// this will cause update proc to be called
	WMImageThresholdWindowProc("EVENT:activate")	
	return 0;
End

Function thresholdHelp(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "ImageThreshold"
End

Function WMImageDoCurrentThresh()
	NVAR nzmax= root:Packages:WMImProcess:ImageThreshold:zmax
	NVAR nzmin= root:Packages:WMImProcess:ImageThreshold:zmin
	SVAR imageGraphName= root:Packages:WMImProcess:ImageThreshold:ImGrfName
	Wave w= $WMGetImageWave(imageGraphName)
	Wave hist= root:Packages:WMImProcess:ImageThreshold:hist

	Variable 	printCommand=0
	String 		cmd
	ControlInfo /W=WMImageThresholdGraph itPrintCmdCheck
	if(V_Value)
		printCommand=1
	endif

	// 05FEB04
	Variable allowSliderControl=0				
	Variable thePlane=0
	if(DimSize(w,2)>4)	
		thePlane=WM_GetDisplayed3DPlane(imageGraphName)
		allowSliderControl=1
		ImageTransform /P=(thePlane) getPlane w
		Wave ww=M_ImagePlane
	else
		Wave ww=w
	endif

	ControlInfo/W=WMImageThresholdGraph method
	Variable popnum= V_value
	if( popnum==1 )		// Manual - try to leave untouched
		if( !WMWithin(nzmin,leftx(hist),rightx(hist)) )
			nzmin= (leftx(hist)+rightx(hist))/2
			nzmax= inf
		endif
	else
		ImageGenerateROIMask/E=1/I=0/W=$imageGraphName $NameOfWave(w)
		if( V_Flag )
			ImageThreshold/M=(popnum-1)/Q/R=M_ROIMask ww		// 05FEB04
			if(printCommand)
				sprintf cmd,"ImageThreshold/M=(%d)/Q/R=M_ROIMask %s\r",popnum-1,NameOfWave(w)
				print cmd
			endif
			KillWaves M_ROIMask
		else
			ImageThreshold/M=(popnum-1)/Q ww						// 05FEB04
			if(printCommand)
				sprintf cmd,"ImageThreshold/M=(%d)/Q  %s\r",popnum-1,NameOfWave(w)
				print cmd
			endif
		endif

		if(allowSliderControl)
			KillWaves/Z ww
		endif
		
		KillWaves/Z M_ImageThresh
		nzmin= V_threshold
		nzmax= inf
	endif
		
	
	ModifyGraph offset(zmaxDrag)={nzmax,0}
	ModifyGraph offset(zminDrag)={nzmin,0}
	WMImageThreshUpdate()
	// Now prevent the offset dependency from firing due to double update.
	String/G root:WinGlobals:WMImageThresholdGraph:S_TraceOffsetInfo= ""
end


Function WMImageThreshMethodPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G root:Packages:WMImProcess:ImageThreshold:method= popNum
	WMImageDoCurrentThresh()
End

Function itColorPopProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	WMImageThreshUpdate()
End

Function WMImageThreshCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	Variable/G root:Packages:WMImProcess:ImageThreshold:invert= checked
	WMImageDoCurrentThresh()
End

Function WMImageThreshActionPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G root:Packages:WMImProcess:ImageThreshold:action= popNum
End


Function WMImageThresholdUpdateProc()
	String newImGrfName= WMTopImageGraph()
	SVAR ImGrfName= root:Packages:WMImProcess:ImageThreshold:ImGrfName

	if( CmpStr(newImGrfName,ImGrfName)== 0 )
		return 0		// nothing to do if revisiting the same image as last time
	endif

	ImGrfName= newImGrfName
	
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif
	
	Wave hist= root:Packages:WMImProcess:ImageThreshold:hist
	Histogram/B=1 w,hist
	SetScale d,0,0,"Counts" hist
	SetAxis bottom,leftx(hist),rightx(hist)

	WMImageDoCurrentThresh()
end
	
Function WMImageThresholdWindowProc(infoStr)
	String infoStr
	
	if( StrSearch(infoStr,"EVENT:activate",0) >= 0 )
		WMImageThresholdUpdateProc()
		return 1
	endif
	if( StrSearch(infoStr,"EVENT:kill;",0) > 0 )
		SVAR imageName=root:Packages:WMImProcess:ImageThreshold:ImGrfName			// 05FEB04 to deactivate slider calls
		imageName=""
		String dfSav= GetDataFolder(1)
		SetDataFolder root:Packages:WMImProcess:ImageThreshold
		Variable/G zminmaxDummy
		SetFormula zminmaxDummy,""
		SetDataFolder dfSav
		return 1
	endif
	return 0
end


Function WMThreshMinMaxVarSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// NOTE: setting the offsets here causes a dependency to fire that ends up updating the image
	if( CmpStr("MaxVar",ctrlName) == 0 )
		ModifyGraph offset(zmaxDrag)={varNum,0}	
	else
		ModifyGraph offset(zminDrag)={varNum,0}
	endif
End

// Fires on a dependency. s is S_TraceOffsetInfo from the quickdrag stuff
Function WMSetImThreshFromCursors(s)
	String s

	Variable isZmin= StrSearch(s,"TNAME:zminDrag;",0)>0
	Variable isZmax= StrSearch(s,"TNAME:zmaxDrag;",0)>0
	if( (isZmin==0) %& (isZmax==0) )
		return 0								// not valid yet
	endif
	String targ= ";XOFFSET:"
	Variable v1= StrSearch(s,targ,0)
	if( v1<0 )
		return 0
	endif
	v1 += strlen(targ)
	Variable v2= StrSearch(s,";",v1)
	Variable xoff= str2num(s[v1,v2-1])
	if( NumType(xoff) != 0 )
		return 0;
	endif
	NVAR nzmax= root:Packages:WMImProcess:ImageThreshold:zmax
	NVAR nzmin= root:Packages:WMImProcess:ImageThreshold:zmin
	if( isZmax )
		nzmax= xoff
	else
		nzmin= xoff
	endif
	PopupMenu method,win=WMImageThresholdGraph,mode=1		// user adjusted thresh, so force to manual
	WMImageThreshUpdate()
	return 0
end

Function/S WMImBinWaveName(w)
	Wave w
	
	return NameOfWave(w)+"_Bin"
end

Function WMImageThreshUpdate()
	SVAR imageGraphName= root:Packages:WMImProcess:ImageThreshold:ImGrfName
	WAVE/Z w= $WMGetImageWave(imageGraphName)
	if( !WaveExists(w) )
		return 0
	endif
	NVAR nzmax= root:Packages:WMImProcess:ImageThreshold:zmax
	NVAR nzmin= root:Packages:WMImProcess:ImageThreshold:zmin
	NVAR invert= root:Packages:WMImProcess:ImageThreshold:invert
	
	Make/O WMThTmp={nzmin,nzmax}		// just in case
	Variable dualOK= nzmax<Inf
	String options="/Q",command="ImageThreshold"
	
	ControlInfo/W=WMImageThresholdGraph method
	Variable popnum= V_value
	
	ImageGenerateROIMask/E=1/I=0/W=$imageGraphName $NameOfWave(w)
	Variable roiExists= V_Flag

	if( roiExists )
		options += "/R=M_ROIMask"
	endif
	if( popnum==1 )		// Manual
		if( dualOK )
			options += "/W=WMThTmp"
		else
			options += "/T="+num2str(nzmin)
		endif
	else
		options += "/M="+num2str(popnum-1)
	endif

	if( invert )
		options += "/I"
	endif
	
	// 05FEB04
	Variable allowSliderControl=0				
	Variable thePlane=0
	if(DimSize(w,2)>4)	
		thePlane=WM_GetDisplayed3DPlane(imageGraphName)
		allowSliderControl=1
		ImageTransform /P=(thePlane) getPlane w
		Wave ww=M_ImagePlane
	else
		Wave ww=w
	endif
	
	command += options + " " + GetWavesDataFolder(ww,2)
	Execute command
	
	if(allowSliderControl)
		KillWaves/Z ww
	endif
	
	ControlInfo /W=WMImageThresholdGraph itPrintCmdCheck
	if(V_Value)
		print command
	endif
	
	KillVariables/Z V_threshold

	if( roiExists )
		KillWaves M_ROIMask
	endif
	KillWaves/Z WMThTmp
	
	Wave thresh= M_ImageThresh

	String dfSav= GetDataFolder(1)
	SetDataFolder $GetWavesDataFolder(w,1)
	Duplicate/O thresh,$WMImBinWaveName(w)		// _Bin wave created here
	Wave nthresh= $WMImBinWaveName(w)
	Variable/G $CleanupName("Th1_"+NameOfWave(w),0)= nzmin	// TH1_ variable created here
	Variable/G $CleanupName("Th2_"+NameOfWave(w),0)= nzmax
	SetDataFolder $dfSav
	KillWaves M_ImageThresh
	
// This should not be necessary - ImageThreshold should have set scaling
// TODO: remove this when ImageThreshold is fixed
SetScale/P x,DimOffset(w, 0),DimDelta(w,0),WaveUnits(w, 0) nthresh
SetScale/P y,DimOffset(w, 1),DimDelta(w,1),WaveUnits(w, 1) nthresh
	
	CheckDisplayed/W=$imageGraphName nthresh
	if( V_Flag==0 )
		WMImageAppendOverlay(imageGraphName,w,nthresh)
		// find the color for the overlay:
		ControlInfo/W=WMImageThresholdGraph itColorPop
		ModifyImage $nameofwave(nthresh),explicit=1,eval={0, -1, 0, 0 },eval={255, (V_Red), (V_Green), (V_Blue) }
		DoWindow/F WMImageThresholdGraph
	else
		ControlInfo/W=WMImageThresholdGraph itColorPop
		ModifyImage/W=$imageGraphName $nameofwave(nthresh),explicit=1,eval={0, -1, 0, 0 },eval={255, (V_Red), (V_Green), (V_Blue) }
	endif
end




Function WMImageThreshDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR ImGrfName= root:Packages:WMImProcess:ImageThreshold:ImGrfName
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif
	WAVE/Z wover= ImageNameToWaveRef(ImGrfName, WMImBinWaveName(w))
	if( !WaveExists(wover) )
		return 0
	endif

	ControlInfo/W=WMImageThresholdGraph#PBottom  action	
	Variable popNum= V_value	// Remove Overlay;Keep Overlay;Replace Data;New Image
	if( popNum==1 )
		// remove and kill overlay
		DoWindow/F $ImGrfName
		RemoveImage $WMImBinWaveName(w)
		KillWaves/Z wover
	endif
	if( popNum==2 )
		// retain overlay - do nothing
	endif
	if( popNum==3 )
		// remove overlay, backup data, overwrite data, kill overlay
		DoWindow/F $ImGrfName
		RemoveImage $WMImBinWaveName(w)
		WMSaveWaveBackups(w)
		Duplicate/O wover,$GetWavesDataFolder(w,2)
		KillWaves/Z wover
	endif
	if( popNum==4 )
		// remove overlay, new graph with overlay wave
		DoWindow/F $ImGrfName
		RemoveImage $WMImBinWaveName(w)
		WMCloneImage(ImGrfName,w,wover)
	endif
	DoWindow/K WMImageThresholdGraph
End
