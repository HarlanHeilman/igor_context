#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=6.0	// requires Igor 6.0 or later
#pragma ModuleName=WindowBrowserModule
#pragma IndependentModule=WMWInBrowser
#include <SaveRestoreWindowCoords>
#include <HierarchicalListWidget>
#pragma version=7

//**********************************************************
//     VERSION HISTORY
// Initial Release had no version number...
// 1.01, JW
//		Added window hook so that upon activation the panel will update the top-level containers with
//		any new content that should be shown.
// 6.1, JP
//		Now an independent module.
//		DisplayProcedure works even if it contains no functions or strings or if procedures are uncompiled.
// 6.11, JW
//		Window Action menu Kill item now kills a subwindow if a subwindow is selected.
//		Added a refresh function to update contents.
//		Implemented hook function to refresh contents when the panel is activated.
//		Window Action menu refreshes contents after kill, generating window macro.
// 6.12, JW 101102
//		Cleaned up some things:
//			If the selection is not a window, the Act On Selection menu is disabled
//			If by some chance the menu is available but the selection is not a window (for instance, you selected "Graphs", but no actual graph) it will not try to kill a window called "graphs".
//			If the selection is the browser itself, you are asked if it should commit suicide. If yes, it avoids a run-time error by not trying to refresh the contents of the now-missing browser.
// 6.351, JP
//		PanelResolution fix after 6.35 was initially released.
// 7, JP
//		PanelResolution changes, uses Igor 7 SetWindow sizeLimit if available
// 7.01 JW
// 	Because the call to DisplayProcedure is in an independent module, the Graph Macros or Table Macros, etc.,
//		need to be preceded with "ProcGlobal#" in order to work
//**********************************************************

Menu "Control"
	Submenu "Window Browser"
		"Window Browser", WMWInBrowser#MakeWindowBrowser()
		"Unload Window Browser", WMWInBrowser#UnloadWindowBrowser()
	end
end

Function UnloadWindowBrowser()

	if (WinType("WMWindowBrowserPanel") == 7)
		DoWindow/K WMWindowBrowserPanel
	endif
	Execute/P "DELETEINCLUDE <WindowBrowser>"
end

static StrConstant TOPLEVELITEMS="Graphs;Tables;Control Panels;Notebooks;Layouts;Procedures;XOP Windows;Graph Macros;Table Macros;Layout Macros;Panel Macros;"
static Constant kMinPanelWidthPanelUnits = 240 	// panel units (pixels if GetResolution == 72, points otherwise)
static Constant kMinPanelHeightPanelUnits = 240 // panel units (pixels if GetResolution == 72, points otherwise)

Function MakeWindowBrowser()

	String win= "WMWindowBrowserPanel"

	if (WinType(win) == 7)
		DoWindow/F WMWindowBrowserPanel
	else
		String savedDF = GetDatafolder(1)
		SetDatafolder root:
		NewDataFolder/O/S Packages
		NewDataFolder/O/S WMWindowBrowser
			String/G gWB_FindString = ""
		SetDataFolder savedDF
		
		DoWindow/K $win	// in case it exists as a non-panel
//		NewPanel/K=1/W=(50,50,341,354) as "Window Browser"
		string cmd = "NewPanel /K=1/W=(%s) as \"Window Browser\""
		Variable left= 50, top=50
		Variable right= left + kMinPanelWidthPanelUnits
		Variable bottom= top + kMinPanelHeightPanelUnits
		cmd= WC_WindowCoordinatesSprintf(win, cmd, left, top, right, bottom, 1)
		Execute/Q/Z cmd
		DoWindow/C WMWindowBrowserPanel

		ListBox WM_WindowBrowserListbox,pos={9,13},size={222,160}
		MakeListIntoHierarchicalList(win, "WM_WindowBrowserListbox", "WindowBrowserModule#WMWB_OpenNotify")
		WMHL_SetNotificationProc(win, "WM_WindowBrowserListbox", "WindowBrowserModule#WMWB_Notification", WMHL_SetSelectNotificationProc)

		Variable i
		Variable nTopLevelItems = ItemsInList(TOPLEVELITEMS)
		for (i = 0; i < nTopLevelItems; i += 1)
			WMHL_AddObject(win, "WM_WindowBrowserListbox", "", StringFromList(i, TOPLEVELITEMS), 1)
		endfor

