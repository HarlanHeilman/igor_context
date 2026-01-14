#pragma rtGlobals=1		// Use modern global access method.
#pragma version=7	// shipped with Igor 7
#pragma IgorVersion=6.1
#pragma moduleName=ResizeControls

//	The ResizeControlsPanel procedure implements the resize behavior of individual controls in panel.
//	When the panel is resized, each edge of each control is (optionally) moved or resized
//	according to the selected mode.
//
//	Controls can be moved relative to the panel's or subwindows' edges,
//	or relative to user guides.
//
//	A table-like editor of these behaviors is implemented by
//		#include <Resize Controls Panel>
//
//	After including Resize Controls Panel.ipf,
//	call the ShowResizeControlsPanel() function to display the editor
//	or choose "Edit Controls Resized Positions" from Igor's Panel menu.
//
// NOTE: 
//		Control resizing information is stored in each control's userData(ResizeControlsInfo),
//		and the window resizing information is stored in the panel's userData(ResizeControlsInfo)
//
//	Revision History:
//		JP090429, version 6.1B07 (initial version)
//		JP090612, version 6.1 (initial release) - Fixed FitControlsToPanel bug: didn't grow controls vertically.
//		JP091022, version 6.12 -  ListOfChildWindows now returns only windows that can contain controls,
//				ResizeControlsHook no longer prevents other resize hooks from being called.
//		JP091201, version 6.13 -  Uses different technique for enforcing minimum size to avoid multiple Execute/P commands
//		JP100922, version 6.20 -  Revised comments.
//		JP160216, version 6.38 -  added Same Width, Same Height, % Width and % Height options.
//		JP160218, version 6.381 -  Fixed bug in FitControlsToPanel if everything used % Width or % Height
//		JP160411, version 7 -  Works with Igor 7's PanelResolution, optionally uses the new SetWindow win sizeLimit feature.
//		JP160523, version 7 - bug fixes for subwindow resizing.

// ++++++++ Public Constants

StrConstant ksResizeUserDataName= "ResizeControlsInfo"

StrConstant ksFixedFromLeft = "Left"	// aka "Panel Left"
StrConstant ksFixedFromMiddle= "Middle"
StrConstant ksFixedFromRight= "Right"
StrConstant ksFixedFromPctWidth= "% Width"	// % width of window, not % width of control.
StrConstant ksSameWidth= "Same Width"

StrConstant ksFixedFromTop = "Top"
StrConstant ksFixedFromCenter= "Center"
StrConstant ksFixedFromBottom= "Bottom"
StrConstant ksFixedFromPctHeight= "% Height"	// % height of window, not % height of control.
StrConstant ksSameHeight= "Same Height"

// ++++++++ Public Structures

Constant kCurrentResizeInfoVersion= 1

Structure WMResizeInfo
	int16	version			// usually kCurrentResizeInfoVersion

	// saved control or panel position in panel coordinates (same as control coordinates) which could be either points or pixels
	float	originalLeft
	float	originalTop
	float	originalWidth
	float	originalHeight
	
	int16	fixedWidth	// boolean for panel resize hook
	int16	fixedHeight	// boolean for panel resize hook
	
	// how to adjust each control edge after panel resize
	char	leftMode[64]		// default is ksFixedFromLeft WITHOUT any appended ksPopArrowText
	char	rightMode[64]	// default is ksFixedFromLeft
	char	topMode[64]		// default is ksFixedFromTop
	char	bottomMode[64]	// default is ksFixedFromTop
EndStructure


static Function GetControlResizeInfo(panelName, controlName, resizeInfo)
 	String panelName, controlName
	STRUCT WMResizeInfo &resizeInfo
	
	Variable hadInfo= 0
	String userdata = GetUserData(panelName, controlName, ksResizeUserDataName)
	if( strlen(userData)  )
		hadInfo= 1
		StructGet/S resizeInfo, userdata
		// if( ResizeInfo.version < kCurrentResizeInfoVersion )
		// here upgrade the structure to the current version
		// endif
	endif
	// Defaults are (Top/Left)
	if( strlen(resizeInfo.leftMode) == 0 )
		resizeInfo.leftMode= ksFixedFromLeft
	endif
	if( strlen(resizeInfo.rightMode) == 0 )
		resizeInfo.rightMode= ksFixedFromLeft
	endif
	if( strlen(resizeInfo.topMode) == 0 )
		resizeInfo.topMode= ksFixedFromTop
	endif
	if( strlen(resizeInfo.bottomMode) == 0 )
		resizeInfo.bottomMode= ksFixedFromTop
	endif
	return hadInfo
End

