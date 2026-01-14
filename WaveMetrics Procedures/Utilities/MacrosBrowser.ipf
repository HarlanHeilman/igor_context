#pragma rtGlobals=2 // Enforce modern global access method and syntax
#pragma IgorVersion= 4.0	// Requires Igor Pro v4.0 or later.
#pragma version=4
//
// MacrosBrowser.ipf
//
// Version 4,  12/07/2000 - JP - Made Procedures Browser into a Macros Browser
// Version 3,  05/19/2000 - JP - window positions are remembered better.
// Version 2,  03/28/2000 - JP - Doesn't try to resize when the panel is minimized.
//                    01/28/2000 - JP - Changed popup into list, removed macro, function, and alphabetic checkboxes, reorganized controls.
// Version 1.4, 10/19/1999 - JP - added Procedure Text in Notebook, goto/list popup, and listings button.
// Version 1.3, 10/16/1999 - JP - added Procedures Listing in Notebook.

Menu "Misc"	// If this Menu item is put into the Procedure menu, MB_MacroBrowser() is displayed rather than executed!
				// Setting root:V_noMacroFind=1 would allow it to be in the Procedure Menu, but the user might not appreciate
				// having it there.
	"-"
	"Macros Browser", MB_MacroBrowser()
	MB_ReportAlphabetic(), MB_ToggleAlphabetic()
End

Function/S MB_SetDF()
	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:MacrosBrowser
	return oldDF
End

Function/S MB_DF()
	return "root:Packages:MacrosBrowser"
End

Function/S MB_DF_Var(varName)
	String varName
	return MB_DF()+":"+varName
End

Function/S MB_ReportAlphabetic()

	String checkStr=""
	String alphaStr= "Macros in Alphabetic Order"
	Variable alpha=NumVarOrDefault(MB_DF_Var("alphabetic"),1)
	if( alpha == 1 )
		checkStr= "!"+num2char(18)	// magic Mac checkmark char
	endif
	return checkStr + alphaStr
End

Function MB_ToggleAlphabetic()
	Variable alpha=NumVarOrDefault(MB_DF_Var("alphabetic"),1)
	alpha= 1-alpha
	String oldDF= MB_SetDF()	// in case the user selects this before building the procedure browser panel
	Variable/G alphabetic=  alpha
	SetDataFolder oldDF
	BuildMenu "Misc"
	DoWindow MacrosBrowser
	if( V_Flag )
		MB_UpdateControls()
	endif
	return alpha
End

Proc MB_MacroBrowser() // : Panel
	Silent 1	;PauseUpdate	// Building Macros Browser...

	DoWindow/F MacrosBrowser
	if( V_Flag == 1 )
		return
	endif
	
	String coords= MB_WindowCoordinatesGetStr("MacrosBrowser",1)
	if( strlen(coords) )		// use previous position
		String cmd="NewPanel/K=1/W=("+coords+") as \"Macros Browser\""
		Execute cmd
	else						// use default coordinates
		NewPanel/K=1/W=(2000+637,41,2000+826,240) as "Macros Browser"
	endif
	
	DoWindow/C MacrosBrowser
	if( strlen(coords) == 0 )
		MB_MoveWindowToURCorner("MacrosBrowser")
	endif
	
	String oldDF= MB_SetDF()
	String ms= StrVarOrDefault(MB_DF_Var("matchString"),"*")
	String/G matchString= ms
	String fm= StrVarOrDefault(MB_DF_Var("fileMatch"),"*")
	String/G fileMatch= fm
	String ltp= StrVarOrDefault(MB_DF_Var("lastTopProc"),"Procedure")
	String/G lastTopProc= ltp
	String/G firstLineText
	String listwn= MB_DF_Var("proceduresList")
	if( exists(listwn) != 1 )
		Make/O/T  $listwn
	endif
	Variable alpha=NumVarOrDefault(MB_DF_Var("alphabetic"),1)
	Variable/G alphabetic= alpha
	
	// added for macros browser
	String st=  StrVarOrDefault(MB_DF_Var("subtype"),"All")
	String/G subtype= st
	
	BuildMenu "Misc"
	SetDataFolder oldDF
	
	// Most of the controls are positioned at x=3
	SetVariable fileMatch,pos={3,2},size={182,15},proc=MB_MatchSetVar,title="Files Matching"
	SetVariable fileMatch,limits={-Inf,Inf,1},value= root:Packages:MacrosBrowser:fileMatch
	PopupMenu fileTypePop,pos={3,20},size={172,20},proc=MB_ProcBrowserTypePop,title="Files"
	PopupMenu fileTypePop,mode=2,popvalue="All Matching Files",value= #"MB_ProcedureFileList()"

	// subtype popup added for Window Macros Browser
	PopupMenu subtype,pos={3,43},size={123,20},proc=MB_ProcBrowserTypePop
	Variable mode=WhichListItem(st , "All;Graph;GraphStyle;GraphMarquee;Table;TableStyle;Layout;LayoutStyle;LayoutMarquee;Panel")
	mode= max(1,mode)
	PopupMenu subtype,mode=mode,popvalue=st,value= #"\"All;Graph;GraphStyle;GraphMarquee;Table;TableStyle;Layout;LayoutStyle;LayoutMarquee;Panel\""
	PopupMenu subtype, title="Subtype"
	SetVariable matchString,pos={3,66},size={168,15},proc=MB_MatchSetVar,title="Macros Matching"
	SetVariable matchString,limits={-Inf,Inf,1},value= root:Packages:MacrosBrowser:matchString

	ListBox proceduresList,pos={3,84},size={182,48},frame=4
	ListBox proceduresList,listWave=root:Packages:MacrosBrowser:proceduresList,mode= 1
	ListBox proceduresList,selRow= 0, proc=MB_ListboxProc
	SetVariable firstLine,pos={3,136},size={182,15},title=" "
	SetVariable firstLine,value= root:Packages:MacrosBrowser:firstLineText
