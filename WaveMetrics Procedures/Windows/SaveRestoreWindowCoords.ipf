#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion= 6.0	// Has fixed GetWindow/MoveWindow on PCs, has GetWindow wsizeRM
#pragma version=7		// Shipped with Igor 7
//
// SaveRestoreWindowCoords.ipf - Window Coordinates Save/Restore Utilities, based on window name.
// 
// Version 1.01, 5/02/2002, fixes for problem of panels on windows moving downwards with some Igors.
// Version 6.1, 3/4/2009, limiting the Igor to 6.0 means we no longer need to deal with broken GetWindow/MoveWindow issues.
//						Added WC_WindowCoordinatesNamedHook().
//						Also, using wsizeRM handles maximized windows better.
// Version 7, 4/20/2016, PanelResolution-based improvements for panels on high-resolution displays.
//							Added WC_WindowCoordinatesForget.
// Version 7, 5/23/2016, PanelResolution-based improvements: Restore won't use coordinates
// if the PanelResolution is different so as to avoid too-small or too-big panels.


//	WC_WindowCoordinatesHook
//
// Usage: SetWindow yourWindowName hook=WC_WindowCoordinatesHook
//
// or call WC_WindowCoordinatesSave() from your own window hook during the kill event
//
Function WC_WindowCoordinatesHook(infoStr)
	String infoStr

	Variable statusCode= 0
	String event= StringByKey("EVENT",infoStr)
	if( CmpStr(event,"kill") == 0 )
		String windowName= StringByKey("WINDOW",infoStr)
		WC_WindowCoordinatesSave(windowName)
	endif

	return statusCode
End

//	WC_WindowCoordinatesNamedHook
//
// Usage: SetWindow yourWindowName hook(someName)=WC_WindowCoordinatesNamedHook
//
// or call WC_WindowCoordinatesSave() from your own window hook during the kill event
//
Function WC_WindowCoordinatesNamedHook(hs)
	STRUCT WMWinHookStruct &hs

	Variable statusCode= 0
	strswitch(hs.eventName)
		case "kill":
			WC_WindowCoordinatesSave(hs.winName)
			break
	endswitch

	return statusCode
End

//
//	WC_WindowCoordinatesRestore
//
//	If coordinates for the named window have been saved,
//	the window is moved and sized accordingly, and 1 is returned.
//
//	If no coordinates are found, 0 is returned.
//
Function WC_WindowCoordinatesRestore(windowName)
	String windowName		// The named window must exist

	Variable restored= 0
	Variable vLeft, vTop, vRight, vBottom, panelRes
	if( WC_WindowCoordinatesGetNums(windowName, vLeft,vTop, vRight, vBottom, panelRes=panelRes) )
		if( panelRes == PanelResolution(windowName) )	// avoid restoring a too-small or too-big size
			MoveWindow/W=$windowName vLeft, vTop, vRight, vBottom
			restored= 1
		endif
	endif
	return restored
End


#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility between Igor 6 and 7
	String wName
	return 72
End
#endif


//
//	WC_WindowCoordinatesSave
//
Function WC_WindowCoordinatesSave(windowName)
	String windowName
	
	if( strlen(windowName) == 0 )
		windowName= WinName(0,255)
	endif
	DoWindow $windowName
	if( V_Flag == 0 )
		return 0
	endif
	// wsizeRM is useful on the PC, because a maximized window's restored size is returned instead of the maximized size.
	// wsizeRM generally returns the same as wsize, but these are the coordinates that would actually be used by a
	// recreation macro EXCEPT that the coordinates are in POINTS even if the window is a PANEL.
	// Also, if the window is minimized or maximized, the coordinates represent the window's restored location.
	// These coordinates are usually perfectly suited for use with MoveWindow.
	// Difficulties ensue with Panels due to legacy panels using pixels for panel window coordinates,
	// thus the PanelResolution code.
	GetWindow $windowName, wsizeRM
	WC_WindowCoordinatesSetNums(windowName, V_left, V_top, V_right, V_bottom)
	return 1
End


//
//	WC_WindowCoordinatesForget
//
Function WC_WindowCoordinatesForget(windowName)
	String windowName
	
	if( strlen(windowName) == 0 )
		windowName= WinName(0,255)
		DoWindow $windowName
		if( V_Flag == 0 )
			return 0
		endif
	endif
	WAVE/T/Z coords= $WC_DF_Var("W_windowCoordinates")
	if( WaveExists(coords) == 0 )
		return 0
	endif
	Variable row= WC_WindowCoordinatesRow(coords,windowName)
	if( row < 0 )
		return 0
	endif
	DeletePoints /M=0 row, 1, coords
	return 1
