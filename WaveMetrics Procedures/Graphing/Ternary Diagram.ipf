#pragma rtGlobals=1		// Use modern global access method.
#include <WaveSelectorWidget>, version=1.21
#include <PopupWaveSelector>, version=1.12
#include <Resize Controls>
#pragma version=1.07
#pragma IgorVersion=8.0
#pragma IndependentModule=TernaryDiagramModule

//******************************
// Ternary Diagram.ipf
// Revision History
// 1.0		Initial Release
// 1.01		On Windows, Ternary Graph menu items in the Graph menu resulted in Too Many Items in the Graph menu.
// 1.02		Removed the alert about killing the data when a ternary diagram is killed. Too easy to get it wrong.
// 1.03		Fixed bug: when initializing the Modify Ternary Labels panel, Side Labels tab, the right and bottom labels were swapped.
// 1.04		Added support for Strikethrough text style, removed support for Shadow and Outline text styles. Used some Igor 7-only syntax in the code!
// 1.05		Fixed possible uninitialized temporary variable error in NewTernaryGraph() function if the "error" optional input wasn't used when the function is called.
// 1.06		JP181029: Private data is killed when ternary graph is closed without leaving behind a window recreation macro.
//				Added "Remove unused Ternary Diagram data" menu item to the Data menu and the Ternary Diagram submenu.
//				Rewrote the SetFormula and UpdateTernaryData code to avoid unnecessary updates of ternary contour and trace data.
//				Changes to various panel "dialogs", mostly related to wave list sorting, but also to clean up unnecessary dependencies and computed ternary data.
// 1.07		JW 210909: Added ability to set a multiplier for the displayed tick label numbers
//				Added ability to set tick label units other than %
//				Added ability to set a different tick label number format other than %d
//******************************

StrConstant 	ksPackageDF= "root:Packages:WM_TernaryDiagrams"
StrConstant 	ksPackageDFC= "root:Packages:WM_TernaryDiagrams:" // with colon

Menu "New"
	"New Ternary Diagram", /Q, mNewTernaryGraph()
end

Menu "Data"
	"Remove unused Ternary Diagram data", /Q, mRemoveUnusedTernaryData()
End

Menu "Graph"
	Submenu "Ternary Diagram"
		"Add Ternary Diagram Trace", /Q, mAddTernaryTracePanel()
		"Add Ternary Diagram Contour", /Q, mAddTernaryContourPanel()
		"Remove Ternary Diagram Trace or Contour", /Q, mRemoveTernaryTracePanel()
		"Modify Ternary Axes, Ticks and Grid", /Q, mModifyTernaryLinesPanel()
		"Modify Ternary Labels", /Q, mModifyTernaryLabelsPanel()
		"Help For Ternary Diagrams", /Q, DisplayHelpTopic "Ternary Diagrams"
		"-"
		"Remove unused Ternary Diagram data", /Q, mRemoveUnusedTernaryData()
	end
end

Function mNewTernaryGraph()

	if (WinType("NewTernaryGraphPanel") == 7)
//		print "Found an existing NewTernaryGraphPanel"
		DoWindow/F NewTernaryGraphPanel
	else
//		print "Building NewTernaryGraphPanel"
		BuildNewTernaryGraphPanel()
	endif
end

Function BuildNewTernaryGraphPanel()

	MakeTernaryDataFolder()

	NewPanel/N=NewTernaryGraphPanel/W=(564,173,1226,736)/K=1 as "New Ternary Graph"
	String panelName = S_name
	ModifyPanel/W=$panelName fixedSize=1, noEdit=1

	TitleBox SelectAWaveTitle,pos={21,11},size={119,16},title="Select A Component"
	TitleBox SelectAWaveTitle,fSize=12,frame=0
	
	ListBox TernaryPanel_AList,pos={17,34},size={198,205}
	MakeListIntoWaveSelector(panelName, "TernaryPanel_AList", selectionMode=WMWS_SelectionSingle, listoptions="DIMS:1,CMPLX:0")

	Variable sortKind= -1 // get default
	Variable sortReverse=  -1 // get default
	GetSetTernarySortKindAndOrder(sortKind,sortReverse) // gets current or default
	GetSetTernarySortKindAndOrder(sortKind,sortReverse) // sets current

	WS_SetGetSortOrder(panelName, "TernaryPanel_AList", sortKind, sortReverse)
	WS_SelectAnObject(panelName, "TernaryPanel_AList", WS_IndexedObjectPath(panelName, "TernaryPanel_AList", 0))
	
	TitleBox SelectBWaveTitle,pos={237,11},size={118,16},title="Select B Component"
	TitleBox SelectBWaveTitle,fSize=12,frame=0
	
	ListBox TernaryPanel_BList,pos={232,34},size={198,205}
	MakeListIntoWaveSelector(panelName, "TernaryPanel_BList", selectionMode=WMWS_SelectionSingle, listoptions="DIMS:1,CMPLX:0")
	WS_SetGetSortOrder(panelName, "TernaryPanel_BList", sortKind, sortReverse)
	WS_SelectAnObject(panelName, "TernaryPanel_BList", WS_IndexedObjectPath(panelName, "TernaryPanel_BList", 1))
	
	TitleBox SelectCWaveTitle,pos={453,11},size={118,16},title="Select C Component"
	TitleBox SelectCWaveTitle,fSize=12,frame=0
	
	ListBox TernaryPanel_CList,pos={448,34},size={198,205}
	MakeListIntoWaveSelector(panelName, "TernaryPanel_CList", selectionMode=WMWS_SelectionSingle, listoptions="DIMS:1,CMPLX:0")
	WS_SetGetSortOrder(panelName, "TernaryPanel_CList", sortKind, sortReverse)
	WS_SelectAnObject(panelName, "TernaryPanel_CList", WS_IndexedObjectPath(panelName, "TernaryPanel_CList", 2))
	
	TitleBox SelectZWaveTitle,pos={21,275},size={186,16},title="Select Z Data (for Contour Plot)"
	TitleBox SelectZWaveTitle,fSize=12,frame=0
	
	ListBox TernaryPanel_ZList,pos={17,298},size={198,205}
	MakeListIntoWaveSelector(panelName, "TernaryPanel_ZList", selectionMode=WMWS_SelectionSingle, listoptions="DIMS:1,CMPLX:0")
	WS_AddSelectableString(panelName, "TernaryPanel_ZList", "_none_")
	WS_SetGetSortOrder(panelName, "TernaryPanel_ZList", sortKind, sortReverse)
	WS_SelectAnObject(panelName, "TernaryPanel_ZList", "_none_")

	PopupMenu sortPopup,pos={370,375},size={100,23},title="Sort Lists by"
	MakePopupIntoWaveSelectorSort(panelName, "TernaryPanel_AList", "sortPopup")
	MakePopupIntoWaveSelectorSort(panelName, "TernaryPanel_BList", "sortPopup")
	MakePopupIntoWaveSelectorSort(panelName, "TernaryPanel_CList", "sortPopup")
	MakePopupIntoWaveSelectorSort(panelName, "TernaryPanel_ZList", "sortPopup")
	WS_SetGetSortOrder(panelName, "sortPopup", sortKind, sortReverse)
	
	Button TernaryGraphPanelDoItButton,pos={19,530},size={100,20},proc=TernaryGraphDoItButtonProc,title="Do It"
	
	Button TernaryGraphPanelCancelButton,pos={544,530},size={100,20},proc=TernaryGraphCancelButtonProc,title="Cancel"

	Button NewTernaryHelpButton,pos={423,530},size={100,20},proc=HelpButtonProc,title="Help"
	
	SetWindow NewTernaryGraphPanel hook(NewTernaryGraphPanel)=NewTernaryGraphPanelHook
end

Function NewTernaryGraphPanelHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	strswitch(s.eventName)
		case "killVote": // "kill" is too late to get a values from controls
			SaveNewTernaryGraphPanelSort()
			hookResult = 0 // ensure we don't prevent the window from being killed.
			break
	endswitch

	return hookResult		// 0 if nothing done, else 1
End

Function SaveNewTernaryGraphPanelSort()

	// copy panel's sort parameters back to global memory
	Variable sortKind= -1 // get current sort kind
	Variable sortReverse= -1 // get current sort reverse
	WS_SetGetSortOrder("NewTernaryGraphPanel", "sortPopup", sortKind, sortReverse)
	GetSetTernarySortKindAndOrder(sortKind,sortReverse)
End

Constant TG_Err_Success = 0
Constant TG_Err_MismatchPnts = 1
Constant TG_Err_NoTextWave = 2
Constant TG_Err_CouldNotCreateWave = 3

Static Constant MaxNameLen=31

Structure TernaryGraphProperties
	char graphName[MaxNameLen]
	
endStructure

Static StrConstant TG_VertAxis="TernaryGraphVertAxis"
Static StrConstant TG_HorizAxis="TernaryGraphHorizAxis"

Function/S NewTernaryGraph(waveA, waveB, waveC, gname [, HOST, waveZ, error])
	Wave waveA, waveB, waveC
	String gname
	String HOST
	Wave waveZ
	Variable &error
	
	if (ParamIsDefault(HOST))
		HOST = ""
	endif
	
	gname = NewTernaryGraphWindow(gname, HOST=HOST)
	String theDF = MakeTernaryGraphDataFolder(gname)
	SetWindow $gname userData(TernaryGraphDFPath)=theDF
	RememberGraphNameInDF(gname) // needs TernaryGraphDFPath
	
	Variable theError = 0
	
	if (ParamIsDefault(waveZ))
		theError = AddTernaryDataToGraph(waveA, waveB, waveC, gname)
	else
		theError = AddTernaryXYZContourToGraph(waveA, waveB, waveC, waveZ, gname)
	endif

	MeasureStyledText/F=GetDefaultFont(gname)/SIZE=(GetDefaultFontSize(gname, "TernaryGraphVertAxis")) "100%"
	Variable offset = V_height*0.5 + V_width*cos30+3			// 3 is from the offset input to DrawTernaryGraphTickLabels above
	DrawTernaryGraphCornerLabels(gname, NameOfWave(waveA), 0,0,0, GetDefaultFont(gname), GetDefaultFontSize(gname, "TernaryGraphVertAxis"), 0, offset, 0, "Left")
	DrawTernaryGraphCornerLabels(gname, NameOfWave(waveB), 0,0,0, GetDefaultFont(gname), GetDefaultFontSize(gname, "TernaryGraphVertAxis"), 0, offset, 0, "Right")
	DrawTernaryGraphCornerLabels(gname, NameOfWave(waveC), 0,0,0, GetDefaultFont(gname), GetDefaultFontSize(gname, "TernaryGraphVertAxis"), 0, 10, 0, "Top")
	
	if (!ParamIsDefault(error))
		error = theError
	endif
	
	return gname
end

Function/S NewTernaryGraphWindow(gname [,HOST])
	String gname
	String HOST
	
	if (strlen(gname) == 0)
		gname = "TernaryGraph"
	endif
	
	if (WinType(gname) != 0)
		gname = UniqueName(gname, 6, 0)
	endif
	
	if (ParamIsDefault(HOST) || (strlen(HOST) == 0))
		Display/N=$gname
	else
		Display/N=$gname/HOST=$HOST
		gname = HOST+"#"+gname
	endif
	
	NewFreeAxis/L $TG_VertAxis
	NewFreeAxis/B $TG_HorizAxis
	SetAxis/W=$gname $TG_HorizAxis 0,1
	SetAxis/W=$gname $TG_VertAxis 0,cos30
	ModifyGraph noLabel=2,axThick=0,freePos($TG_VertAxis)={0,kwFraction}
	ModifyGraph freePos($TG_HorizAxis)={0,kwFraction}
	ModifyGraph width={Plan,1,$TG_HorizAxis, $TG_VertAxis}
	DrawDefaultTernaryAxes(gname)
	
	DrawTernaryGraphGrid(gname, .1, 50000, 50000, 50000, 1, 0)
	//JW 210909 Use defaults for tick label multiplier, unit, and format
	DrawTernaryGraphTickLabels(gname, .1, 0, 0, 0, GetDefaultFont(gname), GetDefaultFontSize(gname, "TernaryGraphVertAxis"), 1, 3, "Bottom")
	DrawTernaryGraphTickLabels(gname, .1, 0, 0, 0, GetDefaultFont(gname), GetDefaultFontSize(gname, "TernaryGraphVertAxis"), 1, 3, "Left")
	DrawTernaryGraphTickLabels(gname, .1, 0, 0, 0, GetDefaultFont(gname), GetDefaultFontSize(gname, "TernaryGraphVertAxis"), 1, 3, "Right")
	
	MeasureStyledText/F=GetDefaultFont(gname)/SIZE=(GetDefaultFontSize(gname, "TernaryGraphVertAxis")) "100%"
	Variable offset = V_height*0.5 + V_width*cos30+3			// 3 is from the offset input to DrawTernaryGraphTickLabels above
	// this makes room for corner labels; since we don't know the labels yet just use the height of "100%"
	ModifyGraph margin(top)=V_height+15						// 15  is the offset of 10 from the last call to DrawTernaryGraphCornerLabels above, plus a margin of 5
	ModifyGraph margin(bottom)=offset+V_height+5

	DrawTernaryGraphCornerLabels(gname, "A", 0,0,0, GetDefaultFont(gname), GetDefaultFontSize(gname, "TernaryGraphVertAxis"), 0, offset, 0, "Left")
	DrawTernaryGraphCornerLabels(gname, "B", 0,0,0, GetDefaultFont(gname), GetDefaultFontSize(gname, "TernaryGraphVertAxis"), 0, offset, 0, "Right")
	DrawTernaryGraphCornerLabels(gname, "C", 0,0,0, GetDefaultFont(gname), GetDefaultFontSize(gname, "TernaryGraphVertAxis"), 0, 10, 0, "Top")

	SetWindow $gname hook(TernaryGraphHook)=TernaryGraphWindowHook

	return gname
end

// SetWindow TernaryGraph hook(TernaryGraphHook)=TernaryDiagramModule#TernaryGraphWindowHook

Function TernaryGraphWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0
	String win= s.winName		// s.winName will be the (possibly edited) name shown in the Close Window dialog.
	String theDF
	strswitch(s.eventName)
		case "renamed":
			RememberGraphNameInDF(win)
			if( GetTernaryDebug() )
				Print ""+s.oldWinName + " has been renamed to "+win
			endif
			break

		case "kill":
			theDF= TernaryGraphDFPath(win) // from GetUserData
			String cmd= GetIndependentModuleName()+"#PossiblyRemoveTernaryDF(\""+win+"\", \""+theDF+"\")"
			if( GetTernaryDebug() )
				Print "TernaryGraphWindowHook: command= \""+cmd+"\""
			endif
			Execute/P/Q/Z "COMPILEPROCEDURES " // so the saved recreation macro shows up in MacroList
			Execute/P/Q/Z cmd
			break
			
		case "modified":
			// TO DO: detect user manually removing a ternary trace or ternary contour
			// and delete the corresponding dependency anchor variable (and thus, the dependency formula)
			// and the ternaryData wave.
			theDF= TernaryGraphDFPath(win) // from GetUserData
			// CleanTernaryDataFolder(win, theDF)
			break
	endswitch

	return hookResult		// 0 if nothing done, else 1
End

Function PossiblyRemoveTernaryDF(win, theDF)
	String win
	String theDF // full path to data folder, usually from TernaryGraphDFPath(theDF)
	
	Variable removed= 0
	String dfName= ParseFilePath(0, theDF, ":", 1, 0)

	if( strlen(dfName) )
		String dfsThatMayBeDeleted = DataFoldersToBeDeleted() // string list of data folder names
		Variable whichOne = strlen(dfsThatMayBeDeleted) ? WhichListItem(dfName, dfsThatMayBeDeleted) : -1
		if( whichOne < 0 )
			// df is not on the list of deletable Ternary Diagram data folders
			if( GetTernaryDebug() )
				Print "Have recreation macro or open window referencing "+theDF+" (derived ternary data not deleted)."
			endif
		else
			String msg = "Delete the data computed by the Ternary Diagram package?"
			msg += "\r\rNo window or recreation macro references the datafolder"
			msg += "\r"+RemoveEnding(theDF)+"."
			msg += "\r\r(Your input data won't be deleted, regardless.)"
			DoAlert/T="Delete Ternary Diagram Package Data" 1, msg
			if( V_Flag == 1 ) // "Yes"
				removed= RemoveTernaryGraphDataFolder(theDF)
				if( removed && GetTernaryDebug() )
					Print "Removed ternary datafolder: "+theDF+"."
				endif
			endif
		endif
	endif
	return removed
End

Function/S SetTernaryDataFolder()
	String oldDF= GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_TernaryDiagrams
	NVAR/Z sk= sortKind
	if( NVAR_Exists(sk) == 0 )
		// initialize sorting settings used for all Ternary wave lists and popups
		Variable sortKind= -1 // get default
		Variable sortReverse=  -1 // get default
		GetSetTernarySortKindAndOrder(sortKind,sortReverse) // gets current or default
		GetSetTernarySortKindAndOrder(sortKind,sortReverse) // saves as current
	endif
	return oldDF
End

Function MakeTernaryDataFolder()
	String saveDF = SetTernaryDataFolder()
	SetDataFolder saveDF
End

// returns full path to the (unique) data folder it makes
Function/S MakeTernaryGraphDataFolder(gname)
	String gname

	String theDF=""
	String saveDF = SetTernaryDataFolder()
	String leafName = ParseFilePath(0, gname, "#", 1, 0)
	if (DataFolderExists(leafName))
		leafName = UniqueName(leafName, 11, 0)
	endif
	NewDataFolder/O/S $leafName
	theDF = GetDataFolder(1)
	SetDataFolder saveDF
	
	return theDF
end