//	Button displaySource,pos={8,132},size={100,20},title="Display Source", proc=MB_DisplaySourceInNotebook
	Button runMacro,pos={8,154},size={100,20},title="Run Macro", proc=MB_RunMacro
	Button gotoSource,pos={111,154},size={60,20},title="Go To", proc=MB_GotoSource
	Button listInNotebook,pos={8,177},size={100,20},proc=MB_ListInNotebookButton,title="Display List"
	Button hideAllProcs,pos={111,177},size={60,20},proc=MB_ProcBrowserHideButton,title="Hide All"
	if( strlen(coords) )		// resize for previous position
		MB_FitControlsToWindow()
	endif
	SetWindow kwTopWin,hook=MB_ProcBrowserHook
	MB_UpdateControls()
EndMacro
#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif


// Don't allow the panel to be made too narrow (Button widths)
// Don't allow the panel to be made too short (one list item, and rest of controls must fit)
// Grow the match fields horizontally
// Grow the list vertically and horizontally.
// Grow the first line field horizontally, and keep it below the vertically resized list
// Move the buttons below the vertically repositioned first line field.
Function MB_FitControlsToWindow()

	String win= "MacrosBrowser"

	// Don't allow the panel to be made too narrow (Button widths)
	// Don't allow the panel to be made too short (one list item, and rest of controls must fit)
	Variable winWidth=188 * PanelResolution(win) / ScreenResolution // convert from pixels to points
	Variable winHeight= 193 * PanelResolution(win) / ScreenResolution 
	Variable/C xy= MB_MinWindowSize(win,winWidth,winHeight)	// make sure the window isn't too small
	winWidth= real(xy) * ScreenResolution / PanelResolution(win) // convert from points to pixels
	winHeight= imag(xy) * ScreenResolution / PanelResolution(win) // convert from points to pixels
	if( (winWidth == 0) && (winHeight == 0 ) )	// minimized, don't move anything
		return 0
	endif
	// Grow the match fields horizontally
	Variable margin=3 // Most of the controls are positioned at x=3, with a right-hand margin of 3
	xy= MB_ControlSizes(win,"fileMatch")
	Variable width= winWidth-margin*2
	Variable setvarHeight= imag(xy)
	SetVariable fileMatch win=$win, size={width,setvarHeight}
	SetVariable firstLine win=$win, size={width,setvarHeight}
	SetVariable matchString win=$win, size={width,setvarHeight}

	// Grow the list vertically and horizontally.
	xy= MB_ControlPosition(win,"proceduresList")
	Variable yPos=  imag(xy)
	Variable reserveHeight= 67	// window height- firstLine y pos + some margin.
	Variable height= winHeight - reserveHeight - yPos
	ListBox proceduresList win=$win, size={width,height}

	// Keep the first line field below the vertically resized list
	yPos += height + 4	// new y position of firstLine, leaving room for list focus ring.
	SetVariable firstLine win=$win, pos={margin,yPos}

	// Move the buttons below the vertically repositioned first line field.
	yPos += setvarHeight + margin
	xy= MB_ControlPosition(win,"runMacro")
	Variable xPos= real(xy)						// same x pos as Display List
	xy= MB_ControlSizes(win,"runMacro")
	width= real(xy)	// same size as Display List
	height= imag(xy)	// all buttons are the same height
	Button runMacro win=$win, pos= {xPos, yPos}
	Button listInNotebook win=$win, pos= {xPos, yPos+height+margin}
	// Right-justify "Go To" and "Hide All" buttons
	xy= MB_ControlSizes(win,"gotoSource")
	width= real(xy)	// same size as Hide All
	Variable growWidth= 14 * MB_IsMacintosh()
	xPos= winWidth-growWidth - margin - width
	Button gotoSource win=$win, pos= {xPos, yPos}
	Button hideAllProcs win=$win, pos= {xPos, yPos+height+margin}
	return 0
