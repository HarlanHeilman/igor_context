#pragma rtGlobals=3		// Use modern global access method.
#pragma version=1.03		// shipped with Igor 7, compatible with Igor 6
#pragma IgorVersion=6.20	// because of rtGlobals=3
#pragma ModuleName=WM_FunctionGrapher

#include <SaveRestoreWindowCoords>

//**********************************************************
//	Graph Function package v. 1.00
//	
//	Control panel with embedded graph to make it easy to visualize a mathematical expression
//	
//**********************************************************

//**********************************************************
//	To Do (not necessarily in order of priority)
//
//	1)	Support functions of two independent variables.	
//	2)	Add divider to re-allocate panel space between coefficient list and graph.
//	3)	Log axis option
//	4)	Handle complex functions in a nice way
//	5)	Igor Exchange member "tutor" says:
//		I use lately the Igor panel called FunctionGrapher. I only have one question: 
//		is there an easy way to modify this macro in such a way that the coefficient 
//		values are are changed "via" a slider or a Set Value button (the one with two 
//		arrows up/down)? This means when one needs 4,5 or 6 parameters one gets 
//		4,5, or 6 sliders/buttons. 
//
//	??)	Add button: "Make Stand-alone Graph"	???	To do it conveniently, I need a WinRecreation that can do a sub-window.
//**********************************************************

//**********************************************************
// Change History
//
//	Version 1.0
//		First Release
//	Version 1.01
//		Fixed bug- when first starting up with nothing in the Function Grapher's preferences folder, and no suitable functions in the current experiment,
//			displaying the Function Grapher main graph window caused it to try to #include the folder, causing a compile error.
//	Version 1.02
//		Fixed bug- using "w" as the name of a parameter caused a compile error due to conflict with "w" as the name of the parameter wave in the generated function.
//			The wave parameter is now called "FG_ParamWave", which is unlikely to conflict with a user's choice of parameter name.
//	Version 1.03
//		PanelResolution for compatibility with Igor 7.
//**********************************************************

Menu "Analysis"
	SubMenu "Function Grapher"
		"Show Function Grapher",/Q, fGraphFunctionGraph()
		"Function Grapher Help",/Q, DisplayHelpTopic/K=1 "Function Grapher"
		"Unload Function Grapher Package",/Q,FG_UnloadPackage()
	end
end

static StrConstant FG_SpecialSecondLine = "// This file belongs to Igor Function Grapher"

// sizes in "Panel Units"
static constant CListWidthDif = 31
static constant CListHeightDif = 94
static constant CListGrpWidthDif = 7
static constant CListGrpHeightDif = 10
static constant FG_MainPanelMinWidth = 455
static constant FG_MainPanelMinHeight = 463
static constant FB_ControlBarToHeight3 = 107		// The control bar is positioned this many panel units below 1/3 of the graph window height

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

static Function FG_InitGlobals()

	String saveDF = GetDataFolder(1)
	SetDatafolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_GraphFunction
	
	NVAR/Z StartX
	if (!NVAR_Exists(StartX))
		Variable/G StartX = -1
	endif
	NVAR/Z EndX
	if (!NVAR_Exists(EndX))
		Variable/G EndX = 1
	endif
	NVAR/Z nPnts
	if (!NVAR_Exists(nPnts))
		Variable/G nPnts = 201
	endif
	NVAR/Z FG_numCoefs
	if (!NVAR_Exists(FG_numCoefs))
		Variable/G FG_numCoefs = 1
	endif
	SVAR/Z FG_FuncName
	Variable nCoefs = -1
	if (SVAR_Exists(FG_FuncName))
		if (FG_IsOneOfOurs(FG_FuncName))
			String coefList
			nCoefs = GetNumCoefsAndNamesFromFunction(FG_FuncName, coefList)
		else
			nCoefs = FG_numCoefs
		endif
	endif
	String/G FG_ExpressionText = ""
	Make/O/D/N=(nPnts) FuncWave
	SetScale/I x StartX, EndX, FuncWave
	Wave/Z cList = CoefListContents
	if (!WaveExists(cList) || (DimSize(cList, 0) != nCoefs))
		Make/O/D/N=(FG_numCoefs,2)/T CoefListContents = {{"w[0]"},{"0.0"}}
	endif
	Make/O/D/N=(FG_numCoefs,2) CoefListSelection
	CoefListSelection[][0] = 0
	CoefListSelection[][1] = 2
	SetDimLabel 1,0,Coefficient,CoefListContents
	SetDimLabel 1,1,Value,CoefListContents
	
	// Make list of files that shouldn't contribute functions to the list of functions in the function menu
	Make/O/T/N=4 ListOfFiles
	ListOfFiles[0] = FunctionPath("FG_FuncMenuList")
	PathInfo Igor
	String IgorPath = S_path
	ListOfFiles[1] = IgorPath+"Igor Procedures:WMMenus.ipf"
	ListOfFiles[2] = IgorPath+"Igor Procedures:DemoLoader.ipf"
	ListOfFiles[3] = FunctionPath("WC_WindowCoordinatesSprintf")
	
	SetDataFolder $saveDF
end

