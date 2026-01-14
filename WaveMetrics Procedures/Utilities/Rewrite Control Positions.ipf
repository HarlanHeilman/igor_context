#pragma rtGlobals=3		// Use modern global access method.
#pragma independentModule=RCP
#pragma moduleName=RewriteControlPositions
#pragma IgorVersion=6.2	// For #pragma rtGlobals=3
#pragma version=7		// Shipped with Igor 7

#include <Resize Controls>
#include <SaveRestoreWindowCoords>

// Rewrite Control Positions.ipf
//
// Version 6.1, 5/12/2009 - JP - Initial version.
// Version 6.1, 6/12/2009 - JP - Prevented addition of WMspecific user data from listbox and popup menus. This will be a futile effort to keep them up-to-date, sorry!
// Version 6.2, 3/31/2010 - JP - Fixed rewriting of title when regExpTitle produced weird stuffAfter results. Added PopupWS_filterProc to list of WMspecific user data.
// Version 6.2, 6/28/2010 - JP - Rewriting a line when the replacement is "" no longer results in double commas.
// Version 6.21, 9/24/2010 - JP - added way to pre-set the panel to rewrite, made title and menu items match.
// Version 7, 6/14/2016 - JP - rewritten positions and sizes use integers when possible.

// Set these two definitions to "" when revising this procedure file
Static StrConstant ksIgnoreProcedureFile= "Rewrite Control Positions.ipf"	// this procedure file
Static StrConstant ksIgnoreWindow= "RewriteControlsPanel"				// this file's panel

Static StrConstant ksPanelName="RewriteControlsPanel"
Static StrConstant ksNotebookName="RewriteControlsPanel#CODE"

Static StrConstant ksNoWindows= "_no graphs or panels_"
Static StrConstant ksNone= "_none_"

Menu "Panel", hideable
	"Rewrite Control Positions, etc in Procedure...", /Q, ShowRewriteControlsPanel()
End
Menu "Procedure", hideable
	"Rewrite Control Positions, etc in Procedure...", /Q, ShowRewriteControlsPanel()
End

static Function/S GetTextToRewrite(isEntireFunction)
	Variable &isEntireFunction

	String text=""
	String procedureTitle=ChosenProcedureWindow()
	ControlInfo/W=$ksPanelName radioPopup
	if( V_Value )
		isEntireFunction= 1
		ControlInfo/W=$ksPanelName procedurePop
		String procedureName= S_Value
		if( strlen(procedureName) && CmpStr(procedureName, ksNone) != 0 )
			procedureTitle= ProcedureTitleWithIM(procedureTitle)
			text= ProcedureText(procedureName,0,procedureTitle)
		endif
	else		// selection
		isEntireFunction= 0	// without analyzing the selected text, we guess.
		getselection procedure, $procedureTitle, 3
		if( V_flag )
			text= S_Selection
		endif
	endif
	 return text
End

// Update code in notebook
Static Function UpdateShownProcedure()

	String text=""
	String procedureTitle=ChosenProcedureWindow()
	String warning=""
	ControlInfo/W=$ksPanelName radioPopup
	if( V_Value )
		ControlInfo/W=$ksPanelName procedurePop
		String procedureName= S_Value
		if( strlen(procedureName) && CmpStr(procedureName, ksNone) != 0 )
			procedureTitle= ProcedureTitleWithIM(procedureTitle)
			text= ProcedureText(procedureName,0,procedureTitle)
		else
			warning= "(No functions or macros in \""+ procedureTitle +"\")"
		endif
	else		// selection
		getselection procedure, $procedureTitle, 3
		if( V_flag && strlen(S_Selection) )
			text= S_Selection
		else
			warning= "(No text is selected text in procedure \""+ procedureTitle +"\")"
		endif
	endif
	
	TitleBox selectionWarning, win=$ksPanelName, title=warning
	
	Notebook $ksNotebookName, selection={startOfFile, endOfFile}, text=text
	Notebook $ksNotebookName selection={startOfFile, startOfFile},  findText={"", 1}
End

Static Function WindowHook(hs)
	STRUCT WMWinHookStruct &hs
	
	strswitch(hs.eventName)
		case "activate":
			UpdateListOfControls()
			UpdateShownProcedure()	// after saving/updating the recreation macro of the RewriteControlsPanel itself, this is too early. For all other uses, it's fine.
			EnableDisableControls()
			break
		case "kill":
			WC_WindowCoordinatesSave(hs.winName)
			break
	endswitch
	return 0
End

Static Function EnableDisableControls()

	// Disable "Rewrite Selected Text" if no text is selected.
	Variable isEntireFunction
	String text= GetTextToRewrite(isEntireFunction)

	Variable disable= 2
	String win= SelectedWindow()
	if( strlen(win) )
		ControlInfo/W=$ksPanelName subwindowsCheck
		Variable wantSubWindows= V_Value
		String controls= GetListOfControls(win, wantSubWindows)
		Variable controlsOK = strlen(controls) && strlen(DuplicatesInList(controls,",")) == 0
		disable= strlen(text) && controlsOK ? 0 : 2
	endif
	Button doit, win=$ksPanelName, disable=disable
End

// The simple logic used here means that if there are 5 identical list items,
// 4 of them are in the duplicates list: they're the ones that need to be removed to make the list unique.
Static Function/S DuplicatesInList(list,sep)
	String list,sep
	
	String duplicates=""
	list= SortList(list,sep,4)	// case insensitive sort
	Variable i, n= ItemsInList(list,sep)
	String previous=StringFromList(0,list,sep)
	for(i=1; i<n; i+=1)
		String this= StringFromList(i,list,sep)
		if( CmpStr(this,previous) == 0 )
			duplicates += this+sep
		endif
		previous= this
	endfor
	
	return duplicates
End

Static Function RewriteRadioCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	// Implement radio button behavior
	Checkbox radioPopup, win=$ksPanelName, value=(CmpStr(ctrlName,"radioPopup") == 0) ? 1 : 0
	Checkbox radioSelection, win=$ksPanelName, value= (CmpStr(ctrlName,"radioSelection") == 0 )? 1 : 0
	UpdateShownProcedure()
	EnableDisableControls()
End

Static Function ProcedurePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	UpdateShownProcedure()
	EnableDisableControls()
End


Static Function/S ListOfChildWindows(hostWindow)
	String hostWindow

	String list= hostWindow+";"

	Variable type= WinType(hostWindow)
	if( type )
		String subwindows= ChildWindowList(hostWindow)
		Variable i, n= ItemsInList(subwindows)
		for(i=0; i<n; i+=1 )
			String subwindow= hostWindow+"#"+StringFromList(i,subwindows)
			list += ListOfChildWindows(subwindow)
		endfor
	endif

	return list
End

Static Function/S SelectedWindow()

	String win= ""
	ControlInfo/W=$ksPanelName panelPop
	if( V_Flag > 0 )
		win= S_Value
		if( WinType(win) == 0 )
			win= ""
		endif
	endif
	
	return win
End

Static Function/S WindowsPopMenu()	// returns list of panels and graphs

	String list
	if( strlen(ksIgnoreWindow) )
		list= WinList("!"+ksIgnoreWindow+"*",";","WIN:65")
	else
		list= WinList("*",";","WIN:65")
	endif
	if( strlen(list) )
		String currentWindow= SelectedWindow()
		if( strlen(currentWindow) )	// could be "Graph0#PTOP"
			String hostWindow= StringFromList(0,currentWindow,"#")
			list = RemoveFromList(hostWindow, list)+ListOfChildWindows(hostWindow)
		endif
		list= SortList(list)
	else
		list=ksNoWindows
	endif
	return list
End

