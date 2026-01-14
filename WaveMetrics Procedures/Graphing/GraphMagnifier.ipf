#pragma rtGlobals=2		// Use modern global access method.
#pragma version 1.03
#pragma IgorVersion=4.00

#include <Axis Utilities>
#include <ControlBarManagerProcs>

//************************************************
// This procedure file provides a magnifying graph facility, allowing you to
// inspect details of a graph.
 // It creates a second graph just like your graph. The area to show in the magnified
 // graph can be either a region around the cursor (Mouse Magnifier) or a region delimited
 // by the graph cursors (Cursor Magnifier).
//************************************************

//************************************************
// I would like to acknowledge Ian Konen as the originator of the Mouse Magnifier idea. I borrowed
// a bit of his code for that. -John Weeks
//************************************************

//************************************************
//	Revision History
//	1.0		first release
//	1.01	added code to avoid a pre-existing control bar
//			does not copy controls from graph to the magnifier graph
//			shows info pane for a cursor magnifier (and hides again when finished)
//	1.02	Changed rtGlobals=1 to rtGlobals=2
//	1.03	Fixed bug: ExecuteWinRecreation() when running not in root data folder, inadvertently created a global 
//			variable "folderSav0" by using Execute on commands extracted from the window recreation macro used 
//			to create the magnifier graph. Window recreation macros create a string variable to restore the CDF; when
//			executed using Execute, it makes a global. If GraphMagnifier was used again later, this global causes an error.
//************************************************

Menu "Graph"
	SubMenu "Graph Magnifier"
		"Make Graph Magnifier", mMakeMagnifier()
		"Stop Magnifier", MagnifierDoneButtonProc("xxx")
		"Unload Graph Magnifier Package", Execute/P "DELETEINCLUDE  <GraphMagnifier>";Execute/P "COMPILEPROCEDURES "
	end
end

Proc mMakeMagnifier()

	PauseUpdate; Silent 1		// building window...
	NewPanel /K=2 /W=(232,273,463,457) as "Make Mouse Graph Magnifier"
	DoWindow/C MakeGraphMagnifier
	PopupMenu MagnifierGraphMenu,pos={60,12},size={111,20},title="Graph:", proc=MagnifierGraphMenuProc
	PopupMenu MagnifierGraphMenu,mode=1,value= #"WinList(\"*\", \";\", \"WIN:1\")"
	PopupMenu MouseMagVAxisMenu,pos={26,39},size={123,20},title="Vertical Axis:"
	PopupMenu MouseMagVAxisMenu,mode=1,value= #"MagListAxesInChosenGraph(0)"
	PopupMenu MouseMagHAxisMenu,pos={14,65},size={159,20},title="Horizontal Axis:"
	PopupMenu MouseMagHAxisMenu,mode=1,value= #"MagListAxesInChosenGraph(1)"
	PopupMenu MagnifierTypeMenu,pos={17,108},size={151,20},title="Magnifier type:"
	PopupMenu MagnifierTypeMenu,mode=1,value= #"\"Mouse;Cursor;\""
	Button MagnifierDoItButton,pos={48,150},size={50,20},proc=MakeMagnifierDoItButtonProc,title="Do It"
	Button MagnifierCancelButton,pos={108,150},size={50,20},proc=MakeMagnifierCancelButtonProc,title="Cancel"
EndMacro

Function MagnifierGraphMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	ControlUpdate/W=MakeGraphMagnifier/A
end

Function MakeMagnifierCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K MakeGraphMagnifier
	return 0
End

Function/S MagListAxesInChosenGraph(ListHorizontal)
	Variable ListHorizontal
	
	ControlInfo/W=MakeGraphMagnifier MagnifierGraphMenu
	return HVAxisList(S_value,ListHorizontal)
end

Function MakeMagnifierDoItButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo MagnifierGraphMenu
	String graphName = S_value
	ControlInfo MouseMagVAxisMenu
	String VAxis = S_value
	ControlInfo MouseMagHAxisMenu
	String HAxis = S_value
	Variable magtype = 2
	ControlInfo MagnifierTypeMenu
	if (V_value == 1)
		magtype = 2
	elseif (V_value == 2)
		magtype = 1
	endif
	MakeMagnifierPartOne(magtype, graphName, HAxis, VAxis)

	DoWindow/K MakeGraphMagnifier
