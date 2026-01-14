#pragma rtGlobals=2		// Use modern global access method.
#pragma IgorVersion=4.0
#pragma version=6.35		// shipped with Igor 6.35

#include <Image Common>
 
// the main function call is ImageTransformPanel()

//*********************************************************************************
// 10JUN99
// Procedure file to add a panel that supports the ImageTransform operation.
// This file should be listed in <All IP Procedures> together with entry on the main Image menu.
// This file requires IGOR versions newer than 3.14.  It will not compile on 3.14 Mac or PC.
// 30JAN03 added support for "Invert".  This will require IGOR 4.x
// JP140421 added support for GetPlaneByDimLabel, lifted getPlane limit from 2 to Inf.
//*********************************************************************************
Function xformDoitButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Variable 	isOverwrite
	String 		imageGraphName= WMTopImageGraph()
	String 		flags="",keyword,cmd, cmd2=""
	
	// first check for top image: 
	
	if(strlen(imageGraphName)<=0)
		doAlert 0, "You must have a top image to operate on."
		return 0
	endif
	
	WAVE/Z srcWave= $WMGetImageWave(imageGraphName)

	if(WaveExists(srcWave)==0)
		doAlert 0, "Could not find a wave associated with top image"
		return 0
	endif
		
	ControlInfo xformOverWriteCheck
	isOverwrite=V_value
	if(isOverWrite)
		flags+=" /O "
	endif
	
	ControlInfo xformNamesPop		// find which transform was chosen
	keyword=S_value
	
	strswitch(keyword)
		case "CMap2RGB":
			// get the name of the wave; it needs to be in the current folder
			ControlInfo xformCmapPop
			String cmapWaveName=S_value
			if(WaveExists($cmapWaveName)==0)
				doAlert 0,"You must choose a proper CMap wave in the current data folder."
				return 0
			endif
			
			flags+="/C="+cmapWaveName+" "
		break
		
		case "Convert2gray":
		break
		
		case "GetPlane":
			NVAR PlaneNumber=root:packages:WMImageTransformPanelFolder:PlaneNumber
			flags+="/P="+num2str(PlaneNumber)
		break
		
		case "GetPlaneByDimLabel":
			ControlInfo xformPlaneDimLabelPop
			String PlaneDimLabel=S_value
			Variable plane= FindPlaneFromDimLabel(srcWave,PlaneDimLabel)
			if( numtype(plane) == 0 )
				cmd2= "NewImage M_ImagePlane"
			else
				plane=0	// to prevent a complaint from ImageTransform
				cmd2= "DoAlert 0, \"No plane is labelled with '"+PlaneDimLabel+"'\""
			endif
			keyword= "GetPlane"
			flags+="/P="+num2str(plane)
		break
		
		case "Hough":
			NVAR refFactor=root:packages:WMImageTransformPanelFolder:refFactor
			flags+="/F="+num2str(refFactor)
		break
		
		case "HSLSegment":
			NVAR minHue=root:Packages:WMImageTransformPanelFolder:minHue
			NVAR maxHue=root:Packages:WMImageTransformPanelFolder:maxHue
			NVAR minSaturation=root:Packages:WMImageTransformPanelFolder:minSaturation
			NVAR maxSaturation=root:Packages:WMImageTransformPanelFolder:maxSaturation
			NVAR minLight=root:Packages:WMImageTransformPanelFolder:minLight
			NVAR maxLight=root:Packages:WMImageTransformPanelFolder:maxLight
			String hslOptions
			sprintf hslOptions,"/S={%g,%g}/H={%g,%g}/L={%g,%g}",minSaturation,maxSaturation,minHue,maxHue,minLight,maxLight
			flags+=hslOptions
		break
		
		case "RGB2Gray":
		break
		
		case "RGB2HSL":
			ControlInfo uFlagCheck
			if(V_value==1)
				flags+="/U "
			endif
		break
		
		case "HSL2RGB":
		break
		
		case "PadImage":
			NVAR rowsToAdd=root:Packages:WMImageTransformPanelFolder:rowsToAdd
			NVAR colsToAdd=root:Packages:WMImageTransformPanelFolder:colsToAdd
			ControlInfo xformWrapCheck
			String padOptions
			sprintf padOptions,"/N={%g,%g}",rowsToAdd,colsToAdd
			if(V_value==1)
				flags +="/w"
			endif
			flags+=padOptions
		break
		
		case "Invert":		// 30JAN03 this is a no-op since there are no flags
		break
		
	endswitch

	cmd="ImageTransform "+flags +keyword+" " + WMGetImageWave(imageGraphName)
	Execute cmd
	if( strlen(cmd2) )
		Execute cmd2
	endif