//		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", "", "Graphs", 1)
//		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", "", "Tables", 1)
//		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", "", "Control Panels", 1)
//		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", "", "Notebooks", 1)
//		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", "", "Layouts", 1)
//		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", "", "Procedures", 1)
//		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", "", "XOP Windows", 1)
//		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", "", "Graph Macros", 1)
//		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", "", "Table Macros", 1)
//		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", "", "Layout Macros", 1)
//		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", "", "Panel Macros", 1)

		SetVariable WMWB_SetFindString,pos={9,216},size={222,13},proc=WMWB_SetFindStringProc,title="Find:"
		SetVariable WMWB_SetFindString,format="%g"
		SetVariable WMWB_SetFindString,value= root:Packages:WMWindowBrowser:gWB_FindString
	
		Button WMWB_CloseAllButton,pos={22,180},size={70,20},proc=WindowBrowserModule#WMWB_CloseAllButtonProc,title="Close All"

		PopupMenu WMWB_ActOnWindowMenu,pos={114,180},size={117,20},proc=WindowBrowserModule#WMWB_ActOnWindowMenuProc,title="Act on Selection"
		PopupMenu WMWB_ActOnWindowMenu,mode=0,value= #"\"Bring Forward;Save Recreation Macro;Save Macro and Kill;Kill;\""

		SetWindow WMWindowBrowserPanel, hook(WMWB_ResizeHook)=WindowBrowserModule#WMWB_ResizeHook
		SetWindow WMWindowBrowserPanel, hook(WMWB_ActivateHook)=WindowBrowserModule#WMWB_ActivateHook

		WMWB_SetWinSizeMinSize(win, kMinPanelWidthPanelUnits, kMinPanelHeightPanelUnits)

		WMWB_PanelResizeControls(win)
	endif
End

// returns truth that a minimum sizeLimit was set.
static Function WMWB_SetWinSizeMinSize(win,minwidthPanelUnits,minheightPanelUnits)
	String win
	Variable minwidthPanelUnits,minheightPanelUnits

#if IgorVersion() >= 7
	Variable minwidthPoints= minwidthPanelUnits * PanelResolution(win)/ScreenResolution	// now points
	Variable minHeightPoints= minheightPanelUnits * PanelResolution(win)/ScreenResolution
	SetWindow $win sizeLimit={minwidthPoints, minHeightPoints, Inf, Inf}	// no max size.
	return 1	// set size limit
#else
	if( minwidthPanelUnits > 0 && minheightPanelUnits > 0 )
		WMWB_PanelMinWindowSize(win,minwidthPanelUnits,minheightPanelUnits)
	endif
	return 0 // didn't set size limit, but did enforce min size
#endif
End

static Function WMWB_PanelMinWindowSize(win, minWidthPanelUnits, minHeightPanelUnits)
	String win
	Variable minWidthPanelUnits,minHeightPanelUnits // panel units (pixels if GetResolution == 72, points otherwise)

	Variable minWidthPoints= minWidthPanelUnits * PanelResolution(win) / ScreenResolution
	Variable minHeightPoints= minHeightPanelUnits * PanelResolution(win) / ScreenResolution
	
	GetWindow $win wsize	// points
	Variable width= V_right-V_left
	Variable height= V_bottom-V_top
	Variable neededWidth= max(width,minWidthPoints)
	Variable neededHeight= max(height,minHeightPoints)
	Variable resizePending= (neededWidth-1 > width) || (neededHeight-1 > height) // -1 to accomodate pixel errors
	if( resizePending )
		// Eventually: MoveWindow/W=$win V_left, V_top, V_left+neededWidth, V_top+neededHeight
		// To prevent WMWB_SetPanelSize commands from piling up, we set a flag that the minimizer has been scheduled to run.
		// To avoid global variables, we use userdata on the window being resized.
		String setPanelSizeScheduledStr= GetUserData(win,"","setPanelSizeScheduled")	// "" if never set (means "no")
		if( strlen(setPanelSizeScheduledStr) == 0 )
			SetWindow $win, userdata(setPanelSizeScheduled)= "yes"
			String cmd
			//sprintf cmd, "MoveWindow/W=%s %g,%g,%g,%g", win, V_left, V_top, V_left+neededWidth, V_top+neededHeight
			String module= GetIndependentModuleName()+"#WindowBrowserModule#"
			sprintf cmd, "%WMWB_SetPanelSize(\"%s\",%g,%g,%g,%g)", module, win, V_left, V_top, V_left+neededWidth, V_top+neededHeight
			Execute/P/Q/Z cmd	// after the functions stop executing, the MoveWindow will provoke another resize event.
		endif
	endif
	return resizePending	
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

