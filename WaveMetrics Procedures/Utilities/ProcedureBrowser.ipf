#pragma rtGlobals=2 		// Enforce modern global access method and syntax
#pragma IgorVersion= 6.1
#pragma version=7
#pragma IndependentModule=WMProcBrowserIM
#include <SaveRestoreWindowCoords>

//
// ProcedureBrowser.ipf
// Version 7,    4/12/2016 - JP - PanelResolution changes, uses SaveRestoreWindowCoords instead of PB_Window* routines.
// Version 6.35, 7/20/2014 - JP - PB_GetListSelection() bugfix.
// Version 6.32, 5/7/2013 - JP - The first line of code has tab chars replaced with spaces so that <??> isn't displayed in the SetVariable control.
// Version 6.23, 8/11/2011 - JP - PB_MoveWindowToUpperRightCorner() works correctly on Windows.
// Version 6.12, 10/5/2009 - JP - Spelling fix.
// Version 6.1, 5/6/2009 - JP - The browser continues to work if user procedures don't compile.
//									PB_GetIndependentModuleDev() doesn't mark the experiment as changed.
// Version 5.5, 1/25/2006 - JP - Made Independent Module, added support for static functions and Independent Modules.
//									Procedures Browser resizes correctly if tools are showing. Added Show Files feature.
// Version 5.02, 6/23/2004 - JP - Added Procedure Context submenu. Fixed bug in PB_CreateNotebook() when the List button was pushed during #include "file" only.
// Version 5, 6/3/2004 - JP - Added default GUI commands for Macintosh.
// Version 4.08, 4/14/2003 - JP - divider menu items show up properly on Windows.
// Version 4.05, 4/30/2002 - JP - Changed displaySource button into a checkbox, browser position restored properly on Windows.
// Version 4.03, 7/16/2001 - JP - Added Copy Template button, required Igor 4.03's PutScrapText operation.
// Version 3,  05/19/2000 - JP - window positions are remembered better.
// Version 2,  03/28/2000 - JP - Doesn't try to resize when the panel is minimized.
//                    01/28/2000 - JP - Changed popup into list, removed macro, function, and alphabetic checkboxes, reorganized controls.
// Version 1.4, 10/19/1999 - JP - added Procedure Text in Notebook, goto/list popup, and listings button.
// Version 1.3, 10/16/1999 - JP - added Procedures Listing in Notebook.

static Constant kMinWidthPoints=200
static Constant kMinHeightPoints=200

Menu "Misc"
	"-"
	"Procedures Browser", /Q, PB_ProcBrowser()
	Submenu "Procedures Browser Options"
		PB_ReportIndependentModules(), /Q, PB_ToggleIndependentModules()
		PB_ReportToggle("Show Files In List","showFiles"), /Q, PB_ToggleSetting("showFiles")
		PB_ReportToggle("Show Static Functions","showStatics"), /Q, PB_ToggleSetting("showStatics")
		Submenu "Static Function Background Color"
			PB_ReportStaticBackground(), /Q, PB_SetStaticBackground()
		End
		PB_ReportToggle("Procedures in Alphabetic Order","alphabetic"), /Q, PB_ToggleSetting("alphabetic")
		"-"
		PB_ReportContext("None"), /Q, PB_SetContext(0)
		PB_ReportContext("Preceding Comments"), /Q, PB_SetContext(-1)
		PB_ReportContext("+/- 10 lines"), /Q, PB_SetContext(10)
		PB_ReportContext("+/- 20 lines"), /Q, PB_SetContext(20)
		PB_ReportContext("+/- 100 lines"), /Q, PB_SetContext(100)
	End
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

Function/S PB_SetDF()
	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:ProcedureBrowser
	return oldDF
End

Function/S PB_DF()
	return "root:Packages:ProcedureBrowser"
End

Function/S PB_DF_Var(varName)
	String varName
	return PB_DF()+":"+varName
End

Function/S PB_ReportStaticBackground()

	Variable staticRed= NumVarOrDefault(PB_DF_Var("staticRed"),61166)
	Variable staticGreen= NumVarOrDefault(PB_DF_Var("staticGreen"),61166)
	Variable staticBlue= NumVarOrDefault(PB_DF_Var("staticBlue"),61166)
	String itemText
	sprintf itemText, "*COLORPOP*(%d,%d,%d)", staticRed, staticGreen, staticBlue
	return itemText
End

Function PB_SetStaticBackground()

	String oldDF= PB_SetDF()	// in case the user selects this before building the procedure browser panel
	GetLastUserMenuInfo

	Variable/G staticRed=  V_red
	Variable/G staticGreen=  V_green
	Variable/G staticBlue=  V_blue
	SetDataFolder oldDF
	BuildMenu "Misc"
	DoWindow ProcBrowser
	if( V_Flag )
		PB_UpdateControls(0)
	endif
End

Function/S PB_ReportIndependentModules()

	String checkStr=""
	String alphaStr= "Show Independent Modules"
	Variable showingIndependentModules= PB_GetIndependentModuleDev()
	if( showingIndependentModules  )
		checkStr= "!"+num2char(18)	// magic Mac checkmark char
	endif
	return checkStr + alphaStr
End

Function PB_ToggleIndependentModules()

	Variable showingIndependentModules= PB_GetIndependentModuleDev()
	Execute "SetIgorOption IndependentModuleDev="+num2istr(!showingIndependentModules)
	ControlUpdate/W=ProcBrowser fileTypePop
	PB_UpdateControls(0)
End

Function/S PB_ReportToggle(menuItemText, varName)
	String menuItemText
	String varName	// name of variable in  PB_DF()

	String checkStr=""
	Variable num=NumVarOrDefault(PB_DF_Var(varName),0)
	if( num  )
		checkStr= "!"+num2char(18)	// magic Mac checkmark char
	endif
	return checkStr + menuItemText