End


//*********************************************************************************
// The following is called when the main keyword popup menu is clicked.  It sets up
// all the controls depending on the user choice of keyword for this operation.
//*********************************************************************************

Function xformNamesPopProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	killControl xformCmapPop
	killControl xformPlaneSetVar
	KillControl minHueSetVar
	KillControl maxHueSetVar
	KillControl minSatSetVar
	KillControl maxSatSetVar
	KillControl minLSetVar
	KillControl maxLSetVar
	KillControl rowsChangeSetVar
	KillControl colsChangeSetVar
	KillControl uFlagCheck
	KillControl xformPlaneDimLabelPop
	
	strswitch(popstr)
		case "CMap2RGB":
			PopupMenu xformCmapPop,pos={25,73},size={146,19},title="CMap Wave:"
			PopupMenu xformCmapPop,mode=1,value= #"rgbWaveList()"
		break
		
		case "GetPlane":
			SetVariable xformPlaneSetVar,pos={26,72},size={150,17},title="Plane Number:"
			SetVariable xformPlaneSetVar,limits={0,Inf,1},value= root:Packages:WMImageTransformPanelFolder:PlaneNumber
		break
		
		case "GetPlaneByDimLabel":	// JP140421
			SVAR PlaneDimLabel= root:Packages:WMImageTransformPanelFolder:PlaneDimLabel
			String dimLabels= PlaneDimLabelsList($"")
			Variable mode= WhichListItem(PlaneDimLabel,dimLabels)+1
			if( mode < 1 )
				PlaneDimLabel= StringFromList(0,dimLabels)	// can be _none_
				mode=1
			endif
			PopupMenu xformPlaneDimLabelPop pos={24,75},size={115,21},value=PlaneDimLabelsList($""),mode=mode
			PopupMenu xformPlaneDimLabelPop title="Plane Dim Label"
		break
		
		case "Hough":
			SetVariable xformPlaneSetVar,pos={26,72},size={170,17},title="Resolution Factor:"
			SetVariable xformPlaneSetVar,limits={0.1,200,.1},value= root:Packages:WMImageTransformPanelFolder:refFactor
		break
		
		case "PadImage":
			SetVariable rowsChangeSetVar,pos={23,69},size={150,17},title="Rows Change:"
			SetVariable rowsChangeSetVar,limits={-Inf,Inf,1},value= root:Packages:WMImageTransformPanelFolder:rowsToAdd
			SetVariable colsChangeSetVar ,pos={183,69},size={150,17},title="Cols Change:"
			SetVariable colsChangeSetVar ,limits={-Inf,Inf,1},value= root:Packages:WMImageTransformPanelFolder:colsToAdd
			CheckBox xformWrapCheck,pos={238,45},size={100,20},title="Wrap Data",value=0
		break
		
		case "RGB2HSL":
			CheckBox uFlagCheck,pos={23,71},size={84,16},title="16 bit result",value= 0
		break
		
		case "HSLSegment":
			// here we are only implementing low-high limits; if you need to use a wave, it should
			// be easy to add a menu here to select proper dimensionality waves
			SetVariable minHueSetVar,pos={14,85},size={110,17},title="Min Hue:"
			SetVariable minHueSetVar,limits={-Inf,Inf,1},value= root:Packages:WMImageTransformPanelFolder:minHue
			SetVariable maxHueSetVar,pos={13,66},size={110,17},title="Max Hue:"
			SetVariable maxHueSetVar,limits={-Inf,Inf,1},value= root:Packages:WMImageTransformPanelFolder:maxHue
			SetVariable minSatSetVar,pos={131,66},size={117,17},title="Min Sat:"
			SetVariable minSatSetVar,limits={-Inf,Inf,1},value= root:Packages:WMImageTransformPanelFolder:minSaturation
			SetVariable maxSatSetVar,pos={131,85},size={117,17},title="Max Sat:"
			SetVariable maxSatSetVar,limits={-Inf,Inf,1},value= root:Packages:WMImageTransformPanelFolder:maxSaturation
			SetVariable minLSetVar,pos={257,66},size={100,17},title="Min L:"
			SetVariable minLSetVar,limits={-Inf,Inf,1},value= root:Packages:WMImageTransformPanelFolder:minLight
			SetVariable maxLSetVar,pos={257,85},size={100,17},title="Max L:"
			SetVariable maxLSetVar,limits={-Inf,Inf,1},value= root:Packages:WMImageTransformPanelFolder:maxLight
		break
		
	endswitch