// Use the Data Browser to set root:Packages:WM_TernaryDiagrams:debugEnabled
Function GetTernaryDebug()

	String path= ksPackageDFC+"debugEnabled"
	Variable isDebug= NumVarOrDefault(path, 0) // off by default
	Variable/G $path=isDebug // create the variable so the user can find it.
	return isDebug
End

Function GetSetTernarySortKindAndOrder(sortKindOrMinus1,sortReverseOrMinus1)
	Variable &sortKindOrMinus1 // -1 to get the current value
	Variable &sortReverseOrMinus1 // -1 to get the current value

	String path= ksPackageDFC+"sortKind"
	if( sortKindOrMinus1 == -1 )
		sortKindOrMinus1= NumVarOrDefault(path, WMWS_sortByName)
	else
		Variable/G $path=sortKindOrMinus1
	endif

	path= ksPackageDFC+"sortReverse"
	if( sortReverseOrMinus1 == -1 )
		sortReverseOrMinus1= NumVarOrDefault(path, 0)
	else
		Variable/G $path=sortReverseOrMinus1
	endif
End

Function/S TernaryGraphDFPath(gname)
	String gname
	
	return GetUserData(gname, "", "TernaryGraphDFPath")
end

Function AddTernaryDataToGraph(waveA, waveB, waveC, gname)
	Wave waveA, waveB, waveC
	String gname
	
	Variable error
	
	String DFPath = TernaryGraphDFPath(gname)
	Wave/Z ternaryData = MakeTernaryData(waveA, waveB, waveC, DFPath, error=error)
	if (error)
		return error
	endif
	AppendToGraph/W=$gname/B=$TG_HorizAxis/L=$TG_VertAxis ternaryData[][1] vs ternaryData[][0]
	String tlist = TraceNameList(gname, ";", 1)
	String tname = StringFromList(ItemsInList(tlist)-1, tlist)		// it will always be the last trace because it was just appended
	ModifyGraph/W=$gname mode($tname)=3, marker($tname)=8
	
	return 0
end

Function AddTernaryXYZContourToGraph(waveA, waveB, waveC, waveZ, gname)
	Wave waveA, waveB, waveC, waveZ
	String gname
	
	Variable error
	
	String DFPath = TernaryGraphDFPath(gname)
	Wave/Z ternaryData = MakeTernaryData(waveA, waveB, waveC, DFPath, waveZ=waveZ, error=error) // also creates dependency on 
	if (error)
		return error
	endif
	AppendXYZContour /W=$gname/B=$TG_HorizAxis/L=$TG_VertAxis ternaryData
	return 0
end

// pre-1.06: Use UpdateTernaryContourData() only to update to 1.06's UpdateTernaryXYZContourData() dependency:
//
//		Keep the name UpdateTernaryContourData unchanged,
//		but use UpdateTernaryContourData() to
//		detect and rewrite the dependency to use the new (1.06) method.
//
// The pre-1.06 problem with having both UpdateTernaryData and UpdateTernaryContourData dependencies
// was that they both update ternaryDataWave which causes an unending updating loop
// that is triggered when ANY global variable or wave is modified (which is often).
Function UpdateTernaryContourData(waveZ, ternaryDataWave)
	Wave waveZ // input
	Wave ternaryDataWave // output
	
	Variable returnVal= NaN
	String path
	if( 0 )
		ternaryDataWave[][2] = waveZ[p]// pre 1.06
		returnVal= datetime
		if( GetTernaryDebug() )
			path= ksPackageDFC+"debugCount"
			Variable/G $path
			NVAR debugCount=$path
			debugCount= debugCount+1
			Print debugCount," UpdateTernaryContourData(): updated "+GetWavesDataFolder(ternaryDataWave,2)
		endif
	else
		String pathToWaveZ= GetWavesDataFolder(waveZ,2)
		String pathToTernaryData= GetWavesDataFolder(ternaryDataWave,2)
		String cmd= GetIndependentModuleName()+"#RewriteContourDataDependency("+pathToWaveZ+", "+pathToTernaryData+")"
		if( GetTernaryDebug() )
			Execute/P/Z cmd	// debug
			path= ksPackageDFC+"debugCount"
			Variable/G $path
			NVAR debugCount=$path
			debugCount= debugCount+1
			Print debugCount," UpdateTernaryContourData(): executing "+cmd
		else
			Execute/P/Q/Z cmd // release
		endif
	endif
	return returnVal
End

Function RewriteContourDataDependency(waveZ, ternaryDataWave)
	Wave/Z waveZ // input
	Wave/Z ternaryDataWave // output, but also contains keys with paths to other data waves
	
	if( !WaveExists(ternaryDataWave) )
		return 0 // failed.
	endif
	
	WAVE/Z waveA= TernaryWaveByKey(ternaryDataWave, "waveA")
	WAVE/Z waveB= TernaryWaveByKey(ternaryDataWave, "waveB")
	WAVE/Z waveC= TernaryWaveByKey(ternaryDataWave, "waveC")
	WAVE/Z waveZ= TernaryWaveByKey(ternaryDataWave, "waveZ")

	Debugger // temporary
	
	String dfPath= GetWavesDataFolder(ternaryDataWave,1) // just the path to the data folder (without the wave name), with ending ":"
	String oldContourVarName= TernaryStringByKey(ternaryDataWave, "TGCDependencyVar")
	// kill the old contour dependency by deleting the global variable.
	String pathToDependencyVar = dfPath+oldContourVarName
	KillVariables/Z $pathToDependencyVar

	// kill the old trace dependency by deleting the global variable.
	String oldTraceVarName= TernaryStringByKey(ternaryDataWave, "TGDependencyVar")
	pathToDependencyVar = dfPath+oldTraceVarName
	KillVariables/Z $pathToDependencyVar
	
	// build the new dependency by remaking the data using the same name for the output wave
	String dataName= NameOfWave(ternaryDataWave)
	
	Variable error
	WAVE/Z rebuiltDataWave= MakeTernaryData(waveA, waveB, waveC, dfPath, waveZ=waveZ, error=error, dataName=dataName)

	if( GetTernaryDebug() )
		if( error != TG_Err_Success )
			Print "RewriteContourDataDependency(): MakeTernaryData() return error code: ", error
		endif
		if( !WaveRefsEqual(ternaryDataWave, rebuiltDataWave) )
			Print "RewriteContourDataDependency(): rebuilt contour data wave did not correctly overwrite old contour data wave!"
		else
			String newContourVarName= TernaryStringByKey(rebuiltDataWave, "TGCDependencyVar")
			Print "RewriteContourDataDependency(): rewrote dependency for "+GetWavesDataFolder(rebuiltDataWave,2)+" via MakeTernaryData(), with dependent variable "+newContourVarName
		endif
	endif
	return 1 // success
End

// 1.06: use only one dependency, but call ComputeXYContourData() if stale
Function UpdateTernaryXYZContourData(waveA, waveB, waveC, waveZ, ternaryDataWave)
	Wave waveA, waveB, waveC, waveZ // inputs
	Wave ternaryDataWave				// output
	
	String varName= TernaryStringByKey(ternaryDataWave, "TGCDependencyVar")
	String theDF= GetWavesDataFolder(ternaryDataWave, 1)	// theDF has trailing ":".
	// we know the dependency target variable and the output wave are in the same data folder
	Variable lastModTime = NumVarOrDefault(theDF+varName, NaN) // lastModTime will be NaN for pre-1.06 saved experiments.
	Variable waveATime = ModDate(waveA)
	Variable waveBTime = ModDate(waveB)
	Variable waveCTime = ModDate(waveC)
	Variable waveZTime = ModDate(waveZ)
	Variable outputStale = numtype(lastModTime) != 0 || (waveZTime > lastModTime) || (waveATime > lastModTime) || (waveBTime > lastModTime) || (waveCTime > lastModTime)
	if( outputStale )
		ComputeXYContourData(waveA, waveB, waveC, ternaryDataWave)
		ternaryDataWave[][2]= waveZ[p]
	endif

	if( GetTernaryDebug() )
		if( outputStale )
			String path= ksPackageDFC+"debugCount"
			Variable/G $path
			NVAR debugCount=$path
			debugCount= debugCount+1
			Print debugCount, "UpdateTernaryXYZContourData(): ternaryDataWave =", GetWavesDataFolder(ternaryDataWave,2)+" waveA = "+NameOfWave(waveA)+" waveB = "+NameOfWave(waveB)+" waveC = "+NameOfWave(waveC)+" waveZ = "+NameOfWave(waveZ)
		else
			Print "UpdateTernaryXYZContourData(): no update needed for ternaryDataWave =", GetWavesDataFolder(ternaryDataWave,2)
		endif
	endif
		
	return datetime	// compare this to ModDate(waveA), etc.
End

// version 1.06 makes either Trace or Contour data, and the output wave name is an optional parameter.
Function/WAVE MakeTernaryData(waveA, waveB, waveC, dfPath[, waveZ, error, dataName])
	Wave waveA, waveB, waveC
	String dfPath
	Wave/Z waveZ 	// optional, if specified, we're making XYZ Contour data.
	Variable &error // optional
	String dataName	// optional. If missing, a unique name will be chosen.
	
	Variable npnts = numpnts(waveA)
	if ( (numpnts(waveB) != npnts) || (numpnts(waveC) != npnts) )
		if( !ParamIsDefault(error) )
			error = TG_Err_MismatchPnts
		endif
		return $""
	endif
	if ( (WaveType(waveA) == 0) || (WaveType(waveB) == 0) || (WaveType(waveC) == 0) )
		if( !ParamIsDefault(error) )
			error = TG_Err_NoTextWave
		endif
		return $""
	endif
	
	Variable addContour= !ParamIsDefault(waveZ) && WaveExists(waveZ)
	if( addContour )
		if ( numpnts(waveZ) != npnts )
			if( !ParamIsDefault(error) )
				error = TG_Err_MismatchPnts
			endif
			return $""
		endif
		if ( WaveType(waveZ) == 0 )
			if( !ParamIsDefault(error) )
				error = TG_Err_NoTextWave
			endif
			return $""
		endif
	endif
	
	String saveDF = GetDataFolder(1)
	SetDataFolder dfPath
		String anchorName, wname
		if( addContour )
			anchorName = UniqueName("TernaryContour", 3, 0)
			wname = UniqueName("TernaryContourData", 1, 0)
		else
			anchorName = UniqueName("TernaryTrace", 3, 0)
			wname = UniqueName("TernaryTraceData", 1, 0)
		endif
		Variable/G $anchorName
		NVAR dependencyOutputVar=$anchorName
		if( !ParamIsDefault(dataName) )
			wname= dataName
		endif
		Make/O/N=(npnts, 3) $wname/WAVE=wout
	SetDataFolder saveDF
	
	wout[][2] = (waveA[p]+waveB[p]+waveC[p])				// Total (scratch)
	wout[][0] = (0.5*waveC[p] + waveB[p])/wout[p][2]	// X
	wout[][1] = waveC[p]*cos30/wout[p][2]					// Y
	if( addContour )
		wout[][2] = waveZ[p]									// Z
	endif	
	String wnote = "WaveA="+GetWavesDataFolder(waveA, 2)+"\r"
	wnote += "WaveB="+GetWavesDataFolder(waveB, 2)+"\r"
	wnote += "WaveC="+GetWavesDataFolder(waveC, 2)+"\r"
	if( addContour )
		wnote += "WaveZ="+GetWavesDataFolder(waveZ, 2)+"\r"
		wnote += "TGCDependencyVar="+anchorName+"\r"
	else
		wnote += "TGDependencyVar="+anchorName+"\r"
	endif
	Note/K wout, wnote
	
	String expression
	if( addContour )
		expression = "TernaryDiagramModule#UpdateTernaryXYZContourData(" // pre-1.06, this was UpdateTernaryContourData
	else
		expression = "TernaryDiagramModule#UpdateTernaryData("
	endif
	
	expression += GetWavesDataFolder(waveA, 2)+","
	expression += GetWavesDataFolder(waveB, 2)+","
	expression += GetWavesDataFolder(waveC, 2)+","
	if( addContour )
		expression += GetWavesDataFolder(waveZ, 2)+","
	endif
	// Because the formula is evaluated in the context of the "anchor" variable
	// the full path to the wout is not needed (because the anchor variable
	// and output wave are in the same data folder).
	expression += NameOfWave(wout)+")"
	
	dependencyOutputVar= dateTime // avoid unnecessary updates by noting the last time the output wave was updated.
	SetFormula dependencyOutputVar, expression

	if( !ParamIsDefault(error) )
		error = TG_Err_Success
	endif
	
	return wout
End

Function/WAVE TernaryWaveByKey(ternaryDataWithNote, key)
	WAVE ternaryDataWithNote // TernaryContourData or TernaryTraceData
	String key					// usually "WaveA", "WaveB", "WaveC", etc
	
	String theNote= note(ternaryDataWithNote)
	String pathToWave= StringByKey(key, theNote, "=", "\r")
	WAVE/Z w = $pathToWave
	return w
End

Function/S TernaryStringByKey(ternaryDataWithNote, key)
	WAVE ternaryDataWithNote // TernaryContourData or TernaryTraceData
	String key					// usually "TGDependencyVar" or "TGCDependencyVar"

	String theNote= note(ternaryDataWithNote)
	String dependencyName = StringByKey(key, theNote, "=", "\r")
	return dependencyName // usually name of global variable
End

Function ComputeXYContourData(waveA, waveB, waveC, ternaryDataWave)
	Wave waveA, waveB, waveC, ternaryDataWave
	
	if (numpnts(waveA) != DimSize(ternaryDataWave, 0))
		Print "Redimensioning "+NameOfWave(ternaryDataWave)	
		Redimension/N=(numpnts(waveA), -1) ternaryDataWave
	endif
	
	ternaryDataWave[][2] = (waveA[p]+waveB[p]+waveC[p])
	ternaryDataWave[][0] = (0.5*waveC[p] + waveB[p])/ternaryDataWave[p][2]
	ternaryDataWave[][1] = waveC[p]*cos30/ternaryDataWave[p][2]
End

// For old (pre-1.06) and new (1.06) experiments.
// However, as of 1.06 it returns the timestamp (in seconds) when the update last occured.
// This is used to skip updating if the modification date/time of waveA, waveB, and waveC
// are the same or older.
Function UpdateTernaryData(waveA, waveB, waveC, ternaryDataWave)
	Wave waveA, waveB, waveC, ternaryDataWave
	
	String varName= TernaryStringByKey(ternaryDataWave, "TGDependencyVar")
	String theDF= GetWavesDataFolder(ternaryDataWave, 1) // theDF has trailing ":". l
	// we know the var and the output wave are in the same data folder
	Variable lastModTime= NumVarOrDefault(theDF+varName, NaN) // lastModTime will be NaN for pre-1.06 saved experiments.
	Variable waveATime = ModDate(waveA)
	Variable waveBTime = ModDate(waveB)
	Variable waveCTime = ModDate(waveC)
	Variable outputStale = numtype(lastModTime) != 0 || (waveATime > lastModTime) || (waveBTime > lastModTime) || (waveCTime > lastModTime)
	if( outputStale )
		ComputeXYContourData(waveA, waveB, waveC, ternaryDataWave)
	endif
	
	if( GetTernaryDebug() )
		if( outputStale )
			String path= ksPackageDFC+"debugCount"
			Variable/G $path
			NVAR debugCount=$path
			debugCount= debugCount+1
			Print debugCount, "UpdateTernaryData(): ternaryDataWave =", GetWavesDataFolder(ternaryDataWave,2)+" waveA = "+NameOfWave(waveA)+" waveB = "+NameOfWave(waveB)+" waveC = "+NameOfWave(waveC)
		else
			Print "UpdateTernaryData(): no update needed for ternaryDataWave =", GetWavesDataFolder(ternaryDataWave,2)
		endif
	endif
	
	return datetime	// compare this to ModDate(waveA), etc.
End

// returns 2 if a contour was removed, 1 if a trace was removed, 0 if neither removed.
// As of 1.06 will not remove a non-Ternary trace or contour
Function RemoveTernaryTraceOrContour(gname, TraceOrContourName)
	String gname
	String TraceOrContourName
	
	Variable removed= 0
	Variable isContour = 0
	WAVE/Z w = TraceNameToWaveRef(gname, TraceOrContourName)
	if (!WaveExists(w))
		WAVE/Z w = ContourNameToWaveRef(gname, TraceOrContourName) // triplet matrix for pre-1.06, z wave (belongs to user) for 1.06 or later.
		isContour = WaveExists(w)
		if( isContour )
			isContour= WaveIsTernaryContour(gname,w)
		else
			WAVE/Z w=$""
		endif
	elseif( !WaveIsTernaryTrace(gname,w) )
			WAVE/Z w=$""
	endif
	if (WaveExists(w))
		// ---- REMOVE TRACE or CONTOUR ----
		if (isContour)
			RemoveContour/W=$gname $TraceOrContourName
			removed= 2
		else
			RemoveFromGraph/W=$gname $TraceOrContourName
			removed= 1
		endif
		// ---- REMOVE DEPENDENCIES AND DERIVED DATA ----
		String theDF = TernaryGraphDFPath(gname) // from graph userData, has trailing ":", should be same as w's data folder
		RemoveTernaryDataFromDF(theDF, w)
	else
		Beep // should not happen
	endif
	return removed
end

Function RemoveTernaryDataFromDF(theDF, ternaryData)
	String theDF			// has trailing ":", should be same as ternaryData's data folder
	Wave/Z ternaryData // contour or trace: this data will be killed!
	
	Variable killed=0
	if (WaveExists(ternaryData))
		// ---- REMOVE DEPENDENCIES by killing the anchor/target global Variables ----
		// Remove trace dependency Variable
		String dependencyName= TernaryStringByKey(ternaryData, "TGDependencyVar")
		if( strlen(dependencyName) ) // 1.06: contour data no longer uses this trace-specific variable
			NVAR/Z dependencyV = $(theDF+dependencyName)
			if (NVAR_Exists(dependencyV))
				KillVariables dependencyV
			endif
		endif
		// Remove contour dependency Variable
		dependencyName= TernaryStringByKey(ternaryData, "TGCDependencyVar")
		NVAR/Z dependencyV = $(theDF+dependencyName)
		if (NVAR_Exists(dependencyV))
			KillVariables dependencyV
		endif
		// ---- KILL DERIVED DATA ----
		KillWaves/Z ternaryData
		killed= WaveExists(ternaryData)
	endif
	return killed