End
	
Function PB_ToggleSetting(varName)
	String varName	// name of variable in  PB_DF()

	Variable num=NumVarOrDefault(PB_DF_Var(varName),1)	// default is 1, so that !default is 0.
	num = !num
	String oldDF= PB_SetDF()	// in case the user selects this before building the procedure browser panel
	Variable/G $varName=  num
	SetDataFolder oldDF
	BuildMenu "Misc"
	DoWindow ProcBrowser
	if( V_Flag )
		PB_UpdateControls(0)
	endif
	return num
End

Function/S PB_ReportContext(menuStr)
	String menuStr

	Variable contextLines=NumVarOrDefault(PB_DF_Var("contextLines"),-1)
	Variable lines= -inf
	String checkStr="\\M0"
	strswitch( menuStr )
		case "None":
			lines= 0
			break
		case "Preceeding Comments":
			lines= -1
			break
		case "+/- 10 lines":
			lines= 10
			break
		case "+/- 20 lines":
			lines= 20
			break
		case "+/- 100 lines":
			lines= 100
			break
	endswitch
	if( contextLines == lines )
		checkStr += ":!"+num2char(18)+":"	// magic Mac checkmark char
	endif
	return checkStr+menuStr
End

Function PB_SetContext(lines)
	Variable lines
	
	String oldDF= PB_SetDF()	// in case the user selects this before building the procedure browser panel
	Variable/G contextLines=  lines
	SetDataFolder oldDF
	BuildMenu "Misc"
	DoWindow ProcBrowser
	if( V_Flag )
		PB_UpdateControls(0)
	endif
	return lines
End

Function PB_ProcBrowser()
	DoWindow/F ProcBrowser
	if( V_Flag == 1 )
		return 0
	endif
	
	String cmd
	String coords= WC_WindowCoordinatesGetStr("ProcBrowser",1)
	if( strlen(coords) )		// use previous position in wsizeRM units
		cmd="NewPanel/K=1/W=("+coords+")/N=ProcBrowser as \"Procedures Browser\""
		Execute/Q/Z cmd
	else
		// use default coordinates (l,t,r,b)
		Variable left= 2100
		Variable top= 44
		// PanelResolution("") = 72 on Windows 96DPI, else == ScreenResolution
		Variable width= kMinWidthPoints * ScreenResolution / PanelResolution("")
		Variable height= kMinHeightPoints * ScreenResolution / PanelResolution("")
		NewPanel/K=1/W=(left,top,left+width,top+height)/N=ProcBrowser as "Procedures Browser"
		PB_MoveWindowToUpperRightCorner("ProcBrowser")
	endif
	Variable isSizeLimited= PB_SetWinSizeMinSize("ProcBrowser",kMinWidthPoints,kMinHeightPoints)
	
	DefaultGuiFont/W=ProcBrowser/Mac popup={"_IgorLarge",0,0},all={"_IgorLarge",0,0}
	DefaultGuiFont/W=ProcBrowser/Win popup={"_IgorLarge",12,0},all={"_IgorLarge",12,0}
	
	String oldDF= PB_SetDF()
	String ms= StrVarOrDefault(PB_DF_Var("matchString"),"*")
	String/G matchString= ms
	String fm= StrVarOrDefault(PB_DF_Var("fileMatch"),"*")
	String/G fileMatch= fm
	String ltp= StrVarOrDefault(PB_DF_Var("lastTopProc"),"Procedure")
	String/G lastTopProc= ltp
	String/G firstLineText
	String listwn= PB_DF_Var("proceduresList")
	if( exists(listwn) != 1 )
		Make/O/T  $listwn
	endif
	Variable alpha=NumVarOrDefault(PB_DF_Var("alphabetic"),1)
	Variable/G alphabetic= alpha
	Variable lines=NumVarOrDefault(PB_DF_Var("contextLines"),-1)
	Variable/G contextLines= lines
	Variable/G showStatics= NumVarOrDefault(PB_DF_Var("showStatics"),1)
	Variable/G showFiles= NumVarOrDefault(PB_DF_Var("showFiles"),0)
	BuildMenu "Misc"
	SetDataFolder oldDF
	
	// Most of the controls are positioned at x=3
	SetVariable fileMatch,pos={3,2},size={182,15},proc=PB_MatchSetVar,title="Files Matching"
	SetVariable fileMatch,limits={-Inf,Inf,1},value= root:Packages:ProcedureBrowser:fileMatch

	PopupMenu fileTypePop,pos={3,23},size={131,17},proc=PB_ProcBrowserTypePop,title="Files"
	cmd= GetIndependentModuleName()+"#PB_ProcedureFileList()"
	PopupMenu fileTypePop,mode=2,popvalue="All Matching Files",value= #cmd

	SetVariable matchString,pos={3,48},size={182,15},proc=PB_MatchSetVar,title="Procedures Matching"
	SetVariable matchString,limits={-Inf,Inf,1},value= root:Packages:ProcedureBrowser:matchString

	ListBox proceduresList,pos={3,71},size={182,122},frame=4,userColumnResize=1
	ListBox proceduresList,listWave=root:Packages:ProcedureBrowser:proceduresList,mode= 1
	ListBox proceduresList,selRow= 0, proc=PB_ListboxProc

	SetVariable firstLine,pos={3,197},size={182,15},title=" "
	SetVariable firstLine,value= root:Packages:ProcedureBrowser:firstLineText

	// First row of buttons
	Button copyTemplate,pos={3,215},size={105,20},proc=PB_CopyTemplate,title="Copy Template"
	Button gotoSource,pos={111,215},size={60,20},title="Go To", proc=PB_GotoSource

	// Second row of buttons
	Checkbox displaySource,pos={3,240},size={49,14},title="Source", value=0, proc=PB_ProcBrowserCheck
	Button listInNotebook,pos={63,238},size={45,20},proc=PB_ListInNotebookButton,title="List"
	Button hideAllProcs,pos={111,238},size={60,20},proc=PB_ProcBrowserHideButton,title="Hide All"

	// resize for previous position or for consistency
	PB_FitControlsToWindow()

	SetWindow kwTopWin,hook=PB_ProcBrowserHook
	PB_UpdateControls(0)