End


Function ImageTransformPanelInit()
	String curDF=GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WMImageTransformPanelFolder
	Variable/G PlaneNumber=0
	String/G PlaneDimLabel=""
	Variable/G refFactor=1
	Variable/G minHue=0,maxHue=359
	Variable/G minLight=0,maxLight=1
	Variable/G minSaturation=0,maxSaturation=1
	Variable/G rowsToAdd=0,colsToAdd=0
	SetDataFolder curDF
End

//*********************************************************************************
// The following is used to tickle the main popup so that the remaining controls in the window are in sync
// with the selection in the popup.
//*********************************************************************************
Function updateXformPanel()
		ControlInfo xformNamesPop		 
		xformNamesPopProc("",V_value,S_Value)
End

//*********************************************************************************
// This is the main call that initializes the panel or brings it to the front in case it is already there.
//*********************************************************************************
Function ImageTransformPanel() 

	DoWindow/F WMImageTransformPanel
	String/G imageGraphName= WMTopImageGraph()
	
	if( V_Flag==1 )
		AutoPositionWindow/E/M=1/R=$imageGraphName
		return 0
	endif
	
	ImageTransformPanelInit()
	PauseUpdate; Silent 1		// building window...
	NewPanel/k=1 /W=(415,96,790,244) as "Image Transform"
	DoWindow/C WMImageTransformPanel
	Button ImageXformDoitButton,pos={14,115},size={50,20},proc=xformDoitButtonProc,title="Do It"
	PopupMenu xformNamesPop,pos={19,9},size={160,19},proc=xformNamesPopProc,title="Transform:"
	PopupMenu xformNamesPop,mode=1,value= #"\"CMap2RGB;Convert2Gray;GetPlane;GetPlaneByDimLabel;Hough;HSLSegment;PadImage;RGB2Gray;RGB2HSL;HSL2RGB;Invert\""
	CheckBox xformOverWriteCheck,pos={23,45},size={180,20},title="Overwrite source wave",value=0
	Button xformHelp,pos={181,115},size={50,20},proc=xformHelpProc,title="Help"
	ModifyPanel fixedsize=1
	updateXformPanel()
	AutoPositionWindow/E/M=1/R=$imageGraphName
EndMacro


//*********************************************************************************
Function xformHelpProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "ImageTransform"
End


//*********************************************************************************
// creates a wave list of 2D 3 column waves in the current data folder
// for use in cmap popup menu
//*********************************************************************************
Function/s rgbWaveList()
	
	String initialList=WaveList("*",";","DIMS:2")		
	Variable items=ItemsInList(initialList)
	Variable index=0
	String  itemString
	// now remove every wave from the list that does not have 3 columns
	
	for(index=0; index<items;index+=1)
		itemString=StringFromList(index,initialList)
		if(DimSize($itemString,1)!=3)
			initialList=RemoveFromList(itemString,initialList)
			items-=1
			index-=1
		endif
	endfor
	
	return initialList
End

//*********************************************************************************
Function FindPlaneFromDimLabel(threeDWave,PlaneDimLabelStr)
 	Wave threeDWave
 	String PlaneDimLabelStr

 	Variable planes= DimSize(threeDWave,2)
 	if( planes <= 1 )
 		return 0
 	endif
 	Variable plane
 	for( plane=0; plane<planes; plane +=1)
 		String labelStr= GetDimLabel(threeDWave, 2, plane)
 		labelStr= ReplaceString(";", labelStr, "");
		if( CmpStr(labelStr, PlaneDimLabelStr) == 0 )
 			return plane
 		endif
 	endfor
 	
 	return NaN	// not found
End

//*********************************************************************************
Function/S PlaneDimLabelsList(srcWave)
	Wave/Z srcWave	// optional, use $"" for top image wave
	
	if( !WaveExists(srcWave) )
		String imageGraphName= WMTopImageGraph()
		if(strlen(imageGraphName)<=0)
			return "_none_;"
		endif
		WAVE/Z srcWave= $WMGetImageWave(imageGraphName)
		if( !WaveExists(srcWave) )
			return "_none_;"
		endif
	endif
	
 	Variable planes= DimSize(srcWave,2)
 	String list=""
 	Variable plane
 	for( plane=0; plane<planes; plane +=1)
 		String labelStr= GetDimLabel(srcWave, 2, plane)
 		labelStr= ReplaceString(";", labelStr, "");
 		if( strlen(labelStr) )
 			list += labelStr+";"
 		endif
 	endfor
 	if( ItemsInList(list) < 1 )
 		list= "_none_;"
 	endif
	return list
End