Function fGraphFunctionGraph()

	DoWindow/F GraphFunctionGraph
	if (V_Flag)
		return 0
	endif
	
	FG_InitGlobals()

	// Scale graph size to accomodate size of the controls in the subwindows.
	Variable PanelUnitsToPoints = PanelResolution("")/ScreenResolution
	Variable defLeft = 50*PanelUnitsToPoints
	Variable defTop =  83*PanelUnitsToPoints
	Variable defRight = defLeft + FG_MainPanelMinWidth*PanelUnitsToPoints
	Variable defBottom = defTop + FG_MainPanelMinHeight*PanelUnitsToPoints

	String fmt= "Display/K=1/N=GraphFunctionGraph/W=(%s) as \"Function Grapher\""
	String cmd= WC_WindowCoordinatesSprintf("GraphFunctionGraph", fmt, defLeft, defTop, defRight, defBottom, 0)	// points
	Execute cmd

	Wave w = root:Packages:WM_GraphFunction:FuncWave
	AppendToGraph w
	ControlBar 261	// panel units

	NewPanel/W=(0.2,0.2,0.8,0.8)/FG=(FL,FT,GR,GT)/HOST=GraphFunctionGraph/N=GraphFunctionPanel
		ModifyPanel frameStyle=0
		GroupBox FG_FuncGroup,pos={7,8},size={200,180},title="Function"
		PopupMenu FuncDisp_FuncMenu,pos={13,27},size={183,20},proc=FG_FuncMenuProc,title=" "
		PopupMenu FuncDisp_FuncMenu,mode=1,bodyWidth= 177,popvalue="_NONE_",value= #"FG_FuncMenuList()"
		Button FuncDisp_NewFunctionButton,pos={47,62},size={120,20},proc=FG_NewFunctionButtonProc,title="New Function..."
		Button FuncDisp_NewFunctionButton,help={"Click to enter information to create a new function."}
		Button FuncDisp_EditFunctionButton,pos={47,86},size={120,20},proc=FG_NewFunctionButtonProc,title="Edit Function..."
		Button FuncDisp_EditFunctionButton,help={"Click to change the definition of the currently selected function.\r\rAvailable only for functions that belong to Function Grapher"}
		Button FuncDisp_SaveFunctionButton,pos={47,111},size={120,20},proc=FG_SaveFunctionButtonProc,title="Save Function..."
		Button FuncDisp_SaveFunctionButton,help={"Allows you to save the definition of the function to your hard disk in a location of your choosing.\r\rAvailable only for functions that belong to Function Grapher"}
		Button FuncDisp_ShowFunctionButton,pos={47,159},size={120,20},proc=FG_ShowCodeButtonProc,title="Show Code"
		Button FuncDisp_ShowFunctionButton,help={"Click to see the user-defined function code.\r\rAvailable only for user-defined functions."}
		Button FuncDisp_KillFunctionButton,pos={47,135},size={120,20},proc=FG_KillFunctionButtonProc,title="Kill Function..."
		Button FuncDisp_KillFunctionButton,help={"Unloads the function's procedure file and deletes the file from the hard drive.\r\rAvailable only for functions that belong to Function Grapher"}
	
		DefineGuide UGV1={FR,-6}
		DefineGuide UGV2={FL,210}
		DefineGuide UGH0={FB,-71}
		DefineGuide UGH1={UGH0,8}
	
		NewPanel/W=(210,8,451,204)/FG=(,FT,UGV1,UGH0)/HOST=GraphFunctionGraph#GraphFunctionPanel/N=FG_CListSubPanel
			ModifyPanel frameStyle=0
			GroupBox FG_CoefsGroup,pos={8,8},size={217,180},title="Coefficients"
			ListBox FuncDisp_CoefListBox,pos={18,26},size={193,96},proc=FG_CoefListBoxProc
			ListBox FuncDisp_CoefListBox,help={"Edit values of the function's coefficients here. Function Grapher functions have mnemonic coefficient names in the first column."}
			ListBox FuncDisp_CoefListBox,listWave=root:Packages:WM_GraphFunction:CoefListContents
			ListBox FuncDisp_CoefListBox,selWave=root:Packages:WM_GraphFunction:CoefListSelection
			ListBox FuncDisp_CoefListBox,mode= 6
	
			DefineGuide UGV0={FL,14}
			DefineGuide UGV1={UGV0,220}
			DefineGuide UGH0={FB,-7}
			DefineGuide UGH1={UGH0,-56}
	
			NewPanel/W=(56,47,168,170)/FG=(UGV0,UGH1,UGV1,UGH0)/HOST=GraphFunctionGraph#GraphFunctionPanel#FG_CListSubPanel/N=FG_CListOtherControlsPanel
				ModifyPanel frameStyle=0
				TitleBox FG_NCoefsTitle,pos={1,12},size={39,12},title="# Coefs:"
				TitleBox FG_NCoefsTitle,help={"The function is one that does not belong to Function Grapher, so Function Grapher doesn't know how many coefficients it requires."}
				TitleBox FG_NCoefsTitle,frame=0
				SetVariable FG_SetNumCoefs,pos={3,26},size={43,15},proc=FG_SetNumCoefsProc,title=" "
				SetVariable FG_SetNumCoefs,help={"The function is one that does not belong to Function Grapher, so Function Grapher doesn't know how many coefficients it requires."}
				SetVariable FG_SetNumCoefs,limits={0,Inf,1},value= root:Packages:WM_GraphFunction:FG_numCoefs,bodyWidth= 43
				Button FG_LoadCoefsFromWave,pos={53,7},size={164,20},proc=FG_LoadCoefsFromWave,title="Load Coefs From Wave..."
				Button FG_LoadCoefsFromWave,help={"Click here to load coefficient values from a wave into the list."}
				Button FG_SaveCoefsToWave,pos={53,32},size={164,20},proc=FG_SaveCoefsToWave,title="Save Coefs to Wave..."
				Button FG_SaveCoefsToWave,help={"Click here to save coefficient values from the list into a wave."}
			
	SetActiveSubwindow GraphFunctionGraph#GraphFunctionPanel
	
	NewPanel/W=(0,220,451,242)/FG=(,UGH1,FR,FB)/HOST=GraphFunctionGraph#GraphFunctionPanel/N=GraphControlSubPanel
		ModifyPanel frameStyle=0
		TitleBox FG_ExpressionTitle,pos={74,7},size={123,20}
		TitleBox FG_ExpressionTitle,help={"Function Grapher functions: shows the expression defined by the function.\r\rOther functions: just shows the function name."}
		TitleBox FG_ExpressionTitle,frame=2
		TitleBox FG_ExpressionTitle,variable= root:Packages:WM_GraphFunction:FG_ExpressionText
		TitleBox FG_ExpressionTitleTitle,pos={11,11},size={53,12},title="Expression:"
		TitleBox FG_ExpressionTitleTitle,frame=0
		SetVariable FuncDisp_SetStartX,pos={10,36},size={114,15},proc=FG_SetXProc,title="Starting X:"
		SetVariable FuncDisp_SetStartX,value= root:Packages:WM_GraphFunction:StartX,bodyWidth= 60
		SetVariable FuncDisp_EndX,pos={143,36},size={105,15},proc=FG_SetXProc,title="Ending X:"
		SetVariable FuncDisp_EndX,value= root:Packages:WM_GraphFunction:EndX,bodyWidth= 60
		SetVariable FuncDisp_nPnts,pos={272,36},size={96,15},proc=FG_SetXProc,title="Points:"
		SetVariable FuncDisp_nPnts,value= root:Packages:WM_GraphFunction:nPnts,bodyWidth= 60
		Button FG_HelpButton,pos={390,34},size={50,20},proc=FG_HelpButtonProc,title="Help"

	SetActiveSubwindow GraphFunctionGraph#GraphFunctionPanel	
	
	FG_SetCoefListBoxSize()
	
	SetWindow GraphFunctionGraph, hook(FG_KillWinHook)=FG_GraphFunctionGraphHook
	SetWindow GraphFunctionGraph, hook = WC_WindowCoordinatesHook
	
	SVAR/Z funcName = root:Packages:WM_GraphFunction:FG_FuncName
	String theFunction = ""
	if (SVAR_Exists(funcName))
		theFunction = funcName
	endif
	Variable theItem = WhichListItem(theFunction, FG_FuncMenuList())+1
	if ( (theItem < 1) || (strlen(theFunction) == 0) )
		theFunction = "_NONE_"
	else
		PopupMenu FuncDisp_FuncMenu, win=GraphFunctionGraph#GraphFunctionPanel, mode = theItem
	endif
	FG_FuncMenuProc("FuncDisp_FuncMenu", 0, theFunction)
end

// PanelCoordEdges is a panel-coordinate replacement for GetWindow wsizeDC.
// NOTE: using GetWindow wsize or wsizeDC based on PanelResolution(win) == 72
// will not work for a subwindow, because GetWindow Panel0#subwindow wsize
// will instead actually return GetWindow Panel0#subwindow wsizeDC.
//
// PanelCoordEdges works with Graph windows, too, but we don't recommend
// putting controls in graphs; put the controls in a panel subwindow within graphs.
// a control with these corner coordinates will fill the entire (sub)window.

Static Function PanelCoordEdges(win, vleft, vtop, vright, vbottom)
	String win	// can be "Panel0#P1", for example
	Variable &vleft, &vtop, &vright, &vbottom	// outputs, host window's left,top is 0,0

	vleft= NumberByKey("POSITION",GuideInfo(win,"FL"))
	vtop= NumberByKey("POSITION",GuideInfo(win,"FT"))
	vright= NumberByKey("POSITION",GuideInfo(win,"FR"))
	vbottom= NumberByKey("POSITION",GuideInfo(win,"FB"))
End

static Function FG_GetCoefListSubPanelSize(width, height)
	Variable &width, &height

	Variable vleft, vtop, vright, vbottom
	PanelCoordEdges("GraphFunctionGraph#GraphFunctionPanel#FG_CListSubPanel", vleft, vtop, vright, vbottom)
	width = vright - vleft
	height = vbottom - vtop
end

static Function FG_SetCoefListBoxSize()

	Variable swwidth, swheight
	
	FG_GetCoefListSubPanelSize(swwidth, swheight)
	Variable width= max(8, swwidth-CListWidthDif)
	Variable height= max(8, swheight-CListHeightDif)
	ListBox FuncDisp_CoefListBox, win=GraphFunctionGraph#GraphFunctionPanel#FG_CListSubPanel, size = {width, height}
	
	width= max(10, swwidth-CListGrpWidthDif)
	height= max(10, swheight-CListGrpHeightDif)
	GroupBox FG_CoefsGroup, win=GraphFunctionGraph#GraphFunctionPanel#FG_CListSubPanel, size = {width, height}
end

static Function FG_SetControlBarPosition()

	GetWindow GraphFunctionGraph, wsize	// points
	Variable heightPoints= V_bottom - V_top
	Variable winHeightPanelUnits = heightPoints * ScreenResolution/PanelResolution("GraphFunctionGraph")
	ControlBar/W=GraphFunctionGraph winHeightPanelUnits/3 + FB_ControlBarToHeight3
end

static Function FG_MainPanelMinWindowSize()

	GetWindow GraphFunctionGraph, wsize	// points
	Variable minimized= (V_right == V_left) && (V_bottom==V_top)
	if( minimized )
		return 0
	endif
	
	Variable width= V_right - V_left
	Variable height= V_bottom - V_top
	Variable PanelUnitsToPoints= PanelResolution("GraphFunctionGraph")/ScreenResolution
	Variable minWidthPoints= FG_MainPanelMinWidth*PanelUnitsToPoints
	Variable minHeightPoints= FG_MainPanelMinHeight*PanelUnitsToPoints
