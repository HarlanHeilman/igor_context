#pragma rtGlobals=3				// Use modern global access method.
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma IgorVersion=9.0			// requires Igor 9
#pragma version=9.005			// shipped with Igor 9.01
#pragma IndependentModule=WM_SubwindowInGraph

// InsertSubwindowInGraph.ipf
// Menu interface to inserting an existing table or graph within another existing graph.
//
// Version 6.12, JP:		Fixed bugs when there is only one graph window,
//							corrected Insert button's text to always refer to the top graph, never the top table.
// Version 6.23, JP:		Changed so that you can insert the graph itself as a subwindow.
// Version 9, ST:			Removed panel code in favor of menu-based interface, added contextual and marquee Insert Subwindow menus, used Igor 9 syntaxes.
// Version 9.001, JP:		Made into an independent module, added Graph and Panel submenus and the Start() alert.
// Version 9.002, ST:		SubwindowInGraphHook() closes obsolete InsertSubWindow panels.
//							JP renamed WMInsertSubwindowIntoGraph() to WMInsertSubwindowIntoHost() because it works with panels, too.
// Version 9.003, JW:		If a graph is inserted, and that graph has window hook,
//							the window hook command is extracted and the hook installed on the top-level window.
//							This was done so that a graph with transform axis would continue to work when inserted as a subwindow.
//							See the ExtractWindowHookCommand() function.
// Version 9.004, JP:		WMInsertSubwindowIntoHost() no longer stops executing commands upon encountering ShowInfo or ShowTools.
// Version 9.005, JP:		WMInsertSubwindowIntoHost() works if the recreation macro has local commands such as "String fldrSav0=GetDataFolder(1)" and SetDataFolder fldrSav0.

Menu "Graph", dynamic,  hideable
	Submenu "Insert Subwindow"
		WM_SubwindowInGraph#ListOfWindowsToInsert(),/Q, WM_SubwindowInGraph#WM_InsertSelectedWindowMenubar()
	End
End

// It is useful to insert a graph or table into a panel
Menu "Panel", dynamic,  hideable
	Submenu "Insert Subwindow"
		WM_SubwindowInGraph#ListOfWindowsToInsert(),/Q, WM_SubwindowInGraph#WM_InsertSelectedWindowMenubar()
	End
End

Menu "GraphPopup", dynamic
	Submenu "Insert Subwindow"
		WM_SubwindowInGraph#ListOfWindowsToInsert(),/Q, WM_SubwindowInGraph#WM_InsertSelectedWindowContextual()
	End
End

Menu "GraphMarquee", dynamic
	Submenu "Insert Subwindow"
		WM_SubwindowInGraph#ListOfWindowsToInsert(),/Q, WM_SubwindowInGraph#WM_InsertSelectedWindowContextual()
	End
End

// Called from WMMenus.ipf via Execute/P/Q/Z "WM_SubwindowInGraph#Start()"
// Now instead of creating a panel that does the subwindow insertion,
// an alert describing the new menu-based usage is presented.
// 
Function Start()

	String msg="Choose \"Insert Subwindow\" from the Graph menu, the Graph Marquee menu, or the Graph Contextual menu."
	msg += "\r\rIf a marquee is showing, the subwindow is inserted there."
	DoAlert 0, msg
End

// backwards compatibility: obsolete panels are silently closed to not generate any errors
// SetWindow WMSubwindowInGraph hook(activate)=WM_SubwindowInGraph#SubwindowInGraphHook
Function SubwindowInGraphHook(hs)
	STRUCT WMWinHookStruct &hs
	KillWindow/Z WMSubwindowInGraph
	return 0
End


