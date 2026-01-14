#pragma rtGlobals=1		// Use modern global access method.
#pragma version=8.03			// shipped with Igor 8.03
#pragma IgorVersion=6.1
#pragma moduleName=ResizeControlsPanel

#include <Resize Controls>
#include <SaveRestoreWindowCoords>

//	The ResizeControlsPanel procedure implements a table-like editor to
//	set the resize behavior of individual controls in a panel. When the panel
//	is resized, each edge of each control is (optionally) moved or resized
//	according to the selected mode.
//
//	NOTE:
//		Call the ShowResizeControlsPanel() function to display the editor,
//		or choose "Edit Controls Resized Positions" from Igor's Panel menu.
//
//	This version works in panels and subwindows of panels.
//	It is not expected to work with exterior subwindows.
//
//	Controls can be moved relative to the panel's or subwindows' edges,
//	or relative to user guides.
//
// NOTE: 
//		Control resizing information is stored in each control's userData($ksResizeUserDataName),
//		and the window resizing information is stored in the panel's userData($ksResizeUserDataName)
//
//	Revision History:
//		JP090429, version 6.1 (initial version)
//		JP091022, version 6.12 - bug fixes for notebook subwindow, bigger Reset buttons
//		JP100922, version 6.20 - Revised comments, defaults to top panel other than resize controls panel,
//									Remove all Resizing works better.
//		JP110429, version 6.23 - Checking the Reposition/Resize Controls checkbox automatically performs
//									Record Control Positions (which also sets the window's minimum size).
//		JP160216, version 6.38 -  added Same Width, Same Height, % Width and % Height options.
//		JP160218, version 6.381 -  added popup for all controls in column.
//		JP160411, version 7 -  revised for Igor 7 PanelResolution.
//		JP190227, version 8.03 -  revised for Igor 8 listbox events -2 and -3
//
// ++++++++ Public routines:
//
//	ShowResizeControlsPanel()
//	SetControlListModes(panelName, controls, leftMode, rightMode, topMode, bottomMode)
//	SaveControlPositions(panelName, updateModesOnly)
//
// Call other (static) routines by using ResizeControlsPanel#nameOfStaticRoutine syntax.
//
// Routines of interest
//		ResizeControlsPanel#RemoveAllResizeInfo(panelName)
//		ResizeControlsPanel#SetClearResizeControlsHook(panelName, sethook)
//

// ++++++++ Menus

Menu "Panel", hideable
	"Edit Controls Resized Positions", /Q, ShowResizeControlsPanel()
End

// ++++++++ Constants

// Listbox selWave constants
Static Constant kCellisCheckboxMask = 0x20
Static Constant kCellisCheckedMask	= 0x10
Static Constant kCellisEditableMask	= 0x02
Static Constant kCellIsSelectedMask	= 0x01

Static StrConstant ksPanelName="ResizeControlsPanel"
Static StrConstant ksResizeHookName= "ResizeControls"
Static StrConstant ksGuidesUserDataName= "ResizeControlsGuides"

Static StrConstant ksStashResizeHookUDName="ResizeControlsHookStash" // userdata

// This string is appended to each mode string in the panel to make it "obvious" the user can click there and get a popup.
Static StrConstant ksPopArrowText= "\\W623\\JR"

// +++++++ Panel Data Folder routines

Static Function/S PanelDF()
	return "root:Packages:ResizeControlsPanel"
End

Static Function/S PanelDFVar(varName)
	String varName
	
	String df= PanelDF()
	if( !DataFolderExists(df) )
		NewDataFolder/O root:Packages
		NewDataFolder/O $df
	endif
	return df+":"+PossiblyQuoteName(varName)	// "root:Packages:ResizeControlsPanel:'my variable'"
End

Static Function/S SetPanelDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S $PanelDF()	// DF is left pointing here
	return oldDF
End

// +++++++ List Waves

// We use column or layer dimension labels to access the list waves.

// EditorTextWave and EditorSelWave
//		%name, %left, %right, %top, %bottom

Static Function ResetListboxWaves()

	String oldDF=  SetPanelDF()
	
	// Listbox listWave
	// this text wave is what shows up in the listbox
	Make/O/N=(0,5)/T EditorTextWave

	// this text wave is what shows up in the listbox's title area
	Make/O/N=(0,5)/T EditorTitleWave= {{"Control"},{"Left Edge"},{"Right Edge"},{"Top Edge"},{"Bottom Edge"}}

	// selwave is multi-purpose and thus multi-dimensional
	// it has the same rows and columns as the text wave.
	//Because we're not setting cell colors, we're not allocating layers.
	Make/O/N=(0,5) EditorSelWave

	SetDimLabel 1, 0, name,		EditorTextWave, EditorSelWave	// name of control
	SetDimLabel 1, 1, left,		EditorTextWave, EditorSelWave	// button popup of left/center/right
	SetDimLabel 1, 2, right,		EditorTextWave, EditorSelWave	// button popup of left/center/right
	SetDimLabel 1, 3, top,		EditorTextWave, EditorSelWave	// button popup of top/middle/bottom
	SetDimLabel 1, 4, bottom,	EditorTextWave, EditorSelWave	// button popup of top/middle/bottom

	// selWave's layer 0 is actually where selection (and checkbox-in-cell and checked state) are stored for each row and column.
	EditorSelWave= 0

	// selWave's layers 1 and 2 contain ROW INDEXES into EditorColorWave to select the background (layer 1) or text (layer 2) colors for each rolw and column
	// we're not using colors here.

	SetDataFolder oldDF
End