End

//
//	WC_WindowCoordinatesSetNums
//
// Window coordinates are saved in a multi-column text wave
// as windowname,num2istr(left),num2istr(top),num2istr(right),num2istr(bottom),num2istr(topOffset), etc.
//
// Saves coordinates for the named window, possibly adding a row to contain the window's coordinates.
// Returns the row of the named window.
//
Function WC_WindowCoordinatesSetNums(windowName, vLeft, vTop, vRight, vBottom)
	String windowName	// window must exist
	Variable vLeft, vTop, vRight, vBottom	// coordinates in points
	
	Variable row
	String dfSav= WC_SetDF()
	if( exists("W_windowCoordinates") != 1 )
		Make/O/T/N=(0,9) W_windowCoordinates
		WAVE/T coords= $WC_DF_Var("W_windowCoordinates")
		row= -1	// add new row
	else
		// search for matching row
		WAVE/T coords= $WC_DF_Var("W_windowCoordinates")
		row= WC_WindowCoordinatesRow(coords,windowName)
	endif
	if( row == -1 )
		InsertPoints/M=0 0,1,coords
		row= 0
	endif
	WC_EnsureDimLabels(coords) // also ensures necessary number of columns
	coords[row][0]=windowName
	coords[row][1]=num2str(vLeft)
	coords[row][2]=num2str(vTop)
	coords[row][3]=num2str(vRight)
	coords[row][4]=num2str(vBottom)
	// new columns for Igor 7.
	Variable panelRes= PanelResolution(windowName)	// 72 for Igor 6, 72 if SetIgorOption PanelResolution=1 and ScreenResolution = 96.	
	Variable screenRes= ScreenResolution
	coords[row][5]=num2str(panelRes)
	coords[row][6]=num2str(screenRes)
	// debugging
	coords[row][7]=num2str(vRight-vLeft)
	coords[row][8]=num2str(vBottom-vTop)
	
	SetDataFolder dfSav
	return row
End

//
//	WC_WindowCoordinatesGetNums
//
//	If coordinates for the named window were found,
//		stores the coordinates into the vXXX variables, and 1 is returned.
//	If not found,
//		the vXXX variables are unchanged, and 0 is returned.
//
Function WC_WindowCoordinatesGetNums(windowName, vLeft, vTop, vRight, vBottom, [usePixels, panelRes, screenRes, widthPoints, heightPoints])
	String windowName
	Variable &vLeft, &vTop, &vRight, &vBottom	// outputs, pass by reference, not by value
	Variable usePixels	// optional input: set to 0 for points, 1 for NewPanel coordinates, 2 for screen pixels

	Variable &panelRes, &screenRes, &widthPoints, &heightPoints	// optional outputs
	
	if( strlen(windowName) == 0 )
		return 0
	endif

	WAVE/T/Z coords= $WC_DF_Var("W_windowCoordinates")
	if( WaveExists(coords) == 0 )
		return 0
	endif

	Variable row= WC_WindowCoordinatesRow(coords,windowName)
	if( row < 0 )
		return 0
	endif

	vLeft= str2num(coords[row][1])	// points (GetWindow wsizeRM). Sets output vLeft
	vTop= str2num(coords[row][2])		// 
	vRight= str2num(coords[row][3])
	vBottom= str2num(coords[row][4])

	if( ParamIsDefault(usePixels) )
		usePixels= 0
	endif
	
	Variable pRes
	if( DimSize(coords,1) >= 6 && strlen(coords[row][5]) )
		pRes= str2num(coords[row][5])
	else
		pRes= PanelResolution("")
	endif

	if( !ParamIsDefault(panelRes) )
		panelRes= pRes
	endif

	Variable sRes
	if( DimSize(coords,1) >= 7 && strlen(coords[row][6]) )
		sRes= str2num(coords[row][6])
	else
		sRes= ScreenResolution
	endif

	if( !ParamIsDefault(screenRes) )
		screenRes= sRes
	endif

	if( !ParamIsDefault(widthPoints) )
		if( DimSize(coords,1) >= 8 && strlen(coords[row][7]) )
			widthPoints= str2num(coords[row][7])
		else
			widthPoints= vRight-vLeft
		endif
	endif
	
	if( !ParamIsDefault(heightPoints) )
		if( DimSize(coords,1) >= 9 && strlen(coords[row][8]) )
			heightPoints= str2num(coords[row][8])
		else
			heightPoints= vBottom-vTop
		endif
	endif

	Variable scale= 1
	if( usePixels == 1 )
		// Legacy calls to WC_WindowCoordinatesGetStr are intended to get here.
		// points for panels
		// used for window restoration when panel coords are needed, as for NewPanel.
		//scale= ScreenResolution / PanelResolution(windowName)	 NO: this assumes that the stored PanelResolution and ScreenResolution are the same as now
		scale = sRes/pRes	// convert saved points to panel resolution as it was saved.	
		// scale is usually 1 (SetIgorOption PanelResolution = 0)
		// or 4/3 on Windows (SetIgorOption PanelResolution = 1 with ScreenResolution==96 && PanelResolution() == 72)
	elseif( usePixels == 2 )
		// convert from saved points to current pixels
		scale= ScreenResolution/72
	endif

	// You can back-compute the value of scale, because widthPoints is NOT scaled: 
	// scale = (vRight-vLeft) / widthPoints
	
	vLeft *= scale
	vTop *= scale
	vRight *= scale
	vBottom *= scale

	return 1
