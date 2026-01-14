#pragma rtGlobals=2		// Use modern global access method.
#include <Image Common>

// LH971226
// Image Edge Panel, version 0.9
// Requires Igor Pro 3.11 or later
//
// Create user interface window by calling the following from a button or a menu:
// WMCreateImageEdgePanel()

 


Function WMCreateImageEdgePanel()

	if(isColorImage())
		return 0;
	endif

	DoWindow/F ImageEdgePanel
	if( V_Flag==1 )
		return 0
	endif

	String igName= WMTopImageGraph()
	if( strlen(igName) == 0 )
		DoAlert 0,"No image plot found"
		return 0
	endif
	
	String dfSav= GetDataFolder(1)

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:WMImProcess
	NewDataFolder/O/S root:Packages:WMImProcess:EdgeDetect
	
	if( NumVarOrDefault("inited",0) == 0 )
		Variable/G inited=1
		Variable/G type= 1			// memory for type of Edge Detect
		Variable/G action= 1		// memory for action: Gray replace;Binary overlay;Binary New
		Variable/G threshMethod= 1	// memory for thresholding method. Manual and ImageThreshold Methods 1,2,4 and 5 or -1 for no thresholding
		Variable/G smooth= 1		// memory for smoothing factor
		Variable/G level= 128		// threshold level
		Variable/G printit= 0		// memory for print command checkbox

		Variable/G fraction= 0.5		// fraction  specifies the portion of the image pixels whose values are below the threshold
		Variable/G ShenSmooth= 0.5	// memory for Shen smoothing factor
		Variable/G ShenWidth= 2		// memory for Shen width factor
		Variable/G ShenThin= 2			// memory for Shen thinning factor
	endif

	SetDataFolder dfSav
	
	Wave w= $WMGetImageWave(igName)

	
	NewPanel/K=1 /W=(10,356,379,485) as "Image Edge Detect"
	DoWindow/C ImageEdgePanel
	AutoPositionWindow/E/M=1/R=$igName

	Variable isWin= CmpStr(IgorInfo(2)[0,2],"Win")==0
	Variable fsize=12
	if( isWin )
		fsize=10
	endif

	NVAR type= root:Packages:WMImProcess:EdgeDetect:type
	NVAR action= root:Packages:WMImProcess:EdgeDetect:action
	NVAR printit= root:Packages:WMImProcess:EdgeDetect:printit

	PopupMenu type,pos={13,10},size={137,24},proc=WMImageEdgeTypePopMenuProc,title="Method:"
	PopupMenu type,mode=1,popvalue="Canny",value= #"\"Canny;Kirsch;Sobel;Marr;Shen;Roberts;Prewitt;Frei\""
	PopupMenu Action,pos={172,10},size={175,24},proc=WMImageEdgeActionPopMenuProc,title="Action:"
	PopupMenu Action,mode=1,popvalue="Gray Replace",value= #"\"Gray Replace;Binary Overlay;Binary New Image\""
	Button DoItEdge,pos={24,100},size={50,20},proc=WMBPEdgeDoIt,title="Do It"
	CheckBox printit,pos={25,76},size={145,20},proc=WMImageEdgePrintCheckProc,title="Print command"
	CheckBox printit,help={"When checked, the ImageEdgeDetection command is printed to history."},value=0
	SetVariable Smooth,pos={166,62},size={105,18},title="Smooth:"
	SetVariable Smooth,help={"Enter smoothing factor (noise reduction)."}
	SetVariable Smooth,limits={0,10,1},value= root:Packages:WMImProcess:EdgeDetect:smooth
	Button buttonUndo,pos={219,100},size={50,20},proc=WMImageBPUndo,title="Undo"
	Button buttonRestore,pos={279,100},size={66,20},proc=WMImageBPUndo,title="Restore"
	Button edgeHelpButt,pos={100,100},size={50,20},proc=edgeHelpProc,title="Help"
	ModifyPanel fixedsize=1
	WMImageUpdateEdgePanel()