End

Function RememberGraphNameInDF(gname)
	String gname

	String theDF = TernaryGraphDFPath(gname)
	if( strlen(theDF) && DataFolderExists(theDF) )
		String saveDF = GetDataFolder(1)
		SetDataFolder theDF
			String/G graphName= gname
		SetDataFolder saveDF
	endif
End

Function IsTernaryGraph(gname)
	String gname

	String df= TernaryGraphDFPath(gname)
	Variable isTG = strlen(df) >= 0
	return isTG
End

// returns truth that any window is using any wave in the data folder
Function SomeWindowIsUsingDataFolder(theDF)
	String theDF

	Variable inUse = 0
	DFREF dfr= $theDF
	Variable dfrStatus= DataFolderRefStatus(dfr)
	if( dfrStatus == 1 )
		Variable index=0
		do
			WAVE/Z w = WaveRefIndexedDFR(dfr, index)
			if (!WaveExists(w))
				break
			endif
			CheckDisplayed/A w
			inUse= V_Flag != 0
			index += 1
		while(!inUse)
	endif

	return inUse
End

Function RemoveTernaryGraphDataFolder(theDF)
	String theDF
	
	Variable removed= 0
	if( strlen(theDF) && DataFolderExists(theDF) )
		String saveDF = GetDataFolder(1)
		SetDataFolder theDF
			KillStrings/A/Z
			KillVariables/A/Z
		SetDataFolder saveDF
		KillDataFolder theDF
		removed= 1
	endif
	return removed
End

Function/S TernaryDataFolderInMacro(mName)
	String mName
	
	String entireDataFolder=""
	String code= ProcedureText("ProcGlobal#"+mName)
	Variable pos= strsearch(code, "SetDataFolder "+ksPackageDFC, 0)
	if( pos >= 0 )
		Variable lineEnd = strsearch(code, "\r", pos)
		pos += strlen("SetDataFolder ")
		entireDataFolder= code[pos,lineEnd-1]
	else
		pos= strsearch(code, "="+ksPackageDFC,0) // Gizmo Scatter: AppendToGizmo Scatter=root:Packages:WM_TernaryDiagrams:TernaryGraph:TernaryContourData0,name=scatter0
		if( pos >= 0 )
			pos += 1 // skip =
			Variable pathEnd = strsearch(code, ",", pos) // could be a , on the next line, probably not, though.
			lineEnd = strsearch(code, "\r", pos)
			String pathToWave=""
			if( pathEnd > pos && pathEnd < lineEnd )
				pathToWave= code[pos,pathEnd-1]
				WAVE/Z w= $pathToWave
				if( WaveExists(w) )
					entireDataFolder= RemoveEnding(GetWavesDataFolder(w,1)) // remove the ending :
				endif
			endif	
		endif
	endif
	return entireDataFolder
End

// List data folder (names) that recreation macros refer to, as in "SetDataFolder root:Packages:WM_TernaryDiagrams:<something>:"
Function/S ListTernaryDataFoldersInMacros()

	String dfList=""
	String mList= MacroList("*",";", "KIND:4,SUBTYPE:Graph") // MacroList returns only Macros in ProcGlobal
	mList += MacroList("*",";", "KIND:4,SUBTYPE:Table")
	mList += MacroList("*",";", "KIND:4,SUBTYPE:GizmoPlot")
	Variable i, n= ItemsInList(mList)
	for(i=0; i<n; i+=1)
		String mName= StringFromList(i,mList)
		String theDF = TernaryDataFolderInMacro(mName)
		if( strlen(theDF) )
			String dfName= ParseFilePath(0,theDF,":",1,0) // first element at end (that is, the leaf name).
			dfList += dfName+";"
		endif
	endfor
	return dfList
End

Function ExplainRemoveUnusedData(dfsToBeDeleted)
	String dfsToBeDeleted

	Variable doDelete = 0
	Variable i, n= ItemsInList(dfsToBeDeleted)
	String promptStr=""

	if( n )
		promptStr="Remove "+num2istr(n)+" unused data subfolders in root:Packages:WM_TernaryDiagrams?"
		promptStr += "\r\r(Removing unused data saves memory, file space, and can improve the responsiveness of Igor.)"
		dfsToBeDeleted= replaceString(";",RemoveEnding(dfsToBeDeleted,";"),", ")
		promptStr += "\r\rUnused data folders: "+dfsToBeDeleted+"."
		DoAlert/T="Remove Unused Ternary Diagram Data" 1, promptStr
		doDelete= V_Flag == 1 // true if "Yes" clicked.
	else
		DoAlert/T="Remove Unused Ternary Diagram Data" 0, "No data to remove; it is all needed to support open or saved windows."
	endif

	return doDelete
End

Function/S DataFoldersToBeDeleted()
	// Method:
	//		For each data folder in root:Packages:TernaryGraph
	//		See if an existing Ternary Diagram window or saved creation macro
	//		refers to that data folder.
	//		If not, see if an open window displays any data in data folder.
	String dfsToBeKept= ListTernaryDataFoldersInMacros() // list of df names, not paths
	String df, theDF, gname
	String dfsToBeDeleted="" // string list of object names
	
	// iterate over the data folders in the root:Packages:TernaryGraph data folder 
	Variable index= 0
	do
		df = GetIndexedObjName(ksPackageDF, 4, index)
		if (strlen(df) == 0)
			break
		endif
		// see if the df is needed
		Variable keepDF= WhichListItem(df,dfsToBeKept) >= 0
		if( !keepDF )
			// no recreation macro references the data folder,
			// perhaps an existing Ternary Graph doesn't (yet) have a recreation macro
			theDF = ksPackageDFC+df
			keepDF= SomeWindowIsUsingDataFolder(theDF)
		endif
		if( keepDF == 0 )
			dfsToBeDeleted += df+";" // df not deleted right now because we don't want to confuse the loop indexing through data folders.
		endif
		index += 1
	while(1)

	return dfsToBeDeleted
End

// Removes Ternary dependencies and data folders that serve no purpose.
// "No purpose" means no open Ternary Diagrams currently *use* the data
// and no saved recreation macros *reference* the data.
Function mRemoveUnusedTernaryData()

	MakeTernaryDataFolder()

	String dfsToBeDeleted = DataFoldersToBeDeleted() // string list of data folder names
	Variable doDelete = ExplainRemoveUnusedData(dfsToBeDeleted)
	if( !doDelete )
		return 0
	endif

	Variable index, n = ItemsInList(dfsToBeDeleted)
	for(index=0; index<n; index+=1)
		String df = StringFromList(index,dfsToBeDeleted)
		String theDF = ksPackageDFC+df
		RemoveTernaryGraphDataFolder(theDF)
	endfor
	
	if( n )
		DoAlert 0, "Removed "+num2istr(n)+" data folder(s)."
	endif
	return n
End

Structure TernaryGraphAxisProperties
	Variable lineThick
	STRUCT RGBColor lineRGB
endStructure

Structure TernaryGraphAxes
	STRUCT TernaryGraphAxisProperties axisAB
	STRUCT TernaryGraphAxisProperties axisBC
	STRUCT TernaryGraphAxisProperties axisCA
endStructure

static constant cos30 = 0.866025403784439
static constant tan60 = 1.73205080756888

Function DrawDefaultTernaryAxes(gname)
	String gname
	
	SetDrawLayer/W=$gname ProgAxes
	DrawAction/W=$gname/L=ProgAxes getgroup=TernaryAxisGroup
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif
	
	STRUCT TernaryGraphAxes defaultAxes
	initializeDefaultTernaryAxis(defaultAxes.axisAB)
	initializeDefaultTernaryAxis(defaultAxes.axisBC)
	initializeDefaultTernaryAxis(defaultAxes.axisCA)
	
	DrawTernaryAxes(gname, defaultAxes.axisAB.lineThick, defaultAxes.axisAB.lineRGB.red, defaultAxes.axisAB.lineRGB.green, defaultAxes.axisAB.lineRGB.blue)
end

Function DrawTernaryAxes(gname, thickness, red, green, blue)
	String gname
	Variable thickness
	Variable red, green, blue
	
	SetDrawLayer/W=$gname ProgAxes
	DrawAction/W=$gname/L=ProgAxes getgroup=TernaryAxisGroup
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif
	
	STRUCT TernaryGraphAxes axisProps
	axisProps.axisAB.lineThick = thickness
	axisProps.axisBC.lineThick = thickness
	axisProps.axisCA.lineThick = thickness
	axisProps.axisAB.lineRGB.red = red
	axisProps.axisAB.lineRGB.green = green
	axisProps.axisAB.lineRGB.blue = blue
	axisProps.axisBC.lineRGB.red = red
	axisProps.axisBC.lineRGB.green = green
	axisProps.axisBC.lineRGB.blue = blue
	axisProps.axisCA.lineRGB.red = red
	axisProps.axisCA.lineRGB.green = green
	axisProps.axisCA.lineRGB.blue = blue

	SetDrawLayer/W=$gname ProgAxes
	SetDrawEnv/W=$gname push
	SetDrawEnv/W=$gname gstart, gname = TernaryAxisGroup
	SetDrawEnv/W=$gname xcoord=$TG_HorizAxis,ycoord=$TG_VertAxis,save
	SetDrawEnv/W=$gname linefgc=(axisProps.axisAB.lineRGB.red,axisProps.axisAB.lineRGB.green,axisProps.axisAB.lineRGB.blue), lineThick=axisProps.axisAB.lineThick
	DrawLine/W=$gname 0,0,1,0
	SetDrawEnv/W=$gname linefgc=(axisProps.axisBC.lineRGB.red,axisProps.axisBC.lineRGB.green,axisProps.axisBC.lineRGB.blue), lineThick=axisProps.axisBC.lineThick
	DrawLine/W=$gname 1,0,.5,cos30
	SetDrawEnv/W=$gname linefgc=(axisProps.axisCA.lineRGB.red,axisProps.axisCA.lineRGB.green,axisProps.axisCA.lineRGB.blue), lineThick=axisProps.axisCA.lineThick
	DrawLine/W=$gname 0,0,.5,cos30
	SetDrawEnv/W=$gname gstop
	SetDrawEnv/W=$gname pop
	
	String GraphAxisStruct
	StructPut/S axisProps, GraphAxisStruct
	SetWindow $gname, UserData(TernaryGraphAxisStruct)=GraphAxisStruct
end


Function GetTernaryAxisStructFromGraph(gname, s)
	String gname
	STRUCT TernaryGraphAxes &s
	
	Variable returnValue = 0		// success
	
	String AxisStructStr = GetUserData(gname, "", "TernaryGraphAxisStruct")
	if (strlen(AxisStructStr) > 0)
		StructGet/S s, AxisStructStr
	else
		returnValue = 1
	endif
	
	return returnValue
end

Structure TernaryGraphGridProperties
	Variable delta
	STRUCT RGBColor gridColor
	Variable gridThick
	Variable gridDash
endStructure

Function GetTernaryGridStructFromGraph(gname, s)
	String gname
	STRUCT TernaryGraphGridProperties &s
	
	Variable returnValue = 0		// success
	
	String GridStructStr = GetUserData(gname, "", "TernaryGraphGridStruct")
	if (strlen(GridStructStr) > 0)
		StructGet/S s, GridStructStr
	else
		returnValue = 1
	endif
	
	return returnValue
end

Function RemoveTernaryGraphGrid(gname)
	String gname
	
	SetDrawLayer/W=$gname ProgAxes
	DrawAction/W=$gname/L=ProgAxes getgroup=TernaryGridGroup
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif
	SetWindow $gname, UserData(TernaryGraphGridStruct)=""
end

Function DrawTernaryGraphGrid(gname, increment, gridRed, gridGreen, gridBlue, gridThick, gridDash)
	String gname
	Variable increment
	Variable gridRed, gridGreen, gridBlue
	Variable gridThick
	Variable gridDash
	
	SetDrawLayer/W=$gname ProgAxes
	DrawAction/W=$gname/L=ProgAxes getgroup=TernaryGridGroup
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif

	if (increment == 0)
		return 0
	endif
	
	STRUCT TernaryGraphGridProperties gridProp
	gridProp.delta = Increment
	gridProp.gridColor.red = gridRed
	gridProp.gridColor.green = gridGreen
	gridProp.gridColor.blue = gridBlue
	gridProp.gridThick = gridThick
	gridProp.gridDash = gridDash
	
	Variable i
	Variable nLines = round(1/increment)
	Variable xstart
	Variable xend
	Variable ystart
	Variable yend
	
	SetDrawLayer/W=$gname ProgAxes
	SetDrawEnv/W=$gname push
	SetDrawEnv/W=$gname gstart, gname = TernaryGridGroup
	SetDrawEnv/W=$gname xcoord=$TG_HorizAxis,ycoord=$TG_VertAxis,save
	SetDrawEnv/W=$gname linefgc=(gridProp.gridColor.red,gridProp.gridColor.green,gridProp.gridColor.blue), lineThick=gridProp.gridThick, dash = gridProp.gridDash, save
	for(i = 1; i < nLines; i += 1)
		ystart = i*increment*cos30
		xstart = i*increment/2
		xend = 1-xstart
		DrawLine/W=$gname xstart,ystart,xend,ystart
	endfor
	for(i = 1; i < nLines; i += 1)
		ystart = 0
		yend = (nLines-i)*increment*cos30
		xstart = i*increment
		xend = 0.5*(xstart+1)
		DrawLine/W=$gname xstart,ystart,xend,yend
	endfor
	for(i = 1; i < nLines; i += 1)
		ystart = 0
		yend = (nLines-i)*increment*cos30
		xstart = (nLines-i)*increment
		xend = 0.5*xstart
		DrawLine/W=$gname xstart,ystart,xend,yend
	endfor
	SetDrawEnv/W=$gname gstop
	SetDrawEnv/W=$gname pop
	
	String GraphGridStruct
	StructPut/S gridProp, GraphGridStruct
	SetWindow $gname, UserData(TernaryGraphGridStruct)=GraphGridStruct
end

Structure TernaryGraphTickProperties
	Variable delta
	STRUCT RGBColor tickColor
	Variable tickThick
	Variable tickLength
	Variable ticksInside
	Variable tickIncrement				// .05, .1, .2, .25, .5
endStructure

Function GetTernaryGraphTickStructure(gname, s)
	String gname
	STRUCT TernaryGraphTickProperties &s
	
	Variable returnValue = 0		// success
	
	String TickStructStr = GetUserData(gname, "", "TernaryGraphTickStruct")
	if (strlen(TickStructStr) > 0)
		StructGet/S s, TickStructStr
	else
		returnValue = 1
	endif
	
	return returnValue
end

Function RemoveTernaryGraphTicks(gname)
	String gname
	
	SetDrawLayer/W=$gname ProgAxes
	DrawAction/W=$gname/L=ProgAxes getgroup=TernaryTickGroup
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif
	SetWindow $gname, UserData(TernaryGraphTickStruct)=""
end

Function DrawTernaryGraphTicks(gname, increment, tickRed, tickGreen, tickBlue, tickThick, tickLength, ticksInside)
	String gname
	Variable increment
	Variable tickRed, tickGreen, tickBlue
	Variable tickThick
	Variable tickLength
	Variable ticksInside
	
	SetDrawLayer/W=$gname ProgAxes
	DrawAction/W=$gname/L=ProgAxes getgroup=TernaryTickGroup
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif

	if (increment == 0)
		SetWindow $gname, UserData(TernaryGraphTickStruct)=""
		return 0
	endif
	
	STRUCT TernaryGraphTickProperties tickProp
	tickProp.delta = Increment
	tickProp.tickColor.red = tickRed
	tickProp.tickColor.green = tickGreen
	tickProp.tickColor.blue = tickBlue
	tickProp.tickThick = tickThick
	tickProp.tickLength = tickLength
	tickProp.ticksInside = ticksInside
	tickProp.tickIncrement = increment
	
	Variable i
	Variable nTicks = round(1/increment)
	Variable xstart
	Variable xend
	Variable delta
	Variable ystart
	Variable yend
	
	SetDrawLayer/W=$gname ProgAxes
	SetDrawEnv/W=$gname push //+++++++++++++++
	SetDrawEnv/W=$gname gstart, gname = TernaryTickGroup
	SetDrawEnv/W=$gname xcoord=$TG_HorizAxis,ycoord=$TG_VertAxis,save
	SetDrawEnv/W=$gname linefgc=(tickProp.tickColor.red,tickProp.tickColor.green,tickProp.tickColor.blue), lineThick=tickProp.tickThick, save

	SetDrawEnv/W=$gname push //+++++++++++++++
	// ticks for horizontal axis
	for(i = 1; i < nTicks; i += 1)
		SetDrawEnv/W=$gname origin=Increment, 0, save
		SetDrawEnv/W=$gname push //+++++++++++++++
		SetDrawEnv/W=$gname xcoord=abs,ycoord=abs,save
		if (tickProp.ticksInside)
			yend = -tickProp.tickLength*cos30
		else
			yend = tickProp.tickLength*cos30
		endif
		delta = tickProp.tickLength*0.5
		xend = -delta
		DrawLine/W=$gname 0,0,xend,yend
		xend = delta
		DrawLine/W=$gname 0,0,xend,yend
		SetDrawEnv/W=$gname pop //-------------------
	endfor
	SetDrawEnv/W=$gname pop //-------------------

	// ticks for left side
	SetDrawEnv/W=$gname push //+++++++++++++++
	for(i = 1; i < nTicks; i += 1)
		SetDrawEnv/W=$gname origin=Increment/2, Increment*cos30, save
		SetDrawEnv/W=$gname push //+++++++++++++++
		SetDrawEnv/W=$gname xcoord=abs,ycoord=abs,save
		delta = -tickProp.tickLength
		if (tickProp.ticksInside)
			delta = -delta
		endif
		DrawLine/W=$gname 0,0,delta,0
		yend = delta*cos30
		xend = delta*0.5
		DrawLine/W=$gname 0,0,xend,yend
		SetDrawEnv/W=$gname pop //-------------------
	endfor
	SetDrawEnv/W=$gname pop //-------------------

	// ticks for right side
	SetDrawEnv/W=$gname push //+++++++++++++++
	SetDrawEnv/W=$gname origin=1, 0,save
	for(i = 1; i < nTicks; i += 1)
		SetDrawEnv/W=$gname origin=-Increment/2, Increment*cos30, save
		SetDrawEnv/W=$gname push //+++++++++++++++
		SetDrawEnv/W=$gname xcoord=abs,ycoord=abs,save
		delta = tickProp.tickLength
		if (tickProp.ticksInside)
			delta = -delta
		endif
		DrawLine/W=$gname 0,0,delta,0
		yend = -delta*cos30
		xend = delta*0.5
		DrawLine/W=$gname 0,0,xend,yend
		SetDrawEnv/W=$gname pop //-------------------
	endfor
	SetDrawEnv/W=$gname pop //-------------------

	SetDrawEnv/W=$gname gstop
	
	SetDrawEnv/W=$gname pop //-------------------

	String GraphTickStruct
	StructPut/S tickProp, GraphTickStruct
	SetWindow $gname, UserData(TernaryGraphTickStruct)=GraphTickStruct
