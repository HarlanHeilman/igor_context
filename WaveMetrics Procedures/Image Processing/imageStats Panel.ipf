#pragma rtGlobals=1		// Use modern global access method.
#include <Image Common>

// 24MAR03
// 
//===================================================================
Function WMSetupImageStatsPanel()

	DoWindow/F WMImageStatsPanel
	if(V_Flag==1)
		return 0
	endif
	
	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S  WMImProcess
	NewDataFolder/O/S  WMImageStats
	Variable/G Plane=0
	Variable/G xMin,xMax,yMin,yMax
	String/G imageGraphName=""
	Make/O/N=14 wResults=NaN
	SetDimLabel 0,0,avg,wResults
	SetDimLabel 0,1,min,wResults
	SetDimLabel 0,2,max,wResults
	SetDimLabel 0,3,minRowLoc,wResults
	SetDimLabel 0,4,minColLoc,wResults
	SetDimLabel 0,5,maxRowLoc,wResults
	SetDimLabel 0,6,maxColLoc,wResults
	SetDimLabel 0,7,npnts,wResults
	SetDimLabel 0,8,adev,wResults
	SetDimLabel 0,9,rms,wResults
	SetDimLabel 0,10,sdev,wResults
	SetDimLabel 0,11,skew,wResults
	SetDimLabel 0,12,kurt,wResults
	ImageStatsPanel() 
	WMImageStatsUpdateProc()
	
	SVAR imageGraphName= root:Packages:WMImProcess:WMImageStats:imageGraphName
	AutoPositionWindow/E/M=1/R=$imageGraphName
	SetDataFolder oldDF
End

//===================================================================

Function ImageStatsPanel() 

	DoWindow/F WMImageStatsPanel
	if(V_Flag)
		return 0
	endif
	NewPanel /K=1 /W=(563,327,997,691) as "ImageStats Panel"
	DoWindow/C WMImageStatsPanel
	CheckBox is_lowestMomentCheck,pos={9,32},size={166,14},title="Compute Lowest Moments Only"
	CheckBox is_lowestMomentCheck,value= 0
	SetVariable is_PlaneSetVar,pos={5,144},size={91,15},disable=1,title="Plane"
	SetVariable is_PlaneSetVar,limits={0,Inf,1},value= root:Packages:WMImProcess:WMImageStats:Plane,bodyWidth= 60
	PopupMenu is_ROIPop,pos={5,5},size={121,20},proc=is_ROIPopProc,title="ROI:"
	PopupMenu is_ROIPop,mode=1,popvalue="All Plane",value= #"\"All Plane;Use ROI;Point Range;Scaled Range\""
	SetVariable is_xminSetVar,pos={11,55},size={100,15},title="xMin:",proc=isVarUpdate
	SetVariable is_xminSetVar,value= root:Packages:WMImProcess:WMImageStats:xMin
	SetVariable is_xmaxSetVar,pos={11,73},size={100,15},title="xMax:",proc=isVarUpdate
	SetVariable is_xmaxSetVar,value= root:Packages:WMImProcess:WMImageStats:xMax
	SetVariable is_yminSetVar,pos={11,91},size={100,15},title="yMin:",proc=isVarUpdate
	SetVariable is_yminSetVar,value= root:Packages:WMImProcess:WMImageStats:yMin
	SetVariable is_ymaxSetVar,pos={11,108},size={100,15},title="yMax:",proc=isVarUpdate
	SetVariable is_ymaxSetVar,value= root:Packages:WMImProcess:WMImageStats:yMax
	TitleBox is_title0,pos={208,4},size={44,20}
	TitleBox is_title0,variable= root:Packages:WMImProcess:WMImageStats:imageGraphName
	Button isHelp,pos={37,180},size={87,22},proc=isHelpButtonProc,title="Help"
	DefineGuide UGV0={FL,205},UGV1={FL,0.956616,FR},UGH0={FT,0.939891,FB},UGH1={FT,28}
	is_ROIPopProc("",1,"All Plane");
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:WMImageStats:
	Edit/W=(191,38,402,326)/FG=(UGV0,UGH1,UGV1,UGH0)/HOST=#  wResults.ld
	Execute "ModifyTable width(Point)=28,width(wResults.ld)=80"
	SetDataFolder fldrSav0
	RenameWindow #,T0
	SetActiveSubwindow ##
	SetWindow kwTopWin,hook=WMImageStatsWindowProc
