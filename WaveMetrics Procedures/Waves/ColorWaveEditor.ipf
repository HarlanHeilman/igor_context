#pragma rtGlobals=3		// Use modern global access method.
#pragma version=9.001		// circa Igor 9.00
#pragma IgorVersion=9
#pragma ModuleName=ColorWaveEditor
#include <PopupWaveSelector>
#include <SaveRestoreWindowCoords>, version>=6.1
#include <colorSpaceConversions>

//**************************************************************************************
//	Version 1.01
//		Changed color wave selector from a list waveselectorwidget to a popup to make room for new stuff.
//		Added an area on the control panel to make a new color wave.
//		Added function to allow client code to put up an editor for a specific wave.
//	Version 1.02
//		Made the color selection a contextual menu click on the list
//		Added ability to edit the color text
//	Version 1.03
//		Fixed control sizing problem when a new client editor was created.
//	Version 1.04
//		Controls that now work on the selected color wave are disabled if there is no selection. This prevents errors if these controls
//			are manipulated when there is no selection.
//	Version 1.05
//		Corrected CWE_FillEditorWaves()'s creation of EditorSelWave.
//	Version 6.36
//		JP, Resize of panel works better on Windows, made some controls longer.
//	Version 7
//		JP, PanelResolution changes for Igor 7, uses SetWindow sizeLimit if available.
// Version 9
//		JW, Added a Cancel button to the client version the panel.
//		JW, Added support for transparency
//		JW, Removed the New Wave section in favor of another panel summoned by "Make a New Wave" item in the Wave Selector
// Version 9.001
//		JP, Fixed alpha-related error in CWE_SetColor().
//		JW 210813, New wave failed to set the Has Alpha checkbox in the main panel correctly.
//**************************************************************************************

Menu "Data"
	"Show Color Wave Editor",/Q, CWE_MakeColorEditorPanel()
end

Menu "ColorWaveEditorMenu",contextualmenu,dynamic
	Submenu "Set the color"
		CWE_ColorPopMenuString(), /Q, CWE_MenuSetColor()
	end
	CWE_ColorPopMenuCopyString(), /Q, CWE_CopyColor()
	CWE_ColorPopMenuPasteString(), /Q, CWE_PasteColor()
end

constant CWE_range1=1
constant CWE_range100=100
constant CWE_range255=255
constant CWE_range65535=65535
strconstant CWE_MakeNewWaveText="\Zr125\f01Make a New Wave..."

//**************************************************************************************
//
// The color wave editor is mostly intended as a stand-alone editor to be invoked from the Data menu. But it can be called from
// your own code to edit a specified wave. In that case, the portions of the panel for selecting a wave or making a new wave are
// hidden, and the panel is set up to immediately start editing a particular wave. To do this, call this function:
//
// CWE_MakeClientColorEditor(cw, redColumn, colorRange, panelTitle, groupBoxTitle, DoneNotificationProc)
//		cw				A color wave to be edited.
//		redColumn		The column number of the first of the three color columns. Some uses of color waves, for instance for
//						a Gizmo plot, may have other stuff in them, with the three RGB columns starting at redColumn.
//		colorRange		A value giving the size of numbers for maximum color intensity. Choices are 1, 100, 255, or 65535.
//						For convenience the constants below can be used.
//		panelTitle	A string displayed in the titlebar of the panel window
//		groupBoxTitle	A string used for the title string of a groupbox control containing the panel's controls.
//							The groupbox is sort of a remnant of the full Color Editor panel.
//		DoneNotificationProc
//						The name of  a function that will be called when the user clicks the Done button. If you don't need this,
//						you can set it to "".
//		doAlpha		Optional input. If set to 1, the input wave cw is assumed to have four columns of color data including
//						an alpha value. If you do not use the doAlpha input, it is set to zero.
//**************************************************************************************

Function CWE_MakeClientColorEditor(Wave cw, Variable redColumn, Variable colorRange, String panelTitle, String groupBoxTitle, String DoneNotificationProc [, Variable doAlpha])
	if (doAlpha && DimSize(cw, 1) < 4)
		return 0
	endif
	
	Variable result = CWE_FixColorWaveDimLabels(cw, redColumn, doAlpha)

	if (WinType("ColorWaveEditorPanel") == 7)
		DoWindow/K ColorWaveEditorPanel
	endif

	CWE_MakeColorEditorPanel()
	SetWindow ColorWaveEditorPanel#WaveSelectionPanel hide=1
	GetWindow ColorWaveEditorPanel wsizeOuter
	MoveWindow/W=ColorWaveEditorPanel V_left,V_top,V_right,V_top+314*(PanelResolution("ColorWaveEditorPanel")/ScreenResolution)
	DefineGuide/W=ColorWaveEditorPanel UGH0={FT,0}
	Button CWE_UnloadPackageButton,win=ColorWaveEditorPanel#WaveEditorPanel,disable=1
	GroupBox CWE_EditWaveGroup,win=ColorWaveEditorPanel#WaveEditorPanel,title=groupBoxTitle
	Button CWE_RevertButton,win=ColorWaveEditorPanel#ColorWaveEditorDonePanel, title="Cancel", rename=CWE_CancelButton
	
	NVAR firstColorColumn = root:Packages:WM_ColorWaveEditor:firstColorColumn
	firstColorColumn = redColumn
	
	String SelectedItem = GetWavesDataFolder(cw, 2)
	PopupWS_SetSelectionFullPath("ColorWaveEditorPanel#WaveSelectionPanel", "CWE_ColorWaveSelector", SelectedItem)
	CWE_WaveSelectNotification(WMWS_SelectionChanged, SelectedItem, "ColorWaveEditorPanel#WaveSelectionPanel", "CWE_ColorWaveSelector")	// JW 200706 This will guess at the color range and set it accordingly, quite possibly incorrectly.
	
	SetWindow ColorWaveEditorPanel,userData(CWE_DoneNotification)=DoneNotificationProc
	SetWindow ColorWaveEditorPanel,userData(CWE_ClientEditor)="YES"
	
	DoWindow/T ColorWaveEditorPanel, panelTitle
	CWE_PositionControlsForResize()
	
	// JW 200706 This must come late in the process. CWE_WaveSelectNotification() makes a guess at the color range from inspecting the wave values.
	// We are likely to have a zero-filled wave if its new, and that will result in a 0-1 range. So we set the range in accordance with the input
	// after everything else.
	NVAR CWD_HighComponentRange = root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange
	CWD_HighComponentRange = colorRange
	Variable highRangeItem = HighValuetoRangeMenuItem(CWD_HighComponentRange)
	NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
	if (ParamIsDefault(doAlpha))
		hasAlpha = 0
	else
		hasAlpha = doAlpha
	endif
	Checkbox CWE_WaveHasAlphaCheckbox,win=ColorWaveEditorPanel#WaveSelectionPanel, value=doAlpha
	PopupMenu CWE_RGBRangeMenu,win=ColorWaveEditorPanel#WaveSelectionPanel,mode=highRangeItem
	CWE_FillEditorWaves(cw, redColumn, CWD_HighComponentRange, doAlpha = hasAlpha)
	CWE_EnableSelectedWaveControls()
end

Function CWE_MakeColorEditorPanel()

	if (WinType("ColorWaveEditorPanel") == 7)
		String isClientEditor = GetUserData("ColorWaveEditorPanel", "", "CWE_ClientEditor")
		if (CmpStr(isClientEditor, "YES") == 0)
			DoWindow/K ColorWaveEditorPanel
			// and fall through to make a new panel below
		else
			DoWindow/F ColorWaveEditorPanel
			return 0
		endif
	endif
	
	
	ColorWaveEditorGlobals()

	String fmt="NewPanel/K=1/W=(%s) as \"Color Wave Editor\""
	Execute WC_WindowCoordinatesSprintf("ColorWaveEditorPanel", fmt, 50, 83, 434, 665, 1)	// points
	
	Dowindow/C ColorWaveEditorPanel

	DefineGuide UGH0={FT,165}
	DefineGuide UGH1={FB,-29}

	NewPanel/W=(0,0,384,437)/FG=(FL,FT,FR,UGH0)/HOST=# 
	ModifyPanel frameStyle=0, frameInset=0
	RenameWindow #,WaveSelectionPanel