static Function GetPanelControlPositions(panelName)
	String panelName	// can be subwindow path, and thus it can be a non-panel window (a notebook or graph)

	Variable type= WinType(panelName)
	if( (type != 1) && (type != 7) )	// only panels and graphs
		Beep
		return 0
	endif
	ResetListboxWaves()
	
	String controls= SortList(ControlNameList(panelName))
	Variable i, n=ItemsInList(controls)

	WAVE/T EditorTextWave= $PanelDFVar("EditorTextWave")
	WAVE EditorSelWave= $PanelDFVar("EditorSelWave")

	InsertPoints/M=0 0, n, EditorTextWave ,EditorSelWave
	STRUCT WMResizeInfo resizeInfo

	for( i=0; i<n; i+=1 )
		String controlName= StringFromList(i,controls)
		
		EditorTextWave[i][%name]= controlName
		SetDimLabel 0, i, $controlName, EditorTextWave, EditorSelWave

		ResizeControls#GetControlResizeInfo(panelName, controlName, resizeInfo)
		EditorTextWave[i][%left]= resizeInfo.leftMode+ksPopArrowText	// ksPopArrowText indicates a popup menu is available
		EditorTextWave[i][%right]= resizeInfo.rightMode+ksPopArrowText
		EditorTextWave[i][%top]= resizeInfo.topMode+ksPopArrowText
		EditorTextWave[i][%bottom]= resizeInfo.bottomMode+ksPopArrowText
	endfor
	
	// opposite of SetWindow $panelName userdata($ksResizeUserDataName)=userData
	panelName= HostWindowFromChild(panelName)
	
	String userdata = GetUserData(panelName, "", ksResizeUserDataName)
	StructGet/S resizeInfo, userdata

	Checkbox keepSameWidth, win= $ksPanelName, value= resizeInfo.fixedWidth
	Checkbox keepSameHeight, win= $ksPanelName, value= resizeInfo.fixedHeight
	
	GetWindow $panelName hook($ksResizeHookName)
	Checkbox enableResizeHook, win= $ksPanelName, value= (strlen(S_Value) > 0)
End

static Function RemoveGuidesUserData(panelName)
	String panelName
		
	// we save a list of the guides so we don't lose the user data names
	String userguides= GetUserData(panelName, "", ksGuidesUserDataName)	// result of GuideNameList (panelName, "TYPE:User")
	SetWindow $panelName userdata($ksGuidesUserDataName)=""	// remove the list

	Variable i, n= ItemsInList(userguides)
	for( i=0; i<n; i+=1 )
		String guideName= StringFromList(i,userguides)
		String userDataName= ksResizeUserDataName+guideName
		SetWindow $panelName userdata($userDataName)=""	// remove the guideInfo
	endfor
End

// Opt out function.
Static Function RemoveAllResizeInfo(panelName)
	String panelName
	
	// remove panel resize info
	SetWindow $panelName userdata($ksResizeUserDataName)=""

	// remove all guide info
	RemoveGuidesUserData(panelName)
	
	// remove userData from all controls
	String controls= ControlNameList(panelName)
	Variable i, n= ItemsInList(controls)
	for( i=0; i < n; i+=1 )
		String controlName= StringFromList(i,controls)
		ModifyControl $controlName, win=$panelName, userdata($ksResizeUserDataName)=""
	endfor
	
	// turn off hook
	SetClearResizeControlsHook(panelName, 0)
End

static Function PutControlResizeInfo(panelName, controlName, resizeInfo)
 	String panelName, controlName
	STRUCT WMResizeInfo &resizeInfo
	
	String userData
	StructPut/S resizeInfo, userData
	ModifyControl $controlName, win=$panelName, userdata($ksResizeUserDataName)= userData
End

Static Function UserOkaysRecordPositionsAndSize(panelName)
	String panelName

	// TO DO: check the recorded control positions against the actual control positions,
	// the recorded panel size against the actual panel size,
	// and if either differ, ask if the user wants to record them.
	Button recordPositions, win=$ksPanelName,  fColor=(0,0,65535)
	DoUpdate/W=$ksPanelName
	Sleep/C=-1/S/Q 0.5
	Button recordPositions, win=$ksPanelName,  fColor=(0,0,0)
	DoUpdate/W=$ksPanelName
	return 1	// to see if just automatically updating them is good enough.
End

// PanelCoordEdges is a panel-coordinate replacement for GetWindow wsizeDC.
// NOTE: using GetWindow wsize or wsizeDC based on PanelResolution(win) == 72
// will not work for a subwindow, because GetWindow wsize Panel0#subwindow
// will instead actually return GetWindow wsizeDC.
// Works with Graph windows.
// Doesn't work with layouts, but those don't contain controls.

Static Function PanelCoordEdges(win, vleft, vtop, vright, vbottom)
	String win	// can be "Panel0#P1", for example
	Variable &vleft, &vtop, &vright, &vbottom	// outputs, host window's left,top is 0,0

	vleft= NumberByKey("POSITION",GuideInfo(win,"FL"))	// panel units
	vtop= NumberByKey("POSITION",GuideInfo(win,"FT"))
	vright= NumberByKey("POSITION",GuideInfo(win,"FR"))
	vbottom= NumberByKey("POSITION",GuideInfo(win,"FB"))
End