Static Function WMWB_SetPanelSize(panelName,leftPoints, topPoints, rightPoints, bottomPoints)
	String panelName
	Variable leftPoints, topPoints, rightPoints, bottomPoints

	DoWindow $panelName
	if( V_Flag )
		MoveWindow/W=$panelName leftPoints, topPoints, rightPoints, bottomPoints
		SetWindow $panelName, userdata(setPanelSizeScheduled)= ""	// allow another call to WMWB_SetPanelSize().
		WMWB_PanelResizeControls(panelName)
	endif
	return V_Flag	
End


// fits controls to window
static Function WMWB_PanelResizeControls(win)
	String win
	
	if( PanelResolution(win) == 72 )
		GetWindow $win wsizeDC
	else
		GetWindow $win wsize
	endif
	Variable width= V_right - V_left
	Variable height= V_bottom-V_top
	
	ControlInfo/W=$win WM_WindowBrowserListbox
	Variable margin= V_left
	Variable fullWidth= width-margin*2
	ListBox WM_WindowBrowserListbox,win=$win,size={fullWidth,height-80}
	SetVariable WMWB_SetFindString,win=$win,pos={margin,height-24},size={fullWidth, 15}

	ControlInfo/W=$win WMWB_CloseAllButton
	Button WMWB_CloseAllButton,win=$win,pos={V_left,height-60}
	ControlInfo/W=$win WMWB_ActOnWindowMenu
	PopupMenu WMWB_ActOnWindowMenu,pos={V_left,height - 60}
end


Function WMWB_ResizeHook(H_Struct)
	STRUCT WMWinHookStruct &H_Struct
	
	Variable statusCode = 0
	String win= H_Struct.winName
	
	strswitch (H_Struct.eventName)
		case "resize":		// resize event
			Variable tooSmall= WMWB_PanelMinWindowSize(win, kMinPanelWidthPanelUnits, kMinPanelHeightPanelUnits)
			if( !tooSmall )	// don't bother resizing if another resize event is pending
				WMWB_PanelResizeControls(win)
			endif
			statusCode=1
			break;
		case "kill":		// window being killed
			WC_WindowCoordinatesSave(win)
			break;
	endswitch

	return statusCode		// 0 if nothing done, else 1
End

Function WMWB_ActivateHook(H_Struct)
	STRUCT WMWinHookStruct &H_Struct
	
	Variable statusCode = 0
	
	if  (H_Struct.eventCode == 0)		// panel window activated
		SetWindow $H_Struct.winName, userdata(setPanelSizeScheduled)= ""	// avoid locking out calls to WMWB_SetPanelSize().
		WMWB_RefreshContents()
	endif

	return statusCode		// 0 if nothing done, else 1
End


static Function WMWB_OpenNotify(HostWindow, ListControlName, ContainerPath)
	String HostWindow, ListControlName, ContainerPath
	
	String windowtype = ParseFilePath(0, ContainerPath, ":", 1, 0)
	AddWindowsToList(HostWindow, ListControlName, windowType, ContainerPath)
end

static Function WMWB_Notification(panelname, ctrlname, SelectedItem, EventCode)
	String panelname, ctrlname
	String SelectedItem
	Variable EventCode
	
	String windowPath
	String windowName
	
	if (EventCode == 3)		// double-click
		windowPath = GetChildPathFromContainerPath(SelectedItem)
		windowName = ParseFilePath(0, windowPath, "#", 0, 0)
		if (strlen(windowName) > 0)
			if (ItemIsWindowMacro(SelectedItem))
				String procname = ParseFilePath(0, SelectedItem, ":", 0, 1)
				DisplayProcedure "ProcGlobal#"+procname
			elseif(ItemIsProcedure(SelectedItem))
				String procWinStr = ParseFilePath(0, SelectedItem, ":", 0, 1)
				if (!BringProcedureForward(procWinStr))
					DoAlert 0, "Could not find a function or macro in procedure window \""+procWinStr+"\""
				endif
			elseif (WinType(windowName) > 0)
				DoWindow/F $windowName
				if (WintypeCanHaveChildren(WinType(windowName)))
					SetActiveSubwindow $windowPath
				endif
			endif
		endif
	elseif ( (EventCode == 4) || (EventCode == 5) )
		String selectedItems = WMHL_SelectedObjectsList(panelname, ctrlname)
		Variable nItems = ItemsInList(selectedItems)
		Variable i
		Variable windowSelected = 0
		for (i = 0; i < nItems; i += 1)
			windowPath = GetChildPathFromContainerPath(StringFromList(i, selectedItems))
			windowName = ParseFilePath(0, windowPath, "#", 0, 0)
			if ( (strlen(windowName) > 0) && (WinType(windowName) > 0) )
				windowSelected = 1
				break;
			endif
		endfor
		PopupMenu WMWB_ActOnWindowMenu, win=$(panelName), disable = windowSelected ? 0 : 2
	endif