Static Function/S ProcedureWindowsPopMenu()

	String procedureList=WinList("*",";","INDEPENDENTMODULE:1,WIN:128")
	if( strlen(ksIgnoreProcedureFile) )
		procedureList=RemoveFromList(ksIgnoreProcedureFile,procedureList)
		String im= GetIndependentModuleName()	// "ProcGlobal" if we're not in another independent module.
		procedureList=RemoveFromList(ksIgnoreProcedureFile+" ["+im+"]",procedureList)
	endif
	return SortList(procedureList)
End

Static Function/S ChosenProcedureWindow()

	String win=""
	Controlinfo/W=$ksPanelName procWinPop
	if( V_Flag == 3 )
		win= S_Value
	endif
	
	return win
End

// Routines like ProcedureText need [ProcGlobal] appended to the title in order to work inside an independent module
// This routine adds [ProcGlobal] if no other independent module is specified
Static Function/S ProcedureTitleWithIM(procedureTitle)
	String procedureTitle	// with or without a trailing " [<imName>]"

	Variable winHasIndependentModule= strsearch(procedureTitle,"[",0) >= 0
	if( !winHasIndependentModule )
		procedureTitle += " [ProcGlobal]"
	endif
	return procedureTitle
End

// List of Functions and Macros in the chosen procedure window
Static Function/S ProceduresList()

	String win= ChosenProcedureWindow()
	String winOption="WIN:"+ProcedureTitleWithIM(win)	// appends " [ProcGlobal]" if win isn't in an independent module (needed if this code is in an independent module)
	String listOfMacros= ""
	
	if( strsearch(winOption, " [ProcGlobal]",0) > 0 )
		listOfMacros= MacroList("*",";","WIN:"+win)	// Macros are allowed only in ProcGlobal, not (other) independent modules
	endif
	String listOfFunctions= FunctionList("*",";","KIND:18,"+winOption)
	String listOfProcedures = SortList(listOfMacros+listOfFunctions)
	if( strlen(listOfProcedures) == 0 )
		listOfProcedures= ksNone
	endif
	return listOfProcedures
End

Static Function PanelPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	UpdateListOfControls()
End

Static Function SubwindowsCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	UpdateListOfControls()
End

// WARNING: returns comma-separated list of control names.
Static Function/S GetListOfControls(win, wantSubWindows)
	String win
	Variable wantSubWindows
	
	String controls= ""
	String wins= win
	if( WinType(wins) )
		if( wantSubWindows )
			wins= ListOfChildWindows(wins)	// includes parameter window in list
		endif
		Variable i, n=ItemsInList(wins)
		for( i=0; i<n; i+=1 )
			win= StringFromList(i,wins)
			Variable wt=Wintype(win)
			if( wt == 1 || wt == 7 )	// graph or panel
				controls += ControlNameList(win,",")
				// We assume here that the control names are all unique even though in different windows.
				// We COULD check it here, but is actually done in UpdateListOfControls()
			endif
		endfor
	endif
	return controls
End

static Function UpdateListOfControls()

	String title=""
	String win= SelectedWindow()
	if( strlen(win) > 0 )
		ControlInfo/W=$ksPanelName subwindowsCheck
		Variable wantSubWindows= V_Value
		String controls= GetListOfControls(win, wantSubWindows)
		if( strlen(controls) )
			String duplicatedControls= DuplicatesInList(controls,",")
			if( strlen(duplicatedControls) == 0 )
				title= "Controls: "+RemoveEnding(controls,",")
			else
				title= "Error: rewriting would fail because pf duplicated controls: "+RemoveEnding(duplicatedControls,",")
			endif
			if( strlen(title) > 100 )
				title[97,inf]="..."
			endif
		else
			title= "(no controls in \""+win+"\")"
		endif
	endif
	TitleBox listOfControlsInPanel, win=$ksPanelName, title=title
End


Static Function GoToButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName procWinPop
	String procedureTitle= S_Value

	ControlInfo/W=$ksPanelName radioPopup
	if( V_Value )
		ControlInfo/W=$ksPanelName procedurePop
		String procedureName= S_Value
		DisplayProcedure/W=$procedureTitle procedureName
	else		// selection
		DisplayProcedure/W=$procedureTitle
		DoIgorMenu "Edit", "Display Selection"
	endif
End

static Function HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "Rewrite Control Positions Panel"
End

static Function CancelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Execute/P/Q/Z "DoWindow/K "+ksPanelName
End

static Function ProcwinPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable mode= 1
	ControlInfo/W=$ksPanelName procedurePop
	if( V_Flag > 0 )
		String matchThis= S_Value
		mode= WhichListItem(S_Value,ProceduresList())+1
		if( mode < 1 )
			mode= 1
		endif
	endif
	PopupMenu procedurePop, win=$ksPanelName, mode=mode
	UpdateShownProcedure()
End

Static Function RewriteButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName panelPop
	String win= S_Value
	
	ControlInfo/W=$ksPanelName subwindowsCheck
	Variable wantSubwindows= V_Value

	ControlInfo/W=$ksPanelName rewriteDisableCheck
	Variable rewriteDisable= V_Value

	ControlInfo/W=$ksPanelName rewriteUserDataCheck
	Variable rewriteUserData= V_Value

	Variable isEntireFunction
	String functionText= GetTextToRewrite(isEntireFunction)		// sets isEntireFunction, too
	RewriteControlPositionsText(win, wantSubwindows, rewriteDisable, rewriteUserData, functionText, isEntireFunction)	// creates notebook
End