#if IgorVersion() >= 7
	SetWindow GraphFunctionGraph sizeLimit={minWidthPoints, minHeightPoints, Inf, Inf}
#else
	Variable newWidth= max(width,minWidthPoints)
	Variable newHeight= max(height,minHeightPoints)
	if (newwidth != width || newheight != height)
		// Turns out that on Windows, if the window is maximized MoveWindow puts the window into a weird state that
		// you can't get out of. So here we do this only if we need to override the minimum size.
		MoveWindow/W=GraphFunctionGraph V_left, V_top, V_left+newWidth, V_top+newHeight
	endif
#endif
	return 1
End

Function FG_GraphFunctionGraphHook(H_Struct)
	STRUCT WMWinHookStruct &H_Struct
	
	Variable statusCode = 0

if (H_Struct.eventCode == 4)
	return 0
endif
//print "event code: ", H_Struct.eventCode, "; Window: ", H_Struct.winName
	
	switch (H_Struct.eventCode)
		case 2:			// kill
			if (WinType("FG_LoadCoefsFromWavePanel") == 7)
				KillWindow FG_LoadCoefsFromWavePanel
			endif
			if (WinType("FG_SaveCoefsToWavePanel") == 7)
				KillWindow FG_SaveCoefsToWavePanel
			endif
			if (WinType("FGNewFunctionPanel") == 7)
				KillWindow FGNewFunctionPanel
			endif
			break
		case 6:			// resize
			if( FG_MainPanelMinWindowSize() )
				FG_SetControlBarPosition()
				FG_SetCoefListBoxSize()
			endif
			break
	endswitch
	
	return statusCode		// 0 if nothing done, else 1
End

Function FG_UnloadPackage()
	if (WinType("GraphFunctionGraph") == 1)
		KillWindow GraphFunctionGraph
	endif
	Execute/P/Q/Z "DELETEINCLUDE <Function Grapher>"
	Execute/P/Q/Z "COMPILEPROCEDURES "
end

Function IsMatchForOneParamFunc(theFunctionName)		// f(x)
	String theFunctionName
	
	String fInfo = FunctionInfo(theFunctionName)
	
	if (NumberByKey("N_PARAMS", fInfo) != 1)
		return 0
	endif
	
	if (NumberByKey("RETURNTYPE", fInfo) != 0x4)
		return 0
	endif
	
	if (NumberByKey("PARAM_0_TYPE", fInfo) != 0x4)
		return 0
	endif
	
	return 1
end

Function IsMatchForTwoParamFunc(theFunctionName)		// f(w, x), just like a fitting function
	String theFunctionName
	
	String fInfo = FunctionInfo(theFunctionName)
	
	if (NumberByKey("N_PARAMS", fInfo) != 2)
		return 0
	endif
	
	if (NumberByKey("RETURNTYPE", fInfo) != 0x4)
		return 0
	endif
	
	Variable ptype = NumberByKey("PARAM_0_TYPE", fInfo)
	if ((ptype & 0x4000) == 0)	// Must be a wave
		return 0
	endif
	
	if (ptype & 0x1)				// reject complex waves
		return 0
	endif
	
	if (ptype  == 0x4000)			// reject text waves
		return 0
	endif
	
	if (NumberByKey("PARAM_1_TYPE", fInfo) != 0x4)
		return 0
	endif
	
	return 1
end

Function/S RemoveFuncsFromWrongFiles(ListOfFuncs, ListOfFiles)
	String ListOfFuncs
	Wave/T ListOfFiles
	
	Variable numFiles = numpnts(ListOfFiles)
	String aFunc
	Variable i=0
	Variable j
	do
		aFunc = StringFromList(i, ListOfFuncs)
		if (strlen(aFunc) == 0)
			break
		endif
		String funcFile = FunctionPath(aFunc)
		for (j = 0; j < numFiles; j += 1)
			if (CmpStr(funcFile, ListOfFiles[j]) == 0)
				ListOfFuncs = RemoveListItem(i, ListOfFuncs)
				i -= 1
			endif
		endfor
		i += 1
	while(1)
	
	return ListOfFuncs
end

Function/S FG_FuncMenuList()

	Variable i
	String funcName

	String anotherList = ""
	Variable numItems
	Wave/T ListOfFiles = root:Packages:WM_GraphFunction:ListOfFiles
	Variable useSeparator = 0
	
	String theList = ""
		
	String thePath = PathToProcFolder("")
	String files = IndexedFile(FG_ProcFolder, -1, ".ipf", "IGR0")
	if (strlen(files) > 0)
		for (i = 0; i < ItemsInList(files); i += 1)
			string afile = StringFromList(i, files)
			afile = RemoveEnding(afile, ".ipf")
			anotherList += afile+";"
		endfor
	endif
	
	if (strlen(anotherList) > 0)
		theList = "\\M1(   Function Grapher Functions;"
		theList += anotherList
		useSeparator = 1
	endif
	
	anotherList = FunctionList("*", ";", "KIND:2,VALTYPE:1,NPARAMS:1")	// functions having a single parameter	
	numItems = ItemsInList(anotherList)
	for (i = numItems-1; i >= 0; i -= 1)
		funcName = StringFromList(i, anotherList)
		if (!IsMatchForOneParamFunc(funcName))
			anotherList = RemoveListItem(i, anotherList)
		endif
		// remove items already added as  Function Grapher functions
		if (WhichListItem(funcName, theList) >= 0)
			anotherList = RemoveListItem(i, anotherList)
		endif
		anotherList = RemoveFuncsFromWrongFiles(anotherList, ListOfFiles)
	endfor	
	
	if (strlen(anotherList) > 0)
		if (useSeparator)
			theList += "-;"
		endif
		theList += "\\M1(   User Functions with No Coefficients;"
		theList += anotherList
		useSeparator = 1
	endif
		
	anotherList = FunctionList("*", ";", "KIND:2,VALTYPE:1,NPARAMS:2")
	numItems = ItemsInList(anotherList)
	for (i = numItems-1; i >= 0; i -= 1)
		funcName = StringFromList(i, anotherList)
		if (!IsMatchForTwoParamFunc(funcName))
			anotherList = RemoveListItem(i, anotherList)
		endif
		if (WhichListItem(funcName, theList) >= 0)
			anotherList = RemoveListItem(i, anotherList)
		endif
		anotherList = RemoveFuncsFromWrongFiles(anotherList, ListOfFiles)
	endfor
	
	if (strlen(anotherList) > 0)
		if (useSeparator)
			theList += "-;"
		endif
		theList += "\\M1(   User-Defined Functions;"
		theList += anotherList
		useSeparator = 1
	endif
	
	anotherList += FunctionList("*", ";", "KIND:4,VALTYPE:1,NPARAMS:2")
	numItems = ItemsInList(anotherList)
	for (i = numItems-1; i >= 0; i -= 1)
		funcName = StringFromList(i, anotherList)
		if (!IsMatchForTwoParamFunc(funcName))
			anotherList = RemoveListItem(i, anotherList)
		endif
		if (WhichListItem(funcName, theList) >= 0)
			anotherList = RemoveListItem(i, anotherList)
		endif
		// don't need to call RemoveFuncsFromWrongFiles() because external functions can't be in procedure files!
	endfor

	if (strlen(anotherList) > 0)
		if (useSeparator)
			theList += "-;"
		endif
		theList += "\\M1(   External Functions [XFUNCs];"
		theList += anotherList
		useSeparator = 1
	endif
	
	return theList
end

Function FG_SetNumCoefsProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	Wave/T CoefListContents = root:Packages:WM_GraphFunction:CoefListContents
	Wave selection = root:Packages:WM_GraphFunction:CoefListSelection
	Variable oldNumCoefs = DimSize(CoefListContents, 0)
	Redimension/N=(varNum, -1) CoefListContents, selection
	if (oldNumCoefs < varNum)
		CoefListContents[oldNumCoefs, varNum-1][0] = "w["+num2str(p)+"]"
		CoefListContents[oldNumCoefs, varNum-1][1] = "0.0"
		selection[][0] = 0
		selection[][1] = 2
	endif
end

Function FG_LoadCoefsFromWave(ctrlName) : ButtonControl
	String ctrlName
	
	fFG_LoadCoefsFromWavePanel()
	AutoPositionWindow/E/M=0/R=GraphFunctionGraph FG_LoadCoefsFromWavePanel