end

static Function BringProcedureForward(procWinStr)
	String procWinStr
	
	DisplayProcedure/W=$procWinStr		// Igor 6 feature
	return 1
end

static Function AddWindowsToList(HostWindow, ListControlName, windowType, parentPath)
	String HostWindow, ListControlName, windowType, parentPath

	Variable i
	Variable nitems
	String windowList
	String oneitem
	
	String parentname = ParseFilePath(0, parentPath, ":", 1, 1)
	String childpath
	Variable isContainer = 1

	StrSwitch(windowType)
		case "Graphs":
			windowList = WindowListOfType(GetChildPathFromContainerPath(parentPath), 1)
			break;
		case "Tables":
			windowList = WindowListOfType(GetChildPathFromContainerPath(parentPath), 2)
			break;
		case "Control Panels":
			windowList = WindowListOfType(GetChildPathFromContainerPath(parentPath), 7)
			break;
		case "Notebooks":
			windowList = WindowListOfType(GetChildPathFromContainerPath(parentPath), 5)
			isContainer = 0
			break;
		case "Layouts":
			windowList = WindowListOfType(GetChildPathFromContainerPath(parentPath), 3)
			break;
		case "Procedures":
			windowList = WinList("*", ";", "WIN:128" )
			isContainer = 0
			break;
		case "XOP Windows":
			windowList = WinList("*", ";", "WIN:4096" )
			isContainer = 0
			break;
		case "Graph Macros":
			windowList = MacroList("*", ";", "KIND:4,SUBTYPE:Graph")
			isContainer = 0
			break;
		case "Table Macros":
			windowList = MacroList("*", ";", "KIND:4,SUBTYPE:Table")
			isContainer = 0
			break;
		case "Layout Macros":
			windowList = MacroList("*", ";", "KIND:4,SUBTYPE:Layout")
			isContainer = 0
			break;
		case "Panel Macros":
			windowList = MacroList("*", ";", "KIND:4,SUBTYPE:Panel")
			isContainer = 0
			break;
		default:
			String leafname = ParseFilePath(0, parentPath, ":", 1, 0)
			WMHL_AddSubItems(leafname, parentname, parentPath)
			return 0
			break;
	endswitch

	nitems = ItemsInList(windowList)
	for (i = 0; i < nitems; i += 1)
		oneitem = StringFromList(i, windowList)
		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, oneitem, isContainer)
	endfor
end

Static Function/S WindowListOfType(parentWindow, type)
	String parentWindow
	Variable type
	
	String theList
	String winstr
	if (strlen(parentWindow) == 0)
		sprintf winstr, "WIN:%d", 2^(type-1)
		theList = WinList("*", ";", winstr)
	else
		theList = ChildListOfType(parentWindow, type)
	endif
	
	return theList
end

static Function/S GetChildPathFromContainerPath(containerPath)
	String containerPath
	
	String thePath = ParseFilePath(0, containerPath, ":", 0, 1)		// the second item is a window name
	if (strlen(thePath) == 0)
		return ""
	endif
	
	Variable index = 2
	do
		String oneElement = ParseFilePath(0, containerPath, ":", 0, index)
		if (strlen(oneElement) == 0)
			break;
		endif
		if (CmpStr(oneElement, "Subwindows") == 0)
			index += 2		// skip the item that says "Graphs" or "Tables", etc.
			String NextItem = ParseFilePath(0, containerPath, ":", 0, index)
			if (strlen(NextItem) > 0)
				thePath += "#"+NextItem
			endif
		endif
		
		index += 1
	while(1)
	
	return thePath
end