End

//===================================================================
Function isVarUpdate(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr,varName
	
	is_DoitButtonProc("")
end
//===================================================================

Function WMImageStatsWindowProc(infoStr)
	String infoStr
	
	if( StrSearch(infoStr,"EVENT:activate",0) >= 0  || StrSearch(infoStr,"EVENT:deactivate",0) >= 0)
		WMImageStatsUpdateProc()
		return 1
	elseif(StrSearch(infoStr,"EVENT:resize",0) >= 0 )
		GetWindow WMImageStatsPanel, wsize
		if((V_right-V_left)<350)
			V_Right=V_left+350
		endif
		
		if((V_bottom-V_top)<250)
			V_bottom=V_top+250
		endif
		
		MoveWindow/W=WMImageStatsPanel V_left, V_top, V_right,V_bottom
	endif
	return 0
End

//===================================================================
Function is_ROIPopProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR imageGraphName= root:Packages:WMImProcess:WMImageStats:imageGraphName
	WAVE/Z w= $WMGetImageWave(imageGraphName)			 
	if( !WaveExists(w) )
		return 0
	endif
	
	NVAR xMin=root:Packages:WMImProcess:WMImageStats:xMin
	NVAR xMax=root:Packages:WMImProcess:WMImageStats:xMax
	NVAR yMin=root:Packages:WMImProcess:WMImageStats:yMin
	NVAR yMax=root:Packages:WMImProcess:WMImageStats:yMax
	
	strswitch(popStr)
		case "All Plane":
			SetVariable is_xminSetVar,disable=1,win=WMImageStatsPanel
			SetVariable is_xmaxSetVar,disable=1,win=WMImageStatsPanel
			SetVariable is_yminSetVar,disable=1,win=WMImageStatsPanel
			SetVariable is_ymaxSetVar,disable=1,win=WMImageStatsPanel
		break
		
		case "Use ROI":
			SetVariable is_xminSetVar,disable=1,win=WMImageStatsPanel
			SetVariable is_xmaxSetVar,disable=1,win=WMImageStatsPanel
			SetVariable is_yminSetVar,disable=1,win=WMImageStatsPanel
			SetVariable is_ymaxSetVar,disable=1,win=WMImageStatsPanel
		break
		
		case "Point Range":
			SetVariable is_xminSetVar,disable=0,win=WMImageStatsPanel
			SetVariable is_xmaxSetVar,disable=0,win=WMImageStatsPanel
			SetVariable is_yminSetVar,disable=0,win=WMImageStatsPanel
			SetVariable is_ymaxSetVar,disable=0,win=WMImageStatsPanel
			xMin=0
			yMin=0
			xMax=DimSize(w,0)-1
			yMax=DimSize(w,1)-1
		break
		
		case "Scaled Range":
			SetVariable is_xminSetVar,disable=0,win=WMImageStatsPanel
			SetVariable is_xmaxSetVar,disable=0,win=WMImageStatsPanel
			SetVariable is_yminSetVar,disable=0,win=WMImageStatsPanel
			SetVariable is_ymaxSetVar,disable=0,win=WMImageStatsPanel
			xMin=DimOffset(w,0)
			yMin=DimOffset(w,1)
			xMax=xMin+(DimSize(w,0)-1)*DimDelta(w,0)
			yMax=yMin+(DimSize(w,1)-1)*DimDelta(w,1)
		break
	endSwitch
	
	if(strlen(popStr)>0)
		WMImageStatsUpdateProc()					// update the stats to the new selection.
	endif
End

//===================================================================
Function WMImageStatsUpdateProc()
	String newImageGraphName= WMTopImageGraph()
	SVAR imageGraphName= root:Packages:WMImProcess:WMImageStats:imageGraphName

	if( CmpStr(newImageGraphName,imageGraphName)!= 0 )
		WMImageStatsNew(newImageGraphName)		
	endif
	imageGraphName= newImageGraphName
	is_DoitButtonProc("")
End

//===================================================================
Function WMImageStatsNew(newImageGraphName)			
	String newImageGraphName
	
	WAVE/Z w= $WMGetImageWave(newImageGraphName)			// the target matrix
	if( !WaveExists(w) )
		return 0
	endif
	
	SVAR imageGraphName= root:Packages:WMImProcess:WMImageStats:imageGraphName
	imageGraphName=newImageGraphName
	NVAR plane=root:Packages:WMImProcess:WMImageStats:Plane
	plane=0
	Variable numLayers=DimSize(w,2)
	if(numLayers>0)
		SetVariable is_PlaneSetVar,disable=0,win=WMImageStatsPanel,limits={0,(numLayers-1),1}
	else
		SetVariable is_PlaneSetVar,disable=1,win=WMImageStatsPanel
	endif
End
//===================================================================
Function is_DoitButtonProc(ctrlName) : ButtonControl
	String ctrlName

	NVAR xMin=root:Packages:WMImProcess:WMImageStats:xMin
	NVAR xMax=root:Packages:WMImProcess:WMImageStats:xMax
	NVAR yMin=root:Packages:WMImProcess:WMImageStats:yMin
	NVAR yMax=root:Packages:WMImProcess:WMImageStats:yMax
	SVAR imageGraphName= root:Packages:WMImProcess:WMImageStats:imageGraphName
	Wave/Z w= $WMGetImageWave(imageGraphName)
	if( !WaveExists(w) )
		return 0
	endif
	
	Variable is3D=0
	if(DimSize(w,2)>0)
		is3D=1
	endif

	NVAR plane=root:Packages:WMImProcess:WMImageStats:Plane
	Variable method=0

	ControlInfo/W=WMImageStatsPanel is_lowestMomentCheck
	if(V_value)
		method=1
	endif
	
	ControlInfo /W=WMImageStatsPanel is_ROIPop
	Variable popnum= V_value
	switch(popNum) 
		case 1:
			if(is3D)
				ImageStats/P=(plane)/M=(method)/Q w
			else
				ImageStats/M=(method)/Q w
			endif
		break
		
		case 2:
			ImageGenerateROIMask/E=1/I=0/W=$imageGraphName $NameOfWave(w)
			if( V_Flag )
				if(is3D)
					ImageStats/P=(plane)/M=(method)/Q/R=M_ROIMask w
				else
					ImageStats/M=(method)/Q/R=M_ROIMask w
				endif
				KillWaves M_ROIMask
			else
				if(is3D)
					ImageStats/P=(plane)/M=(method)/Q  w
				else
					ImageStats/M=(method)/Q  w
				endif
			endif
		break
		
		case 3:		// point range
			if(is3D)
				ImageStats/P=(plane)/M=(method)/Q /G={(xmin),(xmax),(ymin),(ymax)}  w
			else
				ImageStats/M=(method)/Q /G={(xmin),(xmax),(ymin),(ymax)}  w
			endif
		break
		
		case 4:		// scaled range
			if(is3D)
				ImageStats/P=(plane)/M=(method)/Q /GS={(xmin),(xmax),(ymin),(ymax)}  w
			else
				ImageStats/M=(method)/Q /GS={(xmin),(xmax),(ymin),(ymax)}  w
			endif
		break
	endSwitch
	
	// load the wave for display
	Wave wResults=root:Packages:WMImProcess:WMImageStats:wResults
	wResults=NaN
	if(V_Flag==0)
		wResults[0]=V_avg
		wResults[1]=V_min
		wResults[2]=V_max
		wResults[3]=V_minRowLoc
		wResults[4]=V_minColLoc
		wResults[5]=V_maxRowLoc
		wResults[6]=V_maxColLoc
		wResults[7]=V_npnts
		if(method==0)
			wResults[8]=V_adev
			wResults[9]=V_rms
			wResults[10]=V_sdev
			wResults[11]=V_skew
			wResults[12]=V_kurt
		endif
	else
		// can't have an alert here because we can be called from a hook function.
		Print "*** ImageStats encountered an error.  Check that the specified range is valid. ***"
	endif
End
//===================================================================
Function isHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "ImageStats Panel"
End
//===================================================================