end

Function edgeHelpProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic  "ImageEdgeDetection"
End

Function WMImageEdgePrintCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	Variable/G root:Packages:WMImProcess:EdgeDetect:printit= checked
End


Function WMImageEdgeActionPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G root:Packages:WMImProcess:EdgeDetect:action= popNum
	WMImageUpdateEdgePanel()
End

Function WMImageEdgeThreshPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G root:Packages:WMImProcess:EdgeDetect:threshMethod= popNum
	WMImageUpdateEdgePanel()
End


Function WMImageEdgeTypePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G root:Packages:WMImProcess:EdgeDetect:type= popNum
	WMImageUpdateEdgePanel()
End

Function WMImageUpdateEdgePanel()
	ControlInfo type
	String keyword= S_value


	Variable wantThresh=1,wantSmoothing=0,isShen=0
	
	if(cmpstr(keyword,"Canny")==0)
		wantSmoothing= 1
	endif
	if(cmpstr(keyword,"Marr")==0)
		wantThresh= 0
		wantSmoothing= 1
	endif
	if(cmpstr(keyword,"Shen")==0)
		wantThresh= 0
		isShen=1
	endif

	NVAR action= root:Packages:WMImProcess:EdgeDetect:action
	if( action==1)
		wantThresh= 0
	endif

	NVAR threshMethod= root:Packages:WMImProcess:EdgeDetect:threshMethod
	
	ControlInfo thresh
	Variable controlexists= V_Flag!=0
	if( wantThresh %& !controlexists )
		PopupMenu thresh,pos={49,38},size={209,19},proc=WMImageEdgeThreshPopMenuProc,title="Thresholding:"
		PopupMenu thresh,mode=threshMethod,value= #"\"User Level;Iterated;Bimodal fit;Fuzzy-Entropy;Fuzzy-Mean Gray\""
	endif
	if( !wantThresh %& controlexists )
		KillControl thresh
	endif

	ControlInfo level
	controlexists= V_Flag!=0
	if( threshMethod!=1 )
		wantThresh= 0			// really means wantLevel
	endif
	if( wantThresh %& !controlexists )
		SetVariable level,pos={249,41},size={105,15},title="Level:"
		SetVariable level,help={"Enter level for threshold"}
		SetVariable level,limits={0,255,1},value= root:Packages:WMImProcess:EdgeDetect:level
	endif
	if( !wantThresh %& controlexists )
		KillControl level
	endif

	ControlInfo fraction
	controlexists= V_Flag!=0
	if( isShen %& !controlexists )
		SetVariable fraction,pos={52,58},size={105,15},title="Fraction:"
		SetVariable fraction,help={"Enter fraction  specifies the portion of the image pixels whose values are below the threshold."}
		SetVariable fraction,limits={0,1,0.01},value= root:Packages:WMImProcess:EdgeDetect:fraction
		SetVariable ShenWidth,pos={167,37},size={105,15},title="Width:"
		SetVariable ShenWidth,help={"Enter fraction  specifies the portion of the image pixels whose values are below the threshold."}
		SetVariable ShenWidth,limits={0,10,1},value= root:Packages:WMImProcess:EdgeDetect:ShenWidth
		SetVariable ShenThin,pos={52,37},size={105,15},title="Thining:"
		SetVariable ShenThin,help={"Enter fraction  specifies the portion of the image pixels whose values are below the threshold."}
		SetVariable ShenThin,limits={0,10,1},value= root:Packages:WMImProcess:EdgeDetect:ShenThin
		SetVariable ShenSmooth,pos={166,58},size={105,15},title="Smooth:"
		SetVariable ShenSmooth,help={"Enter smoothing factor (noise reduction)."}
		SetVariable ShenSmooth,limits={0,1,0.1},value= root:Packages:WMImProcess:EdgeDetect:ShenSmooth
	endif
	if( !isShen %& controlexists )
		KillControl fraction
		KillControl ShenWidth
		KillControl ShenThin
		KillControl ShenSmooth
	endif

	ControlInfo Smooth
	controlexists= V_Flag!=0
	if( wantSmoothing %& !controlexists )
		SetVariable Smooth,pos={166,62},size={105,15},title="Smooth:"
		SetVariable Smooth,help={"Enter smoothing factor (noise reduction)."}
		SetVariable Smooth,limits={0,10,1},value= root:Packages:WMImProcess:EdgeDetect:smooth
	endif
	if( !wantSmoothing %& controlexists )
		KillControl Smooth
	endif

	ControlInfo buttonUndo
	controlexists= V_Flag!=0
	if( (action==1) %& !controlexists )
		Button buttonUndo,pos={155,100},size={50,20},proc=WMImageBPUndo,title="Undo"
		Button buttonRestore,pos={209,100},size={66,20},proc=WMImageBPUndo,title="Restore"
	endif
	if( (action!=1) %& controlexists )
		KillControl buttonUndo
		KillControl buttonRestore
	endif

	ControlInfo buttonRemoveOverlay
	controlexists= V_Flag!=0
	if( (action==2) %& !controlexists )
		Button buttonRemoveOverlay,pos={155,100},size={150,20},proc=WMImageEdgeRemoveOverlay,title="Remove overlay"
	endif
	if( (action!=2) %& controlexists )
		KillControl buttonRemoveOverlay
	endif

	ControlInfo buttonKillEdgeGrf
	controlexists= V_Flag!=0
	if( (action==3) %& !controlexists )
		Button buttonKillEdgeGrf,pos={155,100},size={150,20},proc=WMImageEdgeRemoveOverlay,title="Kill edge image"
	endif
	if( (action!=3) %& controlexists )
		KillControl buttonKillEdgeGrf
	endif

