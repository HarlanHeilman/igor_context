#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=9.021			// shipped with Igor 9.02
#pragma IgorVersion=9			// For GetWindow wSizeForControls

#include <New Polar Graphs>

// 10/29/2004, JP, Version 5.03 - Initial version of Polar Cursors
// 11/12/2004, JP - used CsrInfo(), limited cursor angle to Angle Axes Range
// 9/17/2010, JP - Menu items disappear if the graph isn't a polar graph.
// 7/10/2013, JP - Repositioned Radius controls, used rtGlobals=3
// 11/7/2019, JP - Readout uses Label formatting functions, if any,
//							which necessitated using SetVariable controls instead of ValDisplays
// 6/1/2022, JP - Adjusted control positions for Windows compatibility.
// 2/24/2023, JP - Controls resize with polar graph resize
// 3/14/2023, JP - 9.021, removed debugging printing of control bar sizes.

// for menu definition: see New Polar Graphs.ipf.
Function/S WMPolarCursorsMenu()

	String menuText=""	// menu item disappears if not a polar graph
	if( WMPolarGraphDFExists("") )
		String graphName= WinName(0,1)
		if (WMHasPolarCursors(graphName) )
			menuText="Hide Polar Cursors"
		else
			menuText="Show Polar Cursors"
		endif
	endif
	return menuText
End

Function WMTogglePolarCursors()
	String graphName= WMPolarTopPolarGraph()
	
	if( strlen(graphName) )
		if (WMHasPolarCursors(graphName) )
			WMRemovePolarCursors()
		else
			WMShowPolarCursors()
		endif
	endif
End

Constant kCursorsBarHeight= 62
Constant kCursorsBarMargin= 9
Constant kCursorsGroupInset= 6
Constant kCursorsAngleInset= 3 // the Angle setvariable's left is this much greater than the Radius control

Function WMRemovePolarCursors()
	String graphName= WMPolarTopPolarGraph()
	
	if( strlen(graphName)==0 )
		DoAlert 0, "No polar graph was found!"
		return 0
	endif
	KillControl/W= $graphName aGroup
	KillControl/W= $graphName aRadius
	KillControl/W= $graphName aAngle
	KillControl/W= $graphName bGroup
	KillControl/W= $graphName bRadius
	KillControl/W= $graphName bAngle
	ControlBar/T/W=$graphName 0
	HideInfo/W=$graphName
	SetWindow $graphname hook(WMPolarCursors)=$""
End

Function WMShowPolarCursors()
	String graphName= WMPolarTopPolarGraph()
	
	if( strlen(graphName)==0 )
		DoAlert 0, "No polar graph was found!"
		return 0
	endif
	
	ControlBar/T/W=$graphName kCursorsBarHeight
	ShowInfo/W=$graphName
	
	GroupBox aGroup,win=$graphname,pos={9,0},size={130,57},title="A", frame=0
	SetVariable aRadius,win=$graphname,pos={15,16},size={119,19},bodyWidth=80,title="Radius"
	SetVariable aRadius,win=$graphname,limits={-inf,inf,0},value= _STR:"NaN",noedit= 1

	SetVariable aAngle,win=$graphname,pos={18,36},size={116,19},bodyWidth=80,title="Angle"
	SetVariable aAngle,win=$graphname,limits={-inf,inf,0},value= _STR:"NaN",noedit= 1

	GroupBox bGroup,win=$graphname,pos={147,0},size={130,57},title="B", frame=0

	SetVariable bRadius,win=$graphname,pos={153,16},size={119,19},bodyWidth=80,title="Radius"
	SetVariable bRadius,win=$graphname,limits={-inf,inf,0},value= _STR:"NaN",noedit= 1

	SetVariable bAngle,win=$graphname,pos={156,36},size={116,19},bodyWidth=80,title="Angle"
	SetVariable bAngle,win=$graphname,limits={-inf,inf,0},value= _STR:"NaN",noedit= 1

	WMPolarEnsureCursor( "A")
	WMPolarEnsureCursor( "B")
	
	WMPolarUpdateCursors(graphName)
	WMPolarResizeCursorControls(graphName)

	SetWindow $graphname hook(WMPolarCursors)=WMPolarCursors