static Function/S ChildListOfType(parentPath, type)
	String parentPath
	Variable type
	
	String allWindowList = ChildWindowList(parentPath)
	String returnList = ""
	Variable nItems = ItemsInList(allWindowList)
	Variable i
	for (i = 0; i < nItems; i += 1)
		String anItem = StringFromList(i, allWindowList)
		if (WinType(parentPath+"#"+anItem) == type)
			returnList += anItem+";"
		endif
	endfor
	
	return returnList
end

static Function WMHL_AddSubItems(leafname, parentname, parentPath)
	String leafname, parentname, parentPath
	
	Variable i
	Variable nitems
	String itemList
	String oneitem
	Variable isContainer
	String windowPath

	strswitch (leafname)
		// things for graphs
		case "Traces":
			windowPath = GetChildPathFromContainerPath(parentPath)
			itemList = TraceNameList(windowPath, ";", 1)
			isContainer = 1
			break;
		case "Axes":
			windowPath = GetChildPathFromContainerPath(parentPath)
			itemList = AxisList(windowPath)
			isContainer = 1
			break;
		case "Subwindows":
			windowPath = GetChildPathFromContainerPath(parentPath)
			if (strlen(WindowListOfType(windowPath, 1)) > 0)
				WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, "Graphs", 1)
			endif
			if (strlen(WindowListOfType(windowPath, 2)) > 0)
				WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, "Tables", 1)
			endif
			if (strlen(WindowListOfType(windowPath, 7)) > 0)
				WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, "Control Panels", 1)
			endif
			return 0
			break;
		case "Controls":
			windowPath = GetChildPathFromContainerPath(parentPath)
			itemList = ControlNameList(windowPath)
			isContainer = 0
			break;
		case "Layout Objects":
			windowPath = GetChildPathFromContainerPath(parentPath)
			itemList = ""
			i = 0
			do
				String Linfo = LayoutInfo(windowPath, num2str(i))
				if (strlen(Linfo) == 0)
					break;
				endif
				itemList += StringByKey("TYPE", Linfo)+":"
				itemList += StringByKey("NAME", Linfo)+";"
				i += 1
			while(1)
			isContainer = 0
			break;
		default:
			strswitch (parentname)
				case "Graphs":
					WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, "Traces", 1)
					WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, "Axes", 1)
					if (strlen(ChildWindowList(GetChildPathFromContainerPath(parentPath))) > 0)
						WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, "Subwindows", 1)
					endif
					return 0
					break;
				case "Axes":
					windowPath = GetChildPathFromContainerPath(parentPath)
					itemList = TraceListForAxis(windowPath, ParseFilePath(0, parentPath, ":", 1, 0))
					isContainer = 0
					break;
				case "Traces":
					String tinfo = TraceInfo(GetChildPathFromContainerPath(parentPath), leafname, 0)
					String yRange = StringByKey("YRANGE", tinfo)
					if (CmpStr(yRange, "[*]") == 0)
						yRange = ""
					endif
					String xRange = StringByKey("XRANGE", tinfo)
					if (CmpStr(xRange, "[*]") == 0)
						xRange = ""
					endif
					Wave yw = TraceNameToWaveRef(GetChildPathFromContainerPath(parentPath), leafname)
					Wave/Z xw = XWaveRefFromTrace(GetChildPathFromContainerPath(parentPath), leafname)
					itemList = "Y Wave "+GetWavesDataFolder(yw, 2)+yRange+";"
					if (WaveExists(xw))
						itemList += "X Wave "+GetWavesDataFolder(xw, 2)+xRange+";"
					else
						itemList += "X Wave _calculated_"
					endif
					isContainer = 0
					break;
				case "Control Panels":
					WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, "Controls", 1)
					if (strlen(ChildWindowList(GetChildPathFromContainerPath(parentPath))) > 0)
						WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, "Subwindows", 1)
					endif
					return 0
					break;
				case "Tables":
					i = 0
					itemList = ""
					do
						Wave/Z w = WaveRefIndexed(GetChildPathFromContainerPath(parentPath), i, 1)
						if (!WaveExists(w))
							break;
						endif
						itemList = AddUniquelyToList(GetWavesDataFolder(w,2), ItemList)
						
						i += 1
					while (1)
					IsContainer = 0
					break;
				case "Layouts":
					WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, "Layout Objects", 1)
					if (strlen(ChildWindowList(GetChildPathFromContainerPath(parentPath))) > 0)
						WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, "Subwindows", 1)
					endif
					return 0
					break;
			endswitch
			break;
	endswitch

	nitems = ItemsInList(itemList)
	for (i = 0; i < nitems; i += 1)
		oneitem = StringFromList(i, itemList)
		WMHL_AddObject("WMWindowBrowserPanel", "WM_WindowBrowserListbox", parentPath, oneitem, isContainer)
	endfor
