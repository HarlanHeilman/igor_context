#pragma rtGlobals=2		// Use modern global access method.
#pragma version=1.1
#include <ControlBarManagerProcs>

//**************************
//
//	Draw polygons around points and create a fit data mask wave that will fit/not fit 
//   the points in the polygons
//
//**************************

// check for no points in poly

// Revisions:
// 1.01
// 		modified to work properly with liberally-named traces.
//		still does not work properly with certain obscure cases with names containing # characters


Static Constant MAXOBJNAME=31

Menu "Analysis"
	"Curve Fit Data Mask", StartupDataMask("")
end

Function StartupDataMask(UseGraph)
	String UseGraph
	
	if (strlen(UseGraph) == 0)
		UseGraph = WinName(0,1)
	endif
	if (WinType(UseGraph) != 1)
		abort "You must have a graph to do this."
	endif
	
	String GraphDataFolder = InitGraphFolder(UseGraph)
	MakeROIControls(UseGraph)		// Really just adds controls to the graph
	
	ControlInfo ROIWhichTraceMenu
	InitTraceFolder(UseGraph, S_value)
End

// Create folder for a graph. Initialize variables if necessary.
// Returns the complete path of the new folder.
Function/S InitGraphFolder(GraphName)
	String GraphName

	String SaveDF=GetDataFolder(1)
	
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_DataMask
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	NewDataFolder/O/S $GraphName
	
	NVAR/Z GraphHasControls
	if (!NVAR_Exists(GraphHasControls))
		Variable/G GraphHasControls = 0
	endif
	
	NVAR/Z ControlYDelta
	if (!NVAR_Exists(ControlYDelta))
		Variable/G ControlYDelta = 0		// space to leave at top of control bar to accomodate other procedure's controls
	endif
	
	NVAR/Z ColorSelection
	if (!NVAR_Exists(ColorSelection))
		Variable/G ColorSelection = 1
	endif
	
	NVAR/Z LongTags
	if (!NVAR_Exists(LongTags))
		Variable/G LongTags = 0
	endif
	
	String NewDataFolder=GetDataFolder(1)
	SetDataFolder $SaveDF
	return NewDataFolder
end

// simply removes any ' characters from the string passed in.
Function/S FolderNameFromTraceName(inTraceName)
	String inTraceName
	
	Variable inChar=0, outChar=0
	Variable lastChar = strlen(inTraceName)
	Variable sQuote = char2num("'")
	String outFolderName = ""
	
	if (strsearch(inTraceName, "'", 0) < 0)
		return inTraceName
	endif
	
	for (inChar = 0; inChar < lastChar; inChar += 1)
		if (char2num(inTraceName[inChar]) != sQuote)
			outFolderName += inTraceName[inChar]
		endif
	endfor
	
	return outFolderName
end

Function/S AppendSequenceNumber(inFolderName, sequence)
	String inFolderName
	Variable sequence
	
	String sequenceStr = num2istr(sequence)
	Variable sequenceLen = strlen(sequenceStr)
	String outFolderName = ""
	
	if (strlen(inFolderName) > (MAXOBJNAME-sequenceLen) )
		outFolderName = inFolderName[0,MAXOBJNAME-sequenceLen]
	else
		outFolderName = inFolderName
	endif
	
	outFolderName += sequenceStr
	return outFolderName
end

// Expects the current datafolder to be the one for a particular graph (that is,
// the parent of the trace folders)
Function/S UniqueFolderNameForTrace(inTraceName)
	String inTraceName
	
	String folderName = FolderNameFromTraceName(inTraceName)
	if (!DataFolderExists(folderName))
		return folderName
	endif
	
	String newFolderName
	Variable sequence = 0
	do
		newFolderName = AppendSequenceNumber(folderName, sequence)
		sequence += 1
	while (DataFolderExists(newFolderName))
	
	return newFolderName
end

// Expects the current datafolder to be the one for a particular graph (that is,
// the parent of the trace folders)
Function/S FindFolderForTrace(inTraceName)
	String inTraceName
	
	String SaveDF = GetDatafolder(1)
	
	String FolderName = FolderNameFromTraceName(inTraceName)
	
	if (DataFolderExists(FolderName))
		SetDatafolder $FolderName
		SVAR/Z realTraceName
		if (!SVAR_Exists(realTraceName))
			SetDataFolder $SaveDF
			return FolderName				// *** EXIT
		else
			if (CmpStr(realTraceName, inTraceName) == 0)
				SetDataFolder $SaveDF
				return FolderName			// *** EXIT
			endif
		endif
	endif
	
	SetDataFolder $saveDF
	
	Variable sequence = 0
	String NewFolderName
	do
		NewFolderName = appendSequenceNumber(FolderName, sequence)
		if (!DataFolderExists(NewFolderName))
			break
		endif
		SetDatafolder $NewFolderName
		SVAR/Z realTraceName
		if (!SVAR_Exists(realTraceName))
			SetDataFolder $SaveDF
			return NewFolderName			// *** EXIT
		else
			if (CmpStr(realTraceName, inTraceName) == 0)
				SetDataFolder $SaveDF
				return NewFolderName		// *** EXIT
			endif
		endif
		sequence += 1
		SetDataFolder $saveDF
	while (1)
	
	SetDataFolder $saveDF
	return ""									// *** EXIT