End

Function MB_IsMacintosh()
	String platform= IgorInfo(2)
	return CmpStr(platform,"Macintosh") == 0
End

// real part is horizontal position in pixels, imaginary part is vertical position.
Function/C MB_ControlPosition(win,ctrlName)
	String win,ctrlName
	
	ControlInfo/W=$win $ctrlName
	Variable xPos=0,yPos=0
	if( V_Flag )
		xPos= V_Left
		yPos= V_Top
	endif
	return cmplx(xPos,yPos)
End

// real part is width in pixels, imaginary part is height.
Function/C MB_ControlSizes(win,ctrlName)
	String win,ctrlName
	
	ControlInfo/W=$win $ctrlName
	Variable xWidth=0,yHeight=0
	if( V_Flag )
		xWidth= V_Width
		yHeight= V_Height
	endif
	return cmplx(xWidth,yHeight)
End

// all dimensions are in points
Function/C MB_MinWindowSize(winName,minwidth,minheight)
	String winName
	Variable minwidth,minheight

	GetWindow $winName wsize
	Variable minimized= (V_right == V_left) && (V_bottom==V_top)
	if( minimized )
		return cmplx(0,0)
	endif
	Variable width= max(V_right-V_left,minwidth)
	Variable height= max(V_bottom-V_top,minheight)
	MoveWindow/W=$winName V_left, V_top, V_left+width, V_top+height
	return cmplx(width,height)
End

// This list is displayed in the fileTypePop PopupMenu control
Function/S MB_ProcedureFileList()

	String list= "Top Procedure;All Matching Files;-;Built-in Only;#include \"file\" only;#include <file> only;"

	String fileMatch= StrVarOrDefault(MB_DF_Var("fileMatch"),"*")
	String windowList= WinList(fileMatch,";","WIN:128")
	if( ItemsInList(windowList) > 1 )
		windowList= SortList(windowList,";",4)	// case-insensitive
		windowList= RemoveFromList("MacrosBrowser.ipf", windowList)	// hide self (Win)
		windowList= RemoveFromList("MacrosBrowser", windowList)		// hide self (Mac)
	endif
	if( ItemsInList(windowList) > 0 )
		list += "-;"+windowList	
	endif
	return list
End