//	TitleBox CWE_FirstTitle,pos={8,11},size={82,15},title="First, either..."
//	TitleBox CWE_FirstTitle,fSize=12,frame=0,fStyle=1

	GroupBox CWE_SelectWaveGroup,pos={6.00,8.00},size={372.00,148.00}
	GroupBox CWE_SelectWaveGroup,fStyle=1,title="Select a Color Wave"

		Button CWE_ColorWaveSelector,pos={39,30},size={200,20}
		Button CWE_ColorWaveSelector,help={"Select a color wave. Only 2D waves with at least three columns are available. Use the area below to make a new three-column wave."}
		MakeButtonIntoWSPopupButton("ColorWaveEditorPanel#WaveSelectionPanel", "CWE_ColorWaveSelector", "CWE_WaveSelectNotification")
		PopupWS_AddSelectableString("ColorWaveEditorPanel#WaveSelectionPanel", "CWE_ColorWaveSelector", CWE_MakeNewWaveText)
		PopupWS_MatchOptions("ColorWaveEditorPanel#WaveSelectionPanel", "CWE_ColorWaveSelector", listoptions="DIMS:2,MINCOLS:3,TEXT:0,CMPLX:0")
		String wlist = WaveList("*", ";", "DIMS:2,MINCOLS:3,TEXT:0,CMPLX:0")
		Wave/Z w = $StringFromList(0, wlist)
		string SelectedItem = ""
		if (WaveExists(w))
			SelectedItem = GetWavesDataFolder(w, 2)
			PopupWS_SetSelectionFullPath("ColorWaveEditorPanel#WaveSelectionPanel", "CWE_ColorWaveSelector", SelectedItem)
		endif
		
		SetVariable CWE_SetFirstColorColumn,pos={92,63},size={200,15},proc=CWE_SetFirstColorColumnProc,title="Column Containing Red Values:"
		SetVariable CWE_SetFirstColorColumn,limits={0,0,1},value= root:Packages:WM_ColorWaveEditor:firstColorColumn,bodyWidth= 60
		SetVariable CWE_SetFirstColorColumn,help={"If the red column is not column zero, set the column number corresponding to red values here."}

		CheckBox CWE_WaveHasAlphaCheckbox,pos={92.00,92.00},size={151.00,16.00}, proc=CWE_WaveHasAlphaCheckProc
		CheckBox CWE_WaveHasAlphaCheckbox,title="Fourth Column Contains Alpha",value= 0

		PopupMenu CWE_RGBRangeMenu,pos={62,119},size={261,20},proc=CWE_RGBRangeMenuProc,title="RGB Component Range for This Wave:"
		PopupMenu CWE_RGBRangeMenu,mode=4,bodyWidth= 90,value= #"\"0-1;0-100;0-255;0-65535;\""
		PopupMenu CWE_RGBRangeMenu,help={"Use this menu to tell the color wave editor what range the RGB values cover. This menu does not alter the wave."}

	SetActiveSubwindow ##
	NewPanel/W=(0,302,384,437)/FG=(FL,UGH0,FR,UGH1)/HOST=#
	ModifyPanel frameStyle=0, frameInset=0

	DefineGuide UGV0={FL,12}
	DefineGuide UGV1={FR,-15}
	DefineGuide UGH0={FB,-119}
	DefineGuide UGH1={FB,-8}

	GroupBox CWE_EditWaveGroup,pos={6,1},size={372,285},title="Edit Color Wave"
	GroupBox CWE_EditWaveGroup,fStyle=1

		Make/T/O/N=2 root:Packages:WM_ColorWaveEditor:CWE_ListTitles
		Wave/T CWE_ListTitles=root:Packages:WM_ColorWaveEditor:CWE_ListTitles
		CWE_ListTitles={"Click for Menu", "Click to Edit; Right-click for Menu"}
		ListBox CWE_ColorEditorList,pos={13,25},size={358,167},proc=CWE_EditorListProc
		ListBox CWE_ColorEditorList,fSize=9,titleWave=CWE_ListTitles
		ListBox CWE_ColorEditorList,mode= 5,widths= {50,150}
		ListBox CWE_ColorEditorList,help={"Displays contents of selected color wave. Click the row number cell or right-click the color sample to get a menu to change the color or copy or paste color info. Click the color sample to edit the numeric values as text."}
		
		NewPanel/W=(273,16,265,275)/FG=(UGV0,UGH0,UGV1,UGH1)/HOST=# 
		ModifyPanel frameStyle=0, frameInset=0

			Button CWE_ColorTableMenuButton,pos={63.00,5.00},size={227.00,20.00},proc=CWE_FillFromCTableMenuProc
			Button CWE_ColorTableMenuButton,title="Fill Wave Using Color Table \\W623"
			
			CheckBox CWE_ColorTableInterpCheck,pos={91,31},size={171,16},title="Interpolate Colors from Color Table"
			CheckBox CWE_ColorTableInterpCheck,value= 1
			CheckBox CWE_ColorTableInterpCheck,help={"When checked, color table values are interpolated to fit the selected color wave. Otherwise, the color index closest to the point number in the wave is selected."}

			SetVariable CWE_SetAllAlphaSetVar,pos={104,60.00},size={145.00,14.00},bodyWidth=60,proc=CWE_SetAllAlphaProc
			SetVariable CWE_SetAllAlphaSetVar,title="Set All Alpha (0,1):"
			SetVariable CWE_SetAllAlphaSetVar,limits={0,1,0.02},value= _NUM:1,live= 1
	
			PopupMenu CWE_RGBChangeRangeMenu,pos={79,85},size={195,20},proc=RGBChangeRangeMenuProc,title="Transform RGB Value Range"
			PopupMenu CWE_RGBChangeRangeMenu,mode=0,value= #"\"0-1;0-100;0-255;0-65535;\""
			PopupMenu CWE_RGBChangeRangeMenu,help={"Select a new range for the RGB values in your wave. All entries in the wave will be scaled to the new range."}

			RenameWindow #,WaveEditorControls
		SetActiveSubwindow ##
	
	RenameWindow #,WaveEditorPanel
	SetActiveSubwindow ##

	NewPanel/W=(0,145,384,582)/FG=(FL,UGH1,FR,FB)/HOST=# 
	ModifyPanel frameStyle=0, frameInset=0

		Button CWE_DoneButton,pos={10,5},size={50,20},proc=CWE_DoneButtonProc,title="Done"
		Button CWE_DoneButton,help={"Click this button to close the Color Wave Editor panel."}

		Button CWE_HelpButton,pos={71.00,5.00},size={50.00,20.00},proc=CWE_HelpButtonProc
		Button CWE_HelpButton,title="Help",proc=CWE_ShowHelp

		Button CWE_UnloadPackageButton,pos={224.00,5.00},size={150,20},proc=CWE_UnloadPackageButtonProc,title="Unload Package"
		Button CWE_UnloadPackageButton,help={"Click this button to close the Color Wave Editor panel and unload the package procedure file."}
		
		Button CWE_RevertButton,pos={133.00,5.00},size={75.00,20.00},title="Revert",proc=CWE_RevertButtonProc
		Button CWE_RevertButton,help={"Click to restore your color wave to its state when you first selected it."}

	RenameWindow #,ColorWaveEditorDonePanel
	SetActiveSubwindow ##

	CWE_FillEditorWaves($PopupWS_GetSelectionFullPath("ColorWaveEditorPanel#WaveEditorPanel", "CWE_ColorWaveSelector"), 0, 4, doAlpha = 0)	// 0=first color column, 4=code for color value range
	ListBox CWE_ColorEditorList,win=ColorWaveEditorPanel#WaveEditorPanel,listWave=root:Packages:WM_ColorWaveEditor:EditorTextWave
	ListBox CWE_ColorEditorList,win=ColorWaveEditorPanel#WaveEditorPanel,selWave=root:Packages:WM_ColorWaveEditor:EditorSelWave
	ListBox CWE_ColorEditorList,win=ColorWaveEditorPanel#WaveEditorPanel,colorWave=root:Packages:WM_ColorWaveEditor:EditorColorWave
	CWE_WaveSelectNotification(WMWS_SelectionChanged, SelectedItem, "ColorWaveEditorPanel#WaveEditorPanel", "CWE_ColorWaveSelector")
	
	SetWindow kwTopWin,hook(ColorEditorHook)=WM_ColorEditorPanelHook
	SetWindow kwTopWin, hook = WC_WindowCoordinatesHook
	SetWindow ColorWaveEditorPanel,userData(CWE_ClientEditor)="NO"
	
	CWE_EnableSelectedWaveControls()
	
	GetWindow ColorWaveEditorPanel, wsize	//points
	Variable minimized= (V_right == V_left) && (V_bottom==V_top)
	if( minimized )
		return 0
	endif
	Variable minWidthPoints= CWE_MainPanelMinWidth / ScreenResolution * PanelResolution("ColorWaveEditorPanel")
	Variable minHeightPoints= CWE_MainPanelMinHeight / ScreenResolution * PanelResolution("ColorWaveEditorPanel")
	SetWindow ColorWaveEditorPanel sizeLimit={minWidthPoints, minHeightPoints, Inf, Inf}

	CWE_PositionControlsForResize()