end

Function/S WMImEdgeWaveName(w)
	Wave w
	
	return NameOfWave(w)+"_Edges"
end

Function/S WMImEdgeWinName(win)
	String win
	
	return win+"_edge"
end



Function WMImageEdgeRemoveOverlay(ctrlName) : ButtonControl
	String ctrlName

	SVAR/Z ImGrfName= root:Packages:WMImProcess:EdgeDetect:ImGrfName
	if(SVAR_Exists(ImGrfName )==0 ||  strlen(ImGrfName)<=0)
		beep
		return 0
	endif
	
	String pw= WMGetImageWave(ImGrfName)
	Wave/Z w= $pw
	if( !WaveExists(w) )
		beep
		return 0
	endif

	WAVE wover= $(GetWavesDataFolder(w,1)+PossiblyQuoteName(WMImEdgeWaveName(w)))
	
	if( CmpStr(ctrlName,"buttonRemoveOverlay") == 0 )
		CheckDisplayed/W=$ImGrfName wover
		if( V_Flag==1 )
			DoWindow/F ImGrfName
			RemoveImage $WMImEdgeWaveName(w)
			DoWindow/F ImageEdgePanel
		endif
	endif
	
	if( CmpStr(ctrlName,"buttonKillEdgeGrf") == 0 )
		DoWindow/K $WMImEdgeWinName(ImGrfName)
	endif
end

