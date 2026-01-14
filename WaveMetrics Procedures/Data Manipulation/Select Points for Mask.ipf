#pragma rtGlobals=2		// Use modern global access method.
#pragma version=1.03
#pragma IgorVersion=6.10
#pragma IndependentModule = SelectPointsforMask

//**************************
//
//	Draw polygons around points and create a wave with selectable values for points inside/outside the polygons
//	Can make either a numeric wave or a text wave. A numeric wave with 1's and 0's or 1's and NaNs is suitable
//	for use as a fit mask wave, or a Graph mask wave (see ModifyGraph for Traces, mask keyword). A numeric wave
//	can also be used as an f(z) wave (see ModifyGraph for Traces, zColor, zmrkNum, or zmrkSize keywords). Either
//	a numeric wave or a text wave could be used as the text marker wave (see ModifyGraph for Traces, textMarker
//	keyword).
//
//**************************

// Revisions:
// 1.00
//		First release.
//		Derived from Data Mask for Fit procedure file
//	1.01
//		Massive re-organization as an exterior panel with tab control
//	1.02	JW 131107
//		Now refuses to work on traces with a subrange. It really ought to, but it is a very complex problem that will
// 		have to be put off for later.
// 1.03	JW 221118
//		Options list now is preserved if you flip back and forth between adding polygons and modifying the list in More Options.
//		Fixed failure to find polygon waves and traces when you delete polygons.

// TODO: make it work on traces with subranges


Constant MAXOBJNAME=31
StrConstant DFUDName = "DataMask_TraceDataFolder"
StrConstant NoTracesString = "No Suitable Traces"

Menu "Graph"
	"Select Points for Mask", /Q, SelectPointsforMask#StartupDataMask("")
end

Menu "DM_MarkerMenu",contextualmenu,dynamic
	"NaN", DM_MenuNOP()
	SubMenu "Markers"
		"*MARKERPOP*", /Q, DM_MenuNOP()
	end
end

Function DM_MenuNOP()
end

Function StartupDataMask(UseGraph)
	String UseGraph
	
	if (strlen(UseGraph) == 0)
		UseGraph = WinName(0,1)
	endif
	if (WinType(UseGraph) != 1)
		abort "You must have a graph to do this."
	endif
	String traces = Non_ROI_TraceNameList(UseGraph)
	if (CmpStr(traces, NoTracesString) == 0)
		DoAlert 0, "No suitable traces on the graph. Does not work on images or traces using a subrange."
		return NaN
	endif

	
	String GraphDataFolder = InitGraphFolder(UseGraph)

	if (WinType(UseGraph+"#MaskWaveControlPanel") == 7)
		DoWindow/F $useGraph		// most likely not necessary, but old habits die hard...
	else
		InitGraphFolder(UseGraph)
		BuildDataMaskPanel(useGraph)
		ControlInfo/W=$(UseGraph+"#MaskWaveControlPanel") ROIWhichTraceMenu
		InitTraceFolder(UseGraph, S_value)
	endif
End

// Create folder for a graph. Initialize variables if necessary.
// Returns the complete path of the new folder.
Function/S InitGraphFolder(GraphName)
	String GraphName

	String SaveDF=GetDataFolder(1)
	
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_SelectPoints
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	NewDataFolder/O/S $GraphName
	
	NVAR/Z ColorSelection
	if (!NVAR_Exists(ColorSelection))
		Variable/G ColorSelection = 1
	endif
	
	NVAR/Z DFSequence
	if (!NVAR_Exists(DFSequence))
		Variable/G DFSequence = 0
	endif
	
	NVAR/Z ROIWaveSuffixNumber
	if (!NVAR_Exists(ROIWaveSuffixNumber))
		Variable/G ROIWaveSuffixNumber = 0
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
Function/S FindFolderForTrace(gname, inTraceName, doFullPath)
	String gname, inTraceName
	Variable doFullPath
	
	if (CmpStr(inTraceName, NoTracesString) == 0 || strlen(inTraceName) == 0)
		return "BAD TRACE"
	endif
	
	String SaveDF = GetDatafolder(1)
	
	if (strlen(gname) == 0)
		gname = WinName(0,1)
	endif
	String storedFolder = GetUserData(gname, inTraceName, DFUDName)
	String justTheName=""
	if (strlen(storedFolder) > 0)
		if (DataFolderExists(storedFolder))
			SetDataFolder storedFolder
			justTheName = GetDataFolder(doFullPath)
			SetDataFolder SaveDF
		else
			ModifyGraph/W=$gname userData($inTraceName)={$DFUDName, 0, ""}
		endif
	endif
	return justTheName
end

// Create folder for a trace. Initialize variables if necessary.
// Returns the complete path of the new folder.
Function/S InitTraceFolder(GraphName, theTraceName)
	String GraphName
	String theTraceName
	
	if (strlen(TraceInfo(GraphName, theTraceName, 0)) == 0)
		return ""			// theTraceName names a non-existent trace, or there are no suitable traces on the graph
	endif

	String SaveDF=GetDataFolder(1)
	
	Variable Initialize
	
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_SelectPoints
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	NewDataFolder/O/S $GraphName
	
	if (strlen(theTraceName) == 0)
		ControlInfo/W=$(GraphName+"#MaskWaveControlPanel") ROIWhichTraceMenu
		theTraceName = S_value
	endif
	
	String FolderName = FindFolderForTrace(GraphName, theTraceName, 1)
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
	String/G ROISequenceList, PolyXWaves, PolyYWaves
	if (Initialize)
		ROINumPolys = 0
		TagNames = ""
		ROISequenceList = ""
		PolyXWaves = ""
		PolyYWaves = ""
		ModifyGraph/W=$GraphName userData($theTraceName)={$DFUDName, 0, GetDataFolder(1)}
	endif
	
	String theNewDataFolder=GetDataFolder(1)
	SetDataFolder $SaveDF
	return theNewDataFolder
