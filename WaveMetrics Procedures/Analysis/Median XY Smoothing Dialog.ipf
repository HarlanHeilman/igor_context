// Median XY Smoothing Dialog
#pragma rtGlobals=1
#pragma version=7			// shipped with Igor 7
#pragma IgorVersion=6.01	// requires Igor 6.01B08 for ToCommandLine operation
#pragma moduleName=WMMedian
#pragma IndependentModule=WMMedianXYIM
#include <Median>  version >=6.01, menus=0
#include <WaveSelectorWidget>  version >=1.07
#include <PopupWaveSelector> version >= 1.01
#include <SaveRestoreWindowCoords>

// Version 6.01 - First version. Jim Prouty, WaveMetrics, Inc.
// Version 6.011 - Used new ToCommandLine operation
// Version 6.02 - Revised for native GUI controls
// Version 6.1 - Now remembers the Sort settings.
// Version 7 - PanelResolution compatibility.

static StrConstant ksPanelName= "MedianXYSmoothingPanel"

// For waveform median smoothing, use Igor 6's Smooth dialog's median (/M) option.
// For image median smoothing, use MatrixFilter median or 
Menu "Analysis"
	"Median XY Smoothing",/Q, WMMedianXYIM#WMMedian#ShowMedianXYSmoothingPanel()
End

// Replace With constants
static Constant kReplaceWithMedian=1
static Constant kReplaceWithValue=2

// Output Mode constants
static Constant kOutputAuto=1
static Constant kOutputNewWave=2
static Constant kOutputSelectExisting=3

// Output Where Constants
static Constant kWhereCurrentDF=1
static Constant kWhereYWaveDF=2
static Constant kWhereSelectDF=3

// Display Where Constants
static Constant kNewGraph=1
static Constant kTopGraph=2	// item may be disabled
static Constant kNewTable=3
static Constant kTopTable=4	// item may be disabled

// Graph Layout Constants
static Constant kGraphOutputOnly=1
static Constant kGraphIOSameAxes=2
static Constant kGraphIOOppositeAxes=3
static Constant kGraphIOStackedAxes=4