Function WMBPEdgeDoIt(ctrlName) : ButtonControl
	String ctrlName

	String ImGrfName= WMTopImageGraph()
	String pw= WMGetImageWave(ImGrfName)
	Wave/Z w= $pw
	if( !WaveExists(w) )
		beep
		return 0
	endif
	
	if( WaveType(w) != 0x48 )
		Abort "Image must be unsigned byte"
	endif

	String/G root:Packages:WMImProcess:EdgeDetect:ImGrfName= ImGrfName		// remember for undo
	
	variable se= -1
	NVAR threshMethod= root:Packages:WMImProcess:EdgeDetect:threshMethod
	NVAR level= root:Packages:WMImProcess:EdgeDetect:level
	NVAR action= root:Packages:WMImProcess:EdgeDetect:action
	NVAR smooth= root:Packages:WMImProcess:EdgeDetect:smooth

	NVAR fraction= root:Packages:WMImProcess:EdgeDetect:fraction
	NVAR ShenSmooth= root:Packages:WMImProcess:EdgeDetect:ShenSmooth
	NVAR ShenWidth= root:Packages:WMImProcess:EdgeDetect:ShenWidth
	NVAR ShenThin= root:Packages:WMImProcess:EdgeDetect:ShenThin

	ControlInfo type
	String keyword= S_value
	Variable wantThresh=1,wantSmoothing=0,isShen=0
	
	if(cmpstr(keyword,"Canny")==0)
		wantSmoothing= 1
	endif
	if(cmpstr(keyword,"Marr")==0)
		wantThresh= 0
		wantSmoothing= 1
	endif
	if(cmpstr(keyword,"Shen")==0)
		wantThresh= 0
		isShen=1
	endif


	
	ImageGenerateROIMask/E=1/I=0/W=$ImGrfName $NameOfWave(w)
	Variable roiExists= V_Flag
	
	String options="",command="ImageEdgeDetection"
	if( roiExists )
		options += "/R=M_ROIMask"
	endif
	if( action==1 )
		options += "/O/M=-1"
		WMSaveWaveBackups(w)
	else
		if( wantThresh )
			if( threshMethod==1 )
				options += "/T="+num2str(level)
			else
				Make/O iepTmp={1,2,4,5}
				options += "/M="+num2istr(iepTmp[threshMethod-2])
				KillWaves iepTmp
			endif
		endif
		if( action!=1 )			// overlay or sep image
			options += "/N"		// make background invisible
		endif
	endif
	if( wantSmoothing )
		options += "/S="+num2str(smooth)
	endif
	if( isShen )
		options += "/S="+num2str(ShenSmooth)
		options += "/F="+num2str(fraction)
		options += "/W="+num2str(ShenWidth)
		options += "/H="+num2str(ShenThin)
	endif
	command += options + " " + keyword + ", "+GetWavesDataFolder(w,2)
	NVAR printit= root:Packages:WMImProcess:EdgeDetect:printit
	if( printit==1 )
		print command
	endif
	Execute command
	if( roiExists )
		KillWaves M_ROIMask
	endif
	if( action!=1 )
		Wave edge= M_ImageEdges
		String dfSav= GetDataFolder(1)
		SetDataFolder $GetWavesDataFolder(w,1)
		Duplicate/O edge,$WMImEdgeWaveName(w)
		Wave nedge= $WMImEdgeWaveName(w)
		SetDataFolder $dfSav
		KillWaves M_ImageEdges
		
		if( action==2 )		// overlay
			CheckDisplayed/W=$ImGrfName nedge
			if( V_Flag==0 )
				WMImageAppendOverlay(ImGrfName,w,nedge)
				ModifyImage $nameofwave(nedge),explicit=1,eval={0, 65535, 0, 0 }
				DoWindow/F ImageEdgePanel
			endif
		endif
		
		if( action==3 )		// New graph
			String newGrfName= WMImEdgeWinName(ImGrfName)
			DoWindow/F $newGrfName
			if( V_Flag==0 )
				WMCloneImage(ImGrfName,w,nedge)
				ModifyImage $nameofwave(nedge),explicit=1,eval={0, 65535, 0, 0 }
				DoWindow/C $newGrfName
				AutoPositionWindow/E/M=1/R=ImageEdgePanel
			endif
			DoWindow/F $ImGrfName		// make sure target is still the same and not the new image
			DoWindow/F ImageEdgePanel
		endif
	endif
End