Static Function RewriteControlPositionsText(win, wantSubwindows, rewriteDisable, rewriteUserData, functionText, isEntireFunction)
	String win
	Variable wantSubwindows, rewriteDisable, rewriteUserData
	String functionText		// text from procedure file
	Variable isEntireFunction

	String controlsFoundInCode=""	// keep track of which controls were found in the code. If a given control wasn't used, the code needs to be augmented with the full definition, probably.
	String controlsChangedInCode=""	// keep track of which controls were used to change text in the code
	String controlsInWindow=""		// keep track of which controls were found in the window(s).

	// We rewrite a copy of the function text AND the notebook at the same time,
	// to make it easier to identify the changes.
	String changedFunctionText= functionText

	// Create a formatted notebook window with the function text.
	String nb= "RewrittenCode"
	DoWindow/F $nb
	if( V_Flag == 0 )
		NewNotebook/F=1/N=$nb
		Variable right= 24*72	// points
		Notebook $nb margins={0,0,right}
	endif
	Notebook $nb selection={startOfFile, endOfFile}, textRGB=(0,0,0), text=changedFunctionText, findText={"",1}	

	String wins= win
	if( wantSubWindows )
		wins= ListOfChildWindows(wins)	// includes parameter window in list
	endif
	Variable i, numWindows=ItemsInList(wins)
	String onlyPanelAndGraphs=""
	for( i=0; i<numWindows; i+=1 )
		win= StringFromList(i,wins)
		Variable wt=Wintype(win)
		if( wt != 1 && wt != 7 )	// not graph or panel, so skip it!
			continue
		endif
		onlyPanelAndGraphs += win+";"

		String controls = ControlNameList(win)
		controlsInWindow += controls

		Variable j, numControls=ItemsInList(controls)
		for( j=0; j<numControls; j+=1 )
			String controlName= StringFromList(j, controls)
			Variable foundControl=0, changedControl= 0
 			changedFunctionText= RewriteOneControlsProcedureText(nb, win, controlName, rewriteDisable, rewriteUserData, changedFunctionText, isEntireFunction, foundControl, changedControl)	// return truth the control was found
			if( foundControl )
				controlsFoundInCode += controlName + ";"
			endif
			if( changedControl )
				controlsChangedInCode += controlName + ";"
			endif
		endfor
	endfor

	// Add comments about controls in the windows that weren't found in the text.
	// We have:
	// 		controlsInWindow = a list of controls from the window(s)
	// 		controlsFoundInCode = a list of controls found in the function text

	Variable seeStuffAtEnd= 0

	Variable n= ItemsInList(controlsInWindow)
	String missingControls= ""
	for(i=0; i<n; i+=1)
		controlName= StringFromList(i,controlsInWindow)
		if( WhichListItem(controlName, controlsFoundInCode) < 0 )
			missingControls= AddListItem(controlName,missingControls)
		endif
	endfor
	n=ItemsInList(missingControls)
	if( n )
		// scroll to the end
		Notebook $nb selection={endOfFile, endOfFile},findText={"", 0}
		String comment
		if( isEntireFunction )
			comment= "These controls from "+RemoveEnding(onlyPanelAndGraphs,";")+" were not found in the function:"
		else
			comment= "These controls from "+RemoveEnding(onlyPanelAndGraphs,";")+" were not found in the selected text:"
		endif
		Notebook $nb textRGB=(65535,0,0), text="\r"+comment+"\r\r"
		Print comment
		Print "\t"+missingControls

		// Add the full text of the missing controls recreation text at the top
		for(i=0; i<n; i+=1)
			controlName= StringFromList(i,missingControls)
			// look through all the windows for the control
			numWindows=ItemsInList(onlyPanelAndGraphs)
			for( j=0;j<numWindows; j+=1 )
				win= StringFromList(j,wins)
				ControlInfo/W=$win $controlName
				if( V_Flag )
					Notebook $nb textRGB=(0,0,65535), text=S_recreation+"\r"
					break
				endif
			endfor
		endfor
		seeStuffAtEnd= 1
	endif

	if( rewriteUserData )	
		// examine changedFunctionText for SetWindow yada yada userdata statements, and see if they match the window recreation text's
		// If not, show the new window recreation text.
		String textUserdataCommands= GetUserDataFromText(changedFunctionText, "SetWindow")
		String shiftedTextCommands= RemoveLeadingSpacesFromItems(textUserdataCommands,"\r")

		String windowUserdataCommands= GetUserDataFromWindows(wins,  "SetWindow")
		String shiftedWindowCommands= RemoveLeadingSpacesFromItems(windowUserdataCommands,"\r")

		if( CmpStr(shiftedTextCommands,shiftedWindowCommands) != 0 )
			// scroll to the end
			Notebook $nb selection={endOfFile, endOfFile},findText={"", 0}
			Notebook $nb textRGB=(65535,0,0), text="\rSetWindow userdata in the text is different than in the window(s).\r\r"	// red
	
			Notebook $nb textRGB=(0,0,65535), text="SetWindow userdata in the text:\r\r"		// blue
			if( strlen(textUserdataCommands) == 0 )
				textUserdataCommands= "\t(No SetWindow userdata commands were found in text.)\r"
			endif
			Notebook $nb textRGB=(0,0,65535), text=textUserdataCommands+"\r"				// blue
	
			Notebook $nb textRGB=(8939,32026,5061), text="SetWindow userdata in the window(s):\r\r"	// green
			if( strlen(windowUserdataCommands) == 0 )
				windowUserdataCommands= "\t(No SetWindow userdata was found in the window(s).)\r"
			endif
			Notebook $nb textRGB=(8939,32026,5061), text=windowUserdataCommands+"\r"	// green
			Notebook $nb selection={endOfFile, endOfFile}, findText={"", 0}, textRGB=(0,0,0), text="\r"
			seeStuffAtEnd= 1
		endif
	endif
	
	// scroll back to the top again
	Notebook $nb selection={startOfFile, startOfFile },findText={"", 1}
	Variable numChanged=ItemsInList(controlsChangedInCode)
	if( numChanged )
		Notebook $nb textRGB=(65535,0,0), text="Changes indicated below in red:\r\r"
	else
		Notebook $nb textRGB=(65535,0,0), text="NOTE: No control positions were changed.\r\r"
	endif
	
	if( seeStuffAtEnd )
 		Notebook $nb textRGB=(65535,0,0), text="ALSO: See comments after the code.\r\r"
	endif
	return numChanged
End

Static Function/S RemoveLeadingSpacesFromItems(list, sep)
	String list, sep
	
	String spaces, goodStuff, cleaned=""
	String regExpr="^([[:blank:]]*)(.*)"

	Variable i, n= ItemsInList(list,sep)
	for(i=0; i<n; i+= 1)
		String str= StringFromList(i,list,sep)
		SplitString/E=regExpr str, spaces, goodStuff
		if( V_flag == 2 )
			str= goodStuff
		endif
		cleaned = str + sep
	endfor
	
	return cleaned
End

Static Function/S GetUserDataFromWindows(wins, command)
	String wins
	String command	// "SetWindow" or "ModifyGraph" (perhaps also "Button", etc

	String allRrecreationTexts= ""
	Variable i, n=ItemsInList(wins)
	for(i=0; i<n; i+= 1 )
		String win= StringFromList(i,wins)
		String recreationText= WinRecreation(win, 4)
		recreationText=GetUserDataFromText(recreationText, command)
		allRrecreationTexts += recreationText
	endfor

	return allRrecreationTexts
End

Static Function/S GetUserDataFromText(recreationText, command)
	String recreationText	// \r-separated list, as per ControlInfo's S_recreation
	String command	// "SetWindow" or "ModifyGraph" (perhaps also "Button", etc

	String regExpr="(?i)[[:blank:]]*"+command+"[[:blank:]]+.*[,[:blank:]]+userdata[\\(\\+=[:blank:]]+"
	recreationText= GrepList(recreationText, regExpr, 0, "\r")

	return recreationText
End

Static Function/S GetRecreationTextByRegExp3(recreationText, regExpr)
	String recreationText	// \r-separated list of commands.
	String regExpr			// must have two or more subpatterns: the second one is what's returned. Beware nested subpatterns: they're counted in V_Flag
	
	String text="", stuffBefore, matched, stuffAfter
	
	Variable i, n= ItemsInList(recreationText,"\r")
	for(i=0; i<n; i+= 1 )
		String recreation= StringFromList(i,recreationText,"\r")	// "Button button0 pos={left,top}, size={width,height}"

		SplitString /E=regExpr recreation, stuffBefore, matched, stuffAfter
		if( V_Flag >= 2 )
			text= matched
			break			// presumes there's only one such match
		endif
	endfor
	
	return text
End

// Returns the length of stuff at the end of str that amounts to a run of spaces and one comma.
static Function/S EndingSeparatorAndWhitespace(str)
	String str
	
	String regExpr= "(?i)([[:blank:]]*,[[:blank:]]*)$"
	String matched
	SplitString /E=regExpr str, matched
	if( V_Flag != 1 )
		return ""
	endif
	
	return matched
End

static Function/S StartingSeparatorAndWhitespace(str)
	String str
	
	String regExpr= "(?i)^([[:blank:]]*,[[:blank:]]*)"
	String matched
	SplitString /E=regExpr str, matched
	if( V_Flag != 1 )
		return ""
	endif
	
	return matched
End

Static Function/S RewriteOneLine(nb, line, stuffBefore, stuffToReplace, replacement, stuffAfter)
	String nb
	Variable line			// 0-based, this line already exists in the notebook as stuffBefore+stuffToReplace+stuffAfter
	String stuffBefore	// unchanged part before the change
	String stuffToReplace	// replace this....
	String replacement		// ... with this (set to "" to delete stuffToReplace), in which case either a leading or trailing ",," is changed to ","
	String stuffAfter		// unchanged part after the change, may or may not include a trailing \r
	
	if( strlen(replacement) == 0 )	// JP100628
		// deletion. replacing "disable=2" with "" could strand a comma either before or after the deleted "disable=2"
		String trailingSeparator= EndingSeparatorAndWhitespace(stuffBefore)
		Variable trailingSepLen=strlen(trailingSeparator)
		if( trailingSepLen )
			stuffBefore= stuffBefore[0,strlen(stuffBefore)-(trailingSepLen+1)]
			stuffToReplace=trailingSeparator+stuffToReplace
		else
			String leadingSeparator=StartingSeparatorAndWhitespace(stuffAfter)
			Variable leadingSepLen=strlen(leadingSeparator)
			if( leadingSepLen )
				stuffAfter= stuffAfter[leadingSepLen,strlen(stuffAfter)-1]
				stuffToReplace=stuffToReplace+leadingSeparator
			endif
		endif
	endif
	
	Variable startOfChange= strlen(stuffBefore)
	Variable originalLength= strlen(stuffToReplace)
	Variable newLength= strlen(replacement)

	Notebook $nb selection={(line,startOfChange), (line,startOfChange+originalLength)},  textRGB=(65535,0,0), text=replacement

	return stuffBefore+replacement+stuffAfter