End

Function WMPolarResizeCursorControls(graphName)
	String graphName
	
	if( WMHasPolarCursors(graphName) )
		GetWindow $graphName, wsizeForControls // honor panel expansion. Requires Igor 9
		Variable controlbarWidth = V_Right-V_Left
		ControlInfo/W=$graphName kwControlBar // sets V_Height
		// Stretch A and B groups over width of polar graph control bar with small margins all around
		// Constant kCursorsBarMargin= 9
		Variable groupWidth = (controlbarWidth - 3*kCursorsBarMargin)/2
		Variable left= kCursorsBarMargin
		GroupBox aGroup,win=$graphname,pos={left,0},size={groupWidth,57}

		// keep the current offsets between Radius and Angle to modify the left and size
		Variable angleOffset = kCursorsAngleInset
		
		left += kCursorsGroupInset
		Variable width = groupWidth - kCursorsGroupInset - kCursorsGroupInset
		SetVariable aRadius,win=$graphname,pos={left,16},size={width,19},bodyWidth=0

		left += angleOffset
		width -= angleOffset
		SetVariable aAngle,win=$graphname,pos={left,36},size={width,19},bodyWidth=0

		
		left= kCursorsBarMargin+groupWidth+kCursorsBarMargin
		GroupBox bGroup,win=$graphname,pos={left,0},size={groupWidth,57}

		left += kCursorsGroupInset
		width = groupWidth - kCursorsGroupInset - kCursorsGroupInset
		SetVariable bRadius,win=$graphname,pos={left,16},size={width,19},bodyWidth=0

		left += angleOffset
		width -= angleOffset
		SetVariable bAngle,win=$graphname,pos={left,36},size={width,19},bodyWidth=0
	endif
End

Function WMPolarEnsureCursor(cursorName)
	String  cursorName
	
	String graphName= WMPolarTopPolarGraph()

	if( strlen(CsrInfo($cursorName, graphName)) == 0 )
		// error if not on graph, put it on
		String traces= WMPolarTraceNameList(0)
		String firstTrace= StringFromList(0, traces)
		if( strlen(firstTrace) )
			Wave w=TraceNameToWaveRef(graphName, firstTrace)
			Variable xAttach= CmpStr(cursorName,"A") == 0 ? 0 : rightx(w)
			Cursor/W=$graphName $cursorName $firstTrace, xAttach
		endif
	endif
End

// call this when the radius function or ange function changes.
Function WMPolarUpdateCursors(graphName)
	String graphName
	
	WMPolarUpdateCursor(graphName, "A")
	WMPolarUpdateCursor(graphName, "B")
End

Function WMHasPolarCursors(graphName)
	String graphName
	
	DoWindow $graphName
	if( V_Flag )
		ControlInfo/W=$graphName aRadius
		return V_Flag
	endif
	return 0
End