end

Function fFG_LoadCoefsFromWavePanel()

	if (WinType("FG_LoadCoefsFromWavePanel") == 7)
		DoWindow/F FG_LoadCoefsFromWavePanel
	else
		NewPanel /K=1 /W=(495,66,783,206) as "Load Coefficients From  Wave"
		RenameWindow $S_name, FG_LoadCoefsFromWavePanel
		ModifyPanel/W=FG_LoadCoefsFromWavePanel fixedSize = 1
		Button FG_LoadCoefsFromWaveButton,pos={113,83},size={50,20},proc=FG_LoadCoefsFromWaveButtonProc,title="Load"
		PopupMenu FG_LoadCoefsWaveMenu,pos={31,33},size={212,20},title="Select Wave:"
		PopupMenu FG_LoadCoefsWaveMenu,mode=1,bodyWidth= 150,value= #"FG_LoadCoefsFromWaveListFunc()"
		PopupMenu FG_LoadCoefsWaveMenu,help={"Choose a wave containing the coefficients you wish to load.\r\rOnly waves having a number of points matching the number of coefficients are listed in the menu."}
	endif
EndMacro

Function FG_LoadCoefsFromWaveButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T CoefListContents = root:Packages:WM_GraphFunction:CoefListContents
	ControlInfo/W=FG_LoadCoefsFromWavePanel FG_LoadCoefsWaveMenu
	Wave coefWave = $S_value
	CoefListContents[][1] = num2str(coefWave[p])
	FG_CalcNewGraph()
End

Function/S FG_LoadCoefsFromWaveListFunc()

	Wave/T CoefListContents = root:Packages:WM_GraphFunction:CoefListContents
	String nCoefsStr = num2str(DimSize(CoefListContents, 0))
	String options = "DIMS:1,"
	options += "MAXROWS:"+nCoefsStr+","
	options += "MINROWS:"+nCoefsStr
	return WaveList("*", ";", options)
end

Function FG_SaveCoefsToWave(ctrlName) : ButtonControl
	String ctrlName
	
	String/G root:Packages:WM_GraphFunction:SaveCoefWaveName
	fFG_SaveCoefsToWavePanel()
	AutoPositionWindow/E/M=0/R=GraphFunctionGraph FG_SaveCoefsToWavePanel
end

Function fFG_SaveCoefsToWavePanel()

	if (WinType("FG_SaveCoefsToWavePanel") == 7)
		DoWindow/F FG_SaveCoefsToWavePanel
	else
		NewPanel/K=1 /W=(150,50,438,190) as "Save Coefficients to  Wave"
		RenameWindow $S_name, FG_SaveCoefsToWavePanel
		ModifyPanel/W=FG_SaveCoefsToWavePanel fixedSize = 1
		SetVariable FG_SaveCoefsSetWName,pos={40,47},size={201,15},title="New Wave Name:"
		SetVariable FG_SaveCoefsSetWName,format="%g"
		SetVariable FG_SaveCoefsSetWName,value= root:Packages:WM_GraphFunction:SaveCoefWaveName,bodyWidth= 120
		SetVariable FG_SaveCoefsSetWName,help={"Enter a name to be used for a new wave to save the cofficients currently in the coefficient list.\r\rIf the name matches an existing wave, that wave will be overwritten."}
		Button FG_SaveCoefsToWaveButton,pos={107,83},size={50,20},proc=FG_SaveCoefsToWaveButtonProc,title="Save"
	endif
EndMacro

Function FG_SaveCoefsToWaveButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR SaveCoefWaveName = root:Packages:WM_GraphFunction:SaveCoefWaveName
	Wave/T CoefListContents = root:Packages:WM_GraphFunction:CoefListContents
	
	Variable ncoefs = DimSize(CoefListContents, 0)
	Make/O/D/N=(ncoefs) $SaveCoefWaveName
	Wave CoefWave = $SaveCoefWaveName
	CoefWave = str2num(CoefListContents[p][1])
	
	DoWindow/K FG_SaveCoefsToWavePanel
End

Function FG_2paramsTemplate(FG_ParamWave, x)
	Wave FG_ParamWave
	Variable x
	
	Variable/G root:Packages:WM_GraphFunction:RunningTemplate = 1
end

Function FG_1paramsTemplate(x)
	Variable x
	
	Variable/G root:Packages:WM_GraphFunction:RunningTemplate = 1
end

Function FG_SetXProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	FG_CalcNewGraph()
End

Function FG_HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic/K=1 "Function Grapher"
End

static Function IsWhiteSpaceChar(thechar)
	Variable thechar
	
	Variable spChar = char2num(" ")
	Variable tabChar = char2num("\t")

	if ( (thechar == spChar) || (thechar == tabChar) )
		return 1
	else
		return 0
	endif
end

static Function IsEndLine(theLine)
	String theLine
	
	Variable i = 0
	Variable linelength = strlen(theLine)
	
	for (i = 0; i < linelength; i += 1)
		Variable thechar = char2num(theLine[i])
		if (!IsWhiteSpaceChar(thechar))
			break
		endif
	endfor
	if (i == linelength)
		return 0
	endif
	return CmpStr(theLine[i, i+2], "end") == 0
end

static Function FG_IsOneOfOurs(funcName)
	String funcName
	
	String funcFile = FunctionPath(funcName)
	if ( (strlen(funcFile) == 0) || (CmpStr(funcFile[0], ":") == 0) )
		return 0
	endif
	Variable fileRef
	Open/R fileRef as funcFile
	String aLine
	FReadLine fileRef, aLine
	FReadLine fileRef, aLine
	Close fileRef
	if (CmpStr(aLine[0, strlen(aLine)-2], FG_SpecialSecondLine) == 0)
		return 1
	else
		return 0
	endif	
end

static Function GetNumCoefsAndNamesFromFunction(funcName, coefList)
	String funcName
	String &coefList
	
	Variable i
	Variable numCoefs
	String funcCode = ProcedureText(funcName )
	
	coefList = ""
	
	if (FindListItem(funcName, FunctionList("*", ";", "KIND:2,VALTYPE:1,NPARAMS:1")) >= 0)
		numCoefs = 0
	elseif (strlen(funcCode) == 0)		// an XOP function?
		numCoefs = NaN
	else
		i=0
		Variable commentPos
		do
			String aLine = StringFromList(i, funcCode, "\r")
			if (IsEndLine(aLine))
				numCoefs = NaN
				break
			endif
			commentPos = strsearch(aLine, "//CurveFitDialog/ Coefficients", 0 , 2)
			if (commentPos >= 0)		// 2 means ignore case
				sscanf aLine[commentPos, inf], "//CurveFitDialog/ Coefficients %d", numCoefs
				i += 1
				break
			endif
			i += 1
		while (1)
		
		if (numType(numCoefs) == 0)
			do
				aLine = StringFromList(i, funcCode, "\r")
				if (IsEndLine(aLine))
					break
				endif
				commentPos = strsearch(aLine, "//CurveFitDialog/ FG_ParamWave[", 0 , 2)
				if (commentPos >= 0)		// 2 means ignore case
					Variable equalPos = strsearch(aLine[commentPos, inf], "=", 0) + commentPos
					if (equalPos > 0)
						equalPos += 1
						Variable spChar = char2num(" ")
						Variable tabChar = char2num("\t")
						do
							Variable char = char2num(aLine[equalPos])
							if ( (char == spChar) || (char == tabChar) )
								equalPos += 1
							else
								string name
								sscanf aLine[equalPos, inf], "%s", name
								coefList += name+";"
								break
							endif
						while(1)
					endif
				endif
				i += 1
			while (1)
		endif
	endif
	
	return numCoefs
end

static Function/S GetFunctionExpression(funcName)
	String funcName
	
	String funcCode = ProcedureText(funcName )
	String aLine = ""
	Variable i = 0
	do
		aLine = StringFromList(i, funcCode, "\r")
		if (IsEndLine(aLine))
			break
		endif
		Variable commentPos = strsearch(aLine, "//", 0)
		Variable returnPos = strsearch(aLine, "return", 0, 2)
		if (commentPos < 0)
			commentPos = strlen(aLine)
		endif
		if ( (returnPos > 0) && (returnPos < commentPos) )
			return aLine[returnPos+7,strlen(aLine)-1]
		endif
		i += 1
	while (1)
	
	return ""