end

// Create folder for a trace. Initialize variables if necessary.
// Returns the complete path of the new folder.
Function/S InitTraceFolder(GraphName, theTraceName)
	String GraphName
	String theTraceName

	String SaveDF=GetDataFolder(1)
	
	Variable Initialize
	
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_DataMask
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	NewDataFolder/O/S $GraphName
	
	if (strlen(theTraceName) == 0)
		ControlInfo ROIWhichTraceMenu
		theTraceName = S_value
	endif
	
	String FolderName = FindFolderForTrace(theTraceName)
	if (strlen(FolderName) > 0)
		SetDataFolder $FolderName
		Initialize = 0
	else
		FolderName = UniqueFolderNameForTrace(theTraceName)
		NewDataFolder/O/S $FolderName
		Initialize = 1
	endif
	
	Variable/G ROINumPolys
	String/G TagNames
	if (Initialize)
		if (CmpStr(theTraceName, FolderName) != 0)
			String/G realTraceName
			realTraceName = theTraceName
		endif
		ROINumPolys = 0
		TagNames = ""
	endif
	
	String theNewDataFolder=GetDataFolder(1)
	SetDataFolder $SaveDF
	return theNewDataFolder
end

Function/S SetTraceFolder(GraphName, TraceName)
	String GraphName, TraceName
	
	String originalDF = GetDatafolder(1)
	
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	if (strlen(TraceName) == 0)
		ControlInfo/W=$GraphName ROIWhichTraceMenu
		TraceName = S_Value
	endif
	
	String completePathToFolder = "root:Packages:WM_DataMask:"
	completePathToFolder += PossiblyQuoteName(GraphName)
	SetDataFolder $completePathToFolder
	
	String TraceFolderName = FindFolderForTrace(TraceName)
	completePathToFolder += ":"
	completePathToFolder += PossiblyQuoteName(TraceFolderName)
//	SetDatafolder root:Packages:WM_DataMask:$(GraphName):$(TraceFolderName)
	SetDataFolder $(completePathToFolder)
	
	return originalDF
end

Function/S SetFolderFromNames(GraphName, TraceFolderName)
	String GraphName, TraceFolderName
	
	String originalDF = GetDatafolder(1)
	
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	
	String completePathToFolder = "root:Packages:WM_DataMask:"
	completePathToFolder += PossiblyQuoteName(GraphName)+":"
	completePathToFolder += PossiblyQuoteName(TraceFolderName)
	SetDataFolder $(TraceFolderName)
	
	return originalDF
end

Function/S ROITraceFolderPath(GraphName, TraceName)
	String GraphName, TraceName
	
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	if (strlen(TraceName) == 0)
		ControlInfo ROIWhichTraceMenu
		TraceName = S_Value
	endif
	String TraceFolderName = FindFolderForTrace(TraceName)
	return "root:Packages:WM_DataMask:"+GraphName+":"+TraceFolderName
end

Function/S SetGraphFolder(GraphName)
	String GraphName
	
	String originalDF = GetDatafolder(1)
	
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	SetDatafolder root:Packages:WM_DataMask:$(GraphName)
	
	return originalDF
end

static constant ControlBarDelta = 72

// Assumes that the Graph folder has been created.
Function MakeROIControls(GraphName)
	String GraphName

	String saveDF =  SetGraphFolder(GraphName)
 	NVAR GraphHasControls
 	NVAR ControlYDelta
 	String/G CBIdentifier
 	
	DoWindow/F $GraphName
	if (!GraphHasControls)
		GetWindow $GraphName, wsize
		MoveWindow V_left, V_top, V_right,V_bottom+72 
		String CBIdent
		ControlYDelta = ExtendControlBar(GraphName, ControlBarDelta, CBIdent)
		CBIdentifier = CBIdent
//		ControlBar 72
		
		ROIDefaultControls()
		
		GraphHasControls = 1
	endif
	
	SetDatafolder $saveDF
EndMacro