End

Function/S ListTracesForMagnifier()

	ControlInfo/W=MakeGraphMagnifier MagnifierGraphMenu
	return TraceNameList(S_value, ";", 1)
end

Function MakeMagnifierPartOne(MagnifierType, GraphName, HAxis, VAxis)
	Variable MagnifierType
	String GraphName
	String HAxis		// if MagnifierType == 1 (cursor mag), Trace Name; == 2 (Mouse mag) vertical axis name
	String VAxis	// if MagnifierType == 1 (cursor mag), nothing; == 2 (Mouse mag) horizontal axis name
	
	if (WinType("MagnifierGraph") == 1)
		DoAlert 1, "A graph magnifier already exists. Coninue? It will destroy the current magnifier."
		if (V_flag == 2)
			return -1
		endif
		DoWindow/K MagnifierGraph
	endif
	
	String saveDF = GetDatafolder(1)
	NewDatafolder/S/O root:Packages
	NewDatafolder/S/O WM_Magnifier
	String/G MagnifiedGraph = graphName
	String/G MagnifiedHAxis = HAxis
	String/G MagnifiedVAxis = VAxis
	Variable/G hasInfoShowing = 0
	SetDatafolder saveDF
	
	Variable/G root:Packages:WM_Magnifier:GraphMagnifierType = MagnifierType

	DoWindow/F $graphName
//	DoWindow/C  MagnifierGraph
	String winrec = WinRecreation(graphName, 0)
	String controls = ControlNameList(graphName)
	if (strsearch(winrec, "\tShowInfo", 0) >= 0)
		hasInfoShowing = 1
	endif
	ExecuteWinRecreation(winrec, controls)
	DoWindow/C MagnifierGraph
	MakeMagnifierPartTwo()
//	Execute/P "DoWindow/R MagnifierGraph"
//	Execute/P "COMPILEPROCEDURES "
//	Execute/P "DoWindow/C "+graphName
//	Execute/P "MagnifierGraph()"
//	Execute/P "MakeMagnifierPartTwo()"
end

Function ExecuteWinRecreation(winrec, cList)
	String winrec
	String cList		// list of controls in original window. We don't want to execute commands that create controls
	
	variable beginline=0, endline
	Variable nchars = strlen(winrec)
	String aCommand
	
	// window recreation macro should run (at least to start with) in the root data folder
	String saveDF = GetDataFolder(1)
	SetDataFolder root:
	
	do
		endline = strsearch(winrec, "\r", beginLine)
		if (endline < 0)
			break
		endif
		aCommand = winrec[beginLine, endLine]
		beginLine = endLine+1
		if (strsearch(aCommand, "Window", 0) >= 0)
			continue
		endif
		if (strsearch(aCommand, "PauseUpdate", 0) >= 0)
			continue
		endif
		if (strsearch(aCommand, "\tControlBar ", 0) >= 0)
			continue
		endif
		if (strsearch(aCommand, "\tCursor ", 0) >= 0)
			continue
		endif
		if (strsearch(aCommand, "\tShowInfo", 0) >= 0)
			continue
		endif
		if (CmpStr(aCommand, "EndMacro\r") == 0)
			continue
		endif
		// fldrSav0 is a (local) string variable created by a graph recreation macro for a graph that uses
		// waves from a non-root data folder. If "String fldrSav0= GetDataFolder(1)" is executed by Execute, it makes
		// a global string. We don't need the saved data folder because we save it above, and the existence of the global in
		// the user's data folder will cause an error if the graph magnifier is shut down and re-started again later.
		// This line will also skip the line in which the recreation macro tries to restore the user's CDF using
		// "SetDataFolder fldrSav0"
		if (strsearch(aCommand, "fldrSav0", 0) >= 0)
			continue
		endif
		if (isControlCommand(aCommand, cList))
			continue
		endif
		Variable displayPos = strsearch(aCommand, "\tDisplay ", 0)
		if (displayPos >= 0)
			String tempStr = aCommand
			aCommand = "Display/K=1 "
			aCommand += tempStr[displayPos+9, strlen(tempStr)-1]
		endif
		Execute aCommand
	while (1)
	
	SetDataFolder saveDF