end

static Function/S GetFunctionIndvarName(funcName)
	String funcName
	
	String funcCode = ProcedureText(funcName )
	Variable LParenPos = strsearch(funcCode, "(", 0)
	Variable RParenPos = strsearch(funcCode, ")", 0)
	Variable commaPos = strsearch(funcCode, ",", LParenPos)
	Variable startPos = commaPos > 0 ? commaPos : LParenPos
	
	startPos += 1
	do
		if (!IsWhiteSpaceChar(char2num(funcCode[startPos])))
			break
		endif
		startPos += 1			
	while (1)
	RParenPos -= 1
	do
		if (!IsWhiteSpaceChar(char2num(funcCode[RParenPos])))
			break
		endif
		RParenPos -= 1			
	while (1)
	return funcCode[startPos, RParenPos]
end

static function ShowHideCoefSubPanel(showIt)
	Variable showIt
	
	String controls= "FG_NCoefsTitle;FG_SetNumCoefs;FG_LoadCoefsFromWave;FG_SaveCoefsToWave;"
	String win= "GraphFunctionGraph#GraphFunctionPanel#FG_CListSubPanel#FG_CListOtherControlsPanel"
	ModifyControlList controls win=$win, disable=!showIt
	
	controls= "FG_CoefsGroup;FuncDisp_CoefListBox;"
	win= "GraphFunctionGraph#GraphFunctionPanel#FG_CListSubPanel"
	ModifyControlList controls win=$win, disable=!showIt
end

Function FG_FuncMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String/G root:Packages:WM_GraphFunction:FG_FuncName = popStr
	SVAR FG_ExpressionText = root:Packages:WM_GraphFunction:FG_ExpressionText
	if ( (strlen(popStr) == 0) || (CmpStr(popStr, "_NONE_") == 0) )
		Button FuncDisp_EditFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 2
		Button FuncDisp_SaveFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 2
		Button FuncDisp_KillFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 2
		Button FuncDisp_ShowFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 2
		FG_ExpressionText = "no expression"
		return -1
	endif
	// functionType is 3 for a function (includes external functions) or 6 for a user-defined function.
	// If it was in the menu but it's not a 3 or a 6, it means it's one from the :packages:WMFunctionGrapher: folder
	// and it needs to be #include'ed
	Variable functionType = Exists(popStr)
	if (functionType == 0)
		String includePath = PathToProcFolder(popStr)
		Execute/P/Q "INSERTINCLUDE \""+includePath+"\""
		Execute/P/Q "COMPILEPROCEDURES "
		Execute/P/Q/Z "SetFuncMenu(\""+popStr+"\")"
		return 0
	endif
	
	String coefList = ""
	Variable numCoefs = GetNumCoefsAndNamesFromFunction(popStr, coefList)

	Variable i

	if (numCoefs == 0)
		ShowHideCoefSubPanel(0)
	else
		ShowHideCoefSubPanel(1)
		if (numtype(numCoefs) != 0)
			SetVariable FG_SetNumCoefs,win=GraphFunctionGraph#GraphFunctionPanel#FG_CListSubPanel#FG_CListOtherControlsPanel, disable=0
			TitleBox FG_NCoefsTitle,win=GraphFunctionGraph#GraphFunctionPanel#FG_CListSubPanel#FG_CListOtherControlsPanel, disable=0
			NVAR FG_numCoefs = root:Packages:WM_GraphFunction:FG_numCoefs
			numCoefs = FG_numCoefs
			for (i = 0; i < numCoefs; i += 1)
				coefList += "FG_ParamWave["+num2str(i)+"];"
			endfor
		else
			SetVariable FG_SetNumCoefs,win=GraphFunctionGraph#GraphFunctionPanel#FG_CListSubPanel#FG_CListOtherControlsPanel, disable=1
			TitleBox FG_NCoefsTitle,win=GraphFunctionGraph#GraphFunctionPanel#FG_CListSubPanel#FG_CListOtherControlsPanel, disable=1
		endif
	endif
	if (numCoefs > 0)
		Wave/T contents = root:Packages:WM_GraphFunction:CoefListContents
		Wave selection = root:Packages:WM_GraphFunction:CoefListSelection
		Variable oldNumCoefs = DimSize(contents, 0)
		Duplicate/O/T contents, tempcontents
		Redimension/N=(numCoefs, 2) contents, selection
		contents[0, min(oldNumCoefs, numCoefs)-1] = tempcontents[p][q]
		KillWaves/Z tempcontents
		contents[][0] = StringFromList(p, coefList)
		if (oldNumCoefs < numCoefs)
			contents[oldNumCoefs, numCoefs-1][1] = "0.0"
		endif
		selection[][0] = 0
		selection[][1] = 2
	endif
	
	if (FG_IsOneOfOurs(popStr))
		String theExpression = GetFunctionExpression(popStr)
//		TitleBox FG_ExpressionTitle, title = theExpression
		FG_ExpressionText = theExpression
		Button FuncDisp_EditFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 0
		Button FuncDisp_SaveFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 0
		Button FuncDisp_KillFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 0
		Button FuncDisp_ShowFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 0, title = "Show Code",proc=FG_ShowCodeButtonProc
	else
//		TitleBox FG_ExpressionTitle, title = popStr
		FG_ExpressionText = popStr
		Button FuncDisp_EditFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 2
		Button FuncDisp_SaveFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 2
		Button FuncDisp_KillFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 2
		Button FuncDisp_ShowFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, disable = 0
		if (functionType == 3)		// it's an XFUNC
			Button FuncDisp_ShowFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, title = "Function Help", proc=ShowFunctionHelp
		else
			Button FuncDisp_ShowFunctionButton, win=GraphFunctionGraph#GraphFunctionPanel, title = "Show Code",proc=FG_ShowCodeButtonProc
		endif
	endif
	FG_CalcNewGraph()
End

Function FG_CoefListBoxProc(ctrlName,row,col,event) : ListBoxControl
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end

	if (event == 7)
		FG_CalcNewGraph()
	endif
	return 0
End

static Function FG_CalcNewGraph()

	NVAR StartX = root:Packages:WM_GraphFunction:StartX
	NVAR EndX = root:Packages:WM_GraphFunction:EndX
//	NVAR DelX = root:Packages:WM_GraphFunction:DelX
	NVAR nPnts = root:Packages:WM_GraphFunction:nPnts
	SVAR FuncName = root:Packages:WM_GraphFunction:FG_FuncName
	
	Variable/G root:Packages:WM_GraphFunction:RunningTemplate = 0
	NVAR RunningTemplate = root:Packages:WM_GraphFunction:RunningTemplate
	
	Variable twoParamFunc = 0
	FUNCREF FG_1paramsTemplate theFunc1 = $FuncName
	Variable numCoefs = 0
	Variable returnValue = theFunc1(0)
	if (RunningTemplate)
		RunningTemplate = 0
		FUNCREF FG_2paramsTemplate theFunc2 = $FuncName
		Wave/T CoefListContents = root:Packages:WM_GraphFunction:CoefListContents
		numCoefs = DimSize(CoefListContents, 0)
		Make/D/O/N=(numCoefs) root:Packages:WM_GraphFunction:FG_CoefWave = str2num(CoefListContents[p][1])
		Wave cwave = root:Packages:WM_GraphFunction:FG_CoefWave
		returnValue = theFunc2(cwave, 0)
		twoParamFunc = 1
		if (RunningTemplate)
			DoAlert 0, "The function "+funcName+" is not of correct form."
			return -1
		endif
	endif
	
//	PopupMenu FuncDisp_CoefWaveMenu, disable = twoParamFunc==0
	ListBox FuncDisp_CoefListBox, win=GraphFunctionGraph#GraphFunctionPanel#FG_CListSubPanel, disable = twoParamFunc==0
	
//	Make/D/O/N=(((EndX - StartX)/DelX)+1) root:Packages:WM_GraphFunction:FuncWave
	Make/D/O/N=(nPnts) root:Packages:WM_GraphFunction:FuncWave
	Wave w = root:Packages:WM_GraphFunction:FuncWave
	SetScale/I x StartX, EndX, w
	if (twoParamFunc)
		w = theFunc2(cwave, x)
	else
		w = theFunc1(x)
	endif
end