Function ROIDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Variable DestroyData
	DoAlert 2, "This will remove the controls from your graph. Remove polygons and clean up data as well?"
	switch (V_flag)
		case 1:
			DestroyData = 1
			break;
		case 2:
			DestroyData = 0
			break;
		case 3:
			return 0
	endswitch

	String theGraph = WinName(0,1)

	String saveDF = SetGraphFolder("")
	NVAR GraphHasControls
	NVAR ControlYDelta
	SVAR CBIdentifier
	String CBIdent = CBIdentifier
	Variable ControlSearch = ControlYDelta+ControlBarDelta
	GraphHasControls = 0
	
//	Variable startingCBHeight = GetControlBarHeight(theGraph)
//	Variable finishedCBHeight = startingCBHeight-ControlBarDelta
//	String moveCList = ListControlsInControlBar(theGraph, ControlSearch)

	Variable numTraceFolders
	Variable i
	String TraceFolder
	Variable OKKillDF = 1
	
//	SetTraceFolder("","")
	if (DestroyData)
		numTraceFolders = CountObjects(":", 4 )
		for (i = 0; i < numTraceFolders; i += 1)
			TraceFolder = GetIndexedObjName(":", 4, 0)		// each time a folder is removed, the next one becomes index 0
			CleanUpDataMaskData(theGraph, TraceFolder)
			if (DatafolderIsEmpty(TraceFolder))
				KillDatafolder $TraceFolder
			else
				OKKillDF = 0
			endif
		endfor
		KillVariables/A/Z
	 	KillStrings/A/Z
		TraceFolder = GetDatafolder(0)
		SetDatafolder ::
		if (DatafolderIsEmpty(theGraph))
			KillDatafolder $TraceFolder
		else
			DoAlert 0, "Some data is still in use, so the data clean-up is incomplete."
		endif
	else
		SetDatafolder $saveDF
	endif
	

	KillControl ROIDrawPolyButton
	KillControl ROIDeletePoly
	KillControl ROIColorPointsCheck
	KillControl ROIDoneButton
	KillControl UseROIPointsCheck
	KillControl ROIModifyPoly
	KillControl DispNumPolys
	KillControl ROIDoneEditingButton
	KillControl ROIHelpButton
	KillControl ROIWhichTraceMenu
	KillControl ROIGenMaskWaveButton
	KillControl ROILongTagsCheck

//	MoveControls(moveCList, 0, -ControlBarDelta)	
	ContractControlBar(theGraph, CBIdent, ControlBarDelta)
//	ControlBar 0
	GetWindow kwTopWin, wsize
	MoveWindow V_left, V_top, V_right,V_bottom-72 
	
	SetDatafolder $saveDF
End

Function OKToKillDataFolder(theDF)
	String theDF
	
	String SaveDF = GetDatafolder(1)
	SetDatafolder $theDF
	
	Variable isOK = 1
	Variable i=0
	do
		Wave/Z w = WaveRefIndexed("", i, 4)
		if (!WaveExists(w))
			break
		endif
		CheckDisplayed/A w
		if (V_flag != 0)
			isOK = 0
			break
		endif
		i += 1
	while (1)
	
	SetDatafolder $saveDF
	return isOK
end

Function DatafolderIsEmpty(theFolder)
	String theFolder
	
	Variable numObjects = CountObjects(theFolder, 1)
	numObjects += CountObjects(theFolder, 2)
	numObjects += CountObjects(theFolder, 3)
	numObjects += CountObjects(theFolder, 4)
	return numObjects==0
end

// This function is called by code that is iterating through datafolders, not through traces.
// That means that TraceFolderName is the actual folder name, not a trace name to be coerced
// into a folder name. Therefore, we can't use SetTraceFolder.
Function CleanUpDataMaskData(theGraph, TraceFolderName)
	String theGraph, TraceFolderName

//	String saveDF = SetTraceFolder(theGraph, theTrace)
//	String saveDF = GetDatafolder(1)
//	String CompletePath = "root:Packages:WM_DataMask:"+PossiblyQuoteName(theGraph)+":"+PossiblyQuoteName(TraceFolderName)
//	SetDataFolder $(CompletePath)
	String saveDF = SetFolderFromNames(theGraph, TraceFolderName)

	NVAR ROINumPolys
	String polyTrace
	String theTrace
	SVAR/Z realTraceName
	if (SVAR_Exists(realTraceName))
		theTrace = realTraceName
	else
		theTrace = TraceFolderName
	endif
	
	Variable i
	for (i = 0; i < ROINumPolys; i += 1)
		polyTrace = GenerateROIPolyWaveName(theTrace, 0, i)
		CheckDisplayed/W=$theGraph $polyTrace
		if (V_flag)
			RemoveFromGraph $polyTrace
		endif
	endfor
 	ModifyGraph zColor($theTrace)=0
 	String WinRec = WinRecreation(theGraph, 0)
 	// The most likely object in the folder to be used unexpectedly is ROI_Points. If an Auto residual trace is made, it may be
 	// attached to the residual trace.
 	Variable Where = StrSearch(WinRec, "ROI_Points", 0)
 	if (Where >= 0)
 		for (i = Where; i >= 0 && CmpStr(WinRec[i], "\r") != 0; i -= 1)
 		endfor
 		if (strsearch(WinRec, "ModifyGraph zColor", i) >= 0)
 			Where = strsearch(WinRec, "(", i)
 			Variable WhereEnd = strsearch(WinRec, ")", Where)
 			ModifyGraph zColor($(WinRec[Where+1, WhereEnd-1])) = 0
 		endif
 	endif
 	
 	KillWaves/A/Z
 	KillVariables/A/Z
 	KillStrings/A/Z
	
	SetDatafolder $saveDF
