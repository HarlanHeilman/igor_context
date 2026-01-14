#pragma rtGlobals=3		// Use modern global access method.
#pragma IgorVersion=6		// for subwindow syntax
#pragma version=9			// released with Igor 9

// Axis Utilities.ipf
//
// 06/28/2002 JP: added AxisForTrace() and AxisUnitsInGraph(), removed need for "Strings as Lists" include.
// 08/01/2002 JP: made compatible with Igor 3.1-mode (Silent 100) experiments.
// 03/04/2003 JP, version 1.1:  added AxisLabelText().
// 07/16/2003 JP, version 1.2:  added PixelFromLinearAxisVal().
// 12/12/2003 JW, version 1.21: requires Igor 5. Added optional parameter to AxisLabelText to suppress the escaping of backslashes.
// 06/18/2004 JW, version 1.22: corrected default initialization syntax in AxisLabelText().
// 03/08/2007 JP, version 1.23: HVAxisList() no longer enters infinite loop if the named graph doesn't exist.
// 07/05/2007 JP, version 6.02: This version released with Igor 6.02.
//										HVAxisList() once again allows "" to mean "top graph".
//										Now AxisForTrace() allows "" to mean "top graph".
//										PixelFromLinearAxisVal() uses the built-in PixelFromAxisVal which requires Igor 5.02.
//										
// 07/05/2007 JP, version 6.02: This version released with Igor 6.02.
// 09/02/2015 JP, version 6.38: Added support for graphs in subwindows; graphName can be "Panel0#G0", for example.
// 09/02/2015 JP, version 8.04: AxisLabelText() fix finds the right axis when the name is a prefix of a longer axis name.
// 12/28/2020 JP, version 9: 	AxisLabel() is built into Igor 9. A version of AxisLabel is implemented here for compatibility.

// Returns list of axes with the requested orientation.
Function/S HVAxisList(graphName,wantHorizAxes)
	String graphName			// "" for top graph (same as WinName(0,1)
	Variable wantHorizAxes	// 0 for vertical (left, right, etc), 1 for horizontal (bottom, top, etc).
	
	String hvlist=""
	
	if( strlen(graphName) == 0 )
		graphName= WinName(0,1)
	endif
	
	if( strlen(graphName) )
		Variable type= WinType(graphName)
		if( type == 1 )
			String axlist=AxisList(graphName)
			Variable index=0
			do
				String axis= StringFromList(index,axlist)
				if (strlen(axis) == 0)
					break								// ran out of items
				endif
				String info=AxisInfo(graphName,axis)
				if( AxisOrientation(info,wantHorizAxes) )
					hvlist += axis + ";"
				endif
				index += 1
			while (1)		// loop until break above
		endif
	endif
	return hvlist
End

// Returns 1 if axis has desired orientation, else returns 0
Function AxisOrientation(axInfo,wantHorizAxes)
	String axInfo				// AxisInfo
	Variable wantHorizAxes	// 0 for vertical (left, right, etc), 1 for horizontal (bottom, top, etc).

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

// returns axis units, which often are ""
Function/S AxisUnitsInGraph(graphName,axis)
	String graphName	// "" for top graph
	String axis

	String units=""

	if( strlen(graphName) == 0 )
		graphName= WinName(0,1)
	endif
	
	if( strlen(graphName) )
		//DoWindow $graphName
		Variable type= WinType(graphName)
		if( type == 1 )
			String info=AxisInfo(graphName,axis)
			Variable st= strsearch(info,"UNITS:",0)
			if( st >= 0 )
				Variable en= strsearch(info,";",st)
				if( en > st )
					units=info[st+6,en-1]
				endif
			endif
		endif
	endif
	return units
End


// returns axis units, which often are ""
Function/S AxisUnits(axis)
	String axis

	return AxisUnitsInGraph(WinName(0,1),axis)
End

// Returns the text of the axis label.
// If optional parameter SuppressEscaping is non-zero, extra backslashes are removed
// ("\\" is required  to include a single backslash in a quoted string)
// so that the result is a string suitable to be passed directly to the Label operation. 
Function/S AxisLabelText(graphName, axisName, [SuppressEscaping])
	String graphName, axisName
	Variable SuppressEscaping
	
	if (ParamIsDefault(SuppressEscaping))
		SuppressEscaping = 0
	endif

	String lbl=""
#if exists("AxisLabel") == 3
	Variable wantSlashes = SuppressEscaping == 0 // built-in and user functions have opposite polarity for 3rd parameter.
	lbl = AxisLabel(graphName, axisName, wantSlashes)
#else	
	String info= WinRecreation(graphName,0)
	Variable start= strsearch(info, "\tLabel "+axisName+" ", 0) // 8/04: +" " avoids matching an axis that starts with axisName
	if( start >= 0 )
		start = strsearch(info, "\"", start)+1
		Variable theEnd= strsearch(info, "\"", start)-1
		lbl= info[start,theEnd]
	endif
	if (SuppressEscaping)
		start = 0
		do
			start = strsearch(lbl, "\\\\", start)	// search for double backslash
			if (start >= 0)
				string newLabel = lbl[0,start-1]
				newLabel += lbl[start+1, strlen(lbl)-1]
				lbl = newLabel
			else
				break
			endif
		while(1)
	endif
#endif
	return lbl
End

#if exists("AxisLabel") != 3
Function/S AxisLabel(graphName, axisName, wantSlashes)
	String graphName, axisName
	Variable wantSlashes	// unlike the built-in routine, all three parameters must be passed.
	
	Variable SuppressEscaping = wantSlashes == 0 // built-in and user functions have opposite polarity for 3rd parameter.
	String lbl = AxisLabelText(graphName, axisName, SuppressEscaping=SuppressEscaping)
	return lbl
End
#endif

// TraceAxis() returns a string containing the X or Y axis of the named trace.
Function/S AxisForTrace(graphName,traceName,instance,wantYAxis)
	String graphName		// As of Igor 6.02, can be "" for top graph
	String traceName		// name of trace, can use trace#instance if instance is 0
	Variable instance		// 0 is first instance, 1 is second, ...
	Variable wantYAxis
 
	if( strlen(graphName) == 0 )
		graphName= WinName(0,1)
	endif
	
	if( strlen(graphName) )
		//DoWindow $graphName
		Variable type= WinType(graphName)
		if( type == 1 )
			String info=TraceInfo(graphName,traceName,instance)
			Variable start
			if( wantYAxis )
				start= strsearch(info,"YAXIS:",0)
			else
				start= strsearch(info,"XAXIS:",0)
			endif
			if( start < 0 )
				return ""
			endif
			start += 6
			Variable theEnd= strsearch(info,";",start)
			if( (start >= 0) %& (theEnd >= start) )
				return info[start,theEnd-1]
			endif
		endif
	endif
	return ""
End

//
// inverse of built-in AxisValFromPixel(graphName, axisName, pixel)
//
Function PixelFromLinearAxisVal(graphName, axisName, axisVal)
	String graphName, axisName
	Variable axisVal
	
	if( strlen(graphName) == 0 )
		graphName= WinName(0,1)
		if( strlen(graphName) == 0 )
			return NaN	// no graphs
		endif
	endif

	//DoWindow $graphName
	Variable type= WinType(graphName)
	if( type != 1 )
		return NaN	// no such graph
	endif

	return PixelFromAxisVal(graphName, axisName, axisVal)	// Igor 5.02, now works with log axes, too.
End