Static Function SaveControlPositions(panelName, updateModesOnly)
	String panelName
	Variable updateModesOnly
	
	STRUCT WMResizeInfo resizeInfo
	resizeInfo.version=kCurrentResizeInfoVersion
	String userData

	if( !updateModesOnly )
		// "Panel Coordinates" are used to store panel sizes to match the control coordinates.
		// In this way, one control that fills the entire panel would have the same width and height values
		// as the panel's "Panel Coordinates".
		Variable vleft, vtop, vright, vbottom	// outputs, host window's left,top is 0,0
		PanelCoordEdges(panelName, vleft, vtop, vright, vbottom)
		Variable winWidth= vright-vleft
		Variable winHeight= vbottom-vtop
	
		// save the current ("original") relative panel coordinates in the window's user data
		resizeInfo.originalLeft= vleft	// 0 for top-level window
		resizeInfo.originalTop= vtop		// 0 for top-level window
		resizeInfo.originalWidth= winWidth
		resizeInfo.originalHeight= winHeight
		
		ControlInfo/W=$ksPanelName keepSameWidth
		resizeInfo.fixedWidth= V_Value	// for panel resize hook
		ControlInfo/W=$ksPanelName keepSameHeight
		resizeInfo.fixedHeight= V_Value	// for panel resize hook
	
		// resizeInfo.modes aren't used for windows, only for controls
		
		StructPut/S resizeInfo, userData
		SetWindow $panelName userdata($ksResizeUserDataName)=userData
		
		// Update the saved user guides
		
		// we save a list of the guides so we can delete them, which we do now to the old guide user data
		RemoveGuidesUserData(panelName)
		
		String userguides= GuideNameList(panelName, "TYPE:USER")
		SetWindow $panelName userdata($ksGuidesUserDataName)=userguides

		// we save the guideInfo, too, mostly so we keep the original position.
		Variable i, n= ItemsInList(userguides)
		for( i=0; i<n; i+=1 )
			String guideName= StringFromList(i,userguides)
			String userDataName= ksResizeUserDataName+guideName
			SetWindow $panelName userdata($userDataName)=GuideInfo(panelName,guideName)
		endfor
		
	endif
	
	WAVE/T EditorTextWave= $PanelDFVar("EditorTextWave")

	String controls= ControlNameList(panelName)
	n= ItemsInList(controls)
	for( i=0; i < n; i+=1 )
		String controlName= StringFromList(i,controls)
		ResizeControls#GetControlResizeInfo(panelName, controlName, resizeInfo)	// gets control's idea of what the resize modes are
		if( !updateModesOnly )
			ControlInfo/W=$panelName $controlName
			resizeInfo.originalLeft= V_Left		// panel coordinates, same as recreation macro, same as Panel Absolute drawing
			resizeInfo.originalTop= V_Top			// ""
			resizeInfo.originalWidth= V_Width	// ""
			resizeInfo.originalHeight= V_Height	// ""
		endif
		Variable row= FindRowByName(controlName)
		if( row >= 0 )
			// update the resize modes from the list wave.
			resizeInfo.leftMode= ReplaceString(ksPopArrowText, EditorTextWave[row][%left], "")
			resizeInfo.rightMode= ReplaceString(ksPopArrowText, EditorTextWave[row][%right], "")
			resizeInfo.topMode= ReplaceString(ksPopArrowText, EditorTextWave[row][%top], "")
			resizeInfo.bottomMode= ReplaceString(ksPopArrowText, EditorTextWave[row][%bottom], "")
		endif

		// tell the control about the modes entered in the list box.
		PutControlResizeInfo(panelName, controlName, resizeInfo)
	endfor
End

// Public programmatic interface to setting control movement modes
Function SetControlListModes(panelName, controls, leftMode, rightMode, topMode, bottomMode)
	String panelName, controls	// controls is a string list
	String leftMode, rightMode, topMode, bottomMode	// pass "" to leave a mode unchanged

	WAVE/T EditorTextWave= $PanelDFVar("EditorTextWave")

	Variable i, n= ItemsInList(controls)
	for( i=0; i < n; i+=1 )
		String controlName= StringFromList(i,controls)

		Variable row= FindRowByName(controlName)
		if( row >= 0 )
			// update the resize modes from the list wave.
			if( strlen(leftMode) )
				EditorTextWave[row][%left]= leftMode+ksPopArrowText
			endif
			if( strlen(rightMode) )
				EditorTextWave[row][%right]= rightMode+ksPopArrowText
			endif
			if( strlen(topMode) )
				EditorTextWave[row][%top]= topMode+ksPopArrowText
			endif
			if( strlen(bottomMode) )
				EditorTextWave[row][%bottom]= bottomMode+ksPopArrowText
			endif
		endif
	endfor
End

// +++++++ Panel support routines

Static Function NumberOfListRows()

	Variable numRows= 0
	WAVE/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( WaveExists(EditorTextWave) )
		numRows= DimSize(EditorTextWave,0)
	endif

	return numRows
End

Static Function CloseButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	CloseResizeControlsPanel()
End

// Public
Function CloseResizeControlsPanel()

	Execute/P/Q/Z "DoWindow/K "+ksPanelName
End

Static Function HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "Resize Controls Panel"
End

static Function RewriteButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String panelName=""
	ControlInfo/W=$ksPanelName panels
	if( V_Flag  )
		panelName=S_Value
	endif
	Execute/P/Q/Z "INSERTINCLUDE <Rewrite Control Positions>";Execute/P/Q/Z "COMPILEPROCEDURES ";Execute/P/Q/Z "RCP#ShowRewriteControlsPanel(selectThisPanel=\""+panelName+"\")"
End

// output suitable for a call to PopupContextualMenu
Function/S ResizePopList(panelName,isAll, colName)
	String panelName	// "Panel0" or "Panel0#P0" or "Graph0#PTOP", etc.
	Variable isAll
	String colName
	
	String list=""
	if( isAll )
		list= "\\M0:(:All Controls;"
	endif
	strswitch(colName)
		case "left":
		case "right":
			list += ksFixedFromLeft+";"
			list += ksFixedFromMiddle+";"
			list += ksFixedFromRight+";"
			list += ksSameWidth+";"
			list += ksFixedFromPctWidth+";"
			list += UserGuides(panelName,0)	// vertical user guides
			break
		default:
			list += ksFixedFromTop+";"
			list += ksFixedFromCenter+";"
			list += ksFixedFromBottom+";"
			list += ksSameHeight+";"
			list += ksFixedFromPctHeight+";"
			list += UserGuides(panelName,1)	// horizontal user guides
	endswitch
	return list
end

Function/S UserGuides(panelName,wantHorizontal)
	String panelName
	Variable wantHorizontal
	
	String options
	sprintf options, "TYPE:User,HORIZONTAL:%d", wantHorizontal
	String guides= GuideNameList(panelName,options)
	// Prepend "Guide " to each list item
	String list=""
	Variable i, n= ItemsInList(guides)
	for(i=0; i<n; i+= 1 )
		String guide= StringFromList(i,guides)
		list += "Guide "+guide+";"
	endfor
	return list
End

static Function/S ListFromColumn(listWave, col)
	WAVE/T listWave
	Variable col

	String list=""
	Variable rows=DimSize(listWave,0)
	Variable cols=DimSize(listWave,1)
	
	if (col >= 0 && col < cols )
		Variable row
		for(row= 0; row<rows; row += 1 )
			list += listWave[row][col]+";"
		endfor
	endif
	return list
End