end

Function/S ListofNumbersForModifyMenu()
	String saveDF = SetTraceFolder("","")
	NVAR ROINumPolys
	String theList = ListOfNumbers(ROINumPolys)
	SetDatafolder $saveDF
	return theList
end

Function/S ListofNumbersForDeleteMenu()
	String saveDF = SetTraceFolder("","")
	NVAR ROINumPolys
	String theList = ListOfNumbers(ROINumPolys)+"-;Delete All"
	SetDatafolder $saveDF
	return theList
end

Function/S ListOfNumbers(Length)
	Variable Length
	
	String theList=""
	if (Length <= 0)
		return ""
	endif
	Variable i=0
	do
		theList += num2istr(i)+";"
		i += 1
	while (i < Length)
	
	return theList
end

// This function gets the currently-selected trace name from the trace menu in the top graph
Function/S GetCurrentROITraceName()

	String theGraph = WinName(0,1)
	ControlInfo/W=$theGraph ROIWhichTraceMenu
	String theTrace
	if (V_flag)
		theTrace = S_value
	else
		theTrace = ""
	endif
	return theTrace
end

Function UsingLongTags()

	ControlInfo ROILongTagsCheck
	return V_value
end

Function WantsColorSelection()

	String SaveDF = SetGraphFolder("")
	NVAR ColorSelection
	SetDatafolder $SaveDF
	return ColorSelection
end

Function ROIDrawPolyButtonProc(ctrlName) : ButtonControl
	String ctrlName
 
	String SaveDF = SetTraceFolder("", "")
	String theTrace = GetCurrentROITraceName()
	String TInfo = TraceInfo("", theTrace, 0)
	String HAxis = StringByKey("XAXIS", TInfo)
	String VAxis = StringByKey("YAXIS", TInfo)
	String cmd = ""
	
 	NVAR ROINumPolys
	String XWaveName = GenerateROIPolyWaveName(theTrace, 1, ROINumPolys)
	String YWaveName = GenerateROIPolyWaveName(theTrace, 0, ROINumPolys)
	Make/O/N=0 $XWaveName, $YWaveName
	CheckDisplayed $YWaveName
	String aInfo, VertAxisFlag, HorizAxisFlag
	if (V_flag == 0)
		aInfo = AxisInfo("", VAxis)
		if (CmpStr(StringByKey("AXTYPE", aInfo), "left") == 0)
			VertAxisFlag = "/L="
		else
			VertAxisFlag = "/R="
		endif
		aInfo = AxisInfo("", HAxis)
		if (CmpStr(StringByKey("AXTYPE", aInfo), "bottom") == 0)
			HorizAxisFlag = "/B="
		else
			HorizAxisFlag = "/T="
		endif
		cmd = "AppendToGraph"+VertAxisFlag+VAxis
		cmd += HorizAxisFlag+HAxis+" "
		cmd += PossiblyQuoteName(YWaveName) + " vs " + PossiblyQuoteName(XWaveName) 
		Execute cmd
//		AppendToGraph/L=$VAxis/B=$HAxis $YWaveName vs $XWaveName
	endif
	
	String TagName
	String TagMessage
	
	// appropriate graph *must* be top graph, because this routine runs as a result of a click on a control
	// that is *in the graph*.
	String ROIGraph = WinName(0,1)
	
	GraphWaveDraw/O $YWaveName, $XWaveName
//	TagName = "ROITag_"+theTrace+num2istr(ROINumPolys)
	TagName = "ROITag_"+num2istr(ROINumPolys)
	TagName = UniqueName(TagName, 14, 0, ROIGraph)
	SVAR TagNames
	TagNames += TagName+";"
	if (UsingLongTags())
		TagMessage = theTrace+":"
	else
		TagMessage = ""
	endif
	TagMessage += "\\{NameOfWave(TagWaveRef())[strlen(NameOfWave(TagWaveRef()))-1]}"
			
	Tag/N=$TagName/F=0/X=0.00/Y=0.00 $YWaveName, 0,TagMessage
	ROINumPolys += 1
	
	ROI_InstallDoneEditButton()
	SetDataFolder $SaveDF
