#pragma rtGlobals = 1

#pragma version = 1.01

// HR, 070511:, 1.01: Fixed issues with liberal wave names.

#include <Smooth Wave With Blanks>		// In WaveMetrics Procedures folder

//	SetPopupToMatch(panelName, popupName, popupContentsList, matchText)
//	Selects the string value of the popup menu to matchText and returns the menu item number.
//	If matchText is not a valid menu item, returns 0.
//	popupContentsList is the contents of the menu as a semicolon-separated list.
static Function SetPopupToMatch(panelName, popupName, popupContentsList, matchText)
	String panelName
	String popupName
	String popupContentsList
	String matchText
	
	Variable menuItemNumber
	menuItemNumber = WhichListItem(matchText, popupContentsList) + 1
	if (menuItemNumber <= 0)
		return 0
	endif
	PopupMenu $popupName, win=$panelName, mode=menuItemNumber
	return menuItemNumber
End

//	GetWavesTraceName(graphName, theWave, instance)
//	Returns the trace name of the wave in question. The trace name is the same as the wave name
//	EXCEPT if
//		The graph contains multiple waves in different data folders with the same name.
//	or
//		The graph contains displays the same wave more than once.
//	graphName is the name of a graph.
//	theWave is a wave reference to a wave displayed one or more times in the graph.
//	instance is the wave instance of interest. This will normally be 0. If the same wave
//	is graphed twice and you want the trace name of the second instance, pass 1.
//	If there is no trace matching the parameters, returns "".
static Function/S GetWavesTraceName(graphName, theWave, instance)
	String graphName			// Name of graph.
	Wave theWave				// The wave of interest
	Variable instance			// Instance number 
	
	String pathToWave = GetWavesDataFolder(theWave,2)
	
	String info
	String list
	Variable items
	String traceName
	Variable i
	
	list = TraceNameList(graphName, ";", 1)
	items = ItemsInList(list)
	if (items == 0)
		return ""				// No such graph or the graph contains no traces.
	endif
	
	for(i=0; i<items; i+=1)
		traceName = StringFromList(i, list)
		Wave w = TraceNameToWaveRef(graphName, traceName)
		if (CmpStr(GetWavesDataFolder(w,2), pathToWave)== 0)
			if (instance <= 0)
				return traceName
			endif
			instance -= 1
		endif
	endfor

	return ""					// Not found.
End

//	SmoothingControlPanelSourceList()
//	Returns list of traces that are candidates for smoothing.
Function/S SmoothingControlPanelSourceList()
	String graphName = WinName(0, 1)
	if (strlen(graphName) == 0)
		return ""
	endif

	String list1 = TraceNameList(graphName, ";", 1)
	String list2 = ""

	Variable i, len
	Variable items = ItemsInList(list1)
	String traceName, suffix
	
	for(i=0; i<items; i+=1)
		traceName = StringFromList(i, list1)
		
		Wave w = TraceNameToWaveRef(graphName, traceName)

		// Reject complex waves.
		if (WaveType(w) %& 1)
			continue
		endif

		// Reject multi-dimensional waves.
		if (WaveDims(w) != 1)
			continue
		endif
		
		// Exclude traces whose names end with "_sm" or  "_sm#<n>". These are destination waves.
		len = strlen(traceName)
		suffix = traceName[len-3, len-1]
		Variable pos = strsearch(traceName, "_sm", 0)
		if (pos > 0)								// Trace name contains "_sm"
			if (pos == len-3)
				continue						// Trace name ends with "_sm"
			endif
			if (CmpStr(traceName[pos+3], "#") == 0)		
				continue						// Trace name is  "_sm#<n>" (wave name plus instance)
			endif
		endif
		
		list2 += traceName + ";"
	endfor
	
	return list2
End

//	SmoothingControlPanelLimitList()
//	Returns list of maximum slider values.
Function/S SmoothingControlPanelLimitList()
	String list
	
	list = "10;25;50;100;250;500;1000;2500;5000;10000"
	return list
End