End

Static Function/S InsertLineAtLine(nb, insertAtLine, functionText, insertThisText, useRed)
	String nb, functionText
	String insertThisText	// a full line, without trailing "\r"
	Variable insertAtLine	// 0-based, the line where insertThisLineOfCode will reside
	Variable useRed

	Notebook $nb selection={(insertAtLine,0), (insertAtLine,0)}, textRGB=(useRed*65535,0,0), text=insertThisText+"\r"
	
	functionText= AddListItem(insertThisText, functionText, "\r", insertAtLine)

	return functionText
End

Static Function DeleteOneNotebookLine(nb, line)
	String nb
	Variable line			// 0-based, this line already exists in the notebook

	Notebook $nb selection={(line,0), startOfNextParagraph}, text=""
End

Static Function/S AppendToCodeLine(nb, line, functionText, appendThisText)
	String nb, functionText, appendThisText
	Variable line	// 0-based
	
	String code= StringFromList(line, functionText, "\r")
	
	RewriteOneLine(nb, line, code, "", appendThisText, "")
	
	functionText= RemoveListItem(line, functionText, "\r")
	functionText= AddListItem(code, functionText, "\r", line)

	return functionText
End

// works only with "keyword={num1,num2}" strings
// convert size={75.00,15.00} to size={75,15}
Static Function/S SimplifyFloatToInt(keyword,strWithNums)
	String keyword,strWithNums

	Variable num1, num2
	sscanf strWithNums, keyword+"={%g,%g}", num1, num2
	if( V_flag ==2 && trunc(num1) == num1 && trunc(num2) == num2 )
		sprintf strWithNums, keyword+"={%d,%d}", num1, num2
	endif
	return strWithNums
End