End

Function ROIGenMaskWaveProc(ctrlName) : ButtonControl
	String ctrlName
	
	string theGraph = WinName(0,1)
	initGenMaskGlobals(theGraph, "")
	MakeGenMaskWavePanel()
	PauseForUser MakeDataMaskWavePanel
end

Function initGenMaskGlobals(GraphName, TraceName)
	String GraphName, TraceName

	String saveDF = SetTraceFolder(GraphName, TraceName)
	
	String dummyString = StrVarOrDefault("MaskWaveName", "FitDataMask")
	String/G MaskWaveName = dummyString
	Variable dummyVar = NumVarOrDefault("UseInteriorPoints", 1)
	Variable/G UseInteriorPoints = dummyVar
	
	SetDatafolder $saveDF
end

Function MakeGenMaskWavePanel()

	NewPanel/K=1/W=(23,471,293,609)
	DoWindow/C MakeDataMaskWavePanel
	String SaveDF=	SetTraceFolder("", "")
	SVAR MaskWaveName
	NVAR UseInteriorPoints
	
	SetVariable SetDataMaskWaveName,pos={15,17},size={225,15},title="Name for Mask Wave:"
	SetVariable SetDataMaskWaveName,limits={-Inf,Inf,1}, value=MaskWaveName
	CheckBox UseInteriorPointsCheck,pos={68,42},size={118,14},proc=UseInteriorPointsCheckProc,title="Use Interior Points"
	CheckBox UseInteriorPointsCheck,value= UseInteriorPoints,mode=1
	CheckBox UseExteriorPointsCheck,pos={68,61},size={120,14},proc=UseInteriorPointsCheckProc,title="Use Exterior Points"
	CheckBox UseExteriorPointsCheck,value= !UseInteriorPoints,mode=1
	Button MakeDataMaskDoItButton,pos={16,99},size={60,20},proc=MakeDataMaskDoItButtonProc,title="Do It"
	Button MakeDataMaskCancelButton,pos={178,99},size={60,20},proc=MakeDataMaskCancelButtonProc,title="Cancel"
	
	SetDatafolder $SaveDF
end

Function MakeDataMaskDoItButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String SaveDF=	SetTraceFolder("", "")
	String theTraceName = GetDatafolder(0)
	NVAR UseInteriorPoints
	SVAR MaskWaveName
	NVAR/Z ROINumPolys
	if (!NVAR_Exists(ROINumPolys))
		SetDatafolder $SaveDF
		abort "Can't find a critical variable- maybe things have been tampered with"
	endif
	if (ROINumPolys == 0)
		SetDatafolder $SaveDF
		abort "You haven't drawn any polygons to select points yet"
	endif
	Wave/Z ROI_Points
	if (!WaveExists(ROI_Points))
		SetDatafolder $SaveDF
		abort "Can't find one of my waves. Try re-initializing the whole thing!"
	endif
	Variable NameOK = CheckName(MaskWaveName, 1)
	if (NameOK != 0 && !Exists(MaskWaveName))	// if CheckName says no, but it's the name of an existing wave, it's a legal name
		SetDatafolder $SaveDF
		abort "Your wave name is not legal. It must not contain ';', ':', ';', or any quote marks."
	endif
	Duplicate/O ROI_Points, $MaskWaveName
	Wave w = $MaskWaveName
	if (!UseInteriorPoints)
		w = w[p]==0 ? 1 : 0
	endif
	
	Wave TraceWave = TraceNameToWaveRef("", theTraceName)
	SetDatafolder $(GetWavesDatafolder(TraceWave, 1))	// put the wave in the same data folder as the data wave
	
	Duplicate/O w, $MaskWaveName
	KillWaves/Z w
	
	DoWindow/K MakeDataMaskWavePanel
	SetDatafolder $SaveDF
End

Function MakeDataMaskCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K MakeDataMaskWavePanel
End

Function UseInteriorPointsCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String panelNote
	GetWindow kwTopWin, note
	panelNote = S_value
	String GraphName = StringByKey("GRAPH", panelNote)
	String TraceName = StringByKey("TRACE", panelNote)
	
	String saveDF = SetTraceFolder(GraphName, "")
	
	NVAR UseInteriorPoints
	
	strswitch (ctrlName)
		case "UseInteriorPointsCheck":
			UseInteriorPoints = checked;
			break;
		case "UseExteriorPointsCheck":
			UseInteriorPoints = !checked;
			break;
	endswitch
	CheckBox UseInteriorPointsCheck value=UseInteriorPoints
	CheckBox UseExteriorPointsCheck value=UseInteriorPoints==0
	
	SetDatafolder $saveDF