End

// Don't allow the panel to be made too narrow (Button widths)
// Don't allow the panel to be made too short (one list item, and rest of controls must fit)
// Grow the match fields horizontally
// Grow the list vertically and horizontally.
// Grow the first line field horizontally, and keep it below the vertically resized list
// Move the buttons below the vertically repositioned first line field.
Function PB_FitControlsToWindow()

	String win= "ProcBrowser"
	if( PanelResolution(win) == 72 )
		GetWindow $win, wsizeDC
	else
		GetWindow $win, wsize
	endif
	Variable winWidth= V_right - V_left
	Variable winHeight= V_bottom - V_top
	if( (winWidth == 0) && (winHeight == 0 ) )	// minimized, don't move anything
		return 0
	endif

	// Grow the match fields horizontally
	ControlInfo/W=$win fileMatch
	Variable hmargin=V_left // Most of the controls are positioned at x=3, with a right-hand margin of 3
	Variable width= winWidth-hmargin*2
	
	// if tools showing, subtract out the fixed tools width
	Variable haveTools = strsearch(WinRecreation(win,0), "ShowTools", 0) >= 0
	if( haveTools )
		width -= 28
		winWidth -= 28
	endif
	
	ControlInfo/W=$win fileMatch
	Variable setvarHeight= V_Height
	SetVariable fileMatch win=$win, size={width,setvarHeight}
	SetVariable matchString win=$win, size={width,setvarHeight}
	SetVariable firstLine win=$win, size={width,setvarHeight}

	// Grow the list vertically and horizontally.
	// compute how much vertical room is needed for the controls below the list,
	// including vertical margin.
	Variable vmargin= 4 // leave room for list focus ring.

	Variable reserveHeight= vmargin
	ControlInfo/W=$win firstLine
	reserveHeight += V_height + vmargin
	ControlInfo/W=$win copyTemplate
	reserveHeight += 2*(V_height + vmargin)
	
	// grow/shrink the list
	ControlInfo/W=$win proceduresList
	Variable yPos= V_top
	Variable height= winHeight - reserveHeight - yPos
	ListBox proceduresList win=$win, size={width,height}

	// Keep the first line field below the vertically resized list
	yPos += height + vmargin	// new y position of firstLine 
	SetVariable firstLine win=$win, pos={hmargin,yPos}
	ControlInfo/W=$win firstLine

	// Move the buttons below the vertically repositioned first line field.
	yPos += V_height + vmargin
	
	ControlInfo/W=$win copyTemplate
	Variable xPos= V_left
	height= V_height	// all buttons are the same height
	Variable yPos2= yPos+height+vmargin	// second row's y position
	Button copyTemplate,win=$win,pos={xPos,yPos},size={105,height},proc=PB_CopyTemplate,title="Copy Template"
	Checkbox displaySource win=$win, pos= {xPos, yPos2+2}, title="Source"
	Button listInNotebook win=$win, pos= {xPos+70, yPos2},size={45,height}, title="List"
	
	// Right-justify "Go To" and "Hide All" buttons
	ControlInfo/W=$win gotoSource
	width= V_width	// same size as Hide All
	Variable growWidth= 14 * PB_IsMacintosh()
	xPos= winWidth - growWidth - hmargin - width
	Button gotoSource win=$win, pos= {xPos, yPos}
	Button hideAllProcs win=$win, pos= {xPos, yPos2}
	return 0
End

Function PB_IsMacintosh()
	String platform= IgorInfo(2)
	return CmpStr(platform,"Macintosh") == 0
End

Function PB_WindowIsMinimized(win)
	String win

	GetWindow $win wsize // points
	Variable minimized= (V_right == V_left) && (V_bottom==V_top)
	return minimized
End

// all dimensions are in points
Function PB_EnforceMinWindowSize(win,minwidth,minheight)
	String win
	Variable minwidth,minheight // points

	GetWindow $win wsize // points
	Variable minimized= (V_right == V_left) && (V_bottom==V_top)
	if( minimized )
		return 0
	endif
	Variable width= V_right-V_left
	Variable height= V_bottom-V_top
	if( (width < minwidth-1) || (height < minHeight-1) )	// -1 to avoid needless resizing due to integer roundoff and truncation
		width= max(width,minwidth)
		height= max(height,minheight)
		MoveWindow/W=$win V_left, V_top, V_left+width, V_top+height
	endif
	return 1
End

Function PB_SetWinSizeMinSize(win,minwidth,minheight)
	String win
	Variable minwidth,minheight	// points. Note that Panel window recreation macros can be in pixels.

#if IgorVersion() >= 7
	SetWindow $win sizeLimit={minwidth, minheight, Inf, Inf}	// no max size.
	return 1	// set size limit
#else
	PB_EnforceMinWindowSize(win,minwidth,minheight)
	return 0 // didn't set size limit (but did enforce minimum size, unless minimized)
#endif
End