// Listbox proc
Static Function ListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable status= 0
	Variable row = lba.row // invalid if eventCode == -3
	Variable col = lba.col // invalid if eventCode == -3
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	
	String colDimLabel		// for both text and sel waves
	Variable rows=DimSize(listWave,0)
	Variable cols=DimSize(listWave,1)
	Variable inList= row < rows && row >=0
	Variable inTitle= row < 0
	Variable isContextual= lba.eventMod & 0x10	// bit 4
	Variable isAllRows= lba.eventMod & 0x2		// bit 1 = Shift key
	String controlName, panelName
	ControlInfo/W=$ksPanelName panels
	panelName= S_Value

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 2:	// mouse up
			break
		case 1:								// mouse down				
			// put up contextual menus
			colDimLabel= GetDimLabel(listWave, 1, col)
			if( inList && !isAllRows )
				if (col >= 1)
					// indicate the control NOW, not after the popup
					controlName= listWave[row][%name]
					IndicateControls(panelName, controlName, 1)

					DoUpdate/W=$panelName
					PopupContextualMenu ResizePopList(panelName, 0, colDimLabel)
					if( V_Flag )
						listWave[row][col]= S_selection+ksPopArrowText
						//Update modes immediately
						SaveControlPositions(panelName,1)	// modes only
					endif
					status= 1
				endif
			elseif (rows > 0 && col >= 1 && col < cols )
				// set all rows of the column to the result.
				String controls= ListFromColumn(listWave, 0)
				IndicateControls(panelName, controls, 1)
				DoUpdate/W=$panelName
				PopupContextualMenu ResizePopList(panelName, 1, colDimLabel)
				if( V_Flag )
					for(row= 0; row<rows; row += 1 )
						listWave[row][col]= S_selection+ksPopArrowText
					endfor
					//Update modes immediately
					SaveControlPositions(panelName,1)	// modes only
				endif
				status= 1
			endif
			break
		case 3: // double click
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			controlName= ""
			String moveMode=""
			colDimLabel= GetDimLabel(listWave, 1, col)
			Variable selRow= SelectedListRow(selWave, 0)
			if( selRow >= 0 )
				controlName= listWave[selRow][%name]
				moveMode= listWave[selRow][%$colDimLabel]
			endif
			IndicateControls(panelName, controlName, 1)
			IndicateOneGuide(panelName,moveMode,1)
			EnableDisableButtons()
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
	endswitch

	return status
End

Static Function/S WindowsPopMenu()

	String list= WinList("*",";","WIN:65")	// panels and graphs
	ControlInfo/W=$ksPanelName panels
	if( V_Flag > 0 )
		String currentWindow= S_Value
		if( strlen(currentWindow) && WinType(currentWindow) )	// could be "Graph0#PTOP"
			String hostWindow= StringFromList(0,currentWindow,"#")
			list = RemoveFromList(hostWindow, list)+ResizeControls#ListOfChildWindows(hostWindow)
		endif
	endif
	list= SortList(list)
	return list
End

// Public
static Function NewShowResizeControlsPanel()

	DoWindow/F $ksPanelName
	if( V_Flag == 0 )
		// create the data folders
		String oldDF= SetPanelDF()
		SetDataFolder oldDF
		
		// create the panel
		NewPanel/W=(39,52,741,398)/K=1 as "Edit Controls Resized Positions"
		DoWindow/C $ksPanelName
		DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
		DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}

		// controlsList

		ResetListboxWaves()
		WAVE/T EditorTextWave=  $PanelDFVar("EditorTextWave")
		WAVE EditorSelWave=  $PanelDFVar("EditorSelWave")
		WAVE/T EditorTitleWave=  $PanelDFVar("EditorTitleWave")

		ListBox controlsList,pos={12.00,93.00},size={501.75,213.75}, mode= 6,userColumnResize= 1
		ListBox controlsList selWave= EditorSelWave, listWave=EditorTextWave, titleWave= EditorTitleWave
		ListBox controlsList, clickEventModifiers=4	// to make popus work better.
		ListBox controlsList, proc=ResizeControlsPanel#ListBoxProc

		// CheckBoxes
		CheckBox enableResizeHook,pos={231.00,39.00},size={187.50,11.25},proc=ResizeControlsPanel#ResizeHookCheckProc,title="Reposition/Resize Controls after Panel Resize"
		CheckBox enableResizeHook,value= 1

		CheckBox keepSameWidth,pos={231.00,66.00},size={119.25,11.25},proc=ResizeControlsPanel#SameWidthCheckProc,title="Keep Constant Panel Width"
		CheckBox keepSameWidth,value= 0
		
		CheckBox keepSameHeight,pos={375.00,66.00},size={122.25,11.25},proc=ResizeControlsPanel#SameHeightCheckProc,title="Keep Constant Panel Height"
		CheckBox keepSameHeight,value= 0

		// PopupMenus
		String panels=WindowsPopMenu()	// includes this panel, so we know there's always at least 1 item in the popup
		Variable numPanels= ItemsInList(panels)
		String otherPanel = WinName(1,64,1)	// next visible panel
		Variable mode = (numPanels < 2 ) ? 1 : 1+WhichListItem(otherPanel,panels)
		String panelName= StringFromList(mode-1,panels)
		PopupMenu panels,pos={162.00,9.00},size={96.00,14.25}, proc= ResizeControlsPanel#PanelPopMenuProc
		PopupMenu panels,mode=mode,popvalue=panelName,value= #"ResizeControlsPanel#WindowsPopMenu()"

		// Buttons
		Button loadFromPanel,pos={18.00,9.00},size={90.00,18.00},proc=ResizeControlsPanel#GetPanelControlsButtonProc,title="Get Controls from:"

		Button recordPositions,pos={15.00,36.00},size={198.75,18.75},proc=ResizeControlsPanel#RecordPositionsButtonProc,title="Record Control Positions and Panel Size"

		Button restoreOriginal,pos={15.00,63.00},size={198.75,18.75},title="Reset to Recorded Positions and Panel Size"
		Button restoreOriginal proc=ResizeControlsPanel#ResetButtonProc		

		Button rewrite,pos={15.00,318.00},size={240.00,18.00},proc=ResizeControlsPanel#RewriteButtonProc,title="Rewrite Control Positions..."
		
		Button help,pos={498.00,318.00},size={78.00,18.00},proc=ResizeControlsPanel#HelpButtonProc,title="Help"
		Button close,pos={609.00,318.00},size={78.75,18.00},proc=ResizeControlsPanel#CloseButtonProc,title="Close"

		Button reset,pos={537.00,129.00},size={150.00,39.00},title="Reset\rselected control", proc=ResizeControlsPanel#ResetSelectedButtonProc

		Button resetAll,pos={537.00,183.00},size={150.00,39.00},proc=ResizeControlsPanel#ResetAllButtonProc,title="Remove\rAll Resizing"

		GetPanelControlPositions(ksPanelName)
		// set up the current panel's control movements
		SetControlListModes(ksPanelName,"rewrite;", ksFixedFromLeft, ksFixedFromLeft, ksFixedFromBottom,ksFixedFromBottom)
		SetControlListModes(ksPanelName,"help;close;", ksFixedFromRight, ksFixedFromRight, ksFixedFromBottom,ksFixedFromBottom)
		SetControlListModes(ksPanelName,"reset;resetAll;", ksFixedFromRight, ksFixedFromRight, ksFixedFromCenter,ksFixedFromCenter)
		SetControlListModes(ksPanelName,"controlsList;", ksFixedFromLeft, ksFixedFromRight, ksFixedFromTop,ksFixedFromBottom)
		SaveControlPositions(ksPanelName,0)
		SetClearResizeControlsHook(ksPanelName,1)

		WC_WindowCoordinatesRestore(ksPanelName)

		GetPanelControlPositions(panelName)	// NOT (necessarily) this editing panel, rather the one showing in the popup.
		SetWindow $ksPanelName hook(ResizeControlsPanel)= ResizeControlsPanel#ResizeControlsPanelHook
	endif
	EnableDisableButtons()