end

Structure TernaryGraphTickLabelProperties
	Variable delta
	STRUCT RGBColor labelColor
	char font[100]
	Variable fontSize
	Variable fontStyle
	Variable labelOffset
	Variable labelIncrement
endStructure

Structure TernaryGraphTickLabelPropertiesEx
	Variable version
	Variable tickmultiplier
	char tickunits[100]
	char tickformat[100]
endStructure

static Function TernaryGraphTickLabelPropsDefaultsEx(STRUCT TernaryGraphTickLabelPropertiesEx & s)
	s.version = 1
	s.tickmultiplier = 1.0
	s.tickunits = "%"
	s.tickformat = "%d"
end

Function/S GetTernaryTickLabelGroupName(gname, which, doEx)
	String gname, which
	Variable doEx
	
	String groupName = ""
	StrSwitch (which)
		case "Bottom":
			groupName = "TernaryTickLabelBGroup"
			break;
		case "Left":
			groupName = "TernaryTickLabelLGroup"
			break;
		case "Right":
			groupName = "TernaryTickLabelRGroup"
			break;
	endswitch
	
	if (doEx)
		groupName += "Ex"
	endif
	
	return groupName
end

Function GetTernaryTickLabelStructure(gname, s, s_ex, which)
	String gname
	STRUCT TernaryGraphTickLabelProperties &s
	STRUCT TernaryGraphTickLabelPropertiesEx &s_ex
	String which
	
	Variable returnValue = 0		// success
	
	String groupName = GetTernaryTickLabelGroupName(gname, which, 0)
	String TickStructStr = GetUserData(gname, "", groupName)
	if (strlen(TickStructStr) > 0)
		StructGet/S s, TickStructStr
	else
		returnValue = 1
	endif
	
	groupName = GetTernaryTickLabelGroupName(gname, which, 1)
	TickStructStr = GetUserData(gname, "", groupName)
	if (strlen(TickStructStr) > 0)
		StructGet/S s_ex, TickStructStr
	else
		TernaryGraphTickLabelPropsDefaultsEx(s_ex)
	endif
	
	return returnValue
end

Function RemoveTernaryTickLabels(gname, which)
	String gname
	String which
	
	SetDrawLayer/W=$gname ProgAxes
	String groupName = GetTernaryTickLabelGroupName(gname, which, 0)

	DrawAction/W=$gname/L=ProgAxes getgroup=$groupName
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif
	SetWindow $gname, UserData($groupName)=""
end	

Function RemoveAllTernaryTickLabels(gname)
	String gname
	
	RemoveTernaryTickLabels(gname, "Left")
	RemoveTernaryTickLabels(gname, "Right")
	RemoveTernaryTickLabels(gname, "Bottom")
end

Function DrawTernaryGraphTickLabels(gname, delta, red, green, blue, font, fontsize, fontstyle, labelOffset, which[, multiplier, unitslabel, tickformat])
	String gname
	Variable delta
	Variable red, green, blue
	String font
	Variable fontsize, fontstyle, labelOffset
	String which			// "Bottom", "Left" or "Right"
	Variable multiplier
	String unitslabel
	String tickformat
	
	if (ParamIsDefault(multiplier))
		multiplier = 1
	endif
	if (ParamIsDefault(unitslabel))
		unitslabel = "%"
	endif
	if (Cmpstr(unitslabel, "%") == 0)
		unitslabel = "%%"
	endif
	if (ParamIsDefault(tickformat))
		tickformat = "%d"
	endif
	
	SetDrawLayer/W=$gname ProgAxes
	String groupName = GetTernaryTickLabelGroupName(gname, which, 0)
	
	DrawAction/W=$gname/L=ProgAxes getgroup=$groupName
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif

	if (delta == 0)
		return 0
	endif
	
	STRUCT TernaryGraphTickLabelProperties labelProp
	labelProp.delta = delta
	labelProp.labelColor.red = red
	labelProp.labelColor.green = green
	labelProp.labelColor.blue = blue
	labelProp.font = font
	labelProp.fontSize = fontsize
	labelProp.fontStyle = fontstyle
	labelProp.labelOffset = labelOffset
	labelProp.labelIncrement = delta
	
	STRUCT TernaryGraphTickLabelPropertiesEx labelPropEx
	labelPropEx.version = 1
	labelPropEx.tickmultiplier = multiplier
	labelPropEx.tickunits = unitslabel
	labelPropEx.tickformat = tickformat

	
	Variable i
	Variable nTicks = round(1/delta)
	Variable xstart
	Variable ystart
	String labelText
	
	SetDrawLayer/W=$gname ProgAxes
	SetDrawEnv/W=$gname push
	SetDrawEnv/W=$gname gstart, gname = $groupName
	SetDrawEnv/W=$gname textrgb=(labelProp.labelColor.red,labelProp.labelColor.green,labelProp.labelColor.blue), fsize=labelProp.fontSize, fstyle=labelProp.fontStyle, save
	SetDrawEnv/W=$gname xcoord=$TG_HorizAxis,ycoord=$TG_VertAxis,save
	
	string format
	strswitch (which)
		case "Bottom":
			SetDrawEnv/W=$gname origin=-delta, 0
			for(i = 0; i <= nTicks; i += 1)
				SetDrawEnv/W=$gname origin=delta, 0,save
				SetDrawEnv/W=$gname push,save
				SetDrawEnv/W=$gname xcoord=abs, ycoord=abs,save
				if (strlen(labelProp.font))
					format = "\\F'%s'"+tickformat
					if (i == nTicks)
						format += unitslabel
					endif
					sprintf labelText, format, labelProp.font, i*delta*100*multiplier
					MeasureStyledText/F=labelProp.font/SIZE=(labelProp.fontSize)/STYL=(labelProp.fontStyle) labelText
				else
					format = tickformat
					if (i == nTicks)
						format += unitslabel
					endif
					sprintf labelText, format, i*delta*100*multiplier
					MeasureStyledText/SIZE=(labelProp.fontSize)/STYL=(labelProp.fontStyle) labelText
				endif
				xstart = -(V_height/2/tan60 + labelProp.labelOffset/cos30)
				ystart = 0
				SetDrawEnv/W=$gname rotate=-60
				SetDrawEnv/W=$gname textxjust=2,textyjust=1
				DrawText/W=$gname xstart, ystart, labelText
				SetDrawEnv/W=$gname pop,save
			endfor
			break;
		case "Left":
			SetDrawEnv/W=$gname push
			for(i = 1; i <= nTicks; i += 1)
				SetDrawEnv/W=$gname origin=delta/2, delta*cos30
				SetDrawEnv/W=$gname push
				SetDrawEnv/W=$gname xcoord=abs, ycoord=abs
				if (strlen(labelProp.font))
					sprintf labelText, "\\F'%s'"+tickformat, labelProp.font, (nTicks-i)*delta*100*multiplier
					MeasureStyledText/F=labelProp.font/SIZE=(labelProp.fontSize)/STYL=(labelProp.fontStyle) labelText
				else
					sprintf labelText, tickformat, (nTicks-i)*(delta)*100*multiplier
					MeasureStyledText/SIZE=(labelProp.fontSize)/STYL=(labelProp.fontStyle) labelText
				endif
				xstart = -V_width-labelProp.labelOffset
				ystart = V_height/2
				SetDrawEnv/W=$gname rotate=60,rsabout
				DrawText/W=$gname xstart, ystart, labelText
				SetDrawEnv/W=$gname pop
			endfor
			SetDrawEnv/W=$gname pop
			SetDrawEnv/W=$gname origin=0,0
			SetDrawEnv/W=$gname push
			SetDrawEnv/W=$gname xcoord=abs, ycoord=abs
			if (strlen(labelProp.font))
				format = "\\F'%s'" + tickformat + unitslabel
				sprintf labelText, format, labelProp.font, 100*multiplier
				MeasureStyledText/F=labelProp.font/SIZE=(labelProp.fontSize)/STYL=(labelProp.fontStyle) labelText
			else
				format = tickformat + unitslabel
				sprintf labelText, format, 100*multiplier
				MeasureStyledText/SIZE=(labelProp.fontSize)/STYL=(labelProp.fontStyle) labelText
			endif
			xstart = -V_width-labelProp.labelOffset
			ystart = V_height/2
			SetDrawEnv/W=$gname rotate=60,rsabout
			DrawText/W=$gname xstart, ystart, labelText
			SetDrawEnv/W=$gname pop
			break;
		case "Right":
			SetDrawEnv/W=$gname origin=1+delta/2, -delta*cos30
			for(i = 0; i < nTicks; i += 1)
				SetDrawEnv/W=$gname origin=-delta/2, delta*cos30
				SetDrawEnv/W=$gname push
				SetDrawEnv/W=$gname xcoord=abs, ycoord=abs
				if (strlen(labelProp.font))
					format = "\\F'%s'"+tickformat
					sprintf labelText, format, labelProp.font, i*delta*100*multiplier
					MeasureStyledText/F=labelProp.font/SIZE=(labelProp.fontSize)/STYL=(labelProp.fontStyle) labelText
				else
					sprintf labelText, tickformat, i*(delta)*100*multiplier
					MeasureStyledText/SIZE=(labelProp.fontSize)/STYL=(labelProp.fontStyle) labelText
				endif
				xstart = labelProp.labelOffset
				ystart = V_height/2
				DrawText/W=$gname xstart, ystart, labelText
				SetDrawEnv/W=$gname pop
			endfor
			SetDrawEnv/W=$gname origin=-delta/2, delta*cos30
			SetDrawEnv/W=$gname push
			SetDrawEnv/W=$gname xcoord=abs, ycoord=abs
			if (strlen(labelProp.font))
				format = "\\F'%s'" + tickformat + unitslabel
				sprintf labelText, format, labelProp.font, 100*multiplier
				MeasureStyledText/F=labelProp.font/SIZE=(labelProp.fontSize)/STYL=(labelProp.fontStyle) labelText
			else
				format = tickformat + unitslabel
				sprintf labelText, format, 100*multiplier
				MeasureStyledText/SIZE=(labelProp.fontSize)/STYL=(labelProp.fontStyle) labelText
			endif
			xstart = labelProp.labelOffset
			ystart = V_height/2
			DrawText/W=$gname xstart, ystart, labelText
			SetDrawEnv/W=$gname pop
			break;
	endswitch
	
	SetDrawEnv/W=$gname gstop
	SetDrawEnv/W=$gname pop
		
	String GraphTickLabelStruct
	StructPut/S labelProp, GraphTickLabelStruct
	SetWindow $gname, UserData($groupName)=GraphTickLabelStruct
	
	groupName = GetTernaryTickLabelGroupName(gname, which, 1)
	StructPut/S labelPropEx, GraphTickLabelStruct
	SetWindow $gname, UserData($groupName)=GraphTickLabelStruct
end

Structure TernaryGraphAxisLabelProperties
	char text[400]
	STRUCT RGBColor labelColor
	char font[100]
	Variable fontSize
	Variable fontStyle
	Variable labelOffset
	Variable labelLatOffset
endStructure

Function/S GetTernaryAxisLabelGroup(gname, which)
	String gname, which
	
	String groupName = ""
	StrSwitch (which)
		case "Bottom":
			groupName = "TernaryAxisLabelBGroup"
			break;
		case "Left":
			groupName = "TernaryAxisLabelLGroup"
			break;
		case "Right":
			groupName = "TernaryAxisLabelRGroup"
			break;
	endswitch
	
	return groupName
end

Function GetTernaryAxisLabelStructure(gname, s, which)
	String gname
	STRUCT TernaryGraphAxisLabelProperties &s
	String which
	
	Variable returnValue = 0		// success
	
	String groupName = GetTernaryAxisLabelGroup(gname, which)
	String AxisLabelStructStr = GetUserData(gname, "", groupName)
	if (strlen(AxisLabelStructStr) > 0)
		StructGet/S s, AxisLabelStructStr
	else
		returnValue = 1
	endif
	
	return returnValue
end

Function RemoveTernaryGraphAxisLabel(gname, which)
	String gname, which
	
	SetDrawLayer/W=$gname ProgAxes
	String groupName = GetTernaryAxisLabelGroup(gname, which)
	
	DrawAction/W=$gname/L=ProgAxes getgroup=$groupName
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif
	SetWindow $gname, UserData($groupName)=""
end

Function RemoveAllTernaryAxisLabels(gname)
	String gname
	
	RemoveTernaryGraphAxisLabel(gname, "Left")
	RemoveTernaryGraphAxisLabel(gname, "Right")
	RemoveTernaryGraphAxisLabel(gname, "Bottom")
end

Function DrawTernaryGraphAxisLabels(gname, labelText, red, green, blue, font, fontsize, fontstyle, labelOffset, labelLatOffset, which)
	String gname
	String labelText
	Variable red, green, blue
	String font
	Variable fontsize, fontstyle, labelOffset, labelLatOffset
	String which			// "Bottom", "Left" or "Right"
	
	SetDrawLayer/W=$gname ProgAxes
	String groupName = GetTernaryAxisLabelGroup(gname, which)
	
	DrawAction/W=$gname/L=ProgAxes getgroup=$groupName
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif

	STRUCT TernaryGraphAxisLabelProperties labelProp
	labelProp.text = labelText
	labelProp.labelColor.red = red
	labelProp.labelColor.green = green
	labelProp.labelColor.blue = blue
	labelProp.font = font
	labelProp.fontSize = fontsize
	labelProp.fontStyle = fontstyle
	labelProp.labelOffset = labelOffset
	labelProp.labelLatOffset = labelLatOffset
	
	Variable i
	Variable xstart
	Variable ystart
	
	SetDrawLayer/W=$gname ProgAxes
	SetDrawEnv/W=$gname push
	SetDrawEnv/W=$gname gstart, gname = $groupName
	SetDrawEnv/W=$gname textrgb=(labelProp.labelColor.red,labelProp.labelColor.green,labelProp.labelColor.blue), fsize=labelProp.fontSize, fstyle=labelProp.fontStyle, save
	SetDrawEnv/W=$gname xcoord=$TG_HorizAxis,ycoord=$TG_VertAxis,save
	
	strswitch (which)
		case "Bottom":
			SetDrawEnv/W=$gname origin=0.5,0.0
			SetDrawEnv/W=$gname xcoord=abs, ycoord=abs
			SetDrawEnv/W=$gname translate=labelProp.labelLatOffset,labelProp.labelOffset
			SetDrawEnv/W=$gname textxjust=1,textyjust=2
			if (strlen(labelProp.font))
				DrawText/W=$gname 0, 0, "\\F'"+labelProp.font+"'"+labelProp.text
			else
				DrawText/W=$gname 0, 0, labelProp.text
			endif
			break;
		case "Left":
			SetDrawEnv/W=$gname origin=0.25,cos30/2
			SetDrawEnv/W=$gname xcoord=abs, ycoord=abs
			SetDrawEnv/W=$gname rotate=-60
			SetDrawEnv/W=$gname translate=labelProp.labelLatOffset,-labelProp.labelOffset
			SetDrawEnv/W=$gname textxjust=1,textyjust=0
			if (strlen(labelProp.font))
				DrawText/W=$gname 0, 0, "\\F'"+labelProp.font+"'"+labelProp.text
			else
				DrawText/W=$gname 0, 0, labelProp.text
			endif
			break;
		case "Right":
			SetDrawEnv/W=$gname origin=0.75,cos30/2
			SetDrawEnv/W=$gname xcoord=abs, ycoord=abs
			SetDrawEnv/W=$gname rotate=60
			SetDrawEnv/W=$gname translate=labelProp.labelLatOffset,-labelProp.labelOffset
			SetDrawEnv/W=$gname textxjust=1,textyjust=0
			if (strlen(labelProp.font))
				DrawText/W=$gname 0, 0, "\\F'"+labelProp.font+"'"+labelProp.text
			else
				DrawText/W=$gname 0, 0, labelProp.text
			endif
			break;
	endswitch
	
	SetDrawEnv/W=$gname gstop
	SetDrawEnv/W=$gname pop
		
	String GraphAxisLabelStruct
	StructPut/S labelProp, GraphAxisLabelStruct
	SetWindow $gname, UserData($groupName)=GraphAxisLabelStruct	
end