// NOTE: it is presumed that the notebook's text content is EXACTLY functionText
Static Function/S RewriteOneControlsProcedureText(nb, win, controlName, rewriteDisable, rewriteUserData, functionText, isEntireFunction, foundControl, changedControl)	// return truth the control was found
	String nb, win, controlName, functionText
	Variable rewriteDisable, rewriteUserData		// optional rewriting. (We always rewrite pos, size, and title.)
	Variable isEntireFunction
	Variable &foundControl						// set to true if the named control was found
	Variable &changedControl					// set to true if anything about the control was changed in the text

	Variable rewriteTitle=1
	
	foundControl= 0
	changedControl= 0
	ControlInfo/W=$win $controlName
	if( V_Flag == 0 )
		return functionText
	endif
	
	String recreation= S_recreation		// \r-separated list of commands.
	String command= StringFromList(0,recreation," ")[1,inf]				// "Button", etc.
	
	String commandRegExpr="(?i)^[[:blank:]]*"+command+"[[:blank:]]+"+controlName+"[,[:blank:]]{1}(.*)"	// <white space>Button<white space>button0<white space or ,>

	Variable lineWhereControlWasFirstFound= -1
	Variable lineWhereControlWasLastFound= -1
	Variable lineWhereUserDataWasFirstFound= -1	// the userdata[(name)] = A"xxxx" was found. Note that there are multiple kinds of user data: unnamed and variously named.

	//
	// We presume that control names are unique in the function.
	// Note: we COULD detect the window that is in effect (if isEntireFunction) through careful parsing.
	//

	String posRegExpr="(?i)(.*[[:blank:],]+)(pos={[^}]+})(.*)"
	String withThisPos= GetRecreationTextByRegExp3(recreation, posRegExpr)	// can be ""
	String orWithThisPos = SimplifyFloatToInt("pos",withThisPos) // convert pos={6.00,10.00} to pos={6,10}

	String sizeRegExpr="(?i)(.*[[:blank:],]+)(size={[^}]+})(.*)"
	String withThisSize= GetRecreationTextByRegExp3(recreation, sizeRegExpr)	// can be ""
	String orWithThisSize = SimplifyFloatToInt("size",withThisSize) // convert size={75.00,15.00} to size={75,15}
	
	// Googling "regular expression match escaped quoted string" gave:
	// If we wanted to deal with, say, only double-quoted strings, we could get by with "([^\\"]|\\.)*"
	//
	//	String titleRegExpr="(?i)(.*[[:blank:],]+)(title=\"([^\\\\\"]|\\\\.)*\")(.*)"
	//
	// HOWEVER: We replace ONLY literal quoted strings in the code.
	// Code  like "title=str" or title="abc"+stuff are skipped.
	// require the quoted text to end with \"$ or ,
	String titleRegExpr="(?i)(.*[[:blank:],]+)(title=\"([^\\\\\"]|\\\\.)*\")((,.*)|($))"
	String withThisTitle=""
	if( rewriteTitle )
		withThisTitle= GetRecreationTextByRegExp3(recreation, titleRegExpr)		// can be ""
	endif
	
	String disableRegExpr="(?i)(.*[[:blank:],]+)(disable=[ [:digit:]]+)(.*)"
	String withThisDisable=""
	if( rewriteDisable )
		withThisDisable= GetRecreationTextByRegExp3(recreation, disableRegExpr)	// can be ""
	endif
	
	String userdatasInFunctionText=""
	String	wmUserDatas= "WaveSelectorInfo;HierarchicalListInfo;"	// list wave selector
			wmUserDatas += "popupWSInfo;popupWSGString;popupWSLastSelection;PopupWS_FullPath;PopupWS_MatchStr;PopupWS_ListOptions;"		// popup wave selector
			wmUserDatas += "PopupWS_SetVarList;PopupWS_ButtonName;PopupWS_FrameName;PopupWS_SelectableStrings;popupWSHostButton;"	// popup wave selector
			wmUserDatas += "popupWSrow;popupWScol;popupWSListBoxProc;WaveSelectorSortInfo;PopupWS_filterProc;"								// popup wave selector
	
	String stuffBefore, stuffMatched, stuffAfter, replaceThis
	
	String changedText=""	// Rewrite code line-by-line
	Variable line, lines= ItemsInList(functionText,"\r")
	for(line=0; line<lines; line+= 1 )
		String code= StringFromList(line,functionText,"\r")

		SplitString/E=commandRegExpr code, stuffAfter
		if( V_flag != 1 )
			changedText += code+"\r"
			continue
		endif
		
		// this is a command for the named control
		foundControl= 1
		if( lineWhereControlWasFirstFound < 0 )
			lineWhereControlWasFirstFound= line
		endif
		lineWhereControlWasLastFound= line
		
		// pos
		SplitString /E=posRegExpr code, stuffBefore, replaceThis, stuffAfter
		if( V_flag == 3 )
			if( CmpStr(replaceThis,withThisPos) != 0 && CmpStr(replaceThis,orWithThisPos) != 0 ) // doesn't match float or int position
				// code= stuffBefore + withThisPos + stuffAfter
				code= RewriteOneLine(nb, line, stuffBefore, replaceThis, orWithThisPos, stuffAfter)
				changedControl= 1
			endif
			withThisPos= ""	// don't need to add this
		endif

		// size
		SplitString /E=sizeRegExpr code, stuffBefore, replaceThis, stuffAfter
		if( V_flag == 3 )
			if(  CmpStr(replaceThis,withThisSize) != 0 && CmpStr(replaceThis,orWithThisSize) != 0 ) // doesn't match float or int size
				// code= stuffBefore + withThisSize + stuffAfter
				code= RewriteOneLine(nb, line, stuffBefore, replaceThis, orWithThisSize, stuffAfter)
				changedControl= 1
			endif
			withThisSize= ""	// don't need to add this
		endif

		// title
		if( rewriteTitle )
			String str4, str5, str6	
			// String titleRegExpr="(?i)(.*[[:blank:],]+)(title=\"([^\\\\\"]|\\\\.)*\")((,.*)|($))"
			// Some people, when confronted with a problem, think: 
			// 		"I know, I'll use regular expressions."
			// Now they have two problems.
			//		--- Jamie Zawinski
			SplitString /E=titleRegExpr code, stuffBefore, replaceThis, stuffAfter, str4, str5, str6
			if( V_flag >= 2 )
				if( CmpStr(replaceThis,withThisTitle) != 0 )
					// code= stuffBefore + withThisTitle + stuffAfter
					// JP100331: the stuffAfter matching is weird with titleRegExpr
					Variable len=strlen(stuffBefore)+strlen(replaceThis)
					stuffAfter= code[len,strlen(code)-1]	
					code= RewriteOneLine(nb, line, stuffBefore, replaceThis, withThisTitle, stuffAfter)
					changedControl= 1
				endif
				withThisTitle= "" // don't need to add this
			endif
		endif	

		// disable
		if( rewriteDisable )
			SplitString /E=disableRegExpr code, stuffBefore, replaceThis, stuffAfter
			if( V_flag == 3 )
				if( CmpStr(replaceThis,withThisDisable) != 0 )
					// code= stuffBefore + withThisDisable + stuffAfter
					code= RewriteOneLine(nb, line, stuffBefore, replaceThis, withThisDisable, stuffAfter)
					changedControl= 1
				endif
				withThisDisable= ""	// don't need to add this
			endif
		endif
		
		// userdata
		if( rewriteUserData )
			// just collect the user data names that are present in the function text
			String userDataList= UserdataNameList(code)	// (ignores += userdata commands)
			Variable i, n= ItemsInList(userDataList)
			for(i=0; i<n; i+=1)
				String userdataName= StringFromList(i,userDataList)
				if( -1 == WhichListItem(userdataName,userdatasInFunctionText) )
					userdatasInFunctionText += userdataName+";"	// could also record the line number at the same time.
				endif
			endfor
		endif

		// done with this line
		changedText += code+"\r"
	endfor
	
	// now we see if optional keywords we need have to be added, namely disable and title
	if( foundControl )
		// append in the order they're normally recreated (usually on the first line, so we append them there).
		if( strlen(withThisPos) )
			changedText = AppendToCodeLine(nb, lineWhereControlWasFirstFound, changedText,  ","+withThisPos)
			changedControl= 1
		endif
		if( strlen(withThisSize) )
			changedText = AppendToCodeLine(nb, lineWhereControlWasFirstFound, changedText, ","+withThisSize)
			changedControl= 1
		endif
		if( rewriteDisable && strlen(withThisDisable) )
			// don't add gratuitous disable=0 commands
			Variable disable
			sscanf withThisDisable, "disable=%d", disable
			if( disable != 0 )
				changedText = AppendToCodeLine(nb, lineWhereControlWasFirstFound, changedText, ","+withThisDisable)
				changedControl= 1
			endif
		endif
		if( rewriteTitle && strlen(withThisTitle) )
			changedText = AppendToCodeLine(nb, lineWhereControlWasFirstFound, changedText, ","+withThisTitle)
			changedControl= 1
		endif
		
		// user data
		if( rewriteUserData )
			// userDatas are complicated by the fact that multiple user datas may be on the same line,
			// and they can be binary or text, name or unnamed:
			//
			//	CheckBox radioSelection,pos={33,125},size={145,16},proc=RewriteControlPositions#RewriteRadioCheckProc,title="Rewrite Selected Text"
			//	CheckBox radioSelection,userdata(ResizeControlsInfo)= A"!!,Ch!!#@^!!#@u!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
			//	CheckBox radioSelection,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
			//	CheckBox radioSelection,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
			//	CheckBox radioSelection,userdata(Jim)=  "this is so cool"
			//	CheckBox radioSelection,userdata=  "unnamed data",value= 1,mode=1
			//
			//	Question: should we DELETE userdata that is no longer in the control.
			//	Question: should we ADD new userdata? (it might be stuff normally added later by function calls, as per the Resize Controls panel).
			//
			// plus there's all the setWindow userData! (but that's not the scope of a routine that edits on behalf of a control's recreation macro.

			// For now the method is to delete userdatas from the text that aren't present in the control,
			// update those that are, and then create new lines for new userdatas found in the control.
			// It is simpler to just delete all of the ones in the functionText and add the ones in the control.
			// Deleting existing userdatas may involve deleting only part of the line, or the entire line.
			String userdatasInControl= SortList(ControlUserdataNameList(win, controlName))
						
			userdatasInControl= RemoveFromList(wmUserDatas, userdatasInControl)

			n= ItemsInList(userdatasInFunctionText)
			for(i=0; i<n; i+=1)
				userdataName= StringFromList(i,userdatasInFunctionText)
				Variable deleteThis= DifferentUserDatas(changedText, lineWhereControlWasFirstFound, lineWhereControlWasLastFound, win, command, controlName, userdataName)
				if( deleteThis )
					Variable linesDeleted
					changedText = DeleteUserDataFromText(nb, changedText, lineWhereControlWasFirstFound, lineWhereControlWasLastFound, command, controlName, userdataName, linesDeleted)
					lineWhereControlWasLastFound -= linesDeleted
					changedControl= 1
				else
					// the user data is unchanged, so we don't need to add this user data from the control
					userdatasInControl = RemoveFromList(userdataName, userdatasInControl)
				endif
			endfor		
			n= ItemsInList(userdatasInControl)
			for(i=0; i<n; i+=1)
				userdataName= StringFromList(i,userdatasInControl)

				Variable linesInserted
				changedText = InsertUserDataInText(win, nb, changedText, lineWhereControlWasLastFound+1, command, controlName, userdataName, linesInserted)
				lineWhereControlWasLastFound += linesInserted
				changedControl= 1
			endfor		
		endif
	endif
	
	return changedText
End


// Returns list of user data names found in the recreation text.
// The special "name" of "_unnamed_" is used to designate that an unnamed userdata was found.
//
// NOTE: no checking is done to ensure this is a control command line
//
Static Function/S UserdataNameList(recreationText)
	String recreationText	// \r-separated list, as per ControlInfo's S_recreation
	
	String list=""
	
	String unNamedRegExpr="((?i),[[:blank:]]*userdata[[:blank:]]*=[[:blank:]]*)"
	String namedRegExpr="(.*)((?i),[[:blank:]]*userdata\\(([^)]+)\\)[[:blank:]]*=[[:blank:]]*)"

	String quotedStringRegExpr="^(\"([^\\\\\"]|\\\\.)*\")"
	String binaryStringRegExpr="^(A\"([^\\\\\"]|\\\\.)*\")"
	
	Variable i, n= ItemsInList(recreationText,"\r")
	for(i=0; i<n; i+= 1 )
		String recreation= StringFromList(i,recreationText,"\r")	// "Button button0 pos={left,top}, size={width,height}"
		String stuffBefore, matched, stuffAfter


		// unnamed (at most one)
		SplitString /E=unNamedRegExpr recreation, matched
		if( V_Flag == 1 )
			list = AddListItem("_unnamed_",RemoveFromList("_unnamed_",list))
		endif

		// named, perhaps several on one line
		// (name can be possibly quoted name)
		String name, subpattern
		do
			SplitString /E=namedRegExpr recreation, stuffBefore, matched, name
			if( V_Flag == 3 )
				list = AddListItem(name,RemoveFromList(name,list))
				// skip past the matched stuff (up to the = and trailing blanks)
				Variable len= strlen(stuffBefore+matched)
				recreation= recreation[len,inf]
				// skip the binary or text string
				SplitString /E=binaryStringRegExpr recreation, matched, subpattern, stuffAfter
				if( !V_Flag )
					SplitString /E=quotedStringRegExpr recreation, matched, subpattern, stuffAfter
				endif
				if( V_flag >= 2 )
					recreation= stuffAfter
				endif
			else
				break
			endif
		while(strlen(recreation))
	endfor
	
	return list