End

// This function assumes that it is called only when the relevant graph window
// is the top one. As long as it is called by a control action proc in the graph
// window, that will be true
Function ROI_InstallDoneEditButton()

	KillControl ROIDrawPolyButton
	KillControl ROIDeletePoly
	KillControl ROIColorPointsCheck
	KillControl ROIDoneButton
	KillControl UseROIPointsCheck
	KillControl ROIModifyPoly
	KillControl DispNumPolys
	KillControl ROIGenMaskWaveButton
	KillControl ROILongTagsCheck
	popupmenu ROIWhichTraceMenu,disable=1

	String saveDF =  SetGraphFolder(WinName(0,1))
	NVAR ControlYDelta
	SetDatafolder saveDF
	
	Button ROIDoneEditingButton,pos={111,ControlYDelta+20},size={90,20},proc=ROIDoneEditingButtonProc,title="Done Editing"
end

Function/S Non_ROI_TraceNameList()
	
	String theList=""
	String allTraces = TraceNameList("", ";", 1)
	String oneTrace
	
	Variable i
	do
		oneTrace = StringFromList(i, allTraces)
		if (strlen(oneTrace) == 0)
			break
		endif
		if (CmpStr(oneTrace[0,6], "ROIPoly") != 0)
			theList += oneTrace+";"
		endif
		i += 1
	while (1)
	
	return theList
end

// Assumes that the top window is the graph in which controls are to be installed
Function ROIDefaultControls()

	ControlInfo ROIDoneEditingButton
	if (V_flag)
		KillControl ROIDoneEditingButton
	endif

	popupmenu ROIWhichTraceMenu, pos={15,1},size={203,20},title="Use Trace", value=#"Non_ROI_TraceNameList()"
	popupmenu ROIWhichTraceMenu,bodywidth=140,proc=ROIWhichTraceMenuProc,disable=0

	DoUpdate
	String saveDF = GetDatafolder(1)
	String tracePath = InitTraceFolder("", "")
	SetGraphFolder("")
 	NVAR ColorSelection
 	NVAR LongTags
 	NVAR top = ControlYDelta
	
	SetTraceFolder("","")
 	
	popupmenu ROIWhichTraceMenu, pos={15,top+1}

	Button ROIGenMaskWaveButton,pos={220,top+1},size={160,20},proc=ROIGenMaskWaveProc,title="Generate Mask Wave..."

	Button ROIDrawPolyButton,pos={0,top+26},size={90,20},proc=ROIDrawPolyButtonProc,title="Add Polygon"
	PopupMenu ROIDeletePoly,pos={191,top+26},size={67,19},proc=ROIDeletePolyPopMenuProc,title="Delete"
	PopupMenu ROIDeletePoly,mode=0,value=#"\"0\""
	PopupMenu ROIDeletePoly,mode=0,value=#"ListOfNumbersForDeleteMenu()"
	
	PopupMenu ROIModifyPoly,pos={106,top+26},size={71,19},proc=ROIModPolyPopMenuProc,title="Modify"
	PopupMenu ROIModifyPoly,mode=0
	PopupMenu ROIModifyPoly,value= #"ListOfNumbersForModifyMenu()"

	CheckBox ROIColorPointsCheck,pos={1,top+51},size={120,20},proc=ColorROIPointsCheckProc,title="Color Selection"
	CheckBox ROIColorPointsCheck,value=ColorSelection
	
	CheckBox ROILongTagsCheck,pos={274,top+29},size={99,14},title="Long Poly Labels"
	CheckBox ROILongTagsCheck,value=LongTags, proc=ROILongTagsCheckProc

	ValDisplay DispNumPolys,pos={119,top+51},size={120,17},title="# of Polygons:", bodywidth = 25
	ValDisplay DispNumPolys,format="%.0f",limits={0,0,0},barmisc={0,1000}, frame=0
	Execute "ValDisplay DispNumPolys value = #\""+GetDatafolder(1)+"ROINumPolys\""

	Button ROIHelpButton,pos={264,top+48},size={60,20},proc=GenDataMaskHelpButtonProc,title="Help"

	Button ROIDoneButton,pos={330,top+48},size={50,20},proc=ROIDoneButtonProc,title="Done"
	
	SetDatafolder $saveDF
end

Function GenDataMaskHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Button ROIHelpButton, title = "Looking"
	DisplayHelpTopic "Generate Curve Fit Data Mask"
	Button ROIHelpButton, title = "Help"
end

Function ROIModPolyPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

 	String SaveDF = SetTraceFolder("","")
 	String theTrace = GetCurrentROITraceName()
	
 	NVAR ROINumPolys = ROINumPolys
	String XWaveName = GenerateROIPolyWaveName(theTrace, 1, popNum-1)
	String YWaveName = GenerateROIPolyWaveName(theTrace, 0, popNum-1)