End

Function ShowResizeControlsPanel()

	DoWindow/F $ksPanelName
	if( V_Flag == 0 )
		// create the data folders
		String oldDF= SetPanelDF()
		SetDataFolder oldDF
		
		// create the panel
		NewPanel/W=(69,60,884,578)/K=1 as "Edit Controls Resized Positions"
		DoWindow/C $ksPanelName
		DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
		DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}

		// controlsList

		ResetListboxWaves()
		WAVE/T EditorTextWave=  $PanelDFVar("EditorTextWave")
		WAVE EditorSelWave=  $PanelDFVar("EditorSelWave")
		WAVE/T EditorTitleWave=  $PanelDFVar("EditorTitleWave")

		ListBox controlsList,pos={12,95},size={625,360}, mode= 6,userColumnResize= 1
		ListBox controlsList selWave= EditorSelWave, listWave=EditorTextWave, titleWave= EditorTitleWave
		ListBox controlsList, clickEventModifiers=4	// to make popus work better.
		ListBox controlsList, proc=ResizeControlsPanel#ListBoxProc
		// CheckBoxes
		CheckBox enableResizeHook,pos={307,40},size={281,16},proc=ResizeControlsPanel#ResizeHookCheckProc,title="Reposition/Resize Controls after Panel Resize"
		CheckBox enableResizeHook,value= 1

		CheckBox keepSameWidth,pos={307,67},size={176,16},proc=ResizeControlsPanel#SameWidthCheckProc,title="Keep Constant Panel Width"
		CheckBox keepSameWidth,value= 0
		
		CheckBox keepSameHeight,pos={491,67},size={179,16},proc=ResizeControlsPanel#SameHeightCheckProc,title="Keep Constant Panel Height"
		CheckBox keepSameHeight,value= 0

		// PopupMenus
		String panels=WindowsPopMenu()	// includes this panel, so we know there's always at least 1 item in the popup
		Variable numPanels= ItemsInList(panels)
		String otherPanel = WinName(1,64,1)	// next visible panel
		Variable mode = (numPanels < 2 ) ? 1 : 1+WhichListItem(otherPanel,panels)
		String panelName= StringFromList(mode-1,panels)
		PopupMenu panels,pos={163,9},size={142,20}, proc= ResizeControlsPanel#PanelPopMenuProc
		PopupMenu panels,mode=mode,popvalue=panelName,value= #"ResizeControlsPanel#WindowsPopMenu()"

		// Buttons
		Button loadFromPanel,pos={18,9},size={130,20},proc=ResizeControlsPanel#GetPanelControlsButtonProc,title="Get Controls from:"

		Button recordPositions,pos={17,38},size={260,20},proc=ResizeControlsPanel#RecordPositionsButtonProc,title="Record Control Positions and Panel Size"

		Button restoreOriginal,pos={17,65},size={260,20},title="Reset to Recorded Positions and Panel Size"
		Button restoreOriginal proc=ResizeControlsPanel#ResetButtonProc		

		Button rewrite,pos={17,479},size={240,20},proc=ResizeControlsPanel#RewriteButtonProc,title="Rewrite Control Positions..."
		
		Button help,pos={597,479},size={80,20},proc=ResizeControlsPanel#HelpButtonProc,title="Help"
		Button close,pos={713,479},size={80,20},proc=ResizeControlsPanel#CloseButtonProc,title="Close"

		Button reset,pos={653,229},size={150,40},title="Reset\rselected control", proc=ResizeControlsPanel#ResetSelectedButtonProc

		Button resetAll,pos={653,284},size={150,40},proc=ResizeControlsPanel#ResetAllButtonProc,title="Remove\rAll Resizing"

		
		GetPanelControlPositions(ksPanelName)
		// set up the current panel's control movements
		SetControlListModes(ksPanelName,"rewrite;", ksFixedFromLeft, ksFixedFromLeft, ksFixedFromBottom,ksFixedFromBottom)
		SetControlListModes(ksPanelName,"help;close;", ksFixedFromRight, ksFixedFromRight, ksFixedFromBottom,ksFixedFromBottom)
		SetControlListModes(ksPanelName,"reset;resetAll;", ksFixedFromRight, ksFixedFromRight, ksFixedFromCenter,ksFixedFromCenter)
		SetControlListModes(ksPanelName,"controlsList;", ksFixedFromLeft, ksFixedFromRight, ksFixedFromTop,ksFixedFromBottom)
		SaveControlPositions(ksPanelName,0)
		SetClearResizeControlsHook(ksPanelName,1)

		WC_WindowCoordinatesRestore(ksPanelName)

		GetPanelControlPositions(panelName)	// NOT (necessarily) this editing panel, rather the one showing in the popup.
		SetWindow $ksPanelName hook(ResizeControlsPanel)= ResizeControlsPanel#ResizeControlsPanelHook
	endif
	EnableDisableButtons()