End


Static Function/S ControlUserdataNameList(win, controlName)
	String win, controlName

	String list=""
	
	ControlInfo/W=$win $controlName
	if( V_Flag == 0 )
		return ""
	endif
	return UserdataNameList(S_recreation)
End


// Returns "" if no nth piece, else it returns ",userdata(name) = <piece>", etc, suitable for inserting into function text.
// Works only for control recreation
Static Function/S GetNthUserDataPieceFromText(n, recreationText, firstLine, lastLine, command, controlName, userdataName)
	Variable n	// 0-based
	Variable firstLine, lastLine	// 0-based
	String recreationText, command, controlName
	String userdataName	// pass "" or "_unnamed_" for unnamed data. if a liberal name, it must already be quoted: 'a liberal name'

	String piece= ""

	String sep
	if( n == 0 )
		sep= "[[:blank:]]*="
	else
		sep= "[[:blank:]]*\\+="
	endif

	String commandRegExpr="(?i)^([[:blank:]]*"+command+"[[:blank:]]+"+controlName+")[,[:blank:]]{1}(.*)"	// <white space>Button<white space>button0<white space or ,>
	
	String regExpr
	if( strlen(userdataName) == 0 || (CmpStr(userdataName,"_unnamed_") == 0) )
		regExpr= "((?i),[[:blank:]]*userdata"+sep+"[[:blank:]]*)"
	else
		regExpr= "((?i),[[:blank:]]*userdata\("+userdataName+"\)"+sep+"[[:blank:]]*)"
	endif

	Variable i, numItems= ItemsInList(recreationText,"\r")
	Variable numPlusEquals= 0	// when looking for piece = 3, it's the second one with +=
	for(i=firstLine; (i<numItems) && (i<= lastLine); i+= 1 )
		String recreation= StringFromList(i,recreationText,"\r")	// "Button button0 pos={left,top}, size={width,height}"
		String subpattern, matchedKey

		String commandAndName	// <white space>Button<white space>button0
		String stuffAfter			// following <white space or ,> and rest of line
		SplitString/E=commandRegExpr recreation, commandAndName, stuffAfter
		if( V_flag != 2 )
			continue
		endif
		
		// Found a line starting with some command followed by the control name

		// Each line will contain a userdata for the same name only once, either = or +=, but not both,
		// so we need look for the specific user only once per line.
		SplitString /E=regExpr recreation, matchedKey
		if( V_Flag == 1 )
			if( n != 0 )
				numPlusEquals += 1	// 1 for the first "+=" (n==1),
				if( numPlusEquals != n )
					continue	// this isn't the right piece, try the next line
				endif
			endif
			// If here, we've found the right piece, now get it's recreation value.
			// Skip past the matched stuff (up to the = and trailing blanks)
			Variable offset= strsearch(recreation,matchedKey,0)
			Variable len= offset+strlen(matchedKey)
			recreation= recreation[len,inf]
			// get the binary or text string
			String matchedValue
			String binaryStringRegExpr="^(A\"([^\\\\\"]|\\\\.)*\")"
			SplitString /E=binaryStringRegExpr recreation, matchedValue, subpattern, stuffAfter
			if( !V_Flag )
				String quotedStringRegExpr="^(\"([^\\\\\"]|\\\\.)*\")"
				SplitString /E=quotedStringRegExpr recreation, matchedValue, subpattern, stuffAfter
			endif
			if( V_flag >= 2 )
				piece=matchedKey+matchedValue
			endif
			break
		endif
	endfor

	return piece
End

// returns the concatenation of all the user data (for comparison)
Static Function/S GetAllUserDataFromText(recreationText, firstLine, lastLine, command, controlName, userdataName)
	Variable firstLine, lastLine	// 0-based
	String recreationText, command, controlName
	String userdataName	// pass "" or "_unnamed_" for unnamed data. if a liberal name, it must already be quoted: 'a liberal name'

	Variable n=0
	String allUserdata=""
	
	do
		String piece= GetNthUserDataPieceFromText(n, recreationText, firstLine, lastLine, command, controlName, userdataName)
		if( strlen(piece) == 0 )
			break
		endif
		allUserdata += piece	
		n += 1
	while(1)
	
	return allUserdata
End


// returns "" if no nth piece, else it returns ",userdata(name) = <piece>", etc, suitable for inserting into function text.
Static Function/S GetControlNthUserDataPiece(n, win, controlName, userdataName)
	Variable n	// 0-based
	String win
	String controlName
	String userdataName	// pass "" or "_unnamed_" for unnamed data. if a liberal name, it must already be quoted: 'a liberal name'

	ControlInfo/W=$win $controlName
	if( V_Flag == 0 )
		return ""
	endif
	String command= StringFromList(0,S_recreation," ")[1,inf]
	Variable numLines= ItemsInList(S_recreation,"\r")

	String piece= GetNthUserDataPieceFromText(n, S_recreation, 0, numLines-1, command, controlName, userdataName)

	return piece
End


// returns the concatenation of all the user data (for comparison)
Static Function/S GetAllUserDataFromControl(win, controlName, userdataName)
	String win, controlName
	String userdataName	// pass "" or "_unnamed_" for unnamed data. if a liberal name, it must already be quoted: 'a liberal name'

	ControlInfo/W=$win $controlName
	if( V_Flag == 0 )
		return ""
	endif
	String command= StringFromList(0,S_recreation," ")[1,inf]
	Variable numLines= ItemsInList(S_recreation,"\r")
	String allUserdata=GetAllUserDataFromText(S_recreation, 0, numLines-1, command, controlName, userdataName)

	return allUserdata
End

Static Function/S InsertUserDataInText(win, nb, functionText, insertAtThisLine, command, controlName, userdataName, linesInserted)
	String win, nb
	String functionText	// \r-separated list, as per ControlInfo's S_recreation
	Variable insertAtThisLine	// 0-based
	String command	// "Button", "Checkbox", etc
	String controlName, userdataName
	Variable &linesInserted
	
	// insert userdata(userdataName)= and += commands as needed
	linesInserted= 0

	String changedText= functionText


	Variable n=0
	String indent="unknown"
	do
		String piece= GetControlNthUserDataPiece(n, win, controlName, userdataName) // returns "" if no nth piece, else it returns ",userdata(name) = <piece>", etc, suitable for inserting into function text.
		if( strlen(piece) == 0 )
			break
		endif
		
		String code
		if( CmpStr(indent,"unknown") == 0 )
			code= StringFromList(insertAtThisLine-1, functionText, "\r")
			SplitString/E="^([[:blank:]]*)(.*)" code, indent
		endif
		
		sprintf code, "%s%s %s%s", indent, command, controlName, piece
		changedText= InsertLineAtLine(nb, insertAtThisLine, changedText, code, 1)
		insertAtThisLine += 1
		linesInserted += 1
		n += 1
	while(1)
	return changedText
End