end

static constant CWE_MainPanelMinWidth = 384 // panel units
//static constant CWE_MainPanelMinHeight = 582 // panel units
static constant CWE_MainPanelMinHeight = 440 // panel units

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

static Function CWE_PositionControlsForResize()

	String ugh0info = GuideInfo("ColorWaveEditorPanel", "UGH0")
	String ugh1info = GuideInfo("ColorWaveEditorPanel", "UGH1")
	Variable EditListPanelHeight = NumberByKey("POSITION", ugh1info) - NumberByKey("POSITION", ugh0info) 			// panel units
	GetWindow ColorWaveEditorPanel, wsize // points
	Variable PointsToPanelUnits=ScreenResolution/PanelResolution("ColorWaveEditorPanel")
	Variable panelWidth = (V_right - V_left)*PointsToPanelUnits

	// Now we're looking at the guides that set the position of the WaveEditorControls panel
	ugh0info = GuideInfo("ColorWaveEditorPanel#WaveEditorPanel", "UGH0")
	ugh1info = GuideInfo("ColorWaveEditorPanel#WaveEditorPanel", "UGH1")
	Variable EditorContorlsPanelVOffset = NumberByKey("RELPOSITION", ugh1info)												// It's relative to a guide below, so negative
	Variable EditorControlsPanelHeight = NumberByKey("POSITION", ugh1info) - NumberByKey("POSITION", ugh0info) 	// panel units
	EditorControlsPanelHeight -= EditorContorlsPanelVOffset

	Variable EditorControlsTop = EditorControlsPanelHeight - EditorContorlsPanelVOffset									// panel units
	Variable ListControlsHeight = EditListPanelHeight - EditorControlsPanelHeight - 25								// 25 is the position of the top of the listbox control
	Groupbox CWE_EditWaveGroup, win=ColorWaveEditorPanel#WaveEditorPanel,size={panelWidth-12,EditListPanelHeight-2}
	ListBox CWE_ColorEditorList, win=ColorWaveEditorPanel#WaveEditorPanel,size={panelWidth-26, ListControlsHeight-5}
End

Function CWE_DeferredResize()
	Variable/G  root:Packages:WM_ColorWaveEditor:resizePending=0
	CWE_PositionControlsForResize()
End

Function WM_ColorEditorPanelHook(H_Struct)
	STRUCT WMWinHookStruct &H_Struct
	
	Variable statusCode = 0
	
	switch (H_Struct.eventCode)
		case 0:		// activate event
			NVAR/Z gColorEditorDeactivateTime = root:Packages:WM_ColorWaveEditor:gColorEditorDeactivateTime
			if (NVAR_Exists(gColorEditorDeactivateTime))
				SVAR/Z SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
				if (SVAR_Exists(SelectedItem))
					Wave/Z w = $SelectedItem
					if (WaveExists(w))
						Variable modTicks = NumberByKey("MODTIME", WaveInfo(w, 0))
						if (modTicks > gColorEditorDeactivateTime)
							// mod time of wave indicates it was changed while the panel was deactivated. We need to refresh the display.
							NVAR firstColorColumn = root:Packages:WM_ColorWaveEditor:firstColorColumn
							NVAR CWD_HighComponentRange = root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange
							NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
							CWE_FillEditorWaves(w, firstColorColumn, CWD_HighComponentRange, doAlpha = hasAlpha)
						endif
					endif
				endif
			endif
			break
		case 1:		// deactivate event
			// save the deactivation time for comparison with wave mod time when the panel is next activated
			Variable/G root:Packages:WM_ColorWaveEditor:gColorEditorDeactivateTime = DateTime
			break
		case 2:		// kill event
			KillDataFolder root:Packages:WM_ColorWaveEditor:
			break
		case 6:		// resize
			Variable pending= NumVarOrDefault("root:Packages:WM_ColorWaveEditor:resizePending",0)
			if( !pending )
				Variable/G  root:Packages:WM_ColorWaveEditor:resizePending=1
				Execute/P/Q/Z "CWE_DeferredResize()"
			endif
			break
	endswitch
	
	return statusCode		// 0 if nothing done, else 1
end

// *** Make a new wave panel ***

static Function CWE_MakeNewWavePanelf()
	NewPanel/W=(50, 83, 434, 200)
	RenameWindow $S_name, CWE_MakeNewWavePanel
	SetVariable CWE_NewWaveName,pos={19,13},size={243,15},title="Name for New Wave"
	SetVariable CWE_NewWaveName,value= root:Packages:WM_ColorWaveEditor:CWE_NewWaveName,bodyWidth= 150
	SetVariable CWE_NewWaveName,help={"Enter a name for your new color wave. This name will be used when you click the Make It button."}

	SetVariable CWE_SetNewWaveRows,pos={33,40},size={139,15},title="Number of Rows:"
	SetVariable CWE_SetNewWaveRows,value= root:Packages:WM_ColorWaveEditor:CWE_NewWaveNumRows,bodyWidth= 60
	SetVariable CWE_SetNewWaveRows,help={"Enter the number of rows for the color wave. If you want to use it to set colors of a graph trace, you may want it to have the same number of rows. In that case, select the graph wave in the menu to the right."}

	Button CWE_MatchRowsWaveSelector,pos={183,38},size={180,20},title="Set Rows to Match This Wave"
	Button CWE_MatchRowsWaveSelector,fSize=9
	Button CWE_MatchRowsWaveSelector,help={"Certain applications, like coloring points in a graph trace, require the number of rows to match the displayed wave. Use this menu to select that wave. Selecting a wave will set the number of rows to match."}
	MakeButtonIntoWSPopupButton("CWE_MakeNewWavePanel", "CWE_MatchRowsWaveSelector", "CWE_MatchWaveSelectNotification",options=PopupWS_OptionTitleInTitle)

	CheckBox CWE_WaveShouldHaveAlphaCheckbox,pos={33.00,66.00},size={152.00,16.00}
	CheckBox CWE_WaveShouldHaveAlphaCheckbox,title="Add a Fourth Column for Alpha"
	CheckBox CWE_WaveShouldHaveAlphaCheckbox,value= 0

	Button CWE_MakeNewWaveButton,pos={20,87},size={80,20},title="Make It",proc=CWE_MakeNewWaveButtonProc
	Button CWE_MakeNewWaveCancelButton,pos={282.00,87},size={80,20},title="Cancel",proc=CWE_MakeNewWaveCancelButtonProc
end

// *** TODO: memory of previous settings ***

Function ColorWaveEditorGlobals()

	String SaveDF = GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_ColorWaveEditor
	
	Variable/G firstColorColumn = 0
	Variable/G CWE_EditMenuRow = -1
	Variable/G CWD_HighComponentRange = 65535
	
	Variable/G CWE_NewWaveNumRows=256
	String/G CWE_NewWaveName="MyColorWave"
	Variable/G CWE_hasAlpha=0
	
	Variable/G CWE_WaveWasNew = 0
	Variable/G CWE_OriginalHighComponentRange = 0
	Variable/G CWE_OriginallyHadAlpha = 0
	
	SetDataFolder SaveDF