//	StoreSmoothPanelSettings(justSource)
//	Stores the state of the control panel settings in global variables in the
//	SmoothingControlPanel data folder. If justSource is set, it stores only
//	the state of the source popup menu.
static Function StoreSmoothPanelSettings(justSource)
	Variable justSource				// If true, stores source popup setting only.
	
	String savedDataFolder = GetDataFolder(1)

	String graphName = WinName(0, 1)
	if (strlen(graphName) == 0)
		return -1
	endif
	
	String sourceTrace
	ControlInfo/W=SmoothingControlPanel sourcePopup
	sourceTrace = S_value
	if (strlen(sourceTrace) == 0)
		return -1
	endif
	
	SetDataFolder root:
	NewDataFolder/O/S :Packages
	NewDataFolder/O/S :SmoothingControlPanel
	NewDataFolder/O/S :$graphName
	
	// Store the graph-specific items.
	String/G gSourceTrace = sourceTrace

	if (justSource)
		SetDataFolder savedDataFolder
		return 0
	endif

	// Store the trace-specific items.

	//	NewDataFolder/O/S :$sourceTrace	// Does not work with liberal wave names.
	String path = ":"+sourceTrace
	NewDataFolder/O/S $path				// HR, 070511: Fixed for liberal wave names.

	ControlInfo/W=SmoothingControlPanel upperLimitPopup
	Variable/G gUpperLimit = str2num(S_value)
	Variable/G root:Packages:SmoothingControlPanel:gUpperLimit = gUpperLimit	// Store new default value for future graphs.

	ControlInfo/W=SmoothingControlPanel smoothSlider
	Variable/G gNumPasses = V_value
	Variable/G root:Packages:SmoothingControlPanel:gNumPasses = gNumPasses	// Store new default value for future graphs.

	SetDataFolder savedDataFolder
End

static Function RestoreSmoothingSourcePopup(sourceStr)
	String sourceStr
	String list = SmoothingControlPanelSourceList()
	SetPopupToMatch("SmoothingControlPanel", "sourcePopup", list, sourceStr)
End

static Function RestoreSmoothingSliderLimit(limit)
	Variable limit
	
	Variable step
	switch (limit)
		default:
			step = 1
			break;
	endswitch
	Slider smoothSlider, win=SmoothingControlPanel, limits={0, limit, step}
	ControlInfo/W=SmoothingControlPanel smoothSlider
	if (V_value > limit)
		Slider smoothSlider, value=limit
	endif
End

static Function RestoreSmoothingPassesSlider(numPasses)
	Variable numPasses
	Slider smoothSlider, value=numPasses
End

static Function RestoreSmoothingUpperLimitPopup(upperLimit)
	Variable upperLimit
	String list = SmoothingControlPanelLimitList()	
	SetPopupToMatch("SmoothingControlPanel", "upperLimitPopup", list, num2str(upperLimit))
	RestoreSmoothingSliderLimit(upperLimit)
End

static Function RestoreSmoothingDestTitle()
	ControlInfo/W=SmoothingControlPanel sourcePopup
	String destStr = S_value
	if (strlen(S_value) > 0)
		destStr = destStr + "_sm"
	endif
	TitleBox destTitle, title="Dest: " + destStr
End