Function ShowMedianXYSmoothingPanel()

	String dfSave= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WM_MedianXY

	DoWindow/F $ksPanelName
	if( V_Flag == 0 )
		// panel doesn't exist, make it
		
		// Get the last position and size of the panel
		Variable vLeft=72, vTop=54, vRight=692, vBottom=670
		WC_WindowCoordinatesGetNums(ksPanelName, vLeft, vTop, vRight, vBottom)

		// use only the saved position, not the size, converted from points to Panel Units
		Variable leftPU= vLeft/72*PanelResolution("")
		Variable topPU= vTop/72*PanelResolution("")
		Variable widthPU= (692-72)
		Variable heightPU= (670-54)

		NewPanel/K=1/N=$ksPanelName/W=(leftPU, topPU, leftPU+widthPU, topPU+heightPU) as "Median XY Smoothing"

		DefaultGuiFont/W=$ksPanelName popup={"_IgorSmall",0,0}, button={"_IgorMedium",0,0}
		ModifyPanel/W=$ksPanelName fixedSize=1, noEdit=1
		
	// Inputs
		GroupBox inputGroup,pos={5,3},size={610,308},title="Input",fStyle=1
		TitleBox xTitle,pos={126,22}, size={39,12},title="X Wave",frame=0,fStyle=1
		TitleBox yTitle,pos={432,22},size={39,12},title="Y Wave",frame=0,fStyle=1

		ListBox xInputList,pos={17,36},size={283,241}
		ListBox yInputList,pos={318,36},size={283,241}
		
		Variable/G fromTarget
		CheckBox fromTarget,pos={133,286},size={72,14},proc=WMMedian#FromTargetCheckProc,title="From target"
		CheckBox fromTarget,variable=root:Packages:WM_MedianXY:fromTarget

		PopupMenu sort, pos={410,285},title="Sort Waves By"

	// Algorithm
		GroupBox algorithmGroup,pos={5,316},size={610,70},title="Algorithm",fStyle=1
		
		Variable/G xWidth
		SetVariable xWidth,pos={39,338}, size={220,15},proc=WMMedian#AlgorithmSetVarProc,title="Compute Median over X Range:"
		SetVariable xWidth,value= root:Packages:WM_MedianXY:xWidth,bodyWidth= 80, limits={0,inf,0}

		Variable/G threshold
		SetVariable threshold,pos={130,362}, size={130,15},proc=WMMedian#AlgorithmSetVarProc,title="Threshold:"
		SetVariable threshold,limits={0,inf,0},value= root:Packages:WM_MedianXY:threshold,bodyWidth= 80

		Variable mode=NumVarOrDefault("root:Packages:WM_MedianXY:replaceWithItem",kReplaceWithMedian) 
		Variable/G replaceWithItem= mode
		PopupMenu replaceWith,pos={265,337}, size={241,17},proc=WMMedian#ReplaceWithPopMenuProc,title="Replace values exceeding Threshold with:"
		PopupMenu replaceWith,mode=mode,value= #"\"Median;Replacement Value;\""

		Variable val= NumVarOrDefault("root:Packages:WM_MedianXY:replacementValue", NaN)
		Variable/G replacementValue=val
		SetVariable replacementValue,pos={396,360},size={171,15},proc=WMMedian#AlgorithmSetVarProc,title="Replacement Value:"
		SetVariable replacementValue,limits={-inf,inf,0},value= root:Packages:WM_MedianXY:replacementValue,bodyWidth= 80
		SetVariable replacementValue, disable=(mode == kReplaceWithValue) ? 0 : 1
	
	// Outputs
		GroupBox outputGroup,pos={5,389},size={610,70},title="Output",fStyle=1
		//  Popup selector:
		//	1) Auto create a new wave Name	from input selection, show the name in a disabled edit box
		//	2) Create with a given Name, show current name in enabled edit box
		//	3) Select an existing wave (OutputPopupWaveSelector)
		//
		// kOutputAuto=1
		// kOutputNewWave=2
		// kOutputSelectExisting=3

		mode=NumVarOrDefault("root:Packages:WM_MedianXY:outputMode",kOutputAuto)
		Variable/G outputMode= mode
		PopupMenu outputMode title="Output Wave:"
		PopupMenu outputMode,pos={18,410}, size={112,17},proc=WMMedian#OutputTypePopMenuProc
		PopupMenu outputMode,mode=mode,value= #"\"Auto;Make New Wave;Select Existing Wave;\""
		
		// Select Existing Wave
		String/G existingOutputWaveName	// for display in the control
		String/G existingOutputWavePath	// to remember the selected wave for the next invocation of the panel
		SetVariable OutputPopupWaveSelector,pos={227,411},size={150,15},title=" "
		SetVariable OutputPopupWaveSelector,bodyWidth= 150
		
		// Make New Output Wave Name
		String lastYWaveName=StrVarOrDefault("root:Packages:WM_MedianXY:lastMedianYOutputWave", "medianWave")
		String/G lastMedianYOutputWave=lastYWaveName	//  name only: for display and for next invocation of panel
		SetVariable outputWaveName,pos={49,436},size={202,15},proc=WMMedian#OutputWaveNameSetVarProc,title="Name:"
		SetVariable outputWaveName,value= root:Packages:WM_MedianXY:lastMedianYOutputWave,bodyWidth= 170
		
		// Auto name
		TitleBox autoName, pos={49,437},size={69,12}, frame=0, title="Name: "
		
		// Output where popup
		Variable where= NumVarOrDefault("root:Packages:WM_MedianXY:makeWhere", kWhereCurrentDF)
		Variable/G makeWhere=where	// popup menu item number for next invocation of panel
		PopupMenu makeWhere,pos={194,410},size={144,17},proc=WMMedian#OutputWherePopMenuProc,title="Where:"
		PopupMenu makeWhere,mode=where,value= #"\"Current Data Folder;Y Wave Data Folder;Select Data Folder;\""

		// output data folder browser (must be quite long: it holds the full path)
		String/G outputDataFolder	// to remember the selected wave for the next invocation of the panel
		SetVariable outputDataFolder,pos={350,412},size={220,15},bodyWidth= 220, title=" "
		
	// Display
		// Display Group Checkbox
		GroupBox displayGroup,pos={5,466},size={610,48},title="                           "
		GroupBox displayGroup,fStyle=1
		Variable/G displayOutputWaveCheck
		CheckBox displayOutputWaveCheck,pos={21,466},size={16,14},proc=WMMedian#DisplayOutputWaveCheckProc,title="Display Output Wave"
		CheckBox displayOutputWaveCheck,variable= root:Packages:WM_MedianXY:displayOutputWaveCheck

		//	 Popup: in new graph, in top graph, etc.
		// An old choice may now be invalid (if a top graph or top table goes away)
		where= NumVarOrDefault("root:Packages:WM_MedianXY:displayWhere", kNewGraph)
		switch(where)
			case kTopGraph:
				if( strlen(WinName(0,1)) == 0 )
					where= kNewGraph
				endif
				break
			case kTopTable:
				if( strlen(WinName(0,2)) == 0 )
					where= kNewTable
				endif
				break
		endswitch
		Variable/G displayWhere= where
		PopupMenu displayWhere,pos={20,488},size={75,17},proc=WMMedian#DisplayWherePopMenuProc
		
		// PopupMenu displayWhere,mode=displayWhere,value= WMMedian#DisplayWhereMenu()
		String popFunc= GetIndependentModuleName()+"#WMMedian#DisplayWhereMenu()"
		PopupMenu displayWhere,mode=displayWhere,value=#popFunc	// requires Igor 6 12/6/06 to work

		// New graph layout
		Variable gl= NumVarOrDefault("root:Packages:WM_MedianXY:newGraphLayout", kGraphOutputOnly)
		Variable/G newGraphLayout= gl
		PopupMenu graphLayout,pos={125,488},size={141,17},proc=WMMedian#GraphLayoutPopMenuProc,title="Graph Layout"
		PopupMenu graphLayout,mode=newGraphLayout,value= #"\"Output Only;Input and Output, Same Axes;Input and Output, Opposite Axes;Input and Output, Stacked Axes;\""

		// Popup axis (vertical)
		String topGraphAxes= HVAxisList(WinName(0,1),0)	// can be ""
		String axis= StrVarOrDefault("root:Packages:WM_MedianXY:topGraphVAxis", "")
		Variable whichItem= WhichListItem(axis,topGraphAxes)
		if( whichItem < 0 )
			whichItem= 0	// default to the first one.
		endif
		String/G topGraphVAxis=StringFromList(whichItem, topGraphAxes)
		mode= 1+whichItem
		PopupMenu vAxis,pos={130,488},size={80,17},proc=WMMedian#VAxisPopMenuProc,title="V Axis:"
		popFunc= GetIndependentModuleName()+"#WMMedian#HVAxisList(WinName(0,1),0)"
		//PopupMenu vAxis,mode=mode,value=WMMedian#HVAxisList(WinName(0,1),0)
		PopupMenu vAxis,mode=mode,value=#popFunc	// requires Igor 6 12/6/06 to work

		// Popup axis (horizontal)
		topGraphAxes= HVAxisList(WinName(0,1),1)	// can be ""
		axis= StrVarOrDefault("root:Packages:WM_MedianXY:topGraphHAxis", "")
		whichItem= WhichListItem(axis,topGraphAxes)
		if( whichItem < 0 )
			whichItem= 0	// default to the first one.
		endif
		String/G topGraphHAxis=StringFromList(whichItem, topGraphAxes)
		mode= 1+whichItem
		PopupMenu hAxis,pos={280,488},size={80,17},proc=WMMedian#HAxisPopMenuProc,title="H Axis:"
		popFunc= GetIndependentModuleName()+"#WMMedian#HVAxisList(WinName(0,1),1)"
		//PopupMenu hAxis,mode=mode,value= WMMedian#HVAxisList(WinName(0,1),1)
		PopupMenu hAxis,mode=mode,value=#popFunc	// requires Igor 6 12/6/06 to work

	// command
		Make/O/T/N=1 commands
		ListBox commands,pos={6,522},size={610,60}, mode=0,row=0,listWave=root:Packages:WM_MedianXY:commands
	
	// Do It, etc buttons
		Button doit,pos={28,590},size={80,20},proc=WMMedian#MedianXYButtonsProc,title="Do It"
		Button toCmdLine,pos={127,590},size={100,20},proc=WMMedian#MedianXYButtonsProc,title="To Cmd Line"
		Button toClip,pos={247,590},size={80,20},proc=WMMedian#MedianXYButtonsProc,title="To Clip"
		Button cancel,pos={505,590},size={80,20},proc=WMMedian#MedianXYButtonsProc,title="Cancel"

		// setup the lists, sort, and from target controls

		String options= "DIMS:1,TEXT:0"	// 1-d numeric waves only
		MakeListIntoWaveSelector(ksPanelName, "xInputList", content = WMWS_Waves, selectionMode=WMWS_SelectionSingle, listoptions=options, nameFilterProc="WMMedian#ApproveInput")
		String/G lastMedianXInputWave
		WS_SetNotificationProc(ksPanelName, "xInputList", "WMMedian#MedianXYInputXNotification")
		WS_SelectAnObject(ksPanelName, "xInputList", lastMedianXInputWave, OpenFoldersAsNeeded=1)

		MakeListIntoWaveSelector(ksPanelName, "yInputList", content = WMWS_Waves, selectionMode=WMWS_SelectionSingle, listoptions=options, nameFilterProc="WMMedian#ApproveInput")
		String/G lastMedianYInputWave
		WS_SetNotificationProc(ksPanelName, "yInputList", "WMMedian#MedianXYInputYNotification")
		WS_SelectAnObject(ksPanelName, "yInputList", lastMedianYInputWave, OpenFoldersAsNeeded=1)

		// For Select Existing Wave
		SVAR ow=root:Packages:WM_MedianXY:existingOutputWavePath
		MakeSetVarIntoWSPopupButton(ksPanelName, "OutputPopupWaveSelector", "WMMedian#OutputPopupWaveSelectorNotify", "root:Packages:WM_MedianXY:existingOutputWaveName", initialSelection= ow)

		SVAR odf=root:Packages:WM_MedianXY:outputDataFolder
		MakeSetVarIntoWSPopupButton(ksPanelName, "outputDataFolder", "WMMedian#OutputDataFolderSelectorNotify", "root:Packages:WM_MedianXY:outputDataFolder", initialSelection= odf, content=WMWS_DataFolders)

		// This function does all the work of making a PopupMenu control into a wave sorting control
		MakePopupIntoWaveSelectorSort(ksPanelName, "xInputList", "sort")
		MakePopupIntoWaveSelectorSort(ksPanelName, "yInputList", "sort")

		Variable sortKind= NumVarOrDefault("root:Packages:WM_MedianXY:sortKind",0)
		Variable sortReverse= NumVarOrDefault("root:Packages:WM_MedianXY:sortReverse",0)
		WS_SetGetSortOrder(ksPanelName, "sort", sortKind, sortReverse)

		SetWindow $ksPanelName hook(WMMedianXY)=WMMedianXYIM#WMMedian#MedianXYWindowHook
	endif
	SetDataFolder dfSave
	
	UpdatePanel()	// output mode, mostly. Also calls PrintEqn