end

Function RangeMenuItemToHighRange(itemNumber)
	Variable itemNumber
	
	switch (itemNumber)
		case 1:
			return 1
		case 2:
			return 100
		case 3:
			return 255
		case 4:
			return 65535
	endswitch
end

Function HighValuetoRangeMenuItem(rangeHigh)
	Variable rangeHigh
	
	if (rangeHigh > 255)
		return 4
	elseif (rangeHigh > 100)
		return 3
	elseif (rangeHigh > 1)
		return 2
	else
		return 1
	endif
end

Function CWE_WaveSelectNotification(event, SelectedItem, windowName, ctrlName)
	Variable event
	String SelectedItem
	String windowName
	String ctrlName

	if (event != WMWS_SelectionChanged)
		return 0
	endif

	if (CmpStr(SelectedItem, CWE_MakeNewWaveText) == 0)
		CWE_MakeNewWavePanelf()
	else
		Wave/Z w = $SelectedItem
		if (WaveExists(w))
			SVAR/Z SavedSelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
			if (!SVAR_Exists(SavedSelectedItem))
				String/G root:Packages:WM_ColorWaveEditor:SelectedItem = SelectedItem
				SVAR/Z SavedSelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
			else
				if (CmpStr(SavedSelectedItem, SelectedItem) == 0)
					return 0		// *** Exit- do nothing
				endif
				SavedSelectedItem = SelectedItem
			endif
			
			[Variable colorMaxValue_a, Variable firstColorColumn_a, Variable hasAlpha_a] = CWE_AnalyzeColorWave(w)
			
			NVAR firstColorColumn = root:Packages:WM_ColorWaveEditor:firstColorColumn
			firstColorColumn = firstColorColumn_a // 0
			Variable maxRedColumn = DimSize(w,1) - (hasAlpha_a ? 4 : 3)
			SetVariable CWE_SetFirstColorColumn, win=ColorWaveEditorPanel#WaveSelectionPanel,limits={0,maxRedColumn,1}

			Variable highRangeItem = HighValuetoRangeMenuItem(colorMaxValue_a)
			PopupMenu CWE_RGBRangeMenu,win=ColorWaveEditorPanel#WaveSelectionPanel,mode=highRangeItem
			Variable/G root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange = colorMaxValue_a
			NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
			hasAlpha = hasAlpha_a
			CheckBox CWE_WaveHasAlphaCheckbox, win=ColorWaveEditorPanel#WaveSelectionPanel,value=hasAlpha
			CWE_FillEditorWaves(w, firstColorColumn, colorMaxValue_a, doAlpha = hasAlpha)

			NVAR/Z CWE_EditMenuRow = root:Packages:WM_ColorWaveEditor:CWE_EditMenuRow
			if (NVAR_Exists(CWE_EditMenuRow))
				CWE_EditMenuRow = -1
			endif

			ListBox CWE_ColorEditorList,win=ColorWaveEditorPanel#WaveEditorPanel, row=0

			Duplicate/O w, root:Packages:WM_ColorWaveEditor:W_SelectedWaveCopy
			NVAR CWE_WaveWasNew = root:Packages:WM_ColorWaveEditor:CWE_WaveWasNew
			NVAR CWD_HighComponentRange = root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange
			NVAR CWE_OriginalHighComponentRange = root:Packages:WM_ColorWaveEditor:CWE_OriginalHighComponentRange
			CWE_OriginalHighComponentRange = CWD_HighComponentRange
			NVAR CWE_OriginallyHadAlpha = root:Packages:WM_ColorWaveEditor:CWE_OriginallyHadAlpha
			CWE_OriginallyHadAlpha = hasAlpha
			CWE_WaveWasNew = 0
		endif
	endif
	CWE_EnableSelectedWaveControls()
end

// DisplayHelpTopic "Multiple Return Syntax"
Function [Variable colorMaxValue, Variable firstColorColumn, Variable hasAlpha] CWE_AnalyzeColorWave(Wave cw)

	Variable cols = DimSize(cw,1)
	if( cols < 3 )
		return [NaN, NaN, 0]
	endif

	// Find first color column.
	firstColorColumn= 0
	hasAlpha = 0
	if( cols > 3 )
		// look for "red" column dimension label
		Variable foundCol = FindDimLabel(cw,1,"red")
		if( foundCol >= 0 )
			firstColorColumn = foundCol
		endif
		Variable alphaColumn = firstColorColumn + 3	// +0 is red, +1 is green, +2 is blue
		if( alphaColumn < cols ) // the wave has enough columns for the alpha
			// but do we KNOW it is alpha?
			// We say alphaColumn contains alpha values if the dimension label is "alpha", otherwise we don't presume.
			foundCol = FindDimLabel(cw,1,"alpha")
			if( foundCol == alphaColumn )
				hasAlpha = 1
			endif
		endif
	endif
	// compute max value of the color columns
	Variable lastColorColumn = firstColorColumn + (hasAlpha ? 3 : 2)
	WaveStats/Q/M=0/RMD=[][firstColorColumn,lastColorColumn] cw
	colorMaxValue = V_max
	// figure out what the absolute max is, in case nothing is full white/opaque
	if( colorMaxValue > 255 )
		colorMaxValue = 65535
	elseif( colorMaxValue > 100 )
		colorMaxValue = 255
	elseif( colorMaxValue > 1 )
		colorMaxValue= 100
	else
		colorMaxValue = 1
	endif
End

Function 	CWE_FixColorWaveDimLabels(Wave cw, Variable redColumn, Variable doAlpha)

	// remove any conflicting dim labels
	Variable col = FindDimLabel(cw,1,"red")
	if( col >= 0 )
		SetDimLabel 1, col, $"", cw
	endif
	col = FindDimLabel(cw,1,"green")
	if( col >= 0 )
		SetDimLabel 1, col, $"", cw
	endif
	col = FindDimLabel(cw,1,"blue")
	if( col >= 0 )
		SetDimLabel 1, col, $"", cw
	endif
	col = FindDimLabel(cw,1,"alpha")
	if( col >= 0 )
		SetDimLabel 1, col, $"", cw
	endif

	Variable cols = DimSize(cw,1)
	Variable lastColumn = cols-1
	Variable neededLastColumn = redColumn + 2
	if( neededLastColumn > lastColumn )
		return -1		// not enough columns for rgb
	endif
	SetDimLabel 1, redColumn, red, cw
	SetDimLabel 1, redColumn+1, green, cw
	SetDimLabel 1, redColumn+2, blue, cw
	if( doAlpha )
		neededLastColumn += 1
		if( neededLastColumn > lastColumn )
			return -2		// not enough columns for rgba
		endif
		SetDimLabel 1, redColumn+3, alpha, cw
	endif
	return 0 // no error
End

static Function CWE_EnableSelectedWaveControls()

	Variable disable = 0
	
	SVAR/Z SavedSelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
	if (SVAR_Exists(SavedSelectedItem))
		Wave/Z selectedWave = $SavedSelectedItem
	endif
	if (!WaveExists(selectedWave))
		disable = 2
	endif
	ListBox CWE_ColorEditorList,win=ColorWaveEditorPanel#WaveEditorPanel,disable=disable
	Button CWE_ColorTableMenuButton,win=ColorWaveEditorPanel#WaveEditorPanel#WaveEditorControls,disable=disable
	Checkbox CWE_ColorTableInterpCheck,win=ColorWaveEditorPanel#WaveEditorPanel#WaveEditorControls,disable=disable
	PopupMenu CWE_RGBChangeRangeMenu,win=ColorWaveEditorPanel#WaveEditorPanel#WaveEditorControls,disable=disable
	
	NVAR CWE_HasAlpha = root:Packages:WM_ColorWaveEditor:CWE_HasAlpha
	SetVariable CWE_SetAllAlphaSetVar, win=ColorWaveEditorPanel#WaveEditorPanel#WaveEditorControls,disable = CWE_HasAlpha ? 0 : 2