End


// Hook for the panel that edits control resizing attributes.
// Not to be confused with the hook for client panels to move their controls as per the edited resizing attributes.
Static Function ResizeControlsPanelHook(hs)
	STRUCT WMWinHookStruct &hs

	Variable statusCode= 0
	String win= hs.winName
	
	strswitch(hs.eventName)
		case "resize":
			RemoveControlIndications()
			IndicateOneGuide("", "", 0)
			// control moving handled by ResizeControlsHook
			break
		case "deactivate":
			RemoveControlIndications()
			IndicateOneGuide("", "", 0)
			break
		case "activate":
			// 6.20A: automatically add new controls found in the panel (if it still exists).
			ControlInfo/W=$ksPanelName panels
			if( strlen(S_Value) && WinType(S_Value) )
				PossiblySelectNewControlInPanel(S_Value)
			endif
			if( EnableDisableButtons() )
				WAVE EditorSelWave=  $PanelDFVar("EditorSelWave")
				Variable row= SelectedListRow(EditorSelWave, 0)
				if( row >= 0 )
					WAVE/T EditorTextWave=  $PanelDFVar("EditorTextWave")
					String controlName= EditorTextWave[row][%name]
					ControlInfo/W=$ksPanelName panels
					IndicateControls(S_Value, controlName, 1)
				endif
			endif
			break
		case "kill":
			RemoveControlIndications()
			IndicateOneGuide("", "", 0)
			WC_WindowCoordinatesSave(win)
			Execute/P/Q/Z "DELETEINCLUDE <Resize Controls Panel>"	// remove this procedure file (Packages INSERTINCLUDEs it).
			Execute/P/Q/Z "COMPILEPROCEDURES "
			break
	endswitch
	return statusCode
End

static Function StringEndsWith(str, endsWith)
	String str, endsWith
	
	if( strlen(endsWith) == 0 )
		return 1
	endif
	Variable options= 1+2	// search backwards, case insensitive
	Variable pos= strsearch(str, endsWith, Inf, options)
	Variable shouldEndAt = strlen(str)-strlen(endsWith)
	Variable doesEndWith= pos >= 0 && pos == shouldEndAt
	return doesEndWith
End

static Function IsResizeControlsHookStr(hookStr)
	String hookStr
	
	variable isResizeHook= StringEndsWith(hookStr, "ResizeControls#ResizeControlsHook")
	return isResizeHook
End

static Function SetClearResizeControlsHook(panelName, sethook)
	String panelName	// expected to be only the host window name, because only host (top-level) windows are hookable.
	Variable sethook	// 0 to clear the hook
	
	GetWindow $panelName hook($ksResizeHookName)
	String oldHook= S_Value
	String stashedHook = GetUserData(panelName, "", ksStashResizeHookUDName)

	if( sethook )
		// avoid overwriting a carefully crafted ResizeHook that includes an independent module name
		if ( !IsResizeControlsHookStr(oldHook) )
			if( IsResizeControlsHookStr(stashedHook) )
				SetWindow $panelName hook($ksResizeHookName) = $stashedHook
			else
				SetWindow $panelName hook($ksResizeHookName) = ResizeControls#ResizeControlsHook
			endif
		endif
		SetWindow $panelName userData($ksStashResizeHookUDName) = ""
	else
		// save old hook from where it can be reinstated
		if( IsResizeControlsHookStr(oldHook) )
			SetWindow $panelName userData($ksStashResizeHookUDName) = oldHook
		endif
		SetWindow $panelName hook($ksResizeHookName) = $""
#if IgorVersion() >= 7
		SetWindow $panelName sizeLimit={0, 0, Inf, Inf}
#endif
	endif
End

static Function/S ControlNotInList(panelName)
	String panelName

	String controlsInPanel= ControlNameList(panelName)
	Variable i,n= ItemsInList(controlsInPanel)
	for(i=0; i<n; i+=1 )
		String controlName= StringFromList(i,controlsInPanel)
		Variable row= FindRowByName(controlName)
		if( row < 0 )
			return controlName
		endif
	endfor
	return ""
End

// returns name of newly selected control
static Function/S PossiblySelectNewControlInPanel(panelName)
	String panelName
	
	String newControlName= ControlNotInList(panelName)
	if( strlen(newControlName) )
		RemoveControlIndications()
		SaveControlPositions(panelName,0)		// make sure the current settings are not lost
		GetPanelControlPositions(panelName)	// update with all controls
		SaveControlPositions(panelName,0)		// save the new controls' default resize info
		// Select the (first) new control
		Variable row= FindRowByName(newControlName)
		if( row >= 0 )
			WAVE selWave=  $PanelDFVar("EditorSelWave")
			SelectListRow(selWave,row)
		endif
	endif
	return newControlName	// "" if no new control
End

// row # (0-n) or -1 if not found
Static Function FindRowByName(controlName)
	String controlName
	
	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( !WaveExists(EditorTextWave) )
		return -2
	endif

	return FindDimlabel(EditorTextWave,0,controlName)
End

// returns the first row with a selection. 0 is the first row. returns -1 if no row selected.
Static Function SelectedListRow(selWave, startRow)
	Wave selWave	// must exist
	Variable startRow	// 0 to search the entire wave for selections, larger to search later rows

	Variable nrows= DimSize(selWave,0)
	Variable ncols= DimSize(selWave,1)
	for( ; startRow < nrows; startRow += 1 )
		Variable col
		for( col= 0; col < ncols; col += 1 )
			if( selWave[startRow][col] & kCellIsSelectedMask )
				return startRow		// row in text and selection waves
			endif
		endfor	
	endfor
 
 	return -1
 End
 
 Static Function SelectListRow(selWave, selRow)
 	WAVE selWave	// must exist
 	Variable selRow	// -1 to select none

	Variable nrows= DimSize(selWave,0)
	Variable ncols= DimSize(selWave,1)
	Variable row
	for( row=0; row < nrows; row += 1 )
		Variable col
		for( col= 0; col < ncols; col += 1 )
			if( row == selRow && col == 0 )
				// select only the name column
				selWave[row][col] =  selWave[row][col] %| kCellIsSelectedMask
			else
				// deselect everything else
				selWave[row][col] = selWave[row][col] %& (~kCellIsSelectedMask)
			endif
		endfor	
	endfor
 
 	return selRow
 End