// This list is displayed in the fileTypePop PopupMenu control
Function/S PB_ProcedureFileList()

	String list= "Top Procedure;All Matching Files;\\M1:0:-;Built-in Only;#include \"file\" only;#include <file> only;"

	String fileMatch= StrVarOrDefault(PB_DF_Var("fileMatch"),"*")
	String winOptions
	Variable showIndependentModules=PB_GetIndependentModuleDev()
	if( showIndependentModules )
		winOptions = "INDEPENDENTMODULE:1,WIN:128"
	else
		winOptions = "INDEPENDENTMODULE:0,WIN:128"
	endif

	String windowList= WinList(fileMatch,";",winOptions)	// will have independent module-included windows if SetIgorOption IndependentModuleDev=1
	if( ItemsInList(windowList) > 1 )
		windowList= SortList(windowList,";",4)	// case-insensitive
		windowList= RemoveFromList("ProcedureBrowser.ipf", windowList)	// hide self (Win)
		windowList= RemoveFromList("ProcedureBrowser", windowList)		// hide self (Mac)
		windowList= RemoveFromList("ProcedureBrowser.ipf [WMProcBrowserIM]", windowList)	// hide independent module self
	endif
	if( ItemsInList(windowList) > 0 )
		list += "\\M1:0:-;"+windowList
		// add any independent modules discovered.
		String independentModules= PB_UniqueIndependentModules(windowList)
		if( ItemsInList(independentModules) > 0  )
			list += "\\M1:0:([Independent Modules];"+independentModules
		endif
	endif
	return list
End

// Split "windowTitle [independentModuleName]" apart into windowTitle and independentModuleName.
Function PB_ParseWinTitleAndModuleName(windowTitleAndModuleName, windowTitle, independentModuleName)
	String windowTitleAndModuleName	// input
	String &windowTitle, &independentModuleName	// outputs

	windowtitle= windowTitleAndModuleName
	independentModuleName=""
	Variable leftBracket= strsearch(windowTitleAndModuleName, "[", inf  , 1)	// case sensitive backwards search
	Variable rightBracket= strsearch(windowTitleAndModuleName, "]", inf  , 1)	// case sensitive backwards search
	if( leftBracket >= 0 && (rightBracket == strlen(windowTitleAndModuleName)-1) )
		Variable endOfWindowName= leftBracket-1
		if( endOfWindowName >= 0 )
			if( CmpStr(windowTitleAndModuleName[endOfWindowName,endOfWindowName], " ") == 0 )
				endOfWindowName -= 1
			endif
		endif
		windowTitle= windowTitleAndModuleName[0,endOfWindowName]
		independentModuleName= windowTitleAndModuleName[leftBracket+1,rightBracket-1]
	endif
	return strlen(independentModuleName)
End

Function/S PB_UniqueIndependentModules(windowList)
	String windowList

	String independentModules=""
	Variable i,n= ItemsInList(windowList)
	for( i=0; i<n; i+=1 )
		String str= StringFromList(i, windowList)	// procedure title followed optionally by " [independentModuleIncludeName]"
		String windowTitle, independentModuleName
		if( PB_ParseWinTitleAndModuleName(str, windowTitle, independentModuleName) )
			String item= "["+independentModuleName+"]"
			if( WhichListItem(item, independentModules) < 0 )
				independentModules += item+";"
			endif
		endif
	endfor	
	return SortList(independentModules,";",16)
End

// list of files that match what is selected in the fileTypePop
Function/S PB_ProcFilesList()

	Variable fileTypePop= 1
	String procTypeStr

	ControlInfo/W=ProcBrowser fileTypePop
	if( V_Flag )
		fileTypePop= V_Value
		procTypeStr= S_Value
	endif
	
	String windowList= "_none_"	// this value should never appear
	String options= ""
	String fileMatch= StrVarOrDefault(PB_DF_Var("fileMatch"),"*")
	if( strlen(fileMatch) == 0 )
		fileMatch= "*"
	endif
	
	String winOptions
	Variable showIndependentModules=PB_GetIndependentModuleDev()
	if( showIndependentModules )
		winOptions = "INDEPENDENTMODULE:1,WIN:128"
	else
		winOptions = "INDEPENDENTMODULE:0,WIN:128"
	endif
	
	switch( fileTypePop )
		case 1:
			windowList=  StringFromList(0,WinList("*",";",winOptions))
			break
		case 1000:	// old
			String topProc=WinName(0,128,1) 	// Top Visible Procedure
			SVAR lpt= $PB_DF_VAR("lastTopProc")
			if( strlen(topProc) == 0 )
				// before using the last top proc, make sure it still exists
				lpt= StringFromList(0,WinList(lpt,";",winOptions))
				if( strlen(lpt) )
					topProc=lpt
				else
					topProc= "Procedure"
				endif
			else
				lpt= topProc
			endif
			windowList= topProc
			break
		case 2:	// All Matching Procedures
			windowList= WinList(fileMatch,";",winOptions)
			break;
		case 4:	// Built-in Only
			windowList= WinList(fileMatch,";","INCLUDE:1,"+winOptions)
			break
		case 5:	//#include "fileName" only
			windowList= WinList(fileMatch,";","INCLUDE:2,"+winOptions)
			break
		case 6:	// #include <fileName> only"
			windowList= WinList(fileMatch,";","INCLUDE:4,"+winOptions)
			break
		default:
			if( fileTypePop >= 8 )	// a specific procedure or independent module
				windowList= procTypeStr	// and procTypeStr is that specific procedure
				// or an independent module name in square brackets
				String windowTitle, independentModuleName
				Variable haveIndependentModuleName= PB_ParseWinTitleAndModuleName(windowList, windowTitle, independentModuleName)
				if( haveIndependentModuleName && strlen(windowTitle) == 0 )	// if  "[independentModuleName]"
					// return all the procedure windows that belong to the independent module
					windowList= WinList("*"+windowList,";", "INDEPENDENTMODULE:1,WIN:128")
				endif
			endif
			break
	endswitch
	
	if( fileTypePop != 1 )	// allow the browser to show up if it is the top procedure
		windowList= RemoveFromList("ProcedureBrowser.ipf", windowList)	// hide self (Win)
		windowList= RemoveFromList("ProcedureBrowser", windowList)		// hide self (Mac)
		windowList= RemoveFromList("ProcedureBrowser.ipf [WMProcBrowserIM]", windowList)	// hide independent module self
	endif

	return windowList