Function/S GetTernaryCornerLabelGroup(gname, which)
	String gname, which
	
	String groupName = ""
	StrSwitch (which)
		case "Top":
			groupName = "TernaryCornerLabelTGroup"
			break;
		case "Left":
			groupName = "TernaryCornerLabelLGroup"
			break;
		case "Right":
			groupName = "TernaryCornerLabelRGroup"
			break;
	endswitch
	
	return groupName
end

Function GetTernaryCornerLabelStructure(gname, s, which)
	String gname
	STRUCT TernaryGraphAxisLabelProperties &s
	String which
	
	Variable returnValue = 0		// success
	
	String groupName = GetTernaryCornerLabelGroup(gname, which)
	String CornerLabelStructStr = GetUserData(gname, "", groupName)
	if (strlen(CornerLabelStructStr) > 0)
		StructGet/S s, CornerLabelStructStr
	else
		returnValue = 1
	endif
	
	return returnValue
end

Function RemoveTernaryCornerLabel(gname, which)
	String gname, which
	
	SetDrawLayer/W=$gname ProgAxes
	String groupName = GetTernaryCornerLabelGroup(gname, which)
	
	DrawAction/W=$gname/L=ProgAxes getgroup=$groupName
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif
	SetWindow $gname, UserData($groupName)=""	
end

Function RemoveAllTernaryCornerLabels(gname)
	String gname
	
	RemoveTernaryCornerLabel(gname, "Left")
	RemoveTernaryCornerLabel(gname, "Right")
	RemoveTernaryCornerLabel(gname, "Top")
end

Function DrawTernaryGraphCornerLabels(gname, labelText, red, green, blue, font, fontsize, fontstyle, labelOffset, labelLatOffset, which)
	String gname
	String labelText
	Variable red, green, blue
	String font
	Variable fontsize, fontstyle, labelOffset, labelLatOffset
	String which			// "Top", "Left" or "Right"
	
	SetDrawLayer/W=$gname ProgAxes
	String groupName = GetTernaryCornerLabelGroup(gname, which)
	
	DrawAction/W=$gname/L=ProgAxes getgroup=$groupName
	if (V_flag)
		DrawAction/W=$gname/L=ProgAxes delete=V_startPos, V_endPos
	endif

	STRUCT TernaryGraphAxisLabelProperties labelProp
	labelProp.text = labelText
	labelProp.labelColor.red = red
	labelProp.labelColor.green = green
	labelProp.labelColor.blue = blue
	labelProp.font = font
	labelProp.fontSize = fontsize
	labelProp.fontStyle = fontstyle
	labelProp.labelOffset = labelOffset
	labelProp.labelLatOffset = labelLatOffset
	
	Variable i
	Variable xstart
	Variable ystart
	
	SetDrawLayer/W=$gname ProgAxes
	SetDrawEnv/W=$gname push
	SetDrawEnv/W=$gname gstart, gname = $groupName
	SetDrawEnv/W=$gname textrgb=(labelProp.labelColor.red,labelProp.labelColor.green,labelProp.labelColor.blue), fsize=labelProp.fontSize, fstyle=labelProp.fontStyle, save
	SetDrawEnv/W=$gname xcoord=$TG_HorizAxis,ycoord=$TG_VertAxis,save
	
	strswitch (which)
		case "Left":
			SetDrawEnv/W=$gname origin=0,0
			SetDrawEnv/W=$gname xcoord=abs, ycoord=abs
			SetDrawEnv/W=$gname origin=0,labelProp.labelOffset
			SetDrawEnv/W=$gname textxjust=1,textyjust=2
			if (strlen(labelProp.font))
				DrawText/W=$gname labelLatOffset, 0, "\\F'"+labelProp.font+"'"+labelProp.text
			else
				DrawText/W=$gname labelLatOffset, 0, labelProp.text
			endif
			break;
		case "Right":
			SetDrawEnv/W=$gname origin=1.0,0.0
			SetDrawEnv/W=$gname xcoord=abs, ycoord=abs
			SetDrawEnv/W=$gname origin=0,labelProp.labelOffset
			SetDrawEnv/W=$gname textxjust=1,textyjust=2
			if (strlen(labelProp.font))
				DrawText/W=$gname labelLatOffset, 0, "\\F'"+labelProp.font+"'"+labelProp.text
			else
				DrawText/W=$gname labelLatOffset, 0, labelProp.text
			endif
			break;
		case "Top":
			SetDrawEnv/W=$gname origin=0.5,cos30
			SetDrawEnv/W=$gname xcoord=abs, ycoord=abs
			SetDrawEnv/W=$gname origin=0,-labelProp.labelOffset
			SetDrawEnv/W=$gname textxjust=1,textyjust=0
			if (strlen(labelProp.font))
				DrawText/W=$gname labelLatOffset, 0, "\\F'"+labelProp.font+"'"+labelProp.text
			else
				DrawText/W=$gname labelLatOffset, 0, labelProp.text
			endif
			break;
	endswitch
	
	SetDrawEnv/W=$gname gstop
	SetDrawEnv/W=$gname pop
		
	String GraphCornerLabelStruct
	StructPut/S labelProp, GraphCornerLabelStruct
	SetWindow $gname, UserData($groupName)=GraphCornerLabelStruct	
end

//Function Test()
//
//	STRUCT TernaryGraphAxes defaultAxes
//	String GraphAxisStruct = GetUserData("TernaryGraph", "", "TernaryGraphAxisStruct")
//	StructGet/S defaultAxes, GraphAxisStruct
//end

//Function Test()
//
//	STRUCT TernaryGraphGridProperties gridProps
//	String GraphGridStruct = GetUserData("TernaryGraph", "", "TernaryGraphGridStruct")
//	StructGet/S gridProps, GraphGridStruct
//end

Function initializeDefaultTernaryAxis(s)
	STRUCT TernaryGraphAxisProperties &s
	
	s.lineThick = 1
	s.lineRGB.red = 0
	s.lineRGB.green = 0
	s.lineRGB.blue = 0
end

Function initializeBlueTernaryAxis(s)
	STRUCT TernaryGraphAxisProperties &s
	
	s.lineThick = 1
	s.lineRGB.red = 0
	s.lineRGB.green = 0
	s.lineRGB.blue = 65535
end

Function initializeRedTernaryAxis(s)
	STRUCT TernaryGraphAxisProperties &s
	
	s.lineThick = 1
	s.lineRGB.red = 65535
	s.lineRGB.green = 0
	s.lineRGB.blue = 0
end

Function TernaryGraphDoItButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Wave/Z WaveA = $StringFromList(0, WS_SelectedObjectsList("NewTernaryGraphPanel", "TernaryPanel_AList"))
			Wave/Z WaveB = $StringFromList(0, WS_SelectedObjectsList("NewTernaryGraphPanel", "TernaryPanel_BList"))
			Wave/Z WaveC = $StringFromList(0, WS_SelectedObjectsList("NewTernaryGraphPanel", "TernaryPanel_CList"))
			Wave/Z WaveZ = $StringFromList(0, WS_SelectedObjectsList("NewTernaryGraphPanel", "TernaryPanel_ZList"))
			
			if (!WaveExists(WaveA))
				DoAlert 0, "You must select a wave from the A Component list"
			endif
			if (!WaveExists(WaveB))
				DoAlert 0, "You must select a wave from the A Component list"
			endif
			if (!WaveExists(WaveC))
				DoAlert 0, "You must select a wave from the A Component list"
			endif
			
			Variable error
			if (WaveExists(WaveZ))
				String gname = NewTernaryGraph(waveA, waveB, waveC, "", waveZ=waveZ, error=error)
			else
				gname = NewTernaryGraph(waveA, waveB, waveC, "", error=error)
			endif
			if (error)
				switch(error)
					case TG_Err_MismatchPnts:
						DoAlert 0, "You have chosen waves that have mismatched number of points."
						break;
					case TG_Err_NoTextWave:
						DoAlert 0, "You have chosen a text wave."
						break;
				endswitch
			else
				Execute/P/Q/Z "KillWindow NewTernaryGraphPanel"
			endif
			break
	endswitch

	return 0
End

Function mAddTernaryTracePanel()

	String gname = WinName(0,1)
	if (WinType(gname+"#TernaryAddTracePanel") == 7)
		KillWindow $(gname+"#TernaryAddTracePanel")
	endif
	TernaryAddTracePanel(gname, 0)
end

Function mAddTernaryContourPanel()

	String gname = WinName(0,1)
	if (WinType(gname+"#TernaryAddTracePanel") == 7)
		KillWindow $(gname+"#TernaryAddTracePanel")
	endif
	TernaryAddTracePanel(gname, 1)
end

Function TernaryAddTracePanel(gname, addContour)
	String gname
	Variable addContour

	MakeTernaryDataFolder()

	String panelName = gname+"#TernaryAddTracePanel"
	if (addContour)
		NewPanel/HOST=$gname/EXT=0/W=(0, 375,275,375)/N=TernaryAddTracePanel as "Add Ternary Contour"
	else	
		NewPanel/HOST=$gname/EXT=0/W=(0, 300,275,300)/N=TernaryAddTracePanel as "Add Ternary Trace"
	endif
		
	TitleBox TernaryGraphLeftComponentTitle,pos={16,15},size={164,16},title="Left Corner (A) Component:"
	TitleBox TernaryGraphLeftComponentTitle,fSize=12,frame=0
	
	String notifyProc= "TernaryAddTracePopNotify"
	Button TernaryGraphAComponentSelector,pos={37,40},size={200,20}
	MakeButtonIntoWSPopupButton(panelName, "TernaryGraphAComponentSelector", notifyProc)
	Variable sortKind = NumVarOrDefault(ksPackageDFC+"sortKind", WMWS_sortByName)
	Variable sortOrder = NumVarOrDefault(ksPackageDFC+"sortReverse", 0)
	PopupWS_SetGetSortOrder(panelName, "TernaryGraphAComponentSelector", sortKind, sortOrder)
	
	TitleBox TernaryGraphRightComponentTitle,pos={16,95},size={169,16},title="Right Corner (B) Component:"
	TitleBox TernaryGraphRightComponentTitle,fSize=12,frame=0
	
	Button TernaryGraphBComponentSelector,pos={37,120},size={200,20}
	MakeButtonIntoWSPopupButton(panelName, "TernaryGraphBComponentSelector", notifyProc)
	PopupWS_SetGetSortOrder(panelName, "TernaryGraphBComponentSelector", sortKind, sortOrder)
	
	TitleBox TernaryGraphTopComponentTitle,pos={16,175},size={161,16},title="Top Corner (C) Component:"
	TitleBox TernaryGraphTopComponentTitle,fSize=12,frame=0
	
	Button TernaryGraphCComponentSelector,pos={37,200},size={200,20}
	MakeButtonIntoWSPopupButton(panelName, "TernaryGraphCComponentSelector", notifyProc)
	PopupWS_SetGetSortOrder(panelName, "TernaryGraphCComponentSelector", sortKind, sortOrder)
	
	if (addContour)
		TitleBox TernaryGraphZComponentTitle,pos={16,250},size={77,16},title="Z Data Wave:"
		TitleBox TernaryGraphZComponentTitle,fSize=12,frame=0
	
		Button TernaryGraphZComponentSelector,pos={37,275},size={200,20}
		MakeButtonIntoWSPopupButton(panelName, "TernaryGraphZComponentSelector", notifyProc)
		PopupWS_SetGetSortOrder(panelName, "TernaryGraphZComponentSelector", sortKind, sortOrder)
	endif
	
	DefineGuide UGH0={FB,-59}
	NewPanel/W=(0,252,275,291)/FG=(,UGH0,,FB)/HOST=# 
	ModifyPanel frameStyle=0, frameInset=0

	Button TernaryGraphAddTraceButton,pos={18,19},size={100,20},proc=AddTraceButtonProc,title="Add"

	Button TernaryGraphAddTraceDoneButton,pos={156,19},size={100,20},proc=TernaryAddTraceDoneButtonProc,title="Done"

	RenameWindow #, AddDoneButtonPanel

	SetActiveSubwindow ##
End

Function TernaryAddTracePopNotify(event, wavepath, panelName, ctrlName)
	Variable event
	String wavepath
	String panelName
	String ctrlName

	if( event != WMWS_PopupPanelKilled )
		return 0
	endif
	
	// Set the sort orders all the same.
	// First get the final sort setting used to make a wave selection.
	Variable sortKind = -1	// inquiry code: WS_SetGetSortOrder() will update to last chosen sortKind
	Variable sortReverse = -1	// and sortOrder
	PopupWS_SetGetSortOrder(panelName, ctrlName, sortKind, sortReverse)
	//Print "sortKind = ", sortKind, "sortReverse = ",sortReverse

	// remember setting in global variables used for all Ternary wave lists and popups
	GetSetTernarySortKindAndOrder(sortKind,sortReverse)
	
	// Synchronize by setting the other controls sorting options to be the same.
	String controls="TernaryGraphAComponentSelector;TernaryGraphBComponentSelector;TernaryGraphCComponentSelector;TernaryGraphZComponentSelector;"
	controls= RemoveFromList(ctrlName, controls)
	Variable i, n= ItemsInList(controls)
	for(i=0;i<n;i+=1)
		String control= StringFromList(i,controls)
		ControlInfo/W=$panelName $control
		if( V_flag )
			PopupWS_SetGetSortOrder(panelName, control, sortKind, sortReverse)
		endif
	endfor

	// Not done: synchronizing other open Ternary panels
	
	WAVE/Z selectedWave= $wavepath
	return 1
End

Function TernaryGraphCancelButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Execute/P/Q/Z "KillWindow NewTernaryGraphPanel"
			break
	endswitch

	return 0
End

Function AddTraceButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String panelName = ParseFilePath(1, ba.win, "#", 1, 0)
			panelName = RemoveEnding(panelName)
			String AComponent = PopupWS_GetSelectionFullPath(panelName, "TernaryGraphAComponentSelector")
			String BComponent = PopupWS_GetSelectionFullPath(panelName, "TernaryGraphBComponentSelector")
			String CComponent = PopupWS_GetSelectionFullPath(panelName, "TernaryGraphCComponentSelector")
			
			ControlInfo/W=$panelName TernaryGraphZComponentSelector
			Variable addContour = V_flag!=0
			
			String gname = ParseFilePath(1, ba.win, "#", 0, 0)
			if (addContour)
				String ZComponent = PopupWS_GetSelectionFullPath(panelName, "TernaryGraphZComponentSelector")
				AddTernaryXYZContourToGraph($AComponent, $BComponent, $CComponent, $ZComponent, gname)
			else
				AddTernaryDataToGraph($AComponent, $BComponent, $CComponent, gname)
			endif
			break
	endswitch

	return 0
End

Function TernaryAddTraceDoneButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String panelName = ParseFilePath(1, ba.win, "#", 1, 0)
			panelName = RemoveEnding(panelName)
			KillWindow $(panelName)
			break
	endswitch

	return 0
End


Function mRemoveTernaryTracePanel()

	String gname = WinName(0,1)
	if (WinType(gname+"#TernaryRemoveTracePanel") == 7)
		DoWindow/F $gname
	else
		TernaryRemoveTracePanel(gname)
	endif
end

Function TernaryRemoveTracePanel(gname)
	String gname

	MakeTernaryDataFolder()

	String panelName = gname+"#TernaryRemoveTracePanel"
	NewPanel/HOST=$gname/EXT=0/W=(0, 300,275,300)/N=TernaryAddTracePanel as "Remove Ternary Trace or Contour"
	
	PopupMenu SelectTernaryTraceMenu,pos={30,56},size={225,20},bodyWidth=225
	String valueString = GetIndependentModuleName()+"#ListTernaryTraces(\""+gname+"\")"
	PopupMenu SelectTernaryTraceMenu,mode=1,value= #valueString
	
	TitleBox TernaryGraphSelectTraceRemove,pos={16,24},size={198,16},title="Select a Ternary Trace to Remove"
	TitleBox TernaryGraphSelectTraceRemove,fSize=12,frame=0
	
	Button RemoveTernaryTraceButton,pos={76,90},size={100,20},proc=RemoveTernaryTraceButtonProc,title="Remove It"
	
	PopupMenu SelectTernaryContourMenu,pos={30,181},size={225,20},bodyWidth=225
	valueString = GetIndependentModuleName()+"#ListTernaryContours(\""+gname+"\")"
	PopupMenu SelectTernaryContourMenu,mode=1,value= #valueString
	
	TitleBox TernaryGraphSelectContourRemove,pos={16,149},size={212,16},title="Select a Ternary Contour to Remove"
	TitleBox TernaryGraphSelectContourRemove,fSize=12,frame=0
	
	Button RemoveTernaryContourButton,pos={76,215},size={100,20},proc=RemoveTernaryContourButtonProc,title="Remove It"
	
	Button TernaryGraphRemoveTrDoneButton,pos={158,264},size={100,20},proc=TernaryRemTrDoneButtonProc,title="Done"
end

Function WaveIsTernaryTrace(gname, w)
	String gname
	Wave w
	
	String dependencyName= TernaryStringByKey(w,"TGDependencyVar")
	String contourDependencyName= TernaryStringByKey(w,"TGCDependencyVar") // present only for pre-1.06 contours, absent ("") for 1.06
	Variable isTrace = strlen(dependencyName) != 0 && strlen(contourDependencyName) == 0
	return isTrace
End

// must list both pre-1.06 an 1.06+ traces
Function/S ListTernaryTraces(gname)
	String gname
	
	String tlist = TraceNameList(gname, ";", 1)
	Variable nTraces = ItemsInList(tlist)
	String outputList = ""
	Variable i
	
	for (i = 0; i < nTraces; i += 1)
		String tname = StringFromList(i, tlist)
		Wave w = TraceNameToWaveRef(gname, tname)
		Variable isTrace = WaveIsTernaryTrace(gname,w)
		
		if (isTrace)
			String dataName = TernaryStringByKey(w,"waveA")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			outputList += dataName+"/"
			dataName = TernaryStringByKey(w,"waveB")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			outputList += dataName+"/"
			dataName = TernaryStringByKey(w,"waveC")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			outputList += dataName+"/"
			outputList += tname+";"
		endif
	endfor
	
	if (strlen(outputList) == 0)
		outputList = "\\M1(_none_"
	endif
	return outputList