//	RestoreSmoothPanelSettings()
//	Called when the panel is activated, this routine attempts to restore the controls
//	to values stored for the current target graph.
static Function RestoreSmoothPanelSettings()
	String graphName = WinName(0, 1)
	if (strlen(graphName) == 0)
		return -1
	endif

	String savedDataFolder = GetDataFolder(1)

	String sourceTrace
	
	SetDataFolder root:
	NewDataFolder/O/S :Packages
	NewDataFolder/O/S :SmoothingControlPanel
	NewDataFolder/O/S :$graphName

	// Restore the graph-specific items.
	String list = SmoothingControlPanelSourceList()
	sourceTrace = StrVarOrDefault(":gSourceTrace", "")
	if ( (strlen(sourceTrace)==0) %| (strsearch(list,sourceTrace,0)<0) )
		// Source trace never stored or trace was removed from graph. Default to the first trace in the graph.
		PopupMenu sourcePopup, win=SmoothingControlPanel, mode=1
		ControlInfo/W=SmoothingControlPanel sourcePopup
		sourceTrace = S_value
		if (strlen(sourceTrace) == 0)
			SetDataFolder savedDataFolder
			return -1						// There are no traces in the graph.
		endif
	endif
	RestoreSmoothingSourcePopup(sourceTrace)
	ControlInfo/W=SmoothingControlPanel sourcePopup
	sourceTrace = S_value					// Make sure that sourceTrace is what is selected in the popup.
	if (strlen(sourceTrace) == 0)
		SetDataFolder savedDataFolder
		return -1							// Unknown problem.
	endif
	String/G gSourceTrace = sourceTrace

	RestoreSmoothingDestTitle()
	
	// Restore the trace-specific items.

	//	NewDataFolder/O/S :$sourceTrace	// Does not work with liberal wave names.
	String path = ":"+sourceTrace
	NewDataFolder/O/S $path				// HR, 070511: Fixed for liberal wave names.
		
	Variable defaultUpperLimit = NumVarOrDefault("root:Packages:SmoothingControlPanel:gUpperLimit", 100)
	Variable upperLimit = NumVarOrDefault(":gUpperLimit", defaultUpperLimit)
	Variable/G gUpperLimit = upperLimit
	RestoreSmoothingUpperLimitPopup(upperLimit)
	
	Variable defaultNumPasses = NumVarOrDefault("root:Packages:SmoothingControlPanel:gNumPasses", 3)
	Variable numPasses = NumVarOrDefault(":gNumPasses", defaultNumPasses)
	Variable/G gNumPasses = numPasses
	RestoreSmoothingPassesSlider(numPasses)

	SetDataFolder savedDataFolder
End

//	SmoothingControlPanelHook(infoStr)
//	This hook function is called by Igor when the control panel is activated or deactivated.
//	When the panel is activated, it restores controls to the appropriate state for the current
//	target graph.
Function SmoothingControlPanelHook(infoStr)
	String infoStr

	String sourceTrace

	Variable statusCode = 0
	String event = StringByKey("EVENT", infoStr)
	strswitch(event)
		case "activate":
			ControlUpdate/W=SmoothingControlPanel sourcePopup
			RestoreSmoothPanelSettings()
			break
	endswitch

	return statusCode
End

//	SmoothingControlPanelSliderProc(name, value, event)
//	Action procedure for the slider control. This is where the actual smoothing is done.
Function SmoothingControlPanelSliderProc(name, value, event)
	String name
	Variable value
	Variable event
	
	// Don't do anything if there is no source selected. Happens if there are no graphs or no waves in the active graph.
	ControlInfo sourcePopup
	if (strlen(S_value) == 0)
		return -1
	endif
	String sourceStr = S_value
	
	Variable passes = value						// Number of smoothing passes to do.
	
	String graphName = WinName(0, 1)		// Name of top graph.
	
	Wave/Z source = TraceNameToWaveRef(graphName, sourceStr)
	if (!WaveExists(source))
		return -1								// Something went wrong. The wave does not exist.
	endif
	
	// If necessary, create a new destination wave and append it to the graph.
	String savedDataFolder = GetDataFolder(1)
	SetDataFolder GetWavesDataFolder(source, 1)			// Create dest in same data folder as source.

	String destStr = NameOfWave(source) +"_sm"
	CheckDisplayed/W=$graphName $destStr
	if (V_flag == 0)										// Need to append to graph?
		Wave/Z dest = $destStr
		if ( (!WaveExists(dest)) %| (numpnts(dest)!=numpnts(source)) )	// Need to create the destination?
			Duplicate/O source, $destStr
			Wave dest = $destStr
		endif
		String info = TraceInfo(graphName, NameOfWave(source), 0)
		String xWave, xWaveDF
		String xAxis, yAxis
		xWave = StringByKey("XWAVE", info)
		xWaveDF = StringByKey("XWAVEDF", info)
		xAxis = StringByKey("XAXIS", info)
		yAxis = StringByKey("YAXIS", info)
		String axisFlags = StringByKey("AXISFLAGS", info)			// HR, 041013, 5.03B03: Fix bug if wave plotted using right or top axis.
		Variable isXY = strlen(xWave) > 0
		strswitch(axisFlags)
			case "/R":
				if (isXY)
					AppendToGraph/B=$xAxis/R=$yAxis dest vs $(xWaveDF + xWave)
				else
					AppendToGraph/B=$xAxis/R=$yAxis dest
				endif
				break

			case "/T":
				if (isXY)
					AppendToGraph/T=$xAxis/L=$yAxis dest vs $(xWaveDF + xWave)
				else
					AppendToGraph/T=$xAxis/L=$yAxis dest
				endif
				break
			
			case "/R/T":
				if (isXY)
					AppendToGraph/T=$xAxis/R=$yAxis dest vs $(xWaveDF + xWave)
				else
					AppendToGraph/T=$xAxis/R=$yAxis dest
				endif
				break
				
			default:
				if (isXY)
					AppendToGraph/B=$xAxis/L=$yAxis dest vs $(xWaveDF + xWave)
				else
					AppendToGraph/B=$xAxis/L=$yAxis dest
				endif
				break
		endswitch
		// ModifyGraph rgb($destStr) = (0, 0, 65535)		// Make smoothed trace blue.
	endif
	
	Wave dest = $destStr

	SetDataFolder savedDataFolder
	
	passes = min(passes, numpnts(source))		// Smooth complains if numPasses is too large.
	if (passes <= 0)
		dest = source
	else
		FSmoothWaveWithBlanks(source, dest, passes, 0)
	endif

	StoreSmoothPanelSettings(0)
						
	return 0
