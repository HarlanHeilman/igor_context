#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.23		
#pragma IndependentModule=WMFillContour
#include <Image Contour Slicing>

// NH Testing notes:
// -	Test with a really long wave name as the base of the contour - i.e. rename wave2 to something much longer


// AppendImageToContour.ipf
// version 6.23 - 08/10/2011, NH:
//				- Converted to a Panel, added the ability to select contour to fill, the color table to use, specify the resolution, 
//                       specify the color for outside the boundary for XYZ contours  
//                     - Converted the package to an independent module 
//				- Wave Notes are now used as flags for flat/contour and log/not_log.  Notes appear in created contour image.
//   			  Wave note format is WM[key name]:[0|1];
// version 6.02 - 08/07/2007, JP:
//				Better menu text for WMAppendFillBetweenContours.
// version 6.01 - 04/23/2007, JP:
//				Works better with matrix contours using x and y waves to provide the coordinates.
// version 6 - 09/05/2006, JP:
//				Demoted AppendImageToContour to Proc (which removed a Macros menu item,
//				added Graph menu item, added slicing option (which is what the #include
//				<Image Contour Slicing> is for).
// version 2.0 - 01/24/2001, JP
//				Created image name is made unique, user prompted to remove existing image.
//
strconstant ksFillImgPrefix = "fillImg"
strconstant ksContImgPrefix = "contImg"

Menu "Graph", hideable
	"Fill Between Contours...", WMFillBetweenContours()
End

Structure contourImageInfo
	// Name and wave refs to contour 
	String contourName
	String contourImageName
	String contourDir
	WAVE contour
	WAVE contourX
	WAVE contourY
	WAVE contourZZ
	WAVE contourImage
	WAVE flatContourCTable
	
	// contour settings
	String traceformat
	String dataformat
	String levelsStr
	String recreationStr
	
	// contour image settings
	String cTableStr
	Variable cTablePos
	Variable flipCTableAxis
	Variable extrapolationFactor
	Variable graduated
	Variable nullValue
	Variable logScale
	Variable rows
	Variable cols
	String baseType
	String haxis
	String vaxis
	String flags
	
	// status
	Variable displayed
EndStructure

// Primary panel creation routine - Menu entry point
Function WMFillBetweenContours()
	DoWindow/F FillContourPanel
	if (V_flag != 0)		// Panel already exists
		return 0
	endif

	String currentDF = GetDataFolder(1)
	DFREF dref = GetFillContourPackageDFR()	
	SetDataFolder dref
	String/G SaveDF = currentDF
	
	// Global Control Variables
	Variable/G expansion
	Variable/G rows
	Variable/G cols
	Variable/G immediateUpdate
	Variable/G flipColorTableAxis
	Variable/G logScaleColorTable
	String/G graphName= WinName(0,1)	// top graph
	String/G colorTable
	String/G contourInstanceDir
	
	NVAR xLoc = dref:FillPanelXLoc
	NVAR yLoc = dref:FillPanelYLoc
	
	String contours= ContourNameList("",";")
	String/G contourInstanceName = StringFromList(0,contours)
	
	NewPanel /N=FillContourPanel /W=(xLoc,yLoc, xLoc+394, yLoc+300) /K=1 
	ModifyPanel/W=FillContourPanel fixedSize=1, noedit=1

	// Draw some rectangles to group controls by functionality
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (56797,56797,56797),fillbgc= (56797,56797,56797)
	DrawRect 6,40,384,131
	SetDrawEnv fillfgc= (56797,56797,56797),fillbgc= (56797,56797,56797)
	DrawRect 6,137,384,235
//	SetDrawEnv fillpat= -1,fillfgc= (56797,56797,56797),fillbgc= (56797,56797,56797)
//	DrawRect 6,241,384,311

	// Controls common to matrix and xyz contours		
	PopupMenu SetContourPopup win=FillContourPanel, pos={24,12},size={246,20}, title="Select Contour  ", bodyWidth=150, proc=WMFillContour#SetContourPopupProc, fSize=13,fstyle=1

	TitleBox fillColorTitle win=FillContourPanel, title="Color Fill Options", fixedSize=1, frame=0, pos={15, 44}, size={190, 20}, fsize=13, fstyle=1
	
	PopupMenu SetGraduatedColorPopup value="Flat;Continuous;", title="Colors Between Contours", pos={41,63},size={198,20},fSize=12
	PopupMenu SetGraduatedColorPopup proc=WMFillContour#SetGraduatedFill
	PopupMenu SetFillColorTable,mode=0,bodyWidth=186,value=#"\"*COLORTABLEPOP*\"",pos={41,86},size={254,20},title="Color Table",fSize=12
	PopupMenu SetFillColorTable, proc=WMFillContour#SetColorTable
	
	Checkbox SetFillColorTableFlipAxis value=0, variable=flipColorTableAxis, title="Reverse Colors", pos={62,111},size={103,16},fSize=12
	Checkbox SetFillColorTableFlipAxis proc=WMFillContour#SetColorTableFlipAxis
	Checkbox SetLogScaleColorTable value=0, variable=logScaleColorTable, title="Log Scale Colors", pos={191,111},size={114,16},fSize=12
	Checkbox SetLogScaleColorTable proc=WMFillContour#SetLogScaleColorTableProc
	
	TitleBox resolutionTitle,pos={13,141},size={380,20},title="Resolution and Boundary Options",fSize=13,frame=0,fStyle=1,fixedSize=1
	// Controls for matrix contours, including a default value
	SetVariable MatrixSetExpansion title="Interpolation Factor",bodyWidth=70,value=expansion,pos={44,181},size={188,19},fSize=12
	SetVariable MatrixSetExpansion proc=WMFillContour#SetMatrixInterpFactor, limits={1,inf,1}
	
	// Controls for XYZ contours
	SetVariable XYZSetNRows pos={44,165},size={169,19},title="Horizontal Pixels",bodyWidth=70,value=rows,fSize=12
	SetVariable XYZSetNRows proc=WMFillContour#SetXYZNRows
	SetVariable XYZSetNCols pos={59,189},size={154,19},title="Vertical Pixels",bodyWidth=70,value=cols,fSize=12
	SetVariable XYZSetNCols proc=WMFillContour#SetXYZNCols
	Button XYZAutoNRowsNCols,pos={218,178},size={150,20},proc=WMFillContour#AutoCalcNPixels,title="Set to Window Size"
	PopupMenu XYZSetNullVals,pos={23,211},size={298,20},title="Values Outside Contour Boundary:",fSize=12
	PopupMenu XYZSetNullVals,mode=1,popvalue="Transparent",value= #"\"Transparent;Max Value;Min Value\"", proc=WMFillContour#setNullValsPopup

	// Update immediately, or delay updates
	Checkbox SetImmediateUpdate value=0, variable=immediateUpdate, title="Live Update", fsize=12, pos={17,244},size={133,16}
	Checkbox SetImmediateUpdate proc=WMFillContour#SetImmediateUpdate
	
	Button RecalcContourToImageButton,pos={160,244},size={170,20},proc=WMFillContour#RecalcContourToImageProc,title="Recalc Contour using Fill"
	
	// Update, Remove and Help Buttons
	Button FillContourDoItButton,pos={17,270},size={130,20},proc=WMFillContour#FillContourDoItButtonProc,title="Append Fill Image"
	Button FillContourHelpButton,pos={298,270},size={70,20},proc=WMFillContour#FillContourHelpButtonProc,title="Help"
	Button FillContourRemoveImgButton,pos={161,270},size={126,20},title="Remove Fill Image",proc=WMFillContour#RemoveFillImgButtonProc

	SetWindow FillContourPanel, hook(appendHook)=WMFillContour#ContourFillHook
	
	//Initialize control values
	InitializePanel()
	
	SetDatafolder SaveDF
	
	return 0