// This list shows up in either the ListBox control or printed into a notebook (Display List button)
// The ListBox control is updated when it activates
Function/S MB_ProceduresList()

	Variable fileTypePop= 1
	String procTypeStr

	ControlInfo/W=MacrosBrowser fileTypePop
	if( V_Flag )
		fileTypePop= V_Value
		procTypeStr= S_Value
	endif
	
	ControlInfo/W=MacrosBrowser subtype
	SVAR subtype= $MB_DF_VAR("subtype")
	if( V_Flag )
		subtype= S_Value
	endif
	
	String windowList= "_none_"	// this value should never appear
	String options= ""
	String fileMatch= StrVarOrDefault(MB_DF_Var("fileMatch"),"*")
	if( strlen(fileMatch) == 0 )
		fileMatch= "*"
	endif

	switch( fileTypePop )
		case 1:
			String topProc=WinName(0,128,1) 	// Top Visible Procedure
			SVAR lpt= $MB_DF_VAR("lastTopProc")
			if( strlen(topProc) == 0 )
				// before using the last top proc, make sure it still exists
				lpt= StringFromList(0,WinList(lpt,";","WIN:128"))
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
			windowList= WinList(fileMatch,";","WIN:128")
			break;
		case 4:	// Built-in Only
			windowList= WinList(fileMatch,";","INCLUDE:1,WIN:128")
			break
		case 5:	//#include "fileName" only
			windowList= WinList(fileMatch,";","INCLUDE:2,WIN:128")
			break
		case 6:	// #include <fileName> only"
			windowList= WinList(fileMatch,";","INCLUDE:4,WIN:128")
			break
		default:
			if( fileTypePop >= 8 )	// a specific procedure
				windowList= procTypeStr	// and procTypeStr is that specific procedure.
			endif
			break
	endswitch
	
	if( fileTypePop != 1 )	// allow the browser to show up if it is the top procedure
		windowList= RemoveFromList("MacrosBrowser.ipf", windowList)	// hide self (Win)
		windowList= RemoveFromList("MacrosBrowser", windowList)		// hide self (Mac)
	endif
	
	String matchStr= StrVarOrDefault(MB_DF_Var("matchString"),"*")
	if( strlen(matchStr) == 0 )
		matchStr= "*"
	endif
	
	Variable numWindows= ItemsInList(windowList)
	if( numWindows < 1 )
		return "(no matching files)"
	endif
	
	String listOfMacros=""
	String listOfFunctions=""
	String opts,win

	String macroOpts = "WIN:"	// All
	if( CmpStr(subtype,"All") != 0 )
		macroOpts = "SUBTYPE:"+subtype+",WIN:"
	endif
	String functionOpts= "KIND:2,WIN:"	// user functions only (no builtin functions)
	Variable ii
	for( ii= 0;  ii < numWindows; ii += 1 )
		win= StringFromList(ii,windowList)
		listOfMacros+= MacroList(matchStr,";",macroOpts+win)
		// listOfFunctions += FunctionList(matchStr,";",functionOpts+win)	// Macros only
	endfor

//	String list= listOfMacros+listOfFunctions
	String list= listOfMacros	// macros only
	if( strlen(list) == 0 )
		list= "(no matching procedures)"
	else
		Variable alpha=NumVarOrDefault(MB_DF_Var("alphabetic"),1)
		if( alpha )
			list=  SortList(list,";",4)	// case insensitive
		endif
	endif
	
	return list
End

Function MB_ProcBrowserHook (infoStr)
	String infoStr
	String event= StringByKey("EVENT",infoStr,":",";")
	Variable statusCode= 0		// 0 if nothing done, else 1
	strswitch (event) 
		case "activate":
			MB_UpdateControls()
			statusCode=1
			break;
		case "resize":
			MB_FitControlsToWindow()
			statusCode=1
			break;
		case "kill":
			String windowName= StringByKey("WINDOW",infoStr,":",";")
			MB_WindowCoordinatesSave(windowName)
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

Function MB_ListboxProc(ctrlName,row,col,event)
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	 Variable event      // event code

	switch( event )
		case 2:	// mouse up
		case 4:	// cell selection (mouse or arrow keys)
			String selectedProc= MB_GetListSelection()
			SVAR firstLineText= root:Packages:MacrosBrowser:firstLineText
			firstLineText= MB_ProcsText(selectedProc,0)
			break;
		case 3:	// double click
			MB_GotoSource("")
			break;
	endswitch
	return 0            // other return values reserved
end

Function/S MB_GetListSelection()

	String selection= ""
	ControlInfo/W=MacrosBrowser proceduresList
	if( V_Flag )
		Variable index= V_Value
		String path=S_DataFolder+S_value
		WAVE/T tw=$path
		selection= tw[index]
	endif
	return selection
End

Function MB_GotoSource(ctrlName) : ButtonControl
	String ctrlName

	String wn= WinName(0,64)	// the panel
	
	String procName= MB_GetListSelection()
	if( exists(procName)  )
		DisplayProcedure/B=$wn procName
	endif
End

Function MB_RunMacro(ctrlName) : ButtonControl
	String ctrlName

	String wn= WinName(0,64)	// the panel
	
	String procName= MB_GetListSelection()
	if( exists(procName)  )
		Execute procName+"()"
	endif
End

Function MB_DisplaySourceInNotebook(ctrlName) : ButtonControl
	String ctrlName

	String wn= WinName(0,64)	// the panel
	
	String procName= MB_GetListSelection()
	if( exists(procName)  )
		MB_DisplayProcTextInNotebook(procName)
	endif