End

//	SmoothingLimitMenuProc(...)
//	Action procedure for the upper limit popup menu.
Function SmoothingLimitMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable limit = str2num(popStr)
	RestoreSmoothingSliderLimit(limit)		// Clip slider to within limit.
	StoreSmoothPanelSettings(0)
End

//	SourceMenuProc(...)
//	Action procedure for the source popup menu.
Function SourceMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	StoreSmoothPanelSettings(1)
	RestoreSmoothPanelSettings()
End

//	KillSmoothedWaveProc(ctrlName)
//	Action procedure for the Kill Dest button.
Function KillSmoothedWaveProc(ctrlName) : ButtonControl
	String ctrlName
	
	String graphName = WinName(0, 1)
	if (strlen(graphName) == 0)
		return -1								// There are no graphs.
	endif
	
	ControlInfo sourcePopup
	String sourceStr = S_value
	if (strlen(sourceStr) == 0)
		return -1								// No source is selected. There are no eligible waves in the graph.
	endif
	
	Wave/Z source = TraceNameToWaveRef(graphName, sourceStr)
	if (!WaveExists(source))
		return -1								// Something went wrong. The wave does not exist. Should not happen.
	endif

	String destStr = NameOfWave(source) +"_sm"
	Wave dest = $(GetWavesDataFolder(source,1) + destStr)
	String destTraceName = GetWavesTraceName(graphName, dest, 0)
	if (strlen(destTraceName) == 0)
		return -1								// Dest is not displayed.
	endif
	Wave/Z dest = TraceNameToWaveRef(graphName, destTraceName)
	if (!WaveExists(dest))
		return -1								// Should never happen.
	endif
	RemoveFromGraph/W=$graphName/Z $destTraceName
	KillWaves/Z dest
End

//	SmoothingControlPanel()
//	This routine creates the Smoothing control panel.
Window SmoothingControlPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(478,45,686,301) as "Smoothing"
	PopupMenu sourcePopup,pos={11,13},size={107,20},proc=SourceMenuProc,title="Source:"
	PopupMenu sourcePopup,mode=1,popvalue="data0",value= #"SmoothingControlPanelSourceList()"
	Slider smoothSlider,pos={36,111},size={57,123},proc=SmoothingControlPanelSliderProc
	Slider smoothSlider,limits={0,250,1},value= 148,ticks= 5
	PopupMenu upperLimitPopup,pos={127,110},size={51,20},proc=SmoothingLimitMenuProc
	PopupMenu upperLimitPopup,mode=5,popvalue="250",value= #"SmoothingControlPanelLimitList()"
	TitleBox destTitle,pos={25,41},size={74,12},title="Dest: data0_sm",frame=0
	TitleBox maxTitle,pos={99,113},size={23,12},title="Max:",frame=0
	GroupBox smoothingGroup,pos={15,88},size={179,156},title="Amount of Smoothing"
	Button KillDestButton,pos={26,58},size={65,20},proc=KillSmoothedWaveProc,title="Kill Dest"
	SetWindow kwTopWin,hook=SmoothingControlPanelHook
End