end

Function CWE_MatchWaveSelectNotification(event, SelectedItem, windowName, ctrlName)
	Variable event
	String SelectedItem
	String windowName
	String ctrlName
	
	if (event != WMWS_SelectionChanged)
		return 0
	endif
	
	Wave/Z w = $SelectedItem
	if (WaveExists(w))
		NVAR CWE_NewWaveNumRows = root:Packages:WM_ColorWaveEditor:CWE_NewWaveNumRows
		CWE_NewWaveNumRows = DimSize(w,0)
	endif
end

Function CWE_MakeNewWaveButtonProc(STRUCT WMButtonAction & s) : ButtonControl
	if (s.eventCode == 2)			// mouse up
		NVAR CWE_NewWaveNumRows = root:Packages:WM_ColorWaveEditor:CWE_NewWaveNumRows
		SVAR CWE_NewWaveName = root:Packages:WM_ColorWaveEditor:CWE_NewWaveName
		NVAR firstColorColumn = root:Packages:WM_ColorWaveEditor:firstColorColumn
		NVAR CWD_HighComponentRange = root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange
		ControlInfo/W=$s.win CWE_WaveShouldHaveAlphaCheckbox
		Variable/G root:Packages:WM_ColorWaveEditor:CWE_HasAlpha = V_value
		NVAR CWE_HasAlpha = root:Packages:WM_ColorWaveEditor:CWE_HasAlpha

		Make/O/N=(CWE_NewWaveNumRows, CWE_HasAlpha ? 4 : 3) $CWE_NewWaveName
		Wave w = $CWE_NewWaveName
		if (WaveExists(w))
			firstColorColumn = 0
			SetDimLabel 1,0,red,w
			SetDimLabel 1,1,green,w
			SetDimLabel 1,2,blue,w
			Variable menuMode = HighValuetoRangeMenuItem(65535)
			PopupMenu CWE_RGBRangeMenu,win=ColorWaveEditorPanel#WaveSelectionPanel,mode=menuMode
			CWD_HighComponentRange = RangeMenuItemToHighRange(menuMode)
			Checkbox CWE_WaveHasAlphaCheckbox,win=ColorWaveEditorPanel#WaveSelectionPanel,value = CWE_HasAlpha
			if (CWE_HasAlpha)
				SetDimLabel 1,3,alpha,w
				w[][3] = 65535
			endif

			String SelectedItem = GetWavesDataFolder(w, 2)
			PopupWS_SetSelectionFullPath("ColorWaveEditorPanel#WaveSelectionPanel", "CWE_ColorWaveSelector", SelectedItem)
			CWE_WaveSelectNotification(WMWS_SelectionChanged, SelectedItem, "ColorWaveEditorPanel#WaveSelectionPanel", "CWE_ColorWaveSelector")

			CWE_FillEditorWaves(w, 0, 65535, doAlpha = CWE_HasAlpha)
			CheckBox CWE_WaveHasAlphaCheckbox, win=$(s.win),value=CWE_HasAlpha
			
			NVAR CWE_WaveWasNew = root:Packages:WM_ColorWaveEditor:CWE_WaveWasNew
			CWE_WaveWasNew = 1
			Duplicate/O w, root:Packages:WM_ColorWaveEditor:W_SelectedWaveCopy
		endif
		CWE_EnableSelectedWaveControls()
		
		Execute/P/Q "KillWindow "+s.win
	endif
end


Function CWE_MakeNewWaveCancelButtonProc(STRUCT WMButtonAction & s) : ButtonControl
	if (s.eventCode == 2)			// mouse up
		SVAR/Z SavedSelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
		if (SVAR_Exists(SavedSelectedItem))
			Wave/Z w = $SavedSelectedItem
			if (WaveExists(w))
				PopupWS_SetSelectionFullPath("ColorWaveEditorPanel#WaveSelectionPanel", "CWE_ColorWaveSelector", SavedSelectedItem)
			endif
		endif
		Wave/Z w = $PopupWS_GetSelectionFullPath("ColorWaveEditorPanel#WaveSelectionPanel", "CWE_ColorWaveSelector")
		if (!WaveExists(w))
			String wlist = WaveList("*", ";", "DIMS:2,MINCOLS:3,TEXT:0,CMPLX:0")
			Wave/Z w = $StringFromList(0, wlist)
			string SelectedItem = ""
			if (WaveExists(w))
				SelectedItem = GetWavesDataFolder(w, 2)
				PopupWS_SetSelectionFullPath("ColorWaveEditorPanel#WaveSelectionPanel", "CWE_ColorWaveSelector", SelectedItem)
			endif
		endif
		Execute/P/Q "KillWindow "+s.win
	endif
end

static Function/S CWE_SetEditorTextForColor(Variable red, Variable green, Variable blue, String format [, Variable doAlpha, Variable alpha])
	String newtext
	String formatstr = format + ", " + format + ", " + format
	if (!ParamIsDefault(doAlpha) && doAlpha)
		formatstr += ", " + format
		sprintf newtext, formatstr, red, green, blue, alpha
	else
		sprintf newtext, formatstr, red, green, blue
	endif
	return newtext
end

// returns doAlpha, possibly modified if it turns out wave w *does not* have the right number of columns.
static Function CWE_FillEditorWaves(Wave/Z w, Variable firstColorColumn, Variable highRange [, Variable doAlpha])
	// highRange	 = top end of component range (100 means RGB components range from 0 to 100)
	// doAlpha = 1 means wave w has enough columns to have alpha, and the appropriate checkbox is turned on
	if (ParamIsDefault(doAlpha))
		doAlpha = 0
	endif
		
	if (WaveExists(w))
		CWE_FixColorWaveDimLabels(w, firstColorColumn, doAlpha)
		Variable rows = DimSize(w, 0)
		Variable cols = DimSize(w, 1)
		Make/O/N=(rows, 2)/T root:Packages:WM_ColorWaveEditor:EditorTextWave
		Make/O/N=(rows, 2, 3) root:Packages:WM_ColorWaveEditor:EditorSelWave
		Make/O/N=(rows+2, 4) root:Packages:WM_ColorWaveEditor:EditorColorWave
		Wave/T EditorTextWave = root:Packages:WM_ColorWaveEditor:EditorTextWave
		Wave EditorSelWave = root:Packages:WM_ColorWaveEditor:EditorSelWave
		Wave EditorColorWave = root:Packages:WM_ColorWaveEditor:EditorColorWave
		EditorColorWave[0][] = 0
		EditorColorWave[1][] = 65535		// white for text on dark colors
		EditorColorWave[2, rows+1][0,2] = w[p-2][q+firstColorColumn]*65535/highRange
		Variable lastColumn = cols-1
		Variable neededLastColumnForAlpha = firstColorColumn + 3

		if (doAlpha && neededLastColumnForAlpha <= lastColumn)
			EditorColorWave[2, rows+1][3] = w[p-2][3+firstColorColumn]*65535/highRange
		else
			doAlpha = 0
			EditorColorWave[2, rows+1][3] = 65535 // opaque
		endif
		
		EditorTextWave[][0] = num2istr(p)
		EditorTextWave[][1] = CWE_SetEditorTextForColor(w[p][firstColorColumn], w[p][firstColorColumn+1], w[p][firstColorColumn+2], SelectString(highRange == 1, "%d", "%g"), doAlpha = doAlpha, alpha = (doAlpha ? w[p][firstColorColumn+3] : 0))
		
		EditorSelWave[][][0] = 0
		EditorSelWave[][1][0] = 2//+4		// editable +4=only on double click
		EditorSelWave[][0][1] = 0
		EditorSelWave[][0][2] = 0
		EditorSelWave[][1][1] = p+2
		if (doAlpha)
			EditorSelWave[][1][2] = CWE_ReadableTextColor2(EditorColorWave[p+2][0], EditorColorWave[p+2][1], EditorColorWave[p+2][2], alpha = EditorColorWave[p+2][3]/65535)
		else
			EditorSelWave[][1][2] = CWE_ReadableTextColor2(EditorColorWave[p+2][0], EditorColorWave[p+2][1], EditorColorWave[p+2][2])
		endif
	else
		Make/O/N=(1, 2)/T root:Packages:WM_ColorWaveEditor:EditorTextWave
		Make/O/N=(1, 2, 3) root:Packages:WM_ColorWaveEditor:EditorSelWave
		Make/O/N=(2,4) root:Packages:WM_ColorWaveEditor:EditorColorWave
		Wave/T EditorTextWave = root:Packages:WM_ColorWaveEditor:EditorTextWave
		Wave EditorSelWave = root:Packages:WM_ColorWaveEditor:EditorSelWave
		Wave EditorColorWave = root:Packages:WM_ColorWaveEditor:EditorColorWave

		EditorColorWave[][3] = 65535 // opaque
		
		EditorTextWave[][0] = num2istr(p)
		EditorTextWave[][1] = "Select a color wave above"
		
		EditorSelWave[][][0] = 0
		EditorSelWave[][1][0] = 2//+4		// editable +4=only on double click
		EditorSelWave[][0][1] = 0
		EditorSelWave[][1][1] = p+1
	endif

	SetDimLabel 2,1,backColors,EditorSelWave
	SetDimLabel 2,2,foreColors,EditorSelWave
	
	Variable/G root:Packages:WM_ColorWaveEditor:savedFirstColorColumn = firstColorColumn