End

// returns the needed DisplayProcedure/W=name for the selected function name.
Function/S PB_WindowForSelectedFunction()
	String windowList= PB_ProcFilesList()	// "Procedure", "somefile.ipf", "somefile.ipf;anotherfile.ipf", "somefile [independentModuleName]", or "[independentModuleName]"

	Variable numWindows= ItemsInList(windowList)
	if( numWindows == 1 )
		return StringFromList(0,windowList)	// remove any trailing ";" to get "Procedure", "somefile.ipf", "somefile [independentModuleName]", or "[independentModuleName]"
	endif
	return ""	// use global scope (no /W)
End

// Return value is string list of procedure (function or macro) names
// This list shows up in either the ListBox control or printed into a notebook (Display List button)
Function/S PB_ProceduresList(windowTitleList)
	String &windowTitleList	// OUTPUT: string list of corresponding window titles

	String windowList= PB_ProcFilesList()
	Variable numWindows= ItemsInList(windowList)
	if( numWindows < 1 )
		windowTitleList= ""
		return "(no matching files)"
	endif
	
	String matchStr= StrVarOrDefault(PB_DF_Var("matchString"),"*")
	if( strlen(matchStr) == 0 )
		matchStr= "*"
	endif
	
	String opts,win

	String macroOpts = "WIN:"
	String functionOpts= "KIND:2,WIN:"	// user functions only (no builtin functions)

	// statics functions
	Variable showStatics=NumVarOrDefault(PB_DF_Var("showStatics"),0)
	if( showStatics )
		functionOpts= ReplaceNumberByKey("KIND",functionOpts, 16+2, ":",",")
	endif
	
	// Version 5.5: use text waves (to make sorting of both the function names and the procedure titles possible)
	Make/O/T/N=0 $PB_DF_Var("wFuncMacroNamesList")
	WAVE/T wFuncMacroNamesList=$PB_DF_Var("wFuncMacroNamesList")

	Make/O/T/N=0 $PB_DF_Var("wProcedureWindowTitlesList")
	WAVE/T wProcedureWindowTitlesList=$PB_DF_Var("wProcedureWindowTitlesList")
	
	Make/O/T/N=0 $PB_DF_Var("wFunctionInfoList")	// for static function indication
	WAVE/T wFunctionInfoList=$PB_DF_Var("wFunctionInfoList")
	
	Variable ii, numItems, nextRow=0
	String listOfMacros, listOfFunctions
	for( ii= 0;  ii < numWindows; ii += 1 )
		win= StringFromList(ii,windowList)
		listOfMacros= MacroList(matchStr,";",macroOpts+win)
		numItems= ItemsInList(listOfMacros)
		if( numItems )
			InsertPoints/M=0 nextRow, numItems, wFuncMacroNamesList, wProcedureWindowTitlesList,wFunctionInfoList
			wFuncMacroNamesList[nextRow, nextRow+numItems-1]= StringFromList(p-nextRow,listOfMacros)
			wProcedureWindowTitlesList[nextRow, nextRow+numItems-1]= win
			wFunctionInfoList[nextRow, nextRow+numItems-1]= ""
			nextRow += numItems
		endif
		// append " [ProcGlobal]" if win isn't in an independent module (needed because ProcedureBrowser is in an independent module)
		Variable winHasIndependentModule= strsearch(win,"[",0) >= 0
		String win2= win
		if( !winHasIndependentModule )
			win2= win +" [ProcGlobal]"
		endif
		listOfFunctions = FunctionList(matchStr,";",functionOpts+win2)
		numItems= ItemsInList(listOfFunctions)
		if( numItems )
			InsertPoints/M=0 nextRow, numItems, wFuncMacroNamesList, wProcedureWindowTitlesList,wFunctionInfoList
			wFuncMacroNamesList[nextRow, nextRow+numItems-1]= StringFromList(p-nextRow,listOfFunctions)
			wProcedureWindowTitlesList[nextRow, nextRow+numItems-1]= win
			wFunctionInfoList[nextRow, nextRow+numItems-1]= StringByKey("SPECIAL", FunctionInfo(wFuncMacroNamesList[p],win2))
			nextRow += numItems
		endif
	endfor

	if( nextRow == 0 )
		windowTitleList= ""
		return  "(no matching procedures)"
	endif

	Variable alpha=NumVarOrDefault(PB_DF_Var("alphabetic"),1)
	if( alpha )
		Sort wFuncMacroNamesList, wFuncMacroNamesList, wProcedureWindowTitlesList,wFunctionInfoList	// keep titles and names together
	endif
	
	windowTitleList= PB_ListFromTextWave(wProcedureWindowTitlesList)
	String funcMacrosList= PB_ListFromTextWave(wFuncMacroNamesList)
	return funcMacrosList
End

Function/S PB_ListFromTextWave(tw)
	Wave/T tw
	
	String list=""
	Variable i
	for(i=0; i<DimSize(tw,0); i+=1)
		list += tw[i]+";"
	endfor
	return list
End

Function PB_ProcBrowserHook (infoStr)
	String infoStr
	String event= StringByKey("EVENT",infoStr,":",";")
	String windowName= StringByKey("WINDOW",infoStr,":",";")
	Variable statusCode= 0		// 0 if nothing done, else 1
	strswitch (event) 
		case "activate":
			PB_UpdateControls(1)
			statusCode=1
			break;
		case "resize":
			PB_SetWinSizeMinSize(windowName,kMinWidthPoints,kMinHeightPoints)
			PB_FitControlsToWindow()
			statusCode=1
			break;
		case "kill":
			WC_WindowCoordinatesSave(windowName)
			statusCode=1
			break;
	endswitch
	return statusCode				// 0 if nothing done, else 1