end

Function isControlCommand(aCommand, cList)
	string aCommand, cList
	
	Variable spacePos = strsearch(aCommand, " ", 1)		// "1" skips the tab character at the beginning
	if (spacePos < 0)
		return 0
	endif
	Variable commaPos = strsearch(aCommand, ",", spacePos)
	if (commaPos < 0)
		return 0
	endif
	String cName = aCommand[spacePos+1, commaPos-1]
	if (FindListItem(cName, cList) < 0)
		return 0
	endif
	
	return 1
end

Static Function/S PossiblyUnquoteTraceName(tname)
	String tname
	
	Variable nlen = strlen(tname)-1
	if (CmpStr(tname[nlen], "'") == 0)
		return tname[1,nlen]
	else
		return tname
	endif
end

static constant ControlBarDelta = 46

Function MakeMagnifierPartTwo()

	SVAR/Z graphName = root:Packages:WM_Magnifier:MagnifiedGraph
	SVAR/Z HAxis = root:Packages:WM_Magnifier:MagnifiedHAxis
	SVAR/Z VAxis = root:Packages:WM_Magnifier:MagnifiedVAxis
	NVAR/Z magFactor = root:Packages:WM_Magnifier:GraphMagnificationFactor
	NVAR/Z GraphMagnifierType = root:Packages:WM_Magnifier:GraphMagnifierType
	NVAR/Z hasInfoShowing = root:Packages:WM_Magnifier:hasInfoShowing

	Variable VMax, VMin, HMax, HMin
	GetAxis/Q/W=$graphName $VAxis
	VMax= V_max
	VMin = V_min
	GetAxis/Q/W=$graphName $HAxis
	HMax= V_max
	HMin = V_min
	
	if (GraphMagnifierType == 1)
		String tlist = TraceNameList(graphName, ";", 1)
		String ilist = ImageNameList(graphName, ";")
		String traceName = ""
		String tinfo
		Variable isImage = 0
		Variable numitems = ItemsInList(tlist)
		Variable i
		for (i = 0; i < numitems; i += 1)
			traceName = PossiblyUnquoteTraceName(StringFromList(i, tlist))
			tinfo = TraceInfo(graphName, traceName, 0)
			if (CmpStr(StringByKey("YAXIS", tinfo), VAxis) == 0)
				if (CmpStr(StringByKey("XAXIS", tinfo), HAxis) == 0)
					break
				endif
			endif
		endfor
		if (strlen(traceName) == 0)
			numitems = ItemsInList(ilist)
			if (numitems > 0)
				for (i = 0; i < numitems; i += 1)
					traceName = PossiblyUnquoteTraceName(StringFromList(i, ilist))
					tinfo = ImageInfo(graphName, traceName, 0)
					if (CmpStr(StringByKey("YAXIS", tinfo), VAxis) == 0)
						if (CmpStr(StringByKey("XAXIS", tinfo), HAxis) == 0)
							isImage = 1
							break
						endif
					endif
				endfor
			endif
			if (strlen(traceName) == 0)
				DoAlert 0, "Could not find a trace or an image that uses both selected axes: "+VAxis+" and "+HAxis
				return -1
			endif
		endif
		String/G root:Packages:WM_Magnifier:MagnifiedTrace = PossiblyQuoteName(traceName)
		if (isImage)
			if (WaveExists(CsrWaveRef(A, graphName)))
				Cursor/I/F/H=1/W=$graphName A $traceName hcsr(A, graphName),vcsr(A, graphName)
			else
				Cursor/I/F/H=1/P/W=$graphName A $traceName 0,1
			endif
			if (WaveExists(CsrWaveRef(B, graphName)))
				Cursor/I/F/H=1/W=$graphName B $traceName hcsr(B, graphName),vcsr(B, graphName)
			else
				Cursor/I/F/H=1/P/W=$graphName B $traceName 1,0
			endif
		else
			if (WaveExists(CsrWaveRef(A, graphName)))
				Cursor/F/H=1/W=$graphName A $traceName hcsr(A, graphName),vcsr(A, graphName)
			else
				Cursor/F/H=1/P/W=$graphName A $traceName 0,1
			endif
			if (WaveExists(CsrWaveRef(B, graphName)))
				Cursor/F/H=1/W=$graphName B $traceName hcsr(B, graphName),vcsr(B, graphName)
			else
				Cursor/F/H=1/P/W=$graphName B $traceName 1,0
			endif
		endif
		
		ShowInfo/W=$graphName
	endif
	
	Wave/Z yw = CsrWaveRef(A, "MagnifierGraph")
	if (WaveExists(yw))
		Cursor/K/W=MagnifierGraph A
	endif
	Wave/Z yw = CsrWaveRef(B, "MagnifierGraph")
	if (WaveExists(yw))
		Cursor/K/W=MagnifierGraph B
	endif

	String ControlsWindow = graphName
	String/G root:Packages:WM_Magnifier:MagnifierControlsWindow = ControlsWindow
	