// returns the truth that the functionText and the control have different values for the given userdataName.
Static Function DifferentUserDatas(functionText, firstLine, lastLine, win, command, controlName, userdataName)
	String functionText	// \r-separated list, as per ControlInfo's S_recreation
	Variable firstLine, lastLine	// 0-based
	String win
	String command	// "Button", "Checkbox", etc
	String controlName, userdataName

	String textUserDatas = GetAllUserDataFromText(functionText, firstLine, lastLine, command, controlName, userdataName)
	textUserDatas= ReplaceString(" ", textUserDatas, "")
	textUserDatas= ReplaceString("\t", textUserDatas, "")
	
	String controlUserDatas =  GetAllUserDataFromControl(win, controlName, userdataName)
	controlUserDatas= ReplaceString(" ", controlUserDatas, "")
	controlUserDatas= ReplaceString("\t", controlUserDatas, "")
	
	return CmpStr(textUserDatas,controlUserDatas) != 0	// 1 if different, 0 if same
End

Static Function/S DeleteUserDataFromText(nb, functionText, firstLine, lastLine, command, controlName, userdataName, linesDeleted)
	String nb
	String functionText	// \r-separated list, as per ControlInfo's S_recreation
	Variable firstLine, lastLine	// 0-based
	String command	// "Button", "Checkbox", etc
	String controlName, userdataName
	Variable &linesDeleted
	
	// delete userdata(userdataName)= and += commands, examine the remainder and discard the entire line if it contains only <command> <controlName> [win=<winName>]
	linesDeleted= 0

	String commandRegExpr="(?i)^([[:blank:]]*"+command+"[[:blank:]]+"+controlName+")[,[:blank:]]{1}(.*)"	// <white space>Button<white space>button0<white space or ,>
	
	String regExpr
	if( strlen(userdataName) == 0 || (CmpStr(userdataName,"_unnamed_") == 0) )
		regExpr= "((?i),[[:blank:]]*userdata[[:blank:]]*([\\+]{0,1}=)[[:blank:]]*)"
	else
		regExpr= "((?i),[[:blank:]]*userdata\("+userdataName+"\)[[:blank:]]*([\\+]{0,1}=)[[:blank:]]*)"
	endif

	String changedText=""	// Rewrite code line-by-line
	Variable functionLine, functionLines= ItemsInList(functionText,"\r")
	for(functionLine=0; functionLine<functionLines; functionLine+= 1 )
		String code= StringFromList(functionLine,functionText,"\r")

		if( (functionLine < firstLine) || (functionLine > lastLine) )
			changedText += code+"\r"
			continue
		endif
		
		String commandAndName	// <white space>Button<white space>button0
		String stuffAfter			// following <white space or ,> and rest of line
		SplitString/E=commandRegExpr code, commandAndName, stuffAfter
		if( V_flag != 2 )
			changedText += code+"\r"
			continue
		endif

		Variable notebookLine= functionLine- linesDeleted
				
		String matchedKeyword, operator
		SplitString /E=regExpr code,matchedKeyword,operator
		if( V_Flag == 2 )
			// get it's recreation value.
			// Skip past the matched stuff (up to the = and trailing blanks)
			Variable offset= strsearch(code,matchedKeyword,0)
			Variable len= offset+strlen(matchedKeyword)
			String remainderOfLine= code[len,inf]
			// get the binary or text string
			String matchedValue,subpattern
			String binaryStringRegExpr="^(A\"([^\\\\\"]|\\\\.)*\")(.*)"
			stuffAfter=""
			SplitString /E=binaryStringRegExpr remainderOfLine, matchedValue, subpattern, stuffAfter
			if( !V_Flag )
				String quotedStringRegExpr="^(\"([^\\\\\"]|\\\\.)*\")(.*)"
				SplitString /E=quotedStringRegExpr remainderOfLine, matchedValue, subpattern, stuffAfter
			endif
			if( V_flag >= 2 )
				// delete the user data code 
				String stuffBefore= code[0,offset-1]
				String replaceThis= matchedKeyword+matchedValue
				code= RewriteOneLine(nb, notebookLine, stuffBefore, replaceThis, "", stuffAfter)
				// and see if there's interesting anything left
				if( CmpStr(code, commandAndName) == 0 )
					// Delete the entire line from the notebook
					DeleteOneNotebookLine(nb, notebookLine)
					linesDeleted += 1
					continue	// DON'T append code to functionText
				endif
			endif
		endif
		changedText += code+"\r"
	endfor
	return changedText
End

Function ShowRewriteControlsPanel([selectThisPanel])
	String selectThisPanel	// optional
	
	if( ParamIsDefault(selectThisPanel) || (strlen(selectThisPanel) &&( WinType(selectThisPanel) == 0)) )
		selectThisPanel=""
	endif
	
	DoWindow/F $ksPanelName
	Variable panelExists= V_Flag
	if( !panelExists )
		if( ParamIsDefault(selectThisPanel) )
			selectThisPanel=WinName(0,64)	// do this here so that if the panel already existed, just showing it again doesn't change the panel.
		endif 
		NewPanel/K=1/W=(468,51,1030,535) as "Rewrite Control Positions"
		DoWindow/C $ksPanelName
		DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
		DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}

		PopupMenu panelPop,pos={31,16},size={260,20},proc=RewriteControlPositions#PanelPopMenuProc,title="Get Controls from:"
		String cmd= GetIndependentModuleName()+"#RewriteControlPositions#WindowsPopMenu()"
		PopupMenu panelPop,value= #cmd
		PopupMenu panelPop,userdata(ResizeControlsInfo)= A"!!,C\\!!#<8!!#AH!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		PopupMenu panelPop,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		PopupMenu panelPop,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		CheckBox subwindowsCheck,pos={327,16},size={217,16},proc=RewriteControlPositions#SubwindowsCheckProc,title="Include Controls from Subwindows"
		CheckBox subwindowsCheck,userdata(ResizeControlsInfo)= A"!!,H^J,hlc!!#Ah!!#<8z!!#o2B4uAe!(U'Ezzzzzzzzzzzzz!!#o2B4uAezz"
		CheckBox subwindowsCheck,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Duafnzzzzzzzzzzz"
		CheckBox subwindowsCheck,userdata(ResizeControlsInfo) += A"zzz!!#u:Duafnzzzzzzzzzzzzzz!!!"
		CheckBox subwindowsCheck,value= 1

		TitleBox listOfControlsInPanel,pos={57,43},size={503,13},title="Controls: panelPop,subwindowsCheck,listOfControlsInPanel,rewriteGroup,procWinPop,radioPopup,proce..."
		TitleBox listOfControlsInPanel,fSize=10,frame=0,fStyle=1,fColor=(65535,0,0)
		TitleBox listOfControlsInPanel,userdata(ResizeControlsInfo)= A"!!,Ds!!#>:!!#A.!!#;]z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		TitleBox listOfControlsInPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox listOfControlsInPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		GroupBox rewriteGroup,pos={19,67},size={525,353},title="Rewrite Procedure in:"
		GroupBox rewriteGroup,userdata(ResizeControlsInfo)= A"!!,BQ!!#??!!#Ch5QF0UJ,fQL!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		GroupBox rewriteGroup,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		GroupBox rewriteGroup,userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct<C]S6zzzzzzzzzzzzz!!!"

		PopupMenu procWinPop,pos={170,68},size={227,20},proc=RewriteControlPositions#ProcwinPopMenuProc
		cmd= GetIndependentModuleName()+"#RewriteControlPositions#ProcedureWindowsPopMenu()"
		PopupMenu procWinPop,value= #cmd
		PopupMenu procWinPop,userdata(ResizeControlsInfo)= A"!!,G:!!#?A!!#Ar!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		PopupMenu procWinPop,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		PopupMenu procWinPop,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		CheckBox radioPopup,pos={33,96},size={152,16},proc=RewriteControlPositions#RewriteRadioCheckProc,title="Rewrite this Procedure:"
		CheckBox radioPopup,userdata(ResizeControlsInfo)= A"!!,Ch!!#@$!!#A'!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		CheckBox radioPopup,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		CheckBox radioPopup,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		CheckBox radioPopup,value= 1,mode=1

		PopupMenu procedurePop,pos={195,94},size={180,20},proc=RewriteControlPositions#ProcedurePopMenuProc
