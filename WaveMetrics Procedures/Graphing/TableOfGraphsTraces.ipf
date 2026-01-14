#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.3		// Shipped with Igor 6.3
#pragma Igorversion=6.0	// for optional function parameters

// TableOfGraphsTraces(graphName [,showHidden,alsoSubWindows])
//
// 	Creates a table containing containing the traces displayed in the named graph or subwindow (use "" for top graph).
//
//	If the two optional parameters are not specified, only the visible traces of the graph are added to the table,
//	and traces in any subwindows are ignored.
//
// JP121116, v6.3: Initial Revision, based on an idea by Howard Rodstein and Brian C. O'Regan.

Menu "Graph", dynamic
	WMTableOfActiveGraphMenu(), /Q, mTableOfGraphsTraces()
End

Function/S WMTableOfActiveGraphMenu()
	String win= WinName(0,1)
	if( strlen(win) )
		GetWindow $win activeSW
		win= S_Value
		return "New Table with "+win+"'s Traces"
	else
		return ""	// disappearing menu item
	endif
End

Proc mTableOfGraphsTraces(showHiddenYesNo,alsoSubWindowsYesNo)	// 1=Yes, 2 = No
	Variable showHiddenYesNo= 2			// default omits hidden traces, set showHiddenYesNo=1 to include them.
	Variable alsoSubWindowsYesNo = 2		// defaults to omit sub windows' traces, set alsoSubWindowsYesNo=1 to include them.
	Prompt showHiddenYesNo, "Hidden Traces:", popup, "Show Hidden Traces;Omit Hidden Traces;"
	Prompt alsoSubWindowsYesNo, "Traces in Subwindows:", popup, "Show Subwindow Traces;Omit Subwindow Traces;"

	String hostGraph= WinName(0,1)
	if( strlen(hostGraph) )
		GetWindow $hostGraph activeSW
		String activeSubwindow= S_Value
		TableOfGraphsTraces(activeSubwindow ,showHidden=(showHiddenYesNo==1),alsoSubWindows=(alsoSubWindowsYesNo==1))
	endif
End

Function TableOfGraphsTraces(graphName [,showHidden,alsoSubWindows])
	String graphName			// "" for top graph
	Variable showHidden			// specify showHidden=1 to show hidden traces
	Variable alsoSubWindows	// specify alsoSubWindows=1 to include traces in subwindows.
	
	if( ParamIsDefault(showHidden) )
		showHidden= 0	// defaults to all visible waves, not including hidden waves
	endif
	
	if( ParamIsDefault(alsoSubWindows) )
		alsoSubWindows= 0	// defaults to only waves in the named graph, not enclosed subwindows.
	endif
	
	Edit			// Create table
	String tableName= S_Name

	Variable flags= 0x1
	if( 0 == showHidden )
		flags += 0x4	// omit hidden traces
	endif
	
	String windows= graphName+";"
	if( alsoSubWindows )
		String children= ChildWindowList(graphName)
		Variable i = 0
		do
			String child = StringFromList(i, children)
			if (strlen(child) == 0)
				break									// No more windows.
			endif
			windows += graphName+"#"+child+";"
			i += 1
		while(1)
	endif
	
	Variable windex = 0
	do
		String win = StringFromList(windex, windows)
		if (strlen(win) == 0)
			break									// No more windows.
		endif
	
		String list = TraceNameList(win, ";", flags)
		Variable index = 0
		do
			String traceName = StringFromList(index, list)
			if (strlen(traceName) == 0)
				break									// No more traces.
			endif

			if (WaveExists(XWaveRefFromTrace(win, tracename)))
				WAVE wx = XWaveRefFromTrace(win, tracename)
				CheckDisplayed/W=$tableName wx
				if( V_Flag == 0 )
					AppendToTable/W=$tableName wx
				endif
			endif
		
			WAVE w = TraceNameToWaveRef(win, traceName)
			CheckDisplayed/W=$tableName w
			if( V_Flag == 0 )
				AppendToTable/W=$tableName w
			endif
			index += 1
		while(1)	
		windex += 1
	while(1)	
End