end

Function WaveIsTernaryContour(gname, w)
	String gname
	Wave w							// from ContourNameToWaveRef, either a triplet with wave notes (pre 1.06), or 1-D without wave notes.

	String contourDependencyName= TernaryStringByKey(w,"TGCDependencyVar")
	Variable isContour= strlen(contourDependencyName)
	return isContour
End

// must list both pre-1.06 an 1.06+ contours
Function/S ListTernaryContours(gname)
	String gname
	
	String clist = ContourNameList(gname, ";")
	Variable nContours = ItemsInList(clist)
	String outputList = ""
	Variable i
	
	for (i = 0; i < nContours; i += 1)
		String cname = StringFromList(i, clist)
		Wave w = ContourNameToWaveRef(gname, cname)
		Variable isContour = WaveIsTernaryContour(gname,w)
		if (isContour)	
			String dataName = TernaryStringByKey(w,"waveA")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			outputList += dataName+"/"
			dataName = TernaryStringByKey(w,"waveB")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			outputList += dataName+"/"
			dataName = TernaryStringByKey(w,"waveC")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			outputList += dataName+"/"
			dataName = TernaryStringByKey(w,"waveZ")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			outputList += dataName+"/"
			outputList += cname+";"
		endif
	endfor
	
	if (strlen(outputList) == 0)
		outputList = "\\M1(_none_"
	endif
	return outputList
End


Function TernaryRemTrDoneButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			KillWindow $(ba.win)
			break
	endswitch

	return 0
End

Function RemoveTernaryTraceButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			ControlInfo/W=$(ba.win) SelectTernaryTraceMenu
			if (strlen(S_value) > 0)
				String tname = StringFromList(3, S_value, "/")
				String gname = ParseFilePath(1, ba.win, "#", 1, 0)
				gname = RemoveEnding(gname)
				if( RemoveTernaryTraceOrContour(gname, tname) )
					String remainingTraces= ListTernaryTraces(gname)
					Variable numTernaryTraces= ItemsInList(remainingTraces)
					Variable mode= max(1,min(numTernaryTraces-1, V_Value))
					PopupMenu SelectTernaryTraceMenu, win=$(ba.win), mode=mode
				endif
			endif
			break
	endswitch

	return 0
End

Function RemoveTernaryContourButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			ControlInfo/W=$(ba.win) SelectTernaryContourMenu
			if (strlen(S_value) > 0)
				String cname = StringFromList(4, S_value, "/")
				String gname = ParseFilePath(1, ba.win, "#", 1, 0)
				gname = RemoveEnding(gname)
				if( RemoveTernaryTraceOrContour(gname, cname) )
					String remainingContours= ListTernaryContours(gname)
					Variable numTernaryContours= ItemsInList(remainingContours)
					Variable mode= max(1,min(numTernaryContours-1, V_Value))
					PopupMenu SelectTernaryContourMenu, win=$(ba.win), mode=mode
				endif
			endif
			break
	endswitch

	return 0
End

Function mModifyTernaryLinesPanel()

	String gname = WinName(0,1)
	if (WinType(gname+"#ModifyTernaryLinesPanel") == 7)
		DoWindow/F $gname
	else
		BuildModifyTernaryLinesPanel(gname)
	endif
end

Function mModifyTernaryLabelsPanel()

	String gname = WinName(0,1)
	if (WinType(gname+"#ModifyTernaryGraphPanel") == 7)
		DoWindow/F $gname
	else
		BuildModifyTernaryLabelsPanel(gname)
	endif
end

Function MenuToTickIncrement(popValue)
	Variable popValue
	
	switch (popValue)
		case 1:
			return .05
			break;
		case 2:
			return .1
			break;
		case 3:
			return .2
			break;
		case 4:
			return .25
			break;
		case 5:
			return .5
			break;
	endswitch
end

Function TickIncrementToMenu(increment)
	Variable increment
	
	Variable popValue = 5
	if (increment < .499)
		popValue = 4
	endif
	if (increment < .2499)
		popValue = 3
	endif
	if (increment < .199)
		popValue = 2
	endif
	if (increment < .099)
		popValue = 1
	endif
	
	return popValue
end

Function BuildModifyTernaryLinesPanel(gname)
	String gname

	MakeTernaryDataFolder()

	Variable popMode
	
	NewPanel /W=(0,384,256,384)/N=ModifyTernaryLinesPanel/HOST=$gname/EXT=0
	String panelName = gname+"#"+S_name
	SetWindow $panelName UserData(ModifyTernaryHostGraph)=gname

	TabControl ModifyTernaryTabControl,pos={1,3},size={249,289}
	TabControl ModifyTernaryTabControl,tabLabel(0)="Axis"
	TabControl ModifyTernaryTabControl,tabLabel(1)="Ticks"
	TabControl ModifyTernaryTabControl,tabLabel(2)="Grid"
	TabControl ModifyTernaryTabControl,value= 0,proc=ModifyTernaryGraphTabProc
	
	Button ModifyTernaryDoneButton,pos={88,347},size={70,20},proc=ModifyTernaryDoneButtonProc,title="Done"

	DefineGuide UGH0={FT,29},UGV0={FL,8},UGH1={FB,-105},UGV1={FR,-10}
	
	NewPanel/W=(168,125,507,376)/FG=(UGV0,UGH0,UGV1,UGH1)/HOST=#/N=ModifyTernaryAxisSubpanel
	ModifyPanel frameStyle=0, frameInset=0
	
		PopupMenu TernaryGraphAxisColorMenu,pos={102,63},size={86,20},title="Color:"
		PopupMenu TernaryGraphAxisColorMenu,fSize=12, proc=ModifyTernaryActionPopupProc
		PopupMenu TernaryGraphAxisColorMenu,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	
		SetVariable TernaryGraphSetAxisThickness,pos={79,100},size={114,19},bodyWidth=50,title="Thickness:",limits={0,inf,1}
		SetVariable TernaryGraphSetAxisThickness,fSize=12,value= _NUM:1,proc=ModifyTernaryActionSetvarProc, live=1

		// structure includes independent info for each axis, but we don't break them out (at least not yet)
		STRUCT TernaryGraphAxes axisStruct
		GetTernaryAxisStructFromGraph(gname, axisStruct)
		PopupMenu TernaryGraphAxisColorMenu, popcolor=(axisStruct.axisAB.lineRGB.red, axisStruct.axisAB.lineRGB.green, axisStruct.axisAB.lineRGB.blue)
		SetVariable TernaryGraphSetAxisThickness,value= _NUM:axisStruct.axisAB.lineThick

	SetActiveSubwindow ##
	
	NewPanel/W=(168,125,507,376)/FG=(UGV0,UGH0,UGV1,UGH1)/HOST=#/N=ModifyTernaryTicksSubpanel
	ModifyPanel frameStyle=0, frameInset=0
	
		CheckBox TernaryGraphShowTicksCheck,pos={29,29},size={114,16},title="Show Tick Marks"
		CheckBox TernaryGraphShowTicksCheck,fSize=12,value= 0, proc=ModifyTernaryActionCheckProc
		
		PopupMenu TernaryGraphTickColorMenu,pos={102,63},size={86,20},title="Color:"
		PopupMenu TernaryGraphTickColorMenu,fSize=12
		PopupMenu TernaryGraphTickColorMenu,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\"", proc=ModifyTernaryActionPopupProc
		
		SetVariable TernaryGraphSetTickThickness,pos={79,100},size={114,19},bodyWidth=50,title="Thickness:",limits={0,inf,1}
		SetVariable TernaryGraphSetTickThickness,fSize=12,value= _NUM:1,proc=ModifyTernaryActionSetvarProc, live=1
		
		SetVariable TernaryGraphSetTickLength,pos={95,136},size={98,19},bodyWidth=50,title="Length:",limits={0,inf,1}
		SetVariable TernaryGraphSetTickLength,fSize=12,value= _NUM:3,proc=ModifyTernaryActionSetvarProc, live=1
		
		CheckBox TernaryGraphInsideTicksCheck,pos={102,173},size={81,16},title="InsideTicks"
		CheckBox TernaryGraphInsideTicksCheck,fSize=12,value= 1, proc=ModifyTernaryActionCheckProc
	
		PopupMenu ModifyTernaryTickIncrement,pos={73,216},size={115,20},bodyWidth=50,title="Increment:"
		PopupMenu ModifyTernaryTickIncrement,fSize=12
		PopupMenu ModifyTernaryTickIncrement,mode=5,value= #"\"5;10;20;25;50;\"", proc=ModifyTernaryActionPopupProc
		
		STRUCT TernaryGraphTickProperties tickProps
		if (GetTernaryGraphTickStructure(gname, tickProps) == 0)
			CheckBox TernaryGraphShowTicksCheck,value= 1
			PopupMenu TernaryGraphTickColorMenu,popColor= (tickProps.tickColor.red,tickProps.tickColor.green,tickProps.tickColor.blue)
			SetVariable TernaryGraphSetTickThickness,value= _NUM:tickProps.tickThick
			SetVariable TernaryGraphSetTickLength,value= _NUM:tickProps.tickLength
			CheckBox TernaryGraphInsideTicksCheck,value= tickProps.ticksInside
			PopupMenu ModifyTernaryTickIncrement,mode=TickIncrementToMenu(tickProps.tickIncrement)
		else
			CheckBox TernaryGraphShowTicksCheck,value= 0
		endif
		
	SetActiveSubwindow ##
	
	NewPanel/W=(168,125,507,376)/FG=(UGV0,UGH0,UGV1,UGH1)/HOST=#/N=ModifyTernaryGridSubpanel
	ModifyPanel frameStyle=0, frameInset=0
	
		CheckBox TernaryGraphGridCheck,pos={29,29},size={76,16},title="Show Grid"
		CheckBox TernaryGraphGridCheck,fSize=12,value= 0, proc=ModifyTernaryActionCheckProc
		
		PopupMenu ModifyTernaryGridIncrement,pos={15,173},size={115,20},bodyWidth=50,title="Increment:"
		PopupMenu ModifyTernaryGridIncrement,fSize=12
		PopupMenu ModifyTernaryGridIncrement,mode=2,popvalue="10",value= #"\"5;10;20;25;50;\"", proc=ModifyTernaryActionPopupProc
			
		PopupMenu TernaryGraphGridColorMenu,pos={44,63},size={86,20},title="Color:"
		PopupMenu TernaryGraphGridColorMenu,fSize=12
		PopupMenu TernaryGraphGridColorMenu,mode=1,popColor= (49151,60031,65535),value= #"\"*COLORPOP*\"", proc=ModifyTernaryActionPopupProc
			
		SetVariable TernaryGraphSetGridThickness,pos={15,100},size={114,19},bodyWidth=50,title="Thickness:",limits={0,inf,1}
		SetVariable TernaryGraphSetGridThickness,fSize=12,value= _NUM:2,proc=ModifyTernaryActionSetvarProc, live=1
			
		PopupMenu TernaryGraphSetGridDash,pos={16,136},size={214,20},title="Line Style:"
		PopupMenu TernaryGraphSetGridDash,fSize=12
		PopupMenu TernaryGraphSetGridDash,mode=3,popvalue="",value= #"\"*LINESTYLEPOP*\"", proc=ModifyTernaryActionPopupProc

		STRUCT TernaryGraphGridProperties gridStruct
		if (GetTernaryGridStructFromGraph(gname, gridStruct) == 0)
			CheckBox TernaryGraphGridCheck,value= 1
			PopupMenu ModifyTernaryGridIncrement,mode=TickIncrementToMenu(gridStruct.delta)
			PopupMenu TernaryGraphGridColorMenu,mode=1,popColor= (gridStruct.gridColor.red, gridStruct.gridColor.green, gridStruct.gridColor.blue)
			SetVariable TernaryGraphSetGridThickness,fSize=12,value= _NUM:gridStruct.gridThick
			PopupMenu TernaryGraphSetGridDash,mode=gridStruct.gridDash+1
		else
			CheckBox TernaryGraphGridCheck,value= 0
		endif
		
	SetActiveSubwindow ##
	
	ModifyTernarySetTab(panelName, 0)
end

static Function PopMenuTextStyleToBitValue(Variable popItem)

	Variable bitValue = 0
	
	switch(popItem)
		case 1:				// plain
			bitValue = 0
			break;
		case 2:				// Bold
			bitValue = 1
			break;
		case 3:				// Italic
			bitValue = 2
			break;
		case 4:				// Underline
			bitValue = 4
			break;
		case 5:				// Strikethrough
			bitValue = 16
			break;
		default:				// Programmer error
			bitValue = 0
	endswitch
	
	return bitValue
end

static Function/S FontStyleValueString(Variable currentBits)

	String theString = "Plain;Bold;Italic;Underline;Strikethrough;"
	if (currentBits != 0)
		String checkString = "\\M1:! :"
		theString = "Plain;"
		if (currentBits & 1)
			theString += checkString + "Bold;"
		else
			theString += "Bold;"
		endif
		if (currentBits & 2)
			theString += checkString + "Italic;"
		else
			theString += "Italic;"
		endif
		if (currentBits & 4)
			theString += checkString + "Underline;"
		else
			theString += "Underline;"
		endif
		if (currentBits & 16)
			theString += checkString + "Strikethrough;"
		else
			theString += "Strikethrough;"
		endif
	endif

	return theString
end

static Function SetFontStylePopValue(String wname, String ctrlname, Variable currentBits)

		String quote = "\""
		String theValue = quote + FontStyleValueString(currentBits) + quote
		PopupMenu $(ctrlName), win=$(wname), value = #theValue
		PopupMenu $(ctrlName), win=$(wname), userData(CurrentStyles)=num2str(currentBits)
end

Function BasicFontStyleMenuAction(struct WMPopupAction & s)

	if (s.eventCode == 2)				// Mouse up
		Variable currentBits = Str2Num(GetUserData(s.win, s.ctrlName, "CurrentStyles"))
		Variable chosenStyle = PopMenuTextStyleToBitValue(s.popNum)
		if (chosenStyle == 0)
			currentBits = 0
		else
			if (currentBits & chosenStyle)
				currentBits = currentBits & (~chosenStyle & 23)			// 23 = 1 + 2 + 4 + 16, all the valid font style bits
			else
				currentBits = currentBits | chosenStyle
			endif
		endif
		SetFontStylePopValue(s.win, s.ctrlName, currentBits)
	endif
end

Function FontStyleMenuAction(struct WMPopupAction & s)

	if (s.eventCode == 2)				// Mouse up
		BasicFontStyleMenuAction(s)
		String panelName = ParseFilePath(0, s.win, "#", 0, 0)
		panelName += "#"+ParseFilePath(0, s.win, "#", 0, 1)
		ApplyModifyTernaryChange(panelName)	
	endif
end