static Function FG_NewFunc_InitGlobals()

	String saveDF = GetDataFolder(1)
	SetDatafolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_GraphFunction
	
	Variable/G NewFuncIsEditing = 0
	Variable/G NewFuncNumCoefs = 1
	String/G FGNewFunc_FuncName = "MyFunc"
	String/G FGNewFunc_Expression = ""
	String/G FGNewFunc_IndVarName = "x"
	Make/O/N=(1,1)/T NewFuncCoefListContents
	SetDimLabel 1, 0, 'Coefficient Name', NewFuncCoefListContents
	Make/O/N=1 NewFuncCoefListSelection = 2		// editable
	
	SetDataFolder $saveDF
end

Function FG_NewFunctionButtonProc(ctrlName) : ButtonControl
	String ctrlName

//	FG_NewFunc_InitGlobals()
	if (CmpStr(ctrlName, "FuncDisp_EditFunctionButton") == 0)
		ControlInfo/W=GraphFunctionGraph#GraphFunctionPanel FuncDisp_FuncMenu
		if (FG_IsOneOfOurs(S_value))
			FG_NewFunctionPanel(S_value)
		else
			DoAlert 0, "Can't edit that function; it was not made created with the Function Grapher package."
		endif
	else
		FG_NewFunctionPanel("")
	endif
End


Function FG_SaveFunctionButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=GraphFunctionGraph#GraphFunctionPanel FuncDisp_FuncMenu
	String funcName = S_Value
	if (FG_IsOneOfOurs(funcName))
		Variable myRefNum
		Open/D/T=".ipf" myRefNum as funcName+".ipf"
		if (strlen(S_fileName) > 0)
			String includePath = PathToProcFolder(funcName)
			String/G root:Packages:WM_GraphFunction:SubroutineLinkage:FunctionName = funcName
			String/G root:Packages:WM_GraphFunction:SubroutineLinkage:FuncIncludePath = includePath
			String/G root:Packages:WM_GraphFunction:SubroutineLinkage:UsersFileNameAndPath = S_fileName
			Execute/P/Q "DELETEINCLUDE \""+includePath+"\""
			Execute/P/Q "COMPILEPROCEDURES "
			Execute/P/Q "FG_SaveFunctionPart2()"
		endif
	endif
End

Function FG_SaveFunctionPart2()
	
	SVAR funcName = root:Packages:WM_GraphFunction:SubroutineLinkage:FunctionName
	SVAR includePath = root:Packages:WM_GraphFunction:SubroutineLinkage:FuncIncludePath
	SVAR usersPath = root:Packages:WM_GraphFunction:SubroutineLinkage:UsersFileNameAndPath
	
	OpenNotebook/V=0/N=FG_TempNotebook includePath+".ipf"
	Notebook FG_TempNotebook, findText={FG_SpecialSecondLine, 8}
	Notebook FG_TempNotebook, selection={startOfParagraph, startOfNextParagraph}
	Notebook FG_TempNotebook, text = ""
	SaveNotebook/O/S=2 FG_TempNotebook as usersPath
	KillWindow FG_TempNotebook
	if (strlen(S_path) == 0)
		Execute/P/Q "INSERTINCLUDE \""+includePath+"\""
		Execute/P/Q "COMPILEPROCEDURES "
	else
		DeleteFile/Z includePath+".ipf"
		if (V_flag)
			DoAlert 0, "Failed to delete original function file. Error code: "+num2str(V_flag)
		endif
		String newInclude = RemoveEnding(usersPath, ".ipf")
		PathInfo Igor
		String IgorProcedures = S_Path+"Igor Procedures:"
		String UserProcedures = S_Path+"User Procedures:"
		String WaveMetricsProcedures = S_Path+"WaveMetrics Procedures:"
		if (strsearch(newInclude, IgorProcedures, 0) >= 0)
			Execute/P/Q "OpenProc/V=0/Z \""+usersPath+"\""
		elseif (strsearch(newInclude, UserProcedures, 0) >= 0)
			newInclude = ParseFilePath(3, newInclude, ":", 0, 0)
			Execute/P/Q "INSERTINCLUDE \""+newInclude+"\""
		elseif (strsearch(newInclude, WaveMetricsProcedures, 0) >= 0)
			newInclude = ParseFilePath(3, newInclude, ":", 0, 0)
			Execute/P/Q "INSERTINCLUDE <"+newInclude+">"		// the user should NOT do this, but I can't prevent it...
		else
			Execute/P/Q "INSERTINCLUDE \""+newInclude+"\""
		endif
		Execute/P/Q "COMPILEPROCEDURES "
		Execute/P/Q/Z "SetFuncMenu(\""+funcName+"\")"
	endif
end

Function FG_ShowCodeButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=GraphFunctionGraph#GraphFunctionPanel FuncDisp_FuncMenu
	DisplayProcedure S_value
End