Static Function EnableDisableButtons()

	// enable/disable up/down/reset based on whether there is a selection
	WAVE EditorSelWave=  $PanelDFVar("EditorSelWave")
	Variable firstSelected= SelectedListRow(EditorSelWave, 0)
	Variable disable = (firstSelected >= 0 ) ? 0 : 2
	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")

//	String title= "Reset\r"+SelectString(firstSelected >= 0, "selected control",  EditorTextWave[firstSelected][%name])
	String firstSelectedStr
	if (firstSelected >= 0)
		firstSelectedStr= EditorTextWave[firstSelected][%name]
	else
		firstSelectedStr = "selected control"
	endif
	String title= "Reset\r"+ firstSelectedStr
	Button reset,win=$ksPanelName, disable=disable, title=title
	return disable == 0
End

Static Function/S HostWindowFromChild(windowName)
	String windowName	// "Panel0" or "Panel0#P0"
	
	return StringFromList(0,windowName,"#")
End

// installs the resize hook and set the info about constant height or width
Static Function UpdatePanelResizeHook()

	ControlInfo/W=$ksPanelName panels
	String panelName= HostWindowFromChild(S_Value)
	
	STRUCT WMResizeInfo resizeInfo
	// opposite of SetWindow $panelName userdata($ksResizeUserDataName)=userData
	String userdata = GetUserData(panelName, "", ksResizeUserDataName)
	if( strlen(userdata) )
		StructGet/S resizeInfo, userdata
	endif
	
	ControlInfo/W=$ksPanelName keepSameWidth
	resizeInfo.fixedWidth= V_Value	// for panel resize hook

	ControlInfo/W=$ksPanelName keepSameHeight
	resizeInfo.fixedHeight= V_Value	// for panel resize hook

	StructPut/S resizeInfo, userData
	SetWindow $panelName userdata($ksResizeUserDataName)=userData

	ControlInfo/W=$ksPanelName enableResizeHook
	SetClearResizeControlsHook(panelName, V_Value)
End

static Function GetPanelControlsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName panels
	GetPanelControlPositions(S_Value)
	SaveControlPositions(S_Value,0)
End

static Function RecordPositionsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName panels
	SaveControlPositions(S_Value,0)
End

Static Function ResizeHookCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	ControlInfo/W=$ksPanelName panels
	if( checked && UserOkaysRecordPositionsAndSize(S_Value))
		SaveControlPositions(S_Value,0)
	endif
	UpdatePanelResizeHook()
End

Static Function SameWidthCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if( checked )
		Checkbox keepSameHeight, win=$ksPanelName, value=0	// no sense in them both being checked.
	endif
	UpdatePanelResizeHook()
End

Static Function SameHeightCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if( checked )
		Checkbox keepSameWidth, win=$ksPanelName, value=0	// no sense in them both being checked.
	endif
	UpdatePanelResizeHook()
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

Static Function 	PanelCoordsToPoints(win, panelOrControlCoordinate)
	String win
	Variable panelOrControlCoordinate	// Igor 6 wsizeDC or Igor 7 points if screen resolution > 96 

	Variable points= panelOrControlCoordinate * PanelResolution(win) / ScreenResolution

	return points
End

// "Panel Coordinates" are used to store panel sizes to match the control coordinates.
// In this way, one control that fills the entire panel would have the same width and height values
// as the panel's "Panel Coordinates".
Static Function PointsToPanelCoords(win, points)
	String win
	Variable points 

	Variable panelOrControlCoordinate= points / PanelResolution(win) * ScreenResolution

	return panelOrControlCoordinate	// Igor 6 wsizeDC or Igor 7 points if screen resolution > 96
End

Static Function ResetButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName panels
	String panelName= HostWindowFromChild(S_Value)

	// We need the original size of window to compare with original positions of controls to generate offsets
	STRUCT WMResizeInfo resizeInfo
	String userdata = GetUserData(panelName, "", ksResizeUserDataName)
	if( strlen(userdata) == 0 )
		return 0
	endif
			
	StructGet/S resizeInfo, userdata

	ControlInfo/W=$ksPanelName keepSameWidth
	Variable saveFixedWidth= V_Value
	Checkbox keepSameWidth, win=$ksPanelName, value=0

	ControlInfo/W=$ksPanelName keepSameHeight
	Variable saveFixedHeight= V_Value
	Checkbox keepSameHeight, win=$ksPanelName, value=0

	ControlInfo/W=$ksPanelName enableResizeHook
	Variable saveHookState= V_Value
	Checkbox enableResizeHook, win=$ksPanelName, value=1

	UpdatePanelResizeHook()	// the hook will  will put the controls back

	GetWindow $panelName wsize	// V_Top, V_Left in points
	
	Variable originalWinWidthPoints= PanelCoordsToPoints(panelName,resizeInfo.originalWidth)
	Variable originalWinHeight= PanelCoordsToPoints(panelName,resizeInfo.originalHeight)
	MoveWindow/W=$panelName V_left, V_top, V_left+originalWinWidthPoints, V_top+originalWinHeight

	Checkbox keepSameWidth, win=$ksPanelName, value=saveFixedWidth
	Checkbox keepSameHeight, win=$ksPanelName, value=saveFixedHeight
	Checkbox enableResizeHook, win=$ksPanelName, value=saveHookState
	UpdatePanelResizeHook()
End