end
	
// return 0 to use black text, 1 to use white text for a given input rgb color
// alpha is [0,1], and assumes the color is painted over opaque white
Function CWE_ReadableTextColor2(Variable red, Variable green, Variable blue [, Variable alpha])
	if (ParamIsDefault(alpha))
		alpha = 1
	endif
	
	Variable LL, aa, bb
	Variable factor = 255/65535
	red = red*alpha + 65535*(1-alpha)
	green = green*alpha + 65535*(1-alpha)
	blue = blue*alpha + 65535*(1-alpha)
	RGB2Lab(Red*factor, Green*factor, Blue*factor, L=LL, a=aa, b=bb)
	return LL < 86 ? 1 : 0			// 86 is an empirically determined constant.
end

Function CWE_SetFirstColorColumnProc(STRUCT WMSetVariableAction & s) : SetVariableControl

	switch (s.eventCode)
		case 1:					// Documented as mouse up, but really new value
		case 2:					// Enter key
		case 3:					// Live update
			SVAR/Z SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
			if (!SVAR_Exists(SelectedItem))
				return 0
			endif
			Wave/Z selectedWave = $SelectedItem
			if (WaveExists(selectedWave))
				Variable newFirstColumnColor = floor(s.dval)
				NVAR/Z savedFirstColorColumn = root:Packages:WM_ColorWaveEditor:savedFirstColorColumn
				if ( !NVAR_Exists(savedFirstColorColumn) || (savedFirstColorColumn != newFirstColumnColor) )
					ControlInfo/W=ColorWaveEditorPanel#WaveSelectionPanel CWE_RGBRangeMenu
					Variable rangeValue = V_value
					NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
					CWE_FillEditorWaves(selectedWave, floor(s.dval), RangeMenuItemToHighRange(rangeValue), doAlpha = hasAlpha) // sets savedFirstColorColumn
				endif
			endif
			break
	endswitch
End

Function CWE_WaveHasAlphaCheckProc(s) : CheckBoxControl
	STRUCT WMCheckboxAction &s

	switch( s.eventCode )
		case 2: // mouse up
			Variable checked = s.checked
			NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
			hasAlpha = s.checked
			SVAR/Z SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
			if (!SVAR_Exists(SelectedItem))
				Checkbox $(s.ctrlName) win=$(s.win), value=0
				return 0
			endif
			Wave/Z selectedWave = $SelectedItem
			if (WaveExists(selectedWave))
				Variable lastColumn = DimSize(selectedWave, 1)-1
				NVAR firstColorColumn = root:Packages:WM_ColorWaveEditor:firstColorColumn
				Variable neededLastColumn = firstColorColumn + 2
				if( hasAlpha)
					neededLastColumn += 1
				endif
				if (neededLastColumn > lastColumn)
					String msg = "The selected wave does not have enough columns to support "
					if( hasAlpha )
						msg += "transparency or alpha colors (rgba)!"
					else
						msg += "opaque colors (rgb)!"
					endif
					DoAlert 0, msg
					Checkbox $(s.ctrlName) win=$(s.win), value=0 // alpha can't be supported, or isn't wanted.
					hasAlpha = 0
					return 0
				endif
				
				NVAR CWE_OriginallyHadAlpha = root:Packages:WM_ColorWaveEditor:CWE_OriginallyHadAlpha
				CWE_OriginallyHadAlpha = hasAlpha
				
				SetVariable CWE_SetAllAlphaSetVar, win=ColorWaveEditorPanel#WaveEditorPanel#WaveEditorControls, disable=(hasAlpha ? 0 : 2)
				
				ControlInfo/W=ColorWaveEditorPanel#WaveSelectionPanel CWE_RGBRangeMenu
				Variable rangeValue = V_value
				CWE_FillEditorWaves(selectedWave, firstColorColumn, RangeMenuItemToHighRange(V_value), doAlpha = hasAlpha)
			endif
			break
	endswitch

	return 0
End

Function/S CWE_ColorPopMenuString()

	NVAR/Z row = root:Packages:WM_ColorWaveEditor:CWE_EditMenuRow
	
	// all this complexity handles the fact that when the package first loads this may run before anything is set up
	Variable theRow
	if (!NVAR_Exists(row))
		theRow = 1
	else
		theRow = row
	endif
	Wave/Z EditorColorWave = root:Packages:WM_ColorWaveEditor:EditorColorWave
	String menustr
	if (!WaveExists(EditorColorWave))
		menustr = "*COLORPOP*"
	else
		sprintf menustr, "*COLORPOP*(%d, %d, %d)",EditorColorWave[theRow+2][0], EditorColorWave[theRow+2][1], EditorColorWave[theRow+2][2]
	endif
	
	return menustr
end

Function/S CWE_ColorPopMenuCopyString()
	String itemstr = "Copy r,g,b"
	NVAR/Z hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
	if (hasAlpha)
		itemStr = "Copy r,g,b,a"
	endif
	
	return itemStr
end

Function/S CWE_ColorPopMenuPasteString()
	String itemstr = "Paste r,g,b"
	NVAR/Z hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
	if (hasAlpha)
		itemStr = "Paste r,g,b,a"
	endif
	
	return itemStr
end

//Function/S CWE_SetAllAlphaMenuString()
//	NVAR/Z hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
//	if (hasAlpha)
//		return "Set all alpha..."
//	else
//		return ""
//	endif
//end

Function CWE_MenuNOP()
end

Function CWE_MenuSetColor()
	GetLastUserMenuInfo
	Variable red = V_red
	Variable green = V_green
	Variable blue = V_blue
	Variable alpha = V_alpha
	NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
	alpha = hasAlpha ? alpha : 65535
	NVAR row = root:Packages:WM_ColorWaveEditor:CWE_EditMenuRow
	SVAR SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
	Wave/Z selectedWave = $SelectedItem
	if (WaveExists(selectedWave))
		ControlInfo/W=ColorWaveEditorPanel#WaveSelectionPanel CWE_RGBRangeMenu
		Variable factor = RangeMenuItemToHighRange(V_value)/65535
		CWE_SetColor(row, red*factor, green*factor, blue*factor, alpha = alpha * factor)
	endif
end

Function CWE_CopyColor()
	GetLastUserMenuInfo
	NVAR row = root:Packages:WM_ColorWaveEditor:CWE_EditMenuRow
	SVAR SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
	Wave/Z selectedWave = $SelectedItem
	if (WaveExists(selectedWave))
		ControlInfo/W=ColorWaveEditorPanel#WaveSelectionPanel CWE_RGBRangeMenu
		Variable factor = RangeMenuItemToHighRange(V_value)/65535
		Wave/T listWave=root:Packages:WM_ColorWaveEditor:EditorTextWave
		PutScrapText listWave[row][1]
	endif