// for menubar's Graph and Panel menus
Function WM_InsertSelectedWindowMenubar()
	String host= ActiveHostWindow()
	Variable type = WinType(host)
	GetLastUserMenuInfo
	String theWindow = S_value // table or graph name to insert as subwindow
	if ( IsValidWindowName(theWindow) )
		String slashW = ""
		if( type == 1 ) // graph
			GetMarquee/K/Z/W=$host
			if ( V_Flag )
				Variable left=V_left, right=V_right, top=V_top, bottom=V_bottom
				GetWindow $host, gsize
				sprintf slashW,"/W=(%g,%g,%g,%g)",left/V_right,top/V_bottom,right/V_right,bottom/V_bottom
			endif
		endif
		WMInsertSubwindowIntoHost(host, theWindow, slashW)
	endif
End

Function WM_InsertSelectedWindowContextual()

	GetLastUserMenuInfo	// sets S_graphName, presumes we are operating on behalf of TracePopup, AllTracesPopup, or GraphPopup contextual menu.
	String slashW = "", theWindow = S_value
	if ( IsValidWindowName(theWindow) )
		GetMarquee/K/Z
		if ( V_Flag )
			Variable left=V_left, right=V_right, top=V_top, bottom=V_bottom
			GetWindow $S_graphName, gsize
			sprintf slashW,"/W=(%g,%g,%g,%g)",left/V_right,top/V_bottom,right/V_right,bottom/V_bottom
		endif
		WMInsertSubwindowIntoHost(S_graphName, theWindow, slashW)
	endif
End

Function/S ListOfWindowsToInsert()
	String list= WinList("*",";","WIN:3") // tables and graphs
	return list
End

Function IsValidWindowName(String name)
	if(strlen(name))
		DoWindow $name
		if(V_Flag)
			return 1
		endif
	endif
	return 0
End

Function/S ActiveHostWindow()

	String win= WinName(0,1+64,1)	// topmost visible graph or panel
	if( strlen(win) )
		GetWindow $win activeSW		// Stores the window "path" of currently active subwindow in S_Value. See Subwindow Syntax for details on the window hierarchy.
		Variable type= WinType(S_Value)
		if( type == 1 || type == 7) // graph or panel is a good host for an inserted graph or table
			win= S_Value
		endif
	endif
	return win
End

// Takes a single command line extracted from the recreation string, tests it for being a SetWindow hook command.
// If so, creates a new SetWindow command using the contents of topWinName as the target. These commands will be saved
// and run after the window has been successfully inserted into the host window.
static Function/S ExtractWindowHookCommand(String oneline, String topWinName)
	String newline = ""
	if ( strsearch(oneline, "SetWindow", 0) > 0 && strsearch(oneline, "hook", 0) > 0 )
		newline = "SetWindow " + topWinName + ", "
		String ge = "\tSetWindow\s+([\w#]+).*,hook(?:(?:\((\w+)\))?)=(\w+)"
		String win, hookname, hookfunc
		SplitString/E=ge oneline, win, hookname, hookfunc
		newline += "hook"
		if (strlen(hookname) > 0)
			newline += "("+hookname+")"
		endif
		newline += "="+hookfunc
	endif
	
	return newline
end