End

static Function MedianXYWindowHook(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	
	strswitch( s.eventName )
		case "kill":
			WC_WindowCoordinatesSave(s.winName)
			Variable sortKind= -1, sortReverse= -1	// get the values
			WS_SetGetSortOrder(ksPanelName, "sort", sortKind, sortReverse)
			Variable/G root:Packages:WM_MedianXY:sortKind= sortKind
			Variable/G root:Packages:WM_MedianXY:sortReverse= sortReverse
	endswitch

	return statusCode
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility between Igor 6 and 7
	String wName
	return 72
End
#endif

static Function OutputDataFolderSelectorNotify(event, path, windowName, ctrlName)
	Variable event
	String path
	String windowName
	String ctrlName
	
	PrintEqn()
end


static Function MedianXYButtonsProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			SVAR cmd=root:Packages:WM_MedianXY:command
			strswitch(ba.ctrlName)
				case "doit":
					Execute/P/Z cmd
					break
				case "toCmdLine":
//					String oldScrap= GetScrapText()
//					PutScrapText cmd
//					DoWindow/F/H
//					DoIgorMenu "Edit", "Paste"
//					PutScrapText oldScrap
					ToCommandLine cmd	// requires 6.01B08
					Execute/P/Q/Z "DoWindow/F/H"
					break
				case "toClip":
					PutScrapText cmd
					break
				case "cancel":
					break
			endswitch		
			Execute/P/Q/Z "DoWindow/K "+ksPanelName
			break
	endswitch

	return 0
End

static Function OutputTypePopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable/G root:Packages:WM_MedianXY:outputMode= pa.popNum
			UpdatePanel()
			break
	endswitch

	return 0
End

static Function/S AutoName()

	String name=""
	String yWavePath= StringFromList(0,WS_SelectedObjectsList(ksPanelName, "yInputList"))	// can be ""
	WAVE/Z wy=$yWavePath
	if( WaveExists(wy) )
		name= NameOfWave(wy)[0,26]+"_med"
	endif			

	return name
End

static Function UpdatePanel()
		// mostly for the currently selected output and display modes, hide and show controls appropriately
	ControlInfo/W=$ksPanelName outputMode
	Variable mode= V_value
	Variable OutputPopupWaveSelectorDisable=1	// hide
	Variable outputWaveNameDisable=1				// hide
	Variable autoNameDisable=1				// hide
	Variable wherePopupDisable=0					//show
	switch( mode )
		case  kOutputAuto:
			// update the output wave name
			TitleBox autoName, win=$ksPanelName, title="Name: "+AutoName()
			autoNameDisable=0	// show
			break
		case  kOutputNewWave:
			outputWaveNameDisable=0	// show, enabled
			break
		case  kOutputSelectExisting:
			OutputPopupWaveSelectorDisable=0	// show
			wherePopupDisable=1				// hide
			break
	endswitch
	ModifyControl makeWhere, win=$ksPanelName, disable= wherePopupDisable

	// Until there's a way to recover the wave popup button's name, we just use the observed name.
	ModifyControlList "OutputPopupWaveSelector;PopupWS_Button0;", win=$ksPanelName, disable= OutputPopupWaveSelectorDisable

	ModifyControl outputWaveName, win=$ksPanelName, disable= outputWaveNameDisable
	ModifyControl autoName, win=$ksPanelName, disable= autoNameDisable
	
	Variable OutputPopupDFSelectorDisable=1	// hide
	if( wherePopupDisable == 0 )
		ControlInfo/W=$ksPanelName makeWhere
		Variable where= V_value
		switch( where )
			case  kWhereCurrentDF:
				break
			case  kWhereYWaveDF:
				break
			case  kWhereSelectDF:
				OutputPopupDFSelectorDisable=0	// show
				break
		endswitch
	endif
	// Until there's a way to recover the wave popup button's name, we just use the observed name.
	ModifyControlList "outputDataFolder;PopupWS_Button1;", win=$ksPanelName, disable= OutputPopupDFSelectorDisable
	
	// display group
	
	ControlInfo/W=$ksPanelName displayOutputWaveCheck
	Variable disableValueIfShowing= V_Value ? 0 : 2	// enabled or disabled; additionally some items will be hidden (disable=1)

	ModifyControl displayWhere,win=$ksPanelName, disable=disableValueIfShowing	// this control is always showing
	
	// other controls are shown or hidden based on control values
	Variable disableGraphLayout=1	// hidden
	Variable disableAxes=1
	ControlInfo/W=$ksPanelName displayWhere
	switch(V_value)
		case kNewGraph:
			disableGraphLayout= disableValueIfShowing
			break
		case kTopGraph:
			disableAxes= disableValueIfShowing
			break
	endswitch

	ModifyControl graphLayout,win=$ksPanelName, disable=disableGraphLayout
	ModifyControlList "vAxis;hAxis;" ,win=$ksPanelName, disable=disableAxes
	
	PrintEqn()
End


static Function OutputWherePopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable/G root:Packages:WM_MedianXY:makeWhere= pa.popNum
			// hide or show data folder widgets.
			UpdatePanel()
			break
	endswitch

	return 0
End

static Function OutputWaveNameSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			String sval = sva.sval
			UpdatePanel()
			break
	endswitch

	return 0
End
 
// generate the command(s) or error status
static Function PrintEqn()

	// first, check for errors
	String xWavePath= StringFromList(0,WS_SelectedObjectsList(ksPanelName, "xInputList"))	// can be ""
	String yWavePath= StringFromList(0,WS_SelectedObjectsList(ksPanelName, "yInputList"))	// can be ""

	WAVE/Z wx=$xWavePath
	WAVE/Z wy=$yWavePath
	NVAR xwidth=root:Packages:WM_MedianXY:xWidth
	
	String status=""
	// check input waves
	if( !WaveExists(wx) )
		if( !WaveExists(wy) )
			status="(select an X and a Y wave)"
		else
			status="(select an X wave)"
		endif
	elseif( !WaveExists(wy) )
		status="(select a Y wave)"
	elseif( numpnts(wx) != numpnts(wy) )
		status= "Expected waves of same length: X wave is "+num2istr(numpnts(wx))+", Y wave is "+num2istr(numpnts(wy))+" points."
	// check x width
	elseif( xWidth <= 0 )
		status= "Enter X Range > 0"
	endif
	Variable enableDoit= strlen(status)==0
	// the threshold is limited to valid ranges by the SetVariable control
	// the replacement value can be anything including a NaN, so it needs no checking.	
	if( enableDoit )
		// generate command (or status) here. Set enableDoit=0 if error status
		String cmd
	
		// output wave name
		WAVE/Z existingOutputWave= $PopupWS_GetSelectionFullPath(ksPanelName, "OutputPopupWaveSelector")
		ControlInfo/W=$ksPanelName outputMode
		Variable mode= V_value
		String nameOfMedianYWave=""
		switch( mode )
			case  kOutputAuto:
				nameOfMedianYWave= AutoName()
				break
			case  kOutputNewWave:
				nameOfMedianYWave= StrVarOrDefault("root:Packages:WM_MedianXY:lastMedianYOutputWave","")
				break
			case  kOutputSelectExisting:
				if( WaveExists(existingOutputWave) )
					nameOfMedianYWave= NameOfWave(existingOutputWave)
				endif
				break
		endswitch
		if( strlen(nameOfMedianYWave) == 0 )
			if( mode == kOutputSelectExisting )
				status= "Select an existing wave."
			else
				status= "Enter a wave name"
			endif
			enableDoit= 0
		endif
				
		// output wave data folder
		ControlInfo/W=$ksPanelName makeWhere
		Variable where= V_value
		String df= GetDataFolder(1)
		switch( where )
			case  kWhereCurrentDF:
				break
			case  kWhereYWaveDF:
				if( WaveExists(wy) )
					df= GetWavesDataFolder(wy,1)
				endif
				break
			case  kWhereSelectDF:
				String selDF= PopupWS_GetSelectionFullPath(ksPanelName, "outputDataFolder")
				if( strlen(selDF) == 0 )
					status= "Select an output data folder."
					enableDoit= 0
				else
					selDF= RemoveEnding(selDF,":")+":"
					if( DataFolderExists(selDF) )
						df= selDF
					endif
				endif
				break
		endswitch

		// generate path to output
		String outputPath= RemoveEnding(df,":")+":"+PossiblyQuoteName(nameOfMedianYWave)
		outputPath= GenRelativePath(outputPath)
		String pathToX=GetWavesDataFolder(wx,4)
		String pathToY=GetWavesDataFolder(wy,4)

		NVAR threshold=root:Packages:WM_MedianXY:threshold
		Variable replacementMode=NumVarOrDefault("root:Packages:WM_MedianXY:replaceWithItem",kReplaceWithMedian) 
		NVAR replacementValue=root:Packages:WM_MedianXY:replacementValue
		
		String routine=GetIndependentModuleName()+"#MedianXY"
		
		if( replacementMode == kReplaceWithValue )
			if( threshold == 0 )
				status= "Using a Threshold == 0 would replace all values with "+num2str(replacementValue)+". Enter a larger value."
				enableDoit= 0
			else
				sprintf cmd, "%s(%s,%s,%g,\"%s\", threshold=%g, replacementValue=%g)",routine,pathToX, pathToY, xwidth, outputPath,threshold,replacementValue
			endif
		else	// kReplaceWithMedian
			if( threshold == 0 )
				sprintf cmd, "%s(%s,%s,%g,\"%s\")",routine,pathToX, pathToY, xwidth, outputPath
			else
				sprintf cmd, "%s(%s,%s,%g,\"%s\",threshold=%g)",routine,pathToX, pathToY, xwidth, outputPath,threshold
			endif
		endif
	endif
	
	// Display
	NVAR displayOutputWaveCheck= root:Packages:WM_MedianXY:displayOutputWaveCheck
	if( enableDoit && displayOutputWaveCheck && strlen(outputPath) && strlen(pathToX) )
		// append display commands
		cmd += ";DelayUpdate\r"
		ControlInfo/W=$ksPanelName displayWhere
		Variable displayWhere= V_value
		switch(displayWhere)
			case kNewGraph:
				ControlInfo/W=$ksPanelName graphLayout
				Variable newGraphLayout= V_value
				switch(newGraphLayout)
					case kGraphOutputOnly:
						cmd += "Display "+outputPath+" vs "+pathToX+";DelayUpdate\r"
						break
					case kGraphIOSameAxes:
						cmd += "Display "+pathToY+" vs "+pathToX+";DelayUpdate\r"
						cmd += "AppendToGraph "+outputPath+" vs "+pathToX
						break
					case kGraphIOOppositeAxes:
						cmd += "Display "+pathToY+" vs "+pathToX+";DelayUpdate\r"
						cmd += "AppendToGraph/R "+outputPath+" vs "+pathToX
						break
					case kGraphIOStackedAxes:
						cmd += "Display "+pathToY+" vs "+pathToX+";DelayUpdate\r"
						cmd += "AppendToGraph/L=output "+outputPath+" vs "+pathToX+";DelayUpdate\r"
						cmd += "ModifyGraph standoff=0, freePos=0,axisEnab(left)={0,0.45},axisEnab(output)={0.55,1}"
						break
				endswitch	
				break
				
			case kTopGraph:
				String topGraph=WinName(0,1)
				// axes
				ControlInfo/W=$ksPanelName vAxis
				String vAxis= S_value
				String vAxFlag= StringByKey("AXFLAG",AxisInfo(topGraph,vAxis))
		
				ControlInfo/W=$ksPanelName hAxis
				String hAxis= S_value
				String hAxFlag= StringByKey("AXFLAG",AxisInfo(topGraph,hAxis))
		
				cmd += "AppendToGraph"+vAxFlag+hAxFlag+" "+outputPath+" vs "+pathToX
				break
				
			case kNewTable:
				cmd += "Edit "+outputPath
				break
				
			case kTopTable:
				cmd += "AppendToTable "+outputPath
				break
		endswitch
	endif
	
	Variable fstyle, red
	if( enableDoit )
		fstyle=0	// plain
		red=0		// black
	else
		cmd= status
		fstyle=1	// bold
		red= 65535	// red
	endif

	String/G root:Packages:WM_MedianXY:command= cmd

	Variable rows= ItemsInList(cmd,"\r")
	Make/O/T/N=(rows,1) root:Packages:WM_MedianXY:commands= StringFromList(p,cmd,"\r")
	
	// set the text (foreground) color
	Make/O/B/U/N=(rows,1,2) root:Packages:WM_MedianXY:selWave =0
	Wave sw=root:Packages:WM_MedianXY:selWave
	SetDimLabel 2,1,foreColors,sw			// define plane/layer 0 as foreground colors
	sw[][][%foreColors]= 1					// color index values; because an index of 0 is special we need to set this to at least 1. That means two rows in the color wave (the first row - row 0 - is ignored).
	Make/O/N=(2,3) root:Packages:WM_MedianXY:colorWave=0
	Wave cw=root:Packages:WM_MedianXY:colorWave
	cw[1][0]=red

	ListBox commands,win=$ksPanelName,fstyle=fstyle,colorWave= cw, selWave=sw
	
	ModifyControlList "doit;toCmdLine;toClip;", win=$ksPanelName, disable= (enableDoit ? 0 : 2)
End

static Function/S GenRelativePath(path)
	String path
	
	String currentDF= GetDataFolder(1)
	if( strsearch(path, currentDF, 0) == 0 )
		path[0,strlen(currentDF)-1]=""
		if( strsearch(path,":",0) > 0 )
			path[0]=":"
		endif
	endif
	
	return path
End	

static Function OutputPopupWaveSelectorNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName

	SVAR path= root:Packages:WM_MedianXY:existingOutputWavePath
	path= wavepath
	UpdatePanel()
end

static Function MedianXYInputXNotification(SelectedItem, EventCode)
	String SelectedItem		// string with full path to the item clicked on in the wave selector
	Variable EventCode		// the ListBox event code that triggered this notification

	switch( EventCode )
		case WMWS_SelectionChanged:
			SVAR path= root:Packages:WM_MedianXY:lastMedianXInputWave
			path= SelectedItem
			UpdatePanel()
			break
	endswitch
End

static Function MedianXYInputYNotification(SelectedItem, EventCode)
	String SelectedItem		// string with full path to the item clicked on in the wave selector
	Variable EventCode		// the ListBox event code that triggered this notification

	switch( EventCode )
		case WMWS_SelectionChanged:
			SVAR path= root:Packages:WM_MedianXY:lastMedianYInputWave
			path= SelectedItem
			UpdatePanel()
			break
	endswitch
End

static Function WaveDisplayedInTarget(w)
	Wave w
	
	String target= WinName(0,1+2,1)	// topmost visible graph or table
	CheckDisplayed/W=$target  w
	return V_Flag 
End

static Function ApproveInput(theNameWithPath, ListContents)
	String theNameWithPath
	Variable ListContents
	
	Wave/Z w= $theNameWithPath
	Variable isOK= WaveExists(w)
	if( isOK )
		ControlInfo/W=$ksPanelName fromTarget
		if( V_Value )
			isOK = WaveDisplayedInTarget(w)
		endif
	endif
	return isOK
end

static Function ApproveOutput(theNameWithPath, ListContents)
	String theNameWithPath
	Variable ListContents
	
	Wave/Z w= $theNameWithPath
	Variable isOK= WaveExists(w)
	if( isOK )
		ControlInfo/W=$ksPanelName fromTarget
		if( V_Value )
			isOK = WaveDisplayedInTarget(w)
		endif
	endif
	return isOK
end

static Function FromTargetCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			WS_UpdateWaveSelectorWidget(ksPanelName, "xInputList")
			WS_UpdateWaveSelectorWidget(ksPanelName, "yInputList")
			break
	endswitch

	return 0
End


static Function/S DisplayWhereMenu()

	String disable="\\M1("
	String menulist="New Graph;"
	String topGraph= WinName(0,1)
	if( strlen(topGraph) == 0 )
		menulist += disable
	endif
	menulist += "Top Graph;New Table;"
	String topTable=WinName(0,2)
	if( strlen(topTable) == 0 )
		menulist += disable
	endif
	menulist += "Top Table;"

	return menulist
End

// Returns the standard  axes (left;right; or top;bottom;) and any axes actually in the graph.
// Set wantStandard=0 to include only existing axes.
static Function/S HVAxisList(graphName,wantHorizAxes[,wantStandard])
	String graphName	// "" not supported as top graph name; use WinName(0,1) instead. "" means there *is* no top graph
	Variable wantHorizAxes,wantStandard
	
	String hvlist=""
	if( ParamIsDefault(wantStandard) )
		wantStandard=1
	endif
	
	if( strlen(graphName) )
		DoWindow $graphName
		if( V_Flag )
			String standardAxes="left;right;bottom;top;"
			if( wantStandard) 
				if( wantHorizAxes )
					hvlist="bottom;top;"
				else
					hvlist="left;right;"
				endif
			endif
			String axlist=AxisList(graphName)
			Variable index=0
			do
				String axis= StringFromList(index,axlist)
				if (strlen(axis) == 0)
					break								// ran out of items
				endif
				Variable isStandardAxis= wantStandard && WhichListItem(axis,standardAxes)>=0
				String info=AxisInfo(graphName,axis)
				if( (!isStandardAxis) && AxisOrientation(info,wantHorizAxes) )
					hvlist += axis + ";"
				endif
				index += 1
			while (1)		// loop until break above
		endif
	endif
	return hvlist
End

// Returns 1 if axis has desired orientation, else returns 0
static Function AxisOrientation(axInfo,wantHorizAxes)
	String axInfo	// AxisInfo
	Variable wantHorizAxes

	if( wantHorizAxes )
		if( strsearch(axInfo,"AXTYPE:bottom;",0) < 0 )
			if( strsearch(axInfo,"AXTYPE:top;",0) < 0 )
				return 0
			endif
		endif
	else
		if( strsearch(axInfo,"AXTYPE:left;",0) < 0 )
			if( strsearch(axInfo,"AXTYPE:right;",0) < 0 )
				return 0
			endif
		endif
	endif

	return 1
End



static Function ReplaceWithPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable/G root:Packages:WM_MedianXY:replaceWithItem= pa.popNum
			ModifyControl replacementValue, win=$ksPanelName, disable=(pa.popNum == kReplaceWithValue) ? 0 : 1
			PrintEqn()
			break
	endswitch

	return 0
End

static Function AlgorithmSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			PrintEqn()
			break
	endswitch

	return 0
End

// Display output group

static Function DisplayOutputWaveCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			UpdatePanel()
			break
	endswitch

	return 0
End

static Function DisplayWherePopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable/G root:Packages:WM_MedianXY:displayWhere= pa.popNum
			UpdatePanel()
			break
	endswitch

	return 0
End

static Function GraphLayoutPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable/G root:Packages:WM_MedianXY:newGraphLayout= pa.popNum
			PrintEqn()
			break
	endswitch

	return 0
End


static Function VAxisPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			String/G root:Packages:WM_MedianXY:topGraphVAxis= pa.popStr
			PrintEqn()
			break
	endswitch

	return 0
End

static Function HAxisPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			String/G root:Packages:WM_MedianXY:topGraphHAxis= pa.popStr
			PrintEqn()
			break
	endswitch

	return 0
End