end

Function CWE_PasteColor()
	GetLastUserMenuInfo
	NVAR row = root:Packages:WM_ColorWaveEditor:CWE_EditMenuRow
	SVAR SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
	Wave/Z selectedWave = $SelectedItem
	if (WaveExists(selectedWave))
		ControlInfo/W=ColorWaveEditorPanel#WaveSelectionPanel CWE_RGBRangeMenu
		Variable factor = RangeMenuItemToHighRange(V_value)/65535
		string scrapText = GetScrapText()
		Variable red = str2num(StringFromList(0, scrapText, ", "))
		Variable green = str2num(StringFromList(1, scrapText, ", "))
		Variable blue = str2num(StringFromList(2, scrapText, ", "))
		NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
		if (hasAlpha)
			Variable alpha = str2num(StringFromList(3, scrapText, ","))
			CWE_SetColor(row, red, green, blue, alpha = alpha)
		else
			CWE_SetColor(row, red, green, blue)
		endif
	endif
end

//Function CWE_AllAlphaPanelf()
//	if (WinType("CWE_AllAlphaPanel") == 7)
//		DoWindow/F CWE_AllAlphaPanel
//	else
//		NewPanel /W=(150,50,449,145)
//		RenameWindow $S_name, CWE_AllAlphaPanel
//		SetDrawLayer UserBack
//		SetVariable CWE_SetAllAlphaSetVar,pos={78.00,22.00},size={126.00,14.00},bodyWidth=60
//		SetVariable CWE_SetAllAlphaSetVar,title="Alpha (0 to 1):"
//		SetVariable CWE_SetAllAlphaSetVar,limits={0,1,0.1},value= _NUM:1
//		Button CWE_SetAllAlphaDoItButton,pos={22.00,66.00},size={75.00,20.00},proc=CWE_SetAllAlphaDoItButtonProc
//		Button CWE_SetAllAlphaDoItButton,title="Set It"
//		Button CWE_SetAllAlphaCancelButton,pos={201.00,66.00},size={75.00,20.00},proc=CWE_SetAllAlphaCancelButtonProc
//		Button CWE_SetAllAlphaCancelButton,title="Cancel"
//	endif
//end

//Function CWE_SetAllAlphaDoItButtonProc(ba) : ButtonControl
//	STRUCT WMButtonAction &ba
//
//	switch( ba.eventCode )
//		case 2: // mouse up
//			ControlInfo/W=$(ba.win) CWE_SetAllAlphaSetVar
//			Variable alpha = V_value
//			SVAR SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
//			Wave/Z selectedWave = $SelectedItem
//			if (WaveExists(selectedWave))
//				ControlInfo/W=$(ba.win) CWE_SetAllAlphaSetVar
//				CWE_SetAllAlpha(V_value)
//			endif
//			Execute/P/Q "KillWindow "+ba.win
//			break
//		case -1: // control being killed
//			break
//	endswitch
//
//	return 0
//End
//
//Function CWE_SetAllAlphaCancelButtonProc(ba) : ButtonControl
//	STRUCT WMButtonAction &ba
//
//	switch( ba.eventCode )
//		case 2: // mouse up
//			KillWindow $(ba.win)
//			break
//		case -1: // control being killed
//			break
//	endswitch
//
//	return 0
//End

Function CWE_EditorListProc(LB_Struct) : ListboxControl
	STRUCT WMListboxAction &LB_Struct

	Variable red
	Variable green
	Variable blue

	if ( (LB_Struct.row < 0) || (LB_Struct.row >= DimSize(LB_Struct.listWave, 0)) )
		return 0
	endif
	switch (LB_Struct.EventCode)
		case 2:								// mouse down				
			// put up contextual menu and use ChooseColor menu
				NVAR/Z row = root:Packages:WM_ColorWaveEditor:CWE_EditMenuRow
				row = LB_Struct.row
				PopupContextualMenu/N "ColorWaveEditorMenu"
			break;
		case 4:								// selection
		case 5:								// selection with shift
			if (LB_Struct.col == 1)
				LB_Struct.selWave[LB_Struct.row][0][0] = 1
				LB_Struct.selWave[LB_Struct.row][1][0] = 2//+4		// editable +4=only on double click
			endif
			break;
		case 7:								// finish edit
			NVAR CWD_HighComponentRange = root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange
			NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
			Variable alpha = CWD_HighComponentRange
			String colorText = LB_Struct.listWave[LB_Struct.row][1]
			String colorFormat
			if (hasAlpha)
				colorFormat= SelectString(CWD_HighComponentRange == 1.0, "%d, %d, %d, %d", "%g, %g, %g, %g")
				sscanf colorText, colorFormat, red, green, blue, alpha
			else
				colorFormat= SelectString(CWD_HighComponentRange == 1.0, "%d, %d, %d", "%g, %g, %g")
				sscanf colorText, colorFormat, red, green, blue
			endif
			CWE_SetColor(LB_Struct.row, red, green, blue, alpha=alpha)
			break;
	endswitch
	
End

// alpha is [0, CWD_HighComponentRange]
Function CWE_SetColor(Variable row, Variable red, Variable green, Variable blue [, Variable alpha])
	
	SVAR SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
	Wave/Z selectedWave = $SelectedItem
	if (WaveExists(selectedWave))
		NVAR firstColorColumn = root:Packages:WM_ColorWaveEditor:firstColorColumn
		NVAR CWE_EditMenuRow = root:Packages:WM_ColorWaveEditor:CWE_EditMenuRow
		NVAR CWD_HighComponentRange = root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange
		if (ParamIsDefault(alpha))
			alpha = CWD_HighComponentRange
		endif
		NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
		Variable factor = 65535/CWD_HighComponentRange
		selectedWave[row][firstColorColumn] = red
		selectedWave[row][firstColorColumn+1] = green
		selectedWave[row][firstColorColumn+2] = blue
		if (hasAlpha)
			selectedWave[row][firstColorColumn+3] = alpha // +3 was +2 prior to 9.001
		endif
		Wave EditorColorWave = root:Packages:WM_ColorWaveEditor:EditorColorWave
		EditorColorWave[row+2][0] = red*factor
		EditorColorWave[row+2][1] = green*factor
		EditorColorWave[row+2][2] = blue*factor
		EditorColorWave[row+2][3] = hasAlpha ? alpha*factor : CWD_HighComponentRange
		Wave/T EditorTextWave = root:Packages:WM_ColorWaveEditor:EditorTextWave
		EditorTextWave[row][1] = CWE_SetEditorTextForColor(red, green, blue, SelectString(CWD_HighComponentRange == 1, "%d", "%g"), doAlpha = hasAlpha, alpha = alpha)

		Wave EditorSelWave = root:Packages:WM_ColorWaveEditor:EditorSelWave
		EditorSelWave[row][1][2] = CWE_ReadableTextColor2(red*factor, green*factor, blue*factor, alpha = alpha/CWD_HighComponentRange)
	endif
end

// *** TODO: need to set the color text in the editor wave ***

// alpha in range [0,1]
Function CWE_SetAllAlpha(Variable alpha)
	SVAR SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
	Wave/Z w = $SelectedItem
	if (WaveExists(w))
		NVAR firstColorColumn = root:Packages:WM_ColorWaveEditor:firstColorColumn
		NVAR CWD_HighComponentRange = root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange
		Variable factor = CWD_HighComponentRange		// because here alpha is always [0,1]
		w[][firstColorColumn+3] = alpha*factor
		Wave EditorColorWave = root:Packages:WM_ColorWaveEditor:EditorColorWave
		EditorColorWave[2,][3] = alpha*65535				// It's 65535 because the listbox color wave requires [0,65535]
		Wave/T EditorTextWave = root:Packages:WM_ColorWaveEditor:EditorTextWave
		EditorTextWave[][1] = CWE_SetEditorTextForColor(w[p][firstColorColumn], w[p][firstColorColumn+1], w[p][firstColorColumn+2], SelectString(CWD_HighComponentRange == 1, "%d", "%g"), doAlpha = 1, alpha = alpha*CWD_HighComponentRange)
		Wave EditorSelWave = root:Packages:WM_ColorWaveEditor:EditorSelWave
		factor = 65535/CWD_HighComponentRange			// because CWE_ReadableTextColor2 expect color components to be [0, 65535] but alpha is [0,1]. Confused yet?
		EditorSelWave[][1][2] = CWE_ReadableTextColor2(w[p][firstColorColumn]*factor, w[p][firstColorColumn+1]*factor, w[p][firstColorColumn+2]*factor, alpha = alpha)
	endif