//	InstallROIGraphHook()
	GraphWaveEdit $YWaveName

	ROI_InstallDoneEditButton()
	SetDataFolder $SaveDF
End

Function ROIWhichTraceMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String SaveDF = GetDataFolder(1)
	String theGraph = WinName(0,1)
	InitTraceFolder(theGraph, popStr)
	SetTraceFolder("","")

	Execute "ValDisplay DispNumPolys value = #\""+GetDatafolder(1)+"ROINumPolys\""
	
	SetDatafolder $saveDF
End

Function ROIDeletePolyPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

  	Variable i
 	String XWaveName
 	String YWaveName
 	
	String SaveDF = SetTraceFolder("","")
	String theTrace = GetCurrentROITraceName()
 	NVAR ROINumPolys = ROINumPolys
	
	if (CmpStr(popStr, "Delete All") == 0)
		for (i=0; i<ROINumPolys; i+=1)
			XWaveName = GenerateROIPolyWaveName(theTrace, 1, i)
			YWaveName = GenerateROIPolyWaveName(theTrace, 0, i)
			Wave XY = $YWaveName
			CheckDisplayed XY
			if (V_flag)
				RemoveFromGraph $YWaveName
			endif
			KillWaves/Z $XWaveName, $YWaveName
		endfor
		ROINumPolys = 0
	else
		XWaveName = GenerateROIPolyWaveName(theTrace, 1, popNum-1)
		YWaveName = GenerateROIPolyWaveName(theTrace, 0, popNum-1)
		Wave XY = $YWaveName
		CheckDisplayed XY
		if (V_flag)
			RemoveFromGraph $YWaveName
		endif
		KillWaves/Z $XWaveName, $YWaveName
		if (popNum < ROINumPolys)
			for (i = popNum; i < ROINumPolys; i += 1)		// Keep all the polygon names in order
				Rename $(GenerateROIPolyWaveName(theTrace, 1, i)), $(GenerateROIPolyWaveName(theTrace, 1, i-1))
				Rename $(GenerateROIPolyWaveName(theTrace, 0, i)), $(GenerateROIPolyWaveName(theTrace, 0, i-1))
			endfor
		endif
		ROINumPolys -= 1
	endif
	DoUpdate
	ROIDoneEditingButtonProc("Delete")	// Use fake control name to signal ROIDoneEditingButtonProc() that this is being called from the Delete a Polygon function
	SetDataFolder $SaveDF
End

// I can't recall why I thought this hook was necessary. It is not presently called.
Function InstallROIGraphHook()

 	String saveDF = SetGraphFolder("")
 	
 	GetWindow kwTopWin hook
 	String/G  ROISavedGraphHook = S_value
	SetWindow kwTopWin hook=QuitROIEdit
	
	SetDatafolder $saveDF
end

// This function used to create a wave name with a base derived from the trace name.
// Since traces have potential problems as wave names, let's not do that. Since the waves
// are stored in a folder named for the trace, we can still tell which trace it's
// attached to.
Function/S GenerateROIPolyWaveName(theTrace, isX, sequenceNumber)
	String theTrace
	Variable isX		
	Variable sequenceNumber
	
//	String theName = "ROIPoly"+theTrace
	String theName = "ROIPoly"
	if (isX)
		theName += "X"
	else
		theName += "Y"
	endif
	theName += num2istr(sequenceNumber)
	return theName
end

Function QuitROIEdit(infoStr)
	String infoStr

	if (CmpStr(StringByKey("EVENT", infoStr), "deactivate") == 0)
	 	String ROIGraph = StringByKey("WINDOW", infoStr)
	 	String saveDF = SetGraphFolder(ROIGraph)
	  	SVAR ROISavedGraphHook
	  	
		SetTraceFolder(ROIGraph, "")
		String theTrace = GetCurrentROITraceName()
	 	NVAR ROINumPolys
	 	Variable i
	
		GraphNormal
		if (strlen(ROISavedGraphHook) > 0)
			SetWindow $ROIGraph hook=$ROISavedGraphHook
		else
			SetWindow $ROIGraph hook=$""
		endif
		i = ROINumPolys
		if (i > 0)
			do
				i -= 1
				Wave w = $(GenerateROIPolyWaveName(theTrace, 0, i))
				CheckDisplayed/W=$ROIGraph w
				if (V_flag == 0)
					ROIDeletePolyPopMenuProc("",i+1,"")		// i+1 because this is really a menu action procedure, and inside the function it uses "popNum-1"
				endif
			while (i > 0)
		endif
		SetDatafolder $saveDF
	endif