End


//The event code has the following meanings:
//1 is mouse down
//2 is mouse up
//3 is double click
//4 is cell selection (mouse or arrow keys)
//5 is cell selection plus shift key
//6 is begin edit, 7 is finish edit

Function PB_ListboxProc(ctrlName,row,col,event)		// there are 2 tab characters before this comment.
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	 Variable event      // event code

	switch( event )
		case 2:	// mouse up
		case 4:	// cell selection (mouse or arrow keys)
			String selectedFile
			String selectedProc= PB_GetListSelection(selectedFile)
			SVAR firstLineText= root:Packages:ProcedureBrowser:firstLineText
			firstLineText= PB_ProcsText(selectedProc,selectedFile,0)
			firstLineText= replaceString("\t", firstLineText, " ")
			ControlInfo/W=ProcBrowser displaySource
			if( V_Value )
				if( strlen(selectedProc) )
					PB_DisplayProcTextInNotebook(selectedProc,selectedFile)
				endif
			endif
			break;
		case 3:	// double click
			PB_GotoSource("")
			break;
	endswitch
	return 0            // other return values reserved
End

// Because the Procedure Browser is an independent module (so that it works when normal compilation fails)
// it runs in the function name space of the independent module.
// In order to "find" normal functions, the file name needs to have " [ProcGlobal]" appended to it
// (but only if no independent module name is already there)
Function/S PB_PossiblyAddProcGlobal(fileName)
	String fileName
	
	Variable whereLeftBracket= strsearch(fileName,"[",0)
	Variable whereRightBracket= strsearch(fileName,"]",whereLeftBracket)
	Variable haveIndependentModule= whereLeftBracket >= 0 && whereRightBracket > whereLeftBracket
	if( !haveIndependentModule )
		if( strlen(fileName) )
			fileName += " [ProcGlobal]"	// has space before [
		else
			fileName= "[ProcGlobal]"	// no space before [
		endif
	endif
	return fileName
End

Function/S PB_GetListSelection(selectedFile)
	String &selectedFile
	
	String selection= ""
	selectedFile=""
	ControlInfo/W=ProcBrowser proceduresList
	if( V_Flag )
		Variable index= V_Value
		if( index >= 0 ) 	// 6.35
			// use the global waves that are created by PB_ProceduresList(), because the listbox may not have the file names
			WAVE/T/Z wFuncMacroNamesList=$PB_DF_Var("wFuncMacroNamesList")
			WAVE/T/Z wProcedureWindowTitlesList=$PB_DF_Var("wProcedureWindowTitlesList")
			if( WaveExists(wFuncMacroNamesList) && WaveExists(wProcedureWindowTitlesList) )
				if( index < DimSize(wFuncMacroNamesList,0) )
					selection= wFuncMacroNamesList[index]
				endif
				if( index < DimSize(wProcedureWindowTitlesList,0) )
					selectedFile= wProcedureWindowTitlesList[index]
					selectedFile= PB_PossiblyAddProcGlobal(selectedFile)
				endif
			else	// pre 5.5 code
				WAVE/T tw=$(S_DataFolder+S_value)
				selection= tw[index]
			endif
		endif
	endif
	return selection
End

Function PB_GotoSource(ctrlName) : ButtonControl
	String ctrlName

	String wn= WinName(0,64)	// the panel
	
	String fileName
	String procName= PB_GetListSelection(fileName)
	if( strlen(procName) )
		if( strlen(fileName) )
			DisplayProcedure/B=$wn/W=$fileName procName
		else
			DisplayProcedure/B=$wn procName
		endif
	endif
End

Function PB_ProcBrowserHideButton(ctrlName) : ButtonControl
	String ctrlName

	HideProcedures
	String win="ProcedureListing"
	WC_WindowCoordinatesSave(win)
	DoWindow/K $win
	ControlInfo/W=ProcBrowser displaySource
	if( V_Flag ==  2)
		Checkbox displaySource,win=ProcBrowser, value=0
	endif
	PB_UpdateControls(0)
End