End

Function MB_ProcBrowserHideButton(ctrlName) : ButtonControl
	String ctrlName

	HideProcedures
	DoWindow/K ProcedureListing
	MB_UpdateControls()
End


Function MB_ProcBrowserTypePop(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	MB_UpdateControls()
End

Function MB_MatchSetVar(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	MB_UpdateControls()
End

Function MB_UpdateControls()

	Variable popMenuItem
	String currentSelection
	String list
	
	ControlInfo/W=MacrosBrowser fileTypePop
	if( V_Flag )
		popMenuItem= V_Value
		list= MB_ProcedureFileList()	// PopMenu fileTypePop value=MB_ProcedureFileList()
		if( popMenuItem > ItemsInList(list) )
			popMenuItem= 1
			PopupMenu fileTypePop win=MacrosBrowser, mode=popmenuItem
		endif
		ControlUpdate/W=MacrosBrowser fileTypePop
	endif

	ControlInfo/W=MacrosBrowser proceduresList
	if( V_Flag )
		Variable oldSelectionRow=V_Value
		currentSelection= MB_GetListSelection()		// preserve current selection
		list= MB_ProceduresList()
		String twn= MB_DF_Var("proceduresList")
		Variable listItems= ItemsInList(list)
		WAVE/T  tw= $twn
		Make/O/T/N=(listItems)  $twn=StringFromList(p,list)
		Variable newSelectionRow= WhichListItem(currentSelection,list)
		if( newSelectionRow < 0 )	// function isn't in the recomputed list of procedures.
			newSelectionRow= 0
			currentSelection= ""
		endif
		ListBox proceduresList, win=MacrosBrowser, selRow= newSelectionRow
		ControlUpdate/W=MacrosBrowser proceduresList
		
		if( newSelectionRow != oldSelectionRow )
			ListBox proceduresList, win=MacrosBrowser, row= newSelectionRow
			ControlUpdate/W=MacrosBrowser proceduresList
		endif

		SVAR firstLineText= root:Packages:MacrosBrowser:firstLineText
		currentSelection= MB_GetListSelection()		// new current selection
		firstLineText= MB_ProcsText(currentSelection,0)
		ControlUpdate/W=MacrosBrowser firstLine
	endif

End


Function MB_ProcBrowserCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	MB_UpdateControls()
End

Function MB_ListInNotebookButton(ctrlName) : ButtonControl
	String ctrlName
	MB_ListFunctionsInNotebook()
End


Function/S MB_DisplayProcTextInNotebook(procName)
	String procName
	
	String notebookName= "ProcedureListing"
	MB_CreateNotebook(notebookName,procName)
	Notebook $notebookName selection={endOfFile,endOfFile}, text=MB_ProcsText(procName,1)
	Notebook $notebookName selection={startOfFile,startOfFile}
	Notebook $notebookName selection={startOfParagraph,endOfParagraph},  findText={"", 1}
	return notebookName
End


Function/S MB_ProcsText(procName,wantAll)
	String procName
	Variable wantAll
	
	String text=ProcedureText(procName)
	if( !wantAll )
		text= StringFromList(0,text,"\r")
	endif
	return text
End

// Creates a new notebook listing the matched functions/macros
// just as they appear in the popup menu
//
Function/S MB_ListFunctionsInNotebook()
	
	String procedures= MB_ProceduresList()
	String notebookName= "ProcedureListing"
	String title= "Procedures "
	ControlInfo/W=MacrosBrowser fileTypePop
	if( V_Flag )
		title += S_Value
	endif
	String matchStr= StrVarOrDefault(MB_DF_Var("matchString"),"*")
	if( strlen(matchStr) == 0 )
		matchStr= "*"
	endif
	title += " matching "+matchStr
	MB_CreateNotebook(notebookName,title)
	Notebook $notebookName selection={endOfFile,endOfFile}, text=title+"\r\r"
	String theproc
	Variable i,n= ItemsInList(procedures)
	Variable pos
	for( i= 0; i < n; i += 1 )
		theproc= StringFromList(i,procedures)
		if( CmpStr(theProc,"\\M1(-") == 0 )
			theProc= "---- Functions ----"
		endif
		NoteBook $notebookName, selection={endOfFile,endOfFile}, text=theProc + "\r"
	endfor
End

Function MB_CreateNotebook(notebookName,title)
	String notebookName,title

	DoWindow/F $notebookName
	if( V_Flag == 0 )
		String coords= MB_WindowCoordinatesGetStr(notebookName,0)
		if( strlen(coords) )
			String cmd= "NewNotebook/K=1/F=0/V=2/W=("+coords+")/N="+notebookName+" as \"" +title[0,39]+"\""
			Execute cmd
		else
			NewNotebook/K=1/F=0/V=2/W=(2000+514,200,2000+826,400)/N=$notebookName as title[0,39]
			AutoPositionWindow/E/M=1/R=MacrosBrowser $notebookName
		endif
		Notebook $notebookName fSize=9
		// SetWindow $notebookName hook=MB_WindowCoordinatesHook
		SetWindow kwTopWin hook=MB_WindowCoordinatesHook
	else
		DoWindow/T $notebookName, title[0,39]
		MB_EmptyNotebook(notebookName)
	endif
End

Function MB_EmptyNotebook(notebookName)
	String notebookName

	Notebook $notebookName selection={startOfFile, endOfFile}, text= ""
End

Function MB_MoveWindowToURCorner(windowName)
	String windowName
	
	// Get current window dimensions into V_left, V_right, V_top, and V_bottom (in points!)
	DoWindow/F $windowName		// MoveWindow works on the top (named) window
	Variable windowExists= V_Flag
	if( windowExists )
		GetWindow $windowName wsize
		Variable width= V_right- V_left		// in points
		Variable height= V_bottom - V_top	// in points
		
		String ScreenSize = IgorInfo(0)								// returns a string with a bunch of stuff including screen size in pixels
		Variable temp = strsearch(ScreenSize, "RECT=", 0)			// parsing out the screen size stuff
		ScreenSize = ScreenSize[temp+5,100]						// hack out everything after RECT=
		Variable left = str2num(StringFromList(0,ScreenSize,","))		// Edges of screen
		Variable top = str2num(StringFromList(1,ScreenSize,","))
		Variable right = str2num(StringFromList(2,ScreenSize,","))
		Variable bottom = str2num(StringFromList(3,ScreenSize,","))
		Variable offset = 12											// Offset window this far from edge of screen
		
		// The screen coordinates are in pixels, but MoveWindow and GetWindow use points
		left  *= PanelResolution(windowName)/ScreenResolution
		top  *= PanelResolution(windowName)/ScreenResolution
		right   *= PanelResolution(windowName)/ScreenResolution
		bottom  *= PanelResolution(windowName)/ScreenResolution
		offset   *= PanelResolution(windowName)/ScreenResolution

		right -= offset
		left= right-width
		top += offset
		bottom = top+height
		
		MoveWindow left, top, right, bottom
	endif
	return windowExists
End


// 
// SaveRestoreWindowCoords.ipf - Window Coordinates Save/Restore Utilities, based on window name.
// 

//
//	MB_WindowCoordinatesHook
//
// Usage: SetWindow yourWindowName hook=MB_WindowCoordinatesHook
//
// or call MB_WindowCoordinatesHook() from your own window hook
//
Function MB_WindowCoordinatesHook(infoStr)
	String infoStr
	Variable statusCode= 0
	String event= StringByKey("EVENT",infoStr)
	if( CmpStr(event,"kill") == 0 )
		String windowName= StringByKey("WINDOW",infoStr)
		MB_WindowCoordinatesSave(windowName)
		statusCode= 1
	endif
	return statusCode
End

//
//	MB_WindowCoordinatesRestore
//
//	If coordinates for the named window have been saved,
//	the window is moved and sized accordingly, and 1 is returned.
//
//	If no coordinates are found, 0 is returned.
//
Function MB_WindowCoordinatesRestore(windowName)
	String windowName

	Variable restored= 0
	Variable vLeft, vTop, vRight, vBottom
	if( MB_WindowCoordinatesGetNums(windowName, vLeft,vTop, vRight, vBottom) )
		if( strlen(windowName) == 0 )
			windowName= WinName(0,255)
		endif
		MoveWindow/W=$windowName vLeft, vTop, vRight, vBottom
		 restored= 1
	endif
	return restored
End

// MB_WindowCoordinatesSprintf
//
// %s in fmt is replaced with left,top,right,bottom
//
// Examples:
//
// String fmt="Display/W=(%s) as \"the title\""
// Execute MB_WindowCoordinatesSprintf("eventualGraphName",fmt,x0,y0,x1,y1,0)	// points
//
//
// String fmt="NewPanel/W=(%s)"
// Execute MB_WindowCoordinatesSprintf("eventualPanelName",fmt,x0,y0,x1,y1,1)	// pixels
//
Function/S MB_WindowCoordinatesSprintf(windowName,fmt,defLeft,defTop,defRight,defBottom,wantPixels)
	String windowName,fmt
	Variable defLeft,defTop,defRight,defBottom,wantPixels
	
	MB_WindowCoordinatesGetNums(windowName, defLeft,defTop,defRight,defBottom) 
	String coordinates
	sprintf coordinates, "%g, %g, %g, %g",defLeft,defTop,defRight,defBottom
	String result
	Sprintf result, fmt, coordinates	// %s in fmt is replaced with left,top,right,bottom
	return result
end

//
//	MB_WindowCoordinatesSave
//
// Window coordinates are saved in a 5-column text wave
// as windowname,num2istr(left),num2istr(top),num2istr(right),num2istr(bottom)
//
Function MB_WindowCoordinatesSave(windowName)
	String windowName
	
	if( strlen(windowName) == 0 )
		windowName= WinName(0,255)
	endif
	DoWindow $windowName
	if( V_Flag == 0 )
		return 0
	endif
	Variable row
	String dfSav= MB_SetDF()
	if( exists("W_windowCoordinates") != 1 )
		Make/O/T/N=(0,5) W_windowCoordinates
		WAVE/T coords= $MB_DF_Var("W_windowCoordinates")
		row= -1	// add new row
	else
		// search for matching row
		WAVE/T coords= $MB_DF_Var("W_windowCoordinates")
		row= MB_WindowCoordinatesRow(coords,windowName)
	endif
	if( row == -1 )
		InsertPoints/M=0 0,1,coords
		row= 0
	endif
	GetWindow $windowName, wsize		// always returns points
	coords[row][0]=windowName
	coords[row][1]=num2str(V_left)
	coords[row][2]=num2str(V_top)
	coords[row][3]=num2str(V_right)
	coords[row][4]=num2str(V_bottom)
	SetDataFolder dfSav
	return 1
End

Function MB_WindowCoordinatesRow(coords,windowName)
	Wave/T coords
	String windowName
	
	Variable rows = DimSize(coords,0)
	Variable row= -1
	if( rows > 0 )
		do
			row += 1
			if( CmpStr(windowName,coords[row][0]) == 0 )
				return row
			endif
		while( row < rows-1 )
		row= -1	// not found
	endif
	return row
end

//
//	MB_WindowCoordinatesGetNums
//
//	If coordinates for the named window were found,
//		stores the coordinates into the vXXX variables, and 1 is returned.
//	If not found,
//		the vXXX variables are unchanged, and 0 is returned.
//
Function MB_WindowCoordinatesGetNums(windowName, vLeft, vTop, vRight, vBottom)
	String windowName
	Variable &vLeft, &vTop, &vRight, &vBottom	// pass by reference, not by value

	if( strlen(windowName) == 0 )
		return 0
	endif
	WAVE/Z/T coords= $MB_DF_Var("W_windowCoordinates")
	if( WaveExists(coords) == 0 )
		return 0
	endif
	Variable row= MB_WindowCoordinatesRow(coords,windowName)
	if( row < 0 )
		return 0
	endif
	vLeft= str2num(coords[row][1])	// changes value in calling routine !
	vTop= str2num(coords[row][2])
	vRight= str2num(coords[row][3])
	vBottom= str2num(coords[row][4])

	return 1
End

// returns "" or the coordinates separated by commas
// prints window coordinates in the returned string.
Function/S MB_WindowCoordinatesGetStr(windowName,usePixels)
	String windowName
	Variable usePixels	// set to 0 for points (normal), non-zero for pixels (panels)

	String coordinates= ""
	Variable vLeft, vTop, vRight, vBottom
	if( MB_WindowCoordinatesGetNums(windowName, vLeft, vTop, vRight, vBottom) )
		if( usePixels ) // convert from saved points to pixels
			vLeft *= ScreenResolution/PanelResolution(windowName)
			vTop *= ScreenResolution/PanelResolution(windowName)
			vRight *= ScreenResolution/PanelResolution(windowName)
			vBottom *= ScreenResolution/PanelResolution(windowName)
		endif
		sprintf coordinates, "%g, %g, %g, %g", vLeft, vTop, vRight, vBottom
	endif
	return coordinates
End