End


// WC_WindowCoordinatesGetStr returns "" or the coordinates separated by commas
// prints window coordinates into the returned string.
//
// See also: WC_WindowCoordinatesSprintf()
//
Function/S WC_WindowCoordinatesGetStr(windowName,usePixels)
	String windowName
	Variable usePixels

	String coordinates= ""
	Variable vLeft, vTop, vRight, vBottom
	if( WC_WindowCoordinatesGetNums(windowName, vLeft, vTop, vRight, vBottom, usePixels=usePixels) )
		sprintf coordinates, "%g, %g, %g, %g", vLeft, vTop, vRight, vBottom
	endif
	return coordinates
End

// WC_WindowCoordinatesSprintf
//
// %s in fmt is replaced with left,top,right,bottom,
// either the saved coordinates, or else the supplied defaults.
//
// Examples:
//
// String fmt="Display/W=(%s) as \"the title\""
// Execute WC_WindowCoordinatesSprintf("eventualGraphName",fmt,x0,y0,x1,y1,0)	// points
//
// String fmt="NewPanel/W=(%s)"
// Execute WC_WindowCoordinatesSprintf("eventualPanelName",fmt,x0,y0,x1,y1,1)	// NewPanel units, pixels if PanelResolution == 72, else points
//
Function/S WC_WindowCoordinatesSprintf(windowName,fmt,defLeft,defTop,defRight,defBottom,wantPixels)
	String windowName,fmt
	Variable defLeft,defTop,defRight,defBottom
	Variable wantPixels	// set to 0 for points, 1 for NewPanel coordinates, 2 for screen pixels. The defaults are already using these units.

	Variable storedLeft= defLeft, storedTop=defTop, storedright=defRight, storedBottom=defBottom
	Variable storedPanelRes, storedScreenRes
	Variable haveStored = WC_WindowCoordinatesGetNums(windowName, storedLeft, storedTop, storedright, storedBottom, usePixels=wantPixels, panelRes=storedPanelRes, screenRes=storedScreenRes)
	
	if( haveStored && storedPanelRes == PanelResolution(windowName) ) // avoid restoring too-small or too-big panels when PanelResolution changes.
		defLeft= storedLeft
		defTop= storedTop
		defRight= storedRight
		defBottom= storedBottom
	endif
	String coordinates
	sprintf coordinates, "%g, %g, %g, %g",defLeft,defTop,defRight,defBottom
	String result
	Sprintf result, fmt, coordinates	// %s in fmt is replaced with left,top,right,bottom
	return result
End

Function WC_WindowCoordinatesRow(coords,windowName)
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
End


Function/S WC_DF()
	return "root:Packages:WindowCoordinates"
End

Function/S WC_SetDF()
	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S $WC_DF()
	return oldDF
End

Function/S WC_DF_Var(varName)
	String varName
	return WC_DF()+":"+varName
End

Static Function WC_EnsureDimLabels(coords)
	WAVE/T coords

	Variable oldColumns= DimSize(coords,1)
	if( oldColumns < 9 )
		Redimension/N=(-1,9) coords	// in case we're updating a 1.01 version of the wave or a zero-point wave
	endif
	SetDimLabel 1, 0, windowName, coords
	SetDimLabel 1, 1, left, coords
	SetDimLabel 1, 2, top, coords
	SetDimLabel 1, 3, right, coords
	SetDimLabel 1, 4, bottom, coords
	// new columns for Igor 7.
	SetDimLabel 1, 5, panelRes, coords	// PanelResolution(windowName) when saved, can be 72 even when 
	SetDimLabel 1, 6, screenRes, coords // ScreenResolution is 96 (or other value)
	// debugging
	SetDimLabel 1, 7, widthPoints, coords
	SetDimLabel 1, 8, heightPoints, coords
End
	