//	SetAxis/W=MagnifierGraph left, VMin, VMax
//	SetAxis/W=MagnifierGraph bottom, HMin, HMax
//	ControlBar/W=$ControlsWindow 46
	Variable/G root:Packages:WM_Magnifier:CBTop
	String CBIdent=""
	Variable CBTop = ExtendControlBar(ControlsWindow, ControlBarDelta, CBIdent)
	String/G root:Packages:WM_Magnifier:CBIdentifier = CBIdent
	
	CheckBox MagnifierVertical,win=$ControlsWindow, pos={6,CBTop+5},size={126,14},proc=MagnifierCheckBoxProc,title="Vertical Magnification"
	CheckBox MagnifierVertical,win=$ControlsWindow, value= 1
	CheckBox MagnifierHorizontal,win=$ControlsWindow, pos={6,CBTop+24},size={138,14},proc=MagnifierCheckBoxProc,title="Horizontal Magnification"
	CheckBox MagnifierHorizontal,win=$ControlsWindow, value= 1
	Button MagnifierDoneButton,win=$ControlsWindow,pos={239,CBTop+12},size={50,20},proc=MagnifierDoneButtonProc,title="Done"
	if (GraphMagnifierType == 2)
		Variable/G root:Packages:WM_Magnifier:GraphYMagnificationFactor = 10
		Variable/G root:Packages:WM_Magnifier:GraphXMagnificationFactor = 10
		SetVariable SetYMagnifierFactor,win=$ControlsWindow,pos={154,CBTop+5},size={70,15},proc=SetMagnifierFactorProc,title="x"
		SetVariable SetYMagnifierFactor,win=$ControlsWindow,limits={1,Inf,5},value= root:Packages:WM_Magnifier:GraphYMagnificationFactor
		SetVariable SetXMagnifierFactor,win=$ControlsWindow,pos={154,CBTop+24},size={70,15},proc=SetMagnifierFactorProc,title="x"
		SetVariable SetXMagnifierFactor,win=$ControlsWindow,limits={1,Inf,5},value= root:Packages:WM_Magnifier:GraphXMagnificationFactor
		SetWindow $graphName hook=MouseMagnifierWindowHook, hookevents=2
	endif
	if (GraphMagnifierType == 1)
		SetWindow $graphName hook=CursorMagKillGraphWindowHook
	endif
	
	SetWindow MagnifierGraph hook=MagnifierKillWindowHook
	DoUpdate
	AutoPositionWindow/E/M=1/R=$graphName MagnifierGraph
	DoWindow/F $graphName
end