End	
	
/////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Control Update Functions ////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
Function SetImmediateUpdate (ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if selected, 0 if not

	DFREF dref = GetFillContourPackageDFR()

	NVAR immediateUpdate = dref:immediateUpdate

	if (checked)
		immediateUpdate=1
		ModifyControl FillContourDoItButton disable=2
		DoFillUpdate()
	else
		immediateUpdate=0
		ModifyControl FillContourDoItButton disable=0
	endif
End

Function SetGraduatedFill (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr
	
	DFREF dref = GetFillContourPackageDFR()
	NVAR immediateUpdate = dref:immediateUpdate
	
	if(immediateUpdate)
		DoFillUpdate()
	endif
End

Function SetColorTable (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr

	DFREF dref = GetFillContourPackageDFR()
	NVAR immediateUpdate = dref:immediateUpdate
	
	if(immediateUpdate)
		DoFillUpdate()
	endif	
End

Function SetColorTableFlipAxis (ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if selected, 0 if not

	DFREF dref = GetFillContourPackageDFR()
	NVAR immediateUpdate = dref:immediateUpdate
	
	if(immediateUpdate)
		DoFillUpdate()
	endif	
End

Function SetLogScaleColorTableProc (ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if selected, 0 if not

	DFREF dref = GetFillContourPackageDFR()
	NVAR immediateUpdate = dref:immediateUpdate
	
	if(immediateUpdate)
		DoFillUpdate()
	endif	
End

Function SetMatrixInterpFactor (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName		// name of variable

	DFREF dref = GetFillContourPackageDFR()
	NVAR immediateUpdate = dref:immediateUpdate
	
	if(immediateUpdate)
		DoFillUpdate()
	endif	
End

Function SetXYZNRows (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName		// name of variable

	DFREF dref = GetFillContourPackageDFR()
	NVAR immediateUpdate = dref:immediateUpdate
	
	if(immediateUpdate)
		DoFillUpdate()
	endif	
End

Function SetXYZNCols (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	
	String varStr		
	String varName		

	DFREF dref = GetFillContourPackageDFR()
	NVAR immediateUpdate = dref:immediateUpdate
	
	if(immediateUpdate)
		DoFillUpdate()
	endif	
End
              
Function SetContourPopupProc (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr
	
      DFREF dref = GetFillContourPackageDFR()
      
      InitializeContourOptions(popStr)
End

Function FillContourDoItButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DoFillUpdate()
End

Function RecalcContourToImageProc(ctrlName) : ButtonControl
	String ctrlName

	Variable i, j
	String currTraceName

	// get the contour and contour image names
	DFREF dref = GetFillContourPackageDFR()	
	SVAR graphName = dref:graphName
	SVAR gContourInstanceName = dref:contourInstanceName
	String contourInstanceName = gContourInstanceName

	Struct contourImageInfo cImageInfo
	Variable fillImageExists = getExistingContourImageVals(graphName, contourInstanceName, cImageInfo)
	
	// get the contour information string
	String contourInfoStr = ContourInfo(graphName, contourInstanceName, 0) // NH DEV NOTE: is an instanceNumber necessary?  Or does contourInstanceName take care of it?
	String contourForModify = cImageInfo.contourImageName

	// get the trace information for each trace
//	TraceInfo(graphNameStr, yWaveNameStr, instance )

	String traceNames = TraceNameList(graphName, ";", 2)	// bit 1 for contour traces
 	Variable nTraces = ItemsInList(traceNames)
 	Make /FREE/T/N=(nTraces) traceRecWave
	for (i=0; i<nTraces; i+=1)
		currTraceName = StringFromList(i, traceNames)
			
		if (stringmatch(currTraceName, "*"+contourInstanceName+"*"))
			String info = TraceInfo(graphName, currTraceName, 0)
			traceRecWave[i] = info[strsearch(info, "RECREATION:", 0)+11, strlen(info)-1]
		endif
	endfor

	// recalculate the contour using AppendMatrixContour with the associated image
	
	// NH DEV NOTE: figure out conditions that require supplying the vs {xWave, yWave} argument, 
	//					 also that require the /L/R/B or /T arguments
	//					 also the /F=formatStr, although possibly that can be done with ModifyContour
	
	// If the image is flat, make a temporary continuous image, then appendMatrixContour to that, then delete the temp image
	if (!cImageInfo.graduated)
			
		// Global Variables
		NVAR expansion = dref:expansion
		NVAR rows = dref:rows
		NVAR cols = dref:cols
	
		// get contour image name and statistics
		WAVE contourImage= ContourNameToWaveRef(graphName,contourInstanceName)	// matrix wave, triplet wave, or z wave of x,y,z contour
		
		//determine if the image should be graduated or flat
		ControlInfo /W=FillContourPanel SetGraduatedColorPopup
		Variable doSlice= V_Value == 1	// 1 is Flat, 2 is graduated/continuous
	
		// matrix row and col values are determined by expansion and matrix dimensions
		if ((CmpStr(cImageInfo.baseType,"Matrix") == 0) && !WaveExists(cImageInfo.contourX) && !WaveExists(cImageInfo.contourY))
			rows= expansion * DimSize(contourImage,0)
	  		cols=  expansion * DimSize(contourImage,1)
		endif
		
		// is the graph axis flipped?
		Variable flippedRows=rows, flippedCols=cols
		String commands=WinRecreation(graphName,4)
		if (strsearch(commands, "swapXY=1",0) >= 0)
			flippedRows = cols
			flippedCols = rows
		endif
		
		// create a new image
		String contName =  WMCreatedFillImagePathName(cImageInfo.contourName, cImageInfo.contour, graphName, alternatePrefix=ksContImgPrefix)
		String pathToImage = WMCreateImageForContour2(graphName,contourInstanceName,0,flippedRows,flippedCols,cImageInfo,preSetWaveName=contName)
		contourForModify = contName
		
		// delete the old contour
		RemoveContour /W=$graphName $contourInstanceName
		
		// append the new contour
		AppendMatrixContour /W=$graphName $pathToImage
		
		// update the Fill Between Contours panel
		InitializePanel()
	else
		// delete the old contour
		RemoveContour /W=$graphName $contourInstanceName	
	
		// append the new contour
		AppendMatrixContour /W=$graphName $(cImageInfo.contourImageName)
	endif

	// reapply the contour information
	String pathlessContourName = parseFilePath(0,contourForModify, ":", 1, 0)
	Variable nFlags = ItemsInList(cImageInfo.recreationStr)
	String ModifyArgs = ""
	for (i=0; i<nFlags; i+=1)
		String keyVal = StringFromList(i,cImageInfo.recreationStr, ";")
		if (strlen(keyVal)-strsearch(keyVal, "=", 0)-1 > 0)
			if (i>0)
				ModifyArgs += ","
			endif
			ModifyArgs += keyVal
		endif
	endfor
	Execute "ModifyContour /W="+graphName+" "+pathlessContourName+" "+ModifyArgs

	String newTraceNameList =  TraceNameList(graphName, ";", 2)	
	String contourNameForTrace = pathlessContourName
	String oldTraceName
	if (strlen(newTraceNameList)>0)
		oldTraceName = StringFromList(0, newTraceNameList)
		contourNameForTrace = pathlessContourName[0, strsearch(oldTraceName, "=", 0)-(CmpStr(oldTraceName[0], "'")?1:2)]
	endif

	for (i=0; i<nTraces; i+=1)
		oldTraceName = StringFromList(i, traceNames)
		String newTraceName = ReplaceString(contourInstanceName, oldTraceName, contourNameForTrace)
		
		if (strsearch(newTraceNameList, newTraceName, 0)>=0) 
			if (strlen(traceRecWave[i])>0)
				String modifyStr = ReplaceString("(x)",traceRecWave[i],"("+newTraceName+")")
				Variable nTraceRecChars = strlen(modifyStr)
				Variable iModifyStr = 0, iEndStr
				do
					iEndStr = nTraceRecChars - iModifyStr	> 350 ? strsearch(modifyStr, ";", iModifyStr+350, 1)-1 : nTraceRecChars-2
					String currModKeyVals = ReplaceString(";",modifyStr[iModifyStr, iEndStr],",")
					String cmd = "ModifyGraph /W="+graphName+" "+currModKeyVals 
					Execute /Z cmd
					iModifyStr = iEndStr+2
				while (nTraceRecChars - iModifyStr > 0)
			endif
		endif
	endfor	
End

Function RemoveFillImgButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DFREF dref = GetFillContourPackageDFR()	
	SVAR graphName = dref:graphName
	SVAR contourInstanceName = dref:contourInstanceName

	Struct contourImageInfo cImageInfo
	Variable fillImageExists = getExistingContourImageVals (graphName, contourInstanceName, cImageInfo)

	RemoveImage /W=$graphName $(cImageInfo.contourImageName)
	KillWaves /Z $(cImageInfo.contourImageName)
	
	ModifyControl FillContourDoItButton win=FillContourPanel, disable=0, title="Append Fill Image"
	ModifyControl FillContourRemoveImgButton win=FillContourPanel, disable=2
	ModifyControl RecalcContourToImageButton win=FillContourPanel, disable=2
	Checkbox SetImmediateUpdate win=FillContourPanel, value=0, disable=2
End

Function SetNullValsPopup (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr
	
	DFREF dref = GetFillContourPackageDFR()
	NVAR immediateUpdate = dref:immediateUpdate
	
	if(immediateUpdate)
		DoFillUpdate()
	endif
End

Function AutoCalcNPixels(ctrlName):ButtonControl
	String ctrlName
	
 	DFREF dref = GetFillContourPackageDFR()
	NVAR rows = dref:rows
	NVAR cols = dref:cols
	SVAR graphName = dref:graphName
	NVAR immediateUpdate = dref:immediateUpdate
	
	String commands=WinRecreation(graphName,4)
	Variable swapXY = strsearch(commands, "swapXY=1",0) >= 0
	
	GetWindow $graphName, psizeDC	// pixels V_left, V_right, V_top, and V_bottom
	rows=V_right-V_left
	cols=V_bottom-V_top
	
	// limit default to something speedy
	if( rows > 1024 )
		rows= 1024
	endif
	if( cols > 1024 )
		cols= 1024
	endif
	
	if(immediateUpdate)
		DoFillUpdate()
	endif
End

Function FillContourHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "Fill Between Contours"
End

Function deactivateControls()
	PopupMenu SetContourPopup value="_none_"
	
	// arbitrarily hide matrix only controls and show unmodifiable XYZ controls
	ModifyControlList ControlNameList("FillContourPanel", ";", "*") disable=2
	ModifyControlList ControlNameList("FillContourPanel", ";", "Matrix*") disable=1
	ModifyControlList "FillContourHelpButton" disable=0
End

//////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// Window Hook Function ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

Function ContourFillHook(s)
	Struct WMWinHookStruct &s
	
	DFREF dref = GetFillContourPackageDFR()
	SVAR SaveDF = dref:SaveDF
	SVAR graphName = dref:graphName
	SVAR contourInstanceName = dref:contourInstanceName
	
	graphName = WinName(0,1)
	
	strswitch(s.eventName)
		case "Activate":
			InitializePanel()
			break
			
		case "Kill":
			// clean up old variables (except FillPanelXLoc and ...YLoc, which locate the Panel at spot previously killed)	
			SetDataFolder SaveDF			
			KillVariables /Z dref:expansion, dref:rows, dref:cols, dref:immediateUpdate, dref:logScaleColorTable, dref:flipColorTableAxis
			KillStrings /Z dref:graphName, dref:colorTable, dref:SaveDF, dref:contourInstanceName						
			break
			
		case "moved"://keep track of the window location
			GetWindow FillContourPanel wsize
			NVAR xLoc = dref:FillPanelXLoc
			NVAR yLoc = dref:FillPanelYLoc
			
			xLoc = V_Left
			YLoc = V_Top
			
			// some attempts to activate can be interpreted as moves.  Initialize the panel as well just in case
			InitializePanel()
			break
	endswitch
End

//////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// Initialize Panel Values ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

Function InitializePanel()
	DFREF dref = GetFillContourPackageDFR()
	SVAR graphName = dref:graphName
	SVAR contourInstanceName = dref:contourInstanceName
	SVAR/Z contourInstanceDir = dref:contourInstanceDir

	DoWindow /T FillContourPanel "Fill Between Contours for " + graphName
			
	//Make sure controls are active
	ModifyControlList ControlNameList("FillContourPanel", ";", "*") disable=0	
			
	// if the current contourInstanceName is on the current window, select it.  otherwise select the first one.  otherwise set it to "_none_"
	String/G contourListStr = ContourNameList("", ";")
	
	// handle the unusual but possible instance that there's multiple contours from the same wave on a graph, differentiated by "#[number]"
	String noPoundContourName = contourInstanceName
	Variable poundLocation = strsearch(contourInstanceName, "#", inf, 1)
	Variable contourInstanceNumber = str2num(contourInstanceName[poundLocation+1,inf])
	if (numtype(contourInstanceNumber) != 2)
		noPoundContourName = noPoundContourName[0, poundLocation-1]
	endif
	
	Variable indx=WhichListItem(contourInstanceName, contourListStr)
	
	if (exists(contourInstanceDir + noPoundContourName) && indx>=0)
		InitializeContourOptions(contourInstanceName)
		PopupMenu SetContourPopup win=FillContourPanel, value=ContourNameList(WinName(0,1),";"), mode=indx+1
	elseif (ItemsInList(contourListStr)>0)
		InitializeContourOptions(StringFromList(0,contourListStr))
		PopupMenu SetContourPopup win=FillContourPanel, value=ContourNameList(WinName(0,1),";"), mode=1
	else 
		deactivateControls()
	endif
End

Function InitializeContourOptions(contourName)
	String contourName
	
	DFREF dref = GetFillContourPackageDFR()
	
	// Global variables in the AppendFillBetweenContours folder
	NVAR expansion = dref:expansion
	NVAR rows = dref:rows
	NVAR cols = dref:cols
	NVAR immediateUpdate = dref:immediateUpdate
	NVAR flipColorTableAxis = dref:flipColorTableAxis
	NVAR logScaleColorTable = dref:logScaleColorTable
	SVAR graphName = dref:graphName
	SVAR contourInstanceName = dref:contourInstanceName
	SVAR contourInstanceDir = dref:contourInstanceDir
	
	// set the new contourInstanceName
	contourInstanceName = contourName

	Struct contourImageInfo cImageInfo
	Variable fillImageExists = getExistingContourImageVals (graphName, contourName, cImageInfo)
	
	// record the contour's source directory
	contourInstanceDir = cImageInfo.contourDir
	
	PopupMenu SetFillColorTable win=FillContourPanel, mode=cImageInfo.cTablePos    //getExisting... sets the cTable to the contour's value if the image doesn't exist
	
	String commands=WinRecreation(graphName,4)
	Variable swapXY = strsearch(commands, "swapXY=1",0) >= 0
	
	if (fillImageExists)
		Variable gradYesNo = (cImageInfo.graduated==0) ? 1:2   // 1==Yes, 2==No
		PopupMenu SetGraduatedColorPopup win=FillContourPanel, mode=gradYesNo
	
		// color fill
		flipColorTableAxis=cImageInfo.flipCTableAxis
		// log values
		logScaleColorTable = cImageInfo.logScale
		// contour null values: Actual Null value is stored in cImageInfo.  Transparent is Nan, but Min or Max must be determined.
		if (numtype(cImageInfo.nullValue)==2)
			PopupMenu XYZSetNullVals win=FillContourPanel, mode=1
		else
			PopupMenu XYZSetNullVals win=FillContourPanel, mode=cImageInfo.nullValue
		
			Variable cMin 
			Variable cMax
			if (CmpStr(cImageInfo.baseType,"XYZMatrix")==0)
				cMin = wavemin(cImageInfo.contour, DimSize(cImageInfo.contour,0)*2, DimSize(cImageInfo.contour,0)*3-1)
				cMax = wavemax(cImageInfo.contour, DimSize(cImageInfo.contour,0)*2, DimSize(cImageInfo.contour,0)*3-1)
			else
				cMin = wavemin(cImageInfo.contour)
				cMax = wavemax(cImageInfo.contour)
			endif
			Variable nullValMode = abs(cMin-cImageInfo.nullValue) < abs(cMax-cImageInfo.nullValue) ? 3 : 2
			PopupMenu XYZSetNullVals win=FillContourPanel, mode=nullValMode
		endif
		
		// Controls for XYZ contours
		if (CmpStr(cImageInfo.baseType,"Matrix")==0)
			expansion = cImageInfo.extrapolationFactor
		else
			rows = swapXY ? cImageInfo.cols : cImageInfo.rows
			cols  = swapXY ? cImageInfo.rows : cImageInfo.cols
		endif
		
		ModifyControl FillContourRemoveImgButton win=FillContourPanel, disable=0
		ModifyControl RecalcContourToImageButton win=FillContourPanel, disable=0
		
		if (immediateUpdate)
			ModifyControl FillContourDoItButton win=FillContourPanel, disable=2, title="Update Fill Image"
		else
			ModifyControl FillContourDoItButton win=FillContourPanel, disable=0, title="Update Fill Image"
		endif
	else
		// choose rows, cols (for xyz contours) based on plot area in pixels,
		GetWindow $graphName, psizeDC	// pixels V_left, V_right, V_top, and V_bottom
		rows=V_right-V_left
		cols=V_bottom-V_top
	
		//default expansion values
		expansion=ceil(rows/DimSize(cImageInfo.contour,0))
		expansion= max(expansion, ceil(cols/DimSize(cImageInfo.contour,1)))
		
		// limit default to something speedy
		if( rows > 1024 )
			rows= 1024
		endif
		if( cols > 1024 )
			cols= 1024
		endif
		
		// Make sure the Append/Update button and immediate update checkbox are correctly labeled
		ModifyControl FillContourDoItButton win=FillContourPanel, disable=0, title="Append Fill Image"
		Checkbox SetImmediateUpdate win=FillContourPanel, value=0, disable=2
		ModifyControl FillContourRemoveImgButton win=FillContourPanel, disable=2
		ModifyControl RecalcContourToImageButton win=FillContourPanel, disable=2
	endif
		
	if (CmpStr(cImageInfo.baseType,"Matrix") == 0 && !WaveExists(cImageInfo.contourX) && !WaveExists(cImageInfo.contourY))
		ModifyControlList ControlNameList("FillContourPanel", ";", "Matrix*") win=FillContourPanel, disable=0
		ModifyControlList ControlNameList("FillContourPanel", ";", "XYZ*") win=FillContourPanel, disable=1
	else
		ModifyControlList ControlNameList("FillContourPanel", ";", "Matrix*") win=FillContourPanel, disable=1
		ModifyControlList ControlNameList("FillContourPanel", ";", "XYZ*") win=FillContourPanel, disable=0		
	endif
End

////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////Get Set Package Data Folder ///////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function InitFillContourPackageData(dfr)
	DFREF dfr

	Variable/G dfr:FillPanelXLoc = 200
	Variable/G dfr:FillPanelYLoc = 200
End

// Creates the data folder if it does not already exist.  Includes X and Y locations for maintaining panel position when killed then re-created
Function /DF GetFillContourPackageDFR()
	DFREF dfr = root:Packages:FillBetweenContours
	if (DataFolderRefStatus(dfr) != 1)
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:FillBetweenContours
		DFREF dfr = root:Packages:FillBetweenContours
		InitFillContourPackageData(dfr)
	endif
	if (!exists("root:Packages:FillBetweenContours:FillPanelXLoc"))
		Variable/G dfr:FillPanelXLoc=200
		Variable/G dfr:FillPanelYLoc=200
	endif
	return dfr
End

////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Contour functions //////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

// getExistingContourImageVals assumes that contour fill images have a pre defined name given by WMCreatedFillImagePathName(), which
// takes the graph and the contour names as arguments
Function getExistingContourImageVals (graphName, contourName, cImageInfo)
	String graphName
	String contourName
	// structure passed as argument to use as return value
	Struct contourImageInfo &cImageInfo
	
	// basic contour information
	cImageInfo.contourName = contourName
	Wave cImageInfo.contour = ContourNameToWaveRef(graphName, contourName)
	
	// Get contour Information
	String info=ContourInfo(graphName,contourName,0)
	
	cImageInfo.haxis= StringByKey("XAXIS",info)
	cImageInfo.vaxis= StringByKey("YAXIS",info)
	String xwavePath= StringByKey("XWAVE",info)
	String xwaveDir = StringByKey("XWAVEDF",info)
	String ywavePath= StringByKey("YWAVE",info)
	String ywaveDir = StringByKey("YWAVEDF",info)
	String zwavePath= StringByKey("ZWAVE",info)
	String zwaveDir = StringByKey("ZWAVEDF",info)
	WAVE/Z cImageInfo.contourX=$(xwaveDir+xwavePath)
	WAVE/Z cImageInfo.contourY=$(ywaveDir+ywavePath)
	WAVE/Z cImageInfo.contourZZ=$(zwaveDir+zwavePath)
	cImageInfo.flags= StringByKey("AXISFLAGS",info)
	cImageInfo.baseType = StringByKey("DATAFORMAT",info)
	if (CmpStr(cImageInfo.baseType, "XYZ")==0 && WaveExists(cImageInfo.contourX)==0 && WaveExists(cImageInfo.contourY)==0 && DimSize(cImageInfo.contour,1)>=3)
		cImageInfo.baseType="XYZMatrix"	
	endif
	
	cImageInfo.traceformat = StringByKey("TRACEFORMAT",info)
	cImageInfo.dataformat = StringByKey("DATAFORMAT",info)
	cImageInfo.levelsStr = StringByKey("LEVELS",info)
	Variable iRECREATION = strsearch(info, "RECREATION:", 0)
	if (strlen(info)-1 > iRECREATION+11)
		cImageInfo.recreationStr = info[iRECREATION+11,strlen(info)-1]
	endif
	
//	cImageInfo.recreationStr = StringByKey("RECREATION",info)
	
	// determine existence of fill image in the graph.  Originally (prior to 4/2016) compared image wave 
	// names in the graph to the wave name created by WMCreatedFillImagePathName.  
	// Problem arises when the fill image does not exactly derive from the graph name.  This can happen
	// in the case of graph copies, or if the graph is renamed.  I will add a wave note in the "fillImg..." 
	// and "contImg..." waves indicating that the image was created as a fill image for a given countour.
	// For contours created using older versions of FillBetweenContours we'll compare the name as done orignially
	Variable foundMatch=0
	String imageNames = ImageNameList(graphName, ";")
	Variable i, nImages = ItemsInList(imageNames)
	for (i=0; i<nImages; i+=1)
		String currImageName = StringFromList(i, imageNames)
		if (StringMatch(currImageName, ksFillImgPrefix+"*"))
			Wave currImage = ImageNameToWaveRef(graphName, currImageName)
			String currContourName = StringByKey("WMBaseContourName", note(currImage), ":")
			if (!CmpStr(contourName, currContourName))
				cImageInfo.contourImageName = currImageName
				cImageInfo.contourDir = GetWavesDataFolder(currImage, 1)
				WAVE cImageInfo.contourImage = currImage
				foundMatch = 1
				break
			endif
		endif
	endfor
	
	if (!foundMatch)
		String contourNameFullPath = WMCreatedFillImagePathName(cImageInfo.contourName, cImageInfo.contour, graphName) 
		cImageInfo.contourImageName = ParseFilePath(0, contourNameFullPath , ":", 1, 0)
		cImageInfo.contourDir = ParseFilePath(1, contourNameFullPath, ":", 1, 0)
		WAVE/Z cImageInfo.contourImage = ImageNameToWaveRef(graphName, cImageInfo.contourImageName)
	endif
	
	// if it exists and is displayed, collect information about it
	String currCTablePosStr
	if (waveExists(cImageInfo.contourImage) && ImageIsDisplayed(graphName, cImageInfo.contourImage))
		cImageInfo.displayed = 1
		
		// get color table recreation string
		cImageInfo.cTableStr = getColorTableFromGraphObject(graphName, cImageInfo.contourImageName, 0, "image")
		currCTablePosStr = StringFromList(2, cImageInfo.cTableStr, ",")		
		
		cImageInfo.flipCTableAxis = str2num(StringFromList(3,cImageInfo.cTableStr,","))
		
		cImageInfo.cTablePos = WhichListItem(currCTablePosStr, CTabList(), ";", 0, 0)+1
		if (cImageInfo.cTablePos <=0)
			cImageInfo.cTableStr = "{*,*,"+StringFromList(0, CTabList())+",0}"
			cImageInfo.cTablePos = 1
		endif
	 	
	 	//////////// Get Image information stored in the wave note ////////////
		// If a contour is flat stick a wave note in the wave.  If its there, use it, otherwise assume graduated
		// Wave note in a ";" separated list of "WMgraduatedImage:0" means its flat
		String wavenote = note(cImageInfo.contourImage)
		String flagString = StringByKey("WMgraduatedImage", wavenote, ":")
		cImageInfo.graduated = str2num(flagString) ? 1:0	
		// Check if a contour has log scaling
		flagString = StringByKey("WMlogScaleImage", wavenote, ":")
		cImageInfo.logScale = str2num(flagString) ? 1:0	
		// get the contour's nullvalue (nan is the default)
		flagString = StringByKey("WMcontourNullValue", wavenote, ":")
		cImageInfo.nullValue = str2num(flagString)

		// show options for rows if its an XYZ plot or a matrix plot with adjusted X and/or Y axes, otherwise give the ability
		// to increase resolution via an "extrapolation" factor
		if ((CmpStr(cImageInfo.baseType,"Matrix") == 0) && !WaveExists(cImageInfo.contourX) && !WaveExists(cImageInfo.contourY))
			cImageInfo.extrapolationFactor = ceil(DimSize(cImageInfo.contourImage,0)/DimSize(cImageInfo.contour,0))
		else
			cImageInfo.rows = DimSize(cImageInfo.contourImage,0)
			cImageInfo.cols = DimSize(cImageInfo.contourImage,1)
		endif
	else 
		cImageInfo.displayed = 0
		cImageInfo.cTableStr = getColorTableFromGraphObject(graphName, cImageInfo.contourName, 0, "contour")
		currCTablePosStr = StringFromList(2, cImageInfo.cTableStr, ",")
		cImageInfo.cTablePos = WhichListItem(currCTablePosStr, CTabList(), ";", 0, 0)+1
		if (cImageInfo.cTablePos <=0)
			cImageInfo.cTableStr = "{*,*,"+StringFromList(0, CTabList())+",0}"
			cImageInfo.cTablePos = 1
		endif
		cImageInfo.extrapolationFactor = NaN
		cImageInfo.graduated = NaN
		cImageInfo.nullValue=NaN
		return 0
	endif
	
	return 1
End

// Parse the ImageInfo or ContourInfo string to get the color table reacreation string
// Unfortunately different graph objects have different ways of storing color table data
Function/S getColorTableFromGraphObject(graphName, objectName, instanceNumber, type)
	String graphName, objectName, type
	Variable instanceNumber
	
  	String info
  	String ret
	
	strswitch(type)
		case "image":
			info = ImageInfo(graphName, objectName, instanceNumber)
			String recreation = StringByKey("RECREATION", info)
			ret = StringByKey("ctab", recreation, "=")
			break
		case "contour":
			info = ContourInfo(graphName, objectName, instanceNumber)	
			ret = StringByKey("ctabLines", info, "=")
			break
		default:
			ret=""
	endswitch
	
	return ret
End

///////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// DO IT: update/append Function /////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

Function DoFillUpdate()
	String SaveDF = GetDatafolder(1)
	DFREF dref = GetFillContourPackageDFR()
	
	// Global Variables
	NVAR expansion = dref:expansion
	NVAR rows = dref:rows
	NVAR cols = dref:cols
	NVAR immediateUpdate = dref:immediateUpdate
	SVAR graphName = dref:graphName
	SVAR contourInstanceName = dref:contourInstanceName

	// get contour image name and statistics
	WAVE contourImage= ContourNameToWaveRef(graphName,contourInstanceName)	// matrix wave, triplet wave, or z wave of x,y,z contour

	Struct contourImageInfo cImageInfo
	Variable fillImageExists = getExistingContourImageVals (graphName, contourInstanceName, cImageInfo)
	
	//Get the Color Table to use
	ControlInfo /W=FillContourPanel SetFillColorTable
	String cTable = S_Value
	//Flip the Color Table axis?	
	ControlInfo /W=FillContourPanel SetFillColorTableFlipAxis
	Variable cTableFlipAxis = V_Value
	//Use a log scale Image
	ControlInfo /W=FillContourPanel SetLogScaleColorTable
	Variable cTableLogScale = V_Value
	
	//determine if the image should be graduated or flat
	ControlInfo /W=FillContourPanel SetGraduatedColorPopup
	Variable doSlice= V_Value == 1	// 1 is Flat, 2 is graduated/continuous

	//determine contour nullvalue (what to do outside the bounds of an XYZ contour)
	ControlInfo /W=FillContourPanel XYZSetNullVals
	strswitch (S_Value)
		case "Transparent":
			cImageInfo.nullValue=NaN
			break
		case "Max Value":
			if (CmpStr(cImageInfo.baseType, "XYZMatrix")==0)
				cImageInfo.nullValue=waveMax(cImageInfo.contour, DimSize(cImageInfo.contour,0)*2, DimSize(cImageInfo.contour,0)*3-1)
		 	else
		 		cImageInfo.nullValue=waveMax(cImageInfo.contour)
		 	endif
			break
		case "Min Value":
			if (CmpStr(cImageInfo.baseType, "XYZMatrix")==0)
				cImageInfo.nullValue=waveMin(cImageInfo.contour, DimSize(cImageInfo.contour,0)*2, DimSize(cImageInfo.contour,0)*3-1)
		 	else
		 		cImageInfo.nullValue=waveMin(cImageInfo.contour)
		 	endif
			break
		default:
			cImageInfo.nullValue=NaN
	endswitch

	// matrix row and col values are determined by expansion and matrix dimensions
	if ((CmpStr(cImageInfo.baseType,"Matrix") == 0) && !WaveExists(cImageInfo.contourX) && !WaveExists(cImageInfo.contourY))
		rows= expansion * DimSize(contourImage,0)
  		cols=  expansion * DimSize(contourImage,1)
	endif
	
	// is the graph axis flipped?
	Variable flippedRows=rows, flippedCols=cols
	String commands=WinRecreation(graphName,4)
	if (strsearch(commands, "swapXY=1",0) >= 0)
		flippedRows = cols
		flippedCols = rows
	endif
	
	// create/update image
	String pathToImage
	if (fillImageExists)
		pathToImage = WMCreateImageForContour2(graphName,contourInstanceName,doSlice,flippedRows,flippedCols,cImageInfo,preSetWaveName=cImageInfo.contourImageName)
	else
		pathToImage = WMCreateImageForContour2(graphName,contourInstanceName,doSlice,flippedRows,flippedCols,cImageInfo)	
	endif
	
	// Note if it is log scale
	Wave image = $pathToImage
	if (cTableLogScale)
		insertChangeWavenoteFlag(image, "WMlogScaleImage", num2str(1))
	else
		insertChangeWavenoteFlag(image, "WMlogScaleImage", num2str(0))	
	endif
	
	//Put the image in the graph
	String imageNameNoPath = ParseFilePath(0, pathToImage, ":", 1, 0)
	String cmd
	if (fillImageExists)
		String currNote = note(cImageInfo.contourImage)
		Note /K $pathToImage, note(cImageInfo.contourImage)
//		cImageInfo
		ReplaceWave /W=$graphName image=$imageNameNoPath, cImageInfo.contourImage
		sprintf cmd, "ModifyImage/W=%s %s, ctab={*,*,%s,%d}, log=%d", graphName, imageNameNoPath, cTable, cTableFlipAxis,cTableLogScale
		Execute cmd
	else
 		sprintf cmd,"AppendImage%s/W=%s %s; ModifyImage/W=%s %s, ctab={*,*,%s,%d}, log=%d", cImageInfo.flags,graphName,pathToImage,graphName,imageNameNoPath,cTable,cTableFlipAxis,cTableLogScale
		Execute cmd
	endif

	//Update controls
	Checkbox SetImmediateUpdate win=FillContourPanel, disable=0
	ModifyControl FillContourRemoveImgButton win=FillContourPanel, disable=0
	ModifyControl RecalcContourToImageButton win=FillContourPanel, disable=0
	if (immediateUpdate)
		ModifyControl FillContourDoItButton win=FillContourPanel, title="Update Fill Image", disable=2
	else
		ModifyControl FillContourDoItButton win=FillContourPanel, title="Update Fill Image", disable=0
	endif

	SetDataFolder SaveDF
	
	return 1	// truth an image was appended or altered
End

// inverse of ImageNameToWaveRef()
Function/S ImageDisplayedName(graphName, image)
	String graphName
	Wave image
	
	String pathToImage=  GetWavesDataFolder(image,2)
	String images=ImageNameList(graphName,";")
	Variable i=0
	do
		String imageName= StringFromList(i, images)
		if( strlen(imageName) == 0 )
			break
		endif
		Wave w= ImageNameToWaveRef(graphName,imageName)
		String pathToW=GetWavesDataFolder(w,2)
		if( CmpStr(pathToImage, pathToW) == 0 )
			return imageName
		endif
		i+=1
	while(1)

	return ""
End

Function ImageIsDisplayed(graphName,image)
	String graphName
	Wave image
	
	String imageInstanceName= ImageDisplayedName(graphName, image)
	return strlen(imageInstanceName) > 0
End


Function/S WMCreateImageForContour2(graphName,contourInstanceName,slice,rows,cols,cImageInfo[,preSetWaveName])
	String graphName,contourInstanceName
	Variable slice		// set to non-zero to make images with identical values within a contour level.
	Variable rows,cols	// size of image
	Struct contourImageInfo &cImageInfo
	String preSetWaveName
	
	Variable usePresetName = 0
	if (!paramIsDefault(preSetWaveName))
		usePresetName = 1
	endif

	Variable doContourZ= StringMatch(cImageInfo.baseType,"XYZ*") || WaveExists(cImageInfo.contourX) || WaveExists(cImageInfo.contourY)
	
	String outPath	
	if (usePresetName)
		outPath = preSetWaveName
	else
		outPath = WMCreatedFillImagePathName(cImageInfo.contourName, cImageInfo.contour, graphName)
	endif
	if( doContourZ )
		Make/O/N=(rows,cols) $outPath
		Wave image=$outPath
		
		Variable miniX, maxiX, miniY, maxiY
			if (CmpStr(cImageInfo.baseType, "XYZMatrix")==0)
			miniX=WaveMin(cImageInfo.contour, 0, DimSize(cImageInfo.contour,0)-1)
			maxiX=WaveMax(cImageInfo.contour, 0, DimSize(cImageInfo.contour,0)-1)
			miniY=WaveMin(cImageInfo.contour, DimSize(cImageInfo.contour,0), DimSize(cImageInfo.contour,0)*2-1)
			maxiY=WaveMax(cImageInfo.contour, DimSize(cImageInfo.contour,0), DimSize(cImageInfo.contour,0)*2-1)
		else
			miniX=WaveMin(cImageInfo.contourX)
			maxiX = WaveMax(cImageInfo.contourX)
			miniY = WaveMin(cImageInfo.contourY)
			maxiY = WaveMax(cImageInfo.contourY)
		endif
		SetScale/I x, miniX, maxiX, "",image
		SetScale/I y, miniY, maxiY, "",image

		//// modify the countour's null value, then after image is created add a wavenote indicating contour's nullValue
		String currContourName = cImageInfo.contourName	
		if (CmpStr(cImageInfo.baseType, "Matrix"))		
			ModifyContour /W=$graphName $currContourName, nullValue=cImageInfo.nullValue
		endif
		image= ContourZ(graphName,cImageInfo.contourName,0,x,y)
		insertChangeWavenoteFlag(image, "WMcontourNullValue", num2str(cImageInfo.nullValue))
	else
		Variable x0= DimOffset(cImageInfo.contour,0)
		Variable xn= x0+(DimSize(cImageInfo.contour,0)-1)*DimDelta(cImageInfo.contour,0)
		Variable dx= (xn-x0)/(rows-1)

		Variable y0= DimOffset(cImageInfo.contour,1)
		Variable yn= y0+(DimSize(cImageInfo.contour,1)-1)*DimDelta(cImageInfo.contour,1)
		Variable dy= (yn-y0)/(cols-1)
			
		ImageInterpolate /S={x0,dx,xn,y0,dy,yn} Bilinear cImageInfo.contour	// output is M_InterpolatedImage
		Duplicate/O M_InterpolatedImage, $outPath
		WAVE image= $outPath
		CopyScales/I cImageInfo.contour, image
		KillWaves/Z M_InterpolatedImage
	endif
				
	if( slice )
		WMSliceImageAtContours(graphName,cImageInfo.contourName,image)
	
		// set some flags
		cImageInfo.graduated = 0
		insertChangeWavenoteFlag(image, "WMgraduatedImage", num2str(0))
	else
		cImageInfo.graduated = 1
		insertChangeWavenoteFlag(image, "WMgraduatedImage", num2str(1))
	endif

	insertChangeWavenoteFlag(image, "WMBaseContourName", contourInstanceName)

	return GetWavesDataFolder(image,2)	// the path to the created interpolated image
End



//Function/S WMCreateImageForContour2(graphName,contourInstanceName,slice,rows,cols,cImageInfo)
//	String graphName,contourInstanceName
//	Variable slice		// set to non-zero to make images with identical values within a contour level.
//	Variable rows,cols	// size of image
//	Struct contourImageInfo &cImageInfo
//
//	Variable doContourZ= StringMatch(cImageInfo.baseType,"XYZ*") || WaveExists(cImageInfo.contourX) || WaveExists(cImageInfo.contourY)
//	
//	String outPath= WMCreatedFillImagePathName(cImageInfo.contourName, cImageInfo.contour, graphName)
//	if( doContourZ )
//		Make/O/N=(rows,cols) $outPath
//		Wave image=$outPath
//		
//		Variable miniX, maxiX, miniY, maxiY
//			if (CmpStr(cImageInfo.baseType, "XYZMatrix")==0)
//			miniX=WaveMin(cImageInfo.contour, 0, DimSize(cImageInfo.contour,0)-1)
//			maxiX=WaveMax(cImageInfo.contour, 0, DimSize(cImageInfo.contour,0)-1)
//			miniY=WaveMin(cImageInfo.contour, DimSize(cImageInfo.contour,0), DimSize(cImageInfo.contour,0)*2-1)
//			maxiY=WaveMax(cImageInfo.contour, DimSize(cImageInfo.contour,0), DimSize(cImageInfo.contour,0)*2-1)
//		else
//			miniX=WaveMin(cImageInfo.contourX)
//			maxiX = WaveMax(cImageInfo.contourX)
//			miniY = WaveMin(cImageInfo.contourY)
//			maxiY = WaveMax(cImageInfo.contourY)
//		endif
//		SetScale/I x, miniX, maxiX, "",image
//		SetScale/I y, miniY, maxiY, "",image
//
//		//// modify the countour's null value, then after image is created add a wavenote indicating contour's nullValue
//		String currContourName = cImageInfo.contourName	
//		if (CmpStr(cImageInfo.baseType, "Matrix"))		
//			ModifyContour /W=$graphName $currContourName, nullValue=cImageInfo.nullValue
//		endif
//		image= ContourZ(graphName,cImageInfo.contourName,0,x,y)
//		insertChangeWavenoteFlag(image, "WMcontourNullValue", num2str(cImageInfo.nullValue))
//	else
//		Variable x0= DimOffset(cImageInfo.contour,0)
//		Variable xn= x0+(DimSize(cImageInfo.contour,0)-1)*DimDelta(cImageInfo.contour,0)
//		Variable dx= (xn-x0)/(rows-1)
//
//		Variable y0= DimOffset(cImageInfo.contour,1)
//		Variable yn= y0+(DimSize(cImageInfo.contour,1)-1)*DimDelta(cImageInfo.contour,1)
//		Variable dy= (yn-y0)/(cols-1)
//			
//		ImageInterpolate /S={x0,dx,xn,y0,dy,yn} Bilinear cImageInfo.contour	// output is M_InterpolatedImage
//		Duplicate/O M_InterpolatedImage, $outPath
//		WAVE image= $outPath
//		CopyScales/I cImageInfo.contour, image
//		KillWaves/Z M_InterpolatedImage
//	endif
//				
//	if( slice )
//		if (DEBUGGINGFLAG)
//			WMSliceImageAtContours(graphName,cImageInfo.contourName,image)
//		else
//
//			Variable numLevels= ItemsInList(cImageInfo.levelsStr,",")
//			String cTableStr = cImageInfo.cTableStr[strsearch(cImageInfo.cTableStr, "{", 0)+1, strsearch(cImageInfo.cTableStr, "}", 0)-1]
//				
////		Variable isLog = str2num(StringByKey("logLines", cImageInfo.cTableStr, "=", ","))
//			String temp = StringFromList(0, cTableStr, ",")
//			Variable zmin = !CmpStr(temp,"*") ? WaveMin(cImageInfo.contourZZ) : str2num(temp)
//			temp = StringFromList(1, cTableStr, ",")
//			Variable zmax = !CmpStr(temp,"*") ? WaveMax(cImageInfo.contourZZ) : str2num(temp)
//			String cTableName = StringFromList(2,cTableStr, ",")
//			Variable isReversed = !CmpStr(StringFromList(2,cTableStr, ","), "1")
//		
//			ColorTab2Wave $cTableName
//			Wave M_colors = M_colors
//		
//			String imagePath = ParseFilePath(1, outPath, ":", 1, 0)
//			String imageWaveName = ParseFilePath(0, outPath, ":",1, 0)
//			String fillCTableName = ReplaceString("fillImg", imageWaveName, "fillTbl", 1, 1)
//			String fullFillCTableName = imagePath + fillCTableName
//			
//			// build the flat color table - attempt 2
//			Variable i
//			Variable nColors = dimsize(M_colors, 0)
//			Make /FREE/D/N=(numLevels) levelVals
//			for (i=0; i<numLevels; i+=1)
//				levelVals[i] = str2num(stringFromList(i,cImageInfo.levelsStr,","))		
//			endfor
//			Variable dz = ((levelVals[numLevels-1] - levelVals[0])/(numLevels-1))/10
//			Variable nTableEntries = numLevels*10+2
//			
//			Make /U/W/O/N=(nTableEntries,dimsize(M_Colors,1)) $fullFillCTableName
//			WAVE cImageInfo.flatContourCTable = $fullFillCTableName
//			setscale /P x, levelVals[0]-dz/2, dz, cImageInfo.flatContourCTable			
//
//			Variable lastLowPt = 0
//			for (i=0; i<numLevels; i+=1)
//				Variable indx = floor(i/numLevels*nColors)
//				Variable contourPt = floor((levelVals[i] - dimoffset(cImageInfo.flatContourCTable,0))/DimDelta(cImageInfo.flatContourCTable,0))+1 //x2pnt(cImageInfo.flatContourCTable, levelVals[i])+1
//				cImageInfo.flatContourCTable[lastLowPt,contourPt][] = M_colors[indx][q]
//				lastLowPt = contourPt
//			endfor
//			cImageInfo.flatContourCTable[lastLowPt,][] = M_colors[dimsize(M_Colors,0)-1][q]
//			
////			// build the flat color table
////			Variable upResFactor = 1
////			
////			Make /U/W/O/N=(dimsize(M_Colors,0)*upResFactor,dimsize(M_Colors,1)) $fullFillCTableName
////			WAVE cImageInfo.flatContourCTable = $fullFillCTableName
////			setscale /I x, zmin, zmax, cImageInfo.flatContourCTable
////
////			Variable i
////			Variable nColors = dimsize(M_colors, 0)
////			Variable lastLowPt = 0//x2pnt(cImageInfo.flatContourCTable, zMin)
////			Make /FREE/D/N=(numLevels) levelVals
////			for (i=0; i<numLevels; i+=1)
////				levelVals[i] = str2num(stringFromList(i,cImageInfo.levelsStr,","))
////				Variable indx = floor(i/numLevels*nColors)
////				Variable contourPt = x2pnt(cImageInfo.flatContourCTable, levelVals[i])
////				cImageInfo.flatContourCTable[lastLowPt,contourPt][] = M_colors[indx][q]
////				lastLowPt = contourPt
////			endfor
////			cImageInfo.flatContourCTable[lastLowPt,][] = M_colors[nColors*(numLevels-1)*upResFactor/numLevels][q]
////
////			// try fine-tuning image z-values around the contour line values?
////			make /D/FREE/N=(numLevels) levelDiffs
////			
//////			Duplicate /FREE image, imageTestPts, imageTest
//////			imageTestPts = x2pnt(image[p][q], cImageInfo.flatContourCTable)
////			
////			
////			for (i=0; i<numLevels; i+=1)
////				Variable pt = x2pnt(cImageInfo.flatContourCTable, levelVals[i])
////				levelDiffs[i] = levelVals[i]-pnt2x(cImageInfo.flatContourCTable, pt)
////			endfor			
//////			for (i=0; i<numLevels; i+=1)
////////				image = abs(image[p][q]-levelVals[i]) < abs(levelDiffs[i]) 
//////			endfor			
////			
////			
////			// NH debugging
////			Make /O/N=(numLevels) contourLevels
////			for (i=0; i<numLevels; i+=1)
////				contourLevels[i] = str2num(stringFromList(i,cImageInfo.levelsStr,","))
////			endfor
//			// NH end debugging
//		endif
//	
//		// set some flags
//		cImageInfo.graduated = 0
//		if (!DEBUGGINGFLAG)
//			insertChangeWavenoteFlag(image, "WMflatColorTable", fillCTableName)
//		endif
//		insertChangeWavenoteFlag(image, "WMgraduatedImage", num2str(0))
//	else
//		cImageInfo.graduated = 1
//		insertChangeWavenoteFlag(image, "WMgraduatedImage", num2str(1))
//	endif
//
//	return GetWavesDataFolder(image,2)	// the path to the created interpolated image
//End

// Maintain information in the wavenote
function insertChangeWavenoteFlag(targetWave, flagName, flagVal)
	Wave targetWave
	String flagName
	String flagVal
	
	String anote = note(targetWave)
	String flagString = StringByKey(flagName, anote)
	
	String newNote = ReplaceStringByKey(flagName, anote, flagVal)
	Note /K targetWave, newNote
End

////// Sets the name of image waves to reflect their source contour wave.  Under most circumantces
////// these values should be unique, but it would be easy to make them not so.  A work around, say either 
////// changing this function or changing the contour names, should be pretty straightforward
Function/S WMCreatedFillImagePathName(imageName, image, graphName[, alternatePrefix])
	String imageName, graphName
	Wave image
	String alternatePrefix
	
	String cleanedWaveName = CleanupName(imageName, 0)
	String imageOutput
	
	Variable nChars = strlen(cleanedWaveName)
	if (nChars > 11)	
		imageOutput=ksFillImgPrefix+cleanedWaveName[0,5]+cleanedWaveName[nchars-5,nchars-1]	
	else
		imageOutput=ksFillImgPrefix+cleanedWaveName[0,10]
	endif
	
	if (!paramIsDefault(alternatePrefix) && strlen(alternatePrefix)>=1 && strlen(alternatePrefix)<=strlen(ksFillImgPrefix))
		imageOutput = ReplaceString(ksFillImgPrefix, imageOutput, alternatePrefix, 1, 1)
	endif
	
	String cleanedGraphName = CleanupName(graphName, 0)
	if (strlen(cleanedGraphName)>11)
		imageOutput+=cleanedGraphName[0,5]+cleanedGraphName[nchars-5,nchars-1]
	else
		imageOutput+=cleanedGraphName[0,10]
	endif
	
	String outPath= GetWavesDataFolder(image,1)+imageOutput
	return outPath
End