end

Menu "CWE_ColorTableFillMenu", contextualmenu
	"*COLORTABLEPOP*", ;	
End

Function CWE_FillFromCTableMenuProc(STRUCT WMButtonAction &s) : ButtonControl
	if (s.eventCode == 2)					// mouse up
		SVAR/Z SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
		if (SVAR_exists(SelectedItem))
			Wave/Z selectedWave = $SelectedItem
		endif
		
		if (WaveExists(selectedWave))
			String menuString = "*COLORTABLEPOP*"
			PopupContextualMenu/N "CWE_ColorTableFillMenu"
			if (V_flag)
				String popstr = S_selection
				ControlInfo/W=ColorWaveEditorPanel#WaveSelectionPanel CWE_RGBRangeMenu
				Variable rangeHigh = RangeMenuItemToHighRange(V_value)
		
				ColorTab2Wave $popStr
				Wave M_colors
				NVAR firstColorColumn = root:Packages:WM_ColorWaveEditor:firstColorColumn
				NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
				Variable nNewColors = DimSize(M_colors, 0)
				Variable nUserRows = DimSize(selectedWave, 0)
				if (nNewColors == nUserRows)
					selectedWave[][firstColorColumn, firstColorColumn+2] = M_colors[p][q-firstColorColumn]
				else
					ControlInfo/W=ColorWaveEditorPanel#WaveEditorPanel#WaveEditorControls CWE_ColorTableInterpCheck
					Variable DoInterp = V_value
					Variable colorInc = nNewColors/(nUserRows-1)
					if (DoInterp)
						Variable i
						for (i = 0; i < nUserRows; i += 1)
							Variable p1 = min(floor(i*colorInc), nNewColors-1)
							Variable p2 = min(p1+1, nNewColors-1)
							Variable frac = i*colorInc - p1
							selectedWave[i][firstColorColumn, firstColorColumn+2] = ((1-frac)*M_colors[p1][q-firstColorColumn] + frac*M_colors[p2][q-firstColorColumn])*rangeHigh/65535
						endfor
					else
						selectedWave[][firstColorColumn, firstColorColumn+2] = (M_colors[min(round(p*colorInc), nNewColors-1)][q-firstColorColumn])*rangeHigh/65535
					endif
				endif
				CWE_FillEditorWaves(selectedWave, firstColorColumn, rangeHigh, doAlpha = hasAlpha)
				KillWaves/Z M_colors
			endif
		endif
	endif
End

Function CWE_RGBRangeMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR firstColorColumn = root:Packages:WM_ColorWaveEditor:firstColorColumn
	Variable/G root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange
	NVAR CWD_HighComponentRange = root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange
	CWD_HighComponentRange = RangeMenuItemToHighRange(popNum)
	NVAR CWE_OriginalHighComponentRange = root:Packages:WM_ColorWaveEditor:CWE_OriginalHighComponentRange
	CWE_OriginalHighComponentRange = CWD_HighComponentRange
	SVAR SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
	Wave/Z selectedWave = $SelectedItem
	if (WaveExists(selectedWave))
		NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
		CWE_FillEditorWaves(selectedWave, firstColorColumn, CWD_HighComponentRange, doAlpha = hasAlpha)
	endif
End

Function CWE_SetAllAlphaProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			SVAR SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
			Wave/Z selectedWave = $SelectedItem
			if (WaveExists(selectedWave))
				CWE_SetAllAlpha(sva.dval)
			endif
			break
	endswitch

	return 0
End

Function RGBChangeRangeMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
	Wave/Z selectedWave = $SelectedItem
	
	NVAR CWD_HighComponentRange = root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange

	if (WaveExists(selectedWave))
		Variable factor = RangeMenuItemToHighRange(popNum)/CWD_HighComponentRange
		NVAR firstColorColumn = root:Packages:WM_ColorWaveEditor:firstColorColumn
		NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
		Variable lastColumn = firstColorColumn + (hasAlpha ? 3 : 2)
		selectedWave[][firstColorColumn, lastColumn] *= factor
		PopupMenu CWE_RGBRangeMenu,win=ColorWaveEditorPanel#WaveSelectionPanel,mode=popNum
		CWD_HighComponentRange = RangeMenuItemToHighRange(popNum)
		CWE_FillEditorWaves(selectedWave, firstColorColumn, CWD_HighComponentRange, doAlpha = hasAlpha)
	endif	
End

Function DoneNotificationTemplate(w, colorRange)
	Wave w
	Variable colorRange

end

Function CWE_DoneButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String doneNotificationProc = GetUserData("ColorWaveEditorPanel", "", "CWE_DoneNotification")
	if (strlen(doneNotificationProc) > 0)
		NVAR CWD_HighComponentRange = root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange
		SVAR SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
		Wave/Z selectedWave = $SelectedItem
		
		FUNCREF DoneNotificationTemplate notifyFunc=$doneNotificationProc
		
		notifyFunc(selectedWave, CWD_HighComponentRange)
	endif
	
	Wave/Z w = root:Packages:WM_ColorWaveEditor:W_SelectedWaveCopy
	KillWaves/Z w
	NVAR CWE_WaveWasNew = root:Packages:WM_ColorWaveEditor:CWE_WaveWasNew
	CWE_WaveWasNew = 0
		
	DoWindow/K ColorWaveEditorPanel
End

Function CWE_UnloadPackageButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K ColorWaveEditorPanel
	Execute/P/Q/Z "DELETEINCLUDE <ColorWaveEditor>"
	Execute/P/Q/Z "COMPILEPROCEDURES "
End

Function CWE_RevertButtonProc(STRUCT WMButtonAction &s) : ButtonControl
	if (s.eventCode == 2)				// mouse up
		Wave/Z w = root:Packages:WM_ColorWaveEditor:W_SelectedWaveCopy
		SVAR SelectedItem = root:Packages:WM_ColorWaveEditor:SelectedItem
		Wave/Z selectedWave = $SelectedItem
		if (WaveExists(w) && WaveExists(selectedWave))
			Duplicate/O w, $(SelectedItem)
			Wave/Z selectedWave = $SelectedItem
			NVAR firstColorColumn = root:Packages:WM_ColorWaveEditor:firstColorColumn
			NVAR hasAlpha = root:Packages:WM_ColorWaveEditor:CWE_hasAlpha
			NVAR CWD_HighComponentRange = root:Packages:WM_ColorWaveEditor:CWD_HighComponentRange
			
			NVAR CWE_OriginalHighComponentRange = root:Packages:WM_ColorWaveEditor:CWE_OriginalHighComponentRange
			CWD_HighComponentRange = CWE_OriginalHighComponentRange

			NVAR CWE_OriginallyHadAlpha = root:Packages:WM_ColorWaveEditor:CWE_OriginallyHadAlpha
			hasAlpha = CWE_OriginallyHadAlpha
			
			// undo a change to the menu in the top of the panel that was done when the range was transformed (if it was)
			PopupMenu CWE_RGBRangeMenu,win=ColorWaveEditorPanel#WaveSelectionPanel,mode=HighValuetoRangeMenuItem(CWD_HighComponentRange)

			CWE_FillEditorWaves(selectedWave, firstColorColumn, CWD_HighComponentRange, doAlpha = hasAlpha)
			
			if (CmpStr(s.ctrlName, "CWE_CancelButton") == 0)
				KillWindow ColorWaveEditorPanel
			endif
		endif
	endif
end

Function CWE_ShowHelp(STRUCT WMButtonAction &s) : ButtonControl
	if (s.eventCode == 2)				// mouse up
		DisplayHelpTopic "Color Wave Editor"
	endif
end