Function/S WMInsertSubwindowIntoHost(String hostWindow, String insertThisTableOrGraph, String slashW)
	String topHost = StringFromList(0, hostWindow, "#")
	topHost = RemoveEnding(topHost, "#")
	String hookCommands = ""
	
	String recreation = WinRecreation(insertThisTableOrGraph, 0)
	Variable lines = ItemsInList(recreation,"\r")
	if( lines < 2 )
		return ""
	endif
	
	DFREF saveDFR = GetDataFolderDFR( )
	SetDataFolder root:										// this is what window recreation macros assume
	
	String procCode="Proc SubWindowCode()\r"				// JP 9.005: accumulate code into proc and execute all at once, so that recreation macros that create and use local variables work. (Executing each statement independently lost the local variables)
	
	String skipstrs= "ShowInfo;ShowTools;"
	String quitstrs= "ControlBar;NewPanel;"
	String hookcmds = ""									// JW 210916 The hooks need to be installed on the top-level window, not a subwindow
	Variable i, foundSlashW = 0
	for(i = 2; i < lines-1; i += 1)							// skip "Window Graph0() : Graph" and "PauseUpdate; Silent 1" and ending "EndMacro"
		String code = StringFromList(i,recreation,"\r")
		if( !foundSlashW )									// do this only for the first Display command
			code = PossiblyRewriteSlashWCommand(code, hostWindow, slashW, foundSlashW)		// slashW is "" or "/W=(#,#,#,#)"
		endif
		
		// JW 210917 recognize and extract SetWindow commands that set a hook function. Those need to be re-directed to the top-level host window
		String possibleHookCmd = ExtractWindowHookCommand(code, topHost)
		if (strlen(possibleHookCmd) > 0)
			hookCommands += possibleHookCmd
			continue										// We don't want to execute this command, but we don't necessarily want to quit, either						
		endif
		
		Variable j,skippos= -1
		for(j = 0; j < ItemsInList(skipstrs); j += 1)
			skippos = StrSearch(code,StringFromList(j,skipstrs),0)
			if( skippos != -1 )
				break;
			endif
		endfor
		if( skippos != -1 )
			continue										// Skip commands that override host window settings
		endif
		
		Variable quitpos= -1
		for(j = 0; j < ItemsInList(quitstrs); j += 1)
			quitpos = StrSearch(code,StringFromList(j,quitstrs),0)
			if( quitpos != -1 )								// Since Igor puts those commands at the end, we quit executing
				break;
			endif
		endfor
		if( quitpos != -1 )
			break											// Stop executing commands when a panel subwindow or ControlBar command is encountered.
		endif
		code = RemoveEnding(code,"\r")+"\r" 					// ensure the line ends with \r
		procCode += code
	endfor
	procCode += "End\r"
	Execute/Q/Z procCode
	
	Execute/Q/Z hookCommands								// JW 210917 Move hook commands to top window
	
	code = "RenameWindow #,"+insertThisTableOrGraph
	Execute/Q/Z code
	code = "ShowTools/A/W="+hostWindow+" arrow"
	Execute/P/Q/Z code

	SetDataFolder saveDFR
	Print insertThisTableOrGraph+" inserted into "+hostWindow+" as "+hostWindow+"#"+insertThisTableOrGraph
	
	return insertThisTableOrGraph
End

Function/S PossiblyRewriteSlashWCommand(String code, String hostWindow, String slashw, Variable &foundSlashW)
	String cmd = "\tDisplay", key = "/W=("
	Variable offset = strsearch(code, cmd,0)
	if( offset < 0 )
		cmd = "\tEdit"
		offset = strsearch(code, cmd,0)
	endif
	
	if( offset == 0 )
		foundSlashW = 1
		// Rewrite the first Display or Edit command as:
		// Display/W=(0.2,0.2,0.8,0.8)/HOST=$hostWindow <waves to append but not as "str">
		Variable startOfGoodStuff = offset+strlen(cmd)		// points to after "\tDisplay" or "\tEdit"
		Variable slashWOffset = strsearch(code, key, startOfGoodStuff)
		if( slashWOffset > 0 )								// find the end of the /W=(#,#,#,#) part
			slashWOffset += strlen(key)
			key= ")"
			Variable endOfSlashW = strsearch(code, key, slashWOffset)
			if( endOfSlashW > 0 )
				startOfGoodStuff = endOfSlashW+strlen(key)
			endif
		endif
		// remove any optional title part ( as "<title>") which is always the last part of the command.
		key = "as \""
		Variable endOfGoodStuff = strlen(code)
		Variable offsetToAs = strsearch(code, key, startOfGoodStuff)
		if( offsetToAs > 0 )
			endOfGoodStuff = offsetToAs-1
		endif
		String goodStuff = code[startOfGoodStuff,endOfGoodStuff]
		if( strlen(slashw) == 0 )							// slashW is "" or "/W=(#,#,#,#)"
			slashw = "/W=(0.2,0.2,0.8,0.8)"
		endif
		code = cmd+slashw+"/HOST="+hostWindow+" "+goodStuff
	endif
	
	return code
End