end

Static Function/S TraceListForAxis(GraphNameStr, AxisNameStr)
	String GraphNameStr, AxisNameStr
	
	String traces = TraceNameList(graphNameStr, ";", 1 )
	Variable nItems = ItemsInList(traces)
	Variable i
	String theList = ""
	
	for (i = 0; i < nItems; i += 1)
		String onetrace = StringFromList(i, traces)
		String info = TraceInfo(GraphNameStr, oneTrace, 0)
		if ( (CmpStr(AxisNameStr, StringByKey("XAXIS", info)) == 0) || (CmpStr(AxisNameStr, StringByKey("YAXIS", info)) == 0) )
			theList += onetrace+";"
		endif
	endfor
	
	return theList
end

Static Function/S AddUniquelyToList(item, list)
	String item, list
	
	if (WhichListItem(item, list) < 0)
		list += item+";"
	endif
	
	return list
end

Function WMWB_SetFindStringProc(SV_Struct)
	STRUCT WMSetVariableAction &SV_Struct
	
	if (SV_Struct.eventCode == 2)
		WMWB_FindStringAndSelectItems()
	endif
End

static Function WMWB_FindGoButtonProc(ctrlName) : ButtonControl
	String ctrlName

	WMWB_FindStringAndSelectItems()
End

static Function WMWB_FindStringAndSelectItems()

	SVAR gWB_FindString = root:Packages:WMWindowBrowser:gWB_FindString
	String Windownames = SearchWindowNamesForString(gWB_FindString)
	if (strlen(WindowNames) > 0)
		Variable items = ItemsInList(WindowNames)
		Variable i
		WMHL_ClearSelection("WMWindowBrowserPanel", "WM_WindowBrowserListbox")
		for (i = 0; i < items; i += 1)
			String onewindow = StringFromList(i, WindowNames)
			String browserItem = ConstructBrowserItemFromWinPath(onewindow)
			OpenFullItemPath(browserItem)
			Variable theRow = WMHL_GetRowNumberForItem("WMWindowBrowserPanel", "WM_WindowBrowserListbox", browserItem)
			WMHL_SelectARow("WMWindowBrowserPanel", "WM_WindowBrowserListbox", theRow, 0)
		endfor
	endif
end

static Function/S SearchWindowNamesForString(FindString)
	String FindString
	
	String windows
	Variable i
	Variable items
	String aWindow
	String ListOfWindows=""
	
	windows = WinList("*", ";", "WIN:1") + WinList("*", ";", "WIN:2") + WinList("*", ";", "WIN:64") + WinList("*", ";", "WIN:16") + WinList("*", ";", "WIN:4") + WinList("*", ";", "WIN:128") + WinList("*", ";", "WIN:4096")
	items = ItemsInList(windows)
	for (i = 0; i < items; i += 1)
		aWindow = StringFromList(i, windows)
		if (StrLen(aWindow) == 0)
			break;
		endif
		if (StringMatch(aWindow, FindString))
			ListOfWindows += aWindow+";"
		endif
		if (WinTypeCanHaveChildren(WinType(aWindow)))
			recurseFindNameInChildren(FindString, aWindow, ListOfWindows)
//			if (strlen(subWindow) > 0)
//				ListOfWindows += subWindows
//			endif
		endif
	endfor
	
	return ListOfWindows
end

static Function recurseFindNameInChildren(FindString, HostWindow, ListOfWindows)
	String FindString
	String HostWindow
	String &ListOfWindows

	if (WinType(HostWindow) == 2)
		return 0		// tables can't have children
	endif
	String children = ChildWindowList(HostWindow)
	if (strlen(children) == 0)
		return 0
	endif
	Variable i
	Variable items
	items = ItemsInList(children)
	for (i = 0; i < items; i += 1)
		String aWindow = StringFromList(i, children)
		if (StrLen(aWindow) == 0)
			break;
		endif
		String LeafName = ParseFilePath(0, aWindow, "#", 1, 0)
		if (StringMatch(LeafName, FindString))
			ListOfWindows += HostWindow+"#"+aWindow+";"
		endif
		recurseFindNameInChildren(FindString, HostWindow+"#"+aWindow, ListOfWindows)