end

Function ColorROIPointsCheckProc (ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if checked, 0 if not
	
	String saveDF = SetGraphFolder("")
	NVAR ColorSelection
	ColorSelection = checked
	
	Variable numTraceFolders
	Variable i
	String TraceFolder
	String theGraph = WinName(0,1)
	String saveGraphFolder = GetDatafolder(1)
	
	numTraceFolders = CountObjects(":", 4 )
	for (i = 0; i < numTraceFolders; i += 1)
		TraceFolder = GetIndexedObjName(":", 4, i)		// each time a folder is removed, the next one becomes index 0
//		SetTraceFolder("",TraceFolder)
		SetFolderFromNames("", TraceFolder)
   		NVAR ROINumPolys = ROINumPolys
	 	if (checked %& (ROINumPolys > 0))
		 	Wave/Z ROI_Points=ROI_Points
		 	if (!WaveExists(ROI_Points))
	 			GenPointInPolyWave(theGraph, TraceFolder)
	 			Wave ROI_Points=ROI_Points
	 		endif
		 	ModifyGraph zColor($TraceFolder)={ROI_Points,*,*,RainBow}
		else
		 	ModifyGraph zColor($TraceFolder)=0
		 endif
		 SetDatafolder $saveGraphFolder
	endfor

	SetDataFolder $SaveDF
End

Function ROILongTagsCheckProc (ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if checked, 0 if not
	
	String saveDF = SetGraphFolder("")
	NVAR LongTags
	LongTags = checked
	
	Variable numTraceFolders
	Variable i,j
	String TraceFolder
	String theGraph = WinName(0,1)
	String saveGraphFolder = GetDatafolder(1)
	String annoList = AnnotationList(theGraph)
	String oneAnno
	String TagMessage
	String TagNameBase
	Variable annoBaseLength
	
	numTraceFolders = CountObjects(":", 4 )
	for (i = 0; i < numTraceFolders; i += 1)
		TraceFolder = GetIndexedObjName(":", 4, i)
//		SetTraceFolder("",TraceFolder)
		SetFolderFromNames("", TraceFolder)
//		TagNameBase = "ROITag_"+TraceFolder
//		annoBaseLength = strlen(TagNameBase)
		j = 0
		do
//			oneAnno = StringFromList(j, annoList)
			SVAR TagNames
			oneAnno = StringFromList(j, TagNames)
			if (strlen(oneAnno) == 0)
				break;
			endif
//			if (CmpStr(oneAnno[0,annoBaseLength-1], TagNameBase) == 0)
				if (checked)
					TagMessage = TraceFolder+":"
				else
					TagMessage = ""
				endif
				TagMessage += "\\{NameOfWave(TagWaveRef())[strlen(NameOfWave(TagWaveRef()))-1]}"
				Tag/N=$oneAnno/C TagMessage
//			endif
			
			j += 1
		while (1)
   		
		 SetDatafolder $saveGraphFolder
	endfor

	SetDataFolder $SaveDF	
end

Function GenPointInPolyWave(theGraph, theTraceName)		// Assumes that the current DataFolder is the one appropriate for the current graph
	String theGraph, theTraceName
	
 	String saveDF = SetTraceFolder(theGraph, theTraceName)
 	theTraceName = GetDatafolder(0)
 	NVAR ROINumPolys

 	Wave DVW = TraceNameToWaveRef("", theTraceName)
 	WAVE/Z DVWX = XWaveRefFromTrace("", theTraceName)

 	if (!WaveExists(DVWX))
 		Duplicate/O DVW, ROI_XWave
 		Wave DVWX = $"ROI_XWave"
 		DVWX = x
 	endif

 	Variable i
 	String XWaveName
 	String YWaveName
 	
 	Make/O/N=(numpnts(DVW)) ROI_Points=0
 	for (i = 0; i < ROINumPolys; i += 1)
 		XWaveName = GenerateROIPolyWaveName(theTraceName, 1, i)
 		Wave XW = $XWaveName
 		YWaveName = GenerateROIPolyWaveName(theTraceName, 0, i)
 		Wave YW = $YWaveName
 		FindPointsInPoly DVWX, DVW, XW, YW
		Wave W_inPoly = W_inPoly
		ROI_Points = ROI_Points | W_inPoly
	endfor
	 	
	SetDataFolder $SaveDF
end

Function ROIDoneEditingButtonProc(ctrlName) : ButtonControl
	String ctrlName

	if (CmpStr(ctrlName, "Delete") != 0)	// see ROIDeletePolyPopMenuProc()
		GraphNormal
		ROIDefaultControls()
	endif

 	GenPointInPolyWave("","")
	if (WantsColorSelection())
		ColorROIPointsCheckProc ("",1)
	endif
End