//		PopupMenu procedurePop,value= #"FunctionList(\"*\",\";\",\"KIND:18\")+MacroList(\"**\",\";\",\"\")"
		cmd= GetIndependentModuleName()+"#RewriteControlPositions#ProceduresList()"
		PopupMenu procedurePop,value= #cmd
		PopupMenu procedurePop,userdata(ResizeControlsInfo)= A"!!,GS!!#?u!!#AC!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		PopupMenu procedurePop,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		PopupMenu procedurePop,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		CheckBox radioSelection,pos={33,125},size={145,16},proc=RewriteControlPositions#RewriteRadioCheckProc,title="Rewrite Selected Text"
		CheckBox radioSelection,userdata(ResizeControlsInfo)= A"!!,Ch!!#@^!!#@u!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		CheckBox radioSelection,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		CheckBox radioSelection,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		CheckBox radioSelection,value= 0,mode=1
		// test user data rewriting
		CheckBox radioSelection,userdata=  "unnamed data"
		CheckBox radioSelection,userdata('1 liberal name')=  "liberal text that exceeds the length of the preferred command length should be split among multiple "
		CheckBox radioSelection,userdata('1 liberal name') +=  "lines of text if it is really long and not too short such as this line of text lamenting the length of lines, generally."
		CheckBox radioSelection,userdata(Text1)=  "some example text"
		CheckBox radioSelection,userdata(Text2)=  "string with \"one quote"

		TitleBox selectionWarning,pos={193,126},size={249,13}
		TitleBox selectionWarning,userdata(ResizeControlsInfo)= A"!!,GQ!!#@`!!#B3!!#;]z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox selectionWarning,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Duafnzzzzzzzzzzz"
		TitleBox selectionWarning,userdata(ResizeControlsInfo) += A"zzz!!#u:Duafnzzzzzzzzzzzzzz!!!"
		TitleBox selectionWarning,fSize=10,frame=0,fStyle=1,fColor=(65535,0,0)

		CheckBox rewritePosSize,pos={36,151},size={292,16},disable=2,title="Rewrite \"pos={}\", \"size={}\", and title keywords"
		CheckBox rewritePosSize,value= 1
		CheckBox rewritePosSize,userdata(ResizeControlsInfo)= A"!!,Ct!!#A&!!#BL!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		CheckBox rewritePosSize,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		CheckBox rewritePosSize,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		CheckBox rewriteDisableCheck,pos={36,171},size={176,16},title="Rewrite \"disable\" keywords"
		CheckBox rewriteDisableCheck,value= 1
		CheckBox rewriteDisableCheck,userdata(ResizeControlsInfo)= A"!!,Ct!!#A:!!#A?!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		CheckBox rewriteDisableCheck,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		CheckBox rewriteDisableCheck,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		CheckBox rewriteUserDataCheck,pos={36,191},size={187,16},title="Rewrite \"userdata\" keywords"
		CheckBox rewriteUserDataCheck,value= 1
		CheckBox rewriteUserDataCheck,userdata(ResizeControlsInfo)= A"!!,Ct!!#AN!!#AJ!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		CheckBox rewriteUserDataCheck,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		CheckBox rewriteUserDataCheck,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		Button goto,pos={37,461},size={170,20},proc=RewriteControlPositions#GoToButtonProc,title="Go To Original Procedure"
		Button goto,userdata(ResizeControlsInfo)= A"!!,D#!!#CKJ,hqd!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		Button goto,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		Button goto,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		Button doit,pos={47,434},size={150,20},proc=RewriteControlPositions#RewriteButtonProc,title="Rewrite Procedure"
		Button doit,userdata(ResizeControlsInfo)= A"!!,DK!!#C>!!#A%!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		Button doit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		Button doit,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		Button cancel,pos={432,458},size={80,20},proc=RewriteControlPositions#CancelButtonProc,title="Cancel"
		Button cancel,userdata(ResizeControlsInfo)= A"!!,I>!!#CJ!!#?Y!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		Button cancel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		Button cancel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		Button help,pos={280,458},size={80,20},proc=RewriteControlPositions#HelpButtonProc,title="Help"
		Button help,userdata(ResizeControlsInfo)= A"!!,HG!!#CJ!!#?Y!!#<Xz!!#`-A7TLf!(U'Ezzzzzzzzzzzzz!!#`-A7TLfzz"
		Button help,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		Button help,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		DefineGuide UGH0={FB,-76},UGV0={FL,35},UGV1={FR,-37},UGH1={FT,214}

		SetWindow kwTopWin,hook(ResizeControls)=ResizeControls#ResizeControlsHook
		SetWindow kwTopWin,hook(rewriteControls)=RewriteControlPositions#WindowHook
		SetWindow kwTopWin,userdata(ResizeControlsInfo)= A"!!*'\"z!!#CqJ,ht-zzzzzzzzzzzzzzzzzzzzz"
		SetWindow kwTopWin,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
		SetWindow kwTopWin,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
		SetWindow kwTopWin,userdata(ResizeControlsGuides)=  "UGH0;UGV0;UGV1;UGH1;"
		SetWindow kwTopWin,userdata(ResizeControlsInfoUGH0)= A":-hTC3`S[@0KW?-:-)9aGB.D>AOCBRFE2;9F&6:_ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr-0K;-a<CoSI0fhcj4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\<9K3r"
		SetWindow kwTopWin,userdata(ResizeControlsInfoUGV0)= A":-hTC3`S[N0KW?-:-)9aGB.D>AOCBRFE2;9F&6:_ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0KW*,;b9q[:JNr,2*4<.8OQ!%3^ue)7o`,K75?nc;FO8U:K'ha8P`)B1Gq5"
		SetWindow kwTopWin,userdata(ResizeControlsInfoUGV1)= A":-hTC3`S[N0frH.:-)9aGB.D>AOCBRFE2;9F&6:_ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0KW*,;b9q[:JNr.1,V-`<CoSI0fhd%4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\<-H3r"
		SetWindow kwTopWin,userdata(ResizeControlsInfoUGH1)= A":-hTC3`S[@0frH.:-)9aGB.D>AOCBRFE2;9F&6:_ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr+0f1s^<CoSI0fhd'4%E:B6q&jl4&SL@:et\"]<(Tk\\3\\iEH3r"

		NewNotebook /F=0 /N=Code /W=(47,280,426,240)/FG=(UGV0,UGH1,UGV1,UGH0) /HOST=# 
		Notebook kwTopWin, defaultTab=20, statusWidth=0, autoSave=1
		Notebook kwTopWin font="Geneva", fSize=10, fStyle=0, textRGB=(0,0,0)
		Notebook kwTopWin, zdata= "GaqDU%ejN7!Z)%D?tAb<=R'hO`]tdL!6<Ul\\,"
		Notebook kwTopWin, zdataEnd= 1
		RenameWindow #,Code
		SetActiveSubwindow ##

		WC_WindowCoordinatesRestore(ksPanelName)
	endif

	if( strlen(selectThisPanel) == 0 && panelExists )
		// change away from a panel that no longer exists
		ControlInfo/W=$ksPanelName panelPop
		if( WinType(S_Value) == 0 )
			selectThisPanel= WinName(1,64,1)	// visible panel behind this one
		endif
	endif
	
	if( strlen(selectThisPanel) )
		String windows= WindowsPopMenu()
		Variable mode= 1+WhichListItem(selectThisPanel,windows)
		PopupMenu panelPop,win=$ksPanelName, mode=mode
		panelExists= 0	// force manual re-update of panel
	endif
	
	if( !panelExists )	
		// panel was just built, or needs a refresh that the activate was done too early to do correctly.
		// activating normally runs these, but the window hook wasn't installed when the panel was created and therefore activated
		UpdateListOfControls()
		UpdateShownProcedure()
		EnableDisableControls()
	endif
End