//		if (strlen(subWindow) > 0)
//			return subWindow
//		endif
	endfor
	
	return 0
end

static Function/S ConstructBrowserItemFromWinPath(winPath)
	String winPath
	
	String rootName = ParseFilePath(0, winPath, "#", 0, 0)
	String itemPath = TitleStringForWinType(wintype(rootname)) +":"+ rootName
	Variable index = 1
	String partialPath = rootName
	do
		String nextName = ParseFilePath(0, winPath, "#", 0, index)
		if (strlen(nextName) == 0)
			break;
		endif
		partialPath += "#"+nextName
		itemPath += ":Subwindows:"+TitleStringForWinType(wintype(partialPath))+":"+nextName
	
		index += 1
	while(1)
	
	return itemPath
end

static Function/S TitleStringForWinType(windowType)
	Variable windowType
	
	switch (windowType)
		case 0:
			return "Procedures"		// this isn't really right, but procedure windows are the only kind that don't work with WinType()
		case 1:
			return "Graphs"
		case 2:
			return "Tables"
		case 3:
			return "Layouts"
		case 5:
			return "Notebooks"
		case 7:
			return "Control Panels"
		case 13:
			return "XOP Windows"
	endswitch

	return ""
end

static Function OpenFullItemPath(itemPath)
	String itemPath
	
	Variable index = 0
	Variable items = ItemsInList(itemPath, ":")
	String nextItem = StringFromList(0, itemPath, ":")
	String PartialPath = nextItem
	WMHL_OpenAContainer("WMWindowBrowserPanel", "WM_WindowBrowserListbox", PartialPath)
	Variable i
	for (i = 1; i < items; i += 1)
		nextItem = StringFromList(i, itemPath, ":")
		if (strlen(nextItem) == 0)
			break;
		endif
		PartialPath += ":"+nextItem
		WMHL_OpenAContainer("WMWindowBrowserPanel", "WM_WindowBrowserListbox", PartialPath)
	endfor
end

static Function WinTypeCanHaveChildren(windowType)
	Variable windowType		// the window type code as returned by WinType()
	
	switch(windowType)
		case 1:
		case 3:
		case 7:
			return 1
			break;
		default:
			return 0
			break;
	endswitch
end

static Function WinTypeHasRecreationMacro(windowType)
	Variable windowType		// the window type code as returned by WinType()
	
	switch(windowType)
		case 1:
		case 2:
		case 3:
		case 7:
			return 1
			break;
		default:
			return 0
			break;
	endswitch
end

static Function ItemIsProcedure(itemStr)
	String itemStr
	
	String Titlestr = ParseFilePath(0, itemStr, ":", 0, 0)
	if (CmpStr(Titlestr, "Procedures") == 0)
			return 1
	endif
	
	return 0
end

static Function ItemIsWindowMacro(itemStr)
	String itemStr
	
	String Titlestr = ParseFilePath(0, itemStr, ":", 0, 0)
	strswitch(Titlestr)
		case "Graph Macros":
		case "Table Macros":
		case "Layout Macros":
		case "Panel Macros":
			return 1
	endswitch
	
	return 0
end

static Function WMWB_CloseAllButtonProc(ctrlName) : ButtonControl
	String ctrlName

	WMWB_CloseAllToplevelItems()
End

Function WMWB_CloseAllToplevelItems()

	Variable i
	for (i = 0; i < WMHL_GetNumberOfRows("WMWindowBrowserPanel", "WM_WindowBrowserListbox"); i += 1)
		String theItem = WMHL_GetItemForRowNumber("WMWindowBrowserPanel", "WM_WindowBrowserListbox", i)
		WMHL_CloseAContainer("WMWindowBrowserPanel", "WM_WindowBrowserListbox", theItem)
	endfor
end