static Function ResetSelectedButtonProc(ctrlName) : ButtonControl
	String ctrlName

	WAVE/T/Z EditorSelWave= $PanelDFVar("EditorSelWave")
	if( !WaveExists(EditorSelWave) )
		Beep
		return -1
	endif
	Variable firstSelected= SelectedListRow(EditorSelWave, 0)
	if (firstSelected >= 0 ) 
		WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
		ctrlName= EditorTextWave[firstSelected][%name]
		//Update modes immediately
		ControlInfo/W=$ksPanelName panels
		String panelName= S_Value
		SetControlListModes(panelName,ctrlName, ksFixedFromLeft, ksFixedFromLeft, ksFixedFromTop,ksFixedFromTop)
		SaveControlPositions(panelName,1)	// modes only
	endif
End

static Function ResetAllButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoAlert 1, "Remove all Resizing info? This will abandon the controls to their current positions."
	if( V_Flag == 1 )	// yes
		ControlInfo/W=$ksPanelName panels
		String panelName= S_Value
		RemoveAllResizeInfo(panelName)
		// choose another panel so that we don't immediately install new resize infor
		String panels= RemoveFromList(panelName, WindowsPopMenu())
		String otherPanel= StringFromList(0,panels)
		Variable mode= 1+WhichListItem(otherPanel,WindowsPopMenu())
		PopupMenu panels, win=$ksPanelName, mode=mode
		PanelPopMenuProc("",mode,otherPanel)	
	endif
End

static Function PanelPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	RemoveControlIndications()
	GetPanelControlPositions(popStr)
	SaveControlPositions(popStr,0)
End

// Delete any existing indicator(s)
Function RemoveControlIndications()
	String IndicatorWindowName= StrVarOrDefault(PanelDFVar("IndicatorWindowName"), "")
	if( strlen(IndicatorWindowName) )
		DrawAction/W=$IndicatorWindowName getgroup=ResizeControlsIndicator	// sets V_startPos and V_endPos to index values of indicator group
		if( V_Flag )
			DrawAction/W=$IndicatorWindowName/L=UserBack delete=V_startPos,V_endPos
		endif
		String/G $PanelDFVar("IndicatorWindowName")= ""
	endif
End

Function IndicateControls(panelName, controlsList, drawIndicator)
	String panelName, controlsList
	Variable drawIndicator
	
	RemoveControlIndications()
	if( drawIndicator )
		Variable type=WinType(panelName)
		if( (type != 1) && (type != 7) )	// only panels and graphs
			return 0
		endif
		Variable groupStarted= 0
		Variable i, n= ItemsInList(controlsList)
		for(i=0; i<n; i+=1 )
			String controlName= StringFromList(i, controlsList)
			ControlInfo/W=$panelName $controlName
			if( V_Flag )
				Variable outset= 4	// pixels
				Variable left= V_Left - outset
				Variable right= V_Left+V_Width+outset
				Variable top= V_Top-outset
				Variable bottom= V_Top+V_Height+outset
				if( !groupStarted )
					SetDrawEnv/W=$panelName gstart, gname= ResizeControlsIndicator
					SetDrawLayer/W=$panelName UserBack
					SetDrawEnv/W=$panelName linefgc= (65535,0,0), linethick=2, dash=3, save
					SetDrawEnv/W=$panelName fillpat=0	, save				//	No fill
					SetDrawEnv/W=$panelName xcoord=abs, ycoord=abs, save	// pixels in a panel
					groupStarted= 1
				endif
				DrawRect/W=$panelName left, top, right, bottom
			endif	
		endfor
		if( groupStarted )
			SetDrawEnv/W=$panelName gstop	// without this, new draw objects are added to the group, But weirdly, DrawEnclosedDrawingObjectsIntoRect doesn't draw it!
			// Remember which window/subwindow has the indicator in it so we can find it for deleting
			String/G $PanelDFVar("IndicatorWindowName")= panelName
		endif
	endif
	return 1
End


Function IndicateOneGuide(panelName, moveMode, drawIndicator)
	String panelName
	String moveMode	// direct from listWave[row][%left], etc, something like "Guide UGV1"+ksPopArrowText
	Variable drawIndicator
	
	// Delete any existing indicator
	String IndicatorWindowName= StrVarOrDefault(PanelDFVar("IndGuideWindowName"), "")
	if( strlen(IndicatorWindowName) )
		DrawAction/W=$IndicatorWindowName getgroup=ResizeGuideIndicator	// sets V_startPos and V_endPos to index values of group
		if( V_Flag )
			DrawAction/W=$IndicatorWindowName/L=UserBack delete=V_startPos,V_endPos
		endif
		String/G $PanelDFVar("IndGuideWindowName")= ""
	endif
	if( drawIndicator )
		Variable type=WinType(panelName)
		if( (type != 1) && (type != 7) )	// only panels and graphs
			return 0
		endif
		String plainMoveMode= ReplaceString(ksPopArrowText, moveMode, "")
		String modeType= StringFromList(0,plainMoveMode," ")
		if( CmpStr(modeType,"Guide") == 0 )
			String guideName= StringFromList(1,plainMoveMode," ")
			String info= GuideInfo(panelName,guideName)
			if( strlen(info) )
				Variable position= NumberByKey("POSITION",info)	// in Panel Coordinates
				Variable isHorizontal= NumberByKey("HORIZONTAL",info)
				Variable outset= 1
				Variable vleft, vtop, vright, vbottom

				PanelCoordEdges(panelName, vleft, vtop, vright, vbottom)
				if( isHorizontal )
					vtop = position - outset
					vbottom = position + outset
				else
					vleft = position - outset
					vright = position + outset
				endif
				SetDrawEnv/W=$panelName gstart, gname= ResizeGuideIndicator
				SetDrawLayer/W=$panelName UserBack
				SetDrawEnv/W=$panelName linefgc= (65535,0,0), linebgc= (0,65535,0), linethick=1, dash=1
				SetDrawEnv/W=$panelName fillpat=0					//	No fill
				SetDrawEnv/W=$panelName xcoord=abs, ycoord=abs	// panel coords (scaled pixels)
				DrawRect/W=$panelName Vleft, Vtop, Vright, Vbottom
				SetDrawEnv/W=$panelName gstop	// without this, new draw objects are added to the group, But weirdly, DrawEnclosedDrawingObjectsIntoRect doesn't draw it!
				String/G $PanelDFVar("IndGuideWindowName")= panelName
			endif
		endif
	endif
	return 1
End