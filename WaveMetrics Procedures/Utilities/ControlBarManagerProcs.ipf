#pragma rtGlobals=1		// Use modern global access method.
#pragma Version=6.1		// shipped with Igor 6.1
#pragma IgorVersion=5.00	// for ModifyControl

//*****************************************************************
// ControlBarManagerProcs.ipf
// When a package puts controls into a control bar in a graph, it risks putting those controls
// on top of any controls already in the graph. A good-citizen control bar package would
// add its controls below any that are already there, extending the control bar as necessary.
// When finished, it would remove its controls and contract the control bar.
// Further, if another package has added controls below your package's controls, those
// controls should be moved up so that they stay in the contracted control bar.
//
// This is a set of Igor functions to help you do all that.
//
// To use it, when you create your controls, first call ExtendControlBar specifying the amount of room
// you need for your controls in the extraHeight parameter.
// You must store the value passed back in CBIdentifier in a global string for later use.
//
// When your package is unloading, first remove your controls from the control bar. Then
// call ContractControlBar() specifying the CBIdentifier you saved from the call to ExtendControlBar.
// Use the extraHeight value as the value for CBDelta.
//
// For examples see AxisSlider.ipf or GraphMagnifier.ipf, both in WaveMetrics Procedures:Graphing:
// Also see Data Mask  for Fit.ipf in WaveMetrics Procedures:Analysis.
// Find WaveMetrics Procedures folder in your Igor Pro folder.
//*****************************************************************

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif


// This function extends the control bar by the amount specified by extraHeight, adding a separator to the
// control bar at the original height. The separator is given a unique name, which is returned via
// CBIdentifier. You must save the name returned in CBIdentifier in order to pass it to ContractControlBar()
// when you are ready to remove your controls from the control bar.
// Returns the old height of the control bar.
Function ExtendControlBar(WindowName, extraHeight, CBIdentifier)
	String WindowName		// window where the control bar might be (better be a graph) (if "" use top graph)
	Variable extraHeight	// additional control bar space needed
	String &CBIdentifier	// name of separator control added to control bar- use as identifier in RemoveMyControlBar()
	
	if (WinType(WindowName) != 1)
		WindowName = WinName(0, 1)
	endif
	if (WinType(WindowName) != 1)
		return -1
	endif
	Variable top = GetControlBarHeight(WindowName)
	String SeparatorName = UniqueName("CBSeparator", 15, 0, WindowName)
	GetWindow $WindowName, gsize	// points
	Variable width = (V_right-V_left)*ScreenResolution/PanelResolution(WindowName)		// v1.01 points->pixels
	GroupBox $SeparatorName, win=$WindowName, pos={0, top}, size={width, 2}
	ControlBar/W=$WindowName top+extraHeight
	CBIdentifier = SeparatorName
	return top
end

// Use this to decrease the height of the control bar when you are removing your controls. It also
// removes the separator added by ExtendControlBar(). It also finds all controls that are below the
// CBIdentifier separator and moves them up so that they will still be in the control bar when
// it is contracted.
Function ContractControlBar(WindowName, CBIdentifier, CBDelta)
	String WindowName, CBIdentifier
	Variable CBDelta
	
	variable top = 0
	ControlInfo/W=$WindowName $CBIdentifier
	if (V_flag == 9)
		top = V_top+CBDelta
		String cList = ListControlsInControlBar(WindowName, top)
		MoveControls(WindowName, cList, 0, -CBDelta)
		KillControl/W=$WindowName $CBIdentifier
	endif
	Variable CBHeight = GetControlBarHeight(WindowName)
	ControlBar/W=$WindowName max(0, CBHeight-CBDelta)
end

// Returns a standard Igor-style semicolon-separated list containing the names of controls
// that are entirely within the control bar and below a given Y position. You may find a use for it;
// it is intended for the use of ContractControlBar()
Function/S ListControlsInControlBar(WindowName, belowYPos)
	String WindowName
	Variable belowYPos		// listed controls are those inside the controlbar but the top is below this pixel
	
	if (strlen(WindowName) == 0)
		WindowName = WinName(0,1)
	endif
	if (WinType(WindowName) != 1)
		return ""
	endif
	String theList = ""
	String cList = ControlNameList(WindowName)
	String aCName
	Variable nControls = ItemsInList(cList)
	Variable i
	ControlInfo/W=$WindowName kwControlBar
	Variable aboveYPos = V_Height
	
	for (i = 0; i < nControls; i += 1)
		aCName = StringFromList(i, cList)
		ControlInfo/W=$Windowname $aCName
		if ( (V_top >= belowYPos) && (V_top+V_Height < aboveYPos) )
			theList += aCName+";"
		endif
	endfor
	
	return theList
end

// Function to move all the controls in a semicolon-separated list by an amount specified by
// XDelta and YDelta. Negative values move controls to the left or up; positive values
// move controls to right or down.
// This function is intended for use by ContractControlBar(), but you may find your own uses
// for it.
Function MoveControls(WindowName, moveCList, XDelta, YDelta)
	String WindowName
	String moveCList
	Variable XDelta, YDelta
	
	Variable i
	Variable nControls = ItemsInList(moveCList)
	String aControl
	for (i = 0; i < nControls; i += 1)
		aControl = StringFromList(i, moveCList)
		ControlInfo/W=$WindowName $aControl
		if (V_flag)
			ModifyControl/Z $aControl, win=$WindowName, pos={V_left+XDelta, V_top+YDelta}
		endif
	endfor
end

Function GetControlBarHeight(WindowName)
	String WindowName
	
	if (WinType(WindowName) != 1)
		WindowName = WinName(0, 1)
	endif
	if (WinType(WindowName) != 1)
		return 0
	endif
	ControlInfo/W=$WindowName kwControlBar
	return V_Height
end