static Function GetGuideDelta(panelName,moveMode)
	String panelName
	String moveMode	// something like "Guide UGV1"

	Variable guideDelta= 0	// how much the guide has moved from its recorded position
	
	String guideName= StringFromList(1,moveMode, " ")

	String info= GuideInfo(panelName,guideName)
	Variable currentPosition= NumberByKey("POSITION",info)// in Absolute Panel coordinates
	String userdataGuideInfo = GetUserData(panelName, "", ksResizeUserDataName+guideName)	// GuideInfo recorded in userData, see SaveControlPositions
	if( strlen(userdataGuideInfo) )
		Variable originalPosition=NumberByKey("POSITION",userdataGuideInfo)
		guideDelta= currentPosition-originalPosition
	endif
	return guideDelta // in Absolute Panel coordinates!
End

// PanelCoordEdges is a panel-coordinate replacement for GetWindow wsizeDC.
// NOTE: using GetWindow wsize or wsizeDC based on PanelResolution(win) == 72
// will not work for a subwindow, because GetWindow Panel0#subwindow wsize
// will instead actually return GetWindow Panel0#subwindow wsizeDC.
//
// A control with these corner coordinates will fill the entire (sub)window.
//
// PanelCoordEdges works with Graph windows, too, but we don't recommend
// putting controls in graphs; put the controls in a panel subwindow within graphs.

Static Function PanelCoordEdges(win, vleft, vtop, vright, vbottom)
	String win	// can be "Panel0#P1", for example
	Variable &vleft, &vtop, &vright, &vbottom	// outputs, host window's left,top is 0,0

	vleft= NumberByKey("POSITION",GuideInfo(win,"FL"))
	vtop= NumberByKey("POSITION",GuideInfo(win,"FT"))
	vright= NumberByKey("POSITION",GuideInfo(win,"FR"))
	vbottom= NumberByKey("POSITION",GuideInfo(win,"FB"))
End

Static Function FitControlsToPanel(win)
	String win

	// We need the original size of window to compare with original positions of controls to generate offsets
	STRUCT WMResizeInfo resizeInfo
	String userdata = GetUserData(win, "", ksResizeUserDataName)
	if( strlen(userdata) == 0 )
		return 0
	endif
			
	StructGet/S resizeInfo, userdata
	Variable originalWinWidth=resizeInfo.originalWidth	// panel coordinates
	Variable originalWinHeight=resizeInfo.originalHeight	// ""
	
	Variable vleft, vtop, vright, vbottom	// outputs, host window's left,top is 0,0
	PanelCoordEdges(win, vleft, vtop, vright, vbottom)
	Variable winWidth= vright-vleft
	Variable winHeight= vbottom-vtop
	
	// adjustment amounts in panel coordinates
	Variable deltaWidth= winWidth - originalWinWidth
	Variable deltaHeight= winHeight - originalWinHeight
	
	String controls= ControlNameList(win)
	Variable i, n= ItemsInList(controls)
	for( i=0; i<n; i+=1 )
		String ctrlName= StringFromList(i,controls)
		
		if( !GetControlResizeInfo(win, ctrlName, resizeInfo) )
			continue
		endif
		
		// get dimensions as originally recorded, NOT current left, etc
		Variable origLeft= resizeInfo.originalLeft// panel coordinates
		Variable origTop= resizeInfo.originalTop
		Variable origWidth= resizeInfo.originalWidth
		Variable origHeight= resizeInfo.originalHeight
		
		Variable left= origLeft, top= origTop, width=origWidth, height= origHeight

		String leftAdjust= resizeInfo.leftMode
		String rightAdjust= resizeInfo.rightMode

		String topAdjust= resizeInfo.topMode
		String bottomAdjust= resizeInfo.bottomMode

		Variable leftNeedsAdjusting= 0	// both left and right can't be "Same Width"
		strswitch(leftAdjust)
			case ksFixedFromLeft:
				break
			case ksFixedFromRight:
				left += deltaWidth
				break
			case ksFixedFromMiddle:
				left += deltaWidth/2
				break
			case ksFixedFromPctWidth:
				left *= winWidth/originalWinWidth
				break
			case ksSameWidth:
				leftNeedsAdjusting= 1
				break
			default:	// user guide
				left +=GetGuideDelta(win,leftAdjust)
				break
		endswitch

		Variable right= origLeft + origWidth
		strswitch(rightAdjust)
			case ksFixedFromLeft:
				break
			case ksFixedFromRight:
				right += deltaWidth
				break
			case ksFixedFromMiddle:
				right += deltaWidth/2
				break
			case ksFixedFromPctWidth:
				right *= winWidth/originalWinWidth
				break
			case ksSameWidth:
				if( !leftNeedsAdjusting )	// if both left and right are set to SameWidth; leave the control where it is
					right = left + origWidth;
				endif
				break
			default:	// user guide
				right +=GetGuideDelta(win,rightAdjust)
				break
		endswitch
		if( leftNeedsAdjusting )
			width = origWidth
			left = right - width
		else
			width = right-left
		endif
		
		Variable topNeedsAdjusting= 0	// both top and bottom can't be "Same Height"
		strswitch(topAdjust)
			case ksFixedFromTop:
				break
			case ksFixedFromBottom:
				top += deltaHeight
				break
			case ksFixedFromCenter:
				top += deltaHeight/2
				break
			case ksFixedFromPctHeight:
				top *= winHeight / originalWinHeight
				break
			case ksSameHeight:
				topNeedsAdjusting= 1
				break
			default:	// user guide
				top +=GetGuideDelta(win,topAdjust)
				break
		endswitch
		
		Variable bottom= origTop+origHeight
		strswitch(bottomAdjust)
			case ksFixedFromTop:
				break
			case ksFixedFromBottom:
				bottom += deltaHeight
				break
			case ksFixedFromCenter:
				bottom += deltaHeight/2
				break
			case ksFixedFromPctHeight:
				bottom *= winHeight / originalWinHeight
				break
			case ksSameHeight:
				if( !topNeedsAdjusting )	// if both to and bottom are set to SameHeight; leave the control where it is
					bottom = top + origHeight;
				endif
				break
			default:	// user guide
				bottom += GetGuideDelta(win,bottomAdjust)
				break
		endswitch
		if( topNeedsAdjusting )
			height = origHeight
			top = bottom - height
		else
			height= bottom-top
		endif
		
		ControlInfo/W=$win $ctrlName
		Variable sizeChange= left != V_left || top != V_top || width != V_Width || height != V_Height
		if( sizeChange )
			ModifyControl $ctrlName, win=$win, pos={left,top},size={width,height}
		else
			ModifyControl $ctrlName, win=$win, pos={left,top}
		endif
	endfor
	
	return 1
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