Function BuildModifyTernaryLabelsPanel(gname)
	String gname

	MakeTernaryDataFolder()

	Variable popMode
	
	NewPanel /W=(0,575,308,575)/N=ModifyTernaryLabelsPanel/HOST=$gname/EXT=0
	String panelName = gname+"#"+S_name
	SetWindow $panelName UserData(ModifyTernaryHostGraph)=gname

	TabControl ModifyTernaryTabControl,pos={1,2},size={304,519}
	TabControl ModifyTernaryTabControl,tabLabel(0)="Tick Labels"
	TabControl ModifyTernaryTabControl,tabLabel(1)="Corner Labels"
	TabControl ModifyTernaryTabControl,tabLabel(2)="Side Labels"
	TabControl ModifyTernaryTabControl,value= 0,proc=ModifyTernaryGraphTabProc
	
	Button ModifyTernaryDoneButton,pos={214,538},size={70,20},proc=ModifyTernaryDoneButtonProc,title="Done"

	DefineGuide UGH0={FT,29},UGV0={FL,8},UGH1={FB,-63},UGV1={FR,-10}
	
	NewPanel/W=(168,125,507,376)/FG=(UGV0,UGH0,UGV1,UGH1)/HOST=#/N=ModifyTernaryTickLabelsSubpanel
	ModifyPanel frameStyle=0, frameInset=0
	
		CheckBox TernaryGraphTickLabelsCheck,pos={29,29},size={117,16},title="Show Tick Labels"
		CheckBox TernaryGraphTickLabelsCheck,fSize=12,value= 1, proc=ModifyTernaryActionCheckProc

		PopupMenu ModifyTernaryTickLabelFontMenu,pos={68,64},size={213,20},bodyWidth=180,title="Font:"
		PopupMenu ModifyTernaryTickLabelFontMenu,fSize=12
		PopupMenu ModifyTernaryTickLabelFontMenu,mode=1,value= #"\"Default;\\M1-;\"+FontList(\";\", 1)", proc=ModifyTernaryActionPopupProc

		SetVariable ModifyTernarySetFontSize,pos={38,103},size={112,19},bodyWidth=50,title="Font Size:",limits={1,inf,1}
		SetVariable ModifyTernarySetFontSize,fSize=12,value= _NUM:12,proc=ModifyTernaryActionSetvarProc, live=1

		PopupMenu ModifyTernaryTickFontStyle,pos={103,140},size={90,23},bodyWidth=87,title="Font Style"
		PopupMenu ModifyTernaryTickFontStyle,fSize=12
		PopupMenu ModifyTernaryTickFontStyle,mode=1,value= #"\"Plain;Bold;Italic;Underline;Strikethrough;\"", proc=FontStyleMenuAction

		PopupMenu ModifyTernaryTickLColorMenu,pos={65,178},size={86,20},title="Color:"
		PopupMenu ModifyTernaryTickLColorMenu,fSize=12
		PopupMenu ModifyTernaryTickLColorMenu,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\"", proc=ModifyTernaryActionPopupProc

		PopupMenu ModifyTernaryTickLabelIncrement,pos={36,216},size={115,20},bodyWidth=50,title="Increment:"
		PopupMenu ModifyTernaryTickLabelIncrement,fSize=12
		PopupMenu ModifyTernaryTickLabelIncrement,mode=2,value= #"\"5;10;20;25;50;\"", proc=ModifyTernaryActionPopupProc

		SetVariable ModifyTernarySetTickLabelOffset,pos={56,255},size={94,19},bodyWidth=50,title="Offset:"
		SetVariable ModifyTernarySetTickLabelOffset,fSize=12,value= _NUM:9,proc=ModifyTernaryActionSetvarProc, live=1

		SetVariable ModifyTernaryTickMultiplier,pos={13.00,295.00},size={157.00,18.00},bodyWidth=70
		SetVariable ModifyTernaryTickMultiplier,title="Tick Multiplier:"
		SetVariable ModifyTernaryTickMultiplier,fSize=12,value=_NUM:1,proc=ModifyTernaryActionSetvarProc
		SetVariable ModifyTernaryTickMultiplier,help={"Tick labels will by 100*multiplier. Simple numbers are best, usually multiples of 10."}
	
		SetVariable ModifyTernaryTickLabelUnits,pos={36.00,334.00},size={94.00,18.00},bodyWidth=30
		SetVariable ModifyTernaryTickLabelUnits,title="Tick Units:",fSize=12
		SetVariable ModifyTernaryTickLabelUnits,value=_STR:"%",proc=ModifyTernaryActionSetvarProc
		SetVariable ModifyTernaryTickLabelUnits,help={"Replaces '%' as the units label for the last tick."}
	
		SetVariable ModifyTernaryTickLabelFormat,pos={25.00,373.00},size={115.00,18.00},bodyWidth=40
		SetVariable ModifyTernaryTickLabelFormat,title="Tick Format:",fSize=12
		SetVariable ModifyTernaryTickLabelFormat,value=_STR:"%d",proc=ModifyTernaryActionSetvarProc
		SetVariable ModifyTernaryTickLabelFormat,help={"Usually %d is best. For small values of the multiplier you may wish to use %g or %f."}

		STRUCT TernaryGraphTickLabelProperties tickLabelStruct
		STRUCT TernaryGraphTickLabelPropertiesEx tickLabelStructEx
		if (GetTernaryTickLabelStructure(gname, tickLabelStruct, tickLabelStructEx, "Left") == 0)		// for now, let the Left labels stand in for all
			CheckBox TernaryGraphTickLabelsCheck,value= 1
			popMode = WhichListItem(tickLabelStruct.font, FontList(";", 1))+3
			if (popMode < 3)
				popMode = 1
			endif
			PopupMenu ModifyTernaryTickLabelFontMenu, mode=popMode
			SetVariable ModifyTernarySetFontSize,value= _NUM:tickLabelStruct.fontSize
			PopupMenu ModifyTernaryTickFontStyle,mode=0
			SetFontStylePopValue(panelName+"#ModifyTernaryTickLabelsSubpanel", "ModifyTernaryTickFontStyle", tickLabelStruct.fontStyle)
			PopupMenu ModifyTernaryTickLColorMenu,mode=1,popColor= (tickLabelStruct.labelColor.red, tickLabelStruct.labelColor.green, tickLabelStruct.labelColor.blue)
			PopupMenu ModifyTernaryTickLabelIncrement,mode=TickIncrementToMenu(tickLabelStruct.labelIncrement)
			SetVariable ModifyTernarySetTickLabelOffset,value= _NUM:tickLabelStruct.labelOffset
			
			SetVariable ModifyTernaryTickLabelFormat,value=_STR:tickLabelStructEx.tickformat
			SetVariable ModifyTernaryTickLabelUnits,value=_STR:tickLabelStructEx.tickunits
			SetVariable ModifyTernaryTickMultiplier,value=_NUM:tickLabelStructEx.tickmultiplier
		else
			CheckBox TernaryGraphTickLabelsCheck,value= 0
		endif

	SetActiveSubwindow ##
	
	NewPanel/W=(168,125,507,376)/FG=(UGV0,UGH0,UGV1,UGH1)/HOST=#/N=ModifyTernaryCornerLblsSubpanel
	ModifyPanel frameStyle=0, frameInset=0
	
		CheckBox TernaryGraphCornerLblsCheck,pos={14,12},size={132,16},title="Show Corner Labels"
		CheckBox TernaryGraphCornerLblsCheck,fSize=12,value= 1, proc=ModifyTernaryActionCheckProc

		PopupMenu ModifyTernaryCornerLblFontMenu,pos={38,37},size={213,20},bodyWidth=180,title="Font:"
		PopupMenu ModifyTernaryCornerLblFontMenu,fSize=12
		PopupMenu ModifyTernaryCornerLblFontMenu,mode=1,value= #"\"Default;\\M1-;\"+FontList(\";\", 1)", proc=ModifyTernaryActionPopupProc

		SetVariable ModifyTernaryCornerLSetFontSize,pos={51,65},size={122,19},bodyWidth=60,title="Font Size:",limits={1,inf,1}
		SetVariable ModifyTernaryCornerLSetFontSize,fSize=12,value= _NUM:18,proc=ModifyTernaryActionSetvarProc, live=1

		PopupMenu ModifyTernaryCornerLblFontStyle,pos={115,91},size={88,23},bodyWidth=87,title="Font Style"
		PopupMenu ModifyTernaryCornerLblFontStyle,fSize=12
		PopupMenu ModifyTernaryCornerLblFontStyle,mode=1,value= #"\"Plain;Bold;Italic;Underline;Strikethrough;\"", proc=FontStyleMenuAction

		PopupMenu ModifyTernaryCornerLblColorMenu,pos={77,119},size={86,20},title="Color:"
		PopupMenu ModifyTernaryCornerLblColorMenu,fSize=12
		PopupMenu ModifyTernaryCornerLblColorMenu,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\"", proc=ModifyTernaryActionPopupProc

		GroupBox TernaryLeftCornerLabelGroup,pos={32,142},size={200,107},title="Lower Left"
		GroupBox TernaryLeftCornerLabelGroup,fSize=12

		SetVariable TernaryLeftCornerLabelText,pos={68,167},size={120,19},bodyWidth=120
		SetVariable TernaryLeftCornerLabelText,fSize=12,value= _STR:"",proc=ModifyTernaryActionSetvarProc

		SetVariable ModifyTernarySetCrnrLYLabelOffs,pos={52,222},size={153,19},bodyWidth=60,title="Vertical Offset:"
		SetVariable ModifyTernarySetCrnrLYLabelOffs,fSize=12,value= _NUM:30,proc=ModifyTernaryActionSetvarProc, live=1

		SetVariable ModifyTernarySetCrnrLXLabelOffs,pos={45,194},size={167,19},bodyWidth=60,title="Horizontal Offset:"
		SetVariable ModifyTernarySetCrnrLXLabelOffs,fSize=12,value= _NUM:-50,proc=ModifyTernaryActionSetvarProc, live=1

		GroupBox TernaryRightCornerLabelGroup,pos={32,258},size={200,107},title="Lower Right"
		GroupBox TernaryRightCornerLabelGroup,fSize=12

		SetVariable TernaryRightCornerLabelText,pos={68,283},size={120,19},bodyWidth=120
		SetVariable TernaryRightCornerLabelText,fSize=12,value= _STR:"",proc=ModifyTernaryActionSetvarProc

		SetVariable ModifyTernarySetCrnrRYLabelOffs,pos={52,338},size={153,19},bodyWidth=60,title="Vertical Offset:"
		SetVariable ModifyTernarySetCrnrRYLabelOffs,fSize=12,value= _NUM:30,proc=ModifyTernaryActionSetvarProc, live=1

		SetVariable ModifyTernarySetCrnrRXLabelOffs,pos={45,310},size={167,19},bodyWidth=60,title="Horizontal Offset:"
		SetVariable ModifyTernarySetCrnrRXLabelOffs,fSize=12,value= _NUM:50,proc=ModifyTernaryActionSetvarProc, live=1

		GroupBox TernaryTopCornerLabelGroup,pos={32,373},size={200,107},title="Top"
		GroupBox TernaryTopCornerLabelGroup,fSize=12

		SetVariable TernaryTopCornerLabelText,pos={68,398},size={120,19},bodyWidth=120
		SetVariable TernaryTopCornerLabelText,fSize=12,value= _STR:"",proc=ModifyTernaryActionSetvarProc

		SetVariable ModifyTernarySetCrnrTYLabelOffs,pos={52,453},size={153,19},bodyWidth=60,title="Vertical Offset:"
		SetVariable ModifyTernarySetCrnrTYLabelOffs,fSize=12,value= _NUM:30,proc=ModifyTernaryActionSetvarProc, live=1

		SetVariable ModifyTernarySetCrnrTXLabelOffs,pos={45,425},size={167,19},bodyWidth=60,title="Horizontal Offset:"
		SetVariable ModifyTernarySetCrnrTXLabelOffs,fSize=12,value= _NUM:40,proc=ModifyTernaryActionSetvarProc, live=1
	
		STRUCT TernaryGraphAxisLabelProperties cornerLabelStruct
		if (GetTernaryCornerLabelStructure(gname, cornerLabelStruct, "Left") == 0)
			CheckBox TernaryGraphCornerLblsCheck,value= 1
			popMode = WhichListItem(cornerLabelStruct.font, FontList(";", 1))+3
			if (popMode < 3)
				popMode = 1
			endif
			PopupMenu ModifyTernaryCornerLblFontMenu,mode=popMode
			SetVariable ModifyTernaryCornerLSetFontSize,value= _NUM:cornerLabelStruct.fontSize
			PopupMenu ModifyTernaryCornerLblFontStyle,mode=0
			SetFontStylePopValue(panelName+"#ModifyTernaryCornerLblsSubpanel", "ModifyTernaryCornerLblFontStyle", cornerLabelStruct.fontStyle)
			PopupMenu ModifyTernaryCornerLblColorMenu,mode=1,popColor= (cornerLabelStruct.labelColor.red, cornerLabelStruct.labelColor.green, cornerLabelStruct.labelColor.blue)
			SetVariable TernaryLeftCornerLabelText,value=_STR:cornerLabelStruct.text
			SetVariable ModifyTernarySetCrnrLYLabelOffs,value= _NUM:cornerLabelStruct.labelOffset
			SetVariable ModifyTernarySetCrnrLXLabelOffs,value= _NUM:cornerLabelStruct.labelLatOffset
			if (GetTernaryCornerLabelStructure(gname, cornerLabelStruct, "Right") == 0)
				SetVariable TernaryRightCornerLabelText,value=_STR:cornerLabelStruct.text
				SetVariable ModifyTernarySetCrnrRYLabelOffs,value= _NUM:cornerLabelStruct.labelOffset
				SetVariable ModifyTernarySetCrnrRXLabelOffs,value= _NUM:cornerLabelStruct.labelLatOffset
			endif
			if (GetTernaryCornerLabelStructure(gname, cornerLabelStruct, "Top") == 0)
				SetVariable TernaryTopCornerLabelText,value=_STR:cornerLabelStruct.text
				SetVariable ModifyTernarySetCrnrTYLabelOffs,value= _NUM:cornerLabelStruct.labelOffset
				SetVariable ModifyTernarySetCrnrTXLabelOffs,value= _NUM:cornerLabelStruct.labelLatOffset
			endif
		else
			String tname = StringFromList(0, TraceNameList(gname, ";", 1))
			if (strlen(tname) == 0)
				tname = StringFromList(0, ContourNameList(gname, ";"))
				if (strlen(tname) == 0)
					return 0
				else
					Wave w = ContourNameToWaveRef(gname, tname)
				endif
			else
				Wave w = TraceNameToWaveRef(gname, tname)
			endif
			String theNote = Note(w)
			String dataName = StringByKey("waveA", theNote, "=", "\r")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			SetVariable TernaryLeftCornerLabelText,value=_STR:dataName
			
			dataName = StringByKey("waveB", theNote, "=", "\r")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			SetVariable TernaryRightCornerLabelText,value=_STR:dataName
			
			dataName = StringByKey("waveC", theNote, "=", "\r")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			SetVariable TernaryTopCornerLabelText,value=_STR:dataName
			
			CheckBox TernaryGraphCornerLblsCheck,value= 0
		endif
	SetActiveSubwindow ##
	
	NewPanel/W=(168,125,507,376)/FG=(UGV0,UGH0,UGV1,UGH1)/HOST=#/N=ModifyTernarySideLabelsSubpanel
	ModifyPanel frameStyle=0, frameInset=0
	
		CheckBox TernaryGraphSideLblsCheck,pos={14,12},size={118,16},title="Show Side Labels"
		CheckBox TernaryGraphSideLblsCheck,fSize=12,value= 1, proc=ModifyTernaryActionCheckProc

		PopupMenu ModifyTernarySideLabelFontMen,pos={38,37},size={213,20},bodyWidth=180,title="Font:"
		PopupMenu ModifyTernarySideLabelFontMen,fSize=12
		PopupMenu ModifyTernarySideLabelFontMen,mode=1,value= #"\"Default;\\M1-;\"+FontList(\";\", 1)", proc=ModifyTernaryActionPopupProc

		SetVariable ModifyTernarySetSideLblFontSize,pos={51,65},size={122,19},bodyWidth=60,title="Font Size:",limits={1,inf,1}
		SetVariable ModifyTernarySetSideLblFontSize,fSize=12,value= _NUM:18,proc=ModifyTernaryActionSetvarProc, live=1

		PopupMenu ModifyTernarySideLblFontStyle,pos={115,91},size={90,23},bodyWidth=87,title="Font Style"
		PopupMenu ModifyTernarySideLblFontStyle,fSize=12
		PopupMenu ModifyTernarySideLblFontStyle,mode=1,value= #"\"Plain;Bold;Italic;Underline;Strikethrough;\"", proc=FontStyleMenuAction

		PopupMenu ModifyTernarySideLblColorMenu,pos={77,119},size={86,20},title="Color:"
		PopupMenu ModifyTernarySideLblColorMenu,fSize=12
		PopupMenu ModifyTernarySideLblColorMenu,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\"", proc=ModifyTernaryActionPopupProc

		GroupBox TernaryLeftSideLabelGroup,pos={32,142},size={200,107},title="Left"
		GroupBox TernaryLeftSideLabelGroup,fSize=12

		SetVariable TernaryLeftSideLabelText,pos={68,167},size={120,19},bodyWidth=120
		SetVariable TernaryLeftSideLabelText,fSize=12,value= _STR:"",proc=ModifyTernaryActionSetvarProc

		SetVariable TernarySideLblLeftYOffset,pos={52,222},size={153,19},bodyWidth=60,title="Vertical Offset:"
		SetVariable TernarySideLblLeftYOffset,fSize=12,value= _NUM:30,proc=ModifyTernaryActionSetvarProc, live=1

		SetVariable TernarySideLblLeftXOffset,pos={45,194},size={167,19},bodyWidth=60,title="Horizontal Offset:"
		SetVariable TernarySideLblLeftXOffset,fSize=12,value= _NUM:0,proc=ModifyTernaryActionSetvarProc, live=1

		GroupBox TernaryRightSideLabelGroup,pos={32,258},size={200,107},title="Right"
		GroupBox TernaryRightSideLabelGroup,fSize=12

		SetVariable TernaryRightSideLabelText,pos={68,283},size={120,19},bodyWidth=120
		SetVariable TernaryRightSideLabelText,fSize=12,value= _STR:"",proc=ModifyTernaryActionSetvarProc

		SetVariable TernarySideLblRightYOffset,pos={52,338},size={153,19},bodyWidth=60,title="Vertical Offset:"
		SetVariable TernarySideLblRightYOffset,fSize=12,value= _NUM:30,proc=ModifyTernaryActionSetvarProc, live=1

		SetVariable TernarySideLblRightXOffset,pos={45,310},size={167,19},bodyWidth=60,title="Horizontal Offset:"
		SetVariable TernarySideLblRightXOffset,fSize=12,value= _NUM:0,proc=ModifyTernaryActionSetvarProc, live=1

		GroupBox TernaryBottomSideLabelGroup,pos={32,373},size={200,107},title="Bottom"
		GroupBox TernaryBottomSideLabelGroup,fSize=12

		SetVariable TernaryBottomSideLabelText,pos={68,398},size={120,19},bodyWidth=120
		SetVariable TernaryBottomSideLabelText,fSize=12,value= _STR:"",proc=ModifyTernaryActionSetvarProc

		SetVariable TernarySideLblBottomYOffset,pos={52,453},size={153,19},bodyWidth=60,title="Vertical Offset:"
		SetVariable TernarySideLblBottomYOffset,fSize=12,value= _NUM:30,proc=ModifyTernaryActionSetvarProc, live=1

		SetVariable TernarySideLblBottomXOffset,pos={45,425},size={167,19},bodyWidth=60,title="Horizontal Offset:"
		SetVariable TernarySideLblBottomXOffset,fSize=12,value= _NUM:0,proc=ModifyTernaryActionSetvarProc, live=1

		STRUCT TernaryGraphAxisLabelProperties axisLabelStruct
		if (GetTernaryAxisLabelStructure(gname, axisLabelStruct, "Left") == 0)
			CheckBox TernaryGraphSideLblsCheck,value= 1
			popMode = WhichListItem(axisLabelStruct.font, FontList(";", 1))+3
			if (popMode < 3)
				popMode = 1
			endif
			PopupMenu ModifyTernarySideLabelFontMen,mode=popMode
			SetVariable ModifyTernarySetSideLblFontSize,value= _NUM:axisLabelStruct.fontSize
			PopupMenu ModifyTernarySideLblFontStyle,mode=0
			SetFontStylePopValue(panelName+"#ModifyTernarySideLabelsSubpanel", "ModifyTernarySideLblFontStyle", axisLabelStruct.fontStyle)
			PopupMenu ModifyTernarySideLblColorMenu,mode=1,popColor= (axisLabelStruct.labelColor.red, axisLabelStruct.labelColor.green, axisLabelStruct.labelColor.blue)
			SetVariable TernaryLeftSideLabelText,value=_STR:axisLabelStruct.text
			SetVariable TernarySideLblLeftYOffset,value= _NUM:axisLabelStruct.labelOffset
			SetVariable TernarySideLblLeftXOffset,value= _NUM:axisLabelStruct.labelLatOffset
			if (GetTernaryAxisLabelStructure(gname, axisLabelStruct, "Right") == 0)
				SetVariable TernaryRightSideLabelText,value=_STR:axisLabelStruct.text
				SetVariable TernarySideLblRightYOffset,value= _NUM:axisLabelStruct.labelOffset
				SetVariable TernarySideLblRightXOffset,value= _NUM:axisLabelStruct.labelLatOffset
			endif
			if (GetTernaryAxisLabelStructure(gname, axisLabelStruct, "Bottom") == 0)
				SetVariable TernaryBottomSideLabelText,value=_STR:axisLabelStruct.text
				SetVariable TernarySideLblBottomYOffset,value= _NUM:axisLabelStruct.labelOffset
				SetVariable TernarySideLblBottomXOffset,value= _NUM:axisLabelStruct.labelLatOffset
			endif
		else
			tname = StringFromList(0, TraceNameList(gname, ";", 1))
			if (strlen(tname) == 0)
				tname = StringFromList(0, ContourNameList(gname, ";"))
				if (strlen(tname) == 0)
					return 0
				else
					Wave w = ContourNameToWaveRef(gname, tname)
				endif
			else
				Wave w = TraceNameToWaveRef(gname, tname)
			endif
			theNote = Note(w)
			dataName = StringByKey("waveA", theNote, "=", "\r")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			SetVariable TernaryLeftSideLabelText,value=_STR:dataName
			
			dataName = StringByKey("waveB", theNote, "=", "\r")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			SetVariable TernaryBottomSideLabelText,value=_STR:dataName
			
			dataName = StringByKey("waveC", theNote, "=", "\r")
			dataName = ParseFilePath(0, dataName, ":", 1, 0)
			SetVariable TernaryRightSideLabelText,value=_STR:dataName
			
			CheckBox TernaryGraphSideLblsCheck,value= 0
		endif
	SetActiveSubwindow ##
	
	ModifyTernarySetTab(panelName, 0)