Function MagnifierDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR/Z GraphMagnifierType = root:Packages:WM_Magnifier:GraphMagnifierType
	NVAR/Z hasInfoShowing = root:Packages:WM_Magnifier:hasInfoShowing
	NVAR/Z CBTop = root:Packages:WM_Magnifier:CBTop
	SVAR/Z graphName = root:Packages:WM_Magnifier:MagnifiedGraph
	SVAR/Z ControlsWindow = root:Packages:WM_Magnifier:MagnifierControlsWindow
	SVAR/Z CBIdentifier = root:Packages:WM_Magnifier:CBIdentifier

	Variable startingCBHeight = GetControlBarHeight(ControlsWindow)
	Variable finishedCBHeight = startingCBHeight-ControlBarDelta
	String moveCList = ListControlsInControlBar(graphName, CBTop)
	
	KillControl/W=$ControlsWindow MagnifierVertical
	KillControl/W=$ControlsWindow MagnifierHorizontal
	KillControl/W=$ControlsWindow MagnifierDoneButton
	if (GraphMagnifierType == 2)
		KillControl/W=$ControlsWindow SetYMagnifierFactor
		KillControl/W=$ControlsWindow SetXMagnifierFactor
		SetWindow $graphName hook=$""
	else
		if (hasInfoShowing == 0)
			HideInfo/W=$ControlsWindow
		endif
	endif
	if (strlen(ctrlName) > 0)			// because kill event on the magnifier graph calls this function with ctrlName set to ""
		// The next statement is to prevent recursion- MagnifierKillWindowHook() calls this 
		// function because it needs to shut down if someone uses the Close Window button on the 
		// magnifier graph 
		SetWindow MagnifierGraph hook=$""
		DoWindow/K MagnifierGraph
	endif
	
//	MoveControls(moveCList, 0, -ControlBarDelta)	
//String CBIdent=""
	ContractControlBar(ControlsWindow, CBIdentifier, ControlBarDelta)

	KillDatafolder root:Packages:WM_Magnifier:
End

Function CursorMagKillGraphWindowHook(InfoStr)
	String infoStr

	String event= StringByKey("EVENT",infoStr)
	if (CmpStr(event, "kill") == 0)
		DoWindow/K MagnifierGraph		// and killing the window will cause MagnifierKillWindowHook to get called
	endif
	return 0
end

Function MagnifierKillWindowHook(infostr)
	String infoStr

	String event= StringByKey("EVENT",infoStr)
	if (CmpStr(event, "kill") == 0)
		MagnifierDoneButtonProc("")
	endif
	return 0
end