Function WMPolarUpdateCursor(graphName, cursorName)
	String graphName, cursorName
	
	Variable radius=NaN, angle=NaN
	String radiusStr="NaN", angleStr="NaN"
	if( strlen(CsrInfo($cursorName, graphName))  )
		Variable xv = hcsr($cursorName, graphName)
		Variable yv= vcsr($cursorName, graphName)
		// invert:
		// drawnX= WMPolarRadiusFunction(radiusData,radiusFunctionStr,valueAtCenter) * cos(WMPolarAngleFunction(angleDataOrNull,zeroAngleWhereDegrees,angleDirection,anglePerCircle))
		// drawnY= WMPolarRadiusFunction(radiusData,radiusFunctionStr,valueAtCenter) * sin(WMPolarAngleFunction(angleDataOrNull,zeroAngleWhereDegrees,angleDirection,anglePerCircle))

		Variable drawnRadius= sqrt(yv*yv+xv*xv)
		Variable drawnAngle= atan2(yv,xv)		// radians

		String radiusFunction = WMPolarGraphGetStr(graphName,"radiusFunction")
		Variable valueAtCenter= WMPolarGraphGetVar(graphName,"valueAtCenter")

		radius= WMPolarRadiusFunctionInv(drawnRadius,radiusFunction,valueAtCenter)

		String radiusFormat = WMPolarGraphGetStr(graphName,"radiusTicklabelNotation")
		String radiusTickLabelSigns= WMPolarGraphGetStr(graphName,"radiusTickLabelSigns")
		radiusStr= WMPolarFormatNumber(radius, radiusFormat, radiusTickLabelSigns)

		Variable zeroAngleWhereDegrees= WMPolarGraphGetVar(graphName,"zeroAngleWhere")
		Variable angleDirection= WMPolarGraphGetVar(graphName,"angleDirection")
		// Variable anglePerCircle	= WMPolarGraphGetVar(graphName,"anglePerCircle")	// this converts back to the input data's units, not the displayed units.

		angle= WMPolarAngleFunctionInv(drawnAngle,zeroAngleWhereDegrees,angleDirection,2*pi)	// angle is in radians
		angle *= 180/pi	// degrees

		Variable angle0= WMPolarGraphGetVar(graphName,"angle0")	// degrees
		Variable angleRange=  WMPolarGraphGetVar(graphName,"angleRange")	// degrees
		
		// Add or subtract 360 degrees to put angle into the range from angle0 to angle0+angleRange
		if( angle >= angle0 && angle <= angle0+angleRange )
			;
		elseif( angle < angle0 && angle+360 <= angle0+angleRange )
			angle += 360
		elseif( angle > angle0+angleRange && angle-360 >= angle0 )
			angle -= 360
		elseif( angle > 180 )
			angle -= 360
		elseif( angle < -180 )
			angle += 360
		endif
				
		String angleTickLabelUnits = WMPolarGraphGetStr(graphName,"angleTickLabelUnits")
		strswitch( angleTickLabelUnits )
			case "degrees":
				break
			case "radians":
				angle *= pi/180	// radians again
				Variable angleTickLabelScale= WMPolarGraphGetVar(graphName,"angleTickLabelScale")
				angle *= angleTickLabelScale
				break
		endswitch
		String angleFormat = WMPolarGraphGetStr(graphName,"angleTicklabelNotation")
		String angleTickLabelSigns= WMPolarGraphGetStr(graphName,"angleTickLabelSigns")
		angleStr= WMPolarFormatNumber(angle, angleFormat, angleTickLabelSigns)
	endif

	String radiusName= cursorName+"Radius"
	String angleName= cursorName+"Angle"
	ControlInfo/W=$graphName $radiusName
	if( V_Flag )
		ReplaceValDisplayWithSetvar(graphName, radiusName)
		ReplaceValDisplayWithSetvar(graphName, angleName)
		SetVariable $radiusName,win=$graphname,value= _STR:radiusStr
		SetVariable $angleName,win=$graphname,value= _STR:angleStr
	endif
End


// Update old polar cursors without errors.
static Function ReplaceValDisplayWithSetvar(graphName, ctrlName)
	String graphName, ctrlName
	
	Variable replaced= 0
	
	ControlInfo/W=$graphName $ctrlName
	if( abs(V_Flag) == 4 ) // we have an old ValDisplay
		String title= ctrlName[1,99]
		Variable width = CmpStr(title,"Angle") == 0 ? 109 : 113
		KillControl/W=$graphName $ctrlName
		SetVariable $ctrlName,win=$graphname,pos={V_left,V_top},size={width,14},bodyWidth=80,title=title
		SetVariable $ctrlName,win=$graphname,limits={-inf,inf,0},value= _STR:"NaN",noedit= 1
		replaced= 1
	endif
	
	return replaced
End

Function WMPolarCursors(hs)
	STRUCT WMWinHookStruct &hs

	Variable ret= 0
	strswitch(hs.eventName)
		case "cursormoved":
			WMPolarUpdateCursor(hs.winName,  hs.cursorName)
			break
		case "resize":
			WMPolarResizeCursorControls(hs.winName)
			break
	endswitch

	return ret
End