end

Function ModifyTernarySetTab(panelName, tabnumber)
	String panelName
	Variable tabnumber
	
	String leafName = ParseFilePath(0, panelName, "#", 1, 0)
	strswitch(leafName)
		case "ModifyTernaryLinesPanel":
			SetWindow $(panelName+"#ModifyTernaryAxisSubpanel") hide= tabnumber!=0
			SetWindow $(panelName+"#ModifyTernaryTicksSubpanel") hide= tabnumber!=1
			SetWindow $(panelName+"#ModifyTernaryGridSubpanel") hide= tabnumber!=2
			break;
		case "ModifyTernaryLabelsPanel":
			SetWindow $(panelName+"#ModifyTernaryTickLabelsSubpanel") hide= tabnumber!=0
			SetWindow $(panelName+"#ModifyTernaryCornerLblsSubpanel") hide= tabnumber!=1
			SetWindow $(panelName+"#ModifyTernarySideLabelsSubpanel") hide= tabnumber!=2
			break;
	endswitch
end

Function ModifyTernaryGraphTabProc(s)
	STRUCT WMTabControlAction &s
	
	if (s.eventCode == 2)
		ModifyTernarySetTab(s.win, s.tab)
	endif
end

Function ModifyTernaryActionCheckProc(s) : CheckBoxControl
	STRUCT WMCheckboxAction &s

	switch( s.eventCode )
		case 2: // mouse up
			String panelName = ParseFilePath(0, s.win, "#", 0, 0)
			panelName += "#"+ParseFilePath(0, s.win, "#", 0, 1)
			ApplyModifyTernaryChange(panelName)
			break
	endswitch

	return 0
End

Function ModifyTernaryActionPopupProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s

	switch( s.eventCode )
		case 1: // mouse up
		case 2: // enter key
		case 3: // live update
			String panelName = ParseFilePath(0, s.win, "#", 0, 0)
			panelName += "#"+ParseFilePath(0, s.win, "#", 0, 1)
			ApplyModifyTernaryChange(panelName)
			break
	endswitch

	return 0
End

Function ModifyTernaryActionSetvarProc(s) : SetVariableControl
	STRUCT WMSetVariableAction &s

	switch( s.eventCode )
		case 1: // mouse up
		case 2: // mouse up
		case 3: // mouse up
			String panelName = ParseFilePath(0, s.win, "#", 0, 0)
			panelName += "#"+ParseFilePath(0, s.win, "#", 0, 1)
			ApplyModifyTernaryChange(panelName)
			break
	endswitch

	return 0
End

Function ModifyTernaryApplyAxisTab(gname, panelName)
	String gname, panelName
	
	ControlInfo/W=$(panelName+"#ModifyTernaryAxisSubpanel") TernaryGraphAxisColorMenu
	Variable red = V_red
	Variable green = V_green
	Variable blue = V_blue
	ControlInfo/W=$(panelName+"#ModifyTernaryAxisSubpanel") TernaryGraphSetAxisThickness
	Variable thickness = V_value
	
	DrawTernaryAxes(gname, thickness, red, green, blue)
end

Function ModifyTernaryApplyTicksTab(gname, panelName)
	String gname, panelName
	
	ControlInfo/W=$(panelName+"#ModifyTernaryTicksSubpanel") TernaryGraphShowTicksCheck
	if (V_value)
		ControlInfo/W=$(panelName+"#ModifyTernaryTicksSubpanel") TernaryGraphTickColorMenu
		Variable red = V_red
		Variable green = V_green
		Variable blue = V_blue
		ControlInfo/W=$(panelName+"#ModifyTernaryTicksSubpanel") TernaryGraphSetTickThickness
		Variable thickness = V_value
		ControlInfo/W=$(panelName+"#ModifyTernaryTicksSubpanel") TernaryGraphSetTickLength
		Variable length = V_value
		ControlInfo/W=$(panelName+"#ModifyTernaryTicksSubpanel") TernaryGraphInsideTicksCheck
		Variable inside = V_value
		ControlInfo/W=$(panelName+"#ModifyTernaryTicksSubpanel") ModifyTernaryTickIncrement
		Variable increment = MenuToTickIncrement(V_value)
		DrawTernaryGraphTicks(gname, increment, Red, Green, Blue, thickness, length, inside)
	else
		RemoveTernaryGraphTicks(gname)
	endif
end

Function ModifyTernaryApplyTickLabelTab(gname, panelName)
	String gname, panelName
	
	ControlInfo/W=$(panelName+"#ModifyTernaryTickLabelsSubpanel") TernaryGraphTickLabelsCheck
	if (V_value)
		ControlInfo/W=$(panelName+"#ModifyTernaryTickLabelsSubpanel") ModifyTernaryTickLabelFontMenu
		String font = S_value
		if (CmpStr(font, "default") == 0)
			font = ""
		endif
		ControlInfo/W=$(panelName+"#ModifyTernaryTickLabelsSubpanel") ModifyTernarySetFontSize
		Variable fontSize = V_value
		Variable fontStyle = Str2Num(GetUserData(panelName+"#ModifyTernaryTickLabelsSubpanel", "ModifyTernaryTickFontStyle", "CurrentStyles"))
		ControlInfo/W=$(panelName+"#ModifyTernaryTickLabelsSubpanel") ModifyTernaryTickLColorMenu
		Variable red = V_red
		Variable green = V_green
		Variable blue = V_blue
		ControlInfo/W=$(panelName+"#ModifyTernaryTickLabelsSubpanel") ModifyTernaryTickLabelIncrement
		Variable increment = MenuToTickIncrement(V_value)
		ControlInfo/W=$(panelName+"#ModifyTernaryTickLabelsSubpanel") ModifyTernarySetTickLabelOffset
		Variable offset = V_value
		ControlInfo/W=$(panelName+"#ModifyTernaryTickLabelsSubpanel") ModifyTernaryTickMultiplier
		Variable multiplier= V_value
		ControlInfo/W=$(panelName+"#ModifyTernaryTickLabelsSubpanel") ModifyTernaryTickLabelUnits
		String unitslabel = S_value
		ControlInfo/W=$(panelName+"#ModifyTernaryTickLabelsSubpanel") ModifyTernaryTickLabelFormat
		String tickformat = S_value
		DrawTernaryGraphTickLabels(gname, increment, red, green, blue, font, fontsize, fontstyle, offset, "Bottom", multiplier=multiplier, unitslabel=unitslabel, tickformat=tickformat)
		DrawTernaryGraphTickLabels(gname, increment, red, green, blue, font, fontsize, fontstyle, offset, "Left", multiplier=multiplier, unitslabel=unitslabel, tickformat=tickformat)
		DrawTernaryGraphTickLabels(gname, increment, red, green, blue, font, fontsize, fontstyle, offset, "Right", multiplier=multiplier, unitslabel=unitslabel, tickformat=tickformat)
	else
		RemoveAllTernaryTickLabels(gname)
	endif
end

Function ModifyTernaryApplyGridTab(gname, panelName)
	String gname, panelName
	
	ControlInfo/W=$(panelName+"#ModifyTernaryGridSubpanel") TernaryGraphGridCheck
	if (V_value)
		ControlInfo/W=$(panelName+"#ModifyTernaryGridSubpanel") ModifyTernaryGridIncrement
		Variable increment = MenuToTickIncrement(V_value)
		ControlInfo/W=$(panelName+"#ModifyTernaryGridSubpanel") TernaryGraphGridColorMenu
		Variable gridred = V_red
		Variable gridgreen = V_green
		Variable gridblue = V_blue
		ControlInfo/W=$(panelName+"#ModifyTernaryGridSubpanel") TernaryGraphSetGridThickness
		Variable gridthick = V_value
		ControlInfo/W=$(panelName+"#ModifyTernaryGridSubpanel") TernaryGraphSetGridDash
		Variable griddash = V_value-1
		
		DrawTernaryGraphGrid(gname, increment, gridRed, gridGreen, gridBlue, gridThick, gridDash)
	else
		RemoveTernaryGraphGrid(gname)
	endif
end

Function ModifyTernaryApplyCornerLblsTab(gname, panelName)
	String gname, panelName
	
	ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") TernaryGraphCornerLblsCheck
	if (V_value)
		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") ModifyTernaryCornerLblFontMenu
		String font = S_value
		if (CmpStr(font, "default") == 0)
			font = ""
		endif
		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") ModifyTernaryCornerLSetFontSize
		Variable fontSize = V_value
		Variable fontStyle = Str2Num(GetUserData(panelName+"#ModifyTernaryCornerLblsSubpanel", "ModifyTernaryCornerLblFontStyle", "CurrentStyles"))
		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") ModifyTernaryCornerLblColorMenu
		Variable red = V_red
		Variable green = V_green
		Variable blue = V_blue
		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") TernaryLeftCornerLabelText
		String labelText = S_value
		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") ModifyTernarySetCrnrLYLabelOffs
		Variable labelOffset = V_value
		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") ModifyTernarySetCrnrLXLabelOffs
		Variable labelLatOffset = V_value
		if (strlen(labelText) > 0)
			DrawTernaryGraphCornerLabels(gname, labelText, red, green, blue, font, fontsize, fontstyle, labelOffset, labelLatOffset, "Left")
		endif

		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") TernaryRightCornerLabelText
		labelText = S_value
		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") ModifyTernarySetCrnrRYLabelOffs
		labelOffset = V_value
		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") ModifyTernarySetCrnrRXLabelOffs
		labelLatOffset = V_value
		if (strlen(labelText) > 0)
			DrawTernaryGraphCornerLabels(gname, labelText, red, green, blue, font, fontsize, fontstyle, labelOffset, labelLatOffset, "Right")
		endif

		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") TernaryTopCornerLabelText
		labelText = S_value
		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") ModifyTernarySetCrnrTYLabelOffs
		labelOffset = V_value
		ControlInfo/W=$(panelName+"#ModifyTernaryCornerLblsSubpanel") ModifyTernarySetCrnrTXLabelOffs
		labelLatOffset = V_value
		if (strlen(labelText) > 0)
			DrawTernaryGraphCornerLabels(gname, labelText, red, green, blue, font, fontsize, fontstyle, labelOffset, labelLatOffset, "Top")
		endif
	else
		RemoveAllTernaryCornerLabels(gname)
	endif
end

Function ModifyTernaryApplySideLblsTab(gname, panelName)
	String gname, panelName
	
	ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") TernaryGraphSideLblsCheck
	if (V_value)
		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") ModifyTernarySideLabelFontMen
		String font = S_value
		if (CmpStr(font, "default") == 0)
			font = ""
		endif
		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") ModifyTernarySetSideLblFontSize
		Variable fontSize = V_value
		Variable fontStyle = Str2Num(GetUserData(panelName+"#ModifyTernarySideLabelsSubpanel", "ModifyTernarySideLblFontStyle", "CurrentStyles"))
		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") ModifyTernarySideLblColorMenu
		Variable red = V_red
		Variable green = V_green
		Variable blue = V_blue
		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") TernaryLeftSideLabelText
		String labelText = S_value
		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") TernarySideLblLeftYOffset
		Variable labelOffset = V_value
		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") TernarySideLblLeftXOffset
		Variable labelLatOffset = V_value
		if (strlen(labelText) > 0)
			DrawTernaryGraphAxisLabels(gname, labelText, red, green, blue, font, fontsize, fontstyle, labelOffset, labelLatOffset, "Left")
		endif

		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") TernaryRightSideLabelText
		labelText = S_value
		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") TernarySideLblRightYOffset
		labelOffset = V_value
		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") TernarySideLblRightXOffset
		labelLatOffset = V_value
		if (strlen(labelText) > 0)
			DrawTernaryGraphAxisLabels(gname, labelText, red, green, blue, font, fontsize, fontstyle, labelOffset, labelLatOffset, "Right")
		endif

		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") TernaryBottomSideLabelText
		labelText = S_value
		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") TernarySideLblBottomYOffset
		labelOffset = V_value
		ControlInfo/W=$(panelName+"#ModifyTernarySideLabelsSubpanel") TernarySideLblBottomXOffset
		labelLatOffset = V_value
		if (strlen(labelText) > 0)
			DrawTernaryGraphAxisLabels(gname, labelText, red, green, blue, font, fontsize, fontstyle, labelOffset, labelLatOffset, "Bottom")
		endif
	else
		RemoveAllTernaryAxisLabels(gname)
	endif
end
	
Function ModifyTernaryApplyThisTabProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if (ba.eventCode != 2)
		return 0
	endif
	
	ControlInfo/W=$(ba.win) ModifyTernaryTabControl
	Variable tabNumber = V_value
	String gname = GetUserData(ba.win, "", "ModifyTernaryHostGraph")
	
	String leafName = ParseFilePath(0, ba.win, "#", 1, 0)
	strswitch(leafName)
		case "ModifyTernaryLinesPanel":
			switch (tabNumber)
				case 0:
					ModifyTernaryApplyAxisTab(gname, ba.win)
					break;
				case 1:
					ModifyTernaryApplyTicksTab(gname, ba.win)
					break;
				case 2:
					ModifyTernaryApplyGridTab(gname, ba.win)
					break;
			endswitch
			break;
		case "ModifyTernaryLabelsPanel":
			switch (tabNumber)
				case 0:
					ModifyTernaryApplyTickLabelTab(gname, ba.win)
					break;
				case 1:
					ModifyTernaryApplyCornerLblsTab(gname, ba.win)
					break;
				case 2:
					ModifyTernaryApplySideLblsTab(gname, ba.win)
					break;
			endswitch
			break;
	endswitch

	return 0
End

Function ApplyModifyTernaryChange(panelName)
	String panelName
	
	ControlInfo/W=$(panelName) ModifyTernaryTabControl
	Variable tabNumber = V_value
	String gname = GetUserData(panelName, "", "ModifyTernaryHostGraph")
	
	String leafName = ParseFilePath(0, panelName, "#", 1, 0)
	strswitch(leafName)
		case "ModifyTernaryLinesPanel":
			switch (tabNumber)
				case 0:
					ModifyTernaryApplyAxisTab(gname, panelName)
					break;
				case 1:
					ModifyTernaryApplyTicksTab(gname, panelName)
					break;
				case 2:
					ModifyTernaryApplyGridTab(gname, panelName)
					break;
			endswitch
			break;
		case "ModifyTernaryLabelsPanel":
			switch (tabNumber)
				case 0:
					ModifyTernaryApplyTickLabelTab(gname, panelName)
					break;
				case 1:
					ModifyTernaryApplyCornerLblsTab(gname, panelName)
					break;
				case 2:
					ModifyTernaryApplySideLblsTab(gname, panelName)
					break;
			endswitch
			break;
	endswitch

	return 0
end

Function ModifyTernaryApplyAllTabsProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String gname = GetUserData(ba.win, "", "ModifyTernaryHostGraph")
			ModifyTernaryApplyAxisTab(gname, ba.win)
			ModifyTernaryApplyTicksTab(gname, ba.win)
			ModifyTernaryApplyTickLabelTab(gname, ba.win)
			ModifyTernaryApplyGridTab(gname, ba.win)
			ModifyTernaryApplyCornerLblsTab(gname, ba.win)
			ModifyTernaryApplySideLblsTab(gname, ba.win)
			break
	endswitch

	return 0
End

Function ModifyTernaryDoneButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			KillWindow $ba.win
			break
	endswitch

	return 0
End

Function HelpButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			DisplayHelpTopic "Ternary Diagrams"
			break
	endswitch

	return 0
End