Function PB_ProcBrowserTypePop(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	PB_UpdateControls(0)
End

Function PB_MatchSetVar(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	PB_UpdateControls(0)
End

Function PB_UpdateControls(isActivate)
	Variable isActivate	// skip some updates if PB_UpdateControls() is called during an activate event.

	Variable popMenuItem
	String list
	
	// update the list of procedure files
	ControlInfo/W=ProcBrowser fileTypePop
	if( V_Flag )
		popMenuItem= V_Value
		list= PB_ProcedureFileList()	// PopMenu fileTypePop value=PB_ProcedureFileList()
		if( popMenuItem > ItemsInList(list) )
			popMenuItem= 1
			PopupMenu fileTypePop win=ProcBrowser, mode=popmenuItem
		endif
		ControlUpdate/W=ProcBrowser fileTypePop
	endif

	// rebuild the list of procedures
	ControlInfo/W=ProcBrowser proceduresList
	if( V_Flag )
		Variable oldSelectionRow=V_Value
		// preserve current selection
		String currentSelectionFile
		String currentSelection= PB_GetListSelection(currentSelectionFile)	
		String correspondingWindowList
		list= PB_ProceduresList(correspondingWindowList)
		Variable listItems= ItemsInList(list)
		String twn= PB_DF_Var("proceduresList")
		Variable showFiles= NumVarOrDefault(PB_DF_Var("showFiles"),0)
		Variable columns= showFiles ? 2 : 1
		Make/O/T/N=(listItems,columns)  $twn
		WAVE/T  tw= $twn
		tw[][0]= StringFromList(p,list)
		if( showFiles )
			tw[][1]= StringFromList(p,correspondingWindowList)
			SetDimLabel 1, 0, Name, tw
			SetDimLabel 1, 1, File, tw
		else
			SetDimLabel 1, 0, $"", tw
		endif

		// indicate functions which are static by setting the background color to light green
		WAVE/T/Z wFunctionInfoList=$PB_DF_Var("wFunctionInfoList")
		if( WaveExists(wFunctionInfoList) && DimSize(wFunctionInfoList,0) > 0 )
			Make/O/N=(listItems,columns,2) $PB_DF_VAR("selWave")
			Wave sw=$PB_DF_VAR("selWave")
			SetDimLabel 2,1,backColors,sw				// define plane 1 as background colors
			sw[][][%backColors] = CmpStr(wFunctionInfoList[p],"static") == 0	// 0 is non-static, 1 is for static functions
			Make/O/U/W/N=(2,3) $PB_DF_VAR("colorWave")= 65535
			Wave cw= $PB_DF_VAR("colorWave")
			cw[1][0]= NumVarOrDefault(PB_DF_Var("staticRed"),61166)
			cw[1][1]= NumVarOrDefault(PB_DF_Var("staticGreen"),61166)
			cw[1][2]= NumVarOrDefault(PB_DF_Var("staticBlue"),61166)
			ListBox proceduresList, win=ProcBrowser, selWave= sw, colorwave=cw
		else
			ListBox proceduresList, win=ProcBrowser, selWave= $"", colorwave=$""
		endif

		Variable newSelectionRow= WhichListItem(currentSelection,list)
		if( newSelectionRow < 0 )	// function isn't in the recomputed list of procedures.
			newSelectionRow= 0
			currentSelection= ""
		endif
		ListBox proceduresList, win=ProcBrowser, selRow= newSelectionRow
		ControlUpdate/W=ProcBrowser proceduresList
		
		if( newSelectionRow != oldSelectionRow )
			ListBox proceduresList, win=ProcBrowser, row= newSelectionRow
			ControlUpdate/W=ProcBrowser proceduresList
		endif

		// Get the first line of the selected macro or function
		SVAR firstLineText= root:Packages:ProcedureBrowser:firstLineText
		currentSelection= PB_GetListSelection(currentSelectionFile)		// new current selection
		firstLineText= PB_ProcsText(currentSelection,currentSelectionFile,0)
		ControlUpdate/W=ProcBrowser firstLine

		// Update any notebook showing the selected macro or function's text.
		PB_FixDisplaySourceControl()	// added auto-source for 4.05
		if( !isActivate )
			ControlInfo/W=ProcBrowser displaySource
			if( V_Value )
				if( strlen(currentSelection) )
					PB_DisplayProcTextInNotebook(currentSelection,currentSelectionFile)
				endif
			else
				String win="ProcedureListing"
				WC_WindowCoordinatesSave(win)
				DoWindow/K $win
			endif
		endif
	endif
End

// as of 4.05, the display Procedure control was changed from a button to a checkbox.
Function PB_FixDisplaySourceControl()

	Variable fixedTheControl= 0
	DoWindow ProcBrowser
	if( V_Flag  )
		ControlInfo/W= ProcBrowser displaySource
		if( V_Flag != 2 )	// not the checkbox it should be
			KillControl/W=ProcBrowser displaySource
			Checkbox displaySource,win=ProcBrowser,pos={3,155},size={55,20},title="Source", value=0, proc=PB_ProcBrowserCheck
			PB_SetWinSizeMinSize("ProcBrowser",kMinWidthPoints,kMinHeightPoints)
			PB_FitControlsToWindow()
			fixedTheControl= 1
		endif
	endif
	return fixedTheControl
End


Function PB_CopyTemplate(ctrlName) : ButtonControl
	String ctrlName

	String fileName
	String procName= PB_GetListSelection(fileName)
	String template= PB_ProcsTemplate(procName,fileName)
	if( strlen(template) )
		PutScrapText template
	endif
End

Function PB_ProcBrowserCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	PB_UpdateControls(0)
	if( checked )
		DoWindow/F ProcedureListing
	endif
End

Function PB_ListInNotebookButton(ctrlName) : ButtonControl
	String ctrlName

	String nb=PB_ListFunctionsInNotebook()
	DoWindow/F $nb
End

Function/S PB_DisplayProcTextInNotebook(procName, fileName)
	String procName, fileName
	
	String notebookName= "ProcedureListing"
	PB_CreateNotebook(notebookName,procName)
	Notebook $notebookName selection={endOfFile,endOfFile}, text=PB_ProcsText(procName, fileName,1)
	Notebook $notebookName selection={startOfFile,startOfFile}
	Notebook $notebookName selection={startOfParagraph,endOfParagraph},  findText={"", 1}
	return notebookName
End

Function/S PB_ProcsText(procName,fileName,wantAll)
	String procName,fileName
	Variable wantAll
	
	Variable lines=0
	if( wantAll )
		lines= NumVarOrDefault(PB_DF_Var("contextLines"),-1)
	endif
	String text=ProcedureText(procName,lines, fileName)
	if( !wantAll )
		text= StringFromList(0,text,"\r")
	endif
	return text
End

Function/S PB_ProcsTemplate(procName, fileName)
	String procName, fileName

	String template= PB_ProcsText(procName,fileName,0)	// "Function/C funcName(.....) : subtype", or "" if the proc doesn't exist
	if( strlen(template) )
		Variable argsStart= strsearch(template,"(",0)
		Variable argsEnd= strsearch(template,")",argsStart)
		template= procName+template[argsStart,argsEnd]
	endif
	return template
End

//
// PB_ListFunctionsInNotebook creates a new notebook listing the matched
// functions/macros just as they appear in the popup menu.
//
Function/S PB_ListFunctionsInNotebook()
	
	String correspondingWindowList
	String procedures= PB_ProceduresList(correspondingWindowList)
	String notebookName= "ProcedureListing"
	String title= "Procedures "
	ControlInfo/W=ProcBrowser fileTypePop
	if( V_Flag )
		title += S_Value
	endif
	String matchStr= StrVarOrDefault(PB_DF_Var("matchString"),"*")
	if( strlen(matchStr) == 0 )
		matchStr= "*"
	endif
	title += " matching "+matchStr
	PB_CreateNotebook(notebookName,title)
	Notebook $notebookName selection={endOfFile,endOfFile}, text=title+"\r\r"
	String theproc
	Variable i,n= ItemsInList(procedures)
	Variable pos
	Variable showFiles= NumVarOrDefault(PB_DF_Var("showFiles"),0)
	for( i= 0; i < n; i += 1 )
		theproc= StringFromList(i,procedures)
		if( CmpStr(theProc,"\\M1(-") == 0 )
			theProc= "---- Functions ----"
		endif
		String text= theProc
		if( showFiles )
			text += "\t"+StringFromList(i,correspondingWindowList)
		endif
		NoteBook $notebookName, selection={endOfFile,endOfFile}, text=text + "\r"
	endfor
	ControlInfo/W=ProcBrowser displaySource
	if( V_Flag ==  2)
		Checkbox displaySource,win=ProcBrowser, value=0
	endif
	return notebookName
End


Function PB_CreateNotebook(notebookName,title)
	String notebookName,title

	DoWindow $notebookName
	Variable existed= V_Flag
	if( existed == 0 )
		String coords= WC_WindowCoordinatesGetStr(notebookName,0)
		if( strlen(coords) )
			String cmd= "NewNotebook/K=1/F=0/W=("+coords+")/N="+notebookName
			Execute cmd
			DoWindow/T $notebookName, title[0,39]
		else
			NewNotebook/K=1/F=0/W=(2000+514,200,2000+826,400)/N=$notebookName as title[0,39]
			AutoPositionWindow/E/M=1/R=ProcBrowser $notebookName
			Notebook $notebookName visible=1
		endif
		Notebook $notebookName fSize=12
		SetWindow $notebookName hook=PB_NotebookHook
	else
		DoWindow/T $notebookName, title[0,39]
		PB_EmptyNotebook(notebookName)
	endif
	return existed
End

Function PB_NotebookHook(infoStr)
	String infoStr
	
	String event= StringByKey("EVENT",infoStr)
	if( CmpStr(event,"kill") == 0 )
		DoWindow ProcBrowser
		if( V_Flag )
			Checkbox displaySource,win=ProcBrowser, value=0
		endif
	endif
	return WC_WindowCoordinatesHook(infoStr)
End

Function PB_EmptyNotebook(notebookName)
	String notebookName

	Notebook $notebookName selection={startOfFile, endOfFile}, text= ""
End


static Function IsMacintosh()
	return strsearch(IgorInfo(2), "Macintosh", 0, 2) != -1
End

Function PB_MoveWindowToUpperRightCorner(windowName)
	String windowName
	
	DoWindow $windowName
	Variable windowExists= V_Flag
	if( windowExists )
		GetWindow $windowName wsize
		Variable width= V_right- V_left		// in points
		Variable height= V_bottom - V_top	// in points
		
		Variable left, top, right, bottom
		if( IsMacintosh() )
			String ScreenSize = IgorInfo(0)								// returns a string with a bunch of stuff including screen size in pixels
			Variable temp = strsearch(ScreenSize, "RECT=", 0)			// parsing out the screen size stuff
			ScreenSize = ScreenSize[temp+5,strlen(ScreenSize)-1]		// keep only everything after RECT=
			left = str2num(StringFromList(0,ScreenSize,","))				// Edges of  main screen in pixels
			top = str2num(StringFromList(1,ScreenSize,","))
			right = str2num(StringFromList(2,ScreenSize,","))
			bottom = str2num(StringFromList(3,ScreenSize,","))

			// The screen coordinates are in pixels, but MoveWindow and GetWindow use points
			left  *= 72/ScreenResolution
			top  *= 72/ScreenResolution
			right   *= 72/ScreenResolution
			bottom  *= 72/ScreenResolution
		else
			GetWindow kwFrameInner wsize	// Edges of frame in points
			left = V_left		
			top = V_top		
			right = V_right
			bottom = V_bottom
		endif
		Variable offset = 8 // offset window 8 points from edge of screen or frame

		right -= offset
		left= right-width
		top += offset
		bottom = top+height
		
		MoveWindow/W=$windowName left, top, right, bottom
	endif
	return windowExists
End


Function PB_GetIndependentModuleDev()

	String oldDF= PB_SetDF()	// in case the user selects this before building the procedure browser panel
#if NumberByKey("IGORVERS", IgorInfo(0)) >= 6.1
	// Igor 6.1 marks the experiment modified after executing SetIgorOption in query mode.
	// It shouldn't, really, but we fix it here
	ExperimentModified 1	// mark it modified, not modifed, we don't care. We just want the current modified value, which is the local V_Flag
	Variable wasModified= V_Flag
#endif
	Execute "SetIgorOption IndependentModuleDev=?"	// sets V_Flag, marks the experiment modified.
	NVAR v= V_Flag
	Variable independentModuleDevEnabled= v
#if NumberByKey("IGORVERS", IgorInfo(0)) >= 6.1
	ExperimentModified wasModified	// set experiment modified back
#endif
	SetDataFolder oldDF
	return independentModuleDevEnabled
End