Function MagnificationTimesTenProc(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR/Z magYFactor = root:Packages:WM_Magnifier:GraphYMagnificationFactor
	NVAR/Z magXFactor = root:Packages:WM_Magnifier:GraphXMagnificationFactor
	SVAR/Z graphName = root:Packages:WM_Magnifier:MagnifiedGraph
	if (!NVAR_Exists(magYFactor) || !NVAR_Exists(magXFactor) || !SVAR_Exists(graphName))
		return 0
	endif
	magYFactor *= 10
	magXFactor *= 10
	DoWindow/F $graphName
end

Function MagnificationDivideTenProc(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR/Z magYFactor = root:Packages:WM_Magnifier:GraphYMagnificationFactor
	NVAR/Z magXFactor = root:Packages:WM_Magnifier:GraphXMagnificationFactor
	SVAR/Z graphName = root:Packages:WM_Magnifier:MagnifiedGraph
	if (!NVAR_Exists(magYFactor) || !NVAR_Exists(magXFactor) || !SVAR_Exists(graphName))
		return 0
	endif
	magYFactor /= 10
	magXFactor /= 10
	DoWindow/F $graphName
end

Function SetMagnifierFactorProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	SVAR/Z graphName = root:Packages:WM_Magnifier:MagnifiedGraph
	if (!SVAR_Exists(graphName))
		return 0
	endif
	DoWindow/F $graphName
End

Function MouseMagnifierWindowHook(infostr)
	String infoStr

	SVAR/Z graphName = root:Packages:WM_Magnifier:MagnifiedGraph
	SVAR/Z ControlsWindow = root:Packages:WM_Magnifier:MagnifierControlsWindow
	SVAR/Z HAxis = root:Packages:WM_Magnifier:MagnifiedHAxis
	SVAR/Z VAxis = root:Packages:WM_Magnifier:MagnifiedVAxis
	NVAR/Z magYFactor = root:Packages:WM_Magnifier:GraphYMagnificationFactor
	NVAR/Z magXFactor = root:Packages:WM_Magnifier:GraphXMagnificationFactor
	NVAR/Z GraphMagnifierType = root:Packages:WM_Magnifier:GraphMagnifierType
	if (!SVAR_Exists(graphName) || !NVAR_Exists(magYFactor) || !NVAR_Exists(magXFactor))
		return 0
	endif
	if (!NVAR_Exists(GraphMagnifierType) || (GraphMagnifierType != 2))
		return 0
	endif
	
	Variable yRange
	
	String event= StringByKey("EVENT",infoStr)
	StrSwitch(event)
		case "kill":
			MagnifierDoneButtonProc("")
			break
		case "mousemoved":
			ControlInfo/W=$ControlsWindow MagnifierVertical
			Variable magV = V_value
			ControlInfo/W=$ControlsWindow MagnifierHorizontal
			Variable magH = V_value
			Variable halffactor

			GetAxis/Q/W=$graphName $VAxis
			if (magV)
				variable mouseY = str2num(StringByKey("mousey",infoStr))
				Variable ypos = AxisValFromPixel(graphName, VAxis, mousey)
				halffactor = 2*magYfactor		// because we use half the range on either side of the center point
				yRange = abs(V_max - V_min)/halffactor
				SetAxis/W=MagnifierGraph $VAxis ypos - yRange/2, yPos + yRange
			else
				SetAxis/W=MagnifierGraph $VAxis V_min, V_max
			endif
			GetAxis/Q/W=$graphName $HAxis
			if (magH)
				variable mouseX = str2num(StringByKey("mousex",infoStr))
				Variable xpos = AxisValFromPixel(graphName, HAxis, mousex)
				halffactor = 2*magXfactor		// because we use half the range on either side of the center point
				Variable xRange = abs(V_max - V_min)/halffactor
				SetAxis/W=MagnifierGraph $HAxis xPos - xRange, xPos + xRange
			else
				SetAxis/W=MagnifierGraph $HAxis V_min, V_max
			endif
			break
	EndSwitch

	return 0
end

Function MagnifierCheckBoxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	SVAR/Z graphName = root:Packages:WM_Magnifier:MagnifiedGraph
	SVAR/Z traceName = root:Packages:WM_Magnifier:MagnifiedTrace
	if ( (!SVAR_Exists(graphName)) || (!SVAR_Exists(traceName)) )
		return 0
	endif
	CursorMovedHook("GRAPH:"+graphName+";TNAME:"+traceName)
End
	
Function CursorMovedHook(infoStr)
	String infoStr
	
	SVAR/Z graphName = root:Packages:WM_Magnifier:MagnifiedGraph
	SVAR/Z traceName = root:Packages:WM_Magnifier:MagnifiedTrace
	SVAR/Z ControlsWindow = root:Packages:WM_Magnifier:MagnifierControlsWindow
	SVAR/Z HAxis = root:Packages:WM_Magnifier:MagnifiedHAxis
	SVAR/Z VAxis = root:Packages:WM_Magnifier:MagnifiedVAxis
	if ( (!SVAR_Exists(graphName))  || (!SVAR_Exists(traceName))  || (!SVAR_Exists(ControlsWindow)) )
		return 0
	endif
	NVAR/Z GraphMagnifierType = root:Packages:WM_Magnifier:GraphMagnifierType
	if (!NVAR_Exists(GraphMagnifierType) || (GraphMagnifierType != 1))
		return 0
	endif
	if (CmpStr(graphName, StringByKey("GRAPH", infoStr)) == 0)		// it's the right graph
		if (CmpStr(traceName, StringByKey("TNAME", infoStr)) == 0)			// it's the right trace
			Variable VMagTop = vcsr(A, graphName)
			Variable VMagBottom = vcsr(B, graphName)
			Variable VMagLeft = hcsr(A, graphName)
			Variable VMagRight = hcsr(B, graphName)
			ControlInfo/W=$ControlsWindow MagnifierVertical
			Variable magV = V_value
			ControlInfo/W=$ControlsWindow MagnifierHorizontal
			Variable magH = V_value
			if (magV)
				SetAxis/W=MagnifierGraph $VAxis, min(VMagTop, VMagBottom), max(VMagTop, VMagBottom)
			else
				SetAxis/A/W=MagnifierGraph $VAxis
			endif
			if (magH)
				SetAxis/W=MagnifierGraph $HAxis, min(VMagLeft, VMagRight), max(VMagLeft, VMagRight)
			else
				SetAxis/A/W=MagnifierGraph $HAxis
			endif
		endif
	endif
	
	return 0
end