// "Bring Forward;Save Recreation Macro;Save Macro and Kill;Kill;"
Function WMWB_ActOnWindowMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String selectedItems = WMHL_SelectedObjectsList("WMWindowBrowserPanel", "WM_WindowBrowserListbox")
	Variable nItems = ItemsInList(selectedItems)
	String oneItem
	Variable i
	Variable rowNumber
	String WindowPath
	String mainWindow
	
	strswitch(popStr)
		case "Bring Forward":
			for (i = 0; i < nItems; i += 1)
				oneItem = StringFromList(i, selectedItems)
				WindowPath = GetChildPathFromContainerPath(oneItem)
				mainWindow = ParseFilePath(0, WindowPath, "#", 0, 0)
				if (strlen(mainWindow) > 0)
					if (WinType(mainWindow) > 0)
						DoWindow/F $mainWindow
						if (WintypeCanHaveChildren(WinType(mainWindow)))
							SetActiveSubwindow $WindowPath
						endif
					elseif(ItemIsProcedure(oneItem))
						String procWinStr = ParseFilePath(0, oneItem, ":", 0, 1)
						if (!BringProcedureForward(procWinStr))
							DoAlert 0, "Could not find a function or macro in procedure window \""+procWinStr+"\""
						endif
					endif
				endif
			endfor
			break;
		case "Save Recreation Macro":
			for (i = 0; i < nItems; i += 1)
				oneItem = StringFromList(i, selectedItems)
				oneItem = GetChildPathFromContainerPath(oneItem)
				oneItem = ParseFilePath(0, oneItem, "#", 0, 0)
				if (strlen(oneItem) > 0)
					if (WinTypeHasRecreationMacro(WinType(oneItem)))
						Execute/P/Q/Z "DoWindow/R "+oneItem
						WMWB_RefreshContents()
					endif
				endif
			endfor
			break;
		case "Save Macro and Kill":
			for (i = 0; i < nItems; i += 1)
				oneItem = StringFromList(i, selectedItems)
				oneItem = GetChildPathFromContainerPath(oneItem)
				oneItem = ParseFilePath(0, oneItem, "#", 0, 0)
				if (strlen(oneItem) > 0)
					if (WinTypeHasRecreationMacro(WinType(oneItem)))
						if ( (WinType(oneItem) == 7) && (CmpStr(oneItem, "WMWindowBrowserPanel") == 0) )
							DoAlert 1, "Should I really commit suicide?"
							if (V_flag != 1)
								return -1
							endif
						endif
						// in this case, it's OK to commit suicide and refresh contents, because the kill is done later when queued commands are executed.
						Execute/P/Q/Z "DoWindow/R/K "+oneItem
						WMWB_RefreshContents()
					endif
				endif
			endfor
			break;
		case "Kill":
			DoAlert 1,"Are you sure you want to kill the selected window and any contained subwindows?"
			if (V_flag == 1)
				for (i = 0; i < nItems; i += 1)
					oneItem = StringFromList(i, selectedItems)
					windowPath = GetChildPathFromContainerPath(oneItem)
					if (strlen(oneItem) > 0)
						if ( (strlen(windowPath) > 0) && (WinType(windowPath) > 0) )
							Variable suicide = 0
							if ( (WinType(windowPath) == 7) && (CmpStr(windowPath, "WMWindowBrowserPanel") == 0) )
								DoAlert 1, "Should I really commit suicide?"
								if (V_flag != 1)
									return -1
								endif
								suicide = 1
							endif
							KillWindow $windowPath
							// if committing suicide, there's nothing left to refresh
							if (!suicide)
								WMWB_RefreshContents()
							endif
						endif
					endif
				endfor
			endif
			break;
	endswitch
End

Function WMWB_RefreshContents()
	
	String OpenItemList = ""
	Variable rowNumber
	String thisItem
	
	Variable i = 0
	do
		thisItem = WMHL_GetItemForRowNumber("WMWindowBrowserPanel", "WM_WindowBrowserListbox", i)
		if (strlen(thisItem) == 0)
			break;
		endif
		
		if (WMHL_RowIsContainer("WMWindowBrowserPanel", "WM_WindowBrowserListbox", i) && WMHL_RowIsOpen("WMWindowBrowserPanel", "WM_WindowBrowserListbox", i))
			OpenItemList += thisItem+";"
		endif
		
		i += 1
	while(1)
	
	WMWB_CloseAllToplevelItems()
	
	Variable nItems = ItemsInList(OpenItemList)
	for (i = 0; i < nItems; i += 1)
		thisItem = StringFromList(i, OpenItemList)
		rowNumber = WMHL_GetRowNumberForItem("WMWindowBrowserPanel", "WM_WindowBrowserListbox", thisItem)
		if (rowNumber >= 0)				// item still exists
			WMHL_OpenAContainer("WMWindowBrowserPanel", "WM_WindowBrowserListbox", thisItem)
		endif
	endfor
end