Function ShowFunctionHelp(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=GraphFunctionGraph#GraphFunctionPanel FuncDisp_FuncMenu
	DisplayHelpTopic/K=1 S_value
End

Function FG_KillFunctionButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=GraphFunctionGraph#GraphFunctionPanel FuncDisp_FuncMenu
	String functionName = S_value
	if (FG_IsOneOfOurs(functionName))
		DoAlert 1, "Really kill the function "+functionName+"?\r\rIt will remove all traces of the function."
		if (V_flag == 1)
			String includePath = PathToProcFolder(functionName)
			Execute/P/Q/Z "DELETEINCLUDE \""+includePath+"\""
			Execute/P/Q "COMPILEPROCEDURES "
			Execute/P/Q/Z "DeleteFile/Z=1 \""+includePath+".ipf\""
			//PopupMenu FuncDisp_FuncMenu, win=GraphFunctionGraph#GraphFunctionPanel, popvalue="_NONE_"
			PopupMenu FuncDisp_FuncMenu,mode=1,popvalue="_NONE_",value= #"FG_FuncMenuList()"
			Execute/P/Q/Z "FG_FuncMenuProc(\"\",0,\"_NONE_\")"
//			PopupMenu FuncDisp_FuncMenu, win=GraphFunctionGraph#GraphFunctionPanel, mode=1
//			Execute/P/Q/Z "SetFuncMenu(\"_NONE_\")"
		endif
	endif
End

Function FG_KillAllFGFunctions()
end

static Function FG_NewFunctionPanel(FuncName)
	String FuncName		// "" if New Function, name of function if Edit Function

	if ( (strlen(FuncName) == 0) && (WinType("FGNewFunctionPanel") == 7) )
		NVAR/Z NewFuncIsEditing = root:Packages:WM_GraphFunction:NewFuncIsEditing
		if (NVAR_Exists(NewFuncIsEditing) && NewFuncIsEditing)
			DoWindow/K FGNewFunctionPanel
		else
			DoWindow/F FGNewFunctionPanel
			return 0
		endif
	endif
	
	if ( (strlen(FuncName) > 0) && (WinType("FGNewFunctionPanel") == 7) )
		DoWindow/K FGNewFunctionPanel
	endif

	FG_NewFunc_InitGlobals()
	
	String winTitle
	if (strlen(FuncName) > 0)
		winTitle = "Edit Function"
	else
		winTitle = "New Function"
	endif
	
	Variable defLeft=46	// panel units
	Variable defTop= 66
	Variable defRight= 624
	Variable defBottom= 325
	String fmt="NewPanel/K=1/N=FGNewFunctionPanel/W=(%s) as \""+winTitle+"\""	// /W=(defLeft,defTop,defRight,defBottom)
	String cmd= WC_WindowCoordinatesSprintf("FGNewFunctionPanel",fmt,defLeft,defTop,defRight,defBottom,1)
	Execute cmd

	ModifyPanel/W=FGNewFunctionPanel fixedSize = 1
	
	SetVariable FG_NewFunc_SetFuncName,pos={78,11},size={188,15},title="Function Name", proc=FG_NewFunc_SetFuncNameProc
	SetVariable FG_NewFunc_SetFuncName,value= root:Packages:WM_GraphFunction:FGNewFunc_FuncName,bodyWidth= 120, live=1
	SetVariable FG_NewFunc_SetFuncName,help={"Enter a name for your function. It must not be the same as any other function, or any Igor function or operation.\r\rIf you are editing a pre-existing function, the name cannot be changed."}
	TitleBox FG_NewFunc_BadNameTitle,pos={136,29},size={136,32},title="\\K(65535,0,0)Function name conflicts with\rexisting procedure."
	TitleBox FG_NewFunc_BadNameTitle,frame=2,anchor= MC, disable=1
	TitleBox FG_NewFunc_BadNameTitle,help={"You have entered a name for your function that conflicts with an existing user-defined function, an XFunc (defined by an XOP) or an Igor built-in function or operation."}

	ListBox FG_NewFunc_CList,pos={307,11},size={199,133},frame=4
	ListBox FG_NewFunc_CList,listWave=root:Packages:WM_GraphFunction:NewFuncCoefListContents
	ListBox FG_NewFunc_CList,selWave=root:Packages:WM_GraphFunction:NewFuncCoefListSelection
	ListBox FG_NewFunc_CList,mode= 3
	ListBox FG_NewFunc_CList,help={"Enter names for the coefficients in this list.\r\rYou will see these names in the coefficient value list in the main control panel."}
	
	SetVariable FG_NewFunc_SetNumCoefs,pos={77,83},size={167,15},proc=FG_NewFunc_SetNumCoefsProc,title="Number of Coefficients", live=1
	SetVariable FG_NewFunc_SetNumCoefs,limits={0,Inf,1},value= root:Packages:WM_GraphFunction:NewFuncNumCoefs,bodyWidth= 60
	SetVariable FG_NewFunc_SetNumCoefs,help={"Enter the number of coefficients here.\r\rThe coefficient name list will be adjusted to have this many lines for entering coefficient names."}
	SetVariable FG_NewFunc_SetIndVarName,pos={49,105},size={235,15},title="Name of Independent Variable"
	SetVariable FG_NewFunc_SetIndVarName,format="%g"
	SetVariable FG_NewFunc_SetIndVarName,value= root:Packages:WM_GraphFunction:FGNewFunc_IndVarName,bodyWidth= 100
	SetVariable FG_NewFunc_SetIndVarName,help={"Enter a name for the independent variable (commonly \"x\") here. You must use this name in the function expression below."}

	SetVariable FG_NewFunc_SetExpression,pos={11,162},size={547,15},title="Function Expression"
	SetVariable FG_NewFunc_SetExpression,format="%g"
	SetVariable FG_NewFunc_SetExpression,value= root:Packages:WM_GraphFunction:FGNewFunc_Expression,bodyWidth= 454
	SetVariable FG_NewFunc_SetExpression,help={"Enter the function expression here. Use * for multiplication (no implied multiplication here!). It must use the coefficient names shown in the list."}
	Button FG_NewFunc_OKbutton,pos={50,217},size={50,20},proc=FG_NewFunc_OKbuttonProc,title="OK"
	Button FG_NewFunc_OKbutton,help={"When you are satisfied with your entries, click OK to have Igor build function code and set up the main panel to use it.\r\rIf there is a problem, an alert is shown with a mysterious numeric code. I wish I knew how to provide better error messages for this."}
	Button FG_NewFunc_Cancelbutton,pos={118,217},size={60,20},proc=FG_NewFunc_CancelbuttonProc,title="Cancel"
	Button FG_NewFunc_Cancelbutton,help={"Click Cancel to return to the main panel, discarding any entries you may have made here."}
	
	SetWindow FGNewFunctionPanel, hook = WC_WindowCoordinatesHook
	
	if (strlen(FuncName) != 0)
		SVAR functionName = root:Packages:WM_GraphFunction:FGNewFunc_FuncName
		functionName = funcName
		SetVariable FG_NewFunc_SetFuncName, noedit = 1, frame=0
		
		NVAR NewFuncNumCoefs = root:Packages:WM_GraphFunction:NewFuncNumCoefs
		String coefList
		NewFuncNumCoefs = GetNumCoefsAndNamesFromFunction(FuncName, coefList)
		Wave/T NewFuncListContents = root:Packages:WM_GraphFunction:NewFuncCoefListContents
		Wave NewFuncListSelection = root:Packages:WM_GraphFunction:NewFuncCoefListSelection
		Redimension/N=(NewFuncNumCoefs, 1) NewFuncListContents, NewFuncListSelection
		NewFuncListSelection = 2
		NewFuncListContents = StringFromList(p, coefList)
		
		SVAR FGNewFunc_Expression = root:Packages:WM_GraphFunction:FGNewFunc_Expression
		FGNewFunc_Expression = GetFunctionExpression(FuncName)
		
		SVAR FGNewFunc_IndVarName = root:Packages:WM_GraphFunction:FGNewFunc_IndVarName
		FGNewFunc_IndVarName = GetFunctionIndvarName(FuncName)
		
		NVAR NewFuncIsEditing = root:Packages:WM_GraphFunction:NewFuncIsEditing
		NewFuncIsEditing = 1
	endif
EndMacro

Function FG_NewFunc_SetNumCoefsProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	NVAR numCoefs = root:Packages:WM_GraphFunction:NewFuncNumCoefs
	Wave/T NewFuncListContents = root:Packages:WM_GraphFunction:NewFuncCoefListContents
	Wave NewFuncListSelection = root:Packages:WM_GraphFunction:NewFuncCoefListSelection
	
	Redimension/N=(numCoefs, 1) NewFuncListContents
	Redimension/N=(numCoefs, 1) NewFuncListSelection
	NewFuncListSelection = 2
End

static Function FG_NewFunc_IsNameOK(funcName)
	String funcName
	
	return !(Exists(funcName) >= 3)
end

Function FG_NewFunc_SetFuncNameProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	NVAR NewFuncIsEditing = root:Packages:WM_GraphFunction:NewFuncIsEditing

	if (!NewFuncIsEditing)
		if (!FG_NewFunc_IsNameOK(varStr))
			titleBox FG_NewFunc_BadNameTitle win=FGNewFunctionPanel, disable = 0
		else
			titleBox FG_NewFunc_BadNameTitle win=FGNewFunctionPanel, disable = 1
		endif
	endif
end

Function FG_NewFunc_OKbuttonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR expression = root:Packages:WM_GraphFunction:FGNewFunc_Expression
	SVAR FuncName = root:Packages:WM_GraphFunction:FGNewFunc_FuncName
	SVAR IndVarName = root:Packages:WM_GraphFunction:FGNewFunc_IndVarName
	NVAR NewFuncIsEditing = root:Packages:WM_GraphFunction:NewFuncIsEditing
	Wave/T NewFuncListContents = root:Packages:WM_GraphFunction:NewFuncCoefListContents
	
	if (!NewFuncIsEditing && !FG_NewFunc_IsNameOK(funcName))
		DoAlert 0, "Your function name conflicts with an existing procedure."
		return -1
	endif
	
	Variable expLen = strlen(expression)
	if (expLen == 0)
		DoAlert 0, "You haven't entered an expression."
		return -1
	endif
	
	if (expLen > 390)		// 400 characters minus "\treturn " minus three characters for safety (or something)
		DoAlert 0, "Your expression is too long."
		return -1
	endif
	
	String saveDF = GetDataFolder(1)
	SetDataFolder root:Packages:WM_GraphFunction:
	NewDataFolder/O/S :Scratch
	
	KillVariables/A/Z
	Variable i
	Variable numCoefs = DimSize(NewFuncListContents, 0)
	for (i = 0; i < numCoefs; i += 1)
		if (CheckName(NewFuncListContents[i], 3))
			DoAlert 0, "The coefficient \""+NewFuncListContents[i]+"\" is not a well-formed name."
			Wave NewFuncListSelection = root:Packages:WM_GraphFunction:NewFuncCoefListSelection
			NewFuncListSelection = 2
			NewFuncListSelection[i] = 3
			return -1
		endif
		if (CmpStr(NewFuncListContents[i], "FG_ParamWave") == 0)
			DoAlert 0, "You cannot use \"FG_ParamWave\" as the coefficient name, because it conflicts with a name Function Grapher uses in generating the function code."
			Wave NewFuncListSelection = root:Packages:WM_GraphFunction:NewFuncCoefListSelection
			NewFuncListSelection = 2
			NewFuncListSelection[i] = 3
			return -1
		endif
		Variable/G $(NewFuncListContents[i])
	endfor
	Variable/G yy, $IndVarName
	
	Execute/Q/Z "yy = "+ expression
	Variable ExpressionError = V_flag
	if (ExpressionError)
		DoAlert 0, "Your expression gave error " + num2str(ExpressionError) + ": " + FG_NewFunc_ExpressionErrMsg(ExpressionError)
	endif

	SetDataFolder $saveDF
	
	if (!ExpressionError)
		String coefList = ""
		for (i = 0; i < numCoefs; i += 1)
			coefList += NewFuncListContents[i] + ";"
		endfor
		
		FG_MakeAndLoadProcFilePart1(FuncName, coefList, IndVarName, expression)
		DoWindow/K FGNewFunctionPanel
	endif
End

static  Function/S FG_NewFunc_ExpressionErrMsg(errNum)
	Variable errNum
	
	switch(errNum)
		case 1002:
			return "unknown/inappropriate name or symbol"
		case 1003:
			return "expected left parenthesis"
		case 1004:
			return "expected right parenthesis"
		case 1005:
			return "expected operand"
		case 1006:
			return  "expected operator"
		case 1007:
			return "operator/operand mismatch"
		case 1008:
			return "wrong number of parameters"
		case 1009:
			return "expected left parenthesis"
		case 1010:
			return "expected right parenthesis"
		case 1011:
			return "this function takes no parameters"
		case 1012:
			return "function not available for this number type"
		case 1013:
			return "ambiguous wave point number"
		case 1014:
			return  "expected wave name"
		case 1016:
			return "expected cursor name (A or B)"
		case 1017:
			return  "line too long"
		case 1018:
			return "expected ']'"
		case 1019:
			return "expected '['"
	endswitch
	
	return ""
end

Function FG_NewFunc_CancelbuttonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K FGNewFunctionPanel
End

static Function/S PathToProcFolder(FunctionName)
	String FunctionName
	
	String tempPathStr = specialdirpath("Packages", 0, 0, 1)
	if (strlen(tempPathStr) == 0)
		return ""
	endif
	String includePath = tempPathStr+"WMFunctionGrapher"
	NewPath/O/Q/C FG_ProcFolder includePath
	if (strlen(FunctionName) > 0)
		includePath += ":"+FunctionName
	endif
	
	return includePath
end

static Function FG_MakeAndLoadProcFilePart1(FuncName, coefList, indVarName, expr)
	String FuncName
	String coefList
	String indVarName
	String expr
	
	String CurrentFuncPath = FunctionPath(FuncName)
	String lineBuffer
	Variable fileRef
	if (strlen(CurrentFuncPath) > 0) 
		if (char2num(CurrentFuncPath[0]) != char2num(":"))
			Open/R fileRef as CurrentFuncPath
			FReadLine fileRef, lineBuffer
			FReadLine fileRef, lineBuffer
			Close fileRef
			lineBuffer = RemoveEnding(lineBuffer)
			if (CmpStr(lineBuffer, FG_SpecialSecondLine) != 0)
				DoAlert 0, "Conflict with existing function. The file defining the function does not belong to the Function Grapher."
				return -1
			endif
		else
			if (CmpStr(CurrentFuncPath, ":Procedure"))
				DoAlert 0,"Conflict with existing function defined in the main procedure window."
			else
				DoAlert 0,"Conflict with existing function defined in procedure window '"+CurrentFuncPath[1,strlen(CurrentFuncPath)-1]+"'."
			endif
		endif
	endif
	
	String SaveDF = GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_GraphFunction
	NewDataFolder/O/S SubroutineLinkage
	String/G FunctionName = FuncName
	String/G CoefficientList = coefList
	String/G IndependantVarName = indVarName
	String/G Expression = expr
	SetDataFolder $SaveDF
	
	Execute/P/Q/Z "DELETEINCLUDE \""+PathToProcFolder(FunctionName)+"\""
	Execute/P/Q "COMPILEPROCEDURES "
	Execute/P/Q "FG_MakeAndLoadProcFilePart2()"
end

Function SetFuncMenu(funcName)
	String funcName
	
	Variable listItem
	if (strlen(funcName) == 0)
		listItem = 1
	else
		listItem = WhichListItem(funcName, FG_FuncMenuList())
	endif
	if (listItem >= 0)
		PopupMenu FuncDisp_FuncMenu, win=GraphFunctionGraph#GraphFunctionPanel, mode = listItem+1
		ControlInfo/W=GraphFunctionGraph#GraphFunctionPanel FuncDisp_FuncMenu
		funcName = S_value
		FG_FuncMenuProc("",listItem+1,funcName)
	else
		DoAlert 0, "Could not find function "+funcName
	endif
end

Function FG_MakeAndLoadProcFilePart2()

	SVAR expression = root:Packages:WM_GraphFunction:SubroutineLinkage:Expression
	SVAR CoefficientList = root:Packages:WM_GraphFunction:SubroutineLinkage:CoefficientList
	SVAR indVarName = root:Packages:WM_GraphFunction:SubroutineLinkage:IndependantVarName
	SVAR FunctionName = root:Packages:WM_GraphFunction:SubroutineLinkage:FunctionName
	
	NVAR NewFuncIsEditing = root:Packages:WM_GraphFunction:NewFuncIsEditing

	String includePath = PathToProcFolder(FunctionName)
	NewNotebook/V=0/F=0/N=$FunctionName
	Notebook $FunctionName,text="#pragma rtglobals=2\r"
	Notebook $FunctionName,text=FG_SpecialSecondLine+"\r\r"
	
	Variable numCoefs = ItemsInList(CoefficientList)
	Variable i
	if (numCoefs > 0)
		Notebook $FunctionName,text="Function "+FunctionName+"(FG_ParamWave, "+indVarName+") : FitFunc\r"
		Notebook $FunctionName,text="\tWave FG_ParamWave\r"
	else
		Notebook $FunctionName,text="Function "+FunctionName+"("+indVarName+")\r"
	endif
	Notebook $FunctionName,text="\tVariable "+indVarName+"\r\r"
	if (numCoefs > 0)
		// using special CurveFitDialog comments will make this work as a fit function as well
		Notebook $FunctionName,text="\t//CurveFitDialog/ \r"
		Notebook $FunctionName,text="\t//CurveFitDialog/ Independent Variables 1\r"
		Notebook $FunctionName,text="\t//CurveFitDialog/ "+indVarName+"\r"
		Notebook $FunctionName,text="\t//CurveFitDialog/ Coefficients "+num2str(numCoefs)+"\r"
		for (i = 0; i < numCoefs; i += 1)
			Notebook $FunctionName,text="\t//CurveFitDialog/ FG_ParamWave["+num2str(i)+"] = "+StringFromList(i, CoefficientList)+"\r"
		endfor
		Notebook $FunctionName,text="\r"
		for (i = 0; i < numCoefs; i += 1)
			Notebook $FunctionName,text="\tVariable "+ StringFromList(i, CoefficientList)+" = FG_ParamWave["+num2str(i)+"]\r"
		endfor
	endif
	Notebook $FunctionName,text="\r"
	Notebook $FunctionName,text="\treturn "+expression+"\r"
	Notebook $FunctionName,text="end\r"
	
	if (NewFuncIsEditing)
		String/G root:Packages:WM_GraphFunction:SubroutineLinkage:FuncIncludePath = includePath
		Execute/P/Q "DELETEINCLUDE \""+includePath+"\""
		Execute/P/Q "COMPILEPROCEDURES "
		Execute/P/Q/Z  "FG_FinishEditProc()"
		return 0
	endif

	SaveNotebook/O $FunctionName as includePath+".ipf"
	if (Strlen(S_path) == 0)
		DoAlert 0, "Failed to save procedure text"
		return -1
	endif
	DoWindow/K $FunctionName
	Execute/P/Q "INSERTINCLUDE \""+includePath+"\""
	Execute/P/Q "COMPILEPROCEDURES "
	Execute/P/Q/Z "SetFuncMenu(\""+FunctionName+"\")"
	
	return 0
end

Function FG_FinishEditProc()

	SVAR FunctionName = root:Packages:WM_GraphFunction:SubroutineLinkage:FunctionName
	SVAR includePath = root:Packages:WM_GraphFunction:SubroutineLinkage:FuncIncludePath

	DeleteFile/Z=2 includePath+".ipf"
	SaveNotebook/O $FunctionName as includePath+".ipf"
	if (Strlen(S_path) == 0)
		DoAlert 0, "Failed to save procedure text"
		return -1
	endif
	DoWindow/K $FunctionName
	Execute/P/Q "INSERTINCLUDE \""+includePath+"\""
	Execute/P/Q "COMPILEPROCEDURES "
	Execute/P/Q/Z "SetFuncMenu(\""+FunctionName+"\")"
	
	return 0
end