Static Function ComputeNewPanelSize(win,minWidthPoints, maxWidthPoints, minHeightPoints, maxHeightPoints, neededWidthPoints, neededHeightPoints)
	String win	// this must be a top-level window
	Variable minWidthPoints, maxWidthPoints, minHeightPoints, maxHeightPoints
	Variable &neededWidthPoints, &neededHeightPoints	// outputs

	Variable resizeNeeded= 0
	DoWindow $win
	if( V_Flag )
		GetWindow $win wsize	// as a top-level window, wsize always returns coordinates in points.
		Variable widthPoints= (V_right-V_left)
		Variable heightPoints= (V_bottom-V_top)

		neededWidthPoints= min(max(widthPoints,minWidthPoints),maxWidthPoints)
		neededHeightPoints= min(max(heightPoints,minHeightPoints),maxHeightPoints)
		//resizeNeeded= (neededWidthPoints != widthPoints) || (neededHeightPoints != heightPoints)
		Variable slop = 1	// we're comparing floating point values in points now (not integer pixels, and truncation errors can build up
		resizeNeeded = (abs(neededWidthPoints-widthPoints) > slop) || (abs(neededHeightPoints-heightPoints) > slop)
	endif
	return resizeNeeded
End

Static Function LimitWindowSize(topWindow)
	String topWindow

	Variable resizePending = 0
	
	// opposite of SetWindow $panelName userdata($ksResizeUserDataName)=userData
	String userdata = GetUserData(topWindow, "", ksResizeUserDataName)
	if( strlen(userdata) )
		// get requested min sizes
		STRUCT WMResizeInfo resizeInfo
		StructGet/S resizeInfo, userdata
		Variable minWidth=resizeInfo.originalWidth	// panel coordinates (Igor 6 used/saved pixels here)
		Variable minHeight=resizeInfo.originalHeight

		// convert min sizes from panel coordinates to points, which is what MoveWindow understands
		Variable minWidthPoints = PanelCoordsToPoints(topWindow,minWidth)
		Variable minHeightPoints = PanelCoordsToPoints(topWindow,minHeight)

		// optionally enforce fixed panel width and/or height
		Variable maxWidthPoints= inf, maxHeightPoints=inf
		if( resizeInfo.fixedWidth )
			maxWidthPoints= minWidthPoints
		endif
		if( resizeInfo.fixedHeight )
			maxHeightPoints= minHeightPoints
		endif

		// either set min size or schedule a resize event.
#if IgorVersion() >= 7
		SetWindow $topWindow sizeLimit={minWidthPoints, minHeightPoints, maxWidthPoints, maxHeightPoints}
#else
		resizePending= LimitPanelSize(topWindow,minWidthPoints, maxWidthPoints, minHeightPoints, maxHeightPoints)
#endif
	endif

	return resizePending
End