end

Function/S SetTraceFolder(GraphName, TraceName)
	String GraphName, TraceName
	
	String originalDF = GetDatafolder(1)
	
	if (strlen(TraceName) == 0)
		TraceName = GetCurrentROITraceName(GraphName)
	endif
		
	String completePathToFolder = FindFolderForTrace(GraphName, TraceName, 1)
	SetDataFolder $(completePathToFolder)
	
	return originalDF
end

Function/S SetFolderFromNames(GraphName, TraceFolderName)
	String GraphName, TraceFolderName
	
	String originalDF = GetDatafolder(1)
	
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	
	String completePathToFolder = "root:Packages:WM_SelectPoints:"
	completePathToFolder += PossiblyQuoteName(GraphName)+":"
	completePathToFolder += PossiblyQuoteName(TraceFolderName)
	SetDataFolder $(TraceFolderName)
	
	return originalDF
end

Function/S SetGraphFolder(GraphName)
	String GraphName
	
	String originalDF = GetDatafolder(1)
	
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	SetDatafolder root:Packages:WM_SelectPoints:$(GraphName)
	
	return originalDF
end

constant ControlBarDelta = 72

Function BuildDataMaskPanel(GraphName)
	String GraphName
	
	NewPanel/EXT=0/HOST=$GraphName/W=(0,0,252,428)/N=MaskWaveControlPanel as "Select Points for Mask"

	DefineGuide UGH0={FT,99}
	DefineGuide UGH1={FB,-53}
	DefineGuide UGV0={FL,9}
	DefineGuide UGV1={FR,-11}
	DefineGuide UGH2={UGH0,-28}
	DefineGuide UGH3={UGH1,15}

	String menuListFunc = " SelectPointsforMask#Non_ROI_TraceNameList(\""+GraphName+"\")"
	PopupMenu ROIWhichTraceMenu,pos={17,6},size={200,20},bodyWidth=140,proc=SelectPointsforMask#ROIWhichTraceMenuProc,title="Use Trace"
	PopupMenu ROIWhichTraceMenu,fSize=12,mode=1,value=#menuListFunc

	String saveDF = GetDataFolder(1)
	ControlUpdate ROIWhichTraceMenu
	InitTraceFolder(GraphName, "")
	SetTraceFolder(GraphName, "")
	initGenMaskGlobals(GraphName, GetCurrentROITraceName(GraphName))
	Variable/G ROINumPolys = NumVarOrDefault("ROINumPolys", 0)
	String traceFolder = GetDataFolder(1)

	Wave/T MoreOptionsListWave
	Wave MoreOptionsSelWave
	Wave MoreOptionsTitleWave
	Variable/G GenMaskDoMoreOptions = NumVarOrDefault("GenMaskDoMoreOptions", 0)
	NVAR ROINumPolys

	SetDataFolder saveDF
 	
	SetVariable DispNumPolys,pos={29,43},size={112,17},bodyWidth=25,title="# of Polygons:"
	SetVariable DispNumPolys,fSize=12,format="%.0f",frame=0,noedit= 1
	SetVariable DispNumPolys,limits={0,0,0},barmisc={0,1000}
	SetVariable DispNumPolys,value=ROINumPolys
	
	TabControl MaskPanelTab,pos={5,75},size={240,309},proc=SelectPointsforMask#SelectPointsTabProc
	TabControl MaskPanelTab,tabLabel(0)="Select Points",tabLabel(1)="Generate Mask"
	TabControl MaskPanelTab,value= 0

	Button ROIHelpButton,pos={175,399},size={70,22},proc=SelectPointsforMask#GenDataMaskHelpButtonProc,title="Help"

	Button ROIDoneButton,pos={15,399},size={70,22},proc=SelectPointsforMask#ROIDoneButtonProc,title="Done"
	
	SetWindow $(GraphName+"#MaskWaveControlPanel"), userdata(EditingROIProperty)=  "NO"

	NewPanel/W=(9,67,501,190)/FG=(,UGH0,UGV1,UGH1)/HOST=#/N=ROIDefaultPanel 
	ModifyPanel frameStyle=0, frameInset=0
	
		Button ROIDrawPolyButton,pos={31,24},size={110,22},proc=SelectPointsforMask#ROIDrawPolyButtonProc,title="Add Polygon"
	
		PopupMenu ROIDeletePoly,pos={31,110},size={110,20},bodyWidth=110,proc=SelectPointsforMask#ROIDeletePolyPopMenuProc,title="Delete"
		String menuValue = "SelectPointsforMask#ListOfNumbersForDeleteMenu(\""+GraphName+"\")"
		PopupMenu ROIDeletePoly,mode=0,value= #menuValue

		PopupMenu ROIModifyPoly,pos={31,70},size={110,20},bodyWidth=110,proc=SelectPointsforMask#ROIModPolyPopMenuProc,title="Modify"
		menuValue = "SelectPointsforMask#ListOfNumbersForModifyMenu(\""+GraphName+"\")"
		PopupMenu ROIModifyPoly,mode=0,value= #menuValue

		CheckBox ROIColorPointsCheck,pos={31,239},size={105,16},proc=SelectPointsforMask#ColorROIPointsCheckProc,title="Color Selection"
		CheckBox ROIColorPointsCheck,fSize=12,value= 1
	
		CheckBox ROILongTagsCheck,pos={31,209},size={115,16},proc=SelectPointsforMask#ROILongTagsCheckProc,title="Long Poly Labels"
		CheckBox ROILongTagsCheck,fSize=12,value= 1

	SetActiveSubwindow ##

	NewPanel/W=(15,63,276,340)/FG=(UGV0,UGH0,UGV1,UGH1)/HOST=# /HIDE=1 /N=GenerateMaskWaveTabPanel
	ModifyPanel frameStyle=0, frameInset=0

		TitleBox DM_NameForWaveTitle,pos={7,2},size={121,16},title="Name for New Wave:"
		TitleBox DM_NameForWaveTitle,fSize=12,frame=0

		SetVariable SetDataMaskWaveName,pos={19,21},size={211,19},fSize=12,value= _STR:"DataMaskWave"
	
		Button MakeDataMaskDoItButton,pos={50,253},size={130,20},proc=SelectPointsforMask#MakeDataMaskDoItButtonProc,title="Make the Wave"
	
		DefineGuide UGH0={FB,-27}
		DefineGuide UGH1={FT,51}

		NewPanel/W=(11,29,232,210)/FG=(FL,UGH1,FR,UGH0)/HOST=#/HIDE=1/N=MoreOptionsPanel
		ModifyPanel frameStyle=0, frameInset=0
	
			ListBox DM_MoreOptionsList,pos={6,24},size={215,139},titleWave=MoreOptionsTitleWave,editStyle= 1,frame=4
			ListBox DM_MoreOptionsList,listWave=MoreOptionsListWave
			ListBox DM_MoreOptionsList,selWave=MoreOptionsSelWave, proc=SelectPointsforMask#DM_MoreOptionsListBoxProc
		
			CheckBox DM_GenMaskTextWave,pos={14,4},size={124,16},title="Make a Text Wave",fSize=12,value= 0

			Button DM_DataMaskFewerOptions,pos={54,171},size={120,20},proc=SelectPointsforMask#DM_DataMaskFewerOptionsBtnProc,title="Fewer Options"

		SetActiveSubwindow ##
	
		NewPanel/W=(13,69,322,211)/FG=(FL,UGH1,,UGH0)/HOST=#/N=FewerOptionsPanel
		ModifyPanel frameStyle=0, frameInset=0
	
			SetVariable DM_SetExteriorValue,pos={10,80},size={209,19},bodyWidth=60,title="Value for Exterior Points:"
			SetVariable DM_SetExteriorValue,fSize=12,value= _NUM:0
		
			Button DM_SwapMaskValues,pos={79,51},size={70,20},proc=SelectPointsforMask#DM_SwapMaskValuesButtonProc,title="Swap"
		
			SetVariable DM_SetInteriorValue,pos={14,23},size={205,19},bodyWidth=60,title="Value for Interior Points:"
			SetVariable DM_SetInteriorValue,fSize=12,value= _NUM:1
		
			Button DM_GenMaskMoreOptions,pos={54,171},size={120,20},proc=SelectPointsforMask#DM_GenMaskMoreOptionsButtonProc,title="More Options"

		SetActiveSubwindow ##

	SetActiveSubwindow ##

	NewPanel/W=(21,29,252,375)/FG=(FL,UGH2,FR,UGH3)/HOST=# /HIDE=1/N=ROI_InstallDonePanel
	ModifyPanel frameStyle=0, frameInset=0

		Button ROIDoneEditingButton,pos={62,42},size={111,22},proc=SelectPointsforMask#ROIDoneEditingButtonProc,title="Done Editing"

	SetActiveSubwindow ##

	SetWindow $GraphName#MaskWaveControlPanel hook(DM_KillPanelHook)=SelectPointsforMask#DM_KillPanelHook
end

Function SwitchToGenMaskWaveTab(ROIGraph, TraceName, GenMaskDoMoreOptions)
	String ROIGraph, TraceName
	Variable GenMaskDoMoreOptions
	
	String SaveDF=	SetTraceFolder(ROIGraph, TraceName)
	initGenMaskGlobals(ROIGraph, TraceName)

	ListBox DM_MoreOptionsList,listWave=MoreOptionsListWave,selWave=MoreOptionsSelWave,win=$(ROIGraph+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel#MoreOptionsPanel")
	SetDataFolder saveDF
	
	SetWindow $(ROIGraph+"#MaskWaveControlPanel#ROIDefaultPanel") hide=1
	SetWindow $(ROIGraph+"#MaskWaveControlPanel#ROI_InstallDonePanel") hide=1
	SetWindow $(ROIGraph+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel") hide=0
	DM_SwitchOptions(ROIGraph, GenMaskDoMoreOptions)
end	

Function SelectPointsTabProc(s) : TabControl
	STRUCT WMTabControlAction &s

	switch( s.eventCode )
		case 2: // mouse up
		 	String ROIGraph = StringFromList(0, s.win, "#")
			String TraceName = GetCurrentROITraceName(ROIGraph)
			String SaveDF=	SetTraceFolder(ROIGraph, TraceName)
				NVAR/Z GenMaskDoMoreOptions
				if (!NVAR_Exists(GenMaskDoMoreOptions))
					Variable/G GenMaskDoMoreOptions=0
				endif
			SetDataFolder saveDF

			if (s.tab == 1)
				if (CmpStr(GetUserData(ROIGraph+"#MaskWaveControlPanel", "", "EditingROIProperty"), "YES") == 0)
					DoAlert 1, "You are currently editing a polygon. Do you want to stop editing and switch tabs?"
					if (V_flag == 1)		// yes was clicked
						ROIDoneEditing(ROIGraph)
						SwitchToGenMaskWaveTab(ROIGraph, TraceName, GenMaskDoMoreOptions)
					endif
				else
					SwitchToGenMaskWaveTab(ROIGraph, TraceName, GenMaskDoMoreOptions)
				endif
			else
				SetWindow $(ROIGraph+"#MaskWaveControlPanel#ROIDefaultPanel") hide=0
				SetWindow $(ROIGraph+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel") hide=1
			endif
			break
	endswitch

	return 0
End

Function DM_KillPanelHook(s)
	STRUCT WMWinHookStruct &s
	
	if ( (s.eventCode == 2) || (s.eventCode == 14) )			// window being killed
		DM_DoneAction(s.winName)
	endif
end

Function DM_DoneAction(PanelName)
	String panelName
	
 	String theGraph = StringFromList(0, panelName, "#")

	Variable DestroyData
	DoAlert 2, "This will close the control panel. Remove polygons and clean up data as well?"
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

	String saveDF = SetGraphFolder(theGraph)

	Variable numTraceFolders
	Variable i
	String TraceFolder
	Variable OKKillDF = 1
	
	if (DestroyData)
		numTraceFolders = CountObjects(":", 4 )
		for (i = 0; i < numTraceFolders; i += 1)
			TraceFolder = GetIndexedObjName(":", 4, 0)		// each time a folder is removed, the next one becomes index 0
			CleanUpDataMaskData(theGraph, TraceFolder)
			KillDatafolder/Z $TraceFolder
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
		
		ModifyGraph/W=$theGraph userData={$DFUDName, 0, ""}
	else
		SetDatafolder $saveDF
	endif
	
	SetWindow $(theGraph+"#MaskWaveControlPanel") hook(DM_KillPanelHook)=$""
	KillWindow $(theGraph+"#MaskWaveControlPanel")
	
	SetDatafolder $saveDF
end	

Function ROIDoneButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s
	
	if (s.eventCode == 2)		// mouse up event
		DM_DoneAction(s.win)
	endif
	
	return 0
End

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

	String saveDF = SetFolderFromNames(theGraph, TraceFolderName)
	String ourFolder = GetDataFolder(1)

	NVAR ROINumPolys
	String polyTrace
	String theTrace = DM_TraceFromFolder(theGraph, ourFolder)
	
 	SVAR ROISequenceList
	
	Variable i
	for (i = 0; i < ROINumPolys; i += 1)
 		Variable ROISequenceNumber = str2num(StringFromList(i, ROISequenceList))
		polyTrace = GenerateROIPolyWaveName(0, ROISequenceNumber)
		CheckDisplayed/W=$theGraph $polyTrace
		if (V_flag)
			RemoveFromGraph/W=$theGraph $polyTrace
		endif
	endfor
 	ModifyGraph/W=$theGraph zColor($theTrace)=0
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
 			ModifyGraph/W=$theGraph zColor($(WinRec[Where+1, WhereEnd-1])) = 0
 		endif
 	endif
 	
 	KillWaves/A/Z
 	KillVariables/A/Z
 	KillStrings/A/Z
	
	SetDatafolder $saveDF
end

Function/S ListofNumbersForModifyMenu(graphName)
	String graphName
	
	String saveDF = SetTraceFolder(graphName,"")
	NVAR ROINumPolys
	String theList = ListOfNumbers(ROINumPolys)
	SetDatafolder $saveDF
	return theList
end

Function/S ListofNumbersForDeleteMenu(graphName)
	String graphName
	
	String saveDF = SetTraceFolder(graphName,"")
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
Function/S GetCurrentROITraceName(gname)
	String gname

	ControlInfo/W=$(gname+"#MaskWaveControlPanel") ROIWhichTraceMenu
	String theTrace
	if (V_flag)
		theTrace = S_value
	else
		theTrace = ""
	endif
	return theTrace
end

Function UsingLongTags(gname)
	String gname

	ControlInfo/W=$(gname+"#MaskWaveControlPanel#ROIDefaultPanel") ROILongTagsCheck
	return V_value
end

Function WantsColorSelection(gname)
	String gname

	String SaveDF = SetGraphFolder(gname)
	NVAR ColorSelection
	SetDatafolder $SaveDF
	return ColorSelection
end

Function ROIDrawPolyButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s
	
	if (s.eventCode != 2)
		return 0
	endif
 
 	String ROIGraph = StringFromList(0, s.win, "#")
 
	String SaveDF = SetTraceFolder(ROIGraph, "")
	NVAR ROIsequence = ::ROIWaveSuffixNumber
	String theTrace = GetCurrentROITraceName(ROIGraph)
	String TInfo = TraceInfo(ROIGraph, theTrace, 0)
	String HAxis = StringByKey("XAXIS", TInfo)
	String VAxis = StringByKey("YAXIS", TInfo)
	String cmd = ""
	
 	NVAR ROINumPolys
 	SVAR PolyXWaves
 	SVAR PolyYWaves
	String XWaveName = GenerateROIPolyWaveName(1, ROIsequence)
	String YWaveName = GenerateROIPolyWaveName(0, ROIsequence)
	PolyXWaves += XWaveName+";"
	PolyYWaves += YWaveName+";"
	
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
	endif
	
	String TagName
	String TagMessage
		
	GraphWaveDraw/O $YWaveName, $XWaveName
	TagName = "ROITag_"+num2istr(ROINumPolys)
	TagName = UniqueName(TagName, 14, 0, ROIGraph)
	SVAR TagNames
	TagNames += TagName+";"
	if (UsingLongTags(ROIGraph))
		TagMessage = theTrace+":"
	else
		TagMessage = ""
	endif
	TagMessage += num2str(ROINumPolys)
			
	Tag/N=$TagName/F=0/X=-4/Y=4/A=RB $YWaveName, 0,TagMessage
	ROINumPolys += 1
	
	SVAR ROISequenceList
	ROISequenceList += num2str(ROIsequence)+";"
	ROIsequence += 1
	
	ROI_InstallDoneEditButton(ROIGraph)
	SetWindow $(ROIGraph+"#MaskWaveControlPanel"), UserData(EditingROIProperty)="YES"

	SetDataFolder $SaveDF
End

Function initGenMaskGlobals(GraphName, TraceName)
	String GraphName, TraceName

	String saveDF = SetTraceFolder(GraphName, TraceName)
	NVAR ROINumPolys
	
	Variable/G GenMaskDoMoreOptions = NumVarOrDefault("GenMaskDoMoreOptions", 0)
	
	Wave/Z/T MoreOptionsListWave
	if ( !(WaveExists(MoreOptionsListWave) && (DimSize(MoreOptionsListWave, 0) == ROINumPolys+1)) )
		Variable PreexistingOptionsWaves = WaveExists(MoreOptionsListWave)
		if (PreexistingOptionsWaves)
			Duplicate/FREE/T MoreOptionsListWave, OldListWave
		endif
		Make/O/T/N=(ROINumPolys+1, 2) MoreOptionsListWave
		Make/O/N=(ROINumPolys+1, 2) MoreOptionsSelWave
		Make/O/T/N=2 MoreOptionsTitleWave={"", "Mask Wave Value"}
		Variable i
		// JW 221118 The last row is special- it represents the value for points outside of any ROI.
		// So if there is a value there, it must be preserved specially
		String outsideValue = "0	"	// the default
		for (i = 0; i < ROINumPolys; i += 1)
			MoreOptionsListWave[i][0] = "Poly "+num2str(i)
			MoreOptionsListWave[i][1] = num2str(i+1)
		endfor
		if (PreexistingOptionsWaves)
			outsideValue = OldListWave[ROINumPolys][1]
			Variable numExistingPolys = min(DimSize(OldListWave,0)-1, ROINumPolys)		// -1 due to exterior value row
			MoreOptionsListWave[0, numExistingPolys-1][1] = OldListWave[p][1]
		endif
		MoreOptionsSelWave[][0] = 0
		MoreOptionsSelWave[][1] = 2
		MoreOptionsListWave[ROINumPolys][0] = "Exterior Points"
		MoreOptionsListWave[ROINumPolys][1] = outsideValue
	endif
	
	SetDatafolder $saveDF
end

Function DM_SwapMaskValuesButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String graphName = StringFromList(0, ba.win, "#")
			ControlInfo/W=$(graphName+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel#FewerOptionsPanel") DM_SetInteriorValue
			Variable interior = V_Value
			ControlInfo/W=$(graphName+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel#FewerOptionsPanel") DM_SetExteriorValue
			Variable exterior = V_Value
			SetVariable DM_SetInteriorValue,win=$(graphName+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel#FewerOptionsPanel"),value= _NUM:exterior
			SetVariable DM_SetExteriorValue,win=$(graphName+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel#FewerOptionsPanel"),value= _NUM:interior
			break
	endswitch

	return 0
End

Function DM_SwitchOptions(graphName, doMoreOptions)
	String graphName
	Variable doMoreOptions
	
	String TraceName = GetCurrentROITraceName(graphName)

	String SaveDF=	SetTraceFolder(GraphName, TraceName)
	NVAR GenMaskDoMoreOptions
	GenMaskDoMoreOptions = doMoreOptions
	SetDataFolder saveDF
	
	SetWindow $(graphName+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel#FewerOptionsPanel"), hide=doMoreOptions
	SetWindow $(graphName+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel#MoreOptionsPanel"), hide=!doMoreOptions
end

Function DM_GenMaskMoreOptionsButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String GraphName = StringFromList(0, ba.win, "#")
			DM_SwitchOptions(GraphName, 1)
			break
	endswitch

	return 0
End

Function DM_DataMaskFewerOptionsBtnProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String GraphName = StringFromList(0, ba.win, "#")
			DM_SwitchOptions(GraphName, 0)
			break
	endswitch

	return 0
End

Function MakeDataMaskDoItButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s
	
	if (s.eventCode != 2)		// mouse up
		return 0
	endif
	
	String GraphName = StringFromList(0, s.win, "#")
	String TraceName = GetCurrentROITraceName(GraphName)

	String SaveDF=	SetTraceFolder(GraphName, TraceName)
	String theTraceName = DM_TraceFromFolder(GraphName, GetDataFolder(1))
	NVAR GenMaskDoMoreOptions
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
	
	ControlInfo/W=$(graphName+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel") SetDataMaskWaveName
	String MaskWaveName = S_value
	Variable NameOK = CheckName(MaskWaveName, 1)
	if (NameOK != 0 && !Exists(MaskWaveName))	// if CheckName says no, but it's the name of an existing wave, it's a legal name
		SetDatafolder $SaveDF
		abort "Your wave name is not legal. It must not contain ';', ':', ';', or any quote marks."
	endif
	
	if (GenMaskDoMoreOptions)		
		Wave/T MoreOptionsListWave
	 	Wave DVW = TraceNameToWaveRef(GraphName, TraceName)
	 	WAVE/Z DVWX = XWaveRefFromTrace(GraphName, TraceName)
	 	if (!WaveExists(DVWX))
	 		Duplicate/O DVW, ROI_XWave
	 		Wave DVWX = $"ROI_XWave"
	 		DVWX = x
	 	endif
	 	
	 	SVAR PolyXWaves
	 	SVAR PolyYWaves
		Variable i

		ControlInfo/W=$(graphName+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel#MoreOptionsPanel") DM_GenMaskTextWave
		Variable MakeTextWave = V_value
		if (MakeTextWave)
			Make/O/T/N=(numpnts(ROI_Points)) $MaskWaveName
			Wave/T tw = $MaskWaveName
			tw = MoreOptionsListWave[ROINumPolys][1]
		else
			Duplicate/O ROI_Points, $MaskWaveName
			Wave w = $MaskWaveName
			Variable exteriorValue = str2num(MoreOptionsListWave[ROINumPolys][1])
			w = exteriorValue
		endif
	
	 	for (i = 0; i < ROINumPolys; i += 1)
			Wave XW = $StringFromList(i, PolyXWaves)
			Wave YW = $StringFromList(i, PolyYWaves)
	
	 		FindPointsInPoly DVWX, DVW, XW, YW
			Wave W_inPoly = W_inPoly
			if (MakeTextWave)
				tw = SelectString(W_inPoly[p] == 1, tw[p], MoreOptionsListWave[i][1])
			else
				Variable polyValue = str2num(MoreOptionsListWave[i][1])
				w = W_inPoly[p] == 1 ? polyValue : w[p]
			endif
		endfor
	else
		Duplicate/O ROI_Points, $MaskWaveName
		Wave w = $MaskWaveName

		ControlInfo/W=$(graphName+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel#FewerOptionsPanel") DM_SetInteriorValue
		Variable interior = V_Value
		ControlInfo/W=$(graphName+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel#FewerOptionsPanel") DM_SetExteriorValue
		Variable exterior = V_Value
		
		w = w[p]==1 ? interior : exterior
	endif

	
	Wave TraceWave = TraceNameToWaveRef("", theTraceName)
	SetDatafolder $(GetWavesDatafolder(TraceWave, 1))	// put the wave in the same data folder as the data wave
	
	if (Exists(MaskWaveName) == 1)
		Variable doPreKill = 0
		if ( (WaveType($MaskWaveName)==0) && (!MakeTextWave) )
			doPreKill = 1
		endif
		if ( (WaveType($MaskWaveName)!=0) && (MakeTextWave) )
			doPreKill = 1
		endif
		
		if (doPreKill)
			try
				KillWaves $MaskWaveName; AbortOnRTE
			catch
				if (V_AbortCode == -4)
					DoAlert 0, "Can't kill pre-existing wave \""+MaskWaveName+"\":\r\r"+GetRTErrMessage()
					Variable dumb = GetRTError(1)
					return -1
				endif
			endtry
		endif
	endif
	
	if (MakeTextWave)
		Duplicate/O/T tw, $MaskWaveName
		KillWaves/Z tw
	else
		Duplicate/O w, $MaskWaveName
		KillWaves/Z w
	endif
	
	SetDatafolder $SaveDF
End

// This function assumes that it is called only when the relevant graph window
// is the top one. As long as it is called by a control action proc in the graph
// window, that will be true
Function ROI_InstallDoneEditButton(gname)
	String gname
	
	SetWindow $(gname+"#MaskWaveControlPanel#ROIDefaultPanel"), hide=1
	SetWindow $(gname+"#MaskWaveControlPanel#ROI_InstallDonePanel"), hide=0
end

Function/S Non_ROI_TraceNameList(graphname)
	String graphname
	
	String theList=""
	String allTraces = TraceNameList(graphname, ";", 1)
	String oneTrace
	
	Variable i
	Variable nItems = ItemsInList(allTraces)
	if (nItems == 0)
		return NoTracesString
	endif
	for (i = 0; i < nItems; i += 1)
		oneTrace = StringFromList(i, allTraces)
		if (strlen(oneTrace) == 0)
			break
		endif
		if (CmpStr(oneTrace[0,6], "ROIPoly") != 0)
			String info = TraceInfo(graphname, oneTrace, 0)
			String YSubRange = StringByKey("YRANGE", info)
			String XSubRange = StringByKey("XRANGE", info)
			if (CmpStr(YSubRange, "[*]") != 0)
				continue
			endif
			if (strlen(XSubRange) == 0 || CmpStr(XSubRange, "[*]") == 0)
				theList += oneTrace+";"
			endif
		endif
	endfor
	
	if (strlen(theList) == 0)
		theList = NoTracesString
	endif
	
	return theList
end

Function GenDataMaskHelpButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode == 2)
		String theGraph = StringFromList(0, s.win, "#")
		Button ROIHelpButton,win=$(theGraph+"#MaskWaveControlPanel"),title = "Looking"
		DisplayHelpTopic "Select Points for Mask"
		Button ROIHelpButton,win=$(theGraph+"#MaskWaveControlPanel"),title = "Help"
	endif
end

Function ROIModPolyPopMenuProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s
	
	if (s.eventCode != 2)
		return 0
	endif

	String gname = StringFromList(0, s.win, "#")
	
 	String SaveDF = SetTraceFolder(gname,"")
 	String theTrace = GetCurrentROITraceName(gname)
	
 	NVAR ROINumPolys = ROINumPolys
 	SVAR ROISequenceList
 	Variable ROISequenceNumber = str2num(StringFromList(s.popNum-1, ROISequenceList))
 	SVAR PolyXWaves
 	SVAR PolyYWaves
	String XWaveName = StringFromList(s.popNum-1, PolyXWaves)
	String YWaveName = StringFromList(s.popNum-1, PolyYWaves)

//	InstallROIGraphHook()
	GraphWaveEdit $YWaveName

	ROI_InstallDoneEditButton(gname)
	SetDataFolder $SaveDF
End

Function ROIWhichTraceMenuProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s
	
	if (s.eventCode != 2)
		return 0
	endif
	
	if (CmpStr(s.popstr, NoTracesString) == 0)
		return 0
	endif

	String theGraph = StringFromList(0, s.win, "#")
	
	String SaveDF = GetDataFolder(1)
	InitTraceFolder(theGraph, s.popStr)
	SetTraceFolder(theGraph,"")
	initGenMaskGlobals(theGraph, s.popStr)
	ListBox DM_MoreOptionsList,listWave=MoreOptionsListWave,selWave=MoreOptionsSelWave,win=$(theGraph+"#MaskWaveControlPanel#GenerateMaskWaveTabPanel#MoreOptionsPanel")
	NVAR ROINumPolys

	SetVariable DispNumPolys, win=$(theGraph+"#MaskWaveControlPanel"),value=ROINumPolys
	
	SetDatafolder $saveDF
End

Function ROIDeletePolyPopMenuProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s

	if (s.eventCode != 2)
		return 0
	endif

	String gname = StringFromList(0, s.win, "#")
	
  	Variable i
 	String XWaveName
 	String YWaveName
 	
	String SaveDF = SetTraceFolder(gname,"")
	String theTrace = GetCurrentROITraceName(gname)
 	NVAR ROINumPolys = ROINumPolys
 	SVAR ROISequenceList
 	SVAR TagNames
 	SVAR PolyXWaves
 	SVAR PolyYWaves
 	Variable ROISequenceNumber
	
	if (CmpStr(s.popStr, "Delete All") == 0)
		for (i=0; i<ROINumPolys; i+=1)
			XWaveName = StringFromList(i, PolyXWaves)
			YWaveName = StringFromList(i, PolyYWaves)
			Wave XY = $YWaveName
			CheckDisplayed/W=$gname XY
			if (V_flag)
				RemoveFromGraph/W=$gname $YWaveName
			endif
			KillWaves/Z $XWaveName, $YWaveName
		endfor
		ROINumPolys = 0
		ROISequenceList = ""
		PolyXWaves = ""
		PolyYWaves = ""
		TagNames = ""
	else
		ROISequenceNumber = str2num(StringFromList(s.popNum-1, ROISequenceList))
		XWaveName = StringFromList(s.popNum-1, PolyXWaves)
		YWaveName = StringFromList(s.popNum-1, PolyYWaves)
		Wave XY = $YWaveName
		CheckDisplayed/W=$gname XY
		if (V_flag)
			RemoveFromGraph/W=$gname $YWaveName
		endif
		KillWaves/Z $XWaveName, $YWaveName
		ROISequenceList = RemoveFromList(num2str(ROISequenceNumber), ROISequenceList)
		TagNames = RemoveListItem(s.popNum-1, TagNames)
		PolyXWaves = RemoveFromList(XWaveName, PolyXWaves)
		PolyYWaves = RemoveFromList(YWaveName, PolyYWaves)
		ROINumPolys -= 1
	endif
	DoUpdate
	GenPointInPolyWave(gname,"")
	if (WantsColorSelection(gname))
		ColorROIPoints(gname, 1)
	endif
	DM_RefreshTags(gname)

	SetDataFolder $SaveDF
End

// The sequence number is kept for the entire graph, so that the various ROI poly trace names are
// unique even when the same wave is graphed twice, or the same name is used for two different waves
// on the same graph.
Function/S GenerateROIPolyWaveName(isX, sequenceNumber)
	Variable isX		
	Variable sequenceNumber
	
	String theName = "ROIPoly"
	if (isX)
		theName += "X"
	else
		theName += "Y"
	endif
	theName += num2istr(sequenceNumber)
	return theName
end

Function/S DM_TraceFromFolder(theGraph, folderPath)
	String theGraph, folderPath
	
	String saveDF = GetDataFolder(1)
	SetDataFolder folderPath
	
	String theTrace = ""
	String tlist = TraceNameList(theGraph, ";", 1)
	Variable nTraces = ItemsInList(tlist)
	Variable j
	
	for (j = 0; j < nTraces; j += 1)
		String oneTrace = StringFromList(j, tlist)
		String traceDF = GetUserData(theGraph, oneTrace, DFUDName)
		if (CmpStr(traceDF, folderPath) == 0)
			theTrace = oneTrace
			break;
		endif
	endfor	
	
	SetDataFolder saveDF
	return theTrace
end
	

Function ColorROIPoints(theGraph, colorON)
	String theGraph
	Variable colorON
	
	String saveDF = SetGraphFolder(theGraph)
	NVAR ColorSelection
	ColorSelection = colorON
	
	Variable numTraceFolders
	Variable i
	String TraceFolder
	String saveGraphFolder = GetDatafolder(1)
	
	numTraceFolders = CountObjects(":", 4 )
	for (i = 0; i < numTraceFolders; i += 1)
		TraceFolder = GetIndexedObjName(":", 4, i)
		SetFolderFromNames(theGraph, TraceFolder)
   		NVAR ROINumPolys = ROINumPolys
		String theTrace = DM_TraceFromFolder(theGraph, GetDataFolder(1))
	 	if (colorON && (ROINumPolys > 0))
		 	Wave/Z ROI_Points=ROI_Points
		 	if (!WaveExists(ROI_Points))
	 			GenPointInPolyWave(theGraph, theTrace)
	 			Wave ROI_Points=ROI_Points
	 		endif
		 	ModifyGraph zColor($theTrace)={ROI_Points,*,*,RainBow}
		else
		 	ModifyGraph zColor($theTrace)=0
		 endif
		 SetDatafolder $saveGraphFolder
	endfor

	SetDataFolder $SaveDF
end

Function ColorROIPointsCheckProc (s) : CheckBoxControl
	STRUCT WMCheckboxAction &s
	
	if (s.eventCode != 2)
		return 0
	endif
	
	String theGraph = StringFromList(0, s.win, "#")
	
	ColorROIPoints(theGraph, s.checked)
end

Function DM_RefreshTags(theGraph)
	String theGraph
	
	String saveDF = SetGraphFolder(theGraph)
	
	Variable numTraceFolders
	Variable i,j
	String TraceFolder
	String saveGraphFolder = GetDatafolder(1)
	String annoList = AnnotationList(theGraph)
	String oneAnno
	String TagMessage
	String TagNameBase
	Variable annoBaseLength
	
	numTraceFolders = CountObjects(":", 4 )
	for (i = 0; i < numTraceFolders; i += 1)
		TraceFolder = GetIndexedObjName(":", 4, i)
		SetFolderFromNames(theGraph, TraceFolder)
		String theTrace = DM_TraceFromFolder(theGraph, GetDataFolder(1))

		j = 0
		do
			SVAR TagNames
			oneAnno = StringFromList(j, TagNames)
			if (strlen(oneAnno) == 0)
				break;
			endif
			if (WhichListItem(oneAnno, annoList) < 0)
				TagNames = RemoveFromList(oneAnno, TagNames)
				j -= 1
				continue
			endif
			if (UsingLongTags(theGraph))
				TagMessage = theTrace+":"
			else
				TagMessage = ""
			endif
			TagMessage += num2str(j)
			Tag/W=$theGraph/N=$oneAnno/C TagMessage
			
			j += 1
		while (1)
   		
		 SetDatafolder $saveGraphFolder
	endfor

	SetDataFolder $SaveDF	
end
	
Function ROILongTagsCheckProc (s) : CheckBoxControl
	STRUCT WMCheckboxAction &s
	
	if (s.eventCode != 2)
		return 0
	endif
	
	String theGraph = StringFromList(0, s.win, "#")
	
	DM_RefreshTags(theGraph)
end

Function GenPointInPolyWave(theGraph, theTraceName)		// Assumes that the current DataFolder is the one appropriate for the current graph
	String theGraph, theTraceName
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0,1)
	endif
	if (strlen(theTraceName) == 0)
		ControlInfo/W=$(theGraph+"#MaskWaveControlPanel") ROIWhichTraceMenu
		theTraceName = S_value
	endif
	
 	String saveDF = SetTraceFolder(theGraph, theTraceName)
 	
 	NVAR ROINumPolys
 	SVAR ROISequenceList
 	SVAR PolyXWaves
 	SVAR PolyYWaves

  	String XWaveName
 	String YWaveName
	Variable ROISequenceNumber

 	Wave DVW = TraceNameToWaveRef(theGraph, theTraceName)
 	WAVE/Z DVWX = XWaveRefFromTrace(theGraph, theTraceName)

 	if (!WaveExists(DVWX))
 		Duplicate/O DVW, ROI_XWave
 		Wave DVWX = $"ROI_XWave"
 		DVWX = x
 	endif

 	Variable i
 	
 	Make/O/N=(numpnts(DVW)) ROI_Points=0
 	for (i = 0; i < ROINumPolys; i += 1)
		Wave XW = $StringFromList(i, PolyXWaves)
		Wave YW = $StringFromList(i, PolyYWaves)

 		FindPointsInPoly DVWX, DVW, XW, YW
		Wave W_inPoly = W_inPoly
		ROI_Points = ROI_Points | W_inPoly
	endfor
	
	for (i = ROINumPolys-1; i >= 0; i -= 1)
		Wave XW = $StringFromList(i, PolyXWaves)
		Wave YW = $StringFromList(i, PolyYWaves)
		
		if (numpnts(YW) == 0)
			KillWaves YW, XW
			PolyXWaves = RemoveListItem(i, PolyXWaves)
			PolyYWaves = RemoveListItem(i, PolyYWaves)
			ROINumPolys -= 1
		endif
	endfor
	 	
	SetDataFolder $SaveDF
end

Function ROIDoneEditing(ROIGraph)
	String ROIGraph
	
	GraphNormal/W=$ROIGraph

 	GenPointInPolyWave(ROIGraph,"")
	if (WantsColorSelection(ROIGraph))
		ColorROIPoints(ROIGraph, 1)
	endif
	SetWindow $(ROIGraph+"#MaskWaveControlPanel"), UserData(EditingROIProperty)="NO"
end	

Function ROIDoneEditingButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s
	
	if (s.eventCode != 2)
		return 0
	endif

 	String ROIGraph = StringFromList(0, s.win, "#")

	ROIDoneEditing(ROIGraph)
	
	SetWindow $(ROIGraph+"#MaskWaveControlPanel#ROI_InstallDonePanel"), hide=1
	SetWindow $(ROIGraph+"#MaskWaveControlPanel#ROIDefaultPanel"),hide=0
End

Function DM_MoreOptionsListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave

	switch( lba.eventCode )
		case 1:					// mouse down
			if ( (lba.eventMod & 4) || (lba.eventMod & 16) )		// option- or context-click?
				if ( (lba.row >= 0) && (lba.row < DimSize(lba.listWave, 0)) )
					if (lba.col == 0)
						// Whew! we know it's a context click in a real row and the value column
						PopupContextualMenu/N "DM_MarkerMenu"
						if (V_flag >= 0)
							if (CmpStr(S_selection, "NaN") == 0)
								lba.listWave[lba.row][1] = "NaN"
							else
								GetLastUserMenuInfo
								lba.listWave[lba.row][1] = num2str(V_value)
							endif
						endif
					endif
				endif
			endif
			break;
	endswitch

	return 0
End