Static Function LimitPanelSize(panelName, minWidthPoints, maxWidthPoints, minHeightPoints, maxHeightPoints)
	String panelName
	Variable minWidthPoints, maxWidthPoints, minHeightPoints, maxHeightPoints

	Variable neededWidthPoints,neededHeightPoints
	Variable resizePending= ComputeNewPanelSize(panelName,minWidthPoints, maxWidthPoints, minHeightPoints, maxHeightPoints, neededWidthPoints, neededHeightPoints)
	if( resizePending )
		// Eventually: MoveWindow/W=$win V_left, V_top, V_left+neededWidthPoints, V_top+neededHeightPoints
		// To prevent SetPanelSize commands from piling up, we set a flag that the minimizer has been scheduled to run.
		// To avoid global variables, we use userdata on the window being resized.
		String setPanelSizeScheduledStr= GetUserData(panelName,"","setPanelSizeScheduled")	// "" if never set (means "no")
		if( strlen(setPanelSizeScheduledStr) == 0 )
			SetWindow $panelName, userdata(setPanelSizeScheduled)= "yes"
			String cmd
			String module= GetIndependentModuleName()+"#ResizeControls#"
			sprintf cmd, "%sSetPanelSize(\"%s\",%g,%g,%g,%g)", module, panelName, minWidthPoints, maxWidthPoints, minHeightPoints, maxHeightPoints
			Execute/P/Q cmd	// after the functions stop executing, the SetPanelSize's call to MoveWindow will provoke another resize event.
		endif
	endif
	return resizePending	
End

Static Function SetPanelSize(panelName,minWidthPoints, maxWidthPoints, minHeightPoints, maxHeightPoints)
	String panelName
	Variable minWidthPoints, maxWidthPoints, minHeightPoints, maxHeightPoints

	Variable resizeNeeded= 0
	DoWindow $panelName
	if( V_Flag )
		Variable neededWidthPoints,neededHeightPoints
		resizeNeeded= ComputeNewPanelSize(panelName,minWidthPoints, maxWidthPoints, minHeightPoints, maxHeightPoints, neededWidthPoints, neededHeightPoints)
		if( resizeNeeded )
			GetWindow $panelName wsize
			MoveWindow/W=$panelName V_left, V_top, V_left+neededWidthPoints, V_top+neededHeightPoints
		endif
		SetWindow $panelName, userdata(setPanelSizeScheduled)= ""	// allow another call to SetPanelSize().
	endif
	return resizeNeeded	
End

// This is the hook function for resizing controls in client panels.
// We also use it for the editing panel itself
Static Function ResizeControlsHook(hs)
	STRUCT WMWinHookStruct &hs

	Variable statusCode= 0
	String rootWindow= StringFromList(0,hs.winName,"#")
	STRUCT WMResizeInfo resizeInfo
	String userdata
	Variable minWidth,minHeight
				
	strswitch(hs.eventName)
		case "activate":
		case "deactivate":
			SetWindow $rootWindow, userdata(setPanelSizeScheduled)= ""	// avoid locking out calls to SetPanelSize().
			break
		case "resize":
			if( !WindowIsMinimized(rootWindow) )
				Variable resizePending= LimitWindowSize(rootWindow)
				if( !resizePending )	// don't bother adjusting controls if another resize event is pending
					FitAllControlsToWin(rootWindow)
				endif
			endif
			// statusCode=1	// don't short-circuit other hooks
			break
	endswitch
	return statusCode
End

static Function WindowIsMinimized(win)
	String win
	
	GetWindow $win wsize
	Variable isMinimized = V_Left == 0 && V_Right == 0	// if true, the others are going to be zero, too.
	
	return isMinimized
End


Static Function FitAllControlsToWin(topWindow)
	String topWindow
	
	DoWindow $topWindow
	if( V_flag )
		String windows= ListOfChildWindows(topWindow)	// includes top/host window in list
		Variable i, n= ItemsInList(windows)
		for(i=0; i<n; i+=1 )
			String win= StringFromList(i,windows)
			FitControlsToPanel(win)
		endfor
	endif
End

// only child windows that can contain controls.
Static Function/S ListOfChildWindows(hostWindow)
	String hostWindow

	String list= hostWindow+";"

	Variable type= WinType(hostWindow)
	if( (type == 1) || (type == 7) )	// list only panels and graphs
		String subwindows= ChildWindowList(hostWindow)
		Variable i, n= ItemsInList(subwindows)
		for(i=0; i<n; i+=1 )
			String subwindow= hostWindow+"#"+StringFromList(i,subwindows)
			type= WinType(subwindow)
			if( (type == 1) || (type == 7) )	// list only panels and graphs
				list += ListOfChildWindows(subwindow)
			endif
		endfor
	